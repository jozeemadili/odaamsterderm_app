import '../../../core/api/api_client.dart';
import 'dashboard_models.dart';

class DashboardRepository {
  DashboardRepository(this._client);

  final ApiClient _client;

  Future<DashboardSummary> fetch({
    DashboardPeriod period = DashboardPeriod.month,
  }) async {
    final response = await _client.guard(
      () => _client.dio.get(
        '/dashboard',
        queryParameters: {'period': period.apiValue},
      ),
    );
    return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
  }
}
