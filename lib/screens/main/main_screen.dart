import 'package:flutter/material.dart';
import 'package:mart_frontend/screens/cart/mycart.dart';
import '../../auth/login_register_screen.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';
import '../category/categories_screen.dart';
import '../order/orders_screen.dart';
import '../../profile/profile_screen.dart';
import '../theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeScreen(),
      CategoriesScreen(),
      OrdersScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // use themed background instead of transparent
      backgroundColor: context.colors.surface,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          // If Orders or Profile tab → require login
          if (index == 2 || index == 3) {
            final isLoggedIn = await ApiService().isLoggedIn();

            if (!isLoggedIn) {
              showAuthBottomSheet(context); // same as home screen
              return;
            }
          }

          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: AssetImage('lib/icons/home.png'), label: 'Home'),
    _NavItem(icon: AssetImage('lib/icons/categories.png'), label: 'Categories'),
    _NavItem(icon: AssetImage('lib/icons/orders.png'), label: 'Orders'),
    _NavItem(icon: AssetImage('lib/icons/profile.png'), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.accent, width: 1),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(.12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
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
                      color: selected ? colors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
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

                        const SizedBox(height: 2),

                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: selected ? 4 : 0,
                          height: selected ? 4 : 0,
                          decoration: BoxDecoration(
                            color: colors.accentLight,
                            shape: BoxShape.circle,
                          ),
                        ),

                        if (!selected) const SizedBox(height: 4),

                        Text(
                          _items[i].label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: selected ? colors.cardBg : colors.text2,
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
    );
  }
}

class _NavItem {
  final ImageProvider icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
