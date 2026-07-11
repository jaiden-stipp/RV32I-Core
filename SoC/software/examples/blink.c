#define GPIO_OUT (*(volatile unsigned int *)0x10000000u)

static void delay(unsigned int led)
{
    for (unsigned int i = 0; i < 5u; i++) {
        GPIO_OUT = led;
    }
}

int main(void)
{
    unsigned int led = 1;

    while (1) {
        GPIO_OUT = led;
        delay(led);
        led ^= 1;
    }
}
