---
task_id: 2026-05-11-001
title: simplicity-maniac — Hickey complecting receipt
type: review
status: complete
agent: simplicity-maniac
summary: Eight braids identified across install harness — install/backup/confirm/hint braid, polish.lua tri-concern braid, user.lua twelve-plugin braid, lazy_setup policy/mechanism braid, justfile composite-recipe braid, init.lua bootstrap/provider-policy/deprecation-filter braid, kanagawa theme-mechanics/syntax-policy braid, snacks single-spec multi-module braid.
---

# Hickey Complecting Receipt — nvim install harness

Doctrine: Hickey, *Simple Made Easy* (one-fold = simple; braided = complect). The test
applied to every finding: **changing concept A forces concept B into working memory**.
Colocation alone is not complecting. Each finding names the axes fused and the
**NOT-a-finding** falsifier so this is not stylistic preference dressed as doctrine.

---

## F-1 — `nvim-install.sh` complects symlink, backup, confirmation, lock-verify, and first-run hint

**Complected concepts**
1. Symlink creation (mechanism)
2. Backup invocation (lifecycle / time)
3. Interactive confirmation (policy: human gate vs CI)
4. `lazy-lock.json` presence verification (reproducibility audit)
5. Post-install "next steps" UI (documentation/communication)
6. Dropbox-eviction readability probe (environment diagnostic)

**Where**: `scripts/nvim-install.sh:38-108`
- `:41-74` braid backup decision + confirmation prompt + symlink replacement
- `:81-85` braid filesystem-environment diagnostic with install success
- `:90-94` braid reproducibility audit with install path
- `:97-108` braid post-install documentation with install path

**Axes fused**: State (filesystem) + Time (backup-before-replace lifecycle) + Identity (which DEST slot) + Policy (interactive vs `--daily-driver` vs `DAILY_DRIVER_NONINTERACTIVE`) + Control (branching on existence kind) + Communication (echo blocks).

**Why it hurts (change-amplification)**:
- Adding a second confirmation mode (e.g. `--force`) requires editing the symlink path code (`:67`).
- Changing how backups are taken (e.g. parallelize, dry-run, label) requires editing install logic, because `nvim-backup.sh` is invoked positionally inside two different `if` branches with no shared contract.
- Wanting to install **without backup** (a perfectly legitimate ops case: backup already taken externally) is impossible without `--skip-backup` flag → another braid axis.
- The Dropbox readability check belongs to **environment diagnosis**, not install. A user fixing a Dropbox eviction would have to read install logic.
- The "next steps" block hard-codes the orchestration shape (`just sync` then `just try` then `just health`). Changing recipe names ripples here.

**Decomposition (toolkit of simplicity)**:
- `nvim-symlink.sh DEST SRC` — pure: create one symlink, fail if target exists. No backup, no confirmation, no hint. **Value**: the symlink, as data.
- `nvim-backup.sh` (already exists) — pure: snapshot.
- `nvim-confirm.sh "prompt"` — pure: interactive gate; honors `NONINTERACTIVE=1`.
- `nvim-verify-readable.sh PATH` — pure: environment probe.
- `nvim-lock-audit.sh PATH` — pure: reproducibility audit.
- Composition lives in `just install` / `just install-side` recipes (already the natural composition surface) or in a thin `nvim-install-flow.sh` whose **only** job is to call the above in order.

Each piece becomes testable, swappable, and skippable independently.

**NOT a finding**:
- "The script is 108 lines long." Length ≠ complecting. A 500-line pure function is still simple.
- "I'd split for readability." Stylistic preference. The braid is real because Time (backup-then-replace) + Policy (confirm gate) + State (which kind of DEST) are forced to vary together at modification time.

---

## F-2 — `polish.lua` complects three independent concerns in one module

**Complected concepts**
1. **Filetype-policy autocmds** (`:45-184`): tabstop, expandtab, commentstring, spell, textwidth per filetype — pure local-option policy.
2. **Editor-behavior autocmds** (`:6-42, 187-214`): terminal insert-mode, yank highlight, resize, trailing-whitespace stripping, cursor restoration, filetype detection — global UX behaviors.
3. **`snacks.nvim` UI wiring + health stub** (`:223-238`): `vim.ui.input`/`vim.ui.select` rebind + `snacks.image.health` monkey-patch — a plugin-integration adapter and a checkhealth-noise patch.

