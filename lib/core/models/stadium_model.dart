class StadiumModel {
  final String id;
  final String name;
  final String location;
  final String city;
  final String sportType; // Football, Tennis, etc.
  final double pricePerHour;
  final String imageUrl;
  final double rating;

  StadiumModel({
    required this.id,
    required this.name,
    required this.location,
    required this.city,
    required this.sportType,
    required this.pricePerHour,
    required this.imageUrl,
    this.rating = 0.0,
  });
}
