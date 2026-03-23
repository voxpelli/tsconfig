# TypeScript 7.0 (tsgo) Preparedness Plan for @voxpelli/tsconfig

## Context

TypeScript 7.0 is the native Go-based rewrite of the TypeScript compiler ("tsgo"). It reached stable release on January 15, 2026, and is available as both `typescript@7.0.x` and `@typescript/native-preview`. This document evaluates what TS 7.0 means for `@voxpelli/tsconfig` and what actions to take.

The repo currently supports `typescript ~5.9.0 || ~6.0.0` with `devDependencies` on `~6.0.0`.

---

## SWOT Analysis

### Strengths — What this repo already does well

**S1: All config options are fully tsgo-compatible.**
Core options in `base-node-bare.json` (`module: "nodenext"`, `moduleResolution: "nodenext"`, `target: "esnext"`, `lib: ["esnext"]`, `types: ["node"]`, `strict: true`) are all supported in tsgo without modification.

**S2: No use of any removed/deprecated options.**
None of the options removed in TS 7.0 are present: no `baseUrl`, `outFile`, `moduleResolution: node10/classic`, `target: es3/es5`, `module: amd/umd/system/none`, or `downlevelIteration`.

**S3: JSDoc-first, noEmit design.**
Since all configs set `noEmit: true`, the repo is immune to tsgo's incomplete emit limitations (declaration emit, downlevel emit). Type-checking — tsgo's strongest capability (~99.97% parity) — is the only thing that matters here.

**S4: CI already tests with tsgo.**
The `external.yml` workflow has a `test_tsgo` job with `continue-on-error: true`, providing forward-compatibility signal.

**S5: Node version configs pin `moduleResolution: "node16"`.**
This avoids any drift if `nodenext` changes meaning in future TS versions.

### Weaknesses — What could cause problems

**W1: Redundant `esModuleInterop`/`allowSyntheticDefaultImports: true`.**
In TS 7.0, these cannot be set to `false` (hard error). Setting them to `true` is fine but redundant. Low risk, but adds noise.

**W2: Node configs use `ESNext.*` lib entries instead of `es2025`.**
`node22.json` uses `["es2024", "ESNext.Array", "ESNext.Collection", "ESNext.Iterator"]` — these are "moving targets" that could gain unexpected additions. Cannot switch to `es2025` while supporting TS 5.9.

**W3: No `ignoreDeprecations` escape hatch documentation.**
TS 7.0 removes `ignoreDeprecations` entirely — all deprecated options become hard errors. Users extending these configs who have their own deprecated options get no migration help.

**W4: Known tsgo regression with `extends` glob resolution.**
microsoft/typescript-go#2699: tsgo resolves inherited `include`/`exclude` globs differently than tsc. This could affect downstream users extending these configs.

**W5: `stableTypeOrdering` differences not addressed.**
TS 7.0 uses deterministic content-based type ordering (always-on). Users generating `.d.ts` from JSDoc may see different output between TS 6.0 and TS 7.0.

**W6: Browser config uses conservative `ES2022` lib.**
`base-browser-bare.json` uses `lib: ["ES2022", "DOM"]` — browser users miss newer API types (Set methods, Iterator helpers, etc.).

### Opportunities — Things we can do proactively

**O1: Drop TS 5.9, clean up redundant options.**
Removing TS 5.9 support enables: removing `esModuleInterop: true`, `allowSyntheticDefaultImports: true`, `noUncheckedSideEffectImports: true` (all defaults in TS 6.0+), and switching node22/24 libs to `["es2025"]`.

**O2: Add `~7.0.0` to peerDependencies.**
Signals official tsgo support. Unblocks users who want to install without peer dep warnings.

**O3: Expand tsgo CI testing.**
Test each config individually (not just `node18.json` via root tsconfig) to catch per-config issues.

**O4: Add `node26.json` preset.**
Node 26 expected April 2026. Clean config with `lib: ["es2025"]`, `target: "es2025"`.

**O5: Update browser config lib to `ES2025`.**
After dropping TS 5.9, update from `["ES2022", "DOM"]` to `["ES2025", "DOM"]`.

**O6: Deprecate `node18` config.**
Node 18 reached EOL April 2025. Update root `tsconfig.json` to extend `node20` or `node22`.

**O7: Add migration guidance to README.**
Document TS 6.0 → 7.0 migration path: no `ignoreDeprecations`, type ordering diffs, glob resolution issue, JSDoc tag changes.

**O8: Consider tsgo as primary dev dependency.**
10x faster CI. Keep TS 6.0 in peerDeps for backward compatibility.

### Threats — External risks to watch

**T1: tsgo JSDoc behavioral differences (HIGH RISK).**
tsgo's JS type-checking was rewritten from scratch. `@enum` and `@constructor` JSDoc tags no longer recognized. Some "relaxed" JS type-checking behaviors removed. Generic type parameters from `@typedef`/`@template` may be dropped in declaration emit. This is a direct threat to a JSDoc-first config package.

