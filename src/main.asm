; ---------------------------
;| CALCULADORA FRACCIONES EN ASM |
; ----------------------------
DATA_SEG SEGMENT
    borderTLeftChar db 218
    borderTRightChar db 191
    borderBRightChar db 217
    borderBLeftChar db 192
    borderVerticalChar db 179
    borderHorizontalChar db 196
    insideChar db 219

    width db 60
    height db 6
    
    rectangleTOffset db 0
    rectangleLOffset db 0
    rectangleChar db ' '
    
    Num1Numerator db 0
    Num1Denominator db 1
    
    operation db ' '
    
    Num2Numerator db 0
    Num2Denominator db 1
    
    Num3Numerator db 0
    Num3Denominator db 1
    
    auxRN1 db 0
    auxRN2 db 0
    
    ten db 10 
    printNumAux db 0  
    
DATA_SEG ENDS

CODE_SEG SEGMENT
    ASSUME CS:CODE_SEG, DS:DATA_SEG

START:
    ; Inicializar segmento de datos
    mov ax, DATA_SEG
    mov ds, ax
    
    
main_loop:
    call DRAW_SCREEN
    call READ_FRACTIONS
    call performOperation ; Aseg?rate de llamar a performOperation
    call DISPLAY_RESULT ; Llamar a DISPLAY_RESULT para mostrar el resultado
    call SCAN_CHAR
    jmp main_loop
    
    ; Terminar el programa
    mov ax, 4C00h
    int 21h


; ----------------------------------------------  
;| PROCEDIMIENTO PARA LEER ENTRADAS DEL USUARIO |
; ----------------------------------------------     
READ_FRACTIONS PROC
    ; leer el numerador de la primera fraccion
    mov dh, 1
    mov dl, 36
    call SET_CURSOR
    call SCAN_NUM
    mov Num1Numerator, al
    
    ; imprimir la barra fraccionaria de primera fraccion
    mov dh, 2
    mov al, '-'
    call PRINT_CHAR
    
    ; leer el denominador de la primera fraccion
    mov dh, 3
    call SET_CURSOR
    call SCAN_NUM
    mov Num1Denominator, al
    
    ; leer la operacion
read_operation:
    mov dl, 38
    mov dh, 2
    call SET_CURSOR
    call SCAN_CHAR
    cmp al, 127
    cmp al, '+'
    je save_operation
    cmp al, '-'
    je save_operation
    cmp al, '/'
    je save_operation
    cmp al, '*'
    je save_operation
    jmp read_operation
    
save_operation:
    mov operation, al
    
    ; leer el numerador de la segunda fraccion
    mov dh, 1
    mov dl, 40
    call SET_CURSOR
    call SCAN_NUM
    mov Num2Numerator, al
    
    ; imprimir la barra fraccionaria de segunda fraccion
    mov dh, 2
    mov al, '-'
    call PRINT_CHAR
    
    ; leer el denominador de la segunda fraccion
    mov dh, 3
    call SET_CURSOR
    call SCAN_NUM
    ;call PRINT_NUM
    mov Num2Denominator, al

    ret
READ_FRACTIONS ENDP  


; -----------------------------------------  
;| PROCEDIMIENTO PARA DIBUJAR LA PANTALLA |
; -----------------------------------------            
DRAW_SCREEN PROC
    mov rectangleTOffset, 0
    mov width, 12
    mov rectangleLOffset, 34
    mov height, 6
    mov rectangleChar, ' '
    call DRAW_RECTANGLE
    
    ; -------------------
    mov width, 3
    mov height, 3
    
    mov rectangleChar, '1'
    mov rectangleTOffset, 6
    mov rectangleLOffset, 34
    call DRAW_RECTANGLE
    
    mov rectangleChar, '2'
    mov rectangleLOffset, 37
    call DRAW_RECTANGLE
    
    mov rectangleChar, '3'
    mov rectangleLOffset, 40
    call DRAW_RECTANGLE
    
    mov rectangleChar, '+'
    mov rectangleLOffset, 43
    call DRAW_RECTANGLE
    
    ; ----------------------------
    mov rectangleTOffset, 9
    
    mov rectangleChar, '4'
    mov rectangleLOffset, 34
    call DRAW_RECTANGLE
    
    mov rectangleChar, '5'
    mov rectangleLOffset, 37
    call DRAW_RECTANGLE
    
    mov rectangleChar, '6'
    mov rectangleLOffset, 40
    call DRAW_RECTANGLE
    
    mov rectangleChar, '-'
    mov rectangleLOffset, 43
    call DRAW_RECTANGLE
    
    ; ----------------------------
    mov rectangleTOffset, 12
    
    mov rectangleChar, '7'
    mov rectangleLOffset, 34
    call DRAW_RECTANGLE
    
    mov rectangleChar, '8'
    mov rectangleLOffset, 37
    call DRAW_RECTANGLE
    
    mov rectangleChar, '9'
    mov rectangleLOffset, 40
    call DRAW_RECTANGLE
    
    mov rectangleChar, '*'
    mov rectangleLOffset, 43
    call DRAW_RECTANGLE
    
    ; ----------------------------
    mov rectangleTOffset, 15
    
    mov rectangleChar, '0'
    mov rectangleLOffset, 34
    call DRAW_RECTANGLE
    
    mov rectangleChar, '='
    mov rectangleLOffset, 37
    call DRAW_RECTANGLE
    
    mov rectangleChar, 127
    mov rectangleLOffset, 40
    call DRAW_RECTANGLE
    
    mov rectangleChar, '/'
    mov rectangleLOffset, 43
    call DRAW_RECTANGLE
    ret
