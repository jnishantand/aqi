import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/features/tax80g/controller/tax_80g_controller.dart';
import 'package:getaqi/features/tax80g/model/tax_80g_model.dart';

class Tax80GScreen extends ConsumerWidget {
  final incomeController = TextEditingController();
  final donationController = TextEditingController();

  Tax80GScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(tax80GProvider);

    return Scaffold(
      appBar: AppBar(title: Text("80G Tax Calculator")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: incomeController,
              decoration: InputDecoration(labelText: "Annual Income"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: donationController,
              decoration: InputDecoration(labelText: "Donation Amount"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(tax80GProvider.notifier)
                    .calculate(
                      income: double.parse(incomeController.text),
                      donation: double.parse(donationController.text),
                      taxRate: 0.30,
                      type: DeductionType.hundredNoLimit,
                      isOldRegime: true,
                    );
              },
              child: Text("Calculate"),
            ),
            SizedBox(height: 20),
            if (result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Tax Saved: ₹${result.taxSaved}"),
                      Text("Net Cost: ₹${result.netCost}"),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
