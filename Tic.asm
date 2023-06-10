;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2022/2023
;--------------------------------------------------------------
; Demostra��o da navega��o do cursor do Ecran 
;
;		arrow keys to move 
;		press ESC to exit
;
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'

        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'jogo.TXT',0
		Fich_nomes		db		'nomes.TXT',0
		Player1_nome	db		'???????????????????????????$'
		PLayer2_nome	db		'???????????????????????????$'
		Player1			db		'X'
		PLayer2			db		'O'
		Simbolo1		db      'X'
		Simbolo2		db      'O'
		JogadorAtual    db      'X'
        HandleFich      dw      0
		Menu_nomes		db		0		;0 Ainda não foi escrito o nome do primeiro jogador
										;1 Já foi escrito o nome do primeiro mas não o do segundo
										;2 Já foram escritos os 2 e pode começar o jogo

		Fases_jogo		db		0		;0 O jogo está na fase de pedir os nomes
										;1 o jogo está na fase de jogar
		
		Escreve_nomes   db      0       ;0 Escreve o Player1
										;1 Escreve o Player2

		car_fich        db      ?

		ultimo_num_aleat dw 	0
		num_jogadas     db      80

		combinacao1     db      1, 1, 1, ?, ?, ?, ?, ?, ?
		combinacao2     db      ?, ?, ?, 1, 1, 1, ?, ?, ?						;#############
		combinacao3     db      ?, ?, ?, ?, ?, ?, 1, 1, 1						;# 1 # 2 # 3 #
		combinacao4     db      1, ?, ?, 1, ?, ?, 1, ?, ?                       ;#############
		combinacao5     db      ?, 1, ?, ?, 1, ?, ?, 1, ?						;# 4 # 5 # 6 #
		combinacao6     db      ?, ?, 1, ?, ?, 1, ?, ?, 1						;#############
		combinacao7     db      1, ?, ?, ?, 1, ?, ?, ?, 1						;# 7 # 8 # 9 #
		combinacao8     db      ?, ?, 1, ?, 1, ?, 1, ?, ?						;#############

		tabuleiro1_X      db      9 dup(?)
		tabuleiro2_X      db      9 dup(?)
		tabuleiro3_X      db      9 dup(?)
		tabuleiro4_X      db      9 dup(?)
		tabuleiro5_X      db      9 dup(?)
		tabuleiro6_X      db      9 dup(?)
		tabuleiro7_X      db      9 dup(?)
		tabuleiro8_X      db      9 dup(?)
		tabuleiro9_X      db      9 dup(?)

		tabuleiro1_O      db      9 dup(?)
		tabuleiro2_O      db      9 dup(?)
		tabuleiro3_O      db      9 dup(?)
		tabuleiro4_O      db      9 dup(?)
		tabuleiro5_O      db      9 dup(?)
		tabuleiro6_O      db      9 dup(?)
		tabuleiro7_O      db      9 dup(?)
		tabuleiro8_O      db      9 dup(?)
		tabuleiro9_O      db      9 dup(?)

		Vitorias        db      ?, ?, ?, ?, ?, ?, ?, ?, ?

		jogoAtual       db      5                            ;Varia de 1 a 9 e é a referencia a cada tabuleiro

		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	2	; a linha pode ir de [1 .. 25]
		POSx			db	24	; POSx pode ir [1..80]	

dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg



;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm


;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax
			xor		bx,bx
			mov		cx,25*80
		
apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp

;######################## AFONSO ################
IMP_FICH_NOMES PROC
		;abre ficheiro
        mov     ah,3dh		; Open File function
        mov     al,0		; Open for reading only
        lea     dx,Fich_nomes		; Load the address of the filename
        int     21h			; Trigger DOS interrupt 21h
        jc      erro_abrir		; Jump to error handler if CF (Carry Flag) is set
        mov     HandleFich,ax		; Store the file handle
        jmp     ler_ciclo_nomes		; Jump to the reading loop

erro_abrir:
        mov     ah,09h		; Print String function
        lea     dx,Erro_Open	; Load the address of the error message
        int     21h				; Trigger DOS interrupt 21h
        jmp     sai_f		 ; Jump to the end of the procedure

