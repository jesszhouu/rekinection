// rectangle bounding box data type

class Rectangle {
  int x;
  int y;
  int x2;
  int y2;
  int rWidth;
  int rHeight;
  boolean hasBeenAdjusted;

// constructor with dimensions
  Rectangle(int x, int y, int x2, int y2) {
    this.x = x;
    this.y = y;
    this.x2 = x2;
    this.y2 = y2;
    this.rWidth = x2 - x;
    this.rHeight = y2 - y;
  }
 
  // check if boxes overlap
  boolean overlaps(Rectangle r) {
    return x < r.x + r.rWidth && x + rWidth > r.x && y < r.y + r.rHeight && y + rHeight > r.y;
  }
  
  // adjust x1-coordinate 
  void adjustX(int newX) {
    this.x = newX;
    hasBeenAdjusted = true;
  }
  
  // adjust x2-coordinate
  void adjustX2(int newX2) {
    this.x2 = newX2;
    hasBeenAdjusted = true;
  }
  
  // check if size has been adjusted
  boolean hasBeenAdjusted() {
    return hasBeenAdjusted;
  }
}

