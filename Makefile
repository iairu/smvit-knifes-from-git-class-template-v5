# -------------------------
# 📄 Makefile – Docusaurus + Git Utils (unified)
# Date: 20250815-0950 (patched, cleaned 20250916)
# Description: Inštalácia, build, testy, validácia a WorkTree deploy.
# CESTA 2 (Actions) doplníme neskôr – tento Makefile je zámerne jednotný.
#
# ❗ Dôležité: pri deployi do worktree NIKDY nemaž priečinok/súbor .git.
# Ak je worktree „rozbité“, použi:  make check-worktree  (self-healing)
# -------------------------

# ❗ Worktree deploy vyžaduje lokálnu GIT autentikáciu k GitHubu.
#    Bez platného HTTPS tokenu (osxkeychain) alebo SSH kľúča `git push` zlyhá.
#    Pozri: make help-auth
# Keď spustíš len `make`, ukáž help
.DEFAULT_GOAL := help  # zobrazenie help pri samotnom `make`
 
SHELL := /bin/bash
NODE := node
NPM  := npm

DOCS_DIR  := docs
BUILD_DIR = $(PUB_BUILD_DIR)

# Build timestamp in UTC (used for footer "Last build")
BUILD_DATE := $(shell date -u '+%Y-%m-%d %H:%M:%S UTC')
# Release helpers (local tag push)
BRANCH ?= main
DATE   := $(shell date -u +%Y%m%d-%H%M%SZ)
VERSION ?= v$(DATE)
MSG     ?= Release $(VERSION)

# 🌿 Worktree deploy
DEPLOY_BRANCH = gh-pages-docusaurus
WORKTREE_DIR  = ../$(DEPLOY_BRANCH)
PAGES_DIR     = $(WORKTREE_DIR)/docs   # <- GH Pages „/docs“ režim

# macOS sed (BSD) potrebuje -i ''
SED_INPLACE := sed -E -i ''
FIND_MD := find $(DOCS_DIR) -type f \( -name "*.md" -o -name "*.mdx" \)

# --- Content → Docusaurus sync paths (Mac) ---
CONTENT_DOCS_DIR := content/docs
PUB_DOCUS_DIR    := publishing/docusaurus
PUB_DOCS_DIR     := $(PUB_DOCUS_DIR)/docs
PUB_BUILD_DIR    := $(PUB_DOCUS_DIR)/build
WORKTREE_DOCS    := $(PAGES_DIR)

# KNIFES generator (CSV → MD)
# default CSV (SSOT export)
SCRIPTS_DIR := scripts
# Single point of input (config-driven)
CONFIG_JSON := config/knifes_config.json
# CSV default path – read from docs/config/knifes_config.json if present; fallback to new location
CSV_DEFAULT := $(shell node -p "try{require('./$(CONFIG_JSON)').csv || ''}catch(e){''}")
ifeq ($(strip $(CSV_DEFAULT)),)
CSV_DEFAULT := config/data/KNIFES-OVERVIEW-INPUTs.csv
endif
# hlavný CSV (možno prebíjať v prostredí)
CSV_OVERVIEW ?= $(CSV_DEFAULT)

# fallback na overview, ak nie je zadané
CSV_BACKFILL ?= $(CSV_OVERVIEW)

# Output directory for CSV snapshots/fixes
OUT_DIR    ?= config/out


# Default locale for normalize/report targets
LOCALE ?= sk

# Reference KNIFES (read-only governance / templates / rules)
KNIFES_REF_DIR := $(DOCS_DIR)/sk/ref
KNIFES_REF_MD_GLOB := $(KNIFES_REF_DIR)/**/index.md
# KNIFES main directory (default scan root)
KNIFES_DIR ?= docs/sk/knifes

# Minify toggle (default ON). Use: make build MINIFY=0  -> passes --no-minify

MINIFY ?= 1
BUILD_EXTRA :=
ifeq ($(MINIFY),0)
  BUILD_EXTRA := --no-minify
endif

# Docusaurus per-locale helpers (keep SK+EN, but allow single-locale runs)
DS_LOCALE ?=
BUILD_LOCALE_OPT :=
ifneq ($(strip $(DS_LOCALE)),)
  BUILD_LOCALE_OPT := --locale $(DS_LOCALE)
endif



.PHONY: \
  help help-auth help-actions \
  install dev clean build build-fast ci-build serve \
  check-links check-links-hard check-links-fast check-links-full fix-links \
  init-worktree check-worktree copy-build commit-deploy remove-worktree \
  push-main deploy full-deploy worktree-status \
  sandbox-from-main sandbox-from-worktree \
  stash-save stash-list stash-apply stash-drop \
  restore-folder restore-file restore-path restore-from-stash-file \
  delete-dotpages \
  actions-status actions-disable actions-enable \
  quickstart mode doctor next-steps \
  knifes-gen knifes-new dev-gen build-gen \
  gen-dry dry-verify \
  knifes-guid-backfill knifes-meta-backfill \
  knifes-verify knifes-verify-csv-docs knifes-verify-frontmatter knifes-verify-smart \
  print-vars knifes-audit-frontmatter \
  fm-fix fm-fix-dry fm-fix-file fm-fix-file-dry fm-set-slug-file knifes-fm-add-missing knifes-fm-add-missing-dry \
  release-ci release-ci-datetime \
  commit push tag push-tag release release-auto release-commit check-version knifes-finish knifes-finish-dry upgrade-docusaurus \
  knife-fm-dry knife-fm-fix knife-header-check knife-csv-fix knife-fm-report-id knife-fm-report-tree \
  knife-normalize-dry knife-normalize-apply csv-normalize-dry csv-normalize-apply \
  knifes-frontmatter-audit knifes-frontmatter-fix-dry knifes-frontmatter-fix-apply knifes-frontmatter-merge \
  knifes-frontmatter-slug-report knifes-frontmatter-slug-comment-dry knifes-frontmatter-slug-comment-apply \
  knifes-frontmatter-slug-delete-dry knifes-frontmatter-slug-delete-apply \
  knifes-id6-dry knifes-id6-apply knifes-id6-audit \
  knifes-frontmatter-audit-id knifes-frontmatter-fix-id-dry knifes-frontmatter-fix-id-apply \
  knifes-build-dry knifes-build-apply \
  knifes-gen-dry knifes-gen-apply \
  knifes-datekey-remove-dry knifes-datekey-remove-apply knifes-smartquotes-scan knifes-smartquotes-fix-dry knifes-smartquotes-fix-apply \
  knife-fm-apply k18-audit k18-fix-dry k18-fix-apply k18-verify k18-align-dry k18-align-apply \
  knifes-ref-audit knifes-ref-align-dry knifes-ref-align-apply \
  knifes-csv-scan knifes-fix-csv-dry knifes-fix-csv-apply \
  SY01-sync-content P10-preview P20-serve-worktree

# -------------------------
# 📌 Help
# -------------------------
help:
	@echo "# #########################################################################"
	@echo "#.                                        KNIFE Makefile v2 from 20250815 #"
	@echo "# 📄 Makefile – Docusaurus + Git Utils (unified)                          #"
	@echo "# Date: 20250815-0950 (patched, cleaned 20250916)                         #"
	@echo "# Description: Inštalácia, build, testy, validácia a WorkTree deploy.     #"
	@echo "# CESTA 2 (Actions) doplníme neskôr – tento Makefile je zámerne jednotný. #"
	@echo "# ❗ Pri deployi do worktree NIKDY nemaž .git; oprav: make check-worktree  #"
	@echo "# #########################################################################"
	@echo "===== 🧭 UX – pamäťový ťahák ====="
	@echo "  quickstart             - 3 kroky na bežný deň (najčastejší flow)"
	@echo "  mode                   - Zistí, či ideš cez Worktree alebo Actions"
	@echo "  doctor                 - Základná diagnostika (node/git/remote/worktree)"
	@echo "  next-steps             - Odporúčanie ďalšieho kroku podľa stavu"
	@echo "===== ⚙️ Actions toggles ====="
	@echo "  actions-status         - Zobrazí, či je workflow zapnutý/vypnutý"
	@echo "  actions-disable        - Dočasne vypne Actions (premenuje deploy.yml)"
	@echo "  actions-enable         - Znovu zapne Actions"
	@echo "  help-actions           - Krátky návod ku GitHub Pages (Actions)"
	@echo "===== 📚 Docusaurus ====="
	@echo "  install                - Nainštaluje docusaurus balíčky"
	@echo "  dev                    - Spustí dev server"
	@echo "  clean                  - Vyčistí cache a build adresáre"
	@echo "  build                  - Build (MINIFY=$(MINIFY)); prepínateľné: make build MINIFY=0"
	@echo "  build-fast             - Alias na 'make build MINIFY=0' (bez minify)"
	@echo "  ci-build               - CI-friendly build bez minifikácie (alias na 'make build MINIFY=0')"
	@echo "  serve                  - Lokálne naservíruj statický build"
	@echo "  SY01-sync-content      - Sync SSOT (content/docs) → publishing/docusaurus/docs"
	@echo "  P10-preview            - Prod náhľad: build + serve lokálne (publishing/docusaurus)"
	@echo "  P20-serve-worktree     - Serve priamo worktree /docs (to čo ide na Pages)"
	@echo "  upgrade-docusaurus    - Upgrade Docusaurus balíčkov na poslednú verziu (@latest)"
	@echo "===== 🚀 Release (CI) =====" 
	@echo "  release-ci             - SemVer patch bump (npm version patch) + push tag → spustí CI release"
	@echo "  release-ci-datetime    - Vytvorí tag vYYYYMMDD-HHMM (UTC) bez zmeny package.json a pushne ho"
	@echo "                         Príklad: v20250925-2315"
	@echo "                         Použitie: make release-ci | make release-ci-datetime"
	@echo "                         (CI) vyžaduje: .github/workflows/release.yml"
	@echo "                          APP_VERSION v pätičke sa nastaví v CI z tagu: $${GITHUB_REF_NAME}"
	@echo "===== 🏷️ Release (lokálne tagy) ====="
	@echo "  release            - vytvorí annotated tag $(VERSION) a pushne ho (spustí CI Release)"
	@echo "  release-auto       - automatický tag vYYYYMMDD-HHMMSSZ a pushne ho"
	@echo "  release-commit     - commit -> push vetvy -> tag -> push tag"
	@echo "  tag                - len vytvorí lokálny tag (bez pushu)"
	@echo "  push-tag           - pushne zadaný tag na origin"
	@echo "===== 🔍 Link Checker ====="
	@echo "  check-links            - DRY-RUN kontrola odkazov v docs/"
	@echo "  check-links-hard       - Striktná kontrola: spustí build"
	@echo "  check-links-fast       - Striktná kontrola s vypnutou minifikáciou"
	@echo "  check-links-full       - Full kontrola (docs + config + témy)"
	@echo "  fix-links              - Oprava …/index -> …/"
	@echo "===== 🌿 Worktree Deploy ====="
	@echo "  init-worktree          - Alias na check-worktree (založí/opraví worktree)"
	@echo "  check-worktree         - Overí/Vytvorí worktree (self-healing)"
	@echo "  copy-build             - Rsync build/ -> $(PAGES_DIR)/  (chráni .git)"
	@echo "  commit-deploy          - Commit & push z worktree"
	@echo "  remove-worktree        - Odpojí worktree (NEmaž .git ručne!)"
	@echo "  worktree-status        - Debug: git status + zoznam worktrees"
	@echo "  push-main              - Bezpečný push mainu (zastaví ak máš zmeny)"
	@echo "  deploy                 - check-worktree + build + copy-build + commit-deploy"
	@echo "  full-deploy            - check-worktree + push-main + build + copy + commit"
	@echo "===== 🧩 KNIFE Generátor ====="
	@echo "  knifes-validate         - Validuje CSV podľa config/knifes_config.json"
	@echo "  knifes-prepare          - Validate + Generate (E2E, config-driven)"
	@echo "  knifes-prepare-strict   - Prísna validácia + Generate (na CI)"
	@echo "  knifes-generate         - Generuje prehľady + nové KNIFE (config-driven)"
	@echo "  dev-gen                - knifes-gen + dev (vygeneruje MD a spustí lokálny dev)"
	@echo "  build-gen              - knifes-gen + build (vygeneruje MD a spraví prod build)"
	@echo "  knifes-gen             - Generuje/aktualizuje MD zo CSV (prehľady + chýbajúce Kxxx skeletony)"
	@echo "  knifes-new              - id=K000062 title=\"...\" – rýchlo založí skeleton novej KNIFE"
	@echo "  gen-dry                - „suchý“ plán generovania (nič nezapisuje)"
	@echo "  dry-verify             - skrátená validácia cez generátor (bez zásahu)"
	@echo "  knifes-build-dry       - DRY-RUN: build (CSV→MD) podľa configu, nič nezapisuje [NEW 2025-10-04]"
	@echo "  knifes-build-apply     - APPLY:   build (CSV→MD) podľa configu, zapíše zmeny [NEW 2025-10-04]"
	@echo "  knifes-csv-scan         - Naskenuje docs/sk/knifes → vytvorí CSV snapshot (timestamp)"
	@echo "  knifes-fix-csv-dry      - DRY: MD → CSV (fill-only), nič neprepíše (len plán)"
	@echo "  knifes-fix-csv-apply    - APPLY: MD → CSV (fill-only), zapíše nový CSV s timestampom"
