//From bildr article: http://bildr.org/2012/08/rotary-encoder-arduino/

// ASSIGN PINS
//these pins can not be changed 2/3 are special pins
int solenoidOut = 9;
int soundCardInput = 5;       // 2nd channel from sound card with events
// int lickInput = 7;

// timing variables:
float rotaryDebounce;      // arbitrary number - how far the wheel needs to exceed previous position to count as moved
float timeOut;            // ms
float holdTimeMin;           // how long mouse must wait before trial starts min
float holdTimeMax;        // how long mouse must wait before trial starts max
float rewardTime;          // ms
float holdTime;
unsigned long t;
unsigned long time;
unsigned long t1;
unsigned long bstate1timer = 0;        // previous state for the bstate 1 timer
unsigned long bstate5timer = 0;       // previous state for the bstate 5 timer timeout

// wheel stuff
const byte encoderPin1 = 2;
const byte encoderPin2 = 3;
#define readA bitRead(PIND,2)//faster than digitalRead()
#define readB bitRead(PIND,3)//faster than digitalRead()
volatile long encoderValue = 0;
long lastencoderValue = 0;
long oldRotaryPos = 0;
int rotaryStartPosition;
long rotaryPos = 0;

long int lastEncoded = 0;
//int lastMSB = 0;
//int lastLSB = 0;
int rotaryDif = 0;
//long rotaryPos = 0;
//int rotaryLastStateA = LOW;
//int rotaryLastStateB = LOW;

// other stuff
char trialStr[6];
char ht[3];
int trialCnt = 1;
int trialOutcome;
int respDir;
int val;
int bstate = 0;             // defines which behavioural state you are in
int sc = LOW;
int trialType = 2;
int giveTO = 1;
int r;
int audioDur;


void setup() {

  pinMode (soundCardInput, INPUT);
  Serial.begin(19200);
  Serial.read();
  Serial.println("serial_established");

  // retrieve parameters from matlab
  int done = 0;
  float val[5];
  int cnt = 0;
  while (!done) {
    while (Serial.available() > 0) {
      val[cnt] = Serial.parseFloat();
      cnt++;
      if (cnt > 4) {
        done = 1;
        rewardTime      = val[0];
        timeOut         = val[1];
        rotaryDebounce  = val[2];
        holdTimeMin     = val[3];
        holdTimeMax     = val[4];


        Serial.print("REWTIME ");
        Serial.println(val[0]);
        Serial.print("TOTIME ");
        Serial.println(val[1]);
        Serial.print("DEBOUNCE ");
        Serial.println(val[2]);
        Serial.print("HOLDTIMEMIN ");
        Serial.println(val[3]);
        Serial.print("HOLDTIMEMAX ");
        Serial.println(val[4]);
        break;
      }
    }
  }

  //  sprintf(trialStr, "%04d ", trialCnt);
  //  Serial.print(trialStr);
  //  Serial.print(micros());
  //  Serial.print(" TRIALON");
  //  Serial.println(trialCnt);

  //Serial.flush();
  //Serial.read();


  pinMode(encoderPin1, INPUT_PULLUP);
  pinMode(encoderPin2, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(encoderPin1), isrA, CHANGE);
  attachInterrupt(digitalPinToInterrupt(encoderPin2), isrB, CHANGE);

  //  pinMode(encoderPin1, INPUT);
  //  pinMode(encoderPin2, INPUT);
  pinMode(solenoidOut, OUTPUT);

  //  digitalWrite(encoderPin1, HIGH); //turn pullup resistor on
  //  digitalWrite(encoderPin2, HIGH); //turn pullup resistor on
  //  updateEncoder();
  //  //call updateEncoder() when any high/low changed seen
  //  //on interrupt 0 (pin 2), or interrupt 1 (pin 3)
  //  attachInterrupt(digitalPinToInterrupt(encoderPin1), updateEncoder, CHANGE);
  //  attachInterrupt(digitalPinToInterrupt(encoderPin2), updateEncoder, CHANGE);

  //delay(100);
  //Serial.println("start");
  sprintf(trialStr, "%04d ", trialCnt);
  Serial.print(trialStr);
  Serial.print(micros());
  Serial.print(" TRIALON");
  Serial.println(trialCnt);
  bstate = 1; // connection established so move to behavioural state 1

  // clear out the serial
  Serial.read();
  Serial.read();
}

