#include "platform.h"

/* Variant 28: a=1, d and n are unsigned bytes. */
static unsigned value, difference, entering_n, release_code;
static unsigned digits;

static void text(unsigned pos, const char *s)
{
    while (*s) vga.char_map[pos++] = (uint8_t)*s++;
}

/* Decimal conversion without division or a standard I/O library. */
static void number(unsigned pos, int value_to_print)
{
    unsigned value_abs;
    if (value_to_print < 0) {
        vga.char_map[pos++] = '-';
        value_abs = (unsigned)-value_to_print;
    } else value_abs = (unsigned)value_to_print;
    unsigned divisor = 10000;
    unsigned started = 0;
    while (divisor) {
        unsigned digit = 0;
        while (value_abs >= divisor) { value_abs -= divisor; ++digit; }
        if (digit || started || divisor == 1) {
            vga.char_map[pos++] = (uint8_t)('0' + digit);
            started = 1;
        }
        /* Fixed divisors avoid a software division routine on RV32I. */
        if (divisor == 10000) divisor = 1000;
        else if (divisor == 1000) divisor = 100;
        else if (divisor == 100) divisor = 10;
        else if (divisor == 10) divisor = 1;
        else divisor = 0;
    }
}

int main(void)
{
    for (unsigned i = 0; i < 2400; ++i) {
        vga.char_map[i] = ' ';
        vga.color_map[i] = 0xF0;
    }
    text(0, "a=1; type d, Enter, n, Enter (0..255)");
    text(80, "d= ");
    text(160, "n= ");
    return 0;
}

void int_handler(void)
{
    unsigned code = ps2_ptr->scan_code;
    if (release_code) { release_code = 0; return; }
    if (code == 0xF0 || code == 0xE0) { release_code = 1; return; }
    if (code == 0x5A) {
        if (!digits) return;
        if (!entering_n) {
            difference = value;
            entering_n = 1;
        } else {
            int result = 1;
            if (value == 0) result -= (int)difference;
            else for (unsigned i = 1; i < value; ++i) result += (int)difference;
            text(240, "result=             ");
            number(248, result);
            entering_n = 0;
        }
        value = digits = 0;
        return;
    }
    unsigned digit;
    switch (code) {
        case 0x45: digit = 0; break;
        case 0x16: digit = 1; break;
        case 0x1E: digit = 2; break;
        case 0x26: digit = 3; break;
        case 0x25: digit = 4; break;
        case 0x2E: digit = 5; break;
        case 0x36: digit = 6; break;
        case 0x3D: digit = 7; break;
        case 0x3E: digit = 8; break;
        case 0x46: digit = 9; break;
        default: return;
    }
    unsigned next = (value << 3) + (value << 1) + digit;
    if (digits == 3 || next > 255) return;
    unsigned pos = entering_n ? 163 : 83;
    if (!digits) text(pos, "   ");
    value = next;
    vga.char_map[pos + digits++] = (uint8_t)('0' + digit);
}
