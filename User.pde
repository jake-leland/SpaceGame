class User
{
  int userId;
  PVector currLHand;
  PVector currRHand;
  PVector currTorso;
  PVector lastLHand;
  PVector lastRHand;
  PVector lastTorso;
  PVector interpolatedLHand;
  PVector interpolatedRHand;
  PVector interpolatedTorso;
  float lerpAmt = .5;
  float handDist;
  boolean hitch;

  public User()
  {
    currLHand = new PVector();
    currRHand = new PVector();
    currTorso = new PVector();
    lastLHand = new PVector();
    lastRHand = new PVector();
    lastTorso = new PVector();
    interpolatedLHand = new PVector();
    interpolatedRHand = new PVector();
    interpolatedTorso = new PVector();
  }
  
  void updateId(int uId)
  {
    userId = uId;
  }

  void update()
  {
    kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, currLHand);
    kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, currRHand);
    kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_TORSO, currTorso);

    lastLHand = interpolatedLHand.get();
    lastRHand = interpolatedRHand.get();
    lastTorso = interpolatedTorso.get();

    interpolatedRHand.x = lerp(lastRHand.x, currRHand.x, lerpAmt);
    interpolatedRHand.y = lerp(lastRHand.y, currRHand.y, lerpAmt);
    interpolatedRHand.z = lerp(lastRHand.z, currRHand.z, lerpAmt);

    interpolatedLHand.x = lerp(lastLHand.x, currLHand.x, lerpAmt);
    interpolatedLHand.y = lerp(lastLHand.y, currLHand.y, lerpAmt);
    interpolatedLHand.z = lerp(lastLHand.z, currLHand.z, lerpAmt);

    interpolatedTorso.x = lerp(lastTorso.x, currTorso.x, lerpAmt);
    interpolatedTorso.y = lerp(lastTorso.y, currTorso.y, lerpAmt);
    interpolatedTorso.z = lerp(lastTorso.z, currTorso.z, lerpAmt);

    PVector diffVector = PVector.sub(interpolatedRHand, interpolatedLHand);
    handDist = diffVector.mag();
  }

  float getHandDist()
  {
    return handDist;
  }

  void hitch()
  {
    hitch = true;
  }

  void unHitch()
  {
    hitch = false;
  }

  boolean isHitched()
  {
    return hitch;
  }

  float getX()
  {
    return interpolatedTorso.x;
  }

  float getZ()
  {
    return interpolatedTorso.z;
  }

  float getRHand()
  {
    return interpolatedRHand.y;
  }

  float getLHand()
  {
    return interpolatedLHand.y;
  }

  float getLastRHand()
  {
    return lastRHand.y;
  }

  float getLastLHand()
  {
    return lastLHand.y;
  }
}

