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

Then in your `tsconfig.json`, it [`extends`](https://www.typescriptlang.org/tsconfig#extends) the chosen base config:

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

### Generic ones

* [`base`](base.json) – where most of the configuration is set
* [`legacy`](legacy.json) – like `base` but for older TypeScript versions – version 4.5 and onward
* [`recommended`](recommended.json) – like `base` but adds a [`target`](https://www.typescriptlang.org/tsconfig#target) set to `ES2015`

### Node specific ones

These extends `base` with the correct [`lib`](https://www.typescriptlang.org/tsconfig#lib) and [`target`](https://www.typescriptlang.org/tsconfig#target) for the node.js version.

Inspired by [tsconfig/bases](https://github.com/tsconfig/bases).

* [`node20`](node20.json)
* [`node18`](node18.json)
* [`node16`](node16.json)
* [`node14`](node14.json)

## Can I use this in my own project?

Absolutely, my pleasure!

Just as with [voxpelli/eslint-config](https://github.com/voxpelli/eslint-config) I follow [Semantic Versioning](https://semver.org/) and thus won't do any breaking changes in any non-major releases.

Give me a ping if you use it, would be a delight to know you like it 🙂

## Alternatives

* [sindresorhus/tsconfig](https://github.com/sindresorhus/tsconfig)
* [tsconfig/bases](https://github.com/tsconfig/bases)

## My other reusable configs

* [voxpelli/eslint-config](https://github.com/voxpelli/eslint-config) – the reusable ESLint setup I use in my projects
* [voxpelli/ghatemplates](https://github.com/voxpelli/ghatemplates) – the reusable GitHub Actions workflows I use in my projects
* [voxpelli/renovate-config-voxpelli](https://github.com/voxpelli/renovate-config-voxpelli) – the reusable [Renovate setup](https://docs.renovatebot.com/config-presets/) I use in my projects
