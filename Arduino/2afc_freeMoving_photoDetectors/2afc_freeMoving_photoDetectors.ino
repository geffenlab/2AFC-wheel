//From bildr article: http://bildr.org/2012/08/rotary-encoder-arduino/

// ASSIGN PINS
//these pins can not be changed 2/3 are special pins
byte const no_output = 0;             // no output
byte const solenoidOut_0 = 1;         // left solenoid
byte const solenoidOut_1 = 2;         // center solenoid
byte const solenoidOut_2 = 4;         // right solenoid
int const AudioEventsInput = 241;      // events from nidaq/soundcard alone: channel 4
int const photoInput_0 = 195;          // left nosepoke: channel 5
int const photoInput_1 = 163;          // centre nosepoke: channel 6
int const photoInput_2 = 97;         // right nosepoke: channel 7
int const audio_photo_1 = 179;         // center nosepoke and audio: channel 4 & 6
int const no_input = 225;               // no input from any channel
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
String output;


void setup() {

  Serial.begin(115200);
  Serial.read();
  Serial.println("serial_established");

  // Set pins 0..7 as INPUTS using the register
  DDRD = B00000000;     // Note that 0 and 1 are TX and RX for serial comms.
  DDRB = B00000111;     //channels 8, 9 & 10 as outputs

  PORTB = no_output;
  PORTD = no_input;

  // retrieve parameters from matlab
  int done = 0;
  float val[4];
  int cnt = 0;
  while (!done) {
    while (Serial.available() > 0) {
      val[cnt] = Serial.parseFloat();
      cnt++;
      if (cnt > 3) {
        done = 1;
        rewardTime      = val[0];
        timeOut         = val[1];
        holdTimeMin     = val[2];
        holdTimeMax     = val[3];


        Serial.print("REWTIME ");
        Serial.println(val[0]);
        Serial.print("TOTIME ");
        Serial.println(val[1]);
        Serial.print("HOLDTIMEMIN ");
        Serial.println(val[2]);
        Serial.print("HOLDTIMEMAX ");
        Serial.println(val[3]);
        break;
      }
    }
  }

  //  // assign pin modes
  //  pinMode(solenoidOut_0, OUTPUT);
  //  pinMode(solenoidOut_1, OUTPUT);
  //  pinMode(solenoidOut_2, OUTPUT);
  //  pinMode(AudioEventsInput, INPUT);
  //  pinMode(photoInput_0, INPUT);
  //  pinMode(photoInput_1, INPUT);
  //  pinMode(photoInput_2, INPUT);

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

    //********************************************************************//
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

    //********************************************************************//
    case 2: {// MONITOR CENTRAL NOSEPOKE UNTIL NOT BROKEN FOR HOLDTIME DURATION
       // Serial.println("state2");
        // inputRegD = PIND;
        //Serial.println(PIND);
        // Serial.println(mouse_center() == "center");
        //  Serial.println(PIND);
        if  (mouse_center() == "center") {  // wait for mouse to do center nose-poke
          //  Serial.println(mouse_center());
          signed long stateTimer = 0;     // start timer at zero
          signed long t = millis();       // Mark time at which timer started
          bool contact = true;            // Mouse in contact with center nosepoke
          Serial.println(t - stateTimer);
          // run the timer until the mouse has been at the center for the hold time
          while ((stateTimer - t) < holdTime) {
            Serial.println(stateTimer - t);
            stateTimer = millis();        // update the timer
            //    inputRegD = PIND;             // read the input pins

            // if the mouse breaks contact with the center nosepoke break out of the while loop and restart
            if (mouse_center() != "center") {
              contact = false;
              break;
            }
          }

          // if the mouse maintained contact for the hold time, present the stimulus (state 3)
          if (contact == true) {
            t = micros();
            Serial.print(trialStr);
            Serial.print("ENDHOLDTIME ");
            Serial.println(t);
            state = 3;
          }

          // Serial.println("STATE2");
        }
        break;
      }

    //********************************************************************//
    case 3: { // MONITOR FOR SOUND ONSET AND OFFSET AND EARLY DEPARTURE

        // Serial.println("STATE3");
        bool onset = false;
        signed long stateTimer = 0;
        signed long t = millis();
        Serial.println(t);
        Serial.println(audioDur);
        Serial.println((stateTimer - t));
        // while sound has not completed
        while ((stateTimer - t) < audioDur) {
          stateTimer = millis();
          Serial.println(stateTimer - t);

          // mouse is at center and sound comes on
          if (mouse_center() == "center" & !onset) {
            t = micros();
            Serial.print(trialStr);
            Serial.print("STIMON ");
            Serial.println(t);
            onset = true;
            break;

            // mouse is not center and sound is presenting
          } else if (mouse_center() == "audio") {
            t = micros();
            Serial.print(trialStr);
            Serial.print("EARLYDEP ");
            Serial.println(t);
            state = 2;
            break;

            // there is no sound input and the mouse is not center
          } else if (mouse_center() == "none") {
            t = micros();
            Serial.print(trialStr);
            Serial.print("EARLYDEP ");
            Serial.println(t);
            state = 2;
            break;
          }
        }

        // mouse has waited but no sound onset detected
        if (!onset & state == 3) {
          t = micros();
          Serial.print(trialStr);
          Serial.print("NOAUDIOEVENT ");
          Serial.println(t);
          state = 8;

          // audio has finished
        } else if (state == 3 & onset) {
          t = micros();
          Serial.print(trialStr);
          Serial.print("STIMOFF ");
          Serial.println(t);
          state = 4;
        }

        break;
      }

    //********************************************************************//
    case 4: { // MONITOR FOR RESPONSE

        int resp = false;
        while (!resp) {
          inputRegD = PIND; // read the inputs
          if (inputRegD == photoInput_0) {
            t = micros();
            respDir = 1;            // mouse responded left
            resp = true;
          } else if (inputRegD == photoInput_2) {
            t = micros();
            respDir = 2;            // mouse responded right
            resp = true;
          }
        }

        Serial.print(trialStr);
        Serial.print("RESPTIME ");
        Serial.println(t);
        Serial.print(trialStr);
        Serial.print("RESPDIR ");
        Serial.println(respDir);
        state = 5;
        break;
      }

    //********************************************************************//
    case 5: { // RESPONSE LOGIC

        // CORRECT TRIAL
        if (trialType == respDir) {
          trialOutcome = 1;
          state = 7;

          // RANDOM REWARD TRIAL
        } else if (trialType == 99) {
          trialOutcome = 99;
          r = random(0, 1); // if this is (0,1) then there will be no rewards, if it is (0,2) there will be random rewards
          if (r > 0.5) {
            state = 7;
          } else {
            state = 8;
          }

          // INCORRECT TRIAL
        } else {
          trialOutcome = 0;
          if (giveTO == 1) {
            state = 6;
          } else if (giveTO == 0) {
            state = 8;
          }
        }

        Serial.print(trialStr);
        Serial.print("TRIALOUTCOME ");
        Serial.println(trialOutcome);

        break;
      }

    //********************************************************************//
    case 6: { // TIMEOUT

        //     Serial.println("timeout");
        long timer = 0;
        t = micros();
        Serial.print(trialStr);
        Serial.print("TOON ");
        Serial.println(t);
        while ((long) (timer - t) < (timeOut * 1000)) {
          timer = micros();
        }
        t = micros();
        Serial.print(trialStr);
        Serial.print("TOOFF ");
        Serial.println(t);
        state = 8;
        break;
      }

    //********************************************************************//
    case 7: { // REWARD

        t = micros();
        if (respDir == 1) {     // left response
          PORTB = solenoidOut_0;
          delay(rewardTime);
          PORTB = no_output;
        } else if (respDir == 2) { // right response
          PORTB = solenoidOut_2;
          delay(rewardTime);
          PORTB = no_output;
        }

        Serial.print(trialStr);
        Serial.print("REWON ");
        Serial.println(t);
        state = 8;
        break;
      }

    //********************************************************************//
    case 8: {// TRIAL END
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
        state = 1;
        break;
      }
  }
}

String mouse_center() { //
  if (PIND == photoInput_1 | PIND == audio_photo_1 | PIND == photoInput_1 - 2 | PIND == audio_photo_1 - 2) {
    output = "center";
  } else if (PIND == photoInput_0 | PIND == photoInput_0 - 2) {
    output = "left";
  } else if (PIND == photoInput_2 | PIND == photoInput_2 - 2) {
    output = "right";
  } else if (PIND == AudioEventsInput | PIND == AudioEventsInput - 2) {
    output = "audio";
  } else {
    output = "none";
  }
  return output;
}
