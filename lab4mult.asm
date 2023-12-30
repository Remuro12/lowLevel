assume CS:code,DS:data
 
data segment
inputBuf1 db 97, 99 dup ('$')
inputBuf2 db 97, 99 dup ('$')
wrongSymbolException db "Not a digit or minus in input", 13, 10, '$'
minusDigit db "-$"
result db 100 dup (0) 
newline db 13, 10, '$'
a db 50 dup(0)
b db 50 dup(0)
data ends

SSEG segment stack
db 400h dup (?)
SSEG ends
 
code segment
printSign proc
  mov dx, offset minusDigit
  mov ah, 09h
  int 21h
  ret
printSign endp

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
  mov di, [bp+6]
  xor cx, cx
  mov cl, [si+1] 
  mov [di], cl
  cmp byte ptr [si+2], '-'
  jne minusSignSkip
	dec cl
	mov [di], cl
	inc si
  minusSignSkip:
  add di, cx
  add si, 2 
  arrLoop:
    cmp byte ptr [si], '0'
	jae aboveCheck
	  cmp byte ptr [si], '-'
	  jne illegalChar
	    inc si
		dec di
	    loop arrLoop
	aboveCheck:
	cmp byte ptr [si], '9'
	ja illegalChar 
      sub byte ptr [si], '0'
	  mov bl, byte ptr [si]
	  mov [di], bl
	  dec di
	  inc si
	loop arrLoop
	
  mov sp, bp 
  pop bp 
  ret 4
  illegalChar: 
  mov dx, offset wrongSymbolException
  mov ah, 09h
  int 21h
  mov ah, 4Ch
  int 21h
Str2Int endp

Int2Str proc 
  push bp 
  mov bp, sp
  
  xor si, si
  xor cx, cx
  mov si, [bp+4] 
  Int2StrLoop:
  cmp [si], byte ptr '$'
  je Int2StrEnd
  add [si], byte ptr '0'
  inc si
  inc cx
  jmp Int2StrLoop
  Int2StrEnd:
  dec si
  mov ah, 02h
  printLoop:
  mov dl, byte ptr [si]
  int 21h
  dec si
  loop printLoop
  
  mov sp, bp 
  pop bp 
  ret 2
Int2Str endp

mult proc
  push bp 
  mov bp, sp
  sub sp, 20
  
  mov si, [bp+6]
  mov bl, [si]
  mov [bp-8], bl
  mov [bp-7], byte ptr 1
  
  mov si, [bp+4]
  mov bl, [si]
  mov [bp-6], bl
  
  startOfB_ILoop:
  mov cl, [bp-7] 
  mov bl, [bp-8]
  cmp cl, bl
  ja endOfMultLoop
    mov [bp-16], byte ptr 0
	
	mov [bp-5], byte ptr 1
	
	startOfA_ILoop:
	mov cl, [bp-5] 
	mov bl, [bp-6] 
	cmp cl, bl
	ja endOfA_ILoop
	  xor ax, ax
	  mov di, [bp+8]
	  mov al, [bp-5]
	  add di, ax 
	  mov al, [bp-7]
	  add di, ax 
	  dec di
	  dec di 
	  mov bl, [bp-16]
	  add [di], bl 
	  mov al, [bp-5] 
      mov si, [bp+4]
      add si, ax
      
      mov dl, [si]
      mov al, [bp-7]
      mov si, [bp+6]
      add si, ax
      ;dec si
      xor ax, ax
      mov al, [si]
      mul dl 
      add [di], al
	  mov al, [di]
	  mov bl, 10
	  div bl
	  mov [bp-16], al 
	  xor ax, ax
	  mov al, [di]
	  div bl
	  mov [di], ah
	  mov ah, [bp-5]
	  inc ah
	  mov [bp-5], ah
	  jmp startOfA_ILoop
    endOfA_ILoop:
    inc di
	mov al, [bp-16]
	add [di], al
	mov ah, [bp-7]
	inc ah
	mov [bp-7], ah
	jmp startOfB_ILoop
  endOfMultLoop:
  inc di
  mov [di], byte ptr '$'
  mov sp, bp
  pop bp
  ret 6
mult endp

start:
mov AX, data
mov DS, AX
mov ah, 0Ah
 mov dx, offset inputBuf1
 int 21h
 call println
 push offset a
 push offset inputBuf1
 call Str2Int

 mov ah, 0Ah
 mov dx, offset inputBuf2
 int 21h
 call println
 push offset b
 push offset inputBuf2
 call Str2Int

 mov si, offset inputBuf1
 mov di, offset inputBuf2
 add si, 2
 add di, 2
 cmp [si], byte ptr '-'
 je minus
   cmp [di], byte ptr '-'
	je plusMinus
	  push offset result
      push offset b
      push offset a
      call mult
	  jmp endOfSelection
	plusMinus:
	  call printSign
	  push offset result
      push offset b
      push offset a
	  call mult
	  jmp endOfSelection
  minus:
    cmp [di], byte ptr '-'
	je minusMinus
	  ;-+
	  call printSign
      push offset result
      push offset b
      push offset a
	  call mult
	  jmp endOfSelection
	minusMinus:
	;--
      push offset result
      push offset b
      push offset a
	  call mult
	  jmp endOfSelection
  endOfSelection:
  push offset result
  call Int2Str


mov ah, 4Ch
int 21h
code ends
end start