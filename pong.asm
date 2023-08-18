.model small
.stack
.data
	posX dw 180 	; posicion inicial en X
	posY dw 100 	; posicion inicial en Y
	tamX dw 0   	; var. para tamaño de pelota y jugadores en X
	tamY dw 0   	; var. para tamaño de pelota y jugadores en Y
	dirX dw 5   	; cantidad de pixeles que se movera la pelota en x
	dirY dw 5   	; cantidad de pixeles que se movera la pelota en y
	dirj1 dw 10 	; cantidad de pixeles que se desplazaran los jugadores hacia arriba o abajo
	ver_end db 0   	; el numero de la variable define la etapa del juego 0. Nadie ha ganado 1. j1 gana 2. j2 gana

	winj1 db 'FIN DEL JUEGO J1 GANA!$'
	winj2 db 'FIN DEL JUEGO J2 GANA!$'

	jug1X dw 10 	; posicion inicial en X j1
	jug1Y dw 200	; posicion inicial en Y j1

	jug2X dw 620	; posicion inicial en X j2
	jug2Y dw 200	; posicion inicial en Y j2

.code

modografico proc
	push ax
	push bp
	mov bp,sp 		; apuntar bp a la cima de la pila
	mov ah, 00 		; Cerrar modo grafico
	mov al, [bp+06]	; Lee parámetro de entrada
	int 10h
	pop bp
	pop ax    
	ret    
modografico endp 

pelota proc
	push ax
	push bx
	push cx
	push dx

	mov cx, posx ; POSICION INICIAL EN X
	mov dx, posy ; POSICION INICIAL EN Y
	
	cic_pel:
		mov ah, 0ch 	; Función para dibujar pixel en modo gráfico
		mov al, 0fh		; Color del pixel
		mov bh, 00 		; Página de video
		int 10h

		inc cx			; Incrementar posición en X
		inc tamX		; Incrementar control tamaño en X
		cmp tamX, 10 	; Comprobar si el tamaño llego a 10 en X
		jne cic_pel 	; Si aún no es 10, repetir ciclo 
		mov cx, posx 	; Reiniciar posición en X
		mov tamX, 0 	; Reiniciar control de tamaño en X
		inc dx 			; Incrementar posición en Y
		inc tamY 		; Incrementar control de tamano en Y
		cmp tamY, 10 	; Comprobar si el tamaño llego a 10 en Y
		jne cic_pel 	; Si aún no es 10, repetir ciclo 
		mov tamY, 0 	; Reiniciar control de tamaño en Y

	pop dx
	pop cx
	pop bx
	pop ax
	ret
pelota endp

movimiento proc
	push ax
	mov ax, dirX 		; Cargar cantidad de pixeles a mover en X
	add posX, ax 		; Sumar la posición actual en X más los pixeles a mover en X

	cmp posX, 01h 		; Comprobar si posición en X es menor que 1
	jl gan2 			; Si se cumple, saltar a etiqueta de ganador jugador 2
	cmp posX, 275h 		; Comprobar si posición en X es mayor que 629 
	jg gan1 			; Si se cumple, saltar a etiqueta de ganador jugador 1
	jmp dis_vert 		; Si no se cumple ninguna, saltar a etiqueta dis_vert

	gan1:
		mov ver_end, 1 	; Cambia la variable controladora del estado de juego a 1, indicando que gano el jugador 1
		pop ax
		ret

	gan2:
		mov ver_end, 2 	; Cambia la variable controladora del estado de juego a 2, indicando que gano el jugador 2
		pop ax
		ret
	
	dis_vert:
		mov ax, dirY 	; Cargar cantidad de pixeles a mover en Y
		add posY, ax 	; Sumar la posición actual en Y más los piceles a mover en Y

		cmp posY, 01h 	; Comprobar si posición en Y es menor que 1
		jl cambVer 		; Si se cumple, saltar a cambVer (para cambiar dirección en vertical)
		cmp posY, 1d6h 	; Comprobar si posición en Y es mayor que 470
		jg cambVer 		; Si se cumple, saltar a cambVer (para cambiar dirección en vertical)

	;COMPROBAR SI CHOCA CON JUGADOR DERECHA - Condición => (maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2)
	; (posX + 10 [tamaño pelota en H] > jug2X) && (posX < jug2X + 10 [tamaño jugador en h]) && (posY + 10 [tamaño pelota en V] > jug2Y) && (posY < jug2Y + 80 [tamaño jugador en V])
	mov ax, posX 		
	add ax,10
	cmp ax,jug2X
	jng ver_choqj1 
		
	mov ax,jug2X
	add ax,10
	cmp posX,ax
	jnl ver_choqj1 
		
	mov ax,posY
	add ax,10
	cmp ax,jug2Y
	jng ver_choqj1 
		
	mov ax,jug2Y
	add ax,80
	cmp posY,ax
	jnl ver_choqj1

	jmp cambDir 		; Si no se cumple ninguna de las condiciones significa que colisiono con el jugador de la derecha (cambia de direccion)

	;COMPROBAR SI CHOCA CON JUGADOR IZQUIERDA
	ver_choqj1:
	mov ax, posX
	add ax, 10
	cmp ax, jug1X
	jng sali_col

	mov ax, jug1X
	add ax, 10
	cmp posX, ax
	jnl sali_col

	mov ax, posY
	add ax, 10
	cmp ax, jug1Y
	jng sali_col

	mov ax, jug1Y
	add ax, 80
	cmp posY, ax
	jnl sali_col

	jmp cambDir			; Si no se cumple ninguna de las condiciones significa que colisiono con el jugador de la izquierda (cambia de direccion)

	cambVer:
		neg dirY		; Invierte la dirección en Y
		pop ax
		ret

	cambDir:
		neg dirX 		; Cambiar dirección en X
		pop ax
		ret

	sali_col:
		pop ax
		ret
