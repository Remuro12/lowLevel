assume CS:code,DS:data
 
data segment
maxRadix db 15
string1 db 97, 99 dup ('$'); max - actual - 97*data - $
string2 db 97, 99 dup ('$')
wrongSymbolException db "Not a digit or minus in input", 13, 10, '$'
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

Str2Int proc
  push bp 
  mov bp, sp
  
  xor si, si
  mov si, [bp+4] 
  xor cx, cx
  mov cl, [si+1] 
  add si, 2 
  arrLoop:
    cmp byte ptr [si], '0'
	jae aboveCheck
	  cmp byte ptr [si], '-'
	  jne illegalChar
	    inc si
	    jmp endOfStr2IntLoop
	aboveCheck:
	cmp byte ptr [si], '9'
	ja aboveCheck1 
      sub byte ptr [si], '0'
	  inc si
	  jmp endOfStr2IntLoop
	aboveCheck1:
	cmp byte ptr [si], 'A'
	jb illegalChar
	cmp byte ptr [si], 'F'
	ja illegalChar
	  sub byte ptr [si], 'A'
	  add byte ptr [si], 10
	  inc si
	endOfStr2IntLoop:
	loop arrLoop
	
  mov sp, bp 
  pop bp 
  ret 2
  illegalChar: 
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
	mov bx, 16
	mov dx, 0
	  addLoop:
	  mov ax, 0
	  mov al, [si]
	  add al, dh
	  add al, [di]
	  div bl ; делим на 16
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

Int2Str proc
  push bp 
  mov bp, sp
  
  xor si, si
  mov si, [bp+4] 
  
  Int2StrLoop:
  cmp [si], byte ptr '$'
  je Int2StrEnd
  cmp byte ptr [si], 10
  jae letter
    add [si], byte ptr '0'
	inc si
	jmp Int2StrLoop
  letter:
    add [si], byte ptr 55
    inc si
  jmp Int2StrLoop

  Int2StrEnd:
  mov sp, bp 
  pop bp 
  ret 2
Int2Str endp

solve proc
 mov ah, 0Ah
 mov dx, offset string1
 int 21h
 call println
 push offset string1
 call Str2Int

 mov ah, 0Ah
 mov dx, offset string2
 int 21h
 call println
 push offset string2
 call Str2Int

 push offset string2
 push offset string1
 call sum  
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