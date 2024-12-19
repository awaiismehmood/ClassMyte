// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  BannerAd? _bannerAd;
  AppOpenAd? _appOpenAd;
  RewardedAd? _rewardedAd;
  ValueNotifier<bool> isAdLoaded = ValueNotifier(false);
  bool _isShowingAd = false;
  bool _isAdShowing = false; // To prevent multiple Rewarded Ads from showing simultaneously

  RewardedAd? get reward => _rewardedAd;

  // Load a Rewarded Ad
  void loadRewardedAd({VoidCallback? onAdLoaded}) {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-6452085379535380/1053355157', // Replace with your actual Ad Unit ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print("Rewarded ad loaded");
          _rewardedAd = ad;
          isAdLoaded.value = true;
          onAdLoaded?.call(); // Notify that the ad is loaded
        },
        onAdFailedToLoad: (error) {
          print("Failed to load rewarded ad: $error");
        },
      ),
    );
  }

  // Show the Rewarded Ad and return a Future<bool> indicating completion
  Future<bool> showRewardedAd() async {
    if (_isAdShowing || _rewardedAd == null) {
      print('Rewarded ad is not ready or already showing.');
      return Future.value(false);
    }

    _isAdShowing = true; // Set flag to prevent multiple ads from showing

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print('Rewarded ad dismissed');
        ad.dispose();
        loadRewardedAd(); // Load a new ad
        _isAdShowing = false;
        completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Failed to show rewarded ad: $error');
        ad.dispose();
        loadRewardedAd(); // Try loading a new ad after failure
        _isAdShowing = false;
        completer.complete(false);
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('User earned reward: ${reward.amount} ${reward.type}');
        completer.complete(true);
      },
    );

    _rewardedAd = null; // Ensure the ad can't be reused
    return completer.future;
  }

  // Enhanced Method for showing ads with timeout and user feedback
  Future<void> tryShowRewardedAd(BuildContext context) async {
    bool success = await showRewardedAd().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('Ad display timed out.');
        return false;
      },
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rewarded ad not available. Try again later.')),
      );
    }
  }

  // Load a Banner Ad
  void loadBannerAd(Function onAdLoadedCallback) {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6452085379535380/3415236131',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          onAdLoadedCallback();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    )..load();
  }

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

  // Load an App Open Ad
  void loadAppOpenAd() {
    AppOpenAd.load(
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

  // Show App Open Ad
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
        loadAppOpenAd();
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
