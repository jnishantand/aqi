class AqiModel {
  final int aqi;
  final String city;

  AqiModel({
    required this.aqi,
    required this.city,
  });

  factory AqiModel.fromJson(Map<String, dynamic> json) {
    return AqiModel(
      aqi: json['data']['aqi'] ?? 0,
      city: json['data']['city']['name'] ?? 'Unknown',
    );
  }
}
