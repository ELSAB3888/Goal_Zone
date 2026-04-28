import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketScreen extends StatelessWidget {
  final String stadiumName;
  final String date;
  final String time;
  final String location;
  final String totalPrice;
  final String duration;
  final String sport;
  final String qrData;

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
  });

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4C8C18);
    final darkBg = const Color(0xFF1E1E1E);
    final cardColor = const Color(0xFF2C2C2C);

    return Scaffold(
      backgroundColor: darkBg,
      body: SingleChildScrollView(
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
                        color: Colors.black.withOpacity(0.3),
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
                          color: greenColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sport,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Stadium Name
                      Text(
                        stadiumName,
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
                        date,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(Icons.access_time, 'Time:', time),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.location_on_outlined,
                        'Location:',
                        location,
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
                                  text: totalPrice,
                                  style: TextStyle(
                                    color: greenColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '/\$duration',
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
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.white,
                            child: QrImageView(
                              data: qrData,
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
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: greenColor, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Download Ticket',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
      ),
    );
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
