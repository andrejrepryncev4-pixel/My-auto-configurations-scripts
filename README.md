# Omarchy Setup Script

Мой персональный скрипт для настройки Omarchy после установки.
Делает то, что **я** хочу — а не то, что «должно быть по умолчанию».

## Что делает

- Проверяет, что система — Omarchy
- Делает снапшот через snapper
- Логирует всё в `~/omarchy-setup-YYYYMMDD-HHMMSS.log`
- Проверяет интернет
- Включает multilib (Steam, Wine 32-bit)
- Автодетект GPU (NVIDIA / AMD / Intel) → ставит драйверы
- Автодетект Wi-Fi / Bluetooth → ставит утилиты
- Бэкапит `~/.config` в `~/.config.bak`
- Настраивает раскладку US/RU с Alt+Shift
- Настраивает прозрачность и анимации Hyprland
- Ставит тему Nord
- Удаляет bloatware (chromium, obs-studio, kdenlive, ...)
- Удаляет web-приложения (hey, basecamp, chatgpt, ...)
- Ставит Firefox, Steam, Wine, qBittorrent, virt-manager, Docker...
- Ставит AUR-пакеты через yay
- Ставит зависимости для Qylock (SDDM, Qt5/Qt6, GStreamer)

## Требования

- **Omarchy** (проверяется в скрипте)
- **snapper** с настроенным конфигом `root`
- **Интернет**
- Запуск **от обычного пользователя**, не от root

## Запуск

```bash
chmod +x Omarchy-setup-script.sh
./Omarchy-setup-script.sh
