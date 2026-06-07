import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class SnapChatScreen extends StatefulWidget {
  final String currentUser;
  const SnapChatScreen({super.key, required this.currentUser});

  @override
  State<SnapChatScreen> createState() => _SnapChatScreenState();
}

class _SnapChatScreenState extends State<SnapChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  final List<Map<String, dynamic>> _mockMessages = [
    {
      'id': 'msg_1',
      'text': 'Hejka! Witamy w wersji demonstracyjnej Naszego Snapa! 🥰',
      'sender': 'User 2',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'id': 'msg_2',
      'text':
          'Możesz wysłać stąd tekst oraz zrobić zdjęcie aparatem. W wersji demo działa offline! 📸',
      'sender': 'User 1',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
    },
  ];

  Future<void> _sendPhoto() async {
    final XFile? photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (photo == null) return;

    try {
      final bytes = await File(photo.path).readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return;

      final resized = img.copyResize(
        image,
        width: 600,
        height: (image.height * 600 ~/ image.width),
      );

      final compressed = img.encodeJpg(resized, quality: 80);
      String base64Image = base64Encode(compressed);

      setState(() {
        _mockMessages.insert(0, {
          'id': 'photo_${DateTime.now().millisecondsSinceEpoch}',
          'text': '[ZDJĘCIE]',
          'sender': widget.currentUser,
          'imageBytes': base64Image,
          'timestamp': DateTime.now(),
          'isOpened': false,
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Błąd wysyłania zdjęcia: $e')));
      }
    }
  }

  void _sendMessage() {
    if (_msgController.text.isEmpty) return;

    setState(() {
      _mockMessages.insert(0, {
        'id': 'text_${DateTime.now().millisecondsSinceEpoch}',
        'text': _msgController.text,
        'sender': widget.currentUser,
        'timestamp': DateTime.now(),
      });
    });

    _msgController.clear();
  }

  void _markAsOpened(String docId) {
    int index = _mockMessages.indexWhere((m) => m['id'] == docId);
    if (index != -1) {
      setState(() {
        _mockMessages[index]['isOpened'] = true;
      });
    }
  }

  Future<void> _deleteMessageAfterView(String docId) async {
    await Future.delayed(const Duration(seconds: 2));
    int index = _mockMessages.indexWhere((m) => m['id'] == docId);
    if (index != -1) {
      setState(() {
        _mockMessages[index].remove('imageBytes');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16151A),
      appBar: AppBar(
        title: const Text(
          'Nasz Snap [DEMO]',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFA709A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -20,
            child: Icon(
              Icons.favorite,
              size: 200,
              color: Colors.pink.withValues(alpha: 0.05),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -30,
            child: Icon(
              Icons.favorite,
              size: 150,
              color: Colors.pink.withValues(alpha: 0.05),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.only(bottom: 10),
                  itemCount: _mockMessages.length,
                  itemBuilder: (context, index) {
                    final data = _mockMessages[index];
                    final sender = data['sender'] as String? ?? 'Unknown';
                    final bool isMe = sender == widget.currentUser;
                    final bool isPhoto = data['text'] == '[ZDJĘCIE]';
                    final bool isOpened = isPhoto && data['isOpened'] == true;

                    final bubbleColor = isOpened
                        ? Colors.grey[700]
                        : (isMe
                              ? const Color(0xFFFA709A)
                              : const Color(0xFF2B2D39));
                    final textColor = isOpened ? Colors.white30 : Colors.white;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72,
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  bottom: 4,
                                ),
                                child: Text(
                                  sender,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 12,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: isPhoto
                                  ? (isMe
                                        ? Text(
                                            isOpened
                                                ? "📸 Zdjęcie (otworzone)"
                                                : "📸 Zdjęcie wysłane",
                                            style: TextStyle(color: textColor),
                                          )
                                        : InkWell(
                                            onTap: isOpened
                                                ? null
                                                : () {
                                                    _markAsOpened(data['id']);
                                                    _deleteMessageAfterView(
                                                      data['id'],
                                                    );
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) => Dialog(
                                                        child: Container(
                                                          constraints: BoxConstraints(
                                                            maxWidth:
                                                                MediaQuery.of(
                                                                  context,
                                                                ).size.width *
                                                                0.9,
                                                            maxHeight:
                                                                MediaQuery.of(
                                                                  context,
                                                                ).size.height *
                                                                0.8,
                                                          ),
                                                          child:
                                                              data.containsKey(
                                                                'imageBytes',
                                                              )
                                                              ? Image.memory(
                                                                  base64Decode(
                                                                    data['imageBytes'],
                                                                  ),
                                                                  fit: BoxFit
                                                                      .contain,
                                                                )
                                                              : const Center(
                                                                  child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                          16.0,
                                                                        ),
                                                                    child: Text(
                                                                      'To zdjęcie wygasło!',
                                                                    ),
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            child: Text(
                                              isOpened
                                                  ? "📸 Zdjęcie"
                                                  : "📸 Zdjęcie (kliknij)",
                                              style: TextStyle(
                                                color: textColor,
                                              ),
                                            ),
                                          ))
                                  : Text(
                                      data['text'] as String? ?? '',
                                      style: TextStyle(color: textColor),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFA709A),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: _sendPhoto,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222029),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFFFA709A),
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _msgController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Wpisz coś...',
                            hintStyle: TextStyle(color: Colors.white30),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFA709A),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_upward,
                          color: Colors.black,
                          size: 22,
                        ),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
