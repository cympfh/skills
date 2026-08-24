SHELL := /bin/bash

.PHONY: install diff help

DESTS = $(HOME)/.claude/skills $(HOME)/.agents/skills $(HOME)/.codex/skills $(HOME)/.grok/skills

## gh skill install で各エージェントへ入れる
install:
	for dest in $(DESTS); do \
		gh skill install $(CURDIR) --all --from-local --dir $$dest -f; \
		gh skill install anthropics/skills frontend-design --dir $$dest -f; \
	done

## install前に、各エージェントへ反映される差分(SKILL.md本文、frontmatterは除く)を確認する
diff:
	@strip_frontmatter() { awk '/^---$$/{c++; next} c<2{next} !started && $$0==""{next} {started=1; print}'; }; \
	for dest in $(DESTS); do \
		echo "=== $$dest ==="; \
		any=0; \
		for skill_dir in $(CURDIR)/skills/*/; do \
			name=$$(basename "$$skill_dir"); \
			local="$$skill_dir/SKILL.md"; \
			installed="$$dest/$$name/SKILL.md"; \
			[ -f "$$local" ] || continue; \
			if [ ! -f "$$installed" ]; then \
				echo "  [new] $$name"; any=1; continue; \
			fi; \
			d=$$(diff <(strip_frontmatter < "$$local") <(strip_frontmatter < "$$installed")); \
			if [ -n "$$d" ]; then \
				echo "  [changed] $$name"; \
				echo "$$d" | sed 's/^/    /'; \
				any=1; \
			fi; \
		done; \
		if [ $$any -eq 0 ]; then echo "  (no diff)"; fi; \
	done; \
	:

.DEFAULT_GOAL := help

help:
	@grep -A1 '^## ' ${MAKEFILE_LIST} | grep -v '^--' |\
		sed 's/^## *//g; s/:$$//g' |\
	awk 'NR % 2 == 1 { PREV=$$0 } NR % 2 == 0 { printf "\033[32m%-8s\033[0m --- %s\n", $$0, PREV }'
