// lib/presentation/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shakuniya_task/data/model/message_model.dart';
import '../../../logic/chat_bloc/chat_bloc.dart';
import '../../../logic/chat_bloc/chat_state.dart';
import '../../../logic/chat_bloc/chat_event.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();

  void _sendMessage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _controller.text.trim().isEmpty) return;

    final message = MessageModel(
      id: '',
      senderId: user.uid,
      senderName: user.displayName ?? 'Anonymous',
      senderAvatar: user.photoURL ?? '',
      text: _controller.text.trim(),
      createdAt: DateTime.now(),
    );

    context.read<ChatBloc>().add(SendMessageEvent(message));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Global Chat", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoaded) {
                  final msgs = state.messages;
                  if (msgs.isEmpty) {
                    return const Center(child: Text("No messages yet"));
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: msgs.length,
                    itemBuilder: (_, i) {
                      final msg = msgs[i];
                      final isMe = msg.senderId == currentUser?.uid;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar (only show for others' messages)
                            if (!isMe)
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: msg.senderAvatar.isNotEmpty
                                    ? NetworkImage(msg.senderAvatar)
                                    : const AssetImage(
                                    'assets/images/default_avatar.png')
                                as ImageProvider,
                              ),

                            const SizedBox(width: 8),

                            // Message bubble
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.deepPurple.shade100
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12),
                                    topRight: const Radius.circular(12),
                                    bottomLeft: isMe
                                        ? const Radius.circular(12)
                                        : const Radius.circular(0),
                                    bottomRight: isMe
                                        ? const Radius.circular(0)
                                        : const Radius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg.senderName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(msg.text),
                                    const SizedBox(height: 3),
                                    Text(
                                      DateFormat('hh:mm a')
                                          .format(msg.createdAt),
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Avatar for own messages (right side)
                            if (isMe) ...[
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: currentUser?.photoURL != null &&
                                    currentUser!.photoURL!.isNotEmpty
                                    ? NetworkImage(currentUser.photoURL!)
                                    : const AssetImage(
                                    'assets/images/default_avatar.png')
                                as ImageProvider,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
