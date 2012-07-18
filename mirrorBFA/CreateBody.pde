
public class CreateBody{
  
  private final float f_density=1.0f;
  private float density=1.0f,friction=0.05f,restitution=0.3f;
  
  CreateBody(){
    // This is a utility class for PBox2D, by Daniel Shiffman
    // You must import PBox2D in your main sketch tab
    // and call it "box2d"
    // This class is static, so it does not have to be instanced
  }
  
  public void setDensity(float DENSITY){
    density = DENSITY;
  }
  
  public void defaultDensity(){
    density = f_density;
  }
  
  // Create avatar part
  public Body avatar(float X,float Y,float R,int PART){
    BodyDef bd = new BodyDef();
    //bd.userData = "avatar";
    
    Vec2 pos = box2d.screenToWorld(X,Y);
    bd.position = pos;
    //Body cb = box2d.createBody(bd);
    
    CircleDef cd = new CircleDef();
    float radius = box2d.scaleScreenToWorld(R);
    cd.radius = radius;
    //cd.density = density;
    cd.friction = friction;
    cd.restitution = restitution;
    // Choosing a category will allow you to specify if another shape will collide with this one
    cd.filter.categoryBits = 0x0001;
    // Choosing a mask will allow you to specify what this shape can collide with;
    // multiple categories separated by '&' are allowed
    switch(PART){
      case 1:
        bd.userData = "avatar";
        cd.density = density;
        cd.filter.maskBits = 0xffff; // 0x0000 = no collisions; 0xffff = collide with everything
        break;
      case 2:
        bd.userData = "hand";
        cd.density = 0.5f;
        cd.filter.maskBits = 0x0000;
        break;
      case 3:
        bd.userData = "hand";
        cd.density = 0.5f;
        cd.filter.maskBits = 0x0004;
        break;
    }
    
    Body cb = box2d.createBody(bd);
    cb.createShape(cd);
    cb.setMassFromShapes();
    //println("circle created | x: "+X+" y: "+Y);
    return cb;
  }
  
  // Create circle
  public Body circle(float X,float Y,float R){
    BodyDef bd = new BodyDef();
    
    Vec2 pos = box2d.screenToWorld(X,Y);
    bd.position = pos;
    Body cb = box2d.createBody(bd);
    
    CircleDef cd = new CircleDef();
    float radius = box2d.scaleScreenToWorld(R);
    cd.radius = radius;
    cd.density = density;
    cd.friction = friction;
    cd.restitution = restitution;
    
    cb.createShape(cd);
    cb.setMassFromShapes();
    //println("circle created | x: "+X+" y: "+Y);
    return cb;
  }
  
  // Create circle
  public Body circle(float X,float Y,float R,int GROUPINDEX){
    BodyDef bd = new BodyDef();
    
    Vec2 pos = box2d.screenToWorld(X,Y);
    bd.position = pos;
    Body cb = box2d.createBody(bd);
    
    CircleDef cd = new CircleDef();
    float radius = box2d.scaleScreenToWorld(R);
    cd.radius = radius;
    cd.density = density;
    cd.friction = friction;
    cd.restitution = restitution;
    cd.filter.groupIndex = GROUPINDEX;
    
    cb.createShape(cd);
    cb.setMassFromShapes();
    //println("circle created | x: "+X+" y: "+Y);
    return cb;
  }
  
  // Create circle with specific categoryBits & maskBits
  public Body circle(float X,float Y,float R,int CATEGORY,int MASK){
    BodyDef bd = new BodyDef();
    
    Vec2 pos = box2d.screenToWorld(X,Y);
    bd.position = pos;
    Body cb = box2d.createBody(bd);
    
    CircleDef cd = new CircleDef();
    float radius = box2d.scaleScreenToWorld(R);
    cd.radius = radius;
    cd.density = density;
    cd.friction = friction;
    cd.restitution = restitution;
    // Choosing a category will allow you to specify if another shape will collide with this one
    cd.filter.categoryBits = CATEGORY;
    // Choosing a mask will allow you to specify what this shape can collide with;
    // multiple categories separated by '&' are allowed
    cd.filter.maskBits = MASK; // 0x0000 = no collisions; 0xffff = collide with everything
    
    cb.createShape(cd);
    cb.setMassFromShapes();
    //println("circle created | x: "+X+" y: "+Y);
    return cb;
  }
  
