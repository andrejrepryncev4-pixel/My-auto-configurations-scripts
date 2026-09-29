# My Auto-Configuration Scripts

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![Omarchy](https://img.shields.io/badge/Omarchy-only-blueviolet)

Мои скрипты для автоматической настройки систем.  
Делаю **для себя** — но если зайдёт, пользуйся.

---

## Скрипты

### `Omarchy-setup-script.sh` (v1.6.1)

Пост-установочная настройка **Omarchy**.

#### Что делает

- ✅ Проверка системы (**Omarchy**) + снапшот через `snapper`
- ✅ Логирование в `~/omarchy-setup-*.log`
- ✅ Автодетект **GPU** (NVIDIA / AMD / Intel), **Wi-Fi**, **Bluetooth**
- ✅ Бэкап `~/.config` → `~/.config.bak`
- ✅ Настройка раскладки **US/RU**, темы **Nord**, **Hyprland**
- ✅ Удаление bloatware + web-приложений
- ✅ Установка **Firefox**, **Steam**, **Wine**, **Docker**, **virt-manager**
- ✅ AUR-пакеты через `yay`
- ✅ Зависимости для **Qylock** (SDDM, Qt5/6, GStreamer)

## Что НЕ делает

- Не ставит графические драйверы для неизвестных GPU
- Не настраивает сеть (только ставит утилиты)
- Не трогает загрузчик, если не найден `limine-entry-tool`

#### Требования

- **Omarchy**
- `snapper` с конфигом `root`
- Интернет
- Запуск **от обычного пользователя** (не root)
- 
![Last commit](https://img.shields.io/github/last-commit/andrejrepryncev4-pixel/My-auto-configurations-scripts)

#### Запуск

```bash
chmod +x Omarchy-setup-script.sh
./Omarchy-setup-script.sh

