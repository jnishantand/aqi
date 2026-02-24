import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/models/aqiModel.dart';
import 'package:http/http.dart' as http;

const _token = '41451e6126963c17bdd3f2026ddfe8c94d6efb47';

final aqiProvider = FutureProvider.family<AqiModel, String>((ref, city) async {
  final url = 'https://api.waqi.info/feed/$city/?token=$_token';

  final response = await http.get(Uri.parse(url));

  final json = jsonDecode(response.body);

  if (json['status'] != 'ok') {
    throw Exception('City not found');
  }

  return AqiModel.fromJson(json);
});