void loop() {
  switch (bstate) {

    case 1: {// RECEIVE TRIAL TYPE FROM MATLAB



        // receive input from matlab saying the type of trial it is
        Serial.read();
        int done = 0;
        float val[3];
        int cnt = 0;
        while (done != 1) {
          while (Serial.available() > 0) {
            val[cnt] = Serial.parseInt();
            cnt++;
            if (cnt > 2) {
              done = 1;
              trialType = val[0];
              giveTO = val[1];
              audioDur = val[2];
              Serial.print(trialStr);
              Serial.print("TRIALTYPE ");
              Serial.println(val[0]);
              Serial.print(trialStr);
              Serial.print("GIVETO ");
              Serial.println(val[1]);
              Serial.print(trialStr);
              Serial.print("AUDIODUR ");
              Serial.println(val[2]);

              holdTime = random(holdTimeMin, holdTimeMax);
              Serial.print(trialStr);
              Serial.print("HOLDTIME ");
              Serial.println(holdTime);
              bstate = 2;
              break;
            }
          }
        }

        break;
      }

    case 2: {// MONITOR WHEEL INPUT UNTIL NOT MOVED FOR HOLDTIME DURATION

        oldRotaryPos = encoderValue;
        signed long bstate1timer = 0;
        signed long t1 = millis();
        //Serial.println(t1);
        //Serial.println(bstate1timer);
        //Serial.println(bstate1timer - t1);
        //Serial.println(holdTime);
        //Serial.println((bstate1timer - t1) < holdTime);
        while ( (bstate1timer - t1) < holdTime) {
          // wait for the mouse to not move the wheel for the hold time duration
          bstate1timer = millis();
          rotaryPos = encoderValue;
          //Serial.println(rotaryPos);

          if (rotaryPos != oldRotaryPos) {
            t1 = millis();
            oldRotaryPos = rotaryPos;
          }
        }
        t = micros();
        Serial.print(trialStr);
        Serial.print("WHEELSTILL ");
        Serial.println(t);
        bstate = 3;

        // Serial.println("STATE2");
        break;
      }

    case 3: {// MONITOR DIGITAL INPUT FOR SOUND CARD INPUT TO SAY SOUND ON

        // Start a timer to check that the sound input is received. It can be missed
        // if the mouse turns the wheel for longer than the sound duration immediately
        // after holding it still - in the tiny bit of time for matlab to trigger the
        // sound

          // Serial.println("STATE3");
          sc = digitalRead(soundCardInput); // read the input from sound card

          if (sc == HIGH) { // if it is low, wait for it to be high
            t = micros();
            Serial.print(trialStr);
            Serial.print("STIMON ");
            Serial.println(t);
            bstate = 4;
          }  else if ((millis() - (t/1000)) > audioDur) {
            // if the timer times out restart the trial
            t = micros();
            Serial.print(trialStr);
            Serial.print("NOAUDIOEVENT ");
            Serial.println(t);
            bstate = 9;
          }
        



        break;
      }

    case 4: {// MONITOR FOR SOUND OFFSET

        // Serial.println("STATE4");
        sc = digitalRead(soundCardInput); // read the input from sound card

        if (sc == LOW) {
          t = micros();
          Serial.print(trialStr);
          Serial.print("STIMOFF ");
          Serial.println(t);
          bstate = 5;
        }
        break;
      }

    case 5: { // MONITOR THE WHEEL FOR RESPONSE

        oldRotaryPos = encoderValue;
        rotaryDif = 0;
        while (abs(rotaryDif) < rotaryDebounce) {
          rotaryPos = encoderValue;
          rotaryDif = rotaryPos - oldRotaryPos;
        }
        t = micros();
        Serial.print(trialStr);
        Serial.print("RESPTIME ");
        Serial.println(t);
        if (rotaryDif < 0) {          // CLOCKWISE TURN
          respDir = 2;
        } else if (rotaryDif > 1) {   // ANTI-CLOCKWISE TURN
          respDir = 1;
        }

        Serial.print(trialStr);
        Serial.print("RESPDIR ");
        Serial.println(respDir);
        bstate = 6;
        break;
      }

    case 6: { // RESPONSE LOGIC


        if (trialType == respDir) { // CORRECT TRIAL
          trialOutcome = 1;
          bstate = 8;

        } else if (trialType == 99) { // RANDOM REWARD TRIAL
          trialOutcome = 99;
          r = random(0, 1); // if this is (0,1) then there will be no rewards, if it is (0,2) there will be random rewards
          if (r > 0.5) {
            bstate = 8;
          } else {
            bstate = 9;
          }
        } else { // INCORRECT TRIAL
          trialOutcome = 0;
          if (giveTO == 1) {
            bstate = 7;
          } else if (giveTO == 0) {
            bstate = 9;
          }
        }

        Serial.print(trialStr);
        Serial.print("TRIALOUTCOME ");
        Serial.println(trialOutcome);

        break;
      }






    case 7: { // TIMEOUT

        //     Serial.println("timeout");
        long timer = 0;
        t1 = millis();
        Serial.print(trialStr);
        Serial.print("TOON ");
        Serial.println(t);
        while ((long) (timer - t1) < timeOut) {
          timer = millis();
        }
        t1 = millis();
        Serial.print(trialStr);
        Serial.print("TOOFF ");
        Serial.println(t);
        bstate = 9;
        break;
      }

    case 8: { // REWARD

        t = micros();
        digitalWrite(solenoidOut, HIGH); //open the solenoid
        delay(rewardTime);
        digitalWrite(solenoidOut, LOW); //close the solenoid

        Serial.print(trialStr);
        Serial.print("REWON ");
        Serial.println(t);
        bstate = 9;
        break;
      }

    case 9: {// TRIAL END
        Serial.print(trialStr);
        Serial.print("TRIALEND ");
        Serial.println(t);

        trialCnt++;
        sprintf(trialStr, "%04d ", trialCnt);
        Serial.print(trialStr);
        Serial.print(micros());
        Serial.print(" TRIALON");
        Serial.println(trialCnt);


        // flush the newline from matlab input for previous trial
        if (Serial.available()) {
          Serial.read();
        }
        //Serial.flush();
        bstate = 1;
        break;
      }
  }
}

void isrA() {
  if (readB != readA) {
    encoderValue ++;
  } else {
    encoderValue --;
  }
}

void isrB() {
  if (readA == readB) {
    encoderValue ++;
  } else {
    encoderValue --;
  }
}




//void updateEncoder() {
//  int MSB = digitalRead(encoderPin1); //MSB = most significant bit
//  int LSB = digitalRead(encoderPin2); //LSB = least significant bit
//
//  int encoded = (MSB << 1) | LSB; //converting the 2 pin value to single number
//  int sum  = (lastEncoded << 2) | encoded; //adding it to the previous encoded value
//
//  if (sum == 0b1101 || sum == 0b0100 || sum == 0b0010 || sum == 0b1011) encoderValue ++;
//  if (sum == 0b1110 || sum == 0b0111 || sum == 0b0001 || sum == 0b1000) encoderValue --;
//
//  lastEncoded = encoded; //store this value for next time
//}
