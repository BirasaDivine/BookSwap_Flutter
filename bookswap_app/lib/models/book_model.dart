import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing the condition of a book
enum BookCondition {
  newBook('New'),
  likeNew('Like New'),
  good('Good'),
  used('Used');

  final String label;
  const BookCondition(this.label);

  static BookCondition fromString(String value) {
    switch (value) {
      case 'New':
        return BookCondition.newBook;
      case 'Like New':
        return BookCondition.likeNew;
      case 'Good':
        return BookCondition.good;
      case 'Used':
        return BookCondition.used;
      default:
        return BookCondition.used;
    }
  }
}

/// Book model representing a textbook listing
class BookModel {
  final String id;
  final String title;
  final String author;
  final BookCondition condition;
  final String? imageUrl;
  final String ownerId;
  final String ownerName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isAvailable;
  final String? swapFor;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
    this.updatedAt,
    this.isAvailable = true,
    this.swapFor,
  });

  /// Convert BookModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'condition': condition.label,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isAvailable': isAvailable,
      'swapFor': swapFor,
    };
  }

  /// Create BookModel from Firestore document
  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      condition: BookCondition.fromString(map['condition'] ?? 'Used'),
      imageUrl: map['imageUrl'],
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      isAvailable: map['isAvailable'] ?? true,
      swapFor: map['swapFor'],
    );
  }

  /// Create BookModel from Firestore DocumentSnapshot
  factory BookModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel.fromMap(data);
  }

  /// Create a copy of BookModel with updated fields
  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    BookCondition? condition,
    String? imageUrl,
    String? ownerId,
    String? ownerName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAvailable,
    String? swapFor,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAvailable: isAvailable ?? this.isAvailable,
      swapFor: swapFor ?? this.swapFor,
    );
  }
}
