import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/stadium_card.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/stadium_provider.dart';
import '../../core/constants/app_colors.dart';

class CourtListScreen extends StatefulWidget {
  const CourtListScreen({super.key});

  @override
  State<CourtListScreen> createState() => _CourtListScreenState();
}

class _CourtListScreenState extends State<CourtListScreen> {
  final List<String> _categories = ['All', 'Football'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = AppColors.primary;
    const darkBg = AppColors.background;
    final navProvider = Provider.of<NavigationProvider>(context);

    final stadiumProvider = Provider.of<StadiumProvider>(context);

    // Filter logic
    final filteredStadiums = stadiumProvider.searchStadiums(
      _searchQuery,
      sport: navProvider.selectedSport,
    );

    return Scaffold(
      backgroundColor: darkBg,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.background,
        onRefresh: () => stadiumProvider.fetchStadiums(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: darkBg,
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
                                color: greenColor.withValues(alpha: 0.5),
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
                    ...filteredStadiums.map(
                      (stadium) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: StadiumCard(
                          name: stadium.name,
                          location: stadium.location,
                          price: stadium.price,
                          imageUrl: stadium.imageUrl,
                          sport: stadium.sport,
                          rating: stadium.rating,
                          stadiumId: stadium.id,
                        ),
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
