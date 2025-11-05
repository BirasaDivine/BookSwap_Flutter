import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Helper service for user-related operations
class UserHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get display name for a user, with fallbacks
  static Future<String> getDisplayName(
    String userId,
    String? fallbackName,
  ) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        final displayName = data?['displayName'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          return displayName;
        }
      }

      // Fallback to provided name or 'Unknown'
      return fallbackName != null &&
              fallbackName.isNotEmpty &&
              fallbackName != 'Unknown'
          ? fallbackName
          : 'Unknown';
    } catch (e) {
      print('Error fetching display name: $e');
      return fallbackName ?? 'Unknown';
    }
  }

  /// Get user model by ID
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }
}
