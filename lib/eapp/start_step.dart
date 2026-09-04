import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/product.dart';
import '../const.dart';
import '../crm/model.dart';
import '../crm/provider.dart';
import '../products/product_icons.dart';
import '../quote/quote_providers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/app_selection_chip.dart';
import '../widgets/app_text.dart';
import '../widgets/app_text_field.dart';
import '../widgets/quote_field.dart';
import '../widgets/soft_card.dart';
import 'applicant_card.dart';

/// Doc 111 §2 — the single entry funnel. Every door into the e-App lands
/// here, and whichever of the three slots the door already knows arrives
/// filled and collapsed: CRM brings the customer, "Buy"/"Continue" from a
/// product or quote brings the product and its premium. What is left open
/// is exactly what the FA still has to decide.
class EappStartStep extends ConsumerStatefulWidget {
  const EappStartStep({
    super.key,
    required this.initialProductCode,
    required this.initialCustomerId,
    required this.onContinue,
  });

  final String? initialProductCode;
  final String? initialCustomerId;
  final void Function(String productCode, String? customerId) onContinue;

  @override
  ConsumerState<EappStartStep> createState() => _EappStartStepState();
}

class _EappStartStepState extends ConsumerState<EappStartStep> {
  String? _productCode;
  String? _customerId;
  late ProductCategory? _category;

  /// Validation stays silent until the FA presses Continue. Opening the
  /// step with "Date of birth ထည့်ပါ" already in red accuses them of a
  /// mistake they have not had the chance to make; the check belongs to
  /// the moment they say the form is finished.
  bool _submitted = false;

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
  /// The linked contact as the card shows it. Two stores feed this screen —
  /// the Customer records and the CRM contact list, whose IDs do not overlap —
  /// so a pick from either has to resolve here or the card reads as empty.
  ({String name, String tag, String phone})? get _customerDisplay {
    final id = _customerId;
    if (id == null) return null;

    final controller = ref.read(crmControllerProvider.notifier);
    final customer = controller.byId(id) ?? controller.byName(id);
    if (customer != null) {
      return (
        name: customer.name,
        tag: customer.isClient ? 'Client' : 'Lead',
        phone: customer.phone,
      );
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
      phone: contact.phone,
    );
  }

  Future<void> _pickCustomer() async {
    final contacts = await ref.read(crmContactsProvider.future);
    if (!mounted) return;
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.paper,
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

    // Shown only after a rejected Continue, and only for the slot at fault.
    final showProductError = _submitted && product == null;
    final showPremiumError = _submitted && product != null && error != null;

    return Scaffold(
      backgroundColor: context.colors.cream,
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            // Never disabled: a dead button says "no" without saying why.
            onPressed: () {
              if (ready) {
                widget.onContinue(product.code, _customerId);
                return;
              }
              setState(() => _submitted = true);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      product == null
                          ? 'Choose a product to continue.'
                          : error ??
                                'Complete the premium details to continue.',
                    ),
                  ),
                );
            },
            icon: Icon(Icons.arrow_forward, size: context.iconLg),
            label: const Text('Continue to e-Application'),
          ),
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
                _CustomerSlotCard(
                  customer: customer,
                  onPick: _pickCustomer,
                  onClear: () => setState(() => _customerId = null),
                ),
                const _SlotDivider(),

                // --- Slot 2: category then product ----------------------
                _StartSlotRow(
                  title: 'Product',
                  done: product != null,
                  value: product?.name,
                  hint: showProductError
                      ? 'Choose a product to continue'
                      : 'Pick a category, then the product',
                  error: showProductError,
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
                    title: 'Premium',
                    done: result != null,
                    value: result == null ? null : 'Inputs completed',
                    hint: 'Fill in the details for this product',
                    error: showPremiumError,
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
                        if (showPremiumError)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: context.iconSm,
                                color: context.colors.danger,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: AppCaptionText(
                                  error,
                                  color: context.colors.danger,
                                ),
                              ),
                            ],
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

/// The customer slot, given a card of its own: empty it is an invitation
/// with a named button, filled it is the person — avatar, name, phone and
/// what they are to the agency. A one-line row could not carry that, and
/// FAs could not tell the row was tappable at all.
class _CustomerSlotCard extends StatelessWidget {
  const _CustomerSlotCard({
    required this.customer,
    required this.onPick,
    required this.onClear,
  });

