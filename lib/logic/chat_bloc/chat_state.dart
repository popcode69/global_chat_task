
import 'package:equatable/equatable.dart';
import 'package:shakuniya_task/data/model/message_model.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final bool isOffline;
  ChatLoaded({ this.isOffline = false,required this.messages});

  @override
  List<Object?> get props => [messages];
}
