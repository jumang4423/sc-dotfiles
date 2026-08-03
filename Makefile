SHELL := /bin/zsh
SUPERCOLLIDER_APP ?= /Applications/SuperCollider.app
SCLANG ?= $(SUPERCOLLIDER_APP)/Contents/MacOS/sclang

.PHONY: help new check check-tidal check-supercollider start stop restart status logs rec5 rec10 rec30

help:
	@echo "make new    - create today's next numbered Tidal set"
	@echo "make check  - test TidalCycles and the full SuperCollider startup"
	@echo "make start  - start SuperCollider and SuperDirt in the background"
	@echo "make stop   - stop every SuperCollider process"
	@echo "make restart - fully stop, then start one SuperCollider instance"
	@echo "make status - show whether the background process is running"
	@echo "make logs   - follow the SuperCollider log"
	@echo "make rec5   - record SuperCollider output for 5 seconds"
	@echo "make rec10  - record SuperCollider output for 10 seconds"
	@echo "make rec30  - record SuperCollider output for 30 seconds"

new:
	@./scripts/new-set.sh

check: check-tidal check-supercollider

check-tidal:
	@ghci -ignore-dot-ghci -v0 < BootTidal.hs

check-supercollider:
	@SCLANG="$(SCLANG)" ./scripts/check-supercollider.sh

start:
	@SCLANG="$(SCLANG)" ./scripts/start-supercollider.sh

stop:
	@./scripts/stop-supercollider.sh

restart:
	@$(MAKE) --no-print-directory stop
	@$(MAKE) --no-print-directory start

status:
	@./scripts/status-supercollider.sh

logs:
	@mkdir -p .run
	@touch .run/supercollider.log
	@tail -f .run/supercollider.log

rec5:
	@SCLANG="$(SCLANG)" ./scripts/record-supercollider.sh 5

rec10:
	@SCLANG="$(SCLANG)" ./scripts/record-supercollider.sh 10

rec30:
	@SCLANG="$(SCLANG)" ./scripts/record-supercollider.sh 30
