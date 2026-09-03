import 'package:demo_ui/widgets/pill_tabs.dart';
import 'package:demo_ui/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../const.dart';
import '../widgets/soft_card.dart';
import 'address_master.dart';
import 'applicant.dart';
import 'pickers.dart';

class EappCardTitle extends StatelessWidget {
  const EappCardTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  );
}

class EappDropdownField extends StatelessWidget {
  const EappDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          hint: const Text('Select', style: TextStyle(fontSize: 12.5)),
          items: [
            for (final o in options)
              DropdownMenuItem(
                value: o,
                child: Text(o, style: const TextStyle(fontSize: 12.5)),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class EappDobField extends StatelessWidget {
  const EappDobField({
    super.key,
    required this.label,
    required this.date,
    required this.onPick,
    this.ageOf,
    this.notFuture = false,
    this.notPast = false,
  });
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onPick;
  final int? Function(DateTime)? ageOf;
  final bool notFuture;

  /// Proposal › Request Policy Date — "Should not be less than today."
  final bool notPast;

  @override
  Widget build(BuildContext context) {
    String? error;
    if (date != null) {
      if (notFuture && date!.isAfter(DateTime.now())) {
        error = 'Should not be greater than today';
      } else if (notPast) {
        error = ApplicantValidators.requestPolicyDate(date!);
      } else if (ageOf != null) {
        final age = ageOf!(date!);
        if (age != null) {
          if (age < 18) {
            error = 'Minimum age is 18.';
          } else if (age > 100) {
            error = 'Maximum age is 100';
          }
        }
      }
    }
    return AppTextField(
      label: label,
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? (notPast ? DateTime.now() : DateTime(1990)),
          firstDate: notPast ? DateTime.now() : DateTime(1900),
          lastDate: DateTime(2035),
        );
        if (picked != null) onPick(picked);
      },
      suffixIcon: Icon(Icons.calendar_today_outlined, size: context.iconLg),
      errorText: error,
      child: Text(
        date == null
            ? 'Select a date'
            : DateFormat('dd-MMM-yyyy', 'en_US').format(date!),
        style: TextStyle(
          fontSize: 13,
          fontWeight: date == null ? FontWeight.normal : FontWeight.bold,
          color: date == null ? AppColors.muted : AppColors.accentNavy,
        ),
      ),
    );
  }
}

/// Doc 112 §2 — a share can never be typed past the budget left for it.
/// The edit is rejected (the old value stands) rather than silently
/// rewritten, so the FA always sees exactly what they typed.
class PercentBudgetFormatter extends TextInputFormatter {
  const PercentBudgetFormatter({required this.max});
  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.trim();
    if (text.isEmpty) return newValue;
    final n = int.tryParse(text);
    if (n == null) return oldValue;
    return n > max ? oldValue : newValue;
  }
}

/// Doc 111 §4.2 — required fields render immediately; everything optional
/// hides behind one expander so a 15-field step reads as 5. The count in
/// the label means a collapsed section never hides filled data silently.
class OptionalDetails extends StatefulWidget {
  const OptionalDetails({
    super.key,
    required this.filledCount,
    required this.children,
  });
  final int filledCount;
  final List<Widget> children;

  @override
  State<OptionalDetails> createState() => _OptionalDetailsState();
}

class _OptionalDetailsState extends State<OptionalDetails> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _open ? Icons.expand_less : Icons.expand_more,
                  size: context.iconLg,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.filledCount > 0
                      ? 'Optional details · ${widget.filledCount} filled'
                      : 'Add optional details',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_open) ...widget.children,
      ],
    );
  }
}

/// Doc 111 §4.4 — the 7 address fields are the worst cluster in the form,
/// so they collapse to a single row and expand into a focused sub-sheet.
Future<bool> showAddressSheet(BuildContext context, Applicant applicant) async {
  final changed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.paper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EappCardTitle('Address'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: applicant.roomNoController,
                    label: 'Room No',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    controller: applicant.buildingNoController,
                    label: 'Building No',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: applicant.houseNoController,
                    label: 'House No *',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    controller: applicant.streetNoController,
                    label: 'Street *',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: applicant.wardNoController,
              label: 'Ward *',
            ),
            const SizedBox(height: 10),
            _TownField(applicant: applicant),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return changed ?? false;
}

