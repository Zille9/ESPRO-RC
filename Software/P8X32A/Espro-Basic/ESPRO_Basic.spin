{{ ---------------------------------------------------------------------------------------------------------

ESPRO-RC-Projekt

Name            : Tiny-Basic für einen Propeller mit SPI PSRAM 64MBit und ESP32 als VGA-terminal
Chip            : P8X32 - Propeller-Chip
Version         : 3.5
Dateien         :

Beschreibung    : Modifiziertes, stark erweitertes FemtoBasic ESPRO 1 Propeller-Chip Computer.

Eigenschaften   : -Benutzung externer Ram, Stringverarbeitung, Array-Verwaltung
                  -Gleitkommafuktion
                  -Syntaxhervorhebung
                  -VGA 640x480 Pixel 64Farben
                  -15 FONTS auswählbar
                  -lange Variablennamen
                  -dynamische Variablen-Verwaltung
                  -Pixelgrafik
                  -Treiber für:
                  -WS2812
                  -DS18B12 Dallas Temperatur-Fühler
                  -I2C - Routinen
                  -Port-Ein-und Ausgabe
                  -RTC-Clock

Logbuch         :
'############################################################ Version 1.2 ######################################################################################################
01-03-2021      -vom Trios-Basic 3.5 abgeleitete Basic-Version für eine Ein-Propeller-Chip-Version mit Seriell-Interface
                -als Ram dient ein 8Mbyte PSRAM-Chip PSRAM64H
                -Grundfunktionen erstellt, Ausgabe zur Zeit über serielle Schnittstelle
                -je nachdem, wieviel Speicher die SD-Card und RTC-Funktionen fressen, könnte noch ein ganz einfacher VGA oder TV-treiber integriert werden
                -Ram-Funktionen als Spin-Code eingefügt -> ist sehr langsam, keine Ahnung,ob ich das auf PASM hinbekomme.
                -3326 Longs frei

04-03-2021      -Ram-Routinen liegen jetzt als PASM-Code vor und funktionieren tadellos :-)
                -der Geschwindigkeitsunterschied zu Spin ist enorm (8MB in ca.7 sek gefüllt - in (optimierte Routinen) Spin ca.40sek.)
                -flüssiges Arbeiten ist jetz kein Problem und kostet nur 28 Longs :-)
                -3298 Longs frei

