/**
    Main Header: Contains general defines and selected portions of CMSIS files
    @file main.h
    @author Josh Brake
    @version 1.0 10/7/2020
*/

#ifndef MAIN_H
#define MAIN_H

#include "STM32L432KC.h"

#define LED_PIN PA3 // LED pin for blinking on Port B pin 3
#define BUFF_LEN 32

#define SPI_CE PA11
#define SPI_SCK PB3
#define SPI_MOSI PB5
#define SPI_MISO PB4

#endif // MAIN_H