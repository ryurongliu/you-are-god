
void setup() {
  Serial.begin(9600);

}

int pot1;
int pot2;

boolean changed = false; 

void loop() {
  // put your main code here, to run repeatedly:
  int read1 = analogRead(A0);
  int read2 = analogRead(A1);
  if(read1 < pot1 - 2 or read1 > pot1 + 2){
    pot1 = read1; 
    changed = true; 
  }
  if(read2 < pot2 - 2 or read2 > pot2 + 2){
    pot2 = read2;
    changed = true; 
  }

  if(changed){
      Serial.print(pot1);
    Serial.print("/");
    Serial.print(pot2);
    Serial.println("/");
    changed = false;
  }

  delay(100);
}
