/*
  Created by Fabrizio Di Vittorio (fdivitto2013@gmail.com) - www.fabgl.com
  Copyright (c) 2019-2020 Fabrizio Di Vittorio.
  All rights reserved.

  This file is part of FabGL Library.

  FabGL is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  FabGL is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with FabGL.  If not, see <http://www.gnu.org/licenses/>.
 */


/** FabGl-Terminal für Propeller-Chip (ähnlich Micromite Companion)
 *  *******    Version 1.0 - Grundfunktionen zur Nutzung des TRIOS-Basic *********
 *  23-03-2021  -Grundfunktionen etabliert
 *              -geplant sind noch WIFI-Unterstützung (NTP,Web-Server o.ä.)
 *              -Grafikfunktionen ??!
 *              -CP/M, VIC20-Emulator über sd-Card starten?
 *              -Anbindung externer Hardware?
 *              -Konzept ist noch offen
 *              
 *              
 * Loopback VT/ANSI Terminal
 */


#include "fabgl.h"

int ESCCH2=0;       //ESC-Marker

  // foregrounds
#define F_BLACK     "\e[30m"
#define F_RED       "\e[31m"
#define F_GREEN     "\e[32m"
#define F_YELLOW    "\e[33m"
#define F_BLUE      "\e[34m"
#define F_MAGENTA   "\e[35m"
#define F_CYAN      "\e[36m"
#define F_WHITE     "\e[37m"
#define F_BLACK     "\e[90m"
#define F_HRED      "\e[91m"
#define F_HGREEN    "\e[92m"
#define F_HYELLOW   "\e[93m"
#define F_HBLUE     "\e[94m"
#define F_HMAGENTA  "\e[95m" 
#define F_HCYAN     "\e[96m"
#define F_HWHITE    "\e[97m"

  // backgrounds
#define B_BLACK     "\e[40m"
#define B_RED       "\e[41m"
#define B_GREEN     "\e[42m"
#define B_YELLOW    "\e[43m"
#define B_BLUE      "\e[44m"
#define B_MAGENTA   "\e[45m"
#define B_CYAN      "\e[46m"
#define B_WHITE     "\e[47m"
#define B_HBLACK    "\e[100m"
#define B_HRED      "\e[101m"
#define B_HGREEN    "\e[102m"
#define B_HYELLOW   "\e[103m"
#define B_HBLUE     "\e[104m"
#define B_HMAGENTA  "\e[105m"
#define B_HCYAN     "\e[106m"



#define Home      "\e[;H"  //Cursor Home
#define Cls       "\e[2J"  //Bildschirm löschen
#define Normal    "\e[#5"  //Normalschrift
#define Weit      "\e[#6"  //Schrift doppelte Breite
#define DBoben    "\e[#3"  //Doppelte Schriftgröße obere Hälfte
#define DBunten   "\e[#4"  //Doppelte Schriftgröße untere Hälfte
#define CLleft    "\e[1K"  //Zeile ab Cursor links löschen
#define CLright   "\e[K"   //Zeile ab Cursor rechts löschen
#define Curleft   "\e[D"    //Cursor 1 Zeichen nach links
#define Curright  "\e[C"    //Cursor 1 Zeichen nach rehts
#define Backspace "\b\e[K" //Backspace
#define INS       "\e[4h"  //Einfügemodus
#define OVERWR    "\e[41"  //Überschreibmodus
#define NEXTLINE  "\e[20h" //Neue Zeile
#define DEL       "\e[P"  //1 Zeichen vonrecht nachrücken

fabgl::VGA16Controller DisplayController;
fabgl::PS2Controller     PS2Controller;
fabgl::Terminal          Terminal;




void print_Basic()
{
  Terminal.setBackgroundColor(Color::BrightRed);
  Terminal.write("             ");
  Terminal.setBackgroundColor(Color::Black);
  Terminal.write("        * Propeller-Basic Version 1.2 by Zille9 * \r\n");
  Terminal.setBackgroundColor(Color::BrightYellow);
  Terminal.write("           ");
  Terminal.setBackgroundColor(Color::Black);
  Terminal.write("              * 131069 Basic-Bytes free *\r\n");
  Terminal.setBackgroundColor(Color::Green);
  Terminal.write("         \r\n");
  Terminal.setBackgroundColor(Color::Cyan);
  Terminal.write("       \r\n");
  Terminal.setBackgroundColor(Color::Magenta);
  Terminal.write("     \r\n");
  Terminal.setBackgroundColor(Color::Black);
}



