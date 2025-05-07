import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_master/features/splash_screen/providers/splash_providers.dart';
import 'package:ai_master/features/main_screen/view/material_main_screen_view.dart'; // Import para a tela principal

/// Tela de splash exibida durante a inicialização do aplicativo.
///
/// Esta tela é responsável por:
/// 1. Exibir uma imagem de fundo e um indicador de progresso.
/// 2. Disparar o carregamento de dados iniciais (cenários e aventuras).
/// 3. Navegar para a tela principal após o carregamento bem-sucedido.
/// 4. Exibir mensagens de erro em caso de falha no carregamento.
class SplashScreen extends ConsumerWidget {
  /// Construtor padrão para SplashScreen.
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Observa o provider appDataReadyProvider para reagir às mudanças de estado
    /// (carregando, dados prontos, erro).
    ref
        .watch(appDataReadyProvider)
        .when(
          data: (_) {
            /// Callback para quando os dados são carregados com sucesso.
            /// Navega para a tela principal após um pequeno atraso.
            // Atraso mínimo para exibir a splash screen, mesmo que os dados carreguem rápido.
            Future.delayed(const Duration(seconds: 10), () {
              // Alterado para 3 segundos
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const MaterialMainScreenView(),
                  ),
                );
              }
            });
            // Durante o delay, continua mostrando a UI de carregamento.
            // O return dentro do 'data' é o que será construído enquanto o Future.delayed não completou
            // ou se a navegação ainda não ocorreu. Para evitar um flash de tela vazia ou
            // um erro de "widget build method returned null", retornamos a UI de loading.
            // No entanto, como a navegação é com pushReplacement, a SplashScreen será removida
            // da árvore de widgets, então o que é retornado aqui é menos crítico após a navegação.
            // Mas é boa prática retornar um widget válido.
          },
          loading: () {
            /// Callback para o estado de carregamento.
            /// Não é necessário retornar nada aqui explicitamente se o build principal
            /// já retorna _buildLoadingUI por padrão antes do .when resolver.
            /// No entanto, para clareza, podemos deixar o fluxo explícito.
            /// O widget build abaixo do .when() será o que é exibido.
          },
          error: (error, stackTrace) {
            /// Callback para quando ocorre um erro durante o carregamento.
            /// Não é necessário retornar nada aqui explicitamente se o build principal
            /// já retorna _buildErrorUI por padrão antes do .when resolver.
          },
        );

    // Determina qual UI exibir com base no estado do provider
    final asyncValue = ref.watch(appDataReadyProvider);
    if (asyncValue.isLoading) {
      return _buildLoadingUI(context);
    } else if (asyncValue.hasError) {
      return _buildErrorUI(context, asyncValue.error!, ref);
    } else {
      // Se chegou em 'data' e o Future.delayed está em progresso, continua mostrando loading.
      // Se a navegação já ocorreu, este widget não estará mais na árvore.
      return _buildLoadingUI(context);
    }
  }

  /// Constrói a interface de usuário para o estado de carregamento.
  Widget _buildLoadingUI(BuildContext context) {
    /// Retorna a UI de carregamento com imagem de fundo e indicador de progresso.
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/images/splash_screen.jpeg', // Caminho da imagem de splash
            fit: BoxFit.cover, // Garante que a imagem cubra toda a tela
          ),
          // Camada para escurecer um pouco a imagem e melhorar o contraste do texto/indicador
          Container(
            color: Colors.black.withOpacity(
              0.5,
            ), // Ajuste a opacidade conforme necessário
          ),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  'Carregando dados...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    shadows: <Shadow>[
                      // Adiciona uma leve sombra para melhor legibilidade
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(150, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a interface de usuário para o estado de erro.
  Widget _buildErrorUI(BuildContext context, Object error, WidgetRef ref) {
    /// Retorna a UI de erro com mensagem e botão para tentar novamente.
    return Scaffold(
      body: Container(
        color: Colors.red[900], // Cor de fundo para erro
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.error_outline, color: Colors.white, size: 60),
                const SizedBox(height: 20),
                Text(
                  'Erro ao carregar os dados:\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    /// Invalida o provider para tentar o carregamento novamente.
                    ref.invalidate(appDataReadyProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red[900],
                  ),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
