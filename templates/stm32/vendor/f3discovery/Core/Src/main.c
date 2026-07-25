/**
 * Minimal bare-CMSIS skeleton for the STM32F3Discovery (STM32F303VCT6).
 *
 * No HAL/LL: peripherals are touched directly through the CMSIS struct
 * definitions in stm32f303xc.h. Blinks LD3 (orange, PE8).
 *
 * Board LED ring on GPIOE, compass-rose layout:
 *   PE8  LD3  orange   PE9  LD4  green
 *   PE10 LD5  orange   PE11 LD6  green
 *   PE12 LD7  orange   PE13 LD8  green
 *   PE14 LD9  orange   PE15 LD10 green
 */
#include "stm32f3xx.h"

static void delay(volatile uint32_t count)
{
  while (count--)
  {
    __NOP();
  }
}

int main(void)
{
  /* Enable GPIOE clock */
  RCC->AHBENR |= RCC_AHBENR_GPIOEEN;

  /* PE8 as general purpose output (MODER = 01) */
  GPIOE->MODER &= ~GPIO_MODER_MODER8;
  GPIOE->MODER |= GPIO_MODER_MODER8_0;

  for (;;)
  {
    GPIOE->ODR ^= GPIO_ODR_8;
    delay(500000);
  }
}
