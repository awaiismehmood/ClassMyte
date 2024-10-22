// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  BannerAd? _bannerAd;
  AppOpenAd? _appOpenAd;
    RewardedAd? _rewardedAd;
  bool _isShowingAd = false;

    RewardedAd? get reward => _rewardedAd;


// Load a Rewarded Ad
void loadRewardedAd() {
  RewardedAd.load(
    adUnitId: 'ca-app-pub-6452085379535380/1053355157', // Replace with your actual Ad Unit ID
    request: const AdRequest(),
    rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (ad) {
        print("Rewarded ad loaded");
        _rewardedAd = ad;
      },
      onAdFailedToLoad: (error) {
        print("Failed to load rewarded ad: $error");
      },
    ),
  );
}

// Show the Rewarded Ad and return a Future<bool> indicating completion
Future<bool> showRewardedAd() async {
  if (_rewardedAd != null) {
    final completer = Completer<bool>(); // Used to return the ad result

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print('Rewarded ad dismissed');
        ad.dispose();
        loadRewardedAd(); // Load a new rewarded ad for the next time
        completer.complete(false); // Ad was dismissed without earning the reward
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Failed to show rewarded ad: $error');
        ad.dispose();
        loadRewardedAd(); // Try loading a new ad after failure
        completer.complete(false); // Ad failed to show
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('User earned reward: ${reward.amount} ${reward.type}');
        completer.complete(true); // User completed the ad and earned reward
      },
    );

    _rewardedAd = null; // Ensure the ad can't be reused
    return completer.future; // Return the completion state (true or false)
  } else {
    print('Rewarded ad is not ready yet.');
    return Future.value(false); // Return false if the ad isn't ready
  }
}



  void loadBannerAd(Function onAdLoadedCallback) {
    _bannerAd = BannerAd(
          // adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      adUnitId: 'ca-app-pub-6452085379535380/3415236131',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('Banner ad loaded.');
          onAdLoadedCallback();  // Notify when ad is loaded
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  // // Method to load a banner ad
  // void loadBannerAd() {
  //   _bannerAd = BannerAd(
  //     size: AdSize.banner,
  //     // adUnitId: 'ca-app-pub-3940256099942544/6300978111',
  //     adUnitId: 'ca-app-pub-6452085379535380/3415236131',

  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (ad) {
  //         print("Banner ad loaded");
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         print("Failed to load banner ad: $error");
  //         ad.dispose();
  //       },
  //     ),
  //   );
  //   _bannerAd!.load();
  // }

  Widget displayBannerAd() {
    if (_bannerAd != null) {
      return SizedBox(
        height: 50,
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return const SizedBox(); // Return an empty widget if the ad is not loaded
    }
  }


  // Method to load an app open ad
  void loadAppOpenAd() {
    AppOpenAd.load(
      // adUnitId: 'ca-app-pub-3940256099942544/9257395921', // Test ad unit ID
      adUnitId: 'ca-app-pub-6452085379535380/3959233441',

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
    _appOpenAd?.dispose();
    _rewardedAd?.dispose();
  }
}