16-03-2021      -Timerfunktionen erst einmal deaktiviert, es wird noch Platz gebraucht für Busroutinen
                -geplant ist, einen ESP32 als Grafikkarte (mit FabGL) und Tastatur/Mausinterface zu benutzen
                -damit sind Text-und Pixelgrafik bei einer Auflösung von 640x480 Pixel und 256 Farben möglich
                -SD-Card + RTC Treiber eingebunden und funktionsfähig ->kostet aber einiges an Speicher :-(
                -bisher 84 Basic-Befehle übernommen
                -jetzt wird erst einmal die Busübertragung vom und zum ESP32 realisiert
                -1872 Longs frei

23-03-2021      -Busübertragung funktioniert nicht, auf serielle Übertragung umgestiegen (VT100-Protokoll)
                -Anpassungen an FabGl-VT100-Terminal, Cursorfunktionen, Zeileneditierung funktioniert
                -Farben ändern funktioniert, über ESC Sequenzen auch spezielle Textfunktionen möglich (doppelte Text-breite oder -höhe,
                -blinkender Text, Unterstreichung usw.
                -mal sehen, ob auch die Grafikfunktionen realisierbar (über seriell) sind
                -Load-und Save-Funktion (Processload/Processsave) auf reine Textdateien reduziert
                -1662 Longs frei

24-03-2021      -Grafikfunktionen integriert ->Pset, Line, Rect, Circle, GScroll,Pen, Brush, Width
                -Polygon-Funktion kommt noch
                -Fehler in Load-Routine behoben (Programm wurde an vorhandenes Programm angehangen)
                -1480 Longs frei

25-03-2021      -Polygonfunktion funktioniert jetzt auch
                -Spritefunktion begonnen
                -1349 Longs frei

29-03-2021      -PS-RAM, SD_Card und RTC-Funkzionen in reg_tiny.spin ausgelagert
                -Fehler in FOR-NEXT-Schleife entdeckt ->zweibuchstabige Variablen werden ab s nicht korrekt verarbeitet (sr=ok ss=nicht ok)
                -im Hive-Max besteht der Fehler nicht !? ob das an den PSRAM-Routinen liegt? Normales Speichern der Variablen funktioniert komischerweise
                -sy=123 -> funktioniert, nur in For-Next-Schleifen wird falsch geschrieben :-(
                -Processload und -Save ausgelagert - jetzt wieder gleiche Funktionalität, wie im Trios-Basic
                -Sprite-Funktion erstmal wieder deaktiviert -> noch nicht wirklich nutzbar da keine kollisionserkennung und das Prinzip des Sprite-Datenformats noch unklar
                -um das volle Potential des ESP und FabGl zu nutzen brauche ich unbedingt eine alternative Datenübertragung (8bit Bus funktioniert nicht)
                -mal sehen, ob eine Übertragung per SPI realisierbar ist, das würde einiges leichter machen.
                -1395 Longs frei

30-03-2021      -Fehler in FOR-NEXT-Verarbeitung gefunden ->für die menge an möglichen Variablen waren die Long-Variablen zu klein dimensioniert
                -FOR_NEXT[26] ist zu wenig ->Variablen in den Ram verschoben, dort ist genug Platz für knapp 4000 Longs, dadurch wieder etwas Arbeitsspeicher eingespart
                -For-Next-Schleifen funktionieren jetzt auch mit allen Buchstaben aa-zz -> muss auch in's Trios-Basic übernommen werden!
                -Tab-Funktion etabliert Print, (Komma) hat jetzt die richtige Wirkung
                -Tab(n) funktioniert etwas anders als gewohnt ->n entspricht immer 8 Zeichenpositionen bei 80 Zeichen sind das 9 Tabulatoren
                -da diese Basic-Version für Spiele mit schneller Grafik nicht geeignet ist, konzentriere ich mich auf die Integration von Funktionen
                -für z.Bsp.LCD-Display's, 1wire oder i2c-Devices am ESP32 oder Propeller für Experimente
                -1486 Longs frei

31-03-2021      -I2C-Funktionen integriert (standard-Funktionen, Read,Write,Wait)
                -LED-Funktion zur Ansteuerung von WS2812-LED-Strips, es sind maximal 150 LED's adressierbar (entspricht einem 5m-LED-Strip mit 30LED/m)
                -DS18B12-Dallas-Temperaturfühler-Treiber eingebaut - Temperaturwert wird mit dem Befehl Temp abgefragt ->muss ich noch testen
                -Befehl FONT eingebaut, es sind 16 Font-Typen auswählbar (0-15) ->Font 0 ist der Standardfont
                -Funktionstasten wieder integriert ->F1-F6
                -DIR-Ausgabe auf Standard begrenzt ->nur sichtbare,erweiterte Ausgabe
                -I2C-Ping Ausgabe funktioniert, ob die anderen Funktionen funktionieren,muss ich noch testen
                -779 Longs frei

03-04-2021      -List-Syntaxhervorhebung wieder eingebaut, jetzt wird der Speicher allerdings langsam knapp
                -Clearing-Routine um For-Next-Speicherbereich erweitert, wird beim Programmstart gelöscht
                -Startbild vom ESP in den Prop überführt - macht den Treiber im ESP universell
                -Fehler in REM-Befehl behoben ->wurde bei Print-Befehl als Fehler behandelt
                -668 Longs frei

19-04-2021      -massive Probleme mit dem PSRAM-Chip, ständig Lesefehler, das frustriert :-(
                -mal sehen, wie ich das Problem beheben kann, hab momentan keine Ahnung, warum es jetzt nicht mehr funktioniert (hatte so lange fehlerfreien Betrieb)
                -675 Longs frei

 --------------------------------------------------------------------------------------------------------- }}

obj
  ios    :"reg_tiny"                                    '0Cog
  FS     :"BasFloatString2"                             '0Cog
  Fl     :"BasF32.spin"                                 '1Cog
  TMRS   :"timer"                                       '1Cog

  LED    :"WS2812RadioShack"                            '1Cog temporär (bei Bedarf zuschaltbar)
  OW     :"OneWire"                                     '1Cog temporär (bei Bedarf zuschaltbar)
{{Hauptprogramm }}                                      '1Cog
                                                        '--------
                                                        '3Cog's +2tmp

con

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

   version   = 1.2

   fEof      = $FF                     ' dateiende-kennung
   linelen   = 80                      ' Maximum input line length
   quote     = 34                      ' Double quote
   caseBit   = !32                     ' Uppercase/Lowercase bit
   point     = 46                      ' point
   FIELD_LEN = 64000                   ' Array-Feldgröße (max Feldgröße 40x40x40 -> Dim a(39,39,39)
   DIR_ENTRY = 546                     ' max.Anzahl mit DIR-Befehl gefundener Einträge
   STR_MAX   = linelen                 ' maximale Stringlänge für Printausgaben und Rom
'*****************Speicherbereiche**********************************************
   maxstack  = 20                      ' Maximum stack tiefe fuer gosub
   userptr   = $1FFFF                  ' Ende Programmspeicher  128kb
   TMP_RAM   = $20000 '.... $3FFFF     ' Bearbeitungsspeicher   128kb (fuer die Zeileneditierung bzw.Einfuegung von Zeilen)
   DIR_RAM   = $40000 '.... $4FFFF     ' Puffer fuer Dateinamen 64Bytes fuer 5041 Dateinamen
   DATA_RAM  = $50000 '.... $5FFFF     ' 64kB DATA-Speicher
   FUNC_RAM  = $60000 '.... $609FF     ' Funktions-Speicher, hier werden die selbstdefinierten Funktionen gespeichert
   FOR_LOOP  = $61000 '.... $61FFF     ' For-Loop Speicher
   FOR_STEP  = $62000 '.... $62FFF     ' FOR-Step Speicher
   FOR_LIMIT = $63000 '.... $63FFF     ' FOR-Limit Speicher

   ERROR_RAM = $70000 '.... $705FF     ' ERROR-Texte

   PMARK_RAM = $7FFF0                  ' Flag für Reclaim           Wert= 161
   BMARK_RAM = $7FFF1                  ' Flag für Basic-Warm-Start  Wert= 121
   SMARK_RAM = $7FFF2                  ' Flag für übergebenen Startparameter Wert = 222

   STR_ARRAY = $80000 '....$EE7FF      ' Variablen und Stringarray-Speicher

   USER_RAM  = $EE800 '....$FAFFF      ' Freier Ram-Bereich, für Anwender, Backup-Funktion usw. 51200Bytes 50kb

   VAR_TBL   = $FB000 '....$FCFFF      ' Variablen-Tabelle
   STR_TBL   = $FD000 '....$FEFFF      ' String-Tabelle

'   SPRITE_TBL= $100000 '....10FFFF     ' Datenbereich für Sprites
'***************** Button-Anzahl ************************************************
   BUTTON_CNT   = 32                       'Anzahl der möglichen Button
'******************Farben Mode0,2,3,4 *******************************************
  #$FC, Light_Grey, #$A8, Grey, #$54, Dark_Grey
  #$C0, Light_Red, #$80, Red, #$40, Dark_Red
  #$30, Light_Green, #$20, Green, #$10, Dark_Green
  #$1F, Light_Blue, #$09, Blue, #$04, Dark_Blue
  #$F0, Light_Orange, #$E6, Orange, #$92, Dark_Orange
  #$CC, Light_Purple, #$88, Purple, #$44, Dark_Purple
  #$3C, Light_Teal, #$28, Teal, #$14, Dark_Teal
  #$FF, White, #$00, Black


'Zeichencodes

CHAR_RETURN     = $0D                                   'eingabezeichen
CHAR_NL         = $0D                                   'newline
CHAR_SPACE      = $20                                   'leerzeichen
CHAR_BS         = $08                                   'tastaturcode backspace
CHAR_TER_BS     = $08                                   'terminalcode backspace
CHAR_ESC        = $1B
CHAR_LEFT       = $02
CHAR_RIGHT      = $03
CHAR_UP         = $0B
CHAR_DOWN       = $0A
KEY_CTRL        = $02
KEY_ALT         = $04
KEY_OS          = $08

{'***************** VT100-Codes ***************************************************
 ArrowLeft      =68            'Arrow left
 ArrowRight     =67            'Arrow right
 ArrowUp        =65            'Arrow up
 ArrowDown      =66            'Arrow down
 ArrowHome      =49            'Home
 ArrowEnd       =52            'End
 ArrowPageup    =53            'Page up
 ArrowPageDown  =54            'Page down
 ArrowBack      =8             'Convert Backspace
 ArrowDel       =51            'DEL
 ArrowInsert    =50            'Insert
}
'*****************Tastencodes*****************************************************
   ENTF_KEY  = 186
   bspKey    = $C8                     ' PS/2 keyboard backspace key
   breakKey  = $CB                     ' PS/2 keyboard escape key
   fReturn   = 13
   fLinefeed = 10
   KEY_LEFT  = 2
   KEY_RIGHT = 3
   KEY_UP    = 4
   KEY_DOWN  = 5

   MIN_EXP   = -99999
   MAX_EXP   =  999999

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
   Bauds        = 57600
   RX           = 24
   TX           = 25
   num_of_toks  = 101

'Farben
Schwarz =0
ROT     =1
GRUEN   =2
GELB    =3
BLAU    =4
PINK    =5
CYAN    =6
WEISS   =7
GRAU    =8
HROT    =9
HGRUEN  =10
HGELB   =11
HBLAU   =12
HPINK   =13
HCYAN   =14
HWEISS  =15

'DS1812 Parameter
  OW_DATA           = 0                                 ' 1-wire data pin

  SKIP_ROM          = $CC                               ' 1-wire commands
  READ_SCRATCHPAD   = $BE
  CONVERT_T         = $44

  CLS               = $00                               ' clear screen
  HOME              = $01                               ' home
  CR                = $0D                               ' carriage return
  DEG               = $B0                               ' degree symbol

var
   long sp, tp, nextlineloc, rv, curlineno, pauseTime                         'Goto,Gosub-Zähler,Kommandozeile,Zeilenadresse,Random-Zahl,aktuelle Zeilennummer, Pausezeit
   long stack[maxstack],speicheranfang,speicherende                           'Gosub,Goto-Puffer,Startadresse-und Endadresse des Basic-Programms
'   long forStep[26], forLimit[26], forLoop[26]                                'Puffer für For-Next Schleifen
   long prm[10]                                                               'Befehlszeilen-Parameter-Feld (hier werden die Parameter der einzelnen Befehle eingelesen)
   long gototemp,gotobuffer,gosubtemp,gosubbuffer                             'Gotopuffer um zu verhindern das bei Schleifen immer der Gesamte Programmspeicher nach der Zeilennummer durchsucht werden muss
   long datapointer                                                           'aktueller Datapointer
   long restorepointer                                                        'Zeiger für den Beginn des aktuellen DATA-Bereiches
   long usermarker,basicmarker                                                'Dir-Marker-Puffer für Datei-und Verzeichnis-Operationen
   long Var_Neu_Platz                                                         'nächste freie Variablen-Adresse
   long tp_back                                                               'sicherheitskopie von tp ->für Input

   word filenumber                                                            'Anzahl der mit Dir gefundenen Dateien
   word VAR_NR                                                                'Variablenzähler
   word STR_NR                                                                'Stringzähler
   byte var_arr[3]                                                            'temp array speicher varis-funktion für direkten Zugriff
   byte var_tmp[3]                                                            'temp array speicher varis-funktion für zweite Variable (in pri factor) um Rechenoperationen u.a. auszuführen
   byte var_temp[3]                                                           'temp array speicher erst mit dem dritten Speicher funktioniert die Arrayverwaltung korrekt

   byte prm_typ[10]                                                           'parametertyp variable oder string
   byte workdir[12]                                                           'aktuelles Verzeichnis
   byte fileOpened,tline[linelen]',tline_back[linelen]                         'File-Open-Marker,Eingabezeilen-Puffer,Sicherheitskopie für tline ->Input-Befehl
   byte file1[12],dzeilen,buff[8],modus                                       'Dir-Befehl-variablen   extension[12]
   byte str0[STR_MAX],strtmp[STR_MAX]                                         'String fuer Fontfunktion in Fenstern
   byte font[STR_MAX]                                                         'Stringpuffer fuer Font-Funktion und str$-funktion
   byte ongosub                                                               'on gosub variable
   byte f0[STR_MAX]                                                           'Hilfsstring
   byte returnmarker                                                          'Abbruchmarker für Zeileneditor
   byte editmarker                                                            'Editmarker für Zeileneditor
   byte tmptime
   byte farbe,hintergr
   byte fontsatz                                                              'ausgewählter Fontsatz
   byte SCL,SDA                                                               'I2C-Pins


dat
   tok0  byte "IF",0                                                                       '128    getestet
   tok1  byte "THEN",0                                                                     '129    getestet
   tok2  byte "INPUT",0     ' INPUT {"<prompt>";} <var> {,<var>}                           '130    getestet
   tok3  byte "PRINT",0     ' PRINT                                                        '131    getestet
   tok4  byte "GOTO",0                                                                     '132    getestet
   tok5  byte "GOSUB", 0                                                                   '133    getestet
   tok6  byte "RETURN", 0                                                                  '134    getestet
   tok7  byte "REM", 0                                                                     '135    getestet
   tok8  byte "NEW", 0                                                                     '136    getestet
   tok9  byte "LIST", 0     ' list <expr>,<expr> listet von bis zeilennummer                137    getestet
   tok10 byte "RUN", 0                                                                     '138    getestet
   tok11 byte "RND", 0      ' Zufallszahl von x                                            '139    getestet
   tok12 byte "OPEN", 0     ' OPEN " <file> ",<mode>                                        140    getestet
   tok13 byte "FREAD", 0    ' FREAD <var> {,<var>}                                          141    getestet
   tok14 byte "WRITE", 0    ' WRITE <"text"> :                                              142    getestet
   tok15 byte "CLOSE", 0    ' CLOSE                                                         143    getestet
   tok16 byte "DEL", 0      ' DELETE " <file> "                                             144    getestet
   tok17 byte "REN", 0      ' RENAME " <file> "," <file> "                                  145    getestet
   tok18 byte "DIR", 0      ' dir anzeige                                                   146    getestet
   tok19 byte "SAVE", 0     ' SAVE or SAVE [<expr>] or SAVE "<file>"                        147    getestet
   tok20 byte "LOAD", 0     ' LOAD or LOAD [<expr>] or LOAD "<file>" ,{<expr>}              148    getestet
   tok21 byte "NOT" ,0      ' NOT <logical>                                                '139    getestet
   tok22 byte "AND" ,0      ' <logical> AND <logical>                                      '150    getestet
   tok23 byte "OR", 0       ' <logical> OR <logical>                                       '151    getestet
   tok24 byte "GFILE",0     ' GETFILE rueckgabe der mit Dir gefundenen Dateien ,Dateinamen  152    getestet
   tok25 byte "NEXT", 0     ' NEXT <var>                                                    153    getestet
   tok26 byte "FOR", 0      ' FOR <var> = <expr> TO <expr>                                  154    getestet
   tok27 byte "TO", 0                                                                      '155    getestet
   tok28 byte "STEP", 0     'optional STEP <expr>                                           156    getestet
   tok29 byte "RENUM",0     'Renumberfunktion                                               157    getestet
   tok30 byte "GATTR",0     'Dateiattribute auslesen                                        158    getestet
   tok31 byte "VAL",0       'String in FLOAT-Zahlenwert umwandeln                           159    getestet
   tok32 byte "SQR",0                                                                    '  160    getestet
   tok33 byte "EXP",0                                                                  '    161    getestet
   tok34 byte "INT",0                                                                     ' 162    getestet
   tok35 byte "LOWER$", 0   'String in Kleinbuchstaben zurückgeben                          163    getestet
   tok36 byte "COMP$", 0    'Stringvergleich                                                164    getestet
   tok37 byte "LEN", 0      'Stringlänge zurueckgeben                                       165    getestet
   tok38 byte "READ", 0     'Data Lesen                                                    '166    getestet
   tok39 byte "LN",0                                                                   '    167    getestet
   tok40 byte "DATA", 0     'Data-Anweisung                                                '168    getestet
   tok41 byte "ABS",0                                               '                       169    getestet
   tok42 byte "SYS",0       'Systemfunktionen z.Bsp.anderer Grafikmodus                    '170    getestet
   tok43 byte "SGN",0                                                                   '   171    getestet
   tok44 byte "SIN",0                                                                     ' 172    getestet
   tok45 byte "COS",0                                                                     ' 173    getestet
   tok46 byte "PI",0        'Kreiszahl PI                                                  '174    getestet
   tok47 byte "RESTORE", 0  'Data-Zeiger zurücksetzen                                       175    getestet
   tok48 byte "CHR$", 0     'CHR$(expr)                                                     176    getestet
   tok49 byte "TAN",0                                                                  '    177    getestet
   tok50 byte "ATN",0                                                                     ' 178    getestet
   tok51 byte "INSTR",0     'Zeichenkette in einer anderen Zeichenkette suchen           '  179    getestet
   tok52 byte "END", 0      '                                                               180    getestet
   tok53 byte "PAUSE", 0    ' PAUSE <time ms> {,<time us>}                                  181    getestet
   tok54 byte "FILE", 0     ' FILE wert aus datei lesen oder in Datei schreiben             182    getestet
   tok55 byte "ELSE",0                                                                    ' 183    getestet
   tok56 byte "TAB", 0      'Tabulator setzen                                               184    getestet
   tok57 byte "MKFILE", 0   'Datei erzeugen                                                 185    getestet
   tok58 byte "DUMP", 0     ' DUMP <startadress>,<anzahl zeilen>,<0..1> (0 Hram,1 Eram)     186    getestet
   tok59 byte "HEX",0       'Ausgabe von Hexzahlen mit Print                              ' 187    getestet
   tok60 byte "STRING$",0   'Zeichenwiederholung                                            188    getestet
   tok61 byte "DIM",0       'Stringarray dimensionieren                                     189    getestet
   tok62 byte "EDIT",0      'Zeile editieren                                                190    getestet
   tok63 byte "BLOAD",0     'Bin Datei laden                                                191    getestet
   tok64 byte "ASC",0       'ASCII-Wert einer Stringvariablen zurueckgeben                  192    getestet
   tok65 byte "UPPER$",0    'String in Großbuchstaben zurückgeben                         ' 193    getestet
   tok66 byte "CHDIR",0    ' Verzeichnis wechseln                                           194    getestet      kann nicht CD heissen, kollidiert sonst mit Hex-Zahlen-Auswertung in getanynumber
   tok67 byte "MID$",0      'Teilstring ab Position n Zeichen zurückgeben                 ' 195    getestet
   tok68 byte "RIGHT$",0    'rechten Teilstring zurückgeben                                '196    getestet
   tok69 byte "BEEP",0      'beep oder beep <expr> piepser in versch.Tonhoehen              197    getestet      'noch keine Funktion -> Platzprobleme
   tok70 byte "STIME",0     'Stunde:Minute:Sekunde setzen ->                                198    getestet
   tok71 byte "SDATE",0     'Datum setzen                                                   199    getestet
   tok72 byte "LEFT$",0     'linken Teilstring zurückgeben                                 '200    getestet
   tok73 byte "BIN",0       'Ausgabe von Binärzahlen mit Print                             '201    getestet
   tok74 byte "ON",0       ' ON GOSUB GOTO                                                  202    getestet
   tok75 byte "PEEK",0      'Byte aus Speicher lesen momentan nur eram                      203    getestet
   tok76 byte "GTIME",0     'Zeit   abfragen                                                204    getestet
   tok77 byte "GDATE",0     'Datum abfragen                                                 205    getestet
   tok78 byte "MKDIR",0     ' Verzeichnis erstellen                                         206    getestet
   tok79 byte "PORT",0      'Port-Funktionen      Port s,i,o,p                              207    getestet
   tok80 byte "POKE",0      'Byte in Speicher schreiben momentan nur eram                   208    getestet
   tok81 byte "CLEAR",0     'alle Variablen loeschen                                        209    getestet
   tok82 byte "INKEY",0     'Auf Tastendruck warten Rueckgabe ascii wert                    210    getestet
   tok83 byte "FN",0        'mathematische Benutzerfunktionen                               211    getestet
   tok84 byte "COLOR",0     'Color-Funktionen                                               212    getestet
   tok85 byte "CLS",0       'Bildschirm löschen                                             213    getestet
   tok86 byte "POS",0       'setze Cursorposition                                           214    getestet
   tok87 byte "TIMER",0     'Timer-Funktionen                                               215    getestet
'**************************** Grafik-Funktionen *******************************************************************
   tok88 byte "PSET",0      'Pixel setzen                                                   216    getestet
   tok89 byte "LINE",0      'Linie zeichnen                                                 217    getestet
   tok90 byte "RECT",0      'Rechteck zeichnen (gefüllt oder ungefüllt)                     218    getestet
   tok91 byte "CIRCLE",0    'Kreis oder Ellipse zeichnen (gefüllt oder ungefüllt)           219    getestet
   tok92 byte "POLYGON",0   'Polygon zeichnen (gefüllt oder ungefüllt)                      220    getestet
   tok93 byte "BRUSH",0     'Füllfarbe                                                      221    getestet
   tok94 byte "PEN",0       'Stiftfarbe                                                     222    getestet
   tok95 byte "WIDTH",0     'Stiftbreite                                                    223    getestet
   tok96 byte "GSCROLL",0   'Grafikbildschirm scrollen                                      224    getestet
   tok97 byte "CUR",0       'Cursor setzen oder löschen                                     225    getestet
   tok98 byte "I2C",0       'I2C - Funktion                                                 226    in Test
   tok99 byte "LED",0       'WS2812 LED-Strip                                               227    in Test
   tok100 byte"TEMP",0      'DS18D12 Temperatursensorwert lesen                             228    in Test
   tok101 byte"FONT",0      'Font ändern                                                    229    getestet
'******************************************************************************************************************

   toks  word @tok0, @tok1, @tok2, @tok3, @tok4, @tok5, @tok6, @tok7
         word @tok8, @tok9, @tok10, @tok11, @tok12, @tok13, @tok14, @tok15
         word @tok16, @tok17, @tok18, @tok19, @tok20, @tok21, @tok22, @tok23
         word @tok24, @tok25, @tok26, @tok27, @tok28, @tok29, @tok30, @tok31
         word @tok32, @tok33, @tok34, @tok35, @tok36, @tok37, @tok38, @tok39
         word @tok40, @tok41, @tok42, @tok43, @tok44, @tok45, @tok46, @tok47
         word @tok48, @tok49, @tok50, @tok51, @tok52, @tok53, @tok54, @tok55
         word @tok56, @tok57, @tok58, @tok59, @tok60, @tok61, @tok62, @tok63
         word @tok64, @tok65, @tok66, @tok67, @tok68, @tok69, @tok70, @tok71
         word @tok72, @tok73, @tok74, @tok75, @tok76, @tok77, @tok78, @tok79
         word @tok80, @tok81, @tok82, @tok83, @tok84, @tok85, @tok86, @tok87
         word @tok88, @tok89, @tok90, @tok91, @tok92, @tok93, @tok94, @tok95
         word @tok96, @tok97, @tok98, @tok99, @tok100, @tok101

DAT
   ext5          byte "*.*",0                                                   'alle Dateien anzeigen
   basicdir      byte "BASIC",0
   errortxt      byte "errors.txt",0                                            'Error-Texte
   importfile    byte "import.sys",0                                            'externe Funktion Import
   exportfile    byte "export.sys",0                                            'externe Funktion Export

con'****************************************** Hauptprogramm-Schleife *************************************************************************************************************
PUB main | sa

   init                                                                         'Startinitialisierung

   sa := 0                                                                      'startparameter
   curlineno := -1                                                              'startparameter

   repeat
      \doline(sa)                                                               'eine kommandozeile verarbeiten
      sa  := 0                                                                  'Zeile verwerfen da abgearbeitet

con'****************************************** Initialisierung *********************************************************************************************************************
PRI init

  waitcnt(clkfreq+cnt)                                                        'etwas warten auf ESP-Grafik
  pauseTime := 0                                                                'pause wert auf 0
  fileOpened := 0                                                               'keine datei geoeffnet
  speicheranfang:=$0                                                            'Programmspeicher beginnt ab adresse 0 im eRam
  speicherende:=$2                                                              'Programmende-marke
  ios.init
  FL.Start
  FS.SetPrecision(6)                                                            'Präzision der Fliesskomma-Arithmetik setzen
'*********************************** Timer-Cog starten ********************************************************************************************************
  TMRS.start(100)                                                               'Timer-Objekt starten mit 1ms-Aufloesung
'*********************************** Programm im Speicher?->wiederherstellen **********************************************************************************
  if (ios.ram_rdbyte(PMARK_RAM))==135
     reclaim
     ios.ram_wrbyte(0,PMARK_RAM)                                                'Reclaim-Marker löschen
  else
     ios.ram_fill(0,$FFFFF,$0)

'*********************************** Startparameter ***********************************************************************************************************
  ios.sdmount                                                                   'SD-Karte Mounten
  activate_dirmarker(0)                                                         'in's Rootverzeichnis
  ios.sdchdir(@basicdir)                                                        'in's Basicverzeichnis wechseln
  basicmarker:= get_dirmarker                                                   'usermarker von lesen
  usermarker:=basicmarker                                                       'basic-verzeichnis setzen


  ios.ram_fill(ERROR_RAM,$BF0,0)                                                'Errortext-Speicher loeschen
  mount
  ios.sdopen("R",@errortxt)
  fileload(ERROR_RAM)                                                           'Error-Text einlesen

'************ startparameter fuer Dir-Befehl *********************************************************************************************************
  dzeilen:=18
  modus  :=2                                                                    'Modus1=compact, 2=lang 0=unsichtbar
  hintergr:=schwarz
  farbe:=hCyan
  color_set(hintergr,farbe)
  ios.ser_tx($90)                                                               'Font 0 laden
  ios.print_cls                                                                 'bildschirm löschen
  errortext(40)                                                                 'Titelanzeige
  ios.ser_tx(9)                                                                 '3 Tabs weiter
  ios.ser_tx(9)
  ios.ser_tx(9)
  ios.printdec(userptr-speicherende)
  errortext(42)                                                                 'freie Bytes anzeigen
  'farbe:=hweiss
  'color_set(hintergr,farbe)                                                     'textfarbe auf weiss setzen
  ios.printnl

obj '************************** Datei-Unterprogramme ******************************************************************************************************************************
con '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PRI ifexist(dateiname) |c ,y                                                        'abfrage,ob datei schon vorhanden, wenn ja Überschreiben-Sicherheitsabfrage
   ios.printnl
   mount
   if ios.sdopen("W",dateiname)==0                                              'existiert die dateischon?
      errortext(8)                                                              '"File exist! Overwrite? y/n"    'fragen, ob ueberschreiben
      if ios.ser_rx=="y"
          if ios.sddel(dateiname)                                               'wenn ja, alte Datei loeschen, bei nein ueberspringen
             close
             return 0
          ios.sdnewfile(dateiname)
          ios.sdopen("W",dateiname)
          return 1
      elseif ios.ser_rx=="n"
         ios.printnl
         return 2                                                               'datei nicht ueberschreiben
   else                                                                         'wenn die Datei noch nicht existiert
      if ios.sdnewfile(dateiname)
         close
         return 0
      ios.sdopen("W",dateiname)
   ios.printnl
   return 1

PRI close
   ios.sdclose
   ios.sdunmount

PRI mount
     playerstatus
     ios.sdmount
     activate_dirmarker(usermarker)
     if strsize(@workdir)>0
        if strcomp(@workdir,string("\"))                                        'ins Root-Verzeichnis
           activate_dirmarker(0)
        else
           ios.sdchdir(@workdir)
        usermarker:=get_dirmarker
con '********************************** Basic-Programm als TXT-Datei von SD-Card Importieren oder Exportieren ******************************************************************
pri import(mode)|i,adr
    adr:=ios#PARAM
    i:=0
    repeat strsize(@f0)                                                               'Dateiname in Parameter-Ram schreiben
          ios.ram_wrbyte(f0[i++],adr++)
    ios.ram_wrbyte(0,adr++)

    if mode
       ios.ram_wrlong(speicherende-2,adr++)
    else
       ios.ram_wrlong(0,adr++)

    ios.ram_wrbyte(135,PMARK_RAM)                                                    'Programmmarker wird bei rüeckkehr abgefragt und das Programm im Speicher wieder hergestellt
    mount
    activate_dirmarker(basicmarker)                                             'ins Basic Stammverzeichnis
    if mode
       ios.sdopen("r",@exportfile)
       ios.BOOT_Partition(@exportfile)
    else
       ios.sdopen("r",@importfile)
       ios.BOOT_Partition(@importfile)
    close
con '********************************** Speicher und Laderoutinen der Basic-Programme als Binaerdateien, ist erheblich schneller *************************
pri binsave|datadresse,count
   datadresse:= 0
   count:=speicherende-2
   ios.sdxputblk(datadresse,count)
   close

PRI binload(adr)|count
    count:=fileload(adr)
    writeendekennung (adr+count)
    RAM_CLEAR

PRI RAM_CLEAR
    ios.ram_fill(speicherende,TMP_RAM-speicherende,0)                            'Programmspeicher hinter dem Programm loeschen

con '********************************** Fehler-und System-Texte in den eRam laden ****************************************************************************************************************
PRI fileload(adr): cont
    cont:=ios.sdfattrib(0)                                                      'Anzahl der in der Datei existierenden Zeichen
    ios.sdxgetblk(adr,cont)
    close

PRI errortext(nummer)|ad                                                    'Fehlertext anzeigen
    ad:=ERROR_RAM
    ram_txt(nummer,ad)
    ios.print(@font)                                                             'fehlertext
    if curlineno>0                                                           'Ausgabe der Zeilennummer bei Programmmodus (im Kommandomodus wird keine Zeilennummer ausgegeben)
       ios.print(string("in Line:"))
       ios.printdec(curlineno)
       Prg_End_Pos
       close
       abort
    ios.printchar(13)
    clearstr                                                                 'Stringpuffer löschen

PRI ram_txt(nummer,ad)|c,i
    i:=0
    repeat nummer
         repeat while (c:=ios.ram_rdbyte(ad++))<>10
                if nummer==1 and c>13
                    byte[@font][i++]:=c
         nummer--
    byte[@font][i]:=0

con'**************************************** Basic-Zeile aus dem Speicher lesen und zur Abarbeitung uebergeben ********************************************************************
PRI doline(s) | c,i,xm
   curlineno := -1                                                              'erste Zeile
   i:=0
   if ios.ser_rxcheck == 24                                                         'Wenn Str+X gedrueck dann?
        Prg_End_Pos                                                             'ans Programmende springen, um das Programm abzubrechen
        ios.printdec(xm)                                                            'Ausgabe der Zeilennummer bei der gestoppt wurde
        abort


   if nextlineloc < speicherende-2                                              'programm abarbeiten

      curlineno :=xm:=ios.ram_rdword(nextlineloc)                                   'Zeilennummer holen

'*******************Zeile aus eram holen*********************************************
      nextlineloc+=2
              repeat while tline[i++]:=ios.ram_rdbyte(nextlineloc++)

      tline[i]:=0
      tp:= @tline

      texec                                                                     'befehl abarbeiten


   else
      pauseTime := 0                                                            'oder eingabezeile

      if s
         bytemove(tp:=@tline,s,strsize(s))                                      'Zeile s in tp verschieben
      else
         if nextlineloc == speicherende - 2 and returnmarker==0                 'nächste Zeile, wenn Programm zu ende und nicht Return gedrückt wurde (da bei Eingabezeile ebenfalls ein Zeilenvorschub erzeugt wird)
            ios.printchar(13)
         returnmarker:=0
         ios.print(string("OK>"))                                                   'Promt ausgeben
         getline(0)                                                             'Zeile lesen und
      c := spaces
      if c=>"1" and c =< "9"                                                    'ueberprüfung auf Zeilennummer
         insertline2                                                            'wenn programmzeile dann in den Speicher schreiben
         Prg_End_Pos                                                            'nächste freie position im speicher hinter der neuen Zeile
      else
         tokenize                                                               'keine Programm sondern eine Kommandozeile
         if spaces
            texec                                                               'dann sofort ausfuehren

con'************************************* Basic-Zeile uebernehmen und Statustasten abfragen ***************************************************************************************
PRI getline(laenge):e | a,i,f, c ', {x,y,t,m,a,rec1,rec2,rec3,rec4,esch}                                       'zeile eingeben
   i := laenge
   f:=0'laenge
   e:=0

   repeat

      c := ios.ser_rx'keywait

      case c

                       004:if i>0                                               'Cursortaste links
                              i--
                       003:if i< linelen-1                                      'Cursortaste rechts
                              i++
                       008:if i > 0                                             'bei backspace ein zeichen zurueck 'solange wie ein zeichen da ist
                              ios.ser_tx($7F)'printbs                           'funktion backspace ausfueren
                              laenge--
                              i--
                              if laenge=>i                                      'dies Abfrage verhindert ein einfrieren bei laenge<1
                                 bytemove(@tline[i],@tline[i+1],laenge-i)
                                 tline[laenge]:=0
                                 ios.print(@tline[i])
                       024:ios.printnl                                          'Abbruch (Str-x)
                           editmarker:=0
                           e:=1                                                 'Abbruchmarker
                           quit
'******************************* Funktionstasten ****************************
                       208:                                                     'F1
                       209:i := put_command(@tok20,0)                           'F2 Load
                       210:i := put_command(@tok19,0)                           'F3 Save
                       211:h_dir(@ext5)                                         'F4 DIR
                       212:i := put_command(@tok10,1)                           'F5 RUN
                           tline[i]:=0
                           tp := @tline
                           return
                       213:i := put_command(@tok9,1)                            'F6 List
                           tline[i]:=0
                           tp:=@tline
                           return
'****************************************************************************

                       186:'Entf
                            if laenge>i
                               bytemove(@tline[i],@tline[i+1],laenge-i)
                               laenge--
                               tline[laenge]:=0
                            next

                       13: Returnmarker:=1                                      'wenn return gedrueckt
                           ios.printnl
                           tline[laenge] := 0                                   'statt i->laenge, so wird immer die komplette Zeile übernommen
                           tp := @tline                                         'tp bzw tline ist die gerade eingegebene zeile
                           return

                       32..126:

                           if i < linelen-1
                                 if i<laenge and laenge<linelen-1
                                    bytemove(@tline[i+1],@tline[i],laenge-i)
                                       tline[i]:=c
                                       laenge++
                                       tline[laenge+1]:=0
                                       ios.printchar(c)
                                       i++
                                 else
                                    ios.printchar(c)
                                    tline[i++] :=c
                                 if i>laenge
                                    laenge:=i                                                          'laenge ist immer die aktuelle laenge der zeile


PRI put_command(stradr,mode)                                                    'Kommandostring nach tp senden
    result:=strsize(stradr)
    ios.print(stradr)
    if mode==1
       ios.printnl
    bytemove(@tline[0],stradr,result)

con '****************************** Basic-Token erzeugen **************************************************************************************************************************
PRI tokenize | tok, c, at, put, state, i, j', ntoks
   at := tp
   put := tp
   state := 0
   repeat while c := byte[at]                                                   'solange Zeichen da sind schleife ausführen
      if c == quote                                                             'text in Anführungszeichen wird ignoriert
         if state == "Q"                                                        'zweites Anführungszeichen also weiter
            state := 0
         elseif state == 0
            state := "Q"                                                        'erstes Anführungszeichen

      if state == 0                                                             'keine Anführungszeichen mehr, also text untersuchen
         repeat i from 0 to num_of_toks                                         'alle Kommandos abklappern
            tok := @@toks[i] '@token'                                           'Kommandonamen einlesen
            j := 0
            repeat while byte[tok] and ((byte[tok] ^ byte[j+at]) & caseBit) == 0'zeichen werden in Grossbuchstaben konvertiert und verglichen solange 0 dann gleich
               j++
               tok++

            if byte[tok] == 0 and not isvar(byte[j+at])                         'Kommando keine Variable?
               byte[put++] := 128 + i                                           'dann wird der Token erzeugt
               at += j
               if i == 7                                                        'REM Befehl
                  state := "R"
               else
                  repeat while byte[at] == " "
                     at++
                  state := "F"
               quit
         if state == "F"
            state := 0
         else
            byte[put++] := byte[at++]
      else
         byte[put++] := byte[at++]
   byte[put] := 0                                                               'Zeile abschliessen

con '*********************************** Routinen zur Programmzeilenverwaltung im E-Ram********************************************************************************************
PRI writeendekennung(adr)
    ios.ram_wrword($FFFF,adr)                                                       'Programmendekennung schreiben
    speicherende:=adr+2                                                         'neues Speicherende

PRI Prg_End_Pos                                                                 'letztes Zeichen der letzten Zeile (Programmende)
    nextlineloc := speicherende - 2

PRI findline(lineno):at
   at := speicheranfang
   repeat while ios.ram_rdword(at) < lineno and at < speicherende-2                 'Zeilennummer
          at:=ios.ram_keep(at+2)'+1                                                 'zur nächsten zeile springen

PRI eram_rw(beginn,adr)|temp,zaehler
'******************** Bereich nach der bearbeiteten Zeile in Bearbeitungsspeicher verschieben **************************
    temp:=TMP_RAM                                        'Anfang Bearbeitungsbereich
    zaehler:=speicherende-2-adr
    if adr<speicherende-2
       ios.ram_copy(adr,TMP_RAM,zaehler)
'******************** Bereich aus dem Bearbeitungsspeicher wieder in den Programmspeicher verschieben ******************
    if zaehler>0                                         'wenn nicht die letzte Zeile
       ios.ram_copy(TMP_RAM,beginn,zaehler)
    writeendekennung(beginn+zaehler)

PRI einfuegen(adr,diff,mode)|anfang
'*********************** aendern und einfuegen von Zeilen funktioniert*************************************************
    anfang:=adr

    if mode>0
       adr:=ios.ram_keep(adr+2)                          'eigentliche Zeile beginnt nach der Adresse
       '****** letzte Zeile? *************
       if ios.ram_rdword(adr)==$FFFF                     'Ueberpruefung, ob es die letzte Zeile ist
          if mode==2                                     'Zeile loeschen
             writeendekennung(anfang)                    'an alte Adresse Speicherendekennung schreiben
             return                                      'und raus
       '*********************************
    eram_rw(anfang+diff,adr)                             'schreibe geaenderten Bereich neu

PRI insertline2 | lineno, fc, loc, locat, newlen, neuesende
   lineno := parseliteral

   neuesende:=0                                                                 'Marker, das Programmende schon geschrieben wurde auf null setzen
   if lineno < 0 or lineno => 65535                                             'Ueberpruefung auf gueltige Zeilennummer
      close
      errortext(2)'@ln
   tokenize                                                                     'erstes Zeichen nach der Zeilennummer ist immer ein Token, diesen lesen
   fc := spaces                                                                 'Zeichen nach dem Token lesen

   loc := findline(lineno)                                                      'adresse der basic-zeile im eram, die gesucht wird
   locat := ios.ram_rdword(loc)                                                 'zeilennummer holen
   newlen := strsize(tp)+1                                                      'laenge neue zeile im speicher 1 fuer token + laenge des restes (alles was nach dem befehl steht)

   if locat == lineno                                                           'zeilennummer existiert schon

      if fc == 0                                                                'zeile loeschen
        einfuegen(loc,0,2)                                                      'Zeile hat null-laenge also loeschen
        neuesende:=1                                                            'Marker, das Programmende schon geschrieben wurde

      else                                                                      'zeile aendern
        einfuegen(loc,newlen+2,1)                                               'platz fuer geaenderte Zeile schaffen +2 fuer Zeilennummer wenn es nicht die letzte Zeile ist sonst muss die 2 weg
        neuesende:=1                                                            'Marker, das Programmende schon geschrieben wurde

   if fc                                                                        'zeilennummer existiert noch nicht
      if locat <65535 and locat > lineno                                        'Zeile einfuegen zwischen zwei Zeilen
         einfuegen(loc,newlen+2,0)                                              'Platz fuer neue Zeile schaffen
         neuesende:=1                                                           'Marker, das Programmende schon geschrieben wurde
      ios.ram_wrword(lineno,loc)                                                'Zeilennummer schreiben
      loc+=2

      repeat newlen
             ios.ram_wrbyte(byte[tp++],loc++)                                        'neue Zeile schreiben entweder ans ende(neuesende=0) oder in die lücke (neuesende=1)

      if neuesende==0                                                           'Marker, das Programmende noch nicht geschrieben wurde (zBsp.letzte Zeile ist neu)
         writeendekennung(loc)                                                  'Programmendekennung schreiben

   RAM_CLEAR                                                                    'Programmspeicher hinter dem Programm loeschen
   ios.ram_wrbyte(135,PMARK_RAM)                                                    'reclaim-Marker setzen -> Programm im Speicher

PRI writeram | lineno
   lineno := parseliteral
   if lineno < 0 or lineno => 65535
      close
      errortext(2)'@ln
   tokenize
   ios.ram_wrword(lineno,nextlineloc)                                               'zeilennummer schreiben
   nextlineloc+=2
   skipspaces                                                                   'leerzeichen nach der Zeilennummer ueberspringen
   repeat strsize(tp)+1
        ios.ram_wrbyte(byte[tp++],nextlineloc++)                                    'Zeile in den Programmspeicher uebernehmen

   writeendekennung(nextlineloc)                                                'Programmende setzen

PRI reclaim |a,rc,f                                                             'Programm-Recovery-Funktion
    rc:=0                                                                       'adresszähler
    f:=0                                                                        'fehlermerker
       repeat
                  if rc>$1FFFF                                                  'nur den Programmspeicher durchsuchen
                     return 0'errortext(7,1)                                    'Fehler, wenn kein Programm da ist
       until (a:=ios.ram_rdlong(rc++))==$FFFF00                                     'Speicherendekennung suchen $FFFF0000
       speicherende:=rc+2                                                       'Speicherendezaehler neu setzen
       Prg_End_Pos
       return 1

con '******************************** Variablenspeicher-Routinen ******************************************************************************************************************
PRI clearvars
   clearing
   nextlineloc := speicheranfang                                                'Programmadresse auf Anfang
   sp := 0
   clearstr                                                                     'Stringpuffer löschen

PRI clearing |i
   ios.ram_fill(DIR_RAM,$24000,0)'$38FF,0)                                      'Variablen,Dir-Speicher,For-Next-Speicher loeschen beginnend mit dem Dir-Speicher
   ios.ram_fill(STR_ARRAY,$6E800,0)                                             'Stringarray-Speicher loeschen
   ios.ram_fill(VAR_TBL,$4000,0)                                                'Variablen-Tabellen löschen
   repeat i from 0 to 961
       ios.ram_wrbyte(10,VAR_TBL+(i*8)+4)
       ios.ram_wrbyte(10,STR_TBL+(i*8)+4)
   pauseTime := 0
   gototemp:=gosubtemp  :=0                                                     'goto-Puffer loeschen
   gotobuffer:=gosubbuffer:=0
   restorepointer:=0                                                            'Restore-Zeiger löschen
   datapointer:=0                                                               'Data-Zeiger löschen
   DATA_POKE(1,0)                                                               'erste Data-Zeile suchen, falls vorhanden
   VAR_NR:=0                                                                    'Variablenzähler zurücksetzen
   STR_NR:=0                                                                    'Stringzähler zurücksetzen
   if restorepointer                                                            'DATA-Zeilen vorhanden
      DATA_POKE(0,restorepointer)                                               'Datazeilen in den E-Ram schreiben
   Var_Neu_Platz:=STR_ARRAY

PRI newprog
   speicherende := speicheranfang + 2
   nextlineloc := speicheranfang
   writeendekennung(speicheranfang)
   sp := 0                                                                      'stack loeschen
   ios.ram_wrbyte(0,PMARK_RAM)                                                      'reclaim-Marker zurücksetzen

PRI clearall
   newprog
   clearvars

PRI pushstack                                                                   'Gosub-Tiefe max. 20
   if sp => constant(maxstack-1)
      errortext(12)
   stack[sp++] := nextlineloc                                                   'Zeile merken

PRI klammers                                                                    'Arraydimensionen lesen (bis zu 3 Dimensionen)
bytefill(@var_arr,0,3)

if spaces=="("
       tp++
       var_arr[0]:=get_array_value
       var_arr[1]:=wennkomma
       var_arr[2]:=wennkomma
       klammerzu

PRI wennkomma:b
    if spaces==","
          tp++
          b:=get_array_value

PRI get_array_value|tok,c,ad                                                    'Array-Koordinaten lesen und zurückgeben
   tok := spaces                                                                'Zeichen lesen
   tp++
   case tok

      "a".."z","A".."Z":                                                        'Wert von Variablen a-z
          ad:=readvar_name(tok)
          c:=fl.ftrunc(varis_neu(ad,0,0,0,0,0,VAR_TBL))                         'pos,wert,r/w,x,y,z
          return c                                                              'und zurueckgeben
      "#","%","0".."9":                                                         'Zahlenwerte
          --tp
          c:=fl.ftrunc(getAnyNumber)
          return c

obj '******************************************STRINGS*****************************************************************************************************************************
con'************************************** neuer Versuch langer Variablennamen ****************************************************************************************************
pri readvar_name(c):varname                                             'Variablennamen lesen und Typ zurückgeben
    varname:=0
    varname:=fixvar(c)                                                  '1.Zeichen in Großbuchtaben umwandeln und in Zahl umwandeln
    c:=spaces                                                           '2.Zeichen lesen
    if isvar(c)
       varname+=(fixvar(c)+1)*26                                        '2.Zeichen ist ein Buchstabe (26Buchstaben) zz =701
    elseif isnum(c)
       varname:=(10*varname)+701+fixnum(c)                              '2.Zeichen ist eine Zahl
    'weitere Zeichen überspringen
    repeat
           if isvar(c)                                                  'Buchstaben überspringen
              c:=skipspaces
           elseif isnum(c)                                              'Zahlen überspringen
              c:=skipspaces
           else
              quit
   ' ser.dec(varname)
    return varname
'Beispiel zz -> 1.Buchstabe 90-65=25 2.Buchstabe 90-65=(25+1)*26=676+25=701
'2.Bsp    sy -> 1.Buchstabe 83-65=18 2.Buchstabe 89-65=(24+1)*26=650+18=668
'3.bsp    sr -> 1.Buchstabe 83-65=18 2.Buchstabe 82-65=(17+1)*26=468+18=486
'4.Bsp    ss -> 1.Buchstabe 83-65=18 2.Buchstabe 83-65=(18+1)*26=494+18=512

PRI varis_neu(var_name,wert,rw,x,y,z,tab):adress|c,ad ,tb                                                    'Arrayverwaltung im eRam (ios.ram_Start_Adresse,Buchstabe, Wert, lesen oder schreiben,Arraytiefenwert 0-255)
    adress:=vari_adr_neu(var_name,x,y,z,tab)
    tb:=0
    if tab==VAR_TBL             'varis_neu(a,h,1,0,0,0,VAR_TBL)
       tb:=1
    if rw
         if adress<STR_ARRAY                                                                                  'existiert die Variable noch nicht, wird sie angelegt und ein Feld von 11 Einträgen angelegt
            ad:=tab+(var_name*8)                                                                              'da die Grunddimensionierung 10 (11 Einträge ) ist
            Felddimensionierung(var_name,tb,ios.ram_rdbyte(ad+4),ios.ram_rdbyte(ad+5),ios.ram_rdbyte(ad+6))
            adress:=vari_adr_neu(var_name,x,y,z,tab)
         if tab==STR_TBL
            stringfunc(1,adress)
         else
            ios.ram_wrlong(wert,adress)                                                    'Array schreiben
    else
         ifnot adress
               if tab==STR_TBL
                  return
               else
                  return 0
         else
            if tb
               c:=ios.ram_rdlong(adress)                                                      'Array lesen
               return c

pri vari_adr_neu(n,x,y,z,tab):adress|ad,adr,ln                                                 'adresse der numerischen Variablen im Ram
     ad:=tab+(n*8)
     adr:=ios.ram_rdlong(ad)
     if tab==VAR_TBL
        ln:=4
     else
        ln:=linelen
     adress:=scandimension_neu(adr,ln,x,y,z,ios.ram_rdbyte(ad+4),ios.ram_rdbyte(ad+5),ios.ram_rdbyte(ad+6))

PRI scandimension_neu(startpos,laenge,x,y,z,varx,vary,varz) :Position        'Überprüfung auf Dimensionswerte und Feldpositionsberechnung
    if x>varx+1 or y>vary+1 or z>varz+1
       errortext(16)
   'Feldposition im Ram    y-Position   x-Position       z-Position
    Position:=startpos+((varx+1)*y*laenge)+(x*laenge)+((varx+1)*(vary+1)*laenge*z)

pri getvar(name,tbl):ad                                                         'ermitteln der Variablen-Adresse
    klammers
    bytemove(@var_tmp,@var_arr,3)
    ad:=varis_neu(name,0,0,var_tmp[0],var_tmp[1],var_tmp[2],tbl)

con'*************************************************************** Array-Dimensionierung ****************************************************************************************
PRI Felddimensionierung(variabl,var_str,x,y,z)|grenze,ort,len,ad

    grenze:=(z+1)*(y+1)*(x+1)

    if grenze>FIELD_LEN
       errortext(18)                                                            'Dimensionen dürfen die Grenze von 64000 nicht durchbrechen

    if var_str==1                                                               'Zahlenfelddimensionen speichern
       ort:=VAR_TBL+(variabl*8)
       VAR_NR++
       len:=4
    else                                                                        'String-Felddimensionen speichern
       ort:=STR_TBL+(variabl*8)
       len:=linelen
       STR_NR++
    ad:=Var_Neu_Platz+(grenze*len)
    if ad>$EFFFF
       errortext(45)                                                            'Out of Memory Error!

   'neu Adresse in Tabelle speichern
   ios.ram_wrlong(VAR_NEU_PLATZ,ort)
   ios.ram_wrbyte(x,ort+4)
   ios.ram_wrbyte(y,ort+5)
   ios.ram_wrbyte(z,ort+6)
   'naechster freier Platz
   Var_Neu_Platz+=(grenze*len)

con '************************************* Stringverarbeitung *********************************************************************************************************************
PRI getstr:a|nt,b,str ,f                                                          'string in Anführungszeichen oder Array-String einlesen
    a:=0
    nt:=spaces
    bytefill(@font,0,STR_MAX)
    case nt
         quote:
              scanfilename(@font,0,quote)                                       'Zeichenkette in Anführungszeichen
         152: skipspaces
              a:=expr(1)                                                        'Gfile mit Parameter
              if a>filenumber
                 errortext(3)
              b:=(a-1)*13
              a:=DIR_RAM+b                                                      'Adresse Dateiname im eRam
              stringlesen(a)

         163,200,196,195,193:                                                   'Left$,Right$,Mid$,Upper$,Lower$
               skipspaces
               stringfunc2(nt)
         176: skipspaces                                                        'Chr$-Funktion
              a:=klammer(1)
              byte[@font][0]:=a
              byte[@font][1]:=0
         188: stringwiederholung                                                'String$-Funktion

         "a".."z","A".."Z":                                                     'konvertiert eine Variable a(0..255)-z(0..255) in einen String
              skipspaces
              f:=readvar_name(nt)
              if dollar
                 klammers
                 b:=varis_neu(f,0,0,var_arr[0],var_arr[1],var_arr[2],STR_TBL)   'Stringarray lesen
                 stringlesen(b)
              else
                 klammers
                 b:=varis_neu(f,0,0,var_arr[0],var_arr[1],var_arr[2],VAR_TBL)   'Arrayvariable aus eRam holen
                 str:=zahlenformat(b)

                 bytemove(@font,str,strsize(str))

Pri Input_String
       getstr
       bytemove(@f0,@font,strsize(@font))                                       'string nach f0 kopieren

pri Get_Input_Read(anz):b |nt,c,tb,ad                                                   'Eingabe von gemischten Arrays für INPUT und FREAD

                b:=0
                nt:=spaces
                c:=0
                bytefill(@prm_typ,0,10)

             repeat
                  '***************** Zahlen ***************************************
                  if isvar(nt)
                     skipspaces
                     ad:=readvar_name(nt)
                     if dollar
                        tb:=STR_TBL
                        c:=1
                     else
                        tb:=VAR_TBL
                     klammers
                     prm[b]:=varis_neu(ad,0,1,var_arr[0],var_arr[1],var_arr[2],tb)
                     prm_typ[b++]:=c
                     c:=0
                     if spaces==","
                        nt:=skipspaces
                     else
                        quit
                     if anz==b
                        quit
                  '************************
                  else
                     errortext(19)


PRI clearstr
    bytefill(@font,0,STR_MAX)
    bytefill(@str0,0,STR_MAX)

PRI stringfunc(pr,v) | a7,identifier                                              'stringfunktion auswaehlen
   identifier:=0
   a7:=v

   getstr                                                                        'welche Funktion soll ausgeführt werden?

   bytemove(@str0,@font,strsize(@font))
   identifier:=spaces                                                           'welche Funktion kommt jetzt?
   if identifier==43                                                            'Pluszeichen?
      skipspaces
      stringfunktionen(a7,identifier,pr)
   else                                                                         'keine Funktion dann
      stringschreiben(a7,0,@str0,pr)'-1                                          'String schreiben

PRI stringschreiben(adre,chr,strkette,pr) | c9,zaehler
    zaehler:=0

    case pr
         0:if chr>0
              ios.printchar(chr)
           else
              ios.print(strkette)

         1:if chr==0
              repeat strsize(strkette)
                    zaehler++
                    c9:= byte[strkette++]
                    if zaehler=<linelen-1
                       ios.ram_wrbyte(c9,adre++)
                    else
                       quit
           else
              ios.ram_wrbyte(chr,adre++)                                        'chr-Funktion
           ios.ram_wrbyte(0,adre++)                                             'null schreiben fuer ende string
         2:ios.sdputstr(strkette)                                               'auf SD-Card schreiben
    clearstr                                                                    'stringpuffer löschen
    return adre

PRI stringfunktionen(a,identifier,pr)                                           'Strings addieren
     repeat
          if identifier==43
                '************* funktioniert ******************                                                                                '+ Zeichen Strings addieren
                getstr
                if (strsize(@str0)+strsize(@font))<linelen-1
                   bytemove(@str0[strsize(@str0)],@font,strsize(@font))            'verschiebe den String in den Schreibstring-Puffer
                   identifier:=spaces
                   skipspaces
                else
                   quit
          else
             quit
     stringschreiben(a,0,@str0,pr)'-1                                          'keine Zeichen mehr String schreiben

PRI stringwiederholung|a,b                                                      'String$-Funktion
    skipspaces
    klammerauf
        a:=expr(1)                                                              'anzahl wiederholungen
        komma
        getstr
    klammerzu
    bytefill(@strtmp,0,STR_MAX)                                                 'Stringpuffer löschen
    bytemove(@strtmp,@font,strsize(@font))                                      'String, der wiederholt werden soll merken
    bytefill(@font,0,STR_MAX)                                                   'Stringpuffer löschen
    b:=0
    repeat a
        if b>STR_MAX
           byte [@font][STR_MAX-1]:=0
           quit
        bytemove(@font[b],@strtmp,strsize(@strtmp))                             'Anzahl a Wiederholungen in Stringpuffer schreiben
        b:=strsize(@font)

PRI stringfunc2(function)|a8,b8,c8,a,b                                          'die Stringfunktionen (left, right, mid,upper, lower)

    klammerauf
          getstr                                                                'String holen
          a8:=strsize(@font)
          if function==200 or function==196 or function==195
             komma
             b8:=expr(1)                                                        'anzahl zeichen fuer stringoperation
             if function==195                                                   'midstr
                komma
                c8:=expr(1)
    klammerzu

   case function
        200:a:=0                                                                'left
                b:=b8
        195:a:=b8-1                                                             'midstr
                b:=c8
        196:a:=a8-b8                                                            'right
                b:=b8
        193:charactersUpperLower(@font,0)                                       'upper
                return
        163:charactersUpperLower(@font,1)                                       'lower
                return

        other:
             errortext(3)

   bytemove(@font,@font[a],b)
   byte[@font][b]:=0

PRI charactersUpperLower(characters,mode) '' 4 Stack Longs

'' ┌───────────────────────────────────────────────────────────────────────────┐
'' │ Wandelt die Buchstaben in Groß (mode=0) oder Klein(mode=1) um.            │
'' └───────────────────────────────────────────────────────────────────────────┘

  repeat strsize(characters--)

    result := byte[++characters]
    if mode
       if((result > 64) and (result < 91))                                      'nur A -Z in Kleinbuchstaben
          byte[characters] := (result + 32)
    else
       if(result > 96)                                                          'nur a-z in Großbuchstaben
          byte[characters] := (result - 32)


PRI stringlesen(num) | p,i
    i:=0
    repeat while p:=ios.ram_rdbyte(num++)                                       'string aus eram lesen und in @font schreiben
          byte[@font][i++]:=p
    byte[@font][i]:=0
    return num

PUB strpos (searchAddr,strAddr,offset)| searchsize                              'durchsucht strAddr nach auftreten von searchAddr und gibt die Position zurück
  searchsize := strsize(searchAddr)
  repeat until offset  > strsize(strAddr)
    if (strcomp(substr(strAddr, offset++, searchsize), searchAddr))             'if string search found
        return offset
  return 0
PUB substr (strAddr, start, count)                                              'gibt einen Teilstring zurück von start mit der Anzahl Zeichen count
  bytefill(@strtmp, 0, STR_MAX)
  bytemove(@strtmp, strAddr + start, count)                                     'just move the selected section
  return @strtmp
obj '*********************************************** TIMER-FUNKTIONEN ***********************************************************************************************************
con' *********************************************** Verwaltung der acht Timer und 4 Counter ************************************************************************************
PRI timerfunction:b|a,c,function
       function:=spaces
       skipspaces

       case function                                                            'Timerfunktionen mit Werterueckgabe
               "c","C":'isclear?                                                'Timer abgelaufen?
                       a:=klammer(1)'expr
                       return TMRS.isclr(a-1)
               "r","R":'read                                                    'Timerstand abfragen
                          a:=klammer(1)'expr
                          return TMRS.read(a-1)                                 'Timer 1-12 lesen

               "s","S":'timerset                                                'Timer 1-12 setzen

                          klammerauf
                          a:=expr(1)
                          komma
                          c:=expr(1)
                          klammerzu
                          TMRS.set(a-1,c)

               other:
                       errortext(3)'@syn

con '********************************* Befehle, welche mit Printausgaben arbeiten *************************************************************************************************
PRI factor | tok, a,b,c,d,e,g,f,fnum                                            'Hier werden nur Befehle ohne Parameter behandelt
   tok := spaces
   e:=0
   tp++
   case tok
      "(":
         a := expr(0)
         if spaces <> ")"
            errortext(1)
         tp++
         return a

      "a".."z","A".."Z":
             fnum:=readvar_name(tok)
             c:=getvar(fnum,VAR_TBL)
             return c                                                           'und zurueckgeben
      135: return                                                               'bei REM nichts machen
      139: ' RND <factor>
           a:=klammer(1)
           a*=1000
           b:=((rv? >>1)**(a<<1))
           b:=fl.ffloat(b)
           return fl.fmul(fl.fdiv(b,fl.ffloat(10000)),fl.ffloat(10))

      152:'GFile                                                                'Ausgabe Anzahl, mit Dir-Filter gefundener Dateieintraege
          ifnot spaces
                return fl.ffloat(filenumber)
      158:'GATTR
           a:=klammer(1)
           return fl.ffloat(ios.sdfattrib(a))

      159:'VAL
           klammerauf
           Input_String
           fnum:=fs.StringToFloat(@f0)
           klammerzu
           return fnum


      160:'SQR
           return fl.fsqr(klammer(0))
      161:'EXP
           return fl.exp(klammer(0))

      162:'INT
           return fl.ffloat(fl.FTrunc(klammer(0)))                                'Integerwert
      164:'COMP$
          klammerauf
          Input_String
          bytemove(@str0,@f0,strsize(@f0))                                      'in 2.Puffer merken
          komma
          Input_String
          c:=strcomp(@str0,@f0)                                                 'beide vergleichen -1=gleich 0=ungleich
          klammerzu
          return fl.ffloat(c)

      165:'LEN
          klammerauf
          Input_String
          a:=strsize(@f0)
          klammerzu
          return fl.ffloat(a)

      167:'LN
           return fl.LOG(klammer(0))
      169:'ABS
           return fl.fabs(klammer(0))
      170:'SYS
           a:=klammer(1)
           case a
                0:b:=userptr-speicherende   'freier Speicher
                1:b:=speicherende-2         'benutzter Speicher
                2:b:=USER_RAM-STR_ARRAY     'freier Variablenspeicher
                3:b:=Var_Neu_Platz-STR_ARRAY'benutzter Variablenspeicher
                4:return version            'Version
                5:b:=VAR_NR                 'Variablenanzahl
                6:b:=STR_NR                 'Stringanzahl
                10:b:=ios.reggetcogs            'freie Cogs in Regnatix

           return fl.ffloat(b)
      171:'SGN
           a:=klammer(0)                                                       'SGN-Funktion +
            if a>0
               a:=1
            elseif a==0
                   a:=0
            elseif a<0
                   a:=-1
            a:=fl.ffloat(a)
           return a
      172:'sin
           return fl.sin(klammer(0))
      173:'cos
           return fl.cos(klammer(0))
      174:'Pi
          return pi
      177:'tan
           return fl.tan(klammer(0))
      178:'ATN
           return fl.ATAN(klammer(0))
      179:'INSTR
          klammerauf
          Input_String
          bytefill(@str0,0,STR_MAX)
          bytemove(@str0,@f0,strsize(@f0))                                      'in 2.Puffer merken
          komma
          Input_String
          c:=strpos(@str0,@f0,0)                                                'beide vergleichen -1=gleich 0=ungleich
          klammerzu
          return fl.ffloat(c)

      182: ' FILE
           return fl.ffloat(ios.sdgetc)
      192:'asc
           klammerauf
           b:=spaces
           if isvar(b)
              skipspaces
              c:=readvar_name(b)
              if dollar
                 a:=getvar(c,STR_TBL)
                 c:=fl.ffloat(ios.ram_rdbyte(a))
           elseif b==quote
                  c:=fl.ffloat(skipspaces) 'Zeichen
                  skipspaces                     'Quote überspringen
                  skipspaces
           klammerzu
           return c
      203:'PEEK
          a:=expr(1)                                                            'adresse
          komma
          b:=expr(1)                             '1-byte, 2-word, 4-long
          return fl.ffloat(lookup(b:ios.ram_rdbyte(a),ios.ram_rdword(a),0,ios.ram_rdlong(a)))
      204:'gtime
          a:=klammer(1)
          return fl.ffloat(lookup(a:ios.getHours,ios.getMinutes,ios.getSeconds))

      205:'gdate
          a:=klammer(1)
          return fl.ffloat(lookup(a:ios.getDate,ios.getMonth,ios.getYear,ios.getday))

      207: 'Port
          return fl.ffloat(Port_Funktionen)
      210:'inkey
           return fl.ffloat(ios.ser_rxcheck)
      211:'FN
           a:=spaces
           if isvar(a)
              skipspaces
              a:=fixvar(a)                                                      'Funktionsvariable
              c:=FUNC_RAM+(a*56)                                                'Adresse der Funktion im E-Ram 4Variablen(x4Bytes)+34Zeichen String=50 Bytes (+6 reserve)
              klammerauf
              b:=expr(0)                                                        'Operandenwert der Operandenvariablen
              d:=ios.ram_rdlong(c)                                              'Adresse der Operandenvariablen aus Funktionsram lesen
              ios.ram_wrlong(b,d)                                               'Operandenwert an die Adresse der Operanden-Variablen schreiben
              g:=c
              repeat 3
                 g+=4
                 f:=ios.ram_rdlong(g)                                           'Adresse des nächsten Operanden
                 if spaces==","
                    skipspaces
                    e:=expr(0)                                                  'nächster Variablenwert
                    if f=>STR_ARRAY                                             'Variable nicht null, also vorhanden
                       ios.ram_wrlong(e,f)                                      'Variablenwert schreiben, wenn vorhanden
                    else
                       errortext(25)                                            'Variable zuviel
                 else
                    quit
              klammerzu
              stringlesen(c+16)                                                 'Funktionszeile aus dem E-Ram lesen und nach @font schreiben
              tp := @font                                                       'Zeile nach tp übergeben
              d:=expr(0)                                                        'Funktion ausführen
              return d                                                          'berechneter Wert wird zurückgegeben
           else
              errortext(25)
      215:'TIMER
           return fl.ffloat(timerfunction)

      226:'I2C-Funktion
           return fl.ffloat(I2C_Funktion)

      228:'TEMP
           a:=expr(1)                                                           'pin für Temperaturmessung
           return getTemperature(a)

      229:'Font
           return fl.ffloat(fontsatz)
      "-":
          return fl.FNeg(factor)                                                 'negativwert ->factor, nicht expr(0) verwenden

      "#","%", quote,"0".."9":
         --tp
         return getAnyNumber

      other:

           errortext(1)


Con '******************************************* Operatoren *********************************************************************************************************************
PRI bitTerm | tok, t
   t := factor

   repeat
      tok := spaces
      if tok == "^"                                                             'Power  y^x   y hoch x entspricht y*y (x-mal)
         tp++
         t := fl.pow(t,factor)
      else
         return t

PRI term | tok, t,a
   t := bitTerm
   repeat
      tok := spaces
     if tok == "*"
           tp++
           t := fl.FMUL(t,bitTerm)                                              'Multiplikation
     elseif tok == "/"
        if byte[++tp] == "/"
           tp++
           t := fl.FMOD(t,bitTerm)                                              'Modulo
        else
           a:=bitTerm
           if a<>0
              t  :=fl.FDIV(t,a)                                                 'Division
           else
              errortext(35)
     else
        return t

PRI arithExpr | tok, t
   t := term
   repeat
      tok := spaces
      if tok == "+"
         tp++
         t := fl.FADD(t,term)                                                   'Addition
      elseif tok == "-"
         tp++
         t := fl.FSUB(t,term)                                                   'Subtraktion
      else
         return t

PRI compare | op,a,c,left,right,oder

   a := arithExpr
   op:=left:=right:=oder:=0
   'spaces
   repeat
      c := byte[tp]

      case c
         "<": op |= 1                                   '>
              if right                                  '><
                 op|=64
              if left                                   '>>
                 op|=128
              left++
              tp++
         ">": op |= 2                                   '<
              if right                                  '<<
                 op|=64
              right++
              tp++
         "=": op |= 4
              tp++
         "|": op |= 8                                   '|
              if oder                                   '||
                 op|=32
              oder++
              tp++
         "~": op |=16
              tp++
         "&": op |=16                                   '&
              tp++
         other: quit


   case op
      0: return a
      1: return a<arithExpr
      2: return a > arithExpr
      3: return a <> arithExpr
      4: return a == arithExpr
      5: return a =< arithExpr
      6: return a => arithExpr
      8: return fl.ffloat(fl.ftrunc(a)| fl.fTrunc(arithExpr)) 'or
      16:return fl.ffloat(fl.ftrunc(a)& fl.fTrunc(arithExpr)) 'and
      17:return fl.ffloat(fl.ftrunc(a)<- fl.fTrunc(arithExpr))'rotate left
      18:return fl.ffloat(fl.ftrunc(a)-> fl.fTrunc(arithExpr))'rotate right
      40:return fl.ffloat(fl.ftrunc(a)^ fl.fTrunc(arithExpr)) 'xor
      66:return fl.ffloat(fl.ftrunc(a)>> fl.fTrunc(arithExpr))'shift right
      67:return fl.ffloat(fl.ftrunc(a)>< fl.fTrunc(arithExpr))'reverse
      129:return fl.ffloat(fl.ftrunc(a)<< fl.fTrunc(arithExpr))'shift left
      other:errortext(13)


PRI logicNot | tok
   tok := spaces
   if tok == 149 ' NOT
      tp++
      return not compare
   return compare

PRI logicAnd | t, tok
   t := logicNot
   repeat
      tok := spaces
      if tok == 150 ' AND
         tp++
         t := t and logicNot
      else
         return t

PRI expr(mode) | tok, t
   t := logicAnd
   repeat
      tok := spaces
      if tok == 151 ' OR
         tp++
            t := t or logicAnd
      else
         if mode==1                                                             'Mode1, wenn eine Integerzahl gebraucht wird
            t:=fl.FTrunc(t)
         return t

con '*************************************** Dateinamen extrahieren **************************************************************************************************************
PRI scanFilename(f,mode,kennung):chars| c

   chars := 0
   if kennung==quote
      tp++                                                                      'überspringe erstes Anführungszeichen
   repeat while (c := byte[tp++]) <> kennung
      if chars++ < STR_MAX                                                      'Wert stringlänge ist wegen Stringfunktionen
         if mode==1                                                             'im Modus 1 werden die Buchstaben in Grossbuchstanben umgewandelt
            if c>96
               c^=32
         byte[f++] := c
   byte[f] := 0

con '*************************************** Programmlisting farbig ausgeben **************************************************************************************

PRI listout|a,b,c,d,e,f,g,rm,states,qs,ds,rs,fr


               b := 0                                                           'Default line range
               c := 65535                                                       'begrenzt auf 65535 Zeilen
               f :=0                                                            'anzahl Zeilen
               qs:=ds:=0
               if spaces <> 0                                                   'At least one parameter
                  b := c := expr(1)

                  if spaces == ","
                     skipspaces
                     c := expr(1)

               a := speicheranfang
               repeat while a < speicherende-2
                  d := ios.ram_rdword(a)                                        'zeilennummer aus eram holen
                  e:=a+2                                                        'nach der Zeilennummer adresse der zeile
                  if d => b and d =< c                                          'bereich von bis zeile
                     Color_set(schwarz,hweiss)
                     ios.printdec(d)                                            'zeilennummer ausgeben
                     ios.printchar(" ")                                         'freizeichen
                     rs:=0
                     repeat while rm:=ios.ram_rdbyte(e++)                       'gesuchte Zeilen ausgeben
                            if rm=> 128
                               rm-=128
                                  color_set(schwarz,hgruen)
                                  ios.print(@@toks[rm])                         'token zurueckverwandeln
                                  if (rm>50 or rm<32 or rm==40 or rm==42 or rm==47 or rm==48) or (rm>34 and rm<39)
                                     ios.printchar(" ")

                                                              '****************************** Farbausgabe *********************************************************************
                                  case rm
                                       79,87,98,99               : states:="F"                           'Befehlsoptionen haben die gleiche Farbe, wie der Grundbefehl
                                                                   ds:=rs:=0


                                       40                        :'DATA
                                                                   ds:=1
                                                                   fr:=hcyan
                                       7                         : 'REM
                                                                   rs:=1
                                                                   fr:=weiss
                                       other                     : ds:=rs:=0
                                                                   states:=0
                            else
                               if ds<1 and rs<1
                                     case rm
                                             32:                    states:=0
                                          quote:                    if qs                                    'Texte in Anführungszeichen sind gelb
                                                                       qs:=0
                                                                    else
                                                                       qs:=1
                                                                       fr:=hgelb
                                          "$"  :                    fr:=hgelb                                'Strings sind gelb
                                          "0".."9","."    :         ifnot qs                                 'numerische Werte sind weiss
                                                                          ifnot states=="V"                  'Zahlen in Variablennamen sind weiss
                                                                                fr:=hweiss
                                                                          states:=0
                                          "%","#"         :         ifnot qs                                 'numerische Werte sind weiss
                                                                          states:="N"
                                                                          fr:=hweiss
                                          44,58,59,"(",")","[","]": ifnot qs                                 'Befehlstrennzeichen (:) ist weiss
                                                                          fr:=hweiss
                                                                          states:=0
                                          "a".."z","A".."Z":                                                  'Variablen sind pink
                                                                    ifnot qs
                                                                          fr:=hpink

                                                                          ifnot states=="F"
                                                                              if states=="N"
                                                                                 fr:=hweiss
                                                                              else
                                                                                 states:="V"
                                                                          else                                'Befehlsoptionen sind gruen
                                                                              fr:=hgruen
                                          other            :        ifnot qs                                  'Operatoren sind weiss
                                                                          fr:=hweiss'grau
                                                                          states:=0


                            '****************************** Farbausgabe *********************************************************************
                               color_set(schwarz,fr)
                               ios.printchar(rm)                                                        'alle anderen Zeichen ausgeben

                     ios.printnl                                                                         'naechste Zeile
                     states:=0
                     f++                                                                                 'Zeilenanzahl
                     if f==18                                                                            'nach 18 Zeilen Ausgabe pausieren
                        if ios.ser_rx==24                                                                'mit Str-X raus
                           quit
                        else
                           f:=0
                  else
                     e:=ios.ram_keep(e)'+1                                                               'zur nächsten zeile springen

                  a := e                                                                                 'adresse der naechsten Zeile
  color_set(hintergr,farbe)
con '***************************************** Befehlsabarbeitung ****************************************************************************************************************
PRI texec | ht, nt, restart,a,b,c,d,e,f,h,elsa,fvar,tab_typ,e_step,f_limit,g_loop


   bytefill(@f0,0,STR_MAX)
   restart := 1
   a:=0
   b:=0
   c:=0
   repeat while restart
      restart := 0
      ht := spaces
      if ht == 0
         return
      skipspaces
      if isvar(ht)                                                              'Variable?
         fvar:=readvar_name(ht)
         if dollar                                                              'String?
            tab_typ:=STR_TBL
         else
            tab_typ:=VAR_TBL
         klammers                                                               'Array? dann arrayfeld einlesen
         bytemove(@var_temp,@var_arr,3)                                         'kopie des Arrayfeldes
         nt := spaces
         if nt == "="
            tp++
            if tab_typ==STR_TBL
               varis_neu(fvar,0,1,var_temp[0],var_temp[1],var_temp[2],tab_typ)
            elseif tab_typ==VAR_TBL
               varis_neu(fvar,expr(0),1,var_temp[0],var_temp[1],var_temp[2],tab_typ)


      elseif ht => 128


          case ht
             128: 'IF THEN ELSE
                a := expr(0)
                elsa:=0                                                          'else-marker loeschen -> neue if then zeile
                if spaces <> 129
                   errortext(14)
                skipspaces
                if not a                                                         'Bedingung nicht erfuellt dann else marker setzen
                      elsa:=1
                      return
                restart := 1
             183:'ELSE
                 if elsa==1
                    elsa:=0
                    restart := 1

             130: ' INPUT {"<prompt>";} <var> {, <var>}
                 if is_string                                                   'Eingabeprompt-String
                    input_string

                 if spaces <> ";"
                    errortext(18)'@syn
                 nt := skipspaces
                 ios.print(@f0)                                                      'Eingabepromt-String ausgeben
                 b:=Get_Input_READ(9)
                 Backup_restore_Line(1)                                          'Backup der aktuellen Zeile
                 if getline(0)==0 and strsize(@tline)>0                          'nur weitermachen, wenn nicht esc-gedrückt wurde und die Eingabezeile größer null war
                    FILL_ARRAY(b,0)                                              'Daten in die entsprechenden Arrays schreiben
                 Backup_restore_line(0)                                          'Restore der aktuellen Zeile

             131: ' PRINT
                a := 0
                repeat
                   nt := spaces
                   if nt ==0 or nt==":"
                      quit
                   case nt

                       152,163,176,188,200,196,195,193,quote:stringfunc(0,0) 'Strings
                       204:ios.time                                              'Time-Ausgabe
                           quit
                       184:skipspaces                                            'TAB 0..9
                           a:=klammer(1) & $F
                           repeat a
                               ios.ser_tx(9)

                       187,201:skipspaces
                               a:=klammer(1)
                               d:=a
                               c:=1                                              'Hex-Ausgabe Standard 1 Stelle
                               e:=4                                              'Bin-Ausgabe Standard 4 Stellen
                               repeat while (b:=d/16)>0                          'Anzahl Stellen für Ausgabe berechnen
                                     c++
                                     e+=4
                                     d:=b
                               if nt==187
                                  ios.printhex(a,c)                              'Hex
                               if nt==201
                                  ios.printbin(a,e)                              'Bin

                       other:a:=tp
                             b:=spaces
                             skipspaces
                             fvar:=readvar_name(b)
                             if dollar
                                tp:=a
                                stringfunc(0,0)
                             else
                                tp:=a
                                ios.print(zahlenformat(expr(0)))

                   nt := spaces
                   case nt
                         ";": tp++
                         ",": ios.ser_tx(9)                                     'Tab ausführen
                              tp++
                         ":",0:ios.printnl
                               quit


             202: 'ON Gosub,Goto
                  ongosub:=0
                  ongosub:=expr(1)
                  if spaces < 132 or spaces >133                                 'kein goto oder gosub danach
                     errortext(1)
                  if not ongosub                                                 'on 0 gosub wird ignoriert (Nullwerte werden nicht verwendet)
                       return
                  restart := 1

             132, 133: ' GOTO, GOSUB
                e:=0
                a:=expr(1)
                if ongosub>0
                   e:=1
                   repeat while spaces=="," and e<ongosub
                          skipspaces
                          e++
                          a := expr(1)
                ongosub:=0
                if a < 0 or a => 65535
                   errortext(2)'@ln
                '*************** diese routine verhindert,das bei gleichen Schleifendurchlaeufen immer der gesammte Speicher nach der Zeilennummer durchsucht werden muss ******
                if gototemp<>a                                                   'sonst zeilennummer merken fuer naechsten durchlauf
                   gotobuffer:=findline(a)                                       'adresse merken fuer naechsten durchlauf
                   gototemp:=a
                if ht==133
                   pushstack
                nextlineloc := gotobuffer

                '***************************************************************************************************************************************************************

             134: ' RETURN
                if sp == 0
                   errortext(15)
                nextlineloc := stack[--sp]

             135,168: ' REM,DATA
                    repeat while skipspaces

             136: ' NEW
                ios.ram_fill(0,$20000,0)
                clearall

             137: ' LIST {<expr> {,<expr>}}
                  Listout

             138: ' RUN
                   clearvars                                                     'alle variablen loeschen

             140: ' OPEN " <file> ", R/W/A
                 Input_String
                 if spaces <> ","
                    Errortext(20)'@syn
                 d:=skipspaces
                 tp++
                 mount
                 if ios.sdopen(d,@f0)
                    errortext(22)
                 fileOpened := true

             141: 'FREAD <var> {, <var> }
                 b:=Get_Input_Read(9)
                 repeat                                                          'Zeile von SD-Karte in tline einlesen
                      c := ios.sdgetc
                      if c < 0
                         errortext(6)                                            'Dateifehler
                      elseif c == fReturn or c == ios.sdeof                          'Zeile oder Datei zu ende?
                         tline[a] := 0                                           'tline-String mit Nullbyte abschliessen
                         tp := @tline                                            'tline an tp übergeben
                         quit
                      elseif c == fLinefeed                                      'Linefeed ignorieren
                         next
                      elseif a < linelen-1                                       'Zeile kleiner als maximale Zeilenlänge?
                         tline[a++] := c                                         'Zeichen in tline schreiben
                 Fill_Array(b,0)                                                 'Daten in die entsprechenden Arrays schreiben

             142: ' WRITE ...
                b:=0                                                             'Marker zur Zeichenketten-Unterscheidung (String, Zahl)
                repeat
                   nt := spaces                                                  'Zeichen lesen
                   if nt == 0 or nt == ":"                                       'raus, wenn kein Zeichen mehr da ist oder Doppelpunkt auftaucht
                      quit
                   if is_string                                                  'handelt es sich um einen String?
                      input_string                                               'String einlesen
                      b:=1                                                       'es ist ein String
                      stringschreiben(0,0,@font,2)                               'Strings schreiben
                   elseif b==0                                                   'kein String, dann eine Zahl
                      stringschreiben(0,0,zahlenformat(expr(0)),2)               'Zahlenwerte schreiben
                   nt := spaces
                   case nt
                        ";": tp++                                                'Semikolon bewirkt, das keine Leerzeichen zwischen den Werten geschrieben werden
                        ",":ios.sdputc(",")                                          'Komma schreiben
                            tp++
                        0,":":ios.sdputc(fReturn)                                    'ende der Zeile wird mit Doppelpunkt oder kein weiteres Zeichen markiert
                              ios.sdputc(fLinefeed)
                              quit
                        other:errortext(1)

             143: ' CLOSE
                fileOpened := false
                close

             144: ' DELETE " <file>
                Input_String
                mount
                if ios.sddel(@f0)
                   errortext(23)
                close

             145: ' REN " <file> "," <file> "
                Input_String
                bytemove(@file1, @f0, strsize(@f0))                              'ergebnis vom ersten scanfilename in file1 merken
                komma                                                            'fehler wenn komma fehlt
                Input_String
                mount
                if ios.sdrename(@file1,@f0)                                          'rename durchfuehren
                    errortext(24)                                                'fehler wenn rename erfolglos
                close

             146: ' DIR
                 b:=spaces
                 if is_String
                    Input_String
                    charactersUpperLower(@f0,0)                                 'in Großbuchstaben umwandeln
                    h_dir(@f0)
                 elseifnot b
                      h_dir(@ext5)                                              'directory ohne parameter nur anzeigen


             147: ' SAVE or SAVE "<filename>"
                if is_String                                                     'Dateiname? dann normales Speichern
                   Input_String
                   a:=0
                   if spaces==","                                                'speichern ohne zurueckverwandelte token
                      komma
                      a:=expr(1)
                   d:=ifexist(@f0)
                   if d==1                                                       'datei speichern
                         if a==4
                            import(1)                                            'Basic-Programm als Textdatei speichern
                         else
                            binsave
                ios.printnl
                close

             148: ' LOAD or LOAD "<filename>"
                 mount
                 if is_String
                   Input_String
                   a:=0
                   if spaces==","                                                'Autostartfunktion ? (Load"name.ext",1)
                      komma
                      a:=expr(1)
                   if ios.sdopen("R",@f0)                                        'Open requested file
                      errortext(22)

                   case a
                        0:newprog                                                  'Programm normal laden -> Rückkehr zum Promt
                          binload(0)
                          Prg_End_Pos

                        1:newprog                                                  'Basic-Datei laden mit Autostart
                          binload(0)
                          clearvars
                        2:                                                         'Append-Funktion (Datei anhängen)
                          binload(speicherende-2)

                        3:   c:=nextlineloc                                        'Replace-Funktion (Dateiteil ersetzen)
                             Prg_End_Pos
                             b:=klammer(1)                                            'Zeilen an Zeilenposition schreiben
                             binload(findline(b))
                             nextlineloc := c                                      'Programmadresse zurückschreiben
                             restart:=1                                            'Programm fortsetzen
                        4:Import(0)                                                'als Textdatei vorliegendes Basic-File importieren

                 close


             154: ' FOR <var> = <expr> TO <expr> {STEP <expr>}                   For-Next Schleifen funktionieren nicht mit arrays als Operanden
                ht := spaces
                if ht == 0
                   errortext(27)
                skipspaces
                a := readvar_name(ht) 'fixvar(ht)
                nt:=spaces
                if not isvar(ht) or nt <> "="
                   errortext(19)
                skipspaces
                varis_neu(a,expr(0),1,0,0,0,VAR_TBL)
                if spaces <> 155                                                 'TO Save FOR limit
                   errortext(28)
                skipspaces

                f_limit := expr(0)

                ios.ram_wrlong(f_limit,FOR_LIMIT+(a*4))

                if spaces == 156 ' STEP                                          'Save step size
                   skipspaces
                   e_step := expr(0)
                else
                   e_step := fl.ffloat(1)                                            'Default step is 1

                ios.ram_wrlong(e_step,FOR_STEP+(a*4))
                ios.ram_wrlong(nextlineloc,FOR_LOOP+(a*4))

                'forLoop[e] := nextlineloc                                        'Save address of line
                c:=varis_neu(a,0,0,0,0,0,VAR_TBL)
                if e_step < 0                                                        'following the FOR
                   b := fl.Fcmp(c,f_limit)'c=>forLimit[a]
                else                                                             'Initially past the limit?
                   b := fl.Fcmp(f_limit,c)'c=< forLimit[a]

                if not b                                                         'Search for matching NEXT
                   repeat while nextlineloc < speicherende-2
                      curlineno := ios.ram_rdword(nextlineloc)
                      tp := nextlineloc + 2
                      nextlineloc := tp + strsize(tp) + 1
                      if spaces == 153                                           'NEXT <var>
                         nt := skipspaces                                        'Variable has to agree
                         if not isvar(nt)
                            errortext(19)
                         skipspaces
                         fvar:=readvar_name(nt)                                  'vergleiche wenn gleich dan raus
                         if fvar == a                                            'If match, continue after
                            quit                                                 'the matching NEXT

             153: ' NEXT <var>
                nt := spaces
                if not isvar(nt)
                   errortext(19)
                skipspaces
                a := readvar_name(nt)'fixvar(nt)                                 'lese variable next <nt>
                e_step:=ios.ram_rdlong(FOR_STEP+(a*4))
                f_limit:=ios.ram_rdlong(FOR_LIMIT+(a*4))
                c:=varis_neu(a,0,0,0,0,0,VAR_TBL)                                'Wert von variable a lesen
                g_loop:=ios.ram_rdlong(FOR_LOOP+(a*4))

                h:=fl.fadd(c,e_step)                                                 'Increment or decrement the


                varis_neu(a,h,1,0,0,0,VAR_TBL)                                   'neuen wert fuer vars[a]
                if e_step < 0                                                        'FOR variable and check for
                   b := fl.Fcmp(h,f_limit) 'h=> forLimit[a]
                else                                                             'the limit value
                   b := fl.Fcmp(f_limit,h)
                if b==1 or b==0                                                  'If continuing loop, go to
                   nextlineloc := g_loop                                         'statement after FOR
                   quit


             166:'READ (DATA)
                  if restorepointer
                     DATA_READ
                  else
                     errortext(5)


             175:'RESTORE (DATA)
                 ifnot spaces
                       DATA_POKE(1,0)                                            'erste Data-Zeile suchen, falls vorhanden
                       if restorepointer                                         'DATA-Zeilen vorhanden
                          DATA_POKE(0,restorepointer)                            'Datazeilen in den E-Ram schreiben
                          datapointer:=0
                       else
                          errortext(5)                                           'kein DATA, dann Fehler
                 else
                    SET_RESTORE(expr(1))



             180: ' END
                 Prg_End_Pos
                 return

             181: ' PAUSE <expr> {,<expr>}
                   pauseTime := expr(1)
                   waitcnt((clkfreq /1000*pausetime) +cnt)

             182:
              ' FILE = <expr>
                 if spaces <> "="
                    errortext(38)'@syn
                 skipspaces
                 if ios.sdputc(expr(1))
                    errortext(30)                                              'Dateifehler

             185:'MKFILE    Datei erzeugen
                 Input_String
                 mount
                 if ios.sdnewfile(@f0)
                    Errortext(26)'@syn
                 close

             186: ' DUMP <adr>,<zeilen> ,ram-typ
                 'DUMP_Function
                 param(2)
                 ios.dump(prm[0],prm[1],prm[2])
'******************************** neue Befehle ****************************

             157:'Renum
                 ifnot spaces
                       renumber(0,speicherende-2,10,10)
                 else
                       param(3)
                       renumber(prm[0],prm[1],prm[2],prm[3])                     'renumber(start,end,step)

             198:'stime
                a:=expr(1)
                is_spaces(":",1)
                b:=expr(1)
                is_spaces(":",1)
                c:=expr(1)
                    ios.setHours(a)
                    ios.setMinutes(b)
                    ios.setSeconds(c)

             199:'sdate
                 param(3)
                 ios.setDate(prm[0])
                 ios.setMonth(prm[1])
                 ios.setYear(prm[2])
                 ios.setDay(prm[3])


             206:'MKDIR
                 input_string
                 mount
                 if ios.sdnewdir(@f0)
                    errortext(30)
                 close

             207:'PORT
                 Port_Funktionen

             208:'POKE                                                           Poke(adresse, wert, byte;word;long)
                 param(2)
                 if prm[2]==1
                    ios.ram_wrbyte(prm[1],prm[0])
                 elseif prm[2]==2
                    ios.ram_wrword(prm[1],prm[0])
                 else
                    ios.ram_wrlong(prm[1],prm[0])


             211:'FN
                 nt:=spaces
                 f:=0
                 e:=0
                 if isvar(nt)
                    skipspaces
                    a:=fixvar(nt)                                                'Funktionsvariablen-name (a..z)
                 else
                    errortext(25)                                                'Fehler, wenn was Anderes als a..z
                 klammerauf
                 f:=get_input_read(4)                                            'max.4 Variablen
                 klammerzu
                 is_spaces(61,25)   '=
                 is_spaces(91,25)   '[
                 scanfilename(@f0,0,93)                                          'Formelstring extrahieren
                 d:=FUNC_RAM+(a*56)                                              'Adresse der Function im Ram
                 ios.ram_wrlong(prm[0],d)                                        'Variablenadresse in Funktionsram schreiben
                 h:=1
                 e:=d
                 repeat 3
                   e+=4
                   if f>1
                      ios.ram_wrlong(prm[h++],e)                                 'Operandenadressen in den Funktionsram schreiben, wenn vorhanden
                      f--
                   else
                      ios.ram_wrlong(0,e)                                        'nicht benutzte Operanden mit 0 beschreiben

                 stringschreiben(d+16,0,@f0,1)                                   'Formel in den Funktionsram schreiben

             209:'clear
                 clearing


             191:'BLOAD
                  Input_String
                  mount
                  if ios.sdopen("R",@f0)
                     errortext(22)
                  ios.BOOT_Partition(@f0)


             190:'EDIT                                                           'Zeilen editieren bis ESC gedrückt wird
                  editmarker:=1
                  a:=Editline(expr(1))
                  repeat while editmarker
                         a:=Editline(a)
                  return

             194:'CHDIR
                 Input_String
                 bytefill(@workdir,0,12)
                 bytemove(@workdir,@f0,strsize(@f0))
                 mount
                 close
                 bytefill(@workdir,0,12)

             212:'COLOR
                 'Color <vordergr>,<hintergr>
                 farbe:=expr(1)&$F
                 komma
                 hintergr:=expr(1)&$F
                 Color_Set(hintergr,farbe)
                 {
                 ios.ser_str(string(27,"["))
                 hintergr+=40                           'Standardfarben
                 if hintergr>47
                    hintergr+=52                        'hellere Farben ab 100
                 ios.ser_dec(hintergr)
                 ios.ser_tx(";")
                 farbe+=30                              'Standardfarben
                 if farbe>37
                    farbe+=52                           'hellere Farben ab 90
                 ios.ser_dec(farbe)
                 ios.ser_tx("m")
                 }

             215:'TIMER
                  timerfunction

             189:'Dim
                 repeat
                    b:=0
                    c:=spaces
                    if isvar(c)                                                  'Zahlen-Felddimensionierung
                       skipspaces
                       d:=readvar_name(c)                                        'Namen lesen
                       b:=1
                       if dollar
                          b:=2
                    else
                       errortext(18)
                    klammers                                                     'Klammerwerte lesen
                    Felddimensionierung(d,b,var_arr[0],var_arr[1],var_arr[2])    'a-x b-y c-z d-variable e-String oder Zahl
                    if spaces==","
                       skipspaces
                    else
                       quit

             213:'Cls ESC "_B" "$"
                  ios.print_cls

             214:'Pos
                  a:=expr(1)                            'ESC "[" X ";" Y "f"
                  komma
                  b:=expr(1)
                  ios.ser_str(string(27,"["))
                  ios.ser_dec(b)
                  ios.ser_tx(";")
                  ios.ser_dec(a)
                  ios.ser_tx("f")

             216: 'PSET
                  param(1)                              'ESC "_GPIXEL" X ";" Y "$"
                  ios.ser_str(string(27,"_GPIXEL"))
                  ios.ser_dec(prm[0])
                  ios.ser_tx(";")
                  ios.ser_dec(prm[1])
                  ios.ser_tx("$")

             217:'LINE                                  'ESC "_GLINE" X1 ";" Y1 ";" X2 ";" Y2 "$"
                  param(3)
                  Grafikfunktion(prm[0],prm[1],prm[2],prm[3],0,1)

             218:'RECT                                  'ESC "_GRECT" X1 ";" Y1 ";" X2 ";" Y2 "$" / ESC "_GFILLRECT" X1 ";" Y1 ";" X2 ";" Y2 "$"
                  param(4)
                  Grafikfunktion(prm[0],prm[1],prm[2],prm[3],prm[4],2)

             219:'CIRCLE                                'ESC "_GELLIPSE" X ";" Y ";" width ";" height "$" / ESC "_GFILLELLIPSE" X ";" Y ";" width ";" height "$"
                  param(4)
                  Grafikfunktion(prm[0],prm[1],prm[2],prm[3],prm[4],3)

             220:'POLYGON                               'ESC "_GPATH" X1 ";" Y1 ";" X2 ";" Y2 ";" Xn ";" Yn... "$" / ESC "_GFILLPATH" X1 ";" Y1 ";" X2 ";" Y2 [";" Xn ";" Yn...] "$"
                  a:=expr(1)                            'Anzahl Parameter (max.10)
                  komma
                  b:=expr(1)                            'Modus (0=ungefüllt, 1=gefüllt)
                  komma
                  param(a-1)
                  if b==1                               'ESC "_GPATH" X1 ";" Y1 ";" X2 ";" Y2 [";" Xn ";" Yn...] "$" / ESC "_GFILLPATH" X1 ";" Y1 ";" X2 ";" Y2 [";" Xn ";" Yn...] "$"
                     ios.ser_str(string(27,"_GFILLPATH"))
                  else
                     ios.ser_str(string(27,"_GPATH"))   '_GPATH5;5;12;18;6;16$
                  b:=0
                  repeat b from 0 to a-2
                      ios.ser_dec(prm[b])
                      ios.ser_tx(";")
                  ios.ser_dec(prm[b+1])
                  ios.ser_tx("$")


             221:'BRUSH                                 'ESC "_GBRUSH" red ";" green ";" blue "$"
                 param(2)
                 ios.ser_str(string(27,"_GBRUSH"))
                 ios.ser_dec(prm[0])
                 ios.ser_tx(";")
                 ios.ser_dec(prm[1])
                 ios.ser_tx(";")
                 ios.ser_dec(prm[2])
                 ios.ser_tx("$")

             222:'PEN (Stiftfarbe)                      'ESC "_GPEN" red ";" green ";" blue "$"
                 param(2)
                 ios.ser_str(string(27,"_GPEN"))
                 ios.ser_dec(prm[0])
                 ios.ser_tx(";")
                 ios.ser_dec(prm[1])
                 ios.ser_tx(";")
                 ios.ser_dec(prm[2])
                 ios.ser_tx("$")

             223:'Width                                 'ESC "_GPENW" width "$"
                 a:=expr(1)
                 ios.ser_str(string(27,"_GPENW"))
                 ios.ser_dec(a)
                 ios.ser_tx("$")

             224:'GSCROLL                               'ESC "_GSCROLL" offsetX ";" offsetY "$" (<0 left >0 right; <0 up >0down)
                 param(1)
                 ios.ser_str(string(27,"_GSCROLL"))
                 ios.ser_dec(prm[0])
                 ios.ser_tx(";")
                 ios.ser_dec(prm[1])
                 ios.ser_tx("$")


             225:'CUR                                   'ESC "_E" state "$"
                 a:=expr(1)&1
                 ios.ser_str(string(27,"_E"))
                 ios.ser_dec(a)
                 ios.ser_tx("$")

             226:'I2C
                 I2C_Funktion                           'Basis I2C-Funktionen

             227:'LED
                 LED_Funktion                           'WS2812-Led-Strip-Treiber

             229:'FONT
                  a:=expr(1)& $F                        '0-15
                  fontsatz:=a
                  ios.ser_tx($8F+a)


'****************************ende neue befehle********************************

      else
          errortext(1)'@syn
      if spaces == ":"                                                          'existiert in der selben zeile noch ein befehl, dann von vorn
         restart := 1
         tp++

pri Color_set(h,v)

    ios.ser_str(string(27,"["))
    h+=40                           'Standardfarben
    if h>47
       h+=52                        'hellere Farben ab 100
    ios.ser_dec(h)
    ios.ser_tx(";")
    v+=30                           'Standardfarben
    if v>37
       v+=52                        'hellere Farben ab 90
    ios.ser_dec(v)
    ios.ser_tx("m")

con'******************************************* Sonder-Funktionen ********************************************************************************************************************
PRI getTemperature(OW_PIN) : temp
  ow.start(OW_PIN)                                      ' start 1-wire object, pin 0

  ow.reset                                              ' send convert temperature command
  ow.writeByte(SKIP_ROM)
  ow.writeByte(CONVERT_T)

  repeat                                                ' wait for conversion
    waitcnt(cnt+clkfreq/1000*25)
    if ow.readBits(1)
      quit

  ow.reset                                              ' read DS1822 scratchpad
  ow.writeByte(SKIP_ROM)
  ow.writeByte(READ_SCRATCHPAD)
  temp := ow.readByte + ow.readByte << 8                ' read temperature
  temp := fl.FDiv(fl.ffloat(temp), 16.0)                ' convert to floating point

  ow.stop
  'mindestens eine Sekunde warten, bovor neu gelesen wird

Pri I2C_Funktion| p,nx,i,function
    function:=spaces&caseBit
    skipspaces
    klammerauf
        case function
            "I"    :
                    param(1)
                    klammerzu
                    SCL:=prm[0]
                    SDA:=prm[1]
                    setupx

            "W"    : p:=expr(1)                                              'Anzahl Daten
                     komma
                     param(p-1)
                     klammerzu
                     i:=0
                     i2cStart
                     repeat p
                         nx:=i2cWrite(prm[i++])                              'p=byte was geschrieben werden soll
                     i2cStop
                     return nx

            "R"    : p:=expr(1)                                              'read byte(ack)0 oder read(nak)1
                     komma
                     param(p-1)
                     klammerzu
                     i:=0
                     i2cStart
                     repeat p
                         nx:=i2cRead(prm[i++])
                     i2cStop
                     return nx

            other:
                   errortext(3)

PRI LED_Funktion|function
    function:=spaces&caseBit
    skipspaces

        case function
            "S"    :'0=WS2812 1=WS2812B
                    param(2)                                                    'Auswahl Typ, anzahl Pixel (max150)
                    if prm[0]==1
                       LED.start_b(prm[1], prm[2])                              'W2812B-Treiber starten (anderes Timing)
                    else
                       LED.start(prm[1], prm[2])                                'W2812-Treiber starten (anderes Timing)

            "W"    :param(2)                                                    'setze LED n,$RRGGBB,level 0-255
                    LED.setx(prm[0], prm[1], prm[2])

            "F"    :param(2)                                                    'Fill von n,bis nx,rgb ($RRGGBB)
                    LED.fill(prm[0], prm[1], prm[2])

            "X"    :LED.off                                                     'alle LED's aus
                    LED.stop                                                    'Treiber-Cog stoppen

            other:
                   errortext(3)

pri Grafikfunktion(x,y,xx,yy,m,f) 'Grafikfunktionen Linie=1,Rect=2,Circle=3

    case f
         1:ios.ser_str(string(27,"_GLINE"))
         2:if m>0
              ios.ser_str(string(27,"_GFILLRECT"))
           else
              ios.ser_str(string(27,"_GRECT"))
         3:if m>0
              ios.ser_str(string(27,"_GFILLELLIPSE"))
           else
              ios.ser_str(string(27,"_GELLIPSE"))
    ios.ser_dec(x)
    ios.ser_tx(";")
    ios.ser_dec(y)
    ios.ser_tx(";")
    ios.ser_dec(xx)
    ios.ser_tx(";")
    ios.ser_dec(yy)
    ios.ser_tx("$")
con'******************************************* DATA-Funktion ********************************************************************************************************************
PRI DATA_READ|anz                                                               'READ-Anweisungen interpretieren, Data-Werte lesen und an die angegebenen Variablen verteilen
    anz:=0
    anz:=Get_input_read(9)                                                      'Array Adressen berechnen
    FILL_ARRAY(anz,1)                                                           'Arrays mit Daten füllen

pri data_write(adr,art)|adresse,a,c,i,f                                         'schreibt die Data-Anweisungen in die entsprechenden Variablen
    adresse:=DATA_RAM+datapointer
    a:=DATA_LESEN(adresse)
    datapointer:=a-DATA_RAM
    i:=0
    f:=strsize(@font)
    if f<1
       errortext(21) 'Out of Data Error
    if art==0
       repeat f                                                                 'String aus Data-Puffer lesen
              c:=byte[@font][i++]
              ios.ram_wrbyte(c,adr++)                                           'und nach String-Array schreiben
       ios.ram_wrbyte(0,adr++)                                                  'Null-string-Abschluss
    else
       c:=fs.StringToFloat(@font)                                               'String-Zahl in Float-Zahl umwandeln und im Array speichern
       ios.ram_wrlong(c,adr)

PRI DATA_LESEN(num) | p,i                                                       'Data-Wert im Eram lesen
    i:=0
    repeat
          p:=ios.ram_rdbyte(num++)                                              'string aus eram lesen und in @font schreiben egal, ob Zahl oder Zeichenkette
          if p==44 or p==0                                                      'komma oder null
             quit                                                               'dann raus
          byte[@font][i++]:=p
    byte[@font][i]:=0                                                           'String mit Nullbyte abschliessen
    return num                                                                  'Endadresse zurückgeben

PRI SET_RESTORE(lnr)|a                                                          'DATA-Zeiger setzen
    a:=findline(lnr)
    if ios.ram_rdbyte(a+2)==168                                                 'erste Data-Anweisung gefunden?
       restorepointer:=a                                                        'Restorepointer setzen
       data_poke(0,restorepointer)                                              'Data-Zeilen in den Data-Speicher schreiben
       datapointer:=0                                                           'Data-Pointer zurücksetzen
    else
       errortext(5)

PRI DATA_POKE(mode,pointer)|a,adr,b,c,d,merker                                  'DATA-Zeilen in den Ram schreiben
    a := pointer                                                                'entweder 0 oder Restore-Zeiger
    adr:=DATA_RAM
    repeat while a < speicherende-2
                 d := ios.ram_rdword(a)                                         'zeilennummer aus eram holen
                 a+=2                                                           'nach der Zeilennummer kommt der Befehl
                 c:= ios.ram_rdbyte(a)                                          '1.Befehl in der Zeile muss DATA heissen
                 if c==168                                                      'Befehl heisst DATA
                    if merker==1
                       ios.ram_wrbyte(44,b-1)                                   'komma setzen nach für nächste Data-Anweisung
                    if mode==1                                                  'Adresse der ersten Data-Zeile
                       restorepointer:=a-2
                       quit
                    merker:=1                                                   'erste DATA-Anweisung schreiben, ab jetzt wird nach jeder weiteren Anweisung ein Komma gesetzt
                    a+=1
                    a:=stringlesen(a)                                           'DATA-Zeile Lesen
                    b:=stringschreiben(adr,0,@font,1)                           'DATA-Zeile in den RAM schreiben
                    adr:=b
                 else
                    a:=ios.ram_keep(a)'+1                                       'zur nächsten zeile springen
    ios.ram_wrlong(0,adr)                                                       'abschließende nullen für Ende Databereich

Pri FILL_ARRAY(b,mode)|a,f

    repeat a from 1 to b                                                        'Arraywerte schreiben
          ifnot prm_typ[a-1]                                                    'Adresse im Array-Bereich?, dann Zahlenvariable
             if mode
                data_write(prm[a-1],1)
             else
                f:=getanynumber
                ios.ram_wrlong(f,prm[a-1])                                      'zahl im Array speichern
          else                                                                  'String
             if mode
                data_write(prm[a-1],0)
             else
                scanFilename(@f0,0,44)                                          'Zeilen-Teil bis Komma abtrennen
                stringschreiben(prm[a-1],0,@f0,1)                               'String im Stringarray speichern

          if a<b and mode==0                                                    'weiter, bis kein Komma mehr da ist, aber nicht bei DATA(da werden die Daten ohne Komma ausgelesen, kann also nicht abgefragt werden)
             if spaces==","
                skipspaces
             else
                quit


con'******************************************** Port-Funktionen P0-7 *************************************************************************************************
PRI PORT_Funktionen|function,a,b',c
    function:=spaces&caseBit
    skipspaces
        case function
            "D"    :klammerauf                                                  'Port-Direction
                    b:=expr(1)                                                  'Byte-Wert, repräsentiert Ein-und Ausgänge
                    klammerzu
                    dira[7..0]:=b

            "I"    :'Port In                                                    'Byte von Port a lesen
                     return ina[7..0]

            "O"    :'Port Out                                                   'Byte Port-Ausgabe
                     klammerauf
                     b:=expr(1)
                     klammerzu
                     outa[7..0]:=b

            "P"    :'Port Pin
                     klammerauf
                     a:=expr(1)& $7                                             'PIN-Ausgabe Port P(0,1) Pin0=High
                     komma
                     b:=expr(1)&$1                                              '1 oder 0
                     klammerzu
                     outa[a]:=b
            "R"    :'Port-Pin lesen
                     klammerauf
                     a:=expr(1)& $7                                             'PIN-Eingabe Port R(0)
                     klammerzu
                     return ina[a]


            other:
                   errortext(3)

con'********************************************* serielle Schnittstellen-Funktionen *********************************************************************************************
{PRI Comfunktionen|function,a,b
    function:=spaces&CaseBit
    skipspaces
        case function
            "S"    :klammerauf
                    a:=expr(1)                                                  'serielle Schnittstelle öffnen/schliessen
                    if a==1
                       komma                                                    'wenn öffnen, dann Baudrate angeben
                       b:=expr(1)
                       ios.ser2_open(b)
                    elseif a==0                                                 'Schnittstelle schliessen
                       ios.ser2_close
                    else
                       errortext(16)
                    klammerzu

            "G"    :'COM G                                                      'Byte von ios.ser_Schnittstelle lesen ohne warten
                    return fl.ffloat(ios.ser2_rxcheck)
            "R"    :'COM R                                                      'Byte von ios.ser_Schnittstelle lesen mit warten
                    return fl.ffloat(ios.ser2_rx)
            "T"    :klammerauf
                    getstr
                    ios.ser2_str(@font)
                    klammerzu
            other:
                   errortext(3)
}
con'*************************************************************** Zeilen-Editor**************************************************************************************************
PRI editline(Zeilennummer):nex|a,c,d,f,rm,i,x,y,bn,temp
if Zeilennummer<65535
               x:=0
               y:=0
               temp:=zeilennummer
               bytefill(@tline,0,linelen)
               a := speicheranfang
               bn:=0
               a:=findline(zeilennummer)                                        'Adresse der Zeilennummer feststellen
               d := ios.ram_rdword(a)                                           'Zeilennummer aus dem eram holen
               a+=2
               i := 1_000_000_000
                        repeat 10                                               'zahl zerlegen
                          if d => i
                             tline[x++] := d / i + 48
                             d //= i
                             bn~~
                          elseif bn or i == 1
                                 tline[x++] :=48
                          i /= 10
                        tline[x++] :=32                                         'freizeichen
                        repeat while rm:=ios.ram_rdbyte(a++)                    'gesuchte Zeile in tline schreiben
                            if rm => 128
                               rm-=128
                                  f:=strsize(@@toks[rm])
                                  bytemove(@tline[x],@@toks[rm],f)
                                  x+=f
                                  tline[x++]:=32                                'Leerzeichen nach dem Token
                                  y:=0                                          'Tok-Bytezaehler auf null setzen für nächsten Befehl
                            else
                                tline[x++]:=rm                                  'alle anderen Zeichen ausgeben
                        nex:=ios.ram_rdword(a)                                  'Adresse der nächsten Zeile

     ios.print(@tline)                                                          'Zeile auf dem Bildschirm ausgeben

     ifnot getline(strsize(@tline))                                             'wenn die Editierung nicht mit ESC abgebrochen wurde
           tp:=@tline                                                           'tp ist die eigentliche Basic-Arbeitszeile
           c := spaces
           if c=>"1" and c =< "9"                                               'Überprüfung auf gültige Zeilennummer
              insertline2                                                       'wenn programmzeile dann in den Speicher schreiben
              Prg_End_Pos                                                       'neues Speicherende
else
   editmarker:=0

con'********************************************  Renumberfunktion *****************************************************************************************************************
pub renumber(st,ed,nb,stp)|i                                                 'renumber(start,end,neustart,step)
    i:=findline(st)
    if ed<speicherende-2
       ed:=findline(ed+1)

    repeat while i<ed
           if nb<65535
              ios.ram_wrword(nb,i)                                                  'neue Zeilennummer schreiben
              i+=2
              nb+=stp                                                           'Zeilennummerierung mit Schrittweite addieren
              i:=ios.ram_keep(i)                                                    'zur nächsten zeile springen
           else
              errortext(2)                                                      'Abbruch, wenn Zeilennummer >65534
con '************************************ Eingabezeile sichern/wiederherstellen für Input-Funktion *************************************************************************
pub Backup_Restore_line(m)                                             'fertigt eine Kopie der aktuellen Befehlszeile an bzw. schreibt sie zurück
    if m
        tp_back:=tp                                                    'Kopie der Adresse,der aktuellen Position
        bytemove(@strtmp,@tline,strsize(@tline))                       'Kopie der Eingabezeile, da im nächsten Schritt überschrieben wird
    else
        bytemove(@tline,@strtmp,strsize(@strtmp))                      'Befehlszeile wieder aus dem Backupspeicher übernehmen
        tp:=tp_back                                                    'Position innerhalb der Zeile zurückschreiben

con '******************************************* diverse Unterprogramme ***********************************************************************************************************
PRI spaces | c                                                                  'Zeichen lesen
   'einzelnes zeichen lesen
   repeat
      c := byte[tp]
      if c == 0 or c > " "
         return c
      tp++

PRI skipspaces                                                                  'Zeichen überspringen
   if byte[tp]
      tp++
   return spaces

PRI parseliteral | r, c                                                         'extrahiere Zahlen aus der Basiczeile
   r := 0
   repeat
      c := byte[tp]
      if c < "0" or c > "9"
         return r
      r := r * 10 + c - "0"
      tp++

PRI fixvar(c)                                                                   'wandelt variablennamen in Zahl um (z.Bsp. a -> 0)
   c&=caseBit
   return c - "A"

PRI isvar(c)                                                                    'Ueberpruefung ob Variable im gueltigen Bereich
   c := fixvar(c)
   return c => 0 and c < 26

pri fixnum(c)
    if c=>"0" and c=<"9"
       c-= 47
    return c

pri isnum(c)
    c:=fixnum(c)
    return c=>1 and c<11

PRI playerstatus
       'ios.sid_dmpstop
       'ios.sid_resetregisters
       'play:=0
       'close

PRI param(anzahl)|i
    i:=0
    repeat anzahl
        prm[i++]:=expr(1)                                                       'parameter mit kommatrennung
        komma
    prm[i++]:=expr(1)                                                           'letzter Parameter ohne skipspaces

pri is_string |b,c                                                                  'auf String überprüfen
    result:=0
    b:=tp
    c:=spaces
    if isvar(c)
       readvar_name(c)
    c:=spaces
    tp:=b

    case c
          quote,"$",152,163,176,200,196,195,193,188:result:=1


PRI komma
    is_spaces(",",1)

PRI is_spaces(zeichen,t)
    if spaces <> zeichen
       errortext(t)'@syn
    else
       skipspaces

PRI dollar
    if spaces=="$"
       skipspaces
       return 1

PRI klammer(m):b
         if spaces=="("
            skipspaces
            if m
               b:=expr(1)
            else
               b:=expr(0)
            if spaces<>")"
               errortext(1)
            skipspaces
         else
            errortext(1)

PRI klammerauf
    is_spaces(40,1)

PRI klammerzu
    is_spaces(41,1)

PRI getAnyNumber | c, t,i,punktmerker,d,zahl[20]

   case c := byte[tp]
      quote:
         if result := byte[++tp]
            if byte[++tp] == quote
              tp++
            else
               errortext(1)                                                     '("missing closing quote")
         else
            errortext(31)                                                       '("end of line in string")

      "#":
         c := byte[++tp]
         if (t := hexDigit(c)) < 0
            errortext(32)                                                       '("invalid hex character")
         result := t
         c := byte[++tp]
         repeat until (t := hexDigit(c)) < 0
            result := result << 4 | t
            c := byte[++tp]
         result:=fl.FFLOAT(result)

      "%":
         c := byte[++tp]
         if not (c == "0" or c == "1")
            errortext(33)                                                       '("invalid binary character")
         result := c - "0"
         c := byte[++tp]
         repeat while c == "0" or c == "1"
            result := result << 1 | (c - "0")
            c := byte[++tp]
         result:=fl.FFLOAT(result)

      "0".."9":
          i:=0
          punktmerker:=0
          c:=byte[tp++]
          repeat while c=="." or c=="e" or c=="E" or (c => "0" and c =< "9")    'Zahlen mit oder ohne punkt und Exponent
                 if c==point
                    punktmerker++
                 if punktmerker>1                                               'mehr als ein punkt
                    errortext(1)                                                'Syntaxfehler ausgeben
                 if c=="e" or c=="E"
                    d:=byte[tp++]
                    if d=="+" or d=="-"
                       byte[@zahl][i++]:=c
                       byte[@zahl][i++]:=d
                       c:=byte[tp++]
                       next
                 byte[@zahl][i++]:=c
                 c:=byte[tp++]
          byte[@zahl][i]:=0
          result:=fs.StringToFloat(@zahl)
          --tp

      other:
           errortext(34)                                                        '("invalid literal value")

PRI hexDigit(c)
'' Convert hexadecimal character to the corresponding value or -1 if invalid.
   if c => "0" and c =< "9"
      return c - "0"
   if c => "A" and c =< "F"
      return c - "A" + 10
   if c => "a" and c =< "f"
      return c - "a" + 10
   return -1

pri zahlenformat(h)|j
    j:=fl.ftrunc(h)
       if (j>MAX_EXP) or (j<MIN_EXP)                                            'Zahlen >999999 oder <-999999  werden in Exponenschreibweise dargestellt
           return FS.FloatToScientific(h)                                       'Zahlenwerte mit Exponent
       else
           return FS.FloatToString(h)                                           'Zahlenwerte ohne Exponent

con '****************************************** Directory-Anzeige-Funktion *******************************************************************************************************
PRI h_dir(str) | stradr,n,i,dlen,dd,mm,jj,dr,ad,ps                 'hive: verzeichnis anzeigen
{{h_dir - anzeige verzeichnis}}                                                 'mode 0=keine Anzeige,mode 1=einfache Anzeige, mode 2=erweiterte Anzeige
  mount
  'xstart:=ios.getx                                                             'Initial-X-Wert
  if strsize(str)<3
     str:=@ext5                                                                 'wenn kein string uebergeben wird, alle Dateien anzeigen
  else
     repeat 3                                                                   'alle Zeichen von STR in Großbuchstaben umwandeln
        if byte[str][i]>96
           byte[str][i]^=32
        i++

  ios.sddir                                                                     'kommando: verzeichnis öffnen
  n := 0                                                                        'dateizaehler
  i := 0                                                                        'zeilenzaehler
 repeat  while (stradr:=ios.sdnext)<>0                                          'wiederholen solange stradr <> 0


    dlen:=ios.sdfattrib(0)                                                      'dateigroesse
    dd:=ios.sdfattrib(10)                                                       'Aenderungsdatum tag
    mm:=ios.sdfattrib(11)                                                       'Aenderungsdatum monat
    jj:=ios.sdfattrib(12)                                                       'Aenderungsdatum Jahr
    dr:=ios.sdfattrib(19)                                                       'Verzeichnis?

      scanstr(stradr,1)                                                         'dateierweiterung extrahieren

      ifnot ios.sdfattrib(17)                                                   'unsichtbare Dateien ausblenden
        if strcomp(@buff,str) or strcomp(str,@ext5)                             'Filter anwenden
             filenumber++

          '################## Bildschrirmausgabe ##################################
           'if modes>0                                                            'wenn Verzeichnis,dann andere Farbe
               ifnot dr
                    n++
               ios.print(stradr)
               erweitert(dlen,dd,mm,jj)
               ios.printnl
               i++
               if i==20                                                            'nach 20 Zeilen warten auf Taste
                  if ios.ser_rx == 24'CHAR_ESC                                     'auf Taste warten, wenn Str-X dann Ausstieg
                     close                                                         '**********************************
                     filenumber:=n                                                 'Anzal der Dateien merken
                     abort                                                        '**********************************

                 i := 0                                                           '**********************************
           if n<DIR_ENTRY                                                         'Begrenzung der Einträge auf die mit DIR_ENTRY vereinbarte
              ps:=(n-1)*13
              ad:=DIR_RAM+ps
              stringschreiben(ad,0,stradr,1)                                      'Dateiname zur spaeteren Verwendung in ERam speichern an adresse n


 ios.printdec(n)                                                                   'Anzahl Dateien
 errortext(43)
 ios.printnl
 filenumber:=n                                                                    'Anzal der Dateien merken
 close                                                                            'ins Root Verzeichnis ,SD-Card schliessen und unmounten
 abort

PRI erweitert(laenge,tag,monat,jahr)|n                               'erweiterte Dateianzeige

         ios.ser_tx(9)   'tab    ios.print(string(27,"[C"))
         ios.printdec(laenge)
         ios.ser_tx(9) 'Tab
         ios.print(string(" Bytes"))
         ios.ser_tx(9) 'tab
         ios.printdec(tag)
         ios.printchar("/")
         ios.printdec(monat)
         ios.printchar("/")
         ios.printdec(jahr)

PRI scanstr(f,mode) | z ,c                                                      'Dateiendung extrahieren
   if mode==1
      repeat while strsize(f)
             if c:=byte[f++] == point                                           'bis punkt springen
                quit
   z:=0
   repeat 3                                                                     'dateiendung lesen
        c:=byte[f++]
        buff[z++] := c
   buff[z++] := 0
   return @buff

PRI activate_dirmarker(mark)                                                    'USER-Marker setzen

     ios.sddmput(DM_USER,mark)                                              'usermarker wieder in administra setzen
     ios.sddmact(DM_USER)                                                   'u-marker aktivieren

PRI get_dirmarker:dm                                                            'USER-Marker lesen

    ios.sddmset(DM_USER)
    dm:=ios.sddmget(DM_USER)

con '################################################## I2C Routinen #####################################

  #0, ACK, NAK

pub setupx

'' Define I2C SCL (clock) and SDA (data) pins

  dira[scl] := 0                                                '  float to pull-up
  outa[scl] := 0                                                '  write 0 to output reg
  dira[sda] := 0
  outa[sda] := 0

  repeat 9                                                      ' reset device
    dira[scl] := 1
    dira[scl] := 0
    if (ina[sda])
      quit


pub i2cwait(id) | ackbit

'' Waits for I2C device to be ready for new command

  repeat
    i2cstart
    ackbit := i2cwrite(id)
  until (ackbit == ACK)

PUB i2cstart                                               'i2c: dialog starten
  dira[sda] := 0                                                ' float SDA (1)
  dira[scl] := 0                                                ' float SCL (1)
  repeat while (ina[scl] == 0)                                  ' allow "clock stretching"

  dira[sda] := 1                                                ' SDA low (0)
  dira[scl] := 1                                                ' SCL low (0)


PUB i2cstop                                                'i2c: dialog beenden
  dira[sda] := 1                                                ' SDA low
  dira[scl] := 0                                                ' float SCL
  repeat while (ina[scl] == 0)                                  ' hold for clock stretch

  dira[sda] := 0                                                ' float SDA

PUB i2cwrite(data):nack                                     'i2c: byte senden

   nack := 0
   data <<= 24
   repeat 8
      outa[SDA] := (data <-= 1) & 1
      outa[SCL]~~
      outa[SCL]~
   dira[SDA]~
   outa[SCL]~~
   nack := ina[SDA]
   outa[SCL]~
   outa[SDA]~
   dira[SDA]~~

PUB i2cread(nack):data                                      'i2c: byte empfangen

   dira[SDA]~
   repeat 8
      outa[SCL]~~
      data := (data << 1) | ina[SDA]
      outa[SCL]~
   outa[SDA] := nack
   dira[SDA]~~
   outa[SCL]~~
   outa[SCL]~
   outa[SDA]~


PUB ping(adr):nack                                       'plx: device anpingen

  i2cstart
  nack := i2cwrite(adr<<1)
  i2cstop


DAT
                        org 0

entry                   jmp     #entry                   'just loops


{{
                            TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, exprESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}
