#!/bin/bash

# Função para instalar APK nos emuladores
function install_apk() {
  local apk_path="$1"
  adb kill-server
  sleep 5
  adb start-server
  sleep 5

  # Iniciar emulador
  ~/Android/Sdk/emulator/emulator -avd emulator-teste1 -port 5556 -wipe-data -no-snapshot-save &
  sleep 30 # Aguardar o emulador iniciar
  ~/Android/Sdk/emulator/emulator -avd emulator-teste2 -port 5558 -wipe-data -no-snapshot-save &
  sleep 30 # Aguardar o emulador iniciar
  ~/Android/Sdk/emulator/emulator -avd emulator-teste3 -port 5560 -wipe-data -no-snapshot-save &
  sleep 30 # Aguardar o emulador iniciar


  # Instalar APK com permissões de gravação no sdcard
  adb -s emulator-5556 install -r -d -g ~/droidbot/experiments/apps/AtimeTrack.apk
  sleep 10 # Aguardar o emulador instalar
  adb -s emulator-5558 install -r -d -g ~/droidbot/experiments/apps/AtimeTrack.apk
  sleep 10 # Aguardar o emulador instalar
  adb -s emulator-5560 install -r -d -g ~/droidbot/experiments/apps/AtimeTrack.apk
  # adb -s emulator-5556 install -r -d -g ~/droidbot/experiments/apps/AtimeTrack.apk
  sleep 10 # Aguardar o emulador instalar
}

# Função para executar o comando DroidBot nos emuladores
function run_droidbot() {
  local apk_path="$1"
  local output_dir="$2"
  local duration="60" # 2 horas em segundos 7200

  for emulator_port in 5556 5558 5560; do
    # Executar o comando DroidBot nos emuladores
    droidbot -a ~/droidbot/experiments/apps/AtimeTrack.apk -d emulator-$emulator_port -is_emulator -o ~/droidbot/experiments/saida-droidbot-$emulator_port -t $duration &
    # droidbot -a ~/droidbot/experiments/apps/AtimeTrack.apk -d emulator-5556 -is_emulator -o ~/droidbot/experiments/saida-droidbot-5556

    sleep 5
  done
}

# Copiar o arquivo coverage.ec dos emuladores para a pasta local em momentos específicos
function copy_coverage_files() {
  local local_results_dir="$1"
  local emulator_port="$2"
  local coverage_dir="$local_results_dir/emulator_$emulator_port"

  # Copiar o arquivo coverage.ec do emulador para a pasta local
  adb -s emulator-$emulator_port pull /sdcard/coverage.ec "$coverage_dir"
  # adb -s emulator-5556 pull /sdcard/coverage.ec ~/droidbot/experiments/

  # Calcula os tempos em segundos para as cópias
  local duration_30=$((60 * 30 / 100))   # 30% do tempo
  local duration_50=$((60 * 50 / 100))   # 50% do tempo
  local duration_80=$((60 * 80 / 100))   # 80% do tempo

  # Aguarda o tempo e faz as cópias nos momentos específicos
  sleep $duration_30
  adb -s emulator-$emulator_port pull /sdcard/coverage.ec "$coverage_dir/30_percent_coverage.ec"

  sleep $((duration_50 - duration_30))
  adb -s emulator-$emulator_port pull /sdcard/coverage.ec "$coverage_dir/50_percent_coverage.ec"

  sleep $((duration_80 - duration_50))
  adb -s emulator-$emulator_port pull /sdcard/coverage.ec "$coverage_dir/80_percent_coverage.ec"

  sleep $((7200 - duration_80))
  adb -s emulator-$emulator_port pull /sdcard/coverage.ec "$coverage_dir/final_coverage.ec"
}

# Caminhos e diretórios
apk_path=droidbot/experiments/apps/AtimeTrack.apk
output_dir=droidbot/experiments
local_results_dir=droidbot/experiments/results

# Iniciar emuladores e instalar APK
install_apk "$apk_path"

# Executar o comando DroidBot nos emuladores
run_droidbot "$apk_path" "$output_dir"

# Aguardar 2 horas (7200 segundos)
sleep 7200

# Copiar o arquivo coverage.ec dos emuladores para a pasta local
for emulator_port in 5556 5558 5560; do
  copy_coverage_files "$local_results_dir" "$emulator_port"
done