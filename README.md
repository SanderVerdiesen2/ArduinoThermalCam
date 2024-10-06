# AMG8833 Thermal Sensor Visualization
This project demonstrates how to visualize data from the AMG8833 infrared thermal sensor using an Arduino and Processing. Instead of using a traditional TFT display, the thermal image is displayed on a desktop or laptop. The Arduino captures an 8x8 pixel grid of temperature values from the sensor and sends it over serial to a Processing sketch, which renders a color-coded thermal map in real-time.

The map supports optional interpolation for smoother visuals, making the display more detailed and refined. This project was inspired by Adafruit's work with the AMG8833 sensor and extends it to include custom interpolation and visualization techniques. The Processing sketch dynamically adjusts to different temperature ranges and color schemes, making it adaptable for various thermal imaging applications.

Example image captured on desktop with 8x interpolation.
<img width="389" alt="image" src="https://github.com/user-attachments/assets/54d4096c-8d1a-4857-a74c-f727dfc8d1e7">

