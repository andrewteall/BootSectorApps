    cpu 8086

; Constants
TitlePosition           equ 66          ;
MemoryCellStartPosition equ 322
NumberOfMemoryCells     equ 100
BeginningOfScreenMemory equ 0xB800

; Variable Allocations
CardiacMemoryDisplay    equ 0x8000      ; 400 bytes
IdxCounter              equ 0x8257      ; 3 bytes
Input                   equ 0x825A      ; 4 bytes
Output                  equ 0x825E      ; 4 bytes
Accumulator             equ 0x82F2      ; 4 bytes
ProgramCounter          equ 0x82F5      ; 3 bytes
CardiacMemory           equ 0x82F8      ; 200 bytes

    org 0x7c00

    mov word [IdxCounter],'00'

    mov di,CardiacMemory
    mov cx,NumberOfMemoryCells*2

PopulateCardiacMemoryCell:
    mov al,'b'
    stosb
    loop PopulateCardiacMemoryCell

    CS mov word [CardiacMemory],0x0100
    CS mov word [CardiacMemory+198],0x0008

    call clear_screen
    mov ax,BeginningOfScreenMemory
    mov ds,ax
    mov es,ax
    cld
Start:
     ; Convert Memory Values to Strings
    mov bx,0
    mov si,0
    mov cx,NumberOfMemoryCells
    call update_memory_display

    ; Print Title
    mov di,TitlePosition
    mov ah,0x0f
    mov bx,Title
    call print_string

    ; Print all the Cardiac's Memory Cells and Contents
    mov di,MemoryCellStartPosition      ; DI = Where to start printing the Memory Cells
    mov dx,CardiacMemoryDisplay         ; Use DX as a pointer to what Memory Cell we're Printing
    mov cx,NumberOfMemoryCells          ; CX = How many Memory Cells we need to print
DrawCell:
    ; Print Memory Cell Number
    mov bx,IdxCounter
    call print_string

    ; Increment Memory Cell Number
    call increment_index
    
    ; Print Opening Bracket for Memory Cell
    mov al,'['
    stosw

    ; Print Cardiac Memory
    mov bx,dx
    call print_string
    add dx,4
 
    ; Print Closing Bracket for Memory Cell
    mov al,']'
    stosw

    ; Add a space between Memory Cells
    mov al,' '
    stosw
    loop DrawCell

    ; Print Prompts
    add di,172
    mov bx,InputPrompt
    call print_string
    
    add di,144
    mov bx,OutputPrompt
    call print_string
    
    add di,134
    mov bx,AccumulatorPrompt
    call print_string
    
    add di,152
    mov bx,ProgramCounterPrompt
    call print_string

    jmp Start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sub-Routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_string:
    CS mov al,[bx]
    test al,al
    je end
    stosw
    inc bx
    jmp print_string
end:
    ret

clear_screen:
    push ax
    mov ax, 0x0002
    int 0x10
    pop ax
    ret

update_memory_display:
    push cx
    
    CS mov byte al,[CardiacMemory+bx]       ; 0-9
    cmp al,'b'
    je skip_update_memory_cell

    add al,'0'
    CS mov byte [CardiacMemoryDisplay+si],al

    mov ah,0

    CS mov byte al,[CardiacMemory+1+bx]     ; <99
    mov cl,10
    div cl

    add ax,0x3030
    CS mov word [CardiacMemoryDisplay+1+si],ax

    jmp done_update_memory_cell
skip_update_memory_cell:
    CS mov word [CardiacMemoryDisplay+si],'  '
    CS mov byte [CardiacMemoryDisplay+si+2],' '

done_update_memory_cell:
    add bx,2
    add si,4
    pop cx
    loop update_memory_display
    ret

increment_index:
    CS inc byte [IdxCounter+1]
    CS cmp byte [IdxCounter+1],':'
    jne SkipResetIdxCounter
    CS mov byte [IdxCounter+1],'0'
    CS inc byte [IdxCounter]
    CS cmp byte [IdxCounter],':'
    jne SkipResetIdxCounter
    CS mov byte [IdxCounter],'0'
SkipResetIdxCounter:
    ret

; Data
Title:                  db  "Cardiac",0
InputPrompt:            db  "Input: ",0
OutputPrompt:           db  "Output: ",0
AccumulatorPrompt:      db  "Accumulator: ",0
ProgramCounterPrompt:   db  "PC: ",0
    
    times 510-($-$$) db 0x4f
    db 0x55,0xaa