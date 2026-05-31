#!/usr/bin/env python3
import json
import os
import zipfile
import hashlib
from pathlib import Path
from datetime import datetime

ts = datetime.now().strftime("%Y%m%d-%H%M%S")

base = Path("/media/mochafast/MochaArch/ativo")
if not base.exists() or not os.access(base, os.W_OK):
    base = Path.home() / ".local/share/MochaArch-ativo"

theme_dir = base / "vivaldi" / "temas"
theme_dir.mkdir(parents=True, exist_ok=True)

final_zip = theme_dir / "Mocha-Vivaldi-Canonico.zip"
final_json = theme_dir / "Mocha-Vivaldi-Canonico-settings.json"
sha_path = theme_dir / "Mocha-Vivaldi-Canonico.zip.sha256"

theme = {
    "accentFromPage": False,
    "accentOnWindow": True,
    "accentSaturationLimit": 0.35,
    "alpha": 1,
    "blur": 0,
    "colorAccentBg": "#2a241f",
    "colorBg": "#211e1a",
    "colorFg": "#e8dfd4",
    "colorHighlightBg": "#8a6348",
    "colorWindowBg": "#1c1916",
    "contrast": 1,
    "dimBlurred": False,
    "engineVersion": 1,
    "id": f"mocha-arch-vivaldi-canonico-{ts}",
    "name": "Mocha Arch Canônico",
    "preferSystemAccent": False,
    "radius": 8,
    "simpleScrollbar": True,
    "transparencyTabBar": False,
    "transparencyTabs": False,
    "url": "",
    "version": 1
}

final_json.write_text(json.dumps(theme, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

with zipfile.ZipFile(final_zip, "w", compression=zipfile.ZIP_DEFLATED) as z:
    z.write(final_json, "settings.json")

sha = hashlib.sha256(final_zip.read_bytes()).hexdigest()
sha_path.write_text(f"{sha}  {final_zip}\n", encoding="utf-8")

print(final_zip)