void setup()
{
  //Serial1.begin(57600);
  Serial2.begin(57600, SERIAL_8N1, 34, 12);
  
  PS2Controller.begin(PS2Preset::KeyboardPort0);
  PS2Controller.keyboard()->setLayout(&fabgl::GermanLayout);  //Keyboardlayout Deutsch
  DisplayController.begin();
  DisplayController.setResolution(VGA_640x480_60Hz);//VGA_512x384_60Hz);//VGA_640x480_60HzD);//VGA_640x480_60Hz);
  //DisplayController.setResolution(VGA_640x480_60Hz);

  Terminal.begin(&DisplayController);
  Terminal.connectLocally();      // to use Terminal.read(), available(), etc..
  Terminal.loadFont(&fabgl::FONT_8x14);//(siehe Ordner Fonts)
  Terminal.setBackgroundColor(Color::Black);
  Terminal.setForegroundColor(Color::BrightWhite);
  Terminal.clear();

  print_Basic();

  Terminal.enableCursor(true);
  Terminal.print(INS);
 
 Terminal.onVirtualKey = [&](VirtualKey * vk, bool keyDown){
      if (*vk == VirtualKey::VK_DELETE) {
        if (!keyDown) {
          Terminal.print(DEL);
          Serial2.write(186);                   //Taste Del rückt Zeile rechts vom Cursor um ein Zeichen nach links
         } 
         *vk = VirtualKey::VK_NONE;
      }
      if (*vk == VirtualKey::VK_LEFTBRACKET) {
        if (!keyDown) {
          Serial2.print("[");                   //Eckige Klammer für Esc-Sequenzen-Eingabe
        } 
        *vk = VirtualKey::VK_NONE;
      }
//++++++++++++++++++++ Funktionstasten ++++++++++++++++++++++++++++++++++++++++++++++++++      
      if (*vk == VirtualKey::VK_F1 ) {
        if (!keyDown) {
          Serial2.write(208);                   //F1 Help
        } 
        *vk = VirtualKey::VK_NONE;
      }
      if (*vk == VirtualKey::VK_F2 ) {
        if (!keyDown) {
          Serial2.write(209);                   //F2 Load
        } 
        *vk = VirtualKey::VK_NONE;
      }
      if (*vk == VirtualKey::VK_F3 ) {
        if (!keyDown) {
          Serial2.write(210);                   //F3 Save
        } 
        *vk = VirtualKey::VK_NONE;
      }
      if (*vk == VirtualKey::VK_F4 ) {
        if (!keyDown) {
          Serial2.write(211);                   //F4 Dir
        } 
        *vk = VirtualKey::VK_NONE;
      }
      if (*vk == VirtualKey::VK_F5 ) {
        if (!keyDown) {
          Serial2.write(212);                   //F5 Run
        } 
        *vk = VirtualKey::VK_NONE;
      }
      if (*vk == VirtualKey::VK_F6 ) {
        if (!keyDown) {
          Serial2.write(213);                   //F6 List
        } 
        *vk = VirtualKey::VK_NONE;
      }
      if (*vk == VirtualKey::VK_F7 ) {
        if (!keyDown) {
          Serial2.write(214);                   //F7
        } 
        *vk = VirtualKey::VK_NONE;
      }
      if (*vk == VirtualKey::VK_F8 ) {
        if (!keyDown) {
          Serial2.write(215);                   //F8
        } 
        *vk = VirtualKey::VK_NONE;
      }
      if (*vk == VirtualKey::VK_F9 ) {
        if (!keyDown) {
          Serial2.write(216);                   //F9
        } 
        *vk = VirtualKey::VK_NONE;
      }
      if (*vk == VirtualKey::VK_F10 ) {
        if (!keyDown) {
          Serial2.write(217);                   //F0
        } 
        *vk = VirtualKey::VK_NONE;
      }
      if (*vk == VirtualKey::VK_F11 ) {
        if (!keyDown) {
          Serial2.write(218);                   //F11
        } 
        *vk = VirtualKey::VK_NONE;
      }
      if (*vk == VirtualKey::VK_F12 ) {
        if (!keyDown) {
          Serial2.write(219);                   //F2
        } 
        *vk = VirtualKey::VK_NONE;
      }

 };


}



