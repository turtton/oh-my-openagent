# @turtton/oh-my-openagent

[oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)のGitHub Copilotユーザー向けソフトフォーク。Premium Requestの消費をより予測可能にするパッチを適用しています。

## 概要
oh-my-openagentのパッチベース配布です。完全なフォークを維持する代わりに、upstreamのソースコードに対象を絞ったパッチを適用し、`@turtton/oh-my-openagent`としてnpmに公開しています。すべてのパッチはGitHub Copilotの利用モデルで発生する不要なPremium Request消費の削減に焦点を当てています。upstreamの新しいリリースは自動的に追跡され、パッチを適用した状態でCIから公開されます。

## インストール
OpenCodeの設定ファイルの `"plugin"` 配列にパッケージ名を追加します。プロジェクトルートの `opencode.json` は全プラットフォームで使用できます:

```json
{
  "plugin": [
    "@turtton/oh-my-openagent"
  ]
}
```

- **プロジェクト限定（全OS対応）**: プロジェクトルートの `opencode.json`
- **グローバル（macOS/Linux/WSL）**: `~/.config/opencode/opencode.json`

既存の `opencode.json` がある場合は、ファイルを置き換えず既存の `plugin` 配列に `"@turtton/oh-my-openagent"` を追記してください。

次回OpenCode起動時に自動的にインストール・ロードされます。

## 適用パッチ
各パッチの説明:
- **001-block-true-waiting**: バックグラウンドタスクの結果取得時に`block=true`の使用を推奨し、不要なPremium Request消費を削減します。upstreamのデフォルトではバックグラウンドタスク完了時に「レスポンスを終了してシステム通知を待つ」ことを推奨しており、各通知が新しいエージェントターンをトリガーしてPremium Requestを消費します。このパッチは代わりに`block=true`で現在のターン内で結果を待つことを推奨し、ランタイム側もそれを適切にサポートするよう変更します: `block=true`で収集されたタスクについては完了通知（`promptAsync`呼び出し）を完全にスキップし、親セッションへのテキスト注入を行わず、そのタスクを兄弟タスクへの「全完了」サマリーからも除外します。`block=true`のタイムアウト制限を撤廃（無期限待機、`timeout`パラメータはdeprecatedとなり無視されます）し、エージェントプロンプトとツール説明のガイダンステキストを全面更新します。ポーリングされていないタスクについては、元の通知駆動ロジックが維持されます。
    - 対象ファイル: `src/tools/background-task/constants.ts`, `src/tools/call-omo-agent/background-executor.ts`, `src/tools/call-omo-agent/background-agent-executor.ts`, `src/tools/background-task/create-background-task.ts`, `src/agents/dynamic-agent-prompt-builder.ts`, `src/agents/sisyphus.ts`, `src/tools/background-task/clients.ts`, `src/tools/background-task/types.ts`, `src/features/background-agent/manager.ts`, `src/tools/background-task/create-background-output.ts`, `src/tools/delegate-task/background-task.ts`, `src/tools/delegate-task/background-continuation.ts`, `src/features/background-agent/background-task-notification-template.ts`
- **002-disable-todo-continuation-enforcer**: `todo-continuation-enforcer`フックをデフォルトで無効化します。このフックはTODOリストに基づいて自動的に作業を継続し、意図しない追加のエージェントターン（とPremium Request）をトリガーする場合があります。設定初期化時のデフォルト`disabled_hooks`リストに追加することで無効化しています。

## 無効化されたフックの再有効化
`todo-continuation-enforcer`フックを再有効化するには、プロジェクトルートに`opencode.json`を作成します:
```json
{
  "disabled_hooks": []
}
```
`disabled_hooks`を空の配列に設定することで、パッチで変更されたデフォルト（`["todo-continuation-enforcer"]`）を上書きし、全フックが有効になります。

## バージョニング
`<upstream-ver>-copilot.<N>`形式を使用します（例: `3.12.3-copilot.1`）。upstreamバージョンはソースリリースを追跡し、copilotリビジョン番号はパッチのみの変更で増加します。

## 仕組み
- 日次のCI cronジョブがupstreamの新リリースを検出
- 新バージョン検出時（または手動トリガー時）、CIパイプラインが:
  1. 対象タグでupstreamソースをクローン
  2. `patches/`ディレクトリのパッチを順番に適用
  3. `bun build`でビルド
  4. provenanceつきでnpmに公開

## ライセンス
upstreamと同じ（SUL-1.0）。

## リンク
- Upstream: https://github.com/code-yeongyu/oh-my-openagent
- npm: https://www.npmjs.com/package/@turtton/oh-my-openagent
