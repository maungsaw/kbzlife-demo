import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/product.dart';
import '../const.dart';
import 'product_scene.dart';

class ProductVisuals {
  ProductVisuals._();

  static const _byCode = <String, FaIconData>{
    // Saving — what the money is for.
    'UL-01': FontAwesomeIcons.chartLine,
    'STE-01': FontAwesomeIcons.piggyBank,
    'EL-01': FontAwesomeIcons.graduationCap,
    // Protection — who or what is covered.
    'GL-01': FontAwesomeIcons.users,
    'PA-01': FontAwesomeIcons.personFalling,
    'CLP-01': FontAwesomeIcons.buildingColumns,
    'CLS-01': FontAwesomeIcons.creditCard,
    'TV-01': FontAwesomeIcons.plane,
    // Health — the care being paid for.
    'HI-01': FontAwesomeIcons.hospital,
    'IM-01': FontAwesomeIcons.stethoscope,
    'MH-01': FontAwesomeIcons.shieldHeart,
    'CI-01': FontAwesomeIcons.heartPulse,
  };

  /// Falls back to the category glyph for any product not yet mapped, so a
  /// new product code renders sensibly before anyone picks its icon.
  static FaIconData iconFor(Product product) =>
      _byCode[product.code] ?? categoryIcon(product.category);

  static FaIconData categoryIcon(ProductCategory category) => switch (category) {
    ProductCategory.protection => FontAwesomeIcons.shield,
    ProductCategory.saving => FontAwesomeIcons.piggyBank,
    ProductCategory.health => FontAwesomeIcons.heart,
  };

  /// Category colour — the pairing the product detail and quote screens
  /// already used before this file existed, so unifying on it changes no
  /// screen's established look. Baltic was tried for Protection and reads
  /// as grey at the 12% plate alpha; primaryColor keeps the largest group on the
  /// brand primary, and the soft red carries the medical association.
  static Color colorFor(ProductCategory category) => switch (category) {
    ProductCategory.protection => kAppColors.primaryColor,
    ProductCategory.saving => kAppColors.mint,
    ProductCategory.health => kAppColors.danger,
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
    'CLP-01': 'short_term_single_premium_credit_life',
    'CLS-01': 'single_premium_credit',
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
        color: context.colors.primaryColor.withValues(alpha: 0.10),
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
      child: FaIcon(
        ProductVisuals.iconFor(product),
        size: iconSize,
        color: color,
      ),
    );
  }
}
