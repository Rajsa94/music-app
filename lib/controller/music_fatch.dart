import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/music_model.dart';

class MusicService extends GetxService {
  Future<List<Music>> fetchMusic() async {
    const url = 'https://api.fastswiff.com/msformservice/api/Form/getformdata';
    final headers = {
      'Authorization': 'Basic b3BsdWVuY2VVc2Vy',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "id": 0,
      "dynamicFormSettingId": "50142opulenceEstate",
      "formId": "",
      "transactionId": "",
      "accountType": "",
      "accountId": "",
      "dynamicData": "",
      "userDetails": "",
      "status": ""
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      print('BodyOne: ${response.body}');

      // Decode the main response body
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true && responseData.containsKey('data')) {
        // Decode the "data" field separately
        print('BodyTwo:');
        final List<dynamic> dataList = json.decode(responseData['data']);
        print('Body3: ${dataList}');

        // Map the nested data to a list of Music objects
        return dataList.map((item) => Music.fromJson(item['data'][0])).toList();
      } else {
        throw Exception('Failed to load music: Invalid response format');
      }
    } else {
      throw Exception('Failed to load music');
    }
  }
}
