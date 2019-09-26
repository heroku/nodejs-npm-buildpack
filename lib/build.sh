#!/usr/bin/env bash

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

  local heroku_prebuild_script=$(json_get_key "$build_dir/package.json" ".scripts.heroku-prebuild")

  if heroku_prebuild_script ; then
    npm run heroku-prebuild
  fi
}

install_or_reuse_node_modules() {
  local build_dir=$1

  if detect_package_lock $build_dir ; then
    echo "---> Restoring node modules from ./package-lock.json"
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

run_build() {
  local build_dir=$1

  local build_script=$(json_get_key "$build_dir/package.json" ".scripts.build")
  local heroku_postbuild_script=$(json_get_key "$build_dir/package.json" ".scripts.heroku-postbuild")

  if heroku_postbuild_script ; then
    npm run heroku-postbuild
  else if build_script ; then
    npm run build
  fi
}
