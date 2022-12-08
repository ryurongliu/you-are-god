import java.util.ArrayList;
import netP5.*;
import oscP5.*;

//osc stuff
OscP5 oscP5;
NetAddress maxBroadcastLocation;
NetAddress pyBroadcastLocation;

String scene = "menu";

int text_width;
int text_height;

//menu scene variables
int buttonWidth, buttonHeight;
int buttonX;
int beginY, quitY;
boolean beginOver = false;
boolean quitOver = false;


//intro scene variables
int intro_slide = 1;
int nextX, nextY;
boolean nextOver = false;
int fade_counter = 0;

//place intro variables
int text_placed = 0;

//place dot variables
public class Star
{
  int x, y;
  int h, s, b;
  int rad;
  String id; 

  int fade;
  boolean appeared, connected, pinged;
  int ping_counter;

  public Star(int x, int y, int h, int s, int b, int rad, String id) {
    this.x = x;
    this.y = y;
    this.h = h;
    this.s = s;
    this.b = b;
    this.rad = rad;
    this.id = id;

    this.fade = 0;
    this.appeared = false;
    this.connected = false;
    this.pinged = false;
    this.ping_counter = 0;
   
  }
  

  public int[] getColor() {
    int[] col = {this.h, this.s, this.b};
    return col;
  }
  
  public void draw_s(int h, int s, int b, int f){
    push();
      noStroke();
      colorMode(HSB, 400, 400, 400, 255);
      fill(h, s, b, f);
      circle(this.x, this.y, this.rad);
      
      if (this.pinged){
        if (this.ping_counter == 1){
          OscMessage myOscMessage = new OscMessage("/" + this.id);
          myOscMessage.add("/bang");
          myOscMessage.add(1);
          oscP5.send(myOscMessage, maxBroadcastLocation);
        }
        if (this.ping_counter < 5){
          
          push();
            colorMode(RGB, 255);
            stroke(255);
            strokeWeight(2);
            noFill();
            circle(this.x, this.y, this.rad);
          pop();
          
          this.ping_counter += 1;
        }
        else{
          this.ping_counter = 0;
          this.pinged = false;
        }
      }
    pop();
    
    
  }

  public void appear() {

    if (this.appeared == false) {
      
      this.draw_s(this.h, 0, 200, this.fade);

      if (this.fade < 255) {
        this.fade += 5;
      } else if (this.fade >= 255) {
        this.appeared = true;
        this.fade = 0;
      }
      if (this.fade == 10){
        OscMessage myOscMessage = new OscMessage("/" + this.id);
        myOscMessage.add("/info");
        myOscMessage.add(this.h);
        myOscMessage.add(this.rad);
        oscP5.send(myOscMessage, maxBroadcastLocation);
      }
    }
    
    else if (this.appeared && this.connected == false){
      this.draw_s(this.h, 0, 200, 255);
    }

  }


  public void connect(){
    
    if(this.connected == false){
      
      this.draw_s(this.h, this.fade, 200+this.fade, 255);

      if (this.fade < 200) {
        this.fade += 5;
      } 
      else if (this.fade >= 200) {
        this.connected = true;
      } 
    }
    
    else if (this.connected){
      this.draw_s(this.h, this.s, this.b, 255);
    }
  }
  
  //public void disconnect(){
  //  if (this.connected == true){
  //     push();
  //    noStroke();
  //    colorMode(HSB, 400, 400, 400);
  //    fill(this.h, this.fade, 200+this.fade);
  //    circle(this.x, this.y, this.rad);
  //    pop();

  //    if (this.fade > 0) {
  //      this.fade -= 5;
  //    } 
  //    else if (this.fade <= 0) {
  //      this.connected = false;
  //      this.fade = 0;
  //    } 
  //  }
  //}
  
}
ArrayList<Star> stars = new ArrayList<Star>();
int starRad;
ArrayList<Boolean> overStar = new ArrayList<Boolean>();
boolean overStarFr = false;
int starH = 0;
int starS = 200;
int starB = 400;

boolean shift = false;
ArrayList<Boolean> overStarDel = new ArrayList<Boolean>();
boolean overStarDelFr = false;
int starForDel = -1;



//connect variables
public class Connection
{
  int startX, startY;
  int endX, endY;
  float dist;
  
  int animate_counter;
  boolean animated;
  int load_counter;
  boolean loaded;
  
  boolean ping_start;
  boolean ping_end;

  public Connection(Star start, Star end) {
    this.get_endpoints(start, end);
    this.get_dist();
    this.animate_counter = 0;
    this.animated = false;
    this.load_counter = 0;
    this.loaded = false;
    
    this.ping_start = false;
    this.ping_end = false;
  }

  public void get_endpoints(Star start, Star end) {
    int x1 = start.x;
    int y1 = start.y;
    float r1 = start.rad / 2 + 5;
    int x2 = end.x;
    int y2 = end.y;
    float r2 = end.rad / 2 + 5;

    float disX = x2 - x1;
    float disY = y2 - y1;
    float len = sqrt(sq(disX) + sq(disY));

    this.startX = round(x1 + disX/len * r1 + 1);
    this.startY = round(y1 + disY/len * r1);
    this.endX = round(x2 - disX/len * r2);
    this.endY = round(y2 - disY/len * r2);
  }

  public void get_dist() {
    this.dist = sqrt(sq(this.startX - this.endX) + sq(this.startY - this.endY));
  }

