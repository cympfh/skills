---
name: make
description: |
  GNU make 相当を LLM エージェントが実行するエンジン。
  Makefile.agent を読み、古いものだけレシピ（自然言語の手順）を実行する。
  `/make` `/make <target ...>` `/make -n [target ...]` `/make list` `/make init` と言ったら必ず使う。
  Makefile.agent がある状態で「再生成して」「成果物を依存付きで作れ」も必ず使う。
---

# make スキル

`Makefile.agent` を解釈するエンジン。GNU make を呼び出さない。レシピは shell ではなく LLM への手順。
作業ディレクトリは git ルート（`git rev-parse --show-toplevel`）。git でなければ cwd。パスはすべてそこからの相対。

---

## Makefile.agent の構文

```
# コメント

docs/api.md: src/lib.py src/cli.py
    src/lib.py と src/cli.py の公開 API を列挙した Markdown を docs/api.md に書け
    内部関数は入れるな

README.md: docs/api.md
    docs/api.md を反映して README.md の API 節だけ更新せよ

.PHONY: test
test: src/lib.py src/cli.py
    テストを実行し、失敗があれば直せ

# vim: set ft=make:
```

- 擬似的な GNU Makefile 構文
- 依存無しでも可
- レシピのインデントはタブでもスペースでも可
- `.PHONY` は何度出てもよい
- 同じターゲットが二度出たらエラー
- ファイル名は `Makefile.agent`

---

## 判定

mtime は `stat -c '%Y'`（UNIX epoch 秒）。ディレクトリ依存は dir 自体の mtime。中のファイルは追わない。

**PHONY**: 同名ファイルがあっても無視。常にレシピを実行する。PHONY 依存を持つターゲットも常に outdated。

**ファイルターゲット** outdated のとき:

- ターゲットが存在しない
- いずれかのファイル依存の mtime がターゲットより新しい
- いずれかの依存が PHONY
- この実行中に、いずれかの依存のレシピを走らせた

それ以外は skip。依存なしでファイルが存在する → skip。

ファイルでもターゲットでもない依存 → エラー（No rule to make target）。循環 → エラー。

---

## 実行（エンジン）

`/make` と `/make <target ...>` で使う。引数が無ければ、名前が `.` で始まらない最初のターゲットが対象。

1. `Makefile.agent` を読む。ファイルが無ければ `/make init` を案内して止まる。勝手に init するな
2. 対象ターゲットを解決する。無ければエラー。複数なら左から順（GNU make と同じ）
3. 対象を順に `build` する

```
func build(target):
  済なら return
  構築中なら循環エラー
  構築中にする
  依存を先に build（ターゲットなら再帰。ファイル/dir なら存在確認）
  outdated でなければ skip して済にする
  レシピを実行する
  失敗したら: ファイルターゲットならそのパスを削除し、即停止
  ファイルターゲットで、成功後もパスが無ければ失敗（削除するものは無い。停止）
  済にする
```

4. 直列。並列にするな
5. レシピは HOW。書いてある手順を実行する。shell が必要なら自分で叩く。`make -f Makefile.agent` は呼ぶな
6. ファイルターゲットのレシピは、中身が同じでもそのパスを必ず書く

---

## /make -n [target ...]

実行するな。判定して計画を出せ。対象の解決は実行と同じ（複数なら左から順）。run するターゲットは、やろうとしていることを書け。書き方は実行報告の `したこと` と同じ（自然言語。Bash ならコマンドそのもの）。

```
## /make -n <target ...>

計画:
- skip  <target>  (mtime)
- run   <target>

すること:
- <target>: <自然言語。Bash 操作ならコマンドそのもの>
```

run が無ければ `すること` は出さず、`すべて up-to-date`。

```
## /make -n README.md

計画:
- skip  docs/api.md  (mtime)
- run   README.md

すること:
- README.md: docs/api.md に合わせて README.md の API 節を更新する
```

---

## /make list

実行するな。宣言を出せ。

```
## Makefile.agent

* <target>            default
    <target>: <deps>
  <target>            PHONY
    <target>: <deps>
```

先頭の `*` はデフォルトターゲット。

---

## /make init

1. `Makefile.agent` があれば上書きせず、ある旨を伝えて終わる
2. 無ければ作る。リポを見て、繰り返し作る成果物と PHONY を規則として書く。一回限りの作業は書くな
3. ファイル成果物のターゲット名は出力パス
4. 書いた内容を報告する。続けて実行するな

---

## 実行結果の報告

`/make` と `/make <target ...>` のあと、必ずこの形で出せ。判定ログだけ出すな。見出しは指定したターゲットを空白区切りで書く。

```
## /make <target ...>

実行:
- skip  <target>  (mtime)
- run   <target>
- fail  <target>  <理由>

したこと:
- <target>: <自然言語。Bash 操作ならコマンドそのもの>

生成:
- <path>  新規
- <path>  更新

停止: <target>
```

- **実行**: 訪れたターゲットを順に。skip / run / fail
- **したこと**: run したターゲットだけ。skip は書くな。自然言語で何をしたか。Bash を叩いたならコマンドをそのまま書け。レシピの複写ではない
- **生成**: この実行で新規作成または更新したファイル。skip したパスは書くな。PHONY の副作用ファイルも書け。ファイルが無ければ `生成: なし`
- 全部 skip なら `したこと` `生成` は出さず、`すべて up-to-date` で終わる
- 失敗が無ければ `停止` 行は出すな

例:

```
## /make README.md

実行:
- skip  docs/api.md  (mtime)
- run   README.md

したこと:
- README.md: docs/api.md の内容に合わせて API 節を書き直した

生成:
- README.md  更新
```

```
## /make test

実行:
- run   test

したこと:
- test: pytest -q

生成: なし
```

---

## まとめ

- `/make` : デフォルトターゲットとその依存を実行
- `/make <target ...>` : 指定ターゲットを左から順に、各々の依存を含めて実行
- `/make -n [target ...]` : 計画と、run するなら何をするか
- `/make list` : ターゲット一覧
- `/make init` : `Makefile.agent` を新規作成（既存は触らない）
- `clean` はコマンドではない。PHONY ターゲットとして書け
