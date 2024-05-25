display_string macro message
    local msg_start
    mov dx, offset message    ; Load address of the message
    mov ah, 09h               ; DOS function: print string
    int 21h                   ; Call DOS interrupt
endm

name "crypt"
org 100h

jmp start

msg_enc db 'Encrypted : $' 
msg_dec db 'Decrypted : $' 
encrypted db 'hello world!', 0Dh,0Ah, '$' 
decrypted db  'axpps gsupn!', 0Dh,0Ah, '$' 
table1 db 97 dup (' '), 'klmnxyzabcopqrstvuwdefghij'

table2 db 97 dup (' '), 'hijtuvwxyzabcdklmnoprqsefg'


start: 
call encrypt
call decrypt

encrypt:
lea bx, table1
lea si, encrypted
call parse

; show result:
display_string  msg_enc
display_string  encrypted

decrypt:
lea bx, table2
lea si, decrypted
call parse

; show result:
display_string msg_dec
display_string decrypted

; wait for any key...
mov ah, 0
int 16h

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