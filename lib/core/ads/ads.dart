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
  void loadRewardedAd({FutureOr<void> Function()? onAdLoaded}) {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-1060843075895153/4811101523', 
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print("Rewarded ad loaded");
          _rewardedAd = ad;
          isAdLoaded.value = true;
          onAdLoaded?.call(); // Notify that the ad is loaded
        },
        onAdFailedToLoad: (error) {
          print("Failed to load rewarded ad (Code ${error.code}): ${error.message}");
          isAdLoaded.value = false;
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

  bool isBannerLoaded = false;

  // Load a Banner Ad
  void loadBannerAd(Function onAdLoadedCallback) {
    if (isBannerLoaded) return;
    
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-1060843075895153/1140150525',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          isBannerLoaded = true;
          onAdLoadedCallback();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          isBannerLoaded = false;
        },
      ),
    )..load();
  }

  Widget displayBannerAd() {
    if (isBannerLoaded && _bannerAd != null) {
      return Container(
        color: Colors.transparent,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return const SizedBox(height: 50); // Reserved space to prevent UI jumping
    }
  }

  // Load an App Open Ad
  void loadAppOpenAd() {
    AppOpenAd.load(
      // Updated to match your publisher ID. Please create this unit in AdMob.
      adUnitId: 'ca-app-pub-1060843075895153/YOUR_APP_OPEN_AD_ID',
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          print("App open ad loaded");
        },
        onAdFailedToLoad: (error) {
          print("Failed to load app open ad (Code ${error.code}): ${error.message}");
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

