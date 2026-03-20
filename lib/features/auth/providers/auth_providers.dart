import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginLoadingProvider = StateProvider<bool>((ref) => false);
final signupLoadingProvider = StateProvider<bool>((ref) => false);
final forgotPasswordLoadingProvider = StateProvider<bool>((ref) => false);
