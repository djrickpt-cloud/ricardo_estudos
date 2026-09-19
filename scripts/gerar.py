#!/usr/bin/env python3
"""Gera o data.js do site ricardo_estudos a partir do vault do Segundo Cérebro.

Lê as pastas 08 - Sermões/ e 09 - Estudos/ do vault Obsidian, extrai o
frontmatter + título + corpo markdown de cada nota e escreve data.js com
window.ESTUDOS. Ignora notas do tipo 'catalogo' ou sem corpo.
"""
import json
import os
import re
import sys
from datetime import date

VAULT = os.path.expanduser(
    "~/Library/Mobile Documents/com~apple~CloudDocs/Obsidian/Segundo_Cerebro"
)
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "data.js")

FOLDERS = [("estudos", "09 - Estudos"), ("sermoes", "08 - Sermões")]


def parse_nota(path):
    with open(path, encoding="utf-8") as f:
        raw = f.read()

    fm = {}
    body = raw
    if raw.lstrip().startswith("---"):
        head, sep, rest = raw.partition("---")
        if sep:
            fm_text, _, body = rest.partition("---")
            for line in fm_text.splitlines():
                if ":" not in line:
                    continue
                k, v = line.split(":", 1)
                k = k.strip().lower()
                v = v.strip()
                if v.startswith("[") and v.endswith("]"):
                    fm[k] = [t.strip() for t in v[1:-1].split(",") if t.strip()]
                else:
                    fm[k] = v

    if fm.get("type", "").strip().lower() == "catalogo":
        return None
    if not body or not body.strip():
        return None

    title = ""
    m = re.search(r"^#{1,2}\s+(.+)$", body, re.MULTILINE)
    if m:
        title = m.group(1).strip()
    if not title:
        title = os.path.splitext(os.path.basename(path))[0]

    tags = fm.get("tags", [])
    if not isinstance(tags, list):
        tags = [tags]

    return {
        "id": os.path.splitext(os.path.basename(path))[0],
        "file": os.path.relpath(path, VAULT),
        "title": title,
        "tags": tags,
        "texto_base": fm.get("texto-base", fm.get("textobase", "")),
        "versao": fm.get("versao", ""),
        "tipo": fm.get("tipo", ""),
        "autor": fm.get("autor", ""),
        "created": fm.get("created", ""),
        "updated": fm.get("updated", ""),
        "content": body.strip(),
    }


def chave_ordem(item):
    m = re.match(r"^(\d+)", item["id"])
    return (0, int(m.group(1)), "") if m else (1, 0, item["id"].lower())


def main():
    itens = []
    for cat, folder in FOLDERS:
        diretorio = os.path.join(VAULT, folder)
        if not os.path.isdir(diretorio):
            print(f"AVISO: pasta nao encontrada: {diretorio}", file=sys.stderr)
            continue
        for nome in sorted(os.listdir(diretorio)):
            if not nome.endswith(".md"):
                continue
            caminho = os.path.join(diretorio, nome)
            nota = parse_nota(caminho)
            if nota is None:
                continue
            nota["cat"] = cat
            itens.append(nota)

    itens.sort(key=chave_ordem)

    payload = {
        "gerado_em": date.today().isoformat(),
        "fonte": "Segundo Cérebro (Obsidian)",
        "itens": itens,
    }

    with open(OUT, "w", encoding="utf-8") as f:
        f.write("window.ESTUDOS = ")
        f.write(json.dumps(payload, ensure_ascii=False, indent=1))
        f.write(";\n")

    print(f"OK: {len(itens)} notas -> {OUT}")
    by_cat = {}
    for item in itens:
        by_cat[item["cat"]] = by_cat.get(item["cat"], 0) + 1
    print(by_cat)


if __name__ == "__main__":
    main()