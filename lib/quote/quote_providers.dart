import 'package:flutter_riverpod/legacy.dart';

import '../../data/models/product.dart';
import '../../data/models/quote_draft.dart';
import '../../data/models/quote_field.dart';

class QuoteCalcResult {
  const QuoteCalcResult({
    required this.lines,
    required this.premium,
    required this.total,
  });
  final List<(String, String)> lines;
  final int premium;
  final int total;
}

class QuoteFormController extends StateNotifier<Map<String, dynamic>> {
  /// [blank] starts every field empty. The quote calculator seeds sensible
  /// defaults so a figure appears at once, but the e-App is the customer's
  /// own application — the FA types each value in, so nothing is pre-filled.
  QuoteFormController(this.product, {bool blank = false})
    : super(blank ? <String, dynamic>{} : _defaults(product)) {
    _recomputeComputedFields();
  }

  final Product product;

  static Map<String, dynamic> _defaults(Product product) {
    final map = <String, dynamic>{'dob': DateTime(1990, 2, 16)};
    for (final field in product.calculatorFields) {
      switch (field.type) {
        case QuoteFieldType.number:
          map[field.key] = field.defaultNumber ?? 0;
        case QuoteFieldType.singleSelect:
          if (field.options.isNotEmpty) {
            map[field.key] = field.options.first.value;
          }
        case QuoteFieldType.multiSelect:
          map[field.key] = <String>{};
        case QuoteFieldType.date:
        case QuoteFieldType.computed:
          break;
      }
    }
    return map;
  }

  void setValue(String key, dynamic value) {
    state = {...state, key: value};
    _recomputeComputedFields();
  }

  void toggleMulti(String key, String value) {
    final current = Set<String>.from(state[key] as Set<String>? ?? {});
    current.contains(value) ? current.remove(value) : current.add(value);
    setValue(key, current);
  }

  void _recomputeComputedFields() {
    if (product.code == 'UL-01') {
      final annual = state['baseAnnual'] as num?;
      state = {
        ...state,
        'baseMonthly': annual == null ? null : (annual / 12).round(),
      };
    }
  }

  int? ageAt(DateTime now) {
    final dob = state['dob'] as DateTime?;
    if (dob == null) return null;
    var age = now.year - dob.year;
    final beforeBirthday =
        now.month < dob.month || (now.month == dob.month && now.day < dob.day);
    if (beforeBirthday) age--;
    return age;
  }

  String? validate() {
    final age = ageAt(DateTime.now());
    if (age == null) return 'Date of birth ထည့်ပါ';
    if (age < 1 || age > 80) return 'အသက် မှန်ကန်စွာ ရွေးပါ';
    // Every field the product asks for has to be answered — the e-App
    // starts blank, so an unanswered select or an empty cover list would
    // otherwise sail through on the number checks alone.
    for (final field in product.calculatorFields) {
      switch (field.type) {
        case QuoteFieldType.number:
          if ((state[field.key] as num? ?? 0) <= 0) {
            return '${field.label} ဖြည့်ပါ';
          }
        case QuoteFieldType.singleSelect:
          final v = state[field.key];
          if (v == null || (v is String && v.trim().isEmpty)) {
            return '${field.label} ရွေးပါ';
          }
        case QuoteFieldType.multiSelect:
          final picked = state[field.key] as Set<String>? ?? const {};
          if (picked.isEmpty) return '${field.label} ရွေးပါ';
        case QuoteFieldType.date:
          if (state[field.key] == null) return '${field.label} ထည့်ပါ';
        case QuoteFieldType.computed:
          break;
      }
    }
    return null;
  }

