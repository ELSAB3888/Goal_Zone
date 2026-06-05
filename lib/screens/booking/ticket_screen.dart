import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/utils/ticket_downloader.dart';

class TicketScreen extends StatefulWidget {
  final String stadiumName;
  final String date;
  final String time;
  final String location;
  final String totalPrice;
  final String duration;
  final String sport;
  final String qrData;
  /// Optional: the booking ID to fetch qrToken from API if qrData is unavailable
  final String? bookingId;

  const TicketScreen({
    super.key,
    required this.stadiumName,
    required this.date,
    required this.time,
    required this.location,
    required this.totalPrice,
    required this.duration,
    required this.sport,
    required this.qrData,
    this.bookingId,
  });

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late String _resolvedQrData;
  bool _loadingQr = false;
  bool _downloading = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _resolvedQrData = widget.qrData;
    // If qrData is not usable, try fetching from API
    if ((_resolvedQrData.isEmpty || _resolvedQrData == 'NO_QR') &&
        widget.bookingId != null) {
      _fetchQrFromApi();
    }
  }

  Future<void> _fetchQrFromApi() async {
    setState(() => _loadingQr = true);
    try {
      final provider = Provider.of<BookingProvider>(context, listen: false);
      final token = await provider.getBookingQrToken(widget.bookingId!);
      if (mounted) {
        setState(() {
          _resolvedQrData = token;
          _loadingQr = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingQr = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = AppColors.primary;
    const darkBg = AppColors.background;
    const cardColor = Color(0xFF2C2C2C);

    return Scaffold(
      backgroundColor: darkBg,
      body: Screenshot(
        controller: _screenshotController,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Header Image & Ticket Card

            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Top Image
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1518605368461-1e1e1140728c?q=80&w=800&auto=format&fit=crop',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Back Button
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: greenColor,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
                // Ticket Card
                Container(
                  margin: const EdgeInsets.only(top: 150, left: 24, right: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Sport Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: greenColor.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.sport,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Stadium Name
                      Text(
                        widget.stadiumName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24, thickness: 1),
                      const SizedBox(height: 20),

                      // Details Rows
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        'Date:',
                        widget.date,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(Icons.access_time, 'Time:', widget.time),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.location_on_outlined,
                        'Location:',
                        widget.location,
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24, thickness: 1),
                      const SizedBox(height: 20),

                      // Price Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Paid',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 16),
                              children: [
                                TextSpan(
                                  text: widget.totalPrice,
                                  style: TextStyle(
                                    color: greenColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '/${widget.duration}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // QR Code with brackets
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Custom brackets using containers
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Stack(
                              children: [
                                // Top Left
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: _buildBracketCorner(
                                    greenColor,
                                    isTop: true,
                                    isLeft: true,
                                  ),
                                ),
                                // Top Right
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: _buildBracketCorner(
                                    greenColor,
                                    isTop: true,
                                    isLeft: false,
                                  ),
                                ),
                                // Bottom Left
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: _buildBracketCorner(
                                    greenColor,
                                    isTop: false,
                                    isLeft: true,
                                  ),
                                ),
                                // Bottom Right
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: _buildBracketCorner(
                                    greenColor,
                                    isTop: false,
                                    isLeft: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // QR Code
                          _loadingQr
                              ? Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.white,
                                  width: 166,
                                  height: 166,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.white,
                                  child: QrImageView(
                                    data: _resolvedQrData.isNotEmpty
                                        ? _resolvedQrData
                                        : 'NO_QR',
                                    version: QrVersions.auto,
                                    size: 150.0,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // 2. Bottom Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _downloading
                          ? null
                          : () async {
                              setState(() => _downloading = true);
                              // Capture messenger before async gap
                              final messenger =
                                  ScaffoldMessenger.of(context);
                              final success =
                                  await TicketDownloader.renderAndDownload(
                                qrData: _resolvedQrData,
                                stadiumName: widget.stadiumName,
                                date: widget.date,
                                time: widget.time,
                                location: widget.location,
                                totalPrice: widget.totalPrice,
                                sport: widget.sport,
                                fileName:
                                    'GoalZone_${widget.stadiumName.replaceAll(' ', '_')}',
                              );
                              if (mounted) {
                                setState(() => _downloading = false);
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? '✅ Ticket saved to gallery!'
                                          : '❌ Download failed. Please try again.',
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                    backgroundColor: success
                                        ? const Color(0xFF2E7D32)
                                        : Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: _downloading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.download_rounded,
                              color: Colors.white,
                            ),
                      label: Text(
                        _downloading ? 'Saving...' : 'Download Ticket',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.primary, width: 1),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Pop all the way back to the home screen (root of the navigator)
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),    // SingleChildScrollView
    ),      // Screenshot
    );      // Scaffold
  }



  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildBracketCorner(
    Color color, {
    required bool isTop,
    required bool isLeft,
  }) {
    // A simple widget to draw the L-shaped brackets around the QR code
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }
}
