# Funkciók

---

**formatNumber(**number**)**

Egy integer argumentummal rendelkezik, a számot felbontja pontokkal 3 karakterenként és egy stringet ad vissza.

---

**isNumeric(**string[]**)**

Egy string argumentummal rendelkezik, igaz-hamis értékkel tér vissza annak függvényében, hogy az argumentum szám-e vagy sem.

---

**loadServerConfig()**

Újratölti a szerver konfigurációt az adatbázisból.

* Szervernév
* Szerver játékmód
* Szerver nyelv
* Szerver weburl
* Szerver jelszó
* Szervernév (sendMessage prefix)

---

**moveSkinChangerIndex(**playerid, index**)**

Skinválasztóban való léptetés. Ha az érték 1 akkor a következő skint jeleníti meg, ha az érték -1 akkor az előzőt. Ha a lista végére ér, előről kezdi.

---

**setPlayerInSkinChanger(**playerid**)**

Játékost (_playerid_) skinváltóba helyezi, és megjeleníti neki az első skint a `fraction_skins` táblából.

---

**onSkinChangerFinish(**playerid, selectedSkin**)**

Kiszedi a személyt a skinváltóból, és vissza rakja arra a pozicíóra ahol le lett futtatva a setPlayerInSkinChanger funckió. Amennyiben a selectedSkin paraméter értéke -1 akkor a funkció úgy kezeli le azt, mintha kilépett volna a skinváltóból választás nélkül. Ha a személy szolgálatban van, akkor megváltoztatja a skinjét, ha nem akkor csak lementi.

---

**parkCar(**vehicleDBID**)**

Lementi a jármű pozicíóját, állapotát és kinézetét a megadott DBID-vel (_vehicleDBID_).

---

**spawnVehicle(**vehicleDBID**)**

Lekéri az adott DBID-jű (_vehicleDBID_) jármű adatait, és létrehozza azt a játékban. Ha a jármű létezik már az adott DBID-vel akkor az törlésre kerül előtte.

---

**sendAdminMessage(**type, perm, prefix[], msg[]**)**

Azoknak az adminoknak akik a feltételnek (van elég joga a _perm_ paraméterhez viszonyítva), azoknak üzenetet (_msg_) küld. A _prefix_ paraméter fog megjelenni [] zárójelben az üzenet előtt, jelölve azt, hogy hova tartozik (pl. AdmLog). A _type_ paraméter a prefix színét jelöli.

_type_:

* 0 **Információ (kék)**
* 1 **Siker (zöld)**
* 2 **Figyelmeztetés (narancs)**
* 3 **Hiba (piros)**
* 4 **Extra (sárga)**

---

**sendMessage(**playerid, type, prefix[], msg[]**)**

Játékosnak (_playerid_) üzenetet küld. A _prefix_ paraméter fog megjelenni [] zárójelben az üzenet előtt, jelölve azt, hogy hova tartozik (pl. AdmLog). A _type_ paraméter a prefix színét jelöli.

_type_:

* 0 **Információ (kék)**
* 1 **Siker (zöld)**
* 2 **Figyelmeztetés (narancs)**
* 3 **Hiba (piros)**
* 4 **Extra (sárga)**

---

**showPlayerHint(**playerid, string[], time**)**

Játékosnak (_playerid_) egy szövegdobozt jelenít meg bal oldalt a képernyőn (single player stílus). A _string_ paraméter a megjelenített szöveg, a _time_ az idő amíg mutassa a szövegdobozt (alapértelmezettként 5 másodperc).

---

**createTextDraws(**playerid**)**

Létrehozza a játékosnak (_playerid_) a szerveren lévő textdrawokat. Körülbelül csak a csatlakozásnál kell használni, máshol nincs jelentőssége.

---

**showPlayerInventory(**playerid**)**

Játékos táskájának (_playerid_) a tartalmát megmutatja saját magának.

---

**useItem(**playerid, item**)**

Akkor van meghívva mikor a játékos (_playerid_) használ egy tárgyat (_item_). Itt vannak lekezelve a tárgyaknak a funkciói, hogy használatkor mi történjen (pl. Gógyszer életet ad).

---

**addItem(**playerid, item, amount, param1**)**

Játékos (_playerid_) táskájához tudunk hozzáadni tárgyakat. Az item paraméter a tárgy DBID-je az `items` táblából, _amount_ a hozzáadandó mennyiség, _param1_ meg extra paraméter, egyelőre csak kocsikulcsoknál van használatba véve, mint jármű DBID tárolás (_param1_).

---

**removeItem(**playerid, item, amount**)**

Adott mennyiségű (_amount_) tárgyat (_item_) elvesz a játékostól (_playerid_). Amennyiben a mennyiség (_amount_) nagyobb mint a rendelkezésre álló összeg akkor törli a tárgyat a táskájából.

---

**clearItem(**playerid, item**)**

Törli a játékos (_playerid_) meghatározott tárgyát (_item_) a táskájából (összeset).

---

**playerItem(**playerid, item**)**

Leellenőrzi, hogy a játékosnál (_playerid_) van-e meghatározott tárgy (_item_).

---

**kickPlayer(**playerid**)**

Kirúgja a játékost (_playerid_) a szerverről _500ms_ késleltetéssel.
