# 🕊️ Ricardo Estudos

Leitor local e estático dos estudos e sermões salvos no **Segundo Cérebro** (vault Obsidian).
Página completa para **rodar localmente** ou via **GitHub Pages**, com:

- ✅ Modo **dark / claro** (persistido)
- ✅ Aumentar/​diminuir texto (A+ / A−)
- ✅ Modo **leitura** (padrão) e modo **edição** (rascunho local + baixar .md)
- ✅ Busca por tema, tag e texto base; filtro Estudos / Sermões
- ✅ Layout responsivo (drawer no celular)

## Como funciona

- `index.html` - a página (tipografia serifada, sem dependência de servidor)
- `data.js` - **gerado** a partir das notas do vault (contém todo o conteúdo embutido)
- `lib/marked.min.js` - renderizador de markdown (vendido, funciona offline)
- `scripts/gerar.py` - lê `08 - Sermões/` e `09 - Estudos/` do vault e regenera `data.js`

## Como rodar

Opção simples (abrir o arquivo):
```bash
open index.html
```
Ou via servidor local:
```bash
python3 -m http.server 8890
# http://localhost:8890
```

## Regenerar os dados (após novos estudos no vault)

```bash
python3 scripts/gerar.py
```

## Publicar automaticamente a cada estudo/sermão novo

Um agente do macOS (LaunchAgent) vigia as pastas `08 - Sermões` e `09 - Estudos`
do Segundo Cérebro. Quando um arquivo novo aparece ou é renomeado, ele roda
`scripts/sync.sh`, que regenera o `data.js`, faz commit e push (GitHub Pages
publica sozinho).

**Instalação (uma única vez):**

1. Ativar o agente:
   ```bash
   launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/br.ricardomarguliano.ricardo-estudos-sync.plist
   ```
2. Liberar o acesso do iCloud para o Python (TCC):
   - **Ajustes do Sistema → Privacidade e Segurança → Acesso total ao disco**
   - Clique em **+** e adicione `/usr/bin/python3` (no seletor, Cmd+Shift+G e cole o caminho).
   - Necessário porque processos disparados por launchd **não herdam** a permissão de iCloud que o terminal já tem.

**Parar:** `launchctl bootout "gui/$(id -u)/br.ricardomarguliano.ricardo-estudos-sync"`
**Log:** `~/ricardo_estudos_sync.log`

O `scripts/sync.sh` só publica quando o `data.js` muda (evita pushs à toa) e
serializa execuções sobrepostas.

## Publicar (GitHub Pages)

O fluxo usa o GitHub CLI:
```bash
gh repo create ricardo_estudos --public --source=. --push
gh api repos/:owner/ricardo_estudos/pages \
  -f 'source[branch]=main' -f 'source[path]=/' -m POST
```

---

*Dados gerados a partir do Segundo Cérebro do usuário.*