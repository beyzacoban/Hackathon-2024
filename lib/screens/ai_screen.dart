import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  String? apiKey;
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, String>> _conversation = [];
  late final GenerativeModel _model;
  ChatSession? _chat;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    apiKey = dotenv.env['API_KEY']; 
    if (apiKey == null || apiKey!.isEmpty) {
      _showError('API key is missing. Please check your .env file.');
    } else {
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey!,
      );
      _initializeChatSession();
    }
  }

  Future<void> _initializeChatSession() async {
    try {
      _chat = _model.startChat();
      setState(() {}); 
    } catch (e) {
      _showError('Chat session initialization failed: $e');
    }
  }

  Future<void> _sendChatMessage(String message) async {
    if (_chat == null) {
      _showError('Chat session is not initialized.');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      print('User question: $message');

      var response = await _chat!.sendMessage(
        Content.text(message),
      );
      var text = response.text ?? 'No response received.';

      setState(() {
        _conversation.add({'user': message, 'ai': text});
        _loading = false;
      });
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _questionController.clear();
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('An error occurred'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[100],
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: apiKey != null
                  ? ListView.builder(
                      itemCount: _conversation.length,
                      itemBuilder: (context, index) {
                        var message = _conversation[index];
                        return MessageWidget(
                          text: message['user'] ?? '',
                          isFromUser: true,
                        );
                      },
                    )
                  : const Center(child: Text('Loading...')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(15),
                        hintText: 'Ask me anything...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_questionController.text.isNotEmpty) {
                        _sendChatMessage(_questionController.text);
                      }
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String text;
  final bool isFromUser;

  const MessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: isFromUser
                  ? Colors.green[200] 
                  : Colors.grey.withOpacity(0.2), 
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: MarkdownBody(
              selectable: true,
              data: text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 16.0, // Increase the text size
                  color: isFromUser
                      ? Colors.black // User message text color
                      : Colors.black87, // AI message text color
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
