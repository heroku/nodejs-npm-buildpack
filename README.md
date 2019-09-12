# Node.js NPM Cloud Native Buildpack

This buildpack builds on top of the existing [Node.js Engine Cloud Native Buildpack](https://github.com/heroku/nodejs-engine-buildpack). It runs subsequent scripts after Node is install.

- Run automatically
  - `npm install` or `npm ci`
- Run when configured in `package.json`
  - `npm run build` or `npm run heroku-postbuild`

## Usage

### Install pack

Using `brew` (assuming development is done on MacOS), install `pack`.

```sh
brew tap buildpack/tap
brew install pack
```

If you're using Windows or Linux, follow instructions [here](https://buildpacks.io/docs/install-pack/).

### Clone the buildpack

Right now, we are prototyping with a local version of the buildpack. Clone it to your machine.

```sh
git clone git@github.com:heroku/nodejs-npm-buildpack.git
```

Clone the Heroku Node.js Engine Cloud Native Buildpack.

```sh
git clone git@github.com:heroku/nodejs-engine-buildpack.git cd ..
```

### Build the image

Using pack, you're ready to create an image from the buildpack and source code. You will need to add flags that point to the path of the source code (`--path`) and the paths of the buildpacks (`--buildpack`).

```sh
cd nodejs-npm-buildpack
pack build TEST_IMAGE_NAME --path ../TEST_REPO_PATH --buildpack ../nodejs-engine-buildpack --buildpack ../nodejs-npm-buildpack
```

## Glossary

- buildpacks: provide framework and a runtime for source code. Read more [here](https://buildpacks.io).
- OCI image: [OCI (Open Container Initiative)](https://www.opencontainers.org/) is a project to create open sourced standards for OS-level virtualization, most importantly in Linux containers.
