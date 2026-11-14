# LocalHub — Frontend mobile

Aplicação Android do LocalHub (Visitante, Cliente e Prestador de Serviços), feita com Flutter 3 e Dart 3. Requer Android 13 (API 33) ou superior.

## Pré-requisitos

- Flutter 3.50 (canal stable), com o Dart 3.14.
- Android SDK com um emulador Android 16 (API 36) ou um telemóvel com Android 13 ou superior.
- Java 17 (usado pelo Gradle do Android).
- Backend do LocalHub a correr, por omissão em `http://localhost:5041` no computador (ver o README do repositório `backend`).

## Instalação

```bash
flutter pub get
```

## Configuração

O endereço do backend configura-se sem alterar o código, com `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5041
```

Sem `API_BASE_URL`, é usado `http://10.0.2.2:5041`, que é o `localhost` do computador visto a partir do emulador Android.

**HTTP sem HTTPS:** só o build de debug aceita HTTP, e só para `10.0.2.2` e `localhost` (`android/app/src/debug/res/xml/network_security_config.xml`). Para usar um telemóvel real com o backend noutro endereço da rede, é preciso acrescentar esse IP a esse ficheiro.

## Execução local

Com o emulador aberto (ou o telemóvel ligado):

```bash
flutter run
```

## Verificações

| Comando | O que faz |
| --- | --- |
| `dart format --output=none --set-exit-if-changed .` | Verifica a formatação (regulamento interno, secção 10.3). |
| `flutter analyze` | Análise estática com o `flutter_lints` (regulamento interno, secção 10.4). |
| `flutter test` | Testes sem dispositivo (`test/`). |
| `flutter test integration_test` | Testes de sistema, com um emulador ou telemóvel ligado (`integration_test/`). |
| `flutter build apk --debug` | Gera o APK de debug em `build/app/outputs/flutter-apk/`. |

## Organização das pastas

A estrutura segue o Modelo de Classes do frontend mobile v03:

```
lib/
  main.dart          arranque da aplicação (tema, português e router)
  config/            URL base da API
  api/               comunicação com o backend e sessão
  models/            modelos dos dados da API
  data/              leituras e ações por recurso
  router/            rotas e guardas (go_router)
  theme/             tema e espaçamentos do protótipo
  widgets/
    layout/          barras inferiores
    ui/              widgets genéricos
    location/        posição do dispositivo
  screens/
    public/          ecrãs sem sessão e rota inexistente
    account/         ecrãs comuns ao Cliente e ao Prestador
    client/          ecrãs do Cliente
    provider/        ecrãs do Prestador de Serviços
  utils/             funções sem widgets
```
