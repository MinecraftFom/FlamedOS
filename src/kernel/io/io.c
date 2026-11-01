#include <io.h>

int putc(void *io, char c)
{
    struct KernelAbstractIO *kaio = io;
    return kaio->putc(c);
}

int puts(void *io, char *s)
{
    struct KernelAbstractIO *kaio = io;
    return kaio->puts(s);
}