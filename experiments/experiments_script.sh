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
  adb -s emulator-5556 install -r -d -g $apk_path
  sleep 10 # Aguardar o emulador instalar

  adb -s emulator-5558 install -r -d -g $apk_path
  sleep 10 # Aguardar o emulador instalar

  adb -s emulator-5560 install -r -d -g $apk_path
  sleep 10 # Aguardar o emulador instalar
}

# Função para executar o comando DroidBot nos emuladores
function run_droidbot() {
  local apk_path="$1"
  local output_dir="$2"


  droidbot -a $apk_path -d emulator-5556 -is_emulator -o $output_dir/saida-droidbot-5556 -t 7200 &
  sleep 5

 # droidbot -a ~/droidbot/experiments/apps/AtimeTrack.apk -d emulator-5558 -is_emulator -o ~/droidbot/experiments/saida-droidbot-5558 -t 60 &
  droidbot -a $apk_path -d emulator-5558 -is_emulator -o $output_dir/saida-droidbot-5558 -t 7200 &
  sleep 5

#  droidbot -a ~/droidbot/experiments/apps/AtimeTrack.apk -d emulator-5560 -is_emulator -o ~/droidbot/experiments/saida-droidbot-5560 -t 60 &
  droidbot -a $apk_path -d emulator-5560 -is_emulator -o $output_dir/saida-droidbot-5560 -t 7200 &
  sleep 5

}

function copy_coverage_files(){
  local local_results_dir="$1"
  local emulator_port="$2"
  local coverage_dir="$local_results_dir/emulator_$emulator_port"

  adb -s emulator-$emulator_port pull /sdcard/coverage.ec $local_results_dir/final_coverage-$emulator_port-AtimeTrack.ec
  
}


# Caminhos e diretórios
apk_name=AtimeTrack
apk_path=~/droidbot/experiments/apps/$apk_name.apk
output_dir=~/droidbot/experiments/output/$apk_name
local_results_dir=~/droidbot/experiments/results_cov

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