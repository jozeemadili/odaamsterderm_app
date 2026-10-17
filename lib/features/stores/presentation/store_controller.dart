import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/store_repository.dart';

final storeRepositoryProvider =
    Provider((ref) => StoreRepository(ref.watch(apiClientProvider)));

final storesProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(storeRepositoryProvider).list());

final storeDetailProvider = FutureProvider.autoDispose
    .family((ref, int id) => ref.watch(storeRepositoryProvider).get(id));
