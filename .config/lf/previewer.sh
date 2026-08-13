#!/bin/sh
# $1 = file, $2 = width, $3 = height

# plain-text fallback used whenever a fancier tool is missing
show_text() {
  if command -v bat >/dev/null 2>&1; then
    bat --color=always --style=numbers --paging=never ${2:+--language="$2"} -- "$1"
  else
    cat -- "$1"
  fi
}

case "$1" in
*.md | *.markdown)
  if command -v glow >/dev/null 2>&1; then
    glow -s dark -- "$1"
  else
    show_text "$1" markdown
  fi
  ;;
*.pdf)
  if command -v pdftoppm >/dev/null 2>&1 && command -v chafa >/dev/null 2>&1; then
    tmp=$(mktemp /tmp/lf-pdf-XXXXXX)
    pdftoppm -r 150 -l 1 -png -singlefile "$1" "$tmp"
    chafa -f sixel -s "$2x$3" -- "${tmp}.png"
    rm -f "${tmp}" "${tmp}.png"
  else
    echo "[pdf] $(basename "$1")"
  fi
  ;;
*.jpg | *.jpeg | *.png | *.gif | *.bmp | *.webp | *.tiff)
  if command -v chafa >/dev/null 2>&1; then
    chafa -f sixel -s "$2x$3" -- "$1"
  else
    echo "[image] $(basename "$1")"
  fi
  ;;
*.tf | *.tfvars | *.hcl)
  show_text "$1" hcl
  ;;
*)
  case $(file --mime-type -b -- "$1") in
  text/* | */json | */xml | */javascript | */x-shellscript)
    show_text "$1"
    ;;
  *)
    file -b -- "$1"
    ;;
  esac
  ;;
esac