**Where**: `nvim-config/lua/polish.lua:1-238`

**Axes fused**: Identity (one file = one "polish" entity) + multiple Logic domains (filetype rules, UX automation, plugin adapter, health-output policy) + Time (init load order: this is the file that runs *after* `lazy_setup`, so the snacks block depends on that ordering and the filetype block does not — but they are forced to share that load-time identity).

**Why it hurts**:
- Adding a Rust filetype rule forces a reader past the snacks monkey-patch, the deprecation filter knowledge, and the trailing-whitespace exclusion list.
- The `snacks.image.health = function() end` patch (`:233-236`) is a workaround that should die when `snacks.image` is enabled. Its lifetime is **inversely coupled** to a plugin config in `plugins/user.lua:278` (`image = { enabled = false }`). Two files must change together — that is the textbook braid.
- The `vim.ui` rebind comment (`:216-222`) explicitly states it exists because `User VeryLazy` doesn't fire in headless. That is a **time/order** workaround. It belongs near the snacks spec, not near filetype policy.
- Testing the filetype rules in isolation requires loading the snacks adapter (which requires snacks loaded, which requires lazy.nvim) because they share the module.

**Decomposition**:
- `lua/polish/filetypes.lua` — pure filetype-local-option declarations (data, ideally a table consumed by one loop).
- `lua/polish/editor.lua` — UX autocmds (terminal, yank, resize, trailing-WS, cursor restore).
- `lua/polish/filetype-detect.lua` — pattern → filetype mapping (data table).
- `lua/polish/snacks-bridge.lua` — owns BOTH the `vim.ui.*` rebind AND the `snacks.image.health` no-op. Co-located with the *concept it integrates with*, not with filetype policy.
- `polish.lua` becomes 4 `require` lines. Each child file is touchable without dragging the others.

Bonus: the filetype rules are crying out to be **data, not control**. A table `{ go = { tab=4, expand=false }, yaml = {...} }` consumed by one autocmd is one fold; ten parallel autocmds with identical structure is the same braid replicated ten times.

**NOT a finding**:
- "polish.lua is 239 lines." Size is not the braid.
- "Autocmds are slow." Performance, not complecting.
- The filetype rules among themselves are **adjacent**, not braided — changing `python` doesn't force loading `go`. Only the three-concern split (filetype / editor / snacks) is the real braid.

---

## F-3 — `plugins/user.lua` complects twelve unrelated plugin specs in one LazySpec table

**Complected concepts** (each a distinct plugin domain): Kanagawa theme overrides, crates.nvim, aerial-disabled stub, git-conflict, gitlinker, markdown-preview, nvim-bqf, telescope-terraform-doc, gopher.nvim, smear-cursor, vim-fugitive, snacks.nvim (multi-module mega-spec), LuaSnip extension.

**Where**: `nvim-config/lua/plugins/user.lua:1-327`

**Axes fused**: Identity (one file = one "user plugin set") + Logic (12 unrelated configs) + Lifecycle (12 different `event`/`cmd`/`ft`/`lazy` triggers braided into one return table) + Documentation (rationale comments for `aerial` disablement, `nvim-colorizer` removal, `lsp_signature` removal are scattered inline).

**Why it hurts**:
- Changing the Kanagawa palette forces a reader past 200 lines of unrelated plugin specs to find the `overrides` function.
- The `aerial.nvim` disabled-block (`:127-136`) is a **paused-plugin gravestone** that lives with active plugins. When upstream fixes it, finding it requires knowing it's in `user.lua`.
- The `snacks.nvim` block (`:261-315`) is itself a mega-spec configuring 11 sub-modules (dashboard, bigfile, bufdelete, image, input, notifier, picker, quickfile, scratch, scroll, words, zen). It deserves its own file. Touching `notifier.timeout` should not put `dashboard.preset.header` ASCII art in the reader's working memory.
- Adding a new plugin requires editing this file → merge-conflict surface with every other plugin change.
- LazySpec ordering doesn't matter to lazy.nvim, but the file's reading order **does** matter to humans — and the order here is essentially arbitrary.

