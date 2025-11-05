import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:convert';
import '../models/book_model.dart';

/// Service for handling book-related Firestore operations
class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Create a new book listing
  Future<BookModel> createBook({
    required String title,
    required String author,
    required BookCondition condition,
    required String ownerId,
    required String ownerName,
    String? swapFor,
    File? imageFile,
  }) async {
    try {
      final bookId = _uuid.v4();
      String? imageUrl;

      // Convert image to base64 if provided
      if (imageFile != null) {
        try {
          final bytes = await imageFile.readAsBytes();
          imageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        } catch (e) {
          print('Image encoding failed, continuing without image: $e');
          imageUrl = null;
        }
      }

      final book = BookModel(
        id: bookId,
        title: title,
        author: author,
        condition: condition,
        imageUrl: imageUrl,
        ownerId: ownerId,
        ownerName: ownerName,
        createdAt: DateTime.now(),
        isAvailable: true,
        swapFor: swapFor,
      );

      await _firestore.collection('books').doc(bookId).set(book.toMap());
      return book;
    } catch (e) {
      print('Create book error: $e');
      rethrow;
    }
  }

  /// Get all available book listings
  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => BookModel.fromDocument(doc)).toList(),
        );
  }

  /// Get books by owner
  Stream<List<BookModel>> getBooksByOwner(String ownerId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => BookModel.fromDocument(doc)).toList(),
        );
  }

  /// Get a single book by ID
  Future<BookModel?> getBookById(String bookId) async {
    try {
      final doc = await _firestore.collection('books').doc(bookId).get();
      if (doc.exists) {
        return BookModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Get book error: $e');
      rethrow;
    }
  }

  /// Update a book listing
  Future<void> updateBook({
    required String bookId,
    String? title,
    String? author,
    BookCondition? condition,
    String? swapFor,
    bool? isAvailable,
    File? imageFile,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (title != null) updates['title'] = title;
      if (author != null) updates['author'] = author;
      if (condition != null) updates['condition'] = condition.label;
      if (swapFor != null) updates['swapFor'] = swapFor;
      if (isAvailable != null) updates['isAvailable'] = isAvailable;

      // Convert new image to base64 if provided
      if (imageFile != null) {
        try {
          final bytes = await imageFile.readAsBytes();
          updates['imageUrl'] = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        } catch (e) {
          print('Image encoding failed: $e');
        }
      }

      await _firestore.collection('books').doc(bookId).update(updates);
    } catch (e) {
      print('Update book error: $e');
      rethrow;
    }
  }

  /// Delete a book listing
  Future<void> deleteBook(String bookId) async {
    try {
      // Delete book document (no need to delete Storage images)
      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      print('Delete book error: $e');
      rethrow;
    }
  }

  /// Search books by title or author
  Stream<List<BookModel>> searchBooks(String query) {
    return _firestore
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final books = snapshot.docs
              .map((doc) => BookModel.fromDocument(doc))
              .toList();

          // Filter books by query (case-insensitive search)
          if (query.isEmpty) return books;

          final lowerQuery = query.toLowerCase();
          return books.where((book) {
            return book.title.toLowerCase().contains(lowerQuery) ||
                book.author.toLowerCase().contains(lowerQuery);
          }).toList();
        });
  }

  /// Mark book as unavailable (when swap is initiated)
  Future<void> markBookAsUnavailable(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).update({
        'isAvailable': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Mark book unavailable error: $e');
      rethrow;
    }
  }

  /// Mark book as available (when swap is cancelled or rejected)
  Future<void> markBookAsAvailable(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).update({
        'isAvailable': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Mark book available error: $e');
      rethrow;
    }
  }
}
