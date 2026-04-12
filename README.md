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

- **001-block-true-waiting**: Encourages agents to use `block=true` when collecting background task results, reducing unnecessary premium request consumption. The upstream default recommends agents "end their response and wait for system notifications" when background tasks complete — each notification triggers a new agent turn, consuming a premium request. This patch instead recommends `block=true` to wait within the current turn, and makes the runtime support it properly: when a task is collected via `block=true`, the completion notification (`promptAsync` call) is skipped entirely — no text is injected into the parent session, and the task is excluded from the "all complete" summary shown to siblings. This removes the `block=true` timeout limit (now waits indefinitely, with the `timeout` parameter deprecated and ignored), and updates all guidance text across agent prompts and tool descriptions. For tasks not being actively polled, the original notification-driven logic is preserved.
    - Files affected: `src/tools/background-task/constants.ts`, `src/tools/call-omo-agent/background-executor.ts`, `src/tools/call-omo-agent/background-agent-executor.ts`, `src/tools/background-task/create-background-task.ts`, `src/agents/dynamic-agent-prompt-builder.ts`, `src/agents/sisyphus.ts`, `src/tools/background-task/clients.ts`, `src/tools/background-task/types.ts`, `src/features/background-agent/manager.ts`, `src/tools/background-task/create-background-output.ts`, `src/tools/delegate-task/background-task.ts`, `src/tools/delegate-task/background-continuation.ts`, `src/features/background-agent/background-task-notification-template.ts`
- **002-disable-todo-continuation-enforcer**: Disables the `todo-continuation-enforcer` hook by default. This hook automatically continues work based on todo items, triggering additional agent turns (and premium requests) that may not be intended. Disabled by adding it to the default `disabled_hooks` list in the config initialization.

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
