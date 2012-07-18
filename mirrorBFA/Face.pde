import java.awt.Rectangle; // Necessary for OpenCV

public class Face{
  
  PImage faceImg,lastFaceImg,capFaceImg;
  PVector pixelVec,circleVec;
  
  private int[] alphaMask;
  private final int interval=10; // interval (in frames) at which to capture image from camera
  private int rad,diam,frames=interval;
  
  Face(int RAD){
    imageMode(CENTER);
    rad = RAD;
    diam = rad*2;
    frames = 0;
    
    faceImg = new PImage(diam,diam,ARGB);
    lastFaceImg = new PImage(diam,diam,ARGB);
    capFaceImg = new PImage(160,120,ARGB);
    
    opencv.capture( 200, 150 );                   // open video stream 60,60
    //opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT_TREE );  // load detection description, here-> front face detection : "haarcascade_frontalface_alt.xml"
    opencv.cascade( OpenCV.CASCADE_FRONTALFACE_DEFAULT );
  }
  
  public void update(){
    if(frames>=interval){
      captureFace();
      frames = 0;
    }else{
      frames++;
    }
    if(!waitingForPlayer){
      image(faceImg,0,0);
    }
  }
  
  private void captureFace(){
    opencv.read();
    Rectangle[] faces = opencv.detect( 1.2, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 10, 10 );
    //opencv.contrast(50);
    //opencv.convert( GRAY );
    // display the image
    //image( opencv.image(), 0, 0 );
    
    capFaceImg = opencv.image();
    capFaceImg.loadPixels();
    
    if(faces.length>0){
      faceImg.copy(capFaceImg,faces[0].x,faces[0].y,faces[0].width,faces[0].height,0,0,diam,diam);
      //faceImg.resize(diam,diam);
      alphaMask = new int[faceImg.pixels.length];
      
      for(int i = 0; i < faceImg.pixels.length; i++){
        //i = x+y*w; y = (i-x)/w;
        int pixX = i;
        while(pixX>=faceImg.width){
          pixX-=faceImg.width;
        }
        int pixY = (i - pixX)/faceImg.width;
        
        if(checkDistance(pixX,pixY,rad,rad,rad)){
          alphaMask[i] = 255;
        }else{
          alphaMask[i] = 0;
        } 
      }
      faceImg.mask(alphaMask);
      //faceImg.filter(POSTERIZE,10);
      lastFaceImg = faceImg;
      // if image was captured, let program know it is in use
      resetCounter = 0;
      if(waitingForPlayer){
        waitingForPlayer = false;
        //scene.doShatter();
      }
    }else{
      faceImg = lastFaceImg;
    }
    
    //translate(X,Y-rad);
    //rotate(rot);
    //image(faceImg,0,0);
  }
    
  private Boolean checkDistance(int pixelX,int pixelY,float circleX,float circleY,float circleR){
    pixelVec = new PVector(pixelX,pixelY);
    circleVec = new PVector(circleX,circleY);
    if(PVector.dist(pixelVec,circleVec)<=circleR){
      return true;
    }else{
      return false;
    }
  }
  
}
