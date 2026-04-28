import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/stadium_model.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';

class BookingProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<BookingModel> _upcoming = [];
  List<BookingModel> _completed = [];
  List<BookingModel> _cancelled = [];
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => [..._upcoming, ..._completed, ..._cancelled];
  List<BookingModel> get upcoming => _upcoming;
  List<BookingModel> get completed => _completed;
  List<BookingModel> get cancelled => _cancelled;
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;

  /// Returns available slots as a list of maps: [{from: "14:00", to: "15:00"}, ...]
  /// URL: GET /bookings/playground/:id/available-slots?date=YYYY-MM-DD
  Future<List<Map<String, String>>> getAvailableSlots(String playgroundId, String date) async {
    try {
      final response = await _apiService.client.get(
        '/bookings/playground/$playgroundId/available-slots',
        queryParameters: {'date': date},
      );
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map<Map<String, String>>((slot) => {
          'from': slot['from']?.toString() ?? '',
          'to': slot['to']?.toString() ?? '',
        }).toList();
      }
    } on DioException catch (e) {
      debugPrint('Get Available Slots Error: ${e.message}');
    }
    return [];
  }

  /// URL: GET /bookings/my-bookings
  /// Response: { success: true, data: { upcoming: [], completed: [], cancelled: [] } }
  Future<void> fetchMyBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/bookings/my-bookings');
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'] as Map<String, dynamic>;

        final List<BookingModel> upcomingRaw = (data['upcoming'] as List? ?? [])
            .map((json) => BookingModel.fromJson(json))
            .toList();
        
        _completed = (data['completed'] as List? ?? [])
            .map((json) => BookingModel.fromJson(json))
            .toList();
        
        _cancelled = (data['cancelled'] as List? ?? [])
            .map((json) => BookingModel.fromJson(json))
            .toList();

        // Move passed bookings from upcoming to completed
        _upcoming = [];
        for (var booking in upcomingRaw) {
          if (booking.isPassed) {
            _completed.insert(0, booking); // Add to completed list
          } else {
            _upcoming.add(booking);
          }
        }
        
        // Sort completed by date descending
        _completed.sort((a, b) => b.date.compareTo(a.date));
      }
    } on DioException catch (e) {
      debugPrint('Fetch Bookings Error: ${e.message}');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// URL: POST /bookings
  /// Body: { playgroundId, bookTime: { from, to, date } }
  Future<bool> createBooking(
    StadiumModel stadium,
    DateTime date,
    String fromTime,
    String toTime,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final response = await _apiService.client.post('/bookings', data: {
        'playgroundId': stadium.id,
        'bookTime': {
          'from': fromTime,
          'to': toTime,
          'date': dateStr,
        },
      });

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success']) {
        _isLoading = false;
        notifyListeners();
        await fetchMyBookings(); // Refresh bookings list
        return true;
      } else {
        // Show server message if available
        debugPrint('Create Booking Failed: ${response.data['message']}');
      }
    } on DioException catch (e) {
      debugPrint('Create Booking Error: ${e.response?.data}');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// URL: PUT /bookings/:id/cancel
  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.client.put('/bookings/$bookingId/cancel');
      if (response.statusCode == 200 && response.data['success']) {
        await fetchMyBookings(); // Refresh list to update status
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Cancel Booking Error: ${e.response?.data ?? e.message}');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// URL: PUT /bookings/:id/reschedule
  /// Body: { bookTime: { from, to, date } }
  Future<bool> rescheduleBooking(
    String bookingId,
    DateTime newDate,
    String fromTime,
    String toTime,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final dateStr = '${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}';
      final response = await _apiService.client.put('/bookings/$bookingId/reschedule', data: {
        'bookTime': {
          'from': fromTime,
          'to': toTime,
          'date': dateStr,
        },
      });

      if (response.statusCode == 200 && response.data['success']) {
        await fetchMyBookings();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Reschedule Booking Error: ${e.response?.data}');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// URL: GET /messages/my-notifications
  Future<void> fetchNotifications() async {
    try {
      final response = await _apiService.client.get('/messages/my-notifications');
      if (response.statusCode == 200 && response.data['success']) {
        _notifications = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
        notifyListeners();
      }
    } on DioException catch (e) {
      debugPrint('Fetch Notifications Error: ${e.message}');
    }
  }
}
