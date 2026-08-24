.PHONY: install help

DESTS = $(HOME)/.claude/skills $(HOME)/.agents/skills $(HOME)/.codex/skills $(HOME)/.grok/skills

## gh skill install で各エージェントへ入れる
install:
	for dest in $(DESTS); do \
		gh skill install $(CURDIR) --all --from-local --dir $$dest -f; \
		gh skill install anthropics/skills frontend-design --dir $$dest -f; \
	done

.DEFAULT_GOAL := help

help:
	@grep -A1 '^## ' ${MAKEFILE_LIST} | grep -v '^--' |\
		sed 's/^## *//g; s/:$$//g' |\
	awk 'NR % 2 == 1 { PREV=$$0 } NR % 2 == 0 { printf "\033[32m%-8s\033[0m --- %s\n", $$0, PREV }'
