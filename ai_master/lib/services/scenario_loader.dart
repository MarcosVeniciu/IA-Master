import 'dart:convert'; // Mantém jsonDecode
import 'package:flutter/services.dart'
    show rootBundle; // Adiciona import correto para rootBundle
import '../models/scenario.dart';

/// Classe responsável por carregar cenários de aventura a partir de arquivos JSON de assets.
///
/// Esta classe atua como uma camada de acesso a dados, lendo arquivos JSON
/// do diretório especificado em [scenariosFolderPath] e convertendo-os em
/// objetos [Scenario] válidos.
class ScenarioLoader {
  /// Caminho para o diretório contendo os arquivos JSON de cenários.
  ///
  /// Por padrão, aponta para 'assets/scenarios' dentro do projeto.
  final String scenariosFolderPath;

  /// Cria uma instância de [ScenarioLoader] com o caminho especificado.
  ///
  /// [scenariosFolderPath]: Caminho para o diretório de cenários.
  /// Se não fornecido, usa 'assets/scenarios' como padrão.
  ScenarioLoader({this.scenariosFolderPath = 'assets/scenarios'});

  /// Carrega todos os cenários válidos do diretório especificado.
  ///
  /// Retorna uma lista de [Scenario] contendo todos os cenários válidos
  /// encontrados nos arquivos JSON do diretório.
  ///
  /// Lança [ScenarioLoadException] se ocorrer um erro ao acessar o diretório.
  Future<List<Scenario>> loadScenarios() async {
    // print('Carregando cenários da pasta de assets: $scenariosFolderPath'); // Removido - usar logger
    try {
      // 1. Carregar o manifesto de assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // 2. Filtrar as chaves para encontrar os arquivos JSON na pasta de cenários
      final scenarioAssetPaths = manifestMap.keys.where(
        (String key) =>
            key.startsWith(scenariosFolderPath) && key.endsWith('.json'),
      );

      // print( // Removido - usar logger
      //   'Número de arquivos JSON encontrados nos assets: ${scenarioAssetPaths.length}',
      // );

      final scenarios = <Scenario>[];
      for (final assetPath in scenarioAssetPaths) {
        // print('Carregando asset de cenário: $assetPath'); // Removido - usar logger
        try {
          // 3. Carregar o conteúdo do arquivo JSON como string
          final jsonString = await rootBundle.loadString(assetPath);
          // 4. Analisar o conteúdo JSON
          final scenario = await _parseScenario(
            jsonString,
            assetPath,
          ); // Passa o path para logs
          if (scenario != null) {
            scenarios.add(scenario);
            // print( // Removido - usar logger
            //   'Cenário carregado com sucesso: ${scenario.title} (de $assetPath)',
            // );
          } else {
            // print('Falha ao carregar cenário do asset: $assetPath'); // Removido - usar logger
          }
        } catch (e) {
          // print( // Removido - usar logger
          //   'Erro ao carregar ou analisar o asset: $assetPath - ${e.toString()}',
          // );
          // Continua para o próximo arquivo em caso de erro em um específico
        }
      }

      // print('Total de cenários carregados: ${scenarios.length}'); // Removido - usar logger
      return scenarios;
    } on Exception catch (e) {
      // print('Erro geral ao carregar cenários dos assets: ${e.toString()}'); // Removido - usar logger
      throw ScenarioLoadException(
        'Failed to load scenarios from assets: ${e.toString()}',
      );
    }
  }

  /// Analisa uma string JSON e retorna um objeto [Scenario] se válido.
  ///
  /// [jsonContent]: String contendo o JSON do cenário.
  /// [assetPath]: Caminho do asset original (usado para logs).
  /// Retorna um [Scenario] se o JSON for válido, ou null caso contrário.
  Future<Scenario?> _parseScenario(String jsonContent, String assetPath) async {
    try {
      // print('Conteúdo do JSON do asset $assetPath: $jsonContent'); // Descomente para debug detalhado
      final jsonData = jsonDecode(jsonContent) as Map<String, dynamic>;

      if (_validateScenarioData(jsonData)) {
        return Scenario.fromJson(jsonData);
      } else {
        // print('Dados do cenário inválidos no asset: $assetPath'); // Removido - usar logger
        return null;
      }
    } catch (e) {
      // print('Erro ao analisar o JSON do asset: $assetPath - ${e.toString()}'); // Removido - usar logger
      return null;
    }
  }

  /// Valida se os dados do cenário [data] contêm as chaves obrigatórias mínimas
  /// antes de tentar a desserialização completa via [Scenario.fromJson].
  ///
  /// A validação principal e de tipos ocorre dentro de [Scenario.fromJson].
  /// Esta função serve como uma verificação preliminar rápida.
  ///
  /// [data]: Mapa contendo os dados do cenário decodificados do JSON.
  /// Retorna `true` se as chaves obrigatórias básicas estiverem presentes,
  /// `false` caso contrário.
  bool _validateScenarioData(Map<String, dynamic> data) {
    // Lista dos campos obrigatórios conforme definido no construtor de Scenario
    // (exceto imageBase64 que é opcional)
    const requiredFields = [
      'title',
      'author',
      'date',
      'genre',
      'ambiance', // Adicionado
      'origins',
      'plots',
      'scenes',
      'bankOfIdeas', // Renomeado
      'rules',
      'license',
      'credits',
    ];

    // Verifica se todas as chaves obrigatórias existem no mapa
    // Não verifica nulidade aqui, pois Scenario.fromJson fará isso.
    return requiredFields.every((field) => data.containsKey(field));
  }
}

/// Exceção lançada quando ocorre um erro ao carregar cenários.
class ScenarioLoadException implements Exception {
  final String message;
  ScenarioLoadException(this.message);

  @override
  String toString() => 'ScenarioLoadException: $message';
}
