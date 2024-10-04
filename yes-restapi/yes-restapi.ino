#include <WiFiManager.h>
#include <HTTPClient.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <ArduinoJson.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
WiFiManager wm;

// Pin configuration for button
const int buttonPin = 2; // Adjust according to your pin setup
int currentPage = 0;     // Tracks the current page

// API URL for fetching table data
const char* apiURL = "http://192.168.152.205/api/get_available_tables.php"; // Update this URL accordingly

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);

  // Initialize OLED display
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;); // Keep retrying indefinitely if OLED fails to initialize
  }

  display.clearDisplay();
  
  // Display running stars animation
  starAnimation(); 

  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);

  // Set up button input pin
  pinMode(buttonPin, INPUT_PULLUP);

  // Initializing message on the display
  display.setCursor(0, 0);
  display.println("Initializing...");
  display.display();
  delay(2000);

  // WiFi auto-connect setup
  bool res = wm.autoConnect("AutoConnectAP1111", "password"); // Set SSID and Password as needed
  
  if (!res) {
    Serial.println("Failed to connect or hit timeout");
    ESP.restart();
  } else {
    Serial.println("Connected to WiFi");
    displayText("Connected to WiFi");
    delay(2000);
  }
}

void loop() {
  // Check if the button is pressed
  if (digitalRead(buttonPin) == LOW) {
    currentPage = (currentPage + 1) % 1; // Cycle through pages (currently only one page)
    delay(300); // Debounce to prevent accidental multiple presses
  }

  // Display table information on the current page
  if (currentPage == 0) {
    fetchTableData(); // Fetch and display table data
  }

  delay(10000); // Adjust delay as needed
}

// Function to fetch table data from the API
void fetchTableData() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(apiURL);
    int httpCode = http.GET();

    Serial.print("HTTP Code: ");
    Serial.println(httpCode);

    if (httpCode > 0) {
      String payload = http.getString();
      Serial.println("Received Data: ");
      Serial.println(payload);

      // Parse JSON data using ArduinoJson
      StaticJsonDocument<1024> doc;
      DeserializationError error = deserializeJson(doc, payload);
      
      if (!error) {
        int availableCount = 0;
        display.clearDisplay();
        display.setCursor(0, 0);

        // Set text size for "Scan2Eat" and display it
        display.setTextSize(1.25); 
        display.setTextColor(SSD1306_WHITE);
        display.println("Scan2Eat");
        display.setTextSize(1);
        display.println("");

        // Set text size for "Available tables" and display it
        display.setTextSize(1.5);
        display.println("Available tables:");

        // Count available tables
        for (JsonObject table : doc.as<JsonArray>()) {
          String status = table["status"].as<String>();
          Serial.print("Table ");
          Serial.print(table["table_number"].as<int>());
          Serial.print(" status: ");
          Serial.println(status);

          if (status == "available") {
            availableCount++;
          }
        }

        // Display available table count
        display.setTextSize(2); 
        display.setCursor(0, 40); 
        display.print(availableCount); 
        display.print("/10"); // Assuming there are 10 tables
        display.display();
      } else {
        Serial.println("JSON parsing failed!");
        displayText("JSON error");
      }
      
    } else {
      Serial.println("Error on HTTP request");
      displayText("HTTP request error");
    }

    http.end();
  } else {
    Serial.println("WiFi not connected");
    displayText("WiFi not connected");
  }
}

// Function to display a running stars animation
void starAnimation() {
  for (int i = 0; i < SCREEN_WIDTH; i += 10) {
    display.clearDisplay();
    // Draw moving stars
    display.fillCircle(i, 10, 2, SSD1306_WHITE); // Top row star
    display.fillCircle(i + 30, 30, 3, SSD1306_WHITE); // Middle row star
    display.fillCircle(i + 60, 50, 2, SSD1306_WHITE); // Bottom row star
    display.display();
    delay(100); // Adjust the speed of the stars
  }
}

// Helper function to display a single line of text
void displayText(String text) {
  display.clearDisplay();
  display.setCursor(0, 0);
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.println(text);
  display.display();
}
