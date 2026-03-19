# @turtton/oh-my-openagent

[oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)のGitHub Copilotユーザー向けソフトフォーク。Premium Requestの消費をより予測可能にするパッチを適用しています。

## 概要
oh-my-openagentのパッチベース配布です。完全なフォークを維持する代わりに、upstreamのソースコードに対象を絞ったパッチを適用し、`@turtton/oh-my-openagent`としてnpmに公開しています。すべてのパッチはGitHub Copilotの利用モデルで発生する不要なPremium Request消費の削減に焦点を当てています。upstreamの新しいリリースは自動的に追跡され、パッチを適用した状態でCIから公開されます。

## インストール
OpenCodeの設定ファイル（グローバルは `~/.config/opencode/opencode.json`、プロジェクト限定は `opencode.json`）の `"plugin"` 配列にパッケージ名を追加します:

```json
{
  "plugin": [
    "@turtton/oh-my-openagent"
  ]
}
```

次回OpenCode起動時に自動的にインストール・ロードされます。

## 適用パッチ
各パッチの説明:
- **001-background-output-block-true**: `background_output`ツールのガイダンスを6つのソースファイルで変更します。upstreamのデフォルトではバックグラウンドタスク完了時に「レスポンスを終了してシステム通知を待つ」ことを推奨しており、各通知が新しいエージェントターンをトリガーしてPremium Requestを消費します。このパッチは代わりに`block=true`で現在のターン内で結果を待つことを推奨し、通知トリガーによる余分なPremium Request消費を回避します。
    - 対象ファイル: `constants.ts`, `background-executor.ts`, `background-agent-executor.ts`, `create-background-task.ts`, `dynamic-agent-prompt-builder.ts`, `sisyphus.ts`
- **002-disable-todo-continuation-enforcer**: `todo-continuation-enforcer`フックをデフォルトで無効化します。このフックはTODOリストに基づいて自動的に作業を継続し、意図しない追加のエージェントターン（とPremium Request）をトリガーする場合があります。設定初期化時のデフォルト`disabled_hooks`リストに追加することで無効化しています。
- **003-noreply-true**: バックグラウンドタスク完了通知を常に`noReply: true`に強制します。このパッチがない場合、全バックグラウンドタスク完了時に`noReply: false`の通知が新しいエージェントターンをトリガーし、`block=true`（パッチ001）で既に結果を受け取っていてもPremium Requestが消費されます。このパッチは通知トリガーの応答を抑制し、Premium Requestの二重消費を排除します。
    - 対象ファイル: `manager.ts`（2箇所）
    - **⚠️ 注意**: このパッチ適用後、`block=true`を使用しないエージェントはバックグラウンドタスク完了時に自動再開しなくなります。パッチ001がエージェントプロンプトで`block=true`を推奨することで緩和していますが、一部のエッジケース（例: 長時間タスクでの`block=true`タイムアウト）では手動介入が必要になる場合があります。

## 無効化されたフックの再有効化
`todo-continuation-enforcer`フックを再有効化するには、プロジェクトルートに`.opencode.json`を作成します:
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
