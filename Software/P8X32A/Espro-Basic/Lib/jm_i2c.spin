'' =================================================================================================
''
''   File....... jm_i2c.spin
''   Purpose.... Low-level I2C routines (requires pull-ups on SCL and SDA)
''   Author..... Jon "JonnyMac" McPhalen
''               Copyright (c) 2009-2013 Jon McPhalen
''               -- elements inspired by code from Mike Green
''   E-mail.....  
''   Started.... 28 JUL 2009
''   Updated.... 07 APR 2013
''
'' =================================================================================================


con
 
  EE_SDA = 29                                                   ' boot eeprom
  EE_SCL = 28

 
con

  #0, ACK, NAK


var

  long  scl                                                     ' buss pins
  long  sda
    

pub setup

'' Setup I2C using Propeller EEPROM pins

  setupx(EE_SCL, EE_SDA)
         

pub setupx(sclpin, sdapin)

'' Define I2C SCL (clock) and SDA (data) pins

  longmove(@scl, @sclpin, 2)                                    '  copy pins
  dira[scl] := 0                                                '  float to pull-up
  outa[scl] := 0                                                '  write 0 to output reg
  dira[sda] := 0
  outa[sda] := 0

  repeat 9                                                      ' reset device
    dira[scl] := 1
    dira[scl] := 0
    if (ina[sda])
      quit
  
    
pub wait(id) | ackbit

'' Waits for I2C device to be ready for new command

  repeat
    start
    ackbit := write(id)
  until (ackbit == ACK)


pub start

'' Create I2C start sequence
'' -- will wait if I2C buss SDA pin is held low

  dira[sda] := 0                                                ' float SDA (1)
  dira[scl] := 0                                                ' float SCL (1)
  repeat while (ina[scl] == 0)                                  ' allow "clock stretching"

  dira[sda] := 1                                                ' SDA low (0)
  dira[scl] := 1                                                ' SCL low (0)

pub write(i2cbyte) : ackbit

'' Write byte to I2C buss
'' -- leaves SCL low

  i2cbyte := (i2cbyte ^ $FF) << 24                              ' move msb (bit7) to bit31
  repeat 8                                                      ' output eight bits
    dira[sda] := i2cbyte <-= 1                                  ' send msb first
    dira[scl] := 0                                              ' SCL high (float to p/u)
    dira[scl] := 1                                              ' SCL low

  dira[sda] := 0                                                ' relase SDA to read ack bit
  dira[scl] := 0                                                ' SCL high (float to p/u)  
  ackbit := ina[sda]                                            ' read ack bit
  dira[scl] := 1                                                ' SCL low

  return (ackbit & 1)


pub read(ackbit) | i2cbyte

'' Read byte from I2C buss

  dira[sda] := 0                                                ' make sda input

  repeat 8
    dira[scl] := 0                                              ' SCL high (float to p/u)
    i2cbyte := (i2cbyte << 1) | ina[sda]                        ' read the bit
    dira[scl] := 1                                              ' SCL low
                             
  dira[sda] := !ackbit                                          ' output ack bit 
  dira[scl] := 0                                                ' clock it
  dira[scl] := 1

  return (i2cbyte & $FF)

pub stop

'' Create I2C stop sequence 

  dira[sda] := 1                                                ' SDA low
  dira[scl] := 0                                                ' float SCL
  repeat while (ina[scl] == 0)                                  ' hold for clock stretch
  
  dira[sda] := 0                                                ' float SDA


dat

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
