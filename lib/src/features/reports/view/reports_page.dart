import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zello/l10n/app_localizations.dart';
import 'package:zello/src/app/helpers/currency_helper.dart';
import 'package:zello/src/features/reports/controller/reports_controller.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(reportsControllerProvider.notifier).getReportData(_startDate, _endDate);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      selectableDayPredicate: (DateTime val) {
        if (isStartDate) {
          return val.isBefore(_endDate.add(const Duration(days: 1)));
        } else {
          return val.isAfter(_startDate.subtract(const Duration(days: 1)));
        }
      },
    );
    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      await ref.read(reportsControllerProvider.notifier).getReportData(_startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsControllerProvider);
    final size = MediaQuery.of(context).size;
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization.reportsTitle,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF248f3d),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card seleção de período
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.grey),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localization.period, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(localization.startDate, style: TextStyle(fontSize: 16)),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: size.width * 0.4,
                              child: TextField(
                                controller: TextEditingController(text: DateFormat('dd/MM/yyyy').format(_startDate)),
                                readOnly: true,
                                onTap: () => _selectDate(context, true),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(10),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(localization.endDate, style: TextStyle(fontSize: 16)),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: size.width * 0.4,
                              child: TextField(
                                controller: TextEditingController(text: DateFormat('dd/MM/yyyy').format(_endDate)),
                                readOnly: true,
                                onTap: () => _selectDate(context, false),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(10),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(reportsControllerProvider.notifier).getReportData(_startDate, _endDate),
                child: reportsState.when(
                  data: (data) {
                    if (data == null) {
                      return Center(child: Text(localization.selectAPeriodToGenerateTheReport));
                    }
                    return ListView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Card(
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                width: size.width * 0.42,
                                child: Column(
                                  children: [
                                    const Icon(Icons.attach_money, size: 32, color: Colors.green),
                                    Text(
                                      CurrencyHelper.formatCurrency(context, data.totalRevenue),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(localization.totalRevenue, style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                width: size.width * 0.42,
                                child: Column(
                                  children: [
                                    const Icon(Icons.shopping_cart, size: 32, color: Colors.blue),
                                    Text(
                                      data.totalSales.toString(),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(localization.salesQuantity, style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.paymentStatus,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                                      margin: const EdgeInsets.only(right: 8),
                                    ),
                                    Text(localization.paidSales, style: TextStyle(fontSize: 16)),
                                    const Spacer(),
                                    Text(data.paidSales.toString(), style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
                                      margin: const EdgeInsets.only(right: 8),
                                    ),
                                    Text(localization.pendingSales, style: TextStyle(fontSize: 16)),
                                    const Spacer(),
                                    Text(data.pendingSales.toString(), style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    Text(localization.averageTicket, style: TextStyle(fontSize: 16)),
                                    const Spacer(),
                                    Text(
                                      CurrencyHelper.formatCurrency(context, data.averageTicket),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          localization.bestSellingProducts,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (data.topProducts.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(localization.noProductsSoldInThisPeriod, style: TextStyle(fontSize: 16)),
                          ),
                        ...data.topProducts.map(
                          (p) => Card(
                            child: ListTile(
                              title: Text(p.product.name),
                              subtitle: Text(
                                '${localization.sold}: ${p.quantitySold}x - ${localization.revenue}: ${CurrencyHelper.formatCurrency(context, p.totalRevenue)}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(localization.bestCustomers, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (data.topCustomers.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(localization.noCustomersFoundInThisPeriod, style: TextStyle(fontSize: 16)),
                          ),
                        ...data.topCustomers.map(
                          (c) => Card(
                            child: ListTile(
                              title: Text(c.customer.name),
                              subtitle: Text(
                                '${localization.purchases}: ${c.totalPurchases} - ${localization.totalSpend}: ${CurrencyHelper.formatCurrency(context, c.totalSpent)}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(child: Text('Erro: $error')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
