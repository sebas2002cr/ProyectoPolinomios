.386
.model flat,stdcall
.stack 4096
ExitProcess proto, dwExitCode : dword
ReadConsoleA PROTO, handle:DWORD, lpBuffer:PTR BYTE, nNumberOfCharsToRead:DWORD, lpNumberOfCharsRead:PTR DWORD, lpReserved:PTR DWORD 
GetStdHandle proto, nStdHandle: dword
WriteConsoleA PROTO, handle:DWORD, lpBuffer:PTR BYTE, nNumberOfCharsToWrite:DWORD,lpNumberOfCharsWritten:PTR DWORD,lpReserved:PTR DWORD

.DATA
	numPoli dw 1
	freemem dd ?
	polinomio1 dd ? 
	polinomio2 dd ? 
	polinomioR dd ?
	buffer byte 256 dup(?)
	lista dw 8092 dup(?)
	simbolo_negativo db "-",0
	is_potencia_negative dw 0
	is_coeficiente_negative dw 0
	mensaje1 db "Inserte los datos del primer polinomio.", 13, 10, 0
	mensaje2 db "Inserte los datos del segundo polinomio.", 13, 10, 0
	mensajeSalida db "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Resultado", 13, 10, 0
	;Elementos para obtener los datos
	buffere BYTE 256 DUP(?)
	bytesRead DWORD ?
	handleIn DWORD ?
	;Elementos para imprimir datos
	handleOut DWORD ?
	buffer_Size dw 255
	espacio db " ", 0
	newline db 13, 10, 0
; Buffer temporal para conversión de números
	numStr db 11 dup(?)
.CODE
main PROC
	;Inicio del programa.
	invoke GetStdHandle, -11 ;Obtener el handle para la salida.
	mov handleOut, eax		 ;Movemos el handle en eax a handleOut
	mov ebx, 0FFFFFFFFh		 ;Asignamos el valor nulo al registro ebx
	mov eax, OFFSET lista	 ;Asignamos la direccion de la lista al registro eax
	mov [eax], ebx			;Se agrega el valor nulo al primer elemento
	mov freemem, eax		;Se agrega freemem la posicion inicial de la lista
	mov polinomio1, eax		;Se agrega polinomio la posicion inicial de la lista
	invoke WriteConsoleA, handleOut, OFFSET mensaje1, 42, OFFSET bytesRead, 0
	invoke GetStdHandle, -10 ;Obtenemos el handle para la entrada
	mov handleIn, eax		 ;Movemos el handle en el registro eax al handleIn

cicloPolinomio1:
	mov ebx, SIZEOF buffere - 1   ;Se obtiene el tamano del buffer de entrada.
	invoke ReadConsoleA, handleIn, OFFSET buffere, ebx, OFFSET bytesRead, 0	;Realizamos la entrada de datos
	mov esi, OFFSET buffere													;Movemos la direccion del buffere
	cmp byte ptr [esi], "."													;Comparamos si el primer valor es .
	je finalAgregarPolinomioX												;Saltamos al final de agrega si es un punto
	mov eax, freemem														;Movemos el valor de freemem a eax
	push eax				;Se agrega la direccion de la lista en el stack
	mov eax, esi	
	push eax				;Se agrega la direccion de la cadena
	mov eax, 1				;Se reseva el espacio del retorno de la nueva direccion freemem en el stack
	push eax
	call ConvertirStringInt	;Se llama a la funcion ConvertirString
	pop eax					;Se saca el valor de retorno
	pop edx					;Se saca la direccion de la cadena
	pop edx					;Se saca la direccion de la lista.
	mov dx, numPoli			;Movemos el valor de numPoli a dx
	cmp dx, 2				;Comparamos dx con 2 para saber si estamos en el segundo polinomio
	je agregarSegundo		;Saltamos a agregar al segundo si es igual.
	mov ebx, polinomio1		;movemos el valor del polinomio1 a ebx para comparar
