import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch.

//These variables are for my example design. Your input code should modify/replace these!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

void setup() {
  size(1000, 800);

  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);

  //don't change this!
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this!
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    t.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0"
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();
  textSize(20);

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=0; i<trialCount; i++)
  {
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    Target t = targets.get(i);
    translate(t.x, t.y); //center the drawing coordinates to the center of the screen
    rotate(radians(t.rotation));
    if (trialIndex==i)
      fill(255, 0, 0, 192); //set color to semi translucent
    else
      fill(128, 60, 60, 128); //set color to semi translucent
    rect(0, 0, t.z, t.z);
    popMatrix();
  }

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  monitorInfo();
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

int left_op = 0;
int right_op = 1;
int up_op = 2;
int down_op = 3;
int rotate_left = 4;
int rotate_right = 5;
int inc_size = 6;
int dec_size = 7;
int confirm = 8;

void draw_button(String mystr, float x, float y, float w, float h, int TYPE, boolean colorRight){
  if (colorRight) fill (0,220,0, 255);
  else fill (220,220,220, 40);
  //fill (220,220,220, 40);
  rect( x, y, w, h);
  fill(255);
  textAlign(CENTER, CENTER);
  text(mystr, x, y, w, h);
  if(mousePressed && (mouseX > x && mouseY > y && mouseX < x+w && mouseY < y+h)){
    if(TYPE == inc_size) {
      screenZ = constrain(screenZ+inchToPix(.02f), .01, inchToPix(4f));
    } else if(TYPE == dec_size) {
      screenZ = constrain(screenZ-inchToPix(.02f), .01, inchToPix(4f));
    } else if (TYPE == up_op) {
      screenTransY-=inchToPix(.02f);
    } else if (TYPE == down_op) {
      screenTransY+=inchToPix(.02f);
    } else if (TYPE == left_op) {
      screenTransX-=inchToPix(.02f);
    } else if (TYPE == right_op) {
      screenTransX+=inchToPix(.02f);
    } else if (TYPE == rotate_left) {
      screenRotation--;
    } else if (TYPE ==  rotate_right){
      screenRotation++;
    }
        //else if (TYPE == 8) {
    //  if (userDone==false && !checkForSuccess())
    //    errorCount++;

    //  trialIndex++; //and move on to next trial

    //  if (trialIndex==trialCount && userDone==false)
    //  {
    //    userDone = true;
    //    finishTime = millis();
    //  }
    //}
  }

}


void ifSetGreen(boolean flag)
{
  if(flag) fill(0,255,0);
  else fill(255);
}

void monitorInfo()
{
  float l_x = width-inchToPix(2.0f), l_y = inchToPix(0.7f);
  int lineDis = 20;
  textSize(15);
  Target t = targets.get(trialIndex);
  String str1 = "x:Target/Yours = " + String.format("%.2f",t.x) + "/" + String.format("%.2f",screenTransX);
  String str2 = "y:Target/Yours = " + String.format("%.2f",t.y) + "/" + String.format("%.2f",screenTransY);
  String str3 = "rotate:Target/Yours = " + String.format("%.2f",t.rotation) + "/" + String.format("%.2f",screenRotation);
  String str4 = "z:Target/Yours = " + String.format("%.2f",t.z) + "/" + String.format("%.2f",screenZ);

  // Set green color if matches
  boolean closeDist = dist(t.x, t.y, screenTransX, screenTransY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeDist_x = dist(t.x, 0, screenTransX, 0)<inchToPix(.05f)/1.414; //has to be within +-0.05"
  boolean closeDist_y = dist(0, t.y, 0, screenTransY)<inchToPix(.05f)/1.414; //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation, screenRotation)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchToPix(.05f); //has to be within +-0.05"

  //println("%f, %f", l_x, l_y);

 //left middle, move left
  rectMode(CORNER);

  text("Monitor", l_x, l_y );
  ifSetGreen(closeDist_x);
  text(str1, l_x, l_y + lineDis );
  draw_button("left", width-80-140, height-inchToPix(.6f) -40, 70, 40, left_op, closeDist_x);
  draw_button("right", width- 80, height-inchToPix(.6f)- 40, 70, 40, right_op, closeDist_x);

  ifSetGreen(closeDist_y);
  text(str2, l_x, l_y + 2*lineDis );
  draw_button("up", width-80-70, height-inchToPix(.6f)- 80, 70, 40, up_op, closeDist_y);
  draw_button("down", width-80-70, height-inchToPix(.6f), 70, 40, down_op, closeDist_y);


  //upper right corner, rotate clockwise
  ifSetGreen(closeRotation);
  text(str3, l_x, l_y + 3*lineDis );
  draw_button("CW", width- 80, height-inchToPix(.6f)- 80, 70, 40, rotate_right,closeRotation);
  draw_button("CCW", width-80-140, height-inchToPix(.6f) -80, 70, 40, rotate_left,closeRotation);


  //lower left corner, decrease Z
  ifSetGreen(closeZ);
  text(str4, l_x, l_y + 4*lineDis );
  draw_button("-", width-80-140, height-inchToPix(.6f), 70, 40, dec_size,closeZ );
  draw_button("+", width- 80, height-inchToPix(.6f), 70, 40, inc_size,closeZ);


  rectMode(CENTER);

  //===========DRAW CURSOR SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY);
  rotate(radians(screenRotation));
  if (closeDist_x && closeDist_y && closeZ && closeRotation) fill(0,255,0);
  else noFill();
  strokeWeight(3f);
  stroke(160);
  rect(0, 0, screenZ, screenZ);
  popMatrix();


  fill(255, 255, 255, 30);
  //rect(l_x, l_y, 150, 100); // x, y, w, h
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{



}


void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
}


void mouseReleased()
{
  //check to see if user clicked middle of screen within 3 inches
  if (dist(width/2, height/2, mouseX, mouseY)<inchToPix(3f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}


//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Target t = targets.get(trialIndex);
  boolean closeDist = dist(t.x, t.y, screenTransX, screenTransY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation, screenRotation)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchToPix(.05f); //has to be within +-0.05"

  println("Close Enough Distance: " + closeDist + " (cursor X/Y = " + t.x + "/" + t.y + ", target X/Y = " + screenTransX + "/" + screenTransY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(t.rotation, screenRotation)+")");
  println("Close Enough Z: " +  closeZ + " (cursor Z = " + t.z + ", target Z = " + screenZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}