assume CS:code,DS:data
 
data segment
string1 db 97, 99 dup ('$'); max - actual - 97*data - $
string2 db 97, 99 dup ('$')
string3 db 97, 99 dup ('$')
wrongSymbolException db "Not a digit or minus in input", 13, 10, '$'
incorrectOrderStr db "Incorrect order", 13, 10, '$'
minusDigit db "-$"
result db 0, 99 dup ('$') 
newline db 13, 10, '$'
data ends

SSEG segment stack
db 400h dup (?)
SSEG ends
 
code segment
println proc
  mov dx, offset newline
  mov ah, 09h
  int 21h
  ret
println endp

Str2Int proc ; char* arr
  push bp 
  mov bp, sp
  
  xor si, si
  mov si, [bp+4] ; первый аргумент
  xor cx, cx
  mov cl, [si+1] 
  add si, 2 ; первый нужный символ строки
  ;цикл по cx
  arrLoop:
    cmp byte ptr [si], '0' 
		jae MoreZero
		cmp byte ptr [si], '-'
			jne illegalChar
			inc si
			loop arrLoop
	MoreZero:
	cmp byte ptr [si], '9'
		ja illegalChar 
		sub byte ptr [si], '0'
		inc si
		loop arrLoop
	
  mov sp, bp 
  pop bp 
  ret 2
  illegalChar: ;если некорректный символ
  mov dx, offset wrongSymbolException
  mov ah, 09h
  int 21h
  mov ah, 4Ch
  int 21h
Str2Int endp

sum proc
  push bp ;
  mov bp, sp;
  mov si, 0
  mov di, 0
  sub sp, 2
  mov si, [bp+4] ; первый
  mov di, [bp+6] ; второй
  ;фактическая длина в 1, макс в 2
  mov al, [si+1]
  mov [bp-1], al ;len1
  mov ah, [di+1]
  mov [bp-2], ah ;len2
  
  mov cx, 0
  mov cl, al ;
  mov di, offset result
  cmp al, ah
	jae firstLenBigger
	mov cl, ah 
    mov si, [bp+6]
	firstLenBigger:
    mov dx, 0
	mov dl, cl
    add si, 1 
	add si, cx
	add di, cx
	  copyLoop:
	  mov bl, [si]
	  mov [di], bl
	  dec si
	  dec di
	  loop copyLoop
  
  mov si, [bp+4] 
  mov di, [bp+6] 
  
  mov al, [si+1]
  mov [bp-1], al 
  mov ah, [di+1]
  mov [bp-2], ah 
  
  mov dx, 0
  mov si, [bp+6] 
  mov dl, al
  cmp al, ah
	jae Len1
    mov si, [bp+4]
	mov dl, ah
	mov ah, al
	Len1:
	; dh для остатка
    mov di, offset result
	mov cx, 0
	mov cl, ah 
	add si, 1
	add si, cx
	add di, dx
	mov bl, 10
	mov dx, 0
	  addLoop:
	  mov ax, 0
	  mov al, [si]
	  add al, dh
	  add al, [di]
	  div bl ; делим на 10
	  mov dh, al 
	  mov [di], ah
	  dec di
	  dec si
	  loop addLoop
    add [di], dh

  mov sp, bp 
  pop bp 
  ret 4
sum endp

diff proc
  push bp 
  mov bp, sp
  sub sp, 2
  mov si, [bp+4] 
  mov di, [bp+6] 
  
  mov al, [si+1]
  mov [bp-1], al 
  mov ah, [di+1]
  mov [bp-2], ah 
  
  xor cx, cx
  mov cl, al
  mov di, offset result
  add si, 2
  copyLoop1:
    mov bl, [si]
	mov [di], bl
	inc si
	inc di
  loop copyLoop1
  mov si, [bp+6]
  xor bx, bx
  mov bl, byte ptr [bp-2]
  add si, bx
  inc si
  dec di
  xor cx, cx
  mov cl, [bp-2]
  xor dx, dx
  subLoop:
	  xor ax, ax
	  mov al, [si]
	  mov ah, [di]
	  cmp dl, 0
	  je continueSub
	  cmp ah, 0
		jne reduceAh
	    mov dl, 1
		add ah, 10
		reduceAh:
			sub ah, 1
	  continueSub:
	  cmp ah, al
		jae noCarry
	    mov dl, 1
		add ah, 10
		noCarry:
		sub ah, al
		mov [di], ah
		dec di
		dec si
	loop subLoop
  sub [di], dl
  mov sp, bp 
  pop bp 
  ret 4
diff endp

Int2Str proc ; char* arr
  push bp 
  mov bp, sp
  
  xor si, si
  mov si, [bp+4] ;первый аргумент
  
  Int2StrLoop:
  cmp [si], byte ptr '$'
  je Int2StrEnd
  add [si], byte ptr '0'
  inc si
  jmp Int2StrLoop

  Int2StrEnd:
  mov sp, bp 
  pop bp 
  ret 2
Int2Str endp

solve proc
 mov ah, 0Ah
 mov dx, offset string1 ; считываем первую строку
 int 21h
 call println
 push offset string1 ; кладем на стэк
 call Str2Int

 mov ah, 0Ah
 mov dx, offset string2 ; считываем вторую строку
 int 21h
 call println
 push offset string2 ; кладем на стэк
 call Str2Int

 mov si, offset string1
 mov di, offset string2
 add si, 2
 add di, 2
 ; указатели на начало строки
 cmp [si], byte ptr '-'
 ;управляю операцией
	je minus
	cmp [di], byte ptr '-'
		je plusMinus
		push offset string2
		push offset string1
		call sum
		jmp printRes
		plusMinus:
		;+-
		mov [di], byte ptr 0
		push offset string2
		push offset string1
		call diff
		jmp printRes
	minus:
    cmp [di], byte ptr '-'
		je minusMinus
		;-+
		mov dx, offset incorrectOrderStr
		mov ah, 09h
		int 21h
		mov ah, 4Ch
		int 21h
		minusMinus:
		mov [di], byte ptr 0
		mov [si], byte ptr 0
		push offset string2
		push offset string1
		call sum
		mov ah, 09h
		mov dx, offset minusDigit
		int 21h
		jmp printRes
  printRes:
  push offset result
  call Int2Str
  mov ah, 09h
  mov dx, offset result
  int 21h
  ret
solve endp

start:
mov AX, data
mov DS, AX

call solve

mov ah, 4Ch
int 21h
code ends
end start