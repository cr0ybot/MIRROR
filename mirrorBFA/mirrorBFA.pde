import hypermedia.video.*;

import processing.opengl.*;

import fullscreen.*;

import pbox2d.*;
import org.jbox2d.common.*;
import org.jbox2d.common.Vec2;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.collision.*;
import org.jbox2d.collision.shapes.*;
//import org.jbox2d.collision.shapes.Shape;

import procontroll.*;
import java.io.*;

import ddf.minim.*;

import processing.serial.*;
import cc.arduino.*;

PFont font;
// Instance fullscreen library
FullScreen fs;
// instance Box2D World
PBox2D box2d;
// Instance Dual mouse control library for use with Mouse class
ControllIO controll;
// 2 mouse classes, left and right
Mouse mouseL,mouseR;
// Open CV, for facial capture
OpenCV opencv;
// Instance the avatar
Avatar avatar;
// Instance the scene
Scene scene;
// Instance POV camera control
POV pov;
// Instance custom PBox2D helper class
CreateBody createBody;
// Sound Effects!
Minim minim;
AudioSample grabSound,slipSound,portalSound,shatterSound,hitSound;
// Device feedback
Arduino arduino;
final int rightPin=9,leftPin=10,rightInt=4,leftInt=4,hitInt=4,grabFB=120; // Int = interval of time for vibration to occur
int rightCount=0,leftCount=0,hitCount=0;
boolean rightOn=false,leftOn=false,hitOn=false;

// Define screen resolution and helpful horizontal & vertical center points
// desktop: 1280x720 | laptop: 1152x720
final int screenWidth=1152,screenHeight=720,hCenter=screenWidth/2,vCenter=screenHeight/2,scaleFactor=50,resetInt=600;//3600;
final float gravity = -9.8; //-9.8
float screenGravity;
int level=0,nextLevel=1,resetCounter=0;
boolean level1complete=false,level2complete=false,waitingForPlayer=false;

void setup(){
  // OpenGL fix for Mac
  try{
    quicktime.QTSession.open();
  } catch (quicktime.QTException qte){
    qte.printStackTrace();
  }
  size(screenWidth,screenHeight,OPENGL); // OpenGL is faster, but Processing 1.1 will not draw smooth circles due to a bug
  //hint(DISABLE_OPENGL_2X_SMOOTH);
  frame.setLocation(0,0);
  frameRate(60);
  //smooth();
  // enter fullscreen
  // TODO: loading page with button to begin, then enter fullscreen
  fs = new FullScreen(this);
  //fs.setFullScreen(true);
  fs.enter();
  // Initialize Arduino
  //println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(rightPin, Arduino.OUTPUT);
  arduino.pinMode(leftPin, Arduino.OUTPUT);
  // hide cursor hack; replace with transparent GIF
  PImage hideCursor = loadImage("hideCursor.gif");
  cursor(hideCursor,0,0);
  // load fonts
  font = loadFont("Uni0554-48.vlw");
  // Initialize game
  initGame();
}

public void init(){
  frame.removeNotify();
  frame.setUndecorated(true);
  frame.addNotify();
  super.init();
}

void draw(){
  resetCounter++;
  updateFeedback();
  updateMouse();
  // Step physics engine
  box2d.step();
  avatar.update();
  pov.update();
  scene.display();
  if(!waitingForPlayer){
    avatar.display(true);
  }else{
    avatar.display(false);
  }
  // DEBUG mouse cursors
  //mouseL.drawCursor();
  //mouseR.drawCursor();
  //println(frameRate);
  //println("resetCounter: "+resetCounter);
  if(resetCounter >= resetInt){
    resetCounter = 0;
    if(!waitingForPlayer){
      reset();
    }
  }
}

// All final initialize methods go here
void initGame(){
  opencv = new OpenCV(this);
  // Initialize PBox2D; 50 means 50 pixels per "meter" since box2d uses real-world measurements
  box2d = new PBox2D(this,scaleFactor);
  box2d.createWorld();
  box2d.setGravity(0, gravity);
  // Collision detection output through CustomListener class
  box2d.world.setContactListener(new CustomListener());
  // Initialize PBox2D helper class
  createBody = new CreateBody();
  // Initialize ProControll library
  controll = ControllIO.getInstance(this);
  mouseR = new Mouse('R');
  mouseL = new Mouse('L');
  // Initialize sound library
  minim = new Minim(this);
  grabSound = minim.loadSample("sound/grab.wav", 512);
  slipSound = minim.loadSample("sound/slip.wav",512);
  portalSound = minim.loadSample("sound/portal.wav",1024);
  shatterSound = minim.loadSample("sound/shatter.wav",512);
  hitSound = minim.loadSample("sound/hit.wav", 512);
  // Initialize scene
  scene = new Scene();
  scene.loadLevel(level);
  // Initialize avatar
  //avatar = new Avatar(hCenter-25,-screenHeight*4); // -25 is to offset to world center, strangeness with blocks
  switch(level){
    case 0:
      avatar = new Avatar(hCenter-25,vCenter-2200);
      break;
    case 1:
      avatar = new Avatar(hCenter-1450,vCenter+400);
      break;
    case 2:
      avatar = new Avatar(hCenter+1450,vCenter-400);
      //avatar = new Avatar(hCenter+1450,vCenter-2200);
      break;
    case 3:
      avatar = new Avatar(hCenter-25,vCenter+1200);
      break;
    default:
      println("AVATAR PLACEMENT ERROR: NO LEVEL");
      avatar = new Avatar(hCenter-25,vCenter);
      break;
  }
  pov = new POV(avatar.head);
  screenGravity = box2d.scaleWorldToScree(gravity);
  // DEBUG
  //arduino.analogWrite(leftPin,128);
}

void hitOn(int STRENGTH){
  hitOn = true;
  arduino.analogWrite(leftPin,STRENGTH);
  arduino.analogWrite(rightPin,STRENGTH);
}

void updateFeedback(){
  
  if(!hitOn && !leftOn && !rightOn){
    arduino.analogWrite(leftPin,0);
    arduino.analogWrite(rightPin,0);
    hitCount = 0;
    leftCount = 0;
    rightCount = 0;
  }else if(hitOn){
    if(hitCount >= hitInt){
      arduino.analogWrite(leftPin,0);
      arduino.analogWrite(rightPin,0);
      hitOn = false;
      hitCount = 0;
    }
    hitCount++;
  }else{
    if(leftOn){
      if(leftCount >= leftInt){
        arduino.analogWrite(leftPin,0);
        leftCount = 0;
      }
      leftCount++;
    }else{
      arduino.analogWrite(leftPin,0);
    }
    if(rightOn){
      if(rightCount >= rightInt){
        arduino.analogWrite(rightPin,0);
        rightCount = 0;
      }
      rightCount++;
    }else{
      arduino.analogWrite(rightPin,0);
    }
  } 
}

void updateMouse(){
  mouseR.update();
  mouseL.update();

  if(mouseL.mainPressed() && !scene.portalHit){
    Body b = getBodyAtPoint(avatar.handL.getPosition());
    if(b != null){
      if(avatar.muscleL == null){
        if(b.m_userData.equals("slip")){
          avatar.slip(mouseL,b);
          slipSound.setPan(-1);
          slipSound.trigger();
        }else if(b.m_userData.equals("tile") || b.m_userData.equals("door")){
          avatar.grab(mouseL,b);
          grabSound.setPan(-1);
          grabSound.trigger();
          // Device feedback
          arduino.analogWrite(leftPin,grabFB);
          leftOn = true;
        }
      }else if(avatar.grabL == null){
        if(b.m_userData.equals("tile") || b.m_userData.equals("door")){
          avatar.release(mouseL);
          avatar.grab(mouseL,b);
          grabSound.setPan(-1);
          grabSound.trigger();
          // Device feedback
          arduino.analogWrite(leftPin,grabFB);
          leftOn = true;
        }
      }
    }else{
      avatar.release(mouseL);
      leftOn = false;
    }
  }else{
    avatar.release(mouseL);
    leftOn = false;
  }
  if(mouseR.mainPressed() && !scene.portalHit){
    Body b = getBodyAtPoint(avatar.handR.getPosition());
    if(b != null){
      if(avatar.muscleR == null){
        if(b.m_userData.equals("slip")){
          avatar.slip(mouseR,b);
          slipSound.setPan(1);
          slipSound.trigger();
        }else if(b.m_userData.equals("tile") || b.m_userData.equals("door")){
          avatar.grab(mouseR,b);
          grabSound.setPan(1);
          grabSound.trigger();
          arduino.analogWrite(rightPin,grabFB);
          rightOn = true;
        }
      }else if(avatar.grabR == null){
        if(b.m_userData.equals("tile") || b.m_userData.equals("door")){
          avatar.release(mouseR);
          avatar.grab(mouseR,b);
          grabSound.setPan(1);
          grabSound.trigger();
          arduino.analogWrite(rightPin,grabFB);
          rightOn = true;
        }
      }
    }else{
      avatar.release(mouseR);
      rightOn = false;
    }
  }else{
    avatar.release(mouseR);
    rightOn = false;
  }
}

// Idea taken from source seen at The Stem > Box2D Joints #2 - Revolute Joints <http://blog.thestem.ca/archives/102>
Body getBodyAtPoint(Vec2 POS){
  // Create a small box at mouse point
  //Vec2 v = bbox2d.screenToWorld(MOUSE);
  Vec2 v = POS;
  AABB aabb = new AABB(new Vec2(v.x - 0.01f, v.y - 0.01f), new Vec2(v.x + 0.01f, v.y + 0.01f));
  // Look at the shapes intersecting this box (max.: 10)
  Shape[] shapes = box2d.world.query(aabb, 10);
  if (shapes == null){
    return null;  // No body there...
  }
  for (int is = 0; is < shapes.length; is++){
    Shape s = shapes[is];
    // Using "userData" (defined in CreateBody.avatar()) to define objects that do not belong to the avatar itself
    if(s.m_body.m_userData != "avatar" && s.m_body.m_userData != "hand" && s.m_body.m_userData != "brick" && s.m_body.m_userData != "portal"){
      // Ensure it is really at this point
      if (s.testPoint(s.m_body.getXForm(), v)){
        return s.m_body; // Return the first body found
        //println("body detected: "+s.m_body);
      }
    }
  }
  return null;
}

void reset(){
  level = 0;
  nextLevel = 0;
  level1complete=false;
  level2complete=false;
  waitingForPlayer = true;
  Vec2 resetPos = new Vec2(hCenter-25,vCenter-2200);
  avatar.attach(box2d.screenToWorld(resetPos));
  scene.destroyLevel();
}

