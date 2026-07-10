// ════════════════════════════════════════════════════════
//  공 타입
//  0 = 일반  1 = 무거운(검정)  2 = 가벼운(파랑)  3 = 탄성(노랑)
// ════════════════════════════════════════════════════════
class Ball {
  float x, y, vx, vy;
  float radius = 22;

  int   type;
  float gravMult;
  float floorBounce;
  float wallBounce;
  float kickMult;
  color ballColor;

  int   frame      = 0;
  float frameAccum = 0;

  Ball(float sx, float sy, int t) {
    x = sx; y = sy;
    type = t;
    switch (t) {
      case 1:  // 무거운 공
        gravMult    = 3.0;
        floorBounce = 0.22;
        wallBounce  = 0.45;
        kickMult    = 0.7;
        ballColor   = color(115, 115, 115);
        vx = random(-1.5, 1.5);
        vy = -2;
        break;
      case 2:  // 가벼운 공 (달 중력)
        gravMult    = 0.22;
        floorBounce = 0.72;
        wallBounce  = 0.85;
        kickMult    = 1.1;
        ballColor   = color(75, 145, 255);
        vx = random(-3, 3);
        vy = -5;
        break;
      case 3:  // 탄성 공 (강화)
        gravMult    = 1.0;
        floorBounce = 0.97;
        wallBounce  = 0.94;
        kickMult    = 1.6;
        ballColor   = color(255, 215, 25);
        vx = random(-3, 3);
        vy = -5;
        break;
      default: // 일반 공
        gravMult    = 1.0;
        floorBounce = 0.55;
        wallBounce  = 0.80;
        kickMult    = 1.0;
        ballColor   = color(240);
        vx = random(-3, 3);
        vy = -5;
    }
  }

  void update() {
    frameAccum += abs(vx) * 0.04;
    if (frameAccum >= 1) {
      frame = (frame + (int)frameAccum) % 4;
      frameAccum -= (int)frameAccum;
    }

    vy += gravity * gravMult;
    x  += vx;
    y  += vy;

    // ── 벽 / 천장 / 바닥 ──────────────────────
    if (x - radius < 0) {
      if (y < groundY - GH) { x = radius; vx *= -wallBounce; sndBallBound.play(); }
    }
    if (x + radius > width) {
      if (y < groundY - GH) { x = width - radius; vx *= -wallBounce; sndBallBound.play(); }
    }
    if (y - radius < 0) { y = radius; vy *= -wallBounce; sndBallBound.play(); }
    if (y + radius > groundY) {
      y = groundY - radius;
      if (abs(vy) > 1.5) sndBallBound.play();
      vy *= -floorBounce;
      vx *= 0.96;
    }

    // ── HUD 충돌 ──────────────────────────────
    // 점수판 아랫면 (전체 너비, y=52)
    if (y - radius < 52 && vy < 0) {
      y = 52 + radius;
      vy *= -floorBounce;
      sndBallBound.play();
    }
    // P1 쿨타임 바 (x=0~220, y=56~112)
    float hTop = 56, hBot = 112, hRightL = 220;
    if (x - radius < hRightL && y + radius > hTop && y - radius < hBot) {
      if (x + radius > hRightL && vx < 0) {
        x = hRightL + radius; vx *= -wallBounce; sndBallBound.play();
      } else if (y - radius < hBot && vy < 0 && y > hTop) {
        y = hBot + radius; vy *= -floorBounce; sndBallBound.play();
      }
    }
    // P2 쿨타임 바 (x=width-220~width, y=56~112)
    float hLeftR = width - 220;
    if (x + radius > hLeftR && y + radius > hTop && y - radius < hBot) {
      if (x - radius < hLeftR && vx > 0) {
        x = hLeftR - radius; vx *= -wallBounce; sndBallBound.play();
      } else if (y - radius < hBot && vy < 0 && y > hTop) {
        y = hBot + radius; vy *= -floorBounce; sndBallBound.play();
      }
    }
  }

  void shockwave(Slime s) {
    float d = dist(x, y, s.x, s.y);
    if (d < s.radius * 3.5) {
      vy = -10;
      vx += (x - s.x) * 0.08;
    }
  }

  void checkCollision(Slime s) {
    float sx   = s.x;
    float sy   = s.y - s.radius;
    float minD = radius + s.radius;
    float d    = dist(x, y, sx, sy);
    if (d >= minD) return;
    sndBallSlime.play();
    float angle = atan2(y - sy, x - sx);
    float power = ((s.dashFrames > 0) ? 18 : 13) * kickMult;
    vx = cos(angle) * power;
    vy = sin(angle) * power;
    x  = sx + cos(angle) * (minD + 2);
    y  = sy + sin(angle) * (minD + 2);
  }

  void display() {
    // 그림자
    noStroke();
    fill(0, 0, 0, 55);
    ellipse(x, groundY - 2, radius * 2.2, radius * 0.45);

    if (ballSheet != null) {
      int fw = ballSheet.width  / 2;
      int fh = ballSheet.height / 2;
      int col = frame % 2;
      int row = frame / 2;
      imageMode(CENTER);
      if (type == 0) noTint();
      else           tint(ballColor);
      image(ballSheet, x, y, radius * 2, radius * 2,
            col * fw, row * fh, (col+1)*fw, (row+1)*fh);
      noTint();
      imageMode(CORNER);
    } else {
      noStroke();
      fill(ballColor);
      circle(x, y, radius * 2);
      fill(255, 255, 255, 85);
      ellipse(x - radius*0.28, y - radius*0.32, radius*0.55, radius*0.38);
    }
    noStroke();
  }
}
