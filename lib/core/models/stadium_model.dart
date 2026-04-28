class StadiumModel {
  final String id;
  final String name;
  final String location;
  final String price;
  final String imageUrl;
  final String sport;
  final double rating;

  StadiumModel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.sport,
    required this.rating,
  });

  factory StadiumModel.fromJson(Map<String, dynamic> json) {
    String getPlaceholderImage(String sportStr) {
      switch (sportStr.toLowerCase()) {
        case 'tennis':
          return 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=600&auto=format&fit=crop';
        case 'basketball':
          return 'https://images.unsplash.com/photo-1519861531473-9200262188bf?w=600&auto=format&fit=crop';
        case 'padel':
          return 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=600&auto=format&fit=crop';
        case 'football':
        default:
          return 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop';
      }
    }

    final String sportType = json['sport'] ?? 'Football';

    final List<dynamic>? images = json['images'];
    String finalImageUrl = '';

    if (images != null && images.isNotEmpty) {
      final String apiImage = images[0].toString();
      if (apiImage.startsWith('http')) {
        finalImageUrl = apiImage;
      } else if (apiImage.startsWith('/')) {
        finalImageUrl = 'https://goalzone-api.vercel.app$apiImage';
      } else {
        finalImageUrl = 'https://goalzone-api.vercel.app/$apiImage';
      }
    } else {
      finalImageUrl = getPlaceholderImage(sportType);
    }

    return StadiumModel(
      id: json['_id'] ?? '',
      name: json['playground'] ?? json['name'] ?? 'Unknown Stadium',
      location: json['address'] != null 
          ? '${json['address']['governorate'] ?? ''}, ${json['address']['city'] ?? ''}'.trim()
          : json['location'] ?? 'Unknown Location',
      price: json['pricing'] != null && json['pricing']['daytime'] != null
          ? '${json['pricing']['daytime']['price']} EGP'
          : json['price'] != null ? '${json['price']} EGP' : '0 EGP',
      imageUrl: finalImageUrl,
      sport: sportType,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) ?? 0.0 : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'location': location,
      'price': price.replaceAll(RegExp(r'[^0-9.]'), ''), // Save only number
      'imageUrl': imageUrl,
      'sport': sport,
      'rating': rating,
    };
  }
}
