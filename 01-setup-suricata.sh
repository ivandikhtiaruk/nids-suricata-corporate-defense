#!/usr/bin/env bash
# ==============================================================================
# Скрипт: 01-setup-suricata.sh
# Призначення: Автоматизоване встановлення та оптимізація сенсора NIDS Suricata
# Дисципліна: Комп'ютерні системи і мережі (Спеціальність 123)
# ==============================================================================

set -e

if [ "$EUID" -ne 0 ]; then
  echo "[-] Помилка: Запустіть скрипт із правами root (sudo)!"
  exit 1
fi

echo "[+] [1/5] Оновлення пакетів та встановлення залежностей..."
apt-get update -y
apt-get install -y software-properties-common curl wget ethtool jq

echo "[+] [2/5] Додавання офіційного репозиторію OISF Suricata..."
add-apt-repository -y ppa:oisf/suricata-stable
apt-get update -y
apt-get install -y suricata

echo "[+] [3/5] Оптимізація мережевого адаптера перехоплення (enp3s0)..."
ethtool -K enp3s0 rx off tx off gso off gro off || true
ip link set enp3s0 promisc on
ip link set enp3s0 up

echo "[+] [4/5] Застосування конфігураційних файлів..."
mkdir -p /etc/suricata/rules
cp configs/suricata.yaml /etc/suricata/suricata.yaml
cp configs/local.rules /etc/suricata/rules/local.rules

echo "[+] [5/5] Перевірка конфігурації та запуск служби..."
suricata -T -c /etc/suricata/suricata.yaml -v

systemctl daemon-reload
systemctl enable suricata
systemctl restart suricata

echo "=========================================================="
echo " [УСПІХ] Сенсор NIDS Suricata успішно розгорнуто!"
echo " Журнали подій: /var/log/suricata/fast.log та eve.json"
echo "=========================================================="
