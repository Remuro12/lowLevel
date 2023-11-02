assume cs:code, ds:data

data segment
source db 100, 101 dup (0)
dest db 100, 101 dup (0)
data ends

code segment
strcpy proc
    push bp
    mov bp, sp
	
    mov si, [bp+4] ; доступ к 1 аргументу адрес source
    inc si
    mov cl, [si] ; во 2 байте лежит длина(в 1 макс длина) сохраняем ее
    inc si  ; переводим указатель на 1 фактический символ строки
    mov di, [bp+6] ; доступ ко 2 аргументу
    add di, 2

copy:
    mov al, [si] ; по адресу si
    mov [di], al ; копируем
    
    inc si
    inc di
    
    dec cl
    jnz copy
	jz add_end_of_str
add_end_of_str:
    mov [di], byte ptr '$' ; фикс вывода
    pop bp
    ret
strcpy endp

start:
    mov ax, data  
    mov ds, ax
    
    mov dx, offset source
    mov ax, 0
    mov ah, 0Ah
    int 21h

    mov dl, 10
    mov ah, 02h
    int 21h
    
    mov dx, offset dest
    push dx
    mov dx, offset source
    push dx
    call strcpy

    mov dx, offset dest + 2 ; указатель в dx
    mov ah, 09h ; вывод из dx
    int 21h
    
    mov ah, 4ch
    int 21h
code ends
end start
