	.arch armv8-a
// res = a*(-b)*c/(e+d) - (d+b)/e
//DATA
	.data
	.align  3
res:
	.skip   8
c:
	.long 0x7ffffffe
e:
	.long 1
a:
	.short 0x7ffe
b:
	.short 0x7ffe
d:
	.short 0
//CODES
	.text
	.align 2
	.global _start
	.type _start, %function
_start:
//Loading to registers

//x1=c
	adr	x0, c
	ldrsw	x1, [x0]
//x2=e
	adr	x0, e
	ldrsw	x2, [x0]
//w3=a
	adr	x0, a
	ldrsh  	w3, [x0]
//w4=b
	adr	x0, b
	ldrsh	w4, [x0]
//w5=d
	adr	x0, d
	ldrsh	x5, [x0]

	cmp x2, #0
	bEQ	zero
//Calculation

//w6 = w3 * (-w4) = a * (-b)
	mneg 	w6, w3,w4
//x6 = x6 * x1 = a * (-b) * c
	mul 	x6, x6, x1
//x7 = x2 + x5 = e + d
	adds	x7, x2, x5
	bEQ	zero
//x6 = x6 / x7
	sdiv	x6, x6, x7
//w8 = w4 + w5 = d + b
	add	w8, w4, w5
//x8 = x8 / x2
	sdiv	x8, x8, x2
// x6 = x6-x8
	subs    x6, x6, x8
    bVS over
    adr x0, res
    str x6,[x0]
    mox x0,#0
	b exit


zero:
     mov x0, #1
     b exit


over:
     mov x0, #2
     b exit

exit:
	mov	x8, #93
	svc	#0
	.size	_start, .-_start
