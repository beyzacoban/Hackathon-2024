import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  String? apiKey;
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _conversation = [];
  late final GenerativeModel _model;
  ChatSession? _chat;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      _showError('API key is missing.');
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
        _scrollDown();
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

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
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
          title: const Text(
            'ASİSTANIM',
            style: TextStyle(
              fontFamily: 'Lorjuk',
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          backgroundColor: Colors.blueGrey[300],
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
                      controller: _scrollController,
                      itemCount: _conversation.length,
                      itemBuilder: (context, index) {
                        var message = _conversation[index];
                        return Column(
                          crossAxisAlignment: message['user'] != null
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (message['user'] != null)
                              MessageWidget(
                                text: message['user'] ?? '',
                                isFromUser: true,
                              ),
                            if (message['ai'] != null)
                              MessageWidget(
                                text: message['ai'] ?? '',
                                isFromUser: false,
                              ),
                          ],
                        );
                      },
                    )
                  : const Center(child: CircularProgressIndicator()),
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
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFF678FB4)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      onSubmitted: (String value) {
                        if (value.isNotEmpty) {
                          _sendChatMessage(value);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_questionController.text.isNotEmpty) {
                        _sendChatMessage(_questionController.text);
                      }
                    },
                    icon: const Icon(Icons.send),
                    color: Colors.blueGrey[300],
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
              color: isFromUser ? Colors.blueGrey[200] : Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
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
                  fontSize: 16.0,
                  color: isFromUser ? Colors.black : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
