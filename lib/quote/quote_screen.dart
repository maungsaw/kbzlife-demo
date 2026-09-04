import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/product.dart';
import '../../data/models/quote_draft.dart';
import '../../data/models/quote_field.dart';
import '../const.dart';
import '../products/product_icons.dart';
import '../widgets/app_number.dart';
import '../widgets/app_text.dart';
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
        backgroundColor: context.colors.cream,
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
                        Icon(
                          Icons.info_outline,
                          size: context.iconBase,
                          color: context.colors.warn,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: AppCaptionText(error)),
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
                      child: const Text('Calculate'),
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
                  color: context.colors.mint.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: context.colors.mint),
              ),
              const SizedBox(width: 12),
              Expanded(child: const AppSectionTitle('Quote saved')),
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
            backgroundColor: context.colors.paper,
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
            color: context.colors.paper,
            borderRadius: BorderRadius.circular(16),
            // Doc 130 §3 — brand blue, not the category colour.
            border: Border.all(
              color: context.colors.primaryColor.withValues(alpha: 0.35),
              width: 1.4,
            ),
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
                    // Same eyebrow-over-value shape the e-App slots use.
                    const AppLabelText('PRODUCT'),
                    const SizedBox(height: 2),
                    Text(
                      selected.name,
                      style: TextStyle(
                        fontSize: AppType.title,
                        fontWeight: AppType.strong,
                        color: context.colors.textPrimary,
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
                  color: context.colors.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.expand_more,
                  size: context.iconXl,
                  color: context.colors.primaryColor,
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
            const AppSectionTitle('Select product'),
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
                        title: AppBodyText(p.name),
                        trailing: p.code == selected.code
                            ? Icon(
                                Icons.check,
                                color: context.colors.primaryColor,
                                size: context.iconLg,
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

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return SoftCard(
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: context.iconLg,
              color: context.colors.warn,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppBodyText(
                error ?? 'Enter details to see a premium',
                muted: true,
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
                Expanded(child: AppSectionTitle(product.name)),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onBookmark,
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.colors.primaryColor.withValues(
                        alpha: 0.14,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bookmark_border,
                      size: context.iconLg,
                      color: context.colors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Column(
              children: [
                _Row('Product Name', product.name),
                for (final (label, val) in r.lines) _Row(label, val),
                // Premium sits with the figures it is derived from, and
                // directly above the fee that is added to it.
                _Row('Premium', AppNumber.money(r.premium)),
                _Row('Stamp Fee', AppNumber.money(_stampFee)),
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
                  AppNumber.money(r.total),
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
          Expanded(child: AppLabelText(label)),
          const SizedBox(width: 10),
          AppBodyText(value, strong: true),
        ],
      ),
    );
  }
}
