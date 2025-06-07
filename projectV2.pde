//48776254 Minh An Le
//This game take inspiration from touhou, a bullet hell game basically a spaceshooting game but with matrix of bullets from the enemies, very hard to dodge.
//The final goal of this game is to defeat the lackeys of the boss then beat the boss.
//When a mob die, they will drop scores box that give scores, this game can be competitive by competing each other scores and shortest amount of time to finish the run.
//The character move with mouse, Z to shoot and X to bomb.
//Note: the character's hitbox is the red dot, not the entire character, incase teacher think I didnt apply collision for my character. Why red dot? it is signature mechanic of bullet hell game.

int nStars = 100;
int nLines = 30;
float[] starX, starY, starSpeed;
float[] lineX, lineY, lineSpeed;
int mcLives = 2;
boolean Bomb = true;
float radius = 0;
float Angle = 0;
float centerX;
float centerY;
float booletX = -3000;
float booletY = -3000;
int booletAlpha = 255;
float booletR = 40;
int iFrameAlpha = 255;
boolean shoot = false;
boolean isZPressed = false;
boolean ulti = false;
boolean ultiAttack = true;
float ultDmg = 1;
float ultRadius;
float ultStartTime = 0;
float ultX = 0;
float ultY = 0;
float ultSize = 0;
int score = 0;

void setup() {
  size(1200, 900, P2D); //P2D is necessary for smoother experience because a lot of blended bullets on screen = lags and stutters
  //enemy setup
  bossX = width/3;
  bossY = -bossR;
  ultRadius = width/3;
  bossDropX = new float[nBossDrop];
  bossDropY = new float[nBossDrop];
  helpConstructDrops(bossDropX, bossDropY, nBossDrop, bossX, bossY, 200);
  //instead of initialize the entire army in one loop, i seperate half of them to different loop to control them differently, as seen in the game, half of the minion move left to right while other half move right to left
  for (int i = 0; i < 12; i++) {
    minions[i] = new Minion(-500+i*50, -500+i*25, 1, 1, 1);
  }
  for (int i = 12; i < 24; i++) {
    minions[i] = new Minion(1300+(i-12)*-50, -500+(i-12)*25, -1, 1, 2);
  }
  for (int i = 0; i < 2; i++) {
    elites[i] = new Elite(100+100*i, -200+150*i, 1, 2.4);
  }
  for (int i = 2; i < 4; i++) {
    elites[i] = new Elite(700-100*(i-2), -200+150*(i-2), 1, 5);
  }
  bullets = new ArrayList<Bullet>();
  spreadBullets = new ArrayList<Bullet>();
  bossBullets = new ArrayList<Bullet>();
  //scene setup
  starX = new float[nStars];
  starY = new float[nStars];
  starSpeed = new float[nStars];
  lineX = new float[nLines];
  lineY = new float[nLines];
  lineSpeed = new float[nLines];

  for (int i = 0; i < nStars; i++) {
    starX[i] = random(width-width/3);
    starY[i] = random(height);
    starSpeed[i] = random(0.5, 1.5);
  }
  for (int i = 0; i < nLines; i++) {
    lineX[i] = random(width-width/3);
    lineY[i] = random(height);
    lineSpeed[i] = random(5, 30);
  }
}

void draw() {
  //scene making
  background(0);
  fill(255);
  noStroke();
  for (int i = 0; i < nStars; i++) {
    circle(starX[i], starY[i], 3);
    starY[i] += starSpeed[i];
    if (starY[i] > height) {
      starY[i] = 0;
      starX[i] = random(width-width/3);
    }
  }
  stroke(255, 200);
  strokeWeight(2);
  for (int i = 0; i < nLines; i++) {
    line(lineX[i], lineY[i], lineX[i], lineY[i] + 15 + lineSpeed[i]);
    lineY[i] += lineSpeed[i];
    if (lineY[i] > height) {
      lineY[i] = 0;
      lineX[i] = random(width-width/3);
      lineSpeed[i] = random(5, 30);
    }
  }
  //character making
  fill(0, 153, 252, iFrameAlpha);
  centerX = constrain(mouseX, 0, width-width/3);
  centerY = mouseY;
  radius = 30;
  strokeWeight(2);
  stroke(0, 246, 252, 150);
  drawHexagon(radius, centerX, centerY);
  stroke(255, 0, 0);
  fill(255);
  circle(centerX, centerY, 10);
  //circle rotating
  fill(0, 246, 252);
  noStroke();
  if (ulti == false) {
    drawRotatingIcicles(55, 20, centerX, centerY, 0.12);
  }

  //boolet shoot
  if (isZPressed == true) {
    if (shoot == false) {
      booletAlpha = 255;
      booletX = centerX;
      booletY = centerY + 20;
      shoot = true;
    }
  }
  if (shoot == true) {
    booletY -= 150;
    fill(3, 215, 255, booletAlpha);
    for (int i = 0; i <= 2; i++) {
      ellipse(booletX - radius/i, booletY, 8, booletR);
    }
    for (int i = 0; i <= 2; i++) {
      ellipse(booletX + radius/i, booletY, 8, booletR);
    }
    if (booletY < 0) {
      shoot = false;
      booletX = -5;
    }
  }
  //enemy making
  for (int i = 0; i < minions.length; i++) {
    minions[i].display();
    minions[i].update();
    minions[i].shoot();
  }
  if (Enemykilled >= 18) {
    for (int i = 0; i < elites.length; i++) {
      elites[i].display();
      elites[i].update();
      elites[i].shootSpread();
    }
  }
  //Boss making
  if (Enemykilled >= 25) {
    drawBoss();
    BossAngle += 1.5;
  } else {
  }

  //Enemy Bullet shoot
  for (int i = spreadBullets.size() - 1; i >= 0; i--) {
    Bullet c = spreadBullets.get(i);
    c.update();
    c.display();
    if (c.offScreen()) spreadBullets.remove(i);
  }
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.update();
    b.display();
    if (b.offScreen()) {
      bullets.remove(i);
    }
  }
  for (int i = bossBullets.size() - 1; i >= 0; i--) {
    Bullet d = bossBullets.get(i);
    d.update();
    d.display();
    if (d.offScreen()) bossBullets.remove(i);
  }
  //ulti
  if (ulti == true) {
    eraseBullets();
    fill(0, 176, 255, 100);
    noStroke();
    blendMode(ADD);
    drawHexagon(width/4 + 5, ultX, ultY);
    drawHexagon(width/4, ultX, ultY);
    fill(36, 235, 255, 255);
    drawRotatingIcicles(ultRadius, ultSize, ultX, ultY, 0.04);
    drawRotatingIcicles(ultRadius + 5, ultSize, ultX, ultY, 0.04);
    blendMode(NORMAL);
    ultRadius -= 7;
    ultSize += 7;
    if (ultSize > 180) {
      ultSize = 180;
    }
    if (ultRadius < 150) {
      ultRadius = 150;
    }
    if (millis() - ultStartTime > 2500) {
      ulti = false;
      ultRadius = width/3;
      ultSize = 0;
    }
  }
  //Board
  scoreBoard();
  if (mcLives < 0) gameOverScreen();
  if (bosshp < 0 && (millis() - bossDiedTime > 4000)) victoryScreen();
}



//Press Z to shoot, X to bomb
void keyPressed() {
  if ((key == 'z' || key == 'Z')) {
    isZPressed = true;
  }
  if ((key == 'x' || key == 'X') && ulti == false && Bomb == true) {
    ulti = true;
    Bomb = false;
    ultX = centerX;
    ultY = centerY - radius * 13;
    ultStartTime = millis();
  }
}
void keyReleased() {
  if (key == 'Z' || key == 'z') {
    isZPressed = false;
    shoot = false;
  }
}
//Hexagon draw function make life easier.
void drawHexagon(float Rad, float x, float y) {
  pushMatrix();
  translate(x, y);
  quad(-Rad, -Rad/2, 0, -Rad, Rad, -Rad/2, 0, 0);
  quad(0, 0, 0, Rad, -Rad, Rad/2, -Rad, -Rad/2);
  quad(0, 0, Rad, -Rad/2, Rad, Rad/2, 0, Rad);
  popMatrix();
}

//this function make the rotating Icicles that rotate around the hexagon which is the player
void drawRotatingIcicles(float icyrad, float icysize, float centerX, float centerY, float speed) {
  for (int i = 0; i <= 6; i++) {
    float angleRotation = Angle + radians(60) * i;
    float orbitX = centerX + cos(angleRotation) * icyrad;
    float orbitY = centerY + sin(angleRotation) * icyrad;
    float angleToCenter = atan2(centerY - orbitY, centerX - orbitX);
    pushMatrix();
    translate(orbitX, orbitY);
    rotate(angleToCenter);
    quad(icysize, 0, 0, icysize/4, -icysize, 0, 0, -icysize/4);
    popMatrix();
  }
  Angle += speed;
}
//ScoreBoard with ur character informations life lives, bomb and scores
void scoreBoard() {
  stroke(0, 105, 240);
  strokeWeight(3);
  fill(0, 18, 41);
  rect(width-width/3, 0, width-width/3, height);
  fill(82, 222, 255);
  textSize(125);
  text(score, 820, 125);
  textSize(75);
  text("LIVES", 820, 225);
  for (int i = 0; i < mcLives; i++) {
    drawHexagon(30, 1050 + i*75, 200);
  }
  text("BOMB", 900, 325);
  if (Bomb == true) {
    fill(82, 222, 255);
  } else fill(82, 222, 255, 100);
  drawIce(1000, 550, 175);
}
//simple function to draw a diamond shaped object
void drawIce(float x, float y, float radius) {
  pushMatrix();
  translate(x, y);
  quad(0, -radius, +radius/2, 0, 0, +radius, -radius/2, 0);
  popMatrix();
}
