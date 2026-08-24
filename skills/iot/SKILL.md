---
name: iot
description: |
  自宅の家電・温湿度・照明を操作するスキル。実機が動く。Switchbot API のラッパ (ito FastAPI, localhost:9094)。
  「エアコン」「冷房」「暖房」「除湿」「送風」「消灯」「点灯」「室温」「温度」「湿度」
  「文鳥」「ベランダ」「リビング」「家電」「IoT」「Switchbot」「ito」
  「暑い」「寒い」、または /iot と言われたら必ず使う。
---

# IoT

自宅家電を操作する。**POST は実機が動く。** ユーザーが操作を依頼したら確認せず実行する。依頼されていない操作はしない。

`web_fetch` は localhost を弾く。必ず `curl` を使う。

## 接続

```
BASE=http://localhost:9094
```

接続失敗 → 「ito (9094) が落ちてる」と報告して終わる。勝手に起動しない。

## センサ（GET、副作用なし）

温度・湿度・天気を聞かれたら GET する。場所指定がなければ 3 点全部取る。

| path | 場所 |
|---|---|
| `GET /api/temp/hub2` | 室内（リビング） |
| `GET /api/temp/onmo` | 屋外（ベランダ） |
| `GET /api/temp/bun` | 文鳥小屋 |
| `GET /api/tenki` | 現在の天気アイコン |
| `GET /api/tenki/forecast` | 東京の予報 |

値は `raw.body.temperature` と `raw.body.humidity`。報告は `リビング 29°C / 50%` の形。

TTL 300 秒キャッシュあり。直前の操作結果とズレることがある。

## エアコン（POST、実操作）

```bash
curl -sS -X POST "$BASE/api/aircon" \
  -H 'Content-Type: application/json' \
  -d '{"mode":"cool","temperature":24}'
```

`mode` 必須。`temperature` / `fan` は省略可。

| 言い方 | mode | 省略時温度 |
|---|---|---|
| 消す・切る・オフ | `off` | 26 |
| 冷房・クーラー | `cool` | 24 |
| 除湿 | `dry` | 24 |
| 暖房 | `heat` | 26 |
| 送風 | `fan` | 25 |

「冷房 26 度」→ `{"mode":"cool","temperature":26}`。

## エアコン・シーン（POST、実操作）

温度指定なしのプリセットはシーンでも可。

```bash
curl -sS -X POST "$BASE/api/scene/id/<SCENE_ID>"
```

| 名前 | scene_id |
|---|---|
| AC/OFF | `T02-202305251653-17179166` |
| 暖房 | `T02-202310221850-30642228` |
| 送風 | `T02-202305291156-26733633` |
| 除湿 | `T02-202305251652-92445904` |
| とても冷房 | `8d48439e-a1ab-46a4-b174-6f8ecd0bef45` |

温度を指定されたら `/api/aircon`。プリセット名だけならシーン。

## 照明

FastAPI に点灯/消灯エンドポイントは無い（`/api/scene/shoto` `/api/scene/tento` は 404）。CLI を使う。

```bash
switchbot light on    # 点灯
switchbot light off   # 消灯
```

## VRChat 睡眠（POST）

明示的に VRChat / おやすみアバターのときだけ。

```bash
curl -sS -X POST "$BASE/api/vrc/oyasumi" \
  -H 'Content-Type: application/json' \
  -d '{"level":0}'
```

`level` は 0–3。寝る=3 まで段階、起きる=0。

## 報告

操作後はレスポンスを短く報告する。成功なら何をしたか一言。失敗なら status / body を出す。

## 禁止

- 依頼されていない POST / `switchbot light` / `switchbot scene`
- テスト目的の実操作
- 存在しないパスを叩く（`/api/scene/shoto` など）
- センサ GET 以外で OpenAPI を探り回る必要はない
