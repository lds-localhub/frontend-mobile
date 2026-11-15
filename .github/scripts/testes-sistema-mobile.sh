#!/usr/bin/env bash
# Testes de sistema do frontend mobile (QG-07, I093), executados pela pipeline
# com o emulador Android 16 (API 36) já ligado e o backend a correr.
# Os registos ficam em resultados-testes-sistema/ (artefacto da execução).
set -euo pipefail

resultados=resultados-testes-sistema
mkdir -p "$resultados"

# Identificação do dispositivo (versão do Android, API e imagem do sistema)
{
  echo "Android $(adb shell getprop ro.build.version.release | tr -d '\r') (API $(adb shell getprop ro.build.version.sdk | tr -d '\r'))"
  echo "Imagem: $(adb shell getprop ro.build.fingerprint | tr -d '\r')"
  echo "Modelo: $(adb shell getprop ro.product.model | tr -d '\r')"
} | tee "$resultados/dispositivo.txt"
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  echo "**Dispositivo:** $(head -1 "$resultados/dispositivo.txt") · **Backend:** ${BACKEND_REF:-}" >> "$GITHUB_STEP_SUMMARY"
fi

# Começa o registo do Android do zero, para ficar só o desta execução
adb logcat -c

# Testes de sistema; o código de saída do flutter test é o do script
estado=0
flutter test integration_test \
  --reporter expanded \
  --file-reporter "json:$resultados/integration-test.json" \
  --dart-define="E2E_ADMIN_PASSWORD=${E2E_ADMIN_PASSWORD:-}" \
  --dart-define="E2E_DEMO_PASSWORD=${E2E_DEMO_PASSWORD:-}" \
  2>&1 | tee "$resultados/integration-test.log" || estado=$?

adb logcat -d > "$resultados/logcat.txt" || true

exit "$estado"