**Decomposition**:
- `plugins/colorscheme.lua` — Kanagawa only (and its TS/LSP highlight overrides, which deserve their own sub-module given their volume).
- `plugins/git.lua` — git-conflict + gitlinker + fugitive (these *are* a coherent domain).
- `plugins/lang-rust.lua`, `plugins/lang-go.lua`, `plugins/lang-terraform.lua`, `plugins/lang-markdown.lua` — language-local plugin sets.
- `plugins/ui.lua` — bqf, smear-cursor (cursor visuals).
- `plugins/snacks.lua` — the mega-spec gets its own file; that file may further split snacks per module if any module's opts grow.
- `plugins/snippets.lua` — LuaSnip extension.
- `plugins/disabled.lua` — gravestones (aerial, etc.) so the *concept* "plugins we have decided to keep off, and why" has a single home.

lazy.nvim's `{ import = "plugins" }` already aggregates these. The braid is purely a file-organization mistake.

**NOT a finding**:
- "12 plugins is too many." Plugin count is essentialness of the domain; not the braid.
- "lazy specs should be small." Style claim. The real fault is that the **rationale-of-disabling**, **theme palette**, **plugin lifecycle**, and **module-internal config** are all forced to vary together inside one file.

---

## F-4 — `lazy_setup.lua` complects pin-policy with framework-mechanism with checkhealth-cosmetics

**Complected concepts**
1. **AstroNvim version pin** (`:4`: `version = "^6"`) — policy: "we commit to AstroNvim v6 semver-major for reproducibility."
2. **Lazy.nvim mechanism config** (`:18-22`: install colorscheme list, UI backdrop, `rocks.enabled = false`) — mechanism: how lazy itself behaves.
3. **Performance/RTP disabling** (`:23-35`: disabling gzip, netrwPlugin, tarPlugin, etc.) — policy with a different motivation (startup time).
4. **Plugin import composition** (`:14-15`: `community`, `plugins`) — topology/identity decision: which spec namespaces participate.
5. **`rocks.enabled = false` comment** (`:20-22`) makes explicit that this knob exists to **suppress a checkhealth ERROR row** — a cosmetic concern, not a behavioral one. That's a fourth concept (UI/observability policy) inside the lazy config object.

**Where**: `nvim-config/lua/lazy_setup.lua:1-37`

**Axes fused**: Policy (pin version, disable rtp plugins, disable rocks) + Mechanism (lazy options) + Composition (which imports) + Observability/cosmetics (silencing checkhealth) — all crammed into one nested table literal.

**Why it hurts**:
- Bumping AstroNvim to v7 (a *policy* decision with rollback consequences) is a one-character edit on `:4`, but to a reader, the change sits inside the same table as `backdrop = 100`. That's policy and decoration with equal visual weight.
- The `rocks.enabled = false` was set to **silence checkhealth**, not because the build couldn't use luarocks. The comment says so. That is a **checkhealth-cosmetic decision masquerading as a build-mechanism config**. If checkhealth changes its mind, this knob is now lying about its purpose.
- The disabled-plugins list (`:25-33`) is **a startup-perf policy**. Adding `man` to it is a different decision from "disable luarocks." Forcing them into one table forces the reader to evaluate them together.

**Decomposition**:
- `lua/policy/astronvim-pin.lua` returns `{ version = "^6", import = "astronvim.plugins" }` — pin lives where pin lives. Frontmatter the file with the bump policy.
- `lua/policy/perf-rtp.lua` returns the disabled-plugin list. Comment cites the startup-time motivation.
- `lua/policy/checkhealth-cosmetics.lua` returns `{ rocks = { enabled = false } }` (or whatever flags are *only* there to silence checkhealth). The name itself prevents future readers from mistaking it for real config.
- `lazy_setup.lua` composes them: `lazy.setup(specs, vim.tbl_deep_extend("force", perf_rtp, cosmetics, mechanism))`.

The point is **not** more files. The point is that **the reason a knob exists** is recoverable from its location.

