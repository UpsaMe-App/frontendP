import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'create_post_screen.dart';
import 'profile_screen.dart';
import '../services/app_state.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    CreatePostScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Escuchar cambios del tab activo desde AppState
    AppState.instance.activeTabIndex.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    AppState.instance.activeTabIndex.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    setState(() => _index = AppState.instance.activeTabIndex.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          AppState.instance.activeTabIndex.value = i;
          setState(() => _index = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Publicar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
