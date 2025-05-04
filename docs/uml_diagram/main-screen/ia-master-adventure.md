# Classe: Adventure (Model)

Representa uma aventura em andamento que o jogador já iniciou.

**Diagrama UML (Mermaid):**

```mermaid
classDiagram
    class Adventure {
        +String id  // Identificador único para buscar no DB local
        +String scenarioTitle // Título do cenário original (RF-002)
        +String progressIndicator // Ex: "Scene 3", "50%" (RF-002)
        +Object gameState // Estado atual do jogo (RNF-008) - Tipo a definir
        +List~String~ chatHistory // Histórico da conversa (RNF-008) - Tipo a definir
        +DateTime lastPlayedDate // Data da última interação
        +loadState() void // Placeholder: Carrega estado completo
        +saveState() void // Placeholder: Salva estado atual
    }
    %% Nota: Uma Adventure é baseada em um Scenario (definido separadamente).
    %% Para a Main Screen, apenas o scenarioTitle é diretamente necessário.
    %% Adventure ..> Scenario : (based on)

```

**Atributos:**

*   `id`: Identificador único para recuperar a aventura salva (RNF-008).
*   `scenarioTitle`: Título do cenário associado (RF-002).
*   `progressIndicator`: Uma string que descreve o progresso atual (RF-002).
*   `gameState`: Objeto/estrutura contendo o estado atual do jogo (RNF-008).
*   `chatHistory`: Lista/estrutura contendo o histórico da conversa (RNF-008).
*   `lastPlayedDate`: Data/hora da última vez que a aventura foi jogada.

**Métodos:**

*   `loadState()`: Placeholder para carregar dados detalhados da aventura.
*   `saveState()`: Placeholder para salvar o estado atual da aventura.

**Relacionamentos:**

*   Criada/Lida/Atualizada/Deletada por `AdventureRepository`.
*   Baseada em um `Scenario` (usa `scenarioTitle` na Main Screen).
*   Gerenciada pelo `MainScreenController`.
*   Exibida pela `MainScreenView`.