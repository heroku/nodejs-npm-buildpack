.EXPORT_ALL_VARIABLES:

.PHONY: clean \
        package \
        release

SHELL=/bin/bash -o pipefail

VERSION := "v$$(cat buildpack.toml | grep version | sed -e 's/version = //g' | xargs)"

test:
	make shellcheck

clean:
	-rm -f nodejs-npm-buildpack-$(VERSION).tgz

package: clean build
	@tar cvzf nodejs-npm-buildpack-$(VERSION).tgz bin/ lib/** buildpack.toml README.md

release:
	@git tag $(VERSION)
	@git push --tags origin master

shellcheck:
	@shellcheck -x bin/build bin/detect
	@shellcheck -x lib/* lib/utils/*
