import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  runApp(const PopcornApp());
}

class PopcornApp extends StatelessWidget {
  const PopcornApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PopCorn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.yellow,
        colorScheme: ColorScheme.dark(
          primary: Colors.yellow,
          secondary: Colors.amber,
          background: Colors.black,
          surface: const Color(0xFF121212),
        ),
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.yellow),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF121212),
          selectedItemColor: Colors.yellow,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const DiscoverPage(),
    const FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
      ),
    );
  }
}

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Discover', style: TextStyle(color: Colors.yellow)),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Discover Page Content', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Favorites', style: TextStyle(color: Colors.yellow)),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Favorites Page Content', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
