// lib/data/repositories/chat_repository.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shakuniya_task/data/model/message_model.dart';
import '../sources/local_storage_service.dart';

class ChatRepository {
  final _firestore = FirebaseFirestore.instance;
  final _localStorage = LocalStorageService();

  /// ✅ 1. Stream messages in realtime from Firestore + cache offline
  Stream<List<MessageModel>> getMessagesStream() {
    return _firestore
        .collection('global_messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      final messages = snap.docs
          .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
          .toList();

      // 💾 Save messages for offline use
      cacheMessages(messages);
      return messages;
    });
  }

  /// ✅ 2. Send message to Firestore + push notification to all users (topic)
  Future<void> sendMessage(MessageModel message) async {
    // 1️⃣ Save message in Firestore
    await _firestore.collection('global_messages').add(message.toMap());

    // 2️⃣ Push notification via topic (everyone gets it)
    await _sendNotificationToAll(message);
  }

  /// ✅ 3. Cache locally using SharedPreferences
  Future<void> cacheMessages(List<MessageModel> messages) async {
    await _localStorage.saveMessages(messages);
  }

  /// ✅ 4. Load cached messages for offline access
  Future<List<MessageModel>> getCachedMessages() async {
    return await _localStorage.loadMessages();
  }

  /// ✅ 5. Send notification to the global topic “global_chat”
  Future<void> _sendNotificationToAll(MessageModel message) async {
    try {
      const serverKey = 'YOUR_SERVER_KEY_FROM_FIREBASE'; // 🔥 Replace this!
      final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

      final body = jsonEncode({
        "to": "/topics/global_chat", // 🎯 All users subscribed to this topic
        "notification": {
          "title": message.senderName,
          "body": message.text,
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "senderId": message.senderId,
        }
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        print("❌ Failed to send FCM: ${response.body}");
      } else {
        print("✅ Notification sent successfully");
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  /// ✅ 6. Subscribe current user to global topic
  Future<void> subscribeToGlobalTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('global_chat');
    print("✅ Subscribed to global_chat topic");
  }
}
