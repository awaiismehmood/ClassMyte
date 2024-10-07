// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  // Method to load a banner ad
  void loadBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
        adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print("Banner ad loaded");
        },
        onAdFailedToLoad: (ad, error) {
          print("Failed to load banner ad: $error");
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  // Method to display the banner ad
  Widget displayBannerAd() {
    if (_bannerAd != null) {
      return SizedBox(
        height: 50,
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return const SizedBox();
    }
  }

  // Method to load an interstitial ad
  void loadInterstitialAd() {
    InterstitialAd.load(
       adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ad unit ID
      // adUnitId: 'ca-app-pub-6452085379535380/6875134840', // Real ad unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print("Failed to load interstitial ad: $error");
        },
      ),
    );
  }

  // Method to show the interstitial ad
  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null; // Reset after showing
    }
  }

  // Dispose of banner ads to prevent memory leaks
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}


//  void _loadInterstitialAd() {
//     InterstitialAd.load(
//       adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ad unit ID
//       // adUnitId: 'ca-app-pub-6452085379535380/6875134840', // Real ad unit ID
//       request: const AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (InterstitialAd ad) {
//           _interstitialAd = ad;
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           print('Interstitial ad failed to load: $error');
//         },
//       ),
//     );
//   }

//   void _showInterstitialAd(Function onAdShowComplete) {
//     if (_interstitialAd != null) {
//       _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
//         onAdDismissedFullScreenContent: (InterstitialAd ad) {
//           ad.dispose();
//           _loadInterstitialAd(); // Load a new ad for the next time
//           onAdShowComplete();
//         },
//         onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
//           ad.dispose();
//           print('Interstitial ad failed to show: $error');
//           onAdShowComplete(); // Proceed even if ad fails to show
//         },
//       );

//       _interstitialAd!.show();
//     } else {
//       print('Interstitial ad is not ready yet.');
//       onAdShowComplete(); // Proceed if ad is not ready
//     }
//   }
