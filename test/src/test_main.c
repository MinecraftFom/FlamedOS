#include <stdio.h>
#include <test_main.h>

int main(void)
{
    run_tests();
}

void run_c_test(void)
{
    printf("Environment test 'C' finished");
}

void run_tests(void)
{
    run_c_test();
    run_s_test();
}