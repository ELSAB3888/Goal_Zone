import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/booking_model.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/utils/ticket_downloader.dart';

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
    const greenColor = AppColors.primary;
    const darkBg = AppColors.background;

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
                              color: AppColors.primary,
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
                                  color: greenColor.withValues(alpha: 0.4),
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
        border: Border.all(color: greenColor.withValues(alpha: 0.5), width: 1),
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
                            color: greenColor.withValues(alpha: 0.8),
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
        border: Border.all(color: greenColor.withValues(alpha: 0.5), width: 1),
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
                        color: greenColor.withValues(alpha: 0.8),
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
        border: Border.all(color: greenColor.withValues(alpha: 0.5), width: 1),
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
                        color: greenColor.withValues(alpha: 0.8),
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
      builder: (ctx) => _QRDialog(
        booking: booking,
        greenColor: greenColor,
      ),
    );
  }
}

// ─── QR Dialog with API fetch ─────────────────────────────────────────────────
class _QRDialog extends StatefulWidget {
  final BookingModel booking;
  final Color greenColor;

  const _QRDialog({required this.booking, required this.greenColor});

  @override
  State<_QRDialog> createState() => _QRDialogState();
}

class _QRDialogState extends State<_QRDialog> {
  String? _qrToken;
  bool _loading = true;
  bool _error = false;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _fetchQrToken();
  }

  Future<void> _fetchQrToken() async {
    try {
      final provider = Provider.of<BookingProvider>(context, listen: false);
      // 1. If we already have a real qrToken, use it directly
      if (widget.booking.qrCodeData.isNotEmpty &&
          widget.booking.qrCodeData != 'NO_QR') {
        if (mounted) {
          setState(() {
            _qrToken = widget.booking.qrCodeData;
            _loading = false;
          });
        }
        return;
      }
      // 2. Try fetching from /bookings/:id/ticket API
      //    If that returns 500, getBookingQrToken now falls back to the booking ID.
      final token = await provider.getBookingQrToken(widget.booking.id);
      if (mounted) {
        setState(() {
          _qrToken = token; // Will be the qrToken or the booking ID as fallback
          _loading = false;
          _error = token.isEmpty; // Only error if completely empty
        });
      }
    } catch (e) {
      // Last resort: use booking ID as the QR payload
      if (mounted) {
        final fallback = widget.booking.id;
        setState(() {
          _loading = false;
          if (fallback.isNotEmpty) {
            _qrToken = fallback;
            _error = false;
          } else {
            _error = true;
          }
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Booking QR Code',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: widget.greenColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_loading)
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: widget.greenColor),
                    const SizedBox(height: 16),
                    const Text(
                      'Loading QR Code...',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else if (_error || _qrToken == null)
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Could not load QR code.\nPlease try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _error = false;
                        });
                        _fetchQrToken();
                      },
                      child: Text('Retry',
                          style: TextStyle(color: widget.greenColor)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: _qrToken!,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.booking.stadium.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('dd MMM yyyy').format(widget.booking.date)} | ${widget.booking.timeSlot}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Token: $_qrToken',
                style:
                    const TextStyle(color: Colors.white54, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!_loading && !_error && _qrToken != null)
          TextButton.icon(
            onPressed: _downloading
                ? null
                : () async {
                    setState(() => _downloading = true);
                    final booking = widget.booking;
                    final dateStr = DateFormat('dd MMM yyyy')
                        .format(booking.date);
                    // Capture navigator & messenger before async gap
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final success =
                        await TicketDownloader.renderAndDownload(
                      qrData: _qrToken!,
                      stadiumName: booking.stadium.name,
                      date: dateStr,
                      time: booking.timeSlot,
                      location: booking.stadium.location,
                      totalPrice: '${booking.totalPrice.toInt()} EGP',
                      sport: booking.stadium.sport,
                      fileName:
                          'GoalZone_${booking.stadium.name.replaceAll(' ', '_')}',
                    );
                    if (mounted) {
                      setState(() => _downloading = false);
                      navigator.pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? '✅ Ticket saved to gallery!'
                                : '❌ Download failed. Please try again.',
                            style:
                                const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: success
                              ? const Color(0xFF2E7D32)
                              : Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },

            icon: _downloading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(Icons.download_rounded,
                    color: widget.greenColor, size: 20),
            label: Text(
              _downloading ? 'Saving...' : 'Download',
              style: TextStyle(
                color: widget.greenColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Close',
            style: TextStyle(
              color: widget.greenColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