  // Create square
  public Body square(float X, float Y, float W,float H){
    BodyDef bd = new BodyDef();
    
    Vec2 pos = box2d.screenToWorld(X,Y);
    bd.position = pos;
    Body sb = box2d.createBody(bd);
    
    PolygonDef sd = new PolygonDef();
    sd.setAsBox(box2d.scaleScreenToWorld(W/2), box2d.scaleScreenToWorld(H/2));
    sd.density = density;
    sd.friction = friction;
    sd.restitution = restitution;
    
    sb.createShape(sd);
    sb.setMassFromShapes();
    //println("square created | x: "+X+" y: "+Y);
    return sb;
  }
  
  // Create square with specific groupIndex
  public Body square(float X, float Y, float W,float H,int GROUPINDEX){
    BodyDef bd = new BodyDef();
    
    Vec2 pos = box2d.screenToWorld(X,Y);
    bd.position = pos;
    Body sb = box2d.createBody(bd);
    
    PolygonDef sd = new PolygonDef();
    sd.setAsBox(box2d.scaleScreenToWorld(W/2), box2d.scaleScreenToWorld(H/2));
    sd.density = density;
    sd.friction = friction;
    sd.restitution = restitution;
    sd.filter.groupIndex = GROUPINDEX;
    
    sb.createShape(sd);
    sb.setMassFromShapes();
    //println("square created | x: "+X+" y: "+Y);
    return sb;
  }
  
  // Create square with specific categoryBits & maskBits
  public Body square(float X, float Y, float W,float H,int CATEGORY,int MASK){
    BodyDef bd = new BodyDef();
    
    Vec2 pos = box2d.screenToWorld(X,Y);
    bd.position = pos;
    Body sb = box2d.createBody(bd);
    
    PolygonDef sd = new PolygonDef();
    sd.setAsBox(box2d.scaleScreenToWorld(W/2), box2d.scaleScreenToWorld(H/2));
    sd.density = density;
    sd.friction = friction;
    sd.restitution = restitution;
    sd.filter.categoryBits = CATEGORY;
    sd.filter.maskBits = MASK;
    
    sb.createShape(sd);
    sb.setMassFromShapes();
    //println("square created | x: "+X+" y: "+Y);
    return sb;
  }
  
  // Create square with specific categoryBits & maskBits & sleep
  public Body square(float X, float Y, float W,float H,int CATEGORY,int MASK,boolean SLEEP){
    BodyDef bd = new BodyDef();
    
    Vec2 pos = box2d.screenToWorld(X,Y);
    bd.position = pos;
    bd.isSleeping = SLEEP;
    Body sb = box2d.createBody(bd);
    
    PolygonDef sd = new PolygonDef();
    sd.setAsBox(box2d.scaleScreenToWorld(W/2), box2d.scaleScreenToWorld(H/2));
    sd.density = density;
    sd.friction = friction;
    sd.restitution = restitution;
    sd.filter.categoryBits = CATEGORY;
    sd.filter.maskBits = MASK;
    
    
    sb.createShape(sd);
    sb.setMassFromShapes();
    //println("square created | x: "+X+" y: "+Y);
    return sb;
  }
  
  // Create square
  public Body staticSquare(float X, float Y, float W,float H){
    BodyDef bd = new BodyDef();
    
    Vec2 pos = box2d.screenToWorld(X,Y);
    bd.position = pos;
    Body sb = box2d.createBody(bd);
    
    PolygonDef sd = new PolygonDef();
    sd.setAsBox(box2d.scaleScreenToWorld(W/2), box2d.scaleScreenToWorld(H/2));
    sd.density = 0.0f;
    
    sb.createShape(sd);
    sb.setMassFromShapes();
    //println("static square created | x: "+X+" y: "+Y);
    return sb;
  }
  
}
