// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../auth/login_register_screen.dart';
// import '../../services/api_service.dart';
// import '../home/home_screen.dart';
// import '../category/categories_screen.dart';
// import '../order/orders_screen.dart';
// import '../../profile/profile_screen.dart';
// import '../theme/app_theme.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   static void switchToHome(BuildContext context) {
//     context.findAncestorStateOfType<_MainScreenState>()?.switchToTab(0);
//   }

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;

//   void switchToTab(int index) {
//     setState(() => _currentIndex = index);
//   }

//   late final List<Widget> _screens;

//   @override
//   void initState() {
//     super.initState();
//     _screens = const [
//       HomeScreen(),
//       // CategoriesScreen(),
//       CategoryBrandScreen(),
//       OrdersScreen(),
//       ProfileScreen(),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // use themed background instead of transparent
//       backgroundColor: context.colors.surface,
//       extendBody: true,
//       body: IndexedStack(index: _currentIndex, children: _screens),
//       bottomNavigationBar: _FloatingNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) async {
//           // If Orders or Profile tab → require login
//           // if (index == 2 || index == 3) {
//           //   final isLoggedIn = await ApiService().isLoggedIn();

//           //   if (!isLoggedIn) {
//           //     showAuthBottomSheet(context); // same as home screen
//           //     return;
//           //   }
//           // }

//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }

// class _FloatingNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;

//   const _FloatingNavBar({required this.currentIndex, required this.onTap});

//   static const _items = [
//     _NavItem(icon: AssetImage('lib/icons/home.png'), label: 'home'),
//     _NavItem(icon: AssetImage('lib/icons/categories.png'), label: 'categories'),
//     _NavItem(icon: AssetImage('lib/icons/orders.png'), label: 'orders'),
//     _NavItem(icon: AssetImage('lib/icons/profile.png'), label: 'profile'),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return SafeArea(
//       minimum: const EdgeInsets.only(bottom: 10),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 30),
//         child: Container(
//           height: 60,
//           decoration: BoxDecoration(
//             color: colors.cardBg,
//             borderRadius: BorderRadius.circular(40),
//             border: Border.all(color: colors.accent, width: 1),
//             boxShadow: [
//               BoxShadow(
//                 blurRadius: 20,
//                 offset: const Offset(0, 8),
//                 color: Colors.black.withOpacity(.12),
//               ),
//             ],
//           ),
//           padding: const EdgeInsets.all(4),
//           child: Row(
//             children: List.generate(_items.length, (i) {
//               final selected = i == currentIndex;

//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () => onTap(i),
//                   behavior: HitTestBehavior.opaque,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 220),
//                     curve: Curves.easeInOut,
//                     decoration: BoxDecoration(
//                       color: selected ? colors.accent : Colors.transparent,
//                       borderRadius: BorderRadius.circular(33),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,

//                       // children: [
//                       //   Image(
//                       //     image: _items[i].icon,
//                       //     width: 22,
//                       //     height: 22,
//                       //     color: selected ? colors.cardBg : colors.text3,
//                       //   ),

//                       //   const SizedBox(height: 2),

//                       //   AnimatedContainer(
//                       //     duration: const Duration(milliseconds: 200),
//                       //     width: selected ? 4 : 0,
//                       //     height: selected ? 4 : 0,
//                       //     decoration: BoxDecoration(
//                       //       color: colors.accentLight,
//                       //       shape: BoxShape.circle,
//                       //     ),
//                       //   ),

//                       //   if (!selected) const SizedBox(height: 4),

//                       //   Text(
//                       //     _items[i].label.tr,
//                       //     style: TextStyle(
//                       //       fontSize: 10,
//                       //       fontWeight: FontWeight.w600,
//                       //       color: selected ? colors.cardBg : colors.text2,
//                       //     ),
//                       //   ),
//                       // ],
//                       children: [
//                         Image(
//                           image: _items[i].icon,
//                           width: 22,
//                           height: 22,
//                           color: selected ? colors.cardBg : colors.text3,
//                         ),

//                         const SizedBox(height: 4),

//                         AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           width: selected ? 4 : 0,
//                           height: selected ? 4 : 0,
//                           decoration: BoxDecoration(
//                             color: colors.accentLight,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _NavItem {
//   final ImageProvider icon;
//   final String label;

//   const _NavItem({required this.icon, required this.label});
// }

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../../auth/login_register_screen.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';
import '../category/categories_screen.dart';
import '../order/orders_screen.dart';
import '../../profile/profile_screen.dart';
import '../theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static void switchToHome(BuildContext context) {
    context.findAncestorStateOfType<_MainScreenState>()?.switchToTab(0);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _navVisible = true;

  void switchToTab(int index) {
    setState(() {
      _currentIndex = index;
      _navVisible = true;
    });
  }

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeScreen(),
      CategoryBrandScreen(),
      OrdersScreen(),
      ProfileScreen(),
    ];
  }

  // Reacts immediately to scroll direction — no debounce/delay.
  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    final pixels = notification.metrics.pixels;

    if (pixels <= 24) {
      if (!_navVisible) setState(() => _navVisible = true);
      return false;
    }

    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse && _navVisible) {
        setState(() => _navVisible = false);
      } else if (notification.direction == ScrollDirection.forward &&
          !_navVisible) {
        setState(() => _navVisible = true);
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: Stack(
          children: List.generate(_screens.length, (i) {
            final selected = i == _currentIndex;
            return Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                opacity: selected ? 1 : 0,
                child: IgnorePointer(ignoring: !selected, child: _screens[i]),
              ),
            );
          }),
        ),
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        visible: _navVisible,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() {
            _currentIndex = index;
            _navVisible = true;
          });
        },
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final bool visible;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.visible,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: AssetImage('lib/icons/home.png'), label: 'home'),
    _NavItem(icon: AssetImage('lib/icons/categories.png'), label: 'categories'),
    _NavItem(icon: AssetImage('lib/icons/orders.png'), label: 'orders'),
    _NavItem(icon: AssetImage('lib/icons/profile.png'), label: 'profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: IgnorePointer(
          ignoring: !visible,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 280),
            curve: visible ? Curves.easeOutCubic : Curves.easeInCubic,
            offset: visible ? Offset.zero : const Offset(0, 1.6),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              opacity: visible ? 1 : 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: colors.cardBg,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: colors.accent, width: 1),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      color: Colors.black.withOpacity(.12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: List.generate(_items.length, (i) {
                    final selected = i == currentIndex;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onTap(i),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: selected
                                ? colors.accent
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(33),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: _items[i].icon,
                                width: 22,
                                height: 22,
                                color: selected ? colors.cardBg : colors.text3,
                              ),
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: selected ? 4 : 0,
                                height: selected ? 4 : 0,
                                decoration: BoxDecoration(
                                  color: colors.accentLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final ImageProvider icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
