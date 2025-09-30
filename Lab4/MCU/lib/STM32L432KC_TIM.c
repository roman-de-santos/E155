#include <STM32L432KC_TIM.h>

// Note the clock input from RCC is at 5MHz

initTIM15(void){

    // Disable counter
    TIM15->CR1 &= ~(0b1);

    // Disable Auto Pre load register (constant value for counter)
    TIM15->TIM15_CR1  &= (~0b1 << 7);

    // Disable Slave Master Select (SMS) to use internal clock from RCC
    TIM15->TIM15_SMCR &= ~(0b111);

    // Disable inturupts
    TIM15->TIM15_DIER &= ~(0b1);

    // Set Prescaler (divide by 500 (PSC + 1))
    // PSC clock is at 5kHz
    // Delay is 200uS (micro seconds)
    TIM15->TIM15_PSC  |= (0b111110011);     //0b111110011 = 499

    // Clear ARR since reset value is 0xFFFF
    TIM15->TIM15_ARR &= (~(0b1111111111111111));           // Clear bits 15:0
    // Set couter value to 5. Delay is now 1ms
    TIM15->TIM15_ARR |= 0b0000000000000101;                // Set bits to intended counter top
    // Update and Enable counter
    TIM15->TIM15_EGR   |= (0b1); // Force update generatio (UG) bit to be 1
    TIM15->CR1         |= (0b1);
}

void DelayTIM15(uint32_t ms){
    // reset counter
    TIM15->TIM15_CNT  &= ~(0b1111111111111111);
    // clear flag
    TIM15->TIM15_SR   &= ~(0b1);

    // loop timer untill ms miliseconds passes
    for (int i = 0; i < ms; i++) {
        // Wait until counter overflow based off ARR value
        while ((TIM15->TIM15_SR & 1) != 0);
        // Clear Update Interupt FLag (UIF)
        TIM15->TIM15_SR   &= ~(0b1);
    }
}

void initTIM16(){

    // Disable counter
    TIM16->CR1 &= ~(0b1);

    // Enable PWM Mode 1 (Channel 1 is active as long as TIM16_CNT<TIM16_CCR1)
    TIM16->TIM16_CCMR1 &= ~(0b1111 << 4); // clear before writing
    TIM16->TIM16_CCMR1 |=  (0b0110 << 4);

    // Enable OC1PE bit to load TIM16_CCR1 preload value at each update event
    TIM16->TIM16_CCMR1 |= (0b1 << 3);

    // Enable preload buffer
    TIM16->TIM16_CR1 |= (0b1 << 7);

    // Set as active high
    TIM16->TIM16_CCER &= ~(0b1 << 1);

    // Set CC1E and MOE to 1, to enable output of the PWM wave to OC1REF
    TIM16->TIM16_BDTR |= (0b1 << 15); // Main Output Enable (MOE)
    TIM16->TIM16_CCER |= (0b1);       // CC1E on bit 1



    // Update counter registers
    TIM16->TIM15_EGR   |= (0b1); // Force update generatio (UG) bit to be 1
    
    // Enable in the setTIM16_freq function so that there are no floating values
    // in the duty cycle and freq registers
}

void setTIM16_freq(uint32_t freq){
    // Disable counter
    TIM16->CR1 &= ~(0b1);

    // reset counter
    TIM15->TIM15_CNT  &= ~(0b1111111111111111);
    
    if (freq > 0){
        // Calculate Auto Reload Register division factor
        uint32_t ARR_Val = ((5000000)/freq);

        TIM16->TIM16_ARR &= 0b0;                  // Clear
        TIM16->TIM16_ARR |= ARR_Val;

        // 50% duty cycle
        TIM16->TIM16_CCR1 &= 0b0;                  // Clear
        TIM16->TIM16_CCR1 |= (ARR_Val/2);   // Find 50% of ARR value that

        // Update and Enable counter
        TIM16->TIM15_EGR   |= (0b1); // Force update generatio (UG) bit to be 1
        TIM16->CR1         |= (0b1);
        
    } else{
        // From the reference manual " If the compare value is 0 then OC16Ref is held at ‘0"
        // 0% duty cycle
        TIM16->TIM16_CCR1 &= 0b0;                  // Clear

        // Update and Enable counter
        TIM16->TIM15_EGR   |= (0b1); // Force update generatio (UG) bit to be 1
        TIM16->CR1         |= (0b1);
    }

}