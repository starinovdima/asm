        .arch armv8-a
        .data
        .align  3

mes1:
        .asciz  "Enter string\n"
        .equ    len1, . - mes1
mes2:
        .asciz "Input filename for write\n"
        .equ    len2, . - mes2
mes3:
        .asciz  "File exists. Rewrite(Y/N)?\n"
        .equ    len3, . - mes3
ans:
        .skip 3
str:
        .skip 10
filename:
        .skip 1024
        .align  3
fd:
        .skip   8

        .text
        .align 2
        .global _start
        .type   _start, %function
_start:
        ldr     x0, [sp]        //Check the number of parameters passed
        cmp     x0, #1
        beq     _0
        mov     x0, #0
        b       error
_0:                            //Request a file name
        mov     x0, #1
        adr     x1, mes2
        mov     x2, len2
        mov     x8, #64
        svc     #0
        mov     x0, #0
        adr     x1, filename
        mov     x2, #1024
        mov     x8, #63
        svc     #0
        cmp     x0, #1
        ble     _1
        cmp     x0, #1024
        blt     _2
_1:
        mov x0, #1
        b       error
_2:
        sub     x2, x0, #1
        mov     x0, #-100
        adr     x1, filename
        strb    wzr,[x1,x2]
        mov     x2, #0xc1
        mov     x3, #0600
        mov     x8, #56
        svc     #0
        cmp     x0, #0
        bge     main // if all okey
        cmp     x0, #-17
        bne     error
        mov     x0, #1              //Overwrite it?
        adr     x1, mes3
        mov     x2, len3
        mov     x8, #64
        svc     #0
        mov     x0, #0
        adr     x1, ans
        mov     x2, #3
        mov     x8, #63
        svc     #0
        cmp     x0, #2
        beq     answer
        mov     x0, #-17
        b       error
error:
        bl p_error              // output errors close file and go out
        adr     x0, fd
        ldr     x0, [x0]
        mov     x8, #57
        svc     #0
        mov     x0, #1
        b       end


answer:
        adr     x1, ans
        ldrb    w0, [x1]
        cmp     w0, 'y'
        beq     _6
        cmp     w0, 'Y'
        beq     _6
        mov     x0, #-17
        b       error

end:
        mov     x8, #93
        svc     #0
        .size   _start, (. - _start)

_6:
        mov     x0, #-100           // Overwrite file
        adr     x1, filename
        mov     x2, #0x201
        mov     x8, #56
        svc     #0
        cmp     x0,#0
        blt     error
main:
        adr     x1, fd
        str     x0, [x1]
        bl      work
        cbnz    x0, error       // check errors, close file and go out
        adr     x0, fd
        ldr     x0, [x0]
        mov     x8, #57
        svc     #0
        mov     x0, #0
        b       end

        .type   work, %function
        .data
vowels:
        .asciz  "AaEeIiOoUuYy"
        .equ    f1, 16
        .equ    tmp, 24
        .equ    counter, 32
        .equ    letter, 40
        .equ    word, 44
        .equ    input, 48
        .equ    buffer_size, 5

        .text
        .align  2

// x29 - frame pointer
// x30 - link register
// sp -  stack pointer
work:
        mov     x16, buffer_size    // forming a stack frame
        lsl     x16, x16, #1
        add     x16, x16, input
        sub     sp, sp, x16
        stp     x29, x30, [sp]
        mov     x29, sp
        str     x0, [x29, f1]
        str     xzr, [x29, counter]
        str     xzr, [x29, letter]
        b       show_mes
show_mes:
        mov     x0, #1
        adr     x1, mes1
        mov     x2, len1
        mov     x8, #64
        svc     #0
0:
        mov     x0, #0                //Reading the string
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
        ldrb    w2, [x3], #1    //Take the symbol
        cbz     w2, 2f
        cmp     w2, '\n'
        beq     2f
        cmp     w2, ' '
        beq     3f
        cmp     w2, '\t'
        beq     3f
        cbz     w1, 4f
        cmp     w6, #1          // if starts with vowel
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
        adr     x9, vowels
loop:
        ldrb    w10, [x9], #1     //postindex
        cbz     w10, 6f
        cmp     w2, w10
        beq     5f
        b       loop
5:
        mov     w6, #1          // w6 = 1 if starts with a vowel
6:
        cmp     w6, #1
        mov     w1, #1
        beq     1b              //if starts with vowel we pass
        add     x5, x5, #1
        cmp     x5, #1
        beq     7f              //if we didn't split the word
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
        ldr     x0, [x29, f1]
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
        ldp     x29, x30, [sp]      //back to our stack
        mov     x16, buffer_size
        lsl     x16, x16, #1
        add     x16, x16, input
        add     sp, sp, x16
        ret
        .size   work, .-work

        .type   p_error, %function
        .data

er_msg0:
        .asciz  "The programm doesn't require parameters\n"
        .equ    len_er0, .-er_msg0
er_msg1:
        .asciz  "Permisson denied\n"
        .equ    len_er1, .-er_msg1
er_msg2:
        .asciz  "Is a directory\n"
        .equ    len_er2, .-er_msg2
er_msg3:
        .asciz  "File name too long\n"
        .equ    len_er3, .-er_msg3
er_msg4:
        .asciz  "Unknown error\n"
        .equ    len_er4, .-er_msg4
        .text
        .align 2

p_error:
        cbnz    x0, 1f
        adr     x1, er_msg0
        mov     x2, len_er0
        b       5f
1:
        cmp     x0, #-36
        bne     2f
        adr     x1, er_msg1
        mov     x2, len_er1
        b       5f
2:
        cmp     x0, #-21
        bne     3f
        adr     x1, er_msg2
        mov     x2, len_er2
        b       5f
3:
        cmp     x0, #-36
        bne     4f
        adr     x1, er_msg3
        mov     x2, len_er3
        b       5f
4:
        adr     x1, er_msg4
        mov     x2, len_er4
5:
        mov     x0, #2
        mov     x8, #64
        svc     #0
        ret
        .size   p_error, .-p_error