  public void draw_c() {
    push();
    stroke(255);
    strokeWeight(2);
    line(this.startX, this.startY, this.endX, this.endY);
    pop();
  }

  public void draw_alpha(int a) {
    push();
    stroke(255, 255, 255, a);
    strokeWeight(2);
    line(this.startX, this.startY, this.endX, this.endY);
    pop();
  }
  
  public void load(){
    if (this.loaded == false){
      draw_alpha(this.load_counter/2);
      
      if (this.load_counter < 200){
        this.load_counter += 5;
      }
      else if (load_counter >= 200){
        this.loaded = true;
      }
    }
    else if (this.loaded){
      draw_alpha(100);
    }
  }
  
  public void animate(){
    
    if (this.animated == false){
      draw_animate(this.animate_counter);
      
      if (this.animate_counter < this.dist){
        this.animate_counter += 1;
      }
      else if (this.animate_counter >= this.dist){
        this.animated = true;
      }
    }
    
    if (this.animated == true){
      draw_animate(this.animate_counter);
      if (this.animate_counter > 0){
        this.animate_counter -= 1;
      }
      else if (this.animate_counter <= 0){
        this.animated = false;
      }
    }
  }
  
  public void draw_animate(int t){
    int x = round(this.endX + t / this.dist * (this.startX - this.endX));
    int y = round(this.endY + t / this.dist * (this.startY - this.endY));
    push();
      stroke(255);
      strokeWeight(4);
      point(x, y);
    pop();
    
    if (x == this.startX && y == this.startY){
      ping_start = true;
    }
    else{
      ping_start = false;
    }
    
    if (x == this.endX && y == this.endY){
      ping_end = true;
    }
    else{
      ping_end = false;
    }
    
  }
  
}

ArrayList<Integer> star_order = new ArrayList<Integer>(); //order of stars (by index)
ArrayList<Connection> connections = new ArrayList<Connection>();
ArrayList<ArrayList<Integer>> pairs = new ArrayList<ArrayList<Integer>>(); //pairs taken
int prevStarForDel = -1;
int currStarX = 0;
int currStarY = 0;


//play variables
int play_scene = 0;
int destroyX, destroyY;
boolean destroyOver = false;
boolean destroyed = false;

//playing variables
ArrayList<Integer> stars_playing = new ArrayList<Integer>(); //stars displayed during playing
ArrayList<Connection> connections_playing = new ArrayList<Connection>(); // connections displayed during playing
ArrayList<Integer> stars_connected = new ArrayList<Integer>(); //stars connected during playing
boolean connection_connecting = false; 
ArrayList<Connection> connections_loaded = new ArrayList<Connection>();


//destroy variables
int destroy_counter = 0;
String destroy_prev; 
boolean destroy_triggered = false;

void setup() {
  //fullScreen();
  size(960, 540);
  smooth();


  oscP5 = new OscP5(this, 8000);
  maxBroadcastLocation = new NetAddress("127.0.0.1", 5000);
  pyBroadcastLocation = new NetAddress("127.0.0.1", 3000);

  text_width = width/15;
  text_height = width/15;

  //set menu variables
  buttonWidth = width/8;
  buttonHeight = height/16;
  buttonX = width/2;
  beginY = height/2 + 1*buttonHeight/4;
  quitY = height/2 + 8*buttonHeight/4;

  //set intro variables
  nextX = width/2;
  nextY = height - height/16;

  destroyY = nextY;
  destroyX = width - height/16 - buttonWidth/2;

  //place dots varaibles
  starRad = width/50;

  rectMode(CENTER);
  PFont f = createFont("arial.ttf", 24);
  textFont(f);
  textAlign(CENTER, CENTER);
  
  
  OscMessage myOscMessage = new OscMessage("/startnoise");
  myOscMessage.add("1");
  oscP5.send(myOscMessage, maxBroadcastLocation);
}

void draw() {
  switch(scene) {
  case "menu":
    menu();
    break;
  case "intro":
    intro();
    break;
  case "place_intro":
    place_intro();
    break;
  case "place_dots":
    place_dots();
    break;
  case "connect_intro":
    connect_intro();
    break;
  case "connect_dots":
    connect_dots();
    break;
  case "play_intro":
    play_intro(true);
    break;
  case "play_start":
    play_start();
    break;
  case "wait":
    wait_play();
    break;
  case "playing":
    play(true);
    break;
  case "destroyed_intro":
    destroyed_intro();
    break;
  case "destroy":
    destroy();
    break;
  }
}

void mousePressed() {
  switch(scene) {
  case "menu":
    menu_mouse();
    break;
  case "intro":
    intro_mouse();
    break;
  case "place_intro":
    place_dots_mouse();
    break;
  case "place_dots":
    place_dots_mouse();
    break;
  case "connect_intro":
    connect_dots_mouse();
  case "connect_dots":
    connect_dots_mouse();
    break;
  case "play_intro":
    play_intro_mouse();
    break;
  case "play_start":
    play_mouse();
    break;
  case "wait":
    play_mouse();
    break;
  case "playing":
    play_mouse();
    break;
  case "destroyed_intro":
    destroyed_mouse();
    break;
  }
}

