#!/bin/bash
# Checks the App Store material before uploading it:
# text lengths, wording that App Review would read as a medical claim, screenshots, public pages.
set -u
export LC_ALL=en_US.UTF-8
cd "$(dirname "$0")"

fail() { echo "FAIL: $*"; exit 1; }

limit() {
    [ -f "$1" ] || fail "$1 is missing"
    local n
    n=$(printf '%s' "$(cat "$1")" | wc -m | tr -d ' ')
    [ "$n" -gt 0 ] || fail "$1 is empty"
    [ "$n" -le "$2" ] || fail "$1 is $n characters (max $2)"
}

for lang in en it; do
    limit "$lang/name.txt" 30
    limit "$lang/subtitle.txt" 30
    limit "$lang/promotional_text.txt" 170
    limit "$lang/keywords.txt" 100
    limit "$lang/description.txt" 4000
    grep -q ', ' "$lang/keywords.txt" && fail "$lang/keywords.txt: no spaces after the commas"
done
[ -f review_notes.txt ] || fail "review_notes.txt is missing"

en_words='cure|cures|treat|treats|treatment|therapy|therapeutic|clinical|clinically|medical|anxiety disorder|depression'
it_words="cura|cure|curare|terapia|terapeutico|clinico|clinicamente|medico|disturbo d'ansia|depressione"
grep -Eiwn "$en_words" en/*.txt review_notes.txt && fail "medical wording in the English texts (above)"
grep -Eiwn "$it_words" it/*.txt && fail "medical wording in the Italian texts (above)"

for lang in en it; do
    for shot in 01-write 02-sinking 03-breath; do
        f="screenshots/$lang/$shot.png"
        [ -f "$f" ] || fail "$f is missing"
        size=$(sips -g pixelWidth -g pixelHeight "$f" | awk '/pixel/ {print $2}' | paste -sd x -)
        [ "$size" = "1320x2868" ] || fail "$f is $size (expected 1320x2868)"
        strings "$f" | grep -qi c2pa && fail "$f carries a C2PA block"
    done
done

for page in privacy support; do
    f="../../$page.html"
    [ -f "$f" ] || fail "$page.html is missing at the repo root"
    grep -q 'nickdvlp@gmail.com' "$f" || fail "$page.html has no contact address"
done

echo "store material OK"
