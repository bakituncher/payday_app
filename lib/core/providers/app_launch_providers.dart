import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/repositories/local/local_app_launch_flags_repository.dart';

final appLaunchFlagsRepositoryProvider = Provider<LocalAppLaunchFlagsRepository>((ref) {
  return LocalAppLaunchFlagsRepository();
});

final hasSeenFeatureIntroProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(appLaunchFlagsRepositoryProvider);
  return repo.hasSeenFeatureIntro();
});

