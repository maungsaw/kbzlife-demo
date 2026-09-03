import '../models/commission.dart';
import '../models/customer.dart';
import '../models/policy.dart';
import '../models/product.dart';

/// Mock data for CRM (leads/clients), Policies, and Commission — kept
/// separate from mock_data.dart the same way mock_products.dart is,
/// since each of these domains has its own sizeable seed list.
class MockCrmData {
  MockCrmData._();

  static final List<Customer> customers = [
    Customer(
      id: 'C-1',
      name: 'U Aung Ko',
      phone: '09-4212xxxxx',
      email: 'aungko@example.com',
      stage: CustomerStage.qualified,
      source: 'Referral',
      lastContactedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Customer(
      id: 'C-2',
      name: 'Daw Hla Hla',
      phone: '09-7913xxxxx',
      email: 'hlahla@example.com',
      stage: CustomerStage.converted,
      isClient: true,
      source: 'Walk-in',
      lastContactedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Customer(
      id: 'C-3',
      name: 'Ko Zin Min',
      phone: '09-5123xxxxx',
      email: 'zinmin@example.com',
      stage: CustomerStage.proposal,
      source: 'Event',
      lastContactedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Customer(
      id: 'C-4',
      name: 'Daw Nilar',
      phone: '09-4456xxxxx',
      email: 'nilar@example.com',
      stage: CustomerStage.converted,
      isClient: true,
      source: 'Referral',
      lastContactedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Customer(
      id: 'C-5',
      name: 'Ko Thura',
      phone: '09-9988xxxxx',
      email: 'thura@example.com',
      stage: CustomerStage.newLead,
      source: 'Social media',
    ),
    Customer(
      id: 'C-6',
      name: 'Daw Su Su',
      phone: '09-2211xxxxx',
      email: 'susu@example.com',
      stage: CustomerStage.dropped,
      source: 'Cold call',
      dropReason: 'Not interested at this time',
      lastContactedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  static final List<Policy> policies = [
    Policy(
      policyNo: 'PA-88213',
      productName: 'Personal Accident Plus',
      productCode: 'PA-01',
      holderName: 'U Aung Ko',
      status: PolicyStatus.pendingRenewal,
      premium: 180000,
      sumInsured: 30000000,
      renewalDate: DateTime.now().add(const Duration(days: 18)),
    ),
    Policy(
      policyNo: 'UL-55211',
      productName: 'Universal Life Saver',
      productCode: 'UL-01',
      holderName: 'Daw Hla Hla',
      status: PolicyStatus.active,
      premium: 960000,
      sumInsured: 100000000,
      renewalDate: DateTime.now().add(const Duration(days: 210)),
    ),
    Policy(
      policyNo: 'HI-30044',
      productName: 'Family Health Shield',
      productCode: 'HI-01',
      holderName: 'Daw Nilar',
      status: PolicyStatus.active,
      premium: 540000,
      sumInsured: 50000000,
      renewalDate: DateTime.now().add(const Duration(days: 95)),
      riders: ['Dental cover'],
    ),
    Policy(
      policyNo: 'GL-11290',
      productName: 'Group Life Basic',
      productCode: 'GL-01',
      holderName: 'Ko Zin Min',
      status: PolicyStatus.lapsed,
      premium: 240000,
      sumInsured: 20000000,
      renewalDate: DateTime.now().subtract(const Duration(days: 40)),
    ),
  ];

  static final List<Commission> commissions = [
    Commission(id: 'CM-1', period: 'Aug 2026', productName: 'Personal Accident Plus', policyNo: 'PA-88213', amount: 27000, status: CommissionStatus.paid, paidAt: DateTime(2026, 8, 5, 10, 11), category: ProductCategory.protection, clientName: 'U Aung Ko'),
    Commission(id: 'CM-2', period: 'Aug 2026', productName: 'Universal Life Saver', policyNo: 'UL-55211', amount: 144000, status: CommissionStatus.approved, paidAt: DateTime(2026, 8, 20, 14, 30), category: ProductCategory.saving, clientName: 'Daw Hla Hla'),
    Commission(id: 'CM-3', period: 'Jul 2026', productName: 'Family Health Shield', policyNo: 'HI-30044', amount: 81000, status: CommissionStatus.paid, paidAt: DateTime(2026, 7, 12, 9, 5), category: ProductCategory.health, clientName: 'Daw Nilar'),
    Commission(id: 'CM-4', period: 'Jul 2026', productName: 'Group Life Basic', policyNo: 'GL-11290', amount: 36000, status: CommissionStatus.pending, paidAt: DateTime(2026, 7, 28, 16, 45), category: ProductCategory.protection, clientName: 'Ko Zin Min'),
    Commission(id: 'CM-5', period: 'Jun 2026', productName: 'Personal Accident Plus', policyNo: 'PA-88213', amount: 27000, status: CommissionStatus.paid, paidAt: DateTime(2026, 6, 6, 11, 0), category: ProductCategory.protection, clientName: 'U Aung Ko'),
  ];
}
