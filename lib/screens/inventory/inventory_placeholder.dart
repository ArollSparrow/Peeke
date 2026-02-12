import 'package:flutter/material.dart';

class InventoryPlaceholder extends StatelessWidget {
  final String featureName;
  const InventoryPlaceholder({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(featureName, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, size: 80, color: Color(0xFF3399CC)),
            const SizedBox(height: 24),
            Text(featureName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Coming Soon', style: TextStyle(color: Color(0xFF888888), fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