# -------------------------
# 🏗 KNIFES Build (explicit DRY/APPLY wrappers)
# -------------------------
.PHONY: knifes-build-dry knifes-build-apply

## knifes-build-dry: DRY-RUN build (CSV→MD) – no writes
knifes-build-dry:
	@CSV="$(csv)"; if [ -z "$$CSV" ]; then CSV="$(strip $(CSV_OVERVIEW))"; fi; \
	echo "🧪 DRY-RUN: KNIFES build (CSV→MD) [$$(date -u +'%Y-%m-%d %H:%M:%S UTC')] – CSV='$$CSV' locale=$(LOCALE)"; \
	node "$(SCRIPTS_DIR)/knifes-build.mjs" --csv "$$CSV" --root . --locale $(LOCALE) --dry-run

## knifes-build-apply: APPLY build (CSV→MD) – writes
# knifes-build-apply: APPLY build (CSV→MD) – writes
knifes-build-apply:
	@CSV="$(csv)"; if [ -z "$$CSV" ]; then CSV="$(strip $(CSV_OVERVIEW))"; fi; \
	echo "🛠 APPLY: KNIFES build (CSV→MD) [$$(date -u +'%Y-%m-%d %H:%M:%S UTC')] – CSV='$$CSV' locale=$(LOCALE)"; \
	node "$(SCRIPTS_DIR)/knifes-build.mjs" --csv "$$CSV" --root . --locale $(LOCALE)

# -------------------------
# ✅ Backfill & Verify
# -------------------------
# 🧰 KNIFE Normalize (main MD in each KNIFE folder)
# -------------------------
.PHONY: knife-normalize-dry knife-normalize-apply

## knife-normalize-dry: DRY-RUN normalize (no writes)
knife-normalize-dry:
	@echo "🧪 DRY-RUN: knifes-normalize (locale=$(LOCALE))"
	@node scripts/knifes-normalize.mjs --locale $(LOCALE) --dry

## knife-normalize-apply: APPLY normalize (writes)
knife-normalize-apply:
	@echo "🛠 APPLY: knifes-normalize (locale=$(LOCALE))"
	@node scripts/knifes-normalize.mjs --locale $(LOCALE) --apply


# -------------------------
# 🧼 CSV Normalize (aliases + dates + status)
# -------------------------
.PHONY: csv-normalize-dry csv-normalize-apply

## csv-normalize-dry: DRY-RUN CSV normalization (no writes)
csv-normalize-dry:
	@echo "🧪 DRY-RUN: CSV normalize podľa $(CONFIG_JSON)"
	@node scripts/knifes-csv-normalize.mjs --config $(CONFIG_JSON) --dry

## csv-normalize-apply: APPLY CSV normalization (with backup)
csv-normalize-apply:
	@echo "🛠 APPLY: CSV normalize podľa $(CONFIG_JSON) (backup pred zápisom)"
	@node scripts/knifes-csv-normalize.mjs --config $(CONFIG_JSON) --apply


# -------------------------
# 🔑 CSV GUID Sync (MD → CSV)
# -------------------------
.PHONY: csv-guid-sync-dry csv-guid-sync-apply

## csv-guid-sync-dry: DRY-RUN sync GUID from MD frontmatter into CSV
csv-guid-sync-dry:
	@echo "🧪 DRY-RUN: Sync GUID z MD (frontmatter) do CSV podľa $(CONFIG_JSON)"
	@node scripts/knifes-csv-sync-guid.mjs --config $(CONFIG_JSON) --dry

## csv-guid-sync-apply: APPLY sync GUID from MD into CSV (with backup)
csv-guid-sync-apply:
	@echo "🛠 APPLY: Sync GUID z MD (frontmatter) do CSV (backup pred zápisom)"
	@node scripts/knifes-csv-sync-guid.mjs --config $(CONFIG_JSON) --apply

# Extra: GUID audit alias (read-only – same as DRY)
.PHONY: csv-guid-sync-audit
csv-guid-sync-audit:
	@echo "🔎 AUDIT: Sync GUID (MD → CSV) – read-only"
	@node $(SCRIPTS_DIR)/knifes-csv-sync-guid.mjs --config $(CONFIG_JSON) --csv $(CSV_OVERVIEW) --fields guid --dry

# -------------------------
# 🔑 CSV DAO Sync (MD → CSV)
# -------------------------
.PHONY: csv-dao-sync-dry csv-dao-sync-apply csv-dao-sync-audit

## csv-dao-sync-dry: DRY-RUN sync DAO from MD frontmatter into CSV
csv-dao-sync-dry:
	@echo "🧪 DRY-RUN: Sync DAO z MD (frontmatter) do CSV podľa $(CONFIG_JSON)"
	@node $(SCRIPTS_DIR)/knifes-csv-sync-guid.mjs --config $(CONFIG_JSON) --csv $(CSV_OVERVIEW) --fields dao --dry

## csv-dao-sync-apply: APPLY sync DAO from MD into CSV (with backup)
csv-dao-sync-apply:
	@echo "🛠 APPLY: Sync DAO z MD (frontmatter) do CSV (backup pred zápisom)"
	@cp $(CSV_OVERVIEW) $(CSV_OVERVIEW).bak || true
	@node $(SCRIPTS_DIR)/knifes-csv-sync-guid.mjs --config $(CONFIG_JSON) --csv $(CSV_OVERVIEW) --fields dao --apply

## csv-dao-sync-audit: AUDIT (alias DRY) DAO sync
csv-dao-sync-audit:
	@echo "🔎 AUDIT: Sync DAO (MD → CSV) – read-only"
	@node $(SCRIPTS_DIR)/knifes-csv-sync-guid.mjs --config $(CONFIG_JSON) --csv $(CSV_OVERVIEW) --fields dao --dry

# -------------------------
# 🔑 CSV DID Sync (MD → CSV)
# -------------------------
.PHONY: csv-did-sync-dry csv-did-sync-apply csv-did-sync-audit

## csv-did-sync-dry: DRY-RUN sync DID from MD frontmatter into CSV
csv-did-sync-dry:
	@echo "🧪 DRY-RUN: Sync DID z MD (frontmatter) do CSV podľa $(CONFIG_JSON)"
	@node $(SCRIPTS_DIR)/knifes-csv-sync-guid.mjs --config $(CONFIG_JSON) --csv $(CSV_OVERVIEW) --fields did --dry

## csv-did-sync-apply: APPLY sync DID from MD into CSV (with backup)
csv-did-sync-apply:
	@echo "🛠 APPLY: Sync DID z MD (frontmatter) do CSV (backup pred zápisom)"
	@cp $(CSV_OVERVIEW) $(CSV_OVERVIEW).bak || true
	@node $(SCRIPTS_DIR)/knifes-csv-sync-guid.mjs --config $(CONFIG_JSON) --csv $(CSV_OVERVIEW) --fields did --apply

## csv-did-sync-audit: AUDIT (alias DRY) DID sync
csv-did-sync-audit:
	@echo "🔎 AUDIT: Sync DID (MD → CSV) – read-only"
	@node $(SCRIPTS_DIR)/knifes-csv-sync-guid.mjs --config $(CONFIG_JSON) --csv $(CSV_OVERVIEW) --fields did --dry

help-auth:
	@echo "===== 🔐 Autentikácia pre Worktree deploy ====="
	@echo "HTTPS (odporúčané na macOS):"
	@echo "  git remote -v   # má byť https://"
	@echo "  git config --global credential.helper osxkeychain"
	@echo "  pri prvom 'git push' zadaj PAT -> uloží sa do Keychain"
	@echo "SSH (alternatíva):"
	@echo "  ssh-keygen -t ed25519 -C 'tvoj@email'"
	@echo "  eval \"$$(/usr/bin/ssh-agent -s)\" && ssh-add $$HOME/.ssh/id_ed25519"
	@echo "  nahraj verejný kľúč do GitHub (Settings -> SSH and GPG keys)"
	@echo "  git remote set-url origin git@github.com:ORG/REPO.git"
	@echo "  test: ssh -T git@github.com"

help-actions:
	@echo "===== ⚙️ CI/CD (Cesta 2 – GitHub Actions → Pages) ====="
	@echo "1) Pridaj .github/workflows/deploy.yml (oficiálny Docusaurus workflow)."
	@echo "2) Settings -> Pages -> Build and deployment = GitHub Actions."
	@echo "3) V docusaurus.config nastav správny baseUrl (napr. '/knifes-overview/')."
	@echo "4) Po push do main sa build nasadí automaticky."

# -------------------------
# 🚀 Docusaurus Commands
# -------------------------

install:
	cd "$(PUB_DOCUS_DIR)" && $(NPM) install

dev:
	cd "$(PUB_DOCUS_DIR)" && BUILD_DATE="September 2025" NODE_OPTIONS=--max-old-space-size=16384 $(NPM) start -- $(BUILD_LOCALE_OPT)

clean:
	cd "$(PUB_DOCUS_DIR)" && $(NPM) run clear || true
	rm -rf $(PUB_BUILD_DIR) "$(PUB_DOCUS_DIR)/.docusaurus"

build: SY01-sync-content clean
	cd "$(PUB_DOCUS_DIR)" && BUILD_DATE="$(BUILD_DATE)" NODE_OPTIONS=--max-old-space-size=16384 $(NPM) run build -- $(BUILD_EXTRA) $(BUILD_LOCALE_OPT)

