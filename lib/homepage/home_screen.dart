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
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, child) {
          return getPage(index, context);
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, child) {
          return BottomNavigationBar(
            
            backgroundColor: Colors.blue.shade500,
            elevation: 4, 
            selectedFontSize: 15,
            unselectedFontSize: 13,
            selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
            unselectedIconTheme: const IconThemeData(color: Colors.white70, size: 24),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            currentIndex: index,
            onTap: (int newIndex) {
              _selectedIndex.value = newIndex;
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_pin),
                label: 'Contacts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sms),
                label: 'SMS',
              ),
            ],
            type: BottomNavigationBarType.fixed,
          );
        },
      ),
    
    );
  }
}
