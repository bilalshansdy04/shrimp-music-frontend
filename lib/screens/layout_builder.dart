import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import '../widgets/bottom_nav_mobile.dart';
import '../widgets/sidebar_desktop.dart';
import '../widgets/mini_player.dart';
import '../widgets/desktop_player_dock.dart';
import '../providers/player_provider.dart';

class ResponsiveLayoutBuilder extends ConsumerWidget {
  const ResponsiveLayoutBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final bgColor = playerState.dominantColor?.withOpacity(0.3) ?? const Color(0xFF0F0F13);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 1024;
        bool isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
        
        final scaffold = (isDesktop || isTablet) ? Scaffold(
          backgroundColor: Colors.transparent,
          body: Row(
            children: [
              SidebarDesktop(isCollapsed: isTablet),
              const Expanded(child: HomeScreen()),
            ],
          ),
          bottomNavigationBar: const DesktopPlayerDock(),
        ) : Scaffold(
          backgroundColor: Colors.transparent,
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

        return AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.5,
              colors: [
                bgColor,
                const Color(0xFF0F0F13), // AppTheme.backgroundDark
              ],
            ),
          ),
          child: scaffold,
        );
      },
    );
  }
}
