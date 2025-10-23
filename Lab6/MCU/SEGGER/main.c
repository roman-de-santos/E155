/*
File: Lab_6_JHB.c
Author: Josh Brake
Email: jbrake@hmc.edu
Date: 9/14/19
*/


#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "STM32L432KC.h"

/////////////////////////////////////////////////////////////////
// Provided Constants and Functions
/////////////////////////////////////////////////////////////////

//Defining the web page in two chunks: everything before the current time, and everything after the current time
char* webpageStart = "<!DOCTYPE html><html><head><title>E155 Web Server Demo Webpage</title>\
	<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\
	</head>\
	<body><h1>E155 Web Server Demo Webpage</h1>";
char* ledStr = "<p>LED Control:</p><form action=\"ledon\"><input type=\"submit\" value=\"Turn the LED on!\"></form>\
	<form action=\"ledoff\"><input type=\"submit\" value=\"Turn the LED off!\"></form>";

char* tempStr = "<p>Temperature Resolution Control:</p><form action=\"8bit\"><input type=\"submit\" value=\"8 Bit!\"></form>\
	<form action=\"9bit\"><input type=\"submit\" value=\"9 Bit!\"></form>\
        <form action=\"10bit\"><input type=\"submit\" value=\"10 Bit!\"></form>\
        <form action=\"11bit\"><input type=\"submit\" value=\"11 Bit!\"></form>\
        <form action=\"12bit\"><input type=\"submit\" value=\"12 Bit!\"></form>";

char* webpageEnd   = "</body></html>";

//determines whether a given character sequence is in a char array request, returning 1 if present, -1 if not present
int inString(char request[], char des[]) {
	if (strstr(request, des) != NULL) {return 1;}
	return -1;
}

int updateLEDStatus(char request[])
{
	int led_status = 0;
	// The request has been received. now process to determine whether to turn the LED on or off
	if (inString(request, "ledoff")==1) {
		digitalWrite(LED_PIN, PIO_LOW);
		led_status = 0;
	}
	else if (inString(request, "ledon")==1) {
		digitalWrite(LED_PIN, PIO_HIGH);
		led_status = 1;
	}

	return led_status;
}

/////////////////////////////////////////////////////////////////
// Solution Functions
/////////////////////////////////////////////////////////////////

int main(void) {
  configureFlash();
  configureClock();

  gpioEnable(GPIO_PORT_A);
  gpioEnable(GPIO_PORT_B);
  
  pinMode(LED_PIN, GPIO_OUTPUT);

  pinMode(SPI_CE, GPIO_OUTPUT);
  pinMode(SPI_SCK, GPIO_ALT);
  GPIOA->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL3, 5U);

  pinMode(SPI_MOSI, GPIO_ALT);
  GPIOA->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL5, 5U);

  pinMode(SPI_MISO, GPIO_ALT);
  GPIOA->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL4, 5U);

  RCC->APB2ENR |= (RCC_APB2ENR_TIM15EN);
  initTIM(TIM15);
  
  USART_TypeDef * USART = initUSART(USART1_ID, 125000);

  // TODO: Add SPI initialization code
  initSPI(10000, 0, 1);

  while(1) {
    /* Wait for ESP8266 to send a request.
    Requests take the form of '/REQ:<tag>\n', with TAG begin <= 10 characters.
    Therefore the request[] array must be able to contain 18 characters.
    */

    // Receive web request from the ESP
    char request[BUFF_LEN] = "                  "; // initialize to known value
    int charIndex = 0;
  
    // Keep going until you get end of line character
    while(inString(request, "\n") == -1) {
      // Wait for a complete request to be transmitted before processing
      while(!(USART->ISR & USART_ISR_RXNE));
      request[charIndex++] = readChar(USART);
    }

    // TODO: Add SPI code here for reading temperature
    char tempStatusStr[20];
    float temp = 0;
    temp = sendResGetTemp(request, SPI_CE);

    sprintf(tempStatusStr, "Temp: %.4f C", temp);
    
    // Update string with current LED state
    int led_status = updateLEDStatus(request);

    char ledStatusStr[20];
    if (led_status == 1)
      sprintf(ledStatusStr,"LED is on!");
    else if (led_status == 0)
      sprintf(ledStatusStr,"LED is off!");

    // finally, transmit the webpage over UART
    sendString(USART, webpageStart); // webpage header code
    sendString(USART, ledStr); // button for controlling LED

    sendString(USART, "<h2>LED Status</h2>");


    sendString(USART, "<p>");
    sendString(USART, ledStatusStr);
    sendString(USART, "</p>");

    // Bit resolution buttons 
    sendString(USART, tempStr);

    sendString(USART, "<h2>Temperature</h2>");

    sendString(USART, "<p>");
    sendString(USART, tempStatusStr); // Update to be the formatted temperature
    sendString(USART, "</p>");
  
    sendString(USART, webpageEnd);
  }
}
