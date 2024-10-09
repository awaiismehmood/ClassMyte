// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
   AppOpenAd? _appOpenAd;
    bool _isShowingAd = false;

  // Method to load a banner ad
  void loadBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
        adUnitId: 'ca-app-pub-3940256099942544/6300978111',
        // adUnitId: 'ca-app-pub-6452085379535380/3415236131',

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
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          loadInterstitialAd(); // Load a new ad for the next time
      
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          print('Interstitial ad failed to show: $error');
        },
      );

      _interstitialAd!.show();
    } else {
      print('Interstitial ad is not ready yet.');
    }
  }

  // Method to load an app open ad
  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/9257395921', // Test ad unit ID
        // adUnitId: 'ca-app-pub-6452085379535380/3959233441',

      
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          print("App open ad loaded");
        },
        onAdFailedToLoad: (error) {
          print("Failed to load app open ad: $error");
        },
      ),
      
    );
  }

  void showAppOpenAd() {
    if (_appOpenAd == null || _isShowingAd) {
      print('App Open Ad is not ready or already showing.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('App Open Ad showed.');
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        print('App Open Ad dismissed.');
        ad.dispose();
        loadAppOpenAd(); // Load a new ad after dismissing the current one
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        print('Failed to show App Open Ad: $error');
        ad.dispose();
        loadAppOpenAd();
      },
    );

    _appOpenAd!.show();
    _appOpenAd = null; // Set to null to ensure no reuse of the same ad
  }

  // Dispose of ads to prevent memory leaks
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _appOpenAd?.dispose();
    // _nativeAd?.dispose();
  }
}


