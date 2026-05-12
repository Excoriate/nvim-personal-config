---
task_id: 2026-05-11-001-nvim-pristine-reproducible
agent: coordinator
status: draft
summary: Initial requirements mirror of P1 pre-flight; route lock pending user clarification.
---

# Initial Requirements — Mirror of P1 Pre-Flight

## Request (verbatim intent)
Ensure the nvim config at this repo is production-ready, "amazing hacker/max boot in nice/devex and productivity", with no broken plugins. Live-test against the user's actual nvim installation. Add reproducible install automation mirroring the pattern in `/Users/alextorresruiz/Dropbox/@GITHUB/@oss/dotfiles` (justfile). Verify and test before declaring done.

## Domain-class / Control-plane / CRUBVG
- DOMAIN-CLASS: implementation + investigation
- CONTROL-PLANE-ARTIFACT: yes (nvim config + install automation)
- CRUBVG: 2/1/2/1/2/2 → 11 → CRITICAL → Full mode

## Route-flip ambiguities (must resolve before P2 deep dive)
1. **Scope route**: surgical-improve current NvChad-based config vs migrate to a different base (LazyVim / kickstart.nvim / from-scratch).
2. **Platform target** for reproducibility: macOS only? macOS + Linux + WSL (repo has linux.lua/wsl.lua)?
3. **"Broken" symptoms** the user has observed (so live-testing targets the right surfaces).
4. **Aesthetic + UX bar**: keep current NvChad look or pursue a specific "hacker/max boot" aesthetic (theme, alpha/dashboard, startup screen)?

## Proposed Success Criteria (to be locked in P3)
- a. `nvim --headless +checkhealth +qa` reports zero ERROR rows.
- b. Cold-start emits no errors in `:messages` / `:Lazy log`; every plugin in `plugins/spec/` loads or is declared `enabled = false` intentionally.
- c. A `just` recipe installs the configuration end-to-end on a clean machine (deps + symlink/clone + first-run sync) and the resulting nvim passes (a) and (b).
- d. `stylua --check .` + `shellcheck` + markdownlint clean.
- e. `lazy-lock.json` committed and locked; the install path uses `:Lazy restore` (or equivalent) to guarantee identical plugin versions.

## Verification Strategy (preview; locked in P3)
- Truth surface: live `nvim --headless` execution (external runtime witness), independent of coordinator interpretation.
- Witness ≠ producer: adversarial frame agent reviews the verification commands themselves before they're trusted.
- Independent replay: install path tested under an isolated `XDG_CONFIG_HOME=/tmp/...` so the user's live state is not perturbed.
