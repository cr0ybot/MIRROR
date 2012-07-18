public class CustomListener implements ContactListener {
  CustomListener(){
  };
  void add(ContactPoint cp){//contacts collide for the first time
    //println("new hit");
    // Get both shapes
    Shape s1 = cp.shape1;
    Shape s2 = cp.shape2;
    // Get both bodies
    Body b1 = s1.getBody();
    Body b2 = s2.getBody();

    if(b1.getUserData().equals("avatar") && b2.getUserData().equals("portal")){
      //println("portal touched");
      scene.portalHit(b2);
    }else if(b1.getUserData().equals("portal") && b2.getUserData().equals("avatar")){
      //println("portal touched");
      scene.portalHit(b1);
    }else if(b1.getUserData().equals("avatar") || b2.getUserData().equals("avatar")){
      Vec2 vel = avatar.head.getLinearVelocity();
      if(abs(vel.x) > 5 || abs(vel.y) > 5){
        //println(vel);
        hitSound.trigger();
        hitOn(128);
      }
    }
  }

  void persist(ContactPoint cp){//contacts continue to collide - i.e. resting on each other
    /*
    // Get both shapes
    Shape s1 = cp.shape1;
    Shape s2 = cp.shape2;
    // Get both bodies
    Body b1 = s1.getBody();
    Body b2 = s2.getBody();
    */
    /*
    if(b1.getUserData().equals("avatar") || b2.getUserData().equals("avatar")){
      //println("touching");
      avatar.setTouching(true);
    }
    */
  }

  void remove(ContactPoint cp){//objects stop touching each other
    // Get both shapes
    Shape s1 = cp.shape1;
    Shape s2 = cp.shape2;
    // Get both bodies
    Body b1 = s1.getBody();
    Body b2 = s2.getBody();
    
    if(b1.getUserData().equals("avatar") || b2.getUserData().equals("avatar")){
      if(b1.getUserData().equals("portal") || b2.getUserData().equals("portal")){
        //println("portal untouched");
        
        //scene.loadLevel(1);
      }
    }
    /*
    if(b1.getUserData().equals("avatar") || b2.getUserData().equals("avatar")){
      //println("touching");
      avatar.setTouching(false);
    }
    */
  }

  void result(ContactResult cp){//contact point is resolved into an add, persist etc
  }
}
