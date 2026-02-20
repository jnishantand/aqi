import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/models/aqi_news_model.dart';
import 'package:http/http.dart' as http;


final aqiNewsProvider = FutureProvider<List<AqiNews>>((ref) async {
  const apiKey = 'ed676e32b2c940c8cbda415e320f8b17';

  final url = Uri.parse(
    'https://gnews.io/api/v4/search'
        '?q=air quality pollution AQI'
        '&lang=en'
        '&max=10'
        '&apikey=$apiKey',
  );

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Failed to load AQI news');
  }

  final data = jsonDecode(response.body);
  final List articles = data['articles'];

  return articles.map((e) => AqiNews.fromJson(e)).toList();
});
