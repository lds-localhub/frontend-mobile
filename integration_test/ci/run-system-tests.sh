#!/usr/bin/env bash
# Corre os testes de sistema no emulador Android (pipeline, I093, QG-07).
# Chamado pelo reactivecircus/android-emulator-runner depois de o emulador arrancar.
# O backend e o stub do Nominatim já estão a correr no runner (10.0.2.2 no emulador).
set -euo pipefail

mkdir -p logs

# Posição fixa do dispositivo: coordenadas da morada "carla" do stub (longitude latitude)
adb emu geo fix -8.6110 41.1496

# Identificação do ambiente (RNF-11): versão do Android, nível de API e modelo
{
  echo "Android: $(adb shell getprop ro.build.version.release)"
  echo "API: $(adb shell getprop ro.build.version.sdk)"
  echo "Imagem: $(adb shell getprop ro.product.name)"
  echo "Arquitetura: $(adb shell getprop ro.product.cpu.abi)"
} | tee logs/emulador.txt

# TS-MOB-14, caso 2 (I110): primeiro, com a aplicação acabada de instalar e ainda sem a
# permissão de localização, para a janela da aplicação (M06) aparecer
package=pt.ipp.localhub
adb uninstall "$package" > /dev/null 2>&1 || true
flutter test integration_test/ts_mob_14_permissao_recusada.dart -d "$(adb get-serialno)" \
  --reporter expanded 2>&1 | tee logs/ts_mob_14_permissao_recusada.log

# Os restantes testes correm com a permissão de localização (TS-MOB-14, caso 1): a aplicação
# é reinstalada com as permissões dadas (-g), e o flutter test seguinte só a substitui (-r),
# o que mantém as permissões
adb install -r -g build/app/outputs/flutter-apk/app-debug.apk
adb shell dumpsys package "$package" | grep -E 'ACCESS_(FINE|COARSE)_LOCATION: granted=true' \
  | tee logs/permissao-localizacao.txt

# Localização do emulador ligada e a posição da Rua das Flores (Porto) reenviada de 3 em 3
# segundos durante os testes (TS-MOB-14, caso 1): enviada só no arranque, já não chega
# quando a aplicação a pede, minutos depois. O ciclo pára no fim, mesmo que um teste falhe
adb shell cmd location set-location-enabled true
( while true; do adb emu geo fix -8.6110 41.1496; sleep 3; done ) > /dev/null 2>&1 &
geo_fix_pid=$!
# O registo do Android é gravado à medida, para ficar nas evidências mesmo que o trabalho seja
# cancelado a meio (ex.: porque não chegou a posição, ou porque os testes não arrancaram)
adb logcat -v time > logs/logcat.txt 2>&1 &
logcat_pid=$!
trap 'kill "$geo_fix_pid" "$logcat_pid" 2> /dev/null || true' EXIT
sleep 5
adb shell dumpsys location > logs/localizacao.txt 2>&1 || true

# Entrada única dos testes de sistema, no emulador (-d), e não noutro dispositivo do runner
# (ex.: Linux desktop); a saída fica nos registos (evidência). Com limite de tempo, para uma
# execução pendurada terminar com as evidências guardadas, antes do limite do trabalho
timeout 20m flutter test integration_test/app_test.dart -d "$(adb get-serialno)" \
  --reporter expanded 2>&1 | tee logs/integration_test.log

# TS-MOB-15 (RNF-23, I112): rede indisponível antes do pedido, à parte e no fim.
# Sem rede o teste não prepara dados: o Cliente é criado aqui, pela API (E01, E02),
# e o token e o e-mail passam ao teste
api=http://localhost:5041/api
email="cliente.rede.$(date +%s)@localhub.test"
password=Teste2026
curl -sSf -X POST "$api/auth/register" -H 'Content-Type: application/json' \
  -d "{\"name\":\"Cliente sem rede\",\"email\":\"$email\",\"password\":\"$password\",\"role\":\"CLIENT\"}" \
  > /dev/null
token=$(curl -sSf -X POST "$api/auth/login" -H 'Content-Type: application/json' \
  -d "{\"email\":\"$email\",\"password\":\"$password\",\"client\":\"MOBILE\"}" | jq -r .token)

# O modo de avião é desligado no fim, mesmo que o teste falhe. Este trap substitui o anterior,
# por isso também para o envio da posição e o registo do Android
trap 'adb shell cmd connectivity airplane-mode disable; kill "$geo_fix_pid" "$logcat_pid" 2> /dev/null || true' EXIT
adb shell cmd connectivity airplane-mode enable
timeout 5m flutter test integration_test/ts_mob_15_rede_indisponivel.dart -d "$(adb get-serialno)" \
  --reporter expanded \
  --dart-define=TS_MOB_15_TOKEN="$token" --dart-define=TS_MOB_15_EMAIL="$email" 2>&1 \
  | tee logs/ts_mob_15.log
