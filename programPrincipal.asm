INCLUDE Irvine32.inc
.386
.model flat,stdcall
.stack 4096
ExitProcess proto, dwExitCode : dword

.DATA
	sting db "-4 8$", 0
	string db "36 7", 0
	numero1 dw ?
	numero2 dw ?
	buffer byte 100 dup(?)
	lista dw 8092 dup(?)
.CODE
main PROC
	mov eax, OFFSET lista 
	push eax				;Se agrega la direccion de la lista en el stack
	mov eax, OFFSET sting	
	push eax				;Se agrega la direccion de la cadena
	mov ax, 1				;Se reseva el espacio del retorno en el stack
	push ax
	call ConvertirStringInt	;Se llama a la funcion ConvertirString
	pop ax					;Se saca el valor de retorno
	pop edx					;Se saca la direccion de la cadena
	pop edx					;Se saca la direccion de la lista.
salir:
	invoke ExitProcess, 0
	
	
	
	
	
	
	
; Funciones
ConvertirStringInt:				;Transformar un string a Int
								;esp+16: listas
								;esp+12: caracter
								;esp+10: valor Retorno (int)
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
	mov esi, [ebp+12]			;obtienes la direccion del string
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

	inc esi						;Incrementamos la direccion para pasar al siguiente elementos de la cadena
	cmp byte ptr [esi], 0		;Comprobamos si es el final del caracter
	je finConvertirStringInt	;Saltamos para agregar el nuevo elemento a la lista.
	cmp byte ptr [esi], "$"		;Comprobamos si es el final del caracter
	je finConvertirStringInt	;Saltamos para agregar el nuevo elemento a la lista.
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
	mov eax, [ebp+16]			;Se obtiene la direccion de la lista del stack
	push eax					;Se Ponen en el stack la direccion de la lista
	mov ax, [ebp+4]				;Se obtiene el valor de num1 del stack 
	push ax						;Se ponen en stack el num1
	mov ax, [ebp+2]				;Se obtiene el valor num2 del stack
	push ax						;Se pone en el stack el num2 
	mov ax, 0					;Se reserva el valor de retorno
	push ax						;Se pone en stack el valor de retorno
	call agregarLista			;Se llama la funcion de agregarLista
	pop ax						;Se saca del stack el valor de retorno
	pop dx						;Se saca del stack el valor de num2
	pop dx						;Se saca del stack el valor de num1
	pop edx						;Se saca del stack la direccion de la lista
	mov [ebp+10], ax			;Se asigna a el valor de retorno el almacenado en ax
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
					;esp+6: valor de Retorno (int)
					;esp+2: Direccion de retorno
					;esp: indice(int)
	mov ax, 0					;Se reserva el campo del indice
	push ax						;Se pone en el stack el indice
	mov ebp, esp				;Se mueve la direccion del stack en ebp
	mov esi, [ebp+12]			;Se obtiene la direccion de la lista
	xor eax, eax				;Se limpia el registro de eax
cicloLista:
	mov ax, [ebp]				;Se consulta el valor de indice
	cmp byte ptr [esi+eax], 0	;Se comprueba que es un valor vacio para agregar
	je AgregarElemento			;Saltamos para agregar el elemento
	add ax, 4					;Se suma 4 a la direccion del indice
	mov [esp], ax				;Se guarda en el indice
	jmp cicloLista				;Saltamos para seguir el loop

AgregarElemento:
	mov ax, [esp]			;Accedo a la ubicacion de indice
	mov bx, [esp+10]		;Accedo a la ubicacion de num 1
	mov [esi+eax], bx		;Se almacena el primer digito
	mov bx,  [esp+8]		;Se accede a num 2
	add eax, 2				;Se suma 2 a al indice
	mov [esi+eax], bx		;Se agrega el num2 a la lista
	mov eax, 1
	mov [esp+8], eax		;Guardamos el valor de retorno de la funcion
	pop ax					;Se saca del stack el valor del indice
	ret
main ENDP
END main