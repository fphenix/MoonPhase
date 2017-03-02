// Fred Limouzin 2/3/2017
//
// Please read the README.txt first!

LPC lpc;
PImage moonImg;
float offset;

void setup () {
  offset = 20;
  lpc = new LPC();
  moonImg = loadImage("moon.gif"); // must be in subdir "data/"
  size(300, 500);
  background(0);
  lpc.starsInit();
}

void draw () {
  background(0);
  lpc.stars();
  lpc.moonIt(moonImg);
  lpc.shadeIt();
  lpc.display();
}