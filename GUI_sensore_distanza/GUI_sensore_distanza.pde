import processing.video.*;
import processing.serial.*;

Capture cam;
Serial myPort;

final int ROWS = 8;
final int COLS = 8;

int[][] M = new int[ROWS][COLS];

void setup() {
  size(480, 480);
  colorMode(HSB);
  
  String[] serialInterfaces = Serial.list();
  printArray(serialInterfaces);

  myPort = new Serial(this, serialInterfaces[2], 115200);
  myPort.bufferUntil('T');
  // myPort.buffer(4096);

  String[] cameras = Capture.list();
  cam = new Capture(this, 640, 480, cameras[0]);
  cam.start();
}

void serialEvent(Serial myPort) {
  try {
    while (myPort.readChar() != 'S');
    
    String res = myPort.readStringUntil('T');
    res = res.substring(0, res.length() - 1);
    
    // println(res);
    
    String[] splittedRes = res.trim().split(" ");
    
    int i = 0;
    for (String s : splittedRes) {
      M[i / ROWS][i % COLS] = Integer.valueOf(s);
      i++;      
    }
  } catch(RuntimeException e) {
    e.printStackTrace();
  }
}

void draw() {
  if (cam.available()) {
    cam.read();
  }

  int w = width / ROWS;
  int h = height / COLS;

  image(cam, -(cam.width - cam.height) / 2, 0);

  /*
  for (int x = 0; x < ROWS; x++) {
    for (int y = 0; y < COLS; y++) {
      int col = M[x][y];
      print(col + " ");

      float c = map(col, 0, 3000, 0, 100);
      fill(c, 255, 255, 80);

      int x0 = ((x + (ROWS - 1)) % ROWS) * w;
      int y0 = ((y + (COLS - 1)) % COLS) * h;
      rect(x0, y0, w, h);
    }
    println("");
  }*/

 
  strokeWeight(0.2);
  for (int y = 0; y < COLS; y++) {
    for (int x = 0; x < ROWS; x++) {
      int col = M[y][x];
      print(col + " ");

      float c = map(col, 0, 2500, 0, 100);
      fill(c, 255, 255, 80);

      int x0 = x * w;
      int y0 = y * w;
      rect(x0, y0, w, h);
    }
    println("");
  }
  
  println();
 
}

void swapMatrixHorizontallyAndVertically() {
  // Vertical swap
  /*
  for (int i = 0; i < COLS; i++) {
      for (int j = 0; j < ROWS/2; j++) {
          // swap(a[j][i], a[(ROWS-1) - j][i])
          int temp = M[j][i];
          M[j][i] = M[(ROWS-1) - j][i];
          M[(ROWS-1) - j][i] = temp;
      }
  }*/
  
  // Horizontal swap
  for (int i = 0; i < ROWS; i++) {
      for (int j = 0; j < COLS/2; j++) {
          // swap(a[i][j], a[i][(COLS-1) - j])
          int temp = M[i][j];
          M[i][j] = M[i][(COLS-1) - j];
          M[i][(COLS-1) - j] = temp;
      }
  }
}
