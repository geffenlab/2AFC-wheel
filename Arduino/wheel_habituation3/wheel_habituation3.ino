//From bildr article: http://bildr.org/2012/08/rotary-encoder-arduino/

//these pins can not be changed 2/3 are special pins
int encoderPin1 = 2;
int encoderPin2 = 3;
int solenoidOut = 9;

// IMPORTANT VARIABLES
int rotaryDebounce = 5; // arbitrary number
int rewardTime = 50;  // duration of solenoid opening ms
int holdTime = 350;   // how long mouse must wait before trial starts ms

volatile int lastEncoded = 0;
volatile long encoderValue = 0;

long lastencoderValue = 0;

int lastMSB = 0;
int lastLSB = 0;
int LR = 2;

unsigned long time;
int val;
int hState = 0;             // defines which behavioural state you are in
int soundCardInput = 5;       // 2nd channel from sound card
int sc = LOW;
long rotaryPos = 0;
int rotaryLastStateA = LOW;
int rotaryLastStateB = LOW;
int n = LOW;
int rb = LOW;
int dir;
unsigned long t1;
unsigned long bstate1timer = 0;        // previous state for the bstate 1 timer
unsigned long bstate5timer = 0;       // previous state for the bstate 5 timer timeout
int timeOut = 5000;
int trialType;
long oldRotaryPos = 0;
int start = 1;
int count = 0;

void setup() {
  //  pinMode (rotaryInputA, INPUT);
  //  pinMode (rotaryInputB, INPUT);
  pinMode (soundCardInput, INPUT);
  Serial.begin (9600);
  // check serial comm - acknowledgement routine
  Serial.println('a'); // send a character to matlab
  char a = 'b';
  while (a != 'a')
  {
    // Wait for matlab to send specific character to arduino
    a = Serial.read();
  }
  //Serial.flush();
  Serial.println("ready");

  // retrieve parameters from matlab
  int done = 0;
  int val[3];
  int cnt = 0;
  while (!done) {
    while (Serial.available() > 0) {
      val[cnt] = Serial.parseInt();
      Serial.println(val[cnt]);
      cnt++;
      Serial.println(cnt);
      if (cnt > 2) {
        done = 1;
        rewardTime = val[0];
        holdTime = val[1];
        rotaryDebounce = val[2];

        Serial.print("REWTIME ");
        Serial.println(val[1]);
        Serial.print("TOTIME ");
        Serial.println(val[2]);
        Serial.print("DEBOUNCE ");
        Serial.println(val[3]);
        break;
      }
    }
  }



  pinMode(encoderPin1, INPUT);
  pinMode(encoderPin2, INPUT);
  pinMode(solenoidOut, OUTPUT);

  digitalWrite(encoderPin1, HIGH); //turn pullup resistor on
  digitalWrite(encoderPin2, HIGH); //turn pullup resistor on

  //call updateEncoder() when any high/low changed seen
  //on interrupt 0 (pin 2), or interrupt 1 (pin 3)
  attachInterrupt(0, updateEncoder, CHANGE);
  attachInterrupt(1, updateEncoder, CHANGE);

  delay(100);
  Serial.println("start");
  // connection established so move to loop
  hState = 1;
}

void loop() {


  // MONITOR WHEEL INPUT UNTIL NOT MOVED FOR HOLDTIME DURATION
  //  Serial.println("arduinoCase2");
  switch (hState) {
    case 1:

      oldRotaryPos = encoderValue;
      bstate1timer = 0;
      t1 = millis();
      while ((long) (bstate1timer - t1) < holdTime) {
        // wait for the mouse to not move the wheel for the hold time duration
        bstate1timer = millis();
        rotaryPos = encoderValue;
        if (rotaryPos != oldRotaryPos) {
          t1 = millis();
          oldRotaryPos = rotaryPos;
        }
      }
      oldRotaryPos = encoderValue;
      rotaryPos = oldRotaryPos;
      hState = 2;
      break;

    case 2:

      //        Serial.print("HoldTime");
      //        Serial.print("\t");
      //      Serial.println(oldRotaryPos);
      //while (oldRotaryPos == rotaryPos) {
      while (rotaryPos < oldRotaryPos + rotaryDebounce & rotaryPos > oldRotaryPos - rotaryDebounce) {
        rotaryPos = encoderValue;
      }
      //      Serial.println(LR);
      //      Serial.println(rotaryPos);

      // Give reward if correct direction else return to hstate1

      if (rotaryPos < oldRotaryPos && LR == 1) {  // if moved right
        time = micros();
        Serial.println(time);
        digitalWrite(solenoidOut, HIGH); //open the solenoid
        delay(rewardTime);
        digitalWrite(solenoidOut, LOW); //close the solenoid
        Serial.println(rotaryPos);
        count = count + 1;
        Serial.println(count);
        LR = 0;

      } else if (rotaryPos > oldRotaryPos && LR == 0) { // if moved left
        time = micros();
        Serial.println(time);
        digitalWrite(solenoidOut, HIGH); //open the solenoid
        delay(rewardTime);
        digitalWrite(solenoidOut, LOW); //close the solenoid
        LR = 1;
        Serial.println(rotaryPos);
        count = count + 1;
        Serial.println(count);
      } else if (LR == 2) {
        time = micros();
        Serial.println(time);
        digitalWrite(solenoidOut, HIGH); //open the solenoid
        delay(rewardTime);
        digitalWrite(solenoidOut, LOW); //close the solenoid
        LR = (rotaryPos < oldRotaryPos);
        Serial.println(rotaryPos);
        count = count + 1;
        Serial.println(count);
      }

      t1 = millis();
      hState = 1;

      break;
  }
}




void updateEncoder() {
  int MSB = digitalRead(encoderPin1); //MSB = most significant bit
  int LSB = digitalRead(encoderPin2); //LSB = least significant bit

  int encoded = (MSB << 1) | LSB; //converting the 2 pin value to single number
  int sum  = (lastEncoded << 2) | encoded; //adding it to the previous encoded value

  if (sum == 0b1101 || sum == 0b0100 || sum == 0b0010 || sum == 0b1011) encoderValue ++;
  if (sum == 0b1110 || sum == 0b0111 || sum == 0b0001 || sum == 0b1000) encoderValue --;

  lastEncoded = encoded; //store this value for next time
}