boolean overButton(int x, int y, int width, int height) {
  if (mouseX >= x-width/2 && mouseX <= x+width/2 &&
    mouseY >= y-height/2 && mouseY <= y+height/2) {
    return true;
  } else {
    return false;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      if (starH < 245) {
        starH += 5;
      }
    } else if (keyCode == DOWN) {
      if (starH > 0) {
        starH -= 5;
      }
    } else if (keyCode == LEFT) {
      if (starRad > width/100) {
        starRad -= 1;
      }
    } else if (keyCode == RIGHT) {
      if (starRad < width/25) {
        starRad += 1;
      }
    } else if (keyCode == SHIFT) {
      shift = true;
    }
  } else if (key == ENTER) {
    enter_pressed();
  } else if (key == BACKSPACE) {
    delete_pressed();
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      shift = false;
    }
  }
}

void enter_pressed() {
  if (scene == "place_dots" || scene == "place_intro") {
    fade_counter = 0;
    text_placed = 0;
    if (destroyed == false) {
      scene = "connect_intro";
    } else {
      scene = "connect_dots";
    }
  } else if (scene == "connect_dots" || scene == "connect_intro") {
    fade_counter = 0;
    text_placed = 0;
    scene ="play_intro";
    if (destroyed) {
      play_scene = 7;
    }
  }
}



void delete_pressed() {
  if (scene == "connect_dots" || scene == "connect_intro") {
    print("delete pressed");
    delete_connection();
  }
}

void menu() {
  updateMenu(mouseX, mouseY);
  background(0);

  //draw buttons
  stroke(255);

  //begin button
  if (beginOver) {
    fill(100);
  } else {
    noFill();
  }
  rect(buttonX, beginY, buttonWidth, buttonHeight);

  //quit button
  if (quitOver) {
    fill(100);
  } else {
    noFill();
  }
  rect(buttonX, quitY, buttonWidth, buttonHeight);

  //draw text
  fill(255);
  noStroke();
  textSize(width/70);
  text("BEGIN", buttonX, beginY);
  text("QUIT", buttonX, quitY);
}

void menu_mouse() {
  if (beginOver && destroyed == false) {
    scene = "intro";
  } else if (beginOver && destroyed) {
    scene = "destroyed_intro";
  }
  if (quitOver) {
    exit();
  }
}

void updateMenu(int x, int y) {
  beginOver = overButton(buttonX, beginY, buttonWidth, buttonHeight);
  quitOver = overButton(buttonX, quitY, buttonWidth, buttonHeight);
}







void intro() {
  updateIntro(mouseX, mouseY);
  background(0);

  //draw next button
  stroke(255);
  //begin button
  if (nextOver) {
    fill(100);
  } else {
    noFill();
  }
  rect(nextX, nextY, buttonWidth, buttonHeight);

  //draw text
  fill(255);
  noStroke();
  textSize(width/70);
  text("NEXT", nextX, nextY);


  fill(255, 255, 255, fade_counter*3);
  switch(intro_slide) {
  case 1:
    intro_1();
    break;
  case 2:
    intro_2();
    break;
  case 3:
    intro_3();
    break;
  case 4:
    intro_4();
    break;
  case 5:
    intro_5();
    break;
  case 6:
    intro_6();
    break;
  }

  //increment fade
  if (fade_counter < 255) {
    fade_counter += 1;
  }
}

void updateIntro(int x, int y) {
  nextOver = overButton(nextX, nextY, buttonWidth, buttonHeight);
}

void intro_1() {

  text("You are God.", width/2, height/2);
}

void intro_2() {
  text("This is Your universe.", width/2, height/2);
}

void intro_3() {
  text("You plot the stars and chart their connections.", width/2, height/2);
}

void intro_4() {
  text("You control their birth and death.", width/2, height/2);
}

void intro_5() {
  text("So pay attention. Don't be careless.", width/2, height/2);
}

void intro_6() {
  text("Let's begin.", width/2, height/2);
}

void intro_mouse() {
  if (nextOver && intro_slide < 6) {
    intro_slide += 1;
    fade_counter = 0;
  } else if (nextOver && intro_slide == 6) {
    intro_slide = 1;
    scene = "place_intro";
    fade_counter = 0;
  }
}






