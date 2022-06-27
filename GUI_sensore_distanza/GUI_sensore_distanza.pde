import processing.video.*;
import processing.serial.*;

Capture cam;
Serial myPort;

final int ROWS = 8;
final int COLS = 8;
int w, h;

boolean isReceivingData = false;
int loopCount = 0;

int minDistance = 0;
int maxDistance = 4000;

int[][] M = new int[ROWS][COLS];

void setup() {
  size(480, 480);
  colorMode(HSB);
  
  w = width / ROWS;
  h = height / COLS;
  
  String[] serialInterfaces = Serial.list();
  printArray(serialInterfaces);

  myPort = new Serial(this, serialInterfaces[2], 115200);
  myPort.buffer(700);

  String[] cameras = Capture.list();
  cam = new Capture(this, 640, 480, cameras[0]);
  cam.start();
}

void serialEvent(Serial myPort) {
  isReceivingData = true;
  
  try {
    while (myPort.readChar() != 'S');
    
    String res = myPort.readStringUntil('T');
    res = res.substring(0, res.length() - 1);
        
    String[] splittedRes = res.trim().split(" ");
    
    int i = 0;
    for (String s : splittedRes) {
      M[i / ROWS][i % COLS] = Integer.valueOf(s);
      // print(M[i / ROWS][i % COLS] + " ");
      
      // if ((i+1) % 8 == 0) println();
      i++;
    }
    
    // println();
    
    // swapMatrixHorizontally();
  } catch(RuntimeException e) {
    e.printStackTrace();
  }
}


void draw() {
  if (cam.available())
    cam.read();
  
  image(cam, -(cam.width - cam.height) / 2, 0);  

  textSize(12);
  loopCount++;
  
  strokeWeight(0.2);
  for (int y = 0; y < COLS; y++) {
    for (int x = 0; x < ROWS; x++) {
      int col = M[y][x];

      // Maps from minDistance to maxDistance to draw colors from red to green
      float c = map(col, minDistance, maxDistance, 0, 100); 
      
      final int ALPHA = 100;
      fill(c, 255, 255, ALPHA);

      int x0 = x * w;
      int y0 = y * w;
      rect(x0, y0, w, h);
      
      fill(255);
      text(col, x0 + w/2 - 6, y0+h - h/2 + 6);
    }
  }
    
  if (loopCount % 120 == 0 && isReceivingData) {    
    updateMaxMinDistances();
    // println(minDistance, maxDistance);
  }
}

void updateMaxMinDistances() {
  int min = Integer.MAX_VALUE, max = 0;
  
  for (int i = 0; i < ROWS; i++) {
    for (int j = 0; j < COLS; j++) {
      int v = M[i][j];
      
      if (v < min) min = v;
      else if (v > max) max = v;
    }
  }
  
  minDistance = min;
  maxDistance = max;
}

void swapMatrixHorizontally() {
  for (int i = 0; i < ROWS; i++) {
    for (int j = 0; j < COLS/2; j++) {
      // swap(a[i][j], a[i][(COLS-1) - j])
      int temp = M[i][j];
      M[i][j] = M[i][(COLS-1) - j];
      M[i][(COLS-1) - j] = temp;
    }
  }
}
