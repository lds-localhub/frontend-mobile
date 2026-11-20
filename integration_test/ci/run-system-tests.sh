#!/usr/bin/env bash
# Corre os testes de sistema no emulador Android (pipeline, I093, QG-07).
# Chamado pelo reactivecircus/android-emulator-runner depois de o emulador arrancar.
# O backend e o stub do Nominatim já estão a correr no runner (10.0.2.2 no emulador).
set -euo pipefail

mkdir -p logs
package=pt.ipp.localhub
device="$(adb get-serialno)"

# O modo de avião (TS-MOB-15) é sempre desligado no fim, mesmo que um teste falhe
trap 'adb shell cmd connectivity airplane-mode disable || true' EXIT

# Identificação do ambiente (RNF-11): versão do Android, nível de API, imagem e arquitetura
{
  echo "Android: $(adb shell getprop ro.build.version.release)"
  echo "API: $(adb shell getprop ro.build.version.sdk)"
  echo "Imagem: $(adb shell getprop ro.product.name)"
  echo "Arquitetura: $(adb shell getprop ro.product.cpu.abi)"
} | tee logs/emulador.txt

# 1. TS-MOB-14, caso 2: a aplicação acabada de instalar ainda não tem a permissão de
# localização, por isso a janela da aplicação (M06) aparece
adb uninstall "$package" > /dev/null 2>&1 || true
flutter test integration_test/ts_mob_14_permissao_recusada.dart -d "$device" \
  --reporter expanded 2>&1 | tee logs/ts_mob_14_permissao_recusada.log

# 2. Restantes testes, com a permissão de localização: a aplicação é reinstalada com as
# permissões dadas (-g) e o flutter test seguinte só a substitui, o que as mantém.
# Posição do dispositivo na Rua das Flores (Porto), a morada "carla" do stub (longitude latitude)
adb install -r -g build/app/outputs/flutter-apk/app-debug.apk
adb shell cmd location set-location-enabled true
adb emu geo fix -8.6110 41.1496
timeout 20m flutter test integration_test/app_test.dart -d "$device" \
  --reporter expanded 2>&1 | tee logs/integration_test.log

# 3. TS-MOB-15 (RNF-23): sem rede, o teste não consegue preparar dados, por isso o Cliente
# é criado antes, pela API (E01, E02), e o token e o e-mail passam ao teste
api=http://localhost:5041/api
email="cliente.rede.$(date +%s)@localhub.test"
password=Teste2026
curl -sSf -X POST "$api/auth/register" -H 'Content-Type: application/json' \
  -d "{\"name\":\"Cliente sem rede\",\"email\":\"$email\",\"password\":\"$password\",\"role\":\"CLIENT\"}" \
  > /dev/null
token=$(curl -sSf -X POST "$api/auth/login" -H 'Content-Type: application/json' \
  -d "{\"email\":\"$email\",\"password\":\"$password\",\"client\":\"MOBILE\"}" | jq -r .token)

adb shell cmd connectivity airplane-mode enable
timeout 5m flutter test integration_test/ts_mob_15_rede_indisponivel.dart -d "$device" \
  --reporter expanded \
  --dart-define=TS_MOB_15_TOKEN="$token" --dart-define=TS_MOB_15_EMAIL="$email" 2>&1 \
  | tee logs/ts_mob_15.log
