import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = [];
  bool isTyping = false;
  late GenerativeModel model;
  late ChatSession chat;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _loadChatHistory();
  }

  void _initializeChat() {
    const apiKey =
        'AIzaSyAjRlIFSN4LJ_xMuJdsCYOxYx99QZ46OZg'; // Replace with your API key
    model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
    chat = model.startChat();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('chat_history') ?? [];
    setState(() {
      messages.clear();
      messages.addAll(history);
    });
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('chat_history', messages);
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text;
    _controller.clear();

    setState(() {
      messages.insert(0, "User: $userMessage");
      isTyping = true;
    });

    try {
      final response = await chat.sendMessage(Content.text(userMessage));
      final botMessage = response.text ?? 'Sorry, I could not process that.';

      setState(() {
        messages.insert(0, "Bot: $botMessage");
        isTyping = false;
      });

      _saveChatHistory();
    } catch (e) {
      setState(() {
        messages.insert(
            0, "Bot: Sorry, I encountered an error. Please try again.");
        isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 250, 245),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 139, 62),
        title: Row(
          children: [
            Icon(Icons.smart_toy_outlined, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'CropMate Assistant',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 16,
                vertical: 8,
              ),
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isTyping && index == 0) {
                    return _buildTypingIndicator();
                  }

                  final message = messages[isTyping ? index - 1 : index];
                  final isUser = message.startsWith("User: ");

                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) _buildBotAvatar(),
                        SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width *
                                  (isSmallScreen ? 0.75 : 0.6),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Color.fromARGB(255, 0, 139, 62)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20).copyWith(
                                bottomLeft: isUser
                                    ? Radius.circular(20)
                                    : Radius.circular(0),
                                bottomRight: isUser
                                    ? Radius.circular(0)
                                    : Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              message.replaceFirst(
                                  isUser ? "User: " : "Bot: ", ""),
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        if (isUser) _buildUserAvatar(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.all(isSmallScreen ? 8 : 16).copyWith(
              bottom: MediaQuery.of(context).padding.bottom +
                  (isSmallScreen ? 8 : 16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Ask me anything about farming...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.mic, color: Colors.grey),
                          onPressed: () {
                            // TODO: Implement voice input
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 0, 139, 62),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 0, 139, 62).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _buildBotAvatar(),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: Radius.circular(0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 0, 139, 62),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Typing...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return CircleAvatar(
      backgroundColor: Color.fromARGB(255, 0, 139, 62),
      child: Icon(
        Icons.smart_toy,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      backgroundColor: Color.fromARGB(255, 0, 139, 62),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
