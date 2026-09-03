import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/mock/mock_crm_data.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/product.dart';
import '../app_date.dart';
import '../const.dart';
import '../crm/provider.dart';
import '../crm/model.dart';
import '../products/product_icons.dart';
import '../quote/quote_providers.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_selection_chip.dart';
import '../widgets/chip.dart';
import '../widgets/quote_field.dart';
import '../widgets/app_segmented_tabs.dart';
import '../widgets/soft_card.dart';
import 'address_master.dart';
import 'applicant.dart';
import 'applicant_card.dart';
import 'eapp_status.dart';
import 'pickers.dart';

class EAppScreen extends ConsumerStatefulWidget {
  const EAppScreen({
    super.key,
    this.productCode,
    this.customerId,
    this.renewalPolicyNo,
    this.initialStep,
    this.correctionNote,
    this.crmName,
    this.crmPhone,
    this.crmEmail,
  });
  final String? productCode;

  /// Doc 111 §2.3 — the CRM lead/client this application is being written
  /// for. When set, the Policy Holder step arrives prefilled from that
  /// record instead of asking the FA to retype what they already entered.
  final String? customerId;

  /// Doc 81 — e-App can also be entered from a policy row's "Renew"
  /// action; when set, this is a renewal application, not a new sale.
  final String? renewalPolicyNo;

  /// Doc 26 §4.3 — "Mark for Correction" resume flow: the App tracker /
  /// status detail can re-enter this same stepper directly at the step
  /// that needs a fix, instead of restarting from step 1.
  final int? initialStep;

  /// UW's correction note, shown as a banner while resuming — cleared
  /// once the FA continues past the flagged step.
  final String? correctionNote;

  /// CRM contact data passed directly (from CRMContactModel)
  final String? crmName;
  final String? crmPhone;
  final String? crmEmail;

  @override
  ConsumerState<EAppScreen> createState() => _EAppScreenState();
}

enum _EStep {
  proposal,
  policyHolder,
  insuredPerson,
  productInfo,
  beneficiaries,
  healthDeclaration,
  documentation,
  sign,
  review,
}

const _stepTitleMap = {
  _EStep.proposal: 'Proposal',
  _EStep.policyHolder: 'Policy Holder',
  _EStep.insuredPerson: 'Insured Person',
  _EStep.productInfo: 'Product Information',
  _EStep.beneficiaries: 'Beneficiaries',
  _EStep.healthDeclaration: 'Health Declaration',
  _EStep.documentation: 'Documentation',
  _EStep.sign: 'Sign',
  _EStep.review: 'Review',
};

class _EAppScreenState extends ConsumerState<EAppScreen> {
  late int _step = (widget.initialStep ?? 0).clamp(
    0,
    _activeStepTitles.length - 1,
  );
  String? _selectedProductCode;
  String? _selectedCustomerId;

  /// Doc 111 §2 — the Start step is skipped only for the two doors that
  /// genuinely know all three slots already: a renewal (product and terms
  /// come from the in-force policy) and a "Fix now" resume from the
  /// tracker, which re-enters an application that is already underway.
  late bool _startDone =
      widget.renewalPolicyNo != null || widget.initialStep != null;
  EappStatus _status = EappStatus.draft;

  // Doc 26 §4.3 "Fix now" resume flow — the correction banner stays
  // visible until the FA moves off the flagged step, so it's clear which
  // step UW is pointing at.
  late String? _correctionNote = widget.correctionNote;

  // Doc 111 §3 — one shared applicant model per party; each carries its
  // own Person/Entity type, field set and captured documents.
  final Applicant _holder = Applicant(role: ApplicantRole.policyHolder);
  final Applicant _insured = Applicant(role: ApplicantRole.insured);

  /// Doc 111 §2.3 — the linked customer, and the holder fields that came
  /// from their record. Prefill is never silent: [_prefilledKeys] drives
  /// the per-field "From lead record" marker and the banner count, and a
  /// key drops out the moment the FA edits that field away from the value
  /// the lead supplied.
  String? _prefilledFrom;
  final Map<String, String> _prefillValues = {};
  Set<String> get _prefilledKeys {
    if (_prefilledFrom == null) return const {};
    return {
      for (final entry in _prefillValues.entries)
        if (_currentHolderValue(entry.key) == entry.value) entry.key,
    };
  }

  String _currentHolderValue(String key) => switch (key) {
    'name' => _holder.nameController.text,
    'mobile' => _holder.mobileController.text,
    'email' => _holder.emailController.text,
    'nrc' => _holder.idNoController.text,
    'occupation' => _holder.occupationController.text,
    'address' => _holder.addressSummary ?? '',
    _ => '',
  };

  // BRD Section 4 — Proposal tab (auto-populated fields are mocked, as
  // there is no real Core/branch API in this prototype).
  final String _proposalNo =
      'PRP-${DateTime.now().millisecondsSinceEpoch % 900000 + 100000}';
  String _branchOffice = kBranchOffices.first;
  DateTime? _requestPolicyDate;
  String _notifyType = 'Not Notify';
  final _notifyMobileController = TextEditingController();
  final _referralController = TextEditingController();
  bool _specialCase = false;
  final _specialRemarkController = TextEditingController();

  // BRD "Proposal Validation Message" sheet — the field-level validators
  // now live in [ApplicantValidators] so the Policy Holder, Insured and
  // Beneficiary cards, which share one renderer, cannot drift apart.

  /// Accepts a product code or a product name and returns the code. CRM
  /// opportunities carry loose product labels ("Health Insurance",
  /// "Education Plan") rather than catalogue names, so an exact match is
  /// tried first and then the closest catalogue product by shared words —
  /// without it the Start step opens with no product and no estimate.
  static String? _resolveProductCode(String? codeOrName) {
    final query = codeOrName?.trim().toLowerCase() ?? '';
    if (query.isEmpty) return null;

    for (final p in MockData.products) {
      if (p.code.toLowerCase() == query || p.name.toLowerCase() == query) {
        return p.code;
      }
    }

    const filler = {'insurance', 'plan', 'policy', 'the', 'a'};
    Set<String> words(String v) => v
        .toLowerCase()
        .split(RegExp(r'[^a-z]+'))
        .where((w) => w.isNotEmpty && !filler.contains(w))
        .toSet();

    final queryWords = words(query);
    String? best;
    var bestScore = 0;
    for (final p in MockData.products) {
      final score = words(p.name).intersection(queryWords).length;
      if (score > bestScore) {
        bestScore = score;
        best = p.code;
      }
    }
    return best;
  }

  Product get _product => MockData.products.firstWhere(
    (p) => p.code == _selectedProductCode,
    orElse: () => MockData.products.first,
  );

  // Health Declaration only applies to health products — every other step
  // stays fixed regardless of the selected product.
  List<_EStep> get _activeSteps => [
    _EStep.proposal,
    _EStep.policyHolder,
    _EStep.insuredPerson,
    _EStep.productInfo,
    _EStep.beneficiaries,
    if (_product.category == ProductCategory.health) _EStep.healthDeclaration,
    _EStep.documentation,
    _EStep.sign,
    _EStep.review,
  ];

  List<String> get _activeStepTitles => [
    for (final s in _activeSteps) _stepTitleMap[s]!,
  ];

  // BRD Section 4 — Insured Person tab.
  bool _insuredSameAsHolder = false;

  // BRD Section 4 — Beneficiary tab: multiple beneficiaries, percentages
  // must sum to <=100%.
  final List<Applicant> _beneficiaries = [
    Applicant(role: ApplicantRole.beneficiary),
  ];

  // BRD Section 4 — Health Declaration: simple Yes/No questionnaire; any
  // "Yes" answer requires a Remark.
  final Map<String, bool> _healthAnswers = {
    'Have you ever been diagnosed with any major illness?': false,
    'Are you currently under medical treatment?': false,
    'Have you had any surgery in the last 5 years?': false,
  };
  final _healthRemarkController = TextEditingController();

  // Doc 91 — Client and Agent are two isolated pads, each with its own
  // controller. Agent stays locked until Client has real (non-tap) ink,
  // and clearing Client wipes + re-locks Agent.
  final _clientSig = SignatureController(
    penStrokeWidth: 2.4,
    penColor: AppColors.deep,
  );
  final _agentSig = SignatureController(
    penStrokeWidth: 2.4,
    penColor: AppColors.deep,
  );
  bool _clientHasInk = false;
  bool _agentHasInk = false;
  String _clientSigMode = 'esign';
  String _agentSigMode = 'esign';
  dynamic _clientSigPhoto;
  dynamic _agentSigPhoto;

