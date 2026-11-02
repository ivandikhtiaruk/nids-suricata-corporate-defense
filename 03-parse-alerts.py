#!/usr/bin/env python3
# ==============================================================================
# Скрипт: 03-parse-alerts.py
# Призначення: Моніторинг та кольоровий парсинг журналу тривог EVE JSON
# ==============================================================================

import json
import os
import sys

LOG_FILE = "/var/log/suricata/eve.json"

RED = "\033[91m"
YELLOW = "\033[93m"
GREEN = "\033[92m"
CYAN = "\033[96m"
RESET = "\033[0m"

def main():
    print(f"{CYAN}======================================================================={RESET}")
    print(f"{CYAN}       ОПЕРАТИВНИЙ МОНІТОРИНГ ТРИВОГ NIDS SURICATA (EVE JSON)         {RESET}")
    print(f"{CYAN}======================================================================={RESET}")

    if not os.path.exists(LOG_FILE):
        print(f"{YELLOW}[!] Файл журналу {LOG_FILE} ще не створено.{RESET}")
        print(f"{YELLOW}[!] Очікування запуску сенсора або перших пакетів...{RESET}")
        return

    alert_count = 0
    with open(LOG_FILE, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            try:
                data = json.loads(line.strip())
                if data.get("event_type") == "alert":
                    alert_count += 1
                    t = data.get("timestamp", "")[:19].replace("T", " ")
                    alert = data.get("alert", {})
                    src = f"{data.get('src_ip')}:{data.get('src_port')}"
                    dst = f"{data.get('dest_ip')}:{data.get('dest_port')}"
                    msg = alert.get("signature", "Unknown attack")
                    severity = alert.get("severity", 3)

                    col = RED if severity == 1 else (YELLOW if severity == 2 else GREEN)

                    print(f"[{t}] {col}[SEV {severity}]{RESET} {msg}")
                    print(f"       Вектор: {src} -> {dst}")
                    print("-" * 71)
            except json.JSONDecodeError:
                continue

    print(f"\n{GREEN}[+] Усього зафіксовано тривог у журналі: {alert_count}{RESET}")

if __name__ == "__main__":
    main()
