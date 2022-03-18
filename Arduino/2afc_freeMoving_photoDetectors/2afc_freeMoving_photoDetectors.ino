//From bildr article: http://bildr.org/2012/08/rotary-encoder-arduino/

// ASSIGN PINS
//these pins can not be changed 2/3 are special pins
byte const solenoidOut_0 = 1;         // left solenoid
byte const solenoidOut_1 = 2;         // center solenoid
byte const solenoidOut_2 = 4;         // right solenoid
int const AudioEventsInput = 19;      // events from nidaq/soundcard
int const photoInput_0 = 35;          // left nosepoke
int const photoInput_1 = 67;          // centre nosepoke
int const photoInput_2 = 131;         // right nosepoke
int const audio_photo_1 = 83;         // center nosepoke and audio
// setup port reading
byte inputRegD;


// timing variables:
long timeOut;            // ms
float holdTimeMin;       // how long mouse must wait before trial starts min
float holdTimeMax;       // how long mouse must wait before trial starts max
float rewardTime;        // ms
float holdTime;
unsigned long t;
unsigned long time;
unsigned long stateTimer = 0;        // previous state for the bstate 1 timer


// other stuff
char trialStr[6];
char ht[3];
int trialCnt = 1;
int trialOutcome;
int respDir;
int val;
int state = 0;             // defines which behavioural state you are in
int sc = LOW;
int trialType = 2;
int giveTO = 1;
int r;
int audioDur;


void setup() {

  Serial.begin(115200);
  Serial.read();
  Serial.println("serial_established");

  // Set pins 0..7 as INPUTS using the register
  DDRD = B00000000;    // Note that 0 and 1 are TX and RX for serial comms.
  DDRB = B00000111; //channels 8, 9 & 10 as outputs

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

  // assign pin modes
  pinMode(solenoidOut_0, OUTPUT);
  pinMode(solenoidOut_1, OUTPUT);
  pinMode(solenoidOut_2, OUTPUT);
  pinMode(AudioEventsInput, INPUT);
  pinMode(photoInput_0, INPUT);
  pinMode(photoInput_1, INPUT);
  pinMode(photoInput_2, INPUT);

  sprintf(trialStr, "%04d ", trialCnt);
  Serial.print(trialStr);
  Serial.print(micros());
  Serial.print(" TRIALON");
  Serial.println(trialCnt);
  state = 1; // connection established so move to behavioural state 1

  // clear out the serial
  Serial.read();
  Serial.read();
}

void loop() {
  switch (state) {

    case 1: {// RECEIVE TRIAL TYPE FROM MATLAB

        // receive input from matlab/python saying the type of trial it is
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
              state = 2;
              break;
            }
          }
        }
        break;
      }

    case 2: {// MONITOR CENTRAL NOSEPOKE UNTIL NOT BROKEN FOR HOLDTIME DURATION

        inputRegD = PIND;
        signed long stateTimer = 0;
        signed long t = millis();
        //Serial.println(t1);
        //Serial.println(bstate1timer);
        //Serial.println(bstate1timer - t1);
        //Serial.println(holdTime);
        //Serial.println((bstate1timer - t1) < holdTime);
        
        while ((stateTimer - t) < holdTime & inputRegD==photoInput_1) {
          // wait for the mouse to not move the wheel for the hold time duration
          stateTimer = millis();
          //Serial.println(rotaryPos);

          inputRegD = PIND;

        }
        t = micros();
        Serial.print(trialStr);
        Serial.print("ENDHOLDTIME ");
        Serial.println(t);
        state = 3;

        // Serial.println("STATE2");
        break;
      }

    case 3: {// MONITOR DIGITAL INPUT FOR SOUND CARD INPUT TO SAY SOUND ON

        // Start a timer to check that the sound input is received. 

          // Serial.println("STATE3");
          sc = digitalRead(AudioEventsInput); // read the input from sound card

          if (sc == HIGH) { // if it is low, wait for it to be high
            t = micros();
            Serial.print(trialStr);
            Serial.print("STIMON ");
            Serial.println(t);
            state = 4;
          }  else if ((millis() - (t/1000)) > audioDur) {
            // if the timer times out restart the trial
            t = micros();
            Serial.print(trialStr);
            Serial.print("NOAUDIOEVENT ");
            Serial.println(t);
            state = 9;
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
          state = 5;
        }
        break;
      }

    case 5: { // MONITOR FOR RESPONSE

        int resp = 0
        while (resp == 0) {
          PI_0 = digitalRead(photoInput_0);
          PI_2 = digitalRead(photoInput_1);
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
        t = micros();
        Serial.print(trialStr);
        Serial.print("TOON ");
        Serial.println(t);
        while ((long) (timer - t) < (timeOut*1000)) {
          timer = micros();
        }
        t = micros();
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
        t = micros();
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
