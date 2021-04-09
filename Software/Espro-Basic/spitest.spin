{{######################### SPI-Übertragungs-Versuch zum ESP32 ###################################











}}
con

Mosi    =24
Miso    =25
CLK     =26
CS      =27

msb     =1      'MSB first
wait    =50     '50 µsek wartezeit für Slave
Frame   =8      'Datengrösse pro übertragung (8 bit)
Mode    =0      'Modus 0

rx      =31
tx      =30
baud    =57600
obj   spi:"spidriver"
      debug:"FullDuplexSerialExtended"

var



pub main|i

   debug.start(rx, tx, 0, baud)
   spi.Init(Mosi, Miso, CLK, msb, wait, Frame, mode)
   i:=0
   repeat
       spi.ShiftOut(i, CS)
       i++
       if i>255
          i:=0