ler_ciclo_nomes:
		; Read the file character by character
		mov     ah,3fh		; Read File function
        mov     bx,HandleFich	; File handle
        mov     cx,1		; Number of bytes to read (1 character)
        lea     dx,car_fich		; Buffer to store the read character
        int     21h			; Trigger DOS interrupt 21h
		jc		erro_ler		; Jump to error handler if CF is set
		cmp		ax,0		;EOF(end of file)?	; Check if the read operation reached EOF
		je		fecha_ficheiro	; Jump to close the file if AX is zero (EOF reached)
        
		; Print the character read from the file
		mov     ah,02h		; Print Character function
		mov		dl,car_fich		; Character to be printed
		int		21h			; Trigger DOS interrupt 21h
		jmp		ler_ciclo_nomes		; Continue looping to read the next character

erro_ler:
        mov     ah,09h		; Print String function
        lea     dx,Erro_Ler_Msg		; Load the address of the error message
        int     21h			; Trigger DOS interrupt 21h

fecha_ficheiro:
		; Close the file
        mov     ah,3eh			 ; Close File function
        mov     bx,HandleFich		; File handle
        int     21h				; Trigger DOS interrupt 21h
        jnc     sai_f			; Jump to the end of the procedure if CF is not set

        mov     ah,09h			; Print String function
        lea     dx,Erro_Close		; Load the address of the error message
        Int     21h			 ; Trigger DOS interrupt 21h
sai_f:	
		RET		; Return from the procedure
IMP_FICH_NOMES ENDP
;########################################################################
; IMP_FICH

IMP_FICH	PROC
		goto_xy	0, 0
		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro

        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h

sai_f:	
		RET
		
IMP_FICH	endp		


;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC
		
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp



;########################################################################
; Avatar

AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax
CICLO:			
			;Mudar a pos de inicio consoante o menu
			
			;##########
			mov     cl, Menu_nomes
			cmp     cl, 2
			je      INICIAR
			goto_xy	POSx,POSy		; Vai para nova posi��o
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h		
			mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor
		
			goto_xy	78,0			; Mostra o caractr que estava na posi��o do AVATAR
			mov		ah, 02h			; IMPRIME caracter da posi��o no canto
			mov		dl, Car	
			int		21H	
	
			goto_xy	POSx,POSy	; Vai para posi��o do cursor
			
			mov 	ch, Fases_jogo
			cmp 	ch, 0
			je 		LER_SETA_NOMES
			cmp 	ch, 1
			je		LER_SETA
			jmp 	fim
LER_SETA:	
			call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND_JOGO
			CMP 	AL, 27		; ESCAPE para sair
			JE		fim
			CMP     AL, 48		; Compara para ver se é '0' ZERO e se for o jogador joga
			je   	MOSTRA_JOGADA_TESTES
			; je   	MOSTRA_JOGADA	
			goto_xy	POSx,POSy 	; verifica se pode escrever o caracter no ecran
			; mov		CL, Car
			; cmp		CL, 32		; S� escreve se for espa�o em branco
			; JNE 	LER_SETA
			; mov		ah, 02h		; coloca o caracter lido no ecra
			; mov		dl, al
			; int		21H	
			; goto_xy	POSx,POSy
			
			jmp		LER_SETA

LER_SETA_NOMES:
			;Mudar a pos de inicio conseante o menu
				
			;##########
			call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND
			CMP     AL, 49		; '1' UM Para confirmar o nome ou para avançar para o jogo
			JE		CONFIRMA_NOME			
			goto_xy	POSx,POSy 	; verifica se pode escrever o caracter no ecran
			CMP     AL, 48		; Compara para ver se apaga usando o '0'
			JE		DELETE
			; goto_xy	POSx,POSy 	; verifica se pode escrever o caracter no ecran
			mov		CL, Car
			cmp 	CL, "#"
			je		BLOQUEIA_MOVIMENTO_NOMES
			cmp 	CL, ":"
			je		BLOQUEIA_MOVIMENTO_NOMES
			cmp		CL, 32		; S� escreve se for espa�o em branco
			JNE 	LER_SETA_NOMES
			mov		ah, 02h		; coloca o caracter lido no ecra
			mov		dl, al
			mov 	al, POSx
			cmp 	al, 51
			je 		LER_SETA_NOMES
			inc		POSx		;Direita
			int		21H	
			goto_xy	POSx,POSy
			
			jmp		LER_SETA_NOMES

