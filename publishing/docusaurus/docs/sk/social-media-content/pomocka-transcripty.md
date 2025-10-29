# Pomôcky: Transkripty

## Transkript 27-10-2025 cvičenia

### Proaktívny vs. reaktívny prístup

Keď budete nad vecou, nepohltí vás diplomová práca ani akýkoľvek iný projekt. Budete mať šancu tú prácu robiť vedome, nie reaktívne. A už vôbec nie v živom projekte, kde reaktívny prístup znamená, že niečo sa pokazí a až potom to odhaľujete. Vy, IT-čkári a architekti, viete domýšľať dopredu, čo sa udeje, pretože je to kauzálne. Keď si nevytvorím architektúru, systém sa mi zrúti. Keď si nevytvorím diagramy, ako budem robiť prevádzku?

Ak budem úspešný a predám svoj produkt, ako ho budú noví majitelia rozvíjať, keď im nedám žiadnu dokumentáciu? Tvrdiť, že dokumentáciu spravím, až keď bude všetko hotové, to nefunguje, to sú rozprávky. Tu platí kauzalita, tvrdá realita a fakty.

### Paralely s inými inžinierskymi disciplínami

Predstavte si, že budete chcieť postaviť dom. Nepríde stavebná firma a nepovie: „Tu bude záchod, tu kúpeľňa a spálňu doriešime, keď bude hotové prvé podlažie.“ Pozerali by ste sa na nich, ako keby prišli z iného sveta. Skúsme sa pozrieť očami architektov a stavbárov na našu prácu – budeme zdesení. Nevymýšľajme si, že sme iná vedná oblasť, to je sebaklam. Keď sa bude baviť IT architekt, strojársky architekt, stavbár a urbanistický architekt, zistia, že princípy sú rovnaké, aj keď každý pracuje v inej mierke. Nežime v ilúzii, že niečo spravíme „potom“.

Snažím sa vytvoriť priestor, aby sa architekti stretávali s IT-čkármi, pretože to môže byť prínosné pre obe strany. My vieme ponúknuť technológie. Architekti pracujú s veľkými objemami dát, renderovanými pohľadmi a v mnohých variantoch. Používajú nástroje ako Building Information Modeling (BIM), kde je všetko parametrizované. Ak zmeníte polohu záchodu o 5 cm, musíte prerobiť všetky súvisiace veci – to sú závislosti (dependencies).

Určite máte skúsenosť, že keď zmeníte jednu funkciu, hoci len jej interface, alebo aktualizujete verziu nejakej knižnice, má to dopady na mnohých miestach. V Jave môžete mať 200 knižníc, ktoré vytvárajú vaše riešenie, a každá drobnosť ovplyvní výsledok. V praxi sa to často ignoruje, a potom fungujeme reaktívne: „Nainštaloval som tú knižnicu a prestal mi fungovať front-end.“ Možno som na back-ende spravil nejaký update a ani mi nenapadlo, že to ovplyvní nejaké volanie API. Týchto malých detailov je v systéme obrovské množstvo.

Kto iný ako vy by sa mal pokúsiť zachytiť túto komplexitu? Určite ju nezachytíte na 100 %, to sa asi nedá, ale treba vytvoriť podmienky, aby sme sa tomu v súčinnosti so všetkými dotknutými stranami aspoň priblížili. Keď to dokážu stavbári, strojári či automobilový priemysel, kde sa využívajú systémy ako CAD (computer-aided design), CAE (computer-aided engineering) a CAM (computer-aided manufacturing) – kde jeden navrhne, druhý simuluje a tretí vyrobí – prečo by sme to nedokázali my? V IT máme tiež podobný postup: od abstraktnej myšlienky a želania posúvame riešenie cez stratégiu, architektúru, analýzu, dizajn a implementáciu až po overiteľný a verifikovateľný výstup. Takže v tom nie je až taký veľký rozdiel.

### Organizácia predmetu a repozitáre

Teraz vám ukážem repozitáre, ktoré vás čakajú. To, kde sa nachádzam, je v repozitári `naj-framework`, konkrétne v `overview`. Je to prototyp, takže návody na použitie zatiaľ poskytnem ústne. Keď si ho stiahnete, je to v podstate ten istý repozitár, ktorý ste si sťahovali minule. Urobil som logickú chybu s oddelenou template verziou, ale vrátim to späť, takže bude len jedna verzia.

