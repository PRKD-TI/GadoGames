# GadoGames — Componentes Compartilhados (Shared Toolkit)

Esta pasta contém a base reutilizável para todos os jogos do estúdio **GadoGames**.

## 📦 Scripts Disponíveis (`shared/scripts/`)

1. **`gado_economy.gd` (`class_name GadoEconomy`)**:
   - Salva e gerencia o saldo de **GadoCoins (🪙)**.
   - Fornece sinais `coins_changed`, métodos `add_coins()` e `spend_coins()`.
   - Armazena dados criptografados em `user://gadocoin.dat`.

2. **`play_games_bridge.gd` (`class_name PlayGamesBridge`)**:
   - Abstração multiplataforma para o **Google Play Games Services (PGS v2)**.
   - Envia recordes (`submit_score`), abre placares (`show_leaderboard`), desbloqueia conquistas (`unlock_achievement`).
   - Faz fallback silencioso e seguro quando rodando na **Web (HTML5)** ou PC sem travar o jogo.

3. **`audio_manager.gd` (`class_name AudioManager`)**:
   - Gerencia BGM, SFX e Feedback Tátil / Vibração (`trigger_haptic()`).
   - Salva preferências de volume do jogador automaticamente em `user://audio_settings.cfg`.

## 🚀 Como Integrar em um Jogo

Basta copiar ou instanciar os scripts como **Autoloads (Singletons)** no `project.godot` do jogo:
* `GadoEconomy` -> `res://scripts/gado_economy.gd`
* `PlayGamesBridge` -> `res://scripts/play_games_bridge.gd`
* `AudioManager` -> `res://scripts/audio_manager.gd`
