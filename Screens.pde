// ════════════════════════════════════════════════════════
//  화면 씬 클래스
// ════════════════════════════════════════════════════════
void drawPixelBg(boolean dark) {
  noTint(); noStroke();

  // 하늘 그라데이션
  color skyTop = dark ? color(7,  5, 18)  : color(13,  9, 38);
  color skyBot = dark ? color(12, 18,  9) : color(20, 30, 14);
  for (int y = 0; y < height; y += 4) {
    float t = (float)y / height;
    fill(
      (int)lerp(red(skyTop),   red(skyBot),   t),
      (int)lerp(green(skyTop), green(skyBot), t),
      (int)lerp(blue(skyTop),  blue(skyBot),  t)
    );
    rect(0, y, width, 5);
  }

  // 별
  randomSeed(42);
  for (int i = 0; i < 100; i++) {
    float sx = random(width);
    float sy = random(height * 0.60);
    float tw = 0.55 + 0.45 * sin(frameCount * 0.04 + i * 1.9);
    fill(255, 255, 210, (int)((dark ? 90 : 155) * tw));
    int gs = (int)random(1, 3) * 2;
    rect((int)(sx / gs) * gs, (int)(sy / gs) * gs, gs, gs);
  }

  // 달 (크레센트)
  fill(255, 252, 200, 195);
  ellipseMode(CENTER);
  ellipse(130, 92, 54, 54);
  fill(red(skyTop), green(skyTop), blue(skyTop));
  ellipse(143, 85, 46, 46);

  // 반딧불 (인트로에서만)
  if (!dark) {
    for (int i = 0; i < 10; i++) {
      float fx = 110 + i * 148 + sin(frameCount * 0.022 + i * 2.1) * 38;
      float fy = height - 162 + sin(frameCount * 0.031 + i * 1.6) * 20;
      float gw = 0.5 + 0.5 * sin(frameCount * 0.09 + i * 3.3);
      noStroke();
      fill(200, 240, 75, (int)(38 * gw));
      ellipse(fx, fy, 13, 13);
      fill(210, 245, 80, (int)(175 * gw));
      ellipse(fx, fy, 4, 4);
    }
  }

  // 산 레이어 (뒤 → 앞)
  drawPixelMountains(height - 210, 90,  color(36, 42, 85),  0.012);
  drawPixelMountains(height - 168, 65,  color(20, 52, 40),  1.005);

  // 나무숲 레이어
  drawPixelForest(height - 148, color(14, 44, 20), 301, 3);
  drawPixelForest(height - 102, color( 9, 28, 13), 502, 5);

  // 지면
  noStroke();
  fill(26, 68, 22); rect(0, height - 98, width, 22);
  fill(16, 50, 14); rect(0, height - 78, width, 78);

  // 풀 타래
  randomSeed(77);
  fill(42, 100, 35);
  for (int i = 0; i < 38; i++) {
    int gx = (int)(random(width) / 4) * 4;
    rect(gx,      height - 99,  4,  9);
    rect(gx +  4, height - 103, 4, 11);
    rect(gx +  8, height - 98,  4,  7);
  }
}

void drawPixelMountains(float baseY, float maxH, color c, float nOff) {
  fill(c); noStroke();
  int step = 6;
  for (int i = 0; i <= width / step + 1; i++) {
    float h = noise(nOff + i * 0.06) * maxH + maxH * 0.25;
    rect(i * step, baseY - h, step + 1, h + height);
  }
}

void drawPixelForest(float baseY, color tc, int seed, int minPs) {
  randomSeed(seed);
  noStroke();
  for (int tx = -15; tx < width + 20; ) {
    int th = (int)random(55, 100);
    int ps = (int)random(minPs, minPs + 3);
    drawPixelPineTree(tx, (int)baseY, th, ps, tc);
    tx += (int)random(18, 30);
  }
}

