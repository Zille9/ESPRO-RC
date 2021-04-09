CON 'Signaldefinitionen
'signaldefinition regnatix
#16,    D0,D1,D2,D3,D4,D5,D6,D7                         'datenbus
#24,    ESP32                                           'selektionssignale für administra und bellatrix
        BUS_WR                                          '/wr - schreibsignal
        BUS_HS '                                        '/hs - quittungssignal

DB_IN           = %00000011_00000000_00000000_00000000  'maske: dbus-eingabe
DB_OUT          = %00000011_00000000_00000000_11111111
'                       HWP                   |D7-D0 |
'                       SR2

'DB_IN          = %00000110_11111111_11111111_00000000  'maske: dbus-eingabe
'DB_OUT         = %00000110_11111111_11111111_11111111  'maske: dbus-ausgabe
'                      HWCL LPP|||---- ADR--| Daten D0-D7
'                      SRLE A21WR
'                        KD T
'                           C
'                           H
'putchar
'  dira := db_out 'datenbus auf ausgabe stellen
'  outa := %00000000_00111000_00000000_00000000          'prop2=0, wr=0
'  outa[7..0] := c                                       'daten --> dbus
'  outa[busclk] := 1                                     'busclk=1
'  waitpeq(%00000000_00000000_00000000_00000000,%00001000_00000000_00000000_00000000,0) 'hs=0?
'  dira := db_in                                         'bus freigeben
'  outa := %00001100_01111000_00000000_00000000           'wr=1, prop2=1, busclk=0

'bus_getchar2: wert                                  'bus: byte vom prop1 (bellatrix) empfangen
{{bus_getchar2:wert - bus: byte empfangen von prop2 (bellatrix)}}
'  outa := %00000110_00111000_00000000_00000000          'prop2=0, wr=1, busclk=1
'  waitpeq(%00000000_00000000_00000000_00000000,%00001000_00000000_00000000_00000000,0) 'hs=0?
'  wert := ina[7..0]                                     'daten einlesen
'  outa := %00000100_01111000_00000000_00000000          'prop2=1, busclk=0

obj    debug:"FullDuplexSerialExtended"

Pub main|i
dira := DB_IN
'outa[bus_hs]:=1
waitcnt(clkfreq+cnt)
repeat
    waitcnt(clkfreq+cnt)
    bus_putchar2("B")

PUB bus_putchar2(c)                                     'bus: byte an prop1 (bellatrix) senden
{{bus_putchar2(c) - bus: byte senden an prop2 (bellatrix)}}
  dira := db_out                                        'datenbus auf ausgabe stellen
  outa := %00000000_00000000_00000000_00000000          'prop2=0, wr=0
  outa[7..0] := c                                       'daten --> dbus
  waitpeq(%00000000_00000000_00000000_00000000,%00000100_00000000_00000000_00000000,0) 'hs=0?
  dira := db_in                                         'bus freigeben
  outa := %00000111_01000000_00000000_00000000           'wr=1, prop2=1, busclk=0

PUB bus_getchar2: wert                                  'bus: byte vom prop1 (bellatrix) empfangen
{{bus_getchar2:wert - bus: byte empfangen von prop2 (bellatrix)}}
  outa := %00000010_00000000_00000000_00000000          'prop2=0, wr=1, busclk=1
  waitpeq(%00000000_00000000_00000000_00000000,%00000100_00000000_00000000_00000000,0) 'hs=0?
  wert := ina[7..0]                                     'daten einlesen
  outa := %00000011_01000000_00000000_00000000          'prop2=1, busclk=0


