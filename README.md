# Sicredo

Gestão Financeira Pessoal Mobile

---

## Visão Geral

**Sicredo** é um aplicativo Flutter multiplataforma para ajudar você a gerenciar ganhos, gastos, e acompanhar cotações de moedas em tempo real. O app prioriza uma interface intuitiva, design moderno, microinterações e acessibilidade, seguindo os conceitos de Atomic Design e boas práticas de desenvolvimento mobile.

---

## Funcionalidades

- **Tela de Boas-vindas:** Animação de entrada e acesso ao fluxo de autenticação.
- **Autenticação:** Login e cadastro com validação de formulário.
- **Home:** Visualização de saldo total, ganhos e gastos do mês, histórico/registro de extrato financeiro, microinterações, e feedback visual.
- **Registro de Ganhos/Gastos:** Adição e remoção de lançamentos, com animações.
- **Cotações de Moedas:** Consulta de valores de USD, EUR, BTC em tempo real via AwesomeAPI.
- **Navegação entre telas:** Sistema de rotas nomeadas.
- **Acessibilidade:** Contraste de cores, fontes adequadas, uso de Semantics.
- **Widgets Reutilizáveis:** Atomic Design aplicado com átomos e moléculas (ex: botões, campos de formulário).

---

## Estrutura de Pastas

```
lib/
  core/
    cotacao_service.dart       # Serviço de integração com API de cotações
  data/
    database/
      database_helper.dart     # Helper para gerenciar SQLite
    models/
      transaction_model.dart   # Modelo de transação financeira
      cotacao_model.dart       # Modelo de cotação
    repositories/
      transaction_repository.dart  # Repositório de transações
      cotacao_repository_impl.dart # Implementação do repositório de cotações
    datasources/
      cotacao_remote_data_source.dart  # Fonte de dados remota
  screens/
    welcome_screen.dart        # Tela de boas-vindas
    auth_screen.dart           # Tela de autenticação
    home_screen.dart           # Tela principal com persistência
  presentation/
    screens/
      cotacoes_screen.dart     # Tela de cotações com Riverpod
    state/
      cotacoes_notifier.dart   # Gerenciamento de estado com Riverpod
  domain/
    entities/
      cotacao.dart             # Entidade de cotação
    repositories/
      cotacao_repository.dart  # Interface do repositório
    usecases/
      get_cotacoes.dart        # Caso de uso de cotações
  widgets/
    form_input.dart            # Átomo: campo de formulário reutilizável
    primary_button.dart        # Átomo: botão primário reutilizável
```

---

## Atomic Design

- **Átomos:**  
  - `PrimaryButton`, `FormInput`
- **Moléculas:**  
  - Formulário de autenticação (combina átomos), Cards de extrato, Card de cotação
- **Organismos:**  
  - Tela Home, Tela Auth, Tela de Cotações

---

## Microinterações

- Botões com efeito InkWell/splash.
- Animações de entrada (ScaleTransition, FadeTransition).
- Feedback de ação via SnackBar.
- AnimatedSwitcher para atualização de saldo.

---

## Acessibilidade

- Contraste entre fundo/texto e botões.
- Fontes grandes e legíveis.
- Uso do widget `Semantics` em botões e cards relevantes para suporte a leitores de tela.

---

## Consumo de API

- **AwesomeAPI:** Utilizada para buscar cotações em tempo real.
- **FutureBuilder:** Implementado na tela de cotações para atualização assíncrona dos valores.

---

## Validação de Formulários

- Tela de autenticação com 3 campos (`Nome`, `E-mail`, `Senha`).
- Validação de e-mail, senha mínima, nome obrigatório.
- Alertas e feedback visual em caso de erro.

---

## Persistência de Dados

- **SQLite Database:** Implementado para persistência local de transações e saldo.
- **Repository Pattern:** Camada de abstração para operações de banco de dados.
- **Models:** TransactionModel com serialização para/do banco de dados.
- Os dados são persistidos automaticamente e carregados ao iniciar o app.
- Para mais detalhes, veja [DATABASE.md](DATABASE.md).

---

## Gerenciamento de Estado

- Utilização de `setState` para atualização de valores do extrato, saldo e UI.

---

## Como rodar o projeto

1. Clone o repositório:
    ```sh
    git clone https://github.com/Pcgo24/Sicredo.git
    cd Sicredo
    ```
2. Instale as dependências:
    ```sh
    flutter pub get
    ```
3. Rode o app:
    ```sh
    flutter run
    ```

---

## Testes Automatizados
O projeto inclui uma suíte de testes automatizados seguindo os padrões do Flutter para garantir a qualidade, estabilidade e o correto funcionamento das funcionalidades e regras de negócio.

A cobertura de testes foi dividida nas três principais categorias:

- **Testes Unitários (Unit Tests)**:

  - Validam a lógica pura de classes e funções, sem depender da UI.

  - **Cobertura**: Testamos o `CotacaoService` (em `test/core/`) mockando as chamadas HTTP. Garantimos que o serviço processa corretamente tanto uma resposta de sucesso (200) quanto uma resposta de **erro (404)** da API.

- **Testes de Widget (Widget Tests)**:

  - Validam a renderização e a interatividade de widgets e telas de forma isolada.

  - **Cobertura**:

    - `WelcomeScreen` (em `test/screens/`): Garante que o título, ícone e o botão "Começar" são renderizados corretamente após as animações.

    - `AuthScreen` (em `test/screens/`): Garante que as mensagens de erro de validação (ex: "E-mail inválido") são exibidas quando o usuário tenta submeter o formulário de login vazio.

- **Testes de Integração (Integration Tests)**:

  - Validam fluxos completos do aplicativo, simulando um usuário real no app em execução.

  - **Cobertura**:

    - **Fluxo de Autenticação (TI-01)**: Simula o usuário desde a `WelcomeScreen`, tocando em "Começar", preenchendo o login na `AuthScreen` e verificando se ele chega com sucesso à `HomeScreen`.

    - **Fluxo de "Adicionar Saldo" (TI-02)**: Simula o usuário já logado na `HomeScreen`, toca em "Adicionar Saldo", preenche o formulário no `AlertDialog` e verifica se o "Saldo Total" e a lista de extrato na `HomeScreen` são atualizados corretamente.

## Próximos Passos

- ✅ ~~Persistência local dos dados~~ (Implementado com SQLite)
- Filtros e estatísticas avançadas para o extrato.
- Customização de categorias de ganhos/gastos.
- Melhorias de acessibilidade e internacionalização.
- Backup e sincronização de dados na nuvem.

---

## Equipe

- Nome do Projeto: **Sicredo**
- Integrantes: Vitor Bobato e Paulo Cesar Cardoso Domingues.

---

## Licença

Este projeto é apenas para fins acadêmicos.