void drawPixelPineTree(int cx, int baseY, int th, int ps, color c) {
  noStroke();

  // 트렁크
  fill(
    constrain((int)(red(c)   * 0.70 + 14), 0, 255),
    constrain((int)(green(c) * 0.50 +  7), 0, 255),
    constrain((int)(blue(c)  * 0.40),       0, 255)
  );
  int trunkW = ps * 2;
  int trunkH = th / 3;
  rect(cx - trunkW / 2, baseY - trunkH, trunkW, trunkH);

  // 잎 레이어 (위→아래, 좁→넓)
  fill(c);
  int foliageH = th - trunkH;
  int numLayers = max(3, foliageH / (ps * 2));
  int layerH    = foliageH / numLayers;

  for (int l = 0; l < numLayers; l++) {
    int lw = (l + 2) * ps * 2;
    int ly = baseY - trunkH - foliageH + l * layerH;
    rect(cx - lw / 2, ly, lw, layerH + 1);
  }
}

// ─────────────────────────────────────────────
//  낮 배경 (인트로 DAY MODE)
// ─────────────────────────────────────────────
void drawDayBg() {
  noStroke();
  // 하늘 그라데이션 (파란 하늘 → 지평선 밝은 하늘)
  for (int y = 0; y < height; y += 3) {
    float t = (float)y / height;
    fill(
      (int)lerp(80,  210, t),
      (int)lerp(165, 230, t),
      (int)lerp(235, 180, t)
    );
    rect(0, y, width, 4);
  }

  // 태양 (오른쪽 상단)
  fill(255, 245, 100, 30); ellipseMode(CENTER);
  ellipse(width - 135, 85, 120, 120);
  fill(255, 240, 80, 60);
  ellipse(width - 135, 85, 88, 88);
  fill(255, 238, 75, 220);
  ellipse(width - 135, 85, 62, 62);

  // 픽셀 구름들
  int ps = 8;
  color cc = color(248, 252, 255, 215);
  fill(cc); noStroke();
  int[][] cl = {{140,155},{640,115},{1050,85},{1300,148}};
  int[][] shapes = {{2,5,7,9,7},{3,4,9,11,9},{1,4,6,6,4},{2,5,7,8,6}};
  for (int ci = 0; ci < cl.length; ci++) {
    int cx = cl[ci][0], cy2 = cl[ci][1];
    int[] sh = shapes[ci];
    rect(cx + ps*(sh[0]), cy2,        ps*sh[1], ps*2);
    rect(cx + ps,         cy2+ps*2,   ps*sh[2], ps*2);
    rect(cx,              cy2+ps*3,   ps*sh[3], ps*2);
    rect(cx + ps,         cy2+ps*5,   ps*sh[4], ps*2);
  }

  // 산 (밝은 녹색)
  drawPixelMountains(height - 210, 90, color(58, 125, 55), 0.012);
  drawPixelMountains(height - 168, 65, color(48, 148, 52), 1.005);
  // 숲
  drawPixelForest(height - 148, color(32, 115, 38), 301, 3);
  drawPixelForest(height - 102, color(22,  88, 28), 502, 5);

  // 지면
  noStroke();
  fill(58, 158, 45); rect(0, height - 98, width, 22);
  fill(48, 132, 38); rect(0, height - 78, width, 78);

  // 풀 타래
  randomSeed(77);
  fill(80, 195, 58);
  for (int i = 0; i < 38; i++) {
    int gx = (int)(random(width) / 4) * 4;
    rect(gx,      height - 99,  4,  9);
    rect(gx +  4, height - 103, 4, 11);
    rect(gx +  8, height - 98,  4,  7);
  }
}

// ─────────────────────────────────────────────
//  인트로 화면
// ─────────────────────────────────────────────
class IntroScreen {

  void display() {
    if (nightMode) drawPixelBg(false);
    else           drawDayBg();
    drawTitle();
    drawControls();
    drawScoreSelector();
    drawModeSelector();
    boolean startHover = drawStartButton();
    drawSkinSelector();
    drawPreview();
    handleClick(startHover);
  }

  void drawTitle() {
    textFont(pixelFont);
    textAlign(CENTER, CENTER);

    // 글로우
    for (int i = 5; i > 0; i--) {
      fill(255, 200, 40, 18 * i);
      textSize(66 + i);
      text("SLIME SOCCER", width / 2, 112);
    }

    float pulse = sin(frameCount * 0.05) * 2.2;
    fill(255, 228, 58);
    textSize(66);
    text("SLIME SOCCER", width / 2, 110 + pulse);

    fill(155, 212, 138);
    textSize(13);
    text("FIRST TO " + WIN_SCORE + " GOALS WINS", width / 2, 168);
  }

  void drawControls() {
    // 패널 배경
    fill(0, 0, 0, 155); noStroke();
    rect(width / 2 - 390, 192, 780, 108, 6);
    stroke(65, 115, 60, 175); strokeWeight(2); noFill();
    rect(width / 2 - 390, 192, 780, 108, 6);
    noStroke();

    textFont(pixelFont);
    textAlign(CENTER, CENTER);
    fill(155, 222, 125); textSize(11);
    text("P1   A/D MOVE   W JUMP x2   SHIFT DASH   S FALL", width / 2, 228);
    fill(125, 172, 242); textSize(11);
    text("P2   </> MOVE   ^ JUMP x2   ENTER DASH   v FALL", width / 2, 270);
  }

  void drawScoreSelector() {
    float cy = 358;

    fill(0, 0, 0, 148); noStroke();
    rect(width / 2 - 215, cy - 57, 430, 94, 6);
    stroke(65, 115, 60, 148); strokeWeight(2); noFill();
    rect(width / 2 - 215, cy - 57, 430, 94, 6);
    noStroke();

    textFont(pixelFont);
    textAlign(CENTER, CENTER);
    fill(255, 215, 68); textSize(12);
    text("GOAL TO WIN", width / 2, cy - 32);

    boolean hM = hitMinus();
    fill(hM ? color(228, 78, 72) : color(142, 34, 38)); noStroke();
    rect(width / 2 - 198, cy - 22, 58, 46, 6);
    if (hM) { stroke(255, 128, 125); strokeWeight(2); noFill(); rect(width / 2 - 198, cy - 22, 58, 46, 6); noStroke(); }
    fill(255); textSize(28); text("-", width / 2 - 169, cy + 3);

    fill(255, 215, 55); textSize(46); text(WIN_SCORE, width / 2, cy + 4);

    boolean hP = hitPlus();
    fill(hP ? color(68, 205, 82) : color(28, 112, 40)); noStroke();
    rect(width / 2 + 140, cy - 22, 58, 46, 6);
    if (hP) { stroke(128, 255, 138); strokeWeight(2); noFill(); rect(width / 2 + 140, cy - 22, 58, 46, 6); noStroke(); }
    fill(255); textSize(28); text("+", width / 2 + 169, cy + 3);
  }

  void drawModeSelector() {
    textFont(pixelFont);
    textAlign(CENTER, CENTER);

    // DAY MODE 버튼
    boolean hDay = hitDayMode();
    boolean dayActive = !nightMode;
    fill(dayActive ? color(220, 165, 30) : (hDay ? color(180, 130, 20) : color(80, 60, 10))); noStroke();
    rect(width/2 - 195, 418, 178, 44, 8);
    if (dayActive) { stroke(255, 220, 80); strokeWeight(2); noFill(); rect(width/2 - 195, 418, 178, 44, 8); noStroke(); }
    fill(255); textSize(12);
    text("DAY MODE", width/2 - 106, 440);

    // NIGHT MODE 버튼
    boolean hNight = hitNightMode();
    boolean nightActive = nightMode;
    fill(nightActive ? color(40, 55, 130) : (hNight ? color(30, 42, 100) : color(15, 22, 55))); noStroke();
    rect(width/2 + 17, 418, 178, 44, 8);
    if (nightActive) { stroke(120, 150, 255); strokeWeight(2); noFill(); rect(width/2 + 17, 418, 178, 44, 8); noStroke(); }
    fill(255); textSize(12);
    text("NIGHT MODE", width/2 + 106, 440);
  }

  boolean drawStartButton() {
    boolean hover = mouseX > width / 2 - 138 && mouseX < width / 2 + 138 &&
                    mouseY > 480             && mouseY < 538;

    if (hover) {
      fill(78, 228, 108, 42); noStroke();
      rect(width / 2 - 150, 473, 300, 72, 14);
    }

    fill(hover ? color(62, 192, 78) : color(30, 135, 48)); noStroke();
    rect(width / 2 - 138, 480, 276, 58, 10);
    stroke(hover ? color(135, 255, 148) : color(52, 172, 68));
    strokeWeight(2); noFill();
    rect(width / 2 - 138, 480, 276, 58, 10);
    noStroke();

    textFont(pixelFont);
    fill(255); textSize(20); textAlign(CENTER, CENTER);
    text("START", width / 2, 509);
    return hover;
  }

  void drawSkinSelector() {
    textFont(pixelFont); textAlign(CENTER, CENTER);
    fill(255, 215, 68); textSize(11);
    text("SKIN", width / 2, 552);

    int[] labels = {1, 2, 3, 4};
    for (int i = 0; i < 4; i++) {
      float bx = width / 2 - 178 + i * 92;
      float by = 562;
      boolean active = (skinNum == i + 1);
      boolean hover  = mouseX > bx && mouseX < bx + 82 && mouseY > by && mouseY < by + 38;

      fill(active ? color(180, 130, 20) : (hover ? color(80, 70, 20) : color(40, 35, 10)));
      noStroke(); rect(bx, by, 82, 38, 8);
      if (active) {
        stroke(255, 215, 60); strokeWeight(2); noFill();
        rect(bx, by, 82, 38, 8); noStroke();
      }
      fill(255); textSize(16);
      text(str(labels[i]), bx + 41, by + 19);
    }
  }

  void drawPreview() {
    // 선택된 스킨 실시간 반영
    p1.sheet = skinSheets[skinNum - 1];
    p2.sheet = skinSheets[skinNum - 1];
    if (p1.sheet != null) SPRITE_SIZE = p1.sheet.width / (ANIM_FRAMES * 6);
    p1.forceIdleAnim();
    p2.forceIdleAnim();
    p1.displayAt(width / 2 - 330, 660);
    p2.displayAt(width / 2 + 330, 660);
  }

  void handleClick(boolean startHover) {
    if (!(mousePressed && !mouseWasPressed)) return;
    if (hitMinus())   WIN_SCORE = max(1,  WIN_SCORE - 1);
    if (hitPlus())    WIN_SCORE = min(10, WIN_SCORE + 1);
    if (hitDayMode())   nightMode = false;
    if (hitNightMode()) nightMode = true;
    for (int i = 1; i <= 4; i++) if (hitSkin(i)) skinNum = i;
    if (startHover) { p1Score = 0; p2Score = 0; resetRound(); scene = 1; }
  }

  boolean hitSkin(int n) {
    float bx = width / 2 - 178 + (n - 1) * 92;
    return mouseX > bx && mouseX < bx + 82 && mouseY > 562 && mouseY < 600;
  }

  boolean hitMinus() {
    float cy = 358;
    return mouseX > width/2 - 198 && mouseX < width/2 - 140 &&
           mouseY > cy - 22       && mouseY < cy + 24;
  }
  boolean hitPlus() {
    float cy = 358;
    return mouseX > width/2 + 140 && mouseX < width/2 + 198 &&
           mouseY > cy - 22       && mouseY < cy + 24;
  }
  boolean hitDayMode() {
    return mouseX > width/2 - 195 && mouseX < width/2 - 17 &&
           mouseY > 418            && mouseY < 462;
  }
  boolean hitNightMode() {
    return mouseX > width/2 + 17  && mouseX < width/2 + 195 &&
           mouseY > 418            && mouseY < 462;
  }
}

// ─────────────────────────────────────────────
//  명예의 전당 배경 요소
// ─────────────────────────────────────────────
void drawHallOfFameBg() {
  noStroke();
  // 왕실 보라 배경
  for (int y = 0; y < height; y += 3) {
    float t = (float)y / height;
    fill((int)lerp(28,18,t), (int)lerp(10,6,t), (int)lerp(55,38,t));
    rect(0, y, width, 4);
  }

  // 황금 별
  randomSeed(77);
  for (int i = 0; i < 55; i++) {
    float sx = random(width);
    float sy = random(height * 0.65);
    float tw = 0.5 + 0.5 * sin(frameCount * 0.05 + i * 2.3);
    fill(255, 215, 80, (int)(148 * tw));
    rect((int)(sx/2)*2, (int)(sy/2)*2, 2, 2);
  }

  // 색종이 낙하
  noStroke();
  color[] cc = {color(255,60,60), color(60,255,110), color(60,110,255), color(255,215,0), color(255,60,200)};
  for (int i = 0; i < 38; i++) {
    float px = (width * i / 38.0 + sin(frameCount * 0.04 + i * 1.3) * 55 + frameCount * (0.6 + (i%3)*0.4)) % width;
    float py = (frameCount * (0.9 + (i % 4) * 0.35) + i * 22) % height;
    fill(cc[i % 5]);
    rect(px, py, 6, 4);
  }

  // 기둥
  drawHallColumn(58,  height - 45, 530);
  drawHallColumn(185, height - 45, 425);
  drawHallColumn(width - 58,  height - 45, 530);
  drawHallColumn(width - 185, height - 45, 425);

  // 붉은 카펫
  noStroke();
  fill(145, 18, 18); rect(0, height - 75, width, 75);
  fill(168, 22, 22); rect(0, height - 75, width, 10);
  fill(188, 28, 28);
  for (int x = 0; x < width; x += 34) rect(x, height - 75, 17, 75);
  fill(115, 10, 10); rect(0, height - 48, width, 7);
}

void drawHallColumn(float cx, float by, int h) {
  int ps = 7; noStroke();
  fill(172, 155, 118); rect(cx - ps*2, by - h, ps*4, h);
  fill(208, 190, 148); rect(cx - ps*2, by - h, ps, h);
  fill(192, 172, 132);
  rect(cx - ps*3, by - h - ps*2, ps*6, ps*2);
  rect(cx - ps*4, by - h - ps*3, ps*8, ps);
  rect(cx - ps*3, by - ps*2, ps*6, ps*2);
  rect(cx - ps*4, by - ps*3, ps*8, ps);
}

void drawHallPodium(float cx, float by) {
  int ps = 7; noStroke();
  fill(195, 150, 0);  rect(cx - ps*10, by - ps*12, ps*20, ps*12);
  fill(255, 218, 50); rect(cx - ps*10, by - ps*12, ps*20, ps*2);
  fill(148, 108, 0);  rect(cx - ps*10, by - ps*2,  ps*20, ps*2);
  fill(168, 128, 0);  rect(cx + ps*8,  by - ps*12, ps*2,  ps*12);
  fill(100, 72, 0);
  textFont(pixelFont); textSize(17); textAlign(CENTER, CENTER);
  text("1ST", cx, by - ps*6);
}

void drawHallCrown(float cx, float cy) {
  int ps = 7; noStroke();
  fill(255, 205, 0);
  rect(cx - ps*5, cy - ps*2, ps*10, ps*2);
  rect(cx - ps*4, cy - ps*5, ps*2,  ps*3);
  rect(cx - ps,   cy - ps*6, ps*2,  ps*4);
  rect(cx + ps*2, cy - ps*5, ps*2,  ps*3);
  fill(255, 238, 65);
  rect(cx - ps*4, cy - ps*5, ps*2, ps);
  rect(cx - ps,   cy - ps*6, ps*2, ps);
  rect(cx + ps*2, cy - ps*5, ps*2, ps);
  fill(255, 50, 50);   rect(cx - ps*3+1, cy - ps+1, ps-2, ps-2);
  fill(100, 100, 255); rect(cx - 1,       cy - ps+1, ps-2, ps-2);
  fill(255, 50, 50);   rect(cx + ps*2+1,  cy - ps+1, ps-2, ps-2);
  fill(200, 158, 0);   rect(cx - ps*5, cy - ps*2, ps*10, 2);
}

// ─────────────────────────────────────────────
//  아웃트로 화면 (명예의 전당)
// ─────────────────────────────────────────────
class GameOverScreen {

  void display(int winner) {
    Slime ws     = (winner == 1) ? p1 : p2;
    color winCol = (winner == 1) ? color(100, 220, 100) : color(100, 160, 255);
    String winTx = (winner == 1) ? "1P WIN!" : "2P WIN!";

    drawHallOfFameBg();

    textFont(pixelFont); textAlign(CENTER, CENTER);

    // 헤더
    fill(255, 215, 0, 185); textSize(13);
    text("- HALL  OF  FAME -", width / 2, 60);

    // 승리 타이틀 글로우
    for (int i = 4; i > 0; i--) {
      fill(red(winCol), green(winCol), blue(winCol), 18 * i);
      textSize(78 + i * 2);
      text(winTx, width / 2, 132);
    }
    fill(winCol); textSize(78);
    text(winTx, width / 2, 130);

    // 스코어 패널
    fill(0, 0, 0, 162); noStroke();
    rect(width/2 - 235, 208, 470, 66, 8);
    stroke(120, 100, 48, 155); strokeWeight(2); noFill();
    rect(width/2 - 235, 208, 470, 66, 8); noStroke();
    fill(255, 215, 55); textSize(15);
    text("FINAL  " + p1Score + "  :  " + p2Score, width / 2, 241);

    // Play Again
    boolean hA = hitAgain();
    fill(hA ? color(72,142,255) : color(32,92,202)); noStroke();
    rect(width/2 - 158, 300, 316, 54, 10);
    stroke(hA ? color(142,192,255) : color(58,122,218));
    strokeWeight(2); noFill(); rect(width/2 - 158, 300, 316, 54, 10); noStroke();
    fill(255); textSize(15); text("PLAY AGAIN", width / 2, 327);

    // Main Menu
    boolean hM = hitMenu();
    fill(hM ? color(155,155,155) : color(68,68,68)); noStroke();
    rect(width/2 - 158, 368, 316, 52, 10);
    stroke(hM ? color(200,200,200) : color(105,105,105));
    strokeWeight(2); noFill(); rect(width/2 - 158, 368, 316, 52, 10); noStroke();
    fill(255); textSize(15); text("MAIN MENU", width / 2, 394);

    // 전적 패널 (좌우 빈 공간)
    drawWinRecord(1, 420, 340, color(100, 220, 100));
    drawWinRecord(2, width - 420, 340, color(100, 160, 255));

    // 포디엄 + 슬라임 + 왕관
    float podiumTopY = 632;
    drawHallPodium(width / 2, podiumTopY + 7 * 12);
    ws.forceIdleAnim();
    ws.displayAt(width / 2, podiumTopY);
    drawHallCrown(width / 2, podiumTopY - 94);

    if (mousePressed && !mouseWasPressed) {
      if (hA) { p1Score = 0; p2Score = 0; resetRound(); scene = 1; }
      if (hM) { p1Score = 0; p2Score = 0; resetRound(); scene = 0; }
    }
  }

  void drawWinRecord(int player, float cx, float cy, color col) {
    int pw = 240, ph = 280;
    float px = cx - pw / 2, py = cy - ph / 2;

    // 패널 배경
    fill(0, 0, 0, 165); noStroke();
    rect(px, py, pw, ph, 10);
    stroke(red(col), green(col), blue(col), 140);
    strokeWeight(2); noFill();
    rect(px, py, pw, ph, 10); noStroke();

    textFont(pixelFont); textAlign(CENTER, CENTER);

    // 플레이어 헤더
    fill(col); textSize(14);
    text((player == 1 ? "1P" : "2P"), cx, py + 28);

    // 구분선
    stroke(red(col), green(col), blue(col), 100);
    strokeWeight(1);
    line(px + 16, py + 46, px + pw - 16, py + 46);
    noStroke();

    int wins   = (player == 1) ? p1Wins : p2Wins;
    int losses = (player == 1) ? p2Wins : p1Wins;
    int total  = wins + losses;

    // 승
    fill(255, 215, 55); textSize(10);
    text("WIN", cx, py + 68);
    fill(100, 220, 100); textSize(36);
    text(str(wins), cx, py + 108);

    // 패
    fill(255, 215, 55); textSize(10);
    text("LOSE", cx, py + 146);
    fill(200, 80, 80); textSize(36);
    text(str(losses), cx, py + 186);

    // 총 게임수
    fill(180, 180, 180); textSize(9);
    text("TOTAL  " + total + " GAMES", cx, py + 252);
  }

  boolean hitAgain() {
    return mouseX > width/2 - 158 && mouseX < width/2 + 158 && mouseY > 300 && mouseY < 354;
  }
  boolean hitMenu() {
    return mouseX > width/2 - 158 && mouseX < width/2 + 158 && mouseY > 368 && mouseY < 420;
  }
}
