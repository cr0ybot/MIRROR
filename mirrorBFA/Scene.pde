public class Scene{
  
  ArrayList elements = new ArrayList();
  private final static int res=3,numLevels=4;
  private final color[] levelFill={color(0,0,0),color(0,25,0),color(0,0,25),color(25,0,0)};
  PImage[] pixelMaps = new PImage[numLevels*3];
  PImage backImg,idleImg,welcomeImg,thanksImg,portal0Img,portal1Img,portal2Img,portal3Img,arrowNImg,arrowNEImg,arrowSImg;
  
  Vec2 screenPos=new Vec2(0,0),backPos=new Vec2(0,0);
  private int counter=0,portalCount=0;
  private boolean changeLevel=false,portalHit=false;
  
  // Shatter effect by Jean-no
  Shatter shatter;
  
  Scene(){
    // Initialize Shatter
    shatter = new Shatter();
    // load all level pixel maps
    for(int i=0;i<numLevels;i++){
      for(int j=0;j<3;j++){
        //println("loading map level"+i+"_"+j+" into array index "+(i*3+j));
        pixelMaps[i*3+j] = loadImage("levels/level"+i+"_"+j+".gif");
      }
    }
    backImg = loadImage("images/background.jpg");
    idleImg = loadImage("images/idle.png");
    welcomeImg = loadImage("images/welcome.png");
    thanksImg = loadImage("images/thanks.png");
    portal0Img = loadImage("images/portal0.png");
    portal1Img = loadImage("images/portal1.png");
    portal2Img = loadImage("images/portal2.png");
    portal3Img = loadImage("images/portal3.png");
    arrowNImg = loadImage("images/arrowN.png");
    arrowNEImg = loadImage("images/arrowNE.png");
    arrowSImg = loadImage("images/arrowS.png");
    //loadLevel(0);
  }
  
  public void loadLevel(int LEVEL){
    println("LOADING LEVEL "+LEVEL);
    level = LEVEL;
    Tile t;
    // Empty list of scene elements if not empty
    if(!elements.isEmpty()){
      //println("CLEARING TILES");
      /*
      for(int i=0;i<elements.size();i++){
        t = (Tile) elements.get(i);
        //println("clearing: "+x);
        t.kill();
      }
      */
      //println(elements.size()+" level elements");
      elements.clear();
      //println(elements.size()+" level elements");
    }
    //box2d.step();
    for(int i=0;i<res;i++){
      //pixelMap = loadImage("level"+LEVEL+"_"+i+".gif");
      PImage pixelMap = pixelMaps[level*3+i];
      pixelMap.loadPixels();
      for(int x=0;x<pixelMap.width;x++){
        for(int y=0;y<pixelMap.height;y++){
          int loc = x + y * pixelMap.width;
          // Check color of pixel and create tile accordingly
          int R = (pixelMap.pixels[loc] >> 16) & 0xFF; 
          int G = (pixelMap.pixels[loc] >> 8) & 0xFF;
          int B = pixelMap.pixels[loc] & 0xFF;
          if(G > R+B){
            //println("tile created: "+x+" : "+y);
            t = new Tile(x,y,pixelMap.width,"tile");
            elements.add(t);
          }else if(R > G+B){
            t = new Tile(x,y,pixelMap.width,"brick");
            elements.add(t);
          }else if(B > R+G){
            t = new Tile(x,y,pixelMap.width,"slip");
            elements.add(t);
          }
        }
      }
      //println(elements.size()+" level elements");
      // dump image from memory
      pixelMap = null;
    }
    // Level specifics
    switch(level){
      case 0:
        // Level 1 portal
        //t = new Tile(5,14.5,25,"portal");
        //elements.add(t);
        // Level 2 portal
        //t = new Tile(19,14.5,25,"portal");
        //elements.add(t);
        if(level2complete){
          nextLevel = 3;
          // door to level 1
          t = new Tile(10,11.5,25,"door");
          elements.add(t);
          // door to level 2
          t = new Tile(14,11.5,25,"door");
          elements.add(t);
          // Level 3 portal
          // TODO: add portal
          t = new Tile(12,23,25,"portal");
          elements.add(t);
        }else if(level1complete){
          nextLevel = 2;
          // door to level 1
          t = new Tile(10,11.5,25,"door");
          elements.add(t);
          // door to level 3
          t = new Tile(12,12.75,25,"door");
          elements.add(t);
          // Level 2 portal
          t = new Tile(19,14.5,25,"portal");
          elements.add(t);
        }else{
          nextLevel = 1;
          // door to level 2
          t = new Tile(14,11.5,25,"door");
          elements.add(t);
          // door to level 3
          t = new Tile(12,12.75,25,"door");
          elements.add(t);
          // Level 1 portal
          t = new Tile(5,14.5,25,"portal");
          elements.add(t);
        }
        break;
      case 1:
        nextLevel = 0;
        // Exit portal
        t = new Tile(17.5,8.5,25,"portal");
        elements.add(t);
        break;
      case 2:
        nextLevel = 0;
        // Exit portal
        t = new Tile(21,4.5,25,"portal");
        elements.add(t);
        // Moving block 1
        t = new Tile(8,11.75,16,11.75,0.1,25,"tile");
        elements.add(t);
        // Moving block 2
        t = new Tile(8,9.25,11.5,9.25,0.15,25,"tile");
        elements.add(t);
        // Moving block 3
        t = new Tile(16,9.25,12.5,9.25,-0.15,25,"tile");
        elements.add(t);
        // Moving block 4
        //t = new Tile(6,4.25,18,4.25,-0.15,25,"tile");
        //elements.add(t);
        t = new Tile(6,4.25,10,4.25,0.2,25,"tile");
        elements.add(t);
        t = new Tile(14,4.25,10,4.25,-0.25,25,"tile");
        elements.add(t);
        t = new Tile(14,4.25,18,4.25,0.2,25,"tile");
        elements.add(t);
        break;
      case 3:
        nextLevel = 0;
        // Exit portal
        // TODO: exit portal
        break;
      default:
        
        break;
    }
  }
  
  private int getLight(){
    Vec2 pos;
    if(avatar != null){
      pos = avatar.head.getPosition();
    }else{
      pos = new Vec2(0,0);
    }
    screenPos = box2d.worldToScreen(pos);
    backPos.x = screenPos.x+(-pos.x/100)*screenWidth;
    backPos.y = screenPos.y+(pos.y/100)*screenHeight;
    int light = int((pos.y+100)/2);
    if(light<0){
      light = 0;
    }else if(light>100){
      light = 100;
    }
    return light;
  }
  
  public void display(){
    if(portalHit){
      if(portalCount >= 60){
        portalCount = 0;
        portalHit = false;
        destroyLevel();
        //println("waited for portal");
      }else{
        portalCount++;
      }
    }
    if(changeLevel){
      if(counter >= 60){
        counter = 0;
        changeLevel = false;
        doShatter();
        //println("waited for level change");
      }else{
        counter++;
      }
    }
    // Background & light
    imageMode(CENTER);
    image(backImg,backPos.x,backPos.y);
    //fill(0,getLight());
    fill(red(levelFill[level]),green(levelFill[level]),blue(levelFill[level]),getLight());
    noStroke();
    rectMode(CENTER);
    rect(screenPos.x,screenPos.y,screenWidth+50,screenHeight+50);
    // Level details
    if(!waitingForPlayer){
      switch(level){
        case 0:
          fill(0,150);
          textFont(font,100);
          textAlign(LEFT);
          text("1",screenWidth/2-440,screenHeight/2-100);
          text("2",screenWidth/2+350,screenHeight/2-100);
          text("3",screenWidth/2-55,screenHeight/2+160);
          image(welcomeImg,hCenter-25,vCenter/2);
          break;
        case 1:
          image(arrowNEImg,hCenter-600,vCenter-1900);
          image(arrowSImg,hCenter+675,vCenter-2000);
          image(arrowNImg,hCenter+1500,vCenter+1925);
          break;
        case 3:
          fill(0,150);
          textFont(font,45);
          textAlign(CENTER);
          text("in",hCenter-20,vCenter+1800);
          text("order",hCenter-20,vCenter+1400);
          text("to",hCenter-20,vCenter+1000);
          text("escape",hCenter-20,vCenter+600);
          text("you",hCenter-20,vCenter+200);
          text("must",hCenter-20,vCenter-200);
          text("get",hCenter-20,vCenter-600);
          text("up",hCenter-20,vCenter-1000);
          text("and",hCenter-20,vCenter-1400);
          textFont(font,50);
          text("leave!",hCenter-20,vCenter-1800);
          image(thanksImg,hCenter-20,vCenter-2240);
          break;
        default:
          //?
          break;
      }
      for(int i=0;i<elements.size();i++){
        Tile t = (Tile) elements.get(i);
        // Boxes display themselves
        if(t.body != null){
          t.update();
          // Displays only those blocks on screen
          if(t.screenPos.x > screenPos.x-hCenter-75 && t.screenPos.x < screenPos.x+hCenter+75 && t.screenPos.y > screenPos.y-vCenter-75 && t.screenPos.y < screenPos.y+vCenter+75){
            t.display();
          }
        }
      }
    }else{
      imageMode(CENTER);
      image(idleImg,pov.getPosX(),pov.getPosY());
    }
    if(shatter.isShattering()){
      shatter.update();
    }
    
  }
  
  public void doShatter(){
    println("SHATTER + NEXT LEVEL INITIATED");
    shatter.startShatter();
    loadLevel(nextLevel);
    avatar.unattach();
  }
  
  public void destroyLevel(){
    println("DESTROY LEVEL INITIATED");
    Tile t;
    for(int i=0;i<elements.size();i++){
      t = (Tile) elements.get(i);
      //println("clearing: "+x);
      t.kill();
    }
    elements.clear();
    shatter.startShatter();
    if(nextLevel == 0){
      avatar.reposition(hCenter-25,vCenter-2200);
    }else{
      changeLevel = true;
    }
  }
  
  public void portalHit(Body BODY){
    if(!portalHit){
      portalHit = true;
      avatar.attach(BODY);
      portalSound.trigger();
      switch(level){
        case 0:
          
          break;
        case 1:
          level1complete = true;
          break;
        case 2:
          level2complete = true;
          break;
        case 3:
          // TODO: endGame
          break;
        default:
          
          break;
      }
    }
  }
  
}