void loop()
{
int pr,pr2;
 //##################### Bildschirmausgabe vom Keyboard ################

  if (Serial2.available()) {
    char c = Serial2.read();
    pr=0;
    switch (c) {

     case 0x7F:                                   // backspace
          Terminal.write(Backspace);
          break;
     case 0x0D:                                   // CR  -> CR + LF
          Terminal.write("\r\n");
          break;
     case 0x8F:
          Terminal.loadFont(&fabgl::FONT_8x14); //(siehe Ordner Fonts)
          break;
     case 0x90:
          Terminal.loadFont(&fabgl::FONT_8x19);//(siehe Ordner Fonts)
          break;
     case 0x91:
          Terminal.loadFont(&fabgl::FONT_COMPUTER_8x14);//(siehe Ordner Fonts)
          break;
     case 0x92:
          Terminal.loadFont(&fabgl::FONT_LCD_8x14);//(siehe Ordner Fonts)
          break;
     case 0x93:
          Terminal.loadFont(&fabgl::FONT_10x20); //(siehe Ordner Fonts)
          break;
     case 0x94:
          Terminal.loadFont(&fabgl::FONT_BLOCK_8x14);//(siehe Ordner Fonts)
          break;
     case 0x95:
          Terminal.loadFont(&fabgl::FONT_BROADWAY_8x14);//(siehe Ordner Fonts)
          break;
     case 0x96:
          Terminal.loadFont(&fabgl::FONT_OLDENGL_8x16);//(siehe Ordner Fonts)
          break;
     case 0x97:
          Terminal.loadFont(&fabgl::FONT_BIGSERIF_8x16);//(siehe Ordner Fonts)
          break;
     case 0x98:
          Terminal.loadFont(&fabgl::FONT_SANSERIF_8x14);//(siehe Ordner Fonts)
          break;
     case 0x99:
          Terminal.loadFont(&fabgl::FONT_SANSERIF_8x16);//(siehe Ordner Fonts)
          break;
     case 0x9A:
          Terminal.loadFont(&fabgl::FONT_SLANT_8x14);//(siehe Ordner Fonts)
          break;
     case 0x9B:
          Terminal.loadFont(&fabgl::FONT_WIGGLY_8x16);//(siehe Ordner Fonts)
          break;
     case 0x9C:
          Terminal.loadFont(&fabgl::FONT_COURIER_8x14);//(siehe Ordner Fonts)
          break;
     case 0x9D:
          Terminal.loadFont(&fabgl::FONT_BIGSERIF_8x14);//(siehe Ordner Fonts)
          break;
     case 0x9E:
          Terminal.loadFont(&fabgl::FONT_8x9);//(siehe Ordner Fonts)
          break;

     default:
          Terminal.write(c);    //Zeichen ohne ESC
          break;
        
    }

  }
  
//#################### Seriell-Ausgabe zum Propeller #################
  if (Terminal.available()){
    char cc=Terminal.read();
    pr2=0;
    switch (cc) {
     case '[':
          ESCCH2=27;
          pr2=1;
          break;
     case 0x43:
          if(ESCCH2==27){Terminal.write(Curright);Serial2.write(3);ESCCH2=0;}
          else {pr2=1;Serial2.write(cc);}
          break;
     case 0x44:
          if(ESCCH2==27){Terminal.write(Curleft);Serial2.write(4);ESCCH2=0;}  //Cursortaste
          else {pr2=1;Serial2.write(cc);}  
          break;

     case 0x7F:       // DEL -> backspace + ESC[K
       Serial2.write(8);
       break;
     case 0x0D:       // CR  -> CR + LF
       Serial2.write(13);
       break;
     default:
       if(pr2==0)Serial2.write(cc);
       break;
       }
       
    
  }
  

  
} //Loop
