// STM32L432KC_GPIO.c
// Source code for GPIO functions

#include "STM32L432KC_GPIO.h"

void pinMode(int pin, int function) {
    switch(function) {
        case GPIO_INPUT:
            GPIO->MODER &= ~(0b11 << 2*pin);
            break;
        case GPIO_OUTPUT:
            GPIO->MODER |= (0b1 << 2*pin);
            GPIO->MODER &= ~(0b1 << (2*pin+1));
            break;
        case GPIO_ALT:
            GPIO->MODER &= ~(0b1 << 2*pin);
            GPIO->MODER |= (0b1 << (2*pin+1));
            break;
        case GPIO_ANALOG:
            GPIO->MODER |= (0b11 << 2*pin);
            break;
    }
}

int digitalRead(int pin) {
    return ((GPIO->IDR) >> pin) & 1;
}

void digitalWrite(int pin, int val) {
    GPIO->ODR |= (1 << pin);
}

void togglePin(int pin) {
    // Use XOR to toggle
    GPIO->ODR ^= (1 << pin);
}

void PA6OutputPWM(){
    // TIM16_CH1 comes out by AF1 through Port A PA16.

    // To set pin PA6 to Alternate Function 1, connecting it to TIM2_CH1, the PWM output.
    pinModeGPIOA(6, GPIO_ALT);

    // Set which alternate function is connected
    GPIOA->AFRH &= (~(0b1111<<24));   
    GPIOA->AFRH |= (0b1110<<24);      

    // Select the type, pull-up/pull-down, and output speed respectively via GPIOA_OTYPER, GPIOA_PUPDR, GPIOA_OSPEEDER 
    // Make sure pin A6 is in push-pull configuration
    GPIOA->OTYPER &= (~(0b1<<6)); // Check this

    // Set speed to low
    GPIOA->OSPEEDR &= (~(0b11<<12));

    // PWM should be setting our output, so turn off pin A6 PU and PD res's. GPIOA_PUPDR[11:10] clear to 00
    GPIOA->PUPDR &= (~(0b11<<12));
}