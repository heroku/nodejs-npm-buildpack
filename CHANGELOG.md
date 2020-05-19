# Changelog
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## master

## 0.2.0 (2020-05-19)
### Added
- docs: add docs around `Permission denied` issues ([#28](https://github.com/heroku/nodejs-npm-buildpack/pull/28))
- Add dockerized unit tests ([#29](https://github.com/heroku/nodejs-npm-buildpack/pull/29))
- Added `provides` and `requires` of `node_modules` and `node` to buildplan. ([#18](https://github.com/heroku/nodejs-npm-buildpack/pull/18))

## 0.1.4 (2020-02-19)
### Added
- feat: install `npm` version specified in `package.json` ([#24](https://github.com/heroku/nodejs-npm-buildpack/pull/24))
- feat: exchange echo commands for `log_info` method ([#25](https://github.com/heroku/nodejs-npm-buildpack/pull/25))
### Fixed
- fix: use_npm_ci expression return value id ([#22](https://github.com/heroku/nodejs-npm-buildpack/pull/23))

## 0.1.3 (2020-01-28)
### Fixed
- fix: remove `-buildpack` from buildpack id ([#16](https://github.com/heroku/nodejs-npm-buildpack/pull/16))
- feat: support running on `io.buildpacks.stacks.bionic` stack ([#17](https://github.com/heroku/nodejs-npm-buildpack/pull/17))

## 0.1.2 (2019-11-01)
### Added
- feat: support build time environment variables ([#14](https://github.com/heroku/nodejs-npm-buildpack/pull/14))

## 0.1.1 (2019-10-30)
### Fixed
- Fix copying node_modules when a `package-lock.json` is present ([#12](https://github.com/heroku/nodejs-npm-buildpack/pull/12))

## 0.1.0 (2019-10-29)
### Added
- feat: use `npm start` as the default launch.toml ([#11](https://github.com/heroku/nodejs-npm-buildpack/pull/11))

## 0.0.2 (2019-10-11)
### Fixed
- Fix broken builds when a `package-lock.json` is missing ([#9](https://github.com/heroku/nodejs-npm-buildpack/pull/9))
