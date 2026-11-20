# GadoGames — Padrões de Projeto e Diretrizes de Desenvolvimento

Bem-vindo ao repositório central **GadoGames**. Este arquivo estabelece as regras de arquitetura, padrões de nomenclatura e fluxos de publicação para todos os jogos do estúdio.
Qualquer agente de IA (Antigravity/Gemini) ou desenvolvedor deve seguir rigorosamente estas diretrizes ao criar ou modificar jogos neste repositório.

---

## 1. Estrutura do Repositório (Monorepo)

O repositório `GadoGames` reúne todos os jogos satíricos e casuais do estúdio em subdiretórios independentes:

```text
GadoGames/
├── .agents/                    # Skills e ferramentas de automação
├── .gitignore                  # Regras globais de exclusão (chaves, builds)
├── AGENTS.md                   # Este arquivo de instruções
├── GEMINI.md                   # Link / espelho de instruções
├── PatriotaDoCaminhao/         # Jogo 1: Equilíbrio no para-choque
│   ├── assets/
│   ├── export_presets.cfg
│   ├── exports/                # Binários gerados (ignorado no git)
│   ├── playstore_assets/       # Ícone 512, banner 1024, textos e política
│   ├── project.godot
│   ├── scenes/
│   └── scripts/
├── RezarERodar/                # Jogo 2: Sátira do altar de pneu
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

## 3. Diretrizes de Arquitetura Multiplataforma (Web + Android)

Todo jogo no `GadoGames` é projetado para rodar simultaneamente na **Web (HTML5/Navegadores)** e no **Android (Google Play Store)** a partir da mesma base de código:

1. **Renderizador Obrigatório:**
   * Sempre usar `gl_compatibility` (OpenGL ES 3.0 / WebGL 2.0).
   * **Por quê:** Garante 60 FPS estáveis tanto em celulares modestos quanto em qualquer navegador sem necessidade de suporte a Vulkan.
2. **Display e Responsividade:**
   * Modo: `window/stretch/mode="canvas_items"`
   * Aspecto: `window/stretch/aspect="keep"`
   * Orientação: `window/handheld/orientation=1` (Sensor Landscape para jogos horizontais).
3. **Controles Dual/Híbridos:**
   * Todo jogo deve responder tanto a Teclado/Mouse (PC/Web) quanto a Touch e Sensores (Android/Mobile).
   * Quando houver suporte a inclinação (giroscópio/acelerômetro), incluir sempre um botão no HUD para ligar/desligar o sensor.

---

## 4. Requisitos de Build Android e Google Play Store

Conforme validado e estabelecido na publicação dos jogos do estúdio (ex: *Sliding Words*):

1. **Target SDK Obrigatório:**
   * **`compileSdk = 36`**
   * **`targetSdk = 36`** (Android 16 / exigência do Google Play Console)
   * **`minSdk = 24`** (Android 7.0+)
   * **`buildTools = '36.0.0'`**
2. **Símbolos Nativos de Depuração (NDK):**
   * Em `build.gradle`, o `buildTypes.release` deve conter:
     ```groovy
     ndk {
         debugSymbolLevel 'SYMBOL_TABLE'
     }
     ```
   * Isso evita o aviso da Play Store sobre código nativo sem símbolos de depuração.
3. **Versão do Java (JDK):**
   * Sempre usar **Java 17 (OpenJDK 17)** para compilar o Gradle do Godot 4.
4. **Formato de Publicação:**
   * Sempre gerar Android App Bundle (**`.aab`**) assinado com chave de release.

---

## 5. Padrão de Publicação e Assets para a Play Store

Cada subpasta de jogo deve conter um diretório `playstore_assets/` contendo:
* `playstore_icon_512x512.png`: Ícone oficial de alta resolução (512x512 px PNG 32-bit).
* `feature_graphic_1024x500.png`: Banner de destaque promocional da loja (1024x500 px).
* `politica_privacidade.html`: Declaração de privacidade do app (sem coleta invasiva de dados).
* `playstore_listing.txt`: Título, descrição curta, descrição completa e respostas dos formulários de conformidade do Google Play Console.

---

## 6. Segurança de Chaves e Repositório Git

> [!CAUTION]
> **NUNCA** commitar chaves de assinatura (`.keystore`, `.jks`), senhas ou tokens de API no Git.
> O arquivo `.gitignore` na raiz do repositório deve sempre bloquear `*.keystore`, `.jks` e pastas `exports/`.
