# Classe: ScenarioLoader (Data Access / Model Support)

Responsável por encontrar, ler e parsear os arquivos JSON que definem os cenários disponíveis (RF-009, RNF-007).

**Diagrama UML (Mermaid):**

```mermaid
classDiagram
    class ScenarioLoader {
        +String scenariosFolderPath  // Caminho da pasta com os JSONs (RNF-007)
        +loadScenarios() List~Scenario~ // Carrega todos os cenários válidos (RF-009)
        -parseScenario(filePath: String) Scenario? // Tenta parsear um único arquivo
        -validateScenarioData(data: Map) bool // Valida a estrutura do JSON
    }
    class Scenario {
      %% Atributos definidos anteriormente
    }
    ScenarioLoader ..> Scenario : creates >
```

**Atributos:**

*   `scenariosFolderPath`: Caminho configurável para a pasta contendo os arquivos `.json` dos cenários (RNF-007).

**Métodos:**

*   `loadScenarios()`: Varre a pasta `scenariosFolderPath`, tenta ler/parsear cada JSON. Cria objetos `Scenario` válidos e trata erros (RF-009, RF-008).
*   `parseScenario(filePath)`: (Privado) Lê, parseia e tenta instanciar um `Scenario` de um arquivo.
*   `validateScenarioData(data)`: (Privado) Verifica se os dados do JSON contêm os campos obrigatórios.

**Relacionamentos:**

*   Cria instâncias de `Scenario`.
*   Usado pelo `MainScreenController` para obter a lista de cenários disponíveis.