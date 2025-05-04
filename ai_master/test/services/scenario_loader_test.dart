import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_master/models/scenario.dart'; // Ajuste o caminho se necessário
import 'package:ai_master/services/scenario_loader.dart'; // Ajuste o caminho se necessário
import 'package:path/path.dart' as p; // Para manipulação de caminhos

void main() {
  // Diretório que contém o JSON de teste existente
  // Assume que os testes são executados da raiz do projeto 'ai_master'
  const String existingTestDataDir = 'test/models';
  const String existingJsonFileName = 'scenario_test_data.json';

  late Directory tempEmptyDir;
  late Directory tempMixedDir;
  late String validJsonPathInMixedDir;
  late String nonJsonPathInMixedDir;

  setUpAll(() async {
    // Cria diretório temporário vazio
    tempEmptyDir = await Directory.systemTemp.createTemp('empty_scenario_dir_');

    // Cria diretório temporário com JSON válido e arquivo TXT
    tempMixedDir = await Directory.systemTemp.createTemp('mixed_scenario_dir_');
    validJsonPathInMixedDir = p.join(tempMixedDir.path, existingJsonFileName);
    nonJsonPathInMixedDir = p.join(tempMixedDir.path, 'some_text_file.txt');

    // Copia o JSON válido para o diretório misto
    final sourceJsonFile = File(
      p.join(existingTestDataDir, existingJsonFileName),
    );
    if (await sourceJsonFile.exists()) {
      await sourceJsonFile.copy(validJsonPathInMixedDir);
    } else {
      // Se o arquivo de origem não existir, cria um placeholder para evitar falhas
      // mas os testes que dependem dele podem não ser precisos.
      // Lança um erro explícito se o arquivo de dados essencial não for encontrado.
      // Isso evita testes falsos positivos que poderiam ocorrer com dados vazios.
      throw StateError(
        'Erro Crítico na Configuração do Teste: Arquivo JSON de dados de teste necessário não encontrado em $existingTestDataDir. Verifique o caminho e a existência do arquivo.',
      );
    }
    // Cria o arquivo TXT
    await File(
      nonJsonPathInMixedDir,
    ).writeAsString('Este é um arquivo de texto.');
  });

  tearDownAll(() async {
    // Remove os diretórios temporários
    if (await tempEmptyDir.exists()) {
      await tempEmptyDir.delete(recursive: true);
    }
    if (await tempMixedDir.exists()) {
      await tempMixedDir.delete(recursive: true);
    }
  });

  group('ScenarioLoader Tests', () {
    test(
      'loadScenarios should load valid scenario from existing directory',
      () async {
        // Aponta o loader para o diretório com o JSON de teste existente
        final loader = ScenarioLoader(scenariosFolderPath: existingTestDataDir);
        final scenarios = await loader.loadScenarios();

        expect(scenarios, isA<List<Scenario>>());
        // Verifica se pelo menos um cenário foi carregado (o arquivo de teste)
        expect(scenarios, isNotEmpty);
        // Verifica se o cenário carregado tem o título esperado
        final loadedScenario = scenarios.firstWhere(
          (s) => s.title == "Dominus & Dragons",
          orElse: () => throw StateError('Cenário esperado não encontrado'),
        );
        expect(loadedScenario.author, "Jefferson Pimentel");
        expect(
          loadedScenario.ambiance,
          contains("Neste jogo, você é um Aventureiro"),
        );
      },
    );

    test(
      'loadScenarios should ignore non-JSON files in the directory',
      () async {
        // Aponta o loader para o diretório temporário misto
        final loader = ScenarioLoader(scenariosFolderPath: tempMixedDir.path);
        final scenarios = await loader.loadScenarios();

        expect(scenarios, isA<List<Scenario>>());
        // Deve carregar apenas o arquivo JSON, ignorando o .txt
        expect(scenarios.length, 1);
        expect(
          scenarios.first.title,
          "Dominus & Dragons",
        ); // Verifica se é o cenário correto
      },
    );

    test(
      'loadScenarios should return empty list for an empty directory',
      () async {
        // Aponta o loader para o diretório temporário vazio
        final loader = ScenarioLoader(scenariosFolderPath: tempEmptyDir.path);
        final scenarios = await loader.loadScenarios();

        expect(scenarios, isEmpty);
      },
    );

    test(
      'loadScenarios should throw ScenarioLoadException for non-existent directory',
      () async {
        final loader = ScenarioLoader(
          scenariosFolderPath: '/path/that/does/not/exist',
        );

        // Verifica se a exceção específica é lançada
        expect(
          () async => await loader.loadScenarios(),
          throwsA(isA<ScenarioLoadException>()),
        );
      },
    );

    // Não é possível testar facilmente JSON malformado ou com campos faltando
    // sem criar arquivos temporários específicos, o que foi vetado.
    // A validação interna do Scenario.fromJson() cobrirá esses casos
    // quando um arquivo real inválido for encontrado.
  });
}