  final ({String name, String tag, String phone})? customer;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final c = customer;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Customer',
                style: TextStyle(
                  fontSize: AppType.caption,
                  fontWeight: AppType.strong,
                  letterSpacing: 0.3,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Optional',
                style: TextStyle(
                  fontSize: AppType.caption,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (c == null)
            InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.primaryColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_search_outlined,
                      size: context.iconLg,
                      color: context.colors.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select customer',
                            style: TextStyle(
                              fontSize: AppType.body,
                              fontWeight: AppType.strong,
                              color: context.colors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AppCaptionText(
                            'Prefills the form from a lead or client · '
                            'skip for a walk-in',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: context.colors.primaryColor.withValues(
                      alpha: 0.12,
                    ),
                    child: Text(
                      _initials(c.name),
                      style: TextStyle(
                        fontSize: AppType.label,
                        fontWeight: AppType.strong,
                        color: context.colors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppType.title,
                            fontWeight: AppType.strong,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: AppCaptionText(c.phone, maxLines: 1),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.deepAlpha(0.06),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                c.tag,
                                style: TextStyle(
                                  fontSize: AppType.caption,
                                  fontWeight: AppType.strong,
                                  color: context.colors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onPick,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Change'),
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    visualDensity: VisualDensity.compact,
                    onPressed: onClear,
                    icon: Icon(
                      Icons.close,
                      size: context.iconBase,
                      color: context.colors.deepAlpha(0.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _StartSlotRow extends StatelessWidget {
  /// The one inset every row, its expanded body and the divider share.
  static const double _gutter = 14;

  const _StartSlotRow({
    required this.title,
    required this.done,
    required this.hint,
    this.value,
    this.onTap,
    this.expanded,
    this.error = false,
  });

  final String title;
  final bool done;
  final String hint;
  final String? value;
  final VoidCallback? onTap;
  final Widget? expanded;

  /// The slot is what stopped Continue — its hint turns red until it is
  /// satisfied. Set only after a rejected submit, never on arrival.
  final bool error;

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppType.caption,
                  fontWeight: AppType.strong,
                  letterSpacing: 0.3,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value ?? hint,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: value == null ? AppType.label : AppType.body,
                  fontWeight: value == null ? AppType.normal : AppType.strong,
                  color: value != null
                      ? context.colors.textPrimary
                      : error
                      ? context.colors.danger
                      : context.colors.textSecondary,
                ),
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
        else if (!done && expanded == null && onTap != null)
          Icon(
            Icons.chevron_right,
            size: context.iconXl,
            color: context.colors.deepAlpha(0.35),
          ),
      ],
    );

    return Padding(
      // Same inset on both sides so the row, its expanded body and the
      // divider below all start and end on the same rule.
      padding: const EdgeInsets.fromLTRB(_gutter, 12, _gutter, 12),
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
          if (expanded != null) ...[const SizedBox(height: 12), expanded!],
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
                color: context.colors.deepAlpha(0.15),
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
                          size: context.icon5xl,
                          color: context.colors.deepAlpha(0.25),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No match for "${_searchController.text.trim()}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppType.body,
                            fontWeight: AppType.strong,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You can start the application without linking a '
                          'record and fill the details by hand.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppType.label,
                            color: context.colors.textSecondary,
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
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: context.colors.deepAlpha(0.06),
                      ),
                      itemBuilder: (context, i) {
                        final c = results[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: context.colors.deepAlpha(0.07),
                            child: Text(
                              c.name.isEmpty ? '?' : c.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: AppType.body,
                                fontWeight: AppType.strong,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                          title: Text(
                            c.name,
                            style: TextStyle(
                              fontSize: AppType.body,
                              fontWeight: AppType.strong,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            c.phone,
                            style: TextStyle(
                              fontSize: AppType.label,
                              color: context.colors.textSecondary,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: c.contactType.name == 'client'
                                  ? context.colors.mint.withValues(alpha: 0.14)
                                  : c.contactType.name == 'halfQualified'
                                  ? context.colors.warn.withValues(alpha: 0.14)
                                  : context.colors.deepAlpha(0.06),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              c.contactType.name == 'client'
                                  ? 'Client'
                                  : c.contactType.name == 'halfQualified'
                                  ? 'Half-Qualified'
                                  : 'Lead',
                              style: TextStyle(
                                fontSize: AppType.caption,
                                fontWeight: AppType.strong,
                                color: c.contactType.name == 'client'
                                    ? context.colors.mint
                                    : c.contactType.name == 'halfQualified'
                                    ? context.colors.warn
                                    : context.colors.primaryColor,
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
    color: context.colors.deepAlpha(0.06),
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
      color: selected ? context.colors.deep : context.colors.deepAlpha(0.04),
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
                size: context.iconXl,
                color: selected
                    ? Colors.white
                    : ProductVisuals.colorFor(category),
              ),
              const SizedBox(height: 6),
              Text(
                ProductVisuals.labelFor(category),
                style: TextStyle(
                  fontSize: AppType.label,
                  fontWeight: AppType.strong,
                  color: selected ? Colors.white : context.colors.deep,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count product${count == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: AppType.caption,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.75)
                      : context.colors.deepAlpha(0.45),
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
          ? context.colors.primaryColor.withValues(alpha: 0.12)
          : context.colors.deepAlpha(0.035),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              ProductIllustration(product: product, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontSize: AppType.label,
                    fontWeight: AppType.strong,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? context.colors.primaryColor
                    : context.colors.deepAlpha(0.3),
                size: context.iconXl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
