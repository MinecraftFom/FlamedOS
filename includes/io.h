#pragma once

struct KernelAbstractIO;

struct KernelAbstractIO
{
    int (*putc)(char);
    int (*puts)(char *);
};

int putc(void *io, char c);
int puts(void *io, char *s);