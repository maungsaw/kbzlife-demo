import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/product.dart';
import '../const.dart';
import '../providers/router_provider.dart';
import '../widgets/soft_card.dart';
import '../widgets/pill_tabs.dart';
import 'product_icons.dart';
import '../../data/models/quote_field.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productCode});
  final String productCode;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

enum _Tab {
  about('About', 'What the policy is and who it is for'),
  coverage('Coverage', "What's covered, and what is not"),
  eligibility('Eligibility', 'Who can be insured and who can buy');

  const _Tab(this.label, this.hint);
  final String label;
  final String hint;
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  _Tab _tab = _Tab.about;

  @override
  Widget build(BuildContext context) {
    final product = MockData.products.firstWhere(
      (p) => p.code == widget.productCode,
      orElse: () => MockData.products.first,
    );

    final stats = _buildStats(product);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: 64,
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.name,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: context.colors.deep,
                ),
              ),
              Text(
                '${_categoryLabel(product.category)} · ${product.code}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: context.colors.deepAlpha(0.5),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Compare',
            color: context.colors.primaryColor,
            onPressed: () {
              final peer = MockData.products.firstWhere(
                (p) => p.code != product.code && p.category == product.category,
                orElse: () => MockData.products.firstWhere(
                  (p) => p.code != product.code,
                  orElse: () => product,
                ),
              );
              if (peer.code == product.code) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Need at least two products to compare'),
                  ),
                );
                return;
              }
              context.push(
                '${RoutePaths.productsCompare}?left=${product.code}&right=${peer.code}',
              );
            },
            icon: const FaIcon(FontAwesomeIcons.rightLeft),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeroCard(product: product),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 14),
            _StatGrid(stats: stats),
          ],
          const SizedBox(height: 14),
          SizedBox(
            child: PillTabs(
              initialIndex: _tab.index,
              tabs: const [
                PillTab(label: 'About'),
                PillTab(label: 'Coverage'),
                PillTab(label: 'Eligibility'),
              ],
              onPageChanged: (i) => setState(() => _tab = _Tab.values[i]),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _tab.hint,
              style: TextStyle(
                fontSize: 11.5,
                color: context.colors.deepAlpha(0.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._tabContent(product),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/quote?product=${product.code}'),
                icon: FaIcon(
                  FontAwesomeIcons.calculator,
                  size: context.iconBase,
                ),
                label: const Text('Calculate Premium'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/e-app?product=${product.code}'),
                icon: Icon(Icons.description_outlined, size: context.iconLg),
                label: const Text('Start e-App'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _tabContent(Product product) => switch (_tab) {
    _Tab.about => [
      if ((product.description ?? '').isNotEmpty)
        _Section(
          title: 'About this policy',
          child: Text(
            product.description!,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: context.colors.deepAlpha(0.75),
            ),
          ),
        ),
      if (product.eligibility.isNotEmpty) ...[
        const SizedBox(height: 10),
        _Section(
          title: 'This policy is designed for',
          child: _Bullets(
            lines: product.eligibility,
            icon: FontAwesomeIcons.user,
            color: context.colors.primaryColor,
          ),
        ),
      ],
      const SizedBox(height: 10),
      _AccordionCard(
        entry: _AccordionEntry(
          icon: FontAwesomeIcons.fileLines,
          color: context.colors.primaryColor,
          title: 'Endorsements',
          lines: [
            'Riders and endorsements for this product are managed through '
                'the Core system.',
          ],
        ),
      ),
      const SizedBox(height: 10),
      _AccordionCard(
        entry: _AccordionEntry(
          icon: FontAwesomeIcons.cartShopping,
          color: context.colors.primaryColor,
          title: 'How to purchase',
          lines: [
            'Contact your KBZ Life agent or branch to purchase this policy.',
          ],
        ),
      ),
      const SizedBox(height: 10),
      _AccordionCard(
        entry: _AccordionEntry(
          icon: FontAwesomeIcons.clockRotateLeft,
          color: context.colors.primaryColor,
          title: 'How to claim',
          lines: [
            'Claims can be filed through the Resource Center or by '
                'contacting your agent.',
          ],
        ),
      ),
    ],
    _Tab.coverage => [
      if (product.benefits.isNotEmpty)
        _Section(
          title: "What's covered",
          child: _Bullets(
            lines: product.benefits,
            icon: FontAwesomeIcons.solidCircleCheck,
            color: context.colors.mint,
          ),
        ),
      if (product.exclusions.isNotEmpty) ...[
        const SizedBox(height: 10),
        _Section(
          title: "What's not covered",
          child: _Bullets(
            lines: product.exclusions,
            icon: FontAwesomeIcons.solidCircleXmark,
            color: context.colors.warn,
          ),
        ),
      ],
      if (product.benefits.isEmpty && product.exclusions.isEmpty)
        const _EmptySection(
          text: 'Coverage details for this product come from Core.',
        ),
    ],
    _Tab.eligibility => [
      if (product.eligibility.isNotEmpty)
        _Section(
          title: 'Who can be insured',
          child: _Bullets(
            lines: product.eligibility,
            icon: FontAwesomeIcons.solidCircleCheck,
            color: context.colors.primaryColor,
          ),
        )
      else
        const _EmptySection(
          text: 'Eligibility rules for this product come from Core.',
        ),
    ],
  };
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
            color: context.colors.deep,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

class _Bullets extends StatelessWidget {
  const _Bullets({
    required this.lines,
    required this.icon,
    required this.color,
  });
  final List<String> lines;
  final FaIconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final line in lines)
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: FaIcon(icon, size: context.iconBase, color: color),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  line,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: context.colors.deepAlpha(0.75),
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Text(
      text,
      style: TextStyle(fontSize: 12, color: context.colors.deepAlpha(0.5)),
    ),
  );
}

String _categoryLabel(ProductCategory c) {
  final n = c.name;
  return n[0].toUpperCase() + n.substring(1);
}

String _fmtNum(num n) {
  final s = n.toInt().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final posFromEnd = s.length - i;
    buf.write(s[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buf.write(',');
  }
  return buf.toString();
}

QuoteFieldSpec? _fieldByKey(Product p, String key) {
  for (final f in p.calculatorFields) {
    if (f.key == key) return f;
  }
  return null;
}

String _joinOptions(QuoteFieldSpec field) => field.options
    .map((o) => o.label.replaceAll(' Months', 'M').replaceAll(' Years', 'Y'))
    .join(' / ');

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductIllustration(product: product, size: 62),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: context.colors.deep,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.deepAlpha(0.05),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        _categoryLabel(product.category),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: context.colors.deepAlpha(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.tagline,
            style: TextStyle(
              fontSize: 12.5,
              color: context.colors.deepAlpha(0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat {
  const _Stat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  final FaIconData icon;
  final Color color;
  final String label;
  final String value;
}

List<_Stat> _buildStats(Product product) {
  final stats = <_Stat>[];

  final sumInsured = _fieldByKey(product, 'sumInsured');
  final baseAnnual = _fieldByKey(product, 'baseAnnual');
  if (sumInsured != null && sumInsured.defaultNumber != null) {
    stats.add(
      _Stat(
        icon: FontAwesomeIcons.shield,
        color: kAppColors.primaryColor,
        label: 'Sum Insured',
        value: 'From ${_fmtNum(sumInsured.defaultNumber!)} MMK',
      ),
    );
  } else if (baseAnnual == null) {
    stats.add(
      _Stat(
        icon: FontAwesomeIcons.shield,
        color: kAppColors.primaryColor,
        label: 'Coverage',
        value: product.coverage,
      ),
    );
  }

  final policyTerm = _fieldByKey(product, 'policyTerm');
  final policyTermYears = _fieldByKey(product, 'policyTermYears');
  if (policyTerm != null && policyTerm.options.isNotEmpty) {
    stats.add(
      _Stat(
        icon: FontAwesomeIcons.calendar,
        color: kAppColors.primaryColor,
        label: 'Term',
        value: _joinOptions(policyTerm),
      ),
    );
  } else if (policyTermYears != null && policyTermYears.defaultNumber != null) {
    stats.add(
      _Stat(
        icon: FontAwesomeIcons.calendar,
        color: kAppColors.primaryColor,
        label: 'Term',
        value: '${policyTermYears.defaultNumber} yrs',
      ),
    );
  }

  if (baseAnnual != null && baseAnnual.defaultNumber != null) {
    stats.add(
      _Stat(
        icon: FontAwesomeIcons.clock,
        color: kAppColors.primaryColor,
        label: 'Premium',
        value: 'From ${_fmtNum(baseAnnual.defaultNumber!)} MMK/yr',
      ),
    );
  }

  final paymentType = _fieldByKey(product, 'paymentType');
  final productType = _fieldByKey(product, 'productType');
  final dividendRate = _fieldByKey(product, 'dividendRate');
  if (paymentType != null && paymentType.options.isNotEmpty) {
    stats.add(
      _Stat(
        icon: FontAwesomeIcons.circlePlus,
        color: kAppColors.mint,
        label: 'Payment',
        value: _joinOptions(paymentType),
      ),
    );
  } else if (productType != null && productType.options.isNotEmpty) {
    stats.add(
      _Stat(
        icon: FontAwesomeIcons.circlePlus,
        color: kAppColors.mint,
        label: 'Type',
        value: _joinOptions(productType),
      ),
    );
  } else if (dividendRate != null && dividendRate.defaultNumber != null) {
    stats.add(
      _Stat(
        icon: FontAwesomeIcons.circlePlus,
        color: kAppColors.mint,
        label: 'Dividend Rate',
        value: '${dividendRate.defaultNumber}%',
      ),
    );
  }

  return stats;
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});
  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    final rows = <List<_Stat>>[
      for (var i = 0; i < stats.length; i += 2) stats.skip(i).take(2).toList(),
    ];
    return SoftCard(
      child: Column(
        children: [
          for (final row in rows) ...[
            if (row != rows.first) const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _StatCell(stat: row.first)),
                const SizedBox(width: 12),
                Expanded(
                  child: row.length > 1
                      ? _StatCell(stat: row[1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.stat});
  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: stat.color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: FaIcon(stat.icon, size: context.iconBase, color: stat.color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.label,
                style: TextStyle(
                  fontSize: 10.5,
                  color: context.colors.deepAlpha(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stat.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: context.colors.deep,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccordionEntry {
  const _AccordionEntry({
    required this.icon,
    required this.color,
    required this.title,
    required this.lines,
  });
  final FaIconData icon;
  final Color color;
  final String title;
  final List<String> lines;
}

class _AccordionCard extends StatefulWidget {
  const _AccordionCard({required this.entry});
  final _AccordionEntry entry;

  @override
  State<_AccordionCard> createState() => _AccordionCardState();
}

class _AccordionCardState extends State<_AccordionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: entry.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(entry.icon, size: 17, color: entry.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: context.colors.deep,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: FaIcon(
                    FontAwesomeIcons.chevronDown,
                    color: context.colors.deepAlpha(0.4),
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 14, left: 46),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in entry.lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: entry.lines.length > 1
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '•  ',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: context.colors.deepAlpha(0.4),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    line,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: context.colors.deepAlpha(0.7),
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              line,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.colors.deepAlpha(0.7),
                                height: 1.45,
                              ),
                            ),
                    ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}
