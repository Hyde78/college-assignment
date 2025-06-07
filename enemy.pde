float bossR = 120;
float BossAngle = 0;
float bossX, bossY;
float TheRadiantAlpha = 100;
float TheRadiant = 100;
float TheRadiantRadius = 280;
boolean TheRadientStatus = true;
boolean BossEntrance = true;
int bossFireRate = 5;
float bosshp=600;
int nBossDrop = 50;
float[] bossDropX, bossDropY;
int bossDiedTime = 0;
int Enemykilled = 0; //when almost all 24 minions are killed, the elites will emerge.
Minion[] minions = new Minion[24];
Elite[] elites = new Elite[4];
//minions
class Minion {
  float Mhp = 10;
  int toggle = 1;
  float fireposX;
  float fireposY;
  float Yspeed;
  float Xspeed;
  int startTime;
  boolean hit = false;
  int alpha = 255;
  int nDrop = 3;
  float[] dropX, dropY;
  float shootAngle;
  Minion(float Xpos, float Ypos, float Xspd, float Yspd, float angle) {
    shootAngle = angle;
    fireposX = Xpos;
    fireposY = Ypos;
    Xspeed = Xspd;
    Yspeed = Yspd;
    startTime = millis();
    dropX = new float[nDrop];
    dropY = new float[nDrop];
    helpConstructDrops(dropX, dropY, nDrop, fireposX, fireposY, 50);
  }
  //couples of method/functions that help animating the fire
  void HelpdrawFires(int FireColor, float fireposX, float fireposY, float Xradius, float Yradius) {
    noStroke();
    fill(255, FireColor, 0, alpha);
    ellipse(fireposX, fireposY, Xradius, Yradius);
  }

  void drawFires1() {
    HelpdrawFires(100, fireposX, fireposY, 25, 50);
    HelpdrawFires(200, fireposX, fireposY+10, 15, 30);
  }

  void drawFires2() {
    HelpdrawFires(100, fireposX, fireposY-2, 25, 55);
    HelpdrawFires(200, fireposX, fireposY+10-2, 15, 35);
  }

  void drawFires3() {
    HelpdrawFires(100, fireposX, fireposY+4, 25, 45);
    HelpdrawFires(200, fireposX, fireposY+14, 15, 25);
  }

  void Fire() {
    blendMode(ADD);
    if (toggle == 1) {
      drawFires1();
      toggle = 2;
    } else if (toggle == 2) {
      drawFires2();
      toggle = 3;
    } else {
      drawFires3();
      toggle = 1;
    }
    blendMode(NORMAL);
  }
  void display() {
    if (Mhp == 0) Enemykilled++;
    if (Mhp > 0) {
      Fire();
    } else {
      fireposX = -1000;
      Mhp =-1;
      dropItems(dropX, dropY, nDrop);
    }
    Mhp = checkHit(Mhp, fireposX, fireposY, 80);
  }
  void update() {
    if (millis() - startTime >= 9500) {
      Xspeed = 0;
      Yspeed = 0;
    }
    if (Mhp > 0) {
      fireposX += Xspeed;
      fireposY += Yspeed;
    }
    //another funny bug, if the conditional Mhp == 0 this thing will construct the drop at exact Xpos where I tp the minion of screen, which make a buggy mess
    //but it seem if the conditional Mhp == 1, this thing will construct the drop right before it dies which is 1hp, so at the moment it die, the drop will spawn at the exact pos it died
    //but it seem again when i make Mhp =-1 after the Mhp fall to 0 it make Mhp == 0 condition of this thing valid, NEW TECH
    if (Mhp == 0) {
      helpConstructDrops(dropX, dropY, nDrop, fireposX, fireposY, 50);
    }
  }
  //every firerate, the minion will fire once that add a new object into the arraylist
  void shoot() {
    if (frameCount % fireRate == 0) {
      bullets.add(new Bullet(fireposX, fireposY, shootAngle, 3, 20, true));
    }
  }
}
//elite
class Elite {
  float Ehp = 100;
  float ElitePosX;
  float ElitePosY;
  float EliteSize = 150;
  float EliteSpeed;
  float bulletAngle;
  float alpha = 255;
  int startDuration = 0;
  int startTime = 0;
  int toggle = 0;
  int nDrop = 8;
  float[] dropX, dropY;
  Elite(float x, float y, float spd, float angle) {
    ElitePosX = x ;
    ElitePosY = y ;
    EliteSpeed = spd;
    bulletAngle = angle;
    startTime = millis();
    if (Enemykilled >= 18) {
      startDuration = millis();
    }
    dropX = new float[nDrop];
    dropY = new float[nDrop];
    helpConstructDrops(dropX, dropY, nDrop, ElitePosX, ElitePosY, 50);
  }
  //couples of method that help animating whatever this look like, a hot north star??, idk i thought it look cool when i was making it
  void helpDrawEllipse(int i) {
    noStroke();
    pushMatrix();
    translate(ElitePosX, ElitePosY);
    rotate(radians(45)*i);
    ellipse(0, 0, EliteSize, EliteSize/30);
    popMatrix();
  }
  void drawEllipse() {
    if (toggle == 0) {
      fill(248, 254, 64, alpha);
      helpDrawEllipse(0);
      helpDrawEllipse(2);
      toggle = 1;
    } else if (toggle == 1) {
      fill(252, 49, 38, alpha);
      helpDrawEllipse(3);
      helpDrawEllipse(1);
      toggle = 0;
    }
  }
  void display() {
    if (Ehp == 0 ) {
      Enemykilled++;
    }
    if (Ehp > 0) {
      drawEllipse();
    } else {
      ElitePosX = -1000;
      Ehp = -1;
      dropItems(dropX, dropY, nDrop);
    }
    Ehp = checkHit(Ehp, ElitePosX, ElitePosY, EliteSize);
  }
  void update() {
    if (eliteEntrance()) EliteSpeed = 0;
    if (Ehp > 0) {
      ElitePosY += EliteSpeed;
    }
    if (Ehp == 0 ) {
      helpConstructDrops(dropX, dropY, nDrop, ElitePosX, ElitePosY, 50);
    }
  }
  //same as shoot method on the minion, but this time, it shoots many bullets at once
  void shootSpread() {
    if (frameCount % spreadFireRate == 0) {
      for (float i = bulletAngle; i <= bulletAngle+6; i++) {
        float angle = radians(i * 15);
        spreadBullets.add(new Bullet(ElitePosX, ElitePosY, angle, 3, 25, true));
      }
    }
  }
}
//boss, dont need class because theres only one boss
//couple of functions to animate the boss
void drawRadiant() {
  blendMode(ADD);
  circle(0, 0, TheRadiantRadius);
  if (TheRadientStatus == true) {
    TheRadiantRadius += 0.5;
    TheRadiant +=1.5;
    if (TheRadiantRadius >= 320) {
      TheRadientStatus = false;
    }
  } else {
    TheRadiant -= 1.5;
    TheRadiantRadius -= 0.5;
    if (TheRadiantRadius <= 280) {
      TheRadientStatus = true;
    }
  }
}


void drawBoss() {
  if (bosshp > 0) {
    bulletAngleRotation += (radians(30));
    hpBar();
    bosshp = checkHit(bosshp, bossX, bossY, 200);
    blendMode(ADD);
    fill(255, 255, TheRadiant, TheRadiantAlpha);
    pushMatrix();
    translate(bossX, bossY);
    noStroke();
    drawRadiant();
    strokeWeight(5);
    stroke(255, 0, 0);
    fill(255, 136, 8);
    rotate(BossAngle);
    triangle(0, 0, 0, -bossR, +bossR, +bossR/2);
    triangle(0, 0, 0, -bossR, -bossR, +bossR/2);
    triangle(0, 0, -bossR, +bossR/2, +bossR, +bossR/2);
    popMatrix();
    if (frameCount % bossFireRate == 0) {
      spawnSpiralBullets();
    }
    if (BossEntrance == true) {
      bossY++;
      if (bossY == height/4) {
        BossEntrance = false;
      }
    }
    blendMode(NORMAL);
  } else {
    dropItems(bossDropX, bossDropY, nBossDrop);
    bosshp = -1;
    bossX = -1000;
  }
  if (bosshp == 0) {
    helpConstructDrops(bossDropX, bossDropY, nBossDrop, bossX, bossY, 200);
    bossDiedTime = millis();
  }
}
//boss HP bar
void hpBar() {
  noStroke();
  fill(255, 0, 0);
  rect(100, 25, 600, 25);
  fill(0, 255, 0);
  rect(100, 25, bosshp, 25);
}

//functions to construct/setup drops for boss and minions
void helpConstructDrops(float[] dropX, float[] dropY, int nDrop, float posX, float posY, float dropRange) {
  for (int i = 0; i < nDrop; i++) {
    dropX[i] = random((posX - dropRange), (posX + dropRange));
    dropY[i] = random((posY - dropRange), (posY + dropRange));
  }
}
void dropItems(float[] dropX, float[] dropY, int nDrop) {
  blendMode(ADD);
  fill(255, 111, 190);
  for (int i = 0; i < nDrop; i++) {
    square(dropX[i], dropY[i], 25);
    dropY[i] += 3;
    if (dist(dropX[i], dropY[i], centerX, centerY) < radius + 70) {
      score += 1000;
      println(score);
      dropX[i] = -2000;
    }
  }
  blendMode(NORMAL);
}
//collision check for enemy
float checkHit(float hp, float entityX, float entityY, float entitySize) {
  if (dist(booletX, booletY, entityX, entityY) < entitySize) {
    booletX = -50; //if bulletpos not changed after hit, the booletX will still be in the same place even after the alpha = 0 make conditions trigger infinitely.
    hp--;
    println(hp);
    shoot = false;
  }
  if (dist(ultX, ultY, entityX, entityY) < width/4 && ulti == true) {
    println(hp);
    hp -= ultDmg;
  }
  return hp;
}
float EliteEntranceY = -200;
//the timing to make the Elite appear after a while, I could use millis() but anyway..
boolean eliteEntrance() {
  if (Enemykilled >= 18 && EliteEntranceY < 200) {
    EliteEntranceY += 0.3;
    println( EliteEntranceY);
  }
  return EliteEntranceY  >= 200;
}
