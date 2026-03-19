import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginLoadingProvider = StateProvider<bool>((ref) => false);
final loginObscureProvider = StateProvider<bool>((ref) => true);

final signupLoadingProvider = StateProvider<bool>((ref) => false);
final signupObscureProvider = StateProvider<bool>((ref) => true);

final forgotPasswordLoadingProvider = StateProvider<bool>((ref) => false);
