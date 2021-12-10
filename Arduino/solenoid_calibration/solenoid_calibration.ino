const int pin = 9;
int state = 48;
int i = 1;
void setup() {
  // put your setup code here, to run once:
  pinMode(pin, OUTPUT);

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
    digitalWrite(pin, LOW);
    
  }
  else {
    Serial.println(" TESTING valve");
    for (int i = 1; i <= 50; i++) {
      Serial.println(i);
      digitalWrite(pin, HIGH);
      delay(135);
      digitalWrite(pin, LOW);
      delay(50);
    }
    Serial.println(48);
    state = 48;
    Serial.println(" valve CLOSED");
  }
}
