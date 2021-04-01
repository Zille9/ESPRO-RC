{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Autor: Reinhard Zielinski                                                                                 │
│ Copyright (c) 2021 Reinhard Zielinski                                                                    │
│ See end of file for terms of use.                                                                    │
│ Die Nutzungsbedingungen befinden sich am Ende der Datei                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────────────┘

Informationen   : hive-project.de
Kontakt         : zille09@googlemail.com
System          : TriOS
Name            : [I]nput-[O]utput-[S]ystem - System-API
Chip            : Single-Chip
Typ             : Objekt
Version         : 01
Subversion      : 1
Funktion        : System-API - Schnittstelle der Anwendungen zu allen Systemfunktionen



Notizen         :

 --------------------------------------------------------------------------------------------------------- }}
CON '-------------------------------------------------- Konstanten
'dir-marker
#0,     DM_ROOT
        DM_SYSTEM
        DM_USER
        DM_A
        DM_B
        DM_C
'index für dmarker€
#0,     RMARKER                                         'root
        SMARKER                                         'system
        UMARKER                                         'programmverzeichnis
        AMARKER
        BMARKER
        CMARKER

CON 'Systemvariablen
'systemvariablen
LOADERPTR       = $0FFFFB       '4 Byte                 'Zeiger auf Loader-Register im hRAM
MAGIC           = $0FFFFA       '1 Byte                 'Warmstartflag
SIFLAG          = $0FFFF9       '1 byte                 'Screeninit-Flag
BELDRIVE        = $0FFFED       '12 Byte                'Dateiname aktueller Grafiktreiber
PARAM           = $0FFFAD       '64 Byte                'Parameterstring
RAMDRV          = $0FFFAC       '1 Byte                 'Ramdrive-Flag
RAMEND          = $0FFFA8       '4 Byte                 'Zeiger auf oberstes freies Byte (einfache Speicherverwaltung)
RAMBAS          = $0FFFA4       '4 Byte                 'Zeiger auf unterstes freies Byte (einfache Speicherverwaltung)

SYSVAR          = $0FFFA3                               'Adresse des obersten freien Bytes, darüber folgen Systemvariablen

   Bauds        = 57600
   RX           = 24
   TX           = 25

OBJ
        psram  :"PSRAM_PASM_HIVE"'_Tiny"                      '1Cog
        SDFat  :"adm-fat"                                     '1Cog
        rtc    :"adm-rtc"
        ser    :"FullDuplexSerialExtended"'                   '1Cog
                                                        '    ----------
                                                              '3Cog's

VAR
   long  dmarker[6]                                                           'speicher für dir-marker
   byte tmptime

pub init

  SDFat.FATENGINE                                                               'SD-Karten-Treiber starten
  psram.start                                                                   'PSRAM-Treiber starten
  waitcnt(clkfreq/10+cnt)
  psram.ram_reset                                                               'RAM-Chip resetten
  psram.ram_sqi                                                                 'in den Quad-Modus schalten
  ser.start(RX,TX,0,Bauds)                                                      'serielle Schnittstelle zum ESP32 starten

