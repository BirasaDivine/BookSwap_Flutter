import 'package:flutter/foundation.dart';
import '../services/swap_service.dart';
import '../models/swap_offer_model.dart';

/// Provider for managing swap offers state
class SwapProvider with ChangeNotifier {
  final SwapService _swapService = SwapService();

  List<SwapOfferModel> _sentOffers = [];
  List<SwapOfferModel> _receivedOffers = [];
  List<SwapOfferModel> _allOffers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SwapOfferModel> get sentOffers => _sentOffers;
  List<SwapOfferModel> get receivedOffers => _receivedOffers;
  List<SwapOfferModel> get allOffers => _allOffers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get pendingReceivedCount => _receivedOffers
      .where((offer) => offer.status == SwapStatus.pending)
      .length;

  /// Load swap offers for a user
  void loadSwapOffers(String userId) {
    // Load sent offers
    _swapService.getSwapOffersByRequester(userId).listen((offers) {
      _sentOffers = offers;
      _updateAllOffers();
      notifyListeners();
    });

    // Load received offers
    _swapService.getSwapOffersByOwner(userId).listen((offers) {
      _receivedOffers = offers;
      _updateAllOffers();
      notifyListeners();
    });
  }

  /// Combine sent and received offers into allOffers
  void _updateAllOffers() {
    // Combine both lists and remove duplicates by id
    final combined = <String, SwapOfferModel>{};

    for (var offer in _sentOffers) {
      combined[offer.id] = offer;
    }

    for (var offer in _receivedOffers) {
      combined[offer.id] = offer;
    }

    // Convert to list and sort by creation date (newest first)
    _allOffers = combined.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Create a new swap offer
  Future<bool> createSwapOffer({
    required String requestedBookId,
    required String offeredBookId,
    required String requesterId,
    required String requesterName,
    String? message,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _swapService.createSwapOffer(
        requestedBookId: requestedBookId,
        offeredBookId: offeredBookId,
        requesterId: requesterId,
        requesterName: requesterName,
        message: message,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      // Show detailed error message
      if (e.toString().contains('permission-denied')) {
        _errorMessage =
            'Permission denied. Please check Firebase security rules.';
      } else if (e.toString().contains('not found')) {
        _errorMessage = 'Book not found. Please try again.';
      } else {
        _errorMessage = 'Failed to create swap offer: ${e.toString()}';
      }
      print('Swap offer error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Accept a swap offer
  Future<bool> acceptSwapOffer(String swapOfferId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _swapService.acceptSwapOffer(swapOfferId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to accept swap offer.';
      notifyListeners();
      return false;
    }
  }

  /// Reject a swap offer
  Future<bool> rejectSwapOffer(String swapOfferId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _swapService.rejectSwapOffer(swapOfferId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to reject swap offer.';
      notifyListeners();
      return false;
    }
  }

  /// Cancel a swap offer
  Future<bool> cancelSwapOffer(String swapOfferId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _swapService.cancelSwapOffer(swapOfferId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to cancel swap offer.';
      notifyListeners();
      return false;
    }
  }

  /// Complete a swap offer
  Future<bool> completeSwapOffer(String swapOfferId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _swapService.completeSwapOffer(swapOfferId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to complete swap offer.';
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
