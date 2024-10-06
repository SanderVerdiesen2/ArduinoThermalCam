/*
  Author: Sander Verdiesen
  Date: 06/10/2024
  Email: sjverdiesen@gmail.com

  Description:
  This script reads temperature data from an AMG8833 sensor connected to an Arduino
  and displays the temperature grid using Processing. The grid is either shown with 
  or without interpolation, depending on the 'interpolate' flag. 

  When interpolation is enabled, the 8x8 sensor data is expanded to a larger grid 
  (64x64) using bilinear interpolation, providing a smoother visual representation.

  The colors representing the temperature values are mapped from a predefined color 
  palette, and the visualization is updated in real-time as new data is received 
  over the serial connection.

  The color palette is based on the RGB565 format, and the grid adjusts automatically 
  to fit the window size.
  
  Inspired by Adafruit.

  Usage:
  - Set 'interpolate = true' to apply bilinear interpolation for a smoother grid.
  - Set 'interpolate = false' to display the raw 8x8 grid.

  Hardware:
  - AMG8833 thermal camera sensor
  - Arduino (with serial communication)
  - Processing (for visualization)
*/

import processing.serial.*;

// Define the minimum and maximum temperature
final int MINTEMP = 15;
final int MAXTEMP = 25;

int rows = 8;
int cols = 8;
boolean interpolate = true;  // false: original 8x8 image. true: interpolate by interpolation factor
int interpolationFactor = 8; // multiplies the original number of pixels

// Define the colors array using RGB565 format
int[] camColors = {
    0x480F, 0x400F, 0x400F, 0x400F, 0x4010, 0x3810, 0x3810, 0x3810, 0x3810, 
    0x3010, 0x3010, 0x3010, 0x2810, 0x2810, 0x2810, 0x2810, 0x2010, 0x2010,
    0x2010, 0x1810, 0x1810, 0x1811, 0x1811, 0x1011, 0x1011, 0x1011, 0x0811,
    0x0811, 0x0811, 0x0011, 0x0011, 0x0011, 0x0011, 0x0011, 0x0031, 0x0031,
    0x0051, 0x0072, 0x0072, 0x0092, 0x00B2, 0x00B2, 0x00D2, 0x00F2, 0x00F2,
    0x0112, 0x0132, 0x0152, 0x0152, 0x0172, 0x0192, 0x0192, 0x01B2, 0x01D2,
    0x01F3, 0x01F3, 0x0213, 0x0233, 0x0253, 0x0253, 0x0273, 0x0293, 0x02B3,
    0x02D3, 0x02D3, 0x02F3, 0x0313, 0x0333, 0x0333, 0x0353, 0x0373, 0x0394,
    0x03B4, 0x03D4, 0x03D4, 0x03F4, 0x0414, 0x0434, 0x0454, 0x0474, 0x0474,
    0x0494, 0x04B4, 0x04D4, 0x04F4, 0x0514, 0x0534, 0x0534, 0x0554, 0x0554,
    0x0574, 0x0574, 0x0573, 0x0573, 0x0573, 0x0572, 0x0572, 0x0572, 0x0571,
    0x0591, 0x0591, 0x0590, 0x0590, 0x058F, 0x058F, 0x058F, 0x058E, 0x05AE,
    0x05AE, 0x05AD, 0x05AD, 0x05AD, 0x05AC, 0x05AC, 0x05AB, 0x05CB, 0x05CB,
    0x05CA, 0x05CA, 0x05CA, 0x05C9, 0x05C9, 0x05C8, 0x05E8, 0x05E8, 0x05E7,
    0x05E7, 0x05E6, 0x05E6, 0x05E6, 0x05E5, 0x05E5, 0x0604, 0x0604, 0x0604,
    0x0603, 0x0603, 0x0602, 0x0602, 0x0601, 0x0621, 0x0621, 0x0620, 0x0620,
    0x0620, 0x0620, 0x0E20, 0x0E20, 0x0E40, 0x1640, 0x1640, 0x1E40, 0x1E40,
    0x2640, 0x2640, 0x2E40, 0x2E60, 0x3660, 0x3660, 0x3E60, 0x3E60, 0x3E60,
    0x4660, 0x4660, 0x4E60, 0x4E80, 0x5680, 0x5680, 0x5E80, 0x5E80, 0x6680,
    0x6680, 0x6E80, 0x6EA0, 0x76A0, 0x76A0, 0x7EA0, 0x7EA0, 0x86A0, 0x86A0,
    0x8EA0, 0x8EC0, 0x96C0, 0x96C0, 0x9EC0, 0x9EC0, 0xA6C0, 0xAEC0, 0xAEC0,
    0xB6E0, 0xB6E0, 0xBEE0, 0xBEE0, 0xC6E0, 0xC6E0, 0xCEE0, 0xCEE0, 0xD6E0,
    0xD700, 0xDF00, 0xDEE0, 0xDEC0, 0xDEA0, 0xDE80, 0xDE80, 0xE660, 0xE640,
    0xE620, 0xE600, 0xE5E0, 0xE5C0, 0xE5A0, 0xE580, 0xE560, 0xE540, 0xE520,
    0xE500, 0xE4E0, 0xE4C0, 0xE4A0, 0xE480, 0xE460, 0xEC40, 0xEC20, 0xEC00,
    0xEBE0, 0xEBC0, 0xEBA0, 0xEB80, 0xEB60, 0xEB40, 0xEB20, 0xEB00, 0xEAE0,
    0xEAC0, 0xEAA0, 0xEA80, 0xEA60, 0xEA40, 0xF220, 0xF200, 0xF1E0, 0xF1C0,
    0xF1A0, 0xF180, 0xF160, 0xF140, 0xF100, 0xF0E0, 0xF0C0, 0xF0A0, 0xF080,
    0xF060, 0xF040, 0xF020, 0xF800
};



