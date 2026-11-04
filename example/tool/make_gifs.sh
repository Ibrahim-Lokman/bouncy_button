#!/usr/bin/env bash
# Records the README's screenshots and GIFs from the Features tab demos.
#
#   example/tool/make_gifs.sh            # every feature
#   example/tool/make_gifs.sh 05-motion  # only the ids that contain this
#
# Needs ffmpeg. The images go to gifs/features/ in the repository root, and
# are kept small for slow connections: each screenshot is a 400 pixel wide
# PNG with 128 colors, and each GIF runs at 15 frames per second.
set -euo pipefail

cd "$(dirname "$0")/.."
frames=build/gif_frames
out=../gifs/features
max_png=$((80 * 1024))
max_gif=$((1024 * 1024))

if ! command -v ffmpeg >/dev/null; then
  echo "ffmpeg is needed. On macOS: brew install ffmpeg" >&2
  exit 1
fi

filter=()
if [[ $# -gt 0 ]]; then
  filter=(--plain-name "$1")
fi
RECORD_GIFS=1 flutter test test/gifs/record_gifs_test.dart ${filter[@]+"${filter[@]}"}

mkdir -p "$out"
too_big=0
for dir in "$frames"/*/; do
  id=$(basename "$dir")
  if [[ $# -gt 0 && $id != *"$1"* ]]; then
    continue
  fi

  ffmpeg -v error -y -i "$dir/poster.png" \
    -vf "scale=400:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=128[p];[b][p]paletteuse=dither=none" \
    "$out/$id.png"

  # A feature shown by a screenshot only has no frames.
  if [[ -f "$dir/0000.png" ]]; then
    ffmpeg -v error -y -framerate 20 -i "$dir/%04d.png" \
      -vf "fps=15,scale=400:-1:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" \
      -loop 0 "$out/$id.gif"
  fi

  for file in "$out/$id.png" "$out/$id.gif"; do
    [[ -f $file ]] || continue
    size=$(wc -c <"$file" | tr -d ' ')
    limit=$max_gif
    [[ $file == *.png ]] && limit=$max_png
    flag=""
    if ((size > limit)); then
      flag="  <- too big"
      too_big=1
    fi
    printf '%-40s %6d KB%s\n' "$(basename "$file")" $((size / 1024)) "$flag"
  done
done

# pub.dev's screenshot gallery, at twice the size. pub.dev only shows
# screenshots that are inside the package, so these go to screenshots/.
for pair in 01-3d-press:feature-press 02-loading:feature-loading \
  07-styles:feature-styles 11-glass:feature-glass; do
  id=${pair%%:*}
  name=${pair##*:}
  [[ -f "$frames/$id/poster.png" ]] || continue
  ffmpeg -v error -y -i "$frames/$id/poster.png" \
    -vf "split[a][b];[a]palettegen[p];[b][p]paletteuse=dither=none" \
    "../screenshots/$name.png"
  printf '%-40s %6d KB\n' "screenshots/$name.png" \
    $(($(wc -c <"../screenshots/$name.png" | tr -d ' ') / 1024))
done

if ((too_big)); then
  echo "Some images are over the size limit." >&2
  exit 1
fi
