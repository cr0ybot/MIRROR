
public class Avatar{
  
  Body head,handL,handR,elbowL,elbowR,handleL,handleR,targetL,targetR;
  DistanceJoint bicepL,bicepR,tricepL,tricepR,grabL,grabR;
  MouseJoint stringL,stringR,muscleL,muscleR,attach;
  
  Face face;
  
  private Vec2 posNow,posPrev,repos;
  private boolean touching = false, repositioning = false;
  private final float headRadius=30,elbowRadius=3,handRadius=10,armLength=45,constLength=armLength*2+headRadius,constLengthWorld=box2d.scaleScreenToWorld(constLength),slipVal=0.05;
  
  Avatar(float X,float Y){
    grabL = null;
    grabR = null;
    posNow = posPrev = box2d.screenToWorld(X,Y);
    makeBodies(X,Y);
    makeJoints(X,Y);
    face = new Face(int(headRadius));
  }
  
  public void setTouching(boolean LISTENER){
    touching = LISTENER;
  }
  
  public void display(boolean DISPLAY){
    if(DISPLAY){
      // Set draw properties
      fill(175);
      stroke(0);
      strokeWeight(4);
      //strokeJoin(MITER); // does not work with OpenGL
      ellipseMode(CENTER);
      // Head --
      Vec2 headPos = box2d.getScreenPos(head);
      float headAng = head.getAngle();
      // Use translation matrix to draw
      pushMatrix();
      translate(headPos.x,headPos.y);
      rotate(-headAng); // Processing and box2d use opposite angle values
      //ellipse(0,0,headRadius*2,headRadius*2);
      //line(0,-headRadius,0,0);
      //ellipse(-13,0,15,15);
      //ellipse(13,0,15,15);
      face.update();
      noFill();
      ellipse(0,0,headRadius*2,headRadius*2);
      popMatrix();
      // --
      strokeWeight(8);
      // Left bicep joint --
      Vec2 bL1 = box2d.worldToScreen(bicepL.getAnchor1());
      Vec2 bL2 = box2d.worldToScreen(bicepL.getAnchor2());
      line(bL1.x,bL1.y,bL2.x,bL2.y);
      // --
      // Right bicep joint --
      Vec2 bR1 = box2d.worldToScreen(bicepR.getAnchor1());
      Vec2 bR2 = box2d.worldToScreen(bicepR.getAnchor2());
      line(bR1.x,bR1.y,bR2.x,bR2.y);
      // --
      // Left tricep joint --
      Vec2 tL1 = box2d.worldToScreen(tricepL.getAnchor1());
      Vec2 tL2 = box2d.worldToScreen(tricepL.getAnchor2());
      line(tL1.x,tL1.y,tL2.x,tL2.y);
      // --
      // Right tricep joint --
      Vec2 tR1 = box2d.worldToScreen(tricepR.getAnchor1());
      Vec2 tR2 = box2d.worldToScreen(tricepR.getAnchor2());
      line(tR1.x,tR1.y,tR2.x,tR2.y);
      // --
      // Left shoulder --
      noStroke();
      fill(0);
      ellipse(bL1.x,bL1.y,8,8);
      // --
      // Left elbow --
      noStroke();
      fill(0);
      ellipse(bL2.x,bL2.y,8,8);
      // --
      // Right shoulder --
      noStroke();
      fill(0);
      ellipse(bR1.x,bR1.y,8,8);
      // --
      // Right elbow --
      noStroke();
      fill(0);
      ellipse(bR2.x,bR2.y,8,8);
      // --
      strokeWeight(4);
      stroke(0);
      //fill(175);
      // Left hand --
      Vec2 hLPos = box2d.getScreenPos(handL);
      //float hLAng = handL.getAngle();
      // Get angle foom tricep instead
      float hLAng = atan2((tL1.y-tL2.y),(tL1.x-tL2.x));
      if(mouseL.isFrozen()){
        fill(50,50,100);
      }else{
        fill(100,100,200);
      }
      // Use translation matrix to draw
      pushMatrix();
      translate(hLPos.x,hLPos.y);
      rotate(hLAng); // Processing and box2d use opposite angle values
      ellipse(0,0,handRadius*2,handRadius*2);
      //line(0,0,-handRadius,0);
      popMatrix();
      // --
      // Right hand --
      Vec2 hRPos = box2d.getScreenPos(handR);
      //float hRAng = handR.getAngle();
      // Get angle from tricep instead
      float hRAng = atan2((tR1.y-tR2.y),(tR1.x-tR2.x));
      if(mouseR.isFrozen()){
        fill(100,50,50);
      }else{
        fill(200,100,100);
      }
      // Use translation matrix to draw
      pushMatrix();
      translate(hRPos.x,hRPos.y);
      rotate(hRAng); // Processing and box2d use opposite angle values
      ellipse(0,0,handRadius*2,handRadius*2);
      //line(0,0,-handRadius,0);
      popMatrix();
      // --
    }else{
      face.update();
    }
  }
  
  public void update(){
    Vec2 headVel = head.getLinearVelocity();
    Vec2 vel = new Vec2 (0,0);
    vel.x = (headVel.x/50)*0.9;
    vel.y = (headVel.y/50)*0.9;
    //println(vel);
    
    // Check avatar position if repositioning
    if(repositioning){
      Vec2 headPos = head.getPosition();
      if(headPos.x < repos.x+1 && headPos.x > repos.x-1 && headPos.y < repos.y+1 && headPos.y > repos.y-1){
        if(!waitingForPlayer){
          headVel.x -= headVel.x;
          headVel.y -= headVel.y;
          repositioning = false;
          scene.doShatter();
        }
      }
    }
    
    if(!mouseL.isFrozen() && !mouseR.isFrozen()){
      // Add head velocity to mouse position to prevent "sticking"
      Vec2 mL = mouseL.getWorld();
      mL.x += vel.x;
      mL.y += vel.y;
      mouseL.setPos(box2d.worldToScreen(mL));
      mouseL.setPos(constrainMouse(bicepL.getAnchor1(),mouseL.getScreen(),armLength*2,handL));
      stringL.setTarget(mouseL.getWorld());
      
      // Add head velocity to mouse position to prevent "sticking"
      Vec2 mR = mouseR.getWorld();
      mR.x += vel.x;
      mR.y += vel.y;
      mouseR.setPos(box2d.worldToScreen(mR));
      mouseR.setPos(constrainMouse(bicepR.getAnchor1(),mouseR.getScreen(),armLength*2,handR));
      stringR.setTarget(mouseR.getWorld());
    } else{
      // Constrain mouse to arm length if mouse button is not pressed
      if(!mouseL.isFrozen()){
        //println("left hand moving");
        Vec2 mL = mouseL.getWorld();
        // If the other hand is grabbing, allow this hand to pull the head
        if(muscleR != null){
          //Vec2 targetVel = targetR.getLinearVelocity();
          //mouseL.setPos(new Vec2(mL.x+targetVel.x,mL.y+targetVel.y));
          mL.x += vel.x;
          mL.y += vel.y;
          mouseL.setPos(box2d.worldToScreen(mL));
          mouseL.setPos(constrainMouse(handR.getPosition(),mouseL.getScreen(),armLength*4+headRadius*2));
          stringL.setTarget(mouseL.getWorld());
        }else{
          // Add head velocity to mouse position to prevent "sticking"
          //Vec2 mL = mouseL.getWorld();
          mL.x += vel.x;
          mL.y += vel.y;
          //mouseL.setPos(box2d.worldToScreen(mL.add(vel)));
          mouseL.setPos(box2d.worldToScreen(mL));
          mouseL.setPos(constrainMouse(bicepL.getAnchor1(),mouseL.getScreen(),armLength*2));
          stringL.setTarget(mouseL.getWorld());
        }
      }else if(mouseL.isFrozen()){
        if(grabL != null){
          //println("left hand grabbing");
          Vec2 hP = grabL.getAnchor1();
          Vec2 mL = mouseL.getScreen();
          Vec2 targetVel = targetL.getLinearVelocity();
          mouseL.setPos(new Vec2(mL.x+targetVel.x,mL.y+targetVel.y));
          stringL.setTarget(handL.getPosition());
          // Constrain mouse
          mouseL.setPos(constrainMouse(hP,mouseL.getScreen(),armLength*2));
          muscleL.setTarget(mouseL.getWorld());
        }else if(muscleL != null){
          Vec2 slip = handL.getPosition();
          slip.y -= slipVal;
          stringL.setTarget(slip);
          Vec2 sP = stringL.getAnchor1();
          slip = constrainMouse(sP,mouseL.getScreen(),armLength*2);
          slip.y += box2d.scaleWorldToScree(slipVal);
          mouseL.setPos(slip);
          muscleL.setTarget(mouseL.getWorld());
        }
      }
      if(!mouseR.isFrozen()){
        //println("right hand moving");
        Vec2 mR = mouseR.getWorld();
        // If the other hand is grabbing, allow this hand to pull the head
        if(muscleL != null){
          //Vec2 targetVel = targetL.getLinearVelocity();
          //mouseR.setPos(new Vec2(mR.x+targetVel.x,mR.y+targetVel.y));
          mR.x += vel.x;
          mR.y += vel.y;
          mouseR.setPos(box2d.worldToScreen(mR));
          mouseR.setPos(constrainMouse(handL.getPosition(),mouseR.getScreen(),armLength*4+headRadius*2));
          stringR.setTarget(mouseR.getWorld());
        }else{
          // Add head velocity to mouse position to prevent "sticking"
          //Vec2 mR = mouseR.getWorld();
          mR.x += vel.x;
          mR.y += vel.y;
          //mouseR.setPos(box2d.worldToScreen(mR.add(vel)));
          mouseR.setPos(box2d.worldToScreen(mR));
          mouseR.setPos(constrainMouse(bicepR.getAnchor1(),mouseR.getScreen(),armLength*2));
          stringR.setTarget(mouseR.getWorld());
        }
      }else if(mouseR.isFrozen()){
        if(grabR != null){
          //println("right hand grabbing");
          Vec2 hP = grabR.getAnchor1();
          Vec2 mR = mouseR.getScreen();
          Vec2 targetVel = targetR.getLinearVelocity();
          mouseR.setPos(new Vec2(mR.x+targetVel.x,mR.y+targetVel.y));
          stringR.setTarget(handR.getPosition());
          // Constrain mouse
          mouseR.setPos(constrainMouse(hP,mouseR.getScreen(),armLength*2));
          muscleR.setTarget(mouseR.getWorld());
        }else if(muscleR != null){
          Vec2 slip = handR.getPosition();
          slip.y -= slipVal;
          stringR.setTarget(slip);
          Vec2 sP = stringR.getAnchor1();
          slip = constrainMouse(sP,mouseR.getScreen(),armLength*2);
          slip.y += box2d.scaleWorldToScree(slipVal);
          mouseR.setPos(slip);
          muscleR.setTarget(mouseR.getWorld());
        }
      }
    }
  }
  
  private Vec2 constrainMouse(Vec2 GOAL/*world coordinates!*/,Vec2 MOUSE/*screen coordinates!*/,float MAXDIST){
    // Cursors prevent smooth falling, so we find the velocity of the head and add it to the mouse
    // Get difference between previous avatar position and current one to add velocity to cursors
    //float xDiff = box2d.scaleWorldToScree(posPrev.x-posNow.x); // Typo in PBox2D; should be "scalWorldToScreen"
    //float yDiff = box2d.scaleWorldToScree(posPrev.y-posNow.y);
    //Vec2 velocity = new Vec2(xDiff*1.1,yDiff*1.1);
    // Translate world positions to screen positions
    Vec2 goal = box2d.worldToScreen(GOAL);
    //Vec2 mouse = new Vec2(MOUSE.x+velocity.x,MOUSE.y+velocity.y);
    Vec2 mouse = new Vec2(MOUSE.x,MOUSE.y);
    // Find the distance
    float distance = dist(goal.x,goal.y,mouse.x,mouse.y);
    // Constrain mouse if distance is longer than it should be
    if(distance>MAXDIST){
      // atan2 gives us the angle; notice yDiff comes before xDiff
      float angle = atan2((mouse.y-goal.y),(mouse.x-goal.x));
      // X = R cos(Theta) + Xorigin
      float nX = (MAXDIST)*cos(angle)+goal.x;
      // Y = R sin(Theta) + Yorigin
      float nY = (MAXDIST)*sin(angle)+goal.y;
      
      Vec2 newPos = new Vec2(nX,nY);
      // return the new constrained mouse position
      return newPos;
    /*
    }else if(distance<MINDIST){
      // atan2 gives us the angle; notice yDiff comes before xDiff
      float angle = atan2((mouse.y-goal.y),(mouse.x-goal.x));
      // X = R cos(Theta) + Xorigin
      float nX = (MINDIST)*cos(angle)+goal.x;
      // Y = R sin(Theta) + Yorigin
      float nY = (MINDIST)*sin(angle)+goal.y;
      
      Vec2 newPos = new Vec2(nX,nY);
      // return the new constrained mouse position
      return newPos;
      */
    }else{
      // if the distance was within limits, leave the mouse position alone
      return MOUSE;
    }
  }
  private Vec2 constrainMouse(Vec2 GOAL/*world coordinates!*/,Vec2 MOUSE/*screen coordinates!*/,float MAXDIST,Body BODY){
    // Cursors prevent smooth falling, so we push hands back down
    
    // Translate world positions to screen positions
    Vec2 goal = box2d.worldToScreen(GOAL);
    //Vec2 mouse = new Vec2(MOUSE.x+velocity.x,MOUSE.y+velocity.y);
    Vec2 mouse = new Vec2(MOUSE.x,MOUSE.y);
    // Find the distance
    float distance = dist(goal.x,goal.y,mouse.x,mouse.y);
    // Constrain mouse if distance is longer than it should be
    if(distance>MAXDIST){
      // atan2 gives us the angle; notice yDiff comes before xDiff
      float angle = atan2((mouse.y-goal.y),(mouse.x-goal.x));
      // X = R cos(Theta) + Xorigin
      float nX = (MAXDIST)*cos(angle)+goal.x;
      // Y = R sin(Theta) + Yorigin
      float nY = (MAXDIST)*sin(angle)+goal.y;
      
      Vec2 newPos = new Vec2(nX,nY);
      
      // FORCE HANDS TO FALL WHEN AVATAR FALLS
      BODY.applyImpulse(new Vec2(-cos(angle), sin(angle)),BODY.getPosition());
      
      // return the new constrained mouse position
      return newPos;
    }else{
      // if the distance was within limits, leave the mouse position alone
      return MOUSE;
    }
  }
  
  private void makeBodies(float X,float Y){
    // Head
    head = createBody.avatar(X,Y,headRadius,1);
    // DEBUG: Give it some initial random velocity
    //head.setLinearVelocity(new Vec2(random(-5,5),random(2,5)));
    //head.setAngularVelocity(random(-5,5));
    // Left elbow
    elbowL = createBody.avatar(X-headRadius-armLength,Y,elbowRadius,2);
    // Right elbow
    elbowR = createBody.avatar(X+headRadius+armLength,Y,elbowRadius,2);
    // Left hand
    handL = createBody.avatar(X-headRadius-armLength*2,Y,handRadius,3);
    // Right hand
    handR = createBody.avatar(X+headRadius+armLength*2,Y,handRadius,3);
  }
  
  private void makeJoints(float X,float Y){
    DistanceJointDef djd = new DistanceJointDef();
    Vec2 v1,v2;
    // Left bicep joint --
    // Anchor points are in world coordinates
    // Shoulder position
    v1 = box2d.screenToWorld(X-headRadius,Y);
    // Elbow position
    v2 = box2d.screenToWorld(X-headRadius-armLength,Y);
    djd.initialize(head,elbowL,v1,v2);
    // Stop hand from colliding with head
    djd.collideConnected = false;
    bicepL = (DistanceJoint) box2d.world.createJoint(djd);
    // --
    // Right bicep joint --
    // Anchor points are in world coordinates
    // Shoulder position
    v1 = box2d.screenToWorld(X+headRadius,Y);
    // Elbow position
    v2 = box2d.screenToWorld(X+headRadius+armLength,Y);
    djd.initialize(head,elbowR,v1,v2);
    // Stop hand from colliding with head
    djd.collideConnected = false;
    bicepR = (DistanceJoint) box2d.world.createJoint(djd);
    // --
    // Left tricep joint --
    // Elbow position
    v1 = box2d.screenToWorld(X-headRadius-armLength,Y);
    // Hand position
    v2 = box2d.screenToWorld(X-headRadius-armLength*2,Y);
    djd.initialize(elbowL,handL,v1,v2);
    // Stop hand from colliding with head
    djd.collideConnected = false;
    tricepL = (DistanceJoint) box2d.world.createJoint(djd);
    // --
    // Right tricep joint --
    // Elbow position
    v1 = box2d.screenToWorld(X+headRadius+armLength,Y);
    // Hand position
    v2 = box2d.screenToWorld(X+headRadius+armLength*2,Y);
    djd.initialize(elbowR,handR,v1,v2);
    // Stop hand from colliding with head
    djd.collideConnected = false;
    tricepR = (DistanceJoint) box2d.world.createJoint(djd);
    // --
    MouseJointDef mjd = new MouseJointDef();
    // Left cursor string --
    // Set mouse cursor to correct starting position
    Vec2 mL = new Vec2(X-headRadius-armLength*2,Y);
    mouseL.setPos(mL);
    // Body 1 is just a fake ground body for simplicity (there isn't anything at the mouse)
    mjd.body1 = box2d.world.getGroundBody();
    // Body 2 is the elbow
    mjd.body2 = handL;
    // Get the mouse location in world coordinates
    Vec2 hL = mouseL.getWorld();
    // And that's the target
    mjd.target.set(hL);
    // Some stuff about how strong and bouncy the spring should be
    mjd.maxForce = 1000.0f * handL.m_mass; // must be loose to allow cursor to fall with avatar
    mjd.frequencyHz = 10.0f;
    mjd.dampingRatio = 1.0f;
    // Wake up body!
    //handL.wakeUp();
    stringL = (MouseJoint) box2d.world.createJoint(mjd);
    // Reposition mouse cursor
    mouseL.setPos(new Vec2(mL.x+armLength,mL.y));
    // --
    // Right cursor string --
    // Set mouse cursor to correct starting position
    Vec2 mR = new Vec2(X+headRadius+armLength*2,Y);
    mouseR.setPos(mR);
    // Body 1 is just a fake ground body for simplicity (there isn't anything at the mouse)
    mjd.body1 = box2d.world.getGroundBody();
    // Body 2 is the elbow
    mjd.body2 = handR;
    // Get the mouse location in world coordinates
    Vec2 hR = mouseR.getWorld();
    // And that's the target
    mjd.target.set(hR);
    // Some stuff about how strong and bouncy the spring should be
    mjd.maxForce = 1000.0f * handR.m_mass; // must be loose to allow cursor to fall with avatar
    mjd.frequencyHz = 10.0f;
    mjd.dampingRatio = 1.0f;
    // Wake up body!
    //handL.wakeUp();
    stringR = (MouseJoint) box2d.world.createJoint(mjd);
    // Reposition mouse cursor
    mouseR.setPos(new Vec2(mR.x-armLength,mR.y));
    // --
  }
  
  public void slip(Mouse M,Body B){
    switch(M.getSide()){
      case 'L':
        if(grabL == null){
          M.freeze(true);
          
          // Set mouse target to object being grabbed
          targetL = B;
          /*
          // Create DistanceJoint with no length to pin hand to object
          DistanceJointDef djd = new DistanceJointDef();
          Vec2 handPos = handL.getPosition();
          djd.initialize(B,handL,handPos,handPos);
          grabL = (DistanceJoint) box2d.world.createJoint(djd);
          */
          // Create MouseJoint to lift avatar body
          MouseJointDef mjd = new MouseJointDef();
          // Set mouse cursor to correct starting position
          mouseL.setPos(box2d.worldToScreen(bicepL.getAnchor1()));
          // Body 1 is just a fake ground body for simplicity (there isn't anything at the mouse)
          mjd.body1 = box2d.world.getGroundBody();
          // Body 2 is the elbow
          mjd.body2 = head;
          // Get the mouse location in world coordinates
          Vec2 hL = mouseL.getWorld();
          // And that's the target
          mjd.target.set(hL);
          // Some stuff about how strong and bouncy the spring should be
          mjd.maxForce = 40.0f * head.m_mass; // must be loose to allow cursor to fall with avatar
          mjd.frequencyHz = 5.0f;
          mjd.dampingRatio = 0.5f;
          muscleL = (MouseJoint) box2d.world.createJoint(mjd);
          //println("handL grabbing");
        }
        break;
      case 'R':
        if(grabR == null){
          M.freeze(true);
          
          // Set mouse target to object being grabbed
          targetR = B;
          /*
          // Create DistanceJoint with no length to pin hand to object
          DistanceJointDef djd = new DistanceJointDef();
          Vec2 handPos = handR.getPosition();
          djd.initialize(B,handR,handPos,handPos);
          grabR = (DistanceJoint) box2d.world.createJoint(djd);
          */
          // Create MouseJoint to lift avatar body
          MouseJointDef mjd = new MouseJointDef();
          // Set mouse cursor to correct starting position
          mouseR.setPos(box2d.worldToScreen(bicepR.getAnchor1()));
          // Body 1 is just a fake ground body for simplicity (there isn't anything at the mouse)
          mjd.body1 = box2d.world.getGroundBody();
          // Body 2 is the elbow
          mjd.body2 = head;
          // Get the mouse location in world coordinates
          Vec2 hR = mouseR.getWorld();
          // And that's the target
          mjd.target.set(hR);
          // Some stuff about how strong and bouncy the spring should be
          mjd.maxForce = 40.0f * head.m_mass; // must be loose to allow cursor to fall with avatar
          mjd.frequencyHz = 5.0f;
          mjd.dampingRatio = 0.5f;
          muscleR = (MouseJoint) box2d.world.createJoint(mjd);
          //println("handR grabbing");
        }
        break;
    }
  }
  
  public void grab(Mouse M,Body B){
    switch(M.getSide()){
      case 'L':
        if(grabL == null){
          M.freeze(true);
          // Set mouse target to object being grabbed
          targetL = B;
          // Create DistanceJoint with no length to pin hand to object
          DistanceJointDef djd = new DistanceJointDef();
          Vec2 handPos = handL.getPosition();
          djd.initialize(B,handL,handPos,handPos);
          grabL = (DistanceJoint) box2d.world.createJoint(djd);
          
          // Create MouseJoint to lift avatar body
          MouseJointDef mjd = new MouseJointDef();
          // Set mouse cursor to correct starting position
          mouseL.setPos(box2d.worldToScreen(bicepL.getAnchor1()));
          // Body 1 is just a fake ground body for simplicity (there isn't anything at the mouse)
          mjd.body1 = box2d.world.getGroundBody();
          // Body 2 is the elbow
          mjd.body2 = head;
          // Get the mouse location in world coordinates
          Vec2 hL = mouseL.getWorld();
          // And that's the target
          mjd.target.set(hL);
          // Some stuff about how strong and bouncy the spring should be
          mjd.maxForce = 40.0f * head.m_mass; // must be loose to allow cursor to fall with avatar
          mjd.frequencyHz = 5.0f;
          mjd.dampingRatio = 0.5f;
          muscleL = (MouseJoint) box2d.world.createJoint(mjd);
          //println("handL grabbing");
        }
        break;
      case 'R':
        if(grabR == null){
          M.freeze(true);
          // Set mouse target to object being grabbed
          targetR = B;
          // Create DistanceJoint with no length to pin hand to object
          DistanceJointDef djd = new DistanceJointDef();
          Vec2 handPos = handR.getPosition();
          djd.initialize(B,handR,handPos,handPos);
          grabR = (DistanceJoint) box2d.world.createJoint(djd);
          
          // Create MouseJoint to lift avatar body
          MouseJointDef mjd = new MouseJointDef();
          // Set mouse cursor to correct starting position
          mouseR.setPos(box2d.worldToScreen(bicepR.getAnchor1()));
          // Body 1 is just a fake ground body for simplicity (there isn't anything at the mouse)
          mjd.body1 = box2d.world.getGroundBody();
          // Body 2 is the elbow
          mjd.body2 = head;
          // Get the mouse location in world coordinates
          Vec2 hR = mouseR.getWorld();
          // And that's the target
          mjd.target.set(hR);
          // Some stuff about how strong and bouncy the spring should be
          mjd.maxForce = 40.0f * head.m_mass; // must be loose to allow cursor to fall with avatar
          mjd.frequencyHz = 5.0f;
          mjd.dampingRatio = 0.5f;
          muscleR = (MouseJoint) box2d.world.createJoint(mjd);
          //println("handR grabbing");
        }
        break;
    }
    
  }
  
  public void release(Mouse M){
    switch(M.getSide()){
      case 'L':
        if(grabL != null){
          M.freeze(false);
          targetL = null;
          box2d.world.destroyJoint(grabL);
          grabL = null;
          box2d.world.destroyJoint(muscleL);
          muscleL = null;
          M.setPos(box2d.getScreenPos(handL));
          //println("handL released");
        }else if(muscleL != null){
          M.freeze(false);
          targetL = null;
          box2d.world.destroyJoint(muscleL);
          muscleL = null;
          M.setPos(box2d.getScreenPos(handL));
          //println("handL released");
        }
        break;
      case 'R':
        if(grabR != null){
          M.freeze(false);
          targetR = null;
          box2d.world.destroyJoint(grabR);
          grabR = null;
          box2d.world.destroyJoint(muscleR);
          muscleR = null;
          M.setPos(box2d.getScreenPos(handR));
          //println("handR released");
        }else if(muscleR != null){
          M.freeze(false);
          targetR = null;
          box2d.world.destroyJoint(muscleR);
          muscleR = null;
          M.setPos(box2d.getScreenPos(handR));
          //println("handR released");
        }
        break;
    }
  }
  
  public void attach(Body BODY){
    if(attach == null){
      // Create MouseJoint to attach avatar body
      MouseJointDef mjd = new MouseJointDef();
      mjd.body1 = box2d.world.getGroundBody();
      mjd.body2 = head;
      // And that's the target
      mjd.target.set(head.getPosition());
      // Some stuff about how strong and bouncy the spring should be
      mjd.maxForce = 100.0f * head.m_mass; // must be loose to allow cursor to fall with avatar
      mjd.frequencyHz = 10.0f;
      mjd.dampingRatio = 1.0f;
      attach = (MouseJoint) box2d.world.createJoint(mjd);
      Vec2 target = BODY.getPosition();
      attach.setTarget(target);
    }
  }
  
  public void attach(Vec2 POS){
    if(attach == null){
      // Create MouseJoint to attach avatar body
      MouseJointDef mjd = new MouseJointDef();
      mjd.body1 = box2d.world.getGroundBody();
      mjd.body2 = head;
      // And that's the target
      mjd.target.set(head.getPosition());
      // Some stuff about how strong and bouncy the spring should be
      mjd.maxForce = 100.0f * head.m_mass; // must be loose to allow cursor to fall with avatar
      mjd.frequencyHz = 10.0f;
      mjd.dampingRatio = 1.0f;
      attach = (MouseJoint) box2d.world.createJoint(mjd);
      //Vec2 target = BODY.getPosition();
      attach.setTarget(POS);
    }
  }
  
  public void unattach(){
    if(attach != null){
      box2d.world.destroyJoint(attach);
      attach = null;
    }
  }
  
  public void reposition(float X,float Y){
    if(attach != null){
      if(!repositioning){
        repositioning = true;
        repos = box2d.screenToWorld(X,Y);
        attach.setTarget(repos);
      }
    }
  }
  
}