volverAgregar:
	mov edx, freemem		;movemos el valor de freemem a edx para comparar
	cmp ebx, edx			;Comparamos las direcciones de freemem y el polinomio para detenerminar si es el primer elemento
	je esPrimerElemento		;Si es el primer elemento se agrega al siguiente.
	mov esi, eax			;Movemos la direccion del elementos agregado para asignar la ubicacion de inicio en esi 
	sub esi, 4				;Le restamos a esi 4 para ir al inicio del nodo
	mov [eax-8], esi		;Le damos al puntero siguiente el valor del inicio del nodo 
esPrimerElemento:
	mov ebx, 0ffffffffh		;Se movemos a ebx el valor nulo.
	mov [eax], ebx			;Se agrega el valor de nulo al puntero actual
	add eax, 4				;Le agregamos cuatro a la direccion de la lista en eax para el nuevo elemento.
	mov freemem, eax		;Movemos la direccion en eax a freemem
	jmp cicloPolinomio1     ;Continua el loop cicloPolinomio
finalAgregarPolinomioX:
	mov ax, numPoli			;Movemos el valor de numPoli en ax 
	cmp ax, 2				;Comparamos el valor de ax con para saber si estamos en el segundo polinomio.
	je finalPolinomios		;Si es igual salimos de agregar el elemento
	inc ax					;else, incrementamos el valor de ax
	mov numPoli, ax			;Movemos el nuevo valor a la direccion de numPoli
	mov eax, freemem		;Movemos el valor en freemem a eax para 
	mov polinomio2, eax		;Movemos el valor de freemem en eax al polinomio2 para indicar su inicio
	invoke WriteConsoleA, handleOut, OFFSET mensaje2, 43, OFFSET bytesRead, 0  ;Se imprime el mensaje para agregar datos del polinomio 2
	jmp cicloPolinomio1      ;Continua el ciclo
finalPolinomios:			;Termina el proceso de agregar en los polinomios
	mov eax, freemem
	mov polinomioR, eax
	mov ebx, polinomio1
	push ebx
	mov ebx, polinomio2
	push ebx
	push eax
	push eax
	mov esi, 0
	push esi
	call SumarPolinomios
	pop eax
	pop edx
	pop edx
	pop edx
	pop edx
	
	; Inicia la impresión del resultado
	mov eax, polinomioR
	jmp Imprimir

agregarSegundo:
	mov ebx, polinomio2		;Movemos el valor de polinomio2 a ebx para comparar si es el primer elemento
	jmp volverAgregar		;Continua el ciclo.

Imprimir:
    mov eax, polinomioR ; traer la referencia del primer elemento de la salida

imprimirLoop:

	xor ebx, ebx
	xor edx, edx

    mov bx, [eax] ; Cargamos el coeficiente
	test bx, 8000h ; Se prueba el bit de signo (Probar el bit más significativo (bit 15))
	jnz is_negative_coeficiente ; Si el bit es 1, salta a la etiqueta is_negative
	jmp test_potencia
	is_negative_coeficiente:
		not bx;
		add bx,1
		mov is_coeficiente_negative, 1
		
		
	test_potencia:
    mov dx, [eax + 2]; Cargamos la potencia
	test dx, 8000h ; Probar el bit más significativo (bit 15)
	jnz is_negative_potencia ; Si el bit es 1, salta a la etiqueta is_negative
	jmp not_negative
	is_negative_potencia:
		not dx;
		add dx,1
		mov is_potencia_negative, 1

	not_negative:


    ; Convertir el coeficiente a cadena
    push eax
    push edx
    mov eax, ebx
    call IntToStr
    pop edx
    pop eax
	mov ebx, edx
	push eax
	cmp is_coeficiente_negative, 1
	jne volver_coeficiente
	invoke WriteConsoleA, handleOut, OFFSET simbolo_negativo, 1, OFFSET bytesRead, 0
	volver_coeficiente:
		invoke WriteConsoleA, handleOut, OFFSET numStr, ecx, OFFSET bytesRead, 0
		invoke WriteConsoleA, handleOut, OFFSET espacio, 1, OFFSET bytesRead, 0
	pop eax
    ; Convertir la potencia a cadena
    push eax
    push edx
    mov eax, ebx
    call IntToStr
    pop edx
    pop eax
	push eax
	cmp is_potencia_negative, 1
	jne volver_potencia
	invoke WriteConsoleA, handleOut, OFFSET simbolo_negativo, 1, OFFSET bytesRead, 0
	volver_potencia:
		invoke WriteConsoleA, handleOut, OFFSET numStr, ecx, OFFSET bytesRead, 0
		invoke WriteConsoleA, handleOut, OFFSET newline, 2, OFFSET bytesRead, 0
	pop eax

	push eax
	add eax, 4 ; para comprobar si lo que sigue es el final
	mov eax, [eax]
    cmp eax, 0FFFFFFFFh ; Comprobamos si es el final de la lista
	je finImpresionPolinomio
	sub eax, 4
	pop eax
	
    ; Avanzar al siguiente elemento
    add eax, 8
	mov is_coeficiente_negative, 0
	mov is_potencia_negative, 0
    jmp imprimirLoop

