import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/chatbot_service.dart';

/// Chatbot gizi NURI (Groq Llama pretrained + fallback offline).
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _service = ChatbotService();
  final _controller = TextEditingController();
  final _messages = <ChatMessage>[
    const ChatMessage(
      role: 'assistant',
      content: 'Halo! Saya NURI. Tanya soal MPASI, stunting, atau menu sehat.',
    ),
  ];
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _sending = true;
    });
    _controller.clear();
    final reply = await _service.ask(text, history: _messages);
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(role: 'assistant', content: reply));
      _sending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tanya NURI',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(_service.hasKey ? 'AI online' : 'Offline'),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isUser = m.role == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF00BFA5)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      m.content,
                      style: GoogleFonts.poppins(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Tanya gizi, MPASI, stunting...',
                        filled: true,
                        fillColor: const Color(0xFFF0F2F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(onPressed: _send, icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
