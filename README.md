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

## Testes de sistema

Os testes de sistema (`integration_test/`) correm num **emulador Android 16 (API 36) com imagem Google APIs**
contra o sistema real: aplicação, backend e PostgreSQL 18. A única simulação é a do geocodificador externo
(Nominatim), substituído por um stub local (`tool/nominatim_stub.dart`) com coordenadas fixas.

- **Dados:** a base de dados é criada e reposta com os scripts de referência do backend
  (`database/repor-base-dados.sql`, RNF-19), cujos dados são só de leitura para os testes. Cada teste cria os
  restantes dados pela API documentada, com os helpers de `integration_test/support/api.dart` e e-mails
  únicos. Os testes não acedem diretamente à base de dados.
- **Teste de exemplo:** `integration_test/exemplo_backend_test.dart`.

### Execução local

Usar uma base de dados própria para os testes (nunca a `localhub_dev` nem a `localhub_test`). A partir da pasta
do repositório `backend`, na versão indicada em `BACKEND_REF` no `.github/workflows/ci.yml`:

```bash
# 1. Criar ou repor a base de dados dos testes
psql -U postgres -d postgres -v dbname=localhub_e2e -f database/repor-base-dados.sql

# 2. Arrancar o geocodificador simulado (a partir da pasta do frontend-mobile)
dart run tool/nominatim_stub.dart

# 3. Arrancar o backend apontado para a base dos testes e para o stub (a partir da pasta do backend)
ConnectionStrings__LocalHub="Host=localhost;Port=5432;Database=localhub_e2e;Username=localhub;Password=<palavra-passe>" \
Nominatim__BaseUrl="http://localhost:8089/" \
dotnet run --project src/LocalHub.Api

# 4. Com o emulador aberto, correr os testes (a partir da pasta do frontend-mobile)
flutter test integration_test
```

Os testes que usam as contas da base de referência recebem as palavras-passe com
`--dart-define=E2E_ADMIN_PASSWORD=...` (administrador) e `--dart-define=E2E_DEMO_PASSWORD=...` (cliente e
prestador), indicadas no README dos scripts da base de dados do backend.

### Pipeline (QG-07)

O job `frontend-mobile` do `.github/workflows/ci.yml`, depois da construção e da análise estática, arranca o
PostgreSQL 18, cria a base com os scripts de referência, arranca o stub e o backend na versão `BACKEND_REF`,
cria o emulador Android 16 (API 36, Google APIs) e corre o `integration_test`
(`.github/scripts/testes-sistema-mobile.sh`). Um teste falhado faz a pipeline falhar e bloqueia o merge. A
saída dos testes (texto e JSON), a identificação do dispositivo, o `logcat` e os registos do backend e do stub
ficam no artefacto `registos-testes-sistema-frontend-mobile`.

Segredos do repositório (Settings → Secrets and variables → Actions), nunca guardados no código:

| Segredo | Uso |
| --- | --- |
| `E2E_DB_PASSWORD` | Palavra-passe do PostgreSQL da pipeline e do utilizador `localhub`. |
| `E2E_JWT_SIGNING_KEY` | Chave de assinatura dos tokens do backend (mínimo de 32 caracteres). |
| `E2E_ADMIN_PASSWORD` | Palavra-passe do administrador da base de referência. |
| `E2E_DEMO_PASSWORD` | Palavra-passe do cliente e do prestador da base de referência. |

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
assets/fonts/        tipos de letra Figtree e Bricolage Grotesque (licença SIL OFL 1.1, ficheiros OFL-*.txt)
```
