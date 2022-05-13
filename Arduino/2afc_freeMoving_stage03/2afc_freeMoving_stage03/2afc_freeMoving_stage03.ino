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
float rewardTime_L;        // ms
float rewardTime_C;        // ms
float rewardTime_R;        // ms
float holdTime;
signed long t;
signed long t_sound_end;
signed long t_audio_onset;
signed long time;
signed long stateTimer = 0;        // previous state for the bstate 1 timer
signed long timer;
signed long endHoldTime;

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
String input;
bool onset;
bool contact;



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
  float val[6];
  int cnt = 0;
  while (!done) {
    while (Serial.available() > 0) {
      val[cnt] = Serial.parseFloat();
      cnt++;
      if (cnt > 5) {
        done = 1;
        rewardTime_L      = val[0];
        rewardTime_R      = val[1];
        rewardTime_C      = val[2];
        timeOut           = val[3];
        holdTimeMin       = val[4];
        holdTimeMax       = val[5];


        Serial.print("REWTIME_L ");
        Serial.println(val[0]);
        Serial.print("REWTIME_R ");
        Serial.println(val[1]);
        Serial.print("REWTIME_C ");
        Serial.println(val[2]);
        Serial.print("TOTIME ");
        Serial.println(val[3]);
        Serial.print("HOLDTIMEMIN ");
        Serial.println(val[4]);
        Serial.print("HOLDTIMEMAX ");
        Serial.println(val[5]);
        break;
      }
    }
  }

  long const seed = millis();
  randomSeed(seed);
  Serial.print("SEED ");
  Serial.println(seed);
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

        if  (check_inputs() == "center") {  // wait for mouse to do center nose-poke
          // Serial.println("center nosepoke");
          signed long stateTimer = 0;     // start timer at zero
          signed long t = millis();       // Mark time at which timer started
          contact = true;            // Mouse in contact with center nosepoke

          // run the timer until the mouse has been at the center for the hold time
          while ((stateTimer - t) < holdTime) {

            stateTimer = millis();        // update the timer

            // if the mouse breaks contact with the center nosepoke break out of the while loop and restart
            if (check_inputs() != "center") {
              contact = false;
              break;
            }
          }

          // if the mouse maintained contact for the hold time, present the stimulus (state 3)
          if (contact) {
            t = micros();
            endHoldTime = t;
            Serial.print(trialStr);
            Serial.print("ENDHOLDTIME ");
            Serial.println(t);
            state = 3;
            onset = false; // set sound onset detection parameter to false
            long r = random(100);
            //if (r < 5) { // reward center 5% of the time
              
            //}
          }
        }

        break;
      }

    //********************************************************************//
    case 3: { // MONITOR FOR SOUND ONSET AND OFFSET AND EARLY DEPARTURE
        stateTimer = micros();
        timer = stateTimer - endHoldTime;
        // Serial.println(timer);
        // Serial.println(check_inputs());
        input = check_inputs();
       Serial.println(input);

        if  (input == "center_audio" & !onset) {  // mouse is at center and sound is on
          t = micros();
          signed long stateTimer = 0;
          Serial.print(trialStr);
          Serial.print("STIMON ");
          Serial.println(t);
          onset = true;

        } else if (input == "none" & !onset) { // mouse has left before sound onset
          t = micros();
          Serial.print(trialStr);
          Serial.print("EARLYDEP_01 ");
          Serial.println(t);
          state = 2;
          break;

        } else if (!onset & (timer > audioDur * 1000.0)) { // no sound onset detected
          t = micros();
          Serial.print(trialStr);
          Serial.print("NOAUDIOONEVENT ");
          Serial.println(t);
          state = 8;
          break;

        } else if (input == "center" & onset) { // mouse is center and sound has finished presenting
          t = micros();
          Serial.print(trialStr);
          Serial.print("STIMOFF ");
          Serial.println(t);
          state = 4;
          solenoid_out('C');
          break;

        } else if (input == "audio" & onset) { // mouse is not center and sound is presenting
          t = micros();
          Serial.print(trialStr);
          Serial.print("EARLYDEP_02 ");
          Serial.println(t);
          state = 2;
          break;

        } else if (input == "none" & onset) { // mouse has waited but no sound offset detected
          t = micros();
          Serial.print(trialStr);
          Serial.print("EARLYDEP_03 ");
          Serial.println(t);
          state = 2;
          break;
        }
        break;
      }

    //********************************************************************//
    case 4: { // MONITOR FOR RESPONSE
        
        bool resp = false;
        input = check_inputs();

        if (input == "left") { // mouse responded left
          t = micros();
          respDir = 1;
          resp = true;
        } else if (input == "right") { // mouse responded right
          t = micros();
          respDir = 2;
          resp = true;
        }

        if (resp) {
          Serial.print(trialStr);
          Serial.print("RESPTIME ");
          Serial.println(t);
          Serial.print(trialStr);
          Serial.print("RESPDIR ");
          Serial.println(respDir);
          state = 5;
        }
        break;
      }

    //********************************************************************//
    case 5: { // RESPONSE LOGIC

        // CORRECT TRIAL
        if (trialType == respDir) {
          trialOutcome = 1;
          Serial.print(trialStr);
          Serial.print("TRIALOUTCOME ");
          Serial.println(trialOutcome);
          state = 7;

          // INCORRECT TRIAL
        } else {
          trialOutcome = 0;
          state = 4;
        }



        break;
      }

    //********************************************************************//
    case 6: { // TIMEOUT

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
          solenoid_out('L');
        } else if (respDir == 2) { // right response
          solenoid_out('R');
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


//********************************************************************************//
String check_inputs() { // checks PORTD status
  if (PIND == photoInput_1 | PIND == photoInput_1 - 2) {
    output = "center";
  } else if (PIND == audio_photo_1 | PIND == audio_photo_1 - 2) {
    output = "center_audio";
  } else if (PIND == photoInput_0 | PIND == photoInput_0 - 2) {
    output = "left";
  } else if (PIND == photoInput_2 | PIND == photoInput_2 + 2) {
    output = "right";
  } else if (PIND == AudioEventsInput | PIND == AudioEventsInput - 2) {
    output = "audio";
  } else {
    output = "none";
  }
  return output;
}

void solenoid_out(char solenoid_output) {
  switch (solenoid_output) {
    case 'L': {
        PORTB = solenoidOut_0;
        delay(rewardTime_L);
        PORTB = no_output;
        break;
      }
    case 'R': {
        PORTB = solenoidOut_2;
        delay(rewardTime_R);
        PORTB = no_output;
        break;
      }
    case 'C': {
        PORTB = solenoidOut_1;
        delay(rewardTime_C);
        PORTB = no_output;
        break;
      }
  }
}
