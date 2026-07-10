
class Goal {
  boolean isLeft;
  float   gx;       // 프레임 왼쪽 x
  float   topY;     // 가로대 상단 y
  float   w  = GW;  // 너비
  float   h  = GH;  // 높이
  float   post = G_POST;

  Goal(boolean isLeft) {
    this.isLeft = isLeft;
    this.gx     = isLeft ? 0 : width - GW;
    this.topY   = groundY - GH;
  }

  // 골 입구
  float mouthX() {
    return isLeft ? gx + w : gx;
  }

  // ── 그리기 ────────────────────────────────
  void display(PImage img) {
  imageMode(CORNER);
  if (img != null) {
    if (isLeft) {
      // 왼쪽 골대: 이미지 좌우반전
      pushMatrix();
      translate(gx + w, topY);  // 반전 기준점을 이미지 오른쪽 끝으로
      scale(-1, 1);              // 좌우반전
      image(img, 0, 0, w, h);   // 기준점(0,0)에서 그리기
      popMatrix();
    } else {
      // 오른쪽 골대: 원본 그대로
      image(img, width - w, topY, w, h);
    }
  } else {
    stroke(255); strokeWeight(5); noFill();
    rect(gx, topY, w, h);
    noStroke();
  }
}
  // ── 충돌 (가로대 + 뒷벽) ──────────────────
  void collide(Ball ball) {
    float r         = ball.radius;
    float barBottom = topY + post;

    // 골대 영역과 가로로 겹치지 않으면 무시
    boolean inX = (ball.x + r > gx) && (ball.x - r < gx + w);
    if (!inX) return;

    if (ball.y - r < barBottom && ball.y > topY && ball.vy < 0) {
      ball.y  = barBottom + r + 1;
      ball.vy *= -0.65;
    }
    if (ball.y - r < topY && ball.y + r > topY && ball.vy > 0) {
      ball.y  = topY - r - 1;
      ball.vy *= -0.65;
    }

    // 골 이후 화면밖 튕김방지 
    if (isLeft) {
      if (ball.x - r < gx)     { ball.x = gx + r;     ball.vx *= -0.4; }
    } else {
      if (ball.x + r > gx + w) { ball.x = gx + w - r; ball.vx *= -0.4; }
    }
  }

  // ── 슬라임 충돌 ──────────────────────────
  void collideSlime(Slime s) {
    // x 범위 밖이면 무시
    if (s.x + s.radius <= gx || s.x - s.radius >= gx + w) return;

    // 크로스바 윗면 착지
    if (s.vy >= 0 && s.y >= topY && s.y <= topY + 22) {
      s.y = topY; s.vy = 0; s.jumpsLeft = 2; s.fastFall = false;
    }

    // 크로스바 아랫면
    if (s.vy < 0 && s.y > topY + 3 && s.y <= topY + max(abs(s.vy) + 2, 22)) {
      s.vy = 0;
    }

    // 뒷벽
    if (isLeft  && s.x - s.radius < gx)     { s.x = gx + s.radius;     s.dashVx = max(s.dashVx, 0); }
    if (!isLeft && s.x + s.radius > gx + w) { s.x = gx + w - s.radius; s.dashVx = min(s.dashVx, 0); }
  }

  // ── 골 판정 ───────────────────────────────
  //  공이 크로스바 아래로, 입구를 한 반지름 넘어 들어오면 골
  boolean scored(Ball ball) {
    float r         = ball.radius;
    float barBottom = topY + post;

    boolean belowBar = ball.y > barBottom && ball.y < groundY;
    if (!belowBar) return false;

    if (isLeft) return ball.x < mouthX() - r;   // 왼쪽 골 안으로
    else        return ball.x > mouthX() + r;   // 오른쪽 골 안으로
  }
}
