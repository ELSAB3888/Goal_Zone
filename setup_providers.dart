import 'dart:io';

void main() {
  final baseDir = 'sports_booking_app/lib';

  // Create directories
  Directory('$baseDir/core/models').createSync(recursive: true);
  Directory('$baseDir/core/providers').createSync(recursive: true);

  // 1. Models
  File('$baseDir/core/models/user_model.dart').writeAsStringSync('''
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImageUrl;

  UserModel({required this.id, required this.name, required this.phone, this.email, this.profileImageUrl});
}
''');

  File('$baseDir/core/models/stadium_model.dart').writeAsStringSync('''
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
''');

  File('$baseDir/core/models/booking_model.dart').writeAsStringSync('''
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
''');

  // 2. Providers
  File('$baseDir/core/providers/auth_provider.dart').writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    // Mock delay for API
    await Future.delayed(const Duration(seconds: 2));

    // Mock User Data
    _currentUser = UserModel(id: '1', name: 'John Doe', phone: phone);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', 'mock_token_123');

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
''');

  File('$baseDir/core/providers/booking_provider.dart').writeAsStringSync('''
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
''');

  File('$baseDir/core/providers/locale_provider.dart').writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // Default to English
  
  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners();
  }
}
''');

  // 3. Update Main Layout for IndexedStack
  File('$baseDir/widgets/main_layout.dart').writeAsStringSync('''
import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/court/court_list_screen.dart';
import '../screens/booking/my_bookings_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../core/constants/app_colors.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  
  // The pages for IndexedStack
  final List<Widget> _screens = [
    const HomeScreen(),
    const CourtListScreen(),
    const MyBookingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use IndexedStack to keep state alive
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Courts'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
''');

  // ignore: avoid_print
  print('Providers and Models generated successfully!');
}
