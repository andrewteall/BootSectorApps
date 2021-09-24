	cpu 8086


BOARD:              equ 0x0300
Player1_PiecesLeft  equ 0x0340
Player2_PiecesLeft  equ 0x0341
MoveBuffer          equ 0x0342      ; 7 bytes

	org 0x7c00
; Code
start:
	call clear_text_screen

    ; mov bx,Player1_PiecesLeft
    ; mov byte [bx],12
    ; mov bx,Player2_PiecesLeft
    ; mov byte [bx],12

    mov cx,64
    mov bx,BOARD
    mov ax,' '
ClearBoard:
    mov [bx],al
    inc bx
    loop ClearBoard

    mov cx,8
    mov bx,BOARD
    mov ax,'B'
    
SetupBlack1:
    mov [bx],al
    inc bx
    inc bx
    dec cx
    loop SetupBlack1

    inc bx
    mov cx,8
SetupBlack2:
    mov [bx],al
    inc bx
    inc bx
    dec cx
    loop SetupBlack2

    dec bx
    mov cx,8
SetupBlack3:
    mov [bx],al
    inc bx
    inc bx
    dec cx
    loop SetupBlack3

    mov cx,8
    add bx,16
    mov ax,'R'
    inc bx
SetupRed1:
    mov [bx],al
    inc bx
    inc bx
    dec cx
    loop SetupRed1

    dec bx
    mov cx,8
SetupRed2:
    mov [bx],al
    inc bx
    inc bx
    dec cx
    loop SetupRed2

    inc bx
    mov cx,8
SetupRed3:
    mov [bx],al
    inc bx
    inc bx
    dec cx
    loop SetupRed3

    
GameLoop:
    call DrawBoard
    call newline
    call newline
    mov bx,RedMov
    call print_string
    call read_move

    call do_move
    call check_jump

    call clear_text_screen

    call DrawBoard
    call newline
    call newline
    mov bx,BlkMov
    call print_string
    call read_move

    call do_move
    call check_jump

    call clear_text_screen

    jmp GameLoop

    jmp $

; Sub-Routines
DrawBoard:
    mov bx,Title
    call print_string
    call newline
    call newline

    mov bx,BOARD
    mov al,'1'
    mov cx,8
DrawBoardSub:
    call display_letter
    push ax
    mov al,' '
    call display_letter
    
    call DrawRow
    pop ax
    inc ax
    loop DrawBoardSub
    mov bx,ColIdx
    call print_string
    ret

DrawRow:
    push cx
    mov cx,8
DrawRowSub:
    call DrawSquare
    loop DrawRowSub
    call newline
    pop cx
    ret

DrawSquare:
    mov al,[bx]
    call display_letter
    inc bx
    mov al,' '
    call display_letter
    ret


read_move:

    mov bx,MoveBuffer
read_next_key:
    mov ah,0x00             ; Load AH with code for keyboard read
    int 0x16                ; Call the BIOS for reading keyboard
    cmp al,13
    je EndRead
    mov byte [bx],al
    call display_letter
    inc bx
    jmp read_next_key

EndRead:

    ret

do_move:
    mov ax,0x0000
    mov bx,0x0000
    mov al,[MoveBuffer+2]

    sub al,0x31
    mov cx, 0x0008
    mul cx
    
    mov bl,[MoveBuffer]
    sub bl,0x30

    add bl,al
    sub bl,0x0001

    add bx,BOARD
    mov byte cl,[bx]
    
    mov byte [bx],' '

    ;;
    mov ax,0x0000
    mov bx,0x0000
    mov al,[MoveBuffer+6]

    sub al,0x31
    mov dx,0x0008
    mul dx
    
    mov bl,[MoveBuffer+4]
    sub bl,0x30

    add bl,al
    sub bl,0x0001

    add bx,BOARD

    mov byte [bx],cl
    ret

check_jump:
    xor ax,ax                       ; 7,7 5,5                   3,7 5,5
    mov al,[MoveBuffer+6]           ; al = '5'                  al = 5
    
    
    sub al,[MoveBuffer+2]           ; al = -2
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

    mov al,[MoveBuffer+2]           ; al = '7'
    
    sub al,0x31                     ; al = 6
    add byte al,cl                  ; al = 5

    
    mov cx, 0x0008                  ; al = 5 cx = 8
    mul cx                          ; al = 40
    mov bl,al                       ; dl = 40
;;
    xor ax,ax
    mov al,[MoveBuffer+4]           ; al = '5'
    sub al,[MoveBuffer]             ; al = -2                        al = 1
    
    cmp al, 2
    jne SkipNeg2
    mov cl,1
    jmp DoneNum2
SkipNeg2:
    mov cl,-1

DoneNum2:

    mov al,[MoveBuffer]             ; al = '7'
    
    sub al,0x30                     ; al = 7
    add al,cl                  ; al = 6
    
    and bx,0x00FF

    add bl,al                       ; bl = 46
    sub bl,0x0001                   ; bl = 45

    add bx,BOARD                    ; 

    mov byte [bx],' '

no_jump:
    ret



; Includes
%include "library1.asm"
    
; Data
Title: db "    Checkers",0
ColIdx: db "  1 2 3 4 5 6 7 8",0
RedMov: db "R?",0
BlkMov: db "B?",0
    
    
    times 510-($-$$) db 0x4f
	db 0x55,0xaa