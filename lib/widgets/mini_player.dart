import 'package:flutter/material.dart';

class MiniPlayerMobile extends StatelessWidget {
  const MiniPlayerMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: Text("Mini Player (Mobile)", style: TextStyle(color: Colors.white))),
    );
  }
}

class DesktopPlayerDock extends StatelessWidget {
  const DesktopPlayerDock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      color: Colors.black87,
      child: const Center(child: Text("Persistent Bottom Control Bar (Desktop)", style: TextStyle(color: Colors.white))),
    );
  }
}
