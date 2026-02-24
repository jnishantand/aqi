import '../model/tax_80g_model.dart';

class Tax80GService {
  static Tax80GResult calculate({
    required double income,
    required double donation,
    required double taxRate, // example: 0.30 for 30%
    required DeductionType type,
    required bool isOldRegime,
  }) {
    if (!isOldRegime) {
      return Tax80GResult(
        eligibleDonation: 0,
        deductionAmount: 0,
        taxSaved: 0,
        netCost: donation,
      );
    }

    double eligibleDonation = donation;

    // Apply 10% limit if required
    if (type == DeductionType.hundredWithLimit ||
        type == DeductionType.fiftyWithLimit) {
      double maxLimit = income * 0.10;
      eligibleDonation = donation > maxLimit ? maxLimit : donation;
    }

    double deductionPercent =
        (type == DeductionType.hundredNoLimit ||
            type == DeductionType.hundredWithLimit)
        ? 1.0
        : 0.5;

    double deductionAmount = eligibleDonation * deductionPercent;
    double taxSaved = deductionAmount * taxRate;
    double netCost = donation - taxSaved;

    return Tax80GResult(
      eligibleDonation: eligibleDonation,
      deductionAmount: deductionAmount,
      taxSaved: taxSaved,
      netCost: netCost,
    );
  }
}
