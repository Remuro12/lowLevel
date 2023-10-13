assume CS:code,DS:data

data segment
	array dw 5, 28, 36, 27, 31
    min dw ?;
data ends

code segment
start:
  mov AX, data
  mov DS, AX
calc:
	mov si, 4 
    mov bx, word ptr [si]	       
minLoop:
    cmp si, 0
	jge next
	jl finish
	next:
		mov cx, word ptr [si]
		cmp bx, cx
		jg less
		jle notLess
less:
	mov bx, cx
	dec si
	jmp minLoop
notLess:
	dec si
	jmp minLoop
finish:
	mov AX,4C00h
	int 21h
code ends
end start