build-fast:
	$(MAKE) build MINIFY=0

ci-build:
	$(MAKE) build MINIFY=0

.PHONY: dev-sk dev-en build-sk build-en

dev-sk:
	$(MAKE) dev DS_LOCALE=sk

dev-en:
	$(MAKE) dev DS_LOCALE=en

build-sk:
	$(MAKE) build DS_LOCALE=sk

build-en:
	$(MAKE) build DS_LOCALE=en

serve:
	cd "$(PUB_DOCUS_DIR)" && $(NPM) run serve

.PHONY: docusaurus-dev

docusaurus-dev: dev

# -------------------------
# 🧭 SSOT → Docusaurus sync (Mac)
# -------------------------
SY01-sync-content:
	@if [ ! -d "$(CONTENT_DOCS_DIR)" ]; then echo "❌ Nenájdené: $(CONTENT_DOCS_DIR)"; exit 1; fi
	@mkdir -p "$(PUB_DOCS_DIR)"
	rsync -av --delete --checksum "$(CONTENT_DOCS_DIR)/" "$(PUB_DOCS_DIR)/"
	@echo "✅ Synced: $(CONTENT_DOCS_DIR) → $(PUB_DOCS_DIR)"

# -------------------------
# 🎬 Prod preview (build + serve)
# -------------------------
P10-preview: SY01-sync-content
	cd "$(PUB_DOCUS_DIR)" && npm run build
	cd "$(PUB_DOCUS_DIR)" && npm run serve

# -------------------------
# 🌿 Lokálny server nad WORKTREE /docs
# (simuluje presne GitHub Pages obsah)
# -------------------------
P20-serve-worktree:
	@if [ ! -d "$(WORKTREE_DOCS)" ]; then \
	  echo "❌ Nenájdený worktree /docs: $(WORKTREE_DOCS)"; \
	  echo "   Spusť najprv: make check-worktree && make build && make copy-build"; \
	  exit 1; \
	fi
	@echo "🌐 Serving $(WORKTREE_DOCS) na http://127.0.0.1:8080"
	python3 -m http.server 8080 --directory "$(WORKTREE_DOCS)"

upgrade-docusaurus: ## Upgrade Docusaurus packages to latest version
	npm i @docusaurus/core@latest \
	      @docusaurus/plugin-google-gtag@latest \
	      @docusaurus/preset-classic@latest \
	      @docusaurus/module-type-aliases@latest \
	      @docusaurus/plugin-client-redirects@latest \
	      @docusaurus/tsconfig@latest \
	      @docusaurus/types@latest

#
# -------------------------
# 🔍 Link Checker
# -------------------------
check-links:
	@echo ">>> DRY-RUN: hľadám odkazy s '/index' a chýbajúce lokálne súbory"
	@grep -RInE '\]\(((\.\./|\./)+)[^)#]+/index(\.md)?\)' $(DOCS_DIR) --include "*.md" --include "*.mdx" || echo "  ✓ nič nenašiel"
	@echo
	@grep -Roh '\]\(([^)]+)\)' $(DOCS_DIR) --include "*.md" --include "*.mdx" \
	| sed 's/.*](\(.*\))/\1/' \
	| grep -vE '^(http|https|#|mailto:)' \
	| sort -u \
	| while read -r link; do \
		path="$(DOCS_DIR)/$${link#./}"; \
		if [[ ! -e "$$path" && ! -e "$${path%/}/index.md" ]]; then \
			echo "  ✗ $$link"; \
		fi; \
	done || true
	@echo "DRY-RUN done."

check-links-hard:
	@echo ">>> STRICT: validujem odkazy…"
	$(NPM) run build -- $(BUILD_EXTRA) || { echo "❌ Build failed"; exit 1; }

check-links-fast:
	@echo ">>> STRICT (no-minify): validujem odkazy…"
	$(MAKE) check-links-hard MINIFY=0

check-links-full:
	@echo ">>> FULL CHECK: kontrolujem odkazy v docs + configu + témach"
	@$(MAKE) check-links
	@grep -RIn "to: '/docs" docusaurus.config.ts || true
	@node scripts/check_config_paths.js || true

fix-links:
	@echo ">>> Opravujem odkazy …/index -> …/"
	@$(FIND_MD) -print0 | xargs -0 $(SED_INPLACE) \
	  -e 's#\]\(\.\.\/index\)#](../)#g' \
	  -e 's#\]\(\.\.\/\.\.\/index\)#](./)#g'

# -------------------------
# 🌿 Worktree Deploy – Self-healing + ochrany
# -------------------------

# Alias (nech help sedí)
init-worktree: check-worktree

## check-worktree: overí alebo vytvorí worktree pre $(DEPLOY_BRANCH); opraví ak je rozbitá
check-worktree:
	@if [ -d "$(WORKTREE_DIR)" ]; then \
	  if git -C "$(WORKTREE_DIR)" rev-parse --is-inside-work-tree >/dev/null 2>&1; then \
	    echo "✅ Worktree OK: $(WORKTREE_DIR) → $(DEPLOY_BRANCH)"; \
	  else \
	    echo "⚠️  $(WORKTREE_DIR) existuje, ale nevyzerá ako git worktree. Resetujem…"; \
	    rm -rf "$(WORKTREE_DIR)"; \
	    git worktree prune; \
	    git branch -D $(DEPLOY_BRANCH) 2>/dev/null || true; \
	  fi; \
	fi; \
	if ! git worktree list | grep -q "$(WORKTREE_DIR)"; then \
	  echo "ℹ️  Worktree pre $(DEPLOY_BRANCH) neexistuje. Vytváram…"; \
	  git fetch origin || true; \
	  if git ls-remote --exit-code --heads origin $(DEPLOY_BRANCH) >/dev/null 2>&1; then \
	    git worktree add -B $(DEPLOY_BRANCH) "$(WORKTREE_DIR)" origin/$(DEPLOY_BRANCH); \
	  else \
	    echo "ℹ️  Vetva $(DEPLOY_BRANCH) na remote neexistuje, zakladám lokálne…"; \
	    git branch -f $(DEPLOY_BRANCH) 2>/dev/null || true; \
	    git worktree add "$(WORKTREE_DIR)" $(DEPLOY_BRANCH); \
	    cd "$(WORKTREE_DIR)" && git commit --allow-empty -m "init $(DEPLOY_BRANCH)" && git push -u origin $(DEPLOY_BRANCH); \
	  fi; \
	fi

# Bezpečné kopírovanie buildu – vždy do /docs a len ak je to naozaj git repo
copy-build:
	@if ! git -C "$(WORKTREE_DIR)" rev-parse --is-inside-work-tree >/dev/null 2>&1; then \
	  echo "❌ $(WORKTREE_DIR) nie je git worktree. Spusť: make check-worktree"; \
	  exit 1; \
	fi
	@# Safety guard: never allow empty BUILD_DIR (would expand to "/")
	@if [ -z "$(BUILD_DIR)" ] || [ "$(BUILD_DIR)" = "/" ] || [ ! -d "$(BUILD_DIR)" ]; then \
	  echo "❌ BUILD_DIR is invalid: '$(BUILD_DIR)'. Expected a built folder like 'publishing/docusaurus/build'."; \
	  echo "   Hint: run 'make build' first, or check variable resolution with 'make print-vars'."; \
	  exit 1; \
	fi
	@if [ -z "$(PAGES_DIR)" ]; then \
	  echo "❌ PAGES_DIR is empty – aborting to prevent rsync to root."; \
	  exit 1; \
	fi
	@echo "🔁 rsync: SRC='$(BUILD_DIR)/'  →  DST='$(PAGES_DIR)/'"
	mkdir -p "$(PAGES_DIR)"
	rsync -av --delete \
	  --filter='P .git' \
	  --filter='P .gitignore' \
	  "$(BUILD_DIR)/" "$(PAGES_DIR)/"

commit-deploy:
	@if ! git -C "$(WORKTREE_DIR)" rev-parse --is-inside-work-tree >/dev/null 2>&1; then \
	  echo "❌ $(WORKTREE_DIR) nie je git worktree. Spusť: make check-worktree"; \
	  exit 1; \
	fi
	cd $(WORKTREE_DIR) && git add -A
	# Create a safe, single-line commit message with UTC timestamp; don't fail if nothing to commit
	cd $(WORKTREE_DIR) && bash -lc 'ts=$(date -u +"%Y-%m-%d %H:%M:%S UTC"); git commit -m "Deploy '"$$ts"'"' || echo "⚠️ Žiadne zmeny na commit."
	cd $(WORKTREE_DIR) && git push origin $(DEPLOY_BRANCH)

# Rýchly lokálny deploy
deploy: check-worktree build copy-build commit-deploy

# Plný scenár: kontrola worktree + push main + build + deploy
full-deploy: check-worktree push-main build copy-build commit-deploy
	@echo "🎉 Full deploy úspešný → $(DEPLOY_BRANCH)"

remove-worktree:
	# Bezpečné odpojenie cez git (NEmaž .git ručne!)
	git worktree remove "$(WORKTREE_DIR)" 2>/dev/null || true
	git worktree prune || true

worktree-status:
	@git worktree list
	@echo "----"
	@git -C "$(WORKTREE_DIR)" status -sb || true

## push-main: Bezpečný push mainu
push-main:
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "❌ Máš necommitnuté zmeny na main! Najprv commitni/stashni."; \
		exit 1; \
	fi
	git push origin main
	@echo "✅ main pushnutý."

# -------------------------
# 🧪 Sandbox Commands
# -------------------------
sandbox-from-main:
	@if [ -z "$$name" ]; then echo "Použi: make sandbox-from-main name=<branch>"; exit 1; fi
	git checkout -b $$name main

sandbox-from-worktree:
	@if [ -z "$$name" ] || [ -z "$$base" ]; then echo "Použi: make sandbox-from-worktree name=<branch> base=<branch>"; exit 1; fi
	git checkout -b $$name $$base

# -------------------------
# 📦 Stash Commands
# -------------------------
stash-save:
	@if [ -z "$$m" ]; then echo "Použi: make stash-save m='správa'"; exit 1; fi
	git stash push -m "$$m"

stash-list:
	git stash list

stash-apply:
	@if [ -z "$$id" ]; then echo "Použi: make stash-apply id=<n>"; exit 1; fi
	git stash apply stash@{$$id}

stash-drop:
	@if [ -z "$$id" ]; then echo "Použi: make stash-drop id=<n>"; exit 1; fi
	git stash drop stash@{$$id}

# -------------------------
# 🎯 Restore from History
# -------------------------
# ⚠️ Každý riadok pod targetom MUSÍ začínať TABom (nie medzerami)!
restore-folder:
	@if [ -z "$$commit" ] || [ -z "$$path" ]; then \
		echo "❌ Použi: make restore-folder commit=<hash> path=<folder>"; \
		exit 1; \
	fi
	@git checkout $$commit -- $$path
	@echo "✅ Obnovené: $(path) z commitu $(commit)"
	@git status --short
	@echo "--- Zmenené súbory ---"
	@git diff --stat

restore-file:
	@if [ -z "$$commit" ] || [ -z "$$path" ]; then echo "Použi: make restore-file commit=<hash> path=<file>"; exit 1; fi
	git checkout $$commit -- $$path
	@echo "✅ Obnovené: $(path) z commitu $(commit)"
	@git status --short

