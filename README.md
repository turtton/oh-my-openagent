# @turtton/oh-my-openagent

A soft fork of [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) optimized for GitHub Copilot users.

## What is this?

This is a patch-based distribution of oh-my-openagent. Instead of maintaining a full fork, we apply targeted patches to upstream source code and publish as `@turtton/oh-my-openagent` on npm. The upstream project is automatically tracked, and new releases are published with patches applied via CI.

## Installation

```bash
npm install -g @turtton/oh-my-openagent
```

## Patches Applied

- **001-background-output-block-true**: Changes `background_output` tool behavior guidance across 6 source files. Instead of recommending agents "end their response and wait for system notifications" when background tasks complete, this patch recommends using `block=true` to actively wait for results. This produces more reliable agent behavior with GitHub Copilot, which may not handle system notification-based resumption as well as other clients.
    - Files affected: `constants.ts`, `background-executor.ts`, `background-agent-executor.ts`, `create-background-task.ts`, `dynamic-agent-prompt-builder.ts`, `sisyphus.ts`
- **002-disable-todo-continuation-enforcer**: Disables the `todo-continuation-enforcer` hook by default. This hook automatically continues work based on todo items, which can be overly aggressive with Copilot. The hook is disabled by adding it to the default `disabled_hooks` list in the config initialization.

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

Same as upstream (SUL-1.0). Patches in this repository are provided for compatibility purposes.

## Links

- Upstream: https://github.com/code-yeongyu/oh-my-openagent
- npm: https://www.npmjs.com/package/@turtton/oh-my-openagent
