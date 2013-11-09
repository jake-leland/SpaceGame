// Jake Leland
// Matthew Baker

/*
 * This code is not complete, and we know it's kind of messy,
 * but there should not be any major bugs.

 * This game was developed to be played using an Xbox Kinect,
 * but there is a debug mode that enables the user to play without one.
 * This makes the game significantly easier, but you get the idea.

 * The game uses 2 external libraries:
 ** SimpleOpenNI - this is for Kinect interface (code.google.com/p/simple-openni)
 ** gifAnimation - this is for playing gifs (extrapixel.ch/processing/gifAnimation)
 */

// SELECT MAP:
// (there must be a map in the /data folder with that number)
int game = 1;

// If playing without a Kinect, set debug to TRUE
boolean debug = true;

import ddf.minim.*;
import java.util.*;
import java.io.*;
import SimpleOpenNI.*;
import gifAnimation.*;

SimpleOpenNI kinect;
boolean user;
int userId;
String s;
User u;

PImage ship;
PImage psi;
ArrayList<Laser> lasers;
ArrayList<Enemy> enemies;
ArrayList<Laser> enemyLasers;
ArrayList<Bomb> bombs;
Thread t;
boolean startup;
PFont font;
int level;
int score;
int scoreAtLevelStart;
int lives;
Minim m;
AudioSnippet sound;
AudioSnippet explosion;
AudioSnippet bomb;
boolean gameOver;
PImage blowup;
int shipX;
int shipY;
boolean dead;
boolean win;

// MAP SETUP
String[] lines;
char[][] map;
int stepCount;
boolean started;
boolean paused;
boolean prevPaused;
PImage imgtexture;

// Arguments
String argsString;
String[] args;

String[] bgStrings;
int[] bg = new int[3];

int scrollAmt;
float nextFrame;

//speed of .5 = 1 scroll per 2 frames
//speed of 1 = 1 scroll per frame
float speed = 1;
//____________

ArrayList<Gif> anims;
ArrayList<PVector> ex;
Bomb b;
Gif bombExp;

// MUSIC SETUP
AudioPlayer song1;
AudioPlayer song2;
AudioPlayer victory;
int currentTrack;
String[] songs = {
  "Silence.wav", 
  "StartOfStage.mp3", 
  "Battle Theme.mp3", 
  "Samus Theme.mp3", 
  "Final Destination.mp3"
};
int prevTrack;
//____________

void setup()
{
  u = new User();
  smooth();
  ellipseMode(CORNER);
  rectMode(CORNER);
  size(1024, 768);
  ship=loadImage("player.gif");
  psi=loadImage("psi.gif");
  font=loadFont("Emulogic-24.vlw");
  textFont(font, 24);
  textAlign(CENTER, CENTER);
  level=1;
  score=0;
  scoreAtLevelStart=score;
  lives=3;
  imageMode(CENTER);
  m=new Minim(this);
  sound=m.loadSnippet("laser.wav");
  explosion=m.loadSnippet("explosion.wav");
  bomb=m.loadSnippet("bombFireAndExplode.mp3");
  blowup=loadImage("explosion.png");
  gameOver=false;
  imgtexture=loadImage("rock_texture.bmp");
  reset();
  if (lines.length<12)
  {
    println("Map too small.");
    text("Error:\nMap too small.\nMust be at least 12 rows.", width/2, height/2);
    stop();
  }

  ex=new ArrayList<PVector>();
  anims=new ArrayList<Gif>();
  bombExp=new Gif(this, "detonation.gif");

  if (!debug)
  {
    kinect = new SimpleOpenNI(this);

    kinect.enableDepth();
    kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

    kinect.setMirror(true);

    user = false;
  }
  else
    user = true;

  prevTrack=1;
  currentTrack=0;
  victory=m.loadFile("win.mp3");
}

void reset()
{
  if (!new File(dataPath(game + "-"+level+".txt")).exists())
  {
    if (new File(dataPath(game + "-"+(level-1)+".txt")).exists())
    {
      println("YOU WIN");
      gameOver(true);
    }
    else
    {
      println("Bad file.");
      text("Error:\nBad file.", width/2, height/2);
      stop();
    }
  }
  else
  {
    System.out.println("GOOD FILE");
    lines = loadStrings(game + "-" +level+ ".txt");
    argsString = lines[0]; 
    println(argsString);
    args = argsString.split(" ");
    bgStrings = args[0].split(",");
    for (int i=0;i<bgStrings.length;i++)
      bg[i] = Integer.parseInt(bgStrings[i]);
    speed = Float.parseFloat(args[1]);
    stepCount = 0;
    started = false;
    paused = false;
    prevPaused = false;
    map = new char[12][16];
    scrollAmt = 0;
    lasers=new ArrayList<Laser>();
    enemies=new ArrayList<Enemy>();
    enemyLasers=new ArrayList<Laser>();
    bombs=new ArrayList<Bomb>();
    background(bg[0], bg[1], bg[2]);

    currentTrack=Integer.parseInt(args[2]);
    if (currentTrack!=prevTrack)
    {
      loadSong();
    }
  }
}

void keyPressed()
{
  if (debug)
    event();
}

void event()
{
  if (keyCode == UP)
  {
    if (speed<1)
      speed+=.1;
    speed = round(speed*10.0)/10.0;
    println(speed);
  }
  else if (keyCode == DOWN)
  {
    if (speed>.1)
      speed-=.1;
    speed = round(speed*10.0)/10.0;
    println(speed);
  }
  //Not yet working
  //  else if (keyCode == SHIFT)
  //  {
  //    b = new Bomb(shipX, shipY);
  //  }
  else
  {
    if (gameOver)
      exit();
    else
    {
      if (user)
      { 
        if (!started)
        {
          dead = false;
          started = true;
          loadMap();
        }
        else
        {
          paused = !paused;
          prevPaused = false;
        }
        initialize();
      }
    }
  }
}

void initialize()
{
  nextFrame = frameCount+(1/speed);
}

void loadMap()
{
  println("");
  for (int r=0; r<12; r++)
  {
    String line = String.format("%-16s", lines[lines.length-12+r-stepCount]);
    for (int c=0; c<16; c++)
    {
      map[r][c] = line.charAt(c);
      //print(map[r][c]);
    }
    //println();
  }
  stepCount++;
  scrollAmt=0;
}

void draw()
{
  IntVector userList = null;
  if (!debug)
  {
    userList = new IntVector();
    kinect.update();
    kinect.getUsers(userList);
    if (userList.size()>0)
    {
      userId = userList.get(0);
      u.updateId(userId);
      user=true;
    }
    else
      user=false;
  }
  textAlign(CENTER, CENTER);
  if (user)
  {
    if (debug || kinect.isTrackingSkeleton(userId))
    {
      if (!debug)
      {
        u.update();
        if (u.getHandDist()<150 && !u.isHitched())
        {
          event();
          u.hitch();
        }
        else if (u.getHandDist()>200)
        {
          u.unHitch();
        }
      }
      if (started)
      {
        if (!paused)
        {
          if (stepCount+11<lines.length)
          {
            if (!debug)
            {
              //int userId = userList.get(0);
              println(u.getX() + " " + u.getZ());
              shipX = round(map(u.getX(), -500, 500, 0, width));
              shipY = round(map(u.getZ(), 750, 1750, 0, height));
              if (XOR(((u.getRHand()-u.getLHand())>0), ((u.getLastRHand()-u.getLastLHand())>0)))
                fire();
            }
            else
            {
              shipX = mouseX;
              shipY = mouseY;
            }
            if (scrollAmt>=64)
              loadMap();
            if (frameCount >= nextFrame)
            {
              nextFrame = nextFrame+(1.0/speed);
              scroll();
            }
            background(bg[0], bg[1], bg[2]);
            displayMap();
            if (!dead)
            {
              image(ship, shipX, shipY);

              for (int i=0; i<lasers.size(); i++)
              {
                Laser k = lasers.get(i);
                if (k.getY()>-45)
                {
                  k.s();
                }
                else
                  lasers.remove(i);
              }
              for (int i=0; i<enemies.size(); i++)
              {
                Enemy e = enemies.get(i);
                e.s();
                if (e instanceof SmartEnemy)
                {
                  //Shoot
                  e=(SmartEnemy)e;
                  if (e.fire())
                    enemyLasers.add(new Laser(e.getX(), e.getY(), false));
                }
                if (e.getY()>height)
                  enemies.remove(i);
                for (int k=0; k<lasers.size(); k++)
                {
                  Laser shot = lasers.get(k);
                  if (shot.getX()>=e.getX()-e.ship.width/2 && shot.getY()>=e.getY()-e.ship.height/2 && shot.getX()<e.getX()+e.ship.width/2 && shot.getY()<e.getY()+e.ship.height/2)
                  {
                    enemies.remove(i);
                    //Explosion animation
                    lasers.remove(k);
                    score++;
                    explode(round(e.getX()), round(e.getY()));
                  }
                }
                //Collision between ship and enemy
                if (shipX>e.getX()-ship.width/2 && shipX<=e.getX()+ship.width/2 && shipY>e.getY()-ship.height/2 && shipY<+e.getY()+ship.height/2)
                {
                  explode(shipX, shipY);
                  die();
                  break;
                }
              }
              //Collision between ship and enemy laser
              for (int k=0; k<enemyLasers.size(); k++)
              {
                Laser shot = enemyLasers.get(k);
                if (shot.getX()>=shipX-ship.width/2 && shot.getY()>=shipY-ship.height/2 && shot.getX()<shipX+ship.width/2 && shot.getY()<shipY+ship.height/2)
                {
                  explode(shipX, shipY);
                  die();
                  break;
                }
                else
                  shot.s();
              }
            }
            stroke(255);
            fill(0);
            rect(0, 0, width-1, 64);
            fill(255);
            textAlign(CORNER, CENTER);
            text("Score: "+score, 12, 32);
            text("Level "+level, 300, 32);
            text("Ships: "+lives, 600, 32);
          }
          else
          {
            level++;
            reset();
            enemies.clear();
            scoreAtLevelStart=score;
          }
        }
        if (paused && !prevPaused)
        {
          noStroke();
          fill(0, 0, 0, 200);
          rect(0, 0, width, height);
          fill(255);
          textAlign(CENTER, CENTER);
          text("PAUSED", width/2, height/2);
          prevPaused = true;
        }
      }
      else if (!gameOver)
      {
        background(bg[0], bg[1], bg[2]);
        if (debug)
          text("Ready.\nPress any key to begin.\n\nScore: "+score+"\nLevel: "+level+"\nShip(s): "+lives, width/2, height/2);
        else
          text("Ready.\nMove hands close together to begin.\n\nScore: "+score+"\nLevel: "+level+"\nShip(s): "+lives, width/2, height/2);
      }
      else
      {
        background(bg[0], bg[1], bg[2]);
        textAlign(CENTER, CENTER);
        if (win)
          text("YOU WIN", width/2, height/2);
        else
          text("GAME OVER", width/2, height/2);
      }
    }
    else
    {
      background(bg[0], bg[1], bg[2]);
      text(s, width/2, height/2);
      if (s.contains(":"))
        image(psi, width/2, height/2+50);
    }
  }
  else
  {
    background(bg[0], bg[1], bg[2]);
    text("No user detected.\n\nScore: "+score+"\nLevel: "+level+"\nShip(s): "+lives, width/2, height/2);
  }
  animateExplosions();
}

void explode(int x, int y)
{
  explosion.play();
  explosion.rewind();
  ex.add(new PVector(x, y));
  Gif animation = new Gif(this, "Explosion.gif");
  animation.play();
  anims.add(animation);
}

void animateExplosions()
{
  for (int i=0; i<ex.size(); i++)
  {
    Gif current = anims.get(i);
    if (current.currentFrame()==15)
    {
      ex.remove(i);
      anims.remove(i);
      i--;
    }
    else
    {
      image(current, ex.get(i).x, ex.get(i).y);
    }
  }
}

void die()
{
  dead = true;
  lives--;
  if (lives==0)
  {
    gameOver(false);
  }
  else
  {
    reset();
    enemies.clear();
    score=scoreAtLevelStart;
  }
}

void gameOver(boolean winIn)
{
  gameOver=true;
  started=false;
  win = winIn;
  if (song1.isLooping())
    song1.pause();
  if (song2!=null && song2.isLooping())
    song2.pause();
  if (winIn)
    victory.play();
}

void mousePressed()
{
  if (debug)
    fire();
}

void fire()
{
  lasers.add(new Laser(shipX, shipY-35, true));
  sound.play();
  sound.rewind();
}

//void title()
//{
//  while(mainscreen)
//  {
//    background(0);
//    text("SpaceGame",width/2,200);
//    text("Press space to start",width/2,500);
//  }
//}

void scroll()
{
  scrollAmt++;
}

void displayMap()
{
outerloop:
  for (int r=0; r<12; r++)
  {
    for (int c=0; c<16; c++)
    {
      String line = String.format("%-16s", lines[lines.length-11+r-stepCount]);
      if (map[r][c]=='X')
      {
        noStroke();
        fill(255);
        rect(c*64, r*64+scrollAmt, 64, 64);
        imageMode(CORNER);
        image(imgtexture, c*64, r*64+scrollAmt);
        imageMode(CENTER);

        int l = c*64;
        int rt = l+64;
        int t = r*64+scrollAmt;
        int b = t+64;
        if (shipX-24<=rt && shipX+24>=l && shipY-22<=b && shipY+22>=t)
        {
          explode(shipX, shipY);
          die();
          break outerloop;
        }

        for (int i=0; i<enemies.size(); i++)
        {
          Enemy e = enemies.get(i);
          int x = round(e.getX());
          int y = round(e.getY());
          if (x-30<=rt && x+30>=l && y-30<=b && y+30>=t)
          {
            if (e instanceof SmartEnemy)
            {
              e = (SmartEnemy)e;
              x = round(e.getX());
              y = round(e.getY());
              if (x-30<=rt && x-30>=rt-5)
              {
                println(" l " + rt + " " + (x-30));
                e.collision('l');
              }
              if (x+30>=l && x+30<=l+5)
              {
                println(" r " + l + " " + (x+30));
                e.collision('r');
              }
              if (y-30<=b && y-30>=b-5)
              {
                println(" t " + b + " " + (y-30));
                e.collision('t');
              }
              if (y+30>=t && y+30<=t+5)
              {
                println(" b " + t + " " + (y+30));
                e.collision('b');
              }
            }
            else
            {
              explode(round(e.getX()), round(e.getY()));
              enemies.remove(i);
            }
          }
        }
      }
      else if (map[r][c]=='E')
      {
        enemies.add(new Enemy(c*64+32, r*64+32, 2));
        map[r][c]=' ';
        lines[lines.length-11+r-stepCount] = line.substring(0, c)+ " " +line.substring(c+1);
      }
      else if (map[r][c]=='D')
      {
        enemies.add(new DumbEnemy(c*64+32, r*64+32, 2));
        map[r][c]=' ';
        lines[lines.length-11+r-stepCount] = line.substring(0, c)+ " " +line.substring(c+1);
      }
      else if (map[r][c]=='S')
      {
        enemies.add(new SmartEnemy(c*64+32, r*64+32, 2, 2000));
        map[r][c]=' ';
        lines[lines.length-11+r-stepCount] = line.substring(0, c)+ " " +line.substring(c+1);
      }
    }
  }
}

void onNewUser(int userId)
{
  println("User detected. Assume pose.");
  s = "User detected.\nTo calibrate, assume the following pose:\n\n\n\n\n\n\n";
  kinect.startPoseDetection("Psi", userId);
}

void onStartPose(String pose, int userId)
{
  println("Pose detected. Attempting to calibrate.");
  s = "Pose detected.";
  kinect.stopPoseDetection(userId);
  kinect.requestCalibrationSkeleton(userId, true);
}

void onEndCalibration(int userId, boolean successful)
{
  if (successful)
  {
    println("Calibration successful. Tracking started.");
    s = "Calibration successful.";
    kinect.startTrackingSkeleton(userId);
  }
  else
  {
    println("Calibration failed. Starting over.");
    s = "Calibration failed.";
    kinect.startPoseDetection("Psi", userId);
  }
}

public static boolean XOR(boolean x, boolean y)
{
  return ( ( x || y ) && ! ( x && y ) );
}

public void loadSong()
{
  if (song1==null)
  {
    song1=m.loadFile(songs[currentTrack]);
    song1.loop();
    prevTrack=currentTrack;
  }
  else if (song1.isPlaying() && prevTrack!=currentTrack)
  {
    song1.pause();
    song2=m.loadFile(songs[currentTrack]);
    song2.loop();
    prevTrack=currentTrack;
  }
  else if (song2.isPlaying() && prevTrack!=currentTrack)
  {
    song2.pause();
    song1=m.loadFile(songs[currentTrack]);
    song1.loop();
    prevTrack=currentTrack;
  }
}

