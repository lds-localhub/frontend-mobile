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

# Entrada única dos testes de sistema, no emulador (-d), e não noutro dispositivo do runner
# (ex.: Linux desktop); a saída fica nos registos (evidência)
flutter test integration_test/app_test.dart -d "$(adb get-serialno)" --reporter expanded 2>&1 \
  | tee logs/integration_test.log

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

# O modo de avião é desligado no fim, mesmo que o teste falhe
trap 'adb shell cmd connectivity airplane-mode disable' EXIT
adb shell cmd connectivity airplane-mode enable
flutter test integration_test/ts_mob_15_rede_indisponivel.dart -d "$(adb get-serialno)" \
  --reporter expanded \
  --dart-define=TS_MOB_15_TOKEN="$token" --dart-define=TS_MOB_15_EMAIL="$email" 2>&1 \
  | tee logs/ts_mob_15.log
