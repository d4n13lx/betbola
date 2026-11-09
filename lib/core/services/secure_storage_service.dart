import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Serviço para armazenamento seguro de identidade do usuário.
/// Utiliza Keychain (iOS) e Keystore (Android).
class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _userIdKey = 'user_id';

  /// Obtém o ID do usuário ou gera um novo se não existir.
  static Future<String> getUserId() async {
    String? userId = await _storage.read(key: _userIdKey);
    if (userId == null) {
      userId = const Uuid().v4();
      await _storage.write(key: _userIdKey, value: userId);
    }
    return userId;
  }
}
