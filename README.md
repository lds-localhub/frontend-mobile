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

O contacto de suporte mostrado no início de sessão configura-se da mesma forma (`--dart-define=SUPPORT_EMAIL=...`; por omissão, `suporte@localhub.test`). Tem de ser o mesmo que o backend usa na mensagem de conta desativada.

## Comunicação com o backend

Todos os pedidos passam pela função `api()` (`lib/api/api_client.dart`): usa o URL base configurado, envia o token da sessão (`Authorization: Bearer`) e converte as respostas de erro (Problem Details) em `ApiError`, com a mensagem `detail` e os erros por campo `errors`. Um 401 fora do início de sessão termina a sessão e leva ao ecrã de início de sessão. O token fica no armazenamento seguro do dispositivo (`lib/api/session.dart`) e é apagado ao terminar a sessão. Sem ligação ao backend, os ecrãs mostram «Não foi possível contactar o servidor. Tente novamente.» (`lib/utils/errors.dart`).

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
| `./integration_test/ci/run-system-tests.sh` | Testes de sistema no emulador, com o backend e o stub do Nominatim a correr (ver [Testes de sistema](#testes-de-sistema)). |
| `flutter build apk --debug` | Gera o APK de debug em `build/app/outputs/flutter-apk/`. |

## Testes unitários

Os testes unitários (`test/utils/`) correm com:

```bash
flutter test test/utils
```

A pipeline não os corre: são executados antes de cada push pelo hook versionado `.githooks/pre-push`, que cancela o push se algum falhar. Ativação, uma vez por clone:

```bash
git config core.hooksPath .githooks
```

## Testes de sistema

Os testes de sistema (`integration_test/`, quality gate QG-07) correm num emulador Android 16 (API 36) contra o backend real e um geocodificador simulado (stub do Nominatim). Na pipeline, o job `testes-sistema-mobile` monta este ambiente sozinho. Localmente, são precisos quatro passos.

**1. Base de dados de teste.** No clone do backend, na tag `v1.1.0`, cria (ou repõe) uma base só para os testes:

```bash
psql -U postgres -d postgres -v dbname=localhub_e2e -f database/repor-base-dados.sql
```

Nunca usar a `localhub_dev` nem a `localhub_test`: os testes deixam lá as contas que criam. O utilizador `localhub` tem de existir (`database/README.md` do backend, secção 2).

**2. Stub do Nominatim.** Num terminal próprio, neste repositório:

```bash
node integration_test/stubs/nominatim-stub.mjs
```

Fica em `http://localhost:8089/` e só conhece as moradas de `integration_test/stubs/addresses.json`.

**3. Backend.** Num terminal próprio, no clone do backend, apontado para a base de teste e para o stub. As restantes chaves (`Jwt:SigningKey`, `Seed:DefaultPassword`) vêm do `appsettings.Development.json` do backend.

```bash
# Git Bash
ConnectionStrings__LocalHub="Host=localhost;Port=5432;Database=localhub_e2e;Username=localhub;Password=<palavra-passe>" \
Nominatim__BaseUrl="http://localhost:8089/" \
dotnet run --project src/LocalHub.Api --launch-profile http
```

```powershell
# PowerShell
$env:ConnectionStrings__LocalHub = "Host=localhost;Port=5432;Database=localhub_e2e;Username=localhub;Password=<palavra-passe>"
$env:Nominatim__BaseUrl = "http://localhost:8089/"
dotnet run --project src/LocalHub.Api --launch-profile http
```

Está pronto quando `http://localhost:5041/api/health` responder `Healthy`.

**4. Testes.** Com o emulador Android 16 aberto, com a imagem base do Android (`default`, sem Google Play Services), como na pipeline:

```bash
./integration_test/ci/run-system-tests.sh
```

Com a imagem Google APIs, o pedido da posição do dispositivo abre uma janela do sistema a pedir para ligar a precisão da localização da Google, que os testes não conseguem fechar, e o caso 1 do TS-MOB-14 falha.

É o mesmo script da pipeline:

1. Fixa a posição do dispositivo e regista a versão do Android em `logs/emulador.txt`.
2. Desinstala a aplicação e corre o caso sem permissão de localização do TS-MOB-14 (`integration_test/ts_mob_14_permissao_recusada.dart`), com a saída em `logs/ts_mob_14_permissao_recusada.log`.
3. Reinstala a aplicação com as permissões dadas (`adb install -r -g`) e regista-as em `logs/permissao-localizacao.txt`.
4. Liga a localização do emulador e reenvia a posição de 3 em 3 segundos enquanto os testes correm (estado em `logs/localizacao.txt`).
5. Corre `flutter test integration_test/app_test.dart` no emulador e guarda a saída em `logs/integration_test.log`. No fim, o registo do Android fica em `logs/logcat.txt`.

### Regras para escrever testes de sistema

- **Entrada única:** `integration_test/app_test.dart` importa todos os testes, para a aplicação ser compilada e instalada uma só vez. Cada teste novo fica num ficheiro `integration_test/ts_mob_NN_<nome>.dart`, com uma função que é registada num `group` em `app_test.dart`.
- **Dados pela API:** os dados de cada teste são criados com os helpers de `integration_test/helpers/` (`registerAndLogin`, `createProviderWithProfile`, …), com `client: "MOBILE"`. Nunca por SQL.
- **Dados acumulados:** a base só é reposta uma vez por execução. Os dados de referência (`database/README.md` do backend) são só de leitura, e cada teste encontra as suas contas pelo nome, que é único; nunca depende do total de resultados de uma pesquisa.
- **Moradas:** usar só as de `testAddresses` (`integration_test/helpers/addresses.dart`). Uma morada nova tem de ser acrescentada a `addresses.dart` e a `integration_test/stubs/addresses.json` (e à cópia do stub no repositório `frontend-web`).

## Organização das pastas

A estrutura segue o Modelo de Classes do frontend mobile v03:

```
lib/
  main.dart          arranque da aplicação (sessão, Riverpod, tema, português e router)
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
integration_test/
  app_test.dart      entrada única dos testes de sistema
  helpers/           preparação de dados pela API e moradas de teste
  stubs/             stub do Nominatim e tabela de moradas
  ci/                script que corre os testes no emulador (pipeline e local)
assets/fonts/        tipos de letra Figtree e Bricolage Grotesque (licença SIL OFL 1.1, ficheiros OFL-*.txt)
```