finImpresionPolinomio:
	invoke WriteConsoleA, handleOut, OFFSET mensajeSalida, 42, OFFSET bytesRead, 0
    invoke ExitProcess, 0

IntToStr PROC
    ; Esta función convierte un número entero (en eax) a una cadena (en numStr)
    ; y devuelve la longitud de la cadena en eax.

    ; Variables locales
    push ebp
    mov ebp, esp
    sub esp, 16 ; Reservar espacio para la cadena temporal

    mov edi, esp ; Usar edi como puntero de la cadena temporal
    mov ecx, 10  ; Divisor (base 10)

    ; Manejar el caso especial de 0
    cmp eax, 0
    jne intToStrLoop
	xor edx, edx  ; Limpiar edx antes de ponerle el ascii del caracter
    mov dl, 48   ; Convertir el dígito a carácter ASCII '0'
    dec edi       ; Mover el puntero a la izquierda
    mov [edi], dl ; Almacenar el carácter
    jmp intToStrDone

intToStrLoop:
    xor edx, edx  ; Limpiar edx antes de la división
    div ecx       ; Divide eax entre 10, cociente en eax, resto en edx
    add dl, 48   ; Convertir el dígito a carácter ASCII
    dec edi       ; Mover el puntero a la izquierda
    mov [edi], dl ; Almacenar el carácter
    test eax, eax ; ¿Eax es 0?
    jnz intToStrLoop ; Si no, repetir

intToStrDone:
	;mov numStr, 0
    mov eax, esp  ; Apuntar eax a la cadena temporal
    sub eax, edi  ; Calcular la longitud de la cadena

    ; Copiar la cadena temporal a numStr
    mov esi, edi  ; Puntero fuente
    mov edi, OFFSET numStr ; Puntero destino
    mov ecx, eax  ; Longitud de la cadena
    rep movsb     ; Copiar la cadena

    ; Devolver la longitud de la cadena en eax
    mov ecx, eax

    mov esp, ebp  ; Restaurar el puntero de pila
    pop ebp
    ret
IntToStr ENDP










ConvertirStringInt:				;Transformar un string a Int
								;esp+18: listas
								;esp+14: caracter
								;esp+10: valor Retorno 
								;esp+6: direccion retorno
								;esp+4: num1 (int variable local)
								;esp+2: num2 (int variable local)
								;esp: esNegativo (int)
	mov ax, 1					;asignar las variables locales
	push ax						;se pone a num1 al stack
	push ax						;se pone a num2 al stack
	mov ax, 0			
	push ax						;Se pone el valor esNegativo al stack
	mov ebp, esp				;Se pasa la direccion del stack al registro ebp
	mov esi, [ebp+14]			;obtienes la direccion del string
	cmp byte ptr [esi], 0		;se compara que no este vacio
	je finConvertirStringInt	;salta al fin de convertir
	;mov al, [esi]				movemos el primer caracter
	xor eax, eax				;limpiamos el registro eax
	mov bx, 10					;multiplicador de 10