  @override
  void initState() {
    super.initState();
    // Entry points are not consistent: products and quotes pass a product
    // code, CRM passes the opportunity's product *name*. Resolve either one
    // to a code here so the Start step arrives with the product filled and
    // its premium already estimated.
    _selectedProductCode = _resolveProductCode(widget.productCode);
    _selectedCustomerId = widget.customerId;
    // Doc 81 renewal — the in-force policy already names the product, so
    // the FA is never asked to re-pick it.
    final renewal = widget.renewalPolicyNo;
    if (renewal != null) {
      final policy = MockCrmData.policies
          .where((p) => p.policyNo == renewal)
          .firstOrNull;
      _selectedProductCode ??= policy?.productCode;
    }
    if (_startDone) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _applyCustomerPrefill(),
      );
    }
    _applyCrmPrefill();
    _clientSig.addListener(() {
      final hasInk = _clientSig.isNotEmpty && _clientSig.points.length >= 8;
      if (hasInk != _clientHasInk) setState(() => _clientHasInk = hasInk);
    });
    _agentSig.addListener(() {
      final hasInk = _agentSig.isNotEmpty && _agentSig.points.length >= 8;
      if (hasInk != _agentHasInk) setState(() => _agentHasInk = hasInk);
    });
  }

  /// Copies everything the lead/client record already knows onto the
  /// Policy Holder card. Father's name, DOB and gender are deliberately
  /// absent — the CRM record does not carry them (doc 111 §2.3).
  /// CRM stores phone numbers the way they are read out — "09-123-456-789".
  /// The proposal validators want the bare digits ("09" + 7 or more), so a
  /// prefilled number is stripped here rather than failing on the Insured
  /// step with "Please enter correct mobile no."
  static String? _plainPhone(String? v) => v?.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _applyCustomerPrefill() async {
    final id = _selectedCustomerId;
    if (id == null) return;

    void fill(String key, TextEditingController c, String? value) {
      final v = value?.trim() ?? '';
      if (v.isEmpty) return;
      c.text = v;
      _prefillValues[key] = v;
    }

    final controller = ref.read(crmControllerProvider.notifier);
    final customer = controller.byId(id) ?? controller.byName(id);

    if (customer != null) {
      _prefilledFrom = customer.name;
      fill('name', _holder.nameController, customer.name);
      fill('mobile', _holder.mobileController, _plainPhone(customer.phone));
      fill('email', _holder.emailController, customer.email);
      fill('nrc', _holder.idNoController, customer.nrc);
      fill('occupation', _holder.occupationController, customer.jobTitle);
      _holder.maritalStatus = customer.maritalStatus;
      _holder.remarkController.text = customer.remark ?? '';

      _holder.roomNoController.text = customer.roomNo ?? '';
      _holder.buildingNoController.text = customer.buildingNo ?? '';
      _holder.houseNoController.text = customer.houseNo ?? '';
      _holder.streetNoController.text = customer.streetNo ?? '';
      _holder.wardNoController.text = customer.wardNo ?? '';
      _holder.townshipController.text = customer.township ?? '';
      _holder.stateRegionController.text = customer.stateRegion ?? '';
      final address = _holder.addressSummary;
      if (address != null) _prefillValues['address'] = address;
    } else {
      // The CRM contact list is the other source of a linked record, and
      // its IDs are its own — match on either ID or name before giving up.
      final contacts = await ref.read(crmContactsProvider.future);
      final match = contacts
          .where((c) => c.id == id || c.name == id)
          .firstOrNull;
      if (match == null) return;

      _prefilledFrom = match.name;
      fill('name', _holder.nameController, match.name);
      fill('mobile', _holder.mobileController, _plainPhone(match.phone));
      fill('email', _holder.emailController, match.email);
      fill('fatherName', _holder.fatherNameController, match.fatherName);
      fill('nrc', _holder.idNoController, match.nrc);
      fill('occupation', _holder.occupationController, match.occupation);
      if (match.dob != null) {
        _holder.dob = match.dob;
        _prefillValues['dob'] = _formatDate(match.dob!);
      }
      if (match.gender != null) {
        _holder.gender = match.gender;
        _prefillValues['gender'] = match.gender!;
      }
      _holder.maritalStatus ??= match.maritalStatus;

      _holder.houseNoController.text = match.houseNo ?? '';
      _holder.streetNoController.text = match.streetNo ?? '';
      _holder.wardNoController.text = match.wardNo ?? '';
      _holder.townController.text = match.town ?? '';
      _holder.townshipController.text = match.township ?? '';
      _holder.districtController.text = match.district ?? '';
      _holder.stateRegionController.text = match.stateRegion ?? '';
      final address = _holder.addressSummary;
      if (address != null) _prefillValues['address'] = address;
    }

    // The cards read their values from controllers, but the prefill banner
    // and the marital-status chips are plain state — repaint them.
    if (mounted) setState(() {});
  }

  void _applyCrmPrefill() {
    final name = widget.crmName;
    if (name == null || name.isEmpty) return;

    // Don't override if already prefilled from Customer
    if (_prefilledFrom != null) return;

    _prefilledFrom = name;
    void fill(String key, TextEditingController c, String? value) {
      final v = value?.trim() ?? '';
      if (v.isEmpty) return;
      c.text = v;
      _prefillValues[key] = v;
    }

    fill('name', _holder.nameController, name);
    fill('mobile', _holder.mobileController, _plainPhone(widget.crmPhone));
    fill('email', _holder.emailController, widget.crmEmail);
  }

  @override
  void dispose() {
    _clientSig.dispose();
    _agentSig.dispose();
    _notifyMobileController.dispose();
    _referralController.dispose();
    _specialRemarkController.dispose();
    _healthRemarkController.dispose();
    _holder.dispose();
    _insured.dispose();
    for (final b in _beneficiaries) {
      b.dispose();
    }
    super.dispose();
  }

  void _clearClient() {
    _clientSig.clear();
    _agentSig.clear();
  }

  Future<void> _pickSignaturePhoto({required bool isClient}) async {
    final source = await showImageSourceSheet(
      context,
      title: 'Signature photo',
    );
    if (source == null || !mounted) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked == null) return;
    final ext = picked.path.split('.').last.toLowerCase();
    if (!_allowedExt.contains('.$ext')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only JPG, PNG, PDF files are allowed.')),
      );
      return;
    }
    final file = await picked.length();
    if (file > 5 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File size must be under 5 MB.')),
      );
      return;
    }
    setState(() {
      if (isClient) {
        _clientSigPhoto = picked;
      } else {
        _agentSigPhoto = picked;
      }
    });
  }

  // BRD Section 3 — mock file-type/size validation on any document
  // capture: only image files are accepted, and a mock 5MB cap applies
  static const _allowedExt = {'.jpg', '.jpeg', '.png', '.pdf'};

  Future<void> _captureBeneficiaryDocument(
    Applicant beneficiary,
    String documentPart,
  ) async {
    final source = await showImageSourceSheet(
      context,
      title: documentPart == 'passport' ? 'Passport photo' : 'NRC photo',
    );
    if (source == null || !mounted) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked == null) return;
    final ext = picked.name.contains('.')
        ? picked.name.substring(picked.name.lastIndexOf('.')).toLowerCase()
        : '';
    if (!_allowedExt.contains(ext)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid File Type')));
      }
      return;
    }
    final bytes = await picked.length();
    if (bytes > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File size is too large.')),
        );
      }
      return;
    }
    setState(() {
      switch (documentPart) {
        case 'nrc-front':
          beneficiary.nrcFrontPhoto = picked;
        case 'nrc-back':
          beneficiary.nrcBackPhoto = picked;
        case 'passport':
          beneficiary.passportPhoto = picked;
      }
    });
  }

  Future<void> _captureDocument(
    String targetPerson,
    String documentPart,
  ) async {
    // Asked per slot, in a sheet: Camera or Upload, the same two choices
    // the Sign step offers — an NRC photographed before the appointment is
    // as good as one taken during it.
    final source = await showImageSourceSheet(
      context,
      title: documentPart == 'passport' ? 'Passport photo' : 'NRC photo',
    );
    if (source == null || !mounted) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked == null) return;
    final ext = picked.name.contains('.')
        ? picked.name.substring(picked.name.lastIndexOf('.')).toLowerCase()
        : '';
    if (!_allowedExt.contains(ext)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid File Type')));
      }
      return;
    }
    final bytes = await picked.length();
    if (bytes > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File size is too large.')),
        );
      }
      return;
    }
    setState(() {
      if (targetPerson == 'holder') {
        switch (documentPart) {
          case 'nrc-front':
            _holder.nrcFrontPhoto = picked;
          case 'nrc-back':
            _holder.nrcBackPhoto = picked;
          case 'passport':
            _holder.passportPhoto = picked;
        }
      } else if (targetPerson == 'insured') {
        switch (documentPart) {
          case 'nrc-front':
            _insured.nrcFrontPhoto = picked;
          case 'nrc-back':
            _insured.nrcBackPhoto = picked;
          case 'passport':
            _insured.passportPhoto = picked;
        }
      }
    });
  }

  /// Doc 115 §4 — clearing a slot is a local mutation, not a camera trip,
  /// so it lives apart from [_captureDocument] and is instant.
  void _removeDocument(Applicant a, String documentPart) {
    setState(() {
      switch (documentPart) {
        case 'nrc-front':
          a.nrcFrontPhoto = null;
        case 'nrc-back':
          a.nrcBackPhoto = null;
        case 'passport':
          a.passportPhoto = null;
      }
    });
  }

  /// A signature counts either way it was given: drawn on the pad, or
  /// uploaded as a photo. Only checking the ink left "Upload" looking
  /// accepted while Continue stayed dead.
  bool _signatureCaptured(bool isClient) {
    final mode = isClient ? _clientSigMode : _agentSigMode;
    if (mode == 'upload') {
      return (isClient ? _clientSigPhoto : _agentSigPhoto) != null;
    }
    return isClient ? _clientHasInk : _agentHasInk;
  }

  bool get _partiesValid => _holder.isValid;

  bool get _insuredValid => _insured.isValid;

  bool get _beneficiariesValid {
    double totalPct = 0;
    for (final b in _beneficiaries) {
      if (!b.isValid) return false;
      totalPct += double.tryParse(b.percentController.text.trim()) ?? 0;
    }
    return totalPct <= 100;
  }

  bool get _healthDeclarationValid {
    final anyYes = _healthAnswers.values.any((v) => v);
    return !anyYes || _healthRemarkController.text.trim().isNotEmpty;
  }

  bool get _documentsValid {
    return _holder.documentsCaptured &&
        (_insuredSameAsHolder || _insured.documentsCaptured) &&
        _beneficiaries.every((b) => b.documentsCaptured);
  }

  bool _stepComplete(_EStep step) => switch (step) {
    _EStep.policyHolder => _partiesValid,
    _EStep.insuredPerson => _insuredValid,
    _EStep.productInfo =>
      ref.read(eappQuoteFormProvider(_product).notifier).calculate() != null,
    _EStep.beneficiaries => _beneficiariesValid,
    _EStep.healthDeclaration => _healthDeclarationValid,
    _EStep.documentation => _documentsValid,
    _EStep.sign => _signatureCaptured(true) && _signatureCaptured(false),
    _EStep.proposal => _proposalValid,
    _EStep.review => false,
  };

  /// Proposal tab — nothing here is unconditionally mandatory: Notify
  /// Mobile and Special Remark are each conditional on the choice above
  /// them, and Request Policy Date only has to be valid if it is set.
  bool get _proposalValid {
    if (_notifyType == 'SMS') {
      final v = _notifyMobileController.text.trim();
      if (v.isEmpty || ApplicantValidators.notifyMobile(v) != null) {
        return false;
      }
    }
    if (_specialCase && _specialRemarkController.text.trim().isEmpty) {
      return false;
    }
    if (_requestPolicyDate != null &&
        ApplicantValidators.requestPolicyDate(_requestPolicyDate!) != null) {
      return false;
    }
    return true;
  }

  bool get _canContinue => switch (_activeSteps[_step]) {
    _EStep.proposal => _proposalValid,
    _EStep.policyHolder => _partiesValid,
    _EStep.insuredPerson => _insuredValid,
    _EStep.productInfo => true,
    _EStep.beneficiaries => _beneficiariesValid,
    _EStep.healthDeclaration => _healthDeclarationValid,
    _EStep.documentation => _documentsValid,
    _EStep.sign => _signatureCaptured(true) && _signatureCaptured(false),
    _EStep.review => true,
  };

  Future<void> _submit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm submission'),
        content: const Text(
          'Are you sure you want to submit this application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final Uint8List? clientPng = await _clientSig.toPngBytes();
    final Uint8List? agentPng = await _agentSig.toPngBytes();
    if (clientPng == null || agentPng == null) return;
    setState(() => _status = EappStatus.submitted);
  }

  @override
  Widget build(BuildContext context) {
    if (!_startDone) {
      return _EappStartStep(
        initialProductCode: _selectedProductCode,
        initialCustomerId: _selectedCustomerId,
        onContinue: (productCode, customerId) {
          setState(() {
            _selectedProductCode = productCode;
            _selectedCustomerId = customerId;
            _startDone = true;
          });
          _applyCustomerPrefill();
        },
      );
    }
    if (_status != EappStatus.draft) {
      return _SuccessScreen(
        status: _status,
        isRenewal: widget.renewalPolicyNo != null,
        proposalNo: _proposalNo,
        customerName: _holder.nameController.text.trim(),
        productName: _product.name,
      );
    }

    // Leaving mid-application throws the draft away, and the wizard is
    // eight steps deep — so both the app bar arrow and the system back
    // gesture ask first, at every step.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        if (!await _confirmLeave()) return;
        if (router.canPop()) {
          router.pop();
        } else {
          router.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          title: const Text('e-Application'),
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
          ),
          actions: [
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your changes have been saved successfully'),
                ),
              ),
              child: const Text('Save draft'),
            ),
          ],
        ),
        body: Column(
          children: [
            _ProgressHeader(
              step: _step,
              titles: _activeStepTitles,
              complete: [for (final st in _activeSteps) _stepComplete(st)],
              renewal: widget.renewalPolicyNo,
              productName: _product.name,
              onTapStep: (i) => setState(() => _step = i),
            ),
            if (_correctionNote != null)
              _CorrectionBanner(
                note: _correctionNote!,
                onDismiss: () => setState(() => _correctionNote = null),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [_buildStep(context)],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _step--),
                          child: const Text('Back'),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: !_canContinue
                            ? null
                            : _step == _activeStepTitles.length - 1
                            ? _submit
                            : () => setState(() {
                                if (_activeSteps[_step] ==
                                        _EStep.policyHolder &&
                                    _insuredSameAsHolder) {
                                  _copyHolderToInsured();
                                }
                                _step++;
                              }),
                        child: Text(
                          _step == _activeStepTitles.length - 1
                              ? 'Submit application'
                              : (!_canContinue
                                    ? 'Waiting for client…'
                                    : 'Continue'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Discard" throws the draft away; "Save draft" is the non-destructive
  /// way out, mirroring the app bar action the FA already knows. Stacked
  /// buttons rather than a row of three text links: the destructive choice
  /// should never sit a thumb-width from the safe one.
  Future<bool> _confirmLeave() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.paper,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.warn.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    color: AppColors.warn,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Leave this application?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deep,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'It has not been submitted yet. Save it as a draft to pick '
                'it up later, or discard what you have filled in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: AppColors.deepAlpha(0.6),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, 'draft'),
                icon: const Icon(Icons.bookmark_outline, size: 17),
                label: const Text('Save draft & leave'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, 'discard'),
                icon: const Icon(Icons.delete_outline, size: 17),
                label: const Text('Discard'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(
                    color: AppColors.danger.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(context, 'stay'),
                child: const Text('Keep editing'),
              ),
            ],
          ),
        ),
      ),
    );
    if (choice == 'draft' && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your changes have been saved successfully'),
        ),
      );
    }
    return choice == 'draft' || choice == 'discard';
  }

  static final _productInfoMoney = NumberFormat('#,##0.00', 'en_US');
  static const _productInfoStampFee = 100;

  /// Doc 114 §2 — the Proposal tab is 13 fields, but only 4 of them need
  /// a decision from the FA. It is split into three cards: what the system
  /// already knows (read-only), who is selling (the mandatory block), and
  /// an optional block that stays folded until asked for. Notify Mobile
  /// and Special Remark appear only when the field above them opens them.
  Widget _buildProposalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. System-generated — never editable, so it reads as a summary
        // strip rather than three disabled inputs.
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EappCardTitle('Proposal'),
              const SizedBox(height: 10),
              // The branch is a choice, not a read-out — an FA attached to
              // more than one office picks the one the proposal belongs to.
              EappDropdownField(
                label: 'Branch Office *',
                value: _branchOffice,
                options: kBranchOffices,
                onChanged: (v) =>
                    setState(() => _branchOffice = v ?? _branchOffice),
              ),
              const SizedBox(height: 10),
              // Requested policy date sits with the proposal itself; it was
              // buried under Optional details, where it read as an extra.
              EappDobField(
                label: 'Request Policy Date',
                date: _requestPolicyDate,
                onPick: (d) => setState(() => _requestPolicyDate = d),
                notPast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // 3. Notification — the phone field only exists under SMS.
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EappCardTitle('Notification'),
              const SizedBox(height: 10),
              AppSegmentedTabs<String>(
                value: _notifyType,
                options: const [
                  ('SMS', 'SMS', Icons.sms_outlined),
                  (
                    'Not Notify',
                    'Not Notify',
                    Icons.notifications_off_outlined,
                  ),
                ],
                onChanged: (v) => setState(() => _notifyType = v),
              ),
              if (_notifyType == 'SMS') ...[
                const SizedBox(height: 12),
                AppTextField(
                  controller: _notifyMobileController,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.phone,
                  label: 'Notify Mobile Phone No *',
                  hint: '',
                  showFlag: true,
                  helperText: '13 digits including 09',
                  errorText: ApplicantValidators.notifyMobile(
                    _notifyMobileController.text,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        // 4. Everything optional, folded away by default.
        SoftCard(
          child: OptionalDetails(
            filledCount: _proposalOptionalCount,
            children: [
              const SizedBox(height: 4),
              AppTextField(
                controller: _referralController,
                onChanged: (_) => setState(() {}),
                label: 'Referral',
                prefixIcon: Icon(Icons.people_alt_outlined),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text(
                  'Special Case',
                  style: TextStyle(fontSize: 12.5, color: AppColors.deep),
                ),
                value: _specialCase,
                onChanged: (v) => setState(() => _specialCase = v),
              ),
              if (_specialCase)
                AppTextField(
                  controller: _specialRemarkController,
                  onChanged: (_) => setState(() {}),
                  maxLines: 2,
                  label: 'Special Remark *',
                  errorText: _specialRemarkController.text.trim().isEmpty
                      ? 'Required.'
                      : null,
                ),
            ],
          ),
        ),
      ],
    );
  }

  int get _proposalOptionalCount {
    var n = 0;
    if (_referralController.text.trim().isNotEmpty) n++;
    if (_specialCase) n++;
    return n;
  }

  Widget _buildProductInfoStep() {
    final product = _product;
    final answers = ref.watch(eappQuoteFormProvider(product));
    final controller = ref.read(eappQuoteFormProvider(product).notifier);
    final result = controller.calculate();
    final error = controller.validate();

    if (result == null) {
      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: AppColors.warn),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    error ?? 'Premium inputs are incomplete.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.deepAlpha(0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _editPremiumInputs,
              icon: const Icon(Icons.calculate_outlined, size: 16),
              label: const Text('Edit premium inputs'),
            ),
          ],
        ),
      );
    }

    String premiumLabel() {
      for (final field in product.calculatorFields) {
        if (field.key == 'paymentType' && field.options.isNotEmpty) {
          final selected = answers['paymentType'];
          final option = field.options.firstWhere(
            (o) => o.value == selected,
            orElse: () => field.options.first,
          );
          return 'Premium (${option.label})';
        }
      }
      return 'Premium (Lumpsum)';
    }

    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              product.name,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primaryColor.withValues(alpha: 0.10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  premiumLabel(),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deep,
                  ),
                ),
                Text(
                  _productInfoMoney.format(result.premium),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              children: [
                _Row('Product Name', product.name),
                for (final (label, val) in result.lines) _Row(label, val),
                _Row(
                  'Stamp Fee',
                  _productInfoMoney.format(_productInfoStampFee),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deep,
                  ),
                ),
                Text(
                  _productInfoMoney.format(result.total),
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deep,
                  ),
                ),
              ],
            ),
          ),
          // Doc 111 §2.2 — the figure carried in from the Start step stays
          // editable; changing it reopens the same calculator, never a
          // second copy of the fields.
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _editPremiumInputs,
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Edit premium inputs'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reopens the Start step on the Premium slot. The e-App state is kept,
  /// so the FA lands back on this step with the new figure.
  void _editPremiumInputs() => setState(() => _startDone = false);

  Widget _buildPartiesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_prefilledFrom != null) ...[
          _PrefillBanner(
            customerName: _prefilledFrom!,
            count: _prefilledKeys.length,
          ),
          const SizedBox(height: 12),
        ],
        // Asked before the card, not after it: the answer decides whether
        // the FA is filling one party or two, so it belongs above the
        // fields it governs rather than at the foot of a long form.
        SoftCard(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _insuredSameAsHolder
                      ? AppColors.mint
                      : AppColors.deepAlpha(0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _insuredSameAsHolder ? Icons.check : Icons.person_outline,
                  size: 16,
                  color: _insuredSameAsHolder
                      ? Colors.white
                      : AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Insured is the policy holder',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deep,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _insuredSameAsHolder
                          ? 'Step 3 is filled from this card'
                          : 'Leave off to fill the insured separately',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.deepAlpha(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _insuredSameAsHolder,
                onChanged: (v) => setState(() {
                  _insuredSameAsHolder = v;
                  if (v) _copyHolderToInsured();
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ApplicantCard(
          title: 'Policy Holder',
          applicant: _holder,
          prefilledKeys: _prefilledKeys,
          onChanged: () => setState(() {}),
        ),
      ],
    );
  }

  /// Doc 111 §4.1 — the "same as the policy holder" question is answered
  /// once, on the Policy Holder step. Here the answer has already been
  /// applied: the copied values sit in the fields, editable, so the FA can
  /// correct the one thing that differs instead of re-typing the card.
  Widget _buildInsuredStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_insuredSameAsHolder) ...[
          _CopiedFromHolderBanner(
            name: _holder.nameController.text.trim(),
            onEdit: () => setState(
              () => _step = _activeSteps.indexOf(_EStep.policyHolder),
            ),
          ),
          const SizedBox(height: 12),
        ],
        ApplicantCard(
          title: 'Insured Person',
          applicant: _insured,
          onChanged: () => setState(() {}),
        ),
      ],
    );
  }

  /// Mirrors the whole Policy Holder card onto the Insured record — the
  /// switch is answered on the holder step, so this runs again on the way
  /// out of it to pick up anything edited after the toggle.
  void _copyHolderToInsured() {
    _insured.type = _holder.type;
    _insured.nameController.text = _holder.nameController.text;
    _insured.fatherNameController.text = _holder.fatherNameController.text;
    _insured.dob = _holder.dob;
    _insured.gender = _holder.gender;
    _insured.maritalStatus = _holder.maritalStatus;
    _insured.mobileController.text = _holder.mobileController.text;
    _insured.emailController.text = _holder.emailController.text;
    _insured.idType = _holder.idType;
    _insured.documentType = _holder.documentType;
    _insured.idNoController.text = _holder.idNoController.text;
    _insured.occupationController.text = _holder.occupationController.text;
    _insured.weightController.text = _holder.weightController.text;
    _insured.heightFtController.text = _holder.heightFtController.text;
    _insured.heightInController.text = _holder.heightInController.text;
    _insured.remarkController.text = _holder.remarkController.text;

    _insured.roomNoController.text = _holder.roomNoController.text;
    _insured.buildingNoController.text = _holder.buildingNoController.text;
    _insured.houseNoController.text = _holder.houseNoController.text;
    _insured.streetNoController.text = _holder.streetNoController.text;
    _insured.wardNoController.text = _holder.wardNoController.text;
    _insured.townController.text = _holder.townController.text;
    _insured.townshipController.text = _holder.townshipController.text;
    _insured.districtController.text = _holder.districtController.text;
    _insured.stateRegionController.text = _holder.stateRegionController.text;
  }

  // --- Doc 112: the 100% share budget --------------------------------
  int _shareOf(Applicant b) =>
      int.tryParse(b.percentController.text.trim()) ?? 0;

  int get _sharesTotal => _beneficiaries.fold(0, (a, b) => a + _shareOf(b));

  /// The largest share this row may hold: what is unallocated, plus what
  /// it already holds. Re-opens on its own as other rows shrink.
  int _shareCeiling(Applicant b) => 100 - (_sharesTotal - _shareOf(b));

  /// Doc 112 §3 — 3 people become 34/33/33, never 33/33/33, so a tap on
  /// "Split evenly" always lands on exactly 100.
  void _splitEvenly() {
    final n = _beneficiaries.length;
    if (n == 0) return;
    final base = 100 ~/ n;
    var remainder = 100 - base * n;
    setState(() {
      for (final b in _beneficiaries) {
        final extra = remainder > 0 ? 1 : 0;
        remainder -= extra;
        b.percentController.text = '${base + extra}';
      }
    });
  }

  Widget _buildBeneficiariesStep() {
    final total = _sharesTotal;
    final remaining = 100 - total;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: EappCardTitle('Beneficiaries')),
              if (_beneficiaries.length > 1)
                TextButton(
                  onPressed: _splitEvenly,
                  child: const Text('Split evenly'),
                ),
              TextButton.icon(
                // Doc 112 §4 — a new row starts with whatever is left, so
                // "the rest goes to my son" needs no typing at all.
                onPressed: () => setState(() {
                  final b = Applicant(role: ApplicantRole.beneficiary);
                  if (remaining > 0) b.percentController.text = '$remaining';
                  _beneficiaries.add(b);
                }),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ShareAllocationBar(
            shares: [for (final b in _beneficiaries) _shareOf(b)],
            labels: [
              for (var i = 0; i < _beneficiaries.length; i++)
                _beneficiaries[i].nameController.text.trim().isEmpty
                    ? 'Beneficiary ${i + 1}'
                    : _beneficiaries[i].nameController.text.trim(),
            ],
          ),
          for (var i = 0; i < _beneficiaries.length; i++) ...[
            const Divider(height: 24),
            _buildBeneficiaryFields(i),
          ],
        ],
      ),
    );
  }

  Widget _buildBeneficiaryFields(int i) {
    final b = _beneficiaries[i];
    final ceiling = _shareCeiling(b);
    return ApplicantCard(
      index: i + 1,
      applicant: b,
      percentCeiling: ceiling,
      onUseRemaining: ceiling > _shareOf(b)
          ? () => setState(() => b.percentController.text = '$ceiling')
          : null,
      // Removing a row frees its budget but never silently reallocates it
      // to anyone else (doc 112 §5).
      onRemove: _beneficiaries.length > 1
          ? () => setState(() => _beneficiaries.removeAt(i))
          : null,
      onChanged: () => setState(() {}),
    );
  }

  Widget _buildHealthStep() {
    return Column(
      children: [
        if (_product.category == ProductCategory.health) ...[
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EappCardTitle('Health Measurements'),
                const SizedBox(height: 10),
                // Doc 114 §4 — height/weight now belong to the applicant
                // record, so this reads and writes the insured's own
                // figures rather than a second, unrelated pair.
                MeasurementRow(
                  applicant: _insuredSameAsHolder ? _holder : _insured,
                  onChanged: () => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EappCardTitle('Health Declaration'),
              const SizedBox(height: 4),
              Text(
                'Answer each question to complete the health declaration.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.deepAlpha(0.5),
                ),
              ),
              const SizedBox(height: 8),
              for (final q in _healthAnswers.keys)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    q,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.deep,
                    ),
                  ),
                  value: _healthAnswers[q]!,
                  onChanged: (v) => setState(() => _healthAnswers[q] = v),
                ),
              if (_healthAnswers.values.any((v) => v)) ...[
                const SizedBox(height: 6),
                AppTextField(
                  controller: _healthRemarkController,
                  onChanged: (_) => setState(() {}),
                  maxLines: 2,
                  label: 'Remark *',
                  errorText: _healthRemarkController.text.trim().isEmpty
                      ? 'Required.'
                      : null,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentationStep() {
    return Column(
      children: [
        if (_holder.isEntity || _holder.idNoController.text.trim() == 'No ID')
          _NoDocsCard(
            title: 'Policy Holder Documents',
            subtitle: _holder.nameController.text.trim(),
          )
        else
          _DocsStep(
            title: 'Policy Holder Documents',
            subtitle: _holder.nameController.text.trim(),
            documentType: _holder.documentType,
            nrcFrontPhoto: _holder.nrcFrontPhoto,
            nrcBackPhoto: _holder.nrcBackPhoto,
            passportPhoto: _holder.passportPhoto,
            idLabel: _holder.idType,
            onEditIdentification: () => setState(
              () => _step = _activeSteps.indexOf(_EStep.policyHolder),
            ),
            onCapture: (part) => _captureDocument('holder', part),
            onRemove: (part) => _removeDocument(_holder, part),
          ),
        const SizedBox(height: 14),
        if (!_insuredSameAsHolder)
          if (_insured.idNoController.text.trim() == 'No ID')
            _NoDocsCard(
              title: 'Insured Person Documents',
              subtitle: _insured.nameController.text.trim(),
            )
          else
            _DocsStep(
              title: 'Insured Person Documents',
              subtitle: _insured.nameController.text.trim(),
              documentType: _insured.documentType,
              nrcFrontPhoto: _insured.nrcFrontPhoto,
              nrcBackPhoto: _insured.nrcBackPhoto,
              passportPhoto: _insured.passportPhoto,
              idLabel: _insured.idType,
              onEditIdentification: () => setState(
                () => _step = _activeSteps.indexOf(_EStep.insuredPerson),
              ),
              onCapture: (part) => _captureDocument('insured', part),
              onRemove: (part) => _removeDocument(_insured, part),
            ),
        for (var i = 0; i < _beneficiaries.length; i++) ...[
          const SizedBox(height: 14),
          if (_beneficiaries[i].isEntity ||
              _beneficiaries[i].idNoController.text.trim() == 'No ID')
            _NoDocsCard(
              title: _beneficiaries.length == 1
                  ? 'Beneficiary Documents'
                  : 'Beneficiary ${i + 1} Documents',
              subtitle: _beneficiaries[i].nameController.text.trim(),
            )
          else
            _DocsStep(
              title: _beneficiaries.length == 1
                  ? 'Beneficiary Documents'
                  : 'Beneficiary ${i + 1} Documents',
              subtitle: _beneficiaries[i].nameController.text.trim(),
              documentType: _beneficiaries[i].documentType,
              nrcFrontPhoto: _beneficiaries[i].nrcFrontPhoto,
              nrcBackPhoto: _beneficiaries[i].nrcBackPhoto,
              passportPhoto: _beneficiaries[i].passportPhoto,
              idLabel: _beneficiaries[i].idType,
              onEditIdentification: () => setState(
                () => _step = _activeSteps.indexOf(_EStep.beneficiaries),
              ),
              onCapture: (part) =>
                  _captureBeneficiaryDocument(_beneficiaries[i], part),
              onRemove: (part) => _removeDocument(_beneficiaries[i], part),
            ),
        ],
      ],
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_activeSteps[_step]) {
      case _EStep.proposal:
        return _buildProposalStep();
      case _EStep.policyHolder:
        return _buildPartiesStep();
      case _EStep.insuredPerson:
        return _buildInsuredStep();
      case _EStep.productInfo:
        return _buildProductInfoStep();
      case _EStep.beneficiaries:
        return _buildBeneficiariesStep();
      case _EStep.healthDeclaration:
        return _buildHealthStep();
      case _EStep.documentation:
        return _buildDocumentationStep();
      case _EStep.sign:
        return _SignStep(
          clientController: _clientSig,
          agentController: _agentSig,
          clientHasInk: _clientHasInk,
          agentHasInk: _agentHasInk,
          clientCaptured: _signatureCaptured(true),
          onClearClient: () => setState(_clearClient),
          onClearAgent: () => _agentSig.clear(),
          clientMode: _clientSigMode,
          agentMode: _agentSigMode,
          clientPhoto: _clientSigPhoto,
          agentPhoto: _agentSigPhoto,
          onClientModeChanged: (mode) => setState(() => _clientSigMode = mode),
          onAgentModeChanged: (mode) => setState(() => _agentSigMode = mode),
          onPickClientPhoto: () => _pickSignaturePhoto(isClient: true),
          onPickAgentPhoto: () => _pickSignaturePhoto(isClient: false),
          onClearClientPhoto: () => setState(() => _clientSigPhoto = null),
          onClearAgentPhoto: () => setState(() => _agentSigPhoto = null),
        );
      case _EStep.review:
        return _ReviewStep(
          sections: _buildReviewSections(),
          onEditStep: (i) => setState(() => _step = i),
        );
    }
  }

  String _formatDate(DateTime date) =>
      DateFormat('dd-MMM-yyyy', 'en_US').format(date);

  String _fmtDate(DateTime? d) => d == null ? 'Not set' : _formatDate(d);

  /// Only the document that was actually asked for. Listing all three
  /// slots showed a stale NRC shot beside a passport after the FA changed
  /// the identification type.
  List<(String, XFile?)> _docImages(Applicant a) => a.documentType == 'Passport'
      ? [('Passport', a.passportPhoto)]
      : [('Front', a.nrcFrontPhoto), ('Back', a.nrcBackPhoto)];

  List<_ReviewSection> _buildReviewSections() {
    final product = _product;
    final controller = ref.read(eappQuoteFormProvider(product).notifier);
    final result = controller.calculate();

    List<(String, String)> partyRows(Applicant a) {
      String v(String text) => text.trim().isEmpty ? 'Not set' : text.trim();
      return [
        ('Type', a.type.label),
        (a.isEntity ? 'Entity Name' : 'Name', v(a.nameController.text)),
        if (a.isEntity) ...[
          ('Registration No', v(a.regNoController.text)),
          ('Business Type', a.businessType ?? 'Not set'),
          ('Incorporation Date', _fmtDate(a.incorporationDate)),
          ('Contact Person', v(a.contactPersonController.text)),
        ] else ...[
          ('Father Name', v(a.fatherNameController.text)),
          ('Date of Birth', _fmtDate(a.dob)),
          ('Identification', v(a.idNoController.text)),
        ],
        ('Mobile', v(a.mobileController.text)),
        ('Email', v(a.emailController.text)),
        if (!a.isEntity && a.role != ApplicantRole.beneficiary) ...[
          ('Gender', a.gender ?? 'Not set'),
          if (a.heightFtController.text.trim().isNotEmpty)
            (
              'Height',
              "${a.heightFtController.text.trim()}' "
                  '${a.heightInController.text.trim()}"',
            ),
          if (a.weightController.text.trim().isNotEmpty)
            ('Weight', '${a.weightController.text.trim()} lb'),
        ],
        if (a.role != ApplicantRole.beneficiary && a.addressSummary != null)
          ('Address', a.addressSummary!),
        if (a.role == ApplicantRole.policyHolder) ...[
          if (a.maritalStatus != null) ('Marital Status', a.maritalStatus!),
          if (a.occupationController.text.trim().isNotEmpty)
            ('Occupation', a.occupationController.text.trim()),
          if (a.remarkController.text.trim().isNotEmpty)
            ('Remark', a.remarkController.text.trim()),
        ],
      ];
    }

    final holderRows = partyRows(_holder);
    final insuredRows = <(String, String)>[
      if (_insuredSameAsHolder) ('Same as Policy Holder', 'Yes'),
      ...partyRows(_insured),
    ];

    final beneficiaryRows = <(String, String)>[
      // Doc 112 open question — the BRD only forbids >100%, so an
      // unallocated remainder still passes. Say so plainly here rather
      // than letting it reach Core unnoticed.
      (
        'Total share',
        _sharesTotal == 100
            ? '100% — fully allocated'
            : '$_sharesTotal% — ${100 - _sharesTotal}% unallocated',
      ),
    ];
    for (var i = 0; i < _beneficiaries.length; i++) {
      final b = _beneficiaries[i];
      final pct = b.percentController.text.trim().isEmpty
          ? '0'
          : b.percentController.text.trim();
      beneficiaryRows.add((
        'Beneficiary ${i + 1}${b.isEntity ? ' (Entity)' : ''}',
        '${b.nameController.text.isEmpty ? 'Not set' : b.nameController.text} · $pct%',
      ));
    }

    final healthRows = <(String, String)>[
      for (final entry in _healthAnswers.entries)
        (entry.key, entry.value ? 'Yes' : 'No'),
    ];
    if (_healthAnswers.values.any((v) => v)) {
      healthRows.add((
        'Remark',
        _healthRemarkController.text.isEmpty
            ? 'Not set'
            : _healthRemarkController.text,
      ));
    }

    final premiumRows = <(String, String)>[
      ('Product', product.name),
      if (result != null)
        ('Estimated premium', '${_startMoney.format(result.total)} MMK'),
      if (result != null)
        for (final (label, val) in result.lines) (label, val),
    ];

    return [
      _ReviewSection(
        title: 'Policy Holder',
        editStep: _activeSteps.indexOf(_EStep.policyHolder),
        rows: holderRows,
      ),
      _ReviewSection(
        title: 'Insured Person',
        editStep: _activeSteps.indexOf(_EStep.insuredPerson),
        rows: insuredRows,
      ),
      _ReviewSection(
        title: 'Beneficiary',
        editStep: _activeSteps.indexOf(_EStep.beneficiaries),
        rows: beneficiaryRows,
      ),
      _ReviewSection(
        title: 'Premium Information',
        editStep: _activeSteps.indexOf(_EStep.productInfo),
        rows: premiumRows,
      ),
      if (_product.category == ProductCategory.health)
        _ReviewSection(
          title: 'Health Declaration',
          editStep: _activeSteps.indexOf(_EStep.healthDeclaration),
          rows: healthRows,
        ),
      _ReviewSection(
        title: 'Signatures',
        editStep: _activeSteps.indexOf(_EStep.sign),
        rows: const [],
        signatures: [
          _SignatureProof(
            label: 'Client',
            mode: _clientSigMode,
            controller: _clientSig,
            photo: _clientSigPhoto,
          ),
          _SignatureProof(
            label: 'Agent',
            mode: _agentSigMode,
            controller: _agentSig,
            photo: _agentSigPhoto,
          ),
        ],
      ),
      _ReviewSection(
        title: 'Documentation',
        editStep: _activeSteps.indexOf(_EStep.documentation),
        rows: const [],
        // Doc 118 — documents are grouped under the person they belong to,
        // with that person's own name in the header. A flat list of
        // "Holder Docs / Insured Docs / Beneficiary 1 Docs" over a flat
        // strip of thumbnails made the FA match captions to rows by hand.
        docGroups: [
          _DocGroup(
            role: 'Policy Holder',
            name: _holder.nameController.text.trim(),
            isEntity: _holder.isEntity,
            captured: _holder.documentsCaptured,
            documentType: _holder.documentType,
            images: _docImages(_holder),
          ),
          _DocGroup(
            role: 'Insured Person',
            name: _insuredSameAsHolder
                ? _holder.nameController.text.trim()
                : _insured.nameController.text.trim(),
            isEntity: _insured.isEntity && !_insuredSameAsHolder,
            captured: _insuredSameAsHolder || _insured.documentsCaptured,
            // When the insured is the holder there is nothing separate to
            // photograph — say which record covers them instead of
            // repeating the holder's images under a second heading.
            mirrors: _insuredSameAsHolder ? 'Same as Policy Holder' : null,
            documentType: _insured.documentType,
            images: _insuredSameAsHolder ? const [] : _docImages(_insured),
          ),
          for (var i = 0; i < _beneficiaries.length; i++)
            _DocGroup(
              role: _beneficiaries.length == 1
                  ? 'Beneficiary'
                  : 'Beneficiary ${i + 1}',
              name: _beneficiaries[i].nameController.text.trim(),
              isEntity: _beneficiaries[i].isEntity,
              captured: _beneficiaries[i].documentsCaptured,
              documentType: _beneficiaries[i].documentType,
              images: _docImages(_beneficiaries[i]),
            ),
        ],
      ),
    ];
  }
}

class _ReviewSection {
  const _ReviewSection({
    required this.title,
    required this.editStep,
    required this.rows,
    this.docGroups = const [],
    this.signatures = const [],
  });
  final String title;
  final int editStep;
  final List<(String, String)> rows;

  /// The captured signatures, however they were given (doc 111 §7) — the
  /// FA and the client should see on Review exactly what will be sent.
  final List<_SignatureProof> signatures;

  /// Captured documents, grouped by the person they belong to (doc 118).
  final List<_DocGroup> docGroups;
}

/// A signature as the Review step shows it: whose it is, and either the
/// ink still held by the pad's controller or the photo that replaced it.
class _SignatureProof {
  const _SignatureProof({
    required this.label,
    required this.mode,
    required this.controller,
    required this.photo,
  });
  final String label;

  /// 'esign' or 'upload'.
  final String mode;
  final SignatureController controller;
  final dynamic photo;

  bool get captured => mode == 'upload' ? photo != null : controller.isNotEmpty;
}

/// One party's document block on the Review step: who they are, whether
/// their documents are complete, and the photos themselves.
class _DocGroup {
  const _DocGroup({
    required this.role,
    required this.name,
    required this.isEntity,
    required this.captured,
    required this.documentType,
    required this.images,
    this.mirrors,
  });

  /// 'Policy Holder' / 'Insured Person' / 'Beneficiary 2'.
  final String role;
  final String name;
  final bool isEntity;
  final bool captured;
  final String documentType;

  /// Set when this party's documents live on another party's record.
  final String? mirrors;
  final List<(String, XFile?)> images;

  List<(String, XFile)> get captures => [
    for (final (label, file) in images)
      if (file != null) (label, file),
  ];

  (String, bool) get status {
    if (mirrors != null) return (mirrors!, true);
    if (isEntity) return ('Not required', true);
    if (captured) return ('$documentType captured', true);
    return ('Pending', false);
  }
}

/// Doc 111 §2.3 — prefill must be visible. An FA who cannot tell what came
/// from where will not trust the Review step, so say it plainly once at the
/// top of the step and mark each field individually.
class _PrefillBanner extends StatelessWidget {
  const _PrefillBanner({required this.customerName, required this.count});
  final String customerName;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mint.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: AppColors.mint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              count == 0
                  ? 'Linked to $customerName — you have edited every prefilled field.'
                  : '$count ${count == 1 ? 'field' : 'fields'} filled from '
                        '$customerName\u2019s record.',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.deep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown on the Insured step when the FA answered "same as the policy
/// holder" a step earlier: it says where the values came from and offers
/// the way back, since the switch itself no longer lives on this step.
class _CopiedFromHolderBanner extends StatelessWidget {
  const _CopiedFromHolderBanner({required this.name, required this.onEdit});
  final String name;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mint.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.copy_all_outlined, size: 16, color: AppColors.mint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name.isEmpty
                  ? 'Copied from the Policy Holder — edit anything that '
                        'differs.'
                  : 'Copied from $name — edit anything that differs.',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.deep,
              ),
            ),
          ),
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _CorrectionBanner extends StatelessWidget {
  const _CorrectionBanner({required this.note, required this.onDismiss});
  final String note;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warn.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warn.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.flag_outlined, color: AppColors.warn, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Underwriting asked for a fix here',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: AppColors.deep,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.deepAlpha(0.6),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onDismiss,
            child: Icon(Icons.close, size: 16, color: AppColors.deepAlpha(0.4)),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.step,
    required this.titles,
    required this.complete,
    required this.onTapStep,
    this.renewal,
    this.productName,
  });
  final int step;
  final List<String> titles;

  /// Whether each step's own validators are currently satisfied — drives
  /// the segment colour and the "n/m done" counter.
  final List<bool> complete;

  /// Doc 111 §4.3 — steps are tappable. An FA sitting with a customer
  /// collects data in whatever order the conversation goes; Review is the
  /// gate, not the Continue button.
  final ValueChanged<int> onTapStep;
  final String? renewal;
  final String? productName;

  @override
  Widget build(BuildContext context) {
    final done = complete.where((c) => c).length;
    return Container(
      color: AppColors.paper,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (renewal != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Renewal · $renewal',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryColor,
                ),
              ),
            )
          else if (productName != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.deepAlpha(0.06),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Product · $productName',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Step ${step + 1} of ${titles.length} · ${titles[step]}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deep,
                  ),
                ),
              ),
              Text(
                '$done/${titles.length} done',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepAlpha(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < titles.length; i++) ...[
                Expanded(
                  child: Semantics(
                    button: true,
                    label: '${titles[i]}${complete[i] ? ', complete' : ''}',
                    child: InkWell(
                      onTap: () => onTapStep(i),
                      // A wider hit box than the 4px bar it draws — the
                      // segments are a real control, not just an indicator.
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: complete[i]
                                ? AppColors.mint
                                : i == step
                                ? AppColors.primaryColor
                                : i < step
                                ? AppColors.primaryColor.withValues(alpha: 0.45)
                                : AppColors.deepAlpha(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (i != titles.length - 1) const SizedBox(width: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// Doc 111 §2 — the single entry funnel. Every door into the e-App lands
/// here, and whichever of the three slots the door already knows arrives
/// filled and collapsed: CRM brings the customer, "Buy"/"Continue" from a
/// product or quote brings the product and its premium. What is left open
/// is exactly what the FA still has to decide.
class _EappStartStep extends ConsumerStatefulWidget {
  const _EappStartStep({
    required this.initialProductCode,
    required this.initialCustomerId,
    required this.onContinue,
  });

  final String? initialProductCode;
  final String? initialCustomerId;
  final void Function(String productCode, String? customerId) onContinue;

  @override
  ConsumerState<_EappStartStep> createState() => _EappStartStepState();
}

class _EappStartStepState extends ConsumerState<_EappStartStep> {
  String? _productCode;
  String? _customerId;
  late ProductCategory? _category;

  @override
  void initState() {
    super.initState();
    _productCode = widget.initialProductCode;
    _customerId = widget.initialCustomerId;
    _category = _product?.category;
  }

  Product? get _product => _productCode == null
      ? null
      : MockData.products.where((p) => p.code == _productCode).firstOrNull;

  /// The linked contact as the slot shows it. Two stores feed this screen —
  /// the Customer records and the CRM contact list, whose IDs do not overlap —
  /// so a pick from either has to resolve here or the slot reads as empty.
  ({String name, String tag})? get _customerDisplay {
    final id = _customerId;
    if (id == null) return null;

    final controller = ref.read(crmControllerProvider.notifier);
    final customer = controller.byId(id) ?? controller.byName(id);
    if (customer != null) {
      return (name: customer.name, tag: customer.isClient ? 'Client' : 'Lead');
    }

    final contacts = ref.watch(crmContactsProvider).value;
    final contact = contacts
        ?.where((c) => c.id == id || c.name == id)
        .firstOrNull;
    if (contact == null) return null;
    return (
      name: contact.name,
      tag: switch (contact.contactType.name) {
        'client' => 'Client',
        'halfQualified' => 'Half-Qualified',
        _ => 'Lead',
      },
    );
  }

  Future<void> _pickCustomer() async {
    final contacts = await ref.read(crmContactsProvider.future);
    if (!mounted) return;
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CustomerPickerSheet(contacts: contacts),
    );
    if (picked != null) setState(() => _customerId = picked);
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final controller = product == null
        ? null
        : ref.read(eappQuoteFormProvider(product).notifier);
    final answers = product == null
        ? <String, dynamic>{}
        : ref.watch(eappQuoteFormProvider(product));
    final error = controller?.validate();
    final result = controller?.calculate();
    final customer = _customerDisplay;

    final categoryProducts = _category == null
        ? const <Product>[]
        : MockData.products.where((p) => p.category == _category).toList();

    final ready = product != null && error == null && result != null;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Start e-Application'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/products'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      // Doc 116 §4 — the CTA is pinned rather than floating at the end of a
      // short list, so it is always where the thumb expects it and the page
      // never shows a button stranded above half a screen of empty cream.
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product != null && result == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Fill in the premium inputs for this product before '
                  'continuing.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.deepAlpha(0.5),
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: ready
                    ? () => widget.onContinue(product.code, _customerId)
                    : null,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Continue to e-Application'),
              ),
            ),
          ],
        ),
      ),
      // Doc 116 §1 — the three slots are one checklist, so they live in one
      // card separated by hairlines. As three separate SoftCards, a
      // satisfied slot still cost a full card of padding for one line of
      // text, and the page read as three unrelated blocks.
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // --- Slot 1: customer (optional) ------------------------
                _StartSlotRow(
                  icon: Icons.person_search_outlined,
                  title: 'Customer',
                  optional: true,
                  done: customer != null,
                  value: customer?.name,
                  valueTag: customer?.tag,
                  hint: 'Prefill from a lead or client · skip for a walk-in',
                  onTap: _pickCustomer,
                  onClear: customer == null
                      ? null
                      : () => setState(() => _customerId = null),
                ),
                const _SlotDivider(),

                // --- Slot 2: category then product ----------------------
                _StartSlotRow(
                  icon: Icons.inventory_2_outlined,
                  title: 'Product',
                  done: product != null,
                  value: product?.name,
                  hint: 'Pick a category, then the product',
                  onTap: product == null
                      ? null
                      : () => setState(() => _productCode = null),
                  expanded: product != null
                      ? null
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                for (final c in ProductCategory.values) ...[
                                  Expanded(
                                    child: _CategoryTile(
                                      category: c,
                                      count: MockData.products
                                          .where((p) => p.category == c)
                                          .length,
                                      selected: c == _category,
                                      onTap: () => setState(() {
                                        _category = c;
                                        _productCode = null;
                                      }),
                                    ),
                                  ),
                                  if (c != ProductCategory.values.last)
                                    const SizedBox(width: 8),
                                ],
                              ],
                            ),
                            // The product list opens below the category row
                            // rather than on its own page, so switching
                            // category stays one tap.
                            for (final item in categoryProducts) ...[
                              const SizedBox(height: 8),
                              _ProductChoiceTile(
                                product: item,
                                selected: item.code == _productCode,
                                onTap: () =>
                                    setState(() => _productCode = item.code),
                              ),
                            ],
                          ],
                        ),
                ),

                // --- Slot 3: premium ------------------------------------
                if (product != null) ...[
                  const _SlotDivider(),
                  _StartSlotRow(
                    icon: Icons.calculate_outlined,
                    title: 'Premium',
                    done: result != null,
                    value: result == null ? null : 'Inputs completed',
                    hint: 'Fill in the details for this product',
                    // The inputs stay on screen after the figure lands: the
                    // FA is still typing the customer's numbers in, and
                    // collapsing them hid the field they were editing.
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final field in product.calculatorFields)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: QuoteFieldRenderer(
                              field: field,
                              value: answers[field.key],
                              onChanged: (value) =>
                                  controller!.setValue(field.key, value),
                              onToggleMulti: (value) =>
                                  controller!.toggleMulti(field.key, value),
                            ),
                          ),
                        if (error != null)
                          Text(
                            error,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.danger,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _startMoney = NumberFormat('#,##0', 'en_US');

class _StartSlotRow extends StatelessWidget {
  const _StartSlotRow({
    required this.icon,
    required this.title,
    required this.done,
    required this.hint,
    this.value,
    this.valueTag,
    this.optional = false,
    this.onTap,
    this.onClear,
    this.expanded,
  });

  final IconData icon;
  final String title;
  final bool done;
  final String hint;
  final String? value;
  final String? valueTag;
  final bool optional;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? AppColors.mint : AppColors.deepAlpha(0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(
            done ? Icons.check : icon,
            size: 15,
            color: done ? Colors.white : AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: AppColors.deepAlpha(0.55),
                    ),
                  ),
                  if (optional) ...[
                    const SizedBox(width: 6),
                    Text(
                      'Optional',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepAlpha(0.35),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      value ?? hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: value == null ? 12 : 13.5,
                        fontWeight: value == null
                            ? FontWeight.w400
                            : FontWeight.w800,
                        color: value == null
                            ? AppColors.deepAlpha(0.45)
                            : Colors.black,
                      ),
                    ),
                  ),
                  if (valueTag != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.deepAlpha(0.06),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        valueTag!,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (done && onTap != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Change'),
          )
        else if (!done && expanded == null)
          Icon(Icons.chevron_right, size: 20, color: AppColors.deepAlpha(0.3)),
        if (done && onClear != null)
          IconButton(
            tooltip: 'Remove',
            visualDensity: VisualDensity.compact,
            onPressed: onClear,
            icon: Icon(Icons.close, size: 16, color: AppColors.deepAlpha(0.4)),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!done && expanded == null && onTap != null)
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: header,
            )
          else
            header,
          if (expanded != null) ...[
            const SizedBox(height: 12),
            Padding(padding: const EdgeInsets.only(right: 6), child: expanded!),
          ],
        ],
      ),
    );
  }
}

class _CustomerPickerSheet extends StatefulWidget {
  const _CustomerPickerSheet({required this.contacts});
  final List<CRMContactModel> contacts;

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _searchController = TextEditingController();

  /// null = all; true = clients only; false = leads only.
  String? _contactTypeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CRMContactModel> get _results {
    final q = _searchController.text.trim().toLowerCase();
    return widget.contacts.where((c) {
      if (_contactTypeFilter != null &&
          c.contactType.name != _contactTypeFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) ||
          c.phone.replaceAll(' ', '').contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final clients = widget.contacts
        .where((c) => c.contactType.name == 'client')
        .length;
    final halfQualified = widget.contacts
        .where((c) => c.contactType.name == 'halfQualified')
        .length;
    final leads = widget.contacts.length - clients - halfQualified;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // Grab handle — the sheet is draggable, so say so.
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              decoration: BoxDecoration(
                color: AppColors.deepAlpha(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EappCardTitle('Select contact'),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    label: 'Search name or phone',
                    prefixIcon: Icon(Icons.search),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      AppSelectionChip(
                        label: 'All (${widget.contacts.length})',
                        selected: _contactTypeFilter == null,
                        onSelected: (_) =>
                            setState(() => _contactTypeFilter = null),
                      ),
                      const SizedBox(width: 8),
                      AppSelectionChip(
                        label: 'Clients ($clients)',
                        selected: _contactTypeFilter == 'client',
                        onSelected: (_) =>
                            setState(() => _contactTypeFilter = 'client'),
                      ),
                      const SizedBox(width: 8),
                      AppSelectionChip(
                        label: 'Leads ($leads)',
                        selected: _contactTypeFilter == 'lead',
                        onSelected: (_) =>
                            setState(() => _contactTypeFilter = 'lead'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: results.isEmpty
                  // An empty result is a dead end unless it offers the way
                  // out — here, proceeding without a linked record.
                  ? ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 32,
                          color: AppColors.deepAlpha(0.25),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No match for "${_searchController.text.trim()}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deep,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You can start the application without linking a '
                          'record and fill the details by hand.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.deepAlpha(0.5),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Continue without a contact'),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: results.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: AppColors.deepAlpha(0.06)),
                      itemBuilder: (context, i) {
                        final c = results[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.deepAlpha(0.07),
                            child: Text(
                              c.name.isEmpty ? '?' : c.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.deep,
                              ),
                            ),
                          ),
                          title: Text(
                            c.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.deep,
                            ),
                          ),
                          subtitle: Text(
                            c.phone,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.deepAlpha(0.55),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: c.contactType.name == 'client'
                                  ? AppColors.mint.withValues(alpha: 0.14)
                                  : c.contactType.name == 'halfQualified'
                                  ? Colors.orange.withValues(alpha: 0.14)
                                  : AppColors.deepAlpha(0.06),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              c.contactType.name == 'client'
                                  ? 'Client'
                                  : c.contactType.name == 'halfQualified'
                                  ? 'Half-Qualified'
                                  : 'Lead',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: c.contactType.name == 'client'
                                    ? AppColors.mint
                                    : c.contactType.name == 'halfQualified'
                                    ? Colors.orange
                                    : AppColors.primaryColor,
                              ),
                            ),
                          ),
                          onTap: () => Navigator.pop(context, c.name),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotDivider extends StatelessWidget {
  const _SlotDivider();

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    thickness: 1,
    indent: 14,
    endIndent: 14,
    color: AppColors.deepAlpha(0.06),
  );
}

/// Doc 111 §2.1 — three categories deserve one tap, not a dropdown.
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final ProductCategory category;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.deep : AppColors.deepAlpha(0.04),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Column(
            children: [
              FaIcon(
                ProductVisuals.categoryIcon(category),
                size: 20,
                color: selected
                    ? Colors.white
                    : ProductVisuals.colorFor(category),
              ),
              const SizedBox(height: 6),
              Text(
                ProductVisuals.labelFor(category),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.deep,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count product${count == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 10,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.75)
                      : AppColors.deepAlpha(0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductChoiceTile extends StatelessWidget {
  const _ProductChoiceTile({
    required this.product,
    required this.selected,
    required this.onTap,
  });
  final Product product;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryColor.withValues(alpha: 0.12)
          : AppColors.deepAlpha(0.035),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              // Doc 130 §4 — shared illustration, at list-row size.
              ProductIllustration(product: product, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deep,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? AppColors.primaryColor
                    : AppColors.deepAlpha(0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocsStep extends StatelessWidget {
  const _DocsStep({
    required this.title,
    required this.subtitle,
    required this.documentType,
    required this.nrcFrontPhoto,
    required this.nrcBackPhoto,
    required this.passportPhoto,
    required this.onCapture,
    required this.onRemove,
    required this.idLabel,
    required this.onEditIdentification,
  });
  final String title;

  /// The party's own name. Doc 118 §3 — "Policy Holder Documents" alone
  /// does not tell the FA whose card they are about to photograph when
  /// three capture cards sit on one screen.
  final String subtitle;
  final String documentType;
  final XFile? nrcFrontPhoto;
  final XFile? nrcBackPhoto;
  final XFile? passportPhoto;

  /// 'NRC' / 'Old NRC' / 'Passport' as chosen on the party's own card.
  final String idLabel;

  /// Jumps back to the step where that choice lives.
  final VoidCallback onEditIdentification;
  final ValueChanged<String> onCapture;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EappCardTitle(title),
          const SizedBox(height: 2),
          Text(
            subtitle.isEmpty ? 'Name not set' : subtitle,
            style: TextStyle(fontSize: 11.5, color: AppColors.deepAlpha(0.55)),
          ),
          const SizedBox(height: 10),
          // The identification type was already chosen on this party's own
          // card; this step photographs that document, it does not offer a
          // second, contradictory choice. Shown, not asked.
          Row(
            children: [
              Icon(
                documentType == 'Passport'
                    ? Icons.public_outlined
                    : Icons.badge_outlined,
                size: 15,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                idLabel,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deep,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onEditIdentification,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Doc 115 §1 — the NRC has two physical sides, so it gets two
          // slots side by side in the order they are held: Front left,
          // Back right. Stacked rows made one card look like two
          // unrelated tasks and hid the "one of two done" state.
          if (documentType == 'NRC')
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DocumentCaptureTile(
                    label: 'NRC Front',
                    photo: nrcFrontPhoto,
                    onCapture: () => onCapture('nrc-front'),
                    onRemove: () => onRemove('nrc-front'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DocumentCaptureTile(
                    label: 'NRC Back',
                    photo: nrcBackPhoto,
                    onCapture: () => onCapture('nrc-back'),
                    onRemove: () => onRemove('nrc-back'),
                  ),
                ),
              ],
            )
          else
            _DocumentCaptureTile(
              label: 'Passport photo page',
              photo: passportPhoto,
              onCapture: () => onCapture('passport'),
              onRemove: () => onRemove('passport'),
            ),
        ],
      ),
    );
  }
}

/// An Entity party captures no NRC/passport in this prototype — say so
/// rather than leaving an empty slot the FA thinks they have to fill.
class _NoDocsCard extends StatelessWidget {
  const _NoDocsCard({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          Icon(
            Icons.business_outlined,
            size: 18,
            color: AppColors.deepAlpha(0.45),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EappCardTitle(title),
                const SizedBox(height: 3),
                Text(
                  subtitle.isEmpty
                      ? 'Entity — no NRC or passport capture required.'
                      : '$subtitle · Entity — no NRC or passport capture '
                            'required.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.deepAlpha(0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCaptureTile extends StatelessWidget {
  const _DocumentCaptureTile({
    required this.label,
    required this.photo,
    required this.onCapture,
    required this.onRemove,
  });
  final String label;
  final XFile? photo;
  final VoidCallback onCapture;
  final VoidCallback onRemove;

  /// An ID card is landscape; matching the slot to it means the captured
  /// photo fills the frame with no letterboxing, and an empty slot already
  /// shows the shape the FA is being asked to fill (doc 115 §2).
  static const _aspect = 1.58;

  @override
  Widget build(BuildContext context) {
    final captured = photo != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: _aspect,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Material(
                color: AppColors.deepAlpha(0.035),
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: captured ? () => _showPreview(context) : onCapture,
                  child: captured
                      // The photo is the tile — edge to edge, no thumbnail
                      // sitting in a row of text (doc 115 §2).
                      ? Image.file(File(photo!.path), fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: AppColors.primaryColor,
                              size: 22,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to add',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepAlpha(0.6),
                              ),
                            ),
                            const SizedBox(height: 2),
                            // The sheet offers two ways in; say so here so
                            // an FA who already has the photo knows.
                            Text(
                              'Camera or upload',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: AppColors.deepAlpha(0.42),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              // Doc 115 §4 — one clear-and-retake affordance, pinned to the
              // top-right corner of the slot it owns. It replaces the
              // full-width "Retake photo" button, which cost a whole row
              // per slot and read as a second, separate action.
              if (captured)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Semantics(
                    button: true,
                    label: 'Remove $label',
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: onRemove,
                        // 32dp of tappable area inside a small badge, so
                        // the corner target is not a 16dp pinprick.
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              captured ? Icons.check_circle : Icons.circle_outlined,
              size: 13,
              color: captured ? AppColors.mint : AppColors.deepAlpha(0.25),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deep,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPreview(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(photo!.path), fit: BoxFit.contain),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignStep extends StatelessWidget {
  const _SignStep({
    required this.clientController,
    required this.agentController,
    required this.clientHasInk,
    required this.agentHasInk,
    required this.clientCaptured,
    required this.onClearClient,
    required this.onClearAgent,
    this.clientMode = 'esign',
    this.agentMode = 'esign',
    this.clientPhoto,
    this.agentPhoto,
    this.onClientModeChanged,
    this.onAgentModeChanged,
    this.onPickClientPhoto,
    this.onPickAgentPhoto,
    this.onClearClientPhoto,
    this.onClearAgentPhoto,
  });

  final SignatureController clientController;
  final SignatureController agentController;
  final bool clientHasInk;
  final bool agentHasInk;

  /// True once the client has signed *either way* — drawn or uploaded.
  final bool clientCaptured;
  final VoidCallback onClearClient;
  final VoidCallback onClearAgent;
  final String clientMode;
  final String agentMode;
  final dynamic clientPhoto;
  final dynamic agentPhoto;
  final ValueChanged<String>? onClientModeChanged;
  final ValueChanged<String>? onAgentModeChanged;
  final VoidCallback? onPickClientPhoto;
  final VoidCallback? onPickAgentPhoto;
  final VoidCallback? onClearClientPhoto;
  final VoidCallback? onClearAgentPhoto;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SignaturePad(
          title: 'Client signature',
          controller: clientController,
          hasInk: clientHasInk,
          locked: false,
          lockedHint: null,
          onClear: onClearClient,
          mode: clientMode,
          photo: clientPhoto,
          onModeChanged: onClientModeChanged,
          onPickPhoto: onPickClientPhoto,
          onClearPhoto: onClearClientPhoto,
        ),
        const SizedBox(height: 14),
        _SignaturePad(
          title: 'Agent signature',
          controller: agentController,
          hasInk: agentHasInk,
          locked: !clientCaptured,
          lockedHint: 'Sign client first',
          onClear: onClearAgent,
          mode: agentMode,
          photo: agentPhoto,
          onModeChanged: onAgentModeChanged,
          onPickPhoto: onPickAgentPhoto,
          onClearPhoto: onClearAgentPhoto,
        ),
      ],
    );
  }
}

class _SignaturePad extends StatelessWidget {
  const _SignaturePad({
    required this.title,
    required this.controller,
    required this.hasInk,
    required this.locked,
    required this.lockedHint,
    required this.onClear,
    this.mode = 'esign',
    this.photo,
    this.onModeChanged,
    this.onPickPhoto,
    this.onClearPhoto,
  });
  final String title;
  final SignatureController controller;
  final bool hasInk;
  final bool locked;
  final String? lockedHint;
  final VoidCallback onClear;
  final String mode;
  final dynamic photo;
  final ValueChanged<String>? onModeChanged;
  final VoidCallback? onPickPhoto;
  final VoidCallback? onClearPhoto;

  @override
  Widget build(BuildContext context) {
    final hasValue = mode == 'esign' ? hasInk : photo != null;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EappCardTitle(title),
              const Spacer(),
              if (hasValue)
                const Icon(Icons.check_circle, color: AppColors.mint, size: 16),
              if (locked)
                Icon(
                  Icons.lock_outline,
                  size: 14,
                  color: AppColors.deepAlpha(0.4),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (!locked) ...[
            AppSegmentedTabs<String>(
              value: mode,
              options: const [
                ('esign', 'E-Sign', Icons.draw),
                ('upload', 'Upload', Icons.photo_camera_outlined),
              ],
              onChanged: onModeChanged,
            ),
            const SizedBox(height: 10),
          ],
          // Content area
          AbsorbPointer(
            absorbing: locked,
            child: Opacity(
              opacity: locked ? 0.4 : 1,
              child: mode == 'esign'
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          border: Border.all(color: AppColors.deepAlpha(0.1)),
                        ),
                        child: locked
                            ? Center(
                                child: Text(
                                  lockedHint ?? '',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.deepAlpha(0.4),
                                  ),
                                ),
                              )
                            : Signature(
                                controller: controller,
                                backgroundColor: Colors.transparent,
                              ),
                      ),
                    )
                  : GestureDetector(
                      onTap: locked ? null : () => onPickPhoto?.call(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            border: Border.all(
                              color: photo != null
                                  ? AppColors.primaryColor
                                  : AppColors.deepAlpha(0.1),
                            ),
                          ),
                          child: photo != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // A picked signature is a file on the
                                    // device, not a bundled asset — as an
                                    // asset it always fell through to the
                                    // placeholder icon.
                                    Image.file(
                                      File(photo.path),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 40,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => onClearPhoto?.call(),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.5,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 32,
                                        color: AppColors.deepAlpha(0.3),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to upload signature',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.deepAlpha(0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
            ),
          ),
          if (!locked) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: mode == 'esign' ? onClear : onClearPhoto,
                child: const Text('Clear'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.sections, required this.onEditStep});
  final List<_ReviewSection> sections;
  final ValueChanged<int> onEditStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in sections) ...[
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    EappCardTitle(section.title),
                    const Spacer(),
                    TextButton(
                      onPressed: () => onEditStep(section.editStep),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (section.rows.isEmpty &&
                    section.docGroups.isEmpty &&
                    section.signatures.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Not set',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.deepAlpha(0.4),
                      ),
                    ),
                  )
                else
                  for (final (label, value) in section.rows)
                    _ReviewRow(label: label, value: value),
                for (var i = 0; i < section.docGroups.length; i++) ...[
                  if (i > 0)
                    Divider(height: 20, color: AppColors.deepAlpha(0.06)),
                  _DocGroupBlock(group: section.docGroups[i]),
                ],
                if (section.signatures.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (i, proof) in section.signatures.indexed) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(child: _SignatureProofBlock(proof: proof)),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        Text(
          'By submitting, I confirm all information is accurate to the best of my knowledge.',
          style: TextStyle(fontSize: 11, color: AppColors.deepAlpha(0.5)),
        ),
      ],
    );
  }
}

/// Shows the signature itself rather than a "Signed: Yes" row — on a
/// document the client is about to be bound by, the proof is the mark.
class _SignatureProofBlock extends StatelessWidget {
  const _SignatureProofBlock({required this.proof});
  final _SignatureProof proof;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              proof.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.deepAlpha(0.55),
              ),
            ),
            const SizedBox(width: 6),
            if (proof.captured)
              const Icon(Icons.check_circle, size: 13, color: AppColors.mint),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 86,
            width: double.infinity,
            decoration: BoxDecoration(
              color: proof.captured ? Colors.white : AppColors.cream,
              border: Border.all(color: AppColors.deepAlpha(0.1)),
            ),
            child: !proof.captured
                ? Center(
                    child: Text(
                      'Not signed',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.deepAlpha(0.4),
                      ),
                    ),
                  )
                : proof.mode == 'upload'
                ? Image.file(File(proof.photo.path), fit: BoxFit.cover)
                : IgnorePointer(
                    child: Signature(
                      controller: proof.controller,
                      backgroundColor: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          proof.mode == 'upload' ? 'Uploaded image' : 'Signed on screen',
          style: TextStyle(fontSize: 10, color: AppColors.deepAlpha(0.45)),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Doc 118 §2 — one party's documents, under that party's own name. The
/// role and the person's name sit together in the header, so a thumbnail
/// below only has to say which side it is, not who it belongs to.
class _DocGroupBlock extends StatelessWidget {
  const _DocGroupBlock({required this.group});
  final _DocGroup group;

  @override
  Widget build(BuildContext context) {
    final (statusText, ok) = group.status;
    final captures = group.captures;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              group.isEntity ? Icons.business_outlined : Icons.person_outline,
              size: 15,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.role,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  // The name is the whole point: "Beneficiary 1" means
                  // nothing on a page the FA is checking for accuracy.
                  Text(
                    group.name.isEmpty ? 'Name not set' : group.name,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.deepAlpha(0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ok
                    ? AppColors.mint.withValues(alpha: 0.14)
                    : AppColors.warn.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    ok ? Icons.check : Icons.error_outline,
                    size: 11,
                    color: ok ? AppColors.mint : AppColors.warn,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: ok ? AppColors.mint : AppColors.warn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (captures.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            // Indented under the person icon, so the photos read as
            // belonging to the header above them.
            padding: const EdgeInsets.only(left: 22),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final (label, file) in captures)
                  _ReviewImageThumb(label: label, file: file),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewImageThumb extends StatelessWidget {
  const _ReviewImageThumb({required this.label, required this.file});
  final String label;
  final XFile file;

  void _showPreview(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(file.path), fit: BoxFit.contain),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _showPreview(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(file.path),
              width: 92,
              height: 58,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            width: 92,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Doc 119 — the last screen of the e-App. It answers two questions in
/// the order the FA asks them: did it go through, and where is it now.
class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen({
    required this.status,
    required this.isRenewal,
    required this.proposalNo,
    required this.customerName,
    required this.productName,
  });
  final EappStatus status;
  final bool isRenewal;
  final String proposalNo;
  final String customerName;
  final String productName;

  /// Doc 119 §3 — the journey the *customer* is on, derived from the
  /// workflow status (doc 26 Layer B) so the two can never disagree.
  /// Proposal is done the moment this screen exists.
  int get _stage => switch (status) {
    EappStatus.approved => 2,
    _ => 1,
  };

  String get _shareText =>
      'KBZ Life proposal $proposalNo'
      '${customerName.isEmpty ? '' : ' for $customerName'}'
      ' · $productName · ${status.label}.';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back must not walk into the submitted wizard; the application is
      // gone to underwriting and there is nothing left to edit.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: Stack(
          children: [
            // Confetti sits behind the content and only in the top third —
            // celebratory without competing with the tracker below it.
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 340,
              child: _Confetti(),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                      child: Column(
                        children: [
                          const _SuccessCheck(),
                          const SizedBox(height: 24),
                          Text(
                            isRenewal ? 'Renewal submitted' : 'Success',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: AppColors.deep,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your proposal has been successfully created.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.deepAlpha(0.55),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Doc 120 §2 — which application succeeded. The
                          // reference number itself now lives one tap away
                          // on the Proposal stage instead of taking the
                          // centre of the screen.
                          Text(
                            customerName.isEmpty
                                ? productName
                                : '$customerName · $productName',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.deepAlpha(0.45),
                            ),
                          ),
                          const SizedBox(height: 34),
                          _JourneyTracker(
                            stage: _stage,
                            // Doc 120 §3 — the completed Proposal stage is
                            // the way back into what was just submitted.
                            onTapProposal: () => _openProposal(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => context.push('/e-app/tracker'),
                                child: const Text('Track application'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _CircleIconButton(
                              icon: Icons.share_outlined,
                              tooltip: 'Share',
                              onTap: () => _share(context),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Back to home'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Doc 120 §3 — the proposal itself. There is no proposal-detail route
  /// in this prototype (the record only exists in the wizard that just
  /// closed), so it opens as a sheet over the success screen rather than
  /// a navigation into a screen that would have to invent a record.
  void _openProposal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.deepAlpha(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const EappCardTitle('Proposal'),
              const SizedBox(height: 12),
              // The number is the reason this sheet exists, so it is the
              // largest thing in it and copies on tap.
              _ProposalNoPill(proposalNo: proposalNo),
              const SizedBox(height: 14),
              _ReviewRow(
                label: 'Policy Holder',
                value: customerName.isEmpty ? 'Not set' : customerName,
              ),
              _ReviewRow(label: 'Product', value: productName),
              _ReviewRow(label: 'Status', value: status.label),
              _ReviewRow(
                label: 'Submitted',
                value: AppDate.dMyHm(DateTime.now()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/e-app/tracker');
                  },
                  child: const Text('Track application'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Doc 120 §4 — a real share, built from what this app already ships:
  /// SMS and email through url_launcher, plus the clipboard. No stub.
  void _share(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.deepAlpha(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: EappCardTitle('Share proposal'),
              ),
            ),
            _ShareTile(
              icon: Icons.sms_outlined,
              label: 'Send by SMS',
              onTap: () {
                Navigator.pop(sheetContext);
                launchUrl(
                  Uri(scheme: 'sms', queryParameters: {'body': _shareText}),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
            _ShareTile(
              icon: Icons.mail_outline,
              label: 'Send by email',
              onTap: () {
                Navigator.pop(sheetContext);
                launchUrl(
                  Uri(
                    scheme: 'mailto',
                    queryParameters: {
                      'subject': 'KBZ Life proposal $proposalNo',
                      'body': _shareText,
                    },
                  ),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
            _ShareTile(
              icon: Icons.copy_all_outlined,
              label: 'Copy proposal details',
              onTap: () {
                Navigator.pop(sheetContext);
                Clipboard.setData(ClipboardData(text: _shareText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proposal details copied')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Doc 124 — shared chip.
      leading: AppIconChip(
        icon: icon,
        size: 38,
        style: AppIconChipStyle.tinted,
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.deep,
        ),
      ),
      onTap: onTap,
    );
  }
}

/// Doc 120 §1 — the ring draws itself, then the tick lands inside it.
/// The old version scaled a finished check in over 620ms, which was over
/// before the screen had settled; this takes 1.5s and is the thing the
/// eye follows on arrival.
class _SuccessCheck extends StatefulWidget {
  const _SuccessCheck();

  @override
  State<_SuccessCheck> createState() => _SuccessCheckState();
}

class _SuccessCheckState extends State<_SuccessCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      height: 116,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _CheckPainter(
            // The ring sweeps over the first 55% of the run, the tick is
            // drawn over the last 45% — sequential, so the eye reads it
            // as one gesture completing rather than two things appearing.
            ring: Curves.easeOutCubic.transform(
              (_c.value / 0.55).clamp(0.0, 1.0),
            ),
            tick: Curves.easeOutCubic.transform(
              ((_c.value - 0.5) / 0.5).clamp(0.0, 1.0),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.ring, required this.tick});
  final double ring;
  final double tick;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rect = Offset.zero & size;
    canvas.drawArc(rect.deflate(3), -pi / 2, 2 * pi * ring, false, paint);

    if (tick <= 0) return;
    // Two segments of the tick, drawn in order and clipped by [tick].
    final a = Offset(size.width * 0.29, size.height * 0.52);
    final b = Offset(size.width * 0.44, size.height * 0.67);
    final c = Offset(size.width * 0.72, size.height * 0.37);
    final path = Path()..moveTo(a.dx, a.dy);
    const split = 0.38; // share of the tick length in the short leg
    if (tick <= split) {
      final t = tick / split;
      path.lineTo(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
    } else {
      final t = (tick - split) / (1 - split);
      path.lineTo(b.dx, b.dy);
      path.lineTo(b.dx + (c.dx - b.dx) * t, b.dy + (c.dy - b.dy) * t);
    }
    canvas.drawPath(path, paint..strokeWidth = 6);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.ring != ring || old.tick != tick;
}

/// Doc 119 §2 — the proposal number, sized to be read across a desk and
/// tappable to copy. Doc 120 §2 moved it off the success screen and into
/// the Proposal sheet, which is where someone goes looking for it.
class _ProposalNoPill extends StatelessWidget {
  const _ProposalNoPill({required this.proposalNo});
  final String proposalNo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryColor.withValues(alpha: 0.08),
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: proposalNo));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Proposal no $proposalNo copied')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 14, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROPOSAL NO',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryColor.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    proposalNo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.baltic,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.copy_outlined,
                size: 15,
                color: AppColors.primaryColor.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Doc 119 §3 — Proposal → Underwriting → Payment → Policy. Stages behind
/// the current one are solid, the one ahead is dashed: the file has not
/// travelled that link yet, and a dashed line says so without a caption.
class _JourneyTracker extends StatelessWidget {
  const _JourneyTracker({required this.stage, this.onTapProposal});

  /// 0-based index of the stage the application is sitting in.
  final int stage;

  /// Doc 120 §3 — the Proposal stage is done, and it is also the door
  /// back to what was submitted. Only that stage is tappable; the ones
  /// ahead have nothing behind them yet.
  final VoidCallback? onTapProposal;

  static const _labels = ['Proposal', 'Underwriting', 'Payment', 'Policy'];

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          if (i == 0 && onTapProposal != null)
            InkWell(
              onTap: onTapProposal,
              customBorder: const CircleBorder(),
              child: _JourneyDot(index: i, stage: stage),
            )
          else
            _JourneyDot(index: i, stage: stage),
          if (i != _labels.length - 1)
            Expanded(
              child: _JourneyLink(done: i < stage, dashed: i >= stage),
            ),
        ],
      ],
    );

    final labels = Row(
      children: [
        for (var i = 0; i < _labels.length; i++)
          Expanded(
            child: InkWell(
              onTap: i == 0 ? onTapProposal : null,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                children: [
                  Text(
                    _labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: i <= stage
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: i <= stage
                          ? AppColors.deep
                          : AppColors.deepAlpha(0.4),
                    ),
                  ),
                  // The one tappable stage says so, rather than hiding a
                  // link behind an unmarked dot.
                  if (i == 0 && onTapProposal != null)
                    Text(
                      'View',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor.withValues(alpha: 0.9),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );

    return Column(children: [row, const SizedBox(height: 8), labels]);
  }
}

class _JourneyDot extends StatelessWidget {
  const _JourneyDot({required this.index, required this.stage});
  final int index;
  final int stage;

  @override
  Widget build(BuildContext context) {
    final done = index < stage;
    final current = index == stage;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done
            ? AppColors.mint
            : current
            ? AppColors.primaryColor
            : AppColors.primaryColor.withValues(alpha: 0.10),
        // The current stage carries a halo so it reads as "here" rather
        // than just another filled dot.
        border: current
            ? Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.25),
                width: 3,
              )
            : null,
      ),
      child: done
          ? const Icon(Icons.check, size: 15, color: Colors.white)
          : Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: current ? Colors.white : AppColors.primaryColor,
              ),
            ),
    );
  }
}

class _JourneyLink extends StatelessWidget {
  const _JourneyLink({required this.done, required this.dashed});
  final bool done;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: CustomPaint(
        painter: _LinkPainter(
          color: done ? AppColors.primaryColor : AppColors.deepAlpha(0.18),
          dashed: dashed,
        ),
      ),
    );
  }
}

class _LinkPainter extends CustomPainter {
  const _LinkPainter({required this.color, required this.dashed});
  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }
    const dash = 5.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dash).clamp(0, size.width), y),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_LinkPainter old) =>
      old.color != color || old.dashed != dashed;
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.primaryColor.withValues(alpha: 0.10),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 19, color: AppColors.primaryColor),
          ),
        ),
      ),
    );
  }
}

/// Doc 120 §1 — confetti that actually falls. Each piece has its own
/// delay, drop distance and spin over a 2.6s run, so the celebration is
/// something the FA watches rather than something already finished by the
/// time the screen settles. The seed is constant, so the layout does not
/// reshuffle on rebuild.
class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) =>
          CustomPaint(painter: _ConfettiPainter(progress: _c.value)),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress});

  /// 0 → 1 across the whole run.
  final double progress;

  static const _palette = [
    AppColors.mint,
    AppColors.primaryColor,
    AppColors.warn,
    AppColors.danger,
    AppColors.primaryColor,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(7);
    for (var i = 0; i < 46; i++) {
      final x = random.nextDouble() * size.width;
      final restY = random.nextDouble() * size.height;
      final color = _palette[random.nextInt(_palette.length)];
      final angle = random.nextDouble() * pi;
      final spin = (random.nextDouble() - 0.5) * 4;
      final long = 5.0 + random.nextDouble() * 9;
      final round = random.nextBool();
      final delay = random.nextDouble() * 0.45;

      // Each piece runs its own 0→1 inside the shared clock.
      final t = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final eased = Curves.easeOutQuad.transform(t);

      // Falls from above the top edge to its resting place, drifting
      // sideways a little on the way down.
      final y = -40 + (restY + 40) * eased;
      final drift = sin(eased * pi) * 14 * (round ? 1 : -1);
      // Pieces lower down fade first, so the field thins towards the
      // content below instead of ending in a hard line.
      final fade = (1 - restY / size.height).clamp(0.25, 1.0);
      final paint = Paint()..color = color.withValues(alpha: 0.55 * fade * t);

      canvas.save();
      canvas.translate(x + drift, y);
      canvas.rotate(angle + spin * eased);
      if (round) {
        canvas.drawCircle(Offset.zero, 2.5 + random.nextDouble() * 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: long, height: 4),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
