# iOS Makefile – helper targets for common workflows
# Override variables via: make <target> SCHEME=YourScheme CONFIGURATION=Debug

# Auto-detect workspace/project if present in the repo
WORKSPACE ?= $(firstword $(wildcard *.xcworkspace))
PROJECT   ?= $(firstword $(wildcard *.xcodeproj))

# Try to auto-detect a scheme (first listed). You can always override: SCHEME=...
DETECTED_SCHEME := $(shell \
  if [ -n "$(WORKSPACE)" ]; then \
    xcodebuild -list -workspace "$(WORKSPACE)" 2>/dev/null | awk '/Schemes:/{flag=1;next}/^$$/{flag=0}flag' | head -n1; \
  elif [ -n "$(PROJECT)" ]; then \
    xcodebuild -list -project "$(PROJECT)" 2>/dev/null | awk '/Schemes:/{flag=1;next}/^$$/{flag=0}flag' | head -n1; \
  fi)
SCHEME ?= $(DETECTED_SCHEME)

CONFIGURATION ?= Debug
DESTINATION  ?= platform=iOS Simulator,name=iPhone 15,OS=latest
ARCHIVE_PATH ?= build/$(SCHEME).xcarchive

# Compose xcodebuild target selector
XCODE_TARGET := $(if $(WORKSPACE),-workspace "$(WORKSPACE)",-project "$(PROJECT)")

.PHONY: help bootstrap open build test clean archive lint format ci

help:
	@echo "Make targets for iOS/Xcode"
	@echo
	@echo "Usage: make <target> [VAR=value]"
	@echo
	@echo "Targets:"
	@echo "  help        Show this help"
	@echo "  bootstrap   Setup tools, install deps (Pods/SPM), chmod scripts"
	@echo "  open        Open the workspace/project in Xcode"
	@echo "  build       Build the app"
	@echo "  test        Run unit/UI tests"
	@echo "  clean       Clean build artifacts"
	@echo "  archive     Create a Release archive"
	@echo "  lint        Run linters/formatters"
	@echo "  format      Format Swift sources if swift-format available"
	@echo "  ci          Lint + test (CI convenience)"
	@echo
	@echo "Variables (override as needed):"
	@echo "  WORKSPACE     = $(WORKSPACE)"
	@echo "  PROJECT       = $(PROJECT)"
	@echo "  SCHEME        = $(SCHEME)"
	@echo "  CONFIGURATION = $(CONFIGURATION)"
	@echo "  DESTINATION   = $(DESTINATION)"
	@echo "  ARCHIVE_PATH  = $(ARCHIVE_PATH)"

bootstrap:
	@echo "[bootstrap] Ensuring script permissions..."
	@if [ -d Scripts ]; then chmod +x Scripts/*.sh 2>/dev/null || true; fi
	@echo "[bootstrap] Installing Ruby gems if Gemfile exists..."
	@if [ -f Gemfile ]; then \
		if command -v bundle >/dev/null 2>&1; then bundle install; else echo "[bootstrap] bundler not installed. Skipping."; fi; \
	fi
	@echo "[bootstrap] Installing CocoaPods if Podfile exists..."
	@if [ -f Podfile ]; then \
		if command -v bundle >/dev/null 2>&1 && bundle exec pod --version >/dev/null 2>&1; then \
			bundle exec pod install; \
		elif command -v pod >/dev/null 2>&1; then \
			pod install; \
		else \
			echo "[bootstrap] CocoaPods not installed. Skipping."; \
		fi; \
	fi
	@echo "[bootstrap] Resolving Swift Package Manager dependencies if Package.swift exists..."
	@if [ -f Package.swift ]; then \
		if command -v swift >/dev/null 2>&1; then swift package resolve; else echo "[bootstrap] swift not available. Skipping."; fi; \
	fi
	@echo "[bootstrap] Done."

open:
	@if [ -n "$(WORKSPACE)" ]; then \
		echo "Opening $(WORKSPACE)"; open "$(WORKSPACE)"; \
	elif [ -n "$(PROJECT)" ]; then \
		echo "Opening $(PROJECT)"; open "$(PROJECT)"; \
	else \
		echo "No .xcworkspace or .xcodeproj found."; exit 1; \
	fi

_ensure-scheme:
	@if [ -z "$(SCHEME)" ]; then \
		echo "SCHEME not set and could not detect one. Provide SCHEME=YourScheme"; \
		exit 1; \
	fi

build: _ensure-scheme
	@echo "[build] Building scheme=$(SCHEME) config=$(CONFIGURATION)"
	@set -o pipefail; xcodebuild $(XCODE_TARGET) -scheme "$(SCHEME)" -configuration $(CONFIGURATION) build | \
		( command -v xcbeautify >/dev/null 2>&1 && xcbeautify || \
		  command -v xcpretty >/dev/null 2>&1 && xcpretty || cat )

test: _ensure-scheme
	@echo "[test] Testing scheme=$(SCHEME) dest=$(DESTINATION)"
	@set -o pipefail; xcodebuild $(XCODE_TARGET) -scheme "$(SCHEME)" -configuration $(CONFIGURATION) \
		-destination '$(DESTINATION)' -enableCodeCoverage YES test | \
		( command -v xcbeautify >/dev/null 2>&1 && xcbeautify || \
		  command -v xcpretty >/dev/null 2>&1 && xcpretty || cat )

clean: _ensure-scheme
	@echo "[clean] Cleaning scheme=$(SCHEME)"
	@xcodebuild $(XCODE_TARGET) -scheme "$(SCHEME)" clean >/dev/null
	@echo "[clean] Done."

archive: _ensure-scheme
	@echo "[archive] Archiving scheme=$(SCHEME) to $(ARCHIVE_PATH)"
	@set -o pipefail; xcodebuild $(XCODE_TARGET) -scheme "$(SCHEME)" -configuration Release \
		-destination 'generic/platform=iOS' archive -archivePath "$(ARCHIVE_PATH)" | \
		( command -v xcbeautify >/dev/null 2>&1 && xcbeautify || \
		  command -v xcpretty >/dev/null 2>&1 && xcpretty || cat )

lint:
	@echo "[lint] Running linters..."
	@bash Scripts/lint.sh

format:
	@if command -v swift-format >/dev/null 2>&1; then \
		echo "[format] Running swift-format..."; \
		swift-format format --in-place --recursive .; \
	else \
		echo "[format] swift-format not installed. Skipping."; \
	fi

ci: lint test
	@echo "[ci] Completed lint + test"

