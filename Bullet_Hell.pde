ArrayList<Bullet> bullets;
ArrayList<Bullet> spreadBullets;
ArrayList<Bullet> bossBullets;
float bulletAngleRotation = 0;//for unique pattern
int spreadFireRate = 60;
int fireRate = 60;
int iFrameStart = 0;
//A class made for literall every enemy object in the game
class Bullet {
  float bulletX;
  float bulletY;
  float bulletAngle;
  float bulletSpeed;
  float bulletSize;
  boolean isSpecial; //if special then unique bullet pattern use for boss&elites if not then just shoot straight out for minions
  //Construct
  Bullet(float x, float y, float angle, float speed, float size, boolean special) {
    bulletX = x;
    bulletY = y;
    bulletAngle = angle;
    bulletSpeed = speed;
    bulletSize = size;
    isSpecial = special;
  }
  //method movement,... very basic
  void update() {
    if (!isSpecial) {
      bulletY += bulletSpeed;
    } else {
      bulletX += cos(bulletAngle)*bulletSpeed;
      bulletY += sin(bulletAngle)*bulletSpeed;
    }
  }
  //method display, to draw the object on screen. Basic
  void display() {
    HIT();
    blendMode(ADD);
    noStroke();
    fill(255, 57, 57);
    circle(bulletX, bulletY, bulletSize);
    fill(252, 199, 199);
    circle(bulletX, bulletY, bulletSize-bulletSize/10);
    blendMode(NORMAL);
  }
  //method that detect when bullet go offscreen, made as a function helper to put in another method to remove the bullet from the arraylist when the bullet go offscreen
  boolean offScreen() {
    return bulletX < 0 || bulletX > width*2/3 || bulletY < 0 || bulletY > height;
  }
  //Collision checker method for enemy's bullet that when player get hit with the bullet, they lose live
  //Also graze mechanic when the player stay near the bullet that increase their score over time. This mechanic is also a core mechanic of bullet hell game.
  void HIT() {
    if (dist(bulletX, bulletY, centerX, centerY) < 35 && mcLives > 0) {
      score += 10;
    }

    if (dist(bulletX, bulletY, centerX, centerY) < 7 && (millis() - iFrameStart > 1500)) {
      println(mcLives);
      mcLives--;
      Bomb = true;
      iFrameStart = millis();
    }
    if (millis() - iFrameStart < 2000) {
      iFrameAlpha = 100;
    } else iFrameAlpha = 255;
  }
}
//In space shooting game, whenever the bomb is activated, all bullets inside the radius of the bomb got removed
//For some reason, bossBullet which is d.bullet isnt in here, just minion and elite but the bomb still remove boss bullet. But if it works, it works
void eraseBullets() {
  float bombRadius = ultRadius;
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    if (dist(ultX, ultY, b.bulletX, b.bulletY) < bombRadius) {
      bullets.remove(i);
    }
  }
  for (int i = spreadBullets.size() - 1; i >= 0; i--) {
    Bullet c = spreadBullets.get(i);
    if (dist(ultX, ultY, c.bulletX, c.bulletY) < bombRadius) spreadBullets.remove(i);
  }
}
//create spiral bullet patern for boss
void spawnSpiralBullets() {
  float speed;
  float angle;
  for (int i = 0; i < 18; i++) {
    if (bosshp > 200) {
      bossFireRate = 5;
      speed = 3;
      angle = bulletAngleRotation + radians(i * 102);
    } else {
      speed = 3;
      bossFireRate = 5;
      angle = bulletAngleRotation + radians(i * 101);
    }
    //desperation phase
    bullets.add(new Bullet(bossX, bossY, angle, speed, 20, true));
  }
}
//game over screen
void gameOverScreen() {
  background(0);
  fill(255, 0, 0);
  textSize(200);
  textAlign(CENTER, CENTER);
  text("YOU DIED", width / 2, height / 2);
  textSize(24);
  text("GET GOOD", width / 2, height / 2 + 100);
  text("also your scores: " + score, width / 2, height / 2 + 150);
}
//game won screen
void victoryScreen() {
  background(255);
  fill(255, 255, 0);
  textSize(200);
  textAlign(CENTER, CENTER);
  text("YOU WON", width / 2, height / 2);
  textSize(24);
  text("GET FLASHBANGED!!!", width / 2, height / 2 + 100);
  text("also your scores: " + score, width / 2, height / 2 + 150);
}