DRAW_SCREEN ENDP

; -----------------------------------------------  
;| PROCEDIMIENTO PARA POSICIONAR EL CURSOR       |
; -----------------------------------------------
; pasar en dh la fila
; pasar en dl la columna 
SET_CURSOR PROC
    mov bh, 0 ; p?gina 0
    mov ah, 02h
    int 10h
    ret
SET_CURSOR ENDP

; -----------------------------------------------  
;| PROCEDIMIENTO PARA LEER UN NUMERO DEL USUARIO |
; -----------------------------------------------  
SCAN_NUM PROC
    mov si, 0
next_char:
    ; Obtener car?cter del teclado
    mov ah, 00h
    int 16h
    
    ; Verificar si es ENTER
    cmp al, 13
    je one_digit
    
    ; Verificar si es un d?gito v?lido
    cmp al, 48
    jl next_char
    cmp al, 57
    jg next_char
    
    inc si
    
    ; Imprimir el car?cter
    mov ah, 0Eh
    int 10h
    
    sub al, 48 ; Convertir de ASCII a valor num?rico
    
    cmp si, 2
    je save_char2
    
save_char1:
    mov auxRN1, al
    jmp next_char
save_char2:
    mov auxRN2, al
    jmp two_digits
    
two_digits:
    mov al, auxRN1
    mul ten
    add al, auxRN2  
    ret
   
one_digit:
    mov al, auxRN1
    ret
SCAN_NUM ENDP

; -----------------------------------------------  
;| PROCEDIMIENTO PARA LEER UN CARACTER DEL USUARIO |
; -----------------------------------------------  
SCAN_CHAR PROC
    ; Obtener car?cter del teclado
    mov ah, 00h
    int 16h
    ; Imprimir el car?cter
    mov ah, 0Eh
    int 10h
    ret
SCAN_CHAR ENDP

; --------------------------------------------------------   
;| PROCEDIMIENTO PARA IMPRIMIR UN CARACTER EN LA PANTALLA |
; --------------------------------------------------------- 
; pasar en dh la fila
; pasar en dl la columna 
; pasar en al el caracter
PRINT_CHAR PROC
    call SET_CURSOR
    mov cx, 01h
    mov bh, 0
    mov bl, 07h
    mov ah, 09h
    int 10h
    ret
PRINT_CHAR ENDP

; --------------------------------------------------------   
;| PROCEDIMIENTO PARA IMPRIMIR UN NUMERO EN LA PANTALLA |
; --------------------------------------------------------- 
; pasar en dh la fila
; pasar en dl la columna 
; pasar en al el numero
PRINT_NUM PROC
    call SET_CURSOR           ; Establecer el cursor en la posici?n dada por DH y DL
    
    ; verificar si es un numero de 1 caracter
    cmp al, 9
    jg print_two_digits_num
    add al, 48
    call PRINT_CHAR
    ret
    
    ; Convertir AL en caracteres ASCII (m?ximo dos d?gitos)
