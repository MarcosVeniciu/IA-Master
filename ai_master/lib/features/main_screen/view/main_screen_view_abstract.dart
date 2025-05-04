import 'package:flutter/widgets.dart';

// Comentário movido para cima da classe
// /// Importa o pacote de widgets do Flutter, necessário para a classe `Widget`.

/// Importa o controlador da tela principal.
/// O caminho relativo é usado para acessar o controller a partir do diretório view.
import '../../../controllers/main_screen_controller.dart';

/// Define o contrato para as Views da Tela Principal, que devem ser StatefulWidgets.
///
/// Esta classe abstrata estabelece a estrutura básica que todas as implementações
/// de View da tela principal (como Material ou Cupertino) devem seguir,
/// garantindo que sejam `StatefulWidget`s e tenham acesso ao [MainScreenController].
/// A lógica de construção da UI (`build`) será implementada na classe `State` associada.
///
/// Importa o pacote de widgets do Flutter, necessário para a classe `Widget`.
abstract class MainScreenViewAbstract extends StatefulWidget {
  // Remove o campo 'controller'. A responsabilidade de obter o controller
  // passa a ser da classe State concreta, geralmente via Provider.

  /// Cria uma instância de [MainScreenViewAbstract].
  ///
  /// O construtor agora só recebe a chave opcional.
  ///
  /// Parâmetros:
  ///   [key]: Chave opcional para o widget.
  const MainScreenViewAbstract({
    super.key, // Usa super parâmetro para a chave
  }); // Chama o construtor do StatefulWidget implicitamente

  // O método buildUI() é removido daqui. A lógica de construção
  // pertencerá à classe State concreta.
  // As classes concretas deverão implementar createState().

  // /// Constrói a interface do usuário (UI) para a tela principal.
  // ///
  // /// As classes concretas que herdam de [MainScreenViewAbstract] devem
  // /// sobrescrever este método para fornecer a implementação específica da UI
  // /// (por exemplo, usando widgets Material ou Cupertino). O widget retornado
  // /// representará toda a árvore de widgets para a tela principal.
  // ///
  // /// Retorna:
  // ///   Um [Widget] que representa a UI construída para a tela principal.
  // Widget buildUI();
}
