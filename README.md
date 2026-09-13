# sc-testing-tools-playground

Playground and regression test suites for [`sc-testing-tools`](https://github.com/input-output-hk/sc-testing-tools).

This repository ports the Cardano smart-contract use-case test suites from `sc-testing-tools` (`src/use-cases`) in **two parallel test suites** to validate both normal contract verification and threat-model misconfiguration reporting:

1. **`normal-examples`** — Faithful, passing test suites matching upstream contract models and threat analysis.
2. **`flipped-examples`** — Regression fixtures where `threatModels` and `expectedVulnerabilities` lists are intentionally **swapped**, causing every test suite to fail on execution.

---

## Background: Threat Models vs Expected Vulnerabilities

In the `convex-testing-interface` framework:
- **`threatModels`**: Represents the threat models against which a contract is claimed to be *secure*. A test **fails** if an attack defined in this list succeeds against any generated transaction (i.e. vulnerability detected = test failure).
- **`expectedVulnerabilities`**: Represents known vulnerabilities or limitations under test. A test **fails** if the vulnerability is *not* detected (i.e. attack rejected by script = test failure).

Swapping these two lists inverts the testing assertions:
- Known/real vulnerabilities asserted under `threatModels` will succeed against the contract and cause immediate `FAIL: Vulnerability detected`.
- Mitigated attacks asserted under `expectedVulnerabilities` are legitimately rejected by the smart contracts, causing `FAIL: Expected vulnerability NOT found in 100 tested tests`.

---

## Running the Suites

All builds and tests should be run through the Nix development environment (`nix develop`):

### 1. Run the Normal Test Suite (Expected to PASS)

```bash
nix develop -c cabal test normal-examples
```

Result: **All 45 tests pass**.

### 2. Run the Flipped Test Suite (Expected to FAIL)

```bash
nix develop -c cabal test flipped-examples
```

Result: **34 out of 45 tests fail** (all 5 contract models fail their flipped threat assertions as expected).

---

## Ported Use Cases & Flipped Failure Analysis

| Use Case | Normal Status | Flipped Status | Reason for Flipped Failure |
| :--- | :--- | :--- | :--- |
| **Auction** | PASS | FAIL | • `doubleSatisfaction`, `largeDataAttack`, `largeValueAttack`, `timeBoundManipulation`, `tokenForgeryAttack` fail under `threatModels` because the auction contract is vulnerable to them.<br>• `invalidDatumIndexAttack`, `missingOutputDatumAttack`, `negativeIntegerAttack`, `outputDatumHashMissingAttack`, `unprotectedScriptOutput`, `valueUnderpaymentAttack` fail under `expectedVulnerabilities` because the contract rejects them with CEK/validation errors. |
| **Escrow** | PASS | FAIL | • `doubleSatisfaction` and `timeBoundManipulation` fail under `threatModels` because the contract does not prevent them.<br>• `signatoryRemoval` fails under `expectedVulnerabilities` because the escrow contract properly rejects transactions missing required contributor signatures. |
| **MultiPlayerPingPong** | PASS | FAIL | • `duplicateListEntryAttack` fails under `threatModels` because the contract allows duplicate player list entries.<br>• 10 mitigated attacks (`datumListBloatAttack`, `invalidDatumIndexAttack`, `signatoryRemoval`, etc.) fail under `expectedVulnerabilities` because the validator rejects invalid transactions. |
| **RewardWithdrawal** | PASS | FAIL | • `signatoryRemoval` fails under `expectedVulnerabilities` because the withdrawal script requires the owner signature, rejecting tampered transactions. |
| **Vesting** | PASS | FAIL | • `invalidDatumIndexAttack`, `largeDataAttack`, `largeValueAttack`, `missingOutputDatumAttack`, `outputDatumHashMissingAttack`, `unprotectedScriptOutput` fail under `threatModels` because vesting is vulnerable to output-datum manipulation on continuing UTxOs.<br>• `signatoryRemoval` and `timeBoundManipulation` fail under `expectedVulnerabilities` because the contract enforces deadlines and owner signatures. |

---

## Dependency Structure

- **`sc-testing-tools`**: [`36b4dc9cc7b6658af2257425e7d3f2674106035f`](https://github.com/input-output-hk/sc-testing-tools/commit/36b4dc9cc7b6658af2257425e7d3f2674106035f) (`convex-testing-interface`, `convex-tasty-streaming`)
- **`sc-tools`**: [`c50e9edf2606d149820d41c2d4f82fae54eb21dd`](https://github.com/input-output-hk/sc-tools/commit/c50e9edf2606d149820d41c2d4f82fae54eb21dd) (`convex-base`, `convex-mockchain`, `convex-coin-selection`, `convex-optics`, `convex-wallet`, `convex-node-client`)
- **Compiler**: GHC 9.6.6 via CHaP / Haskell.nix
