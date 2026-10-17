import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/catalog_repository.dart';

final catalogRepositoryProvider = Provider(
  (ref) => CatalogRepository(ref.watch(apiClientProvider)),
);

final catalogSearchProvider = FutureProvider.autoDispose.family(
  (ref, String search) =>
      ref.watch(catalogRepositoryProvider).products(search: search),
);

final catalogProposalsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(catalogRepositoryProvider).proposals(),
);

final producersProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(catalogRepositoryProvider).producers(),
);

final animalTypesProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(catalogRepositoryProvider).animalTypes(),
);

final catalogCategoriesProvider = FutureProvider.autoDispose.family(
  (ref, int animalTypeId) => ref
      .watch(catalogRepositoryProvider)
      .categories(animalTypeId: animalTypeId),
);
