// scrolling text data type

class ScrollingText {
  int x; 
  int x2; 
  int textSize;
  String text;
  float speed;
  int startPointX;
  int startPointY;
  PGraphics pg;
  String[] lines;
  ArrayList<boolean[]> visible;
  int currWidth = 0;
  int posx = 0;
  int start;
  int end;
  int offset = 0;

  // constructor 
  ScrollingText(String[] lines, int textSize, float speed, int startPointX, int startPointY, int z) {
    this.textSize = textSize;
    this.lines = lines;
    this.speed = speed;
    this.startPointX = startPointX;
    this.startPointY = startPointY;
    textSize(textSize);

    start = 0;
    end = 0;
    PFont font;
    font = loadFont("CodeNewRoman-Bold-40.vlw");
    textFont(font, textSize);

    // keep track of visibility
    visible = new ArrayList<boolean[]>();
    
    // automatically resize font to screen height 
    int currentHeight = int(startPointY + (((textAscent() + textDescent())) * lines.length) + 50);
    println(currentHeight);
    while ( (currentHeight < height  && (height - currentHeight) > 30) || currentHeight > height) {
      if (currentHeight > height) {
        textSize--;
        textFont(font, textSize);
        currentHeight = int(startPointY + (((textAscent() + textDescent())) * lines.length) + 50);
      } else if (currentHeight < height) {
        textSize++;
        textFont(font, textSize);
        currentHeight = int(startPointY + (((textAscent() + textDescent())) * lines.length) + 50);
      }
    }    

    // initialize x
    x = startPointX;

    // initialize font 
    textFont(font, textSize);
    fill(255, 0, 0);

    // initialize visible array list
    for (int i = 0; i < lines.length; i++) {
      visible.add(new boolean[lines[i].split("\\s+").length]);
    }
  }

  // scrolling animation
  void startScrolling() {    
    
    // traverse through lines like conveyer belt 
    for (int i = 0; i < lines.length; i++) {
      String[] words = lines[i].split("\\s+");
      offset = 0;
      currWidth = 0;
      for (int j = 0; j < words.length; j++) {
        if (visible.get(i)[visible.get(i).length - 1] && !visible.get(i)[0] && j == 0) {
          println("HEY   " + words[j]);
          x = currWidth;
          posx = x;
          visible.get(i)[j] = true;
        } 
        if (x + offset < start || x + offset > end || end - currWidth < int(textWidth(words[j]))) {
          posx = -10000;
          visible.get(i)[j] = false;
          if (x + offset < start) {
            currWidth -= int(textWidth(words[j]) + 15);
          }
        } else if (x + offset > start || end - currWidth > int(textWidth(words[j]))) {
          posx = x + offset;
          visible.get(i)[j] = true;
        }
        text(words[j], posx, startPointY + ((textAscent() + textDescent()) * i) + 50);
        offset += int(textWidth(words[j]) + 15);
        if (currWidth < end - start) {
          currWidth += int(textWidth(words[j]) + 15);
        }
      }
    }
    x-=speed;
  }
  
  // set start and end points
  void setStartPoint(int start, int end) {
    this.start = start;
    this.end = end;
  }

  // erase text if user leaves
  void clear() {
    for (int i = 0; i < lines.length; i++) {
      String[] words = lines[i].split("\\s+");
      for (int j = 0; j < words.length; j++) {
        text(words[j], -10000, 0);
      }
    }
  }
}

