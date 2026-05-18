# Copilot CLI extensions

Manages user-level skills and custom agents for [GitHub Copilot CLI](https://docs.github.com/copilot/concepts/agents/about-copilot-cli).

Upstream repos are cloned into `~/copilot-extensions/` (override with
`COPILOT_EXTENSIONS_DIR`) and symlinked into:

- `~/.copilot/skills/<name>/` for skills
- `~/.copilot/agents/<name>.agent.md` for custom agents

Only `extensions.txt` and the scripts are tracked here — never the cloned
upstream code.

## Files

- `extensions.txt` — source of truth: which repos, which paths, optional pinned ref.
- `bootstrap.sh` — clone missing repos and (re)create symlinks. Idempotent.
- `update.sh` — `git pull --ff-only` for each cloned repo. Pinned repos are skipped.

## Usage

```bash
./bootstrap.sh   # first run, or after editing extensions.txt
./update.sh      # keep upstreams current
```

`install.sh` at the repo root runs `bootstrap.sh` automatically.

## Adding a new skill or agent

Edit `extensions.txt`:

```
skill|<repo-url>|<path-inside-repo>|<link-name>[|<git-ref>]
agent|<repo-url>|<path-to-agent.md>|<link-name>.agent.md[|<git-ref>]
```

Use `.` for `<path-inside-repo>` when the skill lives at the repo root.

Then re-run `./bootstrap.sh`.

## Verifying inside Copilot CLI

```
/env       # see loaded skills, agents, instructions, MCP servers
/skills    # manage skills
/agent     # browse agents
```
