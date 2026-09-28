# Area 51 Hub

Script em Luau com interface gráfica para o jogo [Survive and Kill the Killers in Area 51](https://www.roblox.com/games/155382109/Survive-and-Kill-the-Killers-in-Area-51), feito para executores.

<!-- Coloque um print em assets/screenshot.png e descomente a linha abaixo -->
<!-- ![Menu](assets/screenshot.png) -->

## Funções

| Função | O que faz |
|---|---|
| **ESP Assassinos** | Contorno laranja visível através das paredes, com nome, distância e vida de cada assassino. |
| **Kill Aura** | Equipa sua arma e ataca o assassino mais próximo dentro do alcance (ajustável de 5 a 60 studs). |
| **Auto Farm** | Teleporta para trás do assassino mais próximo e ataca sem parar. |
| **Fuga Automática** | Quando a vida cai abaixo do limite (ajustável, padrão 60%) e há um assassino perto, teleporta para uma plataforma no alto. Volta quando a vida recuperar ou após 10s. |

O menu pode ser arrastado, minimizado com **-** e fechado com **X** (o fechar desliga tudo e limpa o ESP). **RightShift** esconde e mostra o menu.

## Como usar

1. Abra o jogo no Roblox.
2. Abra seu executor e faça o *Attach*.
3. Cole o conteúdo de [`area51.lua`](area51.lua) e clique em **Run**.

Ou carregue direto do GitHub (troque `SEU_USUARIO` e `SEU_REPO`):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/area51.lua"))()
```

## Como funciona

- Os assassinos são detectados como qualquer `Humanoid` vivo no `workspace` que não pertença a um jogador. A lista é atualizada a cada 0,5s.
- O ataque usa `Tool:Activate()` e, se o executor suportar, `firetouchinterest` entre o cabo da arma e o assassino. Funciona melhor com armas corpo a corpo. Armas de tiro dependem de mira e podem errar.
- Se o jogo tiver NPCs neutros (lojista, por exemplo), adicione o nome exato deles na tabela `IGNORE_NAMES` no topo do script para que não sejam tratados como alvo.
- Se a vida não regenerar no jogo, a fuga apenas espera os 10s e volta.

## Configuração rápida

No início do arquivo existe a tabela `cfg`, onde você pode mudar os valores padrão:

```lua
local cfg = {
	esp = false,
	aura = false,
	farm = false,
	escape = false,
	range = 15,      -- alcance do kill aura (studs)
	hpEscape = 60,   -- foge quando a vida estiver abaixo disso (%)
}
```

## Estrutura

```
area51-hub/
├── area51.lua     # script principal
├── assets/        # prints e imagens
├── LICENSE
└── README.md
```

## Compatibilidade

- Feito para executores com suporte a `gethui()` ou acesso ao `CoreGui` (cai para `CoreGui` se `gethui` não existir).
- O jogo pode ser atualizado e mudar a estrutura dos NPCs e armas. Se algo parar de funcionar, abra uma *issue* com um print do Explorer mostrando como os assassinos e a arma aparecem.

## Aviso

Este projeto é apenas para fins educacionais e de estudo de Luau. Usar executores em jogos de terceiros viola os Termos de Uso do Roblox e pode resultar em banimento da conta. Use por sua conta e risco. Este projeto não tem qualquer afiliação com a Roblox Corporation nem com o criador do jogo.

## Licença

Distribuído sob a licença MIT. Veja [`LICENSE`](LICENSE).
