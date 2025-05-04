import 'package:flutter/material.dart';

/// Um widget que representa o menu lateral (Drawer) padrão do aplicativo.
///
/// Contém links para diferentes seções como Assinatura, Instruções e Configurações.
class AppDrawer extends StatelessWidget {
  /// Cria uma instância de [AppDrawer].
  const AppDrawer({super.key}); // Usa super parâmetro

  @override
  Widget build(BuildContext context) {
    return Drawer(
      /// Um ListView garante que o conteúdo do Drawer seja rolável se necessário.
      child: ListView(
        // Importante: Remova qualquer padding do ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          /// Um cabeçalho opcional para o Drawer. Pode ser personalizado.
          const DrawerHeader(
            decoration: BoxDecoration(
              // TODO: Considerar usar uma cor ou imagem de fundo mais temática
              color: Colors.blue, // Cor placeholder
            ),
            child: Text(
              'IA Master Menu', // Título placeholder
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          /// Item de menu para a tela de Assinatura.
          ListTile(
            leading: const Icon(Icons.payment), // Ícone para Assinatura
            title: const Text('Assinatura'),
            onTap: () {
              // Fecha o drawer antes de navegar
              Navigator.pop(context);
              // TODO: Implementar navegação real para a tela de Assinatura
              // Substituir '/subscription' pela rota correta definida no app.
              Navigator.pushNamed(context, '/subscription');
              // print('Navegar para Assinatura'); // Removido - Placeholder
            },
          ),

          /// Item de menu para a tela de Instruções.
          ListTile(
            leading: const Icon(Icons.info_outline), // Ícone para Instruções
            title: const Text('Instruções'),
            onTap: () {
              // Fecha o drawer antes de navegar
              Navigator.pop(context);
              // TODO: Implementar navegação real para a tela de Instruções
              // Substituir '/instructions' pela rota correta definida no app.
              Navigator.pushNamed(context, '/instructions');
              // print('Navegar para Instruções'); // Removido - Placeholder
            },
          ),

          /// Item de menu para a tela de Configurações.
          ListTile(
            leading: const Icon(Icons.settings), // Ícone para Configurações
            title: const Text('Configurações'),
            onTap: () {
              // Fecha o drawer antes de navegar
              Navigator.pop(context);
              // TODO: Implementar navegação real para a tela de Configurações
              // Substituir '/settings' pela rota correta definida no app.
              Navigator.pushNamed(context, '/settings');
              // print('Navegar para Configurações'); // Removido - Placeholder
            },
          ),
        ],
      ),
    );
  }
}
