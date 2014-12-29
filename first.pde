import deadpixel.keystone.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import java.util.*;
import java.lang.Math;


public class Surface {
  PGraphics offscreen;
  int num;
  CornerPinSurface cpSurface;

  public Surface(int num, int w, int h) {
    this.num = num;
    offscreen = createGraphics(w, h, P3D);
    cpSurface = ks.createCornerPinSurface(w, h, 20);
  }

  public int getNum() { return num; }
  public PGraphics getOffscreen() { return offscreen; }
  public CornerPinSurface getCPSurface() { return cpSurface; }
}

abstract class Animation {
  abstract public void run(PGraphics offscreen);
}

Keystone ks;
Minim minim;
FFT fft;
AudioInput in;
PGraphics offscreen;
HashMap<Surface, Animation> anims;

Animation anim1 = new Animation() {
    public void run(PGraphics offscreen) {
      offscreen.beginDraw();
      offscreen.background(0, in.left.get(100)* 255, 0);
      offscreen.stroke(0, 255, 0);
      for(int i = 0; i < in.bufferSize() - 1; i++)
      {
        offscreen.line( i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50 );
        offscreen.line( i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50 );
      }
  
      offscreen.endDraw();
    }
  };

Animation anim2 = new Animation() {
    float rotation = 0.0f;
    public void run(PGraphics offscreen) {
      offscreen.beginDraw();
      offscreen.background(0, in.left.get(100)*255, 0);
      offscreen.fill(0, 255, 0);
      offscreen.stroke(0, 0, 0);
      offscreen.translate(100, 100, 0);
      rotation += 0.1f;
      offscreen.rotate(rotation, rotation, rotation, fft.getBand(2));
      offscreen.box(100);
      offscreen.endDraw();
    }
  };


Animation anim3 = new Animation() {
    float rotation = 0.0f;
    public void run(PGraphics offscreen) {
      fft.forward(in.mix);
      offscreen.beginDraw();
      offscreen.background(0, in.left.get(100)*255, 0);
      offscreen.stroke(0, 255, 0);
      for(int i = 0; i < fft.specSize(); i++)
      {
        offscreen.line( i, offscreen.height, i, offscreen.height - ((float) Math.log(fft.getBand(i)) * 100));
      }
      offscreen.endDraw();
    }
  };


void setup() {
  size(1920, 1080, P3D);
  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), in.sampleRate());

  ks = new Keystone(this);

  anims = new HashMap<Surface, Animation>();
  anims.put(new Surface(0, 800, 300), anim1);
  anims.put(new Surface(1, 200, 600), anim1);
  anims.put(new Surface(2, 200, 600), anim2);
  anims.put(new Surface(3, 200, 600), anim3);

}

void draw() {
  background(0);
  fft.forward(in.mix);
 
  for (Surface surface : anims.keySet()) {
    Animation anim = anims.get(surface);
    PGraphics offscreen = surface.getOffscreen();
    anim.run(offscreen);
    surface.getCPSurface().render(offscreen);
  }  
}

void keyPressed() {
  switch(key) {
  case 'c':
    ks.toggleCalibration();
    break;

  case 'l':
    ks.load();
    break;

  case 's':
    ks.save();
    break;
  }
}
