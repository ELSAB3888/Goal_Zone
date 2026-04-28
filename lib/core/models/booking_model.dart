import 'stadium_model.dart';

enum BookingStatus { upcoming, completed, cancelled }

class BookingModel {
  final String id;
  final StadiumModel stadium;
  final DateTime date;
  final String timeSlot;
  final int durationHours;
  final double totalPrice;
  final BookingStatus status;
  final String qrCodeData;

  BookingModel({
    required this.id,
    required this.stadium,
    required this.date,
    required this.timeSlot,
    required this.durationHours,
    required this.totalPrice,
    required this.status,
    required this.qrCodeData,
  });

  bool get isPassed {
    if (status == BookingStatus.cancelled) return false;
    if (status == BookingStatus.completed) return true;

    try {
      // timeSlot format: "14:00 - 15:00"
      final parts = timeSlot.split(' - ');
      if (parts.length < 2) return false;
      
      final endTimeStr = parts[1]; // "15:00"
      final timeParts = endTimeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Combine booking date with end time
      final bookingEnd = DateTime(date.year, date.month, date.day, hour, minute);
      return DateTime.now().isAfter(bookingEnd);
    } catch (e) {
      return false;
    }
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    BookingStatus parseStatus(String statusStr) {
      switch (statusStr.toLowerCase()) {
        case 'completed':
          return BookingStatus.completed;
        case 'cancelled':
          return BookingStatus.cancelled;
        case 'pending':
        case 'upcoming':
        default:
          return BookingStatus.upcoming;
      }
    }

    // The playgroundId is a nested object from the API
    final playground = json['playgroundId'];
    StadiumModel stadium;
    if (playground is Map<String, dynamic>) {
      stadium = StadiumModel.fromJson(playground);
    } else {
      // It's just an ID string (e.g. from cancel response)
      stadium = StadiumModel(
        id: playground?.toString() ?? '',
        name: 'Unknown Stadium',
        location: '',
        price: '0 EGP',
        imageUrl: '',
        sport: 'Football',
        rating: 0.0,
      );
    }

    // Parse date and time from bookTime object
    final bookTime = json['bookTime'] as Map<String, dynamic>?;
    final dateStr = bookTime?['date'] as String?;
    final timeFrom = bookTime?['from'] as String? ?? '';
    final timeTo = bookTime?['to'] as String? ?? '';

    return BookingModel(
      id: json['_id'] ?? '',
      stadium: stadium,
      date: dateStr != null ? DateTime.tryParse(dateStr) ?? DateTime.now() : DateTime.now(),
      timeSlot: '$timeFrom - $timeTo',
      durationHours: json['duration'] ?? 1,
      totalPrice: json['totalPrice'] != null
          ? double.tryParse(json['totalPrice'].toString()) ?? 0.0
          : 0.0,
      status: parseStatus(json['status'] ?? 'upcoming'),
      qrCodeData: json['qrToken'] ?? 'NO_QR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playgroundId': stadium.id,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'duration': durationHours,
      'totalPrice': totalPrice,
    };
  }
}
