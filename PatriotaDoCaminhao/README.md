# 🚚 Patriota do Caminhão 🇧🇷
*O jogo satírico de equilíbrio no para-choque de um caminhão em alta velocidade.*

Desenvolvido para **GadoGames** em **Godot 4.3** com arquitetura multiplataforma compatível tanto com **Navegadores (Web/HTML5/PWA)** quanto para a **Google Play Store (Android)**.

---

## 🎮 Mecânicas e Visões

### 1. Duas Câmeras em Tempo Real (Tecla `C` ou Botão na tela):
* **Visão de Dentro (Cabine do Motorista):**
  * Veja o volante virando, o velocímetro aumentando e os limpadores de para-brisa em movimento.
  * O Patriota fica pendurado com a cara no vidro encarando você com feições de determinação e desespero!
* **Visão de Fora (Frontal / Perseguição):**
  * O caminhão visto de frente com grade cromada, faróis acesos e as bandeirinhas do Brasil tremulando ao vento nos retrovisores.
  * O Patriota equilibrando o corpo e tentando não soltar as mãos da grade.

### 2. Dificuldade Progressiva e Conquistas Cômicas:
* **Início Suave (Primeiros 20 segundos):**
  * O caminhão começa mais lento (~45 km/h) e anda em linha reta nos primeiros segundos para você pegar o jeito.
  * Curvas bem leves e alta tolerância nas mãos para aprender os controles/sensores.
  * A partir de 20s, a velocidade dispara e os desvios ficam agressivos!
* **🇧🇷 Bandeirinhas da Pátria:**
  * A cada **10 segundos** de sobrevivência, você ganha uma bandeirinha do Brasil exibida em fileira no topo da tela com celebração!
* **🛞 O Sagrado Pneu de Caminhão:**
  * Se você resistir bravamente por **1 minuto (60 segundos)**, você desbloqueia o glorioso **Pneu de Caminhão** (com direito ao título supremo: *"Sacerdote do Pneu Sagrado"* e *"Reze para o Pneu!"*).

### 3. Controles:
* **No Computador / Web:**
  * `A` ou `Seta Esquerda`: Puxar/Equilibrar para a esquerda
  * `D` ou `Seta Direita`: Puxar/Equilibrar para a direita
  * `C` ou `Espaço`: Alternar entre Visão da Cabine e Visão Externa
  * `R` ou `Enter`: Reiniciar partida após a queda
* **No Celular / Touch & Sensores:**
  * **Sensor de Inclinação (Giroscópio / Acelerômetro):** Incline o celular para a esquerda ou direita para equilibrar o patriota naturalmente!
  * **Botão de Alternar Sensor:** `[📱 SENSOR: LIGADO / DESLIGADO]` no topo da tela para ligar/desligar quando quiser.
  * **Botões Virtuais:** `[◀ ESQUERDA]` e `[DIREITA ▶]` na tela
  * **Botão de Câmera:** `[🎥 VISÃO: CABINE (C)]`
  * **Botão de Reiniciar:** `[🔄 TENTAR DE NOVO]` no Game Over

---

## 🚀 Como Executar o Jogo

O **Godot 4.3** já foi instalado e configurado no seu terminal.

### Rodar diretamente na máquina:
```bash
cd /home/prkd/Gado/GadoGames/patriota_caminhao
godot
```
Ou rodar a cena diretamente:
```bash
godot scenes/main.tscn
```

---

## 🌐 Exportação para Web (HTML5 / Itch.io / Navegadores)

O projeto está configurado com renderizador **Compatibility (WebGL 2)** e modo `variant/thread_support=false`, permitindo rodar em qualquer hospedagem web sem exigir cabeçalhos COOP/COEP especiais.

Para exportar via linha de comando:
```bash
godot --headless --export-release "Web" exports/web/index.html
```

---

## 📱 Exportação para Android (Google Play Store)

1. No Godot, acesse **Projeto > Exportar...**
2. Selecione o preset **Android**.
3. O pacote configurado é `com.gadogames.patriotadocaminhao`.
4. Exporte como **Android App Bundle (.aab)** assinado para envio à Play Store.