CON ''------------------------------------------------- eRAM/SPEICHERVERWALTUNG
PUB ram_rdbyte(adresse):wert                        'eram: liest ein byte vom eram

   wert:=psram.rd_value(adresse,psram#JOB_PEEK)

pub ram_fill(adresse,adresse2,wert)
    psram.ram_fill(adresse,adresse2,wert)

pub ram_copy(von,ziel,anzahl)

    psram.ram_copy(von,ziel,anzahl)

pub ram_keep(adr):w

   w:=psram.ram_keep(adr)

PUB ram_wrbyte(wert,adresse)                        'eram: schreibt ein byte in eram

  psram.wr_value(adresse,wert,psram#JOB_POKE)

PUB ram_rdlong(eadr): wert                          'eram: liest long ab eadr
'  wert := ram_rdbyte(eadr)
'  wert += ram_rdbyte(eadr + 1) << 8
'  wert += ram_rdbyte(eadr + 2) << 16
'  wert += ram_rdbyte(eadr + 3) << 24

  wert:=psram.rd_value(eadr,psram#JOB_RDLONG)

PUB ram_rdword(eadr): wert                          'eram: liest word ab eadr

 wert := psram.rd_value(eadr,psram#JOB_RDWORD)

PUB ram_wrlong(wert,eadr) '|n                          'eram: schreibt long ab eadr

  psram.wr_value(eadr,wert,psram#JOB_WRLONG)
{  n := wert & $FF
  ram_wrbyte(n,eadr)
  n := (wert >> 8) & $FF
  ram_wrbyte(n,eadr + 1)
  n := (wert >> 16) & $FF
  ram_wrbyte(n,eadr + 2)
  n := (wert >> 24) & $FF
  ram_wrbyte(n,eadr + 3) }

PUB ram_wrword(wert,eadr) '|n                          'eram: schreibt word ab eadr

  psram.wr_value(eadr,wert,psram#JOB_WRWORD)

CON ''------------------------------------------------- SD_LAUFWERKSFUNKTIONEN
PUB BOOT_Partition(strpt)

    \sdfat.bootPartition(strpt,".")

PUB sdmount: err                                        'sd-card: mounten
''funktionsgruppe               : sdcard
''funktion                      : eingelegtes volume mounten
''busprotokoll                  : [001][get.err]
''                              : err - fehlernummer entspr. list
  ifnot sdfat.checkPartitionMounted
    err := \sdfat.mountPartition(0,0)                     'karte mounten

    ifnot err
      dmarker[DM_ROOT] := sdfat.getDirCluster             'root-marker setzen
      sdfat.setDirCluster(dmarker[DM_ROOT])               'root-marker wieder aktivieren

    'outa[LED_OPEN]:=0
  else                                                    'frida
    return 0                                              'frida
   'outa[LED_OPEN]:=1


PUB sddir                                               'sd-card: verzeichnis wird geöffnet
''funktionsgruppe               : sdcard
''funktion                      : verzeichnis öffnen
''busprotokoll                  : [002]
   \sdfat.listReset

PUB sdnext: strpt                                       'sd-card: nächster dateiname aus verzeichnis
''funktionsgruppe               : sdcard
''funktion                      : nächsten eintrag aus verzeichnis holen
''busprotokoll                  : [003][get.status=0]
''                              : [003][get.status=1][sub_getstr.fn]
''                              : status - 1 = gültiger eintrag
''                              :          0 = es folgt kein eintrag mehr
''                              : fn - verzeichniseintrag string
  strpt := \sdfat.listName                              'nächsten eintrag holen
  if strpt                                              'status senden
    return strpt
  else
    return 0                                            'kein eintrag mehr

PUB sdopen(modes,stradr):err '| len,i                    'sd-card: datei öffnen
''funktionsgruppe               : sdcard
''funktion                      : eine bestehende datei öffnen
''busprotokoll                  : [004][put.modus][sub_putstr.fn][get.error]
''                              : modus - "A" Append, "W" Write, "R" Read (Großbuchstaben!)
''                              : fn - name der datei
''                              : error - fehlernummer entspr. list
   if modes>90
      modes-=32

   if modes=="A"                                        'Appendfunktion, funktioniert sonst nicht
      err := \sdfat.openFile(stradr, "W")              'zum schreiben öffnen
      \sdfat.setCharacterPosition(\sdfat.listSize)      'und zur letzten Position springen
   else
      err := \sdfat.openFile(stradr, modes)


PUB sdclose:err                                         'sd-card: datei schließen
''funktionsgruppe               : sdcard
''funktion                      : die aktuell geöffnete datei schließen
''busprotokoll                  : [005][get.error]
''                              : error - fehlernummer entspr. list
  err  := \sdfat.closeFile

PUB sdgetc: char                                        'sd-card: zeichen aus datei lesen
''funktionsgruppe               : sdcard
''funktion                      : zeichen aus datei lesen
''busprotokoll                  : [006][get.char]
''                              : char - gelesenes zeichen
  char := \sdfat.readCharacter

PUB sdputc(char)                                        'sd-card: zeichen in datei schreiben
{{sdputc(char) - sd-card: zeichen in datei schreiben}}
  \sdfat.writeCharacter(char)

PUB sdgetstr(stringptr,len)                             'sd-card: eingabe einer zeichenkette
  repeat len
    byte[stringptr++] := sdgetc

PUB sdputstr(stringptr)                                 'sd-card: ausgabe einer zeichenkette (0-terminiert)
{{sdstr(stringptr) - sd-card: ausgabe einer zeichenkette (0-terminiert)}}
  repeat strsize(stringptr)
    sdputc(byte[stringptr++])

PUB sddec(value) | i                                    'sd-card: dezimalen zahlenwert auf bildschirm ausgeben
{{sddec(value) - sd-card: dezimale bildschirmausgabe zahlenwertes}}
  if value < 0                                          'negativer zahlenwert
    -value
    sdputc("-")
  i := 1_000_000_000
  repeat 10                                             'zahl zerlegen
    if value => i
      sdputc(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1
      sdputc("0")
    i /= 10                                             'n?chste stelle

PUB sdeof: eof                                          'sd-card: eof abfragen
''funktionsgruppe               : sdcard
''funktion                      : eof abfragen
''busprotokoll                  : [030][get.eof]
''                              : eof - eof-flag
   eof:=sdfat.getEOF

pub sdpos:c

    c:=sdfat.getCharacterPosition

'pub sdcopy(cm,pm,source)
'    bus_putchar1(gc#a_SDCOPY)
'    bus_putlong1(cm)
'    bus_putlong1(pm)

'    bus_putstr1(source)


PUB sdgetblk(count,bufadr) | i                          'sd-card: block lesen
''funktionsgruppe               : sdcard
''funktion                      : block aus datei lesen
''busprotokoll                  : [008][sub_putlong.count][get.char(1)]..[get.char(count)]
''                              : count - anzahl der zu lesenden zeichen
''                              : char - gelesenes zeichen

  i := 0
  repeat count
    byte[bufadr][i++] := \sdfat.readCharacter

'PUB sdputblk(count,bufadr) | i                          'sd-card: block schreiben
''funktionsgruppe               : sdcard
''funktion                      : zeichen in datei schreiben
''busprotokoll                  : [007][put.char]
''                              : char - zu schreibendes zeichen

  i := 0
'  bus_putchar1(gc#a_SDPUTBLK)
'  bus_putlong1(count)
'  repeat count
'    bus_putchar1(byte[bufadr][i++])
con'************************************************ Blocktransfer test modifizieren fuer Tiledateien und Datendateien (damit es schneller geht ;-) **************************************
PUB sdxgetblk(adr,count)|i                              'sd-card: block lesen --> eRAM
''funktionsgruppe               : sdcard
''funktion                      : block aus datei lesen und in ramdisk speichern
''busprotokoll                  : [008][sub_putlong.count][get.char(1)]..[get.char(count)]
''                              : count - anzahl der zu lesenden zeichen
''                              : char - gelesenes zeichen
  i := 0
  repeat count
     ram_wrbyte(\sdfat.readCharacter,adr++)


con '*********************************************** Blocktransfer test **************************************************************************************************
PUB sdxputblk(adr,count)                              'sd-card: block schreiben <-- eRAM
''funktionsgruppe               : sdcard
''funktion                      : zeichen aus ramdisk in datei schreiben
''busprotokoll                  : [007][put.char]
''                              : char - zu schreibendes zeichen

  repeat count
      \sdfat.writeCharacter(ram_rdbyte(adr++))

PUB sdseek(wert)                                        'sd-card: zeiger auf byteposition setzen
''funktionsgruppe               : sdcard
''funktion                      : zeiger in datei positionieren
''busprotokoll                  : [010][sub_putlong.pos]
''                              : pos - neue zeichenposition in der datei

  \sdfat.setCharacterPosition(wert)

PUB sdfattrib(anr): wert                              'sd-card: dateiattribute abfragen
''funktionsgruppe               : sdcard
''funktion                      : dateiattribute abfragen
''busprotokoll                  : [011][put.anr][sub_getlong.wert]
''                              : anr - 0  = Dateigröße
''                              :       1  = Erstellungsdatum - Tag
''                              :       2  = Erstellungsdatum - Monat
''                              :       3  = Erstellungsdatum - Jahr
''                              :       4  = Erstellungsdatum - Sekunden
''                              :       5  = Erstellungsdatum - Minuten
''                              :       6  = Erstellungsdatum - Stunden
''                              :       7  = Zugriffsdatum - Tag
''                              :       8  = Zugriffsdatum - Monat
''                              :       9  = Zugriffsdatum - Jahr
''                              :       10 = Änderungsdatum - Tag
''                              :       11 = Änderungsdatum - Monat
''                              :       12 = Änderungsdatum - Jahr
''                              :       13 = Änderungsdatum - Sekunden
''                              :       14 = Änderungsdatum - Minuten
''                              :       15 = Änderungsdatum - Stunden
''                              :       16 = Read-Only-Bit
''                              :       17 = Hidden-Bit
''                              :       18 = System-Bit
''                              :       19 = Direktory
''                              :       20 = Archiv-Bit
''                              : wert - wert des abgefragten attributes



   case anr
     0:  wert := \sdfat.listSize
     1:  wert := \sdfat.listCreationDay
     2:  wert := \sdfat.listCreationMonth
     3:  wert := \sdfat.listCreationYear
     4:  wert := \sdfat.listCreationSeconds
     5:  wert := \sdfat.listCreationMinutes
     6:  wert := \sdfat.listCreationHours
     7:  wert := \sdfat.listAccessDay
     8:  wert := \sdfat.listAccessMonth
     9:  wert := \sdfat.listAccessYear
     10: wert := \sdfat.listModificationDay
     11: wert := \sdfat.listModificationMonth
     12: wert := \sdfat.listModificationYear
     13: wert := \sdfat.listModificationSeconds
     14: wert := \sdfat.listModificationMinutes
     15: wert := \sdfat.listModificationHours
     16: wert := \sdfat.listIsReadOnly
     17: wert := \sdfat.listIsHidden
     18: wert := \sdfat.listIsSystem
     19: wert := \sdfat.listIsDirectory
     20: wert := \sdfat.listIsArchive


PUB sdvolname: stradr                            'sd-card: volumelabel abfragen
''funktionsgruppe               : sdcard
''funktion                      : name des volumes überragen
''busprotokoll                  : [012][sub_getstr.volname]
''                              : volname - name des volumes
''                              : len   - länge des folgenden strings

  stradr:= \sdfat.listVolumeLabel                    'label holen und senden

PUB sdcheckmounted: flag                                'sd-card: test ob volume gemounted ist
''funktionsgruppe               : sdcard
''funktion                      : test ob volume gemounted ist
''busprotokoll                  : [013][get.flag]
''                              : flag  - 0: unmounted
''                              :         1: mounted
  flag:=\sdfat.checkPartitionMounted

PUB sdcheckopen: flag                                   'sd-card: test ob datei geöffnet ist
''funktionsgruppe               : sdcard
''funktion                      : test ob eine datei geöffnet ist
''busprotokoll                  : [014][get.flag]
''                              : flag  - 0: not open
''                              :         1: open

  flag:=\sdfat.checkFileOpen

PUB sdcheckused:wert                                        'sd-card: abfrage der benutzten sektoren
''funktionsgruppe               : sdcard
''funktion                      : anzahl der benutzten sektoren senden
''busprotokoll                  : [015][sub_getlong.used]
''                              : used - anzahl der benutzten sektoren
  wert:=\sdfat.checkUsedSectorCount("F")

PUB sdcheckfree:wert                                         'sd_card: abfrage der freien sektoren
''funktionsgruppe               : sdcard
''funktion                      : anzahl der freien sektoren senden
''busprotokoll                  : [016][sub_getlong.free]
''                              : free - anzahl der freien sektoren

  wert:=\sdfat.checkFreeSectorCount("F")

PUB sdnewfile(stradr):err                               'sd_card: neue datei erzeugen
''funktionsgruppe               : sdcard
''funktion                      : eine neue datei erzeugen
''busprotokoll                  : [017][sub_putstr.fn][get.error]
''                              : fn - name der datei
''                              : error - fehlernummer entspr. liste
   err := \sdfat.newFile(stradr)

PUB sdnewdir(stradr):err                                'sd_card: neues verzeichnis erzeugen
''funktionsgruppe               : sdcard
''funktion                      : ein neues verzeichnis erzeugen
''busprotokoll                  : [018][sub_putstr.fn][get.error]
''                              : fn - name des verzeichnisses
''                              : error - fehlernummer entspr. liste


   err := \sdfat.newDirectory(stradr)

PUB sddel(stradr):err                                   'sd_card: datei/verzeichnis löschen
''funktionsgruppe               : sdcard
''funktion                      : eine datei oder ein verzeichnis löschen
''busprotokoll                  : [019][sub_putstr.fn][get.error]
''                              : fn - name des verzeichnisses oder der datei
''                              : error - fehlernummer entspr. liste
   err := \sdfat.deleteEntry(stradr)

PUB sdrename(stradr1,stradr2):err                       'sd_card: datei/verzeichnis umbenennen
''funktionsgruppe               : sdcard
''funktion                      : datei oder verzeichnis umbenennen
''busprotokoll                  : [020][sub_putstr.fn1][sub_putstr.fn2][get.error]
''                              : fn1 - alter name
''                              : fn2 - neuer name
''                              : error - fehlernummer entspr. liste

   err := \sdfat.renameEntry(stradr1,stradr2)

PUB sdchattrib(stradr1,stradr2):err                     'sd-card: attribute ändern
''funktionsgruppe               : sdcard
''funktion                      : attribute einer datei oder eines verzeichnisses ändern
''busprotokoll                  : [021][sub_putstr.fn][sub_putstr.attrib][get.error]
''                              : fn - dateiname
''                              : attrib - string mit attributen (AHSR)
''                              : error - fehlernummer entspr. liste

  err := \sdfat.changeAttributes(stradr1,stradr2)

PUB sdchdir(stradr):err                                 'sd-card: verzeichnis wechseln
''funktionsgruppe               : sdcard
''funktion                      : verzeichnis wechseln
''busprotokoll                  : [022][sub_putstr.fn][get.error]
''                              : fn - name des verzeichnisses
''                              : error - fehlernummer entspr. list

  err := \sdfat.changeDirectory(stradr)

PUB sdformat(stradr):err                                'sd-card: medium formatieren
''funktionsgruppe               : sdcard
''funktion                      : medium formatieren
''busprotokoll                  : [023][sub_putstr.vlabel][get.error]
''                              : vlabel - volumelabel
''                              : error - fehlernummer entspr. list

  err := \sdfat.formatPartition(0,stradr,0)


PUB sdunmount:err                                       'sd-card: medium abmelden
''funktionsgruppe               : sdcard
''funktion                      : medium abmelden
''busprotokoll                  : [024][get.error]
''                              : error - fehlernummer entspr. list

  err := \sdfat.unmountPartition
  ifnot err
    clr_dmarker


PUB sddmact(marker):err                                 'sd-card: dir-marker aktivieren
''funktionsgruppe               : sdcard
''funktion                      : ein ausgewählter dir-marker wird aktiviert
''busprotokoll                  : [025][put.dmarker][get.error]
''                              : dmarker - dir-marker
''                              : error   - fehlernummer entspr. list


  ifnot dmarker[marker] == TRUE
    sdfat.setDirCluster(dmarker[marker])
    err:=sdfat#err_noError
  else
    err:=sdfat#err_noError

PUB sddmset(marker)                                     'sd-card: dir-marker setzen
''funktionsgruppe               : sdcard
''funktion                      : ein ausgewählter dir-marker mit dem aktuellen verzeichnis setzen
''busprotokoll                  : [026][put.dmarker]
''                              : dmarker - dir-marker

  dmarker[marker] := sdfat.getDirCluster

PUB sddmget(marker):status                              'sd-card: dir-marker abfragen
''funktionsgruppe               : sdcard
''funktion                      : den status eines ausgewählter dir-marker abfragen
''busprotokoll                  : [027][put.dmarker][sub_getlong.dmstatus]
''                              : dmarker  - dir-marker
''                              : dmstatus - status des markers

  status:=dmarker[marker]

PUB sddmclr(marker)                                     'sd-card: dir-marker löschen
''funktionsgruppe               : sdcard
''funktion                      : ein ausgewählter dir-marker löschen
''busprotokoll                  : [028][put.dmarker]
''                              : dmarker - dir-marker
  dmarker[marker] := TRUE

PUB sddmput(marker,status)                              'sd-card: dir-marker status setzen
''funktionsgruppe               : sdcard
''funktion                      : dir-marker status setzen
''busprotokoll                  : [027][put.dmarker][sub_putlong.dmstatus]
''                              : dmarker  - dir-marker
''                              : dmstatus - status des markers

  dmarker[marker] := status

PUB clr_dmarker| i                                      'chip: dmarker-tabelle löschen
''funktionsgruppe               : chip
''funktion                      : dmarker-tabelle löschen
''eingabe                       : -
''ausgabe                       : -

    i := 0
    repeat 6                                            'alle dir-marker löschen
      dmarker[i++] := TRUE

PUB reggetcogs:regcogs |i,c,cog[8]                      'system: fragt freie cogs von regnatix ab
''funktionsgruppe               : system
''funktion                      : fragt freie cogs von regnatix ab
''eingabe                       : -
''ausgabe                       : regcogs - anzahl der belegten cogs
''busprotokoll                  : -

  regcogs := i := 0
  repeat 'loads as many cogs as possible and stores their cog numbers
    c := cog[i] := cognew(@entry, 0)
    if c=>0
      i++
  while c => 0
  regcogs := i
  repeat 'unloads the cogs and updates the string
    i--
    if i=>0
      cogstop(cog[i])
  while i=>0
con' ######################################### Seriell-Funktionen ############################################################
PUB ser_rx

    return ser.rx
Pub ser_tx(w)

    ser.tx(w)

pub ser_str(strptr)

    ser.str(strptr)

pub ser_dec(n)

    ser.dec(n)

pub ser_hex(n,digit)

    ser.hex(n,digit)

pub ser_bin(n,digit)

    ser.bin(n,digit)

pub ser_flush

    ser.rxflush

pub ser_rxcheck

    return ser.rxcheck
con' ######################################### Seriell2-Funktionen ############################################################
{pub ser2_open(bd)
    ser2.start(31, 30,0,bd)'0, baud)                              'serielle Schnittstelle starten
    'ser.str(string("Start"))

PUB ser2_rx

    return ser2.rx
Pub ser2_tx(w)

    ser2.tx(w)

pub ser2_str(strptr)

    ser2.str(strptr)

pub ser2_dec(n)

    ser2.dec(n)

pub ser2_hex(n,digit)

    ser2.hex(n,digit)

pub ser2_bin(n,digit)

    ser2.bin(n,digit)

pub ser2_flush

    ser2.rxflush

pub ser2_rxcheck

    return ser2.rxcheck
pub ser2_close

    ser2.stop
    }
con' ######################################### Date und Timefunktionen #######################################################
PUB getSeconds                                          'Returns the current second (0 - 59) from the real time clock.
    return rtc.getSeconds
PUB getMinutes                                          'Returns the current minute (0 - 59) from the real time clock.
    return rtc.getMinutes
PUB getHours                                            'Returns the current hour (0 - 23) from the real time clock.
    Return rtc.getHours
PUB getDay                                              'Returns the current day (1 - 7) from the real time clock.
    return rtc.getDay
PUB getDate                                             'Returns the current date (1 - 31) from the real time clock.
    return rtc.getDate
PUB getMonth                                            'Returns the current month (1 - 12) from the real time clock.
    return rtc.getMonth
PUB getYear                                             'Returns the current year (2000 - 2099) from the real time clock.
    return rtc.getYear
PUB setSeconds(seconds)                                 'Sets the current real time clock seconds.
                                                        'seconds - Number to set the seconds to between 0 - 59.
  if seconds => 0 and seconds =< 59
     rtc.setSeconds(seconds)

PUB setMinutes(minutes)                                 'Sets the current real time clock minutes.
                                                        'minutes - Number to set the minutes to between 0 - 59.
  if minutes => 0 and minutes =< 59
     rtc.setMinutes(minutes)

PUB setHours(hours)                                     'Sets the current real time clock hours.
                                                        'hours - Number to set the hours to between 0 - 23.
  if hours => 0 and hours =< 23
     rtc.setHours(hours)

PUB setDay(day)                                         'Sets the current real time clock day.
                                                        'day - Number to set the day to between 1 - 7.
  if day => 1 and day =< 7
     rtc.setDay(day)

PUB setDate(date)                                       'Sets the current real time clock date.
                                                        'date - Number to set the date to between 1 - 31.
  if date => 1 and date =< 31
     rtc.setDate(date)

PUB setMonth(month)                                     'Sets the current real time clock month.
                                                        'month - Number to set the month to between 1 - 12.
  if month => 1 and month =< 12
     rtc.setMonth(month)

PUB setYear(year)                                       'Sets the current real time clock year.
                                                        'year - Number to set the year to between 2000 - 2099.
  if year => 2000 and year =< 2099
     rtc.setYear(year)

CON ''------------------------------------------------- SCREEN
PUB print(stringptr)'|c                                    'screen: bildschirmausgabe einer zeichenkette (0-terminiert)
{{print(stringptr) - screen: bildschirmausgabe einer zeichenkette (0-terminiert)}}
    ser.str(stringptr)
    'repeat strsize(stringptr)
    '     ser.str(string(27,"[P"))     'Ein Zeichen von rechts nachrücken, sonst werden Grafiken bei Textausgabe zerstört
    ' repeat strsize(stringptr)
    '    c:=byte[stringptr++]
    '       bus_putchar2(c)


PUB printdec(value) | i ,c ,x                             'screen: dezimalen zahlenwert auf bildschirm ausgeben
{{printdec(value) - screen: dezimale bildschirmausgabe zahlenwertes}}
  if value < 0                                          'negativer zahlenwert
    -value
    printchar("-")

  i := 1_000_000_000
  repeat 10                                             'zahl zerlegen
    if value => i
      x:=value / i + "0"
      printchar(x)
      c:=value / i + "0"
      value //= i
      result~~
    elseif result or i == 1
      printchar("0")
    i /= 10                                             'nächste stelle

PUB printhex(value, digits)                             'screen: hexadezimalen zahlenwert auf bildschirm ausgeben
{{hex(value,digits) - screen: hexadezimale bildschirmausgabe eines zahlenwertes}}
  value <<= (8 - digits) << 2
  repeat digits
    printchar(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))


PUB printbin(value, digits) |c                            'screen: binären zahlenwert auf bildschirm ausgeben

  value <<= 32 - digits
  repeat digits
     c:=(value <-= 1) & 1 + "0"
     printchar(c)

PUB printchar(c)':c2                                     'screen: einzelnes zeichen auf bildschirm ausgeben
{{printchar(c) - screen: bildschirmausgabe eines zeichens}}
   ser.tx(c)
   'ser.str(string(27,"[P"))     'Ein Zeichen von rechts nachrücken, sonst werden Grafiken bei Textausgabe zerstört
  'bus_putchar2(c)               'Zeichen mit Tilefont

PUB printqchar(c)':c2                                    'screen: zeichen ohne steuerzeichen ausgeben
{{printqchar(c) - screen: bildschirmausgabe eines zeichens}}
   if c<32 or c>126
      c:="."
   ser.tx(c)

PUB printnl                                             'screen: $0D - CR ausgeben
{{printnl - screen: $0D - CR ausgeben}}
    ser.tx(13)
CON ''------------------------------------------------- TOOLS
PUB Dump(adr,line,mod) |zeile ,c[8] ,i  'adresse, anzahl zeilen,ram oder xram
  zeile:=0
  'p:=getx+23
  repeat line
    printnl
    if (mod>0)
       printhex(adr,8)
    else
       printhex(adr,5)
    print(string(" : "))

    repeat i from 0 to 7
      'if mod==3
      '   c[i]:=Read_Flash_Data(adr++)                   '-Flash
      'if mod==2
      '   c[i]:=i2c_rd_byte(adr++)                       '-EEPROM
      if mod==1
           c[i]:=ram_rdbyte(adr++)                      '-E-Ram
      if mod==0
         c[i]:=byte[adr++]                              '-Hub-Ram
      printhex(c[i],2)
      printchar(" ")

    printchar(" ")

    repeat i from 0 to 7
      printqchar(c[i])

    zeile++
    if zeile == 12
       printnl
       print(string("<CONTINUE? */Str-X:>"))
       if ser.rx == 24
          printnl
            quit
       zeile:=0
  printnl


pub time|h,m,s
   ' setpos(y,x)
    s:=getSeconds
   if s<>tmptime
      h:=gethours
      m:=getMinutes
        if h<10
           printchar("0")
        printdec(h)
        printchar(":")
        if m<10
           printchar("0")
        printdec(m)
        printchar(":")
        if s<10
           printchar("0")
        printdec(s)
        tmptime:=s

DAT
                        org 0
'
' Entry
'
entry                   jmp     #entry                   'just loops


{{

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}

                                                                                                                                            
