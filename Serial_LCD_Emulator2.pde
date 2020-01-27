import processing.serial.*;
Serial uno;

LCD lcd;

void setup () {
  size(435, 180);

  uno = new Serial (this, "COM13", 9600);

  lcd = new LCD (16, 4, uno);
}

void draw () {
  lcd.draw ();
}

void serialEvent (Serial p) {
  try {
    lcd.serialEvent();
  } 
  catch (Exception e) {
  }
}
