import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import to handle launching of WhatsApp and Email

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  // Function to launch WhatsApp with pre-filled number
  void _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse("https://wa.me/923185444845"); // Change the number as needed
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

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
          'Contact Us',
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'We’d love to hear from you!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'For any inquiries, feedback, or support, contact us using the options below:',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              
              // WhatsApp Contact Option
              ListTile(
                leading: SizedBox(
                  width: 30,
                  height: 30,
                  child: Image.asset('assets/whatsapp.png', fit: BoxFit.contain),
                ),
                title: const Text(
                  'Contact Us via WhatsApp',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: const Text('Tap to start a chat on WhatsApp', style: TextStyle(color: Colors.black54)),
                onTap: _launchWhatsApp, // Launch WhatsApp when clicked
              ),
              const Divider(),

              // Email Contact Option
              const ListTile(
                leading: Icon(Icons.email, color: Colors.black87),
                title: Text(
                  'Email Us',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'teams.classmyte@gmail.com',
                  style: TextStyle(color: Colors.black54),
                ),
              ),

              const Divider(),
            
            ],
          ),
        ),
      ),
    );
  }
}
