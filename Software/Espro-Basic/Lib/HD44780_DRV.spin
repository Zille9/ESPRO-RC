{{
  For more info on HD44780 command set, I recommend this site:
  http://www.dinceraydin.com/lcd/commands.htm
}}
var
byte buffer[32]
byte mode    
byte ready

pub start(initInstructions) | i
'' Starts new cog running Driver
'' Usage: pass STRING pointer containing intitialization instructions
'' e.g. start(string(%00001101, %00000001, $05))          
mode := %00000100
bytemove(@buffer, initInstructions, strsize(initInstructions))  
cognew(@asmstart, @buffer)

pub out (output)
'' Write textual output to the display
'' Usage: pass STRING the pointer to this method
'' e.g. out(string("HELLO, WORLD!!!")) 
repeat             
while ready == $00
mode := %00000101                     
bytemove(@buffer, output, strsize(output))

pub instr (output)
'' Write instruction to display
'' Usage: pass STRING pointer to this method
'' e.g. instr(string($05))     
repeat             
while ready == $00
mode := %00000100       
bytemove(@buffer, output, strsize(output))

dat
                        org 0  
                                
asmstart                mov     dira, dirs 
                        mov     outa, allOff

                        add     modeptr, par  
                        add     isReady, par
idle                    mov     dptr,  par
:ready                  wrbyte  one, isReady       
                                                
write                   rdbyte  data, dptr                wz
              if_z      jmp     #idle        
              if_nz     wrbyte  zero, dptr
                            
:begin                  wrbyte  zero, isReady
                        
                        shl     data, #8
                        rdlong  outa, modeptr  
                        or      outa, data 

                        mov     time, cnt
                        add     time, delay
                        waitcnt time, #$00 
                        
                        mov     outa, allOff     
                                          
                        add     dptr, #$01                 
                        jmp     #write
           
modeptr long  32
isReady long  33 

dirs    long  %00000000_00000000_11111111_00000111
allOn   long  $FFFFFFFF                           
allOff  long  $00000000
        
delay   long  5000     

zero    byte long $00
one     byte long $01 

data    res   1

time    res   1

dptr    res   1
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
