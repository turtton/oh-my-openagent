# @turtton/oh-my-openagent

[oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)のGitHub Copilotユーザー向けソフトフォーク。

## 概要
oh-my-openagentのパッチベース配布です。完全なフォークを維持する代わりに、upstreamのソースコードに対象を絞ったパッチを適用し、`@turtton/oh-my-openagent`としてnpmに公開しています。upstreamの新しいリリースは自動的に追跡され、パッチを適用した状態でCIから公開されます。

## インストール
```bash
npm install -g @turtton/oh-my-openagent
```

## 適用パッチ
各パッチの説明:
- **001-background-output-block-true**: `background_output`ツールの動作ガイダンスを6つのソースファイルで変更します。バックグラウンドタスク完了時に「レスポンスを終了してシステム通知を待つ」ことを推奨する代わりに、`block=true`を使って積極的に結果を待つことを推奨するよう変更しています。GitHub Copilotではシステム通知ベースの再開がうまく機能しない場合があるため、この変更によりエージェントの動作がより安定します。
    - 対象ファイル: `constants.ts`, `background-executor.ts`, `background-agent-executor.ts`, `create-background-task.ts`, `dynamic-agent-prompt-builder.ts`, `sisyphus.ts`
- **002-disable-todo-continuation-enforcer**: `todo-continuation-enforcer`フックをデフォルトで無効化します。このフックはTODOリストに基づいて自動的に作業を継続しますが、Copilotでは過度に積極的に動作する場合があります。設定初期化時のデフォルト`disabled_hooks`リストに追加することで無効化しています。

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
upstreamと同じ（SUL-1.0）。このリポジトリのパッチは互換性のために提供されています。

## リンク
- Upstream: https://github.com/code-yeongyu/oh-my-openagent
- npm: https://www.npmjs.com/package/@turtton/oh-my-openagent
