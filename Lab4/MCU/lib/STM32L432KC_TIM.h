#ifndef STM32L4_TIM_H
#define STM32L4_TIM_H

#include <stdint.h>

///////////////////////////////////////////////////////////////////////////////
// Definitions
///////////////////////////////////////////////////////////////////////////////

#define __IO volatile

// Base addresses
#define TIM15_BASE (0x40014000UL) // base address of TIM
#define TIM16_BASE (0x40014400UL) // base address of TIM

/**
  * @brief Timer Control
  */

// TIM15 structure  
typedef struct
{
  __IO uint32_t TIM15_CR1;           /*!< RCC clock control register,                                              Address offset: 0x00 */
  __IO uint32_t TIM15_CR2;           /*!< RCC internal clock sources calibration register,                         Address offset: 0x04 */
  __IO uint32_t TIM15_SMCR;          /*!< RCC clock configuration register,                                        Address offset: 0x08 */
  __IO uint32_t TIM15_DIER;          /*!< RCC system PLL configuration register,                                   Address offset: 0x0C */
  __IO uint32_t TIM15_SR;            /*!< RCC PLL SAI1 configuration register,                                     Address offset: 0x10 */                                                           
  __IO uint32_t TIM15_EGR;           /*!< RCC clock interrupt enable register,                                     Address offset: 0x14 */
  __IO uint32_t TIM15_CCMR1;         /*!< RCC clock interrupt flag register,                                       Address offset: 0x18 */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x1C */
  __IO uint32_t TIM15_CCER;          /*!< RCC clock interrupt clear register,                                      Address offset: 0x20 */  
  __IO uint32_t TIM15_CNT;           /*!< RCC AHB1 peripheral reset register,                                      Address offset: 0x24 */
  __IO uint32_t TIM15_PSC;           /*!< RCC AHB2 peripheral reset register,                                      Address offset: 0x28 */
  __IO uint32_t TIM15_ARR;           /*!< RCC AHB3 peripheral reset register,                                      Address offset: 0x2C */  
  __IO uint32_t TIM15_RCR;           /*!< RCC APB1 peripheral reset register 1,                                    Address offset: 0x30 */
  __IO uint32_t TIM15_CCR1;          /*!< RCC APB1 peripheral reset register 2,                                    Address offset: 0x34 */
  __IO uint32_t TIM15_CCR2;          /*!< RCC APB2 peripheral reset register,                                      Address offset: 0x38 */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x3C */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x40 */
  __IO uint32_t TIM15_BDTR;          /*!< RCC AHB1 peripheral clocks enable register,                              Address offset: 0x44 */
  __IO uint32_t TIM15_DCR;           /*!< RCC AHB2 peripheral clocks enable register,                              Address offset: 0x48 */
  __IO uint32_t TIM15_DMAR;          /*!< RCC AHB3 peripheral clocks enable register,                              Address offset: 0x4C */
  __IO uint32_t TIM15_OR1;           /*!< RCC APB1 peripheral clocks enable register 1,                            Address offset: 0x50 */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x54 */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x58 */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x5C */
  __IO uint32_t TIM15_OR2;           /*!< RCC APB2 peripheral clocks enable register,                              Address offset: 0x60 */
} TIM15_TypeDef;

#define TIM15 ((TIM15_TypeDef *) TIM15_BASE)

// TIM16 Structure
typedef struct
{
  __IO uint32_t TIM16_CR1;           /*!< RCC clock control register,                                              Address offset: 0x00 */
  __IO uint32_t TIM16_CR2;           /*!< RCC internal clock sources calibration register,                         Address offset: 0x04 */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x08 */
  __IO uint32_t TIM16_DIER;          /*!< RCC system PLL configuration register,                                   Address offset: 0x0C */
  __IO uint32_t TIM16_SR;            /*!< RCC PLL SAI1 configuration register,                                     Address offset: 0x10 */
  __IO uint32_t TIM16_EGR;           /*!< RCC clock interrupt enable register,                                     Address offset: 0x14 */
  __IO uint32_t TIM16_CCMR1;         /*!< RCC clock interrupt flag register,                                       Address offset: 0x18 */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x1C */
  __IO uint32_t TIM16_CCER;          /*!< RCC clock interrupt clear register,                                      Address offset: 0x20 */
  __IO uint32_t TIM16_CNT;           /*!< RCC AHB1 peripheral reset register,                                      Address offset: 0x24 */
  __IO uint32_t TIM16_PSC;           /*!< RCC AHB2 peripheral reset register,                                      Address offset: 0x28 */
  __IO uint32_t TIM16_ARR;           /*!< RCC AHB3 peripheral reset register,                                      Address offset: 0x2C */
  __IO uint32_t TIM16_RCR;           /*!< RCC APB1 peripheral reset register 1,                                    Address offset: 0x30 */
  __IO uint32_t TIM16_CCR1;          /*!< RCC APB1 peripheral reset register 2,                                    Address offset: 0x34 */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x38 */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x3C */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x40 */
  __IO uint32_t TIM16_BDTR;          /*!< RCC AHB1 peripheral clocks enable register,                              Address offset: 0x44 */
  __IO uint32_t TIM16_DCR;           /*!< RCC AHB2 peripheral clocks enable register,                              Address offset: 0x48 */
  __IO uint32_t TIM16_DMAR;          /*!< RCC AHB3 peripheral clocks enable register,                              Address offset: 0x4C */
  __IO uint32_t TIM16_OR1;           /*!< RCC APB1 peripheral clocks enable register 1,                            Address offset: 0x50 */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x54 */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x58 */
  uint32_t                           /*!< Reserved,                                                                Address offset: 0x5C */
  __IO uint32_t TIM15_OR2;           /*!< RCC APB2 peripheral clocks enable register,                              Address offset: 0x60 */
} TIM16_TypeDef;

#define TIM15 ((TIM15_TypeDef *) TIM15_BASE)

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

void initTIM15(void);
void initTIM16_freq(uint32_t freq);
void Delay(uint32_t ms); // off of TIM15

#endif