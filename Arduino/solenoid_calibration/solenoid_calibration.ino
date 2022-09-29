const int pin = 9;
const int rewardTime = 14;
int state = 48; // zero on the keyboard
int i = 1;
void setup() {
  // put your setup code here, to run once:
  pinMode(pin, OUTPUT);
  digitalWrite(pin, LOW);
  Serial.begin(115200);
}

void loop() {
  // put your main code here, to run repeatedly:
  if (Serial.available() > 0) {
    state = Serial.read();
  }
  if (state == 48) {
    digitalWrite(pin, LOW);
    
  }
  else {
    Serial.println(" TESTING valve");
    for (int i = 1; i <= 50; i++) {
      Serial.println(i);
      digitalWrite(pin, HIGH);
      delay(rewardTime);
      digitalWrite(pin, LOW);
      delay(50);
    }
    Serial.println(48);
    state = 48;
    Serial.println(" valve CLOSED");
  }
}
