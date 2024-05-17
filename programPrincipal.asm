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
	mensaje1 db "Inserte los datos del primer polinomio.", 13, 10, 0
	mensaje2 db "Inserte los datos del segundo polinomio.", 13, 10, 0
	;Elementos para obtener los datos
	buffere BYTE 256 DUP(?)
	bytesRead DWORD ?
	handleIn DWORD ?
	;Elementos para imprimir datos
	handleOut DWORD ?
	buffer_Size dw 255
.CODE
main PROC
	;Inicio del programa.
	invoke GetStdHandle, -11 ;Obtener el handle para la salida.
	mov handleOut, eax		 ;Movemos el handle en eax a handleOut
	mov ebx, 0FFFFFFFFh		 ;Asignamos el valor nulo al registro ebx
	mov eax, OFFSET lista	 ;Asignamos la direccion de la lista al registro al eax
	mov [eax], ebx			;Se agrega el valor nulo al primer elemento
	mov freemem, eax		;Se agrega freemem la posicion inicial de la lista
	mov polinomio1, eax		;Se agrega polinomio la posicion inicial de la lista
	invoke WriteConsoleA, handleOut, OFFSET mensaje1, 42, OFFSET bytesRead, 0
	invoke GetStdHandle, -10 ;Obtenemos el handle para la entrada
	mov handleIn, eax		 ;Movemos el handle en el registro eax al handleIn

cicloPolinomio1:
	mov ebx, SIZEOF buffere - 1   ;Se obtiene el tamaño del buffer de entrada.
	invoke ReadConsoleA, handleIn, OFFSET buffere, ebx, OFFSET bytesRead, 0	;Realizamos la entrada de datos
	mov esi, OFFSET buffere													;Movemos la direccion del buffere
	cmp byte ptr [esi], "."													;Comparamos si el primer valor es .
	je finalAgregarPolinomioX												;Saltamos al final de agrega si es un punto
	mov eax, freemem														;Movemos el valor de freemem a eax
	push eax				;Se agrega la direccion de la lista en el stack
	mov eax, esi	
	push eax				;Se agrega la direccion de la cadena
	mov eax, 1				;Se reseva el espacio del retorno de la nueva dirección freemem en el stack
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
	invoke ExitProcess, 0

agregarSegundo:
	mov ebx, polinomio2		;Movemos el valor de polinomio2 a ebx para comparar si es el primer elemento
	jmp volverAgregar		;Continua el ciclo.
	
	
	
	
; Funciones
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
	mov ebp, esp				;Se pasa la dirección del stack al registro ebp
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
	mov ax, 0
	mov bx, -1
	push ax
	push bx
	push ax
	push bx
	mov ax, 123
	push ax
	mov ebp, esp
inicioCiclo1:	
	mov esi, [ebp+30]
	xor eax, eax
	xor ebx, ebx
ciclo1:
	mov ax, [esi+2]
	mov bx, [ebp]
	cmp ax, bx 
	jge siguienteElemento 
	mov bx, [ebp+6]
	cmp ax, bx
	jle siguienteElemento   
	mov [ebp+6], ax
	mov ax, [esi]
	mov [ebp+8], ax

siguienteElemento:
	mov esi, [esi+4]
	mov eax, 0FFFFFFFFh
	cmp esi, eax
	je iniciociclo2
	jmp ciclo1
inicioCiclo2:	
	mov esi, [ebp+26]
	xor eax, eax
	xor ebx, ebx
ciclo2:
	mov ax, [esi+2]
	mov bx, [ebp]
	cmp ax, bx
	jge siguenteElementoPolinomio2  
	mov bx, [ebp+6]
	cmp ax, bx
	jg cambiarExponente1
	cmp ax, bx
	jne siguenteElementoPolinomio2
	mov [ebp+2], ax
	mov ax, [esi]
	mov [ebp+4], ax
	jmp realizarSuma
siguenteElementoPolinomio2:
	mov esi, [esi+4]
	cmp esi, 0FFFFFFFFh
	je AgregarElemento
	jmp ciclo2
cambiarExponente1:
	mov [ebp+6], ax
	mov ax, [esi]
	mov [ebp+8], ax
	jmp AgregarElemento
realizarSuma:
	mov ax, [ebp+8]
	mov bx, [ebp+4]
	add ax, bx
	mov [ebp+8], ax
AgregarElemento:
	mov bx, [ebp+6]
	cmp bx, -1
	je finalSuma
	mov ax, [ebp+8]
	mov edx, [ebp+18]
	push edx
	push ax
	push bx
	mov eax, 0
	push eax
	call agregarLista
	pop eax
	pop bx
	pop bx
	pop ebx
	mov ebp, esp
	mov ebx, [ebp+18]
	mov edx, [ebp+22]
	cmp ebx, edx
	je primerElementoResult
	mov esi, eax 
	sub esi, 4
	mov [eax-8], esi
primerElementoResult:
	mov ebx, 0FFFFFFFFh
	mov [eax], ebx
	add eax, 4
	mov [ebp+18], eax
	mov ax, [ebp+6]
	mov [ebp], ax
	mov ax, 0
	mov bx, -1
	mov [ebp+8], ax
	mov [ebp+6], bx
	mov [ebp+4], ax
	mov [ebp+2], bx
	jmp inicioCiclo1
finalSuma:
	mov eax, [ebp+18]
	mov [ebp+14], eax
	pop dx
	pop dx
	pop dx
	pop dx
	pop dx
	ret
main ENDP
END main