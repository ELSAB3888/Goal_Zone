import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4C8C18);
    final darkBg = const Color(0xFF1E1E1E);
    final containerBg = const Color(0xFF25331C); // Dark greenish tint from the image

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: greenColor),
          onPressed: () {
            // Keep for consistency with UI, might not pop if it's a bottom nav root.
          },
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // 1. User Info Section
            Center(
              child: Column(
                children: [
                  // Profile Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    // If we had an image: 
                    // child: ClipOval(child: Image.network('url', fit: BoxFit.cover)),
                  ),
                  const SizedBox(height: 16),
                  // Name
                  const Text(
                    'Mohamed ELSab3',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Pro Member Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: greenColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Pro Member', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  // Email
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.email_outlined, color: Colors.white70, size: 16),
                      SizedBox(width: 8),
                      Text('mals08135@gmail.com', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Settings Group 1
            Container(
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: greenColor.withOpacity(0.5), width: 1),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    'Edit Profile', 
                    greenColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                  ),
                  Divider(color: greenColor.withOpacity(0.3), height: 1, indent: 16, endIndent: 16),
                  _buildListTile('Booking History', greenColor),
                  Divider(color: greenColor.withOpacity(0.3), height: 1, indent: 16, endIndent: 16),
                  _buildListTile('Payment Methods', greenColor, subtitle: 'visa ending in 4242'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Settings Group 2
            Container(
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: greenColor.withOpacity(0.5), width: 1),
              ),
              child: Column(
                children: [
                  _buildListTile('Stadium Favorite', greenColor),
                  Divider(color: greenColor.withOpacity(0.3), height: 1, indent: 16, endIndent: 16),
                  _buildListTile(
                    'Setting', 
                    greenColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 4. Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showLogoutDialog(context, greenColor);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: const Color(0xFF2C2C2C), // Dark grey background
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 80), // Padding for Bottom Nav Bar
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, Color greenColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF333333), // Dark grey dialog background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: greenColor.withOpacity(0.5), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Are you sure you want to\nsign out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Handle confirm logout
                          // e.g., Provider.of<AuthProvider>(context, listen: false).logout();
                          // Navigator.of(context).pushAndRemoveUntil(...)
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: greenColor, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          'Please confirm',
                          style: TextStyle(color: greenColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Going back',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile(String title, Color greenColor, {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: greenColor,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: onTap ?? () {
        // Handle tap
      },
    );
  }
}
