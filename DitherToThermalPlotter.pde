//to add pixel resize
// istead of picking a portion of the image show the image as a long strip
import processing.serial.*;
import controlP5.*;
ControlP5 cp5;
Range range;
Serial therm;
Dither d;
PWindow win;
PFont mono;
String ditherToString = "", thermID = "/dev/tty.usbserial";
boolean getImage = false, radialGradient = true;
float [][] ditherKernel = {{0, 0, 0 }, {0, 0, 0.0}, {0.0, 0.0, 0.0}};
float pix1 = 0, pix2 = 0, pix3 = 0, pix4 = 0, prev1 = 0, prev2 = 0, prev3 = 0, prev4 = 0;
int p, x = 0, hexCount = 0; //the maximum number of chars the plotter can print in each line
void settings() {
  size(800, 800);
}
void setup() {
  //fullScreen();
  mono = createFont("courier", 8, true);
  therm = new Serial(this, thermID, 9600);
  thermInit();
  d = new Dither();
  p = d.pixSize;//get the value of the pixel size
  cp5 = new ControlP5(this);
  win = new PWindow();
  initControllers();
  background(51);
  noFill();
}
void draw() {  
  background(51);
  //here we check if the value of the kernel has been changed if yes
  //the previous value is updated to the new value and we generate a new dither
  //with the new values
  if (prev1 != pix1 || prev2 != pix2 || prev3 != pix3 || prev4 != pix4) {
    //update the kernel
    d.kernel[1][2] = (float)pix1;
    d.kernel[2][0] = (float)pix2;
    d.kernel[2][1] = (float)pix3;
    d.kernel[2][2] = (float)pix4;
    //update the previous value
    prev1 = pix1;
    prev2 = pix2;
    prev3 = pix3;
    prev4 = pix4;
    d.generateDither();
  }
  d.displayDither();
  //////////////////////////////////
  x = floor(map(mouseX, 0, width, 1, d.dither.width - d.charXline));
  //if (getImage)showImageToPrint();
}

void keyPressed() {
  if (key == ' ') {
    printImage(d.dither.get(1, 1, d.charXline, d.dither.height - 1));
    thermPrint(ditherToString);
    //getImage = !getImage;
  }
}

void mouseClicked() {
  if (getImage)printImage(d.dither.get(x, 1, d.charXline, d.dither.height - 1));
}

//void showImageToPrint() {
//  stroke(0, 255, 0);
//  strokeWeight(3);
//  rect(x * p, p, p * d.charXline, height - 2 * p);
//}
//
void printImage(PImage img) {
  ditherToString = "";
  for (int i = 0; i < img.pixels.length; i++) {
    color c = img.pixels[i];
    float b = brightness(c);
    //String s = b < 150 ? "\u25FC" : "\u25FD";//black square and white square
    //String s = b < 150 ? "\u2591" : "\u2592";//black square and white square
    //String s = b < 150 ? "\u2588" : "\u2594";//black square and white square
    //String h = "\u005C";
    //String s = b < 150 ? "/" : "|"; //black square and white square
    //String s = b < 150 ? "1" : "0"; //black square and white square
    String s = b < 150 ? "a" : "b";
    //String s = b < 150 ? "\u2588" : "\u202F";//black square and white square sourceCodePro
    //String s = b < 150 ? "\u25E2" : "\u25E3";//triangle different rotation really nice
    //if (i > 1 && i % 42 == 0)ditherToString = ditherToString.concat("\n");
    ditherToString = ditherToString.concat(s);
  }
}
//
void thermInit() {
  byte[] d;
  d = new byte[] {0x1B, 0x40};
  therm.write(d);
}
//
void thermPrint(String img) {//String Title, String myText, 
  byte[] d;
  d = new byte[] {
    0x1B, 0x40, 0x1B, 0x61, byte(1), 
  };
  for(int i = 0; i < img.length(); i++){
    if (i > 1 && i % 42 == 0)therm.write("\n");
    if(img.charAt(i) == 'a')therm.write(0xDB);//fullblack
    else therm.write(0xB0);//semi-white
  }
  //therm.write(0xDB);//fullBlack
  //therm.write(0xDB);//white
  //therm.write(0xB0);
  //therm.write(0xB0);
  //therm.write(img + "\n\n");
  therm.write(d);
  //// set print mode (2xwidth, 2xheight, emph)  
  //therm.write(0x1B); // ESC
  //therm.write(0x21); // !
  //therm.write(48); // double-height

  //therm.write(Title + "\n\n"); // header horoscope
  //therm.write("/////////////////////\n");
  //// set print mode (default)  
  //therm.write(0x1B); // ESC
  //therm.write(0x21); // !
  //therm.write(0); // double-height

  ////therm.write("MORE TEXT\n");
  //therm.write(0x0A); //LF
  //therm.write(0x0D); //CR
  //therm.write(myText); //here comes the horoscope text
  //therm.write(0x0A); //LF


  //// set print mode (2xwidth, 2xheight, emph)  
  //therm.write(0x1B); // ESC
  //therm.write(0x21); // !
  //therm.write(56); // double-height
  //therm.write("\n/////////////////////\n\n");
  //// set print mode (default)  
  //therm.write(0x1B); // ESC
  //therm.write(0x21); // !
  //therm.write(0); // double-height
  //therm.write("Horoscopes by Rob Brezsny\n@ freewillastrology.com");
  //therm.write("\nTexts composed with RiTa 1.12\n@ rednoise.org/rita");
  //therm.write(0x1B); // ESC
  //therm.write(0x21); // !
  //therm.write(0); // default

  therm.write(0x0A); //LF
  //therm.write("Last line of text.. then feed some lines and cut!");
  therm.write(0x0A); //LF
  therm.write(0x0A); //LF
  therm.write(0x0A); //LF
  therm.write(0x0D); //CR
  therm.write(0x1D); //GS
  therm.write(0x56); //V
  therm.write(66); //
  therm.write(3); //3 lines
}