restore-path:
	@echo "⚠️  Pozor: recepty v Makefile MÚSIA začínať TABom!"
	@if [ -z "$$commit" ] || [ -z "$$path" ]; then \
		echo "Použi: make restore-path commit=<hash> path=<file-or-dir>"; exit 1; \
	fi
	@echo "🔎 Pred zmenou (diff vs HEAD) pre '$$path':"
	@git diff --name-status -- $$path || true
	@echo "↩️  Obnovujem '$$path' z commitu $$commit…"
	@git checkout $$commit -- $$path
	@echo "✅ Hotovo. Zmenené súbory:"
	@git status --short -- $$path
	@echo "🔎 Po obnove (diff vs HEAD) pre '$$path':"
	@git diff --name-status -- $$path || true
	@echo "💡 Ak je to ono: git add $$path && git commit -m \"restore: $$path from $$commit\""
	@echo "✅ Obnovené: $(path) z commitu $(commit)"

restore-from-stash-file:
	@if [ -z "$(stash)" ] || [ -z "$(file)" ]; then \
		echo "Použi: make restore-from-stash-file stash=stash@{N} file=<path>"; \
		exit 1; \
	fi
	@git restore --source=$(stash) -- $(file)
	@echo "✅ Súbor '$(file)' obnovený zo stasha '$(stash)'"
	@git status --short

# -------------------------
# 🧹 Delete legacy MkDocs .pages
# -------------------------
delete-dotpages:
	@echo ">>> Odstraňujem všetky '.pages' súbory..."
	@find . -type f -name ".pages" -exec rm -f {} +
	@echo "✅ Hotovo. Súbory '.pages' boli zmazané."
	@echo "💡 Commitni: git add -A && git commit -m 'Remove .pages files'"

# -------------------------
# ⚙️ GitHub Actions – enable/disable by renaming workflow file
# -------------------------
WF_DIR := .github/workflows
WF_FILE := $(WF_DIR)/deploy.yml
WF_DISABLED := $(WF_FILE).disabled

actions-status:
	@if [ -f "$(WF_FILE)" ]; then \
	  echo "Actions workflow: ENABLED ($(WF_FILE))"; \
	elif [ -f "$(WF_DISABLED)" ]; then \
	  echo "Actions workflow: DISABLED ($(WF_DISABLED))"; \
	else \
	  echo "Actions workflow: NOT FOUND"; \
	fi

actions-disable:
	@mkdir -p $(WF_DIR)
	@if [ -f "$(WF_FILE)" ]; then \
	  mv "$(WF_FILE)" "$(WF_DISABLED)"; \
	  git add -A && git commit -m "ci: disable Actions deploy [noactions]" || true; \
	  echo "✅ Actions deaktivované (workflow súbor premenovaný)."; \
	else \
	  echo "ℹ️ Actions už vyzerá byť vypnuté (nenašiel som $(WF_FILE))."; \
	fi

actions-enable:
	@if [ -f "$(WF_DISABLED)" ]; then \
	  mv "$(WF_DISABLED)" "$(WF_FILE)"; \
	  git add -A && git commit -m "ci: enable Actions deploy"; \
	  echo "✅ Actions aktivované (workflow súbor obnovený)."; \
	else \
	  echo "ℹ️ Actions už vyzerá byť zapnuté (nenašiel som $(WF_DISABLED))."; \
	fi

# -------------------------
# 🧭 UX helpers
# -------------------------

quickstart:
	@echo "👋 Ahoj! Najčastejší denný flow:"
	@echo "  1) Uprav docs:          (napr. docs/sk/...)"
	@echo "  2) Lokálny test:        make dev   # alebo: make build && make serve"
	@echo "  3) Deployment:"
	@echo "     - Worktree:          make full-deploy"
	@echo "     - Actions (CI/CD):   git add -A && git commit -m 'msg' && git push"
	@echo ""
	@echo "ℹ️  Tipy:"
	@echo "  • PUSH bez CI:          commit msg obsahuje [noactions]"
	@echo "  • Prepínať Actions:     make actions-enable | make actions-disable"
	@echo "  • Zisti režim:          make mode"

mode:
	@echo "🔎 Režim nasadenia:"
	@if [ -d "$(WORKTREE_DIR)/.git" ]; then \
	  echo "  • Worktree:   ENABLED  → $(WORKTREE_DIR)"; \
	else \
	  echo "  • Worktree:   disabled (spusť: make check-worktree)"; \
	fi
	@if [ -f ".github/workflows/deploy.yml" ]; then \
	  echo "  • Actions:    ENABLED  (CI/CD beží na push)"; \
	elif [ -f ".github/workflows/deploy.yml.disabled" ]; then \
	  echo "  • Actions:    disabled (zapni: make actions-enable)"; \
	else \
	  echo "  • Actions:    nenašiel som workflow súbor (.github/workflows/deploy.yml)"; \
	fi
	@echo ""
	@echo "🧠 Odporúčanie:"
	@if [ -d "$(WORKTREE_DIR)/.git" ]; then \
	  echo "  • Pre okamžitý manual deploy použi: make full-deploy"; \
	else \
	  echo "  • Najprv vytvor worktree: make check-worktree (ak chceš Cestu 1)"; \
	fi
	@echo "  • Alebo použi CI/CD: commit + push (Cesta 2)."

doctor:
	@echo "🩺 Diagnostika…"
	@echo "  • Node: $$(node -v 2>/dev/null || echo 'n/a')"
	@echo "  • NPM:  $$(npm -v 2>/dev/null || echo 'n/a')"
	@echo "  • Git:  $$(git --version 2>/dev/null || echo 'n/a')"
	@echo "  • Remote origin: $$(git remote -v | awk 'NR==1{print $$2}')"
	@echo "  • Aktuálna vetva: $$(git rev-parse --abbrev-ref HEAD)"
	@if [ -d "$(WORKTREE_DIR)/.git" ]; then \
	  echo "  • Worktree: OK  ($(WORKTREE_DIR))"; \
	else \
	  echo "  • Worktree: MISSING (spusť: make check-worktree)"; \
	fi
	@if [ -f ".github/workflows/deploy.yml" ]; then \
	  echo "  • Actions:  ENABLED"; \
	elif [ -f ".github/workflows/deploy.yml.disabled" ]; then \
	  echo "  • Actions:  disabled (make actions-enable)"; \
	else \
	  echo "  • Actions:  workflow chýba (.github/workflows/deploy.yml)"; \
	fi
	@echo "✅ Done."

next-steps:
	@echo "🤖 Navrhovaný ďalší krok:"
	@if [ -d "$(WORKTREE_DIR)/.git" ]; then \
	  echo "  → make full-deploy   # skompiluje + skopíruje do worktree + pushne"; \
	else \
	  if [ -f ".github/workflows/deploy.yml" ]; then \
	    echo "  → git add -A && git commit -m 'update' && git push   # spustí CI/CD"; \
	  else \
	    echo "  → Spusti najprv: make check-worktree  (alebo zapni Actions)"; \
	  fi; \
	fi
	@echo "💡 Debug: make mode | make doctor"

# -------------------------
# 🧩 KNIFES generator (CSV → MD)
# -------------------------

## knifes-gen: CSV -> MD (prehľady + chýbajúce Kxxx súbory)
knifes-gen:
	@if [ ! -f "$(SCRIPTS_DIR)/knifes-build.mjs" ]; then \
		echo "❌ Chýba $(SCRIPTS_DIR)/knifes-build.mjs – skopíruj scripts/ do koreňa repozitára."; exit 1; \
	fi
	@if [ ! -f "$(strip $(CSV_OVERVIEW))" ]; then \
		echo "❌ Chýba CSV '$(strip $(CSV_OVERVIEW))'. Ulož export z Calc/Excel alebo použi: make knifes-gen csv=<path>"; \
		echo "   Príklad: make knifes-gen csv=$(CSV_DEFAULT)"; exit 1; \
	fi
	@CSV="$(csv)"; if [ -z "$$CSV" ]; then CSV="$(strip $(CSV_OVERVIEW))"; fi; \
	node "$(SCRIPTS_DIR)/knifes-build.mjs" --csv "$$CSV" --root .

## knifes-new: založí skeleton KNIFE
## Použitie: make knifes-new id=K000062 title="My Topic"
knifes-new:
	@if [ -z "$(id)" ]; then echo "Použi: make knifes-new id=K000062 title='Názov'"; exit 1; fi
	@if [ ! -f "$(SCRIPTS_DIR)/new_knife.mjs" ]; then \
		echo "❌ Chýba $(SCRIPTS_DIR)/new_knife.mjs – skopíruj scripts/ do koreňa repozitára."; exit 1; \
	fi
	@FOLDER="docs/sk/knifes/$$(echo $(id) | tr 'A-Z' 'a-z')-*"; \
	if compgen -G "$$FOLDER" > /dev/null; then \
		echo "❌ KNIFE priečinok pre $(id) už existuje ($$FOLDER). Ukončujem."; exit 1; \
	fi
	@TITLE="$(title)"; if [ -z "$$TITLE" ]; then TITLE="New Topic"; fi; \
	node "$(SCRIPTS_DIR)/new_knife.mjs" "$(id)" "$$TITLE"

## Kombinované príkazy
dev-gen:
	node scripts/knifes-build.mjs --csv $(CSV_DEFAULT) --root . --locale sk

build-gen: knifes-gen build

## Len suchý plán generovania (nič sa nezapisuje)
gen-dry:
	@CSV="$(csv)"; if [ -z "$$CSV" ]; then CSV="$(strip $(CSV_OVERVIEW))"; fi; \
	node "$(SCRIPTS_DIR)/knifes-build.mjs" --csv "$$CSV" --root . --dry-run


## Dry-verify priamo cez generátor
dry-verify:
	@CSV="$(csv)"; if [ -z "$$CSV" ]; then CSV="$(strip $(CSV_OVERVIEW))"; fi; \
	node "$(SCRIPTS_DIR)/knifes-build.mjs" --csv "$$CSV" --root . --dry-verify

# -------------------------
# 🧵 KNIFE Finish (one-button flow)
# -------------------------
.PHONY: knifes-finish knifes-finish-dry

## knifes-finish-dry: suchý náhľad krokov (bez zápisu)
knifes-finish-dry:
	@echo "① FM podsúbory – DRY"
	@$(MAKE) knifes-fm-add-missing-dry
	@echo "② Verify (CSV/docs + FM)"
	@$(MAKE) knifes-verify
	@echo "③ Gen-dry (CSV → plán)"
	@$(MAKE) gen-dry

## knifes-finish: FM podsúbory -> backfill -> canonical fix -> verify -> gen
knifes-finish:
	@echo "① FM podsúbory – dopĺňam…"
	@$(MAKE) knifes-fm-add-missing
	@echo "② Backfill GUID/DAO…"
	@$(MAKE) knifes-guid-backfill
	@echo "③ Backfill meta (created/modified/category/type/priority)…"
	@$(MAKE) knifes-meta-backfill
	@echo "④ Canonical frontmatter (fm-fix)…"
	@$(MAKE) fm-fix
	@echo "⑤ Verify (CSV/docs + FM)…"
	@$(MAKE) knifes-verify
	@echo "⑥ Generate overviews (CSV → MD)…"
	@$(MAKE) knifes-gen
	@echo "✅ KNIFE finish hotový. Pokračuj: 'make dev' alebo 'make build'"

