import 'package:flutter/foundation.dart';
import 'dart:io';
import '../services/book_service.dart';
import '../models/book_model.dart';

/// Provider for managing book listings state
class BookProvider with ChangeNotifier {
  final BookService _bookService = BookService();

  List<BookModel> _allBooks = [];
  List<BookModel> _myBooks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<BookModel> get allBooks => _searchQuery.isEmpty
      ? _allBooks
      : _allBooks.where((book) {
          final query = _searchQuery.toLowerCase();
          return book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query);
        }).toList();

  List<BookModel> get myBooks => _myBooks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Load all available books
  void loadAllBooks() {
    _bookService.getAllBooks().listen((books) {
      _allBooks = books;
      notifyListeners();
    });
  }

  /// Load user's own books
  void loadMyBooks(String userId) {
    _bookService.getBooksByOwner(userId).listen((books) {
      _myBooks = books;
      notifyListeners();
    });
  }

  /// Create a new book listing
  Future<bool> createBook({
    required String title,
    required String author,
    required BookCondition condition,
    required String ownerId,
    required String ownerName,
    String? swapFor,
    File? imageFile,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _bookService.createBook(
        title: title,
        author: author,
        condition: condition,
        ownerId: ownerId,
        ownerName: ownerName,
        swapFor: swapFor,
        imageFile: imageFile,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create book listing.';
      notifyListeners();
      return false;
    }
  }

  /// Update a book listing
  Future<bool> updateBook({
    required String bookId,
    String? title,
    String? author,
    BookCondition? condition,
    String? swapFor,
    File? imageFile,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _bookService.updateBook(
        bookId: bookId,
        title: title,
        author: author,
        condition: condition,
        swapFor: swapFor,
        imageFile: imageFile,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update book listing.';
      notifyListeners();
      return false;
    }
  }

  /// Delete a book listing
  Future<bool> deleteBook(String bookId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _bookService.deleteBook(bookId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete book listing.';
      notifyListeners();
      return false;
    }
  }

  /// Get a single book by ID
  Future<BookModel?> getBookById(String bookId) async {
    try {
      return await _bookService.getBookById(bookId);
    } catch (e) {
      _errorMessage = 'Failed to load book details.';
      notifyListeners();
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
