public class Tile  {
  
  Body body;
  
  private float tileSize,offset;
  private Vec2 pos,screenPos,worldPos;
  private String userData;
  private color fillColor;
  private final color r=color(65,50,50),g=color(175,175,190),b=color(50,50,65),d=color(190,190,175);
  // Mover blocks
  private boolean moveRight=true,isMover=false; // false by default
  MouseJoint mover;
  private float speed;
  private Vec2 startPos,endPos;
  
  // Stationary Constructor
  Tile(float X, float Y, float MAPSIZE, String USERDATA) {
    userData = USERDATA;
    tileSize = 100/MAPSIZE;
    offset = 1-((tileSize+1)/2);
    //pos = new Vec2(X+tileSize/2, tileSize-Y-tileSize/2); // subtract from y because box2d is inverted
    pos = new Vec2(X*tileSize-50-offset, 100-Y*tileSize-50+offset); // box2d origin is at center of screen, must offset
    //println("tile pos: "+pos+" tile size: "+tileSize);
    worldPos = pos;
    screenPos = box2d.worldToScreen(pos);
    // Define a polygon (this is what we use for a rectangle)
    PolygonDef sd = new PolygonDef();
    sd.setAsBox(tileSize/2, tileSize/2);

    // Parameters that affect physics
    sd.friction = 0.3f;
    sd.restitution = 0.5f;
    // normal blocks never move
    sd.density = 0.0f;
    
    // Determine tile type, color and category
    int randValue = int(random(175,255));
    if(userData.equals("tile")){
      //randValue =int(random(175,215));
      //fillColor = color(175,175,190,randValue);
      fillColor = color(red(g),green(g),blue(g),randValue);
      sd.filter.categoryBits = 0x0002;
    }else if(userData.equals("brick")){
      //randValue =int(random(50,70));
      //fillColor = color(65,50,50,randValue);
      fillColor = color(red(r),green(r),blue(r),randValue);
      sd.filter.categoryBits = 0x0004;
    }else if(userData.equals("slip")){
      //randValue =int(random(50,70));
      //fillColor = color(50,50,65,randValue);
      fillColor = color(red(b),green(b),blue(b),randValue);
      sd.filter.categoryBits = 0x0002;
    }else if(userData.equals("portal")){
      //fillColor = color(255,255,255,50);
      sd.isSensor = true;
    }else if(userData.equals("door")){
      //fillColor = color(190,190,175,75);
      fillColor = color(red(d),green(d),blue(d),75);
      sd.filter.categoryBits = 0x0002;
    }

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.userData = userData;
    //Vec2 center = new Vec2(X,Y);
    bd.position.set(pos);

    body = box2d.createBody(bd);
    body.createShape(sd);
    body.setMassFromShapes();
  }
  
  // Mover Constructor
  Tile(float X, float Y, float X2, float Y2, float SPEED, float MAPSIZE, String USERDATA) {
    isMover = true;
    if(X > X2){
      moveRight = false;
    }
    speed = SPEED;
    userData = USERDATA;
    tileSize = 100/MAPSIZE;
    offset = 1-((tileSize+1)/2);
    //pos = new Vec2(X+tileSize/2, tileSize-Y-tileSize/2); // subtract from y because box2d is inverted
    startPos = new Vec2(X*tileSize-50-offset, 100-Y*tileSize-50+offset); // box2d origin is at center of screen, must offset
    endPos = new Vec2(X2*tileSize-50-offset, 100-Y2*tileSize-50+offset);
    pos = startPos;
    //println("tile pos: "+pos+" tile size: "+tileSize);
    screenPos = box2d.worldToScreen(pos);
    // Define a polygon (this is what we use for a rectangle)
    PolygonDef sd = new PolygonDef();
    sd.setAsBox(tileSize/2, tileSize/2);

    // Parameters that affect physics
    sd.friction = 0.3f;
    sd.restitution = 0.5f;
    // mover blocks need density > 0 to move
    sd.density = 1.0f;
    
    // Determine tile type, color and category
    int randValue = int(random(175,255));
    if(userData.equals("tile")){
      //randValue =int(random(175,215));
      //fillColor = color(175,175,190,randValue);
      fillColor = color(red(g),green(g),blue(g),randValue);
      sd.filter.categoryBits = 0x0002;
    }else if(userData.equals("brick")){
      //randValue =int(random(50,70));
      //fillColor = color(65,50,50,randValue);
      fillColor = color(red(r),green(r),blue(r),randValue);
      sd.filter.categoryBits = 0x0004;
    }else if(userData.equals("slip")){
      //randValue =int(random(50,70));
      //fillColor = color(50,50,65,randValue);
      fillColor = color(red(b),green(b),blue(b),randValue);
      sd.filter.categoryBits = 0x0002;
    }

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.userData = userData;
    //Vec2 center = new Vec2(X,Y);
    bd.position.set(pos);

    body = box2d.createBody(bd);
    body.createShape(sd);
    body.setMassFromShapes();
    
    // MouseJoint for movement
    MouseJointDef mjd = new MouseJointDef();
    mjd.body1 = box2d.world.getGroundBody();
    mjd.body2 = body;
    // And that's the target
    //mjd.target.set(body.getPosition());
    mjd.target.set(pos);
    // Some stuff about how strong and bouncy the spring should be
    mjd.maxForce = 10000.0f * body.m_mass;
    mjd.frequencyHz = 10.0f;
    mjd.dampingRatio = 1.0f;
    mover = (MouseJoint) box2d.world.createJoint(mjd);
    mover.setTarget(pos);
  }
  
  void update(){
    if(isMover){
      Vec2 newPos = new Vec2(pos.x+speed,pos.y);
      // if newPos is outside start or end limits, reverse speed
      if(moveRight){
        if(newPos.x > endPos.x || newPos.x < startPos.x){
          speed = -speed;
          // recalculate newPos
          newPos = new Vec2(pos.x+speed,pos.y);
        }
      }else{
        if(newPos.x < endPos.x || newPos.x > startPos.x){
          speed = -speed;
          // recalculate newPos
          newPos = new Vec2(pos.x+speed,pos.y);
        }
      }
      pos = newPos;
      mover.setTarget(pos);
      worldPos = body.getPosition();
      screenPos = box2d.worldToScreen(worldPos);
    }
  }
  
  // Drawing the box
  void display() {
    /*
    if(isMover){
      Vec2 newPos = new Vec2(pos.x+speed,pos.y);
      // if newPos is outside start or end limits, reverse speed
      if(newPos.x > endPos.x || newPos.x < startPos.x){
        speed = -speed;
        // recalculate newPos
        newPos = new Vec2(pos.x+speed,pos.y);
      }
      pos = newPos;
      mover.setTarget(pos);
    }
    */
    
    // Get its angle of rotation
    float a = body.getAngle();
    //Vec2 worldPos = box2d.worldToScreen(pos);
    //worldPos = body.getPosition();
    //screenPos = box2d.worldToScreen(worldPos);
    
    rectMode(CENTER);
    imageMode(CENTER);
    pushMatrix();
    translate(screenPos.x,screenPos.y);
    rotate(-a);
    strokeWeight(4);
    fill(fillColor);
    stroke(0);
    if(userData.equals("portal")){
      //ellipse(0,0,tileSize*scaleFactor,tileSize*scaleFactor);
      switch(level){
        case 0:
          if(level2complete){
            image(scene.portal3Img,0,0);
          }else if(level1complete){
            image(scene.portal2Img,0,0);
          }else{
            image(scene.portal1Img,0,0);
          }
          break;
        // All other portals lead back to level 0
        case 1:
        case 2:
        case 3:
          image(scene.portal0Img,0,0);
          break;
      }
      //image(scene.portal0Img,0,0);
    }else{
      rect(0,0,tileSize*scaleFactor,tileSize*scaleFactor);
    }
    popMatrix();
  }
  
  void kill() {
    //body.destroyShape(body.m_shapeList);
    box2d.destroyBody(body);
    body = null;
  }

}

