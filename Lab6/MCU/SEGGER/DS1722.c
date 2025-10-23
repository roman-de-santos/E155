// DS1722.c
// Roman De Santos
// rdesantos@hmc.edu
// 10/21/25
// Set up file for the DS1722 temp sensor

#include "DS1722.h"

// Helper function to set the resolution of the thermometer and record the outputs in the MSB and LSB register
void CR_WriteResOnly(int res, int CE) {
    // Calculate the 3-bit resolution value (0-4)
    int normRes = res - 8;
    
    // Shift the bits into position (bits 4, 3, 2)
    int shifted_res = res << 1;

    // Combine with the base byte.
    // This sets Bit {1,1,1,0,res[2:0],0}
    uint8_t data_byte = 0xE0 | shifted_res;
    
    // Send the 16-bit command
    digitalWrite(CE, 1);       // CE Active-HIGH
    spiSendReceive(DS1722_CR);     // First byte: Send Write-Address (0x80)
    spiSendReceive(data_byte);     // Second byte: Send the data byte
    digitalWrite(CE, 0);       // CE Inactive-LOW
}

// Converts the twos compliment float MSB and LSB to a decimal float 
float convertB2D(uint8_t msb, uint8_t lsb){
    float temp = 0;

    // Number is in twos complement so check sign bit
    if ((msb >> 7) == 1){
        temp += -128;
    }

    // bits representing 2^0 to 2^6 in MSB are always sent 
    temp += (msb & (~(0x80)));

    // Conditionally add fractional LSB bits (changes based on resolution)
    if (lsb & 0x10){
        temp +=  0.0625;
    }
    if (lsb & 0x20){
        temp +=  0.125;
    }
    if (lsb & 0x40){
        temp +=  0.250;
    }
    if (lsb & 0x80){
        temp +=  0.500;
    }

    return temp;
}

// Accepts an input string from the website and outputs the temperature from the thermometer
float sendResGetTemp(char request[], int CE) {
    uint8_t lsbTemp = 0;
    uint8_t msbTemp = 0;

    if (inString(request, "8bit")==1) {
        CR_WriteResOnly(8, SPI_CE);
    }
    else if (inString(request, "9bit")==1) {
        CR_WriteResOnly(9, SPI_CE);
    }
    else if (inString(request, "10bit")==1) {
        CR_WriteResOnly(10, SPI_CE);
    }
    else if (inString(request, "11bit")==1) {
        CR_WriteResOnly(11, SPI_CE);
    }
    else if (inString(request, "12bit")==1) {
        CR_WriteResOnly(12, SPI_CE);
    }

    // Read LSB and MSB registers after proper resolution has been set
    digitalWrite(CE, 1);
    spiSendReceive(DS1722_LSB);
    lsbTemp = spiSendReceive(0x00);
    digitalWrite(CE, 0);

    digitalWrite(SPI_CE, 1);
    spiSendReceive(0x00);
    msbTemp = spiSendReceive(0x00);
    digitalWrite(CE, 0);

    // Convert binary float to a decimal float
    return convertB2D(msbTemp, lsbTemp);
}

