// STM32L432KC_SPI.c
// Roman De Santos
// rdesantos@hmc.edu
// 10/21/25
// Provides an initialization and data transfer function for SPI

#include "STM32L432KC_SPI.h"

void initSPI(int br, int cpol, int cpha){

    // Enable clock to SPI1
    RCC->APB2ENR |= RCC_APB2ENR_SPI1EN;

    // Following instructions from the reference manual 40.4.7

    // change baud rate
    SPI1->CR1 |= _VAL2FLD(SPI_CR1_BR, 0b111);

    // set CPOL and CPHA
    SPI1->CR1 |= _VAL2FLD(SPI_CR1_CPHA, cpha);
    SPI1->CR1 |= _VAL2FLD(SPI_CR1_CPOL, cpol);

    // Hardware Managed Chip Select
    SPI1->CR1 |= _VAL2FLD(SPI_CR1_SSM, 0b1);
    SPI1->CR1 |= _VAL2FLD(SPI_CR1_SSI, 0b1);

    // set MCU as master
    SPI1->CR1 |= _VAL2FLD(SPI_CR1_MSTR, 0b1);

    // Select Data Length (8-bit registers on D1722 temp sensor)
    SPI1->CR2 |= _VAL2FLD(SPI_CR2_DS, 0b0111); // 8 bit transfers

    // Flag enables when FIFO buffer has 8 bits
    SPI1->CR2 |= _VAL2FLD(SPI_CR2_FRXTH, 0b1);

    // Enable SPI Peripheral
    SPI1->CR1 |= _VAL2FLD(SPI_CR1_SPE, 0b1);

}

char spiSendReceive(char send){

    // Wait until ready to send (empty send buffer)
    while(!(SPI1->SR & SPI_SR_TXE));

    SPI1->DR = send;

    // Wait until redy to recieve (Non Empty recieve buffer)
    while(!(SPI1->SR & SPI_SR_RXNE));

    return SPI1->DR
}