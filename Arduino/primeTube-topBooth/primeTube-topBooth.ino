const int pin = 8;
int state = 48;
int old_state = 0;

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
  }
  if (state == 48 & old_state != state) {
    digitalWrite(pin,LOW);
    Serial.println(state);
    Serial.println(" valve CLOSED");
    old_state = state;
  }
  else if (state ==49 & old_state != state) {
    digitalWrite(pin,HIGH);
    Serial.println(state);
    Serial.println(" valve OPEN");
    old_state = state;
  }

}
