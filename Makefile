# Quality gate. Run `make check` before committing.

# clear.sh is zsh, which shellcheck does not support
SHELL_SCRIPTS := install.sh scripts/install-intellij-server.sh \
	bin/.local/bin/elio-pick bin/.local/bin/glowm-preview \
	bin/.local/bin/glowm-watch bin/.local/bin/helix-herdr

# Hand-written Lua only. hammerspoon Spoons/ and fish-helix are vendored.
LUA_TARGETS := hammerspoon/.hammerspoon/init.lua sketchybar/.config/sketchybar

.PHONY: check fish shellcheck lua python

check: fish shellcheck lua python

fish:
	@command -v fish >/dev/null 2>&1 || { echo "SKIP: fish not installed"; exit 0; }
	@find fish -name '*.fish' -print0 | xargs -0 -n1 fish -n
	@echo "fish: ok"

shellcheck:
	@command -v shellcheck >/dev/null 2>&1 || { echo "SKIP: shellcheck not installed (brew install shellcheck)"; exit 0; }
	@shellcheck $(SHELL_SCRIPTS)
	@echo "shellcheck: ok"

lua:
	@command -v stylua >/dev/null 2>&1 || { echo "SKIP: stylua not installed (brew install stylua)"; exit 0; }
	@stylua --check $(LUA_TARGETS)
	@echo "stylua: ok"

python:
	@command -v uv >/dev/null 2>&1 || { echo "SKIP: uv not installed"; exit 0; }
	@uv run --quiet --script tests/test_kanban_loop.py