CONFIRMA_NOME:
			mov 	ch, Menu_nomes
			cmp 	ch, 2
			je      INICIAR
			cmp     ch, 1
			je		CONFIRMA_JOGADOR2_INICIO
			cmp 	ch, 0
			je		CONFIRMA_JOGADOR1_INICIO
			jmp		fim

INICIAR:
		inc 	Fases_jogo		;mudar o numero da fase do jogo
		mov     Menu_nomes, 0
		jmp 	fim

CICLO_GUARDA_NOMES2:
			goto_xy POSx, POSy
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h		
			cmp     si, 27
			je      CONFIRMA_JOGADOR2_FIM
			mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor
			mov     byte ptr [Player2_nome + si], al
			inc     si
			inc     POSx
			jmp     CICLO_GUARDA_NOMES2

CONFIRMA_JOGADOR2_INICIO:
			mov     POSx, 24
			mov     POSy, 4
			xor     si, si
			jmp     CICLO_GUARDA_NOMES2

CONFIRMA_JOGADOR2_FIM:
			
			mov     POSx, 33
			mov 	POSy, 7
			inc 	Menu_nomes
			jmp 	CICLO

CICLO_GUARDA_NOMES1:
			goto_xy POSx, POSy
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h		
			cmp     si, 27
			je      CONFIRMA_JOGADOR1_FIM
			mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor
			mov     byte ptr [Player1_nome + si], al
			inc     si
			inc     POSx
			jmp     CICLO_GUARDA_NOMES1

CONFIRMA_JOGADOR1_INICIO:
			mov     POSx, 24
			mov     POSy, 2
			xor     si, si
			jmp     CICLO_GUARDA_NOMES1
			
CONFIRMA_JOGADOR1_FIM:

			mov 	POSx, 24
			mov 	POSy, 4
			inc 	Menu_nomes
			jmp 	CICLO

DELETE:
			mov		ah, 09h		; Function: Write character with attribute
			mov		al, 20h		; ASCII code for space
			mov		bh, 00h		; Page number (0)
			mov		bl, 07h		; Attribute: white on black
			mov		cx, 0001h	; Number of times to write the character
			int		10h			; Video interrupt
			mov 	al, POSx
			cmp 	al, 24
			je		CICLO
			dec 	POSx
			jmp		CICLO

BLOQUEIA_MOVIMENTO_NOMES:
			mov 	al, POSx
			cmp 	al, 24
			je 		INCREMENTA_POSX
			cmp 	al, 51
			je 		DECREMENTA_POSX
			mov 	al, POSy
			cmp 	al, 2
			je		INCREMENTA_POSY
			cmp 	al, 4
			je      DECREMENTA_POSY
			jmp     LER_SETA_NOMES
				
INCREMENTA_POSX:
			inc		POSx
			jmp		LER_SETA_NOMES

DECREMENTA_POSX:
			dec		POSx
			jmp		LER_SETA_NOMES

INCREMENTA_POSY:
			inc		POSy
			jmp		LER_SETA_NOMES
	
DECREMENTA_POSY:
			dec 	POSy
			jmp 	LER_SETA_NOMES

ESTEND:		;Verificar se pode andar
			mov 	cl, Menu_nomes
			cmp 	cl, 2
			je 		CICLO
			mov 	cl, POSy
			cmp 	cl, 2
			je 		ESQUERDA
			cmp 	al,48h
			jne		BAIXO
			dec		POSy		;cima
			jmp		CICLO

BAIXO:		
			cmp		al,50h
			jne		ESQUERDA
			inc 	POSy		;Baixo
			jmp		CICLO

ESQUERDA:
			mov 	cl, POSx
			cmp 	cl, 24
			je 		DIREITA
			cmp		al,4Bh
			jne		DIREITA
			dec		POSx		;Esquerda
			jmp		CICLO

