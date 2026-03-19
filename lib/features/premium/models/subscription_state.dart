class SubscriptionState {
  final bool isPremiumUser;
  final String subscribedPackage;
  final DateTime? expiryDate;
  final bool isLoading;

  SubscriptionState({
    this.isPremiumUser = false,
    this.subscribedPackage = 'Free',
    this.expiryDate,
    this.isLoading = true,
  });

  SubscriptionState copyWith({
    bool? isPremiumUser,
    String? subscribedPackage,
    DateTime? expiryDate,
    bool? isLoading,
  }) {
    return SubscriptionState(
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      subscribedPackage: subscribedPackage ?? this.subscribedPackage,
      expiryDate: expiryDate ?? this.expiryDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
