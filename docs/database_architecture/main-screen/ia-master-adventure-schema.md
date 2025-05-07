# Adventure Schema

## Fields
- id: TEXT (PRIMARY KEY NOT NULL, Identificador único da aventura, UUID)
- scenario_title: TEXT (NOT NULL, Título do cenário base)
- adventure_title: TEXT (NOT NULL, Título específico da instância da aventura)
- progress_indicator: REAL (NULLABLE, Progresso numérico de 0.0 a 1.0)
- game_state: TEXT (NOT NULL, String JSON contendo o estado atual do jogo)
- last_played_date: INTEGER (NOT NULL, Timestamp Unix (ms since epoch) da última interação)
- sync_status: INTEGER (NOT NULL DEFAULT 0, Status de sincronização: 0=local, 1=syncing, 2=synced, -1=error)

## Relationships
- **Implícito:** Baseado em um `Scenario` (identificado por `scenario_title`).
- **1:N:** Uma `Adventure` pode ter muitos `ChatMessage`s. A ligação é feita via `ChatMessage.adventure_id` referenciando `Adventure.id`.

## Mobile Optimizations
- **Índice:** Criar um índice em `last_played_date` para buscar e ordenar eficientemente as aventuras na seção "Ongoing Adventures".
- **Sincronização:** O campo `sync_status` facilita a implementação de estratégias de sincronização (delta sync) se o backup/sincronização online for adicionado futuramente.
- **Armazenamento de Estado (game_state):** Armazenar como JSON (TEXT) oferece flexibilidade para evolução do estado do jogo sem alterar o esquema do banco de dados. Para dados muito grandes ou binários, BLOB poderia ser uma alternativa, mas JSON é geralmente preferível para dados estruturados.
- **Chave Primária:** Usar um UUID (armazenado como TEXT) para `id` garante unicidade mesmo em cenários offline ou distribuídos.