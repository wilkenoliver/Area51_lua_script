# Roblox Hub

Script em Luau para Roblox com interface gráfica, feito para executores. Reúne **Fly**, **ESP**, **Fling** e **Anti-Fling** em um menu único, arrastável e minimizável.

<!-- Coloque um print em assets/screenshot.png e descomente a linha abaixo -->
<!-- ![Menu](assets/screenshot.png) -->

## Funções

| Função | O que faz |
|---|---|
| **Fly** | Voa na direção da câmera (W/A/S/D, Espaço sobe, Ctrl esquerdo desce). Velocidade ajustável de 10 a 300. |
| **ESP** | Contorno vermelho visível através das paredes, com nome e distância (em studs) de cada jogador. |
| **Fling** | Escolha um jogador na lista e arremesse. Sem seleção, usa o jogador mais próximo. Depois do fling você volta para a posição original. |
| **Anti-Fling** | Desativa a colisão dos outros jogadores com você e zera sua velocidade caso ela dispare de repente. |

## Atalhos

| Tecla | Ação |
|---|---|
| `F` | Fly liga/desliga |
| `G` | Fling no alvo selecionado (ou no mais próximo) |
| `T` | ESP liga/desliga |
| `Y` | Anti-Fling liga/desliga |
| `↑` / `↓` | Aumenta / diminui velocidade do fly (só nos scripts standalone) |
| `RightShift` | Esconde/mostra o menu |

## Como usar

1. Abra o Roblox e entre no jogo desejado.
2. Abra seu executor e faça o *Attach*.
3. Cole o conteúdo de [`hub.lua`](hub.lua) e clique em **Run**.

Ou carregue direto do GitHub (troque `SEU_USUARIO` e `SEU_REPO`):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/hub.lua"))()
```

## Script do jogo: Survive and Kill the Killers in Area 51

[`scripts/area51.lua`](scripts/area51.lua) é um menu separado para o jogo [Survive and Kill the Killers in Area 51](https://www.roblox.com/games/155382109/Survive-and-Kill-the-Killers-in-Area-51).

| Função | O que faz |
|---|---|
| **ESP Assassinos** | Contorno laranja, nome, distância e vida de cada assassino. |
| **Kill Aura** | Equipa sua arma e ataca o assassino mais próximo dentro do alcance ajustável. |
| **Auto Farm** | Teleporta para trás do assassino mais próximo e ataca sem parar. |
| **Fuga Automática** | Quando a vida cai abaixo do limite e há um assassino perto, teleporta para uma plataforma no alto e volta depois de recuperar a vida (ou 10s). |

Para carregar direto do GitHub:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/scripts/area51.lua"))()
```

Os assassinos são detectados como qualquer `Humanoid` no `workspace` que não seja de um jogador. Se o jogo tiver NPCs neutros, adicione o nome deles na tabela `IGNORE_NAMES` no topo do script. Se a sua arma for de tiro e não corpo a corpo, o ataque usa `Tool:Activate()`, então a mira pode não acertar.

## Estrutura

```
roblox-hub/
├── hub.lua                    # script principal com interface
├── scripts/
│   ├── fly.lua                # só o fly, sem interface
│   ├── fly_fling_esp.lua      # fly + fling + ESP por teclas, sem interface
│   └── area51.lua             # script do jogo Survive and Kill the Killers in Area 51
├── assets/                    # prints e imagens
├── LICENSE
└── README.md
```

## Compatibilidade

- Testado com a estrutura do **Potassium**. Deve funcionar em executores que suportem `gethui()` ou acesso ao `CoreGui` (o script usa `gethui()` e cai para `CoreGui` se não existir).
- O Fling depende da física do jogo. Em jogos com colisão entre jogadores desativada, ele pode não ter efeito.
- Jogos com anti-cheat forte podem detectar fly, fling e velocidade anormal.

## Aviso

Este projeto é apenas para fins educacionais e de estudo de Luau. Usar executores em jogos de terceiros viola os Termos de Uso do Roblox e pode resultar em banimento da conta. Use por sua conta e risco, de preferência em jogos seus ou servidores privados, e não use o Fling para atrapalhar a partida de outras pessoas. Este projeto não tem qualquer afiliação com a Roblox Corporation.

## Licença

Distribuído sob a licença MIT. Veja [`LICENSE`](LICENSE).