void place_intro() {
  updatePlace(mouseX, mouseY);
  background(0);
  noStroke();
  textSize(width/70);
  textAlign(LEFT, CENTER);
  
  print(text_placed);
  if (text_placed == 0) {
    fill(255, 255, 255, fade_counter*3/2);
    text("Click to birth a star.", text_width, text_height);
  } else if (text_placed == 1) {
    fill(255);
    text("Click to birth a star.", text_width, text_height);
    fill(255, 255, 255, fade_counter*3/2);
    text("Hold arrow keys to change its color and size.", text_width, text_height + width/70*3/2);
  } else if (text_placed == 2) {
    fill(255);
    text("Click to birth a star.", text_width, text_height);
    text("Hold arrow keys to change its color and size.", text_width, text_height + width/70*3/2);
    fill(255, 255, 255, fade_counter*3/2);
    text("Shift-click to kill a star.", text_width, text_height + width/70*6/2);
  } else if (text_placed == 3) {
    fill(255);
    text("Click to birth a star.", text_width, text_height);
    text("Hold arrow keys to change its color and size.", text_width, text_height + width/70*3/2);
    text("Shift-click to kill a star.", text_width, text_height + width/70*6/2);
    fill(255, 255, 255, fade_counter*3/2);
    text("Press Enter when you're done placing stars.", text_width, text_height + width/70*9/2);
  } else if (text_placed == 4) {
    fill(255);
    text("Click to birth a star.", text_width, text_height);
    text("Hold arrow keys to change its color and size.", text_width, text_height + width/70*3/2);
    text("Shift-click to kill a star.", text_width, text_height + width/70*6/2);
    text("Press Enter when you're done placing stars.", text_width, text_height + width/70*9/2);
  } else if (text_placed == 5) {
    fill(255, 255, 255, fade_counter*3/2);
    text("Click to birth a star.", text_width, text_height);
    text("Hold arrow keys to change its color and size.", text_width, text_height + width/70*3/2);
    text("Shift-click to kill a star.", text_width, text_height + width/70*6/2);
    text("Press Enter when you're done placing stars.", text_width, text_height + width/70*9/2);
  }

  
  if (fade_counter < 400 && text_placed < 5) {
   fade_counter += 2;
    println(fade_counter);
  } 
  
  if (text_placed == 0 && stars.size()==1){
    text_placed = 1;
    fade_counter = 0;
  }
  
  else if (text_placed == 1 && stars.size() == 2){
    text_placed = 2;
    fade_counter = 0;
  }
  
  else if (text_placed == 2 && stars.size() == 1){
    text_placed = 3;
    fade_counter = 0; 
  }
  
  else if (fade_counter >= 400 && text_placed == 3) {
    fade_counter = 0;
    text_placed += 1;
  } 
  else if (fade_counter >= 300 && text_placed == 4) {
    text_placed += 1;
  }
  if (fade_counter > 0 && text_placed == 5) {
    fade_counter -= 2;
  } else if (fade_counter <= 0 && text_placed == 5) {
    scene = "place_dots";
  }


  for (int i = 0; i < stars.size(); i++) {
    int h = stars.get(i).h;
    int s = stars.get(i).s;
    int b = stars.get(i).b;
    int x = stars.get(i).x;
    int y = stars.get(i).y;
    int rad = stars.get(i).rad;
    colorMode(HSB, 400);
    fill(h, s, b);
    circle(x, y, rad);
    colorMode(RGB, 255);
  }

  if (shift == false) {
    colorMode(HSB, 400);
    fill(starH, starS, starB);
    circle(mouseX, mouseY, starRad);
    colorMode(RGB, 255);
  }
}







void place_dots() {
  updatePlace(mouseX, mouseY);
  background(0);

  for (int i = 0; i < stars.size(); i++) {
    int h = stars.get(i).h;
    int s = stars.get(i).s;
    int b = stars.get(i).b;
    int x = stars.get(i).x;
    int y = stars.get(i).y;
    int rad = stars.get(i).rad;
    colorMode(HSB, 400);
    fill(h, s, b);
    circle(x, y, rad);
    colorMode(RGB, 255);
  }

  if (shift == false) {
    colorMode(HSB, 400);
    fill(starH, starS, starB);
    circle(mouseX, mouseY, starRad);
    colorMode(RGB, 255);
  }
}

void updatePlace(int x, int y) {

  //get overlaps between potential new star and already placed stars
  if (shift == false) {
    overStar = new ArrayList<Boolean>();
    for (int i = 0; i < stars.size(); i++) {
      int sx = stars.get(i).x;
      int sy = stars.get(i).y;
      int sr = stars.get(i).rad;
      float disX = sx - x;
      float disY = sy - y;
      if (sqrt(sq(disX) + sq(disY)) < (starRad + sr)/2) {
        overStar.add(true);
      }
    }
    if (overStar.size() > 0) {
      overStarFr = true;
    } else {
      overStarFr = false;
    }
  }


  //get overlaps between mouse and already placed stars
  else if (shift) {
    overStarDel = new ArrayList<Boolean>();
    for (int i = 0; i < stars.size(); i++) {
      int sx = stars.get(i).x;
      int sy = stars.get(i).y;
      int sr = stars.get(i).rad;
      float disX = sx - x;
      float disY = sy - y;
      if (sqrt(sq(disX) + sq(disY)) < sr/2) {
        overStarDel.add(true);
        starForDel = i;
      }
    }
    if (overStarDel.size() > 0) {
      overStarDelFr = true;
    } else {
      overStarDelFr = false;
    }
  }
}

void place_dots_mouse() {
  if (shift == false && overStarFr == false) {
    Integer number = stars.size();
    String id = "obj-" + number.toString();
    Star new_star = new Star(mouseX, mouseY, starH, starS, starB, starRad, id);
    stars.add(new_star);
  } 
  else if (shift == true && overStarDelFr == true) {
    stars.remove(starForDel);
  }
}





