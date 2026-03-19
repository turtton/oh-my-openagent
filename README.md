# @turtton/oh-my-openagent

A soft fork of [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) with patches to make premium request consumption more predictable for GitHub Copilot users.

## What is this?

This is a patch-based distribution of oh-my-openagent. Instead of maintaining a full fork, we apply targeted patches to upstream source code and publish as `@turtton/oh-my-openagent` on npm. All patches focus on reducing unnecessary premium request consumption that occurs with GitHub Copilot's usage model. The upstream project is automatically tracked, and new releases are published with patches applied via CI.

## Installation

```bash
npm install -g @turtton/oh-my-openagent
```

## Patches Applied

- **001-background-output-block-true**: Changes `background_output` tool guidance across 6 source files. The upstream default recommends agents "end their response and wait for system notifications" when background tasks complete — each such notification triggers a new agent turn, consuming a premium request. This patch instead recommends `block=true` to wait for results within the current turn, avoiding extra premium request consumption from notification-triggered responses.
    - Files affected: `constants.ts`, `background-executor.ts`, `background-agent-executor.ts`, `create-background-task.ts`, `dynamic-agent-prompt-builder.ts`, `sisyphus.ts`
- **002-disable-todo-continuation-enforcer**: Disables the `todo-continuation-enforcer` hook by default. This hook automatically continues work based on todo items, triggering additional agent turns (and premium requests) that may not be intended. Disabled by adding it to the default `disabled_hooks` list in the config initialization.
- **003-noreply-true**: Forces all background task completion notifications to use `noReply: true`. Without this patch, when all background tasks complete, a notification with `noReply: false` triggers a new agent turn — consuming a premium request even when the agent already received results via `block=true` (patch 001). This patch suppresses notification-triggered responses to eliminate duplicate premium request consumption.
    - Files affected: `manager.ts` (2 locations)
    - **⚠️ Note**: With this patch, agents that do not use `block=true` will not automatically resume when background tasks complete. Patch 001 mitigates this by recommending `block=true` in agent prompts, but some edge cases (e.g., `block=true` timeout on long-running tasks) may require manual intervention.

## Re-enabling Disabled Hooks

To re-enable the `todo-continuation-enforcer` hook, add an `.opencode.json` config file in your project root:

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
