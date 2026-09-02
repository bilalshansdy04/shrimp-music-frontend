import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../widgets/bottom_nav_mobile.dart';
import '../widgets/sidebar_desktop.dart';
import '../widgets/mini_player.dart';

class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Breakpoints based on PRD
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 1024;
        bool isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
        
        if (isDesktop || isTablet) {
          return Scaffold(
            body: Row(
              children: [
                SidebarDesktop(isCollapsed: isTablet),
                const Expanded(child: HomeScreen()),
              ],
            ),
            // We use bottomSheet or a persistent Stack layer for the Desktop player dock
            bottomNavigationBar: const DesktopPlayerDock(),
          );
        }

        // Mobile Layout
        return Scaffold(
          body: const HomeScreen(),
          extendBody: true,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              MiniPlayerMobile(),
              BottomNavMobile(),
            ],
          ),
        );
      },
    );
  }
}