DIREITA:
			mov 	cl, POSx
			cmp 	cl, 51
			je 		CICLO
			cmp		al,4Dh
			jne		CICLO
			;jne		LER_SETA 
			inc		POSx		;Direita
			jmp		CICLO

MOSTRA_JOGADA_TESTES:
			goto_xy	POSx, POSy
			mov		CL, Car
			cmp		CL, 32		; S� escreve se for espa�o em branco
			JNE     CICLO
			mov		ah, 02h		; coloca o caracter lido no ecra
			mov		dl, [JogadorAtual]
			jmp     MUDA_JOGADOR
			int		21H	

MOSTRA_JOGADA:
			goto_xy	POSx, POSy
			mov		CL, Car
			cmp		CL, 32		; S� escreve se for espa�o em branco
			JNE     CICLO
			mov		ah, 02h		; coloca o caracter lido no ecra
			mov		dl, [JogadorAtual]
			int		21H	
			jmp 	PROCURA_VITORIA_TAB

PROCURA_VITORIA_TAB:
			; xor     si, si
			; mov     al, jogoAtual
			; cmp     al, 1
			; je      PROCURA_VITORIA_TAB_1_INICIO
			; cmp     al, 2
			; je      PROCURA_VITORIA_TAB_2_INICIO
			; cmp     al, 3
			; je      PROCURA_VITORIA_TAB_3_INICIO
			; cmp     al, 4
			; je      PROCURA_VITORIA_TAB_4_INICIO
			; cmp     al, 5
			; je      PROCURA_VITORIA_TAB_5_INICIO
			; cmp     al, 6
			; je      PROCURA_VITORIA_TAB_6_INICIO
			; cmp     al, 7
			; je      PROCURA_VITORIA_TAB_7_INICIO
			; cmp     al, 8
			; je      PROCURA_VITORIA_TAB_8_INICIO
			; cmp     al, 9
			; je      PROCURA_VITORIA_TAB_9_INICIO
			jmp     fim

MUDA_JOGADOR_PARA_X:
			mov 	byte ptr [JogadorAtual], 'X'
			dec     num_jogadas
			jmp 	CICLO

MUDA_JOGADOR_PARA_O:
			mov 	byte ptr [JogadorAtual], 'O'
			dec     num_jogadas
			jmp 	CICLO

PROCURA_VITORIA_TAB_1_INICIO:
			mov     al, POSx
			mov     ah, POSy
			cmp     al, 4
			je      PROCURA_VITORIA_TAB_1_COLUNA_1
			cmp     al, 6
			je      PROCURA_VITORIA_TAB_1_COLUNA_2
			cmp     al, 8
			je      PROCURA_VITORIA_TAB_1_COLUNA_3
			jmp     CICLO

PROCURA_VITORIA_TAB_1_COLUNA_1:
			cmp     ah, 2
			je      PROCURA_VITORIA_TAB_1_POS_1
			cmp     ah, 3
			je      PROCURA_VITORIA_TAB_1_POS_4
			cmp     ah, 4
			je      PROCURA_VITORIA_TAB_1_POS_7
			jmp     CICLO


PROCURA_VITORIA_TAB_1_POS_1:
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_1_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_1_O
			; MUDAR a combinaçao atual do array


ATUALIZA_ARRAY_TAB_1_ESPACO_1_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro1_X], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM


ATUALIZA_ARRAY_TAB_1_ESPACO_1_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro1_O], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp     PROCURA_VITORIA_TAB_1_FIM

PROCURA_VITORIA_TAB_1_POS_4:
; 			; VER SE O JOGADOR é X ou O
; 			mov 	al, JogadorAtual
; 			cmp     al, 'X'
; 			je      ATUALIZA_ARRAY_TAB_1_ESPACO_4_X
; 			cmp     al, 'O'
; 			je      ATUALIZA_ARRAY_TAB_1_ESPACO_4_O
; 			; MUDAR a combinaçao atual do array

PROCURA_VITORIA_TAB_1_POS_7:



PROCURA_VITORIA_TAB_1_COLUNA_2:
			cmp     ah, 2
			je      PROCURA_VITORIA_TAB_1_POS_2
			cmp     ah, 3
			je      PROCURA_VITORIA_TAB_1_POS_5
			cmp     ah, 4
			je      PROCURA_VITORIA_TAB_1_POS_8
			jmp     CICLO

PROCURA_VITORIA_TAB_1_POS_2:
			; VER SE O JOGADOR é X ou O
			; MUDAR a combinaçao atual do array

PROCURA_VITORIA_TAB_1_POS_5:


PROCURA_VITORIA_TAB_1_POS_8:

PROCURA_VITORIA_TAB_1_COLUNA_3:
			cmp     ah, 2
			je      PROCURA_VITORIA_TAB_1_POS_3
			cmp     ah, 3
			je      PROCURA_VITORIA_TAB_1_POS_6
			cmp     ah, 4
			je      PROCURA_VITORIA_TAB_1_POS_9
			jmp     CICLO

PROCURA_VITORIA_TAB_1_POS_3:
			; VER SE O JOGADOR é X ou O
			; MUDAR a combinaçao atual do array

PROCURA_VITORIA_TAB_1_POS_6:


PROCURA_VITORIA_TAB_1_POS_9:


PROCURA_VITORIA_TAB_1_FIM:
			; Procurar vitoria no Tabuleiro 1
			; Push the address of combinacao1 onto the stack
			lea  si, combinacao1
			push si
			; Call the compare_arrays subroutine
			call compare_arrays

			; Push the address of combinacao2 onto the stack
			lea  si, combinacao2
			push si
			; Call the compare_arrays subroutine
			call compare_arrays

			; Push the address of combinacao3 onto the stack
			lea  si, combinacao3
			push si
			; Call the compare_arrays subroutine
			call compare_arrays

			; Push the address of combinacao4 onto the stack
			lea  si, combinacao4
			push si
			; Call the compare_arrays subroutine
			call compare_arrays

			; Push the address of combinacao5 onto the stack
			lea  si, combinacao5
			push si
			; Call the compare_arrays subroutine
			call compare_arrays

			; Push the address of combinacao6 onto the stack
			lea  si, combinacao6
			push si
			; Call the compare_arrays subroutine
			call compare_arrays

			; Push the address of combinacao7 onto the stack
			lea  si, combinacao7
			push si
			; Call the compare_arrays subroutine
			call compare_arrays

			; Push the address of combinacao8 onto the stack
			lea  si, combinacao8
			push si
			; Call the compare_arrays subroutine
			call compare_arrays

			jmp  	MUDA_JOGADOR

			compare_arrays:
					; Retrieve the combination array from the stack
					pop si

					; Calculate the size of the arrays
					mov cl, 9  ; Number of elements in the arrays

					; Point to the start of the arrays
					lea bp, tabuleiro1_X

					; Loop to compare elements
				compare_loop:
						; Compare the current elements
						mov al, [si]
						mov bl, [bp]
						cmp al, bl
						; cmp byte [si], [bp]
						jne endComparacao

						; Move to the next element
						inc si
						inc bp

						; Decrement the loop counter
						loop compare_loop

					mov  al, 1              ; Move the value 1 into the AL register
					mov  [Vitorias], al ; Move the value from AL into the memory location tabuleiro1_X
					; jmp     PROCURA_VITORIA_TOTAL
					ret

			;SE CHEGAR A ESTE PONTO E PORQUE FOI DTETADA UMA VITORIA NO TABULEIRO
			endComparacao:
					ret

			jmp     fim


MUDA_JOGADOR:
			mov     al, num_jogadas
			cmp     al, 0
			je      fim
			mov 	al, JogadorAtual
			cmp 	al, 'O'
			je      MUDA_JOGADOR_PARA_X
			cmp 	al, 'X'
			je      MUDA_JOGADOR_PARA_O
			jmp     fim

PROCURA_VITORIA_TOTAL:

ESTEND_JOGO:		;Verificar se pode andar
			cmp 	al,48h
			jne		BAIXO_JOGO
			dec		POSy		;cima
			jmp		CICLO

