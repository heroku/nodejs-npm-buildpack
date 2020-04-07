#!/usr/bin/env bash

set -e
set -o pipefail

source "./lib/detect.sh"

create_temp_project_dir() {
  mktemp -dt project_shpec_XXXXX
}

describe "lib/detect.sh"
  describe "detect_package_json"
    project_dir=$(create_temp_project_dir)

    it "detects if there is no package.json"
      set +e
      detect_package_json "$project_dir"
      loc_var=$?
      set -e

      assert equal $loc_var 1
    end

    it "detects if there is package.json"
      touch "$project_dir/package.json"

      detect_package_json "$project_dir"

      assert equal "$?" 0
    end

    rm -rf "$project_dir"
  end
end
