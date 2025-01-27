#!/bin/bash

set -Eeuo pipefail

declare -A versions=(
  [4.2.17]='177b7e004b90ec7faaac8e21e11b7bc33bd129aba2d512e4b011c37995f8480c'
  [4.4.7]='47af1651d5df3f25b6374ff6c1da71c66202d61919d9431c17259fa3df69ae59'
  [5.0.5]='90f845daaa436198c334b6e9cf5afb1df9f4445dcc165d0bcae35de9eb9be8ef'
)

for version in "${!versions[@]}"; do
  version_major_minor=${version%.*}

  mkdir -p "$version_major_minor"

  cp docker-entrypoint.sh RT_SiteConfig.pm "$version_major_minor"
  cp Dockerfile.template "$version_major_minor"/Dockerfile
  cp rt-passwd-from-env "$version_major_minor"/rt-passwd-from-env

  if [[ "$version_major_minor" == '4.2' ]]; then
    # RT 4.2 does not support --enable-externalauth
    sed -i '/--enable-externalauth/d' "$version_major_minor"/Dockerfile
  fi

  if [[ "$version" == *"alpha"* ]] || [[ "$version" == *"beta"* ]]; then
    release='devel'
  else
    release='release'
  fi

  sed -i \
    -e "s/%%RT_RELEASE%%/$release/" \
    -e "s/%%RT_SHA%%/${versions[$version]}/" \
    -e "s/%%RT_VERSION_MAJOR%%/${version%%.*}/" \
    -e "s/%%RT_VERSION%%/$version/" \
    "$version_major_minor"/docker-entrypoint.sh "$version_major_minor"/Dockerfile
done
