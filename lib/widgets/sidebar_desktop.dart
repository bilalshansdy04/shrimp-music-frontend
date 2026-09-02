import 'package:flutter/material.dart';

class SidebarDesktop extends StatelessWidget {
  final bool isCollapsed;
  const SidebarDesktop({Key? key, this.isCollapsed = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCollapsed ? 80 : 240,
      color: Colors.black26,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(Icons.music_note, size: isCollapsed ? 32 : 48, color: Colors.white),
          const SizedBox(height: 32),
          // Links
        ],
      ),
    );
  }
}
