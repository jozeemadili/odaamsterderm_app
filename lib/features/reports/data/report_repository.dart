import '../../../core/api/api_client.dart';
import 'report_models.dart';

class ReportRepository {
  ReportRepository(this._client);

  final ApiClient _client;

  Future<TodaySalesReport> todaySales() async {
    final response =
        await _client.guard(() => _client.dio.get('/reports/sales/today'));
    return TodaySalesReport.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProductPerformanceReport> productPerformance() async {
    final response = await _client
        .guard(() => _client.dio.get('/reports/product-performance'));
    return ProductPerformanceReport.fromJson(
        response.data as Map<String, dynamic>);
  }
}
