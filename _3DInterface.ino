//
// By Kyle McDonald
// From the instructables project at:
// http://www.instructables.com/id/DIY-3D-Controller/

#define resolution 8
#define mains 50 // 60: north america, japan; 50: most other places

#define refresh 2 * 1000000 / mains
String thevalue1;
String thevalue2;
String thevalue3;
String thevalue;

void setup() {
  Serial.begin(9600);

  // unused pins are fairly insignificant,
  // but pulled low to reduce unknown variables
  for(int i = 2; i < 8; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);
  }

  for(int i = 12; i < 14; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);
  }

  for(int i = 8; i < 11; i++)
    pinMode(i, INPUT);

  startTimer();
}

void loop() {  
  //Serial.print(time(8, B00000001), DEC);
  //Serial.print(" ");
  //Serial.print(time(9, B00000010), DEC);
  //Serial.print(" ");
  //Serial.println(time(10, B00000100), DEC);

  thevalue1 = String(time(8, B00000001), DEC);
  thevalue2 = String(time(9, B00000010), DEC);
  thevalue3 = String(time(10, B00000100), DEC);

  thevalue = thevalue1 + "+" + thevalue2 + "+" + thevalue3 + "\n";
  Serial.print(thevalue);
  //delay(2000);
} 

long time(int pin, byte mask) {
  unsigned long count = 0, total = 0;
  while(checkTimer() < refresh) {
    // pinMode is about 6 times slower than assigning
    // DDRB directly, but that pause is important
    pinMode(pin, OUTPUT);
    PORTB = 0;
    pinMode(pin, INPUT);
    while((PINB & mask) == 0)
      count++;
    total++;
  }
  startTimer();
  return (count << resolution) / total;
}

extern volatile unsigned long timer0_overflow_count;

void startTimer() {
  timer0_overflow_count = 0;
  TCNT0 = 0;
}

unsigned long checkTimer() {
  return ((timer0_overflow_count << 8) + TCNT0) << 2;
}



