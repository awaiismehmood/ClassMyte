import 'package:classmyte/Students/students.dart';
import 'package:classmyte/download/screen_dn.dart';
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
  final isLandscape = screenWidth > screenHeight; // Check if in landscape mode

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
                'assets/pencil_white.png',
                height: screenHeight * 0.04,
              ),
              const SizedBox(width: 8),
              const Text(
                'ClassMyte',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
        children: [
          Expanded(
            child: GridView.count(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * (isLandscape ? 0.04 : 0.035), // Adjust vertical padding for landscape
              ),
              crossAxisCount: isLandscape ? 3 : 2, // Adjust number of columns based on orientation
              crossAxisSpacing: screenWidth * 0.06,
              mainAxisSpacing: screenHeight * 0.01,
              children: [
                _buildGridCard(
                  context,
                  'Students',
                  icon: Icons.person_pin,
                  onPressed: () {
                    Routes.navigateTocontacts(context);
                  },
                ),
                _buildGridCard(
                  context,
                  'Classes',
                  icon: Icons.groups_rounded,
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
                  'Sync Data',
                  icon: Icons.sync,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const UploadDownloadScreen(),
                      ),
                    );
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
              
                      _buildGridCard(
                  context,
                  'Settings',
                  icon: Icons.settings,
                  onPressed: () {
                     Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
              color: Colors.redAccent.shade200,
            ),
          ),
          const SizedBox(height: 30), // Adjust the size as needed
        ],
      ),
    ),
  );
}

Widget _buildGridCard(BuildContext context, String title,
    {IconData? icon, VoidCallback? onPressed, Color color = Colors.blue}) {
  final mediaQuery = MediaQuery.of(context);
  final screenHeight = mediaQuery.size.height;

  return GestureDetector(
    onTap: onPressed,
    child: Card(
      elevation: 6,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
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
          vertical: screenHeight * 0.035,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: screenHeight * 0.05, color: Colors.white),
              SizedBox(height: screenHeight * 0.01),
              Text(
                title,
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  fontWeight: FontWeight.w600,
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
