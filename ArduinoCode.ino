/*
  Author: Sander Verdiesen
  Date: 06/10/2024
  Email: sjverdiesen@gmail.com

  Description:
  This Arduino sketch reads temperature data from the AMG8833 thermal camera sensor
  and transmits the data over a serial connection for real-time visualization using
  Processing. The sensor provides an 8x8 grid of temperature values, which are sent
  as a comma-separated string.

  The sketch is inspired by Adafruit's AMG8833 sensor library and examples. It is
  designed to work with the Processing script that interpolates and displays the
  temperature data in a graphical form.

  The data is read at regular intervals, formatted into a single string, and sent
  over the serial connection to be processed and displayed.

  Hardware:
  - AMG8833 thermal camera sensor
  - Arduino (e.g., Uno, Mega, etc.)
  - Serial communication with Processing

  Library:
  - Adafruit_AMG88xx by Adafruit

  Usage:
  - Connect the AMG8833 sensor to the Arduino via I2C.
  - The Arduino reads temperature values and sends them to a serial monitor or
    a connected Processing sketch for real-time visualization.
*/


#include <Wire.h>
#include <Adafruit_AMG88xx.h>

Adafruit_AMG88xx amg;

void setup() {
  Serial.begin(115200);
  
  if (!amg.begin()) {
    Serial.println("Could not find a valid AMG88xx sensor, check wiring!");
    while (1);
  }
}

void loop() {
  float pixels[AMG88xx_PIXEL_ARRAY_SIZE];  // 1D array for pixel data
  amg.readPixels(pixels);  // Read pixels into the 1D array
  
  // Send pixel values over serial
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 8; j++) {
      Serial.print(pixels[i * 8 + j]); // Accessing 1D array as 2D
      Serial.print(",");
    }
  }
  Serial.println(); // Send newline after each 8x8 array
  delay(100); // Adjust delay as needed
}