convertirLoop:
	xor edx, edx				;limpiamos el registro edx
	cmp byte ptr [esi], " "		;Comparamos si es el espacio
	je siguienteNumero			;Salto para agregar el numero a la lista
	cmp byte ptr [esi], "-"		;Es negativo
	je setNegativo
	sub byte ptr [esi], "0"		;Se resta el valor ascii de 0 == 48
	mov dl, [esi]				;mueve el valor del entero convertido a dx
								
	imul ax, bx					;Se multiplica 10 para sumar el siguiente elemento

	add ax, dx					;Se suma el siguiente elemento

	mov byte ptr [esi], 0
	inc esi						;Incrementamos la direccion para pasar al siguiente elementos de la cadena
	cmp byte ptr [esi], 0		;Comprobamos si es el final del caracter
	je finConvertirStringInt	;Saltamos para agregar el nuevo elemento a la lista.
	cmp byte ptr [esi], "$"		;Comprobamos si es el final del caracter
	je finConvertirStringInt	;Saltamos para agregar el nuevo elemento a la lista.
	cmp byte ptr [esi], 13
	je finConvertirStringInt
	jmp convertirLoop			;salto para seguir el loop.
siguienteNumero:
	mov dx, [ebp]				;Se mueve el valor esNegativo a dx
	cmp dx, 1					;Se comprueba si esta activo
	jne pasarNoNegativo			;Saltamos si no es negativo
	neg ax						;Se niega el numero.
	dec dx						;Reiniciamos la bandera esNegativo
	mov [ebp], dx				;Guardamos el valor en esNegativo
pasarNoNegativo:
	mov [ebp+4], ax				;Movemos el primer numero en ax a num1
	mov byte ptr [esi], 0
	inc esi						;Pasamos al siguiente elemento incrementando la direccion
	xor eax, eax				;Se limpia el valor del registro de eax
	jmp convertirLoop			;Salto para seguir el loop	

setNegativo:
	inc esi						;Pasamos al siguiente elemento incrementando la direccion
	mov dx, [ebp]				;Obtenemos el valor guardado en esNegativo
	inc dx						;Se incrementa para represetar true
	mov [ebp], dx				;Guardamos el valor en esNegativo
	jmp convertirLoop			;Salto para seguir el loop
finConvertirStringInt:
	mov bx, [ebp]				;Se mueve el valor esNegativo a dx
	cmp bx, 1					;Se comprueba si esta activo
	jne pasarNoNegativo2		;Saltamos si no es negativo
	neg ax						;Se niega el valor de ax
pasarNoNegativo2:	
	mov [ebp+2], ax				;Se guarda el numero en ax al campo num2
	mov byte ptr [esi], 0
	mov byte ptr [esi+1], 0
	mov eax, [ebp+18]			;Se obtiene la direccion de la lista del stack
	push eax					;Se Ponen en el stack la direccion de la lista
	mov ax, [ebp+4]				;Se obtiene el valor de num1 del stack 
	push ax						;Se ponen en stack el num1
	mov ax, [ebp+2]				;Se obtiene el valor num2 del stack
	push ax						;Se pone en el stack el num2 
	mov eax, 0					;Se reserva el valor de retorno
	push eax						;Se pone en stack el valor de retorno
	call agregarLista			;Se llama la funcion de agregarLista
	pop eax						;Se saca del stack el valor de retorno la direccion actual de los elementos agregados
	pop dx						;Se saca del stack el valor de num2
	pop dx						;Se saca del stack el valor de num1
	pop edx						;Se saca del stack la direccion de la lista
	mov ebp, esp				;Retornamos la direccion del stack
	mov [ebp+10], eax			;Se asigna a el valor de retorno el almacenado en eax la direccion actual de los elementos agregados
	pop ax						;Se saca del stack el valor de esNegativo
	pop ax						;Se saca del stack el valor de num2
	pop dx						;Se saca del stack el valor de num1
	ret

agregarLista:
					;Agrega el Numero a la lista
					;StackFrame
					;esp+12: lista
					;esp+10: num1(int)
					;esp+8: num2(int)
					;esp+4: valor de Retorno (int)
					;esp: Direccion de retorno
	mov ebp, esp				;Se mueve la direccion del stack en ebp
	mov esi, [ebp+12]			;Se obtiene la direccion de la lista
	xor eax, eax				;Se limpia el registro de eax
