# Bet na Bola

## 1. Identificação
* **App:** Bet na Bola
* **Squad:** Bet na Bola
* **Integrantes:** Daniel Kazimoto, Matheus Rodrigues, Pedro Avila, Vinicius Vasconcelos
* **Contato:** 72500867@aluno.faculdadecotemig.br, 72401729@aluno.faculdadecotemig.br,
               72500972@aluno.faculdadecotemig.br, 72401788@aluno.faculdadecotemig.br

## 2. Sobre o projeto
O **Bet na Bola** é um aplicativo de simulador de apostas esportivas focado no Brasileirão. O grande diferencial é a abordagem "anti-vício": o usuário não aposta dinheiro real, mas sim pontos que são conquistados em desafios de conhecimento. 

O público-alvo são torcedores e entusiastas de futebol. O fluxo do aplicativo consiste em:
1. Visualizar as partidas do campeonato (agendadas, ao vivo e encerradas).
2. Fazer um palpite (Mandante, Empate ou Visitante) gastando pontos fictícios.
3. Participar de desafios (quiz) para recuperar e ganhar novos pontos.
4. Acompanhar o histórico e conferir os resultados para ver a pontuação obtida.

## 3. Requisitos atendidos

| Requisito A3 | Onde está no app |
| :--- | :--- |
| **1. 4+ telas com Navigator** | `lib/screens/home_screen.dart`, `detail_screen.dart`, `challenge_screen.dart`, `profile_screen.dart`, `results_screen.dart` |
| **2. API REST com http e async/await** | `lib/core/services/api_service.dart` e `backend/lib/src/services/football_api_service.dart` |
| **3. Loading e erro visíveis** | `CircularProgressIndicator` na Home. Tratamento de erro e SnackBars no `ApiService` e `HomeScreen`. |
| **4. Formulário com Form e validator** | `lib/screens/challenge_screen.dart` (validação da resposta do quiz). |
| **5. Lista dinâmica com ListView.builder** | `lib/screens/home_screen.dart` (lista de partidas) e `lib/screens/results_screen.dart` (histórico). |
| **6. SharedPreferences persistente** | `lib/core/services/secure_storage_service.dart` (gera e salva o UUID do usuário de forma segura). |
| **7. Provider: telas, HTTP e prefs** | `lib/models/user_provider.dart` (estado do usuário), `soccer_matches.dart` (estado das partidas) e `api_service.dart` (HTTP isolado). |
| **8. App abre e percorre o fluxo** | O fluxo de Login local (UUID) -> Home -> Detalhe -> Aposta -> Perfil funciona sem crashes. |

## 4. API e dados remotos

O projeto utiliza duas fontes de dados remotas:

1. **API Pública (Dados de Futebol): API-Futebol**
   * **URL Base:** `https://api.api-futebol.com.br/v1`
   * **Endpoints:** `/ao-vivo` e `/campeonatos/10/partidas`
   * **Autenticação:** Requer Token de teste (`test_...`) no Header.

2. **API Privada (Banco de Dados): Supabase**
   * **URL Base:** `https://olporlnjhxgwydullnfx.supabase.co`
   * **Endpoints:** Acesso às tabelas `previsoes`, `usuarios`, `perguntas` e `partidas_cache`.
   * **Autenticação:** Chave anônima e restrição de acesso via UUID local do usuário.

## 5. Como rodar

**Pré-requisitos:**
* Flutter SDK (versão 3.6.0 ou superior)
* Dart SDK (versão 3.13.0 ou superior)

**Passos:**
1. Clone o repositório.
2. No terminal, na raiz do projeto Flutter, execute:
   ```bash
   flutter pub get
   ```
3. Para rodar no emulador Android (consumindo o backend local), execute:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
   ```
   *(Para rodar no iOS Simulator ou Web, substitua `10.0.2.2` por `localhost`)*.

## 6. Backend local

O backend foi desenvolvido em Dart/Shelf para servir como proxy de segurança e para gerenciar a lógica de negócios.

**Como rodar o backend:**
1. Abra um terminal e acesse a pasta do backend:
   ```bash
   cd backend
   ```
2. Instale as dependências:
   ```bash
   dart pub get
   ```
3. Crie um arquivo `.env` na pasta `backend/` com as credenciais:
   ```env
   SUPABASE_URL=https://olporlnjhxgwydullnfx.supabase.co
   SUPABASE_ANON_KEY=sua_chave_aqui
   FOOTBALL_API_URL=https://api.api-futebol.com.br/v1
   FOOTBALL_API_TOKEN=test_seu_token_aqui
   ```
4. Inicie o servidor:
   ```bash
   dart run bin/server.dart
   ```
   O servidor estará rodando em `http://0.0.0.0:8080`.

* **Dados de Teste:** O banco conta com uma tabela `partidas_cache` preenchida com jogos fictícios para garantir que o app funcione mesmo se a API pública estiver instável ou vazia. 
* **Como parar:** Pressione `Ctrl + C` no terminal do servidor.

## 7. Estrutura do código

* **`lib/`**: Código Flutter.
  * **`core/`**: Configurações globais, temas (`app_colors`, `app_styles`), serviços (`api_service`, `secure_storage_service`) e widgets reutilizáveis.
  * **`models/`**: Entidades de dados (`partida`, `desafio`) e gerenciamento de estado (`user_provider`, `soccer_matches`).
  * **`screens/`**: Interfaces visuais (Home, Detalhe, Desafio, Perfil, Resultados).
* **`backend/`**: Código do servidor Dart.
  * **`controllers/`**: Regras de negócio (apostas, desafios, usuários, partidas).
  * **`middlewares/`**: Segurança, rate limit e tratamento de erros.
  * **`services/`**: Integração com APIs externas e Supabase.

## 8. Observações

* **Limitações:** Devido à instabilidade e limitações de dados do ambiente de teste da API-Futebol, foi implementado um sistema de fallback com `partidas_cache`. Além disso, o carregamento dos escudos dos times (SVG/PNG) depende de URLs externas e, caso falhem, o app renderiza as iniciais do time de forma colorida para não quebrar a usabilidade.
* **Bônus Implementados:** Tema escuro (Dark Mode) nativo, armazenamento seguro para o UUID (`flutter_secure_storage`), e tratamento de formulários com `validator` focado no anti-vício.
* **Segurança:** A chave de API pública não fica exposta no aplicativo, todo o tráfego de dados sensíveis passa pelo backend local.
