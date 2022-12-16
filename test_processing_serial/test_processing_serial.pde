import processing.serial.*;

Serial myPort; 
String val; 

int val1;
int val2; 

void setup(){
  
  size(200, 200);
  String portName = Serial.list()[3];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil(10);
}

void draw() {

}

void serialEvent(Serial p){
  val = myPort.readStringUntil('\n');
    if(val != null){
      //println(val);
      int[] vals = int(split(val, '/'));
      if(vals.length > 1){
        println(vals[0], vals[1]);

      }
      
    }
}
