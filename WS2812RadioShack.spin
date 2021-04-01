'' =================================================================================================
''
''   File....... jm_ws2812.spin
''   Purpose.... 800kHz driver for WS2812/WS2812B LEDs
''   Author..... Jon "JonnyMac" McPhalen
''               Copyright (c) 2013-14 Jon McPhalen
''               -- see below for terms of use
''   E-mail..... jon@jonmcphalen.com
''   Started.... 
''   Updated.... 24 SEP 2014
''
'' =================================================================================================

{ -------------------------------------- }
{  NOTE: Requires system clock >= 80MHz  }
{ -------------------------------------- }


con { pixel limit }

  MAX_PIXELS = 150

con { rgb colors }

  ' borrowed from Gavin Garner's TM1804 LED driver
  ' -- additional colors by Lachlan   
  ' -- some alterations by JM
  ' Radio Shack 2760249 strip Doug Hilton
  '              BB GG RR   
  BLACK      =  $00_00_00    
  RED        =  $00_00_FF
  GREEN      =  $00_FF_00
  BLUE       =  $FF_00_00
  WHITE      =  $FF_FF_FF
  CYAN       =  $FF_FF_00
  MAGENTA    =  $FF_00_FF
  YELLOW     =  $00_FF_FF
  CHARTREUSE =  $00_FF_7F
  ORANGE     =  $00_60_FF
  AQUAMARINE =  $D4_FF_7F
  PINK       =  $5F_5F_FF
  TURQUOISE  =  $C0_E0_3F
  REALWHITE  =  $C8_FF_FF
  INDIGO     =  $7F_00_3F
  VIOLET     =  $BF_7F_BF
  MAROON     =  $10_00_32
  BROWN      =  $00_06_0E
  CRIMSON    =  $3C_28_DC
  PURPLE     =  $FF_00_BC

var

  long  cog

  long  txp                                                     ' tx output pin
  long  striplen                                                ' # leds in strip
  long  resetticks                                              ' ticks in reset period
  long  t0h                                                     ' bit0 high time (ticks)      
  long  t0l                                                     ' bit0 low time
  long  t1h                                                     ' bir1 high time
  long  t1l                                                     ' bir1 low time
  long  bufaddr                                                 ' hub address of color buf

  long  rgbbuf[MAX_PIXELS]                                      ' rgb buffer
  
    
pub start(pin, pixels)

'' Start WS2812 LED driver
'' -- pin is serial output to WS2812 string
'' -- pixels is # of RGB LEDs in strip

  return startx(pin, pixels, 350, 800, 700, 600)                ' standard WS2812 timing
  

pub start_b(pin, pixels)

'' Start WS2812 LED driver for WS2812B LEDs
'' -- pin is serial output to WS2812B string
'' -- pixels is # of RGB LEDs in strip
                                                                        
  return startx(pin, pixels, 350, 900, 900, 350)                ' WS2812B timing
  
  
pub startx(pin, pixels, ns0h, ns0l, ns1h, ns1l) | ustix    

'' Start WS2812/WS2812B LED driver
'' -- pin is serial output to WS2812 string
'' -- pixels is # of RGB LEDs in strip
'' -- ns0h is 0-bit high timing (ns)
'' -- ns0l is 0-bit low timing (ns)
'' -- ns1h is 1-bit high timing (ns)
'' -- ns1l is 1-bit low timing (ns)



  stop                                                          ' stop if running
  dira[pin] := 0                                                ' clear tx pin in this cog

  if (clkfreq < 80_000_000)                                     ' requires 80MHz clock
    return 0

  ustix := clkfreq / 1_000_000                                  ' ticks in 1us

  ' set cog parameters

  txp        := pin                                           
  striplen   := 1 #> pixels <# MAX_PIXELS                       ' limit led count
  resetticks := ustix * 50                                      ' 50.00us min reset timing
  t0h        := ustix * ns0h / 1000                             ' set pulse timing values
  t0l        := ustix * ns0l / 1000
  t1h        := ustix * ns1h / 1000
  t1l        := ustix * ns1l / 1000
  bufaddr    := @rgbbuf

  cog := cognew(@ws2812, @txp) + 1                              ' start the cog

  return cog


pub stop

'' Stops WS2812 cog (if running)

  if (cog)
    cogstop(cog - 1)
    cog := 0

  off                                                           ' clear rgb buffer for re-start


pub num_pixels

'' Returns number of RGB pixels in string

  return striplen
  
  
pub color(r, g, b) : rgb

'' Packs r-g-b bytes into long
     
  rgb.byte[2] := r                                              ' r << 16
  rgb.byte[1] := g                                              ' g << 8
  rgb.byte[0] := b                                              ' b << 0


pub colorx(r, g, b, level)

'' Packs r-g-b bytes into long
'' -- level (0 to 255) used to adjust brightness (0 to 100%)

  if (level =< 0)
    return $00_00_00
    
  elseif (level => 255)
    return color(r, g, b)
    
  else
    r := r * level / 255                                        ' apply level to rgb   
    g := g * level / 255        
    b := b * level / 255        
    return color(r,g,b)'(r, g, b) 


pub wheel(pos)

'' Creates color from 0 to 255 position input
'' -- colors transition r->g->b back to r

  if (pos < 85)
    return color(255-pos*3, pos*3, 0)
  elseif (pos < 170)
    pos -= 85
    return color(0, 255-pos*3, pos*3)
  else
    pos -= 170
    return color(pos*3, 0, 255-pos*3)


pub wheelx(pos, level)

'' Creates color from 0 to 255 position input
'' -- colors transition r-g-b back to r
'' -- level is brightness, 0 to 255

  if (pos < 85)
    return colorx(255-pos*3, pos*3, 0, level)
  elseif (pos < 170)
    pos -= 85
    return colorx(0, 255-pos*3, pos*3, level)
  else
    pos -= 170
    return colorx(pos*3, 0, 255-pos*3, level)

 
pub set(ch, rgb)

'' Writes rgb value to channel ch in buffer
'' -- rgb is packed long in form $RR_GG_BB

  if ((ch => 0) and (ch < striplen))
    rgbbuf[ch] := rgb


pub setx(ch, rgb, level)

'' Writes scaled rgb value to channel ch in buffer
'' -- rgb is packed long in form $RR_GG_BB
'' -- level is brightness, 0 to 255

  if ((ch => 0) and (ch < striplen))
    rgbbuf[ch] := scale_rgb(rgb, level)


pub scale_rgb(rgb, level)

  if (level =< 0)
    return $00_00_00
    
  elseif (level < 255)
    rgb.byte[2] := rgb.byte[2] * level / 255
    rgb.byte[1] := rgb.byte[1] * level / 255 
    rgb.byte[0] := rgb.byte[0] * level / 255 
  
  return rgb
      

pub set_rgb(ch, r, g, b)

'' Writes rgb elements to channel ch in buffer
'' -- r, g, and b are byte values, 0 to 255

  set(ch, color(r, g, b))   


pub set_red(ch, level)

'' Sets red led level of selected channel

  if ((ch => 0) and (ch < MAX_PIXELS))                          ' valid?
    byte[@rgbbuf + (ch << 2) + 2] := 0 #> level <# 255          '  set it
    

pub set_green(ch, level)

'' Sets green led level of selected channel

  if ((ch => 0) and (ch < MAX_PIXELS))                    
    byte[@rgbbuf + (ch << 2) + 1] := 0 #> level <# 255    


pub set_blue(ch, level)

'' Sets blue led level of selected channel

  if ((ch => 0) and (ch < MAX_PIXELS))                    
    byte[@rgbbuf + (ch << 2) + 0] := 0 #> level <# 255    

    
pub set_all(rgb)

'' Sets all channels to rgb
'' -- rgb is packed long in form $RR_GG_BB

  longfill(@rgbbuf, rgb, striplen)  

    
pub fill(first, last, rgb) | swap

'' Fills first through last channels with rgb
'' -- rgb is packed long in form $RR_GG_BB

  first := 0 #> first <# striplen-1
  last  := 0 #> last  <# striplen-1

  if (first > last)
    swap  := first
    first := last
    last  := swap
  
  longfill(@rgbbuf[first], rgb, last-first+1)


pub off

'' Turns off all LEDs

  longfill(@rgbbuf, $00_00_00, striplen)


pub read(ch)

'' Returns color of channel

  if ((ch => 0) and (ch < striplen))                          ' valid?
    return rgbbuf[ch]
  else
    return 0

  
pub address

