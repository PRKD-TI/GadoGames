# GadoGames — Padrões de Projeto e Diretrizes de Desenvolvimento

Bem-vindo ao repositório central **GadoGames**. Este arquivo estabelece as regras de arquitetura, padrões de nomenclatura, identidade visual, economia unificada e fluxos de publicação para todos os jogos do estúdio.
Qualquer agente de IA (Antigravity/Gemini) ou desenvolvedor deve seguir rigorosamente estas diretrizes ao criar ou modificar jogos neste repositório.

---

## 1. Estrutura do Repositório (Monorepo)

O repositório `GadoGames` reúne todos os jogos satíricos e casuais do estúdio em subdiretórios independentes, além de um diretório `shared/` para componentes e utilitários globais:

```text
GadoGames/
├── .agents/                    # Skills e ferramentas de automação
├── .gitignore                  # Regras globais de exclusão (chaves, builds)
├── AGENTS.md                   # Este arquivo de instruções
├── GEMINI.md                   # Link / espelho de instruções
├── shared/                     # Toolkit compartilhado do estúdio
│   ├── README.md
│   └── scripts/
│       ├── gado_economy.gd     # Gerenciador da moeda GadoCoin (🪙)
│       ├── play_games_bridge.gd# Ponte Google Play Games com fallback Web
│       └── audio_manager.gd    # Áudio e feedback tátil/haptic
├── PatriotaDoCaminhao/         # Jogo 1: Equilíbrio no para-choque
│   ├── assets/
│   ├── export_presets.cfg
│   ├── exports/                # Binários gerados (ignorado no git)
│   ├── playstore_assets/       # Ícone 512, banner 1024, textos e política
│   ├── project.godot
│   ├── scenes/
│   └── scripts/
├── RezarERodar/                # Jogo 2: Sátira do altar de pneu
├── AloNaveMae/                 # Jogo 3: Vigília cósmica e Simon Says alienígena
├── MotociataTurbo/             # Jogo 4: Corrida de física 2D e liderança do comboio
├── EfeitoJacare/               # Jogo 5: Fuga de vacinas com Cloroquina e rampage de Jacaré
├── EmaDoAlvorada/              # Jogo 6: Defesa e bicadas no Palácio
├── HistoricoDeAtleta/          # Jogo 7: Corrida de obstáculos e flexões
├── ZapDoGeneral/               # Jogo 8: Gerenciamento e disparo de correntes
└── [ProximoJogo]/              # Novos jogos seguem o mesmo padrão
```

---

## 2. Convenções de Nomenclatura (Naming Conventions)

Para manter o código limpo, consistente e alinhado aos padrões da indústria e da Godot Engine:

| Elemento | Convenção | Exemplo |
| :--- | :--- | :--- |
| **Pastas de Jogos** | `PascalCase` | `PatriotaDoCaminhao`, `RezarERodar` |
| **Arquivos de Script** | `snake_case.gd` | `game_manager.gd`, `truck_controller.gd` |
| **Nomes de Classes** | `PascalCase` | `class_name GameManager`, `class_name TruckController` |
| **Arquivos de Cena** | `snake_case.tscn` | `main.tscn`, `hud.tscn` |
| **Nós na Cena (Scene Tree)** | `PascalCase` | `TopBar`, `TimerLabel`, `CameraBtn` |
| **Variáveis e Funções** | `snake_case` | `current_speed`, `get_tilt_input()` |
| **Constantes e Enums** | `UPPER_SNAKE_CASE` | `MAX_SPEED`, `GameState.PLAYING` |
| **Sinais (Signals)** | `snake_case` (passado) | `flag_earned`, `fell_off`, `camera_switched` |
| **Package Name Android** | `com.gadogames.<nome>` | `com.gadogames.patriotadocaminhao` |

---

## 3. Padrão Visual e de Display (Modo Paisagem Obrigatório)

> [!IMPORTANT]
> **Todos os jogos do GadoGames devem ser desenvolvidos exclusivamente em MODO PAISAGEM (Landscape).**

No arquivo `project.godot` de cada jogo:
1. **Resolução Base de Design:**
   * Largura: `1280` px | Altura: `720` px (16:9 HD standard).
   * Garante 60 FPS estáveis tanto em celulares modestos quanto em navegadores Web.
2. **Modo de Redimensionamento:**
   * `window/stretch/mode="canvas_items"`
   * `window/stretch/aspect="keep"` (com safe margin para não cortar botões em telas 20:9 ultrawide).
3. **Orientação:**
   * `window/handheld/orientation=4` (**Sensor Landscape**).
   * **Atenção:** `orientation=4` permite ao jogador girar o aparelho 180° mantendo o jogo na horizontal (facilitando uso com fone ou cabo de carregador). NUNCA usar `1` (Portrait).
4. **Renderizador:**
   * Sempre usar `gl_compatibility` (OpenGL ES 3.0 / WebGL 2.0).

---

## 4. Economia Unificada: GadoCoin (🪙)

Todos os jogos compartilham a mesma moeda satírica de recompensa: a **GadoCoin (`🪙`)**.

