const int pin = 10;
int state = 48;

void setup() {
  // put your setup code here, to run once:
  pinMode(pin,OUTPUT);

  Serial.begin(115200);

}
// open the serial thing (top right). type any letter and press enter to 
// open the valve. Enter 0 to close the valve.
void loop() {
  // put your main code here, to run repeatedly:
  if (Serial.available() > 0) {
    state = Serial.read();
    Serial.read();
    Serial.read();
  }
  if (state == 48) {
    digitalWrite(pin,LOW);
    Serial.println(state);
    Serial.println(" valve CLOSED");
  }
  else {
    digitalWrite(pin,HIGH);
    Serial.println(state);
    Serial.println(" valve OPEN");
  }

}
