# Changelog

Все значимые изменения проекта.
Формат: [Keep a Changelog](https://keepachangelog.com/ru/1.1.0/).
Версионирование: [SemVer](https://semver.org/lang/ru/).

## [v1.7.0] - 2026-09-29

### Added
- Zsh + Oh My Zsh installation
- zsh-completions, autosuggestions, syntax-highlighting plugins

### Fixed
- Typos in comments and echo messages

### Changed
- `.zshrc` now prompts before overwrite
- SHA256 verification for Oh My Zsh installer

## [v1.7.1] - 2026-09-29

### Fixed
- Syntax error with `|| true` in block 0.4
- Oh My Zsh installer now checks if already installed
- `|| true` added to pacman-key commands