**NOT a finding**:
- "37 lines is fine, leave it." True for size; false for braid: `version = "^6"` (policy) and `backdrop = 100` (cosmetic) sit in the same literal with no naming distinction.

---

## F-5 — `justfile` `bootstrap` / `promote` recipes complect orchestration with dependency-as-policy

**Complected concepts**
1. **Recipe dependency declaration** (`bootstrap: deps install-side sync`, `promote: backup install sync` — `:132`, `:139`) — just's dependency syntax expresses "run A then B then C."
2. **What the user should do next** (the `echo` blocks at `:133-136`, `:140-142`) — communication artifact about the next recipe to run (`just try`, `just health`, `just rollback`).
3. **Health probe absence** — `bootstrap` *mentions* health (`echo "Health probe: just health"`) but does **not** invoke it. `promote` does the same. The recipe complects "run the install sequence" with "tell the user what to run after," and one of those things (the health check) is **identical in both recipes** and yet is left to the user.

**Where**: `justfile:131-143`

**Axes fused**: Control (the dependency chain), Communication (echo hints), and an implicit Policy decision ("we do not auto-run health"). The user has no way to compose `install + health` without typing both — except that `bootstrap` already chose to compose three steps and arbitrarily stopped before the fourth.

**Why it hurts**:
- Adding a step to the bootstrap (e.g. cache-warm) requires editing both the dep list AND the echo block, because the echo enumerates the orchestration shape.
- The echo block is **documentation as code** — it goes stale the moment a recipe is renamed.
- The asymmetry between `bootstrap` and `promote` (one mentions rollback, the other doesn't because side-by-side doesn't need it) is a policy difference encoded as echo-text divergence rather than as separate code paths.
- A user who runs `just bootstrap` then `just health` and sees a failure has no automated rollback. If `bootstrap` had composed `deps install-side sync health` and just's failure semantics kicked in, the policy "rollback on health failure" would be expressible.

**Decomposition**:
- Recipes describe **mechanism** only: `install-flow := deps install-side sync health`.
- A separate `_help-after-install` recipe (or a `printf` helper) renders the next-steps block, and recipes invoke it explicitly. Renaming `try` updates one location.
- Or: lean on just's built-in `@just --list` and delete the echoes entirely. The "next steps" hint is not the install's job.

**NOT a finding**:
- "Echo blocks are fine." They are, in a non-versioned shell script. In a `justfile` that the README points to, they are documentation duplicated from `just --list`.
- "Composite recipes are the *opposite* of complecting — they decompose." Partially true: just's dependency syntax IS a composition primitive (good). The braid is that the recipe **also** carries hints that re-encode the composition in prose (bad). The composition primitive is simple; the hint duplication braids communication onto it.

---

## F-6 — `init.lua` complects bootstrap with provider-policy with deprecation-filter

**Complected concepts**
1. **`vim.tbl_flatten` shim** (`:6`) — compatibility patch for Nvim 0.11+ deprecation.
2. **Provider disablement** (`:10-13`) — user/host policy: which language hosts we don't use.
3. **Deprecation-warning filter** (`:25-38`) — observability policy: suppress two known upstream deprecation messages.
4. **Lazy.nvim bootstrap** (`:40-61`) — install/clone mechanism + fatal-error UI.
5. **Module loading sequencing** (`:63-64`: `require "lazy_setup"; require "polish"`) — orchestration.

**Where**: `nvim-config/init.lua:1-65`

**Axes fused**: Time (Nvim 0.11 compat shim must run before plugins) + Policy (provider disable, dep filter prefix list) + Mechanism (lazy clone) + Identity (which modules to require, in which order) + Communication (fatal-error echo).

**Why it hurts**:
- The `_suppressed_prefixes` list (`:26-29`) is a **policy decision** ("we have decided to tolerate these two upstream deprecations until plugins migrate"). Its existence is coupled to two plugin authors' issue trackers. The comment is excellent. The location is wrong: it belongs near the affected plugins, not next to lazy bootstrap.
- The provider-disable block is **independent** of bootstrap. A user reviewing "which providers are we using" reads through bootstrap logic to find the answer.
- The `vim.tbl_flatten` shim has the same shape as the deprecation filter — both are upstream-compat patches — but they live as separate concepts with no shared module.
- The fatal-error echo paths (`:47, 58`) duplicate the "tell the user something went wrong" idiom inline.

