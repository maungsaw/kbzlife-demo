import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../const.dart';
import '../providers/router_provider.dart';
import '../widgets/tab_view.dart';
import 'data.dart';
import 'model.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Saving',
    'Protection',
    'Health',
    'Travel',
    'Business',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ProductItem> get _filteredProducts {
    final currentCategory = _categories[_tabController.index];
    return products.where((product) {
      final matchesCategory =
          currentCategory == 'All' || product.category == currentCategory;
      final matchesSearch = product.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: context.colors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: context.iconXxl, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomTabView(
        controller: _tabController,
        isScrollable: true,
        labelColor: context.colors.primaryColor,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: context.colors.primaryColor,
        tabs: _categories.map((cat) => TabItemData(label: cat)).toList(),
        tabViews: _categories.map((cat) {
          if (_filteredProducts.isEmpty) {
            return _buildEmptyState();
          }
          return _buildCategoryView(_filteredProducts);
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryView(List<ProductItem> categoryProducts) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: categoryProducts.length,
      itemBuilder: (context, index) {
        final product = categoryProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductItem product) {
    return GestureDetector(
      onTap: () {
        context.push(RoutePaths.productDetail.replaceFirst(':code', product.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120, // Sets fixed height for the card & left image
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border, width: 1),
        ),
        child: Row(
          children: [
            // Large Left Image (takes full height of 120px and fixed 110px width)
            SizedBox(
              width: 110,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                child: product.imageAsset != null
                    ? Image.asset(
                        product.imageAsset!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: context.colors.infoLight,
                        child: Center(
                          child: Icon(
                            product.icon,
                            size: 36,
                            color: context.colors.primaryColor,
                          ),
                        ),
                      ),
              ),
            ),

            // Content on the Right
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.muted,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: context.colors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                        Icons.arrow_forward,
                        size: context.iconMd,
                          color: context.colors.primaryColor,
                        ),
                      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: context.icon7xl,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No insurance products found',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
