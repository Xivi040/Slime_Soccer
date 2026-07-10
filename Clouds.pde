// ════════════════════════════════════════════════════════
//  픽셀 구름 (낮) / 까마귀 (밤)
// ════════════════════════════════════════════════════════

Cloud[] clouds;

void initClouds() {
  clouds = new Cloud[6];
  clouds[0] = new Cloud( 180, 115,  1.45, 1);
  clouds[1] = new Cloud( 620, 210, -0.28, 3);
  clouds[2] = new Cloud( 830, 145,  0.35, 2);
  clouds[3] = new Cloud(1080, 240, -0.50, 1);
  clouds[4] = new Cloud(1310, 110,  1.22, 3);
  clouds[5] = new Cloud( 670,  90, -0.38, 2);
}

void updateAndDrawClouds() {
  for (Cloud c : clouds) {
    c.update();
    c.display();
  }
}

class Cloud {
  float x, y, speed;
  int   type;
  final int PS = 8;   // 픽셀 한 칸 크기

  Cloud(float sx, float sy, float spd, int t) {
    x = sx; y = sy; speed = spd; type = t;
  }

  void update() {
    x += speed;
    float w = PS * 12;
    if (speed > 0 && x >  width + w) { x = -w;        y = random(90, 260); }
    if (speed < 0 && x < -w)         { x = width + w;  y = random(90, 260); }
  }

  void display() {
    noStroke();
    fill(238, 242, 250, 205);

    switch (type) {
      case 1:   // 둥근 일반 구름
        rect(x + PS*2, y,       PS*5, PS*2);
        rect(x + PS,   y+PS*2,  PS*7, PS*2);
        rect(x,        y+PS*3,  PS*9, PS*2);
        rect(x + PS,   y+PS*5,  PS*7, PS*2);
        break;

      case 2:   // 넓고 납작한 구름
        rect(x + PS*3, y,        PS*4, PS*2);
        rect(x + PS,   y+PS*2,   PS*9, PS*2);
        rect(x,        y+PS*4,   PS*11, PS*2);
        rect(x + PS,   y+PS*6,   PS*9, PS*2);
        break;

      case 3:   // 작고 볼록한 구름
        rect(x + PS*1, y,       PS*4, PS*2);
        rect(x,        y+PS*2,  PS*6, PS*2);
        rect(x,        y+PS*4,  PS*6, PS*2);
        rect(x + PS,   y+PS*6,  PS*4, PS*2);
        break;
    }
  }
}

// ════════════════════════════════════════════════════════
//  까마귀 (야간 모드)
// ════════════════════════════════════════════════════════

Crow[] crows;

void initCrows() {
  crows = new Crow[6];
  crows[0] = new Crow( 200,  88,  0.50);
  crows[1] = new Crow( 650, 155, -0.38);
  crows[2] = new Crow(1000,  96,  0.32);
  crows[3] = new Crow( 420, 205, -0.58);
  crows[4] = new Crow(1220, 130,  0.42);
  crows[5] = new Crow( 820, 245, -0.28);
}

void updateAndDrawCrows() {
  for (Crow c : crows) {
    c.update();
    c.display();
  }
}

class Crow {
  float x, y, speed;
  int   frame      = 0;
  float frameAccum = 0;

  Crow(float sx, float sy, float spd) {
    x = sx; y = sy; speed = spd;
    frame      = (int)random(3);
    frameAccum = random(1);
  }

  void update() {
    x += speed;
    frameAccum += 0.07;
    if (frameAccum >= 1) {
      frame = (frame + 1) % 3;
      frameAccum -= 1;
    }
    if (speed > 0 && x >  width + 45) { x = -45;       y = random(82, 275); }
    if (speed < 0 && x < -45)          { x = width + 45; y = random(82, 275); }
  }

  void display() {
    int ps = 3;
    noStroke();
    fill(22, 18, 26); // 어두운 보라빛 검정

    // 몸통
    rect(x - ps,       y - ps/2,  ps*2, ps*2);
    // 머리
    rect(x - ps/2,     y - ps*2,  ps,   ps);
    // 부리
    rect(x + ps/2,     y - ps*2 + 1, ps, 2);

    // 날개 (프레임별)
    if (frame == 0) {          // 날개 위
      rect(x - ps*5, y - ps*2,  ps*4, ps);
      rect(x + ps,   y - ps*2,  ps*4, ps);
    } else if (frame == 1) {   // 날개 수평
      rect(x - ps*5, y - ps,    ps*4, ps);
      rect(x + ps,   y - ps,    ps*4, ps);
    } else {                   // 날개 아래
      rect(x - ps*4, y + ps/2,  ps*3, ps);
      rect(x + ps,   y + ps/2,  ps*3, ps);
    }
  }
}