;cicloLista:
	;mov ax, [ebp]				;Se consulta el valor de indice
	;cmp byte ptr [esi+eax], 0	;Se comprueba que es un valor vacio para agregar
	;je AgregarElemento			;Saltamos para agregar el elemento
	mov ax,[ebp+10]				;Ponemos el valor de num1 en ax
	mov [esi], ax				;Se agrega num1 al nodo
	add esi, 2					;Se suma 2 a esi
	mov ax, [ebp+8]				;Ponemos el valor de num2 en ax
	mov [esi], ax				;Agregamos el valor de num2 en el nodo
	add esi, 2					;Le sumamos 2 a la direccion de la lista
	mov [esp+4], esi		;Guardamos la direccion actual de la lista de los elementos agregados
	ret

SumarPolinomios:
				;Suma de Polinomios
				;Stack Frame
				;esp+30: Polinomio1
				;esp+26: Polinomio2
				;esp+22: PolinomioR
				;esp+18: Freemem
				;esp+14: ValorRetorno
				;esp+10: Direccion Retorno
				;esp+8: Coef1
				;esp+6: Exp1
				;esp+4: Coef2
				;esp+2: Exp2
				;esp: ultimoExp
	mov ax, 0	;mueve 0 el registro ax para representar el coeficiente 
	mov bx, -1	;mueve -1 al registro ax para representar el exponente vacio
	push ax		;Se inicia Coef1 en el stack
	push bx		;Se inicia Exp1 en el stack
	push ax		;Se inicia Coef2 en el stack
	push bx		;Se inicia Exp2 en el stack
	mov ax, 9999		
	push ax			;Se inicia un numero muy grande para representar el ultimoExp
	mov ebp, esp	;Recuperamos la ubicacion del stack en el registro ebp
inicioCiclo1:	
	mov esi, [ebp+30]	;Movemos al registro esi la direccion del polinomio1
	xor eax, eax		;Limpiamos el registro eax
	xor ebx, ebx		;Limpiamos el registro ebx
cicloSuma1:				;Etiqueta de la direccion para realizar el loop
	mov ax, [esi+2]		;Movemos al registro ax el exp del primer polinomio que se encuentra en la direccion esi 
	mov bx, [ebp]		;Movemos el valor del ultimoExp para comparar si ya se evalua o no.
	cmp ax, bx			
	jge siguienteElemento	;Si es mayor o igual ya fue evaluado.
	mov bx, [ebp+6]			;Movemos el valor del Exp1 para comparar si es mayor el que el exponente en ax
	cmp ax, bx				
	jle siguienteElemento   ;Si es menor entonces pasamos al siguiente si no cambiamos los valores del Exp1 y Coef1
	mov [ebp+6], ax			;Movemos el valor de ax al Exp1
	mov ax, [esi]			;Movemos el valor del coeficiente en polinomio1 a ax.
	mov [ebp+8], ax			;Movemos el valor de ax a Coef1

siguienteElemento:
	mov esi, [esi+4]		;Movemos la siguiente direccion a esi
	mov eax, 0FFFFFFFFh
	cmp esi, eax			;Comparamos si la direccion en esi es igual para saber si estamos al final
	je iniciociclo2			;Si es igual pasamos al siguiente ciclo
	jmp cicloSuma1			
inicioCiclo2:	
	mov esi, [ebp+26]		;Movemos la direccion del polinomio2 en esi
	xor eax, eax			;Limpiamos el registro eax
	xor ebx, ebx			;Limpiamos el registro ebx
cicloSuma2:					;Etiqueta para seguir en el ciclo del segundo Polinomio2
	mov ax, [esi+2]			;Movemos a ax el coeficien en la direccion actual esi+2
	mov bx, [ebp]			;Movemos el valor del ultimoExp para saber si ya comparamos ese exponente
	cmp ax, bx
	jge siguenteElementoPolinomio2		;Si es mayor ya se comparo y pasamos al siguiente elemento
	mov bx, [ebp+6]						;Movemos el valor del Exp1 para compara con el exponente en ax
	cmp ax, bx
	jg cambiarExponente1				;Si es mayor ax pasamos a cambiar el Exponente1 
	cmp ax, bx
	jne siguenteElementoPolinomio2		;Si el Exp1 y ax son diferentes pasamos al siguientem si no se agrega Exp2 y Coef2
	mov [ebp+2], ax						;Se agrega el valor ax a Exp2
	mov ax, [esi]						;Movemos el coeficiente en la direccion esi actual al registro ax.
	mov [ebp+4], ax						;Movemos a Coef2 el valor ax