int newRows = interpolationFactor*rows; // New number of rows for interpolation
int newCols = interpolationFactor*cols; // New number of columns for interpolation
int cellSize;
float[][] pixels = new float[rows][cols]; // Array to hold temperature values
float[][] interpolatedPixels = new float[newRows][newCols]; // Array for interpolated values

// Define an array to hold the color objects
color[] colors = new color[camColors.length];

Serial myPort;

void setup() {
    size(800, 800);
    myPort = new Serial(this, Serial.list()[0], 115200); // Adjust the port index if necessary
    int  cellHeight;
    // Calculate cell size based on canvas width and number of columns
    if(interpolate){
      cellSize = int(width / newCols); // Explicitly cast to int
      // Calculate cell height based on canvas height and number of rows
      cellHeight = int(height / newRows); // Explicitly cast to int
    } else {
      cellSize = int(width / cols); // Explicitly cast to int
      // Calculate cell height based on canvas height and number of rows
      cellHeight = int(height / rows); // Explicitly cast to int
    }

    if (cellSize != cellHeight) {
        println("Warning: Cell width and height are not equal. Adjusting to use the minimum size.");
        cellSize = min(cellSize, cellHeight); // Use the smaller value for consistency
    }

    // Initialize colors
    for (int i = 0; i < camColors.length; i++) {
        int colorValue = camColors[i];

        // Extract RGB values from the RGB565 format
        int r = (colorValue >> 11) & 0x1F; // Red
        int g = (colorValue >> 5) & 0x3F;  // Green
        int b = colorValue & 0x1F;         // Blue

        // Convert to 0-255 scale
        r = (r << 3) | (r >> 2);
        g = (g << 2) | (g >> 4);
        b = (b << 3) | (b >> 2);

        colors[i] = color(r, g, b); // Store the color in the array
    }
}

void draw() {
    if (myPort.available() > 0) {
        String data = myPort.readStringUntil('\n');
        if (data != null) {
            data = data.trim(); // Remove any leading/trailing whitespace
            String[] values = data.split(",");

            if (values.length == rows * cols) {
                // Populate the pixels array with the received temperature values
                int index = 0;
                for (int i = 0; i < rows; i++) {
                    for (int j = 0; j < cols; j++) {
                        pixels[i][j] = float(values[index]);
                        index++;
                    }
                }
                if (interpolate) {
                    interpolate(); // Interpolate only if flag is set
                }
                drawGrid(); // Draw the temperature grid
            }
        }
    }
}




void interpolate() {
    for (int i = 0; i < newRows; i++) {
        for (int j = 0; j < newCols; j++) {
            // Calculate the corresponding pixel in the original 8x8 grid
            float x = float(i) / newRows * (rows - 1);
            float y = float(j) / newCols * (cols - 1);

            int x1 = int(x);
            int y1 = int(y);
            int x2 = min(x1 + 1, rows - 1);
            int y2 = min(y1 + 1, cols - 1);

            // Calculate the fractional parts
            float fx = x - x1;
            float fy = y - y1;

            // Interpolate between the four surrounding pixels
            float a = pixels[x1][y1] * (1 - fx) * (1 - fy); // Top-left
            float b = pixels[x1][y2] * (1 - fx) * fy;       // Bottom-left
            float c = pixels[x2][y1] * fx * (1 - fy);       // Top-right
            float d = pixels[x2][y2] * fx * fy;             // Bottom-right

            interpolatedPixels[i][j] = a + b + c + d;
        }
    }
}



void drawGrid() {
    // Loop through either the interpolated grid (newRows/newCols) or the original grid (rows/cols)
    // depending on whether interpolation is enabled or not
    for (int i = 0; i < (interpolate ? newRows : rows); i++) {
        for (int j = 0; j < (interpolate ? newCols : cols); j++) {
            // Get the temperature value from either the interpolated array or the original array
            float value = interpolate ? interpolatedPixels[i][j] : pixels[i][j];

            // Map the temperature value to an index in the colors array
            int colorIndex = int(map(value, MINTEMP, MAXTEMP, 0, colors.length - 1));

            // Ensure the color index stays within the valid range of the colors array
            colorIndex = constrain(colorIndex, 0, colors.length - 1);

            // Set the fill color based on the mapped temperature value
            fill(colors[colorIndex]);

            // Draw a rectangle at the corresponding grid position
            rect(j * cellSize, i * cellSize, cellSize, cellSize);
        }
    }
}
