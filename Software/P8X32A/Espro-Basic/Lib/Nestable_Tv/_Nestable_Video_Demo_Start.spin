{ File: _Video_Test.spin   this program was written
     by Michael Lord   www.electronicdesignservice.com  info@electronicdesignservice.com

  This program is used to demo the TV test driver program re-written to allow calls from nested objects.


Be sure to set the DisPin to the bank that you want to use.


}


CON

  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x


    ' DisPin     =   12    'Pin for TV    for propeller demo board       uses pins 12 13 14 15
    DisPin     =   8     'Pin for TV for our board                     uses pins 8 9 10 11

    

   

Obj
         text        :  "Mirror_TV_Text"
         vTest       :  "_Nested_Video_Test"


Var
        Long DecMonitorCnt       'This is the count when the electrometer relay is opened


        
'========================================================================================================================================
Pub Main               
'========================================================================================================================================
         
          Initalize        'this initializes all things like LCD and serial terminal  

          Text.str(string("Main"))              
          text.out($0D)
          text.out($0D)

          
       
'===============================================================================================================
 'This is the Main Program Loop

           
          
          Repeat
              FirstLeval
              vtest.NestedProg




'========================================================================================================================================
PUB FirstLeval  | index 
'========================================================================================================================================

  index := 0

          repeat while index < 8
                Text.out($0C)       'this is the set color command -- the next ascii char is the color
                text.out(index)
                text.str(string("First Leval Program Color = "))
                text.dec(index)
                text.out($0D)
                index := index + 1
                waitcnt(clkfreq * 1 + cnt)

   waitcnt(clkfreq * 3 + cnt) 
   text.out($0D)

                

   
'===================================================================================================================================
PUB Initalize                                                               
'===================================================================================================================================
                                                               'this initializes all things at startup like LCD and keyboard 



'This initalizes the TV display on pin DisPin

        
               text.start(DisPin)

               text.out(0)           'Clear TV display
               text.out(1)           'moves TV Display curser to home
               text.str(string("Wait Starting "  ))
               text.out($0D)


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




    
