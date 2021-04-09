con{{

 ---------------------------------------------------------------------------------------------------------

Hive-Computer-Projekt

Name            : TRIOS-Basic
Chip            : Regnatix-Code
Version         : 2.108
Dateien         :

Beschreibung    : Exportmodul für Basic-Dateien ->exportiert ein, im Speicher befindliches Basic-Programm als Textdatei auf die SD-Karte

Notes:
01-05-2014      -erste funktionierende Version
                -um die Sache optisch besser zu gestalten, wird noch ein Hinweisfenster mit dem System-Tile-Font erstellt
                -6901 Longs frei
}}
obj
  ios    :"reg_tiny"
'  gc     :"glob-con"

con
_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000
   version   = 2.108

   fEof      = $FF                     ' dateiende-kennung
   linelen   = 85                      ' Maximum input line length
   quote     = 34                      ' Double quote
   caseBit   = !32                     ' Uppercase/Lowercase bit
   point     = 46                      ' point
   STR_LEN   = 34                      ' Stringlänge von Stringvariablen in Arrays
   FIELD_LEN = 512                     ' Array-Feldgröße (max Feldgröße 8x8x8 -> Dim a(7,7,7)
   DIR_ENTRY = 546                     ' max.Anzahl mit DIR-Befehl gefundener Einträge
   STR_MAX   = 41                      ' maximale Stringlänge für Printausgaben und font
   DPL_CNT   = 1200                    ' Map-und Bildschirm-Shadow-Speicher-Zähler (40Spalten*30Zeilen=1200-Tiles)
'*****************Speicherbereiche**********************************************
   maxstack  = 20                      ' Maximum stack tiefe fuer gosub
   userPtr   = $1FFFF                  ' Ende Programmspeicher  128kb
   TMP_RAM   = $20000 '....$3FFFF      ' Bearbeitungsspeicher   128kb (fuer die Zeileneditierung bzw.Einfuegung von Zeilen)
   TILE_RAM  = $40000 '....$667FF      ' hier beginnt der Tile-Speicher fuer 14 Tiledateien
   SYS_FONT  = $66800 '....$693FF      ' ab hier liegt der System-Font 11kb
   MOUSE_RAM = $69400 '....$6943F      ' User-Mouse-Pointer 64byte
   DIR_RAM   = $69440 '....$6AFFF      ' Puffer fuer Dateinamen 7103Bytes fuer 546 Dateinamen
   VAR_RAM   = $6B000 '....$77FFF      ' Variablen-Speicher fuer Array-Variablen a[0...511]-z[0...511] (13312 moegliche Variablen)
   MAP_RAM   = $78000 '....$79C27      ' Shadow-Display (Pseudo-Kopie des Bildschirmspeichers)
   'FREI_RAM   $79C28 .... $79FFF      ' freier RAM-Bereich 984 Bytes auch für Shadow-Display

   DATA_RAM = $7A000 '.... $7DFFF      ' 16kB DATA-Speicher

   BUTT_RAM = $7E000 '.... $7E4FF      ' ca.1kB Button Puffer
   WTILE_RAM= $7E500 '.... $7E5FF      ' Win-Tile Puffer hier können die Tiles, aus denen die Fenster gebaut werden geändert werden
   FUNC_RAM = $7E600 '.... $7EFFF      ' Funktions-Speicher, hier werden die selbstdefinierten Funktionen gespeichert

   ERROR_RAM = $7F000 '....$7FAFF      ' ERROR-Texte
   DIM_VAR   = $7FB00 '....$7FBFF      ' Variablen-Array-Dimensionstabelle
   DIM_STR   = $7FC00 '....$7FCFF      ' String-Array-Dimensionstabelle
   BACK_RAM  = $7FD00 '....$7FDFF      ' BACKUP RAM-Bereich 256 Bytes für Ladebalken
   'Frei-Ram = $7FE00  ....$7FEFF      ' noch freier Bereich 256 Bytes
   PMARK_RAM = $7FFF0                  ' Flag für Reclaim           Wert= 161
   BMARK_RAM = $7FFF1                  ' Flag für Basic-Warm-Start  Wert= 121
   SMARK_RAM = $7FFF2                  ' Flag für übergebenen Startparameter Wert = 222

   STR_ARRAY = $80000 '....$EE7FF      ' Stringarray-Speicher
   USER_RAM  = $EE800 '....$FFEFF      ' Freier Ram-Bereich, für Anwender, Backup-Funktion usw.

   'ADM_SPEC       = gc#A_FAT|gc#A_LDR|gc#A_SID|gc#A_LAN|gc#A_RTC|gc#A_PLX'%00000000_00000000_00000000_11110011
'***************** Button-Anzahl ************************************************
   BUTTON_CNT   = 32                       'Anzahl der möglichen Button
