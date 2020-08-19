.EXPORT_ALL_VARIABLES:

.PHONY: clean \
        package \
        release

SHELL=/bin/bash -o pipefail

VERSION := "v$$(cat buildpack.toml | grep version | sed -e 's/version = //g' | xargs)"

test:
	make shellcheck
	make docker-unit-test

docker-unit-test:
	@docker run -v $(PWD):/project danielleadams/shpec:latest

unit-test:
	shpec ./shpec/*_shpec.sh

clean:
	-rm -f nodejs-npm-buildpack-$(VERSION).tgz

package: clean
	@tar cvzf nodejs-npm-buildpack-$(VERSION).tgz bin/ lib/** buildpack.toml README.md

release:
	@git tag $(VERSION)
	@git push --tags origin main

shellcheck:
	@shellcheck -x bin/build bin/detect
	@shellcheck -x lib/*.sh lib/utils/*.sh shpec/*.sh
