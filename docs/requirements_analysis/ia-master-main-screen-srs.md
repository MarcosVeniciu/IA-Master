# Software Requirements Specification (SRS) - IA Master: Main Screen

## 1. Introduction

Este documento especifica os requisitos funcionais e não funcionais para a funcionalidade "Main Screen" do aplicativo "IA Master". O objetivo desta tela é servir como hub central para os jogadores acessarem suas aventuras em andamento e explorarem novos cenários disponíveis.

## 2. References

*   Documento original fornecido pelo usuário: "Feature 1: Main Screen" (User Stories, Acceptance Criteria, Feature Specifications, Information Architecture).

## 3. Project Overview

*   **Nome do Projeto:** IA Master
*   **Objetivo Principal:** Fornecer uma plataforma de RPG de texto imersiva onde os jogadores podem viver aventuras geradas dinamicamente por IA.
*   **Stakeholders Primários:** Jogadores (usuários finais).

## 4. Functional Requirements

| ID      | Descrição                                                               | Prioridade | Critério de Aceitação                                                                                                                                                              |
| :------ | :---------------------------------------------------------------------- | :--------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RF-001  | Exibir seção de destaque rotativa.                                      | Alta       | Uma seção no topo exibe até 3 cards (cenários ou aventuras) que rotacionam automaticamente a cada 6 segundos em loop. Cada card tem título, gênero, descrição e botão "Start".        |
| RF-001.1| Exibir seção "Ongoing Adventures".                                      | Alta       | Se houver aventuras em andamento, a seção é visível com o título "Ongoing Adventures" (ou "Ongoing Scenario").                                                                     |
| RF-002  | Listar aventuras em andamento em formato de card.                       | Alta       | Cada card mostra o título do cenário, gênero, uma barra de progresso visual, informação de "Last access" e um botão/ícone "Play".                                                  |
| RF-003  | Exibir mensagem quando não houver aventuras em andamento.               | Média      | Se não houver aventuras, a seção exibe a mensagem "No adventures in progress" (ou equivalente em português) em vez de uma lista vazia.                                             |
| RF-004  | Navegar para a tela de Chat ao clicar em "Play".                        | Alta       | Ao tocar no botão/ícone "Play", o aplicativo navega para a tela de Chat, carregando o histórico de conversa e o estado do jogo salvos para aquela aventura.                          |
| RF-005  | Exibir seção "Available Scenario".                                      | Alta       | Se houver cenários disponíveis para jogar, a seção é visível com o título "Available Scenario".                                                                                  |
| RF-006  | Listar cenários disponíveis em formato de card.                         | Alta       | Cada card de cenário mostra seu título, gênero, uma descrição (aprox. 4 linhas) e um botão "Start".                                                                               |
| RF-007  | Navegar para a tela de Chat ao clicar em "Start".                       | Alta       | Ao tocar no botão "Start" (seja na seção de destaque ou nos cards disponíveis), o aplicativo navega para a tela de Chat e inicia o processo de criação de personagem para o cenário selecionado. |
| RF-008  | Exibir mensagem de erro ao falhar o carregamento de cenários locais.    | Média      | Se houver erro ao ler/processar os arquivos JSON de cenários locais, a seção "Available Scenario" exibe uma mensagem como "Unable to load scenarios, please check files" (ou equivalente). |
| RF-009  | Carregar cenários a partir de arquivos locais.                          | Alta       | Cenários definidos em arquivos JSON em uma pasta específica do aplicativo são carregados e exibidos na seção "Available Scenario" quando o aplicativo é aberto.                      |
| RF-009.1| Implementar busca de cenários disponíveis.                              | Média      | Um campo de busca permite ao usuário digitar texto para filtrar a lista de "Available Scenario" por título ou descrição.                                                            |
| RF-009.2| Implementar filtro de cenários disponíveis.                             | Média      | Um botão/ícone de filtro permite ao usuário aplicar critérios (a definir, ex: gênero) para refinar a lista de "Available Scenario".                                                |
| RF-010  | Botão de navegação para a tela de Assinatura.                           | Média      | Um botão/item de menu "Subscription" (ou equivalente) está acessível (ex: no menu hambúrguer) e, ao ser tocado, navega para a tela de Assinatura.                                     |
| RF-011  | Botão de navegação para a tela de Instruções.                           | Média      | Um botão/item de menu "Instructions" (ou equivalente) está acessível (ex: no menu hambúrguer) e, ao ser tocado, navega para a tela de Instruções.                                    |
| RF-012  | Exibir automaticamente a tela de Instruções no primeiro lançamento.     | Alta       | Na primeira vez que o aplicativo é iniciado após a instalação, ele exibe automaticamente a tela de Instruções antes de mostrar a tela principal.                                     |
| RF-013  | Pular a tela de Instruções em lançamentos subsequentes.                 | Alta       | Em todas as inicializações do aplicativo após a primeira, ele vai diretamente para a tela principal, pulando a tela de Instruções.                                                  |