'******************Farben ********************************************************
  #$FC, Light_Grey, #$A8, Grey, #$54, Dark_Grey
  #$C0, Light_Red, #$80, Red, #$40, Dark_Red
  #$30, Light_Green, #$20, Green, #$10, Dark_Green
  #$1F, Light_Blue, #$09, Blue, #$04, Dark_Blue
  #$F0, Light_Orange, #$E6, Orange, #$92, Dark_Orange
  #$CC, Light_Purple, #$88, Purple, #$44, Dark_Purple
  #$3C, Light_Teal, #$28, Teal, #$14, Dark_Teal
  #$FF, White, #$00, Black

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

   MIN_EXP   = -999999
   MAX_EXP   =  999999

   num_of_toks  = 101

var
   long speicheranfang,speicherende                                           'Startadresse-und Endadresse des Basic-Programms
   byte tline[20]                                                             'Eingabezeilen-Puffer

dat

   tok0  byte "IF",0                                                                       '128    getestet
   tok1  byte "THEN",0                                                                     '129    getestet
   tok2  byte "INPUT",0    ' INPUT {"<prompt>";} <var> {,<var>}                            '130    getestet
   tok3  byte "PRINT",0    ' PRINT                                                         '131    getestet
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
   tok25 byte "NEXT", 0     ' NEXT <var>                                                    153 *  getestet
   tok26 byte "FOR", 0      ' FOR <var> = <expr> TO <expr>                                  154    getestet
   tok27 byte "TO", 0                                                                      '155    getestet
   tok28 byte "STEP", 0     ' optional STEP <expr>                                          156    getestet
   tok29 byte "RENUM",0     'Renumberfunktion                                               157    getestet
   tok30 byte "GATTR",0    ' Dateiattribute auslesen                                        158    getestet
   tok31 byte "VAL",0      'String in FLOAT-Zahlenwert umwandeln                            159    getestet
   tok32 byte "SQR",0                                                                    '  160    getestet
   tok33 byte "EXP",0                                                                  '    161    getestet
   tok34 byte "INT",0                                                                     ' 162    getestet
   tok35 byte "LOWER$", 0     'String in Kleinbuchstaben zurückgeben                        163 *  getestet
   tok36 byte "COMP$", 0    'Stringvergleich                                                164    getestet
   tok37 byte "LEN", 0      'Stringlänge zurueckgeben                                       165    getestet
   tok38 byte "READ", 0      'Data Lesen                                                   '166    getestet
   tok39 byte "LN",0                                                                   '    167    getestet
   tok40 byte "DATA", 0      'Data-Anweisung                                               '168    getestet
   tok41 byte "ABS",0                                               '                       169    getestet
   tok42 byte "SYS",0        'Systemfunktionen z.Bsp.anderer Grafikmodus                   '170    getestet
   tok43 byte "SGN",0                                                                   '   171    getestet
   tok44 byte "SIN",0                                                                     ' 172    getestet
   tok45 byte "COS",0                                                                     ' 173    getestet
   tok46 byte "PI",0         'Kreiszahl PI                                                 '174    getestet
   tok47 byte "RESTORE", 0   'Data-Zeiger zurücksetzen                                      175    getestet
   tok48 byte "CHR$", 0     'CHR$(expr)                                                     176    getestet
   tok49 byte "TAN",0                                                                  '    177    getestet
   tok50 byte "ATN",0                                                                     ' 178    getestet
   tok51 byte "INSTR",0    'Zeichenkette in einer anderen Zeichenkette suchen            '  179    getestet
   tok52 byte "END", 0      '                                                               180    getestet
   tok53 byte "PAUSE", 0    ' PAUSE <time ms> {,<time us>}                                  181    getestet
   tok54 byte "FILE", 0     ' FILE wert aus datei lesen oder in Datei schreiben             182    getestet
   tok55 byte "ELSE",0                                                                    ' 183    getestet
   tok56 byte "TAB", 0     'Tabulator setzen                                                184    getestet
   tok57 byte "MKFILE", 0    'Datei erzeugen                                                185    getestet
   tok58 byte "DUMP", 0     ' DUMP <startadress>,<anzahl zeilen>,<0..1> (0 Hram,1 Eram)     186    getestet
   tok59 byte "HEX",0      'Ausgabe von Hexzahlen mit Print                               ' 187    getestet
   tok60 byte "STRING$",0   'Zeichenwiederholung                                            188    getestet
   tok61 byte "DIM",0       'Stringarray dimensionieren                                     189    getestet
   tok62 byte "EDIT",0      'Zeile editieren                                                190    getestet
   tok63 byte "BLOAD",0      'Bin Datei laden                                               191    getestet
   tok64 byte "ASC",0      'ASCII-Wert einer Stringvariablen zurueckgeben                   192    getestet
   tok65 byte "UPPER$",0     'String in Großbuchstaben zurückgeben                        ' 193    getestet
   tok66 byte "CHDIR",0    ' Verzeichnis wechseln                                           194    getestet      kann nicht CD heissen, kollidiert sonst mit Hex-Zahlen-Auswertung in getanynumber
   tok67 byte "MID$",0     'Teilstring ab Position n Zeichen zurückgeben                  ' 195    getestet
   tok68 byte "RIGHT$",0    'rechten Teilstring zurückgeben                                '196    getestet
   tok69 byte "BEEP",0      'beep oder beep <expr> piepser in versch.Tonhoehen              197    getestet
   tok70 byte "STIME",0    'Stunde:Minute:Sekunde setzen ->                                 198    getestet
   tok71 byte "SDATE",0    'Datum setzen                                                    199    getestet
   tok72 byte "LEFT$",0     'linken Teilstring zurückgeben                                 '200    getestet
   tok73 byte "BIN",0       'Ausgabe von Binärzahlen mit Print                             '201    getestet
   tok74 byte "ON",0       ' ON GOSUB GOTO                                                  202    getestet
   tok75 byte "PEEK",0      'Byte aus Speicher lesen momentan nur eram                      203    getestet
   tok76 byte "GTIME",0    'Zeit   abfragen                                                 204    getestet
   tok77 byte "GDATE",0    'Datum abfragen                                                  205    getestet
   tok78 byte "MKDIR",0     ' Verzeichnis erstellen                                         206    getestet
   tok79 byte "PORT",0       'Port-Funktionen      Port s,i,o,p                             207 *  getestet
   tok80 byte "POKE",0      'Byte in Speicher schreiben momentan nur eram                   208    getestet
   tok81 byte "CLEAR",0     'alle Variablen loeschen                                        209    getestet
   tok82 byte "INKEY",0     'Auf Tastendruck warten Rueckgabe ascii wert                    210    getestet
   tok83 byte "FN",0         'mathematische Benutzerfunktionen                              211    getestet
   tok84 byte "COLOR",0     'Color-Funktionen                                               212    getestet
   tok85 byte "CLS",0       'Bildschirm löschen                                             213    getestet
   tok86 byte "POS",0    'setze Cursorposition                                           214    getestet
   tok87 byte "TIMER",0     'Timer-Funktionen                                               215    getestet