void connect_intro() {
  updateConnect(mouseX, mouseY);
  background(0);

  //draw stars
  for (int i = 0; i < stars.size(); i++) {
    int h = stars.get(i).h;
    int s = stars.get(i).s;
    int b = stars.get(i).b;
    int x = stars.get(i).x;
    int y = stars.get(i).y;
    int rad = stars.get(i).rad;
    colorMode(HSB, 400);
    fill(h, s, b);
    circle(x, y, rad);
    colorMode(RGB, 255);
  }

  //draw connections
  for (int i = 0; i < connections.size(); i++) {
    connections.get(i).draw_c();
  }

  //set up text
  noStroke();
  textSize(width/70);
  textAlign(LEFT, CENTER);
  //draw text
  if (text_placed == 0) {
    fill(0, 0, 0, fade_counter*3/2);
    rect(text_width + textWidth("Click on stars to connect them.")/2, text_height, textWidth("Click on stars to connect them."), width/70);
    fill(255, 255, 255, fade_counter*3/2);
    text("Click on stars to connect them.", text_width, text_height);
  } else if (text_placed == 1) {
    fill(0);
    rect(text_width + textWidth("Click on stars to connect them.")/2, text_height, textWidth("Click on stars to connect them."), width/70);
    fill(255);
    text("Click on stars to connect them.", text_width, text_height);
    fill(0, 0, 0, fade_counter*3/2);
    rect(text_width + textWidth("Press backspace to sever connections.")/2, text_height + width/70*3/2, textWidth("Press backspace to sever connections."), width/70);
    fill(255, 255, 255, fade_counter*3/2);
    text("Press backspace to sever connections.", text_width, text_height + width/70*3/2);
  } else if (text_placed == 2) {
    fill(0);
    rect(text_width + textWidth("Click on stars to connect them.")/2, text_height, textWidth("Click on stars to connect them."), width/70);
    rect(text_width + textWidth("Press backspace to sever connections.")/2, text_height + width/70*3/2, textWidth("Press backspace to sever connections."), width/70);
    fill(255);
    text("Click on stars to connect them.", text_width, text_height);
    text("Press backspace to sever connections.", text_width, text_height + width/70*3/2);

    fill(0, 0, 0, fade_counter*3/2);
    rect(text_width + textWidth("Press Enter when you're done connecting stars.")/2, text_height + width/70*6/2, textWidth("Press Enter when you're done connecting stars."), width/70);
    fill(255, 255, 255, fade_counter*3/2);
    text("Press Enter when you're done connecting stars.", text_width, text_height + width/70*6/2);
  } else if (text_placed == 3) {
    fill(0);
    rect(text_width + textWidth("Click on stars to connect them.")/2, text_height, textWidth("Click on stars to connect them."), width/70);
    rect(text_width + textWidth("Press backspace to sever connections.")/2, text_height + width/70*3/2, textWidth("Press backspace to sever connections."), width/70);
    rect(text_width + textWidth("Press Enter when you're done connecting stars.")/2, text_height + width/70*6/2, textWidth("Press Enter when you're done connecting stars."), width/70);
    fill(255);
    text("Click on stars to connect them.", text_width, text_height);
    text("Press backspace to sever connections.", text_width, text_height + width/70*3/2);
    text("Press Enter when you're done connecting stars.", text_width, text_height + width/70*6/2);
  } else if (text_placed == 4) {
    fill(0, 0, 0, fade_counter*3/2);
    rect(text_width + textWidth("Click on stars to connect them.")/2, text_height, textWidth("Click on stars to connect them."), width/70);
    rect(text_width + textWidth("Press backspace to sever connections.")/2, text_height + width/70*3/2, textWidth("Press backspace to sever connections."), width/70);
    rect(text_width + textWidth("Press Enter when you're done connecting stars.")/2, text_height + width/70*6/2, textWidth("Press Enter when you're done connecting stars."), width/70);
    fill(255, 255, 255, fade_counter*3/2);
    text("Click on stars to connect them.", text_width, text_height);
    text("Press backspace to sever connections.", text_width, text_height + width/70*3/2);
    text("Press Enter when you're done connecting stars.", text_width, text_height + width/70*6/2);
  }


  if (fade_counter < 400 && text_placed < 4) {
    fade_counter += 2;
  }
  
  
  if (text_placed == 0 && star_order.size()==2){
    text_placed = 1;
    fade_counter = 0; 
  }
  
  else if (text_placed == 1 && star_order.size() == 1){
    text_placed = 2;
    fade_counter = 0;
  }
  
  else if (fade_counter >= 300 && text_placed == 3) {
    text_placed += 1;
  }

  if (fade_counter > 0 && text_placed == 4) {
    fade_counter -= 2;
  } else if (fade_counter <= 0 && text_placed == 4) {
    scene = "connect_dots";
  }

  //draw circle for stars being hovered over
  if (overStarDelFr) {
    int x = stars.get(starForDel).x;
    int y = stars.get(starForDel).y;
    int r = stars.get(starForDel).rad;
    colorMode(RGB, 255);
    stroke(255);
    strokeWeight(3);
    noFill();
    circle(x, y, r);
    noStroke();
  }

  //draw thick circle around last star
  if (star_order.size() > 0) {
    push();
    stroke(255);
    strokeWeight(3);
    noFill();

    Star star = stars.get(prevStarForDel);
    circle(star.x, star.y, star.rad);
    pop();
  }
}







void connect_dots() {
  updateConnect(mouseX, mouseY);
  background(0);
  for (int i = 0; i < stars.size(); i++) {
    int h = stars.get(i).h;
    int s = stars.get(i).s;
    int b = stars.get(i).b;
    int x = stars.get(i).x;
    int y = stars.get(i).y;
    int rad = stars.get(i).rad;
    colorMode(HSB, 400);
    fill(h, s, b);
    circle(x, y, rad);
    colorMode(RGB, 255);
  }


  //draw connections
  for (int i = 0; i < connections.size(); i++) {
    connections.get(i).draw_c();
  }

  //draw circle for stars being hovered over
  if (overStarDelFr) {
    int x = stars.get(starForDel).x;
    int y = stars.get(starForDel).y;
    int r = stars.get(starForDel).rad;
    colorMode(RGB, 255);
    stroke(255);
    strokeWeight(2);
    noFill();
    circle(x, y, r);
    noStroke();
  }

  //draw thick circle around last star
  if (star_order.size() > 0) {
    push();
    stroke(255);
    strokeWeight(3);
    noFill();

    Star star = stars.get(prevStarForDel);
    circle(star.x, star.y, star.rad);
    pop();
  }
}



