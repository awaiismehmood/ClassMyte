import 'package:classmyte/Students/students.dart';
import 'package:classmyte/premium/subscription_screen.dart';
import 'package:classmyte/settings/settings.dart';
import 'package:classmyte/sms_screen/sms.dart';
import 'package:flutter/material.dart';
import 'package:classmyte/components/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:classmyte/main.dart';

Widget buildHomeScreen(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final screenHeight = mediaQuery.size.height;
  final screenWidth = mediaQuery.size.width;

  return Scaffold(
    appBar: AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/pencil_white.png', // Add your logo here
                height: screenHeight * 0.04, // Adjust height dynamically
              ),
              const SizedBox(width: 8),
              const Text(
                'ClassMyte',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22, // Make the font size a bit larger
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    ),
    body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpg'),
          fit: BoxFit.cover,
          opacity: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, 
                vertical: screenHeight * 0.06,
              ),
              crossAxisCount: 2,
              crossAxisSpacing: screenWidth * 0.04,
              mainAxisSpacing: screenHeight * 0.03,
              children: [
                _buildGridCard(
                  context,
                  'Students',
                  icon: Icons.people,
                  onPressed: () {
                    Routes.navigateTocontacts(context);
                  },
                ),
                _buildGridCard(
                  context,
                  'Classes',
                  icon: Icons.class_,
                  onPressed: () {
                    Routes.navigateToClasses(context);
                  },
                ),
                _buildGridCard(
                  context,
                  'Send SMS',
                  icon: Icons.sms,
                  onPressed: () {
                    Routes.navigateToSms(context);
                  },
                ),
                _buildGridCard(
                  context,
                  'Premium',
                  icon: Icons.workspace_premium,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.15, // Centered using dynamic padding
              vertical: screenHeight * 0.06,
            ),
            child: _buildGridCard(
              context,
              'Signout',
              icon: Icons.logout,
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
              color: Colors.red,
            ),
          ),
          SizedBox(height: screenHeight * 0.015), // Adjust spacing dynamically
        ],
      ),
    ),
  );
}

Widget _buildGridCard(BuildContext context, String title,
    {IconData? icon, VoidCallback? onPressed, Color color = Colors.blue}) {
  final mediaQuery = MediaQuery.of(context);
  final screenHeight = mediaQuery.size.height;
  final screenWidth = mediaQuery.size.width;

  return GestureDetector(
    onTap: onPressed,
    child: Card(
      elevation: 6, // Increased elevation for a more modern look
      shadowColor: Colors.black38, // Softer shadow for better contrast
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Softer corners for modern look
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.035, // Dynamically sized padding
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: screenHeight * 0.05, color: Colors.white), // Larger icons for clarity
              SizedBox(height: screenHeight * 0.01), // Dynamic spacing
              Text(
                title,
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  fontWeight: FontWeight.w600, // Bolder text for more emphasis
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget getPage(int index, BuildContext context) {
  switch (index) {
    case 0:
      return buildHomeScreen(context);
    case 1:
      return const StudentContactsScreen();
    case 2:
      return const NewMessageScreen();
    default:
      return buildHomeScreen(context);
  }
}
