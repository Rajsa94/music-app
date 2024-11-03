import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart'; // Import the controller

class ChatBotUI extends StatelessWidget {
  const ChatBotUI({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());
    print(chatController.questions.value);
    print('Questions Two loaded successfully');

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Bot"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  return ListTile(
                    title: Align(
                      alignment: message['isUser']
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: message['isUser']
                              ? Colors.blue
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['text'] ?? '', // Avoid null values
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Ensures content does not expand indefinitely
              children: [
                Obx(() {
                  // Check if the selected option is valid; if not, set it to null
                  if (!chatController.questions.any((question) =>
                      question['optionId'] ==
                      chatController.selectedOption.value)) {
                    chatController.updateSelectedOption('');
                  }

                  // Main question dropdown based on questions array
                  return DropdownButton<String>(
                    value: chatController.selectedOption.value.isNotEmpty
                        ? chatController.selectedOption.value
                        : null,
                    hint: Text("Select your issue"),
                    items: chatController.questions.map((question) {
                      return DropdownMenuItem<String>(
                        value: question['optionId']
                            ?.toString(), // Ensure it's a String
                        child: Text(question['label']?.toString() ??
                            'Unknown'), // Avoid null
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      chatController.updateSelectedOption(newValue ?? '');
                    },
                  );
                }),
                SizedBox(height: 10),
                // Sub-question section based on selected option
                Obx(() {
                  final selectedQuestion = chatController.questions.firstWhere(
                      (q) =>
                          q['optionId'] == chatController.selectedOption.value,
                      orElse: () => {});

                  if (selectedQuestion.isEmpty) return Container();

                  return Column(
                    children: (selectedQuestion['options'] as List<dynamic>)
                        .map<Widget>((subOption) {
                      return ListTile(
                        title: Text(subOption['value']?.toString() ??
                            'Unknown'), // Avoid null
                        onTap: () {
                          chatController.sendMessage(subOption['value']);
                        },
                      );
                    }).toList(),
                  );
                }),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            chatController.sendMessage(value);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Type your message",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        // Handle sending the message here if needed
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
