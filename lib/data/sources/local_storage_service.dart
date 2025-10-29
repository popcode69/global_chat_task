// lib/data/sources/local_storage_service.dart
import 'package:shakuniya_task/data/model/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _key = 'messages_cache';

  Future<void> saveMessages(List<MessageModel> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = messages.map((m) => m.toJson()).toList();
    await prefs.setStringList(_key, encoded);
  }

  Future<List<MessageModel>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key);
    if (data == null) return [];
    return data.map((json) => MessageModel.fromJson(json)).toList();
  }
}
