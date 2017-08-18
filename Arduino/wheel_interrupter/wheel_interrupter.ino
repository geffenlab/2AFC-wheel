//From bildr article: http://bildr.org/2012/08/rotary-encoder-arduino/

// ASSIGN PINS
//these pins can not be changed 2/3 are special pins
int encoderPin1 = 2;
int encoderPin2 = 3;
int solenoidOut = 9;
int soundCardInput = 5;       // 2nd channel from sound card

volatile int lastEncoded = 0;
volatile long encoderValue = 0;

long lastencoderValue = 0;

int lastMSB = 0;
int lastLSB = 0;

unsigned long time;
int val;
int bstate = 0;             // defines which behavioural state you are in

int sc = LOW;
long rotaryPos = 0;
int rotaryLastStateA = LOW;
int rotaryLastStateB = LOW;
int n = LOW;
int rb = LOW;
int dir;
unsigned long t1;
int holdTime = 1000;               // how long mouse must wait before trial starts
unsigned long bstate1timer = 0;        // previous state for the bstate 1 timer
unsigned long bstate5timer = 0;       // previous state for the bstate 5 timer timeout
int timeOut = 5000;
int trialType;
long oldRotaryPos = 0;
int start = 1;


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
  Serial.flush();



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
  bstate = 1; // connection established so move to behavioural state 1

}

void loop() {
  switch (bstate) {

    case 1: // RECEIVE TRIAL TYPE FROM MATLAB
      // receive input from matlab saying the type of trial it is

      if (Serial.available() > 0) {
        //   Serial.println("arduinoCase1");
        // read the incoming byte:
        trialType = Serial.read();
        // tell matlab received

        Serial.println(trialType);
        bstate = 2;
      }

      break;

    case 2: // MONITOR WHEEL INPUT UNTIL NOT MOVED FOR HOLDTIME DURATION
      //  send serial com to matlab to intiate sound presentation


      //  Serial.println("arduinoCase2");
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
      //        Serial.print("HoldTime");
      //        Serial.print("\t");
      time = micros();
      Serial.println(time);
      //  Serial.println("wheel not moved for 1 s");
      bstate = 3;


      break;

    case 3: // MONITOR DIGITAL INPUT X FOR SOUND CARD INPUT TO SAY SOUND PRESENTED



      sc = digitalRead(soundCardInput); // read the input from sound card

      if (sc == LOW) { // if it is low, wait for it to be high

        sc = digitalRead(soundCardInput);

      } else { // once high, wait for it to go low again! i.e. wait for the sound to finish
        time = micros();
        Serial.println(time);
        
        while (sc == HIGH) {
          sc = digitalRead(soundCardInput);
        }

        time = micros();
        Serial.println(time);
        //   Serial.println("sound input received");
        bstate = 4;
      }

      break;

    case 4: // MONITOR THE WHEEL FOR RESPONSE

      oldRotaryPos = encoderValue;
      rotaryPos = oldRotaryPos;

      while (rotaryPos == oldRotaryPos) {
        rotaryPos = encoderValue;
        //   Serial.println(trialType);
      }
      time = micros();
      Serial.println (time);

      if (rotaryPos < oldRotaryPos) {
        //       Serial.println(oldRotaryPos);
        //        Serial.println(rotaryPos);
        if (trialType == 49) {
          //INCORRECT TRIAL
          Serial.println (0, DEC);
          bstate = 5; // TIMEOUT
        } else if (trialType == 50) {
          //CORRECT TRIAL
          digitalWrite(solenoidOut, HIGH); //open the solenoid
          delay(100);
          digitalWrite(solenoidOut, LOW); //close the solenoid
          Serial.println (1, DEC);
          Serial.println("start");
          bstate = 1; // RETURN TO BEGINNING
        }

      } else {
        //    Serial.println(oldRotaryPos);
        //     Serial.println(rotaryPos);
        if ( trialType == 50) { 
          //INCORRECT TRIAL
          Serial.println (0, DEC);
          bstate = 5; // TIMEOUT
        } else if (trialType == 49) {
          //CORRECT TRIAL
          digitalWrite(solenoidOut, HIGH); //open the solenoid
          delay(100);
          digitalWrite(solenoidOut, LOW); //close the solenoid
          Serial.println (1, DEC);
          Serial.println("start");
          bstate = 1; // RETURN TO BEGINNING
        }

      }

      break;

    case 5: // TIMEOUT
      //  Serial.println("timeout");
      bstate5timer = 0;
      t1 = millis();
      while ((long) (bstate5timer - t1) < timeOut) {
        bstate5timer = millis();
      }
      Serial.println("start");
      bstate = 1;
      break;

    case 6: // PAUSE AND RECEIVE SOMETHING FROM MATLAB
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