**T2: tsgo `extends`/`include` glob resolution regression.**
microsoft/typescript-go#2699. Since this package is designed to be extended, glob resolution differences directly impact users.

**T3: Declaration emit incompleteness.**
tsgo's declaration emit is still incomplete. Users generating `.d.ts` from JSDoc (a documented use case) may get failures or incorrect output.

**T4: Ecosystem fragmentation.**
ESLint adapting via IPC layer, VS Code transitioning to LSP, framework tools (Vue, Jest, Nuxt) still updating. Users may need to maintain both `tsc` and `tsgo` during transition.

**T5: TypeScript API removal breaks tooling.**
tsgo does not support `createProgram()`, `createLanguageService()`, etc. Tools like `type-coverage` (recommended in README) may not work. IPC-based replacement API is in development.

**T6: Future `moduleResolution` changes.**
If `nodenext` evolves differently in tsgo, the pinned `moduleResolution: "node16"` strategy may diverge.

---

## Action Items

### Phase 1: Immediate (can do now)

| # | Action | Effort | Impact |
|---|--------|--------|--------|
| 1 | Expand tsgo CI to test **each config** individually | Low | Medium |
| 2 | Investigate JSDoc behavioral diffs by running tsgo against downstream projects | Medium | High |
| 3 | Document known TS 7.0 migration notes in README | Medium | Medium |

### Phase 2: After dropping TS 5.9 support

| # | Action | Effort | Impact |
|---|--------|--------|--------|
| 4 | Remove redundant options (`esModuleInterop`, `allowSyntheticDefaultImports`, `noUncheckedSideEffectImports`) | Low | Medium |
| 5 | Switch node22/node24 libs to `["es2025"]` | Low | Medium |
| 6 | Update browser config lib to `["ES2025", "DOM"]` | Low | Low |
| 7 | Deprecate `node18`, update root tsconfig to `node20` or `node22` | Low | Low |

### Phase 3: After tsgo validation passes

| # | Action | Effort | Impact |
|---|--------|--------|--------|
| 8 | Add `~7.0.0` to peerDependencies | Low | High |
| 9 | Remove `continue-on-error: true` from tsgo CI job | Low | Medium |
| 10 | Consider tsgo as primary devDependency | Low | Medium |

### Phase 4: Forward-looking

| # | Action | Effort | Impact |
|---|--------|--------|--------|
| 11 | Add `node26.json` preset | Low | Low |
| 12 | Test `type-coverage` and other recommended tools with tsgo | Medium | Medium |
| 13 | Track tsgo declaration emit progress for JSDoc → `.d.ts` use case | Ongoing | High |

---

## Key Decision Points

1. **When to add TS 7.0 to peerDeps?** After confirming all configs pass `tsgo` validation without errors (CI job currently allows failure).

2. **When to drop TS 5.9?** Natural point is the next major version (v18.0.0). This unblocks Phase 2 actions.

3. **When to make tsgo the primary dev dependency?** When declaration emit and JSDoc checking reach full parity. Currently risky for a JSDoc-first package due to T1.

4. **How to handle JSDoc behavioral differences?** Test downstream projects with tsgo, document known differences, and file issues on microsoft/typescript-go for regressions affecting JSDoc patterns.

---

## TS 7.0 Removed Options Reference

All options deprecated in TS 6.0 become **hard errors** in TS 7.0 (`ignoreDeprecations` no longer works):

| Removed Option | Replacement |
|----------------|-------------|
| `target: "es5"` / `"es3"` | `"es2015"` or higher |
| `module: "amd"` / `"umd"` / `"system"` / `"none"` | `"nodenext"` or `"es2022"` |
| `moduleResolution: "node10"` / `"node"` / `"classic"` | `"nodenext"` or `"bundler"` |
| `baseUrl` | Package.json `exports`/`imports` |
| `outFile` | External bundler (Webpack/Rollup/Vite) |
| `downlevelIteration` | Not needed with `target: "es2015"+` |
| `noStrictGenericChecks` | Remove (strict is default) |
| `keyofStringsOnly` | Remove |
| `suppressExcessPropertyErrors` | Remove |
| `esModuleInterop: false` | Cannot disable (always on) |
| `allowSyntheticDefaultImports: false` | Cannot disable (always on) |

## TS 7.0 Changed Defaults

| Setting | TS 6.0 | TS 7.0 |
|---------|--------|--------|
| `strict` | `false` | `true` |
| `target` | `"es2020"` | `"es2025"` |
| `moduleResolution` | `"node10"` | `"bundler"` |
| `rootDir` | inferred from sources | directory of tsconfig.json |
| `types` | auto-discovered | `[]` (must be explicit) |
| `noUncheckedSideEffectImports` | `false` | `true` |
| `stableTypeOrdering` | `false` | `true` (always on) |
