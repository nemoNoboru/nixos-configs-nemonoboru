# pi (coding agent) setup

`pi` is installed system-wide from the `llm-agents` flake (see `flake.nix`). Its
user configuration lives in `~/.pi/agent/`; the parts worth sharing across machines
are tracked in this repo.

## Installed packages (plugins)

Pi packages are declared in `~/.pi/agent/settings.json` under `packages` and are
installed with `pi install`. This machine has two:

| Package | Version | What it does |
|---|---|---|
| `@sting8k/pi-vcc` | 0.10.0 | Algorithmic conversation compactor — transcript-preserving structured summaries with no LLM calls (VCC). |
| `pi-cache-optimizer` | 2.8.21 | Improves prompt/KV cache hit rates: stable prompts, OpenAI-compatible cache keys, proxy warnings, footer cache stats. |

Declared in `~/.pi/agent/settings.json`:

```json
{
  "packages": [
    "npm:@sting8k/pi-vcc",
    "npm:pi-cache-optimizer"
  ],
  "defaultProvider": "deepseek",
  "defaultModel": "deepseek-v4-pro"
}
```

### pi-vcc configuration

`~/.pi/agent/pi-vcc-config.json`:

```json
{
  "overrideDefaultCompaction": true,
  "smartKeepTail": true,
  "continueAfterThresholdCompact": true,
  "debug": false,
  "skipForProviders": [],
  "skipCustomTypes": [],
  "trackCommands": []
}
```

## Managing packages

```bash
pi install npm:@example/pi-tools@1.0.0   # add a package (writes to settings.json)
pi list                                  # show installed packages
pi remove npm:@example/pi-tools          # remove one
pi update --extensions                   # reconcile installations
```

Personal installs write to `~/.pi/agent/settings.json`; add `--local` to write to
the project `.pi/settings.json` instead (loaded only after project trust).

## Skills

The `nixos-config` skill lives in this repo (`home/pi/skills/nixos-config/`) and is
symlinked into `~/.pi/agent/skills/` by home-manager (`home/pi.nix`), so it clones
onto new machines.

## Not committed (machine-local / secrets)

- `~/.pi/agent/auth.json` — API keys (secrets).
- `~/.pi/agent/models-store.json` — model store.
- `~/.pi/agent/sessions/` — session/chat history.
- `~/.pi/agent/npm/` — installed package files.

Keep these out of git; they are recreated by `pi install`, `pi login`, and normal use.
