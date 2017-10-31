class PWindow extends PApplet {
  PWindow() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(300, 800);
  }
  void setup() {
    surface.setTitle("YOUR AMAZING FACE!!!");
    textFont(mono);
    textSize(4);
    textLeading(4);
  }

  void draw() {
    background(255);
    fill(0);
    text(ditherToString, 0, 0, 600, 800);//fix size for 12 point font
  }
}