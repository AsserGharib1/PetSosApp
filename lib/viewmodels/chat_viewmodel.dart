import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/models/data/services/chat_service.dart';
import '../models/message.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  Future<void> sendMessage(String senderId, String senderName,
      String receiverId, String receiverName, String content) async {
    if (content.trim().isEmpty) return;
    await _chatService.sendMessage(
        senderId, senderName, receiverId, receiverName, content);
  }

  Stream<List<Message>> getMessages(String userId, String otherUserId) {
    return _chatService.getMessages(userId, otherUserId);
  }

  Stream<QuerySnapshot> getUserChats(String userId) {
    return _chatService.getUserChats(userId);
  }
}
