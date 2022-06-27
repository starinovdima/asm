    .arch   armv8-a
    .data
usage:
    .string "Usage: %s file\n"
mes:
    .string "Determinant = %f, error\n"
mes2:
    .string "Det = %f"
format:
    .string "Incorrect format or file\n"
size:
    .string "Dimension of matrix must be less or equal 20\n"
formint:
    .string "%d"
formdouble:
    .string "%lf"
formdouble1:
    .string "%lf "
next:
    .string "\n"
mode:
    .string "r"
    .global main
    .type   main, %function
    .equ    progname, 32
    .equ    filename, 40
    .equ    filestruct, 48
    .equ    n, 56
    .equ    determinant, 64
    .equ    matrix, 72
    .text
    .align 2

main:
    sub sp, sp, #3272
    stp x29, x30, [sp]
    stp x27, x28, [sp, #16]
    bl tar
    cmp w0, #1
    beq exit
    ldr x0, [x1]
    str x0, [x29, progname]
    ldr x0, [x1, #8]
    str x0, [x29, filename]
    adr x1, mode
    bl fopen
    cbnz    x0, 1f
    ldr x0, [x29, filename]
    bl  perror
    mov w0, #1
    b   exit
1:
    str x0, [x29, filestruct]
    adr x1, formint
    add x2, x29, n
    bl fscanf
    cmp w0, #1
    beq 2f
    ldr x0,[x29, filestruct]
    bl fclose
    adr x0, stderr
    ldr x0, [x0]
    adr x1, format
    bl fprintf
    mov w0, #1
    b exit
2:
    mov x27, #0
    ldr w28, [x29, n]
    cmp x28, #0
    ble err_size
    cmp x28, #20
    bgt err_size
    mul x28, x28, x28
    b 3f
3:
    ldr x0, [x29, filestruct]
    adr x1, formdouble
    lsl x2, x27, #3
    add x2, x2, x29
    add x2, x2, matrix
    bl fscanf
    ldr x15,[x29,n]
    cmp x15, #1
    beq ravno
    cmp w0, #1
    beq 4f
    ldr x0, [x29, filestruct]
    bl fclose
    adr x0, stderr
    ldr x0, [x0]
    adr x1, format
    bl  fprintf
    mov w0, #1
    b exit
4:
    add x27, x27, #1
    cmp x27, x28
    bne 3b
    ldr x0, [x29, filestruct]
    bl  fclose
5:
    mov x10, #0
    add x10, x29, matrix
    ldr x11, [x29,n]
    bl  deter
    fcmp d0, #0.000
    bne 6f
    adr x0, mes
    bl printf
    mov w0, #1
    b exit

6:
    str d0,[x29,determinant]
    bl transp
7:
    ldr d0,[x29,determinant]
    bl work
    b exit

ravno:
    fmov d1,#1.0
    ldr d0,[x29,matrix]
    fdiv d0, d1, d0
    adr x0, formdouble
    bl printf
    adr x0, next
    bl printf
    b exit

err_size:
    ldr x0, [x29, filestruct]
    bl  fclose
    adr x0, stderr
    ldr x0, [x0]
    adr x1, size
    bl  printf
    mov w0, #1
    b exit


exit:
    ldp x29, x30, [sp]
    ldp x27, x28, [sp, #16]
    add sp, sp, #3272
    ret
    .size   main, .-main

/////////////////////////////////////////////
    .type   tar, %function
    .text
    .align  2
tar:
    cmp x0,#2
    beq 1f
    ldr x2, [x1]
    adr x0, stderr
    ldr x0, [x0]
    adr x1, usage
    bl fprintf
    mov w0, #1
1:
    ret
    .size   tar, .-tar
/////////////////////////////////////////////
    // x10 - adr matrix
    // x11 - n

    .data
    .type   deter, %function
    .equ    per, 32
    .text
    .align 2

deter:
    sub sp,sp, #432
    stp x29, x30,[sp]
    stp x27, x28, [sp, #16]
    mov x29, sp
1:
    add x0, x29, per
    mov x1, #0
    mov x28, x11
2:
    str x1, [x0, x1, lsl#3]
    add x1, x1, #1
    cmp x1, x28
    blt 2b
    mov x8, #0
    mov x9, x10
    fmov    d0, xzr
    fmov    d2, #1.0
    fmov    d3, #-1.0
3:
    tst x8, #1
    fcsel   d1,d2,d3, eq
    mov x1, #0
4:
    lsl x2, x1, #3
    mul x2, x2, x28
    add x2, x2, x9
    ldr x3, [x0, x1, lsl #3]
    ldr d4, [x2, x3, lsl #3]
    fmul    d1, d1, d4
    add     x1, x1, #1
    cmp     x1, x28
    blt     4b
    fadd    d0, d0, d1
    mov x1, #0
    mov x2, #-1
    ldr x5, [x0,x1,lsl #3]
5:
    mov x4, x5
    add x1, x1, #1
    cmp x1, x28
    beq 1f
    ldr x5, [x0, x1, lsl #3]
    cmp x4, x5
    blt 0f
    cmp x5, x6
    blt 5b
    mov x3, x1
    mov x7, x5
    b   5b
0:
    sub x2, x1, #1
    mov x3, x1
    mov x6, x4
    mov x7, x5
    b 5b
1:
    cmp x2, #-1
    beq 3f
    str x7, [x0,x2, lsl #3]
    str x6, [x0,x3, lsl #3]
    add x8, x8, #1
    mov x1, x2
    mov x2, x28
2:
    add x1, x1, #1
    sub x2, x2, #1
    cmp x1, x2
    bge 3b
    ldr x4, [x0, x1, lsl #3]
    ldr x5, [x0, x2, lsl #3]
    str x5, [x0, x1, lsl #3]
    str x4, [x0, x2, lsl #3]
    add x8, x8, #1
    b 2b
3:
    ldp x29, x30, [sp]
    ldp x27, x28, [sp, #16]
    add sp, sp, #432
    ret
    .size   deter, .-deter
//////////////////////////////////////////

    .type   transp, %function
    .text
    .align 2
transp:
    sub sp, sp, #16
    stp x29, x30, [sp]
    mov x29, sp
1:
    // x10 - matrix
    // x11 - n
    // x5 - i
    // x6 - j
    // x7 - count
    mov x5, #0
    mov x6, #0
    mov x7, #1
    mov x8, #1
    mov x9, x11
2:
    cmp x5, x6
    beq 3f
    ldr d1,[x10,x5,lsl#3]
    ldr d2,[x10,x6,lsl#3]
    str d1,[x10,x6,lsl#3]
    str d2,[x10,x5,lsl#3]
3:
    cmp x9,#1
    beq 5f
    add x8, x8, #1
    add x5, x5, #1
    add x6, x6, x11
    cmp x8, x9
    bgt 4f
    b 2b
4:
   add x5, x5, x7
   mov x6, #0
   mul x6, x7, x11
   add x6, x6, x7
   sub x9, x9, #1
   mov x8, #1
   add x7, x7, #1
   b 2b

5:
    ldp x29, x30, [sp]
    add sp, sp, #16
    ret
    .size   transp, .-transp
//////////////////////////////
    .type   work, %function
    .data
    .equ    sz, 16
    .equ    row, 24
    .equ    column, 32
    .equ    adr, 40
    .equ    sign, 48 // 0 - chetnoe, 1 - nechetnoe
    .equ    count,56
    .equ    determ,64
    .equ    matr, 72
    .text
    .align 2
work:
    sub sp, sp, #2960
    stp x29, x30, [sp]
    mov x29, sp
    mov x1, #1
    str x1, [x29,row]
    str x1, [x29,column]
    mov x1, #0
    str x1, [x29, count]
    str x10, [x29, adr]
    str x11, [x29, sz]
    str d0,[x29,determ]

1:
    ldr x11,[x29,sz]
    ldr x10,[x29,adr]
    ldr x1, [x29,row]
    ldr x2, [x29,column]
    add x0, x1, x2
    tbz x0, #0, 2f
    mov x0, #-1
    str x0,[x29,sign]
    b 3f
2:
    mov x0,#1
    str x0,[x29,sign]
3:
    //x2 idet vsled str
    //x3 start str
    //x4 end str
    add x15,x29,matr
    mul x4,x1,x11
    sub x3,x4,x11
    mul x17, x11, x11
    sub x2,x2, #1
    mov x5, #0 // check all ele
    mov x6, #0  //count
    mov x7, #1  // count str

4:
    cmp x5, x17
    beq 9f
    cmp x5, x3
    bge 5f
    b 6f

5:
    cmp x5, x4
    blt 7f
6:
    cmp x5,x2
    beq 7f
    ldr d0,[x10,x5,lsl#3]
    str d0,[x15,x6,lsl#3]
    add x6, x6, #1
7:
    add x5,x5,#1
    mul x13, x7, x11
    cmp x13, x5
    beq 8f
    b 4b
8:
    add x7, x7, #1
    add x2, x2, x11
    b 4b
9:
    mov x10, x15
    sub x11, x11, #1
    bl deter
    ldr x1,[x29,count]
    ldr x2,[x29,adr]
    ldr x3,[x29,sz]
    ldr x4,[x29,sign]
    ldr d1,[x29,determ]
    fdiv d0,d0,d1
    mov x5, #1
    cmp x4, x5
    beq 10f
    fneg d0,d0
10:
    //str d0,[x2,x1,lsl#3]
    //adr x0, formdouble
    //bl printf
    add x1, x1, #1
    mul x7, x3, x3
    cmp x1, x7
    beq end
    str x1,[x29,count]
11:
    ldr x5,[x29,row]
    ldr x6,[x29,column]
    add x6, x6, #1
    cmp x6, x3
    bgt 12f
    str x6,[x29,column]
    adr x0, formdouble1
    bl printf
    b 1b
12:

    mov x6, #1
    add x5,x5,#1
    str x5,[x29,row]
    str x6,[x29,column]
    adr x0, formdouble
    bl printf
    adr x0, next
    bl printf
    b 1b


end:
    adr x0,formdouble1
    bl printf
    adr x0, next
    bl printf
    ldp x29, x30, [sp]
    add sp, sp, #2960
    ret
    .size   work, .-work
