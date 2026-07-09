#define GPIO_OUT (*(volatile unsigned int *)0x10000000u)

int main(void)
{
    GPIO_OUT = 1;

    while (1) {
    }
}