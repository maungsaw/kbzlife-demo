import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/product.dart';
import '../const.dart';
import '../quote/quote_providers.dart';
import '../widgets/app_selection_chip.dart';
import '../widgets/soft_card.dart';
import 'product_icons.dart';
import 'product_view_preferences.dart';

class ProductsLibraryScreen extends ConsumerStatefulWidget {
  const ProductsLibraryScreen({super.key});

  @override
  ConsumerState<ProductsLibraryScreen> createState() =>
      _ProductLibraryScreenState();
}

class _ProductLibraryScreenState extends ConsumerState<ProductsLibraryScreen> {
  ProductCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final products = MockData.products
        .where((p) => _filter == null || p.category == _filter)
        .toList();
    final draftCount = ref.watch(savedQuotesProvider).length;
    final isGrid = ref.watch(productGridViewProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Saved quotes',
                onPressed: () => context.push('/quote/drafts'),
                icon: const Icon(Icons.description_outlined),
              ),
              if (draftCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$draftCount',
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Doc 113 §2 — the view toggle changes how *this list* is drawn,
          // so it lives with the filters it affects rather than in the
          // AppBar, where its overlay landed on top of the chip row.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        AppSelectionChip(
                          label: 'All ${MockData.products.length}',
                          selected: _filter == null,
                          onSelected: (_) => setState(() => _filter = null),
                        ),
                        for (final c in ProductCategory.values) ...[
                          const SizedBox(width: 8),
                          AppSelectionChip(
                            // Doc 113 — the count tells the FA how much is
                            // behind a filter before they tap it.
                            label:
                                '${ProductVisuals.labelFor(c)} '
                                '${MockData.products.where((p) => p.category == c).length}',
                            selected: _filter == c,
                            onSelected: (_) => setState(() => _filter = c),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  // Doc 130 §2 — the toggle is now a *density* switch, not
                  // a shape switch: rich one-per-row cards, or a compact
                  // list. There is no two-up grid any more.
                  tooltip: isGrid ? 'Compact list' : 'Product cards',
                  onPressed: () => ref
                      .read(productGridViewProvider.notifier)
                      .setGridView(!isGrid),
                  icon: Icon(
                    isGrid
                        ? Icons.view_list_outlined
                        : Icons.view_agenda_outlined,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isGrid
                ? ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _ProductRowCard(
                      product: products[i],
                      onTap: () =>
                          context.push('/products/${products[i].code}'),
                    ),
                  )
                : _ProductList(products: products),
          ),
        ],
      ),
    );
  }
}

class _ProductRowCard extends StatelessWidget {
  const _ProductRowCard({required this.product, required this.onTap});
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductIllustration(product: product, size: 88),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepAlpha(0.05),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    ProductVisuals.labelFor(product.category),
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepAlpha(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // The name is the headline of the row.
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    height: 1.25,
                    color: AppColors.deep,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.tagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: AppColors.deepAlpha(0.55),
                  ),
                ),
                const SizedBox(height: 8),
                // One clear call to action per row.
                Row(
                  children: [
                    const Text(
                      'View details',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.primaryColor.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Doc 113 — the list is a density change, not an information change: it
/// carries the same icon, name and tagline as the grid card.
class _ProductList extends StatelessWidget {
  const _ProductList({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
    itemCount: products.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, i) => SoftCard(
      onTap: () => context.push('/products/${products[i].code}'),
      child: Row(
        children: [
          ProductIllustration(product: products[i], size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  products[i].name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: AppColors.deep,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  products[i].tagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.deepAlpha(0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: AppColors.deepAlpha(0.3)),
        ],
      ),
    ),
  );
}
