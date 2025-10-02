#include "STM32L432KC_TIM.h"

// Note the clock input from RCC is at 5MHz

void initTIM15(void){

    // Disable counter
    TIM15->TIM15_CR1 &= ~(0b1);

    // Disable Auto Pre-load register (constant value for counter)
    TIM15->TIM15_CR1  &= ~(0b1 << 7);

    // Disable Slave Master Select (SMS) to use internal clock from RCC
    TIM15->TIM15_SMCR &= ~(0b111);

    // Disable inturupts
    TIM15->TIM15_DIER &= ~(0b1);

    // Set Prescaler (divide by 500 (PSC + 1))
    // PSC clock is at 10kHz
    // Delay is 100uS (micro seconds)
    TIM15->TIM15_PSC = 499;

    // Clear ARR since reset value is 0xFFFF
    TIM15->TIM15_ARR = 0;
    // Set couter value to 9. Delay is now 1ms
    TIM15->TIM15_ARR = 19;                // Set bits to intended counter top
    // Update and Enable counter
    TIM15->TIM15_EGR   |= (0b1); // Force update generatio (UG) bit to be 1
    TIM15->TIM15_CR1   |= (0b1);
}

void DelayTIM15(uint32_t ms){
    // reset counter
    TIM15->TIM15_CNT  = 0;
    // clear flag
    TIM15->TIM15_SR   &= ~(0b1);

    // loop timer untill ms miliseconds passes
    for (int i = 0; i < ms; i++) {
        // Wait until counter overflow based off ARR value
        while ((TIM15->TIM15_SR & 1) == 0);
        // Clear Update Interupt FLag (UIF)
        TIM15->TIM15_SR   &= ~(0b1);
    }
}

void initTIM16(void) {
    // Disable counter
    TIM16->TIM16_CR1 &= ~1;

    // PWM mode 1 on CH1 (OC1M = 110)
    TIM16->TIM16_CCMR1 &= ~(0x7 << 4);
    TIM16->TIM16_CCMR1 |=  (0x6 << 4);

    // Enable CCR1 preload
    TIM16->TIM16_CCMR1 |= (1 << 3);

    // Enable ARR preload
    TIM16->TIM16_CR1 |= (1 << 7);

    // Active high polarity
    TIM16->TIM16_CCER &= ~(1 << 1);

    //Set divider to 1
    TIM16->TIM16_PSC = 0;

    // Enable output
    TIM16->TIM16_BDTR |= (1 << 15); // MOE
    TIM16->TIM16_CCER |= (1 << 0);  // CC1E

    // Update registers
    TIM16->TIM16_EGR |= 1;
}


void setTIM16_freq(uint32_t freq) {
    // Disable counter
    TIM16->TIM16_CR1 &= ~1;

    // Reset counter
    TIM16->TIM16_CNT = 0;

    if (freq > 0) {
        // Compute ARR (PSC=0)
        uint32_t ARR_Val = ((5000000 * 2) / freq) - 1;

        // Update ARR and CCR1
        TIM16->TIM16_ARR  = ARR_Val;
        TIM16->TIM16_CCR1 = ARR_Val / 2;   // 50% duty

        // Force update and start counter
        TIM16->TIM16_EGR |= 1;
        TIM16->TIM16_CR1 |= 1;
    } else {
        // Stop PWM output → 0% duty
        TIM16->TIM16_CCR1 = 0;
        TIM16->TIM16_EGR |= 1;
        TIM16->TIM16_CR1 |= 1;
    }
}
