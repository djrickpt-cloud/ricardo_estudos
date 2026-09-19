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

## Publicar (GitHub Pages)

O fluxo usa o GitHub CLI:
```bash
gh repo create ricardo_estudos --public --source=. --push
gh api repos/:owner/ricardo_estudos/pages \
  -f 'source[branch]=main' -f 'source[path]=/' -m POST
```

---

*Dados gerados a partir do Segundo Cérebro do usuário.*