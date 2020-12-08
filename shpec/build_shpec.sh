#!/usr/bin/env bash

set -e
set -o pipefail

source "./lib/utils/json.sh"
source "./lib/utils/log.sh"
source "./lib/build.sh"

install_tools() {
  mkdir -p tools/bin

  curl -Ls https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 > tools/bin/jq
  curl -Ls https://github.com/sclevine/yj/releases/download/v2.0/yj-linux > tools/bin/yj
  chmod +x tools/bin/*

  PATH="./tools/bin:$PATH"
}

create_temp_layer_dir() {
  mktemp -d -t layer_shpec_XXXXX
}

create_temp_project_dir() {
  mktemp -u -t project_shpec_XXXXX
}

create_temp_package_lock() {
  mkdir -p "$1"
  cp ./fixtures/package-lock/package-lock.json "$1"
}

create_temp_package_json() {
  mkdir -p "$1"
  cp "./fixtures/package-json$2/package.json" "$1"
}

rm_temp_dirs() {
  rm -rf "$1" "$2"
}

rm_tools_and_mocks() {
  rm -rf tools
  PATH=$CURRENT_PATH
}

# setup mocks
use_npm() {
  PATH="./mocks/npm/v$1/bin:$CURRENT_PATH"
}

describe "lib/build.sh"
  install_tools

  CURRENT_PATH=$PATH

  describe "prune_devdependencies"
    project_dir=$(create_temp_project_dir)
    use_npm 6

    it "skips pruning when NODE_ENV is not 'production'"
      export NODE_ENV=not-production
      result=$(prune_devdependencies "$project_dir")
      assert equal "$result" "Warning: Skip pruning because NODE_ENV is not 'production'."
    end

    it "successfully prunes when NODE_ENV is 'production'"
      export NODE_ENV=production
      result=$(prune_devdependencies "$project_dir")
      assert equal "$result" "[INFO] Successfully pruned devdependencies!"
    end

    it "successfully prunes devdependencies"
      prune_devdependencies "$project_dir"
      assert equal $? 0
    end

    rm_temp_dirs "$project_dir"
  end

  stub_command "log_info"

  describe "detect_package_lock"
    project_dir=$(create_temp_project_dir)

    it "detects when package-lock absent"
      set +e
      detect_package_lock "$project_dir"
      loc_var=$?
      set -e

      assert equal $loc_var 1
    end

    create_temp_package_lock "$project_dir"

    it "detects a package-lock file"
      detect_package_lock "$project_dir"

      assert equal "$?" 0
    end

    rm_temp_dirs "$project_dir"
  end

  describe "use_npm_ci"
    it "does not use npm ci with npm v5"
      use_npm 5

      set +e
      use_npm_ci
      loc_var=$?
      set -e

      assert equal $loc_var 1
    end

    it "uses npm ci with <= npm v5.7"
      use_npm 5.7

      use_npm_ci
      loc_var=$?

      assert equal $loc_var 0
    end

    it "uses npm ci with npm v6"
      use_npm 6

      use_npm_ci
      loc_var=$?

      assert equal $loc_var 0
    end
  end

  describe "install_or_reuse_npm"
    layers_dir=$(create_temp_layer_dir)
    project_dir=$(create_temp_project_dir)

    describe "when no engine specified"
      it "uses the version installed with Node"
        install_or_reuse_npm "$project_dir" "$layers_dir/npm"
        loc_var=$?

        assert equal $loc_var 0
      end
    end

    create_temp_package_json "$project_dir" "/engine-npm/6.0.0"
    use_npm 6

    describe "when an engine is specified"
      describe "and the engine version matches the installed version"
        it "uses the version installed with Node"
          install_or_reuse_npm "$project_dir" "$layers_dir/npm"

          assert file_absent "$(npm root -g --prefix "$layers_dir/npm")"
          assert file_absent "$layers_dir/npm.toml"
        end
      end

      create_temp_package_json "$project_dir" "/engine-npm/6.x"

      describe "and the engine latest version (ie. 6.x) matches the installed version"
        it "uses the version installed with Node"
          install_or_reuse_npm "$project_dir" "$layers_dir/npm"

          assert file_absent "$(npm root -g --prefix "$layers_dir/npm")"
          assert file_absent "$layers_dir/npm.toml"
        end
      end

      create_temp_package_json "$project_dir" "/engine-npm/6.14.x"

      describe "and the engine version does not match the installed version"
        it "installs the engine version of npm"
          install_or_reuse_npm "$project_dir" "$layers_dir/npm"

          assert file_present "$(npm root -g --prefix "$layers_dir/npm")"
          assert file_present "$layers_dir/npm.toml"
        end
      end
    end

    rm_temp_dirs "$project_dir" "$layers_dir"
  end

  describe "install_or_reuse_node_modules"
    layers_dir=$(create_temp_layer_dir)
    project_dir=$(create_temp_project_dir)

    describe "no package-lock.json"
      it "installs node_modules"
        install_or_reuse_node_modules "$project_dir" "$layers_dir/node_modules"

        assert file_present "node_modules"
      end
    end

    describe "package-lock.json does not match cached checksum"
      use_npm 6

      it "installs node_modules with 'npm ci'"
        #todo
      end


      describe "uses npm ci-incompatible version"
        use_npm 5

        it "installs node_modules with 'npm install'"
          #todo
        end
      end
    end

    describe "package-lock.json checksum matches the cached checksum"
      it "reuses the node_modules cache"
        #todo
      end
    end

    rm_temp_dirs "$project_dir" "$layers_dir"
  end

  describe "run_build"
    project_dir=$(create_temp_project_dir)

    use_npm 6

    create_temp_package_json "$project_dir" "/scripts/heroku-postbuild"

    describe "when package.json has a heroku-postbuild script"
      it "runs the heroku-postbuild script"
        run_build "$project_dir"

        assert file_present "heroku-postbuild"
      end
    end

    create_temp_package_json "$project_dir" "/scripts/build"

    describe "when package.json has a build script"
      it "runs the build script"
        run_build "$project_dir"

        assert file_present "build"
      end
    end

    rm_temp_dirs "$project_dir"
  end

  describe "write_launch_toml"
    layers_dir=$(create_temp_layer_dir)
    project_dir=$(create_temp_project_dir)

    create_temp_package_json "$project_dir" ""

    it "does not create a launch.toml file with no start script"
      assert file_absent "$layers_dir/launch.toml"

      write_launch_toml "$project_dir/package.json" "$layers_dir/launch.toml"

      assert file_absent "$layers_dir/launch.toml"
    end

    create_temp_package_json "$project_dir" "/scripts/start"

    it "creates a launch.toml file"
      assert file_absent "$layers_dir/launch.toml"

      write_launch_toml "$project_dir/package.json" "$layers_dir/launch.toml"

      assert file_present "$layers_dir/launch.toml"
    end

    rm_temp_dirs "$project_dir" "$layers_dir"
  end

  unstub_command "log_info"
  rm_tools_and_mocks
end
