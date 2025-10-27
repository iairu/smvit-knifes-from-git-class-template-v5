#index.md

# [brand name wip]

---

# Team Members

- **Denis Ivan**: IoT Engineer, Creator of the idea
- **Ondrej Špánik**: KNIFE Framework Developer, Social Media Manager, IoT Engineer
- **Danilo Bashmakov**: IoT Engineer

---

# Návrh Projektu: USB-TTL Prevodník s Automatickou Detekciou a Bezdrôtovým Terminálom

## 1. Abstrakt

Cieľom tohto projektu je navrhnúť a zostrojiť pokročilý USB-TTL sériový prevodník, ktorý zjednoduší prácu vývojárom a hobby elektronikom. Zariadenie bude okrem štandardnej funkcie prevodníka obsahovať inteligentné funkcie, ako je automatická detekcia prenosovej rýchlosti (baud rate) a automatické prehodenie pinov RX/TX. Navyše bude integrovať bezdrôtovú konektivitu (Wi-Fi alebo Bluetooth), čo umožní používať ho ako bezdrôtový sériový terminál prostredníctvom webovej aplikácie alebo mobilnej aplikácie.

## 2. Kľúčové Funkcie a Ciele

- **Štandardný USB-TTL Prevodník**: Poskytnutie stabilnej sériovej komunikácie medzi PC (USB) a mikrokontrolérmi/zariadeniami (TTL UART).
- **Automatická Detekcia Baud Rate**: Zariadenie samostatne identifikuje správnu prenosovú rýchlosť komunikujúceho zariadenia (napr. 9600, 115200, atď.), čím eliminuje potrebu manuálneho nastavovania.
- **Automatická Detekcia Pozície Pinov (RX/TX Swap)**: Prevodník automaticky zistí, či sú piny RX a TX prekrížené, a prispôsobí sa tomu. Tým sa predchádza častým problémom s pripojením.
- **Duálna Napájacia Úroveň**: Poskytnutie výstupného napätia 3.3V aj 5V pre napájanie pripojených zariadení.
- **Bezdrôtový Terminál**:
  - Wi-Fi Verzia (s ESP8266/ESP32): Zariadenie vytvorí webový server s terminálovou aplikáciou prístupnou cez prehliadač.
  - Bluetooth Verzia (s ESP32): Zariadenie bude fungovať ako Bluetooth "Serial Port Profile" (SPP) zariadenie, ku ktorému sa dá pripojiť z mobilu alebo PC.

## 3. Návrh Hardvéru

### Požadované Komponenty:

1. **Mikrokontrolér**:
   - Odporúčané: ESP32-WROOM-32. Tento čip je ideálny, pretože obsahuje Wi-Fi, Bluetooth, dva UART porty (jeden pre komunikáciu s PC, druhý pre cieľové zariadenie) a dostatočný výpočtový výkon.
   - Alternatíva (len Wi-Fi): NodeMCU (ESP8266). Je lacnejší, ale má menej GPIO pinov a chýba mu Bluetooth.
2. **USB-to-UART Bridge**:
   - CP2102 alebo CH340G/C. Tento čip bude slúžiť ako most medzi USB portom počítača a jedným z UART portov na ESP32.
3. **Regulátor Napätia**:
   - AMS1117-3.3 alebo podobný LDO regulátor na vytvorenie stabilného 3.3V napájania z 5V USB.
4. **Logický Menič Úrovní (Logic Level Shifter)**:
   - Voliteľný, ale odporúčaný pre bezpečnú komunikáciu s 5V zariadeniami, ak ESP beží na 3.3V logike. Modul s BSS138 tranzistormi je bežná voľba.
5. **Pasívne Komponenty**:
   - Konektory (USB-C alebo Micro USB, pinové lišty).
   - Rezistory, kondenzátory, LED diódy na indikáciu stavu (napájanie, RX, TX).

### Bloková Schéma Zapojenia:

```
+-------------------+ +-----------------+ +---------------------+
PC (USB) <=>| USB-to-UART čip | UART1<=>| ESP32 | UART2<=>| Cieľové Zariadenie |
| (CP2102/CH340) | | | | (Arduino, senzor...) |
+-------------------+ +-------+---------+ +---------------------+
|
+--+---+--+
| Wi-Fi / |
| Bluetooth|
+----------+
```