Dúfam, že budúci týždeň už bude všetko pripravené. Ukážem vám GitHub triedu, kde bude 60 repozitárov pre každého študenta, označených číslami `st001`, `st002`, `st003` atď. Svoje číslo nájdete v Class Notebooku v Teams. Toto číslo budete potrebovať na pripojenie. Funguje to tak, že ja vytvorím 60 repozitárov a pošlem vám pozvánku, aby ste sa pripojili na ten konkrétny. Bolo by nepríjemné, keby nastali konflikty, napríklad že na repozitár č. 14 sa pripoja dvaja študenti.

Neskôr vzniknú aj projektové repozitáre, kde budú pracovať 2-3 študenti v tíme. Projekt si vyžaduje tímovú spoluprácu, ale chcem, aby ste mali prácu aj individuálne u seba, aj keď to bude len kópia spoločného projektu. Čo s týmito repozitármi urobíte, či si budete robiť klony alebo ako s nimi budete pracovať, je na vás. Odporúčam, aby ste si ich odložili a prípadne pracovali u seba a do školských repozitárov dali len to, čo ste ochotní zverejniť.

Tu na tejto linke sú vaše identifikačné čísla. Zbieram tieto informácie preto, aby mi systémy ako GitHub nevracali nedoručiteľné maily. Cez licencovaný produkt mám možnosť na dva roky vytvárať takéto triedne repozitáre. Vytvorím zoznam `st001` až `st060` a príde vám e-mail, aby ste sa prihlásili na jeden z nich podľa vášho čísla. Toto budú študentské repozitáre.

### Motivácia a ciele predmetu

Ak si nechcete robiť starosti a chcete len prejsť, robte to len v školskom repozitári a odovzdajte minimum, ktoré vyžadujem. Nejako to prežijeme, ja aj vy. Tí, ktorých to baví a budú ašpirovať na áčko, dohodneme sa na podmienkach. Robíte tým dobré meno nielen mne, ale šírite aj myšlienku, kvôli ktorej tento predmet vznikol a prečo mi dáva zmysel ho robiť.

Energia, ktorú som do toho investoval, je tak obrovská, že keby som povedal, čo ma to stálo za tie peniaze, čo za to dostanem, tak by ste si ťukali na čelo, že musím byť úplný magor. A nebránim sa tomu, asi som. Ale dáva mi to zmysel v tom, že som si vytvoril ďalší framework, ďalšiu dielňu, a už mám v hlave vlastné projekty, ktoré by som chcel s podporou týchto nástrojov realizovať. Teraz som v prípravnej fáze, ktorá ma stála viac ako rok práce a je v nej moje celoživotné know-how. Vy budete mať iné, ale použite to, čo uznáte za vhodné, aby ste mali v dielni upratané, robili s radosťou a aby vám to dávalo zmysel.

### Zhrnutie a ďalšie kroky

Ak tu je niekto, kto zatiaľ nemá zadaný e-mail, je to v poriadku. Pošlem vám do AIS-u linku na GitHub triedu. Tým pádom sa vaše e-maily dozviem sprostredkovane, až keď si vyberiete svoj repozitár. Uvidíme, ako to zafunguje.

Aby som to zhrnul, `naj-framework` je repozitár, ktorý slúži ako vzor pre všetky ostatné. Vytváram v ňom skripty a všetko možné. Niektoré časti, ako napríklad `naj-template`, sú infraštruktúra, ktorú zatiaľ nechcem publikovať. Časom sa ukáže, čo z toho sa osvedčí a čo prestanem používať.

---

## Transkript 27-10-2025 prednášky

### Dôležitosť taxonómie a presnej terminológie

