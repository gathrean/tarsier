#!/usr/bin/env python3
"""
Tarsier TTS Audio Generator

Reads lesson JSON files, extracts unique Tagalog strings, and generates
pronunciation audio via Google Cloud Text-to-Speech API.

Usage:
    python scripts/generate_audio.py \
        --lessons Tarsier/Resources/Lessons \
        --output Tarsier/Resources/Audio \
        --credentials path/to/credentials.json

Requires: pip install google-cloud-texttospeech
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path


def sanitize_filename(text: str, max_length: int = 80) -> str:
    """Convert Tagalog text to a safe filename."""
    s = text.lower().strip()
    s = re.sub(r"[^\w\s-]", "", s)
    s = re.sub(r"\s+", "_", s)
    return s[:max_length]


def extract_tagalog_strings(lesson: dict) -> set[str]:
    """Extract all Tagalog strings needing pronunciation from a lesson."""
    strings = set()

    for session in lesson.get("sessions", []):
        for card in session.get("cards", []):
            card_type = card.get("type", "")

            if card_type == "teach":
                # Highlight field often has Tagalog text
                if highlight := card.get("highlight"):
                    strings.add(highlight.strip())

                # Example sentences
                if example := card.get("example"):
                    if sentence := example.get("sentence"):
                        strings.add(sentence.strip())
                    if casual := example.get("casual"):
                        strings.add(casual.strip())
                    if with_po := example.get("with_po"):
                        strings.add(with_po.strip())

            elif card_type == "quiz":
                # Quiz prompt (if in Tagalog)
                if prompt := card.get("prompt"):
                    strings.add(prompt.strip())

                # Correct answers
                if correct_answers := card.get("correct_answers"):
                    for ans in correct_answers:
                        strings.add(ans.strip())

                # Multiple choice options
                if options := card.get("options"):
                    for opt in options:
                        strings.add(opt.strip())

                # Word order pieces
                if word_pieces := card.get("word_pieces"):
                    for piece in word_pieces:
                        strings.add(piece.strip())

                # Given sentence (word order quiz)
                if given := card.get("given_sentence"):
                    strings.add(given.strip())

    # Vocabulary section
    for vocab in lesson.get("vocabulary", []):
        if word := vocab.get("word"):
            strings.add(word.strip())

    # Filter out empty strings and pure English
    strings = {s for s in strings if s and len(s) > 0}

    return strings


def generate_audio(
    text: str,
    output_path: Path,
    client,
    voice_name: str | None = None,
    speaking_rate: float = 0.9,
):
    """Generate TTS audio for a single Tagalog string."""
    from google.cloud import texttospeech

    synthesis_input = texttospeech.SynthesisInput(text=text)

    voice = texttospeech.VoiceSelectionParams(
        language_code="fil-PH",
        name=voice_name,
        ssml_gender=texttospeech.SsmlVoiceGender.FEMALE,
    )

    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3,
        speaking_rate=speaking_rate,
    )

    response = client.synthesize_speech(
        input=synthesis_input,
        voice=voice,
        audio_config=audio_config,
    )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "wb") as f:
        f.write(response.audio_content)


def main():
    parser = argparse.ArgumentParser(description="Generate TTS audio for Tarsier lessons")
    parser.add_argument("--lessons", required=True, help="Path to lesson JSON directory")
    parser.add_argument("--output", required=True, help="Path to output audio directory")
    parser.add_argument("--credentials", required=True, help="Path to Google Cloud credentials JSON")
    parser.add_argument("--voice", default=None, help="Specific voice name (e.g., fil-PH-Wavenet-A)")
    parser.add_argument("--rate", type=float, default=0.9, help="Speaking rate (default: 0.9)")
    parser.add_argument("--dry-run", action="store_true", help="List strings without generating audio")
    args = parser.parse_args()

    lessons_dir = Path(args.lessons)
    output_dir = Path(args.output)

    if not lessons_dir.exists():
        print(f"Error: Lessons directory not found: {lessons_dir}", file=sys.stderr)
        sys.exit(1)

    # Collect all Tagalog strings per lesson
    all_strings: dict[str, set[str]] = {}  # lesson_id -> set of strings
    unique_strings: set[str] = set()

    for json_file in sorted(lessons_dir.glob("lesson_*.json")):
        with open(json_file) as f:
            lesson = json.load(f)

        lesson_id = lesson.get("lesson_id", json_file.stem)
        strings = extract_tagalog_strings(lesson)
        all_strings[lesson_id] = strings
        unique_strings.update(strings)

    total_strings = len(unique_strings)
    print(f"Found {total_strings} unique strings across {len(all_strings)} lessons")

    if args.dry_run:
        for s in sorted(unique_strings):
            print(f"  {s}")
        return

    # Set up Google Cloud credentials
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = args.credentials

    from google.cloud import texttospeech

    client = texttospeech.TextToSpeechClient()

    generated = 0
    skipped = 0
    errors = 0

    # Generate per-lesson audio files
    for lesson_id, strings in sorted(all_strings.items()):
        for text in sorted(strings):
            filename = sanitize_filename(text) + ".mp3"
            output_path = output_dir / lesson_id / filename

            if output_path.exists():
                skipped += 1
                continue

            try:
                generate_audio(
                    text=text,
                    output_path=output_path,
                    client=client,
                    voice_name=args.voice,
                    speaking_rate=args.rate,
                )
                generated += 1
                print(f"  Generated: {lesson_id}/{filename}")
            except Exception as e:
                errors += 1
                print(f"  Error: {lesson_id}/{filename} — {e}", file=sys.stderr)

    # Generate manifest
    manifest: dict[str, str] = {}
    for lesson_id, strings in sorted(all_strings.items()):
        for text in sorted(strings):
            filename = sanitize_filename(text) + ".mp3"
            relative_path = f"{lesson_id}/{filename}"
            manifest[text] = relative_path

    manifest_path = output_dir / "audio_manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)

    print(f"\nSummary:")
    print(f"  Total strings: {total_strings}")
    print(f"  Generated: {generated}")
    print(f"  Skipped (existing): {skipped}")
    print(f"  Errors: {errors}")
    print(f"  Manifest: {manifest_path}")


if __name__ == "__main__":
    main()
