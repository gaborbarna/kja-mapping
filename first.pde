import deadpixel.keystone.*;
import ddf.minim.*;
import java.util.*;


Keystone ks;
List<CornerPinSurface> surfaces;
Minim minim;
AudioInput in;
PGraphics offscreen;
List<Animation> animations;


abstract class Animation {
  abstract public void run(PGraphics offscreen);
}

Animation anim1 = new Animation() {
    public void run(PGraphics offscreen) {
      offscreen.beginDraw();
      offscreen.background(255);
      offscreen.fill(0, 255, 0);
      for(int i = 0; i < in.bufferSize() - 1; i++)
      {
        offscreen.line( i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50 );
        offscreen.line( i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50 );
      }
  
      offscreen.endDraw();
    }
  };

Animation anim2 = new Animation() {
    public void run(PGraphics offscreen) {
      offscreen.beginDraw();
      offscreen.background(255);
      offscreen.fill(0, 255, 0);
      offscreen.box(100);
      offscreen.endDraw();
    }
  };

void setup() {
  // Keystone will only work with P3D or OPENGL renderers, 
  // since it relies on texture mapping to deform
  size(1920, 1080, P3D);
  minim = new Minim(this);
  in = minim.getLineIn();

  ks = new Keystone(this);
  surfaces = Arrays.asList(ks.createCornerPinSurface(800, 300, 20),
                           ks.createCornerPinSurface(200, 600, 20),
                           ks.createCornerPinSurface(200, 600, 20),
                           ks.createCornerPinSurface(200, 600, 20));

  animations = Arrays.asList(anim1, anim2);
  
  // We need an offscreen buffer to draw the surface we
  // want projected
  // note that we're matching the resolution of the
  // CornerPinSurface.
  // (The offscreen buffer can be P2D or P3D)
  offscreen = createGraphics(800, 600, P3D);
}



void draw() {

  

  background(0);
 
  // render the scene, transformed using the corner pin surface
  for (CornerPinSurface surface : surfaces) {
    anim1.run(offscreen);
    surface.render(offscreen);
  }  
}

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  }
}