'**************************** Grafik-Funktionen *******************************************************************
   tok88 byte "PSET",0      'Pixel setzen                                                   216    getestet
   tok89 byte "LINE",0      'Linie zeichnen                                                 217    getestet
   tok90 byte "RECT",0      'Rechteck zeichnen (gefüllt oder ungefüllt)                     218    getestet
   tok91 byte "CIRCLE",0    'Kreis oder Ellipse zeichnen (gefüllt oder ungefüllt)           219    getestet
   tok92 byte "POLYGON",0   'Polygon zeichnen (gefüllt oder ungefüllt)                      220    getestet
   tok93 byte "BRUSH",0     'Füllfarbe                                                      221
   tok94 byte "PEN",0       'Stiftfarbe                                                     222    getestet
   tok95 byte "WIDTH",0     'Stiftbreite                                                    223    getestet
   tok96 byte "GSCROLL",0   'Grafikbildschirm scrollen                                      224    getestet
   tok97 byte "CUR",0       'Cursor setzen oder löschen                                     225    getestet
   tok98 byte "I2C",0       'I2C - Funktion                                                 226
   tok99 byte "LED",0       'WS2812 LED-Strip                                               227
   tok100 byte"TEMP",0      'DS18D12 Temperatursensorwert lesen                             228
   tok101 byte"FONT",0      'Font ändern                                                    229


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


dat
     BASIC byte "BASIC.BIN",0
     BasicDir byte "BASIC",0

pub main
    ios.init
    speicheranfang:=$0                                                            'Programmspeicher beginnt ab adresse 0 im eRam
    read_filename
    ios.sdmount
    ios.sdchdir(@basicdir)
    ios.sdopen("W",@tline)
    processsave
    ios.sdclose
    ios.sdopen("r",@basic)
    ios.BOOT_Partition(@basic)
    ios.sdclose
    'ios.stop

pri read_filename|i,adr
    adr:=ios#PARAM
    i:=0
    repeat while tline[i++]:=ios.ram_rdbyte(adr++)
    tline[i]:=0
    speicherende:=ios.ram_rdlong(adr++)

PRI processSave | a, c, d,e, ntoks,n,stk,mtk',pr
   'ntoks :=(@tokx - @toks) / 2
   a := speicheranfang
   n:=speicherende
   stk:=0                                                                       'SID_Befehlsmarker
   mtk:=0                                                                       'Mathe-Funktions,arker
   repeat while a+2 < n
      d := ios.ram_rdword(a)
      ios.sddec(d)
      ios.sdputc(" ")
      e := a + 2                                                                  'Speicherplatz
      repeat while c := ios.ram_rdbyte(e++)

         if c => 128
            if (c -= 128) < num_of_toks
                  ios.sdputstr(@@toks[c])                                       'Tokenname schreiben (@token)'
                  ios.sdputc(" ")
         else
            ios.sdputc(c)
      ios.sdputc(fReturn)
      ios.sdputc(fLinefeed)
      a:=e                                                                      'ende Speicherplatz fuer naechste Zeile an a uebergeben
      ios.printchar(46)
      'percent(a-1,n)                                                            'Speicheranzeige Fortschritts-Balken

'***************** noch eine leerzeile schreiben sonst fehlt die letzte zeile beim laden *****************
   ios.sdputc(fReturn)
   ios.sdputc(fLinefeed)


