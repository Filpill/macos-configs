# macos-configs

<p align="center">
  <img src="static/img/mac-rice.png" alt="MacOS rice" width="380">
</p>

Backup and restore of my macOS dotfiles / app configs. Files are stored at their
path relative to `$HOME` (e.g. `~/.config/aerospace/aerospace.toml` lives here as
`.config/aerospace/aerospace.toml`).

## Scripts

| Script       | Direction                | What it does |
|--------------|--------------------------|--------------|
| `backup.sh`  | live configs → repo      | Copies each tracked file from `$HOME` into this repo. |
| `deploy.sh`  | repo → live locations    | Copies the repo's files back to their `$HOME` paths. |

```bash
./backup.sh          # pull current configs into the repo

./deploy.sh          # preview, then confirm before overwriting
./deploy.sh -y       # skip the confirmation prompt
./deploy.sh -n       # dry run: show what would change, touch nothing
```

`deploy.sh` previews every action, asks before writing, and backs up any existing
target to `<file>.bak.<timestamp>` before overwriting.

## Tracked files

- `.config/aerospace/aerospace.toml`
- `.config/karabiner/karabiner.json`
- `.config/snowflake/config.toml`
- `.config/lf/lfrc`, `.config/lf/cleaner.sh`, `.config/lf/previewer.sh`
- `.zshrc`, `.zshenv`, `.zprofile`

## Adding a file

Add its source path to the `CONFIGS` array in `backup.sh` and re-run `./backup.sh`.
`deploy.sh` auto-discovers whatever is in the repo, so it needs no changes.

## Secrets

Tracked configs contain no raw secrets — only settings and *paths* to key/token
files (which live in `~/.ssh` and are not copied here). `.gitignore` also blocks
common secret patterns (`*.pem`, `*.key`, `PAT-*`, `*token*.txt`, …) as a safety net.
Keep this repo private.
