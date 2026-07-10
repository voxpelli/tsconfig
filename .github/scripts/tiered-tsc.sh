#!/usr/bin/env bash
# Tiered type-check escalation for the dependents canary.
#
#   Tier 1: plain TypeScript ${TIER1_TS}                     -> "TS7-clean"
#   Tier 2: same TypeScript via the @typescript/typescript6
#           compat aliases (`typescript` resolves to the 6.0
#           API for tooling, `typescript-7` is the real tsc)  -> "TS7+compat"
#   Tier 3: plain TypeScript ${TIER3_TS}                      -> "TS6-only"
#   All fail                                                  -> "FAIL" (exit 1)
#
# Run with cwd = the dependent's checkout, after its tsconfig has been
# pointed at ../main. Compilers are always invoked by direct path — the
# compat package transitively ships a real TS 6 whose `tsc` bin can win
# the node_modules/.bin/tsc link over typescript-7's (npm bin conflicts
# have an arbitrary winner), so `npx tsc` must not be trusted here.
set -uo pipefail

TIER1_TS="${TIER1_TS:-7.0}"
TIER3_TS="${TIER3_TS:-6.0}"
PROJECT="${PROJECT_NAME:-unknown}"

report () {
  echo "tier=$1" >> "${GITHUB_OUTPUT:-/dev/null}"
  {
    echo "| Project | Result |"
    echo "| --- | --- |"
    echo "| \`${PROJECT}\` | **$1** |"
  } >> "${GITHUB_STEP_SUMMARY:-/dev/null}"
  echo "RESULT: ${PROJECT} -> $1"
}

# Dependents pinning typescript via npm `overrides` would fail every tier's
# install (EOVERRIDE is not bypassed by --force); the canary tests OUR chosen
# TypeScript versions, so drop such an override up front (no-op when absent).
npm pkg delete overrides.typescript

echo "::group::Tier 1: typescript@${TIER1_TS}"
tier1=1
if npm install --force --ignore-scripts "typescript@${TIER1_TS}" &&
   node node_modules/typescript/bin/tsc --version; then
  node node_modules/typescript/bin/tsc --pretty false > tier1-tsc.log 2>&1
  tier1=$?
  cat tier1-tsc.log
fi
echo "::endgroup::"
if [ "$tier1" -eq 0 ]; then report "TS7-clean"; exit 0; fi

# Classify the tier-1 failure so ecosystem blockage (broken .d.ts in
# node_modules, e.g. tools built on the removed TS 6 compiler API) is
# distinguishable from regressions in the presets or the project itself.
if [ -f tier1-tsc.log ] && grep -q 'error TS' tier1-tsc.log; then
  if grep 'error TS' tier1-tsc.log | grep -q '^\.\./main/'; then
    echo "::warning::${PROJECT}: TS ${TIER1_TS} reports errors in ../main/*.json — likely a regression in these presets, not the ecosystem"
  elif grep 'error TS' tier1-tsc.log | grep -v '^node_modules/' | grep -q .; then
    echo "::notice::${PROJECT}: TS ${TIER1_TS} errors include project files (not only node_modules .d.ts) — possible real TS ${TIER1_TS} incompatibility in the project"
  else
    echo "${PROJECT}: TS ${TIER1_TS} errors are confined to node_modules .d.ts — ecosystem-blocked, trying the compat aliases"
  fi
fi
rm -f tier1-tsc.log

echo "::group::Tier 2: typescript@${TIER1_TS} via @typescript/typescript6 compat aliases"
tier2=1
if npm install --force --ignore-scripts \
     'typescript@npm:@typescript/typescript6@^6.0.2' \
     "typescript-7@npm:typescript@${TIER1_TS}" &&
   node node_modules/typescript-7/bin/tsc --version; then
  node node_modules/typescript-7/bin/tsc --pretty false
  tier2=$?
fi
echo "::endgroup::"
if [ "$tier2" -eq 0 ]; then report "TS7+compat"; exit 0; fi

echo "::group::Tier 3: typescript@${TIER3_TS}"
tier3=1
# The typescript-7 alias ships a `tsc` bin that clashes with real TS 6 —
# remove the alias (manifest entry, installed copy, stale bin links) first.
npm pkg delete devDependencies.typescript-7 dependencies.typescript-7
rm -rf node_modules/typescript-7 node_modules/.bin/tsc node_modules/.bin/tsserver
if npm install --force --ignore-scripts "typescript@${TIER3_TS}" &&
   node node_modules/typescript/bin/tsc --version; then
  node node_modules/typescript/bin/tsc --pretty false
  tier3=$?
fi
echo "::endgroup::"
if [ "$tier3" -eq 0 ]; then report "TS6-only"; exit 0; fi

report "FAIL"
exit 1
