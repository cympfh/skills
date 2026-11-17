SHELL := /bin/bash

.PHONY: install diff help

DESTS = $(HOME)/.claude/skills $(HOME)/.agents/skills $(HOME)/.codex/skills $(HOME)/.grok/skills

## gh skill install で各エージェントへ入れる
install:
	for dest in $(DESTS); do \
		gh skill install $(CURDIR) --all --from-local --dir $$dest -f; \
		gh skill install anthropics/skills frontend-design --dir $$dest -f; \
		gh skill install herdrdev/herdr herdr --dir $$dest -f; \
	done

## install前に、各エージェントへ反映される差分(SKILL.mdのfrontmatter/本文)を確認する
## gh skill install が注入する metadata(local-path)とキー順序の違いだけは無視する
diff:
	@extract_frontmatter() { awk '/^---$$/{c++; next} c!=1{next} $$0 ~ /^metadata:/{skip=1; next} skip{if ($$0 ~ /^[ \t]/) next; skip=0} {if ($$0 !~ /^[ \t]/){split($$0,a,":"); key=a[1]} line=$$0; gsub(/^[ \t]+/, "", line); gsub(/\|-$$/, "|", line); if (line=="") next; print key" "line}' | sort -k1,1 -s | sed 's/^[^ ]* //'; }; \
	extract_body() { awk '/^---$$/{c++; next} c<2{next} !started && $$0==""{next} {started=1; print}'; }; \
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
			fm_diff=$$(diff <(extract_frontmatter < "$$local") <(extract_frontmatter < "$$installed")); \
			body_diff=$$(diff <(extract_body < "$$local") <(extract_body < "$$installed")); \
			if [ -n "$$fm_diff" ]; then \
				echo "  [changed:frontmatter] $$name"; \
				echo "$$fm_diff" | sed 's/^/    /'; \
				any=1; \
			fi; \
			if [ -n "$$body_diff" ]; then \
				echo "  [changed:body] $$name"; \
				echo "$$body_diff" | sed 's/^/    /'; \
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
