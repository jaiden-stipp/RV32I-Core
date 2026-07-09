#define GPIO_OUT (*(volatile unsigned int *)0x10000000u)

static void delay(void)
{
    for (volatile unsigned int i = 0; i < 50000u; i++) {
    }
}

int main(void)
{
    unsigned int led = 1;

    while (1) {
        GPIO_OUT = led;
        delay();
        led ^= 1;
    }
}
