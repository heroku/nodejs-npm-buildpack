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

#### with buildpacks

Using pack, you're ready to create an image from the buildpack and source code. You will need to add flags that point to the path of the source code (`--path`) and the paths of the buildpacks (`--buildpack`).

```sh
cd nodejs-npm-buildpack
pack build TEST_IMAGE_NAME --path ../TEST_REPO_PATH --buildpack ../nodejs-engine-buildpack --buildpack ../nodejs-npm-buildpack
```

#### with a builder

You can also create a `builder.toml` file that will have explicit directions when creating a buildpack. This is useful when there are multiple "detect" paths a build can take (ie. yarn vs. npm commands).

In a directory outside of this buildpack, create a builder file:

```sh
cd ..
mkdir heroku_nodejs_builder
touch heroku_nodejs_builder/builder.toml
```

For local development, you'll want the file to look like this:

```toml
[[buildpacks]]
  id = "heroku/nodejs-engine-buildpack"
  uri = "../nodejs-engine-buildpack"

[[buildpacks]]
  id = "heroku/nodejs-npm-buildpack"
  uri = "../nodejs-npm-buildpack"

[[order]]
  group = [
    { id = "heroku/nodejs-engine-buildpack", version = "0.0.1" },
    { id = "heroku/nodejs-npm-buildpack", version = "0.0.1" }
  ]

[stack]
  id = "heroku-18"
  build-image = "heroku/pack:18"
  run-image = "heroku/pack:18"
```

Create the builder with `pack`:

```sh
pack create-builder nodejs --builder-config ../heroku-nodejs-builder/builder.toml
```

Now you can use the builder image instead of chaining the buildpacks.

```sh
pack build TEST_IMAGE_NAME --path ../TEST_REPO_PATH --builder nodejs
```

## Glossary

- buildpacks: provide framework and a runtime for source code. Read more [here](https://buildpacks.io).
- OCI image: [OCI (Open Container Initiative)](https://www.opencontainers.org/) is a project to create open sourced standards for OS-level virtualization, most importantly in Linux containers.
