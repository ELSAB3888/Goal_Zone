import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/stadium_card.dart';
import '../../core/providers/navigation_provider.dart';
import 'filter_screen.dart';

class CourtListScreen extends StatefulWidget {
  const CourtListScreen({Key? key}) : super(key: key);

  @override
  State<CourtListScreen> createState() => _CourtListScreenState();
}

class _CourtListScreenState extends State<CourtListScreen> {
  final List<String> _categories = ['All', 'Football', 'Tennis', 'Basketball'];

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4C8C18);
    final darkBg = const Color(0xFF1E1E1E);
    final navProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      backgroundColor: darkBg,
      body: CustomScrollView(
        slivers: [
          // 1. Header with Stadium Image and Back Button
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: darkBg,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: greenColor, size: 28),
              onPressed: () {
                navProvider.setIndex(0); // Go back to Home tab
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                'https://images.unsplash.com/photo-1518605368461-1e1e1140728c?q=80&w=800&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Play Ground',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search & Filter
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: greenColor.withOpacity(0.5), width: 1),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: greenColor),
                              const SizedBox(width: 12),
                              const Text('Search courts...', style: TextStyle(color: Colors.white54)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FilterScreen()),
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
                  const SizedBox(height: 20),

                  // Category Pills
                  SizedBox(
                    height: 35,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        bool isSelected = navProvider.selectedSport == _categories[index];
                        return GestureDetector(
                          onTap: () {
                            navProvider.setSelectedSport(_categories[index]);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? greenColor : const Color(0xFF3C5E18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _categories[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // List of Stadiums
                  const StadiumCard(
                    name: 'Alahly Stadium',
                    location: 'Nasr city, cairo',
                    price: '350 EGP',
                    imageUrl: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop',
                    sport: 'Football',
                    rating: 4.8,
                  ),
                  const SizedBox(height: 16),
                  const StadiumCard(
                    name: 'Zamalek Stadium',
                    location: 'Nasr city, cairo',
                    price: '350 EGP',
                    imageUrl: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop',
                    sport: 'Football',
                    rating: 4.8,
                  ),
                  const SizedBox(height: 16),
                  const StadiumCard(
                    name: 'Pyramids',
                    location: 'Nasr city, cairo',
                    price: '400 EGP',
                    imageUrl: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop',
                    sport: 'Football',
                    rating: 4.9,
                  ),
                  const SizedBox(height: 16),
                  const StadiumCard(
                    name: 'Pyramids',
                    location: 'Nasr city, cairo',
                    price: '400 EGP',
                    imageUrl: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop',
                    sport: 'Football',
                    rating: 4.9,
                  ),
                  const SizedBox(height: 16),
                  const StadiumCard(
                    name: 'Pyramids',
                    location: 'Nasr city, cairo',
                    price: '400 EGP',
                    imageUrl: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop',
                    sport: 'Football',
                    rating: 4.9,
                  ),
                  const SizedBox(height: 16),
                  const StadiumCard(
                    name: 'Pyramids',
                    location: 'Nasr city, cairo',
                    price: '400 EGP',
                    imageUrl: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop',
                    sport: 'Football',
                    rating: 4.9,
                  ),
                  const SizedBox(height: 16),
                  const StadiumCard(
                    name: 'Pyramids',
                    location: 'Nasr city, cairo',
                    price: '400 EGP',
                    imageUrl: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop',
                    sport: 'Football',
                    rating: 4.9,
                  ),
                  const SizedBox(height: 16),
                  const StadiumCard(
                    name: 'Pyramids',
                    location: 'Nasr city, cairo',
                    price: '400 EGP',
                    imageUrl: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop',
                    sport: 'Football',
                    rating: 4.9,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 80), // Padding for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
