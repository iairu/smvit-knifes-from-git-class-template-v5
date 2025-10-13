---
id: "K000083_03"
guid: "666c06de-ec54-45cd-be1a-38b0333809e2"
dao: "knife"
title: "KNIFE – K000083_03"
description: "-"
author: "Roman Kazička"
authors: ["Roman Kazička"]
category: "deliverable"
type: "knife"
priority: "-"
tags: ["-"]
created: "2025-09-26"
modified: "2025-09-26"
status: "draft"
locale: "sk"
sidebar_label: "K000083_03 –"
rights_holder_content: "Roman Kazička"
rights_holder_system: "Roman Kazička (CAA/KNIFE/LetItGrow)"
license: "CC-BY-NC-SA-4.0"
disclaimer: "Educational content. Use at your own risk."
copyright: "© 2025 Roman Kazička / SystemThinking"
author_id: "-"
author_did: "-"
---
# Študentský checklist
<!-- fm-visible: start -->

> **GUID:** `"666c06de-ec54-45cd-be1a-38b0333809e2"`
>   
> **Category:** `deliverable` · **Type:** `knife` · **Status:** `draft` · **Author:** "" · **License:** "CC-BY-NC-SA-4.0"
<!-- fm-visible: end -->


## Čo nikdy nerobiť
- ❌ Neupgradovať balíky (`npm update`, `ncu`, …).
- ❌ Nemeň `package.json`/`package-lock.json`.

## Rýchly štart
1) Nastav Node **v22** (pozri `SETUP.md`).
2) Inštaluj závislosti:
```bash
npm ci
```
3) Spusti dev server:
```bash
make dev
```
4) Pri commite upravuj len obsah (MD, obrázky).

## Kontrola KNIFE (ak je k dispozícii)
```bash
make knife-validate
```
