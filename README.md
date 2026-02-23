# claude-context-battery

A context window battery for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Know when you're about to get auto-compacted — before it ruins your flow.

```
⎇ main | Opus 4.6 [██████░░░░] 62% | $0.36 | 45m
```

<!-- TODO: Add screenshot showing the battery in action -->
<!-- ![Screenshot](screenshot.png) -->

## Why this exists

Claude Code silently auto-compacts your conversation at ~80% context usage. When it hits mid-task, the agent loses history and sometimes loses the plot entirely. You don't get a warning.

This gives you one. A 10-segment battery bar, color-coded, right in your status line:

| Color | Range | What to do |
|-------|-------|------------|
| Green | <50% | Keep going |
| Orange | 50-80% | Wrap up or start a new session |
| Red | >80% | Compact is about to fire |

The bar is **normalized to 80%** — when it shows 100%, you've still got ~20% buffer. It shows "time to `/clear`", not raw token math.

## Install

Requires [ccstatusline](https://github.com/sirmalloc/ccstatusline) — the customizable status line framework for Claude Code.

### 1. Install ccstatusline

```bash
npm install -g ccstatusline
```

### 2. Download the script

```bash
mkdir -p ~/.claude/widgets

curl -o ~/.claude/widgets/context-battery.sh \
  https://raw.githubusercontent.com/svenmeys/claude-context-battery/main/context-battery.sh

chmod +x ~/.claude/widgets/context-battery.sh
```

### 3. Configure

Run `ccstatusline` to open the TUI, then:

1. Select your status line
2. Add a **Custom Command** widget
3. Set command path: `~/.claude/widgets/context-battery.sh`
4. Set timeout: `500`
5. Enable **Preserve Colors** (the battery uses ANSI colors)
6. Save

Done. Battery shows up on your next Claude Code prompt.

## How it works

Claude Code pipes session JSON to ccstatusline on every prompt. ccstatusline forwards that JSON to custom command widgets via stdin. The battery script:

1. Reads `context_window.context_window_size` and `context_window.current_usage`
2. Sums all input tokens (direct + cache creation + cache read)
3. Normalizes to 80% of the window size
4. Renders a 10-segment bar with ANSI color

### Test locally

```bash
cat example-payload.json | bash context-battery.sh
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- [ccstatusline](https://github.com/sirmalloc/ccstatusline)
- [jq](https://jqlang.github.io/jq/download/) (degrades gracefully if missing — shows an empty bar instead of crashing)

## License

[MIT](LICENSE)

## Author

[Sven Meys](https://github.com/svenmeys) — building developer tools for AI-native workflows.

Built for the [ccstatusline](https://github.com/sirmalloc/ccstatusline) ecosystem by [@sirmalloc](https://github.com/sirmalloc).
