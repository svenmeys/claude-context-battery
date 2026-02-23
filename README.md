# claude-context-battery

A visual context window battery for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). See exactly how much context you have left — before auto-compact surprises you.

```
⎇ main | Opus 4.6 [██████░░░░] 62% | $0.36 | 45m
                   ^^^^^^^^^^^^^^^^
                   this part
```

<!-- TODO: Replace with actual screenshot -->
<!-- ![Screenshot](screenshot.png) -->

## Why

Claude Code auto-compacts your conversation at ~80% context usage. When that happens mid-task, you lose conversation history and the agent may lose track of what it was doing.

The battery gives you a heads-up. Green means plenty of room. Orange means start wrapping up. Red means compact is imminent.

The bar is **normalized to 80%** of your context window — when it shows 100%, you still have ~20% buffer. This gives you a realistic "time to `/clear`" indicator instead of raw token math.

| Color | Range | Meaning |
|-------|-------|---------|
| Green | <50% | Plenty of room |
| Orange | 50-80% | Start wrapping up |
| Red | >80% | Compact is imminent |

## Install

This is a [ccstatusline](https://github.com/sirmalloc/ccstatusline) custom command widget. You need ccstatusline installed first.

### 1. Install ccstatusline (if you haven't)

```bash
npm install -g ccstatusline
```

### 2. Download the battery script

```bash
# Create widgets directory
mkdir -p ~/.claude/widgets

# Download
curl -o ~/.claude/widgets/context-battery.sh \
  https://raw.githubusercontent.com/svenmeys/claude-context-battery/main/context-battery.sh

# Make executable
chmod +x ~/.claude/widgets/context-battery.sh
```

### 3. Add to ccstatusline

Run `ccstatusline` to open the configuration TUI, then:

1. Select your status line
2. Add a **Custom Command** widget
3. Set command path to `~/.claude/widgets/context-battery.sh`
4. Set timeout to `500` (ms)
5. Enable **Preserve Colors** (important — the battery uses ANSI colors)
6. Save and exit

That's it. The battery appears in your Claude Code status line.

## How it works

Claude Code pipes session JSON to ccstatusline on every prompt. ccstatusline passes that JSON to custom command widgets via stdin. The battery script:

1. Reads `.context_window.context_window_size` and `.context_window.current_usage` from the JSON
2. Sums all input tokens (direct + cache creation + cache read)
3. Calculates usage as a percentage, normalized to 80% of the window
4. Renders a 10-segment bar with ANSI color coding

### Test it locally

```bash
cat example-payload.json | bash context-battery.sh
# Output: [██████████] 88% (in orange)
```

## Dependencies

- **bash** — any modern version
- **jq** — JSON parser ([install](https://jqlang.github.io/jq/download/))

If `jq` is missing, the script gracefully outputs an empty bar (`░░░░░░░░░░`) instead of crashing.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- [ccstatusline](https://github.com/sirmalloc/ccstatusline) — the status line framework this plugs into

## License

[MIT](LICENSE)

## Credits

Built for the [ccstatusline](https://github.com/sirmalloc/ccstatusline) ecosystem by [@sirmalloc](https://github.com/sirmalloc).
