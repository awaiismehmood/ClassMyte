import 'package:classmyte/homepage/home_widgets.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _selectedIndex.dispose(); // Dispose ValueNotifier when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, child) {
          return getPage(index, context); // Get the page based on index
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, child) {
          return BottomNavigationBar(
            
            backgroundColor: Colors.blue.shade500, // Updated background color
            elevation: 4, // Added slight elevation for a modern effect
            selectedFontSize: 15,
            unselectedFontSize: 13,
            selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
            unselectedIconTheme: const IconThemeData(color: Colors.white70, size: 24), // Styling unselected icons
            selectedItemColor: Colors.white, // White color for selected items
            unselectedItemColor: Colors.white70, // Light white for unselected items
            currentIndex: index,
            onTap: (int newIndex) {
              _selectedIndex.value = newIndex; // Update the selected index
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.contacts),
                label: 'Contacts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'SMS',
              ),
            ],
            type: BottomNavigationBarType.fixed, // Ensures fixed behavior
          );
        },
      ),
    
    );
  }
}
