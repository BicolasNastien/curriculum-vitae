#!/usr/bin/env bash
# ============================================================
# Génération du CV
# ============================================================
# Compile l'une des variantes de CV du dépôt :
#
#   sidebar     main.tex            deux colonnes, sidebar colorée + photo
#   onecolumn   main-onecolumn.tex  une colonne, sobre (grands groupes / ATS)
#
# Usage :
#   ./build.sh                 # menu interactif
#   ./build.sh sidebar         # compile une variante
#   ./build.sh all             # compile toutes les variantes
#   ./build.sh onecolumn -o cv_dupont.pdf
#
# Deux passes de pdflatex sont systématiques : la sidebar est un overlay TikZ
# « remember picture », dont la position n'est connue qu'après lecture du .aux
# produit par la première passe.

set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

BUILD_DIR="build"          # fichiers intermédiaires (.aux, .log, .out)
OUTPUT_NAME=""             # nom du PDF final, si forcé via -o

# Variantes : nom -> fichier source. Ordre = ordre d'affichage du menu.
VARIANTS=(sidebar onecolumn)
declare -A SOURCES=(
  [sidebar]="main.tex"
  [onecolumn]="main-onecolumn.tex"
)
declare -A LABELS=(
  [sidebar]="Deux colonnes — sidebar colorée, photo, icônes"
  [onecolumn]="Une colonne — sobre, sans photo (grands groupes, ATS)"
)

die() { printf '\033[31mErreur :\033[0m %s\n' "$1" >&2; exit 1; }
info() { printf '\033[34m==>\033[0m %s\n' "$1"; }

usage() {
  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# ------------------------------------------------------------
# Vérifications préalables
# ------------------------------------------------------------
check_requirements() {
  command -v pdflatex >/dev/null 2>&1 || die "pdflatex introuvable (voir README.md)."
  [ -f config/personal.tex ] || die "config/personal.tex manquant. Copiez-le depuis l'exemple :
    cp config/personal.tex.example config/personal.tex"
}

# La photo n'est utilisée que par la variante sidebar : ne bloquer que là.
check_photo() {
  [ -f photo.png ] || die "photo.png manquante à la racine (requise par la variante sidebar)."
}

# ------------------------------------------------------------
# Compilation d'une variante
# ------------------------------------------------------------
build() {
  local variant="$1"
  local source="${SOURCES[$variant]:-}"
  [ -n "$source" ] || die "variante inconnue : $variant. Attendu : ${VARIANTS[*]}"
  [ -f "$source" ] || die "fichier source introuvable : $source"

  [ "$variant" = "sidebar" ] && check_photo

  local base output
  base="$(basename "$source" .tex)"
  output="${OUTPUT_NAME:-cv-$variant.pdf}"

  mkdir -p "$BUILD_DIR"

  info "Compilation de la variante « $variant » ($source)…"
  local pass
  for pass in 1 2; do
    if ! pdflatex -interaction=nonstopmode -halt-on-error \
                  -output-directory="$BUILD_DIR" "$source" >/dev/null; then
      printf '\n'
      # Sur échec, remonter les lignes d'erreur LaTeX (préfixées par « ! »).
      grep -A 4 '^!' "$BUILD_DIR/$base.log" | head -n 40 >&2 || true
      die "échec de pdflatex (passe $pass). Log complet : $BUILD_DIR/$base.log"
    fi
  done

  cp "$BUILD_DIR/$base.pdf" "$output"
  info "PDF généré : $output"
}

# ------------------------------------------------------------
# Menu interactif
# ------------------------------------------------------------
choose_variant() {
  local i=1 choice
  printf 'Quelle version du CV générer ?\n\n' >&2
  for v in "${VARIANTS[@]}"; do
    printf '  %d) %-12s %s\n' "$i" "$v" "${LABELS[$v]}" >&2
    i=$((i + 1))
  done
  printf '  %d) %-12s %s\n\n' "$i" "all" "Toutes les variantes" >&2

  read -rp "Choix [1-$i] : " choice
  case "$choice" in
    ''|*[!0-9]*) die "choix invalide : « $choice »" ;;
  esac
  [ "$choice" -ge 1 ] && [ "$choice" -le "$i" ] || die "choix hors bornes : $choice"

  if [ "$choice" -eq "$i" ]; then
    printf 'all\n'
  else
    printf '%s\n' "${VARIANTS[$((choice - 1))]}"
  fi
}

# ------------------------------------------------------------
# Point d'entrée
# ------------------------------------------------------------
target=""
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage 0 ;;
    -o|--output)
      [ $# -ge 2 ] || die "-o attend un nom de fichier."
      OUTPUT_NAME="$2"; shift 2 ;;
    -*) die "option inconnue : $1" ;;
    *)
      [ -z "$target" ] || die "une seule variante à la fois (reçu : $target puis $1)."
      target="$1"; shift ;;
  esac
done

check_requirements

# Sans argument : menu si le terminal est interactif, erreur sinon (script
# appelé depuis un Makefile ou une CI).
if [ -z "$target" ]; then
  [ -t 0 ] || die "aucune variante indiquée. Attendu : ${VARIANTS[*]} ou all."
  target="$(choose_variant)"
fi

if [ "$target" = "all" ]; then
  [ -z "$OUTPUT_NAME" ] || die "-o est incompatible avec « all » (plusieurs PDF produits)."
  for v in "${VARIANTS[@]}"; do
    build "$v"
  done
else
  build "$target"
fi
