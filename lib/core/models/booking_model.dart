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
        case 'confirmed':
        case 'upcoming':
        default:
          return BookingStatus.upcoming;
      }
    }

    // ======================================================
    // NEW API FORMAT — returned by GET /bookings/my-bookings
    // Each item is a flat object:
    // {
    //   "id": "...",
    //   "playground": "al jzera",
    //   "image": "https://...",
    //   "address": "الأربعين، السويس، السويس",
    //   "date": "2026-04-25T00:00:00.000Z",
    //   "startEnd": "18:00 - 19:00",
    //   "amount": 500,
    //   "status": "pending"
    // }
    // ======================================================
    final bool isNewFormat = json.containsKey('playground') && json.containsKey('startEnd');

    if (isNewFormat) {
      final rawImage = json['image']?.toString() ?? '';
      final imageUrl = (rawImage.isNotEmpty && rawImage.startsWith('http'))
          ? rawImage
          : 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop';

      final dateRaw = json['date']?.toString() ?? '';
      final dateOnly = dateRaw.split('T')[0];

      final stadium = StadiumModel(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        name: json['playground']?.toString() ?? 'Unknown Stadium',
        location: json['address']?.toString() ?? '',
        price: '${json['amount'] ?? 0} EGP',
        imageUrl: imageUrl,
        sport: 'Football',
        rating: 0.0,
      );

      return BookingModel(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        stadium: stadium,
        date: DateTime.tryParse(dateOnly) ?? DateTime.now(),
        timeSlot: json['startEnd']?.toString() ?? '',
        durationHours: 1,
        totalPrice: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
        status: parseStatus(json['status']?.toString() ?? 'pending'),
        qrCodeData: json['qrToken']?.toString() ?? 'NO_QR',
      );
    }

    // ======================================================
    // OLD / NESTED FORMAT — playgroundId as populated object
    // ======================================================
    final playground = json['playgroundId'];
    StadiumModel stadium;

    if (playground is Map<String, dynamic>) {
      final features = playground['features'] as List?;
      String sportType = 'Football';
      if (features != null && features.isNotEmpty) {
        sportType = features[0].toString();
      }

      final images = playground['images'] as List?;
      String imageUrl = 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop';
      if (images != null && images.isNotEmpty) {
        final img = images[0].toString();
        imageUrl = img.startsWith('http') ? img : 'https://goalzone-api.vercel.app/$img';
      }

      final address = playground['address'];
      String location = '';
      if (address is Map<String, dynamic>) {
        final gov = address['governorate'] ?? '';
        final city = address['city'] ?? '';
        location = '$gov, $city'.trim();
        if (location == ',') location = '';
      }

      final pricing = playground['pricing'];
      String price = '0 EGP';
      if (pricing is Map<String, dynamic> && pricing['daytime'] != null) {
        price = '${pricing['daytime']['price']} EGP';
      }

      stadium = StadiumModel(
        id: playground['_id']?.toString() ?? '',
        name: playground['playground']?.toString() ?? playground['name']?.toString() ?? 'Unknown Stadium',
        location: location,
        price: price,
        imageUrl: imageUrl,
        sport: sportType,
        rating: 0.0,
      );
    } else {
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

    final bookTime = json['bookTime'] as Map<String, dynamic>?;
    final dateRaw = bookTime?['date'];
    String? dateStr;
    if (dateRaw != null) {
      dateStr = dateRaw.toString().split('T')[0];
    }
    final timeFrom = bookTime?['from']?.toString() ?? '';
    final timeTo = bookTime?['to']?.toString() ?? '';

    return BookingModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      stadium: stadium,
      date: dateStr != null ? DateTime.tryParse(dateStr) ?? DateTime.now() : DateTime.now(),
      timeSlot: '$timeFrom - $timeTo',
      durationHours: json['duration'] ?? 1,
      totalPrice: json['totalPrice'] != null
          ? double.tryParse(json['totalPrice'].toString()) ?? 0.0
          : 0.0,
      status: parseStatus(json['status']?.toString() ?? 'upcoming'),
      qrCodeData: json['qrToken']?.toString() ?? 'NO_QR',
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
