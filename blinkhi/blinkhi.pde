import ddf.minim.*;
import ddf.minim.analysis.*;
 
Minim minim;
AudioPlayer song;
FFT fft;

import blinkstick.*;
BlinkStick device;

int leds = 8;

void setup() {
  size(512, 200);
 
  // always start Minim first!
  minim = new Minim(this);
  device = BlinkStick.findFirst();
  
  if (device == null) {
    println("Not found...");  
  } else {
    device.setMode(2);
  }
  

  // specify 512 for the length of the sample buffers
  // the default buffer size is 1024
  song = minim.loadFile("song.mp3", 512);
  song.play();
 
  // an FFT needs to know how 
  // long the audio buffers it will be analyzing are
  // and also needs to know 
  // the sample rate of the audio it is analyzing
  fft = new FFT(song.bufferSize(), song.sampleRate());
}

void draw() {

  background(0);
  // first perform a forward fft on one of song's buffers
  // I'm using the mix buffer
  //  but you can use any one you like
  fft.forward(song.mix);
 
  stroke(255, 0, 0, 128);
  // draw the spectrum as a series of vertical lines
  // I multiple the value of getBand by 4 
  // so that we can see the lines better
  for(int i = 0; i < fft.specSize(); i++) {
    line(i, height, i, height - fft.getBand(i)*i);
  }
  int[] ds = new int[leds];

  for(int i = 0; i < fft.specSize(); i++) {
    ds[leds * i / fft.specSize()] += fft.getBand(i)*i;
  }
  int maxVal = 0;
  for( int i = 0; i < leds; i++) 
    maxVal = max(maxVal, ds[i]);

  color a = color(0, 0, 255);
  color b = color(255, 0,0);
    
  byte[] data = new byte[leds * 3];
  int idx = 0;
  int w = width/8;
  noStroke();
  for (int i = 0; i < 8; i++) {
    color c = lerpColor(a, b, float(ds[i])/maxVal);
    // colors in g r b  because ?
    c = color(#FFFFFF);
    data[idx++] = (byte) ((c>>8)  & 0xFF);
    data[idx++] = (byte) ((c>>16) & 0xFF);
    data[idx++] = (byte) ( c      & 0xFF);
    fill(c);
    rect(w*i, 0, w*(i+1), w);
  }
  delay(100);                    // the correct magic amount?
  device.setColors(data);
  stroke(255);
}

void keyPressed() {
  if ('q' == key) {
    delay(100);
    device.turnOff();
    exit();
  }
    
}
