import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/stadium_card.dart';
import '../../core/providers/navigation_provider.dart';
import 'notifications_screen.dart';
import '../court/filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, dynamic>> _allStadiums = [
    {
      'name': 'Alahly Stadium',
      'location': 'Nasr city, cairo',
      'price': '350 EGP',
      'imageUrl':
          'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop',
      'sport': 'Football',
      'rating': 4.8,
    },
    {
      'name': 'Zamalek Club',
      'location': 'Mohandeseen, cairo',
      'price': '300 EGP',
      'imageUrl':
          'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop',
      'sport': 'Football',
      'rating': 4.8,
    },
    {
      'name': 'Pyramids Court',
      'location': 'New Cairo, cairo',
      'price': '400 EGP',
      'imageUrl':
          'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop',
      'sport': 'Football',
      'rating': 4.9,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4C8C18);
    final darkBg = const Color(0xFF1E1E1E);

    final filteredStadiums = _allStadiums.where((stadium) {
      return stadium['name'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          stadium['location'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header (User Info & Notification)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Logo Placeholder
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: greenColor, width: 1),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Text(
                                    'logo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Good Everything',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Mohamed ELSabi',
                              style: TextStyle(
                                color: greenColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Notification Icon
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: greenColor, width: 1),
                        ),
                        child: Icon(
                          Icons.notifications_none,
                          color: greenColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Hero Banner
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=1000&auto=format&fit=crop',
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.broken_image,
                              color: Color(0xFF4C8C18),
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Book Your ',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: 'Game',
                                  style: TextStyle(color: greenColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Find and book the best\nPlay Ground near you',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<NavigationProvider>(
                                context,
                                listen: false,
                              ).setIndex(1);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Explore',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Sports Title
                const Text(
                  'Sports',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Search Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search Play Ground, sports...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: Icon(Icons.search, color: greenColor),
                          filled: true,
                          fillColor: const Color(0xFF2C2C2C),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: greenColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: greenColor, width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FilterScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: greenColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 5. Categories ListView
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryItem(
                        context,
                        'Football',
                        'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=200&auto=format&fit=crop',
                      ),
                      _buildCategoryItem(
                        context,
                        'Tennis',
                        'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=200&auto=format&fit=crop',
                      ),
                      _buildCategoryItem(
                        context,
                        'Basketball',
                        'https://images.unsplash.com/photo-1519861531473-9200262188bf?w=200&auto=format&fit=crop',
                      ),
                      _buildCategoryItem(
                        context,
                        'Padel',
                        'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=200&auto=format&fit=crop',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 6. Featured Stadiums (Filtered by search)
                const Text(
                  'Featured Play Grounds',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (filteredStadiums.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'No play grounds found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  ...filteredStadiums
                      .map(
                        (stadium) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: StadiumCard(
                            name: stadium['name'],
                            location: stadium['location'],
                            price: stadium['price'],
                            imageUrl: stadium['imageUrl'],
                            sport: stadium['sport'],
                            rating: stadium['rating'],
                          ),
                        ),
                      )
                      .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    String imageUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
          if (title == 'Football') {
            final navProvider = Provider.of<NavigationProvider>(
              context,
              listen: false,
            );
            navProvider.setSelectedSport('Football');
            navProvider.setIndex(1);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$title Coming Soon!',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF4C8C18),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 70,
                  color: Colors.grey[900],
                  child: const Icon(
                    Icons.broken_image,
                    color: Color(0xFF4C8C18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
