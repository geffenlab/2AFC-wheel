// ASSIGN PINS

// setup port writing binary codes
byte const no_output = 0;             // no output
byte const solenoidOut_0 = 1;         // left solenoid
byte const solenoidOut_1 = 2;         // center solenoid
byte const solenoidOut_2 = 4;         // right solenoid

// channels 0 & 1 will be 1 if you establish a serial connection
int const delay_on = 100;
int const delay_off = 1000;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.read();
  Serial.println("serial_established");

  // Set pins 0..7 as INPUTS using the register
 // DDRD = 0b0000000;    // Note that 0 and 1 are TX and RX for serial comms. 0 is input, 1 is output
  DDRB = B00000111; //channels 8, 9 & 10 as outputs
  PORTB = no_output;
}

void loop() {
  PORTB = solenoidOut_0;  
  delay(delay_on);
  PORTB = no_output;
  delay(delay_off);
  PORTB = solenoidOut_1;  
  delay(delay_on);
  PORTB = no_output;
  delay(delay_off);
  PORTB = solenoidOut_2;  
  delay(delay_on);
  PORTB = no_output;
  delay(delay_off);

}
