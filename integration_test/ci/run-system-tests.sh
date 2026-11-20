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
# No fim, o registo do Android fica nas evidências (ex.: porque não chegou a posição)
trap 'kill "$geo_fix_pid" 2> /dev/null || true; adb logcat -d -v time > logs/logcat.txt 2>&1 || true' EXIT
sleep 5
adb shell dumpsys location > logs/localizacao.txt 2>&1 || true

# Entrada única dos testes de sistema, no emulador (-d), e não noutro dispositivo do runner
# (ex.: Linux desktop); a saída fica nos registos (evidência)
flutter test integration_test/app_test.dart -d "$(adb get-serialno)" --reporter expanded 2>&1 \
  | tee logs/integration_test.log