void connect_dots_mouse() {

  if (overStarDelFr && star_order.size() == 0) {
    star_order.add(starForDel); //add star index to star order
    prevStarForDel = starForDel;
  } else if (overStarDelFr && starForDel != prevStarForDel) {

    boolean is_duplicate = is_duplicate_connection(starForDel, prevStarForDel);

    if (is_duplicate == false) {
      //get new star to be connected
      Star new_star_connected = stars.get(starForDel);
      star_order.add(starForDel); //add star index to star order

      //make connection to prev
      Star prev_star_connected = stars.get(prevStarForDel);
      Connection new_connection = new Connection(new_star_connected, prev_star_connected);
      connections.add(new_connection);

      //add pair to pairs list
      ArrayList<Integer> new_pair = new ArrayList<Integer>();
      new_pair.add(starForDel);
      new_pair.add(prevStarForDel);
      pairs.add(new_pair);

      prevStarForDel = starForDel;

      print(star_order);
      println(pairs);
    }
  }
}

void delete_connection() {
  if (star_order.size() > 1) {
    prevStarForDel = star_order.get(star_order.size() - 2);
    pairs.remove(pairs.size()-1);
    star_order.remove(star_order.size()-1);
    connections.remove(connections.size()-1);

    print(star_order);
    print(pairs);
  } else if (star_order.size() == 1) {
    star_order.remove(0);
  }
}

boolean is_duplicate_connection(int ind1, int ind2) {

  for (int i = 0; i < pairs.size(); i++) {
    int pair1 = pairs.get(i).get(0);
    int pair2 = pairs.get(i).get(1);

    if ((pair1 == ind1 && pair2 == ind2) || (pair1 == ind2 && pair2 == ind1)) {
      return true;
    }
  }

  return false;
}

void updateConnect(int x, int y) {
  //get overlaps between mouse and already placed stars
  overStarDel = new ArrayList<Boolean>();
  for (int i = 0; i < stars.size(); i++) {
    int sx = stars.get(i).x;
    int sy = stars.get(i).y;
    int sr = stars.get(i).rad;
    float disX = sx - x;
    float disY = sy - y;
    if (sqrt(sq(disX) + sq(disY)) < sr/2) {
      overStarDel.add(true);
      starForDel = i;
    }
  }
  if (overStarDel.size() > 0) {
    overStarDelFr = true;
  } else {
    overStarDelFr = false;
  }
}










void play_intro(boolean text_on) {
  updatePlayIntro(mouseX, mouseY);
  background(0);


  for (int i = 0; i < stars.size(); i++) {
    int h = stars.get(i).h;
    int s = stars.get(i).s;
    int b = stars.get(i).b;
    int x = stars.get(i).x;
    int y = stars.get(i).y;
    int rad = stars.get(i).rad;
    colorMode(HSB, 400);
    fill(h, s, b);
    circle(x, y, rad);
    colorMode(RGB, 255);
  }

  //draw connections
  for (int i = 0; i < connections.size(); i++) {
    connections.get(i).draw_c();
  }

  if (text_on){
    //draw next button
    stroke(255);
    strokeWeight(1);
    //begin button
    if (nextOver) {
      fill(100);
    } else {
      fill(0);
    }
    rect(nextX, nextY, buttonWidth, buttonHeight);
  
    //draw next button text
    textAlign(CENTER, CENTER);
    fill(255);
    noStroke();
    textSize(width/70);
    if (play_scene == 7) {
      text("BEGIN", nextX, nextY);
    } else {
      text("NEXT", nextX, nextY);
    }
  
  
    //draw message
    switch(play_scene) {
    case 0:
      play_0();
      break;
    case 1:
      play_1();
      break;
    case 2:
      play_2();
      break;
    case 3:
      play_3();
      break;
    case 4:
      play_4();
      break;
    case 5:
      play_5();
      break;
    case 6:
      play_6();
      break;
    case 7:
      play_7();
      break;
    }
    //draw destroy button
    if (play_scene > 3) {
      stroke(255);
      strokeWeight(1);
      if (destroyOver) {
        fill(100);
      } else {
        fill(0);
      }
      rect(destroyX, destroyY, buttonWidth, buttonHeight);
  
      //draw text
      textAlign(CENTER, CENTER);
      fill(255);
      noStroke();
      textSize(width/70);
      text("DESTROY", destroyX, destroyY);
    }
  }

  if (fade_counter < 255) {
    fade_counter += 1;
  }



  
}

void play_0() {
  fill(0, 0, 0, fade_counter*3);
  rect(width/2, height/2, textWidth("Congratulations. You've filled Your universe."), width/70);
  fill(255, 255, 255, fade_counter*3);
  text("Congratulations. You've filled Your universe.", width/2, height/2);
}

void play_1() {
  fill(0, 0, 0, fade_counter*3);
  rect(width/2, height/2, textWidth("You've birthed stars and charted their connections."), width/70);
  fill(255, 255, 255, fade_counter*3);
  text("You've birthed stars and charted their connections.", width/2, height/2);
}

