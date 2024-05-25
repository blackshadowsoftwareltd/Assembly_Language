DISPLAY_MSG MACRO msg
    lea dx, msg
    mov ah, 09h
    int 21h
ENDM

NEW_LINE MACRO
    mov dl, 0Dh    ; Carriage return
    mov ah, 02h    ; DOS function: display character
    int 21h        ; Call DOS interrupt

    mov dl, 0Ah    ; Line feed
    int 21h        ; Call DOS interrupt
ENDM

name "crypt"
org 100h

jmp start

msg_input db 'Enter a string : $'
msg_inserted db 0Dh, 0Ah, 'You Inserted : $'
msg_enc db 'Encrypted : $' 
msg_dec db 'Decrypted : $' 

input_buffer db 100, 0
input_string db 100 dup('$')
encrypted db 'hello world!', 0Dh,0Ah, '$' 
decrypted db  'axpps gsupn!', 0Dh,0Ah, '$' 
table1 db 97 dup (' '), 'klmnxyzabcopqrstvuwdefghij'

table2 db 97 dup (' '), 'hijtuvwxyzabcdklmnoprqsefg'


start: 
call user_input
call encrypt
call decrypt

encrypt:
lea bx, table1
lea si, encrypted
call parse

; show result:
DISPLAY_MSG  msg_enc
DISPLAY_MSG  encrypted

decrypt:
lea bx, table2
lea si, decrypted
call parse

; show result:
DISPLAY_MSG msg_dec
DISPLAY_MSG decrypted

; wait for any key...
mov ah, 0
int 16h

; -------- take user input to encryption {
	user_input:
    DISPLAY_MSG msg_input
	call read_input
	DISPLAY_MSG input_string
	NEW_LINE
	ret
; ---------take user input to encryption }

; -------- user input {
read_input:
    mov ah, 0Ah        
    lea dx, input_buffer 
    int 21h           
    mov si, dx          
    add si, 2
	DISPLAY_MSG msg_inserted

 
    mov di, offset input_string   
    mov cx, 100      
    rep movsb 
; -------- user input }

ret   ; exit to operating system.

; subroutine to encrypt/decrypt
; parameters: 
;             si - address of string to encrypt
;             bx - table to use.
parse proc near

next_char:
	cmp [si], '$'      ; end of string?
	je end_of_string
	
	mov al, [si]
	cmp al, 'a'
	jb  skip
	cmp al, 'z'
	ja  skip	
	; xlat algorithm: al = ds:[bx + unsigned al] 
	xlatb     ; encrypt using table2.  
	mov [si], al
skip:
	inc si	
	jmp next_char

end_of_string: 
ret
parse endp
end