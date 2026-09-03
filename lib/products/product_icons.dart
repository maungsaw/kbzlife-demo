import 'package:flutter/material.dart';

import '../../data/models/product.dart';
import '../const.dart';
import 'product_scene.dart';

class ProductVisuals {
  ProductVisuals._();

  static const _byCode = <String, IconData>{
    // Saving — what the money is for.
    'UL-01': Icons.trending_up, // wealth that grows
    'STE-01': Icons.savings_outlined, // cash accumulation
    'EL-01': Icons.school_outlined, // school fees
    // Protection — who or what is covered.
    'GL-01': Icons.groups_outlined, // a workforce
    'PA-01': Icons.personal_injury_outlined, // injury cover
    'CLP-01': Icons.account_balance_outlined, // bank loan
    'CLS-01': Icons.credit_score_outlined, // short-term credit
    'TV-01': Icons.flight_outlined, // travel
    // Health — the care being paid for.
    'HI-01': Icons.local_hospital_outlined, // in-patient
    'IM-01': Icons.medical_services_outlined, // individual medical
    'MH-01': Icons.health_and_safety_outlined, // micro health
    'CI-01': Icons.monitor_heart_outlined, // critical condition
  };

  /// Falls back to the category glyph for any product not yet mapped, so a
  /// new product code renders sensibly before anyone picks its icon.
  static IconData iconFor(Product product) =>
      _byCode[product.code] ?? categoryIcon(product.category);

  static IconData categoryIcon(ProductCategory category) => switch (category) {
    ProductCategory.protection => Icons.shield_outlined,
    ProductCategory.saving => Icons.savings_outlined,
    ProductCategory.health => Icons.favorite_border,
  };

  /// Category colour — the pairing the product detail and quote screens
  /// already used before this file existed, so unifying on it changes no
  /// screen's established look. Baltic was tried for Protection and reads
  /// as grey at the 12% plate alpha; primaryColor keeps the largest group on the
  /// brand primary, and the soft red carries the medical association.
  static Color colorFor(ProductCategory category) => switch (category) {
    ProductCategory.protection => AppColors.primaryColor,
    ProductCategory.saving => AppColors.mint,
    ProductCategory.health => AppColors.danger,
  };

  static String labelFor(ProductCategory category) => switch (category) {
    ProductCategory.protection => 'Protection',
    ProductCategory.saving => 'Saving',
    ProductCategory.health => 'Health',
  };
}

/// Doc 130 §1 — the per-product illustration, if one has been supplied.
///
/// Feedback on the Products Library asked for vector illustrations in
/// place of icons. Rather than block on artwork, every product looks for
/// `assets/products/<code>.png` (lower-cased) and falls back to its icon
/// plate when the file is not there — so the six that exist can ship
/// while the rest follow, with no code change per product.
class ProductIllustration extends StatelessWidget {
  const ProductIllustration({super.key, required this.product, this.size = 88});

  final Product product;
  final double size;

  /// Doc 133 — the supplied artwork, by product code. Mapped by name
  /// rather than derived from the code: the files arrived named after the
  /// products, and renaming someone's assets to suit a lookup is how a
  /// re-export later silently breaks the screen.
  static const _assets = <String, String>{
    'UL-01': 'universal_life',
    'STE-01': 'short_term_endowment',
    'EL-01': 'education_life',
    'GL-01': 'group_life',
    'PA-01': 'personal_accident',
    'CLP-01': 'credit_life_insurance_single_premium',
    'CLS-01': 'credit_life_insurance_short_term_single_premium',
    'TV-01': 'travel',
    'HI-01': 'health_insurance',
    'IM-01': 'i_medical',
    'MH-01': 'micro_health',
    'CI-01': 'critical_illness',
  };

  static String? assetFor(Product product) {
    final name = _assets[product.code];
    return name == null ? null : 'assets/products/$name.jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final asset = assetFor(product);
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: asset == null
          ? ProductScene(product: product, size: size)
          : Image.asset(
              asset,
              fit: BoxFit.cover,

              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, _, _) =>
                  ProductScene(product: product, size: size),
            ),
    );
  }
}

/// The product's icon on its category-tinted plate. One widget so the
/// plate, radius and icon-to-plate ratio cannot drift between screens.
class ProductIconTile extends StatelessWidget {
  const ProductIconTile({
    super.key,
    required this.product,
    this.size = 64,
    this.iconSize = 30,
    this.expand = false,
  });

  final Product product;
  final double size;
  final double iconSize;

  /// Stretch to the available width (the library grid's header band)
  /// instead of drawing a square plate.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final color = ProductVisuals.colorFor(product.category);
    return Container(
      height: size,
      width: expand ? double.infinity : size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        ProductVisuals.iconFor(product),
        size: iconSize,
        color: color,
      ),
    );
  }
}
