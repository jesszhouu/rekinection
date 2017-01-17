import SimpleOpenNI.*;

SimpleOpenNI kinect;

ArrayList<Integer> users = new ArrayList<Integer>();
ArrayList<Integer> colors = new ArrayList<Integer>();
ArrayList<Rectangle> boundingBoxes = new ArrayList<Rectangle>();
ArrayList<ScrollingText> texts = new ArrayList<ScrollingText>();

// turn on camera and set window size
void setup() {
  size(1280, 960);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();

// read in all quotation files
  for (int i = 1; i < 15; i++) {
    texts.add(new ScrollingText(loadStrings("quotes" + i +".txt"), 30, 1, 0, 0, 0));
  }
}

// draw text bodies
void draw() {

  // asks kinect to send new data
  kinect.update();

  // set background 
  background(255);

  // retrieves depth image
  // get user pixels - array of the same size as depthImage.pixels, that gives information about the users in the depth image:
  // if upix[i]=0, there is no user at that pixel position
  // if upix[i]>0, upix[i] indicates which userid is at that position
  int[] upix = kinect.userMap();
  
  // enable pixel color editing
  loadPixels();
  
  // set users' body background to black
  for (int i = 0; i < upix.length; i++) {
    int x = i % 640;
    int y = (i - x) / 640;
    if (upix[i] > 0) {
      pixels[(x*2) + ((y*2) * width)] = color(0, 0, 0);
      pixels[(x*2) + 1 + ((y*2) * width)] = color(0, 0, 0);
      pixels[(x*2) + ((((y*2) + 1) * width))] = color(0, 0, 0);
      pixels[(x*2) + 1 + ((((y*2) + 1) * width))] = color(0, 0, 0);
    }
  }

  // update pixels on screen
  updatePixels();
  
  // make sure there are users
  if (users.size() > 0) { 

    // look through every user
    for (int j = 0; j < users.size (); j++) {
      
      // define user's bounding box
      PVector c1 = new PVector();
      PVector c2 = new PVector();
      kinect.getBoundingBox(users.get(j), c1, c2);
      boundingBoxes.set(j, new Rectangle(int(c1.x), int(c1.y), int(c2.x), int(c2.y)));
       
      // compare bounding boxes of users  
      for (int k = 0; k < boundingBoxes.size () && boundingBoxes.get(j).hasBeenAdjusted(); k++) {
        
        // if not same bounding box, look at overlap of two users
        if (k != j) {
          if (boundingBoxes.get(j).overlaps(boundingBoxes.get(k))) {
            
            // adjust width of left/right bounding box to eliminate overlap
            if (boundingBoxes.get(j).x + boundingBoxes.get(j).rWidth > boundingBoxes.get(k).x) {
              boundingBoxes.get(j).adjustX2(boundingBoxes.get(j).x + boundingBoxes.get(j).rWidth - boundingBoxes.get(k).x - 50);
            } else {
              boundingBoxes.get(j).adjustX2(boundingBoxes.get(k).x + boundingBoxes.get(k).rWidth + boundingBoxes.get(j).x + 50);
            }
          }
        }
      }
      // set start and end points of text to bounding box's x-coordinates
      texts.get(j).setStartPoint(int(boundingBoxes.get(j).x*2), int(boundingBoxes.get(j).x2*2));
      // get scroll text
      texts.get(j).startScrolling();
    }
  }



  loadPixels();
  
  // hide the scrolling text if it is not on the body outlines
  for (int i = 0; i < upix.length; i++) {
    int x = i % 640;
    int y = (i - x) / 640;
    
    // set text to user's text color               
    if (upix[i] > 0) {
      color c;
      if (users.indexOf(upix[i]) == -1) {
        c = color(int(random(255)), int(random(255)), int(random(255)));
      } else {
        c = colors.get(users.indexOf(upix[i]));
      }
      if (pixels[(x*2)+((y*2) * width)] != color(0, 0, 0)) {
        changeTextColor(x*2, y*2, c);
      } else if (pixels[(x*2) + 1 + ((y*2) * width)] != color(0, 0, 0)) {
        changeTextColor((x*2) + 1, y*2, c);
      } else if (pixels[(x*2) + ((((y*2) + 1) * width))] != color(0, 0, 0)) {
        changeTextColor(x*2, (y*2) + 1, c);
      } else if (pixels[(x*2) + 1 + ((((y*2) + 1) * width))] != color(0, 0, 0)) {
        changeTextColor((x*2) + 1, (y*2) + 1, c);
      }
    } else {
      // if it is part of the background, cover up the text
      pixels[(x*2) + ((y*2) * width)] = color(0, 0, 0);
      pixels[(x*2) + 1 + ((y*2) * width)] = color(0, 0, 0);
      pixels[(x*2) + ((((y*2) + 1) * width))] = color(0, 0, 0); 
      pixels[(x*2) + 1 + ((((y*2) + 1) * width))] = color(0, 0, 0);
    }
  }
  updatePixels();
}

// change text color
void changeTextColor(int x, int y, color c) {
  if (pixels[x + (y * width)] != color(0, 0, 0))
    pixels[x + (y * width)] = c;

  if (x + 1 < width) {
    if (pixels[x + 1 + (y * width)] != color(0, 0, 0))
      pixels[x + 1 + (y * width)] = c;
  }

  if (y + 1 < height) {
    if (pixels[x + (((y + 1) * width))] != color(0, 0, 0))
      pixels[x + (((y + 1) * width))] = c;
  }

  if (x + 1 < width && y + 1 < height) {
    if (pixels[x + 1 + (((y + 1) * width))] != color(0, 0, 0))
      pixels[x + 1 + (((y + 1) * width))] = c;
  }
}

// when there is a new user, update user count, randomly assign text color, and initialize bounding box
void onNewUser(SimpleOpenNI curkinect, int userId)
{
  curkinect.startTrackingSkeleton(userId);
  users.add(userId);
  colors.add(color(int(random(255)), int(random(255)), int(random(255))));
  boundingBoxes.add(new Rectangle(0, 0, 0, 0));
}

// when a user leaves, get rid of text, color, bounding box, and user
void onLostUser(SimpleOpenNI curkinect, int userId)
{
  println("onLostUser - userId: " + userId);
  texts.get(users.indexOf(userId)).clear();
  colors.remove(users.indexOf(userId));
  boundingBoxes.remove(users.indexOf(userId));
  users.remove(userId);
}