/// Doc 111 §3 — the one applicant form, shared by the Policy Holder,
/// Insured Person and Beneficiary steps. [Applicant.type] is the first
/// control on the card and the field set below it reacts to the choice;
/// shared fields (mobile, email, address, remark) survive the switch.
/// Doc 114 §3 — Gender is mandatory for every Person party and has only
/// two values, so it is a chip row rather than a dropdown: no sheet to
/// open, and the required choice is visible without a tap.
class EappGenderField extends StatelessWidget {
  const EappGenderField({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GenderPillTabs(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _GenderPillTabs extends StatelessWidget {
  const _GenderPillTabs({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String> onChanged;

  static const _options = [
    ('Male', 'Male', Icons.male_outlined),
    ('Female', 'Female', Icons.female_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final index = _options.indexWhere((t) => t.$1 == value).clamp(0, _options.length - 1);
    return PillTabs(
      initialIndex: index,
      tabs: [
        for (final o in _options)
          PillTab(label: o.$2, icon: o.$3),
      ],
      onPageChanged: (i) => onChanged(_options[i].$1),
    );
  }
}

class ApplicantCard extends StatelessWidget {
  const ApplicantCard({
    super.key,
    required this.applicant,
    required this.onChanged,
    this.title,
    this.index,
    this.onRemove,
    this.prefilledKeys = const {},
    this.header,
    this.percentCeiling,
    this.onUseRemaining,
  });

  final Applicant applicant;

  /// Called after any mutation so the host screen can `setState` and
  /// re-run its step validators.
  final VoidCallback onChanged;
  final String? title;

  /// 1-based beneficiary number, when this card is one of several.
  final int? index;
  final VoidCallback? onRemove;

  /// Field keys that arrived from the linked lead/client record — used to
  /// mark them so the FA can always tell what they did not type.
  final Set<String> prefilledKeys;

  /// Extra content between the title and the type toggle (e.g. the
  /// "Same With Policy Holder" switch on the Insured step).
  final Widget? header;

  /// Doc 112 §2 — the largest share this beneficiary may hold: whatever is
  /// unallocated plus whatever they already hold. A keystroke that would
  /// break it is rejected outright rather than flagged later.
  final int? percentCeiling;

  /// Doc 112 §3 — one tap to close the gap. Null when there is no gap.
  final VoidCallback? onUseRemaining;

  bool get _isBeneficiary => applicant.role == ApplicantRole.beneficiary;

  /// An Entity cannot be the life insured — only a holder or beneficiary
  /// (doc 111 §3). Gate the control rather than failing at validation.
  bool get _canBeEntity => applicant.role != ApplicantRole.insured;

  /// Prefilled fields carry no per-field note: the banner at the top of
  /// the step already says where the values came from, and a line under
  /// every second field made the card twice as tall for no new information.
  String? _helper(String key) => null;

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[];

    void add(Widget w) {
      if (fields.isNotEmpty) fields.add(const SizedBox(height: 10));
      fields.add(w);
    }

    if (_canBeEntity) {
      add(
        _TypeToggle(
          value: applicant.type,
          onChanged: (t) {
            applicant.type = t;
            onChanged();
          },
        ),
      );
    }

    add(
      AppTextField(
        controller: applicant.nameController,
        onChanged: (_) => onChanged(),
        label: applicant.isEntity
            ? 'Entity Name *'
            : switch (applicant.role) {
                ApplicantRole.policyHolder => 'Policy Holder Name *',
                ApplicantRole.insured => 'Insured Person Name *',
                ApplicantRole.beneficiary => 'Beneficiary Name *',
              },
        prefixIcon: Icon(
          applicant.isEntity ? Icons.business_outlined : Icons.person_outline,
        ),
        helperText: _helper('name'),
        errorText: ApplicantValidators.name(applicant.nameController.text),
      ),
    );

    if (applicant.isEntity) {
      add(
        AppTextField(
          controller: applicant.regNoController,
          onChanged: (_) => onChanged(),
          label: 'Registration No *',
          prefixIcon: Icon(Icons.badge_outlined),
        ),
      );
      add(
        EappDropdownField(
          label: 'Business Type *',
          value: applicant.businessType,
          options: const [
            'Company',
            'Partnership',
            'Sole Proprietor',
            'NGO',
            'Government',
          ],
          onChanged: (v) {
            applicant.businessType = v;
            onChanged();
          },
        ),
      );
      add(
        EappDobField(
          label: 'Incorporation Date',
          date: applicant.incorporationDate,
          onPick: (d) {
            applicant.incorporationDate = d;
            onChanged();
          },
          notFuture: true,
        ),
      );
      add(
        AppTextField(
          controller: applicant.contactPersonController,
          onChanged: (_) => onChanged(),
          label: 'Contact Person *',
          prefixIcon: Icon(Icons.person_outline),
          errorText: ApplicantValidators.name(
            applicant.contactPersonController.text,
          ),
        ),
      );
    } else {
      add(
        AppTextField(
          controller: applicant.fatherNameController,
          onChanged: (_) => onChanged(),
          label: 'Father Name *',
          helperText: _helper('fatherName'),
          errorText: ApplicantValidators.name(
            applicant.fatherNameController.text,
          ),
        ),
      );
      add(
        EappDobField(
          label: 'Date of Birth *',
          date: applicant.dob,
          onPick: (d) {
            applicant.dob = d;
            onChanged();
          },
          ageOf: _isBeneficiary ? null : ApplicantValidators.ageOf,
          notFuture: _isBeneficiary,
        ),
      );
      if (!_isBeneficiary) {
        add(
          EappGenderField(
            value: applicant.gender,
            onChanged: (g) {
              applicant.gender = g;
              onChanged();
            },
          ),
        );
      }
      if (_isBeneficiary) {
        add(
          EappDropdownField(
            label: 'Relationship *',
            value: applicant.relationship,
            options: const ['Spouse', 'Child', 'Parent', 'Sibling', 'Other'],
            onChanged: (v) {
              applicant.relationship = v ?? applicant.relationship;
              onChanged();
            },
          ),
        );
      }
    }

    add(
      AppTextField(
        controller: applicant.mobileController,
        onChanged: (_) => onChanged(),
        keyboardType: TextInputType.phone,
        label: 'Mobile Phone No *',
        hint: '',
        showFlag: true,
        helperText: _helper('mobile'),
        errorText: _isBeneficiary
            ? ApplicantValidators.mobileDigits(applicant.mobileController.text)
            : applicant.role == ApplicantRole.insured
            ? ApplicantValidators.mobileFormat(applicant.mobileController.text)
            : null,
      ),
    );

    if (_isBeneficiary) {
      final ceiling = percentCeiling ?? 100;
      final own = int.tryParse(applicant.percentController.text.trim()) ?? 0;
      final unallocated = ceiling - own;
      add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: applicant.percentController,
              onChanged: (_) => onChanged(),
              keyboardType: TextInputType.number,
              label: 'Share *',
              suffixText: '%',
              inputFormatters: [PercentBudgetFormatter(max: ceiling)],
              // The cap explains itself in place, so a refused keystroke
              // never reads as a broken keyboard (doc 112 §2).
              helperText: unallocated > 0
                  ? 'Max $ceiling% — $unallocated% unallocated'
                  : 'Max $ceiling%',
              errorText: ApplicantValidators.percent(
                applicant.percentController.text,
              ),
            ),
            if (onUseRemaining != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onUseRemaining,
                  child: Text('Use remaining ($unallocated%)'),
                ),
              ),
          ],
        ),
      );
    } else {
      add(
        AppTextField(
          controller: applicant.emailController,
          onChanged: (_) => onChanged(),
          keyboardType: TextInputType.emailAddress,
          label: 'Email',
          helperText: _helper('email'),
          errorText: ApplicantValidators.email(applicant.emailController.text),
        ),
      );
    }

    if (!applicant.isEntity) {
      add(
        AppTextField(
          controller: applicant.idNoController,
          readOnly: true,
          label: 'Identification *',
          prefixIcon: Icon(Icons.badge_outlined),
          suffixIcon: const Icon(Icons.chevron_right),
          helperText: _helper('nrc'),
          errorText: ApplicantValidators.idNo(applicant.idNoController.text),
          onTap: () async {
            final result = await showIdentificationPickerSheet(
              context,
              initial: applicant.idNoController.text,
            );
            if (result != null) {
              final (display, type) = result;
              applicant.idNoController.text = display;
              applicant.idType = type;
              // The Documentation step photographs whatever was chosen
              // here — an NRC has two sides, a passport one page.
              applicant.documentType = type == 'Passport' ? 'Passport' : 'NRC';
              onChanged();
            }
          },
        ),
      );
    }

    // Address is mandatory for the Policy Holder and the Insured Person
    // (Proposal Required Field sheet). It stays a single collapsed row —
    // the sub-sheet is what keeps 8 address fields off the card.
    if (!_isBeneficiary) {
      add(
        _AddressRow(
          applicant: applicant,
          prefilled: prefilledKeys.contains('address'),
          onChanged: onChanged,
        ),
      );
    }

    // Optional block — policy holder only. The Insured and Beneficiary
    // cards stay lean; their optional data lives on the holder record.
    if (!_isBeneficiary) {
      fields.add(const SizedBox(height: 4));
      fields.add(
        OptionalDetails(
          filledCount: applicant.filledOptionalCount,
          children: [
            const SizedBox(height: 4),
            EappDropdownField(
              label: 'Marital Status',
              value: applicant.maritalStatus,
              options: const ['Single', 'Married', 'Divorced', 'Widowed'],
              onChanged: (v) {
                applicant.maritalStatus = v;
                onChanged();
              },
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: applicant.occupationController,
              onChanged: (_) => onChanged(),
              label: 'Occupation',
              prefixIcon: Icon(Icons.work_outline),
              helperText: _helper('occupation'),
            ),
            const SizedBox(height: 10),
            MeasurementRow(applicant: applicant, onChanged: onChanged),
            const SizedBox(height: 10),
            AppTextField(
              controller: applicant.remarkController,
              onChanged: (_) => onChanged(),
              maxLines: 2,
              label: 'Remark',
            ),
          ],
        ),
      );
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: EappCardTitle(
                  title ?? (index == null ? '' : 'Beneficiary $index'),
                ),
              ),
              if (onRemove != null)
                InkWell(
                  onTap: onRemove,
                  child: Icon(
                    Icons.close,
                    size: context.iconBase,
                    color: AppColors.deepAlpha(0.4),
                  ),
                ),
            ],
          ),
          ?header,
          const SizedBox(height: 10),
          ...fields,
        ],
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.value, required this.onChanged});
  final ApplicantType value;
  final ValueChanged<ApplicantType> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [
      for (final t in ApplicantType.values)
        (
          t,
          t.label,
          t == ApplicantType.person
              ? Icons.person_outline
              : Icons.business_outlined,
        ),
    ];
    final index = options.indexWhere((t) => t.$1 == value).clamp(0, options.length - 1);
    return PillTabs(
      initialIndex: index,
      tabs: [
        for (final o in options)
          PillTab(label: o.$2, icon: o.$3),
      ],
      onPageChanged: (i) => onChanged(options[i].$1),
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.applicant,
    required this.prefilled,
    required this.onChanged,
  });
  final Applicant applicant;
  final bool prefilled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final summary = applicant.addressSummary;
    // Address opens a sub-sheet rather than taking typing, but it is one of
    // the card's fields — so it wears the same AppTextField shell as the
    // rest instead of a bare InputDecorator.
    return AppTextField(
      label: 'Address',
      suffixIcon: Icon(Icons.chevron_right, size: context.iconBase),
      onTap: () async {
        if (await showAddressSheet(context, applicant)) onChanged();
      },
      child: Text(
        summary ?? 'Tap to fill',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: summary == null ? FontWeight.normal : FontWeight.w600,
          color: summary == null ? AppColors.muted : AppColors.accentNavy,
        ),
      ),
    );
  }
}

