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
├── AloNaveMae/                 # Jogo 3: Vigília cósmica e Simon Says alienígena
├── MotociataTurbo/             # Jogo 4: Corrida de física 2D e liderança do comboio
├── EfeitoJacare/               # Jogo 5: Fuga de vacinas com Cloroquina e rampage de Jacaré
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
   * Orientação: `window/handheld/orientation=0` (Landscape) ou `4` (Sensor Landscape para jogos horizontais). **Atenção:** `1` é Portrait na Godot Engine e NUNCA deve ser usado para jogos horizontais.
3. **Hardware Opcional no AndroidManifest (Evitar Restrições da Play Store):**
   * Declarar sempre com `android:required="false"` os recursos de tela e sensores no `AndroidManifest.xml` para não restringir Tablets, Chromebooks/Desktop, Google Play Games no PC e Android XR:
     ```xml
     <uses-feature android:name="android.hardware.screen.portrait" android:required="false" />
     <uses-feature android:name="android.hardware.screen.landscape" android:required="false" />
     <uses-feature android:name="android.hardware.touchscreen" android:required="false" />
     <uses-feature android:name="android.hardware.sensor.accelerometer" android:required="false" />
     ```
4. **Controles Dual/Híbridos:**
   * Todo jogo deve responder tanto a Teclado/Mouse (PC/Web) quanto a Touch e Sensores (Android/Mobile).
   * Quando houver suporte a inclinação (giroscópio/acelerômetro), incluir sempre um botão no HUD para ligar/desligar o sensor.

---

## 4. Requisitos de Build Android e Google Play Store

Conforme validado e estabelecido na publicação dos jogos do estúdio (ex: *Sliding Words* e *Patriota do Caminhão*):

1. **Target SDK Obrigatório:**
   * **`compileSdk = 36`**
   * **`targetSdk = 36`** (Android 16 / exigência do Google Play Console)
   * **`minSdk = 24`** (Android 7.0+)
   * **`buildTools = '36.0.0'`**
2. **Versionamento Estrito:**
   * Toda nova submissão/upload no Play Console exige um **`versionCode` estritamente incremental** (`1`, `2`, `3`...).
   * Se um upload de `versionCode 1` já tiver sido feito (mesmo como rascunho), o próximo deve ser `versionCode 2` (`versionName 1.0.1`).
3. **Versão do Java (JDK):**
   * Sempre usar **Java 17 (OpenJDK 17)** para compilar o Gradle do Godot 4 (Java 21 causa erro de compatibilidade no Gradle do Godot).
4. **Formato de Publicação:**
   * Sempre gerar Android App Bundle (**`.aab`**) assinado com chave de release.

---

## 5. Tratamento de Avisos do Google Play Console (Warnings vs Errors)

Ao fazer o upload de um `.aab` no Google Play Console, é comum receber **Avisos** (amarelos). É fundamental distinguir **Erros** (que bloqueiam o lançamento) de **Avisos informativos** (que podem ser ignorados sem risco):

### ⚠️ Aviso 1: Arquivo de Desofuscação (R8 / ProGuard / mapping.txt)
* **Texto da Google:** *"Não há um arquivo de desofuscação associado a este App Bundle. Se você usar o código ofuscado (R8/proguard)..."*
* **Significado e Procedimento Padrão:**
  * O Google Play apenas alerta que, **se** você usou ofuscação de código Java, seria bom enviar o arquivo `mapping.txt`.
  * Em jogos Godot (e jogos híbridos HTML5/WebView), a lógica principal roda em GDScript/C++ ou JavaScript. A camada Java existe apenas para hospedar a janela e inicializar o motor.
  * **Regra do Estúdio:** Mantemos a ofuscação Java desligada (`minifyEnabled false`), pois ativar ProGuard em Godot costuma quebrar a reflexão JNI e chamadas internas do motor (`org.godotengine.godot`).
  * **Conclusão:** **Ignorar este aviso com segurança.** Ele é puramente consultivo e não afeta o app.

### ⚠️ Aviso 2: Símbolos Nativos de Depuração (NDK / Native Crash Support)
* **Texto da Google:** *"Este App Bundle contém código nativo, e você não fez upload dos símbolos de depuração. Recomendamos que você faça upload..."*
* **Significado e Procedimento Padrão:**
  * Jogos Godot compilam bibliotecas nativas C++ (`libgodot_android.so`).
  * Os templates oficiais de exportação da Godot Engine já são distribuídos com binários estripados (`stripped`) para que o jogo tenha download rápido (~20MB a 30MB em vez de 300MB+ de símbolos DWARF).
  * No `build.gradle`, mantemos configurado:
    ```groovy
    ndk {
        debugSymbolLevel 'SYMBOL_TABLE'
    }
    ```
  * O aviso do Google Play é uma **recomendação opcional** para rastrear *crash dumps* com nomes de funções em C++ no painel do desenvolvedor.
  * **Conclusão:** **Ignorar este aviso com segurança.** Ele NÃO bloqueia a revisão, nem o teste fechado, nem o lançamento em produção. (Caso um dia seja necessário depurar um crash nativo raro em C++, pode-se baixar o arquivo zip de debug symbols correspondente à versão exata do Godot e fazer o upload manual do zip no painel).


---

## 6. Padrão de Publicação e Assets para a Play Store

Cada subpasta de jogo deve conter um diretório `playstore_assets/` contendo:
* `playstore_icon_512x512.png`: Ícone oficial de alta resolução (512x512 px PNG 32-bit).
* `feature_graphic_1024x500.png`: Banner de destaque promocional da loja (1024x500 px).
* `politica_privacidade.html`: Declaração de privacidade do app (sem coleta invasiva de dados).
* `playstore_listing.txt`: Título, descrição curta, descrição completa e respostas dos formulários de conformidade do Google Play Console.

---

## 7. Segurança de Chaves e Repositório Git

> [!CAUTION]
> **NUNCA** commitar chaves de assinatura (`.keystore`, `.jks`), senhas ou tokens de API no Git.
> O arquivo `.gitignore` na raiz do repositório deve sempre bloquear `*.keystore`, `.jks` e pastas `exports/`.

