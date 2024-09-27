
import 'package:classmyte/components/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../contacts_screen/contacts.dart'; // Import the Contacts screen
import '../sms_screen/sms.dart'; // Import the SMS screen
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightBlue,
        elevation: 1,
        selectedFontSize: 17,
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 25),
        selectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
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
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return const StudentContactsScreen();
      case 2:
        return const NewMessageScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(
                  0), // Optional: Add border radius for rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Shadow color
                  spreadRadius: 1, // Spread radius
                  blurRadius: 3, // Blur radius
                  offset: const Offset(0, 3), // Offset in x and y directions
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/l.png',
                height: 140,
              ),
            ),
          ),
          const SizedBox(
              height: 40), // Add space between the image and the first card
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: _buildCard(
              context,
              'Students',
              onPressed: () {
                Routes.navigateTocontacts(context);
              },
            ),
          ),
          const SizedBox(
              height: 12), // Add space between the first and second card
              Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildCard(
              context,
              'Classes',
              onPressed: () {
                Routes.navigateToClasses(context);
              },
            ),
          ),
          const SizedBox(
              height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildCard(
              context,
              'Send SMS',
              onPressed: () {
                Routes.navigateToSms(context);
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildCard(
              context,
              'Signout',
              onPressed: () {
                FirebaseAuth.instance.signOut();
                // Navigate to a screen indicating the user has been signed out
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title,
      {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width * 0.2,
          decoration: BoxDecoration(
            color: title == 'Signout'
                ? Colors.red // Change color for signout card
                : Colors.blue, // Default color for other cards
            borderRadius: BorderRadius.circular(15.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
