import '../screens/search_screen.dart';
import '../screens/library_screen.dart';
import 'package:flutter/material.dart';

class SidebarDesktop extends StatelessWidget {
  final bool isCollapsed;
  const SidebarDesktop({Key? key, this.isCollapsed = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCollapsed ? 80 : 240,
      color: const Color(0xFF0A0A0C), // Slightly darker than background
      child: Column(
        crossAxisAlignment: isCollapsed ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 24.0),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                const Icon(Icons.music_note, size: 32, color: Colors.white),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Text(
                    "Shrimp",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 40),
          InkWell(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Scaffold())), child: _buildNavItem(Icons.home_filled, "Home", true)),
          InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())), child: _buildNavItem(Icons.search, "Search", false)),
          InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LibraryScreen())), child: _buildNavItem(Icons.library_music_outlined, "Library", false)),
          
          const Spacer(),
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Liked Songs", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("124 tracks", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 16.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (!isCollapsed) const SizedBox(width: 16),
            Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 24),
            if (!isCollapsed) ...[
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

