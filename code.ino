#include <ESP8266WiFi.h> 
#include <ESP8266WebServer.h> 
#include <ArduinoJson.h>
#include <Arduino.h>
#include <IRremoteESP8266.h>
#include <IRsend.h>
const uint16_t kIrLed = 16;  // ESP8266 GPIO pin to use. Recommended: 4 (D2).
IRsend irsend(kIrLed);  // Set the GPIO to be used to sending the message.

// Example of data captured by IRrecvDumpV2.ino
uint16_t rawData[83] = {9062, 4482,  620, 518,  608, 554,  596, 552,  598, 1680,  592, 528,  620, 530,  598, 552,  596, 554,  596, 1680,  568, 1678,  570, 552,  598, 1680,  592, 1656,  590, 530,  618, 532,  620, 528,  598, 552,  620, 528,  616, 530,  624, 1656,  592, 528,  598, 552,  596, 556,  620, 528,  598, 554,  622, 526,  620, 530,  622, 528,  622, 1654,  592, 530,  620, 528,  598, 550,  622, 530,  620, 530,  596, 1680,  590, 1656,  592, 528,  622, 528,  620, 528,  622, 528,  622};  // CARRIER_AC40 10D8100830
uint16_t rawData2[83] = {9082, 4460,  620, 560,  590, 560,  564, 584,  590, 560,  590, 562,  566, 582,  566, 584,  566, 584,  566, 1680,  568, 1680,  566, 584,  590, 1656,  568, 1680,  568, 582,  568, 582,  568, 582,  592, 558,  568, 582,  568, 582,  592, 1654,  594, 556,  592, 556,  594, 554,  594, 556,  594, 554,  592, 558,  594, 556,  594, 556,  594, 1626,  618, 558,  592, 530,  620, 528,  620, 530,  620, 530,  618, 1628,  622, 1626,  622, 528,  622, 526,  624, 526,  624, 526,  622};  // UNKNOWN 709DC0CA


const char* ssid = "Flybox_8A56";
const char* password = "80989222";

ESP8266WebServer server (80) ;

bool switchState = false;

void setup() {
Serial.begin(115200);
  irsend.begin();

// Connect to Wi-Fi
WiFi.begin(ssid, password );
while (WiFi.status () != WL_CONNECTED) {
  delay (1000);
  Serial.print(".");
}

Serial.println("Connected to WiFi");
Serial.println(WiFi. localIP());
// Define the URL endpoint to handle the GET request 
server.on("/", handleUpdateSwitchStatus);
server.begin();
Serial.println("HTTP server started");
}

void loop (){
  server.handleClient();
}

void handleUpdateSwitchStatus (){

String requestArg = server.arg("plain");
// Assuming the requestArg is a JSON string like {"switch_status": true}

DynamicJsonDocument jsonDoc (1024);
deserializeJson (jsonDoc, requestArg) ;

bool newSwitchStatus = jsonDoc ["switch_status"];
if (newSwitchStatus != switchState){
  switchState = newSwitchStatus;
  Serial.print ("Switch State Updated: ");
  Serial.println(switchState);
  if (switchState == true){
    Serial.println("ac on");
      irsend.sendRaw(rawData, 83, 38);  // Send a raw data capture at 38kHz.
      delay(2000);
  } else if (switchState == false ){
    Serial.println("ac off");
      irsend.sendRaw(rawData2, 83, 38);  // Send a raw data capture at 38kHz.
      delay(2000);
  }
}
}










