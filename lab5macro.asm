input macro s

	mov ax, 0
	mov ah, 0ah
	lea dx, s
	int 21h

    mov dl, 10 
    mov ah, 02h
    int 21h

endm


solution macro s, digit
    local count, success, end_macro
    mov si, offset s
    inc si
    mov ch, [si] ; размер
	inc ch
    inc si
    mov di, offset digit
    add di, 2
    mov bl, [di] ; код символа

    mov cl, 0
	mov dx, 0

    count:
		inc cl
		cmp cl, ch ; конец строки
		je end_macro
	    mov al, [si] 
        cmp al, bl
        je success

        
	    inc si
        jmp count

    success:
        inc dx
		inc si
		jmp count
    end_macro:
		
endm