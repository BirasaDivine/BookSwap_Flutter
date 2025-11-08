import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/swap_offer_model.dart';
import 'book_service.dart';

/// Service for handling swap offer operations
class SwapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BookService _bookService = BookService();
  final _uuid = const Uuid();

  /// Create a new swap offer
  Future<SwapOfferModel> createSwapOffer({
    required String requestedBookId,
    required String offeredBookId,
    required String requesterId,
    required String requesterName,
    String? message,
  }) async {
    try {
      print('=== Creating swap offer ===');
      print('Requested book ID: $requestedBookId');
      print('Offered book ID: $offeredBookId');
      print('Requester ID: $requesterId');

      // Get book details
      final requestedBook = await _bookService.getBookById(requestedBookId);
      final offeredBook = await _bookService.getBookById(offeredBookId);

      if (requestedBook == null || offeredBook == null) {
        print('ERROR: Book not found!');
        print('Requested book: $requestedBook');
        print('Offered book: $offeredBook');
        throw Exception('Book not found');
      }

      print('Requested book: ${requestedBook.title}');
      print('Offered book: ${offeredBook.title}');

      final swapId = _uuid.v4();
      print('Generated swap ID: $swapId');

      final swapOffer = SwapOfferModel(
        id: swapId,
        requestedBookId: requestedBookId,
        requestedBookTitle: requestedBook.title,
        offeredBookId: offeredBookId,
        offeredBookTitle: offeredBook.title,
        requesterId: requesterId,
        requesterName: requesterName,
        ownerId: requestedBook.ownerId,
        ownerName: requestedBook.ownerName,
        status: SwapStatus.pending,
        createdAt: DateTime.now(),
        message: message,
      );

      print('Swap offer model created, saving to Firestore...');
      print('Swap offer data: ${swapOffer.toMap()}');

      // Save swap offer to Firestore
      await _firestore
          .collection('swap_offers')
          .doc(swapId)
          .set(swapOffer.toMap());

      print('✅ Swap offer saved successfully!');

      // Mark both books as unavailable
      print('Marking books as unavailable...');
      await _bookService.markBookAsUnavailable(requestedBookId);
      await _bookService.markBookAsUnavailable(offeredBookId);
      print('✅ Books marked as unavailable');

      return swapOffer;
    } catch (e, stackTrace) {
      print('❌ Create swap offer error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get swap offers where user is the requester
  Stream<List<SwapOfferModel>> getSwapOffersByRequester(String userId) {
    return _firestore
        .collection('swap_offers')
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SwapOfferModel.fromDocument(doc))
              .toList(),
        );
  }

  /// Get swap offers where user is the owner
  Stream<List<SwapOfferModel>> getSwapOffersByOwner(String userId) {
    return _firestore
        .collection('swap_offers')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SwapOfferModel.fromDocument(doc))
              .toList(),
        );
  }

  /// Get all swap offers for a user (both as requester and owner)
  Stream<List<SwapOfferModel>> getAllSwapOffersForUser(String userId) {
    // We can't use a single query with OR, so we need to merge two streams
    // However, for simplicity, we'll just get the ones where user is owner
    // and combine with the requester stream in the provider
    return _firestore
        .collection('swap_offers')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SwapOfferModel.fromDocument(doc))
              .toList(),
        );
  }

  /// Accept a swap offer
  Future<void> acceptSwapOffer(String swapOfferId) async {
    try {
      // Get the swap offer
      final doc = await _firestore
          .collection('swap_offers')
          .doc(swapOfferId)
          .get();
      if (!doc.exists) {
        throw Exception('Swap offer not found');
      }

      final swapOffer = SwapOfferModel.fromDocument(doc);

      // Get both books
      final requestedBook = await _bookService.getBookById(swapOffer.requestedBookId);
      final offeredBook = await _bookService.getBookById(swapOffer.offeredBookId);

      if (requestedBook == null || offeredBook == null) {
        throw Exception('One or both books not found');
      }

      // Use a batch to update everything atomically
      final batch = _firestore.batch();

      // Update swap offer status
      batch.update(
        _firestore.collection('swap_offers').doc(swapOfferId),
        {
          'status': SwapStatus.accepted.label,
          'respondedAt': Timestamp.fromDate(DateTime.now()),
        },
      );

      // Swap book ownership
      // requestedBook goes to requester, offeredBook goes to owner
      batch.update(
        _firestore.collection('books').doc(swapOffer.requestedBookId),
        {
          'ownerId': swapOffer.requesterId,
          'ownerName': swapOffer.requesterName,
          'isAvailable': true, // Make available again
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );

      batch.update(
        _firestore.collection('books').doc(swapOffer.offeredBookId),
        {
          'ownerId': swapOffer.ownerId,
          'ownerName': swapOffer.ownerName,
          'isAvailable': true, // Make available again
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );

      // Commit all changes
      await batch.commit();
      
      print('✅ Swap accepted and books ownership transferred!');
    } catch (e) {
      print('Accept swap offer error: $e');
      rethrow;
    }
  }

  /// Reject a swap offer
  Future<void> rejectSwapOffer(String swapOfferId) async {
    try {
      // Get the swap offer
      final doc = await _firestore
          .collection('swap_offers')
          .doc(swapOfferId)
          .get();
      if (!doc.exists) {
        throw Exception('Swap offer not found');
      }

      final swapOffer = SwapOfferModel.fromDocument(doc);

      // Update swap offer status
      await _firestore.collection('swap_offers').doc(swapOfferId).update({
        'status': SwapStatus.rejected.label,
        'respondedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Mark books as available again
      await _bookService.markBookAsAvailable(swapOffer.requestedBookId);
      await _bookService.markBookAsAvailable(swapOffer.offeredBookId);
    } catch (e) {
      print('Reject swap offer error: $e');
      rethrow;
    }
  }

  /// Cancel a swap offer (by requester)
  Future<void> cancelSwapOffer(String swapOfferId) async {
    try {
      // Get the swap offer
      final doc = await _firestore
          .collection('swap_offers')
          .doc(swapOfferId)
          .get();
      if (!doc.exists) {
        throw Exception('Swap offer not found');
      }

      final swapOffer = SwapOfferModel.fromDocument(doc);

      // Update swap offer status
      await _firestore.collection('swap_offers').doc(swapOfferId).update({
        'status': SwapStatus.cancelled.label,
        'respondedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Mark books as available again
      await _bookService.markBookAsAvailable(swapOffer.requestedBookId);
      await _bookService.markBookAsAvailable(swapOffer.offeredBookId);
    } catch (e) {
      print('Cancel swap offer error: $e');
      rethrow;
    }
  }

  /// Complete a swap offer
  Future<void> completeSwapOffer(String swapOfferId) async {
    try {
      await _firestore.collection('swap_offers').doc(swapOfferId).update({
        'status': SwapStatus.completed.label,
      });
    } catch (e) {
      print('Complete swap offer error: $e');
      rethrow;
    }
  }

  /// Get pending swap offers count for a user
  Future<int> getPendingSwapOffersCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('swap_offers')
          .where('ownerId', isEqualTo: userId)
          .where('status', isEqualTo: SwapStatus.pending.label)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Get pending swap offers count error: $e');
      return 0;
    }
  }
}
