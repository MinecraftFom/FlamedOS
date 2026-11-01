#include <io.h>

struct KernelAbstractIO *vga_io;

int vga_putc(char c);
int vga_puts(char *s);

void init_vga(void)
{
    struct KernelAbstractIO kvio = {
        .putc = vga_putc,
        .puts = vga_puts
    };

    vga_io = &kvio;
}

int vga_putc(char c)
{

}

int vga_puts(char *s)
{
    while (*s != '\0')
    {
        vga_putc(*s);
        (*s)++;
    }

    return 0;
}