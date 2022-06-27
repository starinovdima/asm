        .arch armv8-a
// Matrix n*n, sort each diagonal of the square matrix parallel to the main one.
// Heap sort.
        .data
        .align 3
n:
        .byte 5
matrix:
        .word  5, 1, 8, 2, 3
        .word  2, 3, 4, 5, 3
        .word  3, 8, 7, 6, 3
        .word  4, 3, 5, 1, 3
        .word  3, 3, 3, 3, 3

        .text
        .align 2
        .global _start
        .type   _start, %function

_start:
// w1 number of columns
        adr x0, n
        ldrb w1, [x0]
// x2 - adress of matrix
        adr x2, matrix
// w3 = n+1 step for next element
        mov w3, w1
        add w3, w3, #1

prepare_higher:
// w4 starting element
        mov w4, #0
// w5 current number of elements
        mov w5, w1

higher_part:
// while w5 > 1
        cmp w5,#1
        bLS prepare_lower // w5 <= 1
        b prepare_sorted
        next_up:
        // go to next diag
        add w4, w4, #1
        sub w5, w5, #1
        b higher_part

        prepare_lower:
        mov w5, w1
        mov w4, w1
        sub w5, w5, #1

        lower_part:
        // while w5 > 1
        cmp w5, #1
        bLS exit // w5 <= 1
        b prepare_sorted

        next_low:
        add w4, w4, w1
        sub w5, w5, #1
        b lower_part

check:
        cmp w4, w1  //check matrix part
        bLO next_up
        b next_low

prepare_sorted:

        mov x6, x2
        add x6, x6, x4, lsl #2
        lsr w7, w5, #1
        sub w8, w5, #1

//w1 - n
//w2 - adr starting matrix
//w3 - n+1
//w4 - start index
//w5 - number of elements in massive
//w6 - adr start of massive
//w7 - check index from centre masssive
//w8 - index of last element
L0:

        cbz w7, L1
        sub w7, w7, #1
        b L2

L1:
        cbz w8, check
        mul w20, w8, w3
        mul w21, w7, w3
        ldrsw x10, [x6, x20, lsl #2]
        ldrsw x11, [x6, x21, lsl #2]
        str w10, [x6, x21, lsl #2]
        str w11, [x6, x20, lsl #2]
        sub w8, w8, #1
        cbz w8, check

L2:
        mul w20, w7, w3
        ldrsw x10, [x6, x20, lsl #2]
        mov w12, w7

L3:
        mov w13, w12
        lsl w12, w12, #1
        add w12, w12, #1
        cmp w12, w8
        bgt L5
        mul w20, w12, w3
        ldrsw x11, [x6, x20, lsl #2]
        beq L4
        add w14, w12, #1
        mul w20, w14, w3
        ldrsw x15, [x6, x20, lsl #2]
        cmp w11, w15
        .ifdef rev
        bge L4
        .else
        ble L4
        .endif
        add w12, w12, #1
        mov w11, w15

L4:
        cmp w10, w11
        .ifdef rev
        bge L5
        .else
        ble L5
        .endif
        mul w20, w13, w3
        str w11, [x6,x20, lsl #2]
        b L3

L5:
        mul w20, w13, w3
        str w10, [x6, x20, lsl #2]
        b L0



exit:
        mov x0, #0
        mov x8, #93
        svc #0
        .size   _start, .-_start
