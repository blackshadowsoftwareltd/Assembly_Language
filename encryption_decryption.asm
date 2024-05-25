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
.model small
.stack 100h

.data
    msg_press_any_key_exit db 'Press any key to exit$', 0
    msg_input db 'Enter a string: $'
    msg_option_input db 'Enter 0 for Encryption or 1 for Decryption: $'
    msg_inserted db 0Dh, 0Ah, 'You Inserted: $'
    msg_s_enc db 'Encryption: $' 
    msg_s_dec db 'Decryption: $' 
    msg_enc db 'Encrypted: $' 
    msg_dec db 'Decrypted: $' 

    input_buffer db 100, 0
    input_string db 100 dup('$')
    encrypted db 'hello world!', 0Dh, 0Ah, '$' 
    decrypted db 'axpps gsupn!', 0Dh, 0Ah, '$' 
    table1 db 97 dup (' '), 'klmnxyzabcopqrstvuwdefghij'
    table2 db 97 dup (' '), 'hijtuvwxyzabcdklmnoprqsefg'

.code
start:
    jmp user_options_input

encrypt:
    lea bx, table1
    lea si, input_string
    call parse

    NEW_LINE
    DISPLAY_MSG msg_enc
    DISPLAY_MSG input_string
    NEW_LINE
    ret

decrypt:
    lea bx, table2
    lea si, input_string
    call parse

    NEW_LINE
    DISPLAY_MSG msg_dec
    DISPLAY_MSG input_string
    NEW_LINE
    ret

user_options_input:
    ; Display option message
    DISPLAY_MSG msg_option_input

    ; Read user input for option
    call read_option_input

    ; Check user input
    cmp al, '0'
    je option_zero
    cmp al, '1'
    je option_one

    ; Invalid input          
    jmp end_program

option_zero:
    NEW_LINE
    DISPLAY_MSG msg_s_enc
    NEW_LINE
    call user_input
    call encrypt
    jmp end_program

option_one:     
    NEW_LINE
    DISPLAY_MSG msg_s_dec
    NEW_LINE
    call user_input
    call decrypt
    jmp end_program

user_input:
    ; Display input prompt
    DISPLAY_MSG msg_input

    ; Read user input
    call read_input

    ; Display inserted message
    DISPLAY_MSG msg_inserted
    DISPLAY_MSG input_string
    NEW_LINE
    ret

read_option_input:
    mov ah, 01h         ; DOS function: read character with echo
    int 21h             ; Call DOS interrupt
    ret                 ; Return from subroutine

read_input:
    mov ah, 0Ah         ; DOS function: buffered input
    lea dx, input_buffer; Buffer for input
    int 21h             ; Call DOS interrupt
    mov si, dx          ; Point SI to input_buffer
    add si, 2           ; Skip over the length byte and the '$'
    mov di, offset input_string ; Destination pointer
    mov cx, 100         ; Maximum characters to copy
    rep movsb           ; Copy string from input_buffer to input_string
    ret

end_program:
    NEW_LINE
    DISPLAY_MSG msg_press_any_key_exit
    mov ah, 0
    int 16h

    ; Exit program
    mov ah, 4Ch
    int 21h

; Macro to display string
 
parse proc near
next_char:
    cmp [si], '$'        ; End of string?
    je end_of_string

    mov al, [si]
    cmp al, 'a'
    jb skip
    cmp al, 'z'
    ja skip
    xlatb                ; Encrypt/decrypt using table
    mov [si], al

skip:
    inc si
    jmp next_char

end_of_string:
    ret
parse endp

end start
