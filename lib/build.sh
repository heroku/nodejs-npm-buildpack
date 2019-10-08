#!/usr/bin/env bash

set -e

bp_dir=$(cd "$(dirname "$BASH_SOURCE")"; cd ..; pwd)

source "$bp_dir/lib/utils/json.sh"

detect_package_lock() {
  local build_dir=$1
  [[ -f "$build_dir/package-lock.json" ]]
}

use_npm_ci() {
  local npm_version=$(npm -v)
  local major=$(echo $npm_version | cut -f1 -d ".")
  local minor=$(echo $npm_version | cut -f2 -d ".")

  [[ "$major" > "5" || ("$major" == "5" || "$minor" > "6") ]]
}

run_prebuild() {
  local build_dir=$1

  local heroku_prebuild_script=$(json_get_key "$build_dir/package.json" ".scripts[\"heroku-prebuild\"]")

  if [[ $heroku_prebuild_script ]] ; then
    npm run heroku-prebuild
  fi
}

install_modules() {
  local build_dir=$1
  local layer_dir=$2

  if detect_package_lock $build_dir ; then
    echo "---> Installing node modules from ./package-lock.json"
    if use_npm_ci ; then
      npm ci
    else
      npm install
    fi
  else
    echo "---> Installing node modules"
    npm install --no-package-lock
  fi
}

install_or_reuse_node_modules() {
  local build_dir=$1
  local layer_dir=$2
  local local_lock_checksum=$(sha256sum "$build_dir/package-lock.json" | cut -d " " -f 1)
  local cached_lock_checksum=$(cat "$layer_dir.toml" | yj -t | jq -r ".metadata.package_lock_checksum")

  mkdir -p ${layer_dir}

  if [[ -f "$build_dir/package-lock.json" && $local_lock_checksum == $cached_lock_checksum ]] ; then
    echo "---> Reusing node modules"
    cp -r "$layer_dir" "$build_dir/node_modules"
  else
    echo "cache = true" > ${layer_dir}.toml
    echo "build = false" >> ${layer_dir}.toml
    echo "launch = true" >> ${layer_dir}.toml
    echo -e "[metadata]\npackage_lock_checksum = \"$local_lock_checksum\"" >> ${layer_dir}.toml

    install_modules "$build_dir" "$layer_dir"
    cp -r "$build_dir/node_modules" "$layers_dir"
  fi
}

run_build() {
  local build_dir=$1

  local build_script=$(json_get_key "$build_dir/package.json" ".scripts.build")
  local heroku_postbuild_script=$(json_get_key "$build_dir/package.json" ".scripts[\"heroku-postbuild\"]")

  if [[ $heroku_postbuild_script ]] ; then
    npm run heroku-postbuild
  elif [[ $build_script ]] ; then
    npm run build
  fi
}
