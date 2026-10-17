import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/notification_repository.dart';

final notificationRepositoryProvider =
    Provider((ref) => NotificationRepository(ref.watch(apiClientProvider)));

final notificationsFeedProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(notificationRepositoryProvider).feed());
