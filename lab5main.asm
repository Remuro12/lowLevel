include macro.asm

assume cs:code, ds:data

data segment
s db 100, 101 dup('$')
digit db 100, 101 dup('$')
ans db 100, 101 dup('$')
data ends

code segment

start:
    mov ax, data
    mov ds, ax
	
    input s
    input digit
	
	solution s digit
	mov ax, dx
	mov cx, 5
	mov bx, 10	
	printLoop:
		mov dx, 0
		div bx
		mov si, cx
		add dl, '0'
		mov ans[si-1], dl
		loop printLoop
	mov dx, offset ans
	mov ah, 09h
	int 21h

exit:
    mov ax, 4c00h
    int 21h
code ends
end start
