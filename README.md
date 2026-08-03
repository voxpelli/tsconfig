# @voxpelli/tsconfig

[![npm version](https://img.shields.io/npm/v/@voxpelli/tsconfig.svg?style=flat)](https://www.npmjs.com/package/@voxpelli/tsconfig)
[![npm downloads](https://img.shields.io/npm/dm/@voxpelli/tsconfig.svg?style=flat)](https://www.npmjs.com/package/@voxpelli/tsconfig)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/voxpelli/tsconfig)
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
  "extends": "@voxpelli/tsconfig/node22.json",
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

The browser presets intentionally set `"lib": ["ES2025", "DOM", "DOM.Iterable"]`. Note that ES2025 currently exceeds [Baseline](https://web.dev/baseline) _widely available_: per the official [web-features](https://github.com/web-platform-dx/web-features) dataset (July 2026), every ES2025 addition (Set methods, iterator helpers, `Promise.try`, `RegExp.escape`, `Float16Array`, …) is still Baseline _newly available_, with the last projected to reach widely-available in late 2027. TypeScript's `lib` describes which types exist — it is not a runtime guarantee — so this preset trusts you to know your own browser support target. If you need to stay within Baseline widely available, override locally with `"lib": ["ES2023", "DOM", "DOM.Iterable"]` (fully widely available except the rarely-typed symbols-as-`WeakMap`-keys) or `"ES2024"` once its remaining members cross over during 2026–2027. This alignment is tracked automatically — see [`baseline-data/`](baseline-data/).

### Node specific ones

These extend `base-node-jsdoc` with the correct [`lib`](https://www.typescriptlang.org/tsconfig#lib), [`module`](https://www.typescriptlang.org/tsconfig#module), [`moduleResolution`](https://www.typescriptlang.org/tsconfig#moduleResolution) and [`target`](https://www.typescriptlang.org/tsconfig#target) for each Node.js version.

Inspired by [tsconfig/bases](https://github.com/tsconfig/bases).

* [`node14`](node14.json) _deprecated_
* [`node16`](node16.json) _deprecated_
* [`node18`](node18.json) _deprecated_
* [`node20`](node20.json) _deprecated_ (EOL since April 2026)
* [`node22`](node22.json)
* [`node24`](node24.json)
* [`node26`](node26.json)
* [`nodenext`](nodenext.json) (currently an alias for `base-node-jsdoc`)

## TypeScript compatibility

This package supports TypeScript 6.0 and 7.0. (Need TypeScript 5.9? Stay on the `16.x` line.)

TypeScript 6.0 changed many defaults (`strict`, `esModuleInterop`, `allowSyntheticDefaultImports`, `noUncheckedSideEffectImports` are now all `true` by default; `types` defaults to `[]`). Since these configs already set the ones that matter explicitly, **users of this package are unaffected by those default changes**. The options that merely became redundant (`esModuleInterop`, `allowSyntheticDefaultImports`, `noUncheckedSideEffectImports`) have been dropped now that TS 5.9 is no longer supported.

TypeScript 6.0 was the last release built on the JavaScript codebase. TypeScript 7.0 is the native Go rewrite (originally previewed as `tsgo`) with roughly 10x faster type-checking — and in TS 7 the regular `tsc` binary _is_ the native compiler. CI validates every preset against both TypeScript 6.0 and 7.0.

### Migrating to TypeScript 7.0

These configs need no changes to work under TS 7 — they already avoid every option TS 7 removed. A few things to know about your own code and config when moving to TS 7:

* `ignoreDeprecations` no longer exists — options deprecated in TS 6.0 (e.g. `baseUrl`, `outFile`, `moduleResolution: node10`, `target: es5`) are now hard errors and must be removed.
* JavaScript/JSDoc checking was rewritten: some tags such as `@enum` and `@constructor` are no longer recognised, and a few "relaxed" JS inference rules were dropped, so JSDoc-heavy code may surface new errors.
* Type ordering in emitted declarations is now deterministic (content-based), so generated `.d.ts` output can differ from TS 6.0.
* The legacy compiler API (`createProgram`, `createLanguageService`, …) is gone, so tools that import `typescript` as a library — including type-aware ESLint rules and `type-coverage` — may need their own tsgo-compatible releases before they work under TS 7. (A new API is expected in TypeScript 7.1.)

Because these configs deliberately keep [`skipLibCheck: false`](https://github.com/voxpelli/tsconfig/issues/1), running `tsc` under TS 7 will also surface `TS2694 … has no exported member` errors from the bundled `.d.ts` of such tools (e.g. `@typescript-eslint/*`) that still reference the removed compiler API.

Until the ecosystem catches up, TypeScript's own recommendation is to keep 6.0 available side-by-side via npm aliases — use TypeScript 7's `tsc` for type-checking and the [`@typescript/typescript6`](https://www.npmjs.com/package/@typescript/typescript6) package (which re-exports the 6.0 API) for the tooling that needs it:

```json
{
  "devDependencies": {
    "typescript": "npm:@typescript/typescript6@^6.0.2",
    "typescript-7": "npm:typescript@^7.0.2"
  }
}
```

**Caveat:** with this setup, don't trust a bare `npx tsc` — the compat package transitively includes real TypeScript 6, whose `tsc` bin can win the `node_modules/.bin/tsc` link over `typescript-7`'s (npm picks an arbitrary winner on bin conflicts; in our testing the 6.0 bin won). Invoke TypeScript 7 by direct path instead, e.g. a script `"tsc7": "node node_modules/typescript-7/bin/tsc"`, and verify with `--version` (should report 7.x). With the alias in place, type-checking with `skipLibCheck: false` works again even alongside packages like `@typescript-eslint/*` whose bundled types still target the 6.0 compiler API.

Also note: TypeScript 7 ships no `tsserver` binary — editors use its new LSP-based server instead, and any tooling that spawns `tsserver` needs TypeScript 6 present.

#### Generating type declarations under TypeScript 7

Declaration emit from JSDoc (`tsc --declaration --emitDeclarationOnly`, see [Generate types](#generate-types)) is supported and correct on TypeScript 7.0 for code that type-checks cleanly — emit is undefined while errors exist, so fix all TS 7 check errors first. Regenerate and diff your `.d.ts` once when switching from 6.0: output is now deterministically ordered, so expect cosmetic churn. Keep using 6.0 (via the `tsc6` bin from the compat package) for declaration emit only if you rely on `removeComments: false` JSDoc-comment retention or legacy tags. Similarly, [`type-coverage`](https://github.com/plantain-00/type-coverage) imports the compiler API and needs the 6.0 alias until TypeScript 7.1.

#### How this package's CI tracks the transition

Every downstream dependent in this repo's canary CI is type-checked in escalating tiers: plain TypeScript 7 first (`TS7-clean`), then TypeScript 7 with the compat aliases shown above (`TS7+compat`), then TypeScript 6 (`TS6-only`). A project's achieved tier is visible in the workflow run summaries, so ecosystem progress toward native TypeScript 7 support is observable over time; only failing all three tiers is a genuine regression.

#### If a dependency's types break under TypeScript 7

These configs deliberately keep `skipLibCheck: false`, which means broken `.d.ts` in your dependencies surfaces in *your* type-check. If a dependency you can't wait on ships types that are incompatible with TypeScript 7 and the alias setup above doesn't help, override locally in your own tsconfig — `"skipLibCheck": true` — and file the issue upstream, rather than staying off TypeScript 7 entirely.

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
