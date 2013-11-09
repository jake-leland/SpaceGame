class Laser
{
  float x,y;
  PImage img;
  boolean friendly;
  
  Laser(float x, float y,boolean f)
  {
    this.x=x;
    this.y=y;
    friendly=f;
    if(friendly)
      img=loadImage("greenLaserRay.png");
    else
      img=loadImage("redLaserRay.png");
  }
  
  void s()
  {
    if(friendly)
      y-=10;
    else
      y+=10;
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
}
