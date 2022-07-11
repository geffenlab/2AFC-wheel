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
float rewardTime_L;      // ms
float rewardTime_C;      // ms
float rewardTime_R;      // ms
float centerDebounce;    // ms
float centerRewardProb;  // probability (0-1)
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
int audioWait;
int totalWait;
String photoInput;
struct result {
  String photoInput;
  signed long inputTimer;
};
bool onset;
struct input;
struct previous_input;
bool contact;
bool holdTimeFinished;



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
      if (cnt > 7) {
        done = 1;
        rewardTime_L      = val[0];
        rewardTime_R      = val[1];
        rewardTime_C      = val[2];
        timeOut           = val[3];
        holdTimeMin       = val[4];
        holdTimeMax       = val[5];
        centerDebounce    = val[6];
        centerRewardProb  = val[7];


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
        Serial.print("CENTERDEBOUNCE ");
        Serial.println(centerDebounce);
        Serial.print("CENTERREWARDPROB ");
        Serial.println(centerRewardProb);
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
              audioWait = val[2];
              Serial.print(trialStr);
              Serial.print("TRIALTYPE ");
              Serial.println(val[0]);
              Serial.print(trialStr);
              Serial.print("GIVETO ");
              Serial.println(val[1]);
              Serial.print(trialStr);
              Serial.print("AUDIOWAIT ");
              Serial.println(val[2]);

              holdTime = random(holdTimeMin, holdTimeMax);
              totalWait = holdTime + audioWait;
              Serial.print(trialStr);
              Serial.print("HOLDTIME ");
              Serial.println(totalWait);
              state = 2;
              break;
            }
          }
        }
        onset = false; // set sound onset detection parameter to false
        holdTimeFinished = false;
        break;
      }

    //********************************************************************//
    case 2: {// MONITOR CENTRAL NOSEPOKE UNTIL NOT BROKEN FOR HOLDTIME DURATION


        result input = check_inputs();
        
        if  (input.photoInput == "center") {  // wait for mouse to do center nose-poke
          // Serial.println("center nosepoke");
          signed long stateTimer = 0;     // start timer at zero
          signed long tt = millis();       // Mark time at which timer started
          contact = true;            // Mouse in contact with center nosepoke

          // run the timer until the mouse has been at the center for the hold time
          while ((stateTimer - tt) < totalWait) {

            stateTimer = millis();        // update the timer
            result previous_input = input;
            // if the mouse breaks contact with the center nosepoke break out of the while loop and restart
            result input = check_inputs();
            
            // if the mouse leaves the center longer than the debounce time then count as early departure
            if (!(input.photoInput == "center") && !(input.photoInput == "center_audio") && onset && ((input.inputTimer - previous_input.inputTimer) > centerDebounce)) {
              t = micros();
              Serial.print(trialStr);
              Serial.print("EARLYDEP ");
              Serial.println(t);
              contact = false;
              onset = false;
              holdTimeFinished = false;
              break;

            // if mouse waits for hold time (i.e. the silence before the stim is presented) then signal to matlab to present the sound
            } else if (((stateTimer - tt) >= holdTime) && !holdTimeFinished) {
              t = micros();
              Serial.print(trialStr);
              Serial.print("ENDHOLDTIME ");
              Serial.println(t);
              holdTimeFinished = true;

            // signal when you detect stim onset
            } else if  (input.photoInput == "center_audio" && !onset) {  // mouse is at center and sound is on
              t = micros();
              signed long stateTimer = 0;
              Serial.print(trialStr);
              Serial.print("STIMON ");
              Serial.println(t);
              onset = true;
            }
          }

         // if the mouse maintained contact for the total wait time, wait for the response
          if (contact) {
            t = micros();
            endHoldTime = t;
            Serial.print(trialStr);
            Serial.print("TOTALWAITTIME ");
            Serial.println(t);
            state = 4;
            float r = random(100);
            if (r < (centerRewardProb*100)) { // reward center 5% of the time
            solenoid_out('C');
            t = micros();
            Serial.print(trialStr);
            Serial.print("CENTERREWARD ");
            Serial.println(t);
            }
          }
        }

        break;
      }


    //********************************************************************//
    case 4: { // MONITOR FOR RESPONSE

        bool resp = false;
        result input = check_inputs();

        if (input.photoInput == "left") { // mouse responded left
          t = micros();
          respDir = 1;
          resp = true;
        } else if (input.photoInput == "right") { // mouse responded right
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
result check_inputs() { // checks PORTD status

  signed long  inputTimer = millis();
  if (PIND == photoInput_1 | PIND == photoInput_1 - 2) {
    photoInput = "center";
  } else if (PIND == audio_photo_1 | PIND == audio_photo_1 - 2) {
    photoInput = "center_audio";
  } else if (PIND == photoInput_0 | PIND == photoInput_0 - 2) {
    photoInput = "left";
  } else if (PIND == photoInput_2 | PIND == photoInput_2 + 2) {
    photoInput = "right";
  } else if (PIND == AudioEventsInput | PIND == AudioEventsInput - 2) {
    photoInput = "audio";
  } else {
    photoInput = "none";
  }
  result new_result = {photoInput, inputTimer};
  return new_result;
}

//********************************************************************************//
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
