import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the back button color to white
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22, // Make the font size a bit larger
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/pencil_white.png', // Your app logo
                  height: 100, // Adjust height as needed
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Terms and Conditions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Change color as needed
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome to ClassMyte! By using our app, you agree to the following terms and conditions:',
                        style: TextStyle(fontSize: 16,    color: Colors.black, ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '1. Misuse of the App: Users must not misuse the app by engaging in any illegal activities or violating any laws. Any form of harassment, abuse, or bullying is strictly prohibited.',
                        style: TextStyle(fontSize: 16,    color: Colors.black, ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '2. Bulk SMS Spamming: Sending unsolicited bulk messages or spam through the ClassMyte app is not allowed. Violators may face account suspension.',
                        style: TextStyle(fontSize: 16,     color: Colors.black, ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '3. Impersonation: Users must not impersonate any person or entity, or falsely state or misrepresent their affiliation with any person or entity.',
                        style: TextStyle(fontSize: 16,    color: Colors.black, ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'For more information regarding SMS regulations, please download and refer to the ',
                              style: TextStyle(fontSize: 16,    color: Colors.black, ),
                            ),
                            TextSpan(
                              text: 'PTA Bulk SMS policies',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blueAccent,
                                decoration: TextDecoration.underline,
                              ),
                               recognizer: TapGestureRecognizer()..onTap = _launchURL,
                            ),
                            const TextSpan(
                              text: ' document for more details.',
                              style: TextStyle(fontSize: 16,    color: Colors.black, ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'By using the ClassMyte app, you acknowledge that you have read, understood, and agree to these terms and conditions.',
                        style: TextStyle(fontSize: 16,     color: Colors.black, ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  // Function to launch the PTA terms URL
  void _launchURL() async {
    const url = 'https://www.pta.gov.pk/assets/media/cons_paper_spam_msgs_calls_241019.pdf'; // Replace with the actual URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

