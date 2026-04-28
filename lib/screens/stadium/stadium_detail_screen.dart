import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/stadium_model.dart';
import '../../core/providers/booking_provider.dart';
import '../booking/my_bookings_screen.dart';

class StadiumDetailScreen extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String price;
  final String location;
  final String sport;
  final String stadiumId;

  const StadiumDetailScreen({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.location,
    required this.sport,
    required this.stadiumId,
  });

  @override
  State<StadiumDetailScreen> createState() => _StadiumDetailScreenState();
}

class _StadiumDetailScreenState extends State<StadiumDetailScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  // Each slot is a Map: {'from': '14:00', 'to': '15:00'}
  Map<String, String>? _selectedSlot;
  List<Map<String, String>> _availableSlots = [];
  bool _loadingSlots = false;

  List<DateTime> get _nextDays =>
      List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    setState(() {
      _loadingSlots = true;
      _selectedSlot = null;
      _availableSlots = [];
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final slots = await Provider.of<BookingProvider>(
      context,
      listen: false,
    ).getAvailableSlots(widget.stadiumId, dateStr);

    final isToday = dateStr == DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<Map<String, String>> filteredSlots = slots;

    if (isToday) {
      final now = DateTime.now();
      filteredSlots = slots.where((slot) {
        try {
          final fromTimeStr = slot['from'];
          if (fromTimeStr == null) return false;
          final parts = fromTimeStr.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          // Check if the slot start time is in the future
          final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
          return slotTime.isAfter(now);
        } catch (e) {
          return true;
        }
      }).toList();
    }

    if (mounted) {
      setState(() {
        _availableSlots = filteredSlots;
        _loadingSlots = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4C8C18);
    final darkBg = const Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: darkBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Image & Info Card
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: widget.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.sports_soccer,
                              color: Colors.white54,
                              size: 60,
                            ),
                          ),
                        )
                      : Container(color: Colors.grey[900]),
                ),
                // Back Button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: greenColor, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // Info Card
                Positioned(
                  top: 180,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sport Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: greenColor.withOpacity(0.8),
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
                        const SizedBox(height: 8),
                        Text(
                          widget.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white54,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.location,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.price,
                                    style: TextStyle(
                                      color: greenColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '/hr',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
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
                ),
              ],
            ),

            const SizedBox(height: 100),

            // 2. Select Day
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Day',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _nextDays.length,
                      itemBuilder: (context, index) {
                        final day = _nextDays[index];
                        bool isSelected =
                            DateFormat('yyyy-MM-dd').format(day) ==
                            DateFormat('yyyy-MM-dd').format(_selectedDate);
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedDate = day);
                            _fetchSlots();
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? greenColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: greenColor, width: 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('EEE').format(day),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  day.day.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Available Slots
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Slots',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loadingSlots)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF4C8C18),
                        ),
                      ),
                    )
                  else if (_availableSlots.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'No available slots for this day',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _availableSlots.map((slot) {
                        final label = '${slot['from']} → ${slot['to']}';
                        final isSelected =
                            _selectedSlot != null &&
                            _selectedSlot!['from'] == slot['from'] &&
                            _selectedSlot!['to'] == slot['to'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSlot = slot),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? greenColor
                                  : const Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: greenColor, width: 1),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 4. Book Now Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  final canBook =
                      !bookingProvider.isLoading && _selectedSlot != null;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canBook
                          ? () async {
                              final stadium = StadiumModel(
                                id: widget.stadiumId,
                                name: widget.name,
                                location: widget.location,
                                price: widget.price,
                                imageUrl: widget.imageUrl,
                                sport: widget.sport,
                                rating: 0.0,
                              );

                              final fromTime = _selectedSlot!['from']!;
                              final toTime = _selectedSlot!['to']!;

                              final success = await bookingProvider
                                  .createBooking(
                                    stadium,
                                    _selectedDate,
                                    fromTime,
                                    toTime,
                                  );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? '✅ Booking confirmed!'
                                          : '❌ Booking failed. Please try again.',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: success
                                        ? greenColor
                                        : Colors.red,
                                  ),
                                );
                                if (success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MyBookingsScreen(),
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        disabledBackgroundColor: greenColor.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: bookingProvider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              _selectedSlot == null
                                  ? 'Select a slot to book'
                                  : 'Book Now — ${_selectedSlot!['from']} to ${_selectedSlot!['to']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
