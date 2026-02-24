import 'package:flutter_riverpod/legacy.dart';
import '../model/tax_80g_model.dart';
import '../service/tax_80g_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final tax80GProvider = StateNotifierProvider<Tax80GController, Tax80GResult?>(
  (ref) => Tax80GController(),
);

class Tax80GController extends StateNotifier<Tax80GResult?> {
  Tax80GController() : super(null);

  void calculate({
    required double income,
    required double donation,
    required double taxRate,
    required DeductionType type,
    required bool isOldRegime,
  }) {
    final result = Tax80GService.calculate(
      income: income,
      donation: donation,
      taxRate: taxRate,
      type: type,
      isOldRegime: isOldRegime,
    );

    state = result;
  }

  void clear() {
    state = null;
  }
}

Future<void> saveResult(String userId, Tax80GResult result) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('tax80g_history')
      .add(result.toMap());
}
