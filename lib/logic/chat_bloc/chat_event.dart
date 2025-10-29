import 'package:shakuniya_task/data/model/message_model.dart';
import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMessagesEvent extends ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final MessageModel message;
  SendMessageEvent(this.message);
  @override
  List<Object?> get props => [message];
}

class NewMessagesEvent extends ChatEvent {
  final List<MessageModel> messages;
  NewMessagesEvent(this.messages);
  @override
  List<Object?> get props => [messages];
}
