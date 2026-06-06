import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/stadium_card.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/stadium_provider.dart';
import '../../core/providers/auth_provider.dart';
import 'notifications_screen.dart';
import '../../core/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<StadiumProvider>(context, listen: false).fetchStadiums();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = AppColors.primary;
    const darkBg = AppColors.background;

    final stadiumProvider = Provider.of<StadiumProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUser?.name ?? '';

    final filteredStadiums = stadiumProvider.searchStadiums(_searchQuery);

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.background,
          onRefresh: () => stadiumProvider.fetchStadiums(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
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
                              userName,
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
                        stadiumProvider.allStadiums.isNotEmpty
                            ? stadiumProvider.allStadiums[0].imageUrl
                            : 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=1000&auto=format&fit=crop',
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=1000&auto=format&fit=crop',
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
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
                            Colors.black.withValues(alpha: 0.8),
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
                              color: greenColor.withValues(alpha: 0.5),
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
                if (stadiumProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (filteredStadiums.isEmpty)
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
              ],
            ),
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
                backgroundColor: AppColors.primary,
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
                    color: AppColors.primary,
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
