# My Auto-Configuration Scripts

Мои скрипты для автоматической настройки систем. Делаю для себя — но если зайдёт, пользуйся.

## Скрипты

### `Omarchy-setup-script.sh` (v1.6.1)

Пост-установочная настройка Omarchy.

**Что делает:**
- Проверка системы (Omarchy) + снапшот через snapper
- Логирование в `~/omarchy-setup-*.log`
- Автодетект GPU (NVIDIA/AMD/Intel), Wi-Fi, Bluetooth
- Бэкап `~/.config` → `~/.config.bak`
- Настройка раскладки US/RU, темы Nord, Hyprland
- Удаление bloatware + web-приложений
- Установка Firefox, Steam, Wine, Docker, virt-manager
- AUR-пакеты через yay
- Зависимости для Qylock (SDDM, Qt5/6, GStreamer)

**Требования:**
- Omarchy
- snapper с конфигом root
- Интернет
- Запуск от обычного пользователя (не root)

**Запуск:**
```bash
chmod +x Omarchy-setup-script.sh
./Omarchy-setup-script.sh

**Восстановление**

Если что-то пошло не так:

1. **Снапшот:** `sudo snapper list` → `sudo snapper undochange <N>..0`
2. **Бэкап конфигов:** `rm -rf ~/.config && mv ~/.config.bak ~/.config`
3. **Лог:** `cat ~/omarchy-setup-*.log`


## Лицензия

MIT — делай что хочешь, но без гарантий.
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
