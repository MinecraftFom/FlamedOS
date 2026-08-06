// Notice: the prefix 'fd_' represents 'Flamed_Kernel.DisplayModule'

#define VGA_PG_WIDTH 80
#define VGA_PG_HEIGHT 25
#define VGA_PG_MAX VGA_PG_WIDTH * VGA_PG_HEIGHT
#define VGA_MAX VGA_PG_MAX * 32 // 32 pages of display allocated

#define VGA_D_LOC(canvas, x, y) canvas->characters[y * VGA_PG_WIDTH + x]
#define VGA_LOC(canvas) canvas->characters[canvas->yptr * VGA_PG_WIDTH + canvas->xptr]

struct fd_vga_canvas // 80 x 25 char size
{
    char characters[VGA_MAX];
    int yptr;
    int xptr;
};

static struct fd_vga_canvas *default_display;

// Global init function
void init(struct fd_vga_canvas *canvas)
{
    for (int i = 0; i < VGA_MAX; i++)
        canvas->characters[i] = ' ';
}

// Global display function
void display(int x, int y, int ay, struct fd_vga_canvas *canvas)
{
    *((int*)0xB8000 + y * VGA_PG_WIDTH + x) = VGA_D_LOC(canvas, x, ay);
}

// Global refresh function
void refresh(struct fd_vga_canvas *canvas) // Current line of the 'stack pointer', which refers to the top of the display
{
    for (int y = 0; y < VGA_PG_HEIGHT; y++)
    {
        for (int x = 0; x < VGA_PG_WIDTH; x++)
        {
            display(x, y, y + canvas->yptr, canvas);
        }
    }
}

// Global putc function
void putc(char c, struct fd_vga_canvas *canvas)
{
    switch (c)
    {
        case '\n':
            canvas->xptr = 0;
            canvas->yptr++;
        case '\b':
            canvas->xptr--;
            VGA_LOC(canvas) = ' ';
        default:
            if (canvas->xptr >= VGA_PG_WIDTH)
            {
                canvas->xptr = 0;
                canvas->yptr++;
            }
            VGA_LOC(canvas) = c;
    }

    refresh(canvas);
}

// Kernel-specified
void kinit()
{
    init(default_display);
}

// Kernel-specified
void kputc(char c)
{
    putc(c, default_display);
}

// Kernel-specified
void kputs(char* c)
{
    while (*c != '\0')
        kputc(*c++);
}