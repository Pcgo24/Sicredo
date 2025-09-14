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
  screens/
    welcome_screen.dart        # Tela de boas-vindas
    auth_screen.dart           # Tela de autenticação
    home_screen.dart           # Tela principal
    cotacao_screen.dart        # Tela de cotações de moedas
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

## Próximos Passos

- Persistência local dos dados (Hive, SharedPreferences, etc).
- Filtros e estatísticas avançadas para o extrato.
- Customização de categorias de ganhos/gastos.
- Melhorias de acessibilidade e internacionalização.

---

## Equipe

- Nome do Projeto: **Sicredo**
- Integrantes: Vitor Bobato e Paulo Cesar Cardoso Domingues.

---

## Licença

Este projeto é apenas para fins acadêmicos.
