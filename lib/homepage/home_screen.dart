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
          return getPage(index, context); // Fetches the appropriate page from the UI part
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, child) {
          return BottomNavigationBar(
            backgroundColor: Colors.lightBlue,
            elevation: 1,
            selectedFontSize: 17,
            selectedIconTheme: const IconThemeData(color: Colors.white, size: 25),
            selectedItemColor: Colors.white,
            currentIndex: index,
            onTap: (int index) {
              _selectedIndex.value = index; // Update value on tap
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
          );
        },
      ),
    );
  }
}
