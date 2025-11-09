import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';
import '../models/chat_message_model.dart';

/// Provider for managing chat state
class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatRoomModel> _chatRooms = [];
  final Map<String, List<ChatMessageModel>> _messages = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatRoomModel> get chatRooms => _chatRooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get messages for a specific chat room
  List<ChatMessageModel> getMessages(String chatRoomId) {
    return _messages[chatRoomId] ?? [];
  }

  /// Load chat rooms for a user
  void loadChatRooms(String userId) {
    _chatService.getChatRooms(userId).listen((rooms) {
      _chatRooms = rooms;
      notifyListeners();
    });
  }

  /// Load messages for a chat room
  void loadMessages(String chatRoomId) {
    _chatService.getMessages(chatRoomId).listen((messages) {
      _messages[chatRoomId] = messages;
      notifyListeners();
    });
  }

  /// Create or get a chat room
  Future<ChatRoomModel?> createOrGetChatRoom({
    required String user1Id,
    required String user1Name,
    required String user2Id,
    required String user2Name,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final chatRoom = await _chatService.createOrGetChatRoom(
        user1Id: user1Id,
        user1Name: user1Name,
        user2Id: user2Id,
        user2Name: user2Name,
      );

      _isLoading = false;
      notifyListeners();
      return chatRoom;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create chat room.';
      notifyListeners();
      return null;
    }
  }

  /// Send a message
  Future<bool> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String message,
  }) async {
    try {
      await _chatService.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        message: message,
      );

      return true;
    } catch (e) {
      _errorMessage = 'Failed to send message.';
      notifyListeners();
      return false;
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required String chatRoomId,
    required String userId,
  }) async {
    try {
      await _chatService.markMessagesAsRead(
        chatRoomId: chatRoomId,
        userId: userId,
      );
    } catch (e) {
      print('Mark messages as read error: $e');
    }
  }

  /// Get total unread messages count
  Future<int> getUnreadMessagesCount(String userId) async {
    try {
      return await _chatService.getUnreadMessagesCount(userId);
    } catch (e) {
      return 0;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _messages.clear();
    super.dispose();
  }
}