void play_2() {
  fill(0, 0, 0, fade_counter*3);
  rect(width/2, height/2, textWidth("Now it's time to set Your creations in motion."), width/70);
  fill(255, 255, 255, fade_counter*3);
  text("Now it's time to set Your creations in motion.", width/2, height/2);
}

void play_3() {
  fill(0, 0, 0, fade_counter*3);
  rect(width/2, height/2, textWidth("But know this: once in motion, they will not stop..."), width/70);
  fill(255, 255, 255, fade_counter*3);
  text("But know this: once in motion, they will not stop...", width/2, height/2);
}

void play_4() {
  fill(0, 0, 0, fade_counter*3);
  rect(width/2, height/2, textWidth("...unless You destroy this universe and start anew."), width/70);
  fill(255, 255, 255, fade_counter*3);
  text("...unless You destroy this universe and start anew.", width/2, height/2);
}

void play_5() {
  fill(0, 0, 0, fade_counter*3);
  rect(width/2, height/2, textWidth("So choose carefully."), width/70);
  fill(255, 255, 255, fade_counter*3);
  text("So choose carefully.", width/2, height/2);
}

void play_6() {
  fill(0, 0, 0, fade_counter*3);
  rect(width/2, height/2, textWidth("They're inert, for now. You can still start over."), width/70);
  fill(255, 255, 255, fade_counter*3);
  text("They're inert, for now. You can still start over.", width/2, height/2);
}

void play_7() {
  fill(0, 0, 0, fade_counter*3);
  rect(width/2, height/2, textWidth("Make Your choice."), width/70);
  fill(255, 255, 255, fade_counter*3);
  text("Make Your choice.", width/2, height/2);
}

void updatePlayIntro(int x, int y) {
  nextOver = overButton(nextX, nextY, buttonWidth, buttonHeight);
  destroyOver = overButton(destroyX, destroyY, buttonWidth, buttonHeight);
}

void play_intro_mouse() {
  if (nextOver && play_scene < 7) {
    play_scene += 1;
    fade_counter = 0;
  } 
  else if (nextOver && play_scene == 7) {
    play_scene = 1;
    scene = "play_start";
    fade_counter = 255;
    print(scene);
    
    OscMessage myOscMessage = new OscMessage("/endnoise");
    myOscMessage.add("1");
    oscP5.send(myOscMessage, maxBroadcastLocation);
    
    OscMessage myOscMessage2 = new OscMessage("/numStars");
    myOscMessage2.add(stars.size());
    oscP5.send(myOscMessage2, pyBroadcastLocation);
    ///
    ///
    ///
    /// SEND NUM_STARS TO PYTHON HERE!!!!!!!
    ///
    ///  use maxpy to create that many routes & voices
    ///
  }
  
  if (destroyOver) {
    scene = "destroy";
    destroy_prev = "intro";
    OscMessage myOscMessage = new OscMessage("/endnoise");
    myOscMessage.add("1");
    oscP5.send(myOscMessage, maxBroadcastLocation);
    OscMessage myOscMessage2 = new OscMessage("/destroy");
    myOscMessage2.add("1");
    oscP5.send(myOscMessage2, maxBroadcastLocation);
  }
}





void destroyed_intro() {
  updateIntro(mouseX, mouseY);
  background(0);

  //draw next button
  stroke(255);
  //begin button
  if (nextOver) {
    fill(100);
  } else {
    noFill();
  }
  rect(nextX, nextY, buttonWidth, buttonHeight);

  //draw text
  fill(255);
  noStroke();
  textSize(width/70);
  text("NEXT", nextX, nextY);


  fill(255, 255, 255, fade_counter*3);
  text("You know how this works.", width/2, height/2);

  //increment fade
  if (fade_counter < 255) {
    fade_counter += 1;
  }
}

void destroyed_mouse() {
  if (nextOver) {
    scene = "place_dots";
    fade_counter = 0;
  }
}








void play_start() {
  updatePlay(mouseX, mouseY);
  background(0);

  //draw destroy button
  stroke(255);
  strokeWeight(1);
  if (destroyOver) {
    fill(100);
  } else {
    noFill();
  }
  rect(destroyX, destroyY, buttonWidth, buttonHeight);

  //draw text
  textAlign(CENTER, CENTER);
  fill(255);
  noStroke();
  textSize(width/70);
  text("DESTROY", destroyX, destroyY);

  //fade out stars & connections
  for (int i = 0; i < stars.size(); i++) {
    int h = stars.get(i).h;
    int s = stars.get(i).s;
    int b = stars.get(i).b;
    int x = stars.get(i).x;
    int y = stars.get(i).y;
    int rad = stars.get(i).rad;
    colorMode(HSB, 400, 400, 400, 255);
    fill(h, s, b, fade_counter);
    circle(x, y, rad);
    colorMode(RGB, 255);
  }

  //draw connections
  for (int i = 0; i < connections.size(); i++) {
    connections.get(i).draw_alpha(fade_counter);
  }

  if (fade_counter > 0) {
    fade_counter -= 2;
  }
  if (fade_counter <= 0) {
    fade_counter = 0;
    scene = "wait";
  }
}

void wait_play(){
  updatePlay(mouseX, mouseY);
  background(0);
  //draw destroy button
  stroke(255);
  strokeWeight(1);
  if (destroyOver) {
    fill(100);
  } else {
    noFill();
  }
  rect(destroyX, destroyY, buttonWidth, buttonHeight);
  
   //draw text
  textAlign(CENTER, CENTER);
  fill(255);
  noStroke();
  textSize(width/70);
  text("DESTROY", destroyX, destroyY);
  
  if (fade_counter < 200){
    fade_counter += 1;
  }
  else if (fade_counter >= 200){
    fade_counter = 0;
    scene = "playing";
    stars_playing.add(0);
  }
}


