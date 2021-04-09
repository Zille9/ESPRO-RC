'' ┌──────────────────────────────────────────────────────────────────────────┐
'' │ Debug using 1-PinTV demo                                           v1.05 │
'' ├──────────────────────────────────────────────────────────────────────────┤
'' │  Authors:           (c) 2010 "Cluso99" (Ray Rodrick)                     │
'' │  Acknowledgements:  see relevant files for authors and acknowledgements  │
'' │  License   MIT License - See end of file for terms of use                │
'' └──────────────────────────────────────────────────────────────────────────┘
''
'' Demo program just reads and writes characters from/to the serial port (echoes input)
''  It also echoes the input characters (in hex) to the debug port (the 1-pinTV cog)
''  for display on a TV.
'
'  Here is the debug connection diagram...
'
'      Prop tvPin Pxx ───────────────────────┐
'                     ──┐            270R    ┌• TV
'                       ┴       (*100R-1K1)  ┴


CON
' Select for your hardware
{
' Protoboard, Demoboard, TriBlade#1, etc
  _XINFREQ = 5_000_000 + 0000
  _CLKMODE = XTAL1 + PLL16X                            

  rxPin  = 31                   'serial
  txPin  = 30
  baud   = 115200
  tvPin  = 14                   'TV pin (1-pin version)  (best pin to use if trying on existing circuit)
}


' TriBlade#2
  _XINFREQ = 5_000_000 + 0000
'  _XINFREQ = 6_000_000 + 0000   'most are 5_000_000
'  _XINFREQ = 6_500_000 + 0000   'most are 5_000_000
  _CLKMODE = XTAL1 + PLL16X
'  _XINFREQ = 13_500_000 + 0000   'most are 5_000_000
'  _CLKMODE = XTAL1 + PLL8X

  rxPin  = 31                   'serial
  txPin  = 30
  baud   = 115200
  tvPin  = 8                   'TV pin (1-pin version)


OBJ
  fdx   :       "FullDuplexSerial"                      'serial driver
  dbg   :       "Debug_1pinTV"                          'debug display driver

VAR
   
PUB main | ch, i, j

'  waitcnt(clkfreq*5 + cnt)                              'delay (5 secs) to get terminal program runnining (if required)

  fdx.start(31,30,0,baud)                               'start serial driver to PC
  dbg.start(tvPin)                                      'start the Debug 1pinTV driver

  fdx.tx(13)                                            '<cr> in case 0 does not clear screen
  fdx.tx(0)                                             'clear screen
  fdx.str(string("Debug demo v1.08",13))
  dbg.chr(0)                                            'clear screen
  dbg.str(string("Debug demo v1.08",13))

  repeat j from 0 to 22
    repeat i from 0 to 39
      dbg.chr(i + $30)

  dbg.gotoxy(10,5)                                      'goto x=col=10, y=row=line=5 (home=0,0)
  dbg.str(string(" goto "))

  repeat
    if ch := fdx.rx                                     'get an input character from the pc
      fdx.tx(ch)                                        'display it on the pc
      dbg.chr("$")
      dbg.hex(ch,2)                                     'debug: send the hex characters to the debug screen
      dbg.chr(" ")

                
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