print_two_digits_num:
    mov ah, 0
    div ten          ; Dividir AL por 10 (cociente en AL, resto en AH)
    add al, 48               ; Convertir el cociente en car?cter ASCII
    mov printNumAux, ah
    call PRINT_CHAR            ; Imprimir el car?cter en AL
    inc dl
    mov al, printNumAux 
    add al, '0'               ; Convertir el resto en car?cter ASCII
    call PRINT_CHAR            ; Imprimir el car?cter en AL
    
    ret
PRINT_NUM ENDP

; ------------------------------------------------------   
;| PROCEDIMIENTO PARA IMPRIMIR RECTANGULO EN LA PANTALLA |
; ------------------------------------------------------    
DRAW_RECTANGLE PROC 
    mov al, width           ; Cargando el ancho en al para luego multiplicarlo con el alto
    mov ah, height          ; Cargando el alto en cx
    mul ah                  ; Multiplicando el alto cargado en el paso anterior con el ancho cargado en al
    mov cx, ax              ; Moviendo el resultado de la multiplicaci?n a cx para usarlo como contador del ciclo que hace el rect?ngulo
    mov si, 0               ; Creando un contador que sirva para saber cu?l casilla del rect?ngulo estamos pintando
    
rectangle_loop:
    mov ax, si              ; Moviendo a ax el valor del contador si para luego dividirlo entre el ancho
    div width               ; Dividiendo el contador con el ancho, esto nos va a dar que el resultado es que el cociente que queda en 
                            ; (al) es la fila y el resto que queda en (ah) es la columna
    mov dh, al              ; Guardando el valor de la fila en (dh)
    mov dl, ah              ; Guardando el valor de la columna en (dl)
         
    ; Verificar esquinas
checkBorderTLeft:
    cmp dh, 0
    jne checkBorderTRight
    cmp dl, 0               
    je isBorderLeft

checkBorderTRight:
    cmp dh, 0
    jne checkBorderBRight
    mov bl, width
    sub bl, 1
    cmp dl, bl               
    je isBorderTRight
    
checkBorderBRight:
    mov bh, height
    sub bh, 1
    cmp dh, bh
    jne checkBorderBLeft
    mov bl, width
    sub bl, 1
    cmp dl, bl               
    je isBorderBRight
    
checkBorderBLeft:
    mov bh, height
    sub bh, 1
    cmp dh, bh
    jne checkVerticalBorder
    cmp dl, 0              
    je isBorderBLeft
    
    ; Verificar bordes
checkVerticalBorder:
    cmp dl, 0
    je isVerticalBorder
    mov bl, width
    sub bl, 1
    cmp dl, bl
    je isVerticalBorder
    
checkHorizontalBorder:
    cmp dh, 0
    je isHorizontalBorder
    mov bh, height
    sub bh, 1
    cmp dh, bh
    je isHorizontalBorder
    
   
    jmp isInside
  ; jmp fuera de rango
jumpOutOfRange:
    jmp rectangle_loop
  
        
; set print char
isBorderLeft:
    mov al, borderTLeftChar
    jmp printChar
isBorderTRight:
    mov al, borderTRightChar
    jmp printChar
isBorderBRight:
    mov al, borderBRightChar
    jmp printChar
isBorderBLeft:
    mov al, borderBLeftChar
    jmp printChar
isVerticalBorder:
    mov al, borderVerticalChar
    jmp printChar
isHorizontalBorder:
    mov al, borderHorizontalChar
    jmp printChar
    
isInside:
    mov al, rectangleChar
    jmp printChar          
   
printChar:
    add dh, rectangleTOffset
    add dl, rectangleLOffset
    call SET_CURSOR
    mov dx, cx
    mov cx, 01h
    mov bh, 0
    mov bl, 07h
    mov ah, 09h
    int 10h
    mov cx, dx
    inc si
    loop jumpOutOfRange
    ret

DRAW_RECTANGLE ENDP

; ------------------------------------------------------   
;| PROCEDIMIENTO PARA REALIZAR LOS CALCULOS |
; ------------------------------------------------------

performOperation proc
    cmp operation, '+'
    jne notAddition
    call addition
    jmp endOP

notAddition:
    cmp operation, '-'
    jne notSubtraction
    call subtraction
    jmp endOP

notSubtraction:
    cmp operation, '*'
    jne notMultiplication
    call multiplication
    jmp endOP

notMultiplication:
    cmp operation, '/'
    jne notDivision
    call division
    jmp endOP

notDivision:
    ; Salir si no hay una operaci?n v?lida
    jmp endOP

