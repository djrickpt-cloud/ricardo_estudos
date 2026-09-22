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

O `scripts/watch.sh` vigia as pastas `08 - Sermões` e `09 - Estudos` do Segundo
Cérebro. Quando um `.md` novo aparece ou é renomeado, ele chama `scripts/sync.sh`,
que regenera o `data.js`, faz commit e push (GitHub Pages publica sozinho).
O `sync.sh` só publica quando o `data.js` muda e serializa execuções sobrepostas.

**Iniciar (após login/reinício):**

```bash
nohup bash "$HOME/ricardo_estudos/scripts/watch.sh" >/dev/null 2>&1 &
```

**Parar:** `kill "$(cat "$HOME/ricardo_estudos/.watch.pid")"`
**Log:** `~/ricardo_estudos_sync.log`

> Por que não é um LaunchAgent: processos iniciados por launchd não herdam a
> permissão de iCloud Drive do seu usuário (TCC) e falham ao ler o vault com
> `EPERM`. O watcher roda na sessão autorizada e funciona sem configurar nada.
> Limitação: precisa ser reiniciado após reboot/logout. Quem preferir o agente
> que sobrevive a reboots pode conceder "Acesso total ao disco" a `/usr/bin/python3`
> e usar `scripts/br.ricardomarguliano.ricardo-estudos-sync.plist`.

## Publicar (GitHub Pages)

O fluxo usa o GitHub CLI:
```bash
gh repo create ricardo_estudos --public --source=. --push
gh api repos/:owner/ricardo_estudos/pages \
  -f 'source[branch]=main' -f 'source[path]=/' -m POST
```

---

*Dados gerados a partir do Segundo Cérebro do usuário.*