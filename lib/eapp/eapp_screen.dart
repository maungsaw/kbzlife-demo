import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

import '../../data/mock/mock_crm_data.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/product.dart';
import '../const.dart';
import '../widgets/app_key_value_row.dart';
import '../widgets/app_text.dart';
import '../crm/provider.dart';
import '../quote/quote_providers.dart';
import '../widgets/app_text_field.dart';
import '../widgets/pill_tabs.dart';
import '../widgets/soft_card.dart';
import 'address_master.dart';
import 'applicant.dart';
import 'applicant_card.dart';
import 'eapp_status.dart';
import 'pickers.dart';
import 'start_step.dart';
import 'success_screen.dart';

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

final _startMoney = NumberFormat('#,##0', 'en_US');

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

  final _clientSig = SignatureController(penStrokeWidth: 2.4);
  final _agentSig = SignatureController(penStrokeWidth: 2.4);
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
      return EappStartStep(
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
      return EappSuccessScreen(
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
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: BoxDecoration(
              color: context.colors.paper,
              border: Border(
                top: BorderSide(color: context.colors.border, width: 1),
              ),
            ),
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
                  child: ElevatedButton(
                    onPressed: !_canContinue
                        ? null
                        : _step == _activeStepTitles.length - 1
                        ? _submit
                        : () => setState(() {
                            if (_activeSteps[_step] == _EStep.policyHolder &&
                                _insuredSameAsHolder) {
                              _copyHolderToInsured();
                            }
                            _step++;
                          }),
                    child: Text(
                      _step == _activeStepTitles.length - 1 ? 'Submit' : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        backgroundColor: context.colors.paper,
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
                    color: context.colors.warn.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.exit_to_app_rounded,
                    color: context.colors.warn,
                    size: context.iconXxl,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Leave this application?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppType.title,
                  fontWeight: AppType.strong,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'It has not been submitted yet. Save it as a draft to pick '
                'it up later, or discard what you have filled in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppType.label,
                  height: 1.4,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, 'draft'),
                icon: Icon(Icons.bookmark_outline, size: context.iconMd),
                label: const Text('Save draft & leave'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, 'discard'),
                icon: Icon(Icons.delete_outline, size: context.iconMd),
                label: const Text('Discard'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.danger,
                  side: BorderSide(
                    color: context.colors.danger.withValues(alpha: 0.4),
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
              PillTabs(
                initialIndex: _notifyType == 'SMS' ? 0 : 1,
                onPageChanged: (i) =>
                    setState(() => _notifyType = i == 0 ? 'SMS' : 'Not Notify'),
                tabs: const [
                  PillTab(label: 'SMS', icon: Icons.sms_outlined),
                  PillTab(
                    label: 'Not Notify',
                    icon: Icons.notifications_off_outlined,
                  ),
                ],
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
                title: Text(
                  'Special Case',
                  style: TextStyle(
                    fontSize: AppType.label,
                    color: context.colors.textPrimary,
                  ),
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
    final controller = ref.read(eappQuoteFormProvider(product).notifier);
    // Watched so the card redraws when the FA edits the inputs.
    ref.watch(eappQuoteFormProvider(product));
    final result = controller.calculate();
    final error = controller.validate();

    if (result == null) {
      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: context.iconLg,
                  color: context.colors.warn,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppBodyText(
                    error ?? 'Premium inputs are incomplete.',
                    muted: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _editPremiumInputs,
              icon: Icon(Icons.calculate_outlined, size: context.iconBase),
              label: const Text('Edit premium inputs'),
            ),
          ],
        ),
      );
    }

    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                Expanded(child: AppSectionTitle(product.name)),
                // Doc 111 §2.2 — the figure carried in from the Start step
                // stays editable, and the action sits with the thing it
                // edits rather than stranded under the total.
                TextButton(
                  onPressed: _editPremiumInputs,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Edit'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Column(
              children: [
                _Row('Product Name', product.name),
                for (final (label, val) in result.lines) _Row(label, val),
                // Premium sits with the figures it came from, directly
                // above the fee that is added to it.
                _Row('Premium', _productInfoMoney.format(result.premium)),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppSectionTitle('Total Amount'),
                Text(
                  _productInfoMoney.format(result.total),
                  style: TextStyle(
                    fontSize: AppType.title,
                    fontWeight: AppType.strong,
                    color: context.colors.primaryColor,
                  ),
                ),
              ],
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
        // if (_prefilledFrom != null) ...[
        //   _PrefillBanner(
        //     customerName: _prefilledFrom!,
        //     count: _prefilledKeys.length,
        //   ),
        //   const SizedBox(height: 12),
        // ],
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
                      ? context.colors.mint
                      : context.colors.deepAlpha(0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _insuredSameAsHolder ? Icons.check : Icons.person_outline,
                  size: context.iconBase,
                  color: _insuredSameAsHolder
                      ? Colors.white
                      : context.colors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insured is the policy holder',
                      style: TextStyle(
                        fontSize: AppType.body,
                        fontWeight: AppType.strong,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Text(
                    //   _insuredSameAsHolder
                    //       ? 'Step 3 is filled from this card'
                    //       : 'Leave off to fill the insured separately',
                    //   style: TextStyle(
                    //     fontSize: AppType.label,
                    //     color: context.colors.textSecondary,
                    //   ),
                    // ),
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
        // if (_insuredSameAsHolder) ...[
        //   _CopiedFromHolderBanner(
        //     name: _holder.nameController.text.trim(),
        //     onEdit: () => setState(
        //       () => _step = _activeSteps.indexOf(_EStep.policyHolder),
        //     ),
        //   ),
        //   const SizedBox(height: 12),
        // ],
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
                icon: Icon(Icons.add, size: context.iconBase),
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
                  fontSize: AppType.label,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              for (final q in _healthAnswers.keys)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    q,
                    style: TextStyle(
                      fontSize: AppType.label,
                      color: context.colors.textPrimary,
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
        color: context.colors.warn.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.warn.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.flag_outlined,
            color: context.colors.warn,
            size: context.iconLg,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Underwriting asked for a fix here',
                  style: TextStyle(
                    fontWeight: AppType.strong,
                    fontSize: AppType.label,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: TextStyle(
                    fontSize: AppType.label,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onDismiss,
            child: Icon(
              Icons.close,
              size: context.iconBase,
              color: context.colors.deepAlpha(0.4),
            ),
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

  /// Whether each step's own validators are currently satisfied. Used for
  /// the steps already behind the FA — a filled step that later became
  /// invalid still has to show as unfinished.
  final List<bool> complete;

  /// Only steps already visited are tappable: the wizard runs one step at
  /// a time, so a segment ahead is a progress indicator, not a shortcut.
  final ValueChanged<int> onTapStep;
  final String? renewal;
  final String? productName;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.paper,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (renewal != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.colors.primaryColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: context.colors.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Renewal · $renewal',
                style: TextStyle(
                  fontSize: AppType.caption,
                  fontWeight: AppType.strong,
                  color: context.colors.primaryColor,
                ),
              ),
            )
          else if (productName != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.colors.deepAlpha(0.06),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Product · $productName',
                style: TextStyle(
                  fontSize: AppType.caption,
                  fontWeight: AppType.strong,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(child: AppHeading(titles[step], maxLines: 1)),
              const SizedBox(width: 10),
              AppCaptionText('Step ${step + 1} of ${titles.length}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < titles.length; i++) ...[
                Expanded(
                  child: Semantics(
                    button: i <= step,
                    label:
                        '${titles[i]}'
                        '${i < step && complete[i] ? ', complete' : ''}',
                    // Forward is earned by pressing Next, so only a step
                    // already visited can be jumped back to.
                    child: InkWell(
                      onTap: i <= step ? () => onTapStep(i) : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: i == step
                                ? context.colors.primaryColor
                                : i < step
                                ? (complete[i]
                                      ? context.colors.mint
                                      : context.colors.warn)
                                : context.colors.deepAlpha(0.1),
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
  Widget build(BuildContext context) => AppKeyValueRow(
    label: label,
    value: value,
    padding: const EdgeInsets.only(bottom: 10),
  );
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
            style: TextStyle(
              fontSize: AppType.label,
              color: context.colors.textSecondary,
            ),
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
                size: context.iconBase,
                color: context.colors.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                idLabel,
                style: TextStyle(
                  fontSize: AppType.label,
                  fontWeight: AppType.strong,
                  color: context.colors.textPrimary,
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
            size: context.iconLg,
            color: context.colors.deepAlpha(0.45),
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
                    fontSize: AppType.label,
                    color: context.colors.textSecondary,
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
                color: context.colors.deepAlpha(0.035),
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
                              color: context.colors.primaryColor,
                              size: context.iconXxl,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to add',
                              style: TextStyle(
                                fontSize: AppType.caption,
                                fontWeight: AppType.strong,
                                color: context.colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // The sheet offers two ways in; say so here so
                            // an FA who already has the photo knows.
                            Text(
                              'Camera or upload',
                              style: TextStyle(
                                fontSize: AppType.caption,
                                color: context.colors.textSecondary,
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
                      color: context.colors.accentNavy.withValues(alpha: 0.55),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: onRemove,
                        // 32dp of tappable area inside a small badge, so
                        // the corner target is not a 16dp pinprick.
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.close,
                            size: context.iconBase,
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
              size: context.iconSm,
              color: captured
                  ? context.colors.mint
                  : context.colors.deepAlpha(0.25),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppType.label,
                  fontWeight: AppType.strong,
                  color: context.colors.textPrimary,
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
                backgroundColor: context.colors.accentNavy.withValues(
                  alpha: 0.54,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: context.iconLg,
                  ),
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
                Icon(
                  Icons.check_circle,
                  color: context.colors.mint,
                  size: context.iconBase,
                ),
              if (locked)
                Icon(
                  Icons.lock_outline,
                  size: context.iconMd,
                  color: context.colors.deepAlpha(0.4),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (!locked) ...[
            PillTabs(
              initialIndex: mode == 'esign' ? 0 : 1,
              onPageChanged: (i) =>
                  onModeChanged?.call(i == 0 ? 'esign' : 'upload'),
              tabs: const [
                PillTab(label: 'E-Sign', icon: Icons.draw),
                PillTab(label: 'Upload', icon: Icons.photo_camera_outlined),
              ],
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
                          color: context.colors.cream,
                          border: Border.all(
                            color: context.colors.deepAlpha(0.1),
                          ),
                        ),
                        child: locked
                            ? Center(
                                child: Text(
                                  lockedHint ?? '',
                                  style: TextStyle(
                                    fontSize: AppType.label,
                                    color: context.colors.textSecondary,
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
                            color: context.colors.cream,
                            border: Border.all(
                              color: photo != null
                                  ? context.colors.primaryColor
                                  : context.colors.deepAlpha(0.1),
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
                                      errorBuilder: (_, _, _) => Center(
                                        child: Icon(
                                          Icons.image,
                                          size: context.icon6xl,
                                          color: context.colors.muted,
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
                                            color: context.colors.accentNavy
                                                .withValues(alpha: 0.5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: context.iconMd,
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
                                        size: context.icon5xl,
                                        color: context.colors.deepAlpha(0.3),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to upload signature',
                                        style: TextStyle(
                                          fontSize: AppType.label,
                                          color: context.colors.textSecondary,
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
                        fontSize: AppType.label,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  )
                else
                  for (final (label, value) in section.rows)
                    _ReviewRow(label: label, value: value),
                for (var i = 0; i < section.docGroups.length; i++) ...[
                  if (i > 0)
                    Divider(height: 20, color: context.colors.deepAlpha(0.06)),
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
          style: TextStyle(
            fontSize: AppType.caption,
            color: context.colors.textSecondary,
          ),
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
                fontSize: AppType.caption,
                fontWeight: AppType.strong,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            if (proof.captured)
              Icon(
                Icons.check_circle,
                size: context.iconSm,
                color: context.colors.mint,
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 86,
            width: double.infinity,
            decoration: BoxDecoration(
              color: proof.captured
                  ? context.colors.textPrimary
                  : context.colors.cream,
              border: Border.all(color: context.colors.deepAlpha(0.1)),
            ),
            child: !proof.captured
                ? Center(
                    child: Text(
                      'Not signed',
                      style: TextStyle(
                        fontSize: AppType.caption,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  )
                : proof.mode == 'upload'
                ? Image.file(File(proof.photo.path), fit: BoxFit.cover)
                : IgnorePointer(
                    child: Signature(
                      controller: proof.controller,
                      backgroundColor: context.colors.paper,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          proof.mode == 'upload' ? 'Uploaded image' : 'Signed on screen',
          style: TextStyle(
            fontSize: AppType.caption,
            color: context.colors.textSecondary,
          ),
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
  Widget build(BuildContext context) =>
      AppKeyValueRow(label: label, value: value);
}

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
              size: context.iconBase,
              color: context.colors.primaryColor,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.role,
                    style: TextStyle(
                      fontSize: AppType.label,
                      fontWeight: AppType.strong,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  // The name is the whole point: "Beneficiary 1" means
                  // nothing on a page the FA is checking for accuracy.
                  Text(
                    group.name.isEmpty ? 'Name not set' : group.name,
                    style: TextStyle(
                      fontSize: AppType.label,
                      color: context.colors.textSecondary,
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
                    ? context.colors.mint.withValues(alpha: 0.14)
                    : context.colors.warn.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: context.iconSm,
                    color: ok ? context.colors.mint : context.colors.warn,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: AppType.caption,
                      fontWeight: AppType.strong,
                      color: ok ? context.colors.mint : context.colors.warn,
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
                backgroundColor: context.colors.accentNavy.withValues(
                  alpha: 0.54,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: context.iconLg,
                  ),
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
              style: TextStyle(
                fontSize: AppType.caption,
                fontWeight: AppType.strong,
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