# -------------------------
# ✅ Backfill & Verify
# -------------------------

# 1) Doplní guid + dao, nechýbajúce iba
knifes-guid-backfill:
	python3 tools/guid_backfill.py docs

# 2) Backfill z CSV (created, category, type, priority, atď.)
#    - nastaví modified==created, ak modified chýba
knifes-meta-backfill:
	@echo "ℹ️  Používam CSV: $(strip $(CSV_BACKFILL))"
	@test -f "$(strip $(CSV_BACKFILL))" || (echo "❌ Chýba CSV '$(strip $(CSV_BACKFILL))'. Zadaj: make knifes-meta-backfill CSV_BACKFILL=path/to.csv"; exit 1)
	@python3 tools/knife_backfill_from_csv.py "$(strip $(CSV_BACKFILL))" docs

# 3a) CSV/docs konzistencia (duplicitné ID, prázdne názvy, kolízie slugov)
## knifes-verify-csv-docs: skontroluje CSV + docs (duplicitné ID, prázdne Short Title, kolízie slugov)
knifes-verify-csv-docs:
	@echo "🔎 Kontrolujem KNIFES CSV a docs..."
	@if [ ! -f "$(strip $(CSV_OVERVIEW))" ] && [ -z "$(strip $(CSV_BACKFILL))" ]; then \
		echo "❌ Chýba CSV '$(strip $(CSV_OVERVIEW))' (alebo zadaj CSV_BACKFILL=...)"; exit 1; \
	fi
	@CSV="$(strip $(CSV_BACKFILL))"; if [ -z "$$CSV" ]; then CSV="$(strip $(CSV_OVERVIEW))"; fi; \
	echo "→ Duplicitné ID v CSV:"; \
	cut -d',' -f1 "$$CSV" | grep -E '^K[0-9]{3}' | sort | uniq -d || echo "  ✓ nič nenašiel"; \
	echo "→ Prázdne názvy v CSV:"; \
	awk -F',' 'NR>1 && $$3=="" {print $$1}' "$$CSV" || echo "  ✓ nič nenašiel"; \
	echo "→ Kolízie slugov v docs/sk/knifes:"; \
	find docs/sk/knifes -type f -name "*.md" -exec grep -H "^slug:" {} \; | cut -d':' -f2- | sort | uniq -d || echo "  ✓ nič nenašiel"; \
	echo "✅ knifes-verify-csv-docs hotovo."

# 3b) Lint povinných polí vo frontmatteri

## knifes-verify-frontmatter: lint povinných polí len pre KNIFE index.md (podľa folderov)
knifes-verify-frontmatter:
	@echo "🔎 Kontrolujem KNIFE frontmatter (iba index.md)…"
	@find docs/sk/knifes -name index.md -print0 \
	| xargs -0 -n1 -I {} python3 tools/frontmatter_lint.py --file "{}" \
	  --required guid dao id title created modified \
	  --id-pattern '^K[0-9]{6}$'
	@if [ -d "docs/en/knifes" ]; then \
	  find docs/en/knifes -name index.md -print0 \
	  | xargs -0 -n1 -I {} python3 tools/frontmatter_lint.py --file "{}" \
	    --required guid dao id title created modified \
	    --id-pattern '^K[0-9]{6}$'; \
	fi
# 3) Kombinovaný alias
## knifes-verify-smart: konfiguračne riadená verifikácia CSV/docs
knifes-verify-smart:
	@CSV_ARG="$(strip $(CSV_OVERVIEW))"; \
	LOCALE_ARG="sk"; \
	SECTION_ARG="knifes"; \
	DOCS_DIR_ARG="$(strip $(DOCS_DIR))"; \
	if [ -f "$(CONFIG_JSON)" ]; then \
	  CSV_FROM_CFG=$$(node -p "try{require('./$(CONFIG_JSON)').csv || ''}catch(e){''}"); \
	  if [ -n "$$CSV_FROM_CFG" ]; then CSV_ARG="$$CSV_FROM_CFG"; fi; \
	  LOCALE_FROM_CFG=$$(node -p "try{require('./$(CONFIG_JSON)').locale || ''}catch(e){''}"); \
	  if [ -n "$$LOCALE_FROM_CFG" ]; then LOCALE_ARG="$$LOCALE_FROM_CFG"; fi; \
	  SECTION_FROM_CFG=$$(node -p "try{require('./$(CONFIG_JSON)').section || ''}catch(e){''}"); \
	  if [ -n "$$SECTION_FROM_CFG" ]; then SECTION_ARG="$$SECTION_FROM_CFG"; fi; \
	  DOCS_FROM_CFG=$$(node -p "try{require('./$(CONFIG_JSON)').docsDir || ''}catch(e){''}"); \
	  if [ -n "$$DOCS_FROM_CFG" ]; then DOCS_DIR_ARG="$$DOCS_FROM_CFG"; fi; \
	fi; \
	echo "CSV=$$CSV_ARG | locale=$$LOCALE_ARG | section=$$SECTION_ARG | docsDir=$$DOCS_DIR_ARG"; \
	node scripts/knifes-verify.mjs --csv "$$CSV_ARG" --root . --locale "$$LOCALE_ARG" --section "$$SECTION_ARG" --docs-dir "$$DOCS_DIR_ARG"

## knifes-verify: spustí oba checky (CSV/docs + frontmatter + smart)
knifes-verify: knifes-verify-csv-docs knifes-verify-frontmatter knifes-verify-smart
	@echo "✅ All KNIFE verifications passed."

# Debug: vypíš kľúčové premenné (na odhalenie whitespace/chybných ciest)
.PHONY: print-vars
print-vars:
	@echo "[CSV_DEFAULT]  = '$(strip $(CSV_DEFAULT))'"
	@echo "[CSV_OVERVIEW] = '$(strip $(CSV_OVERVIEW))'"
	@echo "[CSV_BACKFILL] = '$(strip $(CSV_BACKFILL))'"
	@echo "[DOCS_DIR]     = '$(strip $(DOCS_DIR))'"
	@echo "[SCRIPTS_DIR]  = '$(strip $(SCRIPTS_DIR))'"
	@echo "[CONFIG_JSON] = '$(strip $(CONFIG_JSON))'"
	@node -e "try{const c=require('./$(CONFIG_JSON)');console.log('[CONFIG.csv]  = \\''+(c.csv||'')+'\\'')}catch(e){console.log('[CONFIG.csv]  = <not found>')}"

knifes-validate-csv:
	node dev/csv/knifes-csv-verify.mjs $(CSV_DEFAULT) --schema dev/csv/schema/header.aliases.json || \
	( echo "❌ CSV validation failed – fix ODS or update dev/csv/schema/header.aliases.json"; exit 1 )

knifes-build-safe:
	@$(MAKE) knifes-validate-csv
	node scripts/knifes-build.mjs --csv $(CSV_DEFAULT) --root . --locale sk

knifes-audit-frontmatter:
	node scripts/knifes-frontmatter-audit.mjs docs/sk/knifes	

# -------------------------
# 🧩 KNIFE FM Fix – reálny opravný nástroj (replaces audit)
# -------------------------
.PHONY: knife-fm-dry knife-fm-fix knife-header-check knife-csv-fix knife-fm-report-id knife-fm-report-tree

## knife-fm-dry: DRY-RUN normalizácie Front Matter (nič nezapisuje)
knife-fm-dry:
	@echo "🧪 DRY-RUN: normalizujem Front Matter v $(DOCS_DIR)/ (len report, bez zápisu)…"
	@node scripts/knifes-frontmatter-fix.mjs --config $(CONFIG_JSON) --dry

## knife-fm-fix: Aplikuj normalizáciu Front Matter (zapíše zmeny)
knife-fm-fix:
	@echo "🛠  APPLY: normalizujem Front Matter v $(DOCS_DIR)/ (zapíšem zmeny)…"
	@node scripts/knifes-frontmatter-fix.mjs --config $(CONFIG_JSON) --apply

## knife-fm-apply: Alias na APPLY normalizáciu Front Matter
knife-fm-apply:
	@echo "🛠  APPLY (alias): normalizujem Front Matter v $(DOCS_DIR)/ …"
	@node scripts/knifes-frontmatter-fix.mjs --config $(CONFIG_JSON) --apply

## knife-header-check: Skontroluj technickú hlavičku obsahu (H1 po FM)
knife-header-check:
	@echo "🔎 Auditujem technickú hlavičku (H1 po FM) – read-only…"
	@node scripts/knifes-frontmatter-audit.mjs "$(DOCS_DIR)/sk/knifes"

## knife-csv-fix: Spusti pôvodný CSV/folder fix (bez úprav obsahu .md)
knife-csv-fix:
	@echo "🧩 CSV/folder fix → použijem knifes-frontmatter-fix.mjs (legacy alias)…"
	@node scripts/knifes-frontmatter-fix.mjs --config $(CONFIG_JSON) --apply

## knife-fm-report-id: Report pre konkrétne ID (detailné FM zmeny), použitie: make knife-fm-report-id id=K000059
knife-fm-report-id:
	@if [ -z "$(id)" ]; then \
		echo "❌ Chýba parameter: id=KXXX"; \
		echo "   Použitie: make knife-fm-report-id id=K000059"; \
		exit 2; \
	fi
	@echo "────────────────────────────────────────────────────────"
	@echo "📋 KNIFE FM REPORT – detailné plánované zmeny"
	@echo "   ID: $(id)"
	@echo "   Config: $(CONFIG_JSON)"
	@echo "────────────────────────────────────────────────────────"
	@echo "ℹ️  Tento report NIČ NEZAPISUJE. Slúži na review pred apply."
	@echo "   Tip: Ak chceš vidieť celý rozsah zmien v repo, použi: make knife-fm-dry"
	@echo "────────────────────────────────────────────────────────"
	@node scripts/knifes-frontmatter-fix.mjs --config $(CONFIG_JSON) --dry --id $(id)
	@ec=$$?; \
	echo "────────────────────────────────────────────────────────"; \
	if [ $$ec -eq 0 ]; then \
	  echo "✅ Report hotový. Ak je všetko OK pre celé repo → make knife-fm-fix"; \
	else \
	  echo "⚠️  Skript vrátil exit-code $$ec (pozri log vyššie)."; \
	fi

## knife-fm-report-tree: Report pre celú zložku KNIFE (ID-tree), použitie: make knife-fm-report-tree id=K000083
knife-fm-report-tree:
	@if [ -z "$(id)" ]; then \
		echo "❌ Chýba parameter: id=KXXX"; \
		echo "   Použitie: make knife-fm-report-tree id=K000083"; \
		exit 2; \
	fi
	@echo "────────────────────────────────────────────────────────"
	@echo "📋 KNIFE FM TREE REPORT – detailné plánované zmeny pre celú zložku ID=$(id)"
	@echo "   Config: $(CONFIG_JSON)"
	@echo "────────────────────────────────────────────────────────"
	@echo "ℹ️  Tento report NIČ NEZAPISUJE. Slúži na review pred apply."
	@node scripts/knifes-frontmatter-audit.mjs "$(DOCS_DIR)/sk/knifes"
	@ec=$$?; \
	echo "────────────────────────────────────────────────────────"; \
	if [ $$ec -eq 0 ]; then \
	  echo "✅ Tree report hotový. Ak je všetko OK → make knife-fm-fix"; \
	else \
	  echo "⚠️  Skript vrátil exit-code $$ec (pozri log vyššie)."; \
	fi

