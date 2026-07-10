class Hud {

  void display() {
    drawScore();
    drawCooldown();
  }

  // ── 점수판 ────────────────────────────────
  void drawScore() {
    fill(0, 0, 0, 160); noStroke(); rect(0, 0, width, 52);

    float dotR = 13, gap = 6, barCY = 26;

    fill(100, 220, 100); textSize(22); textAlign(LEFT,  CENTER); text("P1", 18,        barCY);
    fill(100, 160, 255); textSize(22); textAlign(RIGHT, CENTER); text("P2", width - 18, barCY);

    // 점수 원을 중앙 숫자에서 충분히 떨어진 위치에 배치
    for (int i = 0; i < WIN_SCORE; i++) {
      float dx = width/2 - 130 - i*(dotR*2 + gap);
      if (i < p1Score) { fill(100, 220, 100); stroke(60, 170, 60); strokeWeight(2); }
      else             { fill(40, 40, 60);    stroke(80, 80, 100); strokeWeight(1); }
      ellipse(dx, barCY, dotR*2, dotR*2);
    }
    noStroke();

    fill(255, 220, 50); textSize(26); textAlign(CENTER, CENTER);
    text(p1Score + " : " + p2Score, width/2, barCY);

    // 공 타입 표시 (일반 공 제외)
    if (ballType > 0) {
      color[] bc = {color(0), color(150,150,150), color(80,145,255), color(255,215,25)};
      String[] bn = {"", "HEAVY", "LIGHT", "BOUNCY"};
      noStroke(); fill(bc[ballType]); ellipse(width/2 - 36, 43, 11, 11);
      fill(bc[ballType]); textFont(pixelFont); textSize(9); textAlign(LEFT, CENTER);
      text(bn[ballType] + " BALL", width/2 - 27, 43);
    }

    for (int i = 0; i < WIN_SCORE; i++) {
      float dx = width/2 + 130 + i*(dotR*2 + gap);
      if (i < p2Score) { fill(100, 160, 255); stroke(60, 120, 220); strokeWeight(2); }
      else             { fill(40, 40, 60);    stroke(80, 80, 100);  strokeWeight(1); }
      ellipse(dx, barCY, dotR*2, dotR*2);
    }
    noStroke();
  }

  // ── 대시 쿨다운 ───────────────────────────
  void drawCooldown() {
    float pw = 220, ph = 56, topY = 56;

    // P1
    fill(0, 0, 0, 145); noStroke(); rect(0, topY, pw, ph);
    stroke(100, 220, 100, 110); strokeWeight(1); noFill();
    rect(0, topY, pw, ph); noStroke();
    fill(100, 220, 100); textSize(12); textAlign(LEFT, TOP);
    text("P1  DASH", 12, topY + 10);
    drawCoolBar(12, topY + 32, pw - 24, 18, p1.dashCool, p1.DASH_CD, color(100, 220, 100));

    // P2
    fill(0, 0, 0, 145); noStroke(); rect(width - pw, topY, pw, ph);
    stroke(100, 160, 255, 110); strokeWeight(1); noFill();
    rect(width - pw, topY, pw, ph); noStroke();
    fill(100, 160, 255); textSize(12); textAlign(LEFT, TOP);
    text("P2  DASH", width - pw + 12, topY + 10);
    drawCoolBar(width - pw + 12, topY + 32, pw - 24, 18, p2.dashCool, p2.DASH_CD, color(100, 160, 255));
  }

  void drawCoolBar(float cx, float cy, float w, float h, int cur, int maxCd, color c) {
    noStroke(); fill(50); rect(cx, cy, w, h, 4);
    float ratio = 1.0 - (float)cur / maxCd;
    if (ratio > 0) { fill(c); rect(cx, cy, w*ratio, h, 4); }
    textAlign(CENTER, CENTER); textSize(10); fill(255);
    text(cur <= 0 ? "READY" : nf(cur/60.0, 1, 1) + "s", cx + w/2, cy + h/2);
  }
}