//cp5 control event to set factor and the color of the gradient
void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isFrom("FACTOR")) {
    float fac = theControlEvent.getController().getValue();
    d.setFactor(fac);
  }
  if (theControlEvent.isFrom("RADIAL")) {
    radialGradient = !radialGradient;
    d.setRadiant(radialGradient);
  }
  if (theControlEvent.isFrom("PIXEL SIZE")) {
    int PS = (int)theControlEvent.getController().getValue();
    d.setPixelSize(PS);
  }
  if (theControlEvent.isFrom("COLORS")) {
    // min and max values are stored in an array.
    // access this array with controller().arrayValue().
    // min is at index 0, max is at index 1.
    color colorMin = color(int(theControlEvent.getController().getArrayValue(0)));
    color colorMax = color(int(theControlEvent.getController().getArrayValue(1)));
    d.setColor(colorMin, colorMax);
  }
}
//initialize the cp5 controllers
void initControllers() {
  int w = 40, h = 25, top = 100;
  float sensitivity = 0.02;
  color black = color(0), grey = color(150), green = color(0, 255, 0);

  //the range object, cntrols the black and white value
  range = cp5.addRange("COLORS")
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
    .setPosition(20, 50)
    .setSize(200, 40)
    .setHandleSize(10)
    .setRange(0, 255)
    .setRangeValues(50, 100)
    // after the initialization we turn broadcast back on again
    .setBroadcast(true)
    .setColorForeground(grey)
    .setColorBackground(black)
    .setColorCaptionLabel(green);

  //kernel controllers
  cp5.addNumberbox("pix1")
    .setPosition(120, top)
    .setSize(w, h)
    .setScrollSensitivity(sensitivity)
    .setValue(7)
    .setColorBackground(grey)
    .setColorCaptionLabel(green);

  cp5.addNumberbox("pix2")
    .setPosition(20, top + 50)
    .setSize(w, h)
    .setScrollSensitivity(sensitivity)
    .setValue(3)
    .setColorBackground(grey)
    .setColorCaptionLabel(green);

  cp5.addNumberbox("pix3")
    .setPosition(70, top + 50)
    .setSize(w, h)
    .setScrollSensitivity(sensitivity)
    .setValue(5)
    .setColorBackground(grey)
    .setColorCaptionLabel(green);

  cp5.addNumberbox("pix4")
    .setPosition(120, top + 50)
    .setSize(w, h)
    .setScrollSensitivity(sensitivity)
    .setValue(1)
    .setColorBackground(grey)
    .setColorCaptionLabel(green);

  //factor controller
  cp5.addSlider("FACTOR")
    .setPosition(20, top + 100)
    .setRange(-10, 50)
    .setSize(200, 30)
    .setColorCaptionLabel(green)
    .setValue(16)
    .setColorForeground(grey)
    .setColorBackground(black)
    .setColorCaptionLabel(green);
  //pixel size controller
  cp5.addSlider("PIXEL SIZE")
    .setPosition(20, top + 150)
    .setRange(1, 10)
    .setSize(200, 30)
    .setColorCaptionLabel(green)
    .setValue(10)
    .setNumberOfTickMarks(10)
    .setColorForeground(grey)
    .setColorBackground(black)
    .setColorCaptionLabel(green);
  // radial gradient button
  cp5.addButton("RADIAL")
    .setValue(0)
    .setPosition(20, top + 200)
    .setSize(200, 19)
    .setColorForeground(grey)
    .setColorBackground(black)
    .setColorCaptionLabel(green);
}