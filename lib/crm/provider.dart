import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/mock/mock_crm_data.dart';
import '../../data/models/customer.dart';
import 'model.dart';

final _crmRepository = CRMRepository();

final crmContactsProvider = FutureProvider<List<CRMContactModel>>((ref) async {
  return _crmRepository.fetchContacts();
});

class CrmController extends StateNotifier<List<Customer>> {
  CrmController() : super(List.of(MockCrmData.customers));

  List<Customer> get leads => state
      .where((c) => !c.isClient && c.stage != CustomerStage.dropped)
      .toList();
  List<Customer> get clients => state.where((c) => c.isClient).toList();
  List<Customer> get dropped =>
      state.where((c) => c.stage == CustomerStage.dropped).toList();

  Customer? byId(String id) => state.where((c) => c.id == id).firstOrNull;

  Customer? byName(String name) => state.where((c) => c.name.toLowerCase() == name.toLowerCase()).firstOrNull;

  void convertToClient(String id) {
    state = [
      for (final c in state)
        if (c.id == id)
          c.copyWith(isClient: true, stage: CustomerStage.converted)
        else
          c,
    ];
  }

  void dropLead(String id, String reason) {
    state = [
      for (final c in state)
        if (c.id == id)
          c.copyWith(stage: CustomerStage.dropped, dropReason: reason)
        else
          c,
    ];
  }

  void updateLead(Customer updated) {
    state = [
      for (final c in state)
        if (c.id == updated.id) updated else c,
    ];
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

final crmControllerProvider =
    StateNotifierProvider<CrmController, List<Customer>>(
      (ref) => CrmController(),
    );
