# macos-configs

<p align="center">
  <img src="static/img/mac-rice.png" alt="MacOS rice" width="380">
</p>

Backup and restore of my macOS dotfiles / app configs. Files are stored at their
path relative to `$HOME` (e.g. `~/.config/aerospace/aerospace.toml` lives here as
`.config/aerospace/aerospace.toml`).

## Scripts

| Script              | Direction                | What it does |
|---------------------|--------------------------|--------------|
| `scripts/backup.sh`  | live configs → repo      | Copies each tracked file from `$HOME` into this repo. |
| `scripts/deploy.sh`  | repo → live locations    | Copies the repo's files back to their `$HOME` paths. |
| `scripts/install.sh` | Brewfile → Homebrew      | Installs Homebrew (if needed) and everything in `Brewfile`. |
| `scripts/macos-defaults.sh` | repo → `defaults` domains | Applies system settings that aren't files (screenshot hotkeys). Run automatically by `deploy.sh`. |

```bash
./scripts/backup.sh          # pull current configs into the repo

./scripts/deploy.sh          # preview, then confirm before overwriting
./scripts/deploy.sh -y       # skip the confirmation prompt
./scripts/deploy.sh -n       # dry run: show what would change, touch nothing

./scripts/install.sh         # install Homebrew + all Brewfile packages
./scripts/install.sh --check # report what's missing, install nothing

./scripts/macos-defaults.sh    # apply the non-file system settings on their own
./scripts/macos-defaults.sh -n # dry run: list them, change nothing
```

`deploy.sh` previews every action, asks before writing, and backs up any existing
target to `<file>.bak.<timestamp>` before overwriting. After the file copies it
runs `macos-defaults.sh` for the settings that have no config file.

## System settings (not files)

Some settings live in a `defaults` domain, so they can't be round-tripped as
files — `cfprefsd` caches the domain and would ignore or clobber a plain `cp`.
These are declared in `scripts/macos-defaults.sh`, which is the source of truth
for them (nothing to back up).

### Screenshot hotkeys

macOS's defaults (`⇧⌘3` / `⇧⌘4` / `⇧⌘5`) collide with AeroSpace's
`cmd-shift-N` → `move-node-to-workspace` bindings, so they're moved off `cmd`:

| Shortcut | Action |
|---|---|
| `ctrl+shift+3` | Full screen → file |
| `ctrl+shift+4` | Selection clipper → file |
| `ctrl+shift+5` | Screenshot & recording options |
| `ctrl+alt+shift+3` | Full screen → clipboard |
| `ctrl+alt+shift+4` | Selection clipper → clipboard |

Two gotchas worth remembering if you edit these:

- The `parameters` values **must** be integers. `defaults write -dict-add <id>
  "{...}"` stores them as strings and macOS silently ignores the entry.
- `plutil -replace` does not create intermediate dicts, so each hotkey entry is
  replaced whole — on a fresh Mac the per-id keys don't exist yet.

A logout may be needed if `activateSettings -u` doesn't make them live.

## Tracked files

- `.config/aerospace/aerospace.toml`
- `.config/karabiner/karabiner.json`
- `.config/snowflake/config.toml`
- `.config/lf/lfrc`, `.config/lf/cleaner.sh`, `.config/lf/previewer.sh`
- `.zshrc`, `.zshenv`, `.zprofile`
- `.config/shortcuts/` (alias files sourced by `.zshrc`)
- `.claude/gateway.settings.json` (Claude Code AI-gateway config. The API key it
  points at lives in `~/.ssh/api/` and is **not** tracked — provision it manually
  on a new machine.)

## Adding a file

Add its source path to the `CONFIGS` array in `scripts/backup.sh` and re-run
`./scripts/backup.sh`. `deploy.sh` auto-discovers whatever is in the repo, so it
needs no changes.
