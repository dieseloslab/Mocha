#!/usr/bin/env python3
import json
import os
import shutil
import subprocess
import zipfile
import hashlib
import uuid
from pathlib import Path
from datetime import datetime

ts = datetime.now().strftime("%Y%m%d-%H%M%S")

base = Path("/media/mochafast/MochaArch/ativo")
if not base.exists() or not os.access(base, os.W_OK):
    base = Path.home() / ".local/share/MochaArch-ativo"

theme_dir = base / "vivaldi" / "temas"
report_dir = base / "relatorios"
doc_dir = base / "documentacao"
script_dir = base / "scripts"

for d in (theme_dir, report_dir, doc_dir, script_dir):
    d.mkdir(parents=True, exist_ok=True)

log_path = report_dir / f"{ts}-vivaldi-tema-mocha-certo.log"
doc_path = doc_dir / "Mocha-Vivaldi-Tema-Canonico.md"

fixed_zip = theme_dir / "Mocha-Vivaldi-IMPORTAR-ESTE.zip"
fresh_zip = theme_dir / f"Mocha-Vivaldi-IMPORTAR-ESTE-{ts}.zip"
settings_json = theme_dir / "Mocha-Vivaldi-IMPORTAR-ESTE-settings.json"
sha_path = theme_dir / "Mocha-Vivaldi-IMPORTAR-ESTE.zip.sha256"
deleted_path = report_dir / f"{ts}-vivaldi-temas-antigos-removidos.txt"

def log(msg=""):
    print(msg)
    with log_path.open("a", encoding="utf-8") as f:
        f.write(str(msg) + "\n")

log("==> Mocha Vivaldi: gerando tema importável no formato que abriu prévia")
log(f"Base: {base}")
log(f"Pasta de temas: {theme_dir}")
log("")

log("==> Limpando temas Mocha/Vivaldi antigos da pasta canônica")
deleted = []

patterns = [
    "*Mocha*KDE*Vivaldi*.zip",
    "*Mocha*KDE*Vivaldi*.json",
    "*Mocha*KDE*Canonico*.zip",
    "*Mocha*KDE*Canonico*.json",
    "*Mocha*KDE*Importavel*.zip",
    "*Mocha*KDE*Importavel*.json",
    "*Mocha*KDE*Escuro*.zip",
    "*Mocha*KDE*Escuro*.json",
    "*Mocha*Firefox*Vivaldi*.zip",
    "*Mocha*Firefox*Vivaldi*.json",
    "*Mocha*Vivaldi*Firefox*.zip",
    "*Mocha*Vivaldi*Firefox*.json",
    "Mocha-Vivaldi-Canonico*.zip",
    "Mocha-Vivaldi-Canonico*.json",
    "Mocha-Vivaldi-IMPORTAR-ESTE*.zip",
    "Mocha-Vivaldi-IMPORTAR-ESTE*.json",
    "Mocha-Vivaldi-IMPORTAR-ESTE*.sha256",
]

for pattern in patterns:
    for p in theme_dir.glob(pattern):
        if p.is_file():
            deleted.append(str(p))
            p.unlink()

deleted_path.write_text("\n".join(deleted) + ("\n" if deleted else ""), encoding="utf-8")

for item in deleted:
    log(f"Removido: {item}")

if not deleted:
    log("Nada antigo para remover.")

log("")
log("==> Criando settings.json com as cores corretas")

# Paleta baseada no Firefox atual da captura:
# título marrom/preto #241e18, barra #2b2826, texto claro.
# O acento fica escuro para NÃO pintar a janela de laranja.
theme_name = f"Mocha Vivaldi Correto {ts}"

theme = {
    "accentFromPage": False,
    "accentOnWindow": True,
    "accentSaturationLimit": 1,
    "alpha": 1,
    "blur": 0,

    "colorAccentBg": "#241e18",
    "colorBg": "#2b2826",
    "colorFg": "#efe6da",
    "colorHighlightBg": "#6f5644",
    "colorWindowBg": "#241e18",

    "contrast": 1,
    "dimBlurred": False,
    "engineVersion": 1,
    "id": str(uuid.uuid4()),
    "name": theme_name,
    "preferSystemAccent": False,
    "radius": 8,
    "simpleScrollbar": True,
    "transparencyTabBar": False,
    "transparencyTabs": False,
    "url": "",
    "version": 1
}

settings_json.write_text(
    json.dumps(theme, indent=2, ensure_ascii=False) + "\n",
    encoding="utf-8"
)

json.loads(settings_json.read_text(encoding="utf-8"))

log(f"Nome interno: {theme_name}")
log(f"UUID interno: {theme['id']}")
log("Cores:")
log("  colorWindowBg    #241e18")
log("  colorBg          #2b2826")
log("  colorAccentBg    #241e18")
log("  colorFg          #efe6da")
log("  colorHighlightBg #6f5644")

log("")
log("==> Compactando ZIP com settings.json na raiz")

with zipfile.ZipFile(fresh_zip, "w", compression=zipfile.ZIP_DEFLATED) as z:
    z.write(settings_json, "settings.json")

with zipfile.ZipFile(fresh_zip, "r") as z:
    names = z.namelist()
    if names != ["settings.json"]:
        raise SystemExit(f"ZIP inválido: {names}")
    json.loads(z.read("settings.json").decode("utf-8"))

shutil.copy2(fresh_zip, fixed_zip)

sha = hashlib.sha256(fixed_zip.read_bytes()).hexdigest()
sha_path.write_text(f"{sha}  {fixed_zip}\n", encoding="utf-8")

doc_path.write_text(f"""# Mocha Vivaldi - Tema Canônico Importável

## Arquivo principal para importar

{fresh_zip}

## Cópia fixa

{fixed_zip}

## Cores

- Janela / topo: #241e18
- Barra / fundo: #2b2826
- Acento: #241e18
- Texto: #efe6da
- Destaque: #6f5644

## Aplicação

1. Abrir Vivaldi.
2. Configurações > Temas > Biblioteca.
3. Importar Tema / Open Theme.
4. Selecionar o arquivo:

{fresh_zip}

5. Confirmar em Instalar / Install.

## Regra

Para gerar outro ZIP importável com UUID novo, rode:

python3 {script_dir}/mocha-vivaldi-gerar-tema-importavel-certo.py

Isso evita depender de mim para recriar tema.
""", encoding="utf-8")

log("")
log("==> Tema pronto")
log(f"Importar este ZIP:")
log(str(fresh_zip))
log("")
log(f"Cópia fixa:")
log(str(fixed_zip))
log("")
log(f"Documento:")
log(str(doc_path))
log(f"Log:")
log(str(log_path))

try:
    wl_copy = shutil.which("wl-copy")
    if wl_copy:
        subprocess.run([wl_copy], input=str(fresh_zip), text=True, check=False)
        log("Caminho do ZIP novo copiado para a área de transferência.")
except Exception:
    pass

try:
    subprocess.Popen(["xdg-open", str(theme_dir)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
except Exception:
    pass

vivaldi_bin = None
for candidate in ("vivaldi-stable", "vivaldi", "vivaldi-snapshot"):
    found = shutil.which(candidate)
    if found:
        vivaldi_bin = found
        break

if vivaldi_bin:
    try:
        subprocess.Popen([vivaldi_bin, "vivaldi://settings/themes/"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass
