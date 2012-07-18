
/** Left mouse must be the last connected to the computer, proceeded by the right mouse */

public class Mouse{
  
  // Create device aka mouse
  ControllDevice device;
  // Create "sliders" to give x/y values
  ControllSlider sliderX,sliderY;
  // Create buttons
  ControllButton button1,button2;
  
  private char side;
  private boolean frozen,invert;
  private float x=hCenter,y=vCenter,velX,velY;
  private int numDevices = controll.getNumberOfDevices();
  
  Mouse(char SIDE){
    side = SIDE;
    // Find device # using procontroll_printDevices sketch and plug in numbers
    // desktop: 0,1 | laptop: 3,4
    if(side=='R'){ // Right mouse
      println("right mouse initialized");
      device = controll.getDevice(3); //depends on where procontroll printDevices says the mouse is at
      button1 = device.getButton(0);
      button2 = device.getButton(1);
    }else if(side=='L'){ // Left mouse
      println("left mouse initialized");
      device = controll.getDevice(4);
      button1 = device.getButton(1); // Buttons switched on left so "inside" button is main
      button2 = device.getButton(0);
    }
    device.setTolerance(0.05f);
    // X/Y values come from these
    sliderX = device.getSlider(0);
    sliderY = device.getSlider(1);
    // Set multiplier so mouse moves farther for less cursor movement
    sliderX.setMultiplier(0.2);
    sliderY.setMultiplier(0.2);
    // Start mouse unfrozen
    frozen = false;
    invert = false;
  }
  
  public boolean mainPressed(){
    return button1.pressed();
  }
  
  public boolean otherPressed(){
    return button2.pressed();
  }
  
  // Freezes / unfreezes mouse position
  public void freeze(boolean VALUE){
    frozen = VALUE;
    invert = VALUE;
  }
  
  public boolean isFrozen(){
    return frozen;
  }
  
  public char getSide(){
    return side;
  }
  
  // Returns cursor box2d world coordinates
  public Vec2 getWorld(){
    Vec2 mouseWorld = box2d.screenToWorld(x,y);
    return mouseWorld;
  }
  
  // Returns cursor screen coordinates
  public Vec2 getScreen(){
    Vec2 mouseScreen = new Vec2(x,y);
    return mouseScreen;
  }
  
  public void update(){
    //updateButtons(); // taken care of in main
    //if(!frozen){
      updatePos();
    //}
    //drawCursor();
  }
  
  public void setPos(Vec2 POS){
    x = POS.x;
    y = POS.y;
  }
  
  public Vec2 getWorldVel(){
    Vec2 vel = box2d.screenToWorld(new Vec2(velX,velY));
    return vel;
  }
  
  public Vec2 getGrabVel(){
    Vec2 vel = new Vec2(-velX/5,velY);
    return vel;
  }
  
  public Vec2 getScreenVel(){
    Vec2 vel = new Vec2(velX,velY);
    return vel;
  }
  
  private void updatePos(){
    // Capture x/y values from device
    // returns relative position since last call
    velX = sliderX.getValue();
    velY = sliderY.getValue();
    // if mouse is moved, let program know it is in use
    if(abs(velX) > 0 && abs(velY) > 0){
      resetCounter = 0;
    }
    // Add x/y values to previous x/y
    if(invert){
      x = x-velX;
      y = y-velY;
    }else{
      x = x+velX;
      y = y+velY;
    }
    // Deposit new values into global x/y
    //x = nX;
    //y = nY;
  }
  
  private void updateButtons(){
    if(button1.pressed()){
      println(side+" button 1 pressed");
      frozen = true;
    }else{
      frozen = false;
    }
  }
  
  // For debug purposes
  public void drawCursor(){
    strokeWeight(2);
    noFill();
    rectMode(CENTER);
    if(side == 'R'){
      stroke(0,0,255);
      rect(x,y,6,6);
      line(x-10,y,x+10,y);
      line(x,y-10,x,y+10);
    }else{
      stroke(255,0,0);
      rect(x,y,6,6);
      line(x-10,y,x+10,y);
      line(x,y-10,x,y+10);
    }
  }
}
