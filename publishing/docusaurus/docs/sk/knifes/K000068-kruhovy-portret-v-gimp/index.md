---
id: "K000"
guid: "bfb1bccf-cf2c-4d8a-bc29-c00c6b7e1b8e"
dao: "knife"
title: "Kruhový portrét v GIMP"
description: "Pri publikovaní na Web potrebujem kruhový formát obrázkov. Najjednoduchšie je použiť GIMP. Práca na 5 minút"
author: "Roman Kazicka"
created: "2025-09-17"
modified: "2025-09-17"
date: "2025-09-17"
status: "backlog"
tags: ["KNIFE", "images"]
# slug: "/sk/knifes/k000-kruhovy-portret-v-gimp"
sidebar_label: "K000068 – Kruhový portrét v GIMP"
sidebar_position: "68"
locale: "sk"
---
<!-- body:start -->

<!-- fm-visible: start -->
> **GUID:** `bfb1bccf-cf2c-4d8a-bc29-c00c6b7e1b8e`
> **Status:** `new` · **Author:** Roman Kazicka · **License:** CC-BY-NC-SA-4.0
<!-- fm-visible: end -->
<!-- body:start -->

<!-- fm-visible: start -->
> **GUID:** `bfb1bccf-cf2c-4d8a-bc29-c00c6b7e1b8e`
> **Status:** `new` · **Author:** Roman Kazicka
<!-- fm-visible: end -->
<!-- body:start -->

<!-- fm-visible: start -->
> **GUID:** `bfb1bccf-cf2c-4d8a-bc29-c00c6b7e1b8e`
> **Status:** `new` · **Author:** Roman Kazicka
<!-- fm-visible: end -->
<!-- body:start -->

<!-- nav:knifes -->
> [⬅ KNIFES – Prehľad](../overview.md) • [Zoznam](../KNIFE_Overview_List.md) • [Detaily](../KNIFE_Overview_Details.md)
---

# K000068 – Ako urobiť kruhový portrét s transparentným pozadím a efektom
<!-- fm-visible: start -->

> **GUID:** `"bfb1bccf-cf2c-4d8a-bc29-c00c6b7e1b8e"`
>   
> **Category:** `""` · **Type:** `""` · **Status:** `"new"` · **Author:** "Roman Kazicka" · **License:** "CC-BY-NC-SA-4.0"
<!-- fm-visible: end -->


**Category**: Vizualizácia / Tooling  
**Status**: hotové  
**Type**: Praktický tip  
**Priority**: 🎯  
**Date**: 2025-09-05  

---

## 🎯 Cieľ
Vytvoriť kruhový portrét (napr. profilová fotka) s priehľadným pozadím a prípadne doplnkovým efektom (tieň, rámik), použiteľný v XMind, prezentáciách alebo dokumentácii.

---

## 🛠️ Postup v GIMP

### 1. Príprava obrázka
- Otvor portrét v **GIMP**.  
- V menu: `Layer → Transparency → Add Alpha Channel` (ak je sivé, už máš alpha).  
- 
![Nastavenie transparentnosti](./img/02-see-transparency-alpha.png)
### 2. Kruhový výber
- Vyber nástroj **Ellipse Select**.  
- Podrž **Shift** (aby bol dokonalý kruh).  
- Myšou vytiahni výber okolo tváre.  
- Potom: `Select → Invert` a stlač **Delete** → pozadie sa vymaže.  
  
![Vyber 'Invert'](./img/05-select-invert.png)

- Vidíš šachovnicu (checkerboard) → to je transparentnosť.  

![Vybranie kruhu](./img/01-menu-Select-elipse.png)

### 3. Orezanie
- `Image → Crop to Content` (odstráni nadbytočný priestor).  

### 4. Pridanie tieňa
- Menu: `Filters → Light and Shadow → Drop Shadow`.  
- Nastav:  
  - Offset X/Y: 5–10 px  
  - Blur radius: 20–30 px  
  - Opacity: 40–60 %  
- Potvrď → fotka dostane jemný tieň.  

![Pridanie tieňa](./img/03-drop-shadow.png)

### 5. (Voliteľne) Farebný rámik
- `Select → Grow` (napr. o 10 px).  
- Vytvor novú vrstvu pod obrázkom.  
- `Edit → Stroke Selection` → nastav hrúbku a farbu (napr. tmavomodrá).  

![Pridanie farebného rámiku](./img/04-stroke-selection-line.png)

### 6. Export
- `File → Export As → PNG`.  
- Transparentnosť sa zachová, ak má obrázok alpha channel a pozadie je vymazané.  
![Menu Export](./img/06-menu-export.png)

![Export vo formáte PNG](./img/07-export-to-png.png)
---

## ✅ Výsledok
- **PNG portrét v kruhu**  
- Transparentné pozadie (hodí sa na rôzne pozadia).  
- Voliteľný tieň alebo rámik pre lepší kontrast.  

---

## 🧭 Použitie
- **XMind** – centrálna téma bude elegantne kruhová.  
- **Prezentácie** – fotka na slide zapadne do dizajnu.  
- **Web / KNIFE** – môžeš ju embednúť do MD ako:

![Roman Kazička – Portrait](./img/rka-portret-circle-04.png)