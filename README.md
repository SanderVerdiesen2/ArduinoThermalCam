# AMG8833 Thermal Sensor Visualization
This project demonstrates how to visualize data from the AMG8833 infrared thermal sensor using an Arduino and Processing. Instead of displaying the thermal image on a traditional TFT display, the visualization is rendered on a desktop or laptop. The Arduino captures an 8x8 pixel grid of temperature values from the sensor and sends it over serial to a Processing sketch, which generates a real-time, color-coded thermal map.

The visualization supports optional interpolation, enhancing the image by making it smoother and more detailed. This project is inspired by Adafruit's work with the AMG8833 sensor and expands on it by introducing custom interpolation techniques and a desktop/laptop display option.

## Features

- **Real-time visualization**: Displays the thermal image in real time on your desktop or laptop.
- **Interpolation**: Option to enable interpolation for a smoother visual representation of temperature gradients.
- **Customizable color mapping**: Modify the colors used to represent temperature values in the visualization.
- **Inspired by Adafruit**: The code and implementation draw inspiration from Adafruit’s resources for the AMG8833 sensor.
- **Easy setup**: Simple wiring and code upload process to get started quickly.


## Usage Instructions

1. **Set up the hardware:**
   - Connect the AMG8833 thermal sensor to your Arduino according to the wiring diagram provided in Adafruit's documentation.

2. **Upload the Arduino code:**
   - Open the provided Arduino sketch in the Arduino IDE and upload it to your board.
   - The Arduino will capture the temperature data from the sensor and transmit it over the serial port.

3. **Run the Processing sketch:**
   - Open the Processing sketch in Processing IDE and make sure the correct serial port is selected.
   - Run the Processing sketch to visualize the thermal image on your desktop or laptop.
   - You can enable or disable interpolation by adjusting the `interpolate` flag in the Processing sketch.

<p align="center">
  <img width="389" alt="image" src="https://github.com/user-attachments/assets/54d4096c-8d1a-4857-a74c-f727dfc8d1e7">
  <br>
  <caption>Example image captured on desktop with 8x interpolation</caption>
</p>
<p align="center">
<img width="396" alt="image" src="https://github.com/user-attachments/assets/1c8c53a4-32cb-45d5-95e9-a6b7808e3278">
<br>
  <caption>Original image captured on desktop with no interpolation</caption>
  </p>


