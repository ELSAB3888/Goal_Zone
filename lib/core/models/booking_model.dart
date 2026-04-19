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
}
