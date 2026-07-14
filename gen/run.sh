#!/usr/bin/env bash
set -euo pipefail

SLUGS=$(cue export ./gen -e 'strings.Join([for slug,_ in evals {slug}]," ")' --out text)

rm ./evals/recipes/*.yaml

for slug in ${SLUGS[@]}; do
  echo "$slug"
  cue export ./gen -e "evals.\"$slug\"" -fo evals/recipes/$slug.yaml
done