import 'package:ai_master/models/adventure.dart';
import 'package:ai_master/models/scenario.dart'; // Ainda pode ser útil para tipos internos se ScenarioData não for usado em todos os lugares
import 'package:ai_master/models/scenario_data.dart'; // Importa a nova classe
import 'package:ai_master/repositories/adventure_repository.dart';
import 'package:ai_master/services/database_helper.dart';
import 'package:ai_master/services/scenario_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para carregar a lista de cenários com imagens pré-decodificadas.
///
/// Dispara a carga dos cenários a partir dos arquivos JSON locais e decodifica
/// as imagens associadas em isolates para otimizar a performance.
final scenariosLoadProvider = FutureProvider<List<ScenarioData>>((ref) async {
  /// Logica para carregar cenários e suas imagens decodificadas.
  /// Retorna uma lista de objetos ScenarioData.
  final scenarioLoader = ScenarioLoader();
  return scenarioLoader.loadScenarios();
});

/// Provider para carregar a lista de aventuras salvas.
///
/// Primeiro garante a inicialização do banco de dados e depois busca
/// todas as aventuras armazenadas.
final adventuresLoadProvider = FutureProvider<List<Adventure>>((ref) async {
  /// Logica para carregar aventuras do banco de dados.
  /// Retorna uma lista de objetos Adventure.
  // Garante que o banco de dados esteja inicializado
  await DatabaseHelper.instance.database;
  // O construtor de AdventureRepository usa DatabaseHelper.instance por padrão se nenhum dbHelper for fornecido.
  final adventureRepository = AdventureRepository();
  return adventureRepository.getAllAdventures();
});

/// Provider que indica se todos os dados iniciais do aplicativo foram carregados.
///
/// Este provider depende do [scenariosLoadProvider] e [adventuresLoadProvider].
/// Ele completa quando ambos os providers de carregamento de dados são resolvidos
/// com sucesso. Pode ser usado para controlar a transição da splash screen
/// para a tela principal do aplicativo.
///
/// Retorna um booleano `true` quando todos os dados estão prontos,
/// ou propaga um erro se qualquer um dos carregamentos falhar.
final appDataReadyProvider = FutureProvider<bool>((ref) async {
  /// Observa os providers de carregamento de cenários e aventuras.
  /// Retorna true se ambos carregarem com sucesso, caso contrário, propaga o erro.
  await ref.watch(scenariosLoadProvider.future);
  await ref.watch(adventuresLoadProvider.future);
  return true; // Ambos carregaram com sucesso
});
