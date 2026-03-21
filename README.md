# @turtton/oh-my-openagent

[日本語](./README.ja.md)

A soft fork of [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) with patches to make premium request consumption more predictable for GitHub Copilot users.

## What is this?

This is a patch-based distribution of oh-my-openagent. Instead of maintaining a full fork, we apply targeted patches to upstream source code and publish as `@turtton/oh-my-openagent` on npm. All patches focus on reducing unnecessary premium request consumption that occurs with GitHub Copilot's usage model. The upstream project is automatically tracked, and new releases are published with patches applied via CI.

## Installation

Add the package to the `plugin` array in your OpenCode config file. The project-local `opencode.json` works on all platforms; the global path shown below is for macOS/Linux:

```json
{
  "plugin": [
    "@turtton/oh-my-openagent"
  ]
}
```

- **Project-local**: `opencode.json` in your project root (works on all platforms)
- **Global (macOS/Linux/WSL)**: `~/.config/opencode/opencode.json`

If you already have an `opencode.json`, add `"@turtton/oh-my-openagent"` to the existing `plugin` array rather than replacing the file.

OpenCode will automatically install and load the plugin on next startup.

## Patches Applied

- **001-background-output-block-true**: Changes `background_output` tool guidance across 6 source files. The upstream default recommends agents "end their response and wait for system notifications" when background tasks complete — each such notification triggers a new agent turn, consuming a premium request. This patch instead recommends `block=true` to wait for results within the current turn, avoiding extra premium request consumption from notification-triggered responses.
    - Files affected: `constants.ts`, `background-executor.ts`, `background-agent-executor.ts`, `create-background-task.ts`, `dynamic-agent-prompt-builder.ts`, `sisyphus.ts`
- **002-disable-todo-continuation-enforcer**: Disables the `todo-continuation-enforcer` hook by default. This hook automatically continues work based on todo items, triggering additional agent turns (and premium requests) that may not be intended. Disabled by adding it to the default `disabled_hooks` list in the config initialization.
- **003-noreply-true**: Intelligently suppresses background task completion notifications when the agent is already waiting via `block=true`. Instead of the previous blanket `noReply: true` approach, this patch tracks which tasks are being actively polled by `background_output(block=true)`. For those tasks, notifications use `noReply: true` to avoid triggering redundant agent turns. For tasks not being actively polled, the original `noReply: !allComplete` logic is preserved, allowing proper notification-driven resumption. Also removes the `block=true` timeout limit (now waits indefinitely) and registers/unregisters blocking state via `BackgroundManager`.
    - Files affected: `clients.ts`, `types.ts`, `manager.ts`, `create-background-output.ts`

## Re-enabling Disabled Hooks

To re-enable the `todo-continuation-enforcer` hook, add an `opencode.json` config file in your project root:

```json
{
  "disabled_hooks": []
}
```

Setting `disabled_hooks` to an empty array overrides the patched default (`["todo-continuation-enforcer"]`) and re-enables all hooks.

## Versioning

Uses `<upstream-ver>-copilot.<N>` scheme (e.g., `3.12.3-copilot.1`). The upstream version tracks the source release, and the copilot revision number increments for patch-only changes.

## How It Works

- A daily CI cron job checks for new upstream releases
- When a new version is detected (or manually triggered), the CI pipeline:
  1. Clones the upstream source at the target tag
  2. Applies all patches from `patches/` directory
  3. Builds with `bun build`
  4. Publishes to npm with provenance

## License

Same as upstream (SUL-1.0).

## Links

- Upstream: https://github.com/code-yeongyu/oh-my-openagent
- npm: https://www.npmjs.com/package/@turtton/oh-my-openagent
