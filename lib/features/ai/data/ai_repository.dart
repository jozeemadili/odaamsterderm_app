import '../../../core/api/api_client.dart';
import '../../market/data/market_models.dart';
import 'ai_models.dart';

/// The AI search and order assistant. The API key stays on the server.
class AiRepository {
  AiRepository(this._client);

  final ApiClient _client;

  Future<AiConfig> config() async {
    final r = await _client.guard(() => _client.dio.get('/market/ai/config'));
    return AiConfig.fromJson(r.data as Map<String, dynamic>);
  }

  Future<AiSearchResult> search(String query, {MarketLocation? from}) async {
    final r = await _client.guard(
      () => _client.dio.post(
        '/market/ai/search',
        data: {'query': query, if (from != null) ...from.toQuery()},
      ),
    );
    return AiSearchResult.fromJson(r.data as Map<String, dynamic>);
  }

  /// One assistant turn; [messages] ends with the customer's message.
  Future<AiOrderReply> order(
    List<AiChatMessage> messages, {
    MarketLocation? from,
  }) async {
    final r = await _client.guard(
      () => _client.dio.post(
        '/customer/ai/order',
        data: {
          'messages': [
            for (final m in messages)
              if (m.role != 'notice') m.toJson(),
          ],
          if (from != null) ...from.toQuery(),
        },
      ),
    );
    return AiOrderReply.fromJson(r.data as Map<String, dynamic>);
  }
}
