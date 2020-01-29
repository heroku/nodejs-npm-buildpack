# Changelog
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.1.3 (2020-01-28)
###
- fix: remove `-buildpack` from buildpack id ([#16](https://github.com/heroku/nodejs-npm-buildpack/pull/16))
- feat: support running on `io.buildpacks.stacks.bionic` stack ([#17](https://github.com/heroku/nodejs-npm-buildpack/pull/17))

## 0.1.2 (2019-11-01)
###
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
