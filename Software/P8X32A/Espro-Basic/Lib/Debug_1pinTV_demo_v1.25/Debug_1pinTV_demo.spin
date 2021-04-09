'' ┌──────────────────────────────────────────────────────────────────────────┐
'' │ Debug using 1-PinTV and 1-Pin KBD demo                             v1.20 │
'' ├──────────────────────────────────────────────────────────────────────────┤
'' │  Authors:           (c) 2010 "Cluso99" (Ray Rodrick)                     │
'' │  Acknowledgements:  see relevant files for authors and acknowledgements  │
'' │  License   MIT License - See end of file for terms of use                │
'' └──────────────────────────────────────────────────────────────────────────┘
'' RR20100424   v1.10   Add sample code for 1-Pin Keyboard driver
''                       and include TV calcs program in archive.
''
'' Demo program just reads and writes characters from/to the serial port (echoes input)
''   It also echoes the input characters (optionally in hex) to the debug port (the 1-pinTV cog)
''   for display on a TV.
'' v1.10 adds the 1-pinKBD driver also. This can easily be commented out if not required.
''   Any characters typed on the keyboard are also echoed to both the serial port and debug port.
'' RR20100505   v1.20   Add auto-calculation of parameters by just setting PAL/NTSC & cols
'' RR20100505   v1.25   Code shrink (for later VT100 use); variable screen size

'──────────────────────────────────────────────────────────────────────────────────────────────────
'  Here is the 1-Pin TV connection diagram...
'                              270R(100R-1K1)                               
'   Prop tvPin Pxx (P14) ────────────────────────────────────────────────┐
'                        ──┐                                             ┌• TV  
'                          ┴                                             ┴   
'──────────────────────────────────────────────────────────────────────────────────────────────────
'  Here is the 1-Pin Keyboard connection diagram...
'                          ┬ 5V                ┬ ┬ 5V                    ┬    Keyboard
'                        ──┘               10K   10K                   └─•  +5V
'                                            ──┻─┼─────────────────────────•  kbdclk 
'   Prop kdPin Pxx (P26) ──────────────────────┻─────────────────────────•  kbddata
'                        ──┐       100R                                  ┌─•  Gnd
'                          ┴                                             ┴
'──────────────────────────────────────────────────────────────────────────────────────────────────
                                                      
                                                      
CON                                                   
' Select for your hardware                            
                                                      

' Protoboard, Demoboard, TriBlade#1, etc
  _XINFREQ = 5_000_000 + 0000
  _CLKMODE = XTAL1 + PLL16X                            

  rxPin  = 31                   'serial
  txPin  = 30
  baud   = 19200
  tvPin  = 10                   'TV pin (1-pin version)  (best pin to use if trying on existing circuit)
  kdPin  = 17                   'Kbd pin (1-pin version) (use this pin    if trying on existing circuit)


{
' TriBlade#2
' _XINFREQ = 5_000_000 + 0000
' _XINFREQ = 6_000_000 + 0000   'most are 5_000_000
  _XINFREQ = 6_500_000 + 0000   'most are 5_000_000
  _CLKMODE = XTAL1 + PLL16X
' _XINFREQ = 13_500_000 + 0000  'most are 5_000_000
' _CLKMODE = XTAL1 + PLL8X

  rxPin  = 31                   'serial
  txPin  = 30
  baud   = 115200
  tvPin  = 14                   'TV pin (1-pin version)
  kdPin  = 26                   'Kbd pin (1-pin version)
}


OBJ
  fdx   :       "FullDuplexSerial"                      'serial driver
  dbg   :       "Debug_1pinTV"                          'debug display driver
  kb    :       "Debug_1pinKBD"                         'debug keyboard driver

PUB main | ch, i, j, t 

' waitcnt(clkfreq*5 + cnt)                              'delay (5 secs) to get terminal program runnining (if required)

  fdx.start(31,30,0,baud)                               'start serial driver to PC
  dbg.start(tvPin)                                      'start the Debug 1pinTV driver

  fdx.tx(13)                                            '<cr> in case 0 does not clear screen
  fdx.tx(0)                                             'clear screen
  fdx.str(string("Debug demo v1.25",13))
  dbg.chr(0)                                            'clear screen
  dbg.str(string("Debug demo v1.25",13))

'start the 1pinKBD driver
'──────────────────────────────────────────────────────────────────────────────────────────────────
  'first calculate the timing
  '  note you can skip this if you always use the same kbd & xtal by and hardcode the times in kb.start below
  fdx.str(string("Hit <spacebar> to synchronise keyboard "))
  dbg.str(string("Hit <spacebar> to synchronise keyboard "))
  t := kb.calckbdtime(kdpin)-5                            'calculate the keyboard timing
  fdx.str(string("Timing = "))                          '\ optionally show the timing calculated
  fdx.dec(t & $FFFF)                                    '|
  fdx.tx(",")                                           '|
  fdx.dec(t >> 16)                                      '/
  fdx.tx(13)
  dbg.tx(13)                                '<cr>
  'start the 1pinKBD driver (using the timing returned)
  kb.start(kdpin, t & $FFFF, t >> 16)                   'start the 1pinKbd driver 
'──────────────────────────────────────────────────────────────────────────────────────────────────
' kb.start(kdpin, 6741, 7259)                           'start the 1pinKbd driver (e.g. fixed bittimes)
'──────────────────────────────────────────────────────────────────────────────────────────────────

  'display the video parameters
  if dbg#PAL
    dbg.str(string("PAL "))
  else
    dbg.str(string("NTSC "))
  dbg.dec(dbg#ocols)
  dbg.chr("x")
  dbg.dec(dbg#orows)
  dbg.chr(13)

  'fill the remaining screen as an example
  repeat j from 0 to dbg#orows -5                       'rows less 4
    repeat i from 0 to dbg#ocols -1                     'cols
      dbg.chr(i + $30)                                  'character sequence from 0...


  repeat
    ch := fdx.rxcheck                                   'get an input char from pc (-1 if none)
    if ch <> -1                                         'if input character
      fdx.tx(ch)                                        'display it on the pc
      dbg.chr(ch)                                       'display on debug screen
'      dbg.chr("$")                                      '\ uncomment to send out the hex characters
'      dbg.hex(ch,2)                                     '|   to the debug screen
'      dbg.chr(" ")                                      '/
    ch := kb.rxcheck                                    'get an input char from kbd (-1 if none)
    if ch <> -1                                         'if input character
      fdx.tx(ch)                                        'display it on the pc
      dbg.chr(ch)                                       'display on debug screen

{
'other examples of reading the keyboard characters

    if kb.peek <> 0                                     'see if input char (0 if none)
      ch := kb.in                                       'get the keyboard char
      dbg.out(ch)                                       'display it
      fdx.tx(ch)

    if kb.rxavail                                       'see if input char (true -1 if avail)
      ch := kb.in                                       'get the keyboard char
      tv.out(ch)                                        'display it
      fdx.tx(ch)
}

                
dat

{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    TERMS OF USE: Parallax Object Exchange License                                            │                                                            
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
