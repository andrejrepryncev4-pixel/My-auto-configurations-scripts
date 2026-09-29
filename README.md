# My Auto-Configuration Scripts

![Omarchy](https://img.shields.io/badge/Omarchy-only-blueviolet)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Last commit](https://img.shields.io/github/last-commit/andrejrepryncev4-pixel/My-auto-configurations-scripts)

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
- Не настраивает Qylock сам — зависимости ставит, но тему выбираешь ты
- Не делает бэкап данных, только ~/.config

#### Требования

- **Omarchy**
- `snapper` с конфигом `root`
- Интернет
- Запуск **от обычного пользователя** (не root)

#### Установка

```bash
git clone https://github.com/andrejrepryncev4-pixel/My-auto-configurations-scripts.git
cd My-auto-configurations-scripts
```

#### Запуск

```bash
chmod +x Omarchy-setup-script.sh
./Omarchy-setup-script.sh
```
---

## Восстановление

Если что-то пошло не так:
## Восстановление

Если что-то пошло не так — не паникуй. Есть **три** **способа** откатить изменения.

### 1. Откат через снапшот (самый надёжный)

Перед запуском скрипт создаёт **снапшот** через `snapper`. Если что-то сломалось — откатывайся к нему.

**Посмотреть список снапшотов:**
```bash
sudo snapper list
```

**Откатить всё до снапшота `<N>`:**
```bash
sudo snapper undochange <N>..0
```

**Где `<N>`** — номер снапшота, созданного **перед** запуском скрипта (обычно самый **последний** в списке).

### 2. Восстановление конфигов из бэкапа

Скрипт **копирует** `~/.config` в `~/.config.bak` **перед** изменениями.

**Удалить сломанные конфиги:**
```bash
rm -rf ~/.config
```

**Вернуть бэкап на место:**
```bash
mv ~/.config.bak ~/.config
```

**Перезагрузить Hyprland:**
```bash
hyprctl reload
```

### 3. Посмотреть лог

Весь вывод скрипта **сохраняется** в `~/omarchy-setup-*.log`.

**Найти последний лог:**
```bash
ls -lt ~/omarchy-setup-*.log | head -n 1
```

**Прочитать его:**
```bash
cat ~/omarchy-setup-*.log
```

**Или** **открыть** **в** **редакторе:**
```bash
nano ~/omarchy-setup-*.log
```

---

**Если ничего не помогло** — заведи [issue](https://github.com/andrejrepryncev4-pixel/My-auto-configurations-scripts/issues) и **приложи** **лог**.
---

## Лицензия

**MIT** — делай что хочешь, но без гарантий.  
Подробнее в [LICENSE](LICENSE).

## Автор

**Andrejrepryncev-Pixel4**  
GitHub: [@andrejrepryncev4-pixel](https://github.com/andrejrepryncev4-pixel)
