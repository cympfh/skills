---
name: git
version: 0.1.2
description: Git コマンドを使用して、リポジトリの管理やコードのバージョン管理を行うスキルです
---

# Git スキル

## /git commit

1. git diff を実行し、変更点を確認する
2. 内容を見て1つの git commit にまとめる

## /git commits

1. git diff を実行し 変更点を確認する
2. 内容を見て論理的な粒度に分割し git commit する
    - ただし、一つのファイルに複数の変更がある場合は、諦めて一つの git commit にまとめることも検討する

## /git auto

このセッション内での「自動コミットモード」を切り替えるコマンド。

### /git auto commit

実行以降、`/git auto off` が実行されるまで **auto-commit mode** になる。

このモードでは、何らかの変更作業（実装・修正・リファクタ等）がひとまとまり完了するたびに、次を自動で行う。

1. 作業内容が正しいことを確認する
    - lint check を実行する
    - format check を実行する
    - test を実行する
    - テストが存在しない場合は、サブエージェントにレビューを依頼する
2. すべての確認が通ったら `/git commit` を実行する（上記の手順に従う）
3. 確認に失敗した場合はコミットせず、問題を修正してから再度確認する

### /git auto commit-push

`/git auto commit` と同様に **auto-commit-push mode** になる。
上記の手順でコミットした後、続けて `git push` も行う。

### /git auto off

auto-commit mode / auto-commit-push mode を解除し、通常の動作に戻す。

### モード中の注意

- auto-commit mode / auto-commit-push mode 中は、commit（および push）を実行した直後、応答の最後に
  `**auto-commit mode**` または `**auto-commit-push mode**` と一言添える。
  モードに入っていることを自分自身が忘れないようにするため。
- `/git auto off` を実行したときも、応答の最後に `**auto-commit off**` と一言添える。
