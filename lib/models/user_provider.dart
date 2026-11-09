import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/services/user_service.dart';

/// Provedor de estado do usuário (pontos e status de bloqueio).
class UserProvider extends ChangeNotifier {
  int _pontos = 100;
  String? _bloqueadoAte;
  bool _isLoading = false;
  bool _fetching = false;
  String? _erro;

  int get pontos => _pontos;
  String? get bloqueadoAte => _bloqueadoAte;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  bool get estaBloqueado {
    if (_bloqueadoAte == null) return false;
    final dt = DateTime.tryParse(_bloqueadoAte!);
    return dt != null && dt.isAfter(DateTime.now());
  }

  /// Busca o status atualizado do usuário.
  /// Ignora chamadas concorrentes (race condition guard).
  Future<void> fetchUserStatus() async {
    if (_fetching) return;
    _fetching = true;
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      final userId = await UserService.getUserId();
      final data = await ApiService.get('/api/usuarios/status', userId: userId);
      _pontos = (data['pontos'] as int?) ?? 100;
      _bloqueadoAte = data['bloqueado_ate'] as String?;
    } on ApiException catch (e) {
      _erro = e.message;
    } catch (e) {
      _erro = 'Erro inesperado: $e';
    } finally {
      _isLoading = false;
      _fetching = false;
      notifyListeners();
    }
  }
}
