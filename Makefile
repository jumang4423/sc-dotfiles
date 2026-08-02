SHELL := /bin/zsh
SUPERCOLLIDER_APP ?= /Applications/SuperCollider.app
SCLANG ?= $(SUPERCOLLIDER_APP)/Contents/MacOS/sclang

.PHONY: help check check-tidal check-supercollider start stop status logs

help:
	@echo "make check  - test TidalCycles and the full SuperCollider startup"
	@echo "make start  - start SuperCollider and SuperDirt in the background"
	@echo "make stop   - stop the background SuperCollider process"
	@echo "make status - show whether the background process is running"
	@echo "make logs   - follow the SuperCollider log"

check: check-tidal check-supercollider

check-tidal:
	@ghci -ignore-dot-ghci -v0 < BootTidal.hs

check-supercollider:
	@SCLANG="$(SCLANG)" ./scripts/check-supercollider.sh

start:
	@SCLANG="$(SCLANG)" ./scripts/start-supercollider.sh

stop:
	@./scripts/stop-supercollider.sh

status:
	@./scripts/status-supercollider.sh

logs:
	@mkdir -p .run
	@touch .run/supercollider.log
	@tail -f .run/supercollider.log
