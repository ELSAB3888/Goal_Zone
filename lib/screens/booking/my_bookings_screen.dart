import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/models/booking_model.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  int _selectedTab = 0; // 0: Upcoming, 1: Completed, 2: Cancelled

  @override
  void initState() {
    super.initState();
    // Fetch bookings when screen loads
    Future.microtask(() {
      if (mounted) {
        Provider.of<BookingProvider>(context, listen: false).fetchMyBookings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4C8C18);
    final darkBg = const Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: darkBg,
      body: CustomScrollView(
        slivers: [
          // 1. Header Image and Back Button
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: darkBg,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                'https://images.unsplash.com/photo-1551958219-acbc608c6377?q=80&w=1000&auto=format&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.black),
              ),
            ),
          ),

          // 2. Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Booking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Custom Tab Bar / Segmented Control
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: greenColor, width: 1),
                    ),
                    child: Row(
                      children: [
                        _buildTabSegment('Upcoming', 0, greenColor),
                        _buildTabSegment('Completed', 1, greenColor),
                        _buildTabSegment('Cancelled', 2, greenColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. List of Bookings from API
                  Consumer<BookingProvider>(
                    builder: (context, bookingProvider, child) {
                      if (bookingProvider.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF4C8C18),
                            ),
                          ),
                        );
                      }

                      List<BookingModel> currentList;
                      if (_selectedTab == 0) {
                        currentList = bookingProvider.upcoming;
                      } else if (_selectedTab == 1) {
                        currentList = bookingProvider.completed;
                      } else {
                        currentList = bookingProvider.cancelled;
                      }

                      if (currentList.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.sports_soccer,
                                  color: greenColor.withOpacity(0.4),
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No bookings found',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: currentList.map((booking) {
                          if (_selectedTab == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildUpcomingCard(
                                greenColor,
                                booking,
                                bookingProvider,
                              ),
                            );
                          } else if (_selectedTab == 1) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildCompletedCard(greenColor, booking),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildCancelledCard(greenColor, booking),
                            );
                          }
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 80), // Padding for Bottom Nav Bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSegment(String title, int index, Color greenColor) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? greenColor : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(
    Color greenColor,
    BookingModel booking,
    BookingProvider provider,
  ) {
    final imageUrl = booking.stadium.imageUrl.isNotEmpty
        ? booking.stadium.imageUrl
        : 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800&q=80';
    final dateStr = DateFormat('dd-MM-yyyy').format(booking.date);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greenColor.withOpacity(0.5), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Top Row: Image & Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 120,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => Container(
                    width: 120,
                    height: 100,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.sports_soccer,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: greenColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            booking.stadium.sport,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Text(
                          '${booking.totalPrice.toInt()} EGP',
                          style: TextStyle(
                            color: greenColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking.stadium.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (booking.stadium.location.isNotEmpty)
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        booking.stadium.location,
                      ),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.calendar_today_outlined, dateStr),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      Icons.access_time,
                      'From ${booking.timeSlot}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bottom Row: Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  color: Colors.transparent,
                  borderColor: greenColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showQRDialog(context, booking, greenColor);
                  },
                  child: _buildActionButton(
                    icon: Icons.qr_code_2,
                    label: 'View QR',
                    color: const Color(0xFF3355FF),
                    borderColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF333333),
                    title: const Text(
                      'Cancel Booking',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Are you sure you want to cancel this booking?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('No', style: TextStyle(color: greenColor)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Yes',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  final success = await provider.cancelBooking(booking.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Booking cancelled successfully'
                              : 'Failed to cancel booking',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: success ? greenColor : Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(
                Icons.cancel_outlined,
                color: Colors.red,
                size: 16,
              ),
              label: const Text(
                'Cancel Booking',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 12),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(Color greenColor, BookingModel booking) {
    final imageUrl = booking.stadium.imageUrl.isNotEmpty
        ? booking.stadium.imageUrl
        : 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800&q=80';
    final dateStr = DateFormat('dd-MM-yyyy').format(booking.date);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greenColor.withOpacity(0.5), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 120,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => Container(
                width: 120,
                height: 100,
                color: Colors.grey[800],
                child: const Icon(Icons.sports_soccer, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: greenColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking.stadium.sport,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Text(
                      '${booking.totalPrice.toInt()} EGP',
                      style: TextStyle(
                        color: greenColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  booking.stadium.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (booking.stadium.location.isNotEmpty)
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    booking.stadium.location,
                  ),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.calendar_today_outlined, dateStr),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.access_time,
                        'From ${booking.timeSlot}',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: greenColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledCard(Color greenColor, BookingModel booking) {
    final imageUrl = booking.stadium.imageUrl.isNotEmpty
        ? booking.stadium.imageUrl
        : 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800&q=80';
    final dateStr = DateFormat('dd-MM-yyyy').format(booking.date);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greenColor.withOpacity(0.5), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 120,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => Container(
                width: 120,
                height: 100,
                color: Colors.grey[800],
                child: const Icon(Icons.sports_soccer, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: greenColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking.stadium.sport,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Text(
                      '${booking.totalPrice.toInt()} EGP',
                      style: TextStyle(
                        color: greenColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  booking.stadium.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (booking.stadium.location.isNotEmpty)
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    booking.stadium.location,
                  ),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.calendar_today_outlined, dateStr),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.access_time,
                        'From ${booking.timeSlot}',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.cancel_outlined,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Cancelled',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQRDialog(
    BuildContext context,
    BookingModel booking,
    Color greenColor,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Booking QR Code',
          textAlign: TextAlign.center,
          style: TextStyle(color: greenColor, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: booking.qrCodeData,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              booking.stadium.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('dd MMM yyyy').format(booking.date)} | ${booking.timeSlot}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Token: ${booking.qrCodeData}',
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: TextStyle(color: greenColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
