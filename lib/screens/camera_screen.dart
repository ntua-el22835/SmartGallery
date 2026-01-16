import 'package:flutter/material.dart';

/// Dummy Camera Screen (for navigation)
class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.camera_alt, size: 80, color: Colors.white70),
            SizedBox(height: 16),
            Text('Camera Screen', style: TextStyle(color: Colors.white70, fontSize: 20)),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