/// Doc 112 §1 — the live budget. A stacked bar plus one line of text, so
/// the FA can see what is left before they type rather than discovering it
/// from a rejected keystroke or a red total at the bottom of the card.
class ShareAllocationBar extends StatelessWidget {
  const ShareAllocationBar({
    super.key,
    required this.shares,
    required this.labels,
  });

  /// Each beneficiary's share, in order.
  final List<int> shares;

  /// Display name (or "Beneficiary n") per share, same order.
  final List<String> labels;

  static const _segmentColors = [
    AppColors.primaryColor,
    AppColors.primaryColor,
    AppColors.accentNavy,
    AppColors.mint,
    AppColors.warn,
  ];

  @override
  Widget build(BuildContext context) {
    final total = shares.fold<int>(0, (a, b) => a + b);
    final remaining = 100 - total;
    final full = remaining == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                for (var i = 0; i < shares.length; i++)
                  if (shares[i] > 0)
                    Expanded(
                      flex: shares[i],
                      child: Container(
                        color: _segmentColors[i % _segmentColors.length],
                        margin: const EdgeInsets.only(right: 1),
                      ),
                    ),
                if (remaining > 0)
                  Expanded(
                    flex: remaining,
                    child: Container(color: AppColors.deepAlpha(0.08)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          full
              ? 'Fully allocated — 100%'
              : total > 100
              ? 'Over-allocated by ${total - 100}%'
              : 'Remaining $remaining% of 100%',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: full
                ? AppColors.mint
                : total > 100
                ? AppColors.danger
                : AppColors.deepAlpha(0.6),
          ),
        ),
        if (shares.length > 1) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              for (var i = 0; i < shares.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _segmentColors[i % _segmentColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${labels[i]} ${shares[i]}%',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.deepAlpha(0.6),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// The Town picker plus its three derived read-outs. Township, District
/// and State/Region are never typed — showing them as a single derived
/// line (rather than three disabled inputs) keeps the sheet short while
/// still proving to the FA that the picked town resolved correctly.
class _TownField extends StatefulWidget {
  const _TownField({required this.applicant});
  final Applicant applicant;

  @override
  State<_TownField> createState() => _TownFieldState();
}

class _TownFieldState extends State<_TownField> {
  Future<void> _pick() async {
    final entry = await showModalBottomSheet<TownEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: EappCardTitle('Select Town'),
            ),
            for (final t in kTownMaster)
              ListTile(
                dense: true,
                title: Text(t.town, style: const TextStyle(fontSize: 13.5)),
                subtitle: Text(
                  '${t.district} · ${t.stateRegion}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.deepAlpha(0.5),
                  ),
                ),
                onTap: () => Navigator.pop(context, t),
              ),
          ],
        ),
      ),
    );
    if (entry == null) return;
    setState(() {
      widget.applicant.townController.text = entry.town;
      widget.applicant.townshipController.text = entry.township;
      widget.applicant.districtController.text = entry.district;
      widget.applicant.stateRegionController.text = entry.stateRegion;
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.applicant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: a.townController,
          readOnly: true,
          label: 'Town *',
          prefixIcon: Icon(Icons.location_city_outlined),
          suffixIcon: const Icon(Icons.chevron_right),
          onTap: _pick,
        ),
        if (a.townshipController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              '${a.townshipController.text} · ${a.districtController.text} · '
              '${a.stateRegionController.text}',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.deepAlpha(0.55),
              ),
            ),
          ),
      ],
    );
  }
}

