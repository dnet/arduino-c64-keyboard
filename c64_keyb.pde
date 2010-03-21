/*
 * c64-keyb.pde - C64 keyboard interface for Arduino with decoder
 *
 * Copyright (c) 2010 András Veres-Szentkirályi
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#define INP_START 2 /* +0..7 */
#define INP_END 9
#define MPX_START 10 /* +0..2 */
#define MPX_END 12

char state_table[64]; /* pressed = LOW */

void setup() {
	Serial.begin(9600);
	for (char i = INP_START; i <= INP_END; i++) {
		pinMode(i, INPUT);
		digitalWrite(i, HIGH); /* enable internal pullups */
	}
	for (char i = MPX_START; i <= MPX_END; i++) {
		pinMode(i, OUTPUT);
	}
	for (char i = 0; i < 64; i++) {
		state_table[i] = HIGH;
	}
}

void mpx(char value) {
	for (char i = MPX_START; i <= MPX_END; i++) {
		char chk = 1 << (i - MPX_START);
		digitalWrite(i, (value & chk) == chk ? HIGH : LOW);
	}
}

char scan = 0;

void loop() {
	scan = (scan + 1) & 7; /* scan through columns */
	mpx(scan);
	for (char i = INP_START; i <= INP_END; i++) {
		char idx = (i - INP_START) * 8 + scan;
		char dr = digitalRead(i);
		if (state_table[idx] != dr) { /* state changed */
			state_table[idx] = dr;
			Serial.print("Key ");
			Serial.print(dr == LOW ? "pressed" : "released");
			Serial.print(" @ column ");
			Serial.print(scan, DEC);
			Serial.print(" line ");
			Serial.print(i - INP_START, DEC);
			Serial.println();
		}
	}
	delay(1); /* ~1 khz */
}
