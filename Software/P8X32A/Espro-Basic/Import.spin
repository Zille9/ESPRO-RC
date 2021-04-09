con
{{
 ---------------------------------------------------------------------------------------------------------

Hive-Computer-Projekt

Name            : TRIOS-Basic
Chip            : Regnatix-Code
Version         : 2.108
Dateien         :

Beschreibung    : Importmodul für Text-Dateien ->importiert ein, als Textdatei vorliegendes Basic-Programm von SD-Karte in den Speicher

Notes:
01-05-2014      -erste funktionierende Version
                -um die Sache optisch besser zu gestalten, wird noch ein Hinweisfenster mit dem System-Tile-Font erstellt
                -6761 Longs frei

11-05-2014      -Laderoutine durch Sicherheitsabfrage ergänzt, es wird überprüft, ob es sich bei der zu ladenden Datei um eine Textdatei handelt
                -überflüssige Variablen entfernt
                -PI und Wurzelzeichen in der Abfrage gültiger Zeichen hinzugefügt
                -6798 Longs frei
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
   long tp, nextlineloc                                                       'Kommandozeile,Zeilenadresse
   long speicheranfang,speicherende                                           'Startadresse-und Endadresse des Basic-Programms
   byte tline[linelen]                                                        'Eingabezeilen-Puffer

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
     BASIC    byte "BASIC.BIN",0
     BasicDir byte "BASIC",0

pub main
    ios.init
    speicheranfang:=$0                                                            'Programmspeicher beginnt ab adresse 0 im eRam
    speicherende:=$2                                                              'Programmende-marke
    read_filename
    ios.sdmount
    ios.sdchdir(@basicdir)
    ios.sdopen("R",@tline)
    processload
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

PRI processLoad | a,b,c,e,l',pr

   b:=0
   e:=ios.sdfattrib(0)
   l:=1
   repeat
      a := 0
      repeat
         c := ios.sdgetc
      '############### Überprüfung auf gültige Zeichen ###############
         if (c<32 or c>125) and not c==13 and not c==10 and not c==17 and not c==21
            ios.ram_wrbyte(0,PMARK_RAM)
            ios.print(string("Wrong Fileformat!"))
            ios.printdec(l)
            'ios.sid_beep(0)
            return
      '###############################################################
         b++
         if c == fReturn or b==e                                                'c==ios.sdeof  sdeof funktioniert nicht so richtig
            tline[a] := 0
            tp := @tline
            quit
         elseif c == fLinefeed
            next
         elseif c < 0
            quit
         elseif a < linelen-1
            tline[a++] := c
      if b==e and tline[a] == 0                                                 'c==ios.sdeof sdeof funktioniert nicht so richtig
         quit
      if c < 0
         ios.ram_wrbyte(0,PMARK_RAM)
         ios.print(string("Error while loading file!"))
         'ios.sid_beep(0)
         return
      tp := @tline
      a := spaces

      if a=>"0" and a =< "9"
            ios.printchar(46)                                                    'Punkt als Fortschrittsanzeige
            writeram                                                            'normaler Programmload
            Prg_End_Pos

      else
         if a <> 0
            ios.ram_wrbyte(0,PMARK_RAM)
            ios.print(string("Missing Linenumber!"))
            'ios.sid_beep(0)
            return

   RAM_CLEAR                                                                    'Programmspeicher hinter dem Programm loeschen
   'ios.printnl

pri binsave|datadresse,count
   datadresse:= 0
   count:=speicherende-2
   ios.sdxputblk(datadresse,count)
   ios.sdclose

PRI writeendekennung(adr)
    ios.ram_wrword($FFFF,adr)                                                   'Programmendekennung schreiben
    speicherende:=adr+2                                                         'neues Speicherende

PRI Prg_End_Pos                                                                 'letztes Zeichen der letzten Zeile (Programmende)
    nextlineloc := speicherende - 2

PRI findline(lineno):at
   at := speicheranfang
   repeat while ios.ram_rdword(at) < lineno and at < speicherende-2             'Zeilennummer
          at:=ios.ram_keep(at+2)'+1                                                     'zur nächsten zeile springen

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
      ios.sdclose
      'errortext(2,1)'@ln
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


PRI writeram | lineno
   lineno := parseliteral
   if lineno < 0 or lineno => 65535
      ios.sdclose
      'errortext(2,1)'@ln
   tokenize
   ios.ram_wrword(lineno,nextlineloc)                                           'zeilennummer schreiben
   nextlineloc+=2
   skipspaces                                                                   'leerzeichen nach der Zeilennummer ueberspringen
   repeat strsize(tp)+1
        ios.ram_wrbyte(byte[tp++],nextlineloc++)                                     'Zeile in den Programmspeicher uebernehmen

   writeendekennung(nextlineloc)                                                'Programmende setzen

PRI tokenize | tok, c, at, put, state, i, j, ntoks

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

PRI spaces | c
   'einzelnes zeichen lesen
   repeat
      c := byte[tp]
      if c==21 or c==17                                                         'Wurzelzeichen und Pi-Zeichen
         return c
      if c == 0 or c > " "
         return c
      tp++

PRI skipspaces
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
   if c => "a"
      c -= 32
   return c - "A"

PRI isvar(c)                                                                    'Ueberpruefung ob Variable im gueltigen Bereich
   c := fixvar(c)
   return c => 0 and c < 26
PRI RAM_CLEAR
    ios.ram_fill(speicherende,$20000-speicherende,0)                            'Programmspeicher hinter dem Programm loeschen

