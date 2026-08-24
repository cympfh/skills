# skills

Agent Skills。配置は `skills/*/SKILL.md`（[Agent Skills 仕様](https://agentskills.io/specification)）。

## インストール

このマシン:

```bash
make install
```

`gh skill install` で `~/.claude/skills/`、`~/.agents/skills/`、`~/.codex/skills/`、`~/.grok/skills/` にこのリポジトリの全スキルを入れる。`frontend-design` は [anthropics/skills](https://github.com/anthropics/skills) から入れる。

---

[GitHub CLI](https://cli.github.com/) **v2.90.0 以降**が必要（`gh skill` は preview）。

```bash
# 全スキルを Claude Code のユーザースコープへ
gh skill install cympfh/skills --all --agent claude-code --scope user

# 1つだけ
gh skill install cympfh/skills check --agent claude-code --scope user
```

`--scope` のデフォルトは `project`（カレント git リポジトリ）。全プロジェクトで使うなら `--scope user`。

`--agent` のデフォルトは `github-copilot`。よく使う値:

| `--agent` | ユーザースコープのインストール先 |
| --- | --- |
| `claude-code` | `~/.claude/skills/` |
| `codex` | `~/.codex/skills/` |
| `grok` | `~/.grok/skills/` |
| `cursor` | `~/.cursor/skills/` |
| `universal` | `~/.agents/skills/` |

一覧は `gh skill install --help`。`--agent grok` が無い古い gh は `--dir` で直接指定:

```bash
gh skill install cympfh/skills --all --dir ~/.grok/skills
```

対話なしでリポジトリ内スキルを列挙:

```bash
gh skill install cympfh/skills
```

バージョン指定（タグ / SHA）:

```bash
gh skill install cympfh/skills check@v1.2.0
gh skill install cympfh/skills check --pin abc123def
```

既存を上書きするときは `-f` / `--force`。

インストール前に中身を見る:

```bash
gh skill preview cympfh/skills check
```

更新:

```bash
gh skill update --all
```

ローカルの作業ツリーから入れる（`make install` と同じ。コピー）:

```bash
gh skill install ~/git/skills --all --from-local --agent claude-code --scope user
```

エイリアス: `gh skills`、`gh skill add`。詳細は [gh skill](https://cli.github.com/manual/gh_skill) / [gh skill install](https://cli.github.com/manual/gh_skill_install)。

## スキル

| name | 内容 |
| --- | --- |
| [arxiv-memo](skills/arxiv-memo/SKILL.md) | 論文の補助教材を Markdown で作る |
| [bump](skills/bump/SKILL.md) | プロジェクトのバージョンを上げる |
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
