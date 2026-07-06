#!/bin/sh
case "$1" in
*.md | *.markdown)
  glow -s dark -- "$1"
  ;;
*.pdf)
  tmp=$(mktemp /tmp/lf-pdf-XXXXXX)
  pdftoppm -r 150 -l 1 -png -singlefile "$1" "$tmp"
  chafa -f sixel -s "$2x$3" -- "${tmp}.png"
  rm -f "${tmp}" "${tmp}.png"
  ;;
*.jpg | *.jpeg | *.png | *.gif | *.bmp | *.webp | *.tiff)
  chafa -f sixel -s "$2x$3" -- "$1"
  ;;
*.tf | *.tfvars | *.hcl)
  bat --color=always --style=numbers --language=hcl "$1" 2>/dev/null || cat "$1"
  ;;
*)
  # fallback: use bat or cat
  bat --color=always --style=numbers "$1" 2>/dev/null || cat "$1"
  ;;
esac