**Decomposition**:
- `lua/bootstrap/lazy.lua` — only: locate lazypath, clone if missing, prepend rtp. Returns boolean.
- `lua/policy/providers.lua` — only: which `loaded_*_provider` flags we set to 0, with rationale.
- `lua/compat/nvim-0.12.lua` — only: `vim.tbl_flatten` shim + the deprecation filter prefix list. Both are "we run on a Nvim version where upstream code hasn't migrated yet" concerns; that's **one concept**.
- `init.lua` becomes a sequenced require list. The reader's question "why is `client.supports_method` filtered?" is answered by opening `compat/nvim-0.12.lua` — not by scrolling past lazy clone logic.

**NOT a finding**:
- "init.lua is short, leave it." True size-wise; false braid-wise. Five concerns in 65 lines is denser, not simpler.
- "The shim has to run early." Yes — that is a **Time** constraint expressible by ordering the requires. It does not require the shim to be **inlined** in `init.lua`.

---

## F-7 — Kanagawa spec complects mechanism, theme-policy, and per-token style policy

**Complected concepts**
1. **Mechanism**: `compile = true`, `transparent = true` (`:10-11`) — kanagawa-the-plugin behavior.
2. **Theme variant selection**: `theme = "wave"` (`:12-16`) — policy: which kanagawa variant is default.
3. **Palette overrides** (`:29-34`) — color values (data).
4. **TreeSitter capture style rules** (`:51-83`) — per-language-feature highlight policy.
5. **LSP semantic-token style rules** (`:86-102`) — per-LSP-token-kind highlight policy.
6. **Diagnostic underline rules** (`:104-108`) — diagnostic-presentation policy.

**Where**: `nvim-config/lua/plugins/user.lua:6-112`

**Axes fused**: Plugin-mechanism (compile/transparent) + Theme-variant-policy + Color-data + TS-style-policy + LSP-style-policy + Diagnostic-style-policy — all crammed into one `opts = { ... overrides = function() return { ... } end }` blob.

**Why it hurts**:
- The TS captures (`:51-83`) are essentially a **data table** mapping `@variable.builtin` → `{ fg = palette.oniViolet, italic = true }`. Today they live inside a closure returned by `overrides`, which means they cannot be swapped, audited, or reused across themes without rewriting the closure.
- Switching to a different theme requires duplicating the TS/LSP capture tables, because they're a **theme-agnostic policy** ("we want builtins italicized, regex strings in `boatYellow2`") trapped inside a **theme-specific function**.
- Tweaking one capture (e.g. make `@comment` non-italic) requires the reader to load palette identities, theme-variant context, and the closure structure simultaneously.

**Decomposition**:
- `lua/theme/syntax-policy.lua` returns `{ ["@variable"] = { italic = true }, ... }` — pure data, theme-agnostic where possible. The values reference palette keys, not concrete hex codes.
- `lua/theme/diagnostic-policy.lua` — diagnostic underline rules. Reusable across colorschemes.
- `lua/theme/kanagawa.lua` — kanagawa-the-plugin spec. Its `overrides` function **applies** the policy tables to the kanagawa palette.
- Want to try tokyonight? `lua/theme/tokyonight.lua` applies the same policy tables to its palette. The style policy is no longer trapped.

**NOT a finding**:
- "It's just colorscheme config, who cares." The braid bites the moment a second theme is considered (the README implies `just theme tokyonight-storm` works) — and the syntax-policy tables would have to be **re-authored** per theme, which is exactly the duplication Hickey calls "the same braid replicated."

---

## F-8 — `snacks.nvim` spec complects eleven independent UI modules in one opts table

**Complected concepts**: dashboard ASCII art (`:297-313`), bigfile threshold policy (`:276`), bufdelete (`:277`), image disablement + comment about ghostscript/kitty (`:278`), input (`:279`), notifier style + timeout (`:280-284`), picker.ui_select (`:285`), quickfile (`:286`), scratch (`:287`), scroll (`:288`), words debounce (`:289`), zen win.backdrop (`:290-296`).