addition:
    ; Cargar los numeradores en registros
    mov al, Num1Numerator
    mov bl, Num2Numerator

    ; Comparar los valores
    cmp al, bl

    ; Si son iguales, saltar a la etiqueta NumeratorsEqual
    je numeratorsEqual
    
    ; Calcular nuevo numerador: Num1Numerator * Num2Denominator + Num2Numerator * Num1Denominator
    mov al, Num1Numerator
    mov bl, Num2Denominator
    mul bl
    mov cl, al  ; Guardar Num1Numerator * Num2Denominator en cx
    
    mov al, Num2Numerator
    mov bl, Num1Denominator
    mul bl
    add cl, al  ; Sumar Num2Numerator * Num1Denominator al resultado
    
    mov Num3Numerator, cl
    
    ; Calcular nuevo denominador: Num1Denominator * Num2Denominator
    mov al, Num1Denominator
    mov bl, Num2Denominator
    mul bl
    mov Num3Denominator, al
    jmp endAddition
    
numeratorsEqual:
    mov al, Num1Numerator
    mov bl, Num2Numerator
    add al, bl
    mov Num3Numerator, al
    
    mov al, Num1Denominator
    mov Num3Denominator, al

endAddition:
    ret

subtraction:
    ; Cargar los numeradores en registros
    mov al, Num1Numerator
    mov bl, Num2Numerator

    ; Comparar los valores
    cmp al, bl

    ; Si son iguales, saltar a la etiqueta NumeratorsEqualS
    je numeratorsEqualS
    
    ; Calcular nuevo numerador: Num1Numerator * Num2Denominator - Num2Numerator * Num1Denominator
    mov al, Num1Numerator
    mov bl, Num2Denominator
    mul bl
    mov cl, al  ; Guardar Num1Numerator * Num2Denominator en cx
    
    mov al, Num2Numerator
    mov bl, Num1Denominator
    mul bl
    sub cl, al  ; Restar Num2Numerator * Num1Denominator del resultado
    
    mov Num3Numerator, cl
    
    ; Calcular nuevo denominador: Num1Denominator * Num2Denominator
    mov al, Num1Denominator
    mov bl, Num2Denominator
    mul bl
    mov Num3Denominator, al
    jmp endSubtraction
    
numeratorsEqualS:
    mov al, Num1Numerator
    mov bl, Num2Numerator
    sub al, bl
    mov Num3Numerator, al
    
    mov al, Num1Denominator
    mov Num3Denominator, al

endSubtraction:
    ret

multiplication:
    ; Calcular nuevo numerador: Num1Numerator * Num2Numerator
    mov al, Num1Numerator
    mov bl, Num2Numerator
    mul bl
    mov Num3Numerator, al
          
    ; Calcular nuevo denominador: Num1Denominator * Num2Denominator
    mov al, Num1Denominator
    mov bl, Num2Denominator
    mul bl
    mov Num3Denominator, al
    
    ret       
    
division:
    ; Calcular nuevo numerador: Num1Numerator * Num2Denominator
    mov al, Num1Numerator
    mov bl, Num2Denominator
    mul bl
    mov Num3Numerator, al
          
    ; Calcular nuevo denominador: Num1Denominator * Num2Numerator
    mov al, Num1Denominator
    mov bl, Num2Numerator
    mul bl
    mov Num3Denominator, al
    
    ret


endOP:
    ret

performOperation endp



; ------------------------------------------------------   
;| PROCEDIMIENTO PARA MOSTRAR EL RESULTADO |
; ------------------------------------------------------

DISPLAY_RESULT PROC
    call DRAW_SCREEN
    ; Mostrar el numerador del resultado
    mov dh, 1
    mov dl, 42
    mov al, Num3Numerator
    call PRINT_NUM
    
    ; Mostrar la barra fraccionaria del resultado
    mov dh, 2
    mov al, '-'
    call PRINT_CHAR
    
    ; Mostrar el denominador del resultado
    mov dh, 3
    mov al, Num3Denominator
    call PRINT_NUM
    
    ret
DISPLAY_RESULT ENDP


; ------------------------------------------------------   
;| PROCEDIMIENTO PARA RESETEAR CALCULADORA
; ------------------------------------------------------

RESET_CALC PROC
    call DRAW_SCREEN
    mov Num1Numerator, 0
    mov Num1Denominator, 1
    mov Num2Numerator, 0
    mov Num2Denominator, 1
    mov operation, ' '
RESET_CALC ENDP

    

CODE_SEG ENDS
END START
