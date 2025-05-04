import 'package:ai_master/controllers/main_screen_controller.dart';
import 'package:ai_master/features/main_screen/view/main_screen_view_abstract.dart';
import 'package:ai_master/features/main_screen/view/material_main_screen_view.dart';
// import 'package:ai_master/features/main_screen/view/cupertino_main_screen_view.dart'; // Para uso futuro
// import 'dart:io' show Platform; // Para uso futuro

/// Fábrica responsável por criar a instância correta da View da Tela Principal
/// (`MainScreenView`) com base na plataforma ou configuração.
class PlatformViewFactory {
  /// Construtor privado para evitar instanciação, já que usaremos um método estático.
  PlatformViewFactory._();

  /// Cria e retorna a instância apropriada de [MainScreenView].
  ///
  /// Atualmente, esta função sempre retorna uma [MaterialMainScreenView]
  /// para simplificar os testes iniciais, especialmente em ambientes web.
  ///
  /// // TODO: Implementar lógica de seleção de plataforma (Android/iOS/Web/Configuração).
  /// A lógica real baseada em `Platform.isAndroid`/`isIOS` ou configuração do usuário
  /// deve ser adicionada posteriormente para retornar `CupertinoMainScreenView` quando apropriado.
  ///
  /// Parâmetros:
  ///   - [controller]: O [MainScreenController] a ser associado à view criada.
  ///
  /// Retorna:
  ///   Uma instância de [MainScreenViewAbstract] (atualmente sempre [MaterialMainScreenView]).
  static MainScreenViewAbstract createMainScreenView(
    // Remove o parâmetro 'controller', pois a view o obterá do Provider.
  ) {
    // Lógica futura:
    // if (Platform.isIOS) {
    //   // A view Cupertino também precisará ser ajustada para obter o controller do Provider.
    //   return CupertinoMainScreenView();
    // }
    // Por enquanto, sempre retorna Material:
    // Remove a passagem explícita do controller.
    return MaterialMainScreenView();
  }
}