void play(boolean destroy_on) {
  updatePlay(mouseX, mouseY);
  background(0);

  if (destroy_on){
    //draw destroy button
    stroke(255);
    strokeWeight(1);
    if (destroyOver) {
      fill(100);
    } else {
      noFill();
    }
    rect(destroyX, destroyY, buttonWidth, buttonHeight);
  
    //draw text
    textAlign(CENTER, CENTER);
    fill(255);
    noStroke();
    textSize(width/70);
    text("DESTROY", destroyX, destroyY);
  }


  //make stars show up, faded first
  for (int i = 0; i < stars_playing.size(); i++) {
    int ind = stars_playing.get(i);
    Star star = stars.get(ind);
    star.appear();
  }
  if (stars.get(stars_playing.get(stars_playing.size()-1)).appeared && stars_playing.size() < stars.size()) {
    stars_playing.add(stars_playing.size());
  }
  
  
  if (stars_playing.size() == stars.size() && stars.get(stars.size()-1).appeared){
    //make stars connect
    
    //add first star if no stars connected 
    if (stars_connected.size() == 0){
      stars_connected.add(star_order.get(0));
      connections_loaded.add(connections.get(0));
      //stars.get(stars_connected.get(0)).display_timer = -10000;
    }
    
    //fade in color for connected stars 
    for (int i = 0; i < stars_connected.size(); i++) {
      int ind = stars_connected.get(i);
      Star star = stars.get(ind);
      star.connect();
    }
    
    //fade in color for connected lines
    for (int i = 0; i < connections_loaded.size();i++){
      connections_loaded.get(i).load();
    }
    
    //draw connected lines
    for (int i = 0; i < connections_playing.size(); i++){
      connections_playing.get(i).animate();
    }
    

    //add next connection if prev star finished connecting 
    if (stars.get(stars_connected.get(stars_connected.size()-1)).connected && stars_connected.size() < star_order.size() && connection_connecting == false) {
      connections_playing.add(connections.get(stars_connected.size()-1));
      println("added connection to connections_playing");
      //connections_playing.get(connections_playing.size()-1).display_timer = 0;
      connection_connecting = true;
      //stars_connected.add(star_order.get(stars_connected.size()));
    }
    
    
    else if (stars.get(stars_connected.get(stars_connected.size()-1)).connected && stars_connected.size() < star_order.size() && connections_playing.get(connections_playing.size()-1).animated) {
      connection_connecting = false;
      //if (stars_connected.size() >= 1){
      //  stars.get(stars_connected.get(stars_connected.size()-1)).display_timer = 256/2; 
      //}
      stars_connected.add(star_order.get(stars_connected.size()));
      if (stars_connected.size() != star_order.size()){
        connections_loaded.add(connections.get(stars_connected.size()-1));
      }
      
      //stars.get(stars_connected.get(stars_connected.size()-1)).display_timer = -10000;
       
    }
    
  
    //ping stars
    for (int i = 0; i < connections_playing.size(); i++){
      if (connections_playing.get(i).ping_start){
        stars.get(star_order.get(i+1)).pinged = true; 
      }
      if (connections_playing.get(i).ping_end){
        stars.get(star_order.get(i)).pinged = true;
      }
    }
  }
  
}


void play_mouse() {
  if (destroyOver) {
    scene = "destroy";
    destroy_prev = "play";
    OscMessage myOscMessage = new OscMessage("/endnoise");
    myOscMessage.add("1");
    oscP5.send(myOscMessage, maxBroadcastLocation);
    OscMessage myOscMessage2 = new OscMessage("/destroy");
    myOscMessage2.add("1");
    oscP5.send(myOscMessage2, maxBroadcastLocation);
  }
}

void destroy(){
  if (destroy_counter < 200){
    if (destroy_triggered == false){
      switch(destroy_prev){
        case "play":
          play(false);
          break;
        case "intro":
          play_intro(false);
          break;
          
      }
      destroy_triggered = true;
    }
    
    //if (destroy_counter > 10){
      fill(255, 255, 255, sq(destroy_counter/20));
      rectMode(CENTER);
      rect(width/2, height/2, width, height); 
    //}
    
    //text("destroying", width/2, height/2);
    destroy_counter += 1;
  }
  else{
    play_scene = 1;
    fade_counter = 0;
    scene = "menu";
    stars.clear();
    star_order.clear();
    pairs.clear();
    connections.clear();
    stars_playing.clear();
    connections_playing.clear();
    stars_connected.clear();
    connections_loaded.clear();
    connection_connecting = false; 
    destroyed = true;
    destroy_counter = 0;
    destroy_triggered = false;
    OscMessage myOscMessage = new OscMessage("/startnoise");
    myOscMessage.add("1");
    oscP5.send(myOscMessage, maxBroadcastLocation);
  }
}

void updatePlay(int x, int y) {
  destroyOver = overButton(destroyX, destroyY, buttonWidth, buttonHeight);
}


void exit(){
  OscMessage myOscMessage = new OscMessage("/endnoise");
  myOscMessage.add("1");
  oscP5.send(myOscMessage, maxBroadcastLocation);
  super.exit();
}