'' Returns address of color array

  return @rgbbuf


pub transfer(p_src, n)

'' Transfter n longs from p_src to rgb buffer

  longmove(@rgbbuf, p_src, n)
  

pub running

'' Returns > 0 if running

  return cog
 

dat { auto-run ws2812 driver } 

                        org     0

ws2812                  mov     r1, par                         ' hub address of parameters -> r1
                        movd    :read, #txpin                   ' location of cog parameters -> :read(dest)
                        mov     r2, #8                          ' get 8 parameters
:read                   rdlong  0-0, r1                         ' copy parameter from hub to cog
                        add     r1, #4                          ' next hub element
                        add     :read, INC_DEST                 ' next cog element                         
                        djnz    r2, #:read                      ' done?
                        
                        mov     txmask, #1                      ' create mask for tx
                        shl     txmask, txpin
                        andn    outa, txmask                    ' set to output low
                        or      dira, txmask


rgb_main                mov     bittimer, resettix              ' set reset timing  
                        add     bittimer, cnt                   ' sync timer 
                        waitcnt bittimer, #0                    ' let timer expire                             
                        
                        mov     addr, hubpntr                   ' point to rgbbuf[0]
                        mov     nleds, ledcount                 ' set # active leds

frame_loop              rdlong  colorbits, addr                 ' read a channel
                        add     addr, #4                        ' point to next


' Correct placement of color bytes for WS2812
'   $RR_GG_BB --> $GG_RR_BB

fix_colors              mov     r1, colorbits                   ' copy for red
                        mov     r2, colorbits                   ' copy for green
                        and     colorbits, HX_0000FF            ' isolate blue
                        shr     r1, #8                          ' fix red pos (byte1)
                        and     r1, HX_00FF00                   ' isolate red
                        or      colorbits, r1                   ' add red back in
                        shl     r2, #8                          ' fix green pos (byte2)
                        and     r2, HX_FF0000                   ' isolate green
                        or      colorbits, r2                   ' add green back in

                        
' Shifts long in colorbits to WS2812 chain
'
'  WS2812 Timing 
'
'  0       0.35us / 0.80us
'  1      0.70us / 0.60us
'
'  WS2812B Timing
'
'  0       0.35us / 0.90us
'  1       0.90us / 0.35us
'
'  At least 50us (reset) between frames

shift_out               shl     colorbits, #8                   ' left-justify bits
                        mov     nbits, #24                      ' shift 24 bits (3 x 8) 

:loop                   rcl     colorbits, #1           wc      ' msb --> C
        if_c            mov     bittimer, bit1hi                ' set bit timing  
        if_nc           mov     bittimer, bit0hi                
                        or      outa, txmask                    ' tx line 1  
                        add     bittimer, cnt                   ' sync bit timer  
        if_c            waitcnt bittimer, bit1lo                
        if_nc           waitcnt bittimer, bit0lo 
                        andn    outa, txmask                    ' tx line 0             
                        waitcnt bittimer, #0                    ' hold while low
                        djnz    nbits, #:loop                   ' next bit

                        djnz    nleds, #frame_loop              ' done with all leds?

                        jmp     #rgb_main                       ' back to top

        
' --------------------------------------------------------------------------------------------------

INC_DEST                long    1 << 9                          ' to increment D field

HX_0000FF               long    $0000FF                         ' byte masks
HX_00FF00               long    $00FF00
HX_FF0000               long    $FF0000

txpin                   res     1                               ' tx pin #
ledcount                res     1                               ' # of rgb leds in chain
resettix                res     1                               ' frame reset timing
bit0hi                  res     1                               ' bit0 high timing
bit0lo                  res     1                               ' bit0 low timing
bit1hi                  res     1                               ' bir1 high timing    
bit1lo                  res     1                               ' bir1 low timing     
hubpntr                 res     1                               ' pointer to rgb array

txmask                  res     1                               ' mask for tx output

bittimer                res     1                               ' timer for reset/bit
addr                    res     1                               ' address of current rgb bit
nleds                   res     1                               ' # of channels to process
colorbits               res     1                               ' rgb for current channel
nbits                   res     1                               ' # of bits to process

r1                      res     1                               ' work vars
r2                      res     1
r3                      res     1

                        fit     496                                    

                        
dat { license }

{{

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}  
