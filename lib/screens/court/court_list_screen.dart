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
  final List<String> _categories = ['All', 'Football'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Dynamic stadium data - ONLY Football for now
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
      'name': 'Zamalek Stadium',
      'location': 'Mohandeseen, cairo',
      'price': '320 EGP',
      'imageUrl':
          'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=600&auto=format&fit=crop',
      'sport': 'Football',
      'rating': 4.7,
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4C8C18);
    final darkBg = const Color(0xFF1E1E1E);
    final navProvider = Provider.of<NavigationProvider>(context);

    // Filter logic
    final List<Map<String, dynamic>> filteredStadiums = _allStadiums.where((
      stadium,
    ) {
      final bool matchesSport =
          navProvider.selectedSport == 'All' ||
          stadium['sport'] == navProvider.selectedSport;
      final bool matchesSearch =
          stadium['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          stadium['location'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesSport && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: darkBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: darkBg,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: greenColor, size: 28),
              onPressed: () {
                navProvider.setIndex(0);
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                'https://images.unsplash.com/photo-1551958219-acbc608c6377?q=80&w=1000&auto=format&fit=crop', // Unified banner image
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.black),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Play Ground',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                            hintText: 'Search courts...',
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
                              borderSide: BorderSide(
                                color: greenColor,
                                width: 1,
                              ),
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
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 35,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        bool isSelected =
                            navProvider.selectedSport == _categories[index];
                        return GestureDetector(
                          onTap: () {
                            navProvider.setSelectedSport(_categories[index]);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? greenColor
                                  : const Color(0xFF3C5E18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _categories[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (filteredStadiums.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Text(
                          'No courts found matching your search.',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
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
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
