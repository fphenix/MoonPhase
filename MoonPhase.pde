// Fred Limouzin - First version : 02/03/2017
// Updated with Calendar options : 12/03/2017
//
// Please read the README.txt first!

import java.util.Calendar;
import java.util.Date;

LPC lpc;
PImage moonImg;
float offset;

void setup () {
  offset = 20;
  lpc = new LPC();
  moonImg = loadImage("moon.gif"); // must be in subdir "data/"
  size(300, 500);
  background(0, 0, 0);
  lpc.starsInit();
}

void draw () {
  lpc.stars();
  lpc.moonIt(moonImg);
  lpc.shadeIt();
  lpc.display();
}