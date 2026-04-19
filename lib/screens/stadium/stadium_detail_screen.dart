import 'package:flutter/material.dart';
import '../booking/ticket_screen.dart';

class StadiumDetailScreen extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String price;
  final String location;
  final String sport;

  const StadiumDetailScreen({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.location,
    required this.sport,
  }) : super(key: key);

  @override
  State<StadiumDetailScreen> createState() => _StadiumDetailScreenState();
}

class _StadiumDetailScreenState extends State<StadiumDetailScreen> {
  int _selectedDayIndex = 3; // Default 'Fri 13' selected as per image

  final List<Map<String, String>> _days = [
    {'day': 'Tue', 'date': '10'},
    {'day': 'Wed', 'date': '11'},
    {'day': 'Thu', 'date': '12'},
    {'day': 'Fri', 'date': '13'},
    {'day': 'Sat', 'date': '14'},
    {'day': 'Sun', 'date': '15'},
  ];

  String? _selectedFromTime;
  String? _selectedToTime;

  final List<String> _times = ['10:00Am', '9:00Am', '5:00Pm', '11:00Am', '9:00Pm'];

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
            // 1. Header Image & Overlay Card
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Top Image
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
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
                // Overlay Card
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: greenColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.sport,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Stadium Name
                        Text(
                          widget.name,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // Info Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.location, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                            const Text('10-22 player', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                            const Text('7 slots available', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Price
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16),
                            children: [
                              TextSpan(text: widget.price, style: TextStyle(color: greenColor, fontWeight: FontWeight.bold)),
                              const TextSpan(text: '/hr', style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Spacer for overlapping card
            const SizedBox(height: 110),

            // 2. Select Day
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Day',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _days.length,
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedDayIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDayIndex = index;
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? greenColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: greenColor, width: 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _days[index]['day']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _days[index]['date']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white,
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

            // 3. Available Times
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Times',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align to top because of dropdowns
                    children: [
                      // From Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('From', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              hint: 'select time',
                              value: _selectedFromTime,
                              items: _times,
                              onChanged: (val) {
                                setState(() {
                                  _selectedFromTime = val;
                                });
                              },
                              greenColor: greenColor,
                            ),
                          ],
                        ),
                      ),
                      
                      // Colon Separator
                      const Padding(
                        padding: EdgeInsets.only(top: 36.0, left: 8, right: 8),
                        child: Text(':', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),

                      // To Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('To', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              hint: 'select time',
                              value: _selectedToTime,
                              items: _times,
                              onChanged: (val) {
                                setState(() {
                                  _selectedToTime = val;
                                });
                              },
                              greenColor: greenColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 4. Book Now Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Ticket Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketScreen(
                          stadiumName: widget.name,
                          date: '12-2-2026', // Mock data
                          time: 'From ' + (_selectedFromTime ?? '10:00Am') + ' To ' + (_selectedToTime ?? '12:00Am'),
                          location: widget.location,
                          totalPrice: widget.price,
                          duration: '2hr',
                          sport: widget.sport,
                          qrData: 'BOOKING_QR_DATA_MOCK',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required Color greenColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Darker background to match the list box in image
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: greenColor.withOpacity(0.5), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.white)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: const Color(0xFF2C2C2C),
          items: items.map((String time) {
            return DropdownMenuItem<String>(
              value: time,
              child: Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
