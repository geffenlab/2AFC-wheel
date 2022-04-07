// ASSIGN PINS
//these pins can not be changed 2/3 are special pins
int solenoidOut_0 = 8;
int solenoidOut_1 = 9;
int solenoidOut_2 = 10;
int AudioEventsInput = 4;       // events from nidaq/soundcard
int photoInput_0 = 5;            // left nosepoke
int photoInput_1 = 6;            // centre nosepoke
int photoInput_2 = 7;            // right nosepoke
// setup port reading
byte inputRegD;
byte setpin = 64; // channel order: 7,6,5,4,3,2,1,0, 
// channels 0 & 1 will be 1 if you establish a serial connection

unsigned long startTime;
unsigned long timeInterval;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.read();
  Serial.println("serial_established");

  // Set pins 0..7 as INPUTS using the register
  DDRD = 0b0000000;    // Note that 0 and 1 are TX and RX for serial comms. 0 is input, 1 is output
  DDRB = B00000111; //channels 8, 9 & 10 as outputs
}

void loop() {
  // put your main code here, to run repeatedly:
  //PORTD = setpin;
  //startTime = micros(); // Get the current time in microseconds
  inputRegD = PIND;
  //timeInterval = micros() - startTime;  // Calculate time it took to read 8 inputs
  Serial.println(inputRegD);
  //Serial.println(inputRegD==64);
  //delay(1000);  // Wait a second

}
