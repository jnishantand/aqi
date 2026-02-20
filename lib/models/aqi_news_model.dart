class AqiNews {
  final String title;
  final String description;
  final String url;
  final String image;
  final String source;

  AqiNews({
    required this.title,
    required this.description,
    required this.url,
    required this.image,
    required this.source,
  });

  factory AqiNews.fromJson(Map<String, dynamic> json) {
    return AqiNews(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      image: json['image'] ?? '',
      source: json['source']['name'] ?? '',
    );
  }
}
