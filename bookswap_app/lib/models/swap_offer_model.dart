import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing the status of a swap offer
enum SwapStatus {
  pending('Pending'),
  accepted('Accepted'),
  rejected('Rejected'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;
  const SwapStatus(this.label);

  static SwapStatus fromString(String value) {
    switch (value) {
      case 'Pending':
        return SwapStatus.pending;
      case 'Accepted':
        return SwapStatus.accepted;
      case 'Rejected':
        return SwapStatus.rejected;
      case 'Completed':
        return SwapStatus.completed;
      case 'Cancelled':
        return SwapStatus.cancelled;
      default:
        return SwapStatus.pending;
    }
  }
}

/// Swap offer model representing a book swap request
class SwapOfferModel {
  final String id;
  final String requestedBookId;
  final String requestedBookTitle;
  final String offeredBookId;
  final String offeredBookTitle;
  final String requesterId;
  final String requesterName;
  final String ownerId;
  final String ownerName;
  final SwapStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? message;

  SwapOfferModel({
    required this.id,
    required this.requestedBookId,
    required this.requestedBookTitle,
    required this.offeredBookId,
    required this.offeredBookTitle,
    required this.requesterId,
    required this.requesterName,
    required this.ownerId,
    required this.ownerName,
    this.status = SwapStatus.pending,
    required this.createdAt,
    this.respondedAt,
    this.message,
  });

  /// Convert SwapOfferModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestedBookId': requestedBookId,
      'requestedBookTitle': requestedBookTitle,
      'offeredBookId': offeredBookId,
      'offeredBookTitle': offeredBookTitle,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'status': status.label,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null
          ? Timestamp.fromDate(respondedAt!)
          : null,
      'message': message,
    };
  }

  /// Create SwapOfferModel from Firestore document
  factory SwapOfferModel.fromMap(Map<String, dynamic> map) {
    return SwapOfferModel(
      id: map['id'] ?? '',
      requestedBookId: map['requestedBookId'] ?? '',
      requestedBookTitle: map['requestedBookTitle'] ?? '',
      offeredBookId: map['offeredBookId'] ?? '',
      offeredBookTitle: map['offeredBookTitle'] ?? '',
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      status: SwapStatus.fromString(map['status'] ?? 'Pending'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      respondedAt: map['respondedAt'] != null
          ? (map['respondedAt'] as Timestamp).toDate()
          : null,
      message: map['message'],
    );
  }

  /// Create SwapOfferModel from Firestore DocumentSnapshot
  factory SwapOfferModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SwapOfferModel.fromMap(data);
  }

  /// Create a copy of SwapOfferModel with updated fields
  SwapOfferModel copyWith({
    String? id,
    String? requestedBookId,
    String? requestedBookTitle,
    String? offeredBookId,
    String? offeredBookTitle,
    String? requesterId,
    String? requesterName,
    String? ownerId,
    String? ownerName,
    SwapStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? message,
  }) {
    return SwapOfferModel(
      id: id ?? this.id,
      requestedBookId: requestedBookId ?? this.requestedBookId,
      requestedBookTitle: requestedBookTitle ?? this.requestedBookTitle,
      offeredBookId: offeredBookId ?? this.offeredBookId,
      offeredBookTitle: offeredBookTitle ?? this.offeredBookTitle,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message ?? this.message,
    );
  }
}