Každá vedná disciplína, ak sa chce označovať ako veda, musí mať základné vlastnosti. Jednou z nich je jasná terminológia. Každá veda, ktorá chce niečo znamenať, musí mať jasno v pojmoch – čo je čo. Toto má dve roviny. Prvou je taxonómia, teda hierarchia pojmov od všeobecných po konkrétne. Pekným príkladom sú prírodné vedy, ktoré už 200-300 rokov majú zavedený systém kategorizácie skúmaných objektov. V prírodných vedách máme živočíchy, rastliny či minerály a tam je jasne definované, čo je čo, napríklad diamanty sa klasifikujú podľa tvrdosti a iných kritérií. Zaviedla sa taxonómia základných pojmov a ich vysvetlenie. Keď sa objaví nejaký nový prvok, vedci skúmajú, kam pasuje, a hľadajú súvislosti, aby vedeli použiť správne metódy skúmania. Niekedy nie je jednoduché zaradiť daný organizmus či rastlinu do správnej čeľade alebo skupiny, ale je to kľúčové. Dokonca sa používajú latinské názvy, aby sa vedeli vyjadrovať jednoznačne.

V IT je v tomto smere úplná „galiba“. Už len keď sa spýtam: „Povedzte mi zoznam aplikácií,“ vznikne nekonečná diskusia o tom, čo je to aplikácia a čo je to platforma. Nevieme sa zjednotiť.

### Praktické využitie taxonómie v IT a biznise

V priebehu tejto prednášky vám ukážem, že existujú medzinárodné pokusy o stabilizáciu tejto taxonómie v IT. Existujú už verzie 5.0, sú k tomu dostupné Excel súbory a popisy, prečo by to malo byť práve takto. Pomáha to všetkým. Ak ste absolvovali TOGAF alebo iné architektonické metódy, viete, že svet biznisu, systémov a technológií sa dá rozčleniť na zhruba 600 kategórií v 8 úrovniach. Praktický význam to má v tom, že ten, komu záleží na nákladoch firmy a má takúto kategorizáciu, vie presne povedať, koľko ho stojí dané oddelenie, koľko softvér, hardvér alebo konkrétny proces.

Na príkladoch z jednej aplikácie si ukážeme tzv. Sankey diagramy, kde rozkladáte náklady od hrubého k jemnému a naopak. Ak sa implementácia urobí dobre a napojí sa na hlavnú účtovnú knihu v ERP systéme, ktorá má tiež svoju kategorizáciu, môžete veľmi rýchlo získať prehľad o efektivite firmy s fokusom napríklad na IT.

Nepoznám veľa IT firiem, ktoré by riešili, koľko ich stojí nekvalita. Pritom vo výrobných fabrikách je cena za nekvalitu jedným z hlavných parametrov. Sú to peniaze, ktoré sa dajú zarobiť tým, že sa zamyslíme nad procesmi. Ak sa robotník nemusí zohnúť pod stôl, ale bude mať diel na stole, ušetrí sekundy. V rámci osemhodinovej zmeny to môže byť 15 minút, čo predstavuje napríklad 150 výrobkov navyše. A to sú čisté peniaze.

### Katalógy aktív, ontológia a pohľady

Základom sú definované katalógy referenčných objektov pre architektonické prvky. Vytvoríte si kategórie, a keď budete robiť konkrétnu implementáciu, spravíte si inštancie. Budete mať inštančný model, ale kategorizácia zostane – server bude stále server, len pôjde o konkrétnu inštanciu. K taxonómii sa pridáva ontológia a pohľady.

Aby sme si rozumeli, realitu sa môžeme pokúsiť definovať ako aktíva (assets), ktoré potrebujeme na dosahovanie výsledkov. Aktíva sú referenčné objekty v katalógoch a ich konkrétne inštancie. Môžeme ich rozdeliť podľa rôznych hľadísk, ale vždy nás zaujímajú tri hlavné časti:
1.  **Biznisová časť:** ľudia, vzťahy, organizačné veci, smernice, zmluvy, dodávatelia.
2.  **Systémová časť:** aplikácie, systémy, frameworky, databázy potrebné na realizáciu.
3.  **Technologická časť:** infraštruktúra, napríklad virtualizácia (na úrovni systému poviem, že to bude virtualizácia, a na úrovni technológie špecifikujem, či to bude VMware, Hyper-V alebo Docker).