/// Height (ft/in) and Weight — optional, numeric-only. They reuse the
/// existing wheel pickers so the FA never types into three tiny boxes.
class MeasurementRow extends StatelessWidget {
  const MeasurementRow({
    super.key,
    required this.applicant,
    required this.onChanged,
  });
  final Applicant applicant;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final ft = applicant.heightFtController.text.trim();
    final inch = applicant.heightInController.text.trim();
    return Row(
      children: [
        Expanded(
          // Same shell as Weight beside it, which is a plain AppTextField.
          child: AppTextField(
            label: 'Height',
            suffixIcon: Icon(Icons.chevron_right, size: context.iconBase),
            onTap: () async {
              final result = await showHeightPickerSheet(context);
              if (result == null) return;
              // Pickers hand back 5' 7" — split it into the two numeric
              // fields the proposal payload actually carries.
              final m = RegExp(r"(\d+)'\s*(\d+)").firstMatch(result);
              if (m != null) {
                applicant.heightFtController.text = m.group(1)!;
                applicant.heightInController.text = m.group(2)!;
                onChanged();
              }
            },
            child: Text(
              ft.isEmpty ? 'Tap to set' : "$ft' $inch\"",
              style: TextStyle(
                fontSize: 13,
                fontWeight: ft.isEmpty ? FontWeight.normal : FontWeight.w600,
                color: ft.isEmpty ? AppColors.muted : AppColors.accentNavy,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppTextField(
            controller: applicant.weightController,
            readOnly: true,
            label: 'Weight (lb)',
            suffixIcon: Icon(Icons.chevron_right, size: context.iconBase),
            errorText: ApplicantValidators.numberOnly(
              applicant.weightController.text,
            ),
            onTap: () async {
              final result = await showWeightPickerSheet(context);
              if (result != null) {
                applicant.weightController.text = result;
                onChanged();
              }
            },
          ),
        ),
      ],
    );
  }
}
