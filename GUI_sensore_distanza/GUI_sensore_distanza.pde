import processing.video.*;
Capture cam;

final int ROWS = 4;
final int COLS = 4;

/*
float[][] M = {{0, 0, 0, 0, 0, 0, 0, 0},
               {0, 0, 0, 0, 0, 0, 0, 0},
               {0, 0, 0, 0, 0, 0, 0, 0},
               {0, 0, 0, 0, 0, 0, 0, 0},
               {0, 0, 0, 0, 0, 0, 0, 0},
               {0, 0, 0, 0, 0, 0, 0, 0},
               {0, 0, 0, 0, 0, 0, 0, 0},
               {0, 0, 0, 0, 0, 0, 0, 0}};
*/

float[][] M = {{0, 0, 0, 0},
               {0, 0, 0, 0},
               {0, 0, 0, 0},
               {0, 0, 0, 0}};

void setup() {
  size(480, 480);
  colorMode(HSB);
  
  String[] cameras = Capture.list();
  cam = new Capture(this, 640, 480, cameras[0]);
  cam.start();   
  
  for (int i = 0; i < ROWS; i++) {
    for (int j = 0; j < COLS; j++) {
      M[i][j] = 255;
    }
  }
  
  M[0][0] = 30;
  M[2][3] = 120;
  M[1][2] = 220;
  M[3][2] = 170;
}

void draw() {
  if (cam.available()) {
    cam.read();
  }
  
  int w = width / ROWS;
  int h = height / COLS;
  
  image(cam, -(cam.width - cam.height) / 2, 0);
  
  for (int y = 0; y < COLS; y++) {
    for (int x = 0; x < ROWS; x++) {
      float col = M[y][x];
      
      float c = map(col, 0, 255, 0, 100);
      fill(c, 255, 255, 100);
      
      int x0 = x * w;
      int y0= y * w;
      rect(x0, y0, w, h);
    }
  }
  
}
