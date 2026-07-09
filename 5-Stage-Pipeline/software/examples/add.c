static volatile unsigned int *const TEST_STATUS =
    (volatile unsigned int *)0x0000F000;

int main(void)
{
    int a = 8;
    int b = 3;
    int result = a + b;

    *TEST_STATUS = (result == 11) ? 1u : 2u;

    while (1) {
    }
}
