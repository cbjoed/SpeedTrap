import 'dart:convert';

import 'package:http/http.dart' as http;

class RoadSpeedService {
  const RoadSpeedService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<int?> lookupSpeedLimit(
      {required double latitude, required double longitude}) async {
    final query =
        '''[out:json][timeout:8];way(around:50,$latitude,$longitude)[highway][maxspeed];out tags;''';
    final response = await (_client ?? http.Client()).post(
      Uri.parse('https://overpass-api.de/api/interpreter'),
      headers: const {'content-type': 'application/x-www-form-urlencoded'},
      body: {'data': query},
    );

    if (response.statusCode != 200) {
      return null;
    }

    final elements = (jsonDecode(response.body)
        as Map<String, dynamic>)['elements'] as List<dynamic>?;
    for (final element in elements ?? const []) {
      final tags =
          (element as Map<String, dynamic>)['tags'] as Map<String, dynamic>?;
      final parsed = _parseSpeed(tags?['maxspeed']?.toString());
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  static int? _parseSpeed(String? value) {
    if (value == null) return null;
    final match = RegExp(r'\d+(?:[.,]\d+)?').firstMatch(value);
    if (match == null) return null;
    final speed = double.tryParse(match.group(0)!.replaceAll(',', '.'));
    if (speed == null || speed <= 0 || speed > 200) return null;
    return speed.round();
  }
}
