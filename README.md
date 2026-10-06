# Configurazione Neovim

Configurazione modulare per **Rust, Flutter/Dart, React, Next.js, Node, Svelte,
HTML/CSS/Tailwind, PHP, C#/.NET, PostgreSQL, nginx** e affini.

Richiede **Neovim ≥ 0.12**, `git`, un compilatore C, [`ripgrep`](https://github.com/BurntSushi/ripgrep),
[`fd`](https://github.com/sharkdp/fd), [`lazygit`](https://github.com/jesseduffield/lazygit)
e la CLI [`tree-sitter`](https://formulae.brew.sh/formula/tree-sitter-cli):

```sh
brew install ripgrep fd lazygit tree-sitter-cli
```

Server LSP, formattatori e debugger vengono installati da Mason al primo avvio
(`:Mason` per vederne lo stato).

---

## Struttura

```
init.lua                      punto di ingresso, richiede i moduli sotto
lua/config/
  options.lua                 opzioni globali (leader compreso)
  lazy.lua                    bootstrap e setup di lazy.nvim
  autocmds.lua                autocomandi + riconoscimento filetype
  keymaps.lua                 TUTTE le keymap, raggruppate per funzionalità
  colorscheme.lua             selettore di tema persistente
lua/plugins/
  ai.lua                      GitHub Copilot
  colorschemes.lua            temi disponibili nel selettore
  completion.lua              blink.cmp + LuaSnip
  database.lua                vim-dadbod-ui (PostgreSQL)
  debug.lua                   nvim-dap + interfaccia + adapter Node/Chrome/PHP/.NET
  editor.lua                  mini.nvim, autopairs, autotag, indent, progetti
  explorer.lua                nvim-tree
  format.lua                  conform.nvim
  git.lua                     gitsigns + lazygit
  lsp.lua                     Mason + configurazione dei language server
  telescope.lua               ricerca fuzzy
  terminal.lua                toggleterm
  treesitter.lua              parser, highlighting, folding
  ui.lua                      which-key, barbar, indent guides, markdown
  lang/rust.lua               rustaceanvim + crates.nvim
  lang/flutter.lua            flutter-tools
  lang/web.lua                integrazioni React/Next/Svelte
```

Regola pratica: **un file per area funzionale**. Per aggiungere un plugin basta
creare un file in `lua/plugins/` che ritorna una spec di lazy.nvim — viene
importato da solo.

---

## Keymaps

Il leader è `<Space>`. Premendolo, **which-key** mostra i gruppi disponibili;
`<leader>?` elenca le mappe valide solo nel buffer corrente e `<leader>fk` le
cerca tutte con Telescope.

| Prefisso     | Gruppo         |
| ------------ | -------------- |
| `<leader>a`  | AI / Copilot   |
| `<leader>b`  | Buffer         |
| `<leader>c`  | Codice / LSP   |
| `<leader>d`  | Debug          |
| `<leader>D`  | Database       |
| `<leader>f`  | Find / File    |
| `<leader>g`  | Git            |
| `<leader>l`  | Lazy & Tools   |
| `<leader>r`  | Run / Test     |
| `<leader>t`  | Terminale      |
| `<leader>u`  | UI / Toggle    |
| `<leader>x`  | Diagnostica    |

### Generale

| Tasto | Azione |
| ----- | ------ |
| `<C-s>` / `<leader>w` | Salva |
| `<leader>W` | Salva tutto |
| `<leader>q` / `<leader>Q` | Chiudi finestra / esci |
| `<leader>e` / `<leader>E` | Explorer / explorer sul file corrente |
| `<C-h/j/k/l>` | Cambia finestra (anche dal terminale) |
| `<C-frecce>` | Ridimensiona la finestra |
| `<S-h>` / `<S-l>` | Buffer precedente / successivo |
| `<C-\>` | Terminale al volo |
| `<Tab>` (inserimento) | Accetta la voce del menu di completamento, salta nello snippet, o accetta il suggerimento di Copilot |
| `<C-y>` (inserimento) | Accetta la voce del menu di completamento (alternativa a `<Tab>`) |
| `<C-l>` (inserimento) | Accetta il suggerimento di Copilot (anche con il menu aperto) |
| `<M-]>` / `<M-[>` | Suggerimento Copilot successivo / precedente |
| `<Esc><Esc>` | Esci dalla modalità terminale |

### Codice / LSP (locali al buffer)

| Tasto | Azione |
| ----- | ------ |
| `gd` `gD` `gy` | Definizione, dichiarazione, tipo |
| `grr` `gri` | Riferimenti, implementazioni (Telescope) |
| `grn` `gra` | Rinomina, azioni sul codice (mappe native di Neovim) |
| `gO` `gW` | Simboli del documento / del progetto |
| `K` | Documentazione | 
| `<C-k>` (inserimento) | Firma della funzione |
| `<leader>ca` `<leader>cr` | Azioni sul codice, rinomina |
| `<leader>cf` | Formatta (anche in visuale) |
| `<leader>cd` | Diagnostica sotto il cursore |

### Run / Test — dipende dal linguaggio del buffer

| Rust | Flutter | JS/TS | PHP | C# / .NET |
| ---- | ------- | ----- | --- | --------- |
| `<leader>rr` runnables | `<leader>rr` avvia l'app | `<leader>rr` npm run dev | `<leader>rr` esegui il file | `<leader>rr` dotnet run |
| `<leader>rt` test | `<leader>rl` hot reload | `<leader>rb` npm run build | `<leader>rt` phpunit | `<leader>rw` dotnet watch |
| `<leader>rd` debug | `<leader>rR` hot restart | `<leader>rt` npm test | `<leader>ri` composer install | `<leader>rb` dotnet build |
| `<leader>rc` Cargo.toml | `<leader>rd` dispositivi | `<leader>ri` npm install | `<leader>ru` composer update | `<leader>rt` dotnet test |
| `<leader>re` spiega errore | `<leader>ro` outline widget | `<leader>rl` npm run lint | | `<leader>ri` dotnet restore |

### Colorscheme persistente

`<leader>uc` apre il selettore con anteprima live; `<leader>ub` alterna sfondo
chiaro/scuro. La scelta viene salvata in `~/.local/share/nvim/colorscheme.json`
e riapplicata a ogni avvio — vale anche per un `:colorscheme` digitato a mano.
`:ColorschemeReset` torna al default.

Per aggiungere un tema basta inserirlo in `lua/plugins/colorschemes.lua` con
`lazy = false`.

---

## Manutenzione

| Comando | Cosa fa |
| ------- | ------- |
| `<leader>ll` / `:Lazy` | Gestione plugin |
| `<leader>lu` | Aggiorna i plugin |
| `<leader>lm` / `:Mason` | LSP, formattatori, debugger |
| `<leader>lt` / `:TSUpdate` | Aggiorna i parser treesitter |
| `<leader>lh` / `:checkhealth` | Diagnostica della configurazione |
