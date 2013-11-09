/*
 * Smart Enemy:
 ** Flies toward the location of the user
 ** Shoots after a particular time interval
 ** Will not run into walls
 */

class SmartEnemy extends Enemy
{
  int fireRate;
  int count;

  public SmartEnemy(float x, float y, int s, int r)
  {
    super(x, y, s);
    ship=loadImage("SmartEnemy.png");
    fireRate=r;
    count=0;
  }

  boolean fire()
  {
    if (millis()>=count)
    {
      count=millis()+fireRate;
      return true;
    }
    else
      return false;
  }

  void collision(char dir)
  {
    if (dir=='l')
      x+=speed;
    else if (dir=='r')
      x-=speed;
    else if (dir=='t')
      y+=speed;
    else if (dir=='b')
      y-=speed;
  }
}