# -------------------------
# 📝 Frontmatter Tools
# -------------------------

## fm-fix: Prejde celý docs/ a zakomentuje 'slug' (bez zápisu konkrétnej hodnoty)
fm-fix:
	@python3 tools/fix_frontmatter.py --root $(DOCS_DIR)

## fm-fix-dry: DRY-RUN náhľad zmien (vypíše unified diff), nič nezapisuje
fm-fix-dry:
	@python3 tools/fix_frontmatter.py --root $(DOCS_DIR) --dry-run

## fm-fix-file: Prepíše frontmatter iba jedného súboru (vyžaduje file=PATH)
fm-fix-file:
	@if [ -z "$$file" ]; then echo "Použi: make fm-fix-file file=PATH"; exit 1; fi
	@python3 tools/fix_frontmatter.py --file "$$file"

## fm-fix-file-dry: DRY-RUN iba pre jeden súbor (vyžaduje file=PATH)
fm-fix-file-dry:
	@if [ -z "$$file" ]; then echo "Použi: make fm-fix-file-dry file=PATH"; exit 1; fi
	@python3 tools/fix_frontmatter.py --file "$$file" --dry-run


## fm-set-slug-file: Zapíše aktívny slug pre jediný súbor (vyžaduje file=PATH a slug=/cesta)
fm-set-slug-file:
	@if [ -z "$$file" ] || [ -z "$$slug" ]; then echo "Použi: make fm-set-slug-file file=PATH slug=/cesta/bez-locale"; exit 1; fi
	@python3 tools/fix_frontmatter.py --file "$$file" --set-slug --slug-val "$$slug"

# ## knifes-fm-add-missing: doplní YAML frontmatter do .md súborov bez FM (idempotentné)
.PHONY: knifes-fm-add-missing knifes-fm-add-missing-dry

knifes-fm-add-missing:
	@python3 tools/knife_frontmatter_add_missing.py
	@echo "→ Next: make knifes-guid-backfill knifes-meta-backfill fm-fix knifes-verify"

knifes-fm-add-missing-dry:
	@python3 tools/knife_frontmatter_add_missing.py --dry
#
# -------------------------
# 🚀 Release – CI-based (GitHub Actions)
# -------------------------
.PHONY: release-ci
release-ci:
	@echo "🔖 Pripravujem CI release (patch bump + push tag)…"
	@current=$$(node -p "require('./package.json').version"); \
	echo "   Aktuálna verzia: $$current"; \
	npm version patch -m "chore(release): %s"; \
	git push && git push --tags; \
	newv=$$(node -p "require('./package.json').version"); \
	echo "✅ Pushnutý tag v$$newv – CI workflow sa spustí na serveri";

# Alternatíva: dátumový tag (bez zásahu do package.json)
.PHONY: release-ci-datetime
release-ci-datetime:
	@echo "🔖 Pripravujem CI release (datetime tag)…"
	@ts=$$(date -u '+%Y%m%d-%H%M'); \
	TAG="v$$ts"; \
	echo "   Tag: $$TAG (UTC)"; \
	git tag -a "$$TAG" -m "release $$ts"; \
	git push origin "$$TAG"; \
#	echo "✅ Pushnutý tag $$TAG – CI workflow sa spustí na serveri";

# -------------------------
# 🏷️ Release helpers – local tag & push
# -------------------------

.PHONY: check-version commit push tag push-tag release release-auto release-commit

check-version: ## Overí formát verzie (musí začínať na 'v')
	@printf '%s' "$(VERSION)" | grep -Eq '^v[0-9A-Za-z._-]+$$' \
	|| (echo "❌ VERSION musí začínať na 'v' (napr. v1.0.0 alebo v20250926-0745)" && exit 1)

commit: ## Commit všetkých zmien s COMMIT_MSG
	@test -n "$(COMMIT_MSG)" || (echo "Použi: make commit COMMIT_MSG='Popis'" && exit 1)
	git add -A
	git commit -m "$(COMMIT_MSG)"

push: ## Push aktuálnej vetvy
	git push origin $(BRANCH)

tag: check-version ## Vytvorí annotated tag lokálne
	git tag -a $(VERSION) -m "$(MSG)"

push-tag: check-version ## Pushne tag na origin
	git push origin $(VERSION)

release: check-version ## Tag -> push tag (spustí GH Action Release)
	@echo "🏷️  Tagging $(VERSION) ..."
	$(MAKE) tag VERSION=$(VERSION) MSG="$(MSG)"
	@echo "🚀 Pushing tag $(VERSION) ..."
	$(MAKE) push-tag VERSION=$(VERSION)
	@echo "✅ 🚀 Release $(VERSION) hotový."

release-auto: ## Auto verzia vYYYYMMDD-HHMMSSZ
	$(MAKE) release VERSION=$(VERSION) MSG="$(MSG)"

release-commit: check-version ## Commit -> push -> tag -> push tag
	@test -n "$(MSG)" || (echo "MSG je prázdny. Pridaj MSG='...'" && exit 1)
	@echo "📝 Commit & push na $(BRANCH) ..."
	$(MAKE) commit COMMIT_MSG="$(MSG)" || true
	$(MAKE) push
	@echo "🏷️  Tagging & push tag ..."
	$(MAKE) tag VERSION=$(VERSION) MSG="$(MSG)"
	$(MAKE) push-tag VERSION=$(VERSION)
	@echo "✅ 🚀 Release $(VERSION) hotový."
	
# --- KNIFE automation (config-driven; single point of input = knifes_config.json) ---
.PHONY: knifes-validate knifes-generate knifes-prepare knifes-prepare-strict

knifes-validate:
	@echo "🔎 Validujem KNIFES CSV podľa knifes_config.json"
	@node scripts/knifes-validate.mjs

knifes-prepare-strict:
	@echo "🔎 Validujem KNIFES CSV (strict) podľa knifes_config.json"
	@node scripts/knifes-validate.mjs --strict

knifes-generate:
	@echo "🛠  Generujem KNIFE obsah podľa knifes_config.json"
	@node scripts/knifes-generate.mjs

knifes-prepare: knifes-validate knifes-generate
	@echo "✅ CSV OK → KNIFE vygenerované."

# -------------------------
# 🧾 KNIFES Frontmatter (audit/fix/merge) – scripts placeholders
# -------------------------
#
# -------------------------
# 🧹 FM Sanitation (remove deprecated keys, normalize quotes)
# -------------------------
.PHONY: knifes-datekey-remove-dry knifes-datekey-remove-apply knifes-smartquotes-scan knifes-smartquotes-fix-dry knifes-smartquotes-fix-apply

