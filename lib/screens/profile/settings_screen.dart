import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4C8C18);
    final darkBg = const Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: greenColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          bool isEnglish = localeProvider.locale.languageCode == 'en';

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Select language',
                  style: TextStyle(
                    color: greenColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // English Option
                _buildLanguageOption(
                  title: 'English',
                  isSelected: isEnglish,
                  greenColor: greenColor,
                  onTap: () {
                    localeProvider.setLocale(const Locale('en'));
                  },
                ),
                const SizedBox(height: 16),

                // Arabic Option
                _buildLanguageOption(
                  title: 'Arabic',
                  isSelected: !isEnglish,
                  greenColor: greenColor,
                  onTap: () {
                    localeProvider.setLocale(const Locale('ar'));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required bool isSelected,
    required Color greenColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: greenColor.withOpacity(0.5), width: 1),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? greenColor : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: greenColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
