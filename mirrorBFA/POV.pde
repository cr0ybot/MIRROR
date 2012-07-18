public class POV{
  
  Body parent;
  private Vec2 pos;
  private float x,y;
  private final float z=(height/2.0) / tan(PI*60.0 / 360.0);
  
  POV(Body PARENT){
    parent = PARENT;
  }
  
  public void update(){
      // Camera follow head
      if(parent!=null) pos = box2d.getScreenPos(parent);
      x = pos.x;
      y = pos.y;
      //z = (height/2.0) / tan(PI*60.0 / 360.0);
      //camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ)
      //camera(width/2.0, height/2.0, (height/2.0) / tan(PI*60.0 / 360.0), width/2.0, height/2.0, 0, 0, 1, 0) // Default
      //camera(width/2.0, height/2.0, (height/2.0) / tan(PI*60.0 / 360.0), pos.x, pos.y, 0, 0, 1, 0); // 3D aim
      camera(x, y, z, x, y, 0, 0, 1, 0); // 2D
      // x=cos(angle) | y=sin(angle)
      //float ang = parent.getAngle();
      //camera(pos.x, pos.y, (height/2.0) / tan(PI*60.0 / 360.0), pos.x, pos.y, 0, sin(ang), cos(-ang), 0); // 2D roll camera
  }
  
  public float getPosX(){
    return x;
  }
  public float getPosY(){
    return y;
  }
}
