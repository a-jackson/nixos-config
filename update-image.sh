#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash nix-prefetch-docker jq

image="$1"
tag="$2"

dir=$(dirname "$0")
imagesPath="$dir/images.json"

images=$(cat "$imagesPath")

imageName=$(echo "$images" | jq --arg image "$image" -r '.[$image].image')

newImage=$(nix-prefetch-docker --image-name "$imageName" --image-tag "$tag" --json)

digest=$(echo "$newImage" | jq -r '.imageDigest')
sha256=$(echo "$newImage" | jq -r '.sha256')

echo "$images" | jq \
  --arg digest "$digest" \
  --arg sha "$sha256" \
  --arg image "$image" \
  '.[$image].imageDigest = $digest | .[$image].sha256 = $sha' > "$imagesPath"
