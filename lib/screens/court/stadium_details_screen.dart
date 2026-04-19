import 'package:flutter/material.dart';

class StadiumDetailsPlaceholder extends StatelessWidget {
  const StadiumDetailsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stadium Details')),
      body: const Center(child: Text('Stadium Details Placeholder')),
    );
  }
}
