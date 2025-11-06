# Firebase Setup Guide for Sicredo

Este guia fornece instruções detalhadas para configurar o Firebase e Firestore no projeto Sicredo.

## Pré-requisitos

- Flutter SDK instalado (>=3.0.0)
- Conta no [Firebase Console](https://console.firebase.google.com/)
- FlutterFire CLI instalado

## Instalação do FlutterFire CLI

```bash
# Instalar o FlutterFire CLI globalmente
dart pub global activate flutterfire_cli

# Verificar instalação
flutterfire --version
```

## 1. Criar Projeto no Firebase

1. Acesse o [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Digite o nome do projeto (ex: "sicredo-dev" ou "sicredo-prod")
4. (Opcional) Ative o Google Analytics
5. Clique em "Criar projeto"

## 2. Ativar o Firestore

1. No Firebase Console, selecione seu projeto
2. No menu lateral, clique em "Firestore Database"
3. Clique em "Criar banco de dados"
4. Escolha o modo:
   - **Modo de produção**: Requer regras de segurança (recomendado)
   - **Modo de teste**: Acesso livre por 30 dias (apenas para desenvolvimento)
5. Selecione a localização do servidor (ex: `southamerica-east1` para São Paulo)
6. Clique em "Ativar"

## 3. Configurar o App no Firebase

### Opção A: Usar FlutterFire CLI (Recomendado)

O FlutterFire CLI automatiza a configuração para todas as plataformas:

```bash
# No diretório raiz do projeto
flutterfire configure

# Siga as instruções:
# 1. Selecione ou crie um projeto Firebase
# 2. Selecione as plataformas (Android, iOS, Web, macOS)
# 3. O CLI irá gerar o arquivo lib/firebase_options.dart automaticamente
```

Este comando irá:
- Criar/atualizar `lib/firebase_options.dart` com as configurações
- Baixar `google-services.json` para Android
- Baixar `GoogleService-Info.plist` para iOS/macOS
- Configurar a web automaticamente

### Opção B: Configuração Manual

Se preferir configurar manualmente:

#### Android

1. No Firebase Console, adicione um app Android
2. Registre o app com o package name: `com.example.sicredo` (ou o package do seu app)
3. Baixe o arquivo `google-services.json`
4. Coloque em `android/app/google-services.json`
5. Edite `android/build.gradle` e adicione:
   ```gradle
   buildscript {
     dependencies {
       // Add this line
       classpath 'com.google.gms:google-services:4.4.0'
     }
   }
   ```
6. Edite `android/app/build.gradle` e adicione no final:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### iOS

1. No Firebase Console, adicione um app iOS
2. Registre o app com o bundle ID: `com.example.sicredo` (ou o bundle do seu app)
3. Baixe o arquivo `GoogleService-Info.plist`
4. Abra `ios/Runner.xcworkspace` no Xcode
5. Arraste `GoogleService-Info.plist` para a pasta Runner no Xcode
6. Certifique-se de marcar "Copy items if needed"

#### Web

1. No Firebase Console, adicione um app Web
2. Copie as configurações do Firebase
3. As configurações já estão incluídas no `lib/firebase_options.dart` gerado pelo FlutterFire CLI

#### macOS

Similar ao iOS:
1. No Firebase Console, adicione um app macOS
2. Baixe `GoogleService-Info.plist`
3. Coloque em `macos/Runner/GoogleService-Info.plist`

## 4. Configurar Regras de Segurança do Firestore

As regras de segurança estão definidas em `firebase/firestore.rules`. Para aplicá-las:

### Opção A: Via Firebase Console

1. No Firebase Console, vá em "Firestore Database" > "Regras"
2. Copie o conteúdo de `firebase/firestore.rules`
3. Cole no editor e clique em "Publicar"

### Opção B: Via Firebase CLI

```bash
# Instalar Firebase CLI (se ainda não tiver)
npm install -g firebase-tools

# Login no Firebase
firebase login

# Inicializar o projeto (se ainda não fez)
firebase init firestore

# Quando perguntado sobre o arquivo de regras, mantenha firebase/firestore.rules
# Deploy das regras
firebase deploy --only firestore:rules
```

## 5. Estrutura de Dados no Firestore

O app usa a seguinte estrutura de coleções:

```
users/ (collection)
  └── {userId}/ (document)
      ├── saldo_total: number
      ├── created_at: timestamp
      ├── updated_at: timestamp
      └── transactions/ (subcollection)
          └── {transactionId}/ (document)
              ├── nome: string
              ├── valor: number
              ├── data: timestamp
              └── isGanho: boolean
```

### Exemplo de Documento de Transação

```json
{
  "nome": "Salário",
  "valor": 5000.0,
  "data": Timestamp(2024-01-15 00:00:00),
  "isGanho": true
}
```

## 6. Múltiplos Ambientes (Dev/Prod)

Para usar diferentes projetos Firebase para desenvolvimento e produção:

### Método 1: Múltiplos Projetos FlutterFire

```bash
# Configurar projeto de desenvolvimento
flutterfire configure --project=sicredo-dev

# Configurar projeto de produção
flutterfire configure --project=sicredo-prod
```

### Método 2: Dart Define

Use variáveis de ambiente para alternar entre projetos:

```bash
# Desenvolvimento
flutter run --dart-define=ENV=dev

# Produção
flutter run --dart-define=ENV=prod
```

Depois, no código:

```dart
const String environment = String.fromEnvironment('ENV', defaultValue: 'dev');
final String projectId = environment == 'prod' ? 'sicredo-prod' : 'sicredo-dev';
```

### Método 3: Flavors (Avançado)

Configure flavors no Android e iOS para alternar automaticamente entre ambientes.

## 7. Autenticação (Opcional)

Se desejar adicionar autenticação Firebase:

1. No Firebase Console, vá em "Authentication"
2. Clique em "Começar"
3. Ative os provedores desejados (Email/senha, Google, etc.)
4. Adicione `firebase_auth` ao `pubspec.yaml`
5. Atualize as regras de segurança para usar `request.auth.uid`

Exemplo de código:

```dart
import 'package:firebase_auth/firebase_auth.dart';

// Login
final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Obter usuário atual
final user = FirebaseAuth.instance.currentUser;
final userId = user?.uid ?? 'default_user';

// Usar userId no repository
final repository = TransactionRepository(userId: userId);
```

## 8. Testando a Configuração

Execute o app e verifique os logs:

```bash
flutter run
```

Você deve ver no console:

```
[Firebase/Core] Configuration succeeded
[Firebase/Firestore] Firestore initialized
```

Teste as operações CRUD:
1. Adicione uma transação
2. Verifique no Firebase Console > Firestore Database se o documento foi criado
3. Tente deletar uma transação
4. Verifique se foi removida do Firestore

## 9. Emulador Firebase (Desenvolvimento Local)

Para testar sem conectar ao Firebase real:

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Inicializar emuladores
firebase init emulators

# Selecionar Firestore
# Iniciar emulador
firebase emulators:start
```

No código, conecte ao emulador:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Em desenvolvimento, use o emulador
  if (kDebugMode) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }
  
  runApp(const ProviderScope(child: SicredoApp()));
}
```

## Troubleshooting

### Erro: "Default FirebaseApp is not initialized"

Certifique-se de que `Firebase.initializeApp()` é chamado antes de usar o Firestore.

### Erro: "PERMISSION_DENIED"

Verifique as regras de segurança no Firestore. Se estiver usando autenticação, certifique-se de que o usuário está autenticado.

### Erro: "google-services.json not found"

Certifique-se de que o arquivo está em `android/app/google-services.json` e que o plugin do Google Services está aplicado no `build.gradle`.

### Build iOS falha

1. Abra `ios/Runner.xcworkspace` no Xcode
2. Verifique se `GoogleService-Info.plist` está na pasta Runner
3. Execute `pod install` na pasta `ios/`
4. Tente buildar novamente

## Recursos Adicionais

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Data Model](https://firebase.google.com/docs/firestore/data-model)
- [Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
