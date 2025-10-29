// lib/logic/chat_bloc/chat_bloc.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../data/model/message_model.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repo;
  StreamSubscription? _sub;
  StreamSubscription? _connectivitySub;

  bool _isOnline = true;

  ChatBloc(this._repo) : super(ChatInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<NewMessagesEvent>(_onNewMessages);
  }

  /// 🚀 Step 1: Load cached messages first, then stream Firestore updates
  Future<void> _onLoadMessages(
      LoadMessagesEvent event, Emitter<ChatState> emit) async {
    // Load from cache instantly for offline users
    final cached = await _repo.getCachedMessages();
    emit(ChatLoaded(messages: cached, isOffline: false));

    // 🔔 Subscribe user to global chat topic
    await _repo.subscribeToGlobalTopic();

    // Monitor connectivity changes
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((result) => _isOnline = result != ConnectivityResult.none);

    // Listen for realtime updates from Firestore
    _sub = _repo.getMessagesStream().listen(
          (messages) async {
        // Cache messages for offline access
        await _repo.cacheMessages(messages);

        // Update UI only if there’s an actual change
        if (state is ChatLoaded) {
          final current = (state as ChatLoaded).messages;
          if (!_areListsEqual(current, messages)) {
            add(NewMessagesEvent(messages));
          }
        } else {
          add(NewMessagesEvent(messages));
        }
      },
      onError: (error) {
        // Firestore offline fallback (keep showing cached)
        emit(ChatLoaded(messages: cached, isOffline: true));
      },
    );
  }

  /// ✉️ Send new message
  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      await _repo.sendMessage(event.message);
    } catch (e) {
      print("Send message failed: $e");

      // Cache unsent message locally if offline
      if (!_isOnline) {
        final current =
        state is ChatLoaded ? (state as ChatLoaded).messages : [];
        List<MessageModel> updated = [event.message, ...current];
        await _repo.cacheMessages(updated);
        emit(ChatLoaded(messages: updated, isOffline: true));
      }
    }
  }

  /// 🔁 Refresh state with new messages
  void _onNewMessages(
      NewMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoaded(messages: event.messages, isOffline: !_isOnline));
  }

  bool _areListsEqual(List<MessageModel> a, List<MessageModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _connectivitySub?.cancel();
    return super.close();
  }
}
