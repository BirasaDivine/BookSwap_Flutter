import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message_model.dart';

/// Service for handling chat operations
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Create or get a chat room between two users
  Future<ChatRoomModel> createOrGetChatRoom({
    required String user1Id,
    required String user1Name,
    required String user2Id,
    required String user2Name,
  }) async {
    try {
      // Create a consistent chat room ID based on user IDs
      final participantIds = [user1Id, user2Id]..sort();
      final chatRoomId = participantIds.join('_');

      // Check if chat room already exists
      final doc = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .get();

      if (doc.exists) {
        return ChatRoomModel.fromDocument(doc);
      }

      // Create new chat room
      final chatRoom = ChatRoomModel(
        id: chatRoomId,
        participantIds: participantIds,
        participantNames: {user1Id: user1Name, user2Id: user2Name},
        unreadCounts: {user1Id: 0, user2Id: 0},
      );

      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .set(chatRoom.toMap());
      return chatRoom;
    } catch (e) {
      print('Create or get chat room error: $e');
      rethrow;
    }
  }

  /// Send a message in a chat room
  Future<ChatMessageModel> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String message,
  }) async {
    try {
      final messageId = _uuid.v4();
      final chatMessage = ChatMessageModel(
        id: messageId,
        chatRoomId: chatRoomId,
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Save message to Firestore
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .set(chatMessage.toMap());

      // Update chat room with last message info
      await _firestore.collection('chat_rooms').doc(chatRoomId).update({
        'lastMessage': message,
        'lastMessageTime': Timestamp.fromDate(chatMessage.timestamp),
        'lastSenderId': senderId,
        'unreadCounts.$receiverId': FieldValue.increment(1),
      });

      return chatMessage;
    } catch (e) {
      print('Send message error: $e');
      rethrow;
    }
  }

  /// Get messages in a chat room
  Stream<List<ChatMessageModel>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessageModel.fromDocument(doc))
              .toList(),
        );
  }

  /// Get all chat rooms for a user
  Stream<List<ChatRoomModel>> getChatRooms(String userId) {
    return _firestore
        .collection('chat_rooms')
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatRoomModel.fromDocument(doc))
                  .toList()
                ..sort((a, b) {
                  if (a.lastMessageTime == null && b.lastMessageTime == null) {
                    return 0;
                  }
                  if (a.lastMessageTime == null) return 1;
                  if (b.lastMessageTime == null) return -1;
                  return b.lastMessageTime!.compareTo(a.lastMessageTime!);
                }),
        );
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required String chatRoomId,
    required String userId,
  }) async {
    try {
      // Reset unread count for this user
      await _firestore.collection('chat_rooms').doc(chatRoomId).update({
        'unreadCounts.$userId': 0,
      });

      // Mark all unread messages as read
      final unreadMessages = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Mark messages as read error: $e');
      rethrow;
    }
  }

  /// Get total unread messages count for a user
  Future<int> getUnreadMessagesCount(String userId) async {
    try {
      final chatRooms = await _firestore
          .collection('chat_rooms')
          .where('participantIds', arrayContains: userId)
          .get();

      int totalUnread = 0;
      for (final doc in chatRooms.docs) {
        final chatRoom = ChatRoomModel.fromDocument(doc);
        totalUnread += chatRoom.unreadCounts[userId] ?? 0;
      }

      return totalUnread;
    } catch (e) {
      print('Get unread messages count error: $e');
      return 0;
    }
  }

  /// Delete a chat room
  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      // Delete all messages in the chat room
      final messages = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Delete the chat room
      await _firestore.collection('chat_rooms').doc(chatRoomId).delete();
    } catch (e) {
      print('Delete chat room error: $e');
      rethrow;
    }
  }
}