Týmto kategóriám sa rôzni dodávatelia a tvorcovia metodík venujú už minimálne 15 rokov. Vo Volkswagene sme mali zoznam kategórií, ktorý mal asi 1100 položiek, a to boli len kategórie, nie koncové inštancie. Organizácia TBM Council (tbmcouncil.org) ponúka excelový súbor, ktorý má 560 až 600 kategórií a slúži na prepojenie sveta biznisu a IT. Keď sa to podarí prepojiť – čiže si vytvoríte katalóg referenčných a inštančných objektov a začnete ho používať – má to dopad na celú organizáciu. Zrazu všetci majú spoločný slovník. Keď poviem server, bude mať prívlastok: aplikačný, hardvérový atď. Pri otázke „čo je to platforma?“ by inak vznikali nekonečné diskusie, lebo každý by mal potrebu vyjadriť svoj názor.

### Perspektívy a pohľady pre rôznych stakeholderov

Dôležité je pozerať sa na to z pohľadu stakeholderov, ktorí tieto katalógy používajú. Ak sa spýtam napríklad CIO (Chief Information Officer), ako chce vidieť svoje systémy a procesy, nejakým spôsobom to popíše. Povie, že potrebuje vidieť náklady za jednotlivé oddelenia a aplikácie. On nie je technický odborník, má byť manažér, ktorý sa rozpráva s biznisom a zabezpečuje preň stabilnú prevádzku.

On nevie presne, čo má povedať, ale niekto s metodickým zmýšľaním by s ním mal spraviť interview a zistiť, aké informácie a ako často potrebuje. Manažment nie je o presných číslach, ale o trendoch. Keď vidím, že nejaký sledovaný parameter, ktorý si zadefinujem, sa zhoršuje alebo zlepšuje, môžem reagovať. Neviem povedať, či náklady na mzdy 100 000 sú dobré alebo zlé v absolútnych číslach. Ale keď za tých 100 000 vyrobím milión, je to dobré. Keď zistím, že pri danej skladbe nákladov na interný tím mi rastie obrat (revenue), tak nebudem prepúšťať ľudí. Toto sú kľúčové informácie.

Stakeholder by mal rozumieť tomu, čo riadi, aby vedel, aké parametre chce sledovať a čo by mu mal informačný systém poskytnúť. Informácie musia byť objektívne a verifikovateľné. My ako analytici sme si definovali vlastné pojmy, ako chceme vidieť aplikácie z pohľadu API rozhraní, a vytvorili sme si šablóny. To je perspektíva analytika, ktorý odovzdáva programátorovi špecifikáciu. Až na základe týchto predpisov kreslím obrázky. Toto považujem za dokumentáciu. Z tohto modelu si viem vygenerovať Word, HTML alebo čokoľvek iné. Ak budem robiť dopadovú analýzu, potrebujem vidieť nielen aplikácie, ale aj biznisové procesy – čo všetko sa musí stať, aby sa neprerušila cesta od zákazníka cez objednávku až po dodávku.

### Asset management a konfiguračná databáza (CMDB)

Tento koncept aktív, perspektív a pohľadov je implementovaný aj vo vašich modeloch. Ak budete vo firme, kde biznis už funguje a robíte len change management, bez katalógov sa vám bude fungovať veľmi ťažko. Bežne sa kupujú aplikácie na tzv. asset management, kde sa evidujú licencie, ich platnosť a sleduje sa stav aplikačného portfólia.

Ale to nie je izolovaná vec. Asset management je dôležitý pre všetkých, vrátane prevádzky. Keď sa niečo odovzdá na prevádzku, tá má zabezpečiť, aby to fungovalo. Ale už len taká drobnosť ako evidencia, kedy vypršia certifikáty, je kľúčová. Ak chýba proces evidencie, každý rok riešite problém s vypršaným certifikátom. Tu prichádza na rad CMDB (Configuration Management Database). Vo všetkých metodikách je CMDB definovaná ako reálny obraz toho, čo máte nasadené v živom prostredí.

Ak nahlásite incident, musíte ho naviazať na nejaký konkrétny prvok. Keď používateľ nahlási, že „nejde mu front-end“, môže to mať milión dôvodov. Ak nemám jednoznačný slovník pojmov (čo je server, aký operačný systém...), neviem, kam incident priradiť. Mať spoločný slovník pojmov je preto kľúčová vec, na ktorej sa musíme dokázať zhodnúť.

### Štandardizácia a reálne príklady z praxe

