#!/usr/bin/env python3
"""
Wikimedia Image Pipeline for Tarsier

Reads image_sources.json, downloads images from Wikimedia Commons,
resizes to max 400px dimension, and generates ATTRIBUTIONS.md.

Usage:
    pip install -r requirements.txt
    python download_images.py
"""

import json
import os
import sys
from pathlib import Path

import requests
from PIL import Image

SCRIPT_DIR = Path(__file__).parent
SOURCES_FILE = SCRIPT_DIR / "image_sources.json"
OUTPUT_DIR = SCRIPT_DIR.parent / "Tarsier" / "Resources" / "Images"
ATTRIBUTIONS_FILE = OUTPUT_DIR / "ATTRIBUTIONS.md"
MAX_DIMENSION = 400


def load_sources() -> dict:
    with open(SOURCES_FILE) as f:
        data = json.load(f)
    # Filter out meta keys like _comment, _example
    return {k: v for k, v in data.items() if not k.startswith("_")}


def download_image(url: str, dest: Path) -> bool:
    try:
        resp = requests.get(url, timeout=30, stream=True)
        resp.raise_for_status()
        with open(dest, "wb") as f:
            for chunk in resp.iter_content(8192):
                f.write(chunk)
        return True
    except Exception as e:
        print(f"  ERROR downloading {url}: {e}")
        return False


def resize_image(path: Path):
    with Image.open(path) as img:
        w, h = img.size
        if max(w, h) <= MAX_DIMENSION:
            return
        if w > h:
            new_w = MAX_DIMENSION
            new_h = int(h * MAX_DIMENSION / w)
        else:
            new_h = MAX_DIMENSION
            new_w = int(w * MAX_DIMENSION / h)
        img = img.resize((new_w, new_h), Image.LANCZOS)
        img.save(path, quality=85, optimize=True)
        print(f"  Resized to {new_w}x{new_h}")


def generate_attributions(sources: dict):
    lines = [
        "# Image Attributions",
        "",
        "Images used in Tarsier are sourced from Wikimedia Commons.",
        "All images are used under their respective Creative Commons licences.",
        "",
        "| Image | Author | Licence | Source |",
        "|-------|--------|---------|--------|",
    ]
    for key, info in sorted(sources.items()):
        author = info.get("author", "Unknown")
        licence = info.get("licence", "Unknown")
        source = info.get("source", "")
        lines.append(f"| {key} | {author} | {licence} | [Link]({source}) |")

    lines.append("")
    with open(ATTRIBUTIONS_FILE, "w") as f:
        f.write("\n".join(lines))
    print(f"\nGenerated {ATTRIBUTIONS_FILE}")


def main():
    sources = load_sources()
    if not sources:
        print("No image sources found in image_sources.json (only meta keys).")
        print("Add entries like:")
        print('  "araw": { "direct_url": "https://...", "licence": "CC BY-SA 4.0", ... }')
        sys.exit(0)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    success = 0
    failed = 0
    for key, info in sources.items():
        url = info.get("direct_url")
        if not url:
            print(f"Skipping {key}: no direct_url")
            failed += 1
            continue

        ext = Path(url).suffix or ".jpg"
        dest = OUTPUT_DIR / f"{key}{ext}"
        print(f"Downloading {key}...")

        if download_image(url, dest):
            resize_image(dest)
            success += 1
        else:
            failed += 1

    generate_attributions(sources)
    print(f"\nDone: {success} downloaded, {failed} failed.")


if __name__ == "__main__":
    main()
