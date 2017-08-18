const int pin = 9;
int state = 48;

void setup() {
  // put your setup code here, to run once:
  pinMode(pin,OUTPUT);

  Serial.begin(9600);

}

void loop() {
  // put your main code here, to run repeatedly:
  if (Serial.available() > 0) {
    state = Serial.read();
    Serial.read();
    Serial.read();
  }
  if (state == 48) {
    digitalWrite(pin,LOW);
    Serial.print(state);
    Serial.println(" valve CLOSED");
  }
  else {
    digitalWrite(pin,HIGH);
    Serial.print(state);
    Serial.println(" valve OPEN");
  }

}
