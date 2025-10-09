// button_interrupt.c
// Josh Brake
// jbrake@hmc.edu
// 10/31/22

#include "main.h"

// State bits
volatile int A = 0;
volatile int B = 0;
volatile int oldState = 0;

// revolutions count
volatile int count = 0;

int main(void) {
    //Enable gpio banks
    gpioEnable(GPIO_PORT_A);

    // Enable QEA as input
    pinMode(QEA_PIN, GPIO_INPUT); //USE PA6
    GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD6, 0b01); // Set PA6 as pull-up

    // Enable QEB as input
    pinMode(QEB_PIN, GPIO_INPUT); // USE PA8
    GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD8, 0b01); // Set PA8 as pull-up

    // Initialize timer
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
    initTIM(DELAY_TIM);

    // 1. Enable SYSCFG clock domain in RCC
    RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;
    // 2. Configure EXTICR for the input button interrupt
    SYSCFG->EXTICR[2] |= _VAL2FLD(SYSCFG_EXTICR2_EXTI6, 0b000); // Select PA6
    SYSCFG->EXTICR[3] |= _VAL2FLD(SYSCFG_EXTICR3_EXTI8, 0b000); // Select PA8

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
    NVIC_EnableIRQ(EXTI9_5_IRQn);
    

    while(1){   
        delay_millis(TIM2, 500);
        float revs = count/(0.5);
        printf("Revs/s: %.1f", revs);
        count = 0;
    }

}

void updateCount(void){
    int QEM [16] = {0,-1,1,2,1,0,2,-1,-1,2,0,1,2,1,-1,0};
    int index;
    index = oldState * 4 +  (A*2) + B;

    count += QEM[index];
    oldState = (A*2) + B;
}


void EXTI9_5_IRQHandler(void)
{
    if (EXTI->PR1 & (1 << 6)) {  // Check line 6
        EXTI->PR1 = (1 << 6);    // Clear pending bit
        
        A = !A;
        updateCount();
    }

    if (EXTI->PR1 & (1 << 8)) {  // Check line 8
        EXTI->PR1 = (1 << 8);    // Clear pending bit
        B = !B;
        updateCount();
    }
}