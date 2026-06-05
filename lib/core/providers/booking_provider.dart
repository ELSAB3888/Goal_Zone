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

  String? _lastCreatedQrToken;

  List<BookingModel> get bookings => [..._upcoming, ..._completed, ..._cancelled];
  List<BookingModel> get upcoming => _upcoming;
  List<BookingModel> get completed => _completed;
  List<BookingModel> get cancelled => _cancelled;
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get lastCreatedQrToken => _lastCreatedQrToken;

  // ─── Available Slots ────────────────────────────────────────────────────────
  /// GET /bookings/playground/:id/available-slots?date=YYYY-MM-DD
  Future<List<Map<String, String>>> getAvailableSlots(
      String playgroundId, String date) async {
    try {
      final response = await _apiService.client.get(
        '/bookings/playground/$playgroundId/available-slots',
        queryParameters: {'date': date},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
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

  // ─── Fetch My Bookings ───────────────────────────────────────────────────────
  /// GET /bookings/my-bookings
  /// Response: {
  ///   success: true,
  ///   data: {
  ///     upcoming: [{ id, playground, image, address, date, startEnd, amount, status }],
  ///     completed: [...],
  ///     cancelled: [...]
  ///   }
  /// }
  Future<void> fetchMyBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/bookings/my-bookings');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        List upcomingJson = [];
        List completedJson = [];
        List cancelledJson = [];

        if (data is Map<String, dynamic>) {
          upcomingJson = data['upcoming'] as List? ?? [];
          completedJson = data['completed'] as List? ?? [];
          cancelledJson = data['cancelled'] as List? ?? [];
        } else if (data is List) {
          // Flat list fallback — categorise by status field
          for (final item in data) {
            final status = item['status']?.toString().toLowerCase() ?? '';
            if (status == 'completed') {
              completedJson.add(item);
            } else if (status == 'cancelled') {
              cancelledJson.add(item);
            } else {
              upcomingJson.add(item);
            }
          }
        }

        final List<BookingModel> upcomingRaw = upcomingJson
            .map((json) => _safeParseBooking(json))
            .whereType<BookingModel>()
            .toList();

        _completed = completedJson
            .map((json) => _safeParseBooking(json))
            .whereType<BookingModel>()
            .toList();

        _cancelled = cancelledJson
            .map((json) => _safeParseBooking(json))
            .whereType<BookingModel>()
            .toList();

        // Move any already-passed upcoming bookings to completed
        _upcoming = [];
        for (final booking in upcomingRaw) {
          if (booking.isPassed) {
            _completed.insert(0, booking);
          } else {
            _upcoming.add(booking);
          }
        }

        // Sort completed by date descending (most recent first)
        _completed.sort((a, b) => b.date.compareTo(a.date));
      }
    } on DioException catch (e) {
      debugPrint('Fetch Bookings Error: ${e.response?.data ?? e.message}');
    } catch (e, stack) {
      debugPrint('Fetch Bookings Unexpected Error: $e');
      debugPrint('Stack: $stack');
    }

    _isLoading = false;
    notifyListeners();
  }

  BookingModel? _safeParseBooking(dynamic json) {
    try {
      return BookingModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error parsing booking: $e | JSON: $json');
      return null;
    }
  }

  // ─── Get Booking By ID ───────────────────────────────────────────────────────
  /// GET /bookings/:id  — Returns full booking object including qrToken
  Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    try {
      final response =
          await _apiService.client.get('/bookings/$bookingId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>?;
      }
    } on DioException catch (e) {
      debugPrint('Get Booking By ID Error: ${e.response?.data ?? e.message}');
    }
    return null;
  }

  /// Fetches only the qrToken for a given booking ID from the API.
  Future<String> getBookingQrToken(String bookingId) async {
    final data = await getBookingById(bookingId);
    return data?['qrToken']?.toString() ?? 'NO_QR';
  }

  // ─── Create Booking ──────────────────────────────────────────────────────────
  /// POST /bookings
  /// Body: { playgroundId, bookTime: { from, to, date } }
  /// Returns true on success. On success, [lastCreatedQrToken] holds the qrToken
  /// returned directly from the creation response.
  Future<bool> createBooking(
    StadiumModel stadium,
    DateTime date,
    String fromTime,
    String toTime,
  ) async {
    _isLoading = true;
    _lastCreatedQrToken = null;
    notifyListeners();

    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final response = await _apiService.client.post('/bookings', data: {
        'playgroundId': stadium.id,
        'bookTime': {
          'from': fromTime,
          'to': toTime,
          'date': dateStr,
        },
      });

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        // Extract qrToken directly from the creation response
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          _lastCreatedQrToken = data['qrToken']?.toString();
          // If qrToken not in direct response, fetch by booking ID
          if (_lastCreatedQrToken == null || _lastCreatedQrToken!.isEmpty) {
            final bookingId =
                data['_id']?.toString() ?? data['id']?.toString();
            if (bookingId != null && bookingId.isNotEmpty) {
              _lastCreatedQrToken = await getBookingQrToken(bookingId);
            }
          }
        }
        _isLoading = false;
        notifyListeners();
        await fetchMyBookings(); // Refresh list
        return true;
      } else {
        debugPrint('Create Booking Failed: ${response.data['message']}');
      }
    } on DioException catch (e) {
      debugPrint('Create Booking Error: ${e.response?.data}');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── Cancel Booking ──────────────────────────────────────────────────────────
  /// PUT /bookings/:id/cancel   (user cancellation — no body required)
  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await _apiService.client.put('/bookings/$bookingId/cancel');

      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchMyBookings(); // Refresh list to show updated status
        return true;
      } else {
        debugPrint('Cancel Booking Failed: ${response.data['message']}');
      }
    } on DioException catch (e) {
      debugPrint('Cancel Booking Error: ${e.response?.data ?? e.message}');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── Reschedule Booking ──────────────────────────────────────────────────────
  /// PUT /bookings/:id/reschedule
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
      final dateStr =
          '${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}';

      final response =
          await _apiService.client.put('/bookings/$bookingId/reschedule', data: {
        'bookTime': {
          'from': fromTime,
          'to': toTime,
          'date': dateStr,
        },
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
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

  // ─── Notifications ───────────────────────────────────────────────────────────
  /// GET /messages/my-notifications
  Future<void> fetchNotifications() async {
    try {
      final response =
          await _apiService.client.get('/messages/my-notifications');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _notifications =
            List<Map<String, dynamic>>.from(response.data['data'] ?? []);
        notifyListeners();
      }
    } on DioException catch (e) {
      debugPrint('Fetch Notifications Error: ${e.message}');
    }
  }
}
