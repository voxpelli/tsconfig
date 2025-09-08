# @voxpelli/tsconfig

[![npm version](https://img.shields.io/npm/v/@voxpelli/tsconfig.svg?style=flat)](https://www.npmjs.com/package/@voxpelli/tsconfig)
[![npm downloads](https://img.shields.io/npm/dm/@voxpelli/tsconfig.svg?style=flat)](https://www.npmjs.com/package/@voxpelli/tsconfig)
[![Follow @voxpelli@mastodon.social](https://img.shields.io/mastodon/follow/109247025527949675?domain=https%3A%2F%2Fmastodon.social&style=social)](https://mastodon.social/@voxpelli)

My personal [types in js](https://github.com/voxpelli/types-in-js) focused tsconfig bases.

Are meant to be used with javascript code, not typescript code, hence they're having eg. `noEmit: true` set.

## Usage

```bash
npm install --save-dev @voxpelli/tsconfig
```

Then add an [`extends`](https://www.typescriptlang.org/tsconfig#extends) to your `tsconfig.json` like this:

```json
{
  "extends": "@voxpelli/tsconfig/node20.json",
  "files": [
    "index.js"
  ],
  "include": [
    "test/**/*",
  ]
}
```


## Available configs

### Base ones

* [`base-node-bare`](base-node-bare.json) – where most of the configuration is set (Node.js focused)
* [`base-jsdoc`](base-jsdoc.json) – adds JSDoc related config (now shared by both Node and Browser bases)
* [`base-node-jsdoc`](base-node-jsdoc.json) – combines `base-node-bare` and `base-jsdoc` for Node.js+JSDoc
* [`base-browser-bare`](base-browser-bare.json) – base config for browser environments
* [`base-browser-jsdoc`](base-browser-jsdoc.json) – combines `base-browser-bare` and `base-jsdoc` for Browser+JSDoc

### Browser specific ones

* [`browser`](browser.json) – main browser config, replicates `base-browser-jsdoc`

### Node specific ones

These extend `base-node-jsdoc` with the correct [`lib`](https://www.typescriptlang.org/tsconfig#lib), [`module`](https://www.typescriptlang.org/tsconfig#module), [`moduleResolution`](https://www.typescriptlang.org/tsconfig#moduleResolution) and [`target`](https://www.typescriptlang.org/tsconfig#target) for each Node.js version.

Inspired by [tsconfig/bases](https://github.com/tsconfig/bases).

* [`node14`](node14.json) _deprecated_
* [`node16`](node16.json) _deprecated_
* [`node18`](node18.json)
* [`node20`](node20.json)
* [`node22`](node22.json)
* [`node24`](node24.json)
* [`nodenext`](nodenext.json) (currently an alias for `base-node-jsdoc`)

## Can I use this in my own project?

Absolutely, my pleasure!

Just as with [voxpelli/eslint-config](https://github.com/voxpelli/eslint-config) I follow [Semantic Versioning](https://semver.org/) and thus won't do any breaking changes in any non-major releases.

Give me a ping if you use it, would be a delight to know you like it 🙂

## Generate types

When publishing a module, no matter if we use JSDoc or TS syntax we need to publish type declarations.

Here's how to generate type declarations when using JSDoc,

### 1. Declaration specific config file

Add a new declaration specific tsconfig (eg. `declaration.tsconfig.json`) that extends your base tsconfig. Something like:

```json
{
  "extends": "./tsconfig",
  "files": [],
  "exclude": [
    "test/**/*.js"
  ],
  "compilerOptions": {
    "declaration": true,
    "declarationMap": true,
    "noEmit": false,
    "emitDeclarationOnly": true
  }
}
```

The above excludes all top level files and all files in `test/` from having types generated. If one wants eg. `index.js` to have auto-generated types, then one needs to either remove `"files": [],` to use the inherited value or explicitly add it (`"files": ["index.js"],`).

If one uses eg. [`@deprecated`](https://www.typescriptlang.org/docs/handbook/jsdoc-supported-types.html#deprecated) and wants to retain JSDoc comments in ones type declarations, then one should set [`"removeComments": false`](https://www.typescriptlang.org/tsconfig/#removeComments) in the `compilerOptions`. By default `@voxpelli/tsconfig` sets `"removeComments": true` to keep generated types lean and DRY.

### 2. Add scripts

We should add scripts that uses the config file. These are examples add them to `"scripts"` in `package.json` and uses [`npm-run-all2`](https://github.com/bcomnes/npm-run-all2) to give clean separation and enable parallel execution.

#### Build script

```json
"build:0": "run-s clean",
"build:1-declaration": "tsc -p declaration.tsconfig.json",
"build": "run-s build:*",
```

When we run `build` we sequentially run all `build:*` using [`run-s`](https://github.com/bcomnes/npm-run-all2/blob/e9ca500b9a5f2d4550f4a72020afc1cd8d68b281/docs/run-s.md).

1. First we run `clean` to remove any pre-existing generated type declarations (as else they will be used as the source)
2. Then we run `tsc` which generates the new type declarations thanks to it using the declaration specific tsconfig

#### Clean script

```json
"clean:declarations-top": "rm -f $(find . -maxdepth 1 -type f -name '*.d.ts*' ! -name 'index.d.ts')",
"clean:declarations-lib": "rm -f $(find lib -type f -name '*.d.ts*' ! -name '*-types.d.ts')",
"clean": "run-p clean:*",
```

When we run `clean` we run all `clean:*` in parallel using [`run-p`](https://github.com/bcomnes/npm-run-all2/blob/e9ca500b9a5f2d4550f4a72020afc1cd8d68b281/docs/run-p.md).

Both clean commands use `rm -f` to delete a list of files found through `find`. The `-f` flag is needed since `find` may return an empty list, which without `-f` causes `rm` to fail.

The `find` command returns all matching type declaration files. It uses three flags:

* `-maxdepth 1'` is used when running in `.` to avoid recursing into `node_modules` (as we of course do _not_ want to remove any type declarations in there)
* `-name '*.d.ts*'` limits matching file names to `.d.ts` and `.d.ts.map` files. (If you generate `.mts` or `.cts` as well, then change this to `*.d.*ts*`)
* `-type f` ensures that only files are returned

The two clean scripts are:

* `clean:declarations-top` cleans all top level (`.`) type declarations except for `index.d.ts` (as that's often hand coded instead). One can remove the `! -name 'index.d.ts'` or add additional `! -name` sections to tweak what is ignored.
* `clean:declarations-lib` recursively cleans all type declarations in `lib` except for those ending with `-types.d.ts` (as our naming convention is that all such files are hand coded). One can add additional `! -name` sections to ignore further files.

#### Tweak type validation scripts

Assuming that we have something like the following that checks our types (if you're not using [`type-coverage`](https://github.com/plantain-00/type-coverage) you should start!):

```json
"check:tsc": "tsc",
"check:type-coverage": "type-coverage --detail --strict --at-least 99 --ignore-files 'test/*'",
```

Then we should make sure that we run `clean` before we run our checks as else `tsc` will use the type declarations rather than the JSDoc types when validating.

So we should do something like the following, it first runs `clean`, then runs `check:*` in parallel.

```json
"check": "run-s clean && run-p check:*",
```

#### Ensure we generate before publish

Lastly we should make sure that we generate the files before publish, something we can do by eg. adding a [`prepublishOnly`](https://docs.npmjs.com/cli/v8/using-npm/scripts#life-cycle-scripts) life cyle script:

```json
"prepublishOnly": "run-s build",
```

### 3. Ignore files in `.gitignore`

And something like this in your `.gitignore`:

```gitignore
# Generated types
*.d.ts
*.d.ts.map
!/lib/**/*-types.d.ts
!/index.d.ts
```

The ignores here (`!/lib/**/*-types.d.ts`, `!/index.d.ts`) matches the ignores we added in our [`clean:*`](#2-add-scripts) scripts

### Reference example

See my [`voxpelli/node-module-template`](https://github.com/voxpelli/node-module-template) repository for a fully functioning example of my current (and hopefully up to date) reference of this pattern.

## Alternatives

* [sindresorhus/tsconfig](https://github.com/sindresorhus/tsconfig)
* [tsconfig/bases](https://github.com/tsconfig/bases)

## My other reusable configs

* [voxpelli/eslint-config](https://github.com/voxpelli/eslint-config) – the reusable ESLint setup I use in my projects
* [voxpelli/ghatemplates](https://github.com/voxpelli/ghatemplates) – the reusable GitHub Actions workflows I use in my projects
* [voxpelli/renovate-config-voxpelli](https://github.com/voxpelli/renovate-config-voxpelli) – the reusable [Renovate setup](https://docs.renovatebot.com/config-presets/) I use in my projects
