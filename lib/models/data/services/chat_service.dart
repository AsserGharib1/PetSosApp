import 'package:cloud_firestore/cloud_firestore.dart';
import '../../message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a chat room ID from two user IDs to ensure uniqueness
  String _getChatRoomId(String user1, String user2) {
    List<String> ids = [user1, user2];
    ids.sort();
    return ids.join('_');
  }

  // Send a message
  Future<void> sendMessage(
    String senderId,
    String senderName,
    String receiverId,
    String receiverName,
    String content,
  ) async {
    final String chatRoomId = _getChatRoomId(senderId, receiverId);
    final Message message = Message(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Add to specific chat room subcollection
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(message.toMap());

    // Update last message info for the chat list
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'users': [senderId, receiverId],
      'userNames': {senderId: senderName, receiverId: receiverName},
      'lastMessage': content,
      'lastTimestamp': DateTime.now(),
    }, SetOptions(merge: true));
  }

  // Get messages stream
  Stream<List<Message>> getMessages(String userId, String otherUserId) {
    String chatRoomId = _getChatRoomId(userId, otherUserId);
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
    });
  }

  // Get all chats for a user (simplified)
  Stream<QuerySnapshot> getUserChats(String userId) {
    return _firestore
        .collection('chat_rooms')
        .where('users', arrayContains: userId)
        .snapshots();
  }
}
