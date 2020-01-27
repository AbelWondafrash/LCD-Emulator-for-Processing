class LCD {
  Serial device;
  color blue = #0041FF;

  PFont consola;

  private int nX = 16, nY = 4;

  private String CLEAR_SCREEN = "/CLS/";
  private String contents [];
  private String lastPortContentString;
  private String lastNonNullPortContentString;

  private float pixelDimension;
  private float pixelGap;
  private float nPixelX = 5, nPixelY = 8;

  private float boxW, boxH;
  private float gap;
  private float startX, startY;

  private char bufferUntilChar = '\n';

  private void init (int nX, int nY, Serial serial) {
    device = serial;
    device.bufferUntil(bufferUntilChar);
    consola = createFont("data/fonts/consola.ttf", 10);

    this.nX = nX;
    this.nY = nY;

    clear ();

    pixelDimension = 3.2;
    pixelGap = 1;
    gap = pixelDimension;

    boxW = pixelGap*(nPixelX - 1) + pixelDimension*nPixelX;
    boxH = pixelGap*(nPixelY - 1) + pixelDimension*nPixelY;

    startX = (width - boxW*nX - gap*(nX - 1))/2;
    startY = (height - boxH*nY - gap*(nY - 1))/2;
  }

  private LCD (int nX, int nY, Serial serial) {
    init (nX, nY, serial);
  }

  LCD (int nX, int nY, Serial serial, char bufferUntilChar) {
    this.bufferUntilChar = bufferUntilChar;
    init (nX, nY, serial);
  }

  void clear () {
    contents = new String [nY];

    String content = "";
    for (int a = 0; a < nY; a ++) {
      for (int b = 0; b < nX; b ++)
        content += " ";
      contents [a] = content;
    }
  }

  void draw () {
    background(blue);

    strokeWeight(1);
    stroke(255, 40);
    noFill ();

    textFont(consola);
    textAlign(CENTER, CENTER);
    textSize(boxH*0.8);

    for (int b = 0; b < nY; b ++) {
      for (int a = 0; a < nX; a ++) {
        float x = startX + boxW*a + gap*a, y = startY + boxH*b + gap*b;

        rect(x, y, boxW, boxH);
        try {
          char charToDisplay = contents [b].charAt(a);
          if (str(charToDisplay).length() > 0) {
            text(charToDisplay, x + boxW/2, y + boxH/2 - textDescent ()/2);
          }
        } 
        catch (Exception e) {
        }
      }
    }

    overlay();
  }

  void overlay () {
    strokeWeight(pixelGap);
    stroke(blue, 40);
    for (int b = 0; b < nY; b ++) {
      for (int a = 0; a < nX; a ++) {
        float x = startX + boxW*a + gap*a, y = startY + boxH*b + gap*b;

        for (int c = 1; c < nPixelY; c ++) {
          line(x, y + c*pixelGap + c*pixelDimension, x + boxW, y + c*pixelGap + c*pixelDimension);
        }
        for (int c = 1; c < nPixelX; c ++) {
          line(x + c*pixelGap + c*pixelDimension, y, x + c*pixelGap + c*pixelDimension, y + boxH);
        }
      }
    }
  }

  void print (String text, int x, int y) {
    String content = "";
    if (x >= nX ||y >= nY)
      return;
    for (int a = 0; a < nX; a ++) {
      if (a < x)
        content += contents [y].charAt(a);
      else {
        int counter = 0;
        for (int b = a; b < nX; b ++) {
          if (counter < text.length ()) {
            content += text.charAt(counter ++);
          } else
            content += contents [y].charAt (b);
        }
        break;
      }
    }

    contents [y] = content;
  }

  void serialEvent () throws Exception {
    String content = device.readString ();
    lastPortContentString = content;

    if (content != null) {
      lastNonNullPortContentString = content;
      content = content.replace(str(bufferUntilChar), "").replace("\r", "");

      if (content.equals(lcd.CLEAR_SCREEN)) { 
        lcd.clear ();
      } else if (content.contains("~")) {
        String splitted [] = split(content, "~");
        if (splitted.length < 3 || !content.contains(","))
          return;
        String text = splitted [1];
        String location = splitted [2];

        splitted = split(location, ",");
        if (splitted.length > 2) {
          int x, y;

          x = Integer.parseInt(splitted [0]);
          y = Integer.parseInt(splitted [1]);
          lcd.print(text, x, y);
        }
      }
    }
  }

  String lastPortContent () {
    return lastPortContentString;
  }
  
  String lastNonNullPortContent () {
    return lastNonNullPortContentString;
  }
}
