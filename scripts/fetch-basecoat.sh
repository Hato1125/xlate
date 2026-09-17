#!/bin/sh
set -eu

VERSION=1.0.2
DEST=vendor/basecoat

FILES="
base/base.css
styles/vega.css
components/button.css
components/button-group.css
components/card.css
components/field.css
components/input.css
components/label.css
components/popover.css
components/select.css
"

cd "$(dirname "$0")/.."

STAGE="$DEST.tmp"
rm -rf "$STAGE"
mkdir -p "$STAGE"
trap 'rm -rf "$STAGE"' EXIT

paths=""
for file in $FILES; do
  paths="$paths package/dist/$file"
done

curl -sSLf "https://registry.npmjs.org/basecoat-css/-/basecoat-css-$VERSION.tgz" \
  | tar -xz -C "$STAGE" --strip-components=2 $paths

# Basecoat switches to dark colors only under `html.dark`, which needs JS to
# toggle. Re-emit the same variables under a media query so the OS theme applies.
{
  echo "@media (prefers-color-scheme: dark) {"
  echo "  :root {"
  sed -n '/^\.dark {/,/^}/p' "$STAGE/base/base.css" | sed '1d;$d' | sed 's/^/  /'
  echo "  }"
  echo "}"
} > "$STAGE/dark-media.css"

rm -rf "$DEST"
mv "$STAGE" "$DEST"

echo "Basecoat $VERSION -> $DEST"
