import processing.sound.*;

// ── 이미지 리소스 ───
PImage spriteSheet;        // 현재 선택된 슬라임 스프라이트시트
PImage bg1;                // 낮 모드 배경 이미지
PImage goalImg;            // 골대 이미지 (오른쪽 골대는 좌우반전 적용)
PImage ballSheet;          // 공 스프라이트시트 (2×2 그리드, 4프레임)

// ── 게임 오브젝트 ────
Slime  p1, p2;             // 플레이어 슬라임 (p1=초록/왼쪽, p2=파랑/오른쪽)
Ball   ball;               // 공
Goal   goalL, goalR;       // 왼쪽/오른쪽 골대
Hud    hud;                // 상단 HUD (점수판 + 대시 쿨다운)

// ── 화면 객체 ───
IntroScreen    intro;      // 타이틀/설정 화면
GameOverScreen gameOver;   // 승리/전적 화면
PFont  pixelFont;          // Press Start 2P 픽셀 폰트

// ── 사운드 ───
SoundFile sndJump;         // 점프/더블점프 효과음
SoundFile sndBallBound;    // 공이 벽/바닥/HUD에 부딪힐 때
SoundFile sndBallSlime;    // 공이 슬라임에 맞을 때
SoundFile sndDash;         // 대시 발동 시 (쿨타임 0일 때만)
SoundFile sndHardland;     // 빠른 하강(S/↓) 착지 시
SoundFile sndVictory;      // 승리 확정 순간 (한 번만 재생)
SoundFile sndIntro;        // 인트로 BGM (loop)
SoundFile sndGameBgm;      // 낮 모드 게임 BGM (loop)
SoundFile sndNightBgm;     // 밤 모드 게임 BGM (loop)

// ── 씬 / 물리 / 모드 전역 변수 ───────────────
// scene: 0=인트로, 1=게임, 2=P2승, 3=P1승
int     scene     = 0;
float   gravity   = 0.4;   // 프레임당 중력 가속도 (공/슬라임 공통)
float   groundY;           // 바닥 y좌표 (setup에서 height-75로 설정)
boolean nightMode  = false; // true=밤 모드 (다른 배경·BGM·랜덤공 사용)
int     ballType   = 0;    // 0=일반 1=무거운 2=가벼운 3=탄성
int     skinNum    = 4;    // 선택된 슬라임 스킨 번호 (1~4, 기본 4)
PImage[] skinSheets = new PImage[4]; // 스킨 스프라이트시트 배열 [0]=100px~[3]=400px

// ── 골대 치수 상수 (goal.png 와 픽셀 단위 일치) ──
final float GW     = 60;   // 골대 프레임 너비
final float GH     = 150;  // 골대 프레임 높이
final float G_POST = 6;    // 가로대(크로스바) 두께

// ── 점수 및 전적 ─────
int p1Score   = 0;         // 현재 게임 P1 골 수
int p2Score   = 0;         // 현재 게임 P2 골 수
int WIN_SCORE = 3;         // 목표 점수 (인트로에서 1~10 조정 가능)
int p1Wins    = 0;         // 세션 누적 P1 승수
int p2Wins    = 0;         // 세션 누적 P2 승수

boolean mouseWasPressed = false; // 마우스 클릭 에지 감지용 (이전 프레임 상태)

// ─────────────────────────────────────────────
void setup() {
  size(1600, 800, P2D);          // P2D: OpenGL 기반 2D 렌더러
  groundY = height - 75;         // 바닥 y = 725

  pixelFont = createFont("PressStart2P-Regular.ttf", 32); // 픽셀 폰트 로드

  // 효과음 (0.8 = 80% 볼륨)
  sndJump      = new SoundFile(this, "jump_b.wav");             sndJump.amp(0.8);
  sndBallBound = new SoundFile(this, "ball_bound_b_short.mp3"); sndBallBound.amp(0.8);
  sndBallSlime = new SoundFile(this, "ball_bound_b_cut.mp3");   sndBallSlime.amp(0.8);
  sndDash      = new SoundFile(this, "dash_b.wav");             sndDash.amp(0.8);
  sndHardland  = new SoundFile(this, "hardland_b.wav");         sndHardland.amp(0.8);
  sndVictory   = new SoundFile(this, "victory.wav");            sndVictory.amp(0.8);

  // BGM (0.05 = 5% 볼륨, 효과음 대비 낮게 설정)
  sndIntro     = new SoundFile(this, "intro_b.mp3");            sndIntro.amp(0.01);
  sndGameBgm   = new SoundFile(this, "game_bgm.mp3");           sndGameBgm.amp(0.01);
  sndNightBgm  = new SoundFile(this, "game_bgm3.mp3");          sndNightBgm.amp(0.01);

  // 슬라임 스킨 4종 로드 (각 파일의 셀 크기: 100/200/300/400px)
  skinSheets[0] = loadImage("slime_grid_100.png");
  skinSheets[1] = loadImage("slime_grid_200.png");
  skinSheets[2] = loadImage("slime_grid_300.png");
  skinSheets[3] = loadImage("slime_grid_400.png");
  spriteSheet   = skinSheets[skinNum - 1]; // 기본 스킨 4번

  ballSheet = loadImage("BALL.png");       // 공 스프라이트 (2×2 그리드)
  goalImg   = loadImage("goal.png");       // 골대 이미지
  bg1       = loadImage("bg1.png");        // 낮 배경 이미지
  if (bg1 != null) bg1.resize(width, height);

  goalL = new Goal(true);                  // 왼쪽 골대 
  goalR = new Goal(false);                 // 오른쪽 골대
  hud   = new Hud();

  intro    = new IntroScreen();
  gameOver = new GameOverScreen();

  initClouds();  // 낮 배경용 픽셀 구름 6개 초기화
  initCrows();   // 밤 배경용 까마귀 6마리 초기화
  resetRound();  // 슬라임·공 첫 배치
}

// 라운드 시작 시 슬라임과 공을 초기 위치로 재배치
void resetRound() {
  spriteSheet = skinSheets[skinNum - 1];
  p1 = new Slime(width / 4,     groundY, false, spriteSheet); // P1: 왼쪽 1/4 지점
  p2 = new Slime(width * 3 / 4, groundY, true,  spriteSheet); // P2: 오른쪽 3/4 지점

  // 밤 모드: 이전과 다른 타입으로 순환 선택 / 낮 모드: 항상 일반 공
  if (nightMode) {
    ballType = (ballType + 1 + (int)random(3)) % 4; // 현재 타입 제외 3종 중 랜덤
  } else {
    ballType = 0;
  }
  ball = new Ball(width / 2, 200, ballType); // 공은 화면 중앙 상단에 생성
}

// 매 프레임 실행: BGM 관리 + 씬 분기
void draw() {
  // 인트로 BGM: scene 0에서만 루프 재생
  if (scene == 0) {
    if (!sndIntro.isPlaying()) sndIntro.loop();
  } else {
    if (sndIntro.isPlaying()) sndIntro.stop();
  }

  // 게임 BGM: 낮/밤 모드에 따라 다른 BGM, 다른 씬에서는 모두 정지
  if (scene == 1 && !nightMode) {
    if (!sndGameBgm.isPlaying())  sndGameBgm.loop();
    if (sndNightBgm.isPlaying())  sndNightBgm.stop();
  } else if (scene == 1 && nightMode) {
    if (!sndNightBgm.isPlaying()) sndNightBgm.loop();
    if (sndGameBgm.isPlaying())   sndGameBgm.stop();
  } else {
    if (sndGameBgm.isPlaying())   sndGameBgm.stop();
    if (sndNightBgm.isPlaying())  sndNightBgm.stop();
  }

  switch (scene) {
    case 0: intro.display();         break; // 인트로 화면
    case 1: playGame();              break; // 게임 플레이
    case 2: gameOver.display(2);     break; // P2 승리
    case 3: gameOver.display(1);     break; // P1 승리
  }
  mouseWasPressed = mousePressed; // 다음 프레임 클릭 에지 감지를 위해 저장
}

void playGame() {
  // 배경 
  if (nightMode) {
    drawNightGameBg();       // 절차적 야간 배경
    updateAndDrawCrows();    // 까마귀 이동+그리기
  } else {
    if (bg1 != null) { imageMode(CORNER); image(bg1, 0, 0, width, height); }
    else             { background(30, 100, 30); }
    updateAndDrawClouds();   // 구름 이동+그리기
  }

  // 골대
  goalL.display(goalImg);
  goalR.display(goalImg);

  // HUD
  hud.display();

  // landFrames 변화 감지용: update 전 값 저장
  int p1LandPrev = p1.landFrames;
  int p2LandPrev = p2.landFrames;

  // 슬라임 골대 충돌
  goalL.collideSlime(p1); goalL.collideSlime(p2);
  goalR.collideSlime(p1); goalR.collideSlime(p2);

  // 슬라임 물리 업데이트
  p1.update();
  p2.update();

  // 슬라임 겹침 방지 
  float minDist = p1.radius + p2.radius;
  float p1cy    = p1.y - p1.radius;
  float p2cy    = p2.y - p2.radius;
  float slimeDx = p2.x - p1.x;
  float slimeDy = p2cy - p1cy;
  float d       = sqrt(slimeDx*slimeDx + slimeDy*slimeDy);
  if (d < minDist) {
    float overlap = minDist - d;
    float push    = overlap * 0.5 + 1; // 1px 여유값: 딱 붙어서 떨림 방지
    float dir     = (slimeDx >= 0) ? 1 : -1;
    p1.x -= dir * push;
    p2.x += dir * push;
    p1.x = constrain(p1.x, p1.radius, width - p1.radius);
    p2.x = constrain(p2.x, p2.radius, width - p2.radius);
  }

  // 슬라임 그리기
  p1.display();
  p2.display();

  // 빠른 하강
  if (p1.landFrames > 0 && p1LandPrev == 0) ball.shockwave(p1);
  if (p2.landFrames > 0 && p2LandPrev == 0) ball.shockwave(p2);

  // 공 물리 업데이트 + 골대 충돌
  ball.update();
  goalL.collide(ball);
  goalR.collide(ball);

  // 공-슬라임 충돌 처리
  float d1   = dist(ball.x, ball.y, p1.x, p1.y - p1.radius);
  float d2   = dist(ball.x, ball.y, p2.x, p2.y - p2.radius);
  float minD = ball.radius + p1.radius;
  if (d1 < minD && d2 < minD) {
    ball.x  = (p1.x + p2.x) / 2;
    ball.y  = min(p1.y - p1.radius, p2.y - p2.radius) - ball.radius - 5;
    ball.vy = -16;
    ball.vx = 0;
  } else if (d1 < d2) {
    ball.checkCollision(p1);
  } else {
    ball.checkCollision(p2);
  }

  // 공 그리기
  ball.display();

  // 공/슬라임이 골대 안에 있으면 골대를 다시 위에 그림
  boolean anyInLG = (ball.x - ball.radius < goalL.mouthX() && ball.y > goalL.topY + G_POST && ball.y < groundY) ||
                    (p1.x - p1.radius < goalL.mouthX() && p1.y > goalL.topY) ||
                    (p2.x - p2.radius < goalL.mouthX() && p2.y > goalL.topY);
  boolean anyInRG = (ball.x + ball.radius > goalR.mouthX() && ball.y > goalR.topY + G_POST && ball.y < groundY) ||
                    (p1.x + p1.radius > goalR.mouthX() && p1.y > goalR.topY) ||
                    (p2.x + p2.radius > goalR.mouthX() && p2.y > goalR.topY);
  if (anyInLG) goalL.display(goalImg);
  if (anyInRG) goalR.display(goalImg);

  checkGoal();
}

// 골 판정: 왼쪽 골 → P2 득점 / 오른쪽 골 → P1 득점
void checkGoal() {
  if (goalL.scored(ball)) {
    p2Score++;
    if (p2Score >= WIN_SCORE) { scene = 2; p2Wins++; sndVictory.play(); return; }
    resetRound();
  } else if (goalR.scored(ball)) {
    p1Score++;
    if (p1Score >= WIN_SCORE) { scene = 3; p1Wins++; sndVictory.play(); return; }
    resetRound();
  }
}

// ═════════════════════════════════════════════
//  키 입력 처리
// ═════════════════════════════════════════════
void keyPressed() {
  // P1 (왼쪽 슬라임): WASD + L-Shift
  if (key=='a'||key=='A') p1.left      = true;
  if (key=='d'||key=='D') p1.right     = true;
  if (key=='w'||key=='W') p1.jump();
  if (key=='s'||key=='S') p1.downPress = true;  // 빠른 하강
  if (keyCode==SHIFT)     p1.dash();

  // P2 (오른쪽 슬라임): 방향키 + Enter
  if (keyCode==LEFT)  p2.left      = true;
  if (keyCode==RIGHT) p2.right     = true;
  if (keyCode==UP)    p2.jump();
  if (keyCode==DOWN)  p2.downPress = true;
  if (keyCode==ENTER) p2.dash();
}

void keyReleased() {
  if (key=='a'||key=='A') p1.left      = false;
  if (key=='d'||key=='D') p1.right     = false;
  if (key=='s'||key=='S') p1.downPress = false;

  if (keyCode==LEFT)  p2.left      = false;
  if (keyCode==RIGHT) p2.right     = false;
  if (keyCode==DOWN)  p2.downPress = false;
}

// ─────────────────────────────────────────────
//  야간 게임 배경
// ─────────────────────────────────────────────
void drawNightGameBg() {
  noStroke();
  // 하늘: 위(진한 남색) → 아래(어두운 녹색) 그라데이션
  for (int y = 0; y < height; y += 4) {
    float t = (float)y / height;
    fill((int)lerp(22,12,t), (int)lerp(28,18,t), (int)lerp(62,32,t));
    rect(0, y, width, 5);
  }

  // 별: randomSeed로 매 프레임 동일한 위치에, sin으로 반짝임 효과
  randomSeed(42);
  for (int i = 0; i < 55; i++) {
    float sx = random(width);
    float sy = random(height * 0.58);
    float tw = 0.55 + 0.45 * sin(frameCount * 0.04 + i * 1.9);
    fill(255, 255, 210, (int)(118 * tw));
    int gs = (int)random(1, 3) * 2;
    rect((int)(sx/gs)*gs, (int)(sy/gs)*gs, gs, gs);
  }

  // 초승달
  ellipseMode(CENTER); noStroke();
  fill(255, 252, 200, 215);
  ellipse(130, 92, 60, 60);
  fill(22, 28, 62);
  ellipse(145, 84, 50, 50);

  // 산 실루엣 2레이어
  drawPixelMountains(height - 210, 90, color(24, 28, 60), 0.012);
  drawPixelMountains(height - 168, 65, color(14, 36, 26), 1.005);

  // 나무숲 실루엣 2레이어
  drawPixelForest(height - 148, color(8, 25, 10), 301, 3);
  drawPixelForest(height - 102, color(5, 16,  7), 502, 5);

  // 지면
  noStroke();
  fill(12, 44, 12); rect(0, height - 98, width, 22);
  fill(8,  30,  8); rect(0, height - 78, width, 78);

  randomSeed(77);
  fill(20, 60, 18);
  for (int i = 0; i < 38; i++) {
    int gx = (int)(random(width) / 4) * 4;
    rect(gx,     height-99,  4,  9);
    rect(gx + 4, height-103, 4, 11);
    rect(gx + 8, height-98,  4,  7);
  }
}
