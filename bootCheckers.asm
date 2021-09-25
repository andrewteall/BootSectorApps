	cpu 8086


BOARD:              equ 0x0300
Player1_PiecesLeft  equ 0x0340
Player2_PiecesLeft  equ 0x0341
MoveBuffer          equ 0x0342      ; 7 bytes

	org 0x7c00
; Code
start:
    ; mov bx,Player1_PiecesLeft
    ; mov byte [bx],12
    ; mov bx,Player2_PiecesLeft
    ; mov byte [bx],12
    
; Fill the board with blank spaces
    mov cx,64
    mov bx,BOARD
    mov al,' '
ClearBoard:
    mov [bx],al
    inc bx
    loop ClearBoard

; Setup Checker Pieces
    mov bx,BOARD
    mov dx,2
    mov ax,'B'
    
SetupPlayer:
    mov cx,3
SetupRow:
    push cx
    mov cx,4
SetupSquare:
    mov [bx],al
    add bx,2
    loop SetupSquare

    pop cx
    cmp cx,3
    je AdjustSquare
    cmp dx,2
    je DecSquare
    jmp IncSquare

AdjustSquare:
    cmp dx,2
    je IncSquare
DecSquare:
    sub bx,2
IncSquare:
    inc bx
    loop SetupRow

    add bx,18
    mov ax,'R'
    dec dx
    jne SetupPlayer
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start Game Logic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartTurn:
    call clear_screen               ; Clear the screen
DrawBoard:
    mov bx,Title                    ; Print the title at the top of the board
    call print_string
    call newline                    ; Make some space between the title
    call newline                    ; and the board

    mov bx,BOARD                    ; Draw the board and pieces
    mov al,'1'
    mov cx,8
DrawBoardLoop:
    call display_letter
    push ax
    mov al,' '
    call display_letter
    
    call drawRow
    pop ax
    inc ax
    loop DrawBoardLoop
    mov bx,ColIdx
    call print_string

    call newline
    call newline
    
    xor di,1
    je BlackTurn
    mov bx,RedMov
    jmp RedTurn
BlackTurn:
    mov bx,BlkMov
RedTurn:    
    call print_string               ; End Drawing the board

ReadMove:                           ; Let the user type in the move to be 
    mov bx,MoveBuffer               ; performed
ReadNextKey:
    mov ah,0x00                     ; Load AH with code for keyboard read
    int 0x16                        ; Call the BIOS for reading keyboard
    cmp al,8
    jne SkipBackSpace
    cmp bx,MoveBuffer
    je ReadNextKey
    mov byte [bx],al
    call display_letter
    mov al,' '
    call display_letter
    mov al,8
    call display_letter
    dec bx
    jmp ReadNextKey
SkipBackSpace:
    cmp al,13
    je EndRead
    mov byte [bx],al
    call display_letter
    inc bx
    jmp ReadNextKey
EndRead:                            ; End reading move

DoMove:                             ; Perform the move entered if it is a
    xor bx,bx                       ; valid move
    mov al,[MoveBuffer+2]

    sub al,0x31
    mov cl, 0x08
    mul cx
    
    mov bl,[MoveBuffer]
    sub bl,0x30

    add bl,al
    sub bl,0x0001

    add bx,BOARD
    mov byte cl,[bx]
    mov si,bx
    
    ;;
    
    ; xor ax,ax
    xor bx,bx
    mov al,[MoveBuffer+6]

    sub al,0x31
    mov dl,0x08
    mul dx
    
    mov bl,[MoveBuffer+4]
    sub bl,0x30

    add bl,al
    sub bl,0x0001

    add bx,BOARD

    xor di,1
    cmp di,0
    jne SkipRedMove
    cmp cl,'R'
    jne StartTurn
    jmp SkipBlackMove
SkipRedMove:
    cmp cl,'B'
    jne StartTurn
SkipBlackMove:
    xor di,1

    mov dx,[bx]
    cmp dl,0x20
    je ContinueTurn
    xor di,1
    jmp StartTurn

ContinueTurn:

    mov byte [bx],cl
    mov byte [si],' '               ; End performing move

check_jump:                         ; See if a jump was performed
    xor ax,ax
    mov al,[MoveBuffer+6]
    sub al,[MoveBuffer+2]
    cmp al,1
    je no_jump
    cmp al,-1
    je no_jump

    cmp al, 2
    jne SkipNeg
    mov cl,1
    jmp DoneNum1
SkipNeg:
    mov cl,-1

DoneNum1:

    mov al,[MoveBuffer+2]
    
    sub al,0x31
    add byte al,cl

    
    mov cx, 0x0008
    mul cx
    mov bl,al
;;
    xor ax,ax
    mov al,[MoveBuffer+4]
    sub al,[MoveBuffer]
    
    cmp al, 2
    jne SkipNeg2
    mov cl,1
    jmp DoneNum2
SkipNeg2:
    mov cl,-1

DoneNum2:

    mov al,[MoveBuffer]
    
    sub al,0x30
    add al,cl
    
    and bx,0x00FF

    add bl,al
    sub bl,0x0001

    add bx,BOARD

    mov byte [bx],' '               ; End Checking for a Junp

no_jump:
    jmp StartTurn                   ; Next turn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sub-Routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawRow:
    push cx
    mov cx,8
drawRowLoop:
    call drawSquare
    loop drawRowLoop
    call newline
    pop cx
    ret

drawSquare:
    mov al,[bx]
    call display_letter
    inc bx
    mov al,' '
    call display_letter
    ret

display_letter:
    push ax
    push bx
    mov ah,0x0e             ; Load AH with code for terminal output
    mov bx,0x000f           ; Load BH page zero and BL color (graphic mode)
    int 0x10                ; Call the BIOS for displaying one letter
    pop bx
    pop ax
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
    push ax
    push bx
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
    pop bx
    pop ax
    ret

clear_screen:
    push ax
    mov ah, 0x00
    mov al, 0x03  ; text mode 80x25 16 colours
    int 0x10
    pop ax
    ret
    
; Data
Title:  db "    Checkers",0
ColIdx: db "  1 2 3 4 5 6 7 8",0
RedMov: db "Red Move?",0
BlkMov: db "Black Move?",0
    
    
    times 510-($-$$) db 0x4f
	db 0x55,0xaa