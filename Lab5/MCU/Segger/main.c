// button_interrupt.c
// Josh Brake
// jbrake@hmc.edu
// 10/31/22

#include "main.h"

// State bits
volatile int oldState = 0;
volatile int A = 0;
volatile int B = 0;

// revolutions count
volatile double count = 0;

/*
Counts the number of pulses sent out by the encoder

Used by the EXTI9_5_IRQHandler function to update based on interupts 
*/
void updateCount(void){
    int QEM [16] = {0,-1,1,2,1,0,2,-1,-1,2,0,1,2,1,-1,0};
    int index;
    index = oldState * 4 +  (A*2) + B;

    count += QEM[index];
    oldState = (A*2) + B;
}

int _write(int file, char *ptr, int len) {
  int i = 0;
  for (i = 0; i < len; i++) {
    ITM_SendChar((*ptr++));
  }
  return len;
}

/*
External Interrupt Handler.

Triggered by GPIO pins PA6 and PA8 on rising and falling edge of each.

Global Variables A and B can only be used by this handler.
*/
void EXTI9_5_IRQHandler(void)
{
    digitalWrite(PA9, 1);
    if (EXTI->PR1 & (1 << 6)) {  // Check line 6
        EXTI->PR1 = (1 << 6);    // Clear pending bit
        
        A = digitalRead(QEA_PIN);
        updateCount();
    }

    if (EXTI->PR1 & (1 << 8)) {  // Check line 8
        EXTI->PR1 = (1 << 8);    // Clear pending bit
        B = digitalRead(QEB_PIN);
        updateCount();
    }

    digitalWrite(PA9,0);
}

int main(void) {
    configureFlash();
    //Enable gpio banks
    gpioEnable(GPIO_PORT_A);

    // Enable QEA as input
    pinMode(QEA_PIN, GPIO_INPUT); //USE PA6
    GPIOA->PUPDR &= ~_VAL2FLD(GPIO_PUPDR_PUPD6, 0b11);
    GPIOA->PUPDR |=  _VAL2FLD(GPIO_PUPDR_PUPD6, 0b01);

    // Enable QEB as input
    pinMode(QEB_PIN, GPIO_INPUT); // USE PA8
    GPIOA->PUPDR &= ~_VAL2FLD(GPIO_PUPDR_PUPD8, 0b11);
    GPIOA->PUPDR |=  _VAL2FLD(GPIO_PUPDR_PUPD8, 0b01);
    
    // Initialize values
    count = 0;
    A = (GPIOA->IDR & (1U << 6)) ? 1 : 0;
    B = (GPIOA->IDR & (1U << 8)) ? 1 : 0;
    oldState = (A << 1) | B;

    // Initialize timer
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
    initTIM(DELAY_TIM);

    // 1. Enable SYSCFG clock domain in RCC
    RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;
    // 2. Configure EXTICR for the input button interrupt
    SYSCFG->EXTICR[2] |= (_VAL2FLD(SYSCFG_EXTICR2_EXTI6, 0b000)); // Select PA6
    SYSCFG->EXTICR[3] |= (_VAL2FLD(SYSCFG_EXTICR3_EXTI8, 0b000)); // Select PA8

    // Enable interrupts globally
    __enable_irq();

    // Enable QEA and QEB as intrupts
    int pins[] = {6, 8};
    for (int i = 0; i < 2; i++) {
        int pin = pins[i];
        EXTI->IMR1  |= (1 << pin);
        EXTI->RTSR1 |= (1 << pin);
        EXTI->FTSR1 |= (1 << pin);
    }
    
  
    // Turn on EXTI interrupt in NVIC_ISER
    EXTI->PR1 = (0b11111 << 5); //clear flags
    NVIC_EnableIRQ(EXTI9_5_IRQn);
    

    while(1){   
        delay_millis(TIM2, 500);
        float revs_per_sec = count / (0.5 * (408*4));
        printf("Revs/s: %.2f, count: %.1f \n", revs_per_sec, count);
        count = 0;
    }

}