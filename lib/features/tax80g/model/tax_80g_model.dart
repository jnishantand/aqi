enum DeductionType {
  hundredNoLimit,
  fiftyNoLimit,
  hundredWithLimit,
  fiftyWithLimit,
}

class Tax80GResult {
  final double eligibleDonation;
  final double deductionAmount;
  final double taxSaved;
  final double netCost;

  Tax80GResult({
    required this.eligibleDonation,
    required this.deductionAmount,
    required this.taxSaved,
    required this.netCost,
  });

  Map<String, dynamic> toMap() {
    return {
      "eligibleDonation": eligibleDonation,
      "deductionAmount": deductionAmount,
      "taxSaved": taxSaved,
      "netCost": netCost,
      "createdAt": DateTime.now(),
    };
  }
}
