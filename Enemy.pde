/*
 * Default Enemy:
 ** Flies toward the location of the user
 ** Does not shoot
 ** Blows up upon hitting a wall
 */

class Enemy
{
  PImage ship;
  float x;
  float y;
  int speed;

  public Enemy(float x, float y, int s)
  {
    ship=loadImage("Enemy.png");
    this.x=x;
    this.y=y;
    speed=s;
  }

  void s()
  {
    if (x+1<shipX)
    {
      x+=speed;
    }
    else if (x-1>shipX)
    {
      x-=speed;
    }
    if (y+1<shipY)
    {
      y+=speed;
    }
    else if (y-1>shipY)
    {
      y-=speed;
    }
    image(ship, x, y);
  }

  float getX()
  {
    return x;
  }

  float getY()
  {
    return y;
  }

  boolean fire()
  {
    return false;
  }
  
  void collision(char dir)
  {
    return;
  }
}

