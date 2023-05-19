#!/bin/bash

# Função para instalar APK nos emuladores
function install_apk() {
  local apk_path="$1"
  local emulators=("emulator-teste1" "emulator-teste2" "emulator-teste3")
  
  adb kill-server
  sleep 5
  adb start-server
  sleep 5

  for emulator in "${emulators[@]}"; do
    ~/Android/Sdk/emulator/emulator -avd "$emulator" -port 5556 -wipe-data -no-snapshot-save &
    sleep 30 # Aguardar o emulador iniciar
  done

  # Instalar APK com permissões de gravação no sdcard
  for port in 5556 5558 5560; do
    adb -s "emulator-$port" install -r -d -g "$apk_path"
    sleep 10 # Aguardar o emulador instalar
  done
}

# Função para executar o comando DroidBot nos emuladores
function run_droidbot() {
  local apk_path="$1"
  local output_dir="$2"
  local duration="7200" # 2 horas em segundos

  for port in 5556 5558 5560; do
    droidbot -a "$apk_path" -d "emulator-$port" -is_emulator -o "$output_dir/saida-droidbot-$port" -t "$duration" &
    sleep 5
  done
}

# Copiar o arquivo coverage.ec dos emuladores para a pasta local em momentos específicos
function copy_coverage_files() {
  local local_results_dir="$1"
  local emulator_port="$2"
  local coverage_dir="$local_results_dir/emulator_$emulator_port"

  # Copiar o arquivo coverage.ec do emulador para a pasta local
  adb -s "emulator-$emulator_port" pull /sdcard/coverage.ec "$coverage_dir"

  # Calcula os tempos em segundos para as cópias
  local duration_30=$((7200 * 30 / 100))   # 30% do tempo
  local duration_50=$((7200 * 50 / 100))   # 50% do tempo
  local duration_80=$((7200 * 80 / 100))   # 80% do tempo

  # Aguarda o tempo e faz as cópias nos momentos específicos
  sleep "$duration_30"
  adb -s "emulator-$emulator_port" pull /sdcard/coverage.ec "$coverage_dir/30_percent_coverage.ec"

  sleep $((duration_50 - duration_30))
  adb -s "emulator-$emulator_port" pull /sdcard/coverage.ec "$coverage_dir/50_percent_coverage.ec"

  sleep $((duration_80 - duration_50))
  adb -s "emulator-$emulator_port" pull /sdcard/coverage.ec "$coverage_dir/80_percent_coverage.ec"

  sleep $((7200 - duration_80))
  adb -s "emulator-$emulator_port" pull /sdcard/coverage.ec "$coverage_dir/final_coverage.ec"
}

# Caminhos e diretórios
apk_path="~/droidbot/experiments/apps/AtimeTrack.apk"
output_dir="~/droidbot/experiments"
local_results_dir="~/droidbot/experiments/results"

# Iniciar emuladores e instalar APK
install_apk "$apk_path"