* **Origem:** Gerenciada pela classe `GadoEconomy` (`shared/scripts/gado_economy.gd`).
* **Como o jogador ganha:**
  * Recompensa de desempenho na partida (tempo vivo, distância, pontos).
  * Conquistas cumpridas (ex: 72 horas no caminhão = +100 GadoCoins).
* **Para que serve:**
  * Desbloqueio de cosméticos e skins satíricas (chapéus, capas, pneus cromados, cores especiais).
  * Segunda chance / Reviver uma vez por partida ("Pagar 50 GadoCoins ou assistir anúncio").
* **Interface:**
  * O topo da tela (TopBar) de todos os jogos deve exibir o saldo: `[ 🪙 1.250 ]`.

---

## 5. Google Play Games Services (PGS v2) & Login

Os jogos contam com integração oficial aos serviços de jogos do Google através da ponte `PlayGamesBridge` (`shared/scripts/play_games_bridge.gd`):

1. **Login 100% Opcional:**
   * O jogador **nunca** é obrigado a fazer login para jogar. Partidas offline e saldos locais sempre funcionam.
   * Se o jogador quiser sincronizar pontuação e competir no ranking mundial, clica no botão 🏆 **"Ranking Global"** ou 👤 **"Conectar Google"**.
2. **Placares (Leaderboards):**
   * Cada jogo publica suas maiores pontuações/tempos na sua tabela oficial do Google Play Games.
   * Botão nativo de ranking no Game Over e no Menu Principal.
3. **Conquistas (Achievements):**
   * Conquistas bem-humoradas e satíricas desbloqueiam a notificação oficial verde do Play Games e concedem bônus de GadoCoins.
4. **Compatibilidade Multiplataforma (Web vs Android):**
   * A ponte `PlayGamesBridge` detecta automaticamente a plataforma. Na Web (HTML5) ou Desktop, ela opera em modo seguro sem erros e mantém o recorde localmente.

---

## 6. Identidade de Franquia & Experiência de Usuário (HUD, Áudio e Haptic)

Para que o usuário sinta que está jogando títulos da mesma produtora:

1. **Vinheta de Abertura (Splash):**
   * Tela rápida de ~2 segundos com o logotipo do **GadoGames** e o efeito sonoro oficial de abertura antes da tela de título.
2. **TopBar Universal:**
   * Canto superior: Saldo de GadoCoins `[ 🪙 ]`, Botão de Mudo/Áudio e Botão de Pausa/Configurações.
3. **Tela de Game Over Padronizada:**
   * Exibição clara de: Pontuação Atual, Melhor Pontuação (Recorde), GadoCoins Ganhos na rodada, Botão "Jogar Novamente" e Botão "🏆 Ranking".
4. **Feedback Tátil (Haptic / Vibração):**
   * Via `AudioManager.trigger_haptic(40)`. Pulsos curtos e satisfatórios ao clicar em botões, desviar no último segundo ou bater recorde. Configurável nas opções para quem preferir desativar.

---

## 7. Requisitos de Build Android e Google Play Store

Conforme validado e estabelecido no estúdio:

1. **Target SDK Obrigatório:**
   * **`compileSdk = 36`**
   * **`targetSdk = 36`** (Android 16 / exigência do Google Play Console)
   * **`minSdk = 24`** (Android 7.0+)
   * **`buildTools = '36.0.0'`**
2. **Versionamento Estrito:**
   * Toda nova submissão no Play Console exige **`versionCode` estritamente incremental** (`1`, `2`, `3`...).
3. **Versão do Java (JDK):**
   * Sempre usar **Java 17 (OpenJDK 17)** para compilar o Gradle do Godot 4.
4. **Formato de Publicação:**
   * Sempre gerar Android App Bundle (**`.aab`**) assinado com chave de release.
5. **Hardware Opcional no AndroidManifest (Evitar Restrições):**
   ```xml
   <uses-feature android:name="android.hardware.screen.portrait" android:required="false" />
   <uses-feature android:name="android.hardware.screen.landscape" android:required="false" />
   <uses-feature android:name="android.hardware.touchscreen" android:required="false" />
   <uses-feature android:name="android.hardware.sensor.accelerometer" android:required="false" />
   ```

---

## 8. Tratamento de Avisos do Google Play Console (Warnings vs Errors)

* **Aviso de Desofuscação (R8 / ProGuard / mapping.txt):** Manter `minifyEnabled false`. É apenas informativo e não bloqueia lançamentos.
* **Aviso de Símbolos Nativos (NDK / SYMBOL_TABLE):** Os templates oficiais Godot já vêm com binários estripados (~25MB). Mantemos `ndk { debugSymbolLevel 'SYMBOL_TABLE' }`. O aviso é puramente consultivo e pode ser ignorado.

---

## 9. Segurança e CI/CD

> [!CAUTION]
> **NUNCA** commitar chaves de assinatura (`.keystore`, `.jks`), senhas ou arquivos de credenciais JSON do Google Cloud no Git.
> O arquivo `.gitignore` global bloqueia `*.keystore`, `.jks`, `.json` de credenciais e pastas `exports/`.
