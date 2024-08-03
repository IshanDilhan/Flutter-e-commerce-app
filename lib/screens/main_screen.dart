import 'package:flutter/material.dart';
import 'package:myapp/screens/Admin/add_item.dart';
import 'package:myapp/screens/Admin/carview.dart';
import 'package:myapp/screens/CarPages/favourite_page.dart';
import 'package:myapp/screens/CarPages/home_page.dart';
import 'package:myapp/screens/CarPages/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(), // Pass parameters later
    const FavoriteScreen(),
    const AddItemPage(),
    const ViewCarsPage(),
    // const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('RideTime Car Sale'),
      // ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(
            255, 23, 23, 23), // Color for the selected item
        unselectedItemColor:
            const Color.fromARGB(255, 92, 86, 86), // Color for unselected items
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outlined), label: "Favorite"),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle,
              size: 30,
            ),
            label: "addItem",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
        ],
      ),
    );
  }
}



// Placeholder pages

