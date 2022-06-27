
        .arch   armv8-a
        .data
message:

        .asciz   "Enter filename: "
        .equ     lgth, (. - message)

filename:

        .skip    1024
        .align   3

file_des:

        .skip    8
        .text
        .align  2
        .global _start
        .type   _start, %function

_start:
        ldr     x0, [sp]
        cmp     x0, #1
        beq     0f
        mov     x0, #0
        b       3f
0:
        mov     x0, #1
        adr     x1, message
        mov     x2, lgth
        mov     x8, #64
        svc     #0
        mov     x0, #0
        adr     x1, filename
        mov     x2, 1024
        mov     x8, #63
        svc     #0
        cmp     x0, #1
        ble     1f
        cmp     x0, #1024
        blt     2f
1:
        mov     x0, #1
        b       3f
2:
        sub     x2, x0, #1
        mov     x0, #-100
        adr     x1, filename
        strb    wzr, [x1, x2]
        mov     x2, #0
        mov     x8, #56
        svc     #0
        cmp     x0, #0
        blt     3f
        adr     x1,file_des
        str     x0, [x1]
        bl      main
        cbnz    x0, 4f
        adr     x0, file_des
        ldr     x0, [x0]
        mov     x8, #57
        svc     #0
        mov     x0, #0
        b       5f
3:
        bl      print_error
        mov     x0, #1
        b       5f
4:
        bl      print_error
        adr     x0, file_des
        ldr     x0, [x0]
        mov     x8, #57
        svc     #0
        mov     x0, #1
5:
        mov     x8, #93
        svc     #0
        .size   _start, (. - _start)

        .type   main, %function
        .data

string_with_vowels:

        .asciz  "AaEeIiOoUuYy"
        .equ    fd, 16
        .equ    tmp, 24
        .equ    counter, 32
        .equ    letter, 40
        .equ    word, 44
        .equ    input, 48
        .equ    buffer_size, 5
        .text
        .align  2

main:
        mov     x16, buffer_size
        lsl     x16, x16, #1
        add     x16, x16, input
        sub     sp, sp, x16
        stp     x29, x30, [sp]
        mov     x29, sp
        str     x0, [x29, fd]
        str     xzr, [x29, counter]
        str     xzr, [x29, letter]
0:
        ldr     x0, [x29, fd]
        add     x1, x29, input
        mov     x2, buffer_size
        mov     x8, #63
        svc     #0
        cmp     x0, #0
        ble     10f
        add     x0, x0, x29
        add     x0, x0, input
        ldr     w1, [x29, word]
        add     x3, x29, input
        mov     x16, buffer_size
        add     x16, x16, input
        add     x4, x29, x16
        ldr     x5, [x29, counter]
        ldr     w6, [x29, letter]
        mov     w7, ' '
1:
        cmp     x3, x0
        bge     8f
        ldrb    w2, [x3], #1
        cbz     w2, 2f
        cmp     w2, '\n'
        beq     2f
        cmp     w2, ' '
        beq     3f
        cmp     w2, '\t'
        beq     3f
        cbz     w1, 4f
        cmp     w6, #1
        beq     1b
        b       7f
2:
        mov     w1, #0
        mov     x5, #0
        b       7f
3:
        mov     w1, #0
        b       1b
4:
        mov     w6, #0
        adr     x9, string_with_vowels

loop:
        ldrb    w10, [x9], #1
        cbz     w10, 6f
        cmp     w2, w10
        beq     5f
        b       loop
5:
        mov     w6, #1
6:
        cmp     w6, #1
        mov     w1, #1
        beq     1b
        add     x5, x5, #1
        cmp     x5, #1
        beq     7f
        strb    w7, [x4], #1
7:
        strb    w2, [x4], #1
        b       1b
8:
        str     w1, [x29, word]
        str     x5, [x29, counter]
        str     w6, [x29, letter]
        mov     x16, buffer_size
        add     x16, x16, input
        add     x1, x29, x16
        sub     x2, x4, x1
        cbz     x2, 0b
        str     x2, [x29, tmp]
9:
        mov     x0, #1
        mov     x8, #64
        svc     #0
        cmp     x0, #0
        blt     10f
        ldr     x2, [x29, tmp]
        cmp     x0, x2
        beq     0b
        mov     x16, buffer_size
        add     x16, x16, input
        add     x1, x29, x16
        add     x1, x1, x0
        sub     x2, x2, x0
        str     x2, [x29, tmp]
        b       9b
10:
        ldp     x29, x30, [sp]
        mov     x16, buffer_size
        lsl     x16, x16, #1
        add     x16, x16, input
        add     sp, sp, x16
        ret
        .size   main, (. - main)
        .type   print_error, %function

        .data

msg1:
        .asciz  "The programm doesn't require parameters.\n"
        .equ    lgth1, (. - msg1)
msg2:
        .asciz "Error reading filename.\n"
        .equ    lgth2, (. - msg2)
msg3:
        .asciz  "No such file or directory.\n"
        .equ    lgth3, (. - msg3)
msg4:
        .asciz  "Permission denied.\n"
        .equ    lgth4, (. - msg4)
msg5:
        .asciz  "This is the directory.\n"
        .equ    lgth5, (. - msg5)
msg6:
        .asciz  "The filename is very long.\n"
        .equ    lgth6, (. - msg6)
msg7:
        .asciz  "Unknown error.\n"
        .equ    lgth7, (. - msg7)
        .text
        .align 2

print_error:
        cbnz    x0, 0f
        adr     x1, msg1
        mov     x2, lgth1
        b       6f
0:
        cmp     x0, #1
        bne     1f
        adr     x1, msg2
        mov     x2, lgth2
        b       6f
1:
        cmp     x0, #-2
        bne     2f
        adr     x1, msg3
        mov     x2, lgth3
        b       6f
2:
        cmp     x0, #-13
        bne     3f
        adr     x1, msg4
        mov     x2, lgth4
        b       6f
3:
        cmp     x0, #-21
        bne     4f
        adr     x1, msg5
        mov     x2, lgth5
        b       6f
4:
        cmp     x0, #-36
        bne     5f
        adr     x1, msg6
        mov     x2, lgth6
        b       6f
5:
        adr     x1, msg7
        mov     x2, lgth7
6:
        mov     x0, #2
        mov     x8, #64
        svc     #0
        ret
        .size   print_error, (. - print_error)

