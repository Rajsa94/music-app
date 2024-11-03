import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  var questions = <Map<String, dynamic>>[].obs;
  var selectedOption = "".obs;

  // Define your environment values here, or import from an environment file
  final String adminSystemId = 'easylaworder';
  final String appliedSystemId = 'easylaworderPMS';
  final String dynamicApplicationKey = 'EasyLawOrder';

  @override
  void onInit() {
    super.onInit();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    var data = {
      "formId": "50147EasyLawOrder",
      "adminSystemId": adminSystemId,
      "id": '',
      "appliedSystemId": appliedSystemId,
      "templated": "",
      "formSetting": "",
      "userDetails": "",
      "status": "active",
      "accountType": "",
      "accountId": "",
      "industryType": dynamicApplicationKey,
      "industrySubType": "",
      "uxTemplateId": ""
    };

    try {
      final response = await http.post(
        Uri.parse(
            'https://api.fastswiff.com/msformservice/api/Form/getformsettingdetails'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print("Full response: ${response.body}");

        if (responseData['success'] == true &&
            responseData.containsKey('data')) {
          final dataString = responseData['data'];
          print("Type of dataString: ${dataString.runtimeType}");
          print("Raw dataString: $dataString");

          if (dataString is String) {
            try {
              // Decode the string into a List<dynamic>
              final List<dynamic> dataList = json.decode(dataString);
              print("Decoded dataList: $dataList");
              print("Type of dataList: ${dataList.runtimeType}");

              // Check if the first item in dataList is a List
              if (dataList.isNotEmpty && dataList[0] is List<dynamic>) {
                // Access the first inner list
                final innerList = dataList[0] as List<dynamic>;

                // Check if the inner list contains Map<String, dynamic> items
                if (innerList.isNotEmpty &&
                    innerList[0] is Map<String, dynamic>) {
                  questions.assignAll(innerList.cast<Map<String, dynamic>>());
                  print('Questions loaded successfully');
                  print(questions);
                } else {
                  print(
                      "Inner list does not contain Map<String, dynamic> items.");
                }
              } else {
                print("Decoded list does not contain List<dynamic> items.");
              }
            } catch (decodeError) {
              print("Error decoding data string: $decodeError");
            }
          } else {
            print("Unexpected format: 'data' is not a JSON string.");
          }
        } else {
          throw Exception('Failed to load questions: Invalid response format');
        }
      } else {
        print('Failed to load questions: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updateSelectedOption(String optionId) {
    selectedOption.value = optionId;
  }

  void sendMessage(String text) {
    messages.add({"text": text, "isUser": true});
  }
}