## knifes-datekey-remove-dry: DRY – remove deprecated 'date:' key from KNIFE index.md
knifes-datekey-remove-dry:
	@echo "🧪 DRY: Removing deprecated 'date:' from KNIFE index.md (no writes)…"
	@if [ ! -f "scripts/knifes-frontmatter-datekey.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-datekey.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-datekey.mjs --config $(CONFIG_JSON) --key date --dry

## knifes-datekey-remove-apply: APPLY – remove deprecated 'date:' key
knifes-datekey-remove-apply:
	@echo "🛠 APPLY: Removing deprecated 'date:' from KNIFE index.md…"
	@if [ ! -f "scripts/knifes-frontmatter-datekey.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-datekey.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-datekey.mjs --config $(CONFIG_JSON) --key date --apply

## knifes-smartquotes-scan: read-only scan for “smart quotes” in all docs
knifes-smartquotes-scan:
	@echo "🔎 SCAN: Hľadám typografické úvodzovky v docs/…"
	@rg -n --pcre2 '[“”‚’]' $(DOCS_DIR) || true

## knifes-smartquotes-fix-dry: DRY – replace smart quotes with straight quotes (no writes)
knifes-smartquotes-fix-dry:
	@echo "🧪 DRY: smart quotes → straight quotes (no writes)…"
	@if [ ! -f "scripts/knifes-frontmatter-quotes.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-quotes.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-quotes.mjs --config $(CONFIG_JSON) --dry

## knifes-smartquotes-fix-apply: APPLY – replace smart quotes with straight quotes (writes)
knifes-smartquotes-fix-apply:
	@echo "🛠 APPLY: smart quotes → straight quotes…"
	@if [ ! -f "scripts/knifes-frontmatter-quotes.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-quotes.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-quotes.mjs --config $(CONFIG_JSON) --apply
.PHONY: knifes-frontmatter-audit knifes-frontmatter-fix-dry knifes-frontmatter-fix-apply knifes-frontmatter-merge

knifes-frontmatter-audit:
	@echo "🔎 Auditujem Front Matter v KNIFE (read-only)…"
	@if [ ! -f "scripts/knifes-frontmatter-audit.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-audit.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-audit.mjs "$(DOCS_DIR)/sk/knifes"

knifes-frontmatter-fix-dry:
	@echo "🧪 DRY-RUN: Front Matter fix (bez zápisu)…"
	@if [ ! -f "scripts/knifes-frontmatter-fix.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-fix.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-fix.mjs --config $(CONFIG_JSON) --dry

knifes-frontmatter-fix-apply:
	@echo "🛠 APPLY: Front Matter fix (zapíše)…"
	@if [ ! -f "scripts/knifes-frontmatter-fix.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-fix.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-fix.mjs --config $(CONFIG_JSON) --apply

knifes-frontmatter-merge:
	@echo "🔗 Merge Front Matter (config-driven)…"
	@if [ ! -f "scripts/knifes-frontmatter-merge.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-merge.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-merge.mjs --config $(CONFIG_JSON) --csv $(CSV_OVERVIEW)

## knifes-frontmatter-audit-id: Audit iba pre jedno KNIFE ID (id=K000059)
.PHONY: knifes-frontmatter-audit-id
knifes-frontmatter-audit-id:
	@if [ -z "$(id)" ]; then echo "Použi: make knifes-frontmatter-audit-id id=K000059"; exit 2; fi
	@echo "🔎 Auditujem Front Matter pre ID=$(id) (read-only)…"
	@if [ ! -f "scripts/knifes-frontmatter-audit.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-audit.mjs"; exit 1; \
	fi
	@# audit podporuje argument root dir; filtrujeme cez id6 prefiks priečinka
	@DIR="$(DOCS_DIR)/sk/knifes/$$(echo $(id) | tr 'A-Z' 'a-z')-*"; \
	if compgen -G "$$DIR" > /dev/null; then \
	  node scripts/knifes-frontmatter-audit.mjs "$$(dirname $$DIR)"; \
	else \
	  echo "❌ Nenašiel som priečinok pre $(id) pod docs/sk/knifes"; exit 1; \
	fi

## knifes-frontmatter-fix-id-dry: DRY-RUN fix iba pre jedno ID
.PHONY: knifes-frontmatter-fix-id-dry
knifes-frontmatter-fix-id-dry:
	@if [ -z "$(id)" ]; then echo "Použi: make knifes-frontmatter-fix-id-dry id=K000059"; exit 2; fi
	@echo "🧪 DRY-RUN: FM fix pre ID=$(id)…"
	@if [ ! -f "scripts/knifes-frontmatter-fix.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-fix.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-fix.mjs --dry --id $(id)

## knifes-frontmatter-fix-id-apply: APPLY fix iba pre jedno ID
.PHONY: knifes-frontmatter-fix-id-apply
knifes-frontmatter-fix-id-apply:
	@if [ -z "$(id)" ]; then echo "Použi: make knifes-frontmatter-fix-id-apply id=K000059"; exit 2; fi
	@echo "🛠 APPLY: FM fix pre ID=$(id)…"
	@if [ ! -f "scripts/knifes-frontmatter-fix.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-fix.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-fix.mjs --apply --id $(id)

# -------------------------
# 🔗 Slug tools (report/comment/delete) – separate script
# -------------------------
.PHONY: knifes-frontmatter-slug-report knifes-frontmatter-slug-comment-dry knifes-frontmatter-slug-comment-apply knifes-frontmatter-slug-delete-dry knifes-frontmatter-slug-delete-apply

knifes-frontmatter-slug-report:
	@echo "🔎 SLUG REPORT (id=$(id) scope=$(scope))"
	@if [ ! -f "scripts/knifes-frontmatter-slug.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-slug.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-slug.mjs --config $(CONFIG_JSON) --action report --scope $(if $(scope),$(scope),index) $(if $(id),--id $(id),) --dry

knifes-frontmatter-slug-comment-dry:
	@echo "🧪 DRY: SLUG comment (id=$(id) scope=$(scope))"
	@if [ ! -f "scripts/knifes-frontmatter-slug.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-slug.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-slug.mjs --config $(CONFIG_JSON) --action comment --scope $(if $(scope),$(scope),index) $(if $(id),--id $(id),) --dry

knifes-frontmatter-slug-comment-apply:
	@echo "🛠 APPLY: SLUG comment (id=$(id) scope=$(scope))"
	@if [ ! -f "scripts/knifes-frontmatter-slug.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-slug.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-slug.mjs --config $(CONFIG_JSON) --action comment --scope $(if $(scope),$(scope),index) $(if $(id),--id $(id),) --apply

knifes-frontmatter-slug-delete-dry:
	@echo "🧪 DRY: SLUG delete (id=$(id) scope=$(scope))"
	@if [ ! -f "scripts/knifes-frontmatter-slug.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-slug.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-slug.mjs --config $(CONFIG_JSON) --action delete --scope $(if $(scope),$(scope),index) $(if $(id),--id $(id),) --dry

knifes-frontmatter-slug-delete-apply:
	@echo "🛠 APPLY: SLUG delete (id=$(id) scope=$(scope))"
	@if [ ! -f "scripts/knifes-frontmatter-slug.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-slug.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-slug.mjs --config $(CONFIG_JSON) --action delete --scope $(if $(scope),$(scope),index) $(if $(id),--id $(id),) --apply

# -------------------------
# 🔢 KNIFE ID6 Migration (K### → K######) – separate script
# -------------------------
.PHONY: knifes-id6-dry knifes-id6-apply knifes-id6-audit

knifes-id6-dry:
	@echo "🧪 DRY-RUN: ID6 migration (id=$(id))"
	@if [ ! -f "scripts/knifes-frontmatter-id6.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-id6.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-id6.mjs --config $(CONFIG_JSON) --dry $(if $(id),--id $(id),)

knifes-id6-apply:
	@echo "🛠 APPLY: ID6 migration (id=$(id))"
	@if [ ! -f "scripts/knifes-frontmatter-id6.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-id6.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-id6.mjs --config $(CONFIG_JSON) --apply $(if $(id),--id $(id),)

knifes-id6-audit:
	@echo "🔍 AUDIT: ID6 migration – post-check"
	@if [ ! -f "scripts/knifes-frontmatter-id6.mjs" ]; then \
	  echo "❌ Chýba scripts/knifes-frontmatter-id6.mjs"; exit 1; \
	fi
	@node scripts/knifes-frontmatter-id6.mjs --config $(CONFIG_JSON) --audit
# -------------------------
# 📐 K18 Baseline – 3-krokový flow (Audit → Fix → Verify)
# -------------------------
.PHONY: k18-audit k18-fix-dry k18-fix-apply k18-verify k18-align-dry k18-align-apply

k18-audit:
	@echo "🔎 K18 AUDIT (read-only)…"
	@if [ ! -f "scripts/knifes-frontmatter-audit.mjs" ]; then echo "❌ Chýba scripts/knifes-frontmatter-audit.mjs"; exit 1; fi
	@node scripts/knifes-frontmatter-audit.mjs "$(DOCS_DIR)/sk/knifes"

k18-fix-dry:
	@echo "🧪 K18 FIX (DRY-RUN)…"
	@if [ ! -f "scripts/knifes-frontmatter-fix.mjs" ]; then echo "❌ Chýba scripts/knifes-frontmatter-fix.mjs"; exit 1; fi
	@node scripts/knifes-frontmatter-fix.mjs --config $(CONFIG_JSON) --dry

k18-fix-apply:
	@echo "🛠 K18 FIX (APPLY)…"
	@if [ ! -f "scripts/knifes-frontmatter-fix.mjs" ]; then echo "❌ Chýba scripts/knifes-frontmatter-fix.mjs"; exit 1; fi
	@node scripts/knifes-frontmatter-fix.mjs --config $(CONFIG_JSON) --apply

k18-verify: k18-audit knifes-verify-frontmatter
	@echo "✅ K18 VERIFY hotovo."

k18-align-dry:
	@$(MAKE) k18-audit
	@$(MAKE) k18-fix-dry
	@$(MAKE) k18-audit
	@echo "🧪 K18 align DRY sekvencia dokončená."

k18-align-apply:
	@$(MAKE) k18-fix-apply
	@$(MAKE) k18-verify
	@echo "🎉 K18 align APPLY sekvencia dokončená."

# -------------------------
# 📚 KNIFES_REF tooling (audit + alignment placeholders)
# -------------------------
.PHONY: knifes-ref-audit knifes-ref-align-dry knifes-ref-align-apply

knifes-ref-audit:
	@echo "🔎 Auditujem KNIFES_REF (read-only)…"
	@if [ ! -f "scripts/knifes-frontmatter-audit.mjs" ]; then echo "❌ Chýba scripts/knifes-frontmatter-audit.mjs"; exit 1; fi
	@node scripts/knifes-frontmatter-audit.mjs "$(KNIFES_REF_DIR)"

knifes-ref-align-dry:
	@echo "🧪 KNIFES_REF align (DRY)…"
	@$(MAKE) knifes-ref-audit
	@echo "ℹ️  Placeholder: sem doplníme DRY fix pre KNIFES_REF (keď bude pripravený)."
	@$(MAKE) knifes-ref-audit
	@echo "🧪 KNIFES_REF align DRY sekvencia dokončená."

knifes-ref-align-apply:
	@echo "🛠 KNIFES_REF align (APPLY)…"
	@echo "ℹ️  Placeholder: sem doplníme APPLY fix pre KNIFES_REF (keď bude pripravený)."
	@$(MAKE) knifes-ref-audit
	@echo "🎉 KNIFES_REF align APPLY sekvencia dokončená."
# -------------------------
# 🧩 KNIFES Gen New (CSV → MD, seed-only, new script)
# -------------------------
.PHONY: knifes-gen-dry knifes-gen-apply

## knifes-gen-dry: DRY-RUN generation (CSV→MD, seed-only)
knifes-gen-dry:
	@KNIFE_CSV="$(KNIFE_CSV)"; if [ -z "$$KNIFE_CSV" ]; then KNIFE_CSV="$(strip $(CSV_OVERVIEW))"; fi; \
	KNIFE_OUT="$(KNIFE_OUT)"; if [ -z "$$KNIFE_OUT" ]; then KNIFE_OUT="docs/sk/knifes"; fi; \
	echo "🧪 [UAT] DRY-RUN generation (CSV→MD, seed-only) [$$(date -u +'%Y-%m-%d %H:%M:%S UTC')] – CSV='$$KNIFE_CSV' OUT='$$KNIFE_OUT'"; \
	node scripts/knifes-gen-new.mjs --csv "$$KNIFE_CSV" --out "$$KNIFE_OUT" --dry-run

## knifes-gen-apply: APPLY generation (CSV→MD, seed-only)
knifes-gen-apply:
	@KNIFE_CSV="$(KNIFE_CSV)"; if [ -z "$$KNIFE_CSV" ]; then KNIFE_CSV="$(strip $(CSV_OVERVIEW))"; fi; \
	KNIFE_OUT="$(KNIFE_OUT)"; if [ -z "$$KNIFE_OUT" ]; then KNIFE_OUT="docs/sk/knifes"; fi; \
	echo "⚙️ [UAT] APPLY generation (CSV→MD, seed-only) [$$(date -u +'%Y-%m-%d %H:%M:%S UTC')] – CSV='$$KNIFE_CSV' OUT='$$KNIFE_OUT'"; \
	node scripts/knifes-gen-new.mjs --csv "$$KNIFE_CSV" --out "$$KNIFE_OUT"


# -------------------------
# 🧾 CSV Scan & Fix (NEW 2025-10-05)
# -------------------------
.PHONY: knifes-csv-scan knifes-fix-csv-dry knifes-fix-csv-apply

## knifes-csv-scan: Scan docs → CSV snapshot (timestamped)
knifes-csv-scan:
	@TS="$$(date -u +'%Y-%m-%d %H:%M:%S UTC')"; \
	echo "🔎 SCAN [$${TS}] → DIR='$(KNIFES_DIR)' OUT='$(OUT_DIR)' CSV_REF='$(strip $(CSV_OVERVIEW))'"; \
	node scripts/knifes-csv-scan.mjs --dir "$(KNIFES_DIR)" --outdir "$(OUT_DIR)" --csv "$(strip $(CSV_OVERVIEW))"

## knifes-fix-csv-dry: DRY-RUN fill-only merge (MD → CSV)
knifes-fix-csv-dry:
	@TS="$$(date -u +'%Y-%m-%d %H:%M:%S UTC')"; \
	echo "🧪 FIX CSV DRY [$${TS}] → IN='$(strip $(CSV_OVERVIEW))' OUTDIR='$(OUT_DIR)'"; \
	node scripts/knifes-fix-csv.mjs --dir "$(KNIFES_DIR)" --csv "$(strip $(CSV_OVERVIEW))" --outdir "$(OUT_DIR)" --dry-run

## knifes-fix-csv-apply: APPLY fill-only merge (MD → CSV) → writes new timestamped file
knifes-fix-csv-apply:
	@TS="$$(date -u +'%Y-%m-%d %H:%M:%S UTC')"; \
	echo "⚙️  FIX CSV APPLY [$${TS}] → IN='$(strip $(CSV_OVERVIEW))' OUTDIR='$(OUT_DIR)'"; \
	node scripts/knifes-fix-csv.mjs --dir "$(KNIFES_DIR)" --csv "$(strip $(CSV_OVERVIEW))" --outdir "$(OUT_DIR)"
# -------------------------
# 📄 Makefile — Docusaurus (minimal, cleaned)
# Date: 20251012
# Purpose: Local dev/build + optional Git worktree deploy to gh-pages-docusaurus
# -------------------------

.DEFAULT_GOAL := help
SHELL := /bin/bash
NODE := node
NPM  := npm

# ---- Paths
CONTENT_DOCS_DIR := content/docs
PUB_DOCUS_DIR    := publishing/docusaurus
PUB_DOCS_DIR     := $(PUB_DOCUS_DIR)/docs
PUB_BUILD_DIR    := $(PUB_DOCUS_DIR)/build

# ---- Worktree Deploy (GitHub Pages /docs mode)
DEPLOY_BRANCH := gh-pages-docusaurus
WORKTREE_DIR  := ../$(DEPLOY_BRANCH)
PAGES_DIR     := $(WORKTREE_DIR)/docs

# ---- Build options
BUILD_DATE := $(shell date -u '+%Y-%m-%d %H:%M:%S UTC')
MINIFY ?= 1
BUILD_EXTRA :=
ifeq ($(MINIFY),0)
  BUILD_EXTRA := --no-minify
endif

# ---- i18n helpers (optional single-locale run)
DS_LOCALE ?=
BUILD_LOCALE_OPT :=
ifneq ($(strip $(DS_LOCALE)),)
  BUILD_LOCALE_OPT := --locale $(DS_LOCALE)
endif

# =========================================================
# H10: Help / Meta
# =========================================================
.PHONY: help mode doctor print-vars
help: ## H10 – Help
	@echo "================  KNIFE Docusaurus – Minimal Makefile  ================"
	@echo "Core:"
	@echo "  SY01-sync-content        – Sync content/docs → publishing/docusaurus/docs"
	@echo "  D10-dev                  – Start local dev server (option: DS_LOCALE=sk|en)"
	@echo "  B10-build                – Production build (MINIFY=$(MINIFY))"
	@echo "  B20-build-fast           – Build without minify (MINIFY=0)"
	@echo "  S10-serve                – Serve static build locally"
	@echo ""
	@echo "Deploy (Git worktree → $(DEPLOY_BRANCH)):"
	@echo "  W10-check-worktree       – Create/repair worktree ../$(DEPLOY_BRANCH)"
	@echo "  W20-copy-build           – Rsync build → $(PAGES_DIR)"
	@echo "  W30-commit-deploy        – Commit & push worktree"
	@echo "  W40-deploy               – W10 + build + copy + commit"
	@echo "  W50-full-deploy          – W10 + push-main + build + copy + commit"
	@echo "  W60-worktree-status      – Show worktree status"
	@echo ""
	@echo "Preview:"
	@echo "  P10-preview              – build + serve (production preview)"
	@echo ""
	@echo "Aliases kept for compatibility: dev/build/build-fast/serve/check-worktree/copy-build/commit-deploy/deploy/full-deploy"
	@echo "======================================================================="

mode: ## H20 – Show deploy mode (worktree availability)
	@echo "🔎 Deploy mode:"
	@if [ -d "$(WORKTREE_DIR)/.git" ]; then echo " • Worktree: ENABLED ($(WORKTREE_DIR))"; else echo " • Worktree: disabled"; fi

doctor: ## H30 – Quick environment diagnostic
	@echo "🩺 Node:  $$(node -v 2>/dev/null || echo n/a)"
	@echo "🩺 NPM:   $$(npm -v 2>/dev/null || echo n/a)"
	@echo "🩺 Git:   $$(git --version 2>/dev/null || echo n/a)"
	@echo "🩺 Origin: $$(git remote -v | awk 'NR==1{print $$2}')"
	@echo "🩺 Branch: $$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo n/a)"

print-vars: ## H40 – Show key variables
	@echo "[CONTENT_DOCS_DIR] = $(CONTENT_DOCS_DIR)"
	@echo "[PUB_DOCUS_DIR]    = $(PUB_DOCUS_DIR)"
	@echo "[PUB_DOCS_DIR]     = $(PUB_DOCS_DIR)"
	@echo "[PUB_BUILD_DIR]    = $(PUB_BUILD_DIR)"
	@echo "[WORKTREE_DIR]     = $(WORKTREE_DIR)"
	@echo "[PAGES_DIR]        = $(PAGES_DIR)"
	@echo "[DS_LOCALE]        = $(DS_LOCALE)"
	@echo "[BUILD_EXTRA]      = $(BUILD_EXTRA)"

# =========================================================
# SY01: Sync content → docusaurus/docs
# =========================================================
.PHONY: SY01-sync-content
SY01-sync-content: ## SY01 – Sync SSOT content/docs → publishing/docusaurus/docs
	@if [ ! -d "$(CONTENT_DOCS_DIR)" ]; then echo "❌ Missing $(CONTENT_DOCS_DIR)"; exit 1; fi
	@mkdir -p "$(PUB_DOCS_DIR)"
	rsync -av --delete --checksum "$(CONTENT_DOCS_DIR)/" "$(PUB_DOCS_DIR)/"
	@echo "✅ Synced: $(CONTENT_DOCS_DIR) → $(PUB_DOCS_DIR)"

# =========================================================
# D10: Dev / Clean / Build / Serve
# =========================================================
.PHONY: D10-dev clean B10-build B20-build-fast S10-serve dev build build-fast serve dev-sk dev-en build-sk build-en

D10-dev: ## D10 – Start dev server
	cd "$(PUB_DOCUS_DIR)" && BUILD_DATE="$(BUILD_DATE)" NODE_OPTIONS=--max-old-space-size=16384 $(NPM) start -- $(BUILD_LOCALE_OPT)

clean: ## C10 – Clean caches and build output
	cd "$(PUB_DOCUS_DIR)" && $(NPM) run clear || true
	rm -rf "$(PUB_BUILD_DIR)" "$(PUB_DOCUS_DIR)/.docusaurus"

B10-build: SY01-sync-content clean ## B10 – Production build
	cd "$(PUB_DOCUS_DIR)" && BUILD_DATE="$(BUILD_DATE)" NODE_OPTIONS=--max-old-space-size=16384 $(NPM) run build -- $(BUILD_EXTRA) $(BUILD_LOCALE_OPT)

B20-build-fast: ## B20 – Build without minify
	$(MAKE) B10-build MINIFY=0

S10-serve: ## S10 – Serve static build
	cd "$(PUB_DOCUS_DIR)" && $(NPM) run serve

# Compatibility aliases
dev: D10-dev
build: B10-build
build-fast: B20-build-fast
serve: S10-serve

# Locale helpers
dev-sk:
	$(MAKE) D10-dev DS_LOCALE=sk
dev-en:
	$(MAKE) D10-dev DS_LOCALE=en
build-sk:
	$(MAKE) B10-build DS_LOCALE=sk
build-en:
	$(MAKE) B10-build DS_LOCALE=en

# =========================================================
# P10: Production preview (build + serve)
# =========================================================
.PHONY: P10-preview
P10-preview: SY01-sync-content ## P10 – Build + Serve (preview)
	cd "$(PUB_DOCUS_DIR)" && $(NPM) run build -- $(BUILD_EXTRA) $(BUILD_LOCALE_OPT)
	cd "$(PUB_DOCUS_DIR)" && $(NPM) run serve

# =========================================================
# W10–W60: Worktree deploy (gh-pages-docusaurus)
# =========================================================
.PHONY: W10-check-worktree W20-copy-build W30-commit-deploy W40-deploy W50-full-deploy W60-worktree-status remove-worktree push-main \
        check-worktree copy-build commit-deploy deploy full-deploy worktree-status

W10-check-worktree: ## W10 – Create/repair worktree
	@if [ -d "$(WORKTREE_DIR)" ]; then \
	  if git -C "$(WORKTREE_DIR)" rev-parse --is-inside-work-tree >/dev/null 2>&1; then \
	    echo "✅ Worktree OK: $(WORKTREE_DIR) → $(DEPLOY_BRANCH)"; \
	  else \
	    echo "⚠️  $(WORKTREE_DIR) exists but isn't a git worktree, resetting…"; \
	    rm -rf "$(WORKTREE_DIR)"; git worktree prune; git branch -D $(DEPLOY_BRANCH) 2>/dev/null || true; \
	  fi; \
	fi; \
	if ! git worktree list | grep -q "$(WORKTREE_DIR)"; then \
	  echo "ℹ️  Creating worktree for $(DEPLOY_BRANCH)…"; \
	  git fetch origin || true; \
	  if git ls-remote --exit-code --heads origin $(DEPLOY_BRANCH) >/dev/null 2>&1; then \
	    git worktree add -B $(DEPLOY_BRANCH) "$(WORKTREE_DIR)" origin/$(DEPLOY_BRANCH); \
	  else \
	    git branch -f $(DEPLOY_BRANCH) 2>/dev/null || true; \
	    git worktree add "$(WORKTREE_DIR)" $(DEPLOY_BRANCH); \
	    cd "$(WORKTREE_DIR)" && git commit --allow-empty -m "init $(DEPLOY_BRANCH)" && git push -u origin $(DEPLOY_BRANCH); \
	  fi; \
	fi

W20-copy-build: ## W20 – Rsync build → /docs
	@if ! git -C "$(WORKTREE_DIR)" rev-parse --is-inside-work-tree >/dev/null 2>&1; then echo "❌ $(WORKTREE_DIR) not a git worktree. Run: make W10-check-worktree"; exit 1; fi
	@if [ -z "$(PUB_BUILD_DIR)" ] || [ ! -d "$(PUB_BUILD_DIR)" ]; then echo "❌ Build not found: $(PUB_BUILD_DIR). Run: make build"; exit 1; fi
	@echo "🔁 rsync: '$(PUB_BUILD_DIR)/' → '$(PAGES_DIR)/'"
	mkdir -p "$(PAGES_DIR)"
	rsync -av --delete --filter='P .git' --filter='P .gitignore' "$(PUB_BUILD_DIR)/" "$(PAGES_DIR)/"

W30-commit-deploy: ## W30 – Commit & push worktree
	@if ! git -C "$(WORKTREE_DIR)" rev-parse --is-inside-work-tree >/dev/null 2>&1; then echo "❌ $(WORKTREE_DIR) not a git worktree. Run: make W10-check-worktree"; exit 1; fi
	cd $(WORKTREE_DIR) && git add -A
	cd $(WORKTREE_DIR) && bash -lc 'ts=$$(date -u +"%Y-%m-%d %H:%M:%S UTC"); git commit -m "Deploy '"'"'$$ts'"'"'' || echo "⚠️ Nothing to commit."'
	cd $(WORKTREE_DIR) && git push origin $(DEPLOY_BRANCH)

W40-deploy: W10-check-worktree B10-build W20-copy-build W30-commit-deploy ## W40 – Build & deploy to worktree

W50-full-deploy: W10-check-worktree push-main B10-build W20-copy-build W30-commit-deploy ## W50 – Push main + build + deploy
	@echo "🎉 Full deploy → $(DEPLOY_BRANCH)"

W60-worktree-status: ## W60 – Show worktree status
	@git worktree list
	@echo "----"
	@git -C "$(WORKTREE_DIR)" status -sb || true

remove-worktree: ## WX – Remove worktree (safe)
	git worktree remove "$(WORKTREE_DIR)" 2>/dev/null || true
	git worktree prune || true

push-main: ## GX – Safe push of main branch
	@if [ -n "$$(git status --porcelain)" ]; then echo "❌ Uncommitted changes on main!"; exit 1; fi
	git push origin main
	@echo "✅ main pushed."

# Compatibility aliases
check-worktree: W10-check-worktree
copy-build:     W20-copy-build
commit-deploy:  W30-commit-deploy
deploy:         W40-deploy
full-deploy:    W50-full-deploy
worktree-status: W60-worktree-status