## 4. Návrh Softvéru (Firmware pre ESP32)

Firmware bude napísaný v C++ s použitím Arduino Framework alebo ESP-IDF.

### Modul 1: Automatická Detekcia Baud Rate

1. ESP32 bude cyklicky prepínať svoj druhý UART port (UART2) medzi zoznamom štandardných prenosových rýchlostí (300, 1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200).
2. Na každej rýchlosti bude krátky čas počúvať prichádzajúce dáta.
3. Primitívna metóda: Ak prijme akékoľvek dáta bez chyby rámca (framing error), predpokladá, že rýchlosť je správna a uzamkne ju.
4. Pokročilá metóda: Bude čakať na špecifický znak, napríklad 0x0A (Newline) alebo 0x55 (binárne striedanie bitov), ktorý sa často posiela pri štarte alebo v "idle" stave. Po úspešnej detekcii sa rýchlosť uzamkne.

### Modul 2: Automatická Detekcia Pinov (RX/TX Swap)

1. Po úspešnej detekcii baud rate sa ESP32 pokúsi poslať testovací príkaz na cieľové zariadenie (napr. "AT\r\n", ak ide o modem, alebo len čaká na dáta).
2. Scenár A (predvolené zapojenie): ESP32 TX -> Cieľový RX, ESP32 RX -> Cieľový TX.
3. Ak ESP32 prijme očakávanú odpoveď alebo akékoľvek platné dáta na svojom RX pine, konfigurácia je správna.
4. Ak po krátkom časovom limite (napr. 500ms) nepríde žiadna odpoveď, firmvér programovo prehodí funkciu svojich pinov (pomocou gpio_matrix_out a gpio_matrix_in v ESP-IDF alebo softvérovou emuláciou) a zopakuje test.

### Modul 3: Bezdrôtový Most

**Pre Wi-Fi:**

1. ESP32 sa spustí v režime Access Point (AP).
2. Spustí jednoduchý webový server, ktorý po pripojení klienta (napr. z mobilu) zobrazí HTML stránku.
3. Táto stránka bude obsahovať JavaScript, ktorý vytvorí WebSocket spojenie s ESP32.
4. Všetky dáta prijaté z cieľového zariadenia sa okamžite posielajú cez WebSocket do webového prehliadača.
5. Dáta zadané vo webovom termináli sa posielajú cez WebSocket do ESP32 a následne na TX pin cieľového zariadenia.

**Pre Bluetooth:**

1. ESP32 inicializuje Bluetooth a spustí "Bluetooth Serial" službu.
2. Na mobilnom telefóne alebo PC sa spáruje s ESP32.
3. Pomocou akejkoľvek štandardnej Bluetooth terminálovej aplikácie je možné posielať a prijímať dáta rovnako ako cez káblové spojenie.

## 5. Postup Realizácie

1. **Fáza 1: Prototyp na Breadboarde**. Zapojenie základných komponentov (ESP32, CP2102 modul, regulátor) a otestovanie základnej funkcie USB-TTL prevodníka.
2. **Fáza 2: Implementácia Firmvéru**. Postupné programovanie jednotlivých modulov (detekcia baud rate, pin swap, Wi-Fi/Bluetooth most).
3. **Fáza 3: Vývoj Webovej Aplikácie**. Tvorba jednoduchej a responzívnej HTML/CSS/JS stránky pre Wi-Fi terminál.
4. **Fáza 4: Návrh a Výroba PCB**. Po úspešnom otestovaní prototypu navrhnúť vlastnú dosku plošných spojov pre kompaktné a robustné riešenie.
5. **Fáza 5: Finálne Zostavenie a Testovanie**. Osadenie PCB, nahratie finálneho firmvéru a komplexné testovanie všetkých funkcií.

## 6. Možné Vylepšenia

- Pridanie malého OLED displeja na zobrazenie aktuálneho stavu (zistená baud rate, IP adresa, stav pripojenia).
- Implementácia fyzického prepínača na vypnutie automatickej detekcie a manuálne nastavenie parametrov.
- Rozšírenie o logický analyzátor alebo podporu pre iné protokoly (I2C, SPI).
- Návrh 3D tlačenej krabičky.
