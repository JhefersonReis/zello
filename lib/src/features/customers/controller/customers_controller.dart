import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello/src/features/customers/domain/customer_model.dart';
import 'package:zello/src/features/customers/domain/customers_service.dart';
import 'package:zello/src/app/providers/providers.dart';

final customersControllerProvider = StateNotifierProvider<CustomersController, AsyncValue<List<CustomerModel>>>(
  (ref) => CustomersController(service: ref.read(customersServiceProvider)),
);

final customerByIdProvider = FutureProvider.family<CustomerModel, int>(
  (ref, id) => ref.read(customersServiceProvider).findById(id),
);

final customersFilterProvider = StateProvider<String>((ref) => '');

final filteredCustomersProvider = Provider.autoDispose<List<CustomerModel>>((ref) {
  final customersState = ref.watch(customersControllerProvider);
  final filter = ref.watch(customersFilterProvider);

  return customersState.when(
    data: (customers) {
      if (filter.isEmpty) {
        return customers;
      }

      return customers.where((customer) {
        final searchTerm = filter.toLowerCase();
        final customerName = customer.name.toLowerCase();
        final customerAddress = customer.address?.toLowerCase() ?? '';
        final customerPhone = customer.phone?.toLowerCase() ?? '';

        return customerName.contains(searchTerm) ||
            customerAddress.contains(searchTerm) ||
            customerPhone.contains(searchTerm);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

class CustomersController extends StateNotifier<AsyncValue<List<CustomerModel>>> {
  final CustomersService _service;

  CustomersController({required CustomersService service}) : _service = service, super(const AsyncLoading()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    try {
      final customers = await _service.findAll();
      state = AsyncData(customers);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addCustomer({
    required String name,
    required String address,
    required String phone,
    required String countryISOCode,
    String? observation,
  }) async {
    final newCustomer = await _service.create(
      name: name,
      address: address,
      phone: phone,
      countryISOCode: countryISOCode,
      observation: observation,
    );

    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, newCustomer]);
  }

  Future<void> updateCustomer({
    required int id,
    required String name,
    required String address,
    required String phone,
    required String countryISOCode,
    required DateTime createdAt,
    String? observation,
  }) async {
    final updatedCustomer = await _service.update(
      id: id,
      name: name,
      address: address,
      phone: phone,
      countryISOCode: countryISOCode,
      observation: observation,
      createdAt: createdAt,
    );

    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final customer in current)
        if (customer.id == id) updatedCustomer else customer,
    ]);
  }

  Future<void> deleteCustomer(int id) async {
    await _service.delete(id);

    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((c) => c.id != id).toList());
  }
}
