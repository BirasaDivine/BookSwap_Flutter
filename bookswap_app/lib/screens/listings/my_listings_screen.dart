import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/swap_provider.dart';
import '../../models/book_model.dart';
import '../../models/swap_offer_model.dart';
import '../book/add_book_screen.dart';
import '../book/book_detail_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'My Listings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.yellow),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddBookScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.yellow,
          labelColor: AppColors.yellow,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'My Books'),
            Tab(text: 'Swap Offers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [MyBooksTab(), SwapOffersTab()],
      ),
    );
  }
}

class MyBooksTab extends StatelessWidget {
  const MyBooksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    if (bookProvider.myBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No books posted yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first book',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        bookProvider.loadMyBooks(authProvider.user!.uid);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookProvider.myBooks.length,
        itemBuilder: (context, index) {
          final book = bookProvider.myBooks[index];
          return MyBookCard(book: book);
        },
      ),
    );
  }
}

class MyBookCard extends StatelessWidget {
  final BookModel book;

  const MyBookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: book.photoUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(book.photoUrl!),
              )
            : const Icon(Icons.book, size: 40),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.author),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                book.isAvailable ? 'Available' : 'In Swap',
                style: TextStyle(
                  fontSize: 11,
                  color: book.isAvailable ? Colors.green : Colors.orange,
                ),
              ),
              backgroundColor: book.isAvailable
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('View')),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            if (value == 'view') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BookDetailScreen(book: book),
                ),
              );
            } else if (value == 'edit') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddBookScreen(bookToEdit: book),
                ),
              );
            } else if (value == 'delete') {
              _deleteBook(context);
            }
          },
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BookDetailScreen(book: book),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String photoUrl) {
    // Check if it's a base64 image
    if (photoUrl.startsWith('data:image')) {
      try {
        final base64String = photoUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: 50,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.book);
          },
        );
      } catch (e) {
        return const Icon(Icons.book);
      }
    } else {
      return Image.network(
        photoUrl,
        width: 50,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.book),
      );
    }
  }

  void _deleteBook(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      await bookProvider.deleteBook(book.id);
    }
  }
}

class SwapOffersTab extends StatelessWidget {
  const SwapOffersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final swapProvider = Provider.of<SwapProvider>(context);

    if (swapProvider.allOffers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No swap offers yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: swapProvider.allOffers.length,
      itemBuilder: (context, index) {
        final offer = swapProvider.allOffers[index];
        return SwapOfferCard(offer: offer);
      },
    );
  }
}

class SwapOfferCard extends StatelessWidget {
  final SwapOfferModel offer;

  const SwapOfferCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isReceived = offer.ownerId == authProvider.user?.uid;
    final isPending = offer.status == SwapStatus.pending;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isReceived ? 'Received Offer' : 'Sent Offer',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _getStatusChip(offer.status),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offered',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.offeredBookTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.swap_horiz, color: AppColors.yellow),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'For',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.requestedBookTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isReceived
                  ? 'From: ${offer.requesterName}'
                  : 'To: ${offer.ownerName}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            if (isReceived && isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptOffer(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _rejectOffer(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getStatusChip(SwapStatus status) {
    Color color;
    switch (status) {
      case SwapStatus.pending:
        color = Colors.orange;
        break;
      case SwapStatus.accepted:
        color = Colors.green;
        break;
      case SwapStatus.rejected:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _acceptOffer(BuildContext context) async {
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);
    await swapProvider.acceptSwapOffer(offer.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Swap offer accepted!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectOffer(BuildContext context) async {
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);
    await swapProvider.rejectSwapOffer(offer.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Swap offer rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}