Existujú rôzne pokusy o definíciu takejto taxonómie. Jedným z nich je medzinárodná organizácia Technology Business Management Council (TBM Council), ktorá ponúka štandardizovanú taxonómiu vo forme voľne stiahnuteľného Excel súboru. Riešia síce len taxonómiu, nie ontológiu, ale už aj to je obrovský prínos. Obsahuje okolo 560 kategórií a je to pokus o vytvorenie spoločného slovníka pojmov. Môžete sa stať členom, vzdelávať sa a aktívne sa zapojiť.

V praxi je dôležité modelovať produkčné, ale aj ostatné prostredia. Keď niečo vyvíjate, nerobíte to priamo na produkcii. Na produkciu dávate najviac peňazí – ostré licencie, najlepší hardvér. Ale vývoj prebieha inde, máte testovacie prostredie, UAT prostredie atď., kde nekupujete plné licencie, lebo je to drahé.

### Riziká a dopady nedostatočného riadenia

Zvažujete aj reputačné riziko. Čo sa stane, ak mi vypadne front-end na 10 minút? Manažér pre kontinuitu prevádzky (Business Continuity Manager) povie: „Dobre, zabezpečíme to, ale bude to stáť 10 miliónov.“ Ak poviete, že môže vypadnúť na dve hodiny, bude to stáť milión. Tieto odhady vychádzajú zo skúseností a sú výsledkom business impact analýzy.

Musíte vedieť posúdiť dopady. Predstavte si diaľnicu medzi Malackami a Bratislavou, kde desiatky dodávateľov vozia diely do Volkswagenu systémom just-in-time. Súčiastku privezú presne vtedy, keď ju treba, lebo medzisklady sú minimálne. Auto je už na linke, keď kamión prichádza k hale a priamo z neho sa vykladá. Logistika je extrémne náročná. A teraz si predstavte, že niekto spraví útok na diaľnicu a vyradí ju z činnosti. Celý dodávateľský kanál sa zastaví.

Podobná situácia sa stala nedávno. Možno ste zachytili, čo sa stalo v auguste a septembri – Jaguar Land Rover šesť týždňov nevyrábal. Stratili 2 miliardy libier a nevedia sa z toho spamätať. Stalo sa to cez tretiu stranu, ktorá im zabezpečovala SAP systém. Patchovanie je rutina, 90 % IT aktivít je patchovanie, ale dopady, keď niečo napatchujem, nespravím update firmvéru a systémy prestanú spolu komunikovať, môžu byť katastrofálne. Aj nám to zastavilo výrobu. Ak neviete, kde čo máte, nemáte CMDB ani asset management, zákonite sa to musí stať. Pravda je taká, že ransomware poškodil dáta, ktoré nedokázali obnoviť. Vo výrobných fabrikách je to veľmi ťažká situácia.

Ale čím horšie, tým lepšie. Garantujem vám, že oni sa z toho poučia. Keď vo výrobe pochopia, že IT je pre nich životne dôležité, veci sa pohnú. Šesť týždňov výpadku výroby je extrémne zlé, reputačne aj finančne. Potrebujú úvery na prežitie a dobré meno, aby zarobili na škody.

### Systémový prístup a budovanie znalostí

Bez principiálnych vecí, ako je taxonómia, ontológia, technologické postupy a vyškolení ľudia, je to veľmi ťažké. Toto sú ďalšie oblasti pre vás ako budúcich inžinierov. Mali by ste mať prehľad, čo je potrebné. Ekonómovia možno nebudú cítiť túto potrebu tak silno ako vy. Tento predmet je o tom, že veci fungujú vtedy, keď pochopíte kontext riešenia, nielen keď napíšete use case. Vtedy je väčšia pravdepodobnosť, že to bude fungovať.

Treba si uvedomiť, že nič nemáte pod plnou kontrolou. IT-čkár, aj keď robí čistý softvér, má pod kontrolou oveľa menej vecí ako poľnohospodár. Ten spraví všetko, čo treba, ale potom príde búrka, záplavy a je koniec. IT-čkárovi príde ransomware a je koniec. Je to komplexná vec a bez systémového prístupu a budovania a výmeny znalostí sa to nedá robiť.

Zaznačte si TBM Council a ich taxonómiu verzie 5. Nájdete tam konkrétne návody. Aspoň sa nad tým zamyslite.