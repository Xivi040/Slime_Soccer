// ════════════════════════════════════════════════════════
//  슬라임 스프라이트시트 구조  (slime_grid_200.png)
// ════════════════════════════════════════════════════════

final int ST_IDLE       = 0;
final int ST_WALK       = 1;
final int ST_DASH       = 2;
final int ST_JUMP       = 3;
final int ST_DOUBLEJUMP = 4;
final int ST_HARDLAND   = 5;

final int ANIM_FRAMES   = 4;
int       SPRITE_SIZE   = 200;  // 스킨에 따라 동적으로 설정됨

class Slime {

  // ── 물리 ──────────────────────────────────
  float x, y, vy;
  float radius    = 45;
  float baseSpeed = 5;
  boolean left, right;

  // ── 점프 ──────────────────────────────────
  int     jumpsLeft   = 2;
  boolean wasOnGround = true;

  // ── 대시 ──────────────────────────────────
  final int DASH_CD  = 90;   // 1.5초 (60fps 기준)
  int   dashCool     = 0;
  float dashVx       = 0;
  int   dashFrames   = 0;

  // ── 빠른 하강 ─────────────────────────────
  boolean downPress = false;
  boolean fastFall  = false;

  // ── 착지 이펙트 타이머 ────────────────────
  int landFrames = 0;
  final int LAND_EFFECT_DURATION = 16;

  // ── 스프라이트 ────────────────────────────
  PImage  sheet;
  boolean isPlayer1;
  int     sheetRow;

  // ── 애니메이션 ────────────────────────────
  int animState  = ST_IDLE;
  int animFrame  = 0;
  int frameTimer = 0;
  final int[] FRAME_DELAY = { 9, 6, 4, 7, 6, 5 };

  // ── 방향 ──────────────────────────────────
  boolean faceLeft;

  // ──────────────────────────────────────────
  Slime(float sx, float sy, boolean isP1, PImage img) {
    x         = sx;
    y         = sy;
    isPlayer1 = isP1;
    sheet     = img;
    sheetRow  = isP1 ? 0 : 1;
    faceLeft  = (sx < width / 2);
    if (img != null) SPRITE_SIZE = img.width / (ANIM_FRAMES * 6);
  }

  // ──────────────────────────────────────────
  void update() {
    if (dashCool   > 0) dashCool--;
    if (landFrames > 0) landFrames--;

    boolean onGround = (y >= groundY + 12);

    if (dashFrames > 0) {
      x += dashVx;
      dashFrames--;
    } else {
      if (left)  { x -= baseSpeed; faceLeft = true;  }
      if (right) { x += baseSpeed; faceLeft = false; }
    }

    if (downPress && !onGround && !fastFall) {
      vy       = 16;
      fastFall = true;
    }

    vy += gravity;
    y  += vy;

    if (y >= groundY + 12) {
      // S/↓ 빠른 하강으로 착지했을 때만 이펙트 발동
      if (!wasOnGround && fastFall) {
        landFrames = LAND_EFFECT_DURATION;
        sndHardland.play();
      }
      y         = groundY + 12;
      vy        = 0;
      jumpsLeft = 2;
      fastFall  = false;
    }
    wasOnGround = onGround;
    x = constrain(x, radius, width - radius);

    int next = decideState();
    if (next != animState) {
      animState  = next;
      animFrame  = 0;
      frameTimer = 0;
    }
    frameTimer++;
    if (frameTimer >= FRAME_DELAY[animState]) {
      frameTimer = 0;
      animFrame  = (animFrame + 1) % ANIM_FRAMES;
    }
  }

  int decideState() {
    if (dashFrames > 0)                       return ST_DASH;
    // HARDLAND: S/↓ 착지 이후 이펙트 재생 중일 때만
    if (y >= groundY + 12 && landFrames > 0)  return ST_HARDLAND;
    if (y < groundY + 12) {
      // 빠른 하강 중(아직 착지 전)에도 HARDLAND 모션 미리 재생
      if (fastFall)                           return ST_HARDLAND;
      return (jumpsLeft == 0) ? ST_DOUBLEJUMP : ST_JUMP;
    }
    if (left || right)                        return ST_WALK;
    return ST_IDLE;
  }

  void jump() {
    if (jumpsLeft > 0) {
      vy = -12;
      jumpsLeft--;
      if (landFrames == 0) sndJump.play();  // hardland 중에는 jump 소리 억제
    }
  }

  void dash() {
    if (dashCool > 0) return;
    sndDash.play();
    float dir = faceLeft ? -1 : 1;
    if (left)  dir = -1;
    if (right) dir =  1;
    dashVx     = dir * 14;
    dashFrames = 12;
    dashCool   = DASH_CD;
  }

  void forceIdleAnim() {
    animState = ST_IDLE;
    animFrame = (frameCount / 9) % ANIM_FRAMES;
  }

  // ──────────────────────────────────────────
  void display() {
    drawSprite(x, y);
  }

  void displayAt(float tx, float ty) {
    drawSprite(tx, ty);
  }

  void drawSprite(float tx, float ty) {
    if (sheet == null) return;

    // ── 착지 이펙트 (스프라이트 아래에 먼저 그림) ──
    if (landFrames > 0) drawLandEffect(tx, ty);

    int col  = animState * ANIM_FRAMES + animFrame;
    int srcX = col      * SPRITE_SIZE;
    int srcY = sheetRow * SPRITE_SIZE;

    float drawW = radius * 2.6;
    float drawH = radius * 2.6;
    float drawX = tx - drawW * 0.5;
    float drawY = ty - drawH;

    if (dashFrames > 0)  tint(255, 210, 60, 220);
    else if (fastFall)   tint(180, 220, 255, 220);
    else                 noTint();

    imageMode(CORNER);

    if (faceLeft) {
      image(sheet, drawX, drawY, drawW, drawH,
            srcX + SPRITE_SIZE, srcY, srcX, srcY + SPRITE_SIZE);
    } else {
      image(sheet, drawX, drawY, drawW, drawH,
            srcX, srcY, srcX + SPRITE_SIZE, srcY + SPRITE_SIZE);
    }

    noTint();
  }

  // ──────────────────────────────────────────
  //  착지 충격파 이펙트
  //  landFrames: LAND_EFFECT_DURATION(16) → 0
  // ──────────────────────────────────────────
  void drawLandEffect(float tx, float ty) {
    float t = 1.0 - (float)landFrames / LAND_EFFECT_DURATION; // 0.0 → 1.0

    pushMatrix();
    translate(tx, ty);
    noFill();

    // ── 1. 1차 충격파 링 (빠르게 팽창) ───────
    if (landFrames > 8) {
      float rt     = 1.0 - (float)(landFrames - 8) / 8.0;  // 0→1
      float ringRx = radius * (1.1 + rt * 1.5);
      float ringRy = ringRx * 0.20;
      float alpha  = 255 * (1.0 - rt);
      stroke(255, 255, 255, alpha);
      strokeWeight(2.5 - rt * 1.5);
      ellipse(0, 0, ringRx * 2, ringRy * 2);
    }

    // ── 2. 2차 충격파 링 (조금 뒤처져서 팽창) ─
    if (landFrames > 3 && landFrames < 13) {
      float rt     = 1.0 - (float)(landFrames - 3) / 10.0;
      float ringRx = radius * (0.9 + rt * 1.8);
      float ringRy = ringRx * 0.18;
      float alpha  = 180 * (1.0 - rt);
      stroke(255, 255, 255, alpha);
      strokeWeight(1.2);
      ellipse(0, 0, ringRx * 2, ringRy * 2);
    }

    // ── 3. 먼지 파티클 (좌우로 튀어나감) ─────
    noStroke();
    if (t > 0.1 && t < 0.9) {
      float dustT   = (t - 0.1) / 0.8;
      float alpha   = 200 * sin(dustT * PI); // 나타났다 사라짐

      // 슬라임 색상에 맞는 먼지색
      if (isPlayer1) fill(120, 180, 240, alpha);
      else           fill(80,  210, 80,  alpha);

      int num = 7;
      for (int i = 0; i < num; i++) {
        // 좌우 대칭 반원 형태로 방사
        float a   = PI + (i / (float)(num - 1)) * PI;
        float dist = radius * (0.7 + dustT * 1.6);
        float px  = cos(a) * dist;
        float py  = sin(a) * dist * 0.28 - dustT * 10;
        float sz  = 6 * (1.0 - dustT * 0.6);
        ellipse(px, py, sz, sz);
      }

      // 흰 중앙 작은 먼지
      fill(255, 255, 255, alpha * 0.5);
      float spread = dustT * 14;
      ellipse(-spread, -dustT * 5, 3, 3);
      ellipse( spread, -dustT * 5, 3, 3);
    }

    popMatrix();
    noStroke();
  }
}