**Where**: `nvim-config/lua/plugins/user.lua:261-315`

**Axes fused**: Identity (one `snacks.nvim` plugin entry) + 11 distinct module policies + a `lazy = false` Time decision driven by **only one** of those modules (input + picker.ui_select, per the comment at `:263-265`).

**Why it hurts**:
- `lazy = false` is a **per-module Time decision**: input/picker must replace `vim.ui.*` before the first prompt. The other nine modules don't need eager loading, but they get it because they share the entry.
- The `image = { enabled = false }` flag (`:278`) is **coupled to the polish.lua health monkey-patch** (F-2). Two files must agree on an enablement decision.
- The dashboard ASCII art (`:299-311`) is **content**, not policy — it has no business sharing visual space with `bigfile.size = 1.5 * 1024 * 1024` (a *threshold policy*). They are different kinds of decision.
- Touching `notifier.timeout` puts the dashboard art in the reader's working memory.

**Decomposition**:
- `plugins/snacks/init.lua` — the lazy entry; composes module opts via `vim.tbl_deep_extend`.
- `plugins/snacks/dashboard.lua` — ASCII art + preset. Contains content + cosmetic policy.
- `plugins/snacks/perf.lua` — bigfile + quickfile (perf-class modules).
- `plugins/snacks/ui-bridge.lua` — input + picker.ui_select. **This** file declares `lazy = false` and explains why. Time is isolated to where it matters.
- `plugins/snacks/notifications.lua` — notifier.
- `plugins/snacks/editing.lua` — bufdelete + scroll + scratch + words.
- `plugins/snacks/zen.lua` — zen.

The decomposition mirrors snacks' own module boundary. Currently the spec **erases** that boundary by funneling everything through one opts table.

**NOT a finding**:
- "snacks is designed to be a single plugin with sub-modules." That's snacks' delivery boundary; it does not mandate that **the consumer's spec** be a single blob. The consumer can deep-merge as many specs as desired — lazy.nvim supports identical plugin entries being merged.
- "lazy = false is fine." Eager loading isn't the braid. Eager loading **driven by a justification that applies to 2 of 11 modules** is the braid.

---

# Cross-finding pattern: this harness pays for ease with hidden braids

The dominant recurring shape across F-1 through F-8:

> A primitive (a file, a recipe, a lazy spec, a setup table) hosts **multiple concept classes** because doing so was *easy at authoring time* — one less file to create, one less recipe to define, one less import to wire. Each is a Hickey **ease purchase** that buys nothing structural and locks future changes into multi-axis edits.

The "next steps" hints in `nvim-install.sh` and `justfile` are particularly telling: they are **documentation about composition** living **inside** the things being composed. That is documentation complected with mechanism — the worst kind, because it goes stale silently and you only learn about it when a reader trusts the wrong copy.

**Six-month projection**:
- A new contributor will move `polish.lua` filetype rules into a child module and **forget** the snacks-image health monkey-patch. Result: `:checkhealth` re-grows ERROR rows; nobody knows why; the rationale comment is now in a deleted hunk.
- Adding a second theme (`just theme tokyonight-storm` already implies this is on the roadmap) will duplicate F-7's TS/LSP rules. The braid will replicate, not dissolve.
- A future bump of AstroNvim from `^6` to `^7` will require simultaneously reviewing `rocks.enabled = false`, `disabled_plugins`, the deprecation filter prefixes, and the snacks `lazy = false` justification — because none of them are co-located with their actual concept-of-concern.

---

# What this receipt is NOT

- It is **not** a refactor mandate. The braids are real; the priority is the user's call.
- It is **not** style critique. Every finding cites two or more concepts forced to vary together, with a falsifier.
- It does **not** recommend a different framework, language, or plugin manager. The doctrine survives in Lua / Bash / Just.

Handoff:
- Structural redesign (file topology, recipe boundaries) → `architect-kernel`.
- Proof that the un-braiding changed the failure surface (e.g. headless test that filetype rules load without snacks) → `verification-engineer`.
- Generic SOLID / responsibility-factoring critique → `uncle-bob`.
