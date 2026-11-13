import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_client.dart';
import '../../auth/data/auth_models.dart';
import '../../auth/presentation/auth_controller.dart';

/// The signed-in person's own profile: details, photo and password.
class ProfileRepository {
  ProfileRepository(this._client);

  final ApiClient _client;

  DukaUser _user(Response<dynamic> response) => DukaUser.fromJson(
    (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
  );

  Future<DukaUser> update({String? name, String? phone, String? email}) async =>
      _user(
        await _client.guard(
          () => _client.dio.patch(
            '/me/profile',
            data: {'name': ?name, 'phone': ?phone, 'email': ?email},
          ),
        ),
      );

  /// Works on phones and the web alike (bytes, not a file path).
  Future<DukaUser> uploadAvatar(XFile photo) async {
    final form = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(
        await photo.readAsBytes(),
        filename: photo.name,
      ),
    });
    return _user(
      await _client.guard(() => _client.dio.post('/me/avatar', data: form)),
    );
  }

  Future<DukaUser> removeAvatar() async =>
      _user(await _client.guard(() => _client.dio.delete('/me/avatar')));

  /// Deletes the signed-in customer's account (password, or "DELETE" for
  /// Google-only accounts). The server signs out every device.
  Future<void> deleteAccount({String? password, String? confirm}) async {
    await _client.guard(
      () => _client.dio.delete(
        '/me',
        data: {'password': ?password, 'confirm': ?confirm},
      ),
    );
  }

  Future<DukaUser> changePassword({
    String? current,
    required String password,
    required String confirmation,
  }) async => _user(
    await _client.guard(
      () => _client.dio.put(
        '/me/password',
        data: {
          'current_password': ?current,
          'password': password,
          'password_confirmation': confirmation,
        },
      ),
    ),
  );
}

final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(ref.watch(apiClientProvider)),
);
