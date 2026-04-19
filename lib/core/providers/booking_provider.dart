import 'package:flutter/material.dart';
import '../models/stadium_model.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  List<StadiumModel> _stadiums = [];
  List<BookingModel> _bookings = [];
  bool _isLoading = false;

  List<StadiumModel> get stadiums => _stadiums;
  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> fetchStadiums() async {
    _isLoading = true;
    notifyListeners();

    // Mock API Delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock Data
    _stadiums = [
      StadiumModel(
        id: 's1',
        name: 'Camp Nou',
        location: 'Downtown',
        city: 'Cairo',
        sportType: 'Football',
        pricePerHour: 150.0,
        imageUrl: 'https://placeholder.com/stadium1.jpg',
        rating: 4.8,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createBooking(StadiumModel stadium, DateTime date, String time, int hours) async {
    final newBooking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      stadium: stadium,
      date: date,
      timeSlot: time,
      durationHours: hours,
      totalPrice: hours * stadium.pricePerHour,
      status: BookingStatus.upcoming,
      // Fixed interpolation for the string:
      qrCodeData: 'QR_CODE_DATA_' + DateTime.now().millisecondsSinceEpoch.toString(),
    );

    _bookings.add(newBooking);
    notifyListeners();
  }
}
