import 'package:classmyte/data_management/getSubscribe.dart';
import 'package:classmyte/download/download.dart';
import 'package:classmyte/download/upload.dart';
import 'package:classmyte/premium/subscription_screen.dart';
import 'package:flutter/material.dart';

class UploadDownloadScreen extends StatefulWidget {
  const UploadDownloadScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UploadDownloadScreenState createState() => _UploadDownloadScreenState();
}

class _UploadDownloadScreenState extends State<UploadDownloadScreen> {
  final SubscriptionData subscriptionData = SubscriptionData();

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
          'Data Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDownloadCard(context),
            _buildUploadCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          _buildUploadIcon(),
          const SizedBox(height: 20),
          const Text(
            'Upload',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          _buildDownloadIcon(),
          const SizedBox(height: 20),
          const Text(
            'Download',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadIcon() {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white38,
      ),
     child: IconButton(
          onPressed: () async {
            await subscriptionData.checkSubscriptionStatus();
            if (!subscriptionData.isPremiumUser.value) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            } else {
              ExcelImport().importFromExcel();
            }
          },
          icon: const Icon(
            Icons.cloud_upload_outlined,
            size: 100,
            color: Colors.blue,
          ),
        ));
    
  }

  Widget _buildDownloadIcon() {
    return Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white38,
        ),
        child: IconButton(
          onPressed: () async {
            await subscriptionData.checkSubscriptionStatus();
            if (!subscriptionData.isPremiumUser.value) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            } else {
              ExcelExport().exportToExcel();
            }
          },
          icon: const Icon(
            Icons.cloud_download_outlined,
            size: 100,
            color: Colors.blue,
          ),
        ));
  }
}