BAIXO_JOGO:		
			cmp		al,50h
			jne		ESQUERDA_JOGO
			inc 	POSy		;Baixo 
			jmp		CICLO

ESQUERDA_JOGO:
			cmp		al,4Bh
			jne		DIREITA_JOGO
			dec		POSx		;Esquerda
			dec		POSx
			jmp		CICLO

DIREITA_JOGO:
			cmp		al,4Dh
			jne		CICLO
			inc		POSx		;Direita
			inc		POSx
			jmp		CICLO

fim:				
			RET
AVATAR		endp

; #################################################################
IMP_NOMES_JOGO PROC
					mov     POSx, 37
					mov     POSy, 3
					mov     al, Escreve_nomes
					cmp     al, 0
					je      JOGADOR1
					mov     POSx, 37
					mov     POSy, 4
					cmp     al, 1
					je      JOGADOR2
					mov		POSx, 15
					mov 	POSy, 7
					jmp     fim

JOGADOR1:
		goto_xy POSx, POSy
		mov dl, 'X'            ; Print 'X' character
		mov ah, 02h            ; Set the function to display a character
		int 21h                ; Call interrupt 21h to print the character
		inc POSx               ; Increment POSx to move the cursor position
		mov dl, '-'            ; Print '-' character
		int 21h                ; Call interrupt 21h to print the character
		lea dx, Player1_nome   ; Load the address of the 'Player1_nome' string into the DX register
		mov ah, 09h            ; Set the function to display a string
		int 21h                ; Call interrupt 21h to print the string
		inc Escreve_nomes
		jmp IMP_NOMES_JOGO

JOGADOR2:
		goto_xy POSx, POSy
		mov dl, 'O'            ; Print 'O' character
		mov ah, 02h            ; Set the function to display a character
		int 21h                ; Call interrupt 21h to print the character
		inc POSx               ; Increment POSx to move the cursor position
		mov dl, '-'            ; Print '-' character
		int 21h                ; Call interrupt 21h to print the character
		lea dx, Player2_nome   ; Load the address of the 'Player2_nome' string into the DX register
		mov ah, 09h            ; Set the function to display a string
		int 21h                ; Call interrupt 21h to print the string
		inc Escreve_nomes
		jmp IMP_NOMES_JOGO

fim:
	RET
IMP_NOMES_JOGO endp

; ##################################################################
ATRIBUI_SIMBOLO PROC
					jmp		fim


fim:
	RET
ATRIBUI_SIMBOLO endp

; ####################################################################
CalcAleat proc near

	sub	sp,2
	push	bp
	mov	bp,sp
	push	ax
	push	cx
	push	dx	
	mov	ax,[bp+4]
	mov	[bp+2],ax

	mov	ah,00h
	int	1ah

	add	dx,ultimo_num_aleat
	add	cx,dx	
	mov	ax,65521
	push	dx
	mul	cx
	pop	dx
	xchg	dl,dh
	add	dx,32749
	add	dx,ax

	mov	ultimo_num_aleat,dx

	mov	[BP+4],dx

	pop	dx
	pop	cx
	pop	ax
	pop	bp
	ret
CalcAleat endp
; ######################################################################

;########################################################################
Main  proc
		mov			ax, dseg
		mov			ds,ax
		
		mov			ax,0B800h
		mov			es,ax
		
		call		apaga_ecran
		goto_xy		0,0				;Mudar as coordenadas de inicio
		call		IMP_FICH_NOMES    ;Abre o ficheiro dos nomes
		call 		AVATAR		
		; call		CalcAleat
		; pop			ax ; vai buscar 'a pilha o numero aleatorio
		; call        ATRIBUI_SIMBOLO      ;Atribui o simbolo de forma aleatória aos jogadores
		call		apaga_ecran
		call		IMP_FICH		;Abre o ficheiro de texto e imprime
		call        IMP_NOMES_JOGO		;Escreve o nome dos jogadores e os seus simbolos
		call 		AVATAR
		goto_xy		0,22
		
		mov			ah,4CH
		INT			21H
Main	endp
Cseg	ends
end	Main