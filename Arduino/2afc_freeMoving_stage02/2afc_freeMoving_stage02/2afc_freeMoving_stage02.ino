//From bildr article: http://bildr.org/2012/08/rotary-encoder-arduino/

// ASSIGN PINS
byte const no_output = 0;             // no output
byte const solenoidOut_0 = 1;         // left solenoid: channel 8
byte const solenoidOut_1 = 2;         // center solenoid: channel 9
byte const solenoidOut_2 = 4;         // right solenoid: channel 10
byte const LED_centeron = 10;         // center on and LED on (LED channel: 11)
byte const LED_centeroff = 8;         // center off and LED on
int const AudioEventsInput = 241;      // events from nidaq/soundcard alone: channel 4
int const photoInput_0 = 195;          // left nosepoke: channel 5
int const photoInput_1 = 163;          // centre nosepoke: channel 6
int const photoInput_2 = 97;         // right nosepoke: channel 7
int const audio_photo_1 = 179;         // center nosepoke and audio: channel 4 & 6
int const no_input = 225;               // no input from any channel
// setup port reading
byte inputRegD;


// timing variables:
float rewardTime_L;        // ms
float rewardTime_C;        // ms
float rewardTime_R;        // ms
signed long t;
signed long time;
signed long rewardInterval;
signed long center_triggered = millis();
signed long left_triggered = millis();
signed long right_triggered = millis();

// other stuff:
String output;
String input;
int state;
int prev_resp = 99;
char trialStr[6];
int trialCnt = 0;



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
        rewardTime_L      = val[0];
        rewardTime_R      = val[1];
        rewardTime_C      = val[2];
        rewardInterval    = val[3];

        Serial.print("REWTIME_L ");
        Serial.println(val[0]);
        Serial.print("REWTIME_R ");
        Serial.println(val[1]);
        Serial.print("REWTIME_C ");
        Serial.println(val[2]);
        Serial.print("REWINTERVAL ");
        Serial.println(val[3]);
        break;
      }
    }
  }


  long const seed = millis();
  randomSeed(seed);
  Serial.print("SEED ");
  Serial.println(seed);
  state = 1;

  // clear out the serial
  Serial.read();
  Serial.read();
}

void loop() {

  switch (state) {

    //***********************************************************************************//
    case 1: { //WAIT FOR CENTER POKE

        if  (check_inputs() == "center") {  // wait for mouse to do center nose-poke
          t = micros();
          solenoid_out('C');
          trialCnt++;
          sprintf(trialStr, "%04d ", trialCnt);
          Serial.print(trialStr);
          Serial.print("CENTER ");
          Serial.println(t);
          state = 2; // GO TO STATE 2
        }
        break;
      }

    //***********************************************************************************//
    case 2: { //WAIT FOR LEFT OR RIGHT POKE

        input = check_inputs();
        
        if (input == "left" & prev_resp != 1) { // mouse responded left
          t = micros();
          prev_resp = 1;
          solenoid_out('L');
          Serial.print("LEFT ");
          Serial.println(t);
          state = 1;
        } else if (input == "right" & prev_resp != 2) { // mouse responded right
          t = micros();
          prev_resp = 2;
          solenoid_out('R');
          Serial.print("RIGHT ");
          Serial.println(t);
          state = 1;
        }

        break;
      }
  }
}

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
