class Bomb
{
  float x;
  float y;
  PImage img;
  int rad;
  int al;
  
  Bomb(float x,float y)
  {
    this.x=x;
    this.y=y;
    img=loadImage("Bomb.png");
    rad=10;
    al=128;
  }
  
  void s()
  {
    y-=10;
    image(img,x,y);
  }
  
  float getX()
  {
    return x;
  }
  
  float getY()
  {
    return y;
  }
  
  void detonate()
  {
    //Possible explosion ring?
    //fill(242,104,17,al);
    //ellipse(x,y,rad,rad);
    //rad+=2;
    //al-=5;
    //Detonation animation to be implemented below
  }
}
