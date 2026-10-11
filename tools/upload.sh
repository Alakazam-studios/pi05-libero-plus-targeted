#!/usr/bin/env bash
# ABOUTME: Fills a Hugging Face model repo with this repository's card and the weights from our bucket, checked against
# ABOUTME: MANIFEST.json. Usage: tools/upload.sh <hf-repo, e.g. alakazamworld/pi05-libero-plus-targeted> <empty work dir>
set -euo pipefail

repo=${1:?give the Hugging Face repo, e.g. alakazamworld/pi05-libero-plus-targeted}
work=${2:?give an empty work directory on a disk with 8 GB free}
here=$(cd "$(dirname "$0")/.." && pwd)
src=gs://alakazam-experiments-us-central1/runs/xp/louisbench/ckpt/fla-disjoint/ckpt

[ -e "$work" ] && [ -n "$(ls -A "$work")" ] && { echo "refused: $work is not empty" >&2; exit 1; }
mkdir -p "$work/assets/physical-intelligence/libero"
gcloud storage cp "$src/model.safetensors" "$work/model.safetensors"
gcloud storage cp "$src/assets/physical-intelligence/libero/norm_stats.json" \
  "$work/assets/physical-intelligence/libero/norm_stats.json"

# every file must match the manifest before anything leaves this machine
python3 - "$here/MANIFEST.json" "$work" <<'PY'
import hashlib, json, sys
from pathlib import Path
manifest, work = json.loads(Path(sys.argv[1]).read_text()), Path(sys.argv[2])
for name, want in manifest["files"].items():
    path = work / name
    digest = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1 << 24), b""):
            digest.update(block)
    if digest.hexdigest() != want["sha256"] or path.stat().st_size != want["bytes"]:
        sys.exit(f"refused: {name} does not match MANIFEST.json")
    print(f"ok {name}")
PY

cp "$here/README.md" "$here/NOTICE" "$here/MANIFEST.json" "$work/"
# the Gemma terms require a copy of the agreement with every distribution; fetched now, as Google publishes it
curl -fsSL https://ai.google.dev/gemma/terms -o "$work/GEMMA-TERMS.html"

hf upload "$repo" "$work" . --repo-type model --commit-message "pi0.5 with targeted data for LIBERO-Plus: weights and card"
echo "uploaded to https://huggingface.co/$repo"
