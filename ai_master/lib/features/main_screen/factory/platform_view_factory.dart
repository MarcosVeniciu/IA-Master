import 'package:ai_master/controllers/main_screen_controller.dart';
import 'package:flutter/material.dart'; // Import Widget
// import 'package:ai_master/features/main_screen/view/main_screen_view_abstract.dart'; // Removido
import 'package:ai_master/features/main_screen/view/material_main_screen_view.dart';
// import 'package:ai_master/features/main_screen/view/cupertino_main_screen_view.dart'; // Para uso futuro
// import 'dart:io' show Platform; // Para uso futuro

/// Fábrica responsável por criar a instância correta da View da Tela Principal
/// com base na plataforma ou configuração.
class PlatformViewFactory {
  /// Construtor privado para evitar instanciação, já que usaremos um método estático.
  PlatformViewFactory._();

  /// Cria e retorna a instância apropriada da View da Tela Principal como um [Widget].
  ///
  /// Atualmente, esta função sempre retorna uma [MaterialMainScreenView].
  ///
  /// // TODO: Implementar lógica de seleção de plataforma (Android/iOS/Web/Configuração).
  /// A lógica real baseada em `Platform.isAndroid`/`isIOS` ou configuração do usuário
  /// deve ser adicionada posteriormente para retornar `CupertinoMainScreenView` quando apropriado.
  ///
  /// Retorna:
  ///   Um [Widget] representando a tela principal (atualmente sempre [MaterialMainScreenView]).
  static Widget createMainScreenView(
    // Retorna Widget
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
