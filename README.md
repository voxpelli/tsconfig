# @voxpelli/tsconfig

My personal [types in js](https://github.com/voxpelli/types-in-js) focused tsconfig bases.

Are meant to be used with javascript code, not typescript code, hence having eg. `noEmit: true` set.

## Usage

```bash
npm install --save-dev @voxpelli/tsconfig
```

Then in your `tsconfig.json`, it [`extends`](https://www.typescriptlang.org/tsconfig#extends) the chosen base config:

```json
{
  "extends": "@voxpelli/tsconfig/node18.json",
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

* `base` – where most of the configuration is set
* `recommended` – like `base` but adds a [`target`](https://www.typescriptlang.org/tsconfig#target) set to `ES2015`

### Node specific ones

Extends `base` and adds the correct [`lib`](https://www.typescriptlang.org/tsconfig#lib) and [`target`](https://www.typescriptlang.org/tsconfig#target) for that version of node.js.

Inspired by [tsconfig/bases](https://github.com/tsconfig/bases).

* `node18`
* `node16`
* `node14`

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
