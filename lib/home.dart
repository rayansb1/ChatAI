import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_keys.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<String> _messages = ["Bot: Welcome!"];
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add("You: $message");
    });

    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey', // Use the imported apiKey
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": message}
          ],
          "max_tokens": 50,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final botMessage = jsonResponse['choices'][0]['message']['content'];
        setState(() {
          _messages.add("Bot: $botMessage");
        });
      } else if (response.statusCode == 429) {
        setState(() {
          _messages.add("Bot: Rate limit exceeded. Please wait and try again.");
        });
      } else {
        setState(() {
          _messages.add("Bot: Error ${response.statusCode}");
        });
      }
    } catch (e) {
      setState(() {
        _messages.add("Bot: An error occurred. Please try again.");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat Bot',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message.startsWith("You:");

                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Colors.grey : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isUserMessage ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter message",
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    final message = _controller.text;
                    _controller.clear();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15.0),
                    backgroundColor: Colors.grey,
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
