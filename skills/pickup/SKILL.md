---
name: pickup
description: |
  明示の /pickup のときだけ使う。GitHub Issues からタスクを1件選び、最小実装して PR を出す。
  「/pickup」「issue から PR」「次の issue を拾って」と明示されたとき。
---

# pickup

GitHub Issues からタスクを **ちょうど1件** 選び、最小実装して PR を出す。

明示入力 `/pickup` のときだけ使う。

## 手順

1. 対象リポジトリを決める
   - **作業中のプロジェクト（カレントの git repo）で決める**
   - カレントが git repo でなければ止めて報告する（勝手に別 repo を探さない）
   - ユーザーがこのコマンドと一緒に `owner/repo` や URL を明示したときだけ、それを使う
2. open な issue を列挙する
   ```bash
   gh issue list --state open --limit 30
   ```
   必要なら label / assignee で絞る（ユーザー指定があれば従う）
3. 候補を短く一覧し、**1件だけ**選ぶ
   - 実装可能なもの優先（discussion・設計相談だけ・情報不足は除外）
   - 巨大すぎる / 仕様が割れているものは選ばず、理由を書いて止めるか別候補にする
   - 迷ったら実装に入る前にユーザーに確認する（勝手に巨大 issue を取らない）
4. 作業ブランチを切る（例: `pickup/#N-short-slug`）
5. その issue の意図に必要な **最小限** だけ実装する
   - drive-by リファクタ・無関係な整形・依存更新はしない
   - 既存テストがあれば走らせる。無ければ無理に増やさない（issue が求めていればその範囲で）
6. ひとまとまり終わったら `git` スキルの `/git commit` 手順でコミットする
7. push して PR を作る
   ```bash
   git push -u origin HEAD
   gh pr create --title "<要約>" --body "$(cat <<'EOF'
   ## Summary
   - <やったこと>

   ## Notes
   - <やらなかったこと / 残り>

   Fixes #<N>
   EOF
   )"
   ```
8. PR URL と、選んだ issue / 変更の要約を報告する

## やること / やらないこと

| やること | やらないこと |
|---|---|
| open issue を見て1件選ぶ | 複数 issue を同時に進める |
| 最小実装して PR を出す | カレント外の repo を勝手に触る |
| 本文に `Fixes #N` を付ける | merge / approve / レビュアー代行 |
| 迷ったら選定時点で確認する | 選定前にコードを書き始める |
| commit は `/git commit` に従う | 無関係なリファクタや依存更新 |
| | レビュー指摘対応（それは `vs-codereview`） |

## オプション

- `/pickup #N` — 選定を飛ばし、指定 issue で 4 以降だけ行う
- `/pickup auto` — 確認なしで1件選んで進める（それでも作業中 repo・最小実装・1件制限は守る）