  QuoteCalcResult? calculate() {
    if (validate() != null) return null;
    final a = state;
    int premium;
    final lines = <(String, String)>[];

    switch (product.code) {
      case 'UL-01':
        premium = ((a['baseAnnual'] as num?) ?? 0).round();
        lines.add((
          'Base premium (monthly)',
          '${_fmt(a['baseMonthly'] as int? ?? 0)} MMK',
        ));
        lines.add(('Dividend rate', '${a['dividendRate']}%'));
      case 'GL-01':
        premium = (((a['sumInsured'] as num?) ?? 0) * 0.004).round();
        lines.add((
          'Sum insured',
          '${_fmt((a['sumInsured'] as num).round())} MMK',
        ));
      case 'PA-01':
        final sum = ((a['sumInsured'] as num?) ?? 0);
        final term = int.tryParse(a['policyTerm'] as String? ?? '12') ?? 12;
        final termFactor = switch (term) {
          3 => 0.25,
          6 => 0.5,
          _ => 1.0,
        };
        premium = (sum * 0.007 * termFactor).round();
        lines.add(('Sum insured', '${_fmt(sum.round())} MMK'));
        lines.add(('Policy term', '$term Months'));
      case 'HI-01':
        final covers = (a['covers'] as Set<String>? ?? {});
        premium = (covers.length.clamp(1, 3) * 45000).round();
        lines.add((
          'Covers selected',
          covers.isEmpty ? 'None' : '${covers.length}',
        ));
        lines.add(('Payment type', '${a['paymentType']} Months'));
      case 'IM-01':
        final sum = ((a['sumInsured'] as num?) ?? 0);
        premium = (sum * 0.015).round();
        lines.add(('Sum insured', '${_fmt(sum.round())} MMK'));
        lines.add(('Payment type', '${a['paymentType']} Months'));
      case 'MH-01':
        final sum = ((a['sumInsured'] as num?) ?? 0);
        premium = (sum * 0.011).round();
        lines.add(('Sum insured', '${_fmt(sum.round())} MMK'));
      case 'CI-01':
        final unit = ((a['unit'] as num?) ?? 1).round();
        premium = (unit * 30000).round();
        lines.add(('Unit', '$unit'));
      case 'CLS-01':
        final sum = ((a['sumInsured'] as num?) ?? 0);
        final fixed = a['productType'] == 'fixed';
        final years = int.tryParse(a['policyTerm'] as String? ?? '1') ?? 1;
        premium = (sum * (fixed ? 0.02 : 0.015) * years).round();
        lines.add(('Sum insured', '${_fmt(sum.round())} MMK'));
        lines.add((
          'Product type',
          fixed ? 'Fixed Premium Rate' : 'Decreasing Premium Rate',
        ));
        lines.add(('Policy term', '$years Years'));
      case 'CLP-01':
        final sum = ((a['sumInsured'] as num?) ?? 0);
        final years = ((a['policyTermYears'] as num?) ?? 3);
        premium = (sum * 0.03 * (years / 3)).round();
        lines.add(('Sum insured', '${_fmt(sum.round())} MMK'));
        lines.add(('Policy term', '${years.round()} years'));
      case 'TV-01':
        final sum = ((a['sumInsured'] as num?) ?? 0);
        final days = ((a['travelDays'] as num?) ?? 1).round();
        premium = (sum * 0.0001 * days).round();
        lines.add(('Coverage amount', '${_fmt(sum.round())} MMK'));
        lines.add(('Travel days', '$days days'));
        lines.add((
          'Travel type',
          a['travelType'] == 'international' ? 'International' : 'Domestic',
        ));
      case 'STE-01':
        final sum = ((a['sumInsured'] as num?) ?? 0);
        final years = int.tryParse(a['policyTerm'] as String? ?? '5') ?? 5;
        premium = (sum / years * 1.05).round();
        lines.add(('Sum insured', '${_fmt(sum.round())} MMK'));
        lines.add(('Policy term', '$years Years'));
        lines.add(('Payment type', _paymentLabel(a['paymentType'] as String?)));
      case 'EL-01':
        final sum = ((a['sumInsured'] as num?) ?? 0);
        final years = int.tryParse(a['policyTerm'] as String? ?? '9') ?? 9;
        final double_ = a['productType'] == 'double';
        premium = (sum / years * (double_ ? 1.15 : 1.0)).round();
        lines.add(('Sum insured', '${_fmt(sum.round())} MMK'));
        lines.add((
          'Product type',
          double_ ? 'Double Benefits Plan' : 'Basic Plan',
        ));
        lines.add(('Policy term', '$years Years'));
        lines.add(('Payment type', _paymentLabel(a['paymentType'] as String?)));
      default:
        premium = 0;
    }

    const stamp = 100;
    return QuoteCalcResult(
      lines: lines,
      premium: premium,
      total: premium + stamp,
    );
  }

  String _paymentLabel(String? v) => switch (v) {
    'monthly' => 'Monthly',
    'quarterly' => 'Quarterly',
    'semi' => 'Semi Annually',
    'annual' => 'Annually',
    _ => '—',
  };

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
}

final quoteFormProvider =
    StateNotifierProvider.family<
      QuoteFormController,
      Map<String, dynamic>,
      Product
    >((ref, product) => QuoteFormController(product));

/// The e-App's own copy of the calculator state: same fields, but starting
/// empty and kept apart from whatever the FA last typed in the quote screen.
final eappQuoteFormProvider =
    StateNotifierProvider.family<
      QuoteFormController,
      Map<String, dynamic>,
      Product
    >((ref, product) => QuoteFormController(product, blank: true));

/// Doc `draft-quotes-ux-brainstorm` — parked calculator sessions, separate
/// from the product catalog. In-memory for this prototype (device-local
/// "will sync when online" in spirit; no persistence layer wired yet).
class SavedQuotesController extends StateNotifier<List<QuoteDraft>> {
  SavedQuotesController() : super(const []);

  void add(QuoteDraft draft) => state = [draft, ...state];
  void remove(String id) => state = state.where((d) => d.id != id).toList();
}

final savedQuotesProvider =
    StateNotifierProvider<SavedQuotesController, List<QuoteDraft>>(
      (ref) => SavedQuotesController(),
    );