movimiento endp

jugadores proc
	push ax
	push bx
	push cx
	push dx

	mov cx, jug1X ; POSICION INICIAL EN X
	mov dx, jug1Y ; POSICION INICIAL EN Y

	cic_jugI: ; (DIBUJAR JUGADOR IZQUIERDO)
		mov ah, 0ch		; Función para dibujar pixel en modo gráfico
		mov al, 0fh		; Color del pixel (blanco)
		mov bh, 00 		; Página del video
		int 10h

		inc cx 			; Incrementa posición en X
		inc tamX 		; Incrementa control de tamaño en X
		cmp tamX, 10 	; Comprueba si el tamaño llego a 10 en X
		jne cic_jugI 	; Si aún no, repite el ciclo
		mov cx, jug1X 	; Reinicia la posición en X
		mov tamX, 0 	; Reinicia control de tamaño en X
		inc dx 			; Incrementa posición en Y
		inc tamY 		; Incrementa control de tamaño en Y
		cmp tamY, 80 	; Comprueba si el tamaño llego a 80 en Y
		jne cic_jugI 	; Si aún no, repite el ciclo
		mov tamY, 0 	; Reinicia control de tamaño en Y

	mov cx, jug2X ; POSICION INICIAL EN X
	mov dx, jug2Y ; POSICION INICIAL EN Y

	cic_jugD: ; (DIBUJAR JUGADOR DERECHO)
		mov ah, 0ch   	; Función para dibujar pixel en modo gráfico
		mov al, 0fh 	; Color del pixel (blanco)
		mov bh, 00 		; Página del video
		int 10h

		inc cx 			; Incrementa posición en X
		inc tamX 		; Incrementa control de tamaño en X
		cmp tamX, 10 	; Comprueba si el tamano llego a 10 en X
		jne cic_jugD 	; Si aún no, repite el ciclo
		mov cx, jug2X 	; Reinicia la posición en X
		mov tamX, 0 	; Reinicia control de tamaño en X
		inc dx 			; Incrementa posición en Y
		inc tamY 		; Incrementa control de tamaño en Y
		cmp tamY, 80 	; Comprueba si el tamano llego a 80 en Y
		jne cic_jugD 	; Si aún no, repite el ciclo
		mov tamY, 0 	; Reinicia control de tamaño en Y

	pop dx
	pop cx
	pop bx
	pop ax
	ret
jugadores endp

mov_jugador proc
	push ax

	mov ah, 01h ; verifica si alguna tecla se presiono
	int 16h
	jnz tecla 	; Si se presiono una tecla salta a etiqueta tecla para comprobar cual se presiono

	romper2: 	; Si no se presiona ninguna sale del procedimiento
	pop ax
	ret

	tecla:
	mov ah, 00h ; Lee el código de la tecla ingresada
	int 16h

	cmp al, 72h ; verifica si se presiono r 
	je j1arr
	cmp al, 76h ; verifica si se presiono v
	je j1aba
	cmp al, 75h ; verifica si se presiono u 
	je j2arr
	cmp al, 6dh ; verifica si se presiono m
	je j2aba
	jmp romper

	j1arr:
		mov ax, dirj1 		; Carga la cantidad de pixeles a desplazar al jugador
		sub jug1Y, ax 		; Resta dicha cantidad de pixeles a la posición del jugador1
		cmp jug1Y, 6 		; Comprueba si la posición del jugador en Y es menor que 6 (el borde superior)
		jl cambio_arr 		; Si es menor, salta a la etiqueta cambio_arr (para regresar al jugador)
		jmp romper 			; Si no es menor sale del procedimiento
		cambio_arr: 
			mov ax, 6 		; Establece la posición en Y del jugador 1 en 6
			mov jug1Y, ax
			jmp romper
	j1aba:
		mov ax, dirj1 		; Carga la cantidad de pixeles a desplazar al jugador
		add jug1Y, ax 		; Incrementa dicha cantidad de pixeles a la posición del jugador1
		cmp jug1Y, 394 		; Comprueba si la posición del jugador en Y es mayor que 394 (el borde inferior)
		jg cambio_aba 		; Si es mayor, salta a la etiqueta cammbio_aba (para regresar al jugador)
		jmp romper 			; Si no es mayor sale del procedimiento

		cambio_aba:
			mov ax, 394 	; Establece la posición en Y del jugador 1 en 394
			mov jug1Y, ax
			jmp romper
	j2arr:
		mov ax, dirj1
		sub jug2Y, ax
		cmp jug2Y, 6
		jl cambio_arr2
		jmp romper
		cambio_arr2: 
			mov ax, 6
			mov jug2Y, ax
			jmp romper
	j2aba:
		mov ax, dirj1
		add jug2Y, ax
		cmp jug2Y, 394
		jg cambio_aba2
		jmp romper
		cambio_aba2:
			mov ax, 394
			mov jug2Y, ax
			jmp romper
	romper:
	pop ax
	ret
