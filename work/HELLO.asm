assume cs:codesg, ds:datasg

datasg segment
    db 'Hello, Assembly!', 0dh, 0ah, '$'
datasg ends

codesg segment
start:
    mov ax, datasg
    mov ds, ax
    mov dx, 0
    mov ah, 9
    int 21h
    mov ax, 4c00h
    int 21h
codesg ends

end start
