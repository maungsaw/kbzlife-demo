import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/product.dart';
import '../const.dart';
import '../products/product_icons.dart';
import '../../data/models/quote_draft.dart';
import '../../data/models/quote_field.dart';
import '../widgets/quote_field.dart';
import '../widgets/soft_card.dart';
import 'quote_providers.dart';

class QuoteScreen extends ConsumerStatefulWidget {
  const QuoteScreen({super.key, this.productCode});
  final String? productCode;

  @override
  ConsumerState<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends ConsumerState<QuoteScreen> {
  int _step = 0;
  String? _stepProductCode;

  @override
  Widget build(BuildContext context) {
    final product = MockData.products.firstWhere(
      (p) => p.code == widget.productCode,
      orElse: () => MockData.products.first,
    );
    if (_stepProductCode != product.code) {
      _stepProductCode = product.code;
      _step = 0;
    }
    final answers = ref.watch(quoteFormProvider(product));
    final controller = ref.read(quoteFormProvider(product).notifier);
    final result = controller.calculate();
    final error = controller.validate();

    void goBack() {
      if (_step == 1) {
        setState(() => _step = 0);
        return;
      }
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/products');
      }
    }

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            onPressed: goBack,
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Premium Calculator'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: _step == 0
              ? [
                  _ProductPicker(selected: product),
                  const SizedBox(height: 12),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final field in product.calculatorFields)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: QuoteFieldRenderer(
                              field:
                                  product.code == 'UL-01' &&
                                      field.type == QuoteFieldType.date &&
                                      field.key == 'dob'
                                  ? _withAgeHint(
                                      field,
                                      controller.ageAt(DateTime.now()),
                                    )
                                  : field,
                              value: answers[field.key],
                              onChanged: (v) =>
                                  controller.setValue(field.key, v),
                              onToggleMulti: (v) =>
                                  controller.toggleMulti(field.key, v),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.warn,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.deepAlpha(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: result == null
                          ? null
                          : () => setState(() => _step = 1),
                      child: const Text('Calculate Premium'),
                    ),
                  ),
                ]
              : [
                  _PremiumHero(
                    product: product,
                    answers: answers,
                    result: result,
                    error: error,
                    onBookmark: () => _requireLogin(
                      context,
                      true,
                      () => _saveDraft(context, ref, product, result!),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Center(
                  //   child: TextButton.icon(
                  //     onPressed: () => setState(() => _step = 0),
                  //     icon: const Icon(Icons.edit_outlined, size: 15),
                  //     label: const Text('Edit details'),
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: result == null
                          ? null
                          : () => _requireLogin(
                              context,
                              true,
                              () => context.push(
                                '/e-app?product=${product.code}',
                              ),
                            ),
                      child: const Text('Start e-App'),
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  /// Universal Life's mockup labels the DOB field "Date Of Birth
  /// ( Policy Term - 43 )" — a live age-derived hint, not a static
  /// caption — so this appends it once an age can be computed.
  QuoteFieldSpec _withAgeHint(QuoteFieldSpec field, int? age) {
    if (age == null) return field;
    return QuoteFieldSpec(
      key: field.key,
      label: '${field.label} ( Policy Term - $age )',
      type: field.type,
      options: field.options,
      suffix: field.suffix,
      defaultNumber: field.defaultNumber,
      helperText: field.helperText,
    );
  }

  void _requireLogin(
    BuildContext context,
    bool isLoggedIn,
    VoidCallback action,
  ) {
    if (isLoggedIn) {
      action();
      return;
    }
  }

  void _saveDraft(
    BuildContext context,
    WidgetRef ref,
    Product product,
    QuoteCalcResult result,
  ) {
    ref
        .read(savedQuotesProvider.notifier)
        .add(
          QuoteDraft(
            id: 'QT-${DateTime.now().millisecondsSinceEpoch}',
            productCode: product.code,
            productName: product.name,
            premium: result.total,
            savedAt: DateTime.now(),
          ),
        );
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _QuoteSavedSheet(product: product),
    );
  }
}

/// Doc 100 — Quote saved: two CTAs on one row (View saved quotes outline
/// left, Start e-App filled right); no third "Back to Products" link —
/// the AppBar back chevron already owns that job.
class _QuoteSavedSheet extends StatelessWidget {
  const _QuoteSavedSheet({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.mint),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Quote saved',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.deep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/quote/drafts');
                    },
                    child: const FittedBox(child: Text('View saved quotes')),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/e-app?product=${product.code}');
                    },
                    child: const Text('Start e-App'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductPicker extends ConsumerStatefulWidget {
  const _ProductPicker({required this.selected});
  final Product selected;

  @override
  ConsumerState<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends ConsumerState<_ProductPicker> {
  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final chosen = await showModalBottomSheet<Product>(
            context: context,
            backgroundColor: AppColors.paper,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (sheetContext) => _ProductPickerSheet(selected: selected),
          );
          if (chosen != null && context.mounted) {
            context.go('/quote?product=${chosen.code}');
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(16),
            // Doc 130 §3 — brand blue, not the category colour.
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.35),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepAlpha(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Doc 130 §4 — shared illustration.
              ProductIllustration(product: selected, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRODUCT',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: AppColors.deepAlpha(0.45),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selected.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deep,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.expand_more,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductPickerSheet extends StatelessWidget {
  const _ProductPickerSheet({required this.selected});
  final Product selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select product',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.deep,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final p in MockData.products)
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        title: Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deep,
                          ),
                        ),
                        trailing: p.code == selected.code
                            ? const Icon(
                                Icons.check,
                                color: AppColors.primaryColor,
                                size: 18,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, p),
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
}

/// Doc — plain white result card (not the previous gradient hero): a
/// header row (product name + bookmark), a primaryColor-tinted "Premium" row for
/// the headline figure, a plain label/value list built from whatever
/// [QuoteCalcResult.lines] the selected product produced, a hardcoded
/// "Stamp Fee" row mirroring `QuoteFormController.calculate()`'s `stamp`
/// constant, and a divider before the final Total Amount row.
class _PremiumHero extends StatelessWidget {
  const _PremiumHero({
    required this.product,
    required this.answers,
    required this.result,
    required this.error,
    required this.onBookmark,
  });
  final Product product;
  final Map<String, dynamic> answers;
  final QuoteCalcResult? result;
  final String? error;
  final VoidCallback onBookmark;

  static const _stampFee = 100;
  static final _money = NumberFormat('#,##0.00', 'en_US');

  /// Payment-cadence wording for the highlighted premium row — reads the
  /// selected `paymentType` option's label when the product has one
  /// (e.g. "Monthly", "Semi Annually"); products without that field are
  /// lump-sum priced per their eligibility copy, so those fall back to
  /// "Lumpsum"; anything unrecognized falls back to a bare "Premium".
  String _premiumLabel() {
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

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return SoftCard(
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 18, color: AppColors.warn),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error ?? 'Enter details to see a premium',
                style: TextStyle(fontSize: 13, color: AppColors.deepAlpha(0.6)),
              ),
            ),
          ],
        ),
      );
    }

    final r = result!;
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deep,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onBookmark,
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
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
                  _premiumLabel(),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deep,
                  ),
                ),
                Text(
                  _money.format(r.premium),
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
                for (final (label, val) in r.lines) _Row(label, val),
                _Row('Stamp Fee', _money.format(_stampFee)),
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
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deep,
                  ),
                ),
                Text(
                  _money.format(r.total),
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deep,
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
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.deepAlpha(0.55),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.deep,
            ),
          ),
        ],
      ),
    );
  }
}
