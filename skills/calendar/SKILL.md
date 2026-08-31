---
name: calendar
description: |
  ~/Dropbox/cal/ の予定を追記・照会する。
  「予定」「カレンダー」「スケジュール」「予約」「誕生日」
  「予定入れて」「予定見て」「今週の予定」または /calendar と言われたら必ず使う。
  日付の入った予定・予約の追加・確認は private ではなくこちら。
---

# calendar

`~/Dropbox/cal/` の独自カレンダー。パスは `calendar` ではなく **`cal`**。

日付つき予定はここ。事実の最新状態は `private`（Wikipedia 形式）。混ぜない。

## 絶対ルール

- **追記のみ。削除禁止。** 既存行の削除・置換・並べ替え・全ファイル書き換えは禁止
- キャンセル・時刻変更も旧行は残す。正しい内容の行を新たに追記する
- 確認せず即追記する
- 区切りは **TAB**。スペース区切りはパース失敗する
- 追記は `>>`。Read して Write し直さない（事故で消える）

```bash
# 末尾改行が無ければ足してから追記
f=~/Dropbox/cal/private.calendar
[[ -s "$f" && $(tail -c 1 "$f" | wc -l) -eq 1 ]] || printf '\n' >> "$f"
printf '%s\t%s\n' '2026/09/13' '1330- 資格試験, 中央区民センター 3F' >> "$f"
```

## フォーマット

```
YYYY/MM/DD<TAB>内容
MM/DD<TAB>内容
```

- 通常: `YYYY/MM/DD`（ゼロ埋め）
- 毎年: `MM/DD`（誕生日。`Date.parse` が今年の日付にする）
- 空行と `//` で始まる行は無視
- 1イベント1行。同じ日の別予定は別行
- 時刻・場所・URL は内容側。時刻はコロン無し24h（`1530-1600` `1500-`）

内容の慣例:

| 接頭辞・語 | 意味 |
|---|---|
| `DONE` | 処理済み（`calendar` CLI が灰色/取り消し線） |
| `TODO` | 未処理リマインダ |
| `canceled` / `キャンセル` | 中止 |
| `暫定` | 未確定 |

```
# 良い
2026/09/11	星見台プラネタリウム 1530-1600
2026/09/13	1330- 資格試験, 中央区民センター 3F
03/17	alice

# 悪い
2026-09-11  星見台プラネタリウム     ← ハイフン日付、スペース区切り
2026/9/11	資格試験 13:30          ← ゼロ埋め無し、コロン時刻（新規は避ける）
```

## ファイル

入口は `index.calendar`。`#include <name.calendar>` で結合する。

| ファイル | 用途 |
|---|---|
| `private.calendar` | 私用（病院・美容院・旅行・試験）。**迷ったらここ** |
| `birthday.calendar` | 誕生日（年なし `MM/DD`） |
| `bike.calendar` | バイク |
| `anime.calendar` | アニメ・VTuber・同人イベント |
| `kakin.calendar` | 課金・解約期限 |
| `procon.calendar` | 競プロ・CTF |
| `movie.calendar` | 映画 |
| `study.calendar` | 勉強 |
| `shukujitsu.calendar` | 祝日 |
| `rec.calendar` | 録画 |
| `train.calendar` | 鉄道 |
| `dwango.calendar` / `lab.calendar` / `jasso_2015.calendar` | レガシー。新規は使わない |

index に無いファイルは CLI に出ない。勝手に include しない。該当しそうでも `private.calendar` へ。

新規カテゴリが必要なら `.calendar` を作り、`index.calendar` の末尾に `#include <name.calendar>` を追記してからイベントを書く。include 行も削除・並べ替えしない。

## 動作

### 記録（平叙・「入れて」）

1. 日付と内容を確定する。年が無い通常予定は今年、必要ならユーザーに年を確認
2. 上表からファイルを選ぶ。迷ったら `private.calendar`
3. 末尾に1行追記
4. ファイル名と追記した行を報告

### 照会（疑問・「見て」）

```bash
calendar -A 30 -f ~/Dropbox/cal/index.calendar
calendar -B 7 -A 14 -f ~/Dropbox/cal/index.calendar
```

- `-A` 前方日数、`-B` 後方日数。`-f` 必須
- 検索は `rg 'キーワード' ~/Dropbox/cal/`
- 表示は CLI が日付順。ファイル自体は挿入順のまま（並べ替えない）

### キャンセル・変更

旧行は触らない。新行を追記する。

```
2026/09/11	星見台プラネタリウム キャンセル
2026/09/11	星見台プラネタリウム 1630-1700
```

## 禁止

- 既存行の削除・書き換え・ソート
- `~/Dropbox/calendar` への書き込み（そのパスは無い）
- `private` スキルの Wikipedia マージをここへ適用すること
- 依頼されていない予定の捏造
- index 未登録ファイルへの追記（出ない）
