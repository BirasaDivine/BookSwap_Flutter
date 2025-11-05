import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Service for handling Firebase Authentication operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      if (userCredential.user != null) {
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          displayName: displayName,
          emailVerified: false,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        print('Email not verified. Please check your inbox.');
      }

      // Update email verification status in Firestore
      // Also ensure displayName is synced
      if (userCredential.user != null) {
        final updates = <String, dynamic>{
          'emailVerified': userCredential.user!.emailVerified,
        };

        // Sync displayName from Firebase Auth if it exists
        if (userCredential.user!.displayName != null &&
            userCredential.user!.displayName!.isNotEmpty) {
          updates['displayName'] = userCredential.user!.displayName!;
        }

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update(updates);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print('Send email verification error: $e');
      rethrow;
    }
  }

  /// Reload current user to get updated email verification status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      print('Reload user error: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Send password reset email error: $e');
      rethrow;
    }
  }

  /// Get user model from Firestore
  Future<UserModel?> getUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Get user model error: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      if (displayName != null) {
        await _auth.currentUser?.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await _auth.currentUser?.updatePhotoURL(photoUrl);
      }

      // Update Firestore document
      if (_auth.currentUser != null) {
        final updates = <String, dynamic>{};
        if (displayName != null) updates['displayName'] = displayName;
        if (photoUrl != null) updates['photoUrl'] = photoUrl;

        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update(updates);
      }
    } catch (e) {
      print('Update user profile error: $e');
      rethrow;
    }
  }
}
