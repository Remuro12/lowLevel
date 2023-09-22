assume CS:code,DS:data

data segment
    num dw 123
	res db "000000$"
    msg db "Number as string: $"
data ends

code segment
start:
  mov AX, data
  mov DS, AX
calc:
    mov ax, num  	
    mov cx, 16       
    mov si, 2    
convertLoop:
    xor dx, dx        
    div cx   
	cmp dl, 9
	jz isDigit         
    jg isNotDigit       
    jl isDigit
	cont:
		mov res[si], dl
		dec si
    jnz convertLoop    
	;convertloop сравнивает ax с 0
	
output:
    mov AH, 09h
	mov DX, offset res
	int 21h
	
	mov AX,4C00h
	int 21h
isDigit:
	add dl, '0'
	jmp cont
isNotDigit:
	sub dl, 10
	add dl, 'A'
	jmp cont
code ends
end start
