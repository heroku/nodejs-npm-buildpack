#!/usr/bin/env bash

# TODO: distinguish between npm <= and > 5.7.1 for ci.
# If a package.json is less than 5.7.1, and has a package-lock.json,
# it will break the build.

install_or_reuse_node_modules() {
  local build_dir=$1

  if [[ -f "$build_dir/package-lock.json" ]]; then
    echo "---> Restoring node modules from ./package-lock.json"
    npm ci
  else
    echo "---> Installing node modules"
    npm install --no-package-lock
  fi
}