## 5. Non-Functional Requirements

| ID      | Categoria                 | Descrição                                                                                                                                                                                                                         |
| :------ | :------------------------ | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RNF-001 | Interface/Usabilidade     | A tela principal e seus componentes (seções, cards, botões) devem seguir uma estética com fundo escuro e detalhes/acentos em neon (ex: bordas azuis brilhantes), conforme especificado no design.                                      |
| RNF-002 | Desempenho                | O carregamento de cenários na seção "Scenario Options" deve ser eficiente, especialmente para listas longas (ex: 50+ itens). O scroll deve ser suave e, se aplicável, implementar carregamento progressivo para evitar lentidão. |
| RNF-003 | Acessibilidade            | A interface deve suportar recursos de acessibilidade, incluindo texto de alto contraste, fontes escaláveis e compatibilidade com leitores de tela (anunciando corretamente botões e descrições).                                  |
| RNF-004 | Interface/Usabilidade     | Os cards usados nas seções "Ongoing Adventures" e "Scenario Options" devem ter um layout e estilo visual consistentes.                                                                                                              |
| RNF-005 | Restrição Técnica         | O aplicativo deve ser desenvolvido utilizando o framework Flutter, com foco inicial na plataforma Android.                                                                                                                          |
| RNF-006 | Restrição Técnica         | A geração de conteúdo de IA durante as aventuras dependerá de uma API externa. O carregamento de cenários e o armazenamento do progresso das aventuras serão locais.                                                              |
| RNF-007 | Armazenamento de Cenários | Os cenários disponíveis serão definidos em arquivos JSON armazenados localmente dentro do pacote do aplicativo ou em um diretório acessível por ele.                                                                              |
| RNF-008 | Armazenamento de Progresso| O progresso das aventuras em andamento (histórico de chat, estado do jogo) será armazenado em um banco de dados local (ex: SQLite).                                                                                              |

## 6. Constraints

*   **Plataforma:** Foco inicial em Android.
*   **Tecnologia:** Desenvolvimento obrigatório com Flutter.
*   **Dependência Externa:** Necessidade de uma API externa *apenas* para a geração de conteúdo de IA durante o jogo.
*   **Armazenamento Local:** Cenários (arquivos JSON) e progresso das aventuras (banco de dados local, ex: SQLite) devem ser gerenciados localmente no dispositivo.

## 7. Acceptance Criteria

Os critérios de aceitação específicos para cada requisito funcional estão detalhados na tabela da Seção 4 (Functional Requirements).

## 8. Prioritization

Os requisitos funcionais foram priorizados utilizando os níveis **Alta** e **Média**, conforme indicado na Seção 4. Requisitos de prioridade Alta são essenciais para a funcionalidade principal da tela, enquanto os de prioridade Média agregam valor ou tratam de casos de uso menos frequentes ou fluxos secundários.

## 9. Glossary

*   **API:** Application Programming Interface. Interface que permite a comunicação entre diferentes softwares (neste contexto, usada para a IA).
*   **Card:** Componente visual de UI usado para agrupar informações relacionadas (ex: detalhes de uma aventura ou cenário).
*   **DB Local:** Banco de dados armazenado no dispositivo do usuário (ex: SQLite).
*   **Flutter:** Framework de UI do Google para construir aplicativos compilados nativamente para mobile, web e desktop a partir de uma única base de código.
*   **JSON:** JavaScript Object Notation. Formato leve de troca de dados, usado aqui para definir os cenários.
*   **Main Screen:** Tela principal do aplicativo "IA Master", ponto central de navegação inicial para o jogador.
*   **RPG:** Role-Playing Game. Jogo onde os jogadores assumem papéis de personagens em um cenário fictício.
*   **SQLite:** Sistema de gerenciamento de banco de dados relacional leve e embarcado, comum em aplicativos móveis para armazenamento local.
*   **Stakeholder:** Indivíduo, grupo ou organização que pode afetar ou ser afetado por um projeto (neste caso, primariamente os Jogadores).
*   **SRS:** Software Requirements Specification. Documento que descreve o que um sistema de software deve fazer.
*   **UI:** User Interface. Meios pelos quais um usuário interage com um sistema.

## 10. Change History

| Date         | Author      | Description of Changes                                                                                                                               |
| :----------- | :---------- | :--------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2025-04-30   | Roo (AI)    | Updated RFs based on wireframe feedback: Added RF-001 (Highlight Section), modified RF-002/RF-004 (Ongoing Cards/Play Button), RF-006 (Available Cards Description), added RF-009.1 (Search), RF-009.2 (Filter). Adjusted RF-010/RF-011 location assumption. |