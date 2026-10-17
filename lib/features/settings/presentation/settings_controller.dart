import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_models.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/kyc_document_models.dart';
import '../data/kyc_document_repository.dart';
import '../data/merchant_settings_repository.dart';
import '../data/staff_repository.dart';

final merchantSettingsRepositoryProvider =
    Provider((ref) => MerchantSettingsRepository(ref.watch(apiClientProvider)));

final staffRepositoryProvider =
    Provider((ref) => StaffRepository(ref.watch(apiClientProvider)));

final kycDocumentRepositoryProvider =
    Provider((ref) => KycDocumentRepository(ref.watch(apiClientProvider)));

final merchantProfileProvider = FutureProvider.autoDispose<DukaMerchant>(
  (ref) => ref.watch(merchantSettingsRepositoryProvider).get(),
);

final staffListProvider = FutureProvider.autoDispose<List<DukaUser>>(
  (ref) => ref.watch(staffRepositoryProvider).list(),
);

final kycDocumentListProvider = FutureProvider.autoDispose<List<KycDocument>>(
  (ref) => ref.watch(kycDocumentRepositoryProvider).list(),
);
