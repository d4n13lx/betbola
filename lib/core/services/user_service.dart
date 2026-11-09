import 'secure_storage_service.dart';

/// Fachada de compatibilidade. Mantém a API antiga, mas usa
/// armazenamento criptografado por baixo.
class UserService {
  UserService._();

  /// Retorna o ID único do usuário, persistido de forma segura.
  static Future<String> getUserId() => SecureStorageService.getUserId();
}
