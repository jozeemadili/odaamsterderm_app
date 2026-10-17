import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/report_repository.dart';

final reportRepositoryProvider =
    Provider((ref) => ReportRepository(ref.watch(apiClientProvider)));

final todaySalesReportProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(reportRepositoryProvider).todaySales());

final productPerformanceReportProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(reportRepositoryProvider).productPerformance());
