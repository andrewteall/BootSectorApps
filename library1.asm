    int 0x20


display_letter:
    push ax
    push bx
    push cx
    ; push dx
    ; push si
    ; push di
    mov ah,0x0e             ; Load AH with code for terminal output
    mov bx,0x000f           ; Load BH page zero and BL color (graphic mode)
    int 0x10                ; Call the BIOS for displaying one letter
    ; pop di
    ; pop si
    ; pop dx
    pop cx
    pop bx
    pop ax
    ret

; display_number:
;     mov dx,0
;     mov cx,10
;     div cx
;     push dx
;     cmp ax,0
;     je display_number_1
;     call display_number
; display_number_1:
;     pop ax
;     add al,'0'
;     call display_letter
;     ret

read_keyboard:
    ; push ax
    ; push bx
    ; push cx
    ; push dx
    ; push si
    ; push di
    mov ah,0x00             ; Load AH with code for keyboard read
    int 0x16                ; Call the BIOS for reading keyboard
    ; pop di
    ; pop si
    ; pop dx
    ; pop cx
    ; pop bx
    ; pop ax
    ret

newline:
    push ax
    mov al,13
    call display_letter
    mov al,10
    call display_letter
    pop ax
    ret

print_string:
    push cx
    push dx
    push si
    push di
print_string_loop:
    mov al,[bx]
    test al,al
    je end
	push bx
    mov ah,0x0e             ; Load AH with code for terminal output
    mov bx,0x000f           ; Load BH page zero and BL color (graphic mode)
    int 0x10                ; Call the BIOS for displaying one letter
    pop bx
	inc bx
	jmp print_string_loop
end:
    pop di
    pop si
    pop dx
    pop cx
    ret

clear_text_screen:
    ; clear screen
    mov ah, 0x00
    mov al, 0x03  ; text mode 80x25 16 colours
    int 0x10
    ret
