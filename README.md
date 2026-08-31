# skills

Agent Skills.
配置は `skills/*/SKILL.md`（[Agent Skills 仕様](https://agentskills.io/specification)）.

## Install

[GitHub CLI](https://cli.github.com/) **v2.90.0 以降** が必要

### gh skill install

```bash
# とりあえず何があるか見てみる
gh skill preview cympfh/skills

# 全スキルを Claude Code のユーザースコープへ
gh skill install cympfh/skills --all --agent claude-code --scope user

# todo スキルだけをインストール
gh skill install cympfh/skills todo
```

### 自分用に全部入れる

```bash
cd ~/git && git clone git@github.com:cympfh/skills.git && cd ~/git/skills/
make install
```

- 使ってるハーネス全部対象
    - `~/.agents/skills/`
    - `~/.claude/skills/`
    - `~/.codex/skills/`
    - `~/.grok/skills/`
- 追加で
    - [anthropics/skills](https://github.com/anthropics/skills)
    - [herdrdev/herdr](https://github.com/herdrdev/herdr) の `herdr` skill

## スキル

| name | 内容 |
| --- | --- |
| [arxiv-memo](skills/arxiv-memo/SKILL.md) | 論文の補助教材を Markdown で作る |
| [bump](skills/bump/SKILL.md) | プロジェクトのバージョンを上げる |
| [calendar](skills/calendar/SKILL.md) | `~/Dropbox/cal/` の予定。追記のみ、削除禁止 |
| [check](skills/check/SKILL.md) | コードの確認・報告。実装しない |
| [git](skills/git/SKILL.md) | git commit |
| [grill-me](skills/grill-me/SKILL.md) | 設計・意思決定を徹底的に質問する |
| [iot](skills/iot/SKILL.md) | 自宅家電・温湿度・照明を操作する |
| [issue](skills/issue/SKILL.md) | 人間への相談を `ISSUE.md` に書き出す |
| [notify](skills/notify/SKILL.md) | 作業完了時にデスクトップ通知 |
| [private](skills/private/SKILL.md) | プライベートメモの記録・検索 |
| [report](skills/report/SKILL.md) | 作業レポート |
| [skill-creator](skills/skill-creator/SKILL.md) | スキルの作成・改善 |
| [todo](skills/todo/SKILL.md) | `TODO.md` の管理 |
