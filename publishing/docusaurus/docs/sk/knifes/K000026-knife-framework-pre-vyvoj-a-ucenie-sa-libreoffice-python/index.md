---
id: "REF-UAT-001"
guid: "uat-guide-20251005"
dao: "knife"
title: "Postup pre presun zmien z vetvy FIX do UAT"
author: "Roman Kazička"
category: "governance"
type: "user-guide"
priority: "top"
tags: ["GIT", "UAT", "Workflow"]
created: "2025-10-05"
modified: "-"
status: "active"
locale: "sk"
sidebar_label: "Presun zmien z FIX do UAT"
rights_holder_system: "Roman Kazička (CAA/KNIFE/LetItGrow)"
license: "CC-BY-NC-SA-4.0"
disclaimer: "Use at your own risk. Educational purposes only."
---

# 🧭 Postup pre presun zmien z vetvy **FIX** do **UAT**

Tento postup popisuje odporúčaný spôsob, ako presunúť stabilizované zmeny z pracovnej vetvy `fix/*` do testovacej vetvy `UAT`.  
Cieľom je zachovať transparentnosť, možnosť spätnej kontroly a zamedziť nechceným zmenám v produkcii.

---

## 🧩 1. Overenie lokálneho stavu

Pred akoukoľvek akciou sa uisti, že máš všetky zmeny uložené a commitnuté:

```bash
git status
git add .
git commit -m "fix: final UAT preparation"
```

Ak hlási `nothing to commit, working tree clean`, všetko je pripravené.

---

## 🧭 2. Vytvorenie vetvy UAT (ak ešte neexistuje)

Over existenciu vetvy:

```bash
git branch
```

Ak `UAT` chýba, vytvor ju z aktuálneho `main` (alebo `develop` podľa procesu):

```bash
git checkout main
git pull origin main
git checkout -b UAT
git push -u origin UAT
```

---

## 🔀 3. Vytvorenie Pull Requestu z FIX → UAT

1. Prejdi na GitHub repozitár.  
2. Klikni na **Compare & pull request**.  
3. Nastav:
   - **Base branch:** `UAT`
   - **Compare branch:** `fix/fm-stabilize` (alebo tvoja aktuálna fix vetva)
4. Vyplň popis (napr. *„Synchronizácia FM a CSV, testované – pripravené pre UAT.“*).
5. Klikni **Create pull request**.

---

## 🧪 4. Overenie a test v UAT

Po merge do `UAT`:

```bash
git checkout UAT
git pull origin UAT
make verify
make knifes-gen-dry
```

✅ Over, že:
- sa všetky KNIFE súbory generujú správne,
- CSV zodpovedá realite,
- nevznikli nové GUIDy bez dôvodu.

---

## 🚀 5. Príprava na merge do MAIN (produkcia)

Keď je `UAT` overený:

```bash
git checkout main
git pull origin main
git merge --no-ff UAT -m "merge: verified UAT → main"
git push origin main
```

---

## 🧾 6. Poznámky a odporúčania

- `FIX` = technické úpravy a ladenie  
- `UAT` = testovanie a validácia  
- `MAIN` = produkčný obsah

Každá vetva má svoj účel – nikdy nerob úpravy priamo v `UAT` alebo `MAIN`.  
Ak potrebuješ opraviť drobnosti, vytvor novú `fix/*` vetvu a znova ju pošli cez PR.

---

## 📦 7. Odporúčané príkazy pre opakovanie

```bash
make csv-guid-sync-dry
make knifes-csv-scan
make knifes-gen-dry
```

Tieto príkazy pomáhajú overiť, že všetky KNIFE majú správne GUID, FM a väzby pred prenosom.

---

> 💡 **Tip:** Ak chceš dať študentom tento proces ako cvičenie, pridaj ho do `docs/sk/ref/UAT-Promotion-Guide.md`  
> alebo ako úlohu v `GitDocs-Lab` template s parametrom `branch: fix → UAT`.