siguenteElementoPolinomio2:				;Pasamos al siguiente elemento en la lista
	mov esi, [esi+4]					;Movemos la direccion en esi+4 a esi
	cmp esi, 0FFFFFFFFh					;comparamos si la direccion de esi es el final del polinomio2
	je realizarSuma						;Si es el final pasamos a la suma
	jmp cicloSuma2						;Seguimos en el cicloSuma2
cambiarExponente1:						;Cambiar exponente1 si es mayor
	mov [ebp+6], ax						;Movemos el valor del registro ax en Exp1
	mov ax, [esi]						;Movemos el coeficiente en la direccion en esi a ax
	mov [ebp+8], ax						;Movemos el valor de ax en Coef1
	mov ax, 0					
	mov [ebp+4], ax						;Movemos 0 a Coef2
	mov ax, -1			
	mov [ebp+2], ax						;Movemos -1 a Exp2
	jmp siguenteElementoPolinomio2		;Pasamos al siguiente Elemento del Polinomio2
realizarSuma:
	mov ax, [ebp+8]						;Movemos el valor de Coef1 en ax
	mov bx, [ebp+4]						;Movemos el valor de Coef2 en bx
	add ax, bx							;Sumamos el valor ax y bx
	mov [ebp+8], ax						;Movemos el resultado en ax a Coef1
AgregarElemento:
	mov bx, [ebp+6]						;Movemos el valor en Exp1 a bx para saber si ya se operaron todos los elementos
	cmp bx, -1							
	je finalSuma						;Saltamos al final del procedimiento
	mov ax, [ebp+8]						;Movemos el valor del Coef1 en ax
	mov edx, [ebp+18]					;Movemos la direccion de freemem en edx
	push edx							;Agregamos al stack la direccion freemem
	push ax								;Agregamos al stack el valor Coef1
	push bx								;Agregamos al stack el valor Exp1
	mov eax, 0
	push eax							;Agregamos el valor de retorno
	call agregarLista					;Llamamos al procedimiento de AgregarLista
	pop eax								;Obtenemos el valor de retorno
	pop bx
	pop bx
	pop ebx								;Limpiamos el stack
	mov ebp, esp						;Recuperamos la direccion del stack en ebp
	mov ebx, [ebp+18]					;Movemos la direccion de freemem
	mov edx, [ebp+22]					;Movemos la direccion de polinomioR
	cmp ebx, edx
	je primerElementoResult				;Comparamos si el valor igual para saber si es el primer elemento.
	mov esi, eax						
	sub esi, 4
	mov [eax-8], esi					; Se agrega la direccion del ultimo objeto agregado al puntero del elemento anterior
primerElementoResult:
	mov ebx, 0FFFFFFFFh					
	mov [eax], ebx						;Se agrega al puntero del ultimo elemento el valor nulo
	add eax, 4							;Se suma la 4 a la direccion en eax
	mov [ebp+18], eax					;Le pasamos la direccion en eax a freemem
	mov ax, [ebp+6]						
	mov [ebp], ax						;Movemos el valor Exp1 que se encuentra en ax a ultimoExp
	mov ax, 0			
	mov bx, -1
	mov [ebp+8], ax	
	mov [ebp+6], bx
	mov [ebp+4], ax
	mov [ebp+2], bx						;Ponemos los valores iniciales de Exp1, Ex2 en -1 y Coef1, Coef2 eb 0
	jmp inicioCiclo1					;Saltamos al inicio del polinomio1
finalSuma:
	mov eax, [ebp+18]					;Pasamos el valor de freemem como valor de retorno
	mov [ebp+14], eax					
	pop dx
	pop dx
	pop dx
	pop dx
	pop dx								;Limpiamos el stack y retornamos
	ret
main ENDP
END main