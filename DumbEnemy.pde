/*
 * Dumb Enemy:
 ** Flies straight down.
 ** Does not shoot
 ** Blows up upon hitting a wall
 */

class DumbEnemy extends Enemy
{
  
  public DumbEnemy(float x, float y,int s)
  {
    super(x,y,s);
    ship=loadImage("DumbEnemy.png");
  }
  
  void s()
  {
    y+=speed;
    image(ship,x,y);
  }
}