mov_jugador endp

pausa proc
	push ax
	push cx
	push dx
		mov cx, 65000 		; Contador de repeticiones de la pausa
		pausa_ciclo1:
			push cx
			mov al, 86h 	; Establece los valores para el "temporizador"
			mov cx, 65000 	; Establece el contador para el "temporizador"
			mov dx, 65000 	; Establece el contador para el "temporizador"
			int 15h
			pop cx
		loop pausa_ciclo1 	; Repite el ciclo hasta haberse repetido 65,000 veces
	pop dx
	pop cx
	pop ax
	ret
pausa endp

borrar proc
	push ax
	   mov ah, 0Fh    ; Color del texto
	   int 10h        ; Borra el ultimo asterisco
	   mov ah, 0      ; Prepara el color de fondo
	   int 10h        ; Establece el fondo a su color original
	pop ax
	ret
borrar endp


ganaj1 proc
push ax
push bx
push dx
	mov bx, 0 		
	mov ah, 02h 	; Establece el subcodigo para cambiar la posicion del cursor
	mov bh, 00 		; Página de video
	mov dh, 14 		; Indica fila en Y donde se escribira
	mov dl, 28 		; Indica columna en X donde se escribira
	int 10h			; Cambia la posición del cursor
	mov ah,09 		; Establece la función para imprimir una cadena
	lea dx, winj1 	; Carga la cadena winj1 en dx
	int 21h 		; Imprime el mensaje
pop dx
pop bx
pop ax
ret
ganaj1 endp


ganaj2 proc
push ax
push bx
push dx
	mov bx, 0
	mov ah, 02h 	; Establece el subcodigo para cambiar la posicion del cursor
	mov bh, 00 		; Página de video
	mov dh, 14 		; Indica fila en Y donde se escribira
	mov dl, 28 		; Indica columna en X donde se escribira
	int 10h 		; Cambia la posición del cursor
	mov ah,09 		; Establece la función para imprimir una cadena
	lea dx, winj2 	; Carga la cadena winj2 en dx
	int 21h 		; Imprime el mensaje
pop dx
pop bx
pop ax
ret
ganaj2 endp

start:

mov dx, @data
mov ds, dx

;INICIAR MODO GRAFICO
mov al, 12h 		; Carga el valor 12h en al (modo gráfico)
push ax
call modografico 
pop ax

call borrar 		; Limpia la pantalla

ciclo: 
	call pausa 			; Genera una pausa
	call borrar 		; Limpia la pantalla
	push ax 			
	call movimiento 	; Cambia la posición de la pelota
	pop ax
	cmp ver_end, 1 		; Verifica si el estado del juego cambio a "gana jugador 1"
	je win_1 			; Si se cumple, salta a etiqueta win_1
	cmp ver_end, 2 		; Verifica si el estado del juego cambio a "gana jugador 2"
	je win_2			; Si se cumple, salta a etiqueta win_2
	call pelota 		; Dibuja la pelota
	push ax
	call mov_jugador 	; Cambia la posición de los jugadores
	pop ax
	call jugadores 		; Dibuja a los jugadores

	cmp ver_end, 0 		; Verifica si el estado del juego no ha cambiado (nadie ha ganado)
	je ciclo 			; Si se cumple, repite el ciclo

win_1:
	call ganaj1 		; Muestra el mensaje de que gano el jugador 1
	jmp fin 			; Salta al fin del juego

win_2:
	call ganaj2 		; Muestra el mensaje de que gano el jugador 2
	jmp fin 			; Salta al fin del juego

fin:
;ESPERAR TECLA
mov ah, 01 			; Establece la función para verificar si se presiona una tecla
int 21h 			; Espera a que se ingrese una tecla

;CERRAR MODO GRAFICO
mov al, 03 			; Carga el valor 03h en al (modo de texto)
push ax  			
call modografico
pop ax

mov ax, 4c00h
int 21h
end start