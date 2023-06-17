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
		Fich_final 		db 		'winner.TXT',0
		Player1_nome	db		'???????????????????????????$'
		PLayer2_nome	db		'???????????????????????????$'
		Player1			db		'X'
		PLayer2			db		'O'
		Simbolo1		db      'X'
		Simbolo2		db      'O'
		JogadorAtual    db      'X'
		JogadorAtual_Cor    db    9h
		JogoTerminado 	db 		?       ;0 Empate            1 Vitoria
		Winner          db 		?
		Winner_nome     db 		'???????????????????????????$'
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

		tabuleiro1_X      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro2_X      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro3_X      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro4_X      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro5_X      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro6_X      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro7_X      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro8_X      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro9_X      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)

		tabuleiro1_O      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro2_O      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro3_O      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro4_O      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro5_O      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro6_O      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro7_O      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro8_O      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		tabuleiro9_O      db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)

		contador1 		db 		0
		contador2 		db 		0
		contador3 		db 		0
		contador4 		db 		0
		contador5 		db 		0
		contador6 		db 		0
		contador7 		db 		0
		contador8 		db 		0
		contador9 		db 		0

		Vitorias_X        db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		Vitorias_O        db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		Vitorias_Gerais   db      ?, ?, ?, ?, ?, ?, ?, ?, ?     ;9 dup(?)
		contador_gerais   db     0
		Empate_geral 	db 		0

		jogoAtual       db      5                            ;Varia de 1 a 9 e é a referencia a cada tabuleiro
		proximoTab      db      ?

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

;##################################################################
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
			goto_xy	POSx,POSy		; Vai para nova posi��o
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h		
			mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor
		
			; goto_xy	78,0			; Mostra o caractr que estava na posi��o do AVATAR
			; mov		ah, 02h			; IMPRIME caracter da posi��o no canto
			; mov		dl, Car	
			; int		21H	
	
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
			je   	MOSTRA_JOGADA	
			; je   	MOSTRA_JOGADA_TESTES
			goto_xy	POSx,POSy 	; verifica se pode escrever o caracter no ecran

			jmp		LER_SETA

LER_SETA_NOMES:
			call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND
			CMP     AL, 49		; '1' UM Para confirmar o nome ou para avançar para o jogo
			JE		CONFIRMA_NOME			
			goto_xy	POSx,POSy 	; verifica se pode escrever o caracter no ecran
			CMP     AL, 48		; Compara para ver se apaga usando o '0'
			JE		DELETE
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

INICIAR:
		mov     al, 1
		mov 	Fases_jogo, al		;mudar o numero da fase do jogo
		mov     al, 0
		mov     Menu_nomes, al
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
			mov     cl, 2
			mov 	Menu_nomes, cl
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
			mov     cl, 1
			mov 	Menu_nomes, cl
			jmp 	CICLO

DELETE:
			mov     al, Menu_nomes
			cmp     al, 2
			je      CICLO
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
			cmp     cl, 4
			je      ESQUERDA
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

; ;########################### CODIGO PARA TESTES ####################################################
; MOSTRA_JOGADA_TESTES:
; 			goto_xy	POSx, POSy
; 			mov		CL, Car
; 			cmp		CL, 32		; S� escreve se for espa�o em branco
; 			JNE     CICLO
; 			mov		ah, 02h				; coloca o caracter lido no ecra
; 			mov		dl, [JogadorAtual]
; 			int		21H	
; 			jmp     MUDA_JOGADOR_TESTE

; MUDA_JOGADOR_TESTE:
; 			mov     al, num_jogadas
; 			cmp     al, 0
; 			je      fim
; 			mov 	al, JogadorAtual
; 			cmp 	al, 'O'
; 			je      MUDA_JOGADOR_PARA_X_TESTE
; 			cmp 	al, 'X'
; 			je      MUDA_JOGADOR_PARA_O_TESTE

; MUDA_JOGADOR_PARA_X_TESTE:
; 			mov 	byte ptr [JogadorAtual], 'X'
; 			dec     num_jogadas
; 			jmp     CICLO
; MUDA_JOGADOR_PARA_O_TESTE:
; 			mov 	byte ptr [JogadorAtual], 'O'
; 			dec     num_jogadas
; 			jmp     CICLO

;####################################################################################################
;##################### DAQUI PARA A FRENTE É A LOGICA DAS VITORIAS E DO JOGO  #######################
;####################################################################################################

MOSTRA_JOGADA:
			goto_xy	POSx, POSy
			mov		CL, Car
			cmp		CL, 32		; S� escreve se for espa�o em branco
			JNE     CICLO
			; mov		ah, 02h					; coloca o caracter lido no ecra
			; mov		dl, [JogadorAtual]

			; MOV AL, BYTE PTR [JogadorAtual]    ; Load the character from the variable into AL
			; MOV AH, BYTE PTR [JogadorAtual_Cor]  ; Load the color attribute from the variable into AH

			;(POSy - 1)*160+POSx

			mov ax, 0
			mov cx, 0

			mov cl, byte ptr [POSx]     ; Store POSx in CL

			add cl, cl

			mov al, byte ptr [POSy]     ; Store POSy in AL

			; dec al                      ; Decrement AL by 1 to calculate (POSy - 1)

			mov bl, al                  ; Store (POSy - 1) in BL temporarily
			mov al, 160                 ; Load the constant value 160 into AL

			mul bl                      ; Multiply AL by BL

			mov ch, 0
			add ax, cx                  ; Add POSx to the result (stored in AX)

			; The result is now stored in AX


			mov bx, ax

			; The result is now stored in AX      

			MOV AH, BYTE PTR [JogadorAtual]    ; Load the character from the variable into AL
			MOV AL, BYTE PTR [JogadorAtual_Cor]  ; Load the color attribute from the 

			mov es:[bx], ah
			mov es:[bx+1], al	

; ciclo_mostra_jogada:			
			
			int		21H	
			jmp 	PROCURA_VITORIA_TAB

PROCURA_VITORIA_TAB:
			; xor     si, si
			mov     al, jogoAtual
			cmp     al, 1
			je      PROCURA_VITORIA_TAB_1_INICIO
			cmp     al, 2
			je      PROCURA_VITORIA_TAB_2_INICIO
			cmp     al, 3
			je      PROCURA_VITORIA_TAB_3_INICIO
			cmp     al, 4
			je      PROCURA_VITORIA_TAB_4_INICIO
			cmp     al, 5
			je      PROCURA_VITORIA_TAB_5_INICIO
			cmp     al, 6
			je      PROCURA_VITORIA_TAB_6_INICIO
			cmp     al, 7
			je      PROCURA_VITORIA_TAB_7_INICIO
			cmp     al, 8
			je      PROCURA_VITORIA_TAB_8_INICIO
			cmp     al, 9
			je      PROCURA_VITORIA_TAB_9_INICIO
			; jmp     fim
			jmp     CICLO

MUDA_PARA_TAB_1:
			mov     POSy, 3
			mov     POSx, 6
			jmp     CICLO

MUDA_PARA_TAB_2:
			mov     POSy, 3
			mov     POSx, 15
			jmp     CICLO

MUDA_PARA_TAB_3:
			mov     POSy, 3
			mov     POSx, 24
			jmp     CICLO

MUDA_PARA_TAB_4:
			mov     POSy, 7
			mov     POSx, 6
			jmp     CICLO

MUDA_PARA_TAB_5:
			mov     POSy, 7
			mov     POSx, 15
			jmp     CICLO

MUDA_PARA_TAB_6:
			mov     POSy, 7
			mov     POSx, 24
			jmp     CICLO

MUDA_PARA_TAB_7:
			mov     POSy, 11
			mov     POSx, 6
			jmp     CICLO

MUDA_PARA_TAB_8:
			mov     POSy, 11
			mov     POSx, 15
			jmp     CICLO

MUDA_PARA_TAB_9:
			mov     POSy, 11
			mov     POSx, 24
			jmp     CICLO


MUDA_JOGADOR_PARA_X:
			mov 	byte ptr [JogadorAtual], 'X'
			mov 	al, 9h
			mov 	byte ptr [JogadorAtual_Cor], al

			; MOV AL, 'X' ; Move the character to AL register
			; MOV AH, 1Fh      ; Move the color attribute to AH register
			; MOV BYTE PTR [JogadorAtual], AL ; Store the character in the video memory
			; MOV BYTE PTR [JogadorAtual+1], AH ; Store the color attribute in the video memory

			;GARANTIR QUE NAO VAI PARA QUADRADOS QUE JA TEM WINS
			mov     bl, proximoTab

			mov 	dh, [contador_gerais]  ; Load the byte value from the memory location pointed to by contador_gerais into al

			;al = 10 - bl
			mov    	al, 10
			sub 	al, bl

			mov     ah, 0
			mov     cx, ax

			mov  	bh, 0
			dec  	bl
			mov  	si, bx
	confirma_que_pode_ir_para_tab_O_1:
			
			cmp     [Vitorias_Gerais+si], 1
			jne     fim_do_loop_O

			inc 	dh
			inc     si
			mov  	bx, si

			loop confirma_que_pode_ir_para_tab_O_1

			mov   	dl, al

			;al = 9 - dl
			mov  	al, 9
			sub 	al, dl

			mov 	ah, 0
			mov   	cx, ax

			xor     si, si
			mov  	bx, si
	confirma_que_pode_ir_para_tab_O_2:
			
			cmp     [Vitorias_Gerais+si], 1
			jne     fim_do_loop_O

			inc 	dh
			inc     si
			mov  	bx, si

			loop confirma_que_pode_ir_para_tab_O_2

	fim_do_loop_O:

			cmp 	dh, 9
			jae     PREPARA_FIM_DO_JOGO_EMPATE
			mov 	bh, 0
			dec     num_jogadas
			inc     bl
			mov     jogoAtual, bl
			cmp     bl, 1
			je      MUDA_PARA_TAB_1
			cmp     bl, 2
			je      MUDA_PARA_TAB_2
			cmp     bl, 3
			je      MUDA_PARA_TAB_3
			cmp     bl, 4
			je      MUDA_PARA_TAB_4
			cmp     bl, 5
			je      MUDA_PARA_TAB_5
			cmp     bl, 6
			je      MUDA_PARA_TAB_6
			cmp     bl, 7
			je      MUDA_PARA_TAB_7
			cmp     bl, 8
			je      MUDA_PARA_TAB_8
			cmp     bl, 9
			je      MUDA_PARA_TAB_9
MUDA_JOGADOR_PARA_O:
			mov 	byte ptr [JogadorAtual], 'O'
			mov 	al, 0Eh
			mov     byte ptr [JogadorAtual_Cor], al

			; MOV AL, 'O' ; Move the character to AL register
			; MOV AH, 0Eh       ; Move the color attribute to AH register
			; MOV BYTE PTR [JogadorAtual], AL ; Store the character in the video memory
			; MOV BYTE PTR [JogadorAtual+1], AH ; Store the color attribute in the video memory

			;GARANTIR QUE NAO VAI PARA QUADRADOS QUE JA TEM WINS
			mov     bl, proximoTab

			mov 	dh, [contador_gerais]  ; Load the byte value from the memory location pointed to by contador_gerais into al

			;al = 10 - bl
			mov    	al, 10
			sub 	al, bl

			mov 	ah, 0
			mov     cx, ax

			mov  	bh, 0
			dec  	bl
			mov  	si, bx
	confirma_que_pode_ir_para_tab_X_1:
			
			cmp     [Vitorias_Gerais+si], 1
			jne     fim_do_loop_X
			
			inc 	dh
			inc     si
			mov  	bx, si

			loop confirma_que_pode_ir_para_tab_X_1

			mov   	dl, al

			;al = 9 - dl
			mov  	al, 9
			sub 	al, dl

			mov 	ah, 0
			mov   	cx, ax

			xor 	si, si
			mov  	bx, si
	confirma_que_pode_ir_para_tab_X_2:

			cmp     [Vitorias_Gerais+si], 1
			jne     fim_do_loop_X

			inc 	dh
			inc 	si
			mov  	bx, si

			loop confirma_que_pode_ir_para_tab_X_2

	fim_do_loop_X:

			cmp 	dh, 9
			jae     PREPARA_FIM_DO_JOGO_EMPATE
			mov   	bh, 0
			dec     num_jogadas
			inc     bl
			mov     jogoAtual, bl
			cmp     bl, 1
			je      MUDA_PARA_TAB_1
			cmp     bl, 2
			je      MUDA_PARA_TAB_2
			cmp     bl, 3
			je      MUDA_PARA_TAB_3
			cmp     bl, 4
			je      MUDA_PARA_TAB_4
			cmp     bl, 5
			je      MUDA_PARA_TAB_5
			cmp     bl, 6
			je      MUDA_PARA_TAB_6
			cmp     bl, 7
			je      MUDA_PARA_TAB_7
			cmp     bl, 8
			je      MUDA_PARA_TAB_8
			cmp     bl, 9
			je      MUDA_PARA_TAB_9

;############################################ TODA A LOGICA DO TABULEIRO 1 #############################
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
CONFIRMA_EMPATE_TAB_1:
			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 0
			mov  [Vitorias_Gerais+si], al
			jmp 	MUDA_JOGADOR
PROCURA_VITORIA_TAB_1_COLUNA_1:
			cmp     ah, 2
			je      PROCURA_VITORIA_TAB_1_POS_1
			cmp     ah, 3
			je      PROCURA_VITORIA_TAB_1_POS_4
			cmp     ah, 4
			je      PROCURA_VITORIA_TAB_1_POS_7
			jmp     CICLO


PROCURA_VITORIA_TAB_1_POS_1:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 1
			mov     proximoTab, cl
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
			jmp  PROCURA_VITORIA_TAB_1_FIM_X


ATUALIZA_ARRAY_TAB_1_ESPACO_1_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro1_O], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_O

PROCURA_VITORIA_TAB_1_POS_4:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 4
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_4_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_4_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_1_ESPACO_4_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro1_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_X

ATUALIZA_ARRAY_TAB_1_ESPACO_4_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro1_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_O

PROCURA_VITORIA_TAB_1_POS_7:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 7
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_7_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_7_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_1_ESPACO_7_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro1_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_X

ATUALIZA_ARRAY_TAB_1_ESPACO_7_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro1_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_O

PROCURA_VITORIA_TAB_1_COLUNA_2:
			cmp     ah, 2
			je      PROCURA_VITORIA_TAB_1_POS_2
			cmp     ah, 3
			je      PROCURA_VITORIA_TAB_1_POS_5
			cmp     ah, 4
			je      PROCURA_VITORIA_TAB_1_POS_8
			jmp     CICLO

PROCURA_VITORIA_TAB_1_POS_2:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 2
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_2_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_2_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_1_ESPACO_2_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro1_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_X


ATUALIZA_ARRAY_TAB_1_ESPACO_2_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro1_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_O

PROCURA_VITORIA_TAB_1_POS_5:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 5
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_5_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_5_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_1_ESPACO_5_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro1_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_X


ATUALIZA_ARRAY_TAB_1_ESPACO_5_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro1_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_O

PROCURA_VITORIA_TAB_1_POS_8:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 8
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_8_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_8_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_1_ESPACO_8_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro1_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_X


ATUALIZA_ARRAY_TAB_1_ESPACO_8_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro1_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_O

PROCURA_VITORIA_TAB_1_COLUNA_3:
			cmp     ah, 2
			je      PROCURA_VITORIA_TAB_1_POS_3
			cmp     ah, 3
			je      PROCURA_VITORIA_TAB_1_POS_6
			cmp     ah, 4
			je      PROCURA_VITORIA_TAB_1_POS_9
			jmp     CICLO

PROCURA_VITORIA_TAB_1_POS_3:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 3
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_3_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_3_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_1_ESPACO_3_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro1_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_X


ATUALIZA_ARRAY_TAB_1_ESPACO_3_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro1_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_O

PROCURA_VITORIA_TAB_1_POS_6:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 6
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_6_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_6_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_1_ESPACO_6_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro1_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_X


ATUALIZA_ARRAY_TAB_1_ESPACO_6_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro1_O+si], al 	; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_O


PROCURA_VITORIA_TAB_1_POS_9:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 9
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_9_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_1_ESPACO_9_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_1_ESPACO_9_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro1_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_X


ATUALIZA_ARRAY_TAB_1_ESPACO_9_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro1_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_1_FIM_O
PROCURA_VITORIA_TAB_1_FIM_X:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_1_COMB_1_FIM_X
PROCURA_VITORIA_TAB_1_COMB_1_FIM_X:		
		mov 	cx, 9
		lea 	bx, tabuleiro1_X
		lea     si, combinacao1
	compare_loop_1_comb_1_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_1_X
			cmp al, ah
			jne endComparacao_1_comb_1_X
		comparacao_nao_interessa_1_comb_1_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_1_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_X], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_1_X:
			jmp		PROCURA_VITORIA_TAB_1_COMB_2_FIM_X
PROCURA_VITORIA_TAB_1_COMB_2_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_X
		lea     si, combinacao2
	compare_loop_1_comb_2_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_2_X
			cmp al, ah
			jne endComparacao_1_comb_2_X
		comparacao_nao_interessa_1_comb_2_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_2_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_X], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_2_X:
			jmp		PROCURA_VITORIA_TAB_1_COMB_3_FIM_X
PROCURA_VITORIA_TAB_1_COMB_3_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_X
		lea     si, combinacao3
	compare_loop_1_comb_3_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_3_X
			cmp al, ah
			jne endComparacao_1_comb_3_X
		comparacao_nao_interessa_1_comb_3_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_3_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_X], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_3_X:
			jmp		PROCURA_VITORIA_TAB_1_COMB_4_FIM_X
PROCURA_VITORIA_TAB_1_COMB_4_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_X
		lea     si, combinacao4
	compare_loop_1_comb_4_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_4_X
			cmp al, ah
			jne endComparacao_1_comb_4_X
		comparacao_nao_interessa_1_comb_4_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_4_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_X], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_4_X:
			jmp		PROCURA_VITORIA_TAB_1_COMB_5_FIM_X
PROCURA_VITORIA_TAB_1_COMB_5_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_X
		lea     si, combinacao5
	compare_loop_1_comb_5_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_5_X
			cmp al, ah
			jne endComparacao_1_comb_5_X
		comparacao_nao_interessa_1_comb_5_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_5_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_X], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_5_X:
			jmp		PROCURA_VITORIA_TAB_1_COMB_6_FIM_X
PROCURA_VITORIA_TAB_1_COMB_6_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_X
		lea     si, combinacao6
	compare_loop_1_comb_6_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_6_X
			cmp al, ah
			jne endComparacao_1_comb_6_X
		comparacao_nao_interessa_1_comb_6_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_6_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_X], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_6_X:
			jmp		PROCURA_VITORIA_TAB_1_COMB_7_FIM_X
PROCURA_VITORIA_TAB_1_COMB_7_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_X
		lea     si, combinacao7
	compare_loop_1_comb_7_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_7_X
			cmp al, ah
			jne endComparacao_1_comb_7_X
		comparacao_nao_interessa_1_comb_7_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_7_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_X], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_7_X:
			jmp		PROCURA_VITORIA_TAB_1_COMB_8_FIM_X
PROCURA_VITORIA_TAB_1_COMB_8_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_X
		lea     si, combinacao8
	compare_loop_1_comb_8_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_8_X
			cmp al, ah
			jne endComparacao_1_comb_8_X
		comparacao_nao_interessa_1_comb_8_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_8_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_X], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_8_X:
			inc		contador1
			mov 	al, contador1
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_1
			jmp		MUDA_JOGADOR

PROCURA_VITORIA_TAB_1_FIM_O:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_1_COMB_1_FIM_O
PROCURA_VITORIA_TAB_1_COMB_1_FIM_O:		
		mov 	cx, 9
		lea 	bx, tabuleiro1_O
		lea     si, combinacao1
	compare_loop_1_comb_1_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_1_O
			cmp al, ah
			jne endComparacao_1_comb_1_O
		comparacao_nao_interessa_1_comb_1_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_1_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_O], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_1_O:
			jmp		PROCURA_VITORIA_TAB_1_COMB_2_FIM_O
PROCURA_VITORIA_TAB_1_COMB_2_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_O
		lea     si, combinacao2
	compare_loop_1_comb_2_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_2_O
			cmp al, ah
			jne endComparacao_1_comb_2_O
		comparacao_nao_interessa_1_comb_2_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_2_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_O], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_2_O:
			jmp		PROCURA_VITORIA_TAB_1_COMB_3_FIM_O
PROCURA_VITORIA_TAB_1_COMB_3_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_O
		lea     si, combinacao3
	compare_loop_1_comb_3_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_3_O
			cmp al, ah
			jne endComparacao_1_comb_3_O
		comparacao_nao_interessa_1_comb_3_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_3_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_O], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_3_O:
			jmp		PROCURA_VITORIA_TAB_1_COMB_4_FIM_O
PROCURA_VITORIA_TAB_1_COMB_4_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_O
		lea     si, combinacao4
	compare_loop_1_comb_4_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_4_O
			cmp al, ah
			jne endComparacao_1_comb_4_O
		comparacao_nao_interessa_1_comb_4_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_4_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_O], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_4_O:
			jmp		PROCURA_VITORIA_TAB_1_COMB_5_FIM_O
PROCURA_VITORIA_TAB_1_COMB_5_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_O
		lea     si, combinacao5
	compare_loop_1_comb_5_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_5_O
			cmp al, ah
			jne endComparacao_1_comb_5_O
		comparacao_nao_interessa_1_comb_5_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_5_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_O], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_5_O:
			jmp		PROCURA_VITORIA_TAB_1_COMB_6_FIM_O
PROCURA_VITORIA_TAB_1_COMB_6_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_O
		lea     si, combinacao6
	compare_loop_1_comb_6_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_6_O
			cmp al, ah
			jne endComparacao_1_comb_6_O
		comparacao_nao_interessa_1_comb_6_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_6_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_O], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_6_O:
			jmp		PROCURA_VITORIA_TAB_1_COMB_7_FIM_O
PROCURA_VITORIA_TAB_1_COMB_7_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_O
		lea     si, combinacao7
	compare_loop_1_comb_7_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_7_O
			cmp al, ah
			jne endComparacao_1_comb_7_O
		comparacao_nao_interessa_1_comb_7_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_7_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_O], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_7_O:
			jmp		PROCURA_VITORIA_TAB_1_COMB_8_FIM_O
PROCURA_VITORIA_TAB_1_COMB_8_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro1_O
		lea     si, combinacao8
	compare_loop_1_comb_8_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_1_comb_8_O
			cmp al, ah
			jne endComparacao_1_comb_8_O
		comparacao_nao_interessa_1_comb_8_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_1_comb_8_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [Vitorias_O], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_1
	endComparacao_1_comb_8_O:
			inc		contador1
			mov 	al, contador1
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_1
			jmp		MUDA_JOGADOR

MOSTRA_VITORIAS_MAIN_1:
		mov 	POSx, 55
		mov     POSy, 6
		goto_xy	POSx, POSy
		mov		CL, Car
		cmp		CL, 32		; S� escreve se for espa�o em branco
		JNE     MUDA_JOGADOR

		mov bx, 0
		mov bx, 1070

		MOV AH, BYTE PTR [JogadorAtual]    ; Load the character from the variable into AL
		MOV AL, BYTE PTR [JogadorAtual_Cor]  ; Load the color attribute from the 

		mov es:[bx], ah
		mov es:[bx+1], al		
		
		int		21H
		jmp 	ESCOLHE_COR_TAB_1
ESCOLHE_COR_TAB_1:
		mov 	al, [JogadorAtual]
		cmp 	al, 'X'
		je 		COLOCA_COR_X_TAB_1
		cmp	 	al, 'O'
		je 		COLOCA_COR_O_TAB_1
COLOCA_COR_X_TAB_1:
		mov 	al, 019h
		jmp 	PINTA_FUNDO_TAB_1

COLOCA_COR_O_TAB_1:
		mov 	al, 0EFh 
		jmp 	PINTA_FUNDO_TAB_1
PINTA_FUNDO_TAB_1:
		mov  	bx, 326
		mov 	cx, 7
		MOV     AH, ' '
	ciclo_pinta_linha_1_TAB_1:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_1_TAB_1

		mov  	bx, 486
		mov 	cx, 7
	ciclo_pinta_linha_2_TAB_1:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_2_TAB_1

		mov  	bx, 646
		mov 	cx, 7
	ciclo_pinta_linha_3_TAB_1:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_3_TAB_1	

		jmp 	PROCURA_VITORIA_TOTAL

;############################################### TODA A LOGICA DO TABULEIRO 2 ###############################

PROCURA_VITORIA_TAB_2_INICIO:
			mov     al, POSx
			mov     ah, POSy
			cmp     al, 13
			je      PROCURA_VITORIA_TAB_2_COLUNA_1
			cmp     al, 15
			je      PROCURA_VITORIA_TAB_2_COLUNA_2
			cmp     al, 17
			je      PROCURA_VITORIA_TAB_2_COLUNA_3
			jmp     CICLO
CONFIRMA_EMPATE_TAB_2:
			mov  ax, 0
			mov  al, 1             ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_Gerais+si], al
			jmp 	MUDA_JOGADOR
PROCURA_VITORIA_TAB_2_COLUNA_1:
			cmp     ah, 2
			je      PROCURA_VITORIA_TAB_2_POS_1
			cmp     ah, 3
			je      PROCURA_VITORIA_TAB_2_POS_4
			cmp     ah, 4
			je      PROCURA_VITORIA_TAB_2_POS_7
			jmp     CICLO


PROCURA_VITORIA_TAB_2_POS_1:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 1
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_1_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_1_O
			; MUDAR a combinaçao atual do array


ATUALIZA_ARRAY_TAB_2_ESPACO_1_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro2_X], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_X


ATUALIZA_ARRAY_TAB_2_ESPACO_1_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro2_O], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_O

PROCURA_VITORIA_TAB_2_POS_4:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 4
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_4_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_4_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_2_ESPACO_4_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro2_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_X

ATUALIZA_ARRAY_TAB_2_ESPACO_4_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro2_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_O

PROCURA_VITORIA_TAB_2_POS_7:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 7
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_7_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_7_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_2_ESPACO_7_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro2_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_X

ATUALIZA_ARRAY_TAB_2_ESPACO_7_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro2_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_O

PROCURA_VITORIA_TAB_2_COLUNA_2:
			cmp     ah, 2
			je      PROCURA_VITORIA_TAB_2_POS_2
			cmp     ah, 3
			je      PROCURA_VITORIA_TAB_2_POS_5
			cmp     ah, 4
			je      PROCURA_VITORIA_TAB_2_POS_8
			jmp     CICLO

PROCURA_VITORIA_TAB_2_POS_2:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 2
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_2_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_2_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_2_ESPACO_2_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro2_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_X


ATUALIZA_ARRAY_TAB_2_ESPACO_2_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro2_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_O

PROCURA_VITORIA_TAB_2_POS_5:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 5
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_5_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_5_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_2_ESPACO_5_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro2_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_X


ATUALIZA_ARRAY_TAB_2_ESPACO_5_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro2_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_O

PROCURA_VITORIA_TAB_2_POS_8:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 8
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_8_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_8_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_2_ESPACO_8_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro2_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_X


ATUALIZA_ARRAY_TAB_2_ESPACO_8_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro2_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_O

PROCURA_VITORIA_TAB_2_COLUNA_3:
			cmp     ah, 2
			je      PROCURA_VITORIA_TAB_2_POS_3
			cmp     ah, 3
			je      PROCURA_VITORIA_TAB_2_POS_6
			cmp     ah, 4
			je      PROCURA_VITORIA_TAB_2_POS_9
			jmp     CICLO

PROCURA_VITORIA_TAB_2_POS_3:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 3
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_3_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_3_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_2_ESPACO_3_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro2_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_X


ATUALIZA_ARRAY_TAB_2_ESPACO_3_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro2_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_O

PROCURA_VITORIA_TAB_2_POS_6:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 6
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_6_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_6_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_2_ESPACO_6_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro2_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_X


ATUALIZA_ARRAY_TAB_2_ESPACO_6_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro2_O+si], al 	; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_O


PROCURA_VITORIA_TAB_2_POS_9:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 9
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_9_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_2_ESPACO_9_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_2_ESPACO_9_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro2_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_X


ATUALIZA_ARRAY_TAB_2_ESPACO_9_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro2_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_2_FIM_O

PROCURA_VITORIA_TAB_2_FIM_X:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_2_COMB_1_FIM_X
PROCURA_VITORIA_TAB_2_COMB_1_FIM_X:		
		mov 	cx, 9
		lea 	bx, tabuleiro2_X
		lea     si, combinacao1
	compare_loop_2_comb_1_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_1_X
			cmp al, ah
			jne endComparacao_2_comb_1_X
		comparacao_nao_interessa_2_comb_1_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_1_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_1_X:
			jmp		PROCURA_VITORIA_TAB_2_COMB_2_FIM_X
PROCURA_VITORIA_TAB_2_COMB_2_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_X
		lea     si, combinacao2
	compare_loop_2_comb_2_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_2_X
			cmp al, ah
			jne endComparacao_2_comb_2_X
		comparacao_nao_interessa_2_comb_2_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_2_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_2_X:
			jmp		PROCURA_VITORIA_TAB_2_COMB_3_FIM_X
PROCURA_VITORIA_TAB_2_COMB_3_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_X
		lea     si, combinacao3
	compare_loop_2_comb_3_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_3_X
			cmp al, ah
			jne endComparacao_2_comb_3_X
		comparacao_nao_interessa_2_comb_3_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_3_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_3_X:
			jmp		PROCURA_VITORIA_TAB_2_COMB_4_FIM_X
PROCURA_VITORIA_TAB_2_COMB_4_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_X
		lea     si, combinacao4
	compare_loop_2_comb_4_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_4_X
			cmp al, ah
			jne endComparacao_2_comb_4_X
		comparacao_nao_interessa_2_comb_4_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_4_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_4_X:
			jmp		PROCURA_VITORIA_TAB_2_COMB_5_FIM_X
PROCURA_VITORIA_TAB_2_COMB_5_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_X
		lea     si, combinacao5
	compare_loop_2_comb_5_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_5_X
			cmp al, ah
			jne endComparacao_2_comb_5_X
		comparacao_nao_interessa_2_comb_5_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_5_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_5_X:
			jmp		PROCURA_VITORIA_TAB_2_COMB_6_FIM_X
PROCURA_VITORIA_TAB_2_COMB_6_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_X
		lea     si, combinacao6
	compare_loop_2_comb_6_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_6_X
			cmp al, ah
			jne endComparacao_2_comb_6_X
		comparacao_nao_interessa_2_comb_6_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_6_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_6_X:
			jmp		PROCURA_VITORIA_TAB_2_COMB_7_FIM_X
PROCURA_VITORIA_TAB_2_COMB_7_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_X
		lea     si, combinacao7
	compare_loop_2_comb_7_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_7_X
			cmp al, ah
			jne endComparacao_2_comb_7_X
		comparacao_nao_interessa_2_comb_7_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_7_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_7_X:
			jmp		PROCURA_VITORIA_TAB_2_COMB_8_FIM_X
PROCURA_VITORIA_TAB_2_COMB_8_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_X
		lea     si, combinacao8
	compare_loop_2_comb_8_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_8_X
			cmp al, ah
			jne endComparacao_2_comb_8_X
		comparacao_nao_interessa_2_comb_8_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_8_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_8_X:
			inc		contador2
			mov 	al, contador2
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_2
			jmp		MUDA_JOGADOR

PROCURA_VITORIA_TAB_2_FIM_O:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_2_COMB_1_FIM_O
PROCURA_VITORIA_TAB_2_COMB_1_FIM_O:		
		mov 	cx, 9
		lea 	bx, tabuleiro2_O
		lea     si, combinacao1
	compare_loop_2_comb_1_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_1_O
			cmp al, ah
			jne endComparacao_2_comb_1_O
		comparacao_nao_interessa_2_comb_1_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_1_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_1_O:
			jmp		PROCURA_VITORIA_TAB_2_COMB_2_FIM_O
PROCURA_VITORIA_TAB_2_COMB_2_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_O
		lea     si, combinacao2
	compare_loop_2_comb_2_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_2_O
			cmp al, ah
			jne endComparacao_2_comb_2_O
		comparacao_nao_interessa_2_comb_2_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_2_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_2_O:
			jmp		PROCURA_VITORIA_TAB_2_COMB_3_FIM_O
PROCURA_VITORIA_TAB_2_COMB_3_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_O
		lea     si, combinacao3
	compare_loop_2_comb_3_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_3_O
			cmp al, ah
			jne endComparacao_2_comb_3_O
		comparacao_nao_interessa_2_comb_3_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_3_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_3_O:
			jmp		PROCURA_VITORIA_TAB_2_COMB_4_FIM_O
PROCURA_VITORIA_TAB_2_COMB_4_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_O
		lea     si, combinacao4
	compare_loop_2_comb_4_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_4_O
			cmp al, ah
			jne endComparacao_2_comb_4_O
		comparacao_nao_interessa_2_comb_4_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_4_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_4_O:
			jmp		PROCURA_VITORIA_TAB_2_COMB_5_FIM_O
PROCURA_VITORIA_TAB_2_COMB_5_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_O
		lea     si, combinacao5
	compare_loop_2_comb_5_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_5_O
			cmp al, ah
			jne endComparacao_2_comb_5_O
		comparacao_nao_interessa_2_comb_5_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_5_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_5_O:
			jmp		PROCURA_VITORIA_TAB_2_COMB_6_FIM_O
PROCURA_VITORIA_TAB_2_COMB_6_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_O
		lea     si, combinacao6
	compare_loop_2_comb_6_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_6_O
			cmp al, ah
			jne endComparacao_2_comb_6_O
		comparacao_nao_interessa_2_comb_6_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_6_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_6_O:
			jmp		PROCURA_VITORIA_TAB_2_COMB_7_FIM_O
PROCURA_VITORIA_TAB_2_COMB_7_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_O
		lea     si, combinacao7
	compare_loop_2_comb_7_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_7_O
			cmp al, ah
			jne endComparacao_2_comb_7_O
		comparacao_nao_interessa_2_comb_7_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_7_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_7_O:
			jmp		PROCURA_VITORIA_TAB_2_COMB_8_FIM_O
PROCURA_VITORIA_TAB_2_COMB_8_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro2_O
		lea     si, combinacao8
	compare_loop_2_comb_8_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_2_comb_8_O
			cmp al, ah
			jne endComparacao_2_comb_8_O
		comparacao_nao_interessa_2_comb_8_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_2_comb_8_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_2
	endComparacao_2_comb_8_O:
			inc		contador2
			mov 	al, contador2
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_2
			jmp		MUDA_JOGADOR

MOSTRA_VITORIAS_MAIN_2:
		mov 	POSx, 57
		mov     POSy, 6
		goto_xy	POSx, POSy
		mov		CL, Car
		cmp		CL, 32		; S� escreve se for espa�o em branco
		JNE     MUDA_JOGADOR

		mov bx, 0
		mov bx, 1074

		MOV AH, BYTE PTR [JogadorAtual]    ; Load the character from the variable into AL
		MOV AL, BYTE PTR [JogadorAtual_Cor]  ; Load the color attribute from the 

		mov es:[bx], ah
		mov es:[bx+1], al		
		
		int		21H
		jmp 	ESCOLHE_COR_TAB_2
ESCOLHE_COR_TAB_2:
		mov 	al, [JogadorAtual]
		cmp 	al, 'X'
		je 		COLOCA_COR_X_TAB_2
		cmp	 	al, 'O'
		je 		COLOCA_COR_O_TAB_2
COLOCA_COR_X_TAB_2:
		mov 	al, 019h
		jmp 	PINTA_FUNDO_TAB_2

COLOCA_COR_O_TAB_2:
		mov 	al, 0EFh 
		jmp 	PINTA_FUNDO_TAB_2
PINTA_FUNDO_TAB_2:
		mov  	bx, 344
		mov 	cx, 7
		MOV     AH, ' '
	ciclo_pinta_linha_1_TAB_2:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_1_TAB_2

		mov  	bx, 504
		mov 	cx, 7
	ciclo_pinta_linha_2_TAB_2:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_2_TAB_2

		mov  	bx, 664
		mov 	cx, 7
	ciclo_pinta_linha_3_TAB_2:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_3_TAB_2

		jmp 	PROCURA_VITORIA_TOTAL

;############################################### TODA A LOGICA DO TABULEIRO 3 ###############################

PROCURA_VITORIA_TAB_3_INICIO:
			mov     al, POSx
			mov     ah, POSy
			cmp     al, 22
			je      PROCURA_VITORIA_TAB_3_COLUNA_1
			cmp     al, 24
			je      PROCURA_VITORIA_TAB_3_COLUNA_2
			cmp     al, 26
			je      PROCURA_VITORIA_TAB_3_COLUNA_3
			jmp     CICLO
CONFIRMA_EMPATE_TAB_3:
			mov  ax, 0
			mov  al, 1             ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_Gerais+si], al
			jmp 	MUDA_JOGADOR
PROCURA_VITORIA_TAB_3_COLUNA_1:
			cmp     ah, 2
			je      PROCURA_VITORIA_TAB_3_POS_1
			cmp     ah, 3
			je      PROCURA_VITORIA_TAB_3_POS_4
			cmp     ah, 4
			je      PROCURA_VITORIA_TAB_3_POS_7
			jmp     CICLO


PROCURA_VITORIA_TAB_3_POS_1:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 1
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_1_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_1_O
			; MUDAR a combinaçao atual do array


ATUALIZA_ARRAY_TAB_3_ESPACO_1_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro3_X], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_X


ATUALIZA_ARRAY_TAB_3_ESPACO_1_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro3_O], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_O

PROCURA_VITORIA_TAB_3_POS_4:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 4
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_4_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_4_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_3_ESPACO_4_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro3_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_X

ATUALIZA_ARRAY_TAB_3_ESPACO_4_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro3_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_O

PROCURA_VITORIA_TAB_3_POS_7:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 7
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_7_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_7_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_3_ESPACO_7_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro1_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_X

ATUALIZA_ARRAY_TAB_3_ESPACO_7_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro3_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_O

PROCURA_VITORIA_TAB_3_COLUNA_2:
			cmp     ah, 2
			je      PROCURA_VITORIA_TAB_3_POS_2
			cmp     ah, 3
			je      PROCURA_VITORIA_TAB_3_POS_5
			cmp     ah, 4
			je      PROCURA_VITORIA_TAB_3_POS_8
			jmp     CICLO

PROCURA_VITORIA_TAB_3_POS_2:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 2
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_2_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_2_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_3_ESPACO_2_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro3_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_X


ATUALIZA_ARRAY_TAB_3_ESPACO_2_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro3_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_O

PROCURA_VITORIA_TAB_3_POS_5:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 5
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_5_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_5_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_3_ESPACO_5_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro3_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_X


ATUALIZA_ARRAY_TAB_3_ESPACO_5_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro3_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_O

PROCURA_VITORIA_TAB_3_POS_8:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 8
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_8_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_8_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_3_ESPACO_8_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro3_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_X


ATUALIZA_ARRAY_TAB_3_ESPACO_8_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro3_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_O

PROCURA_VITORIA_TAB_3_COLUNA_3:
			cmp     ah, 2
			je      PROCURA_VITORIA_TAB_3_POS_3
			cmp     ah, 3
			je      PROCURA_VITORIA_TAB_3_POS_6
			cmp     ah, 4
			je      PROCURA_VITORIA_TAB_3_POS_9
			jmp     CICLO

PROCURA_VITORIA_TAB_3_POS_3:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 3
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_3_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_3_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_3_ESPACO_3_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro3_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_X


ATUALIZA_ARRAY_TAB_3_ESPACO_3_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro3_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_O

PROCURA_VITORIA_TAB_3_POS_6:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 6
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_6_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_6_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_3_ESPACO_6_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro3_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_X


ATUALIZA_ARRAY_TAB_3_ESPACO_6_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro3_O+si], al 	; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_O


PROCURA_VITORIA_TAB_3_POS_9:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 9
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_9_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_3_ESPACO_9_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_3_ESPACO_9_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro3_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_X


ATUALIZA_ARRAY_TAB_3_ESPACO_9_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro3_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_3_FIM_O

PROCURA_VITORIA_TAB_3_FIM_X:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_3_COMB_1_FIM_X
PROCURA_VITORIA_TAB_3_COMB_1_FIM_X:		
		mov 	cx, 9
		lea 	bx, tabuleiro3_X
		lea     si, combinacao1
	compare_loop_3_comb_1_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_1_X
			cmp al, ah
			jne endComparacao_3_comb_1_X
		comparacao_nao_interessa_3_comb_1_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_1_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_1_X:
			jmp		PROCURA_VITORIA_TAB_3_COMB_2_FIM_X
PROCURA_VITORIA_TAB_3_COMB_2_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_X
		lea     si, combinacao2
	compare_loop_3_comb_2_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_2_X
			cmp al, ah
			jne endComparacao_3_comb_2_X
		comparacao_nao_interessa_3_comb_2_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_2_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_2_X:
			jmp		PROCURA_VITORIA_TAB_3_COMB_3_FIM_X
PROCURA_VITORIA_TAB_3_COMB_3_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_X
		lea     si, combinacao3
	compare_loop_3_comb_3_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_3_X
			cmp al, ah
			jne endComparacao_3_comb_3_X
		comparacao_nao_interessa_3_comb_3_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_3_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_3_X:
			jmp		PROCURA_VITORIA_TAB_3_COMB_4_FIM_X
PROCURA_VITORIA_TAB_3_COMB_4_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_X
		lea     si, combinacao4
	compare_loop_3_comb_4_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_4_X
			cmp al, ah
			jne endComparacao_3_comb_4_X
		comparacao_nao_interessa_3_comb_4_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_4_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_4_X:
			jmp		PROCURA_VITORIA_TAB_3_COMB_5_FIM_X
PROCURA_VITORIA_TAB_3_COMB_5_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_X
		lea     si, combinacao5
	compare_loop_3_comb_5_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_5_X
			cmp al, ah
			jne endComparacao_3_comb_5_X
		comparacao_nao_interessa_3_comb_5_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_5_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_5_X:
			jmp		PROCURA_VITORIA_TAB_3_COMB_6_FIM_X
PROCURA_VITORIA_TAB_3_COMB_6_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_X
		lea     si, combinacao6
	compare_loop_3_comb_6_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_6_X
			cmp al, ah
			jne endComparacao_3_comb_6_X
		comparacao_nao_interessa_3_comb_6_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_6_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_6_X:
			jmp		PROCURA_VITORIA_TAB_3_COMB_7_FIM_X
PROCURA_VITORIA_TAB_3_COMB_7_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_X
		lea     si, combinacao7
	compare_loop_3_comb_7_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_7_X
			cmp al, ah
			jne endComparacao_3_comb_7_X
		comparacao_nao_interessa_3_comb_7_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_7_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_7_X:
			jmp		PROCURA_VITORIA_TAB_3_COMB_8_FIM_X
PROCURA_VITORIA_TAB_3_COMB_8_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_X
		lea     si, combinacao8
	compare_loop_3_comb_8_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_8_X
			cmp al, ah
			jne endComparacao_3_comb_8_X
		comparacao_nao_interessa_3_comb_8_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_8_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_8_X:
			inc		contador3
			mov 	al, contador3
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_3
			jmp		MUDA_JOGADOR

PROCURA_VITORIA_TAB_3_FIM_O:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_3_COMB_1_FIM_O
PROCURA_VITORIA_TAB_3_COMB_1_FIM_O:		
		mov 	cx, 9
		lea 	bx, tabuleiro3_O
		lea     si, combinacao1
	compare_loop_3_comb_1_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_1_O
			cmp al, ah
			jne endComparacao_3_comb_1_O
		comparacao_nao_interessa_3_comb_1_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_1_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_1_O:
			jmp		PROCURA_VITORIA_TAB_3_COMB_2_FIM_O
PROCURA_VITORIA_TAB_3_COMB_2_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_O
		lea     si, combinacao2
	compare_loop_3_comb_2_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_2_O
			cmp al, ah
			jne endComparacao_3_comb_2_O
		comparacao_nao_interessa_3_comb_2_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_2_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_2_O:
			jmp		PROCURA_VITORIA_TAB_3_COMB_3_FIM_O
PROCURA_VITORIA_TAB_3_COMB_3_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_O
		lea     si, combinacao3
	compare_loop_3_comb_3_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_3_O
			cmp al, ah
			jne endComparacao_3_comb_3_O
		comparacao_nao_interessa_3_comb_3_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_3_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_3_O:
			jmp		PROCURA_VITORIA_TAB_3_COMB_4_FIM_O
PROCURA_VITORIA_TAB_3_COMB_4_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_O
		lea     si, combinacao4
	compare_loop_3_comb_4_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_4_O
			cmp al, ah
			jne endComparacao_3_comb_4_O
		comparacao_nao_interessa_3_comb_4_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_4_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_4_O:
			jmp		PROCURA_VITORIA_TAB_3_COMB_5_FIM_O
PROCURA_VITORIA_TAB_3_COMB_5_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_O
		lea     si, combinacao5
	compare_loop_3_comb_5_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_5_O
			cmp al, ah
			jne endComparacao_3_comb_5_O
		comparacao_nao_interessa_3_comb_5_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_5_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_5_O:
			jmp		PROCURA_VITORIA_TAB_3_COMB_6_FIM_O
PROCURA_VITORIA_TAB_3_COMB_6_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_O
		lea     si, combinacao6
	compare_loop_3_comb_6_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_6_O
			cmp al, ah
			jne endComparacao_3_comb_6_O
		comparacao_nao_interessa_3_comb_6_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_6_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_6_O:
			jmp		PROCURA_VITORIA_TAB_3_COMB_7_FIM_O
PROCURA_VITORIA_TAB_3_COMB_7_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_O
		lea     si, combinacao7
	compare_loop_3_comb_7_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_7_O
			cmp al, ah
			jne endComparacao_3_comb_7_O
		comparacao_nao_interessa_3_comb_7_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_7_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_7_O:
			jmp		PROCURA_VITORIA_TAB_3_COMB_8_FIM_O
PROCURA_VITORIA_TAB_3_COMB_8_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro3_O
		lea     si, combinacao8
	compare_loop_3_comb_8_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_3_comb_8_O
			cmp al, ah
			jne endComparacao_3_comb_8_O
		comparacao_nao_interessa_3_comb_8_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_3_comb_8_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_3
	endComparacao_3_comb_8_O:
			inc		contador3
			mov 	al, contador3
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_3
			jmp		MUDA_JOGADOR

MOSTRA_VITORIAS_MAIN_3:
		mov 	POSx, 59
		mov     POSy, 6
		goto_xy	POSx, POSy
		mov		CL, Car
		cmp		CL, 32		; S� escreve se for espa�o em branco
		JNE     MUDA_JOGADOR

		mov bx, 0
		mov bx, 1078

		MOV AH, BYTE PTR [JogadorAtual]    ; Load the character from the variable into AL
		MOV AL, BYTE PTR [JogadorAtual_Cor]  ; Load the color attribute from the 

		mov es:[bx], ah
		mov es:[bx+1], al		
		
		int		21H	
		jmp 	ESCOLHE_COR_TAB_3
ESCOLHE_COR_TAB_3:
		mov 	al, [JogadorAtual]
		cmp 	al, 'X'
		je 		COLOCA_COR_X_TAB_3
		cmp	 	al, 'O'
		je 		COLOCA_COR_O_TAB_3
COLOCA_COR_X_TAB_3:
		mov 	al, 019h
		jmp 	PINTA_FUNDO_TAB_3

COLOCA_COR_O_TAB_3:
		mov 	al, 0EFh 
		jmp 	PINTA_FUNDO_TAB_3
PINTA_FUNDO_TAB_3:
		mov  	bx, 362
		mov 	cx, 7
		MOV     AH, ' ' 
	ciclo_pinta_linha_1_TAB_3:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_1_TAB_3

		mov  	bx, 522
		mov 	cx, 7
	ciclo_pinta_linha_2_TAB_3:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_2_TAB_3

		mov  	bx, 682
		mov 	cx, 7
	ciclo_pinta_linha_3_TAB_3:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_3_TAB_3

		jmp 	PROCURA_VITORIA_TOTAL

;############################################ TODA A LOGICA DO TABULEIRO 4 #############################
PROCURA_VITORIA_TAB_4_INICIO:
			mov     al, POSx
			mov     ah, POSy
			cmp     al, 4
			je      PROCURA_VITORIA_TAB_4_COLUNA_1
			cmp     al, 6
			je      PROCURA_VITORIA_TAB_4_COLUNA_2
			cmp     al, 8
			je      PROCURA_VITORIA_TAB_4_COLUNA_3
			jmp     CICLO
CONFIRMA_EMPATE_TAB_4:
			mov  ax, 0
			mov  al, 1             ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_Gerais+si], al
			jmp 	MUDA_JOGADOR
PROCURA_VITORIA_TAB_4_COLUNA_1:
			cmp     ah, 6
			je      PROCURA_VITORIA_TAB_4_POS_1
			cmp     ah, 7
			je      PROCURA_VITORIA_TAB_4_POS_4
			cmp     ah, 8
			je      PROCURA_VITORIA_TAB_4_POS_7
			jmp     CICLO


PROCURA_VITORIA_TAB_4_POS_1:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 1
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_1_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_1_O
			; MUDAR a combinaçao atual do array


ATUALIZA_ARRAY_TAB_4_ESPACO_1_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro4_X], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_X


ATUALIZA_ARRAY_TAB_4_ESPACO_1_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro4_O], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_O

PROCURA_VITORIA_TAB_4_POS_4:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 4
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_4_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_4_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_4_ESPACO_4_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro4_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_X

ATUALIZA_ARRAY_TAB_4_ESPACO_4_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro4_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_O

PROCURA_VITORIA_TAB_4_POS_7:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 7
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_7_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_7_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_4_ESPACO_7_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro4_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_X

ATUALIZA_ARRAY_TAB_4_ESPACO_7_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro4_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_O

PROCURA_VITORIA_TAB_4_COLUNA_2:
			cmp     ah, 6
			je      PROCURA_VITORIA_TAB_4_POS_2
			cmp     ah, 7
			je      PROCURA_VITORIA_TAB_4_POS_5
			cmp     ah, 8
			je      PROCURA_VITORIA_TAB_4_POS_8
			jmp     CICLO

PROCURA_VITORIA_TAB_4_POS_2:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 2
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_2_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_2_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_4_ESPACO_2_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro4_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_X


ATUALIZA_ARRAY_TAB_4_ESPACO_2_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro4_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_O

PROCURA_VITORIA_TAB_4_POS_5:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 5
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_5_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_5_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_4_ESPACO_5_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro4_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_X


ATUALIZA_ARRAY_TAB_4_ESPACO_5_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro4_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_O

PROCURA_VITORIA_TAB_4_POS_8:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 8
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_8_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_8_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_4_ESPACO_8_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro4_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_X


ATUALIZA_ARRAY_TAB_4_ESPACO_8_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro4_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_O

PROCURA_VITORIA_TAB_4_COLUNA_3:
			cmp     ah, 6
			je      PROCURA_VITORIA_TAB_4_POS_3
			cmp     ah, 7
			je      PROCURA_VITORIA_TAB_4_POS_6
			cmp     ah, 8
			je      PROCURA_VITORIA_TAB_4_POS_9
			jmp     CICLO

PROCURA_VITORIA_TAB_4_POS_3:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 3
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_3_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_3_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_4_ESPACO_3_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro4_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_X


ATUALIZA_ARRAY_TAB_4_ESPACO_3_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro4_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_O

PROCURA_VITORIA_TAB_4_POS_6:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 6
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_6_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_6_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_4_ESPACO_6_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro4_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_X


ATUALIZA_ARRAY_TAB_4_ESPACO_6_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro4_O+si], al 	; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_O


PROCURA_VITORIA_TAB_4_POS_9:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 9
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_9_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_4_ESPACO_9_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_4_ESPACO_9_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro4_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_X


ATUALIZA_ARRAY_TAB_4_ESPACO_9_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro4_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_4_FIM_O

PROCURA_VITORIA_TAB_4_FIM_X:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_4_COMB_1_FIM_X
PROCURA_VITORIA_TAB_4_COMB_1_FIM_X:		
		mov 	cx, 9
		lea 	bx, tabuleiro4_X
		lea     si, combinacao1
	compare_loop_4_comb_1_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_1_X
			cmp al, ah
			jne endComparacao_4_comb_1_X
		comparacao_nao_interessa_4_comb_1_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_1_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_1_X:
			jmp		PROCURA_VITORIA_TAB_4_COMB_2_FIM_X
PROCURA_VITORIA_TAB_4_COMB_2_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_X
		lea     si, combinacao2
	compare_loop_4_comb_2_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_2_X
			cmp al, ah
			jne endComparacao_4_comb_2_X
		comparacao_nao_interessa_4_comb_2_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_2_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_2_X:
			jmp		PROCURA_VITORIA_TAB_4_COMB_3_FIM_X
PROCURA_VITORIA_TAB_4_COMB_3_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_X
		lea     si, combinacao3
	compare_loop_4_comb_3_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_3_X
			cmp al, ah
			jne endComparacao_4_comb_3_X
		comparacao_nao_interessa_4_comb_3_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_3_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_3_X:
			jmp		PROCURA_VITORIA_TAB_4_COMB_4_FIM_X
PROCURA_VITORIA_TAB_4_COMB_4_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_X
		lea     si, combinacao4
	compare_loop_4_comb_4_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_4_X
			cmp al, ah
			jne endComparacao_4_comb_4_X
		comparacao_nao_interessa_4_comb_4_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_4_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_4_X:
			jmp		PROCURA_VITORIA_TAB_4_COMB_5_FIM_X
PROCURA_VITORIA_TAB_4_COMB_5_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_X
		lea     si, combinacao5
	compare_loop_4_comb_5_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_5_X
			cmp al, ah
			jne endComparacao_4_comb_5_X
		comparacao_nao_interessa_4_comb_5_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_5_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_5_X:
			jmp		PROCURA_VITORIA_TAB_4_COMB_6_FIM_X
PROCURA_VITORIA_TAB_4_COMB_6_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_X
		lea     si, combinacao6
	compare_loop_4_comb_6_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_6_X
			cmp al, ah
			jne endComparacao_4_comb_6_X
		comparacao_nao_interessa_4_comb_6_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_6_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_6_X:
			jmp		PROCURA_VITORIA_TAB_4_COMB_7_FIM_X
PROCURA_VITORIA_TAB_4_COMB_7_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_X
		lea     si, combinacao7
	compare_loop_4_comb_7_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_7_X
			cmp al, ah
			jne endComparacao_4_comb_7_X
		comparacao_nao_interessa_4_comb_7_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_7_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_7_X:
			jmp		PROCURA_VITORIA_TAB_4_COMB_8_FIM_X
PROCURA_VITORIA_TAB_4_COMB_8_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_X
		lea     si, combinacao8
	compare_loop_4_comb_8_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_8_X
			cmp al, ah
			jne endComparacao_4_comb_8_X
		comparacao_nao_interessa_4_comb_8_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_8_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_8_X:
			inc		contador4
			mov 	al, contador4
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_4
			jmp		MUDA_JOGADOR

PROCURA_VITORIA_TAB_4_FIM_O:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_4_COMB_1_FIM_O
PROCURA_VITORIA_TAB_4_COMB_1_FIM_O:		
		mov 	cx, 9
		lea 	bx, tabuleiro4_O
		lea     si, combinacao1
	compare_loop_4_comb_1_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_1_O
			cmp al, ah
			jne endComparacao_4_comb_1_O
		comparacao_nao_interessa_4_comb_1_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_1_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_1_O:
			jmp		PROCURA_VITORIA_TAB_4_COMB_2_FIM_O
PROCURA_VITORIA_TAB_4_COMB_2_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_O
		lea     si, combinacao2
	compare_loop_4_comb_2_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_2_O
			cmp al, ah
			jne endComparacao_4_comb_2_O
		comparacao_nao_interessa_4_comb_2_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_2_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_2_O:
			jmp		PROCURA_VITORIA_TAB_4_COMB_3_FIM_O
PROCURA_VITORIA_TAB_4_COMB_3_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_O
		lea     si, combinacao3
	compare_loop_4_comb_3_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_3_O
			cmp al, ah
			jne endComparacao_4_comb_3_O
		comparacao_nao_interessa_4_comb_3_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_3_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_3_O:
			jmp		PROCURA_VITORIA_TAB_4_COMB_4_FIM_O
PROCURA_VITORIA_TAB_4_COMB_4_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_O
		lea     si, combinacao4
	compare_loop_4_comb_4_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_4_O
			cmp al, ah
			jne endComparacao_4_comb_4_O
		comparacao_nao_interessa_4_comb_4_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_4_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_4_O:
			jmp		PROCURA_VITORIA_TAB_4_COMB_5_FIM_O
PROCURA_VITORIA_TAB_4_COMB_5_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_O
		lea     si, combinacao5
	compare_loop_4_comb_5_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_5_O
			cmp al, ah
			jne endComparacao_4_comb_5_O
		comparacao_nao_interessa_4_comb_5_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_5_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_5_O:
			jmp		PROCURA_VITORIA_TAB_4_COMB_6_FIM_O
PROCURA_VITORIA_TAB_4_COMB_6_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_O
		lea     si, combinacao6
	compare_loop_4_comb_6_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_6_O
			cmp al, ah
			jne endComparacao_4_comb_6_O
		comparacao_nao_interessa_4_comb_6_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_6_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_6_O:
			jmp		PROCURA_VITORIA_TAB_4_COMB_7_FIM_O
PROCURA_VITORIA_TAB_4_COMB_7_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_O
		lea     si, combinacao7
	compare_loop_4_comb_7_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_7_O
			cmp al, ah
			jne endComparacao_4_comb_7_O
		comparacao_nao_interessa_4_comb_7_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_7_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_7_O:
			jmp		PROCURA_VITORIA_TAB_4_COMB_8_FIM_O
PROCURA_VITORIA_TAB_4_COMB_8_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro4_O
		lea     si, combinacao8
	compare_loop_4_comb_8_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_4_comb_8_O
			cmp al, ah
			jne endComparacao_4_comb_8_O
		comparacao_nao_interessa_4_comb_8_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_4_comb_8_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_4
	endComparacao_4_comb_8_O:
			inc		contador4
			mov 	al, contador4
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_4
			jmp		MUDA_JOGADOR

MOSTRA_VITORIAS_MAIN_4:
		mov 	POSx, 55
		mov     POSy, 7
		goto_xy	POSx, POSy
		mov		CL, Car
		cmp		CL, 32		; S� escreve se for espa�o em branco
		JNE     MUDA_JOGADOR

		mov bx, 0
		mov bx, 1230

		MOV AH, BYTE PTR [JogadorAtual]    ; Load the character from the variable into AL
		MOV AL, BYTE PTR [JogadorAtual_Cor]  ; Load the color attribute from the 

		mov es:[bx], ah
		mov es:[bx+1], al		
		
		int		21H		
		jmp 	ESCOLHE_COR_TAB_4
ESCOLHE_COR_TAB_4:
		mov 	al, [JogadorAtual]
		cmp 	al, 'X'
		je 		COLOCA_COR_X_TAB_4
		cmp	 	al, 'O'
		je 		COLOCA_COR_O_TAB_4
COLOCA_COR_X_TAB_4:
		mov 	al, 019h
		jmp 	PINTA_FUNDO_TAB_4

COLOCA_COR_O_TAB_4:
		mov 	al, 0EFh 
		jmp 	PINTA_FUNDO_TAB_4
PINTA_FUNDO_TAB_4:
		mov  	bx, 966
		mov 	cx, 7
		MOV     AH, ' '
	ciclo_pinta_linha_1_TAB_4:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_1_TAB_4

		mov  	bx, 1126
		mov 	cx, 7
	ciclo_pinta_linha_2_TAB_4:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_2_TAB_4

		mov  	bx, 1286
		mov 	cx, 7
	ciclo_pinta_linha_3_TAB_4:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_3_TAB_4	
		jmp 	PROCURA_VITORIA_TOTAL

;############################################ TODA A LOGICA DO TABULEIRO 5 #############################
PROCURA_VITORIA_TAB_5_INICIO:
			mov     al, POSx
			mov     ah, POSy
			cmp     al, 13
			je      PROCURA_VITORIA_TAB_5_COLUNA_1
			cmp     al, 15
			je      PROCURA_VITORIA_TAB_5_COLUNA_2
			cmp     al, 17
			je      PROCURA_VITORIA_TAB_5_COLUNA_3
			jmp     CICLO
CONFIRMA_EMPATE_TAB_5:
			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_Gerais+si], al
			jmp 	MUDA_JOGADOR
PROCURA_VITORIA_TAB_5_COLUNA_1:
			cmp     ah, 6
			je      PROCURA_VITORIA_TAB_5_POS_1
			cmp     ah, 7
			je      PROCURA_VITORIA_TAB_5_POS_4
			cmp     ah, 8
			je      PROCURA_VITORIA_TAB_5_POS_7
			jmp     CICLO


PROCURA_VITORIA_TAB_5_POS_1:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 1
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_1_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_1_O
			; MUDAR a combinaçao atual do array


ATUALIZA_ARRAY_TAB_5_ESPACO_1_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro5_X], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_X


ATUALIZA_ARRAY_TAB_5_ESPACO_1_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro5_O], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_O

PROCURA_VITORIA_TAB_5_POS_4:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 4
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_4_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_4_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_5_ESPACO_4_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro5_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_X

ATUALIZA_ARRAY_TAB_5_ESPACO_4_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro5_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_O

PROCURA_VITORIA_TAB_5_POS_7:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 7
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_7_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_7_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_5_ESPACO_7_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro5_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_X

ATUALIZA_ARRAY_TAB_5_ESPACO_7_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro5_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_O

PROCURA_VITORIA_TAB_5_COLUNA_2:
			cmp     ah, 6
			je      PROCURA_VITORIA_TAB_5_POS_2
			cmp     ah, 7
			je      PROCURA_VITORIA_TAB_5_POS_5
			cmp     ah, 8
			je      PROCURA_VITORIA_TAB_5_POS_8
			jmp     CICLO

PROCURA_VITORIA_TAB_5_POS_2:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 2
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_2_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_2_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_5_ESPACO_2_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro5_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_X


ATUALIZA_ARRAY_TAB_5_ESPACO_2_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro5_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_O

PROCURA_VITORIA_TAB_5_POS_5:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 5
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_5_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_5_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_5_ESPACO_5_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro5_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_X


ATUALIZA_ARRAY_TAB_5_ESPACO_5_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro5_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_O

PROCURA_VITORIA_TAB_5_POS_8:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 8
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_8_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_8_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_5_ESPACO_8_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro5_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_X


ATUALIZA_ARRAY_TAB_5_ESPACO_8_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro5_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_O

PROCURA_VITORIA_TAB_5_COLUNA_3:
			cmp     ah, 6
			je      PROCURA_VITORIA_TAB_5_POS_3
			cmp     ah, 7
			je      PROCURA_VITORIA_TAB_5_POS_6
			cmp     ah, 8
			je      PROCURA_VITORIA_TAB_5_POS_9
			jmp     CICLO

PROCURA_VITORIA_TAB_5_POS_3:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 3
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_3_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_3_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_5_ESPACO_3_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro5_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_X


ATUALIZA_ARRAY_TAB_5_ESPACO_3_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro5_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_O

PROCURA_VITORIA_TAB_5_POS_6:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 6
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_6_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_6_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_5_ESPACO_6_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro5_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_X


ATUALIZA_ARRAY_TAB_5_ESPACO_6_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro5_O+si], al 	; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_O


PROCURA_VITORIA_TAB_5_POS_9:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 9
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_9_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_5_ESPACO_9_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_5_ESPACO_9_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro5_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_X


ATUALIZA_ARRAY_TAB_5_ESPACO_9_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro5_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_5_FIM_O

PROCURA_VITORIA_TAB_5_FIM_X:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_5_COMB_1_FIM_X
PROCURA_VITORIA_TAB_5_COMB_1_FIM_X:		
		mov 	cx, 9
		lea 	bx, tabuleiro5_X
		lea     si, combinacao1
	compare_loop_5_comb_1_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_1_X
			cmp al, ah
			jne endComparacao_5_comb_1_X
		comparacao_nao_interessa_5_comb_1_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_1_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_1_X:
			jmp		PROCURA_VITORIA_TAB_5_COMB_2_FIM_X
PROCURA_VITORIA_TAB_5_COMB_2_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_X
		lea     si, combinacao2
	compare_loop_5_comb_2_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_2_X
			cmp al, ah
			jne endComparacao_5_comb_2_X
		comparacao_nao_interessa_5_comb_2_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_2_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_2_X:
			jmp		PROCURA_VITORIA_TAB_5_COMB_3_FIM_X
PROCURA_VITORIA_TAB_5_COMB_3_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_X
		lea     si, combinacao3
	compare_loop_5_comb_3_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_3_X
			cmp al, ah
			jne endComparacao_5_comb_3_X
		comparacao_nao_interessa_5_comb_3_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_3_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_3_X:
			jmp		PROCURA_VITORIA_TAB_5_COMB_4_FIM_X
PROCURA_VITORIA_TAB_5_COMB_4_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_X
		lea     si, combinacao4
	compare_loop_5_comb_4_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_4_X
			cmp al, ah
			jne endComparacao_5_comb_4_X
		comparacao_nao_interessa_5_comb_4_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_4_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_4_X:
			jmp		PROCURA_VITORIA_TAB_5_COMB_5_FIM_X
PROCURA_VITORIA_TAB_5_COMB_5_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_X
		lea     si, combinacao5
	compare_loop_5_comb_5_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_5_X
			cmp al, ah
			jne endComparacao_5_comb_5_X
		comparacao_nao_interessa_5_comb_5_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_5_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_5_X:
			jmp		PROCURA_VITORIA_TAB_5_COMB_6_FIM_X
PROCURA_VITORIA_TAB_5_COMB_6_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_X
		lea     si, combinacao6
	compare_loop_5_comb_6_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_6_X
			cmp al, ah
			jne endComparacao_5_comb_6_X
		comparacao_nao_interessa_5_comb_6_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_6_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_6_X:
			jmp		PROCURA_VITORIA_TAB_5_COMB_7_FIM_X
PROCURA_VITORIA_TAB_5_COMB_7_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_X
		lea     si, combinacao7
	compare_loop_5_comb_7_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_7_X
			cmp al, ah
			jne endComparacao_5_comb_7_X
		comparacao_nao_interessa_5_comb_7_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_7_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_7_X:
			jmp		PROCURA_VITORIA_TAB_5_COMB_8_FIM_X
PROCURA_VITORIA_TAB_5_COMB_8_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_X
		lea     si, combinacao8
	compare_loop_5_comb_8_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_8_X
			cmp al, ah
			jne endComparacao_5_comb_8_X
		comparacao_nao_interessa_5_comb_8_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_8_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_8_X:
			inc		contador5
			mov 	al, contador5
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_5
			jmp		MUDA_JOGADOR

PROCURA_VITORIA_TAB_5_FIM_O:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_5_COMB_1_FIM_O
PROCURA_VITORIA_TAB_5_COMB_1_FIM_O:		
		mov 	cx, 9
		lea 	bx, tabuleiro5_O
		lea     si, combinacao1
	compare_loop_5_comb_1_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_1_O
			cmp al, ah
			jne endComparacao_5_comb_1_O
		comparacao_nao_interessa_5_comb_1_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_1_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_1_O:
			jmp		PROCURA_VITORIA_TAB_5_COMB_2_FIM_O
PROCURA_VITORIA_TAB_5_COMB_2_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_O
		lea     si, combinacao2
	compare_loop_5_comb_2_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_2_O
			cmp al, ah
			jne endComparacao_5_comb_2_O
		comparacao_nao_interessa_5_comb_2_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_2_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_2_O:
			jmp		PROCURA_VITORIA_TAB_5_COMB_3_FIM_O
PROCURA_VITORIA_TAB_5_COMB_3_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_O
		lea     si, combinacao3
	compare_loop_5_comb_3_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_3_O
			cmp al, ah
			jne endComparacao_5_comb_3_O
		comparacao_nao_interessa_5_comb_3_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_3_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_3_O:
			jmp		PROCURA_VITORIA_TAB_5_COMB_4_FIM_O
PROCURA_VITORIA_TAB_5_COMB_4_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_O
		lea     si, combinacao4
	compare_loop_5_comb_4_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_4_O
			cmp al, ah
			jne endComparacao_5_comb_4_O
		comparacao_nao_interessa_5_comb_4_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_4_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_4_O:
			jmp		PROCURA_VITORIA_TAB_5_COMB_5_FIM_O
PROCURA_VITORIA_TAB_5_COMB_5_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_O
		lea     si, combinacao5
	compare_loop_5_comb_5_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_5_O
			cmp al, ah
			jne endComparacao_5_comb_5_O
		comparacao_nao_interessa_5_comb_5_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_5_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_5_O:
			jmp		PROCURA_VITORIA_TAB_5_COMB_6_FIM_O
PROCURA_VITORIA_TAB_5_COMB_6_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_O
		lea     si, combinacao6
	compare_loop_5_comb_6_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_6_O
			cmp al, ah
			jne endComparacao_5_comb_6_O
		comparacao_nao_interessa_5_comb_6_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_6_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_6_O:
			jmp		PROCURA_VITORIA_TAB_5_COMB_7_FIM_O
PROCURA_VITORIA_TAB_5_COMB_7_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_O
		lea     si, combinacao7
	compare_loop_5_comb_7_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_7_O
			cmp al, ah
			jne endComparacao_5_comb_7_O
		comparacao_nao_interessa_5_comb_7_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_7_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_7_O:
			jmp		PROCURA_VITORIA_TAB_5_COMB_8_FIM_O
PROCURA_VITORIA_TAB_5_COMB_8_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro5_O
		lea     si, combinacao8
	compare_loop_5_comb_8_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_5_comb_8_O
			cmp al, ah
			jne endComparacao_5_comb_8_O
		comparacao_nao_interessa_5_comb_8_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_5_comb_8_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_5
	endComparacao_5_comb_8_O:
			inc		contador5
			mov 	al, contador5
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_5
			jmp		MUDA_JOGADOR

MOSTRA_VITORIAS_MAIN_5:
		mov 	POSx, 57
		mov     POSy, 7
		goto_xy	POSx, POSy
		mov		CL, Car
		cmp		CL, 32		; S� escreve se for espa�o em branco
		JNE     MUDA_JOGADOR

		mov bx, 0
		mov bx, 1234

		MOV AH, BYTE PTR [JogadorAtual]    ; Load the character from the variable into AL
		MOV AL, BYTE PTR [JogadorAtual_Cor]  ; Load the color attribute from the 

		mov es:[bx], ah
		mov es:[bx+1], al		
		
		int		21H		
		jmp 	ESCOLHE_COR_TAB_5
ESCOLHE_COR_TAB_5:
		mov 	al, [JogadorAtual]
		cmp 	al, 'X'
		je 		COLOCA_COR_X_TAB_5
		cmp	 	al, 'O'
		je 		COLOCA_COR_O_TAB_5
COLOCA_COR_X_TAB_5:
		mov 	al, 019h
		jmp 	PINTA_FUNDO_TAB_5

COLOCA_COR_O_TAB_5:
		mov 	al, 0EFh 
		jmp 	PINTA_FUNDO_TAB_5
PINTA_FUNDO_TAB_5:
		mov  	bx, 984
		mov 	cx, 7
		MOV     AH, ' '
	ciclo_pinta_linha_1_TAB_5:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_1_TAB_5

		mov  	bx, 1144
		mov 	cx, 7
	ciclo_pinta_linha_2_TAB_5:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_2_TAB_5

		mov  	bx, 1304
		mov 	cx, 7
	ciclo_pinta_linha_3_TAB_5:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_3_TAB_5
		jmp 	PROCURA_VITORIA_TOTAL

;############################################ TODA A LOGICA DO TABULEIRO 6 #############################
PROCURA_VITORIA_TAB_6_INICIO:
			mov     al, POSx
			mov     ah, POSy
			cmp     al, 22
			je      PROCURA_VITORIA_TAB_6_COLUNA_1
			cmp     al, 24
			je      PROCURA_VITORIA_TAB_6_COLUNA_2
			cmp     al, 26
			je      PROCURA_VITORIA_TAB_6_COLUNA_3
			jmp     CICLO
CONFIRMA_EMPATE_TAB_6:
			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_Gerais+si], al
			jmp 	MUDA_JOGADOR
PROCURA_VITORIA_TAB_6_COLUNA_1:
			cmp     ah, 6
			je      PROCURA_VITORIA_TAB_6_POS_1
			cmp     ah, 7
			je      PROCURA_VITORIA_TAB_6_POS_4
			cmp     ah, 8
			je      PROCURA_VITORIA_TAB_6_POS_7
			jmp     CICLO


PROCURA_VITORIA_TAB_6_POS_1:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 1
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_1_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_1_O
			; MUDAR a combinaçao atual do array


ATUALIZA_ARRAY_TAB_6_ESPACO_1_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro6_X], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_X


ATUALIZA_ARRAY_TAB_6_ESPACO_1_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro6_O], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_O

PROCURA_VITORIA_TAB_6_POS_4:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 4
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_4_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_4_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_6_ESPACO_4_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro6_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_X

ATUALIZA_ARRAY_TAB_6_ESPACO_4_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro6_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_O

PROCURA_VITORIA_TAB_6_POS_7:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 7
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_7_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_7_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_6_ESPACO_7_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro6_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_X

ATUALIZA_ARRAY_TAB_6_ESPACO_7_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro6_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_O

PROCURA_VITORIA_TAB_6_COLUNA_2:
			cmp     ah, 6
			je      PROCURA_VITORIA_TAB_6_POS_2
			cmp     ah, 7
			je      PROCURA_VITORIA_TAB_6_POS_5
			cmp     ah, 8
			je      PROCURA_VITORIA_TAB_6_POS_8
			jmp     CICLO

PROCURA_VITORIA_TAB_6_POS_2:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 2
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_2_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_2_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_6_ESPACO_2_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro6_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_X


ATUALIZA_ARRAY_TAB_6_ESPACO_2_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro6_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_O

PROCURA_VITORIA_TAB_6_POS_5:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 5
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_5_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_5_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_6_ESPACO_5_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro6_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_X


ATUALIZA_ARRAY_TAB_6_ESPACO_5_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro6_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_O

PROCURA_VITORIA_TAB_6_POS_8:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 8
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_8_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_8_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_6_ESPACO_8_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro6_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_X


ATUALIZA_ARRAY_TAB_6_ESPACO_8_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro6_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_O

PROCURA_VITORIA_TAB_6_COLUNA_3:
			cmp     ah, 6
			je      PROCURA_VITORIA_TAB_6_POS_3
			cmp     ah, 7
			je      PROCURA_VITORIA_TAB_6_POS_6
			cmp     ah, 8
			je      PROCURA_VITORIA_TAB_6_POS_9
			jmp     CICLO

PROCURA_VITORIA_TAB_6_POS_3:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 3
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_3_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_3_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_6_ESPACO_3_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro6_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_X


ATUALIZA_ARRAY_TAB_6_ESPACO_3_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro6_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_O

PROCURA_VITORIA_TAB_6_POS_6:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 6
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_6_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_6_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_6_ESPACO_6_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro6_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_X


ATUALIZA_ARRAY_TAB_6_ESPACO_6_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro6_O+si], al 	; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_O


PROCURA_VITORIA_TAB_6_POS_9:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 9
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_9_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_6_ESPACO_9_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_6_ESPACO_9_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro6_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_X


ATUALIZA_ARRAY_TAB_6_ESPACO_9_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro6_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_6_FIM_O

PROCURA_VITORIA_TAB_6_FIM_X:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_6_COMB_1_FIM_X
PROCURA_VITORIA_TAB_6_COMB_1_FIM_X:		
		mov 	cx, 9
		lea 	bx, tabuleiro6_X
		lea     si, combinacao1
	compare_loop_6_comb_1_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_1_X
			cmp al, ah
			jne endComparacao_6_comb_1_X
		comparacao_nao_interessa_6_comb_1_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_1_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_1_X:
			jmp		PROCURA_VITORIA_TAB_6_COMB_2_FIM_X
PROCURA_VITORIA_TAB_6_COMB_2_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_X
		lea     si, combinacao2
	compare_loop_6_comb_2_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_2_X
			cmp al, ah
			jne endComparacao_6_comb_2_X
		comparacao_nao_interessa_6_comb_2_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_2_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_2_X:
			jmp		PROCURA_VITORIA_TAB_6_COMB_3_FIM_X
PROCURA_VITORIA_TAB_6_COMB_3_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_X
		lea     si, combinacao3
	compare_loop_6_comb_3_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_3_X
			cmp al, ah
			jne endComparacao_6_comb_3_X
		comparacao_nao_interessa_6_comb_3_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_3_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_3_X:
			jmp		PROCURA_VITORIA_TAB_6_COMB_4_FIM_X
PROCURA_VITORIA_TAB_6_COMB_4_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_X
		lea     si, combinacao4
	compare_loop_6_comb_4_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_4_X
			cmp al, ah
			jne endComparacao_6_comb_4_X
		comparacao_nao_interessa_6_comb_4_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_4_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_4_X:
			jmp		PROCURA_VITORIA_TAB_6_COMB_5_FIM_X
PROCURA_VITORIA_TAB_6_COMB_5_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_X
		lea     si, combinacao5
	compare_loop_6_comb_5_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_5_X
			cmp al, ah
			jne endComparacao_6_comb_5_X
		comparacao_nao_interessa_6_comb_5_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_5_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_5_X:
			jmp		PROCURA_VITORIA_TAB_6_COMB_6_FIM_X
PROCURA_VITORIA_TAB_6_COMB_6_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_X
		lea     si, combinacao6
	compare_loop_6_comb_6_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_6_X
			cmp al, ah
			jne endComparacao_6_comb_6_X
		comparacao_nao_interessa_6_comb_6_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_6_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_6_X:
			jmp		PROCURA_VITORIA_TAB_6_COMB_7_FIM_X
PROCURA_VITORIA_TAB_6_COMB_7_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_X
		lea     si, combinacao7
	compare_loop_6_comb_7_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_7_X
			cmp al, ah
			jne endComparacao_6_comb_7_X
		comparacao_nao_interessa_6_comb_7_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_7_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_7_X:
			jmp		PROCURA_VITORIA_TAB_6_COMB_8_FIM_X
PROCURA_VITORIA_TAB_6_COMB_8_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_X
		lea     si, combinacao8
	compare_loop_6_comb_8_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_8_X
			cmp al, ah
			jne endComparacao_6_comb_8_X
		comparacao_nao_interessa_6_comb_8_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_8_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_8_X:
			inc		contador6
			mov 	al, contador6
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_6
			jmp		MUDA_JOGADOR

PROCURA_VITORIA_TAB_6_FIM_O:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_6_COMB_1_FIM_O
PROCURA_VITORIA_TAB_6_COMB_1_FIM_O:		
		mov 	cx, 9
		lea 	bx, tabuleiro6_O
		lea     si, combinacao1
	compare_loop_6_comb_1_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_1_O
			cmp al, ah
			jne endComparacao_6_comb_1_O
		comparacao_nao_interessa_6_comb_1_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_1_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_1_O:
			jmp		PROCURA_VITORIA_TAB_6_COMB_2_FIM_O
PROCURA_VITORIA_TAB_6_COMB_2_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_O
		lea     si, combinacao2
	compare_loop_6_comb_2_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_2_O
			cmp al, ah
			jne endComparacao_6_comb_2_O
		comparacao_nao_interessa_6_comb_2_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_2_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_2_O:
			jmp		PROCURA_VITORIA_TAB_6_COMB_3_FIM_O
PROCURA_VITORIA_TAB_6_COMB_3_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_O
		lea     si, combinacao3
	compare_loop_6_comb_3_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_3_O
			cmp al, ah
			jne endComparacao_6_comb_3_O
		comparacao_nao_interessa_6_comb_3_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_3_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_3_O:
			jmp		PROCURA_VITORIA_TAB_6_COMB_4_FIM_O
PROCURA_VITORIA_TAB_6_COMB_4_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_O
		lea     si, combinacao4
	compare_loop_6_comb_4_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_4_O
			cmp al, ah
			jne endComparacao_6_comb_4_O
		comparacao_nao_interessa_6_comb_4_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_4_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_4_O:
			jmp		PROCURA_VITORIA_TAB_6_COMB_5_FIM_O
PROCURA_VITORIA_TAB_6_COMB_5_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_O
		lea     si, combinacao5
	compare_loop_6_comb_5_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_5_O
			cmp al, ah
			jne endComparacao_6_comb_5_O
		comparacao_nao_interessa_6_comb_5_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_5_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_5_O:
			jmp		PROCURA_VITORIA_TAB_6_COMB_6_FIM_O
PROCURA_VITORIA_TAB_6_COMB_6_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_O
		lea     si, combinacao6
	compare_loop_6_comb_6_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_6_O
			cmp al, ah
			jne endComparacao_6_comb_6_O
		comparacao_nao_interessa_6_comb_6_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_6_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_6_O:
			jmp		PROCURA_VITORIA_TAB_6_COMB_7_FIM_O
PROCURA_VITORIA_TAB_6_COMB_7_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_O
		lea     si, combinacao7
	compare_loop_6_comb_7_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_7_O
			cmp al, ah
			jne endComparacao_6_comb_7_O
		comparacao_nao_interessa_6_comb_7_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_7_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_7_O:
			jmp		PROCURA_VITORIA_TAB_6_COMB_8_FIM_O
PROCURA_VITORIA_TAB_6_COMB_8_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro6_O
		lea     si, combinacao8
	compare_loop_6_comb_8_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_6_comb_8_O
			cmp al, ah
			jne endComparacao_6_comb_8_O
		comparacao_nao_interessa_6_comb_8_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_6_comb_8_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_6
	endComparacao_6_comb_8_O:
			inc		contador6
			mov 	al, contador6
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_6
			jmp		MUDA_JOGADOR

MOSTRA_VITORIAS_MAIN_6:
		mov 	POSx, 59
		mov     POSy, 7
		goto_xy	POSx, POSy
		mov		CL, Car
		cmp		CL, 32		; S� escreve se for espa�o em branco
		JNE     MUDA_JOGADOR

		mov bx, 0
		mov bx, 1238

		MOV AH, BYTE PTR [JogadorAtual]    ; Load the character from the variable into AL
		MOV AL, BYTE PTR [JogadorAtual_Cor]  ; Load the color attribute from the 

		mov es:[bx], ah
		mov es:[bx+1], al		
		
		int		21H		
		jmp 	ESCOLHE_COR_TAB_6
ESCOLHE_COR_TAB_6:
		mov 	al, [JogadorAtual]
		cmp 	al, 'X'
		je 		COLOCA_COR_X_TAB_6
		cmp	 	al, 'O'
		je 		COLOCA_COR_O_TAB_6
COLOCA_COR_X_TAB_6:
		mov 	al, 019h
		jmp 	PINTA_FUNDO_TAB_6

COLOCA_COR_O_TAB_6:
		mov 	al, 0EFh 
		jmp 	PINTA_FUNDO_TAB_6
PINTA_FUNDO_TAB_6:
		mov  	bx, 1002
		mov 	cx, 7
		MOV     AH, ' ' 
	ciclo_pinta_linha_1_TAB_6:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_1_TAB_6

		mov  	bx, 1162
		mov 	cx, 7
	ciclo_pinta_linha_2_TAB_6:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_2_TAB_6

		mov  	bx, 1322
		mov 	cx, 7
	ciclo_pinta_linha_3_TAB_6:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_3_TAB_6
		jmp 	PROCURA_VITORIA_TOTAL

;############################################ TODA A LOGICA DO TABULEIRO 7 #############################
PROCURA_VITORIA_TAB_7_INICIO:
			mov     al, POSx
			mov     ah, POSy
			cmp     al, 4
			je      PROCURA_VITORIA_TAB_7_COLUNA_1
			cmp     al, 6
			je      PROCURA_VITORIA_TAB_7_COLUNA_2
			cmp     al, 8
			je      PROCURA_VITORIA_TAB_7_COLUNA_3
			jmp     CICLO
CONFIRMA_EMPATE_TAB_7:
			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_Gerais+si], al
			jmp 	MUDA_JOGADOR
PROCURA_VITORIA_TAB_7_COLUNA_1:
			cmp     ah, 10
			je      PROCURA_VITORIA_TAB_7_POS_1
			cmp     ah, 11
			je      PROCURA_VITORIA_TAB_7_POS_4
			cmp     ah, 12
			je      PROCURA_VITORIA_TAB_7_POS_7
			jmp     CICLO


PROCURA_VITORIA_TAB_7_POS_1:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 1
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_1_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_1_O
			; MUDAR a combinaçao atual do array


ATUALIZA_ARRAY_TAB_7_ESPACO_1_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro7_X], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_X


ATUALIZA_ARRAY_TAB_7_ESPACO_1_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro7_O], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_O

PROCURA_VITORIA_TAB_7_POS_4:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 4
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_4_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_4_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_7_ESPACO_4_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro7_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_X

ATUALIZA_ARRAY_TAB_7_ESPACO_4_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro7_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_O

PROCURA_VITORIA_TAB_7_POS_7:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 7
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_7_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_7_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_7_ESPACO_7_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro7_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_X

ATUALIZA_ARRAY_TAB_7_ESPACO_7_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro7_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_O

PROCURA_VITORIA_TAB_7_COLUNA_2:
			cmp     ah, 10
			je      PROCURA_VITORIA_TAB_7_POS_2
			cmp     ah, 11
			je      PROCURA_VITORIA_TAB_7_POS_5
			cmp     ah, 12
			je      PROCURA_VITORIA_TAB_7_POS_8
			jmp     CICLO

PROCURA_VITORIA_TAB_7_POS_2:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 2
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_2_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_2_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_7_ESPACO_2_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro7_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_X


ATUALIZA_ARRAY_TAB_7_ESPACO_2_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro7_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_O

PROCURA_VITORIA_TAB_7_POS_5:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 5
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_5_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_5_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_7_ESPACO_5_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro7_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_X


ATUALIZA_ARRAY_TAB_7_ESPACO_5_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro7_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_O

PROCURA_VITORIA_TAB_7_POS_8:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 8
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_8_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_8_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_7_ESPACO_8_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro7_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_X


ATUALIZA_ARRAY_TAB_7_ESPACO_8_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro7_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_O

PROCURA_VITORIA_TAB_7_COLUNA_3:
			cmp     ah, 10
			je      PROCURA_VITORIA_TAB_7_POS_3
			cmp     ah, 11
			je      PROCURA_VITORIA_TAB_7_POS_6
			cmp     ah, 12
			je      PROCURA_VITORIA_TAB_7_POS_9
			jmp     CICLO

PROCURA_VITORIA_TAB_7_POS_3:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 3
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_3_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_3_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_7_ESPACO_3_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro7_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_X


ATUALIZA_ARRAY_TAB_7_ESPACO_3_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro7_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_O

PROCURA_VITORIA_TAB_7_POS_6:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 6
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_6_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_6_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_7_ESPACO_6_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro7_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_X


ATUALIZA_ARRAY_TAB_7_ESPACO_6_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro7_O+si], al 	; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_O


PROCURA_VITORIA_TAB_7_POS_9:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 9
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_9_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_7_ESPACO_9_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_7_ESPACO_9_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro7_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_X


ATUALIZA_ARRAY_TAB_7_ESPACO_9_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro7_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_7_FIM_O

PROCURA_VITORIA_TAB_7_FIM_X:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_7_COMB_1_FIM_X
PROCURA_VITORIA_TAB_7_COMB_1_FIM_X:		
		mov 	cx, 9
		lea 	bx, tabuleiro7_X
		lea     si, combinacao1
	compare_loop_7_comb_1_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_1_X
			cmp al, ah
			jne endComparacao_7_comb_1_X
		comparacao_nao_interessa_7_comb_1_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_1_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_1_X:
			jmp		PROCURA_VITORIA_TAB_7_COMB_2_FIM_X
PROCURA_VITORIA_TAB_7_COMB_2_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_X
		lea     si, combinacao2
	compare_loop_7_comb_2_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_2_X
			cmp al, ah
			jne endComparacao_7_comb_2_X
		comparacao_nao_interessa_7_comb_2_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_2_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_2_X:
			jmp		PROCURA_VITORIA_TAB_7_COMB_3_FIM_X
PROCURA_VITORIA_TAB_7_COMB_3_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_X
		lea     si, combinacao3
	compare_loop_7_comb_3_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_3_X
			cmp al, ah
			jne endComparacao_7_comb_3_X
		comparacao_nao_interessa_7_comb_3_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_3_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_3_X:
			jmp		PROCURA_VITORIA_TAB_7_COMB_4_FIM_X
PROCURA_VITORIA_TAB_7_COMB_4_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_X
		lea     si, combinacao4
	compare_loop_7_comb_4_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_4_X
			cmp al, ah
			jne endComparacao_7_comb_4_X
		comparacao_nao_interessa_7_comb_4_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_4_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_4_X:
			jmp		PROCURA_VITORIA_TAB_7_COMB_5_FIM_X
PROCURA_VITORIA_TAB_7_COMB_5_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_X
		lea     si, combinacao5
	compare_loop_7_comb_5_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_5_X
			cmp al, ah
			jne endComparacao_7_comb_5_X
		comparacao_nao_interessa_7_comb_5_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_5_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_5_X:
			jmp		PROCURA_VITORIA_TAB_7_COMB_6_FIM_X
PROCURA_VITORIA_TAB_7_COMB_6_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_X
		lea     si, combinacao6
	compare_loop_7_comb_6_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_6_X
			cmp al, ah
			jne endComparacao_7_comb_6_X
		comparacao_nao_interessa_7_comb_6_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_6_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_6_X:
			jmp		PROCURA_VITORIA_TAB_7_COMB_7_FIM_X
PROCURA_VITORIA_TAB_7_COMB_7_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_X
		lea     si, combinacao7
	compare_loop_7_comb_7_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_7_X
			cmp al, ah
			jne endComparacao_7_comb_7_X
		comparacao_nao_interessa_7_comb_7_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_7_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_7_X:
			jmp		PROCURA_VITORIA_TAB_7_COMB_8_FIM_X
PROCURA_VITORIA_TAB_7_COMB_8_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_X
		lea     si, combinacao8
	compare_loop_7_comb_8_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_8_X
			cmp al, ah
			jne endComparacao_7_comb_8_X
		comparacao_nao_interessa_7_comb_8_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_8_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_8_X:
			inc		contador7
			mov 	al, contador7
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_7
			jmp		MUDA_JOGADOR

PROCURA_VITORIA_TAB_7_FIM_O:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_7_COMB_1_FIM_O
PROCURA_VITORIA_TAB_7_COMB_1_FIM_O:		
		mov 	cx, 9
		lea 	bx, tabuleiro7_O
		lea     si, combinacao1
	compare_loop_7_comb_1_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_1_O
			cmp al, ah
			jne endComparacao_7_comb_1_O
		comparacao_nao_interessa_7_comb_1_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_1_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_1_O:
			jmp		PROCURA_VITORIA_TAB_7_COMB_2_FIM_O
PROCURA_VITORIA_TAB_7_COMB_2_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_O
		lea     si, combinacao2
	compare_loop_7_comb_2_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_2_O
			cmp al, ah
			jne endComparacao_7_comb_2_O
		comparacao_nao_interessa_7_comb_2_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_2_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_2_O:
			jmp		PROCURA_VITORIA_TAB_7_COMB_3_FIM_O
PROCURA_VITORIA_TAB_7_COMB_3_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_O
		lea     si, combinacao3
	compare_loop_7_comb_3_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_3_O
			cmp al, ah
			jne endComparacao_7_comb_3_O
		comparacao_nao_interessa_7_comb_3_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_3_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_3_O:
			jmp		PROCURA_VITORIA_TAB_7_COMB_4_FIM_O
PROCURA_VITORIA_TAB_7_COMB_4_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_O
		lea     si, combinacao4
	compare_loop_7_comb_4_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_4_O
			cmp al, ah
			jne endComparacao_7_comb_4_O
		comparacao_nao_interessa_7_comb_4_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_4_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_4_O:
			jmp		PROCURA_VITORIA_TAB_7_COMB_5_FIM_O
PROCURA_VITORIA_TAB_7_COMB_5_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_O
		lea     si, combinacao5
	compare_loop_7_comb_5_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_5_O
			cmp al, ah
			jne endComparacao_7_comb_5_O
		comparacao_nao_interessa_7_comb_5_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_5_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_5_O:
			jmp		PROCURA_VITORIA_TAB_7_COMB_6_FIM_O
PROCURA_VITORIA_TAB_7_COMB_6_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_O
		lea     si, combinacao6
	compare_loop_7_comb_6_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_6_O
			cmp al, ah
			jne endComparacao_7_comb_6_O
		comparacao_nao_interessa_7_comb_6_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_6_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_6_O:
			jmp		PROCURA_VITORIA_TAB_7_COMB_7_FIM_O
PROCURA_VITORIA_TAB_7_COMB_7_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_O
		lea     si, combinacao7
	compare_loop_7_comb_7_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_7_O
			cmp al, ah
			jne endComparacao_7_comb_7_O
		comparacao_nao_interessa_7_comb_7_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_7_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_7_O:
			jmp		PROCURA_VITORIA_TAB_7_COMB_8_FIM_O
PROCURA_VITORIA_TAB_7_COMB_8_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro7_O
		lea     si, combinacao8
	compare_loop_7_comb_8_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_7_comb_8_O
			cmp al, ah
			jne endComparacao_7_comb_8_O
		comparacao_nao_interessa_7_comb_8_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_7_comb_8_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_7
	endComparacao_7_comb_8_O:
			inc		contador7
			mov 	al, contador7
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_7
			jmp		MUDA_JOGADOR

MOSTRA_VITORIAS_MAIN_7:
		mov 	POSx, 55
		mov     POSy, 8
		goto_xy	POSx, POSy
		mov		CL, Car
		cmp		CL, 32		; S� escreve se for espa�o em branco
		JNE     MUDA_JOGADOR

		mov bx, 0
		mov bx, 1390

		MOV AH, BYTE PTR [JogadorAtual]    ; Load the character from the variable into AL
		MOV AL, BYTE PTR [JogadorAtual_Cor]  ; Load the color attribute from the 

		mov es:[bx], ah
		mov es:[bx+1], al		
		
		int		21H		
		jmp 	ESCOLHE_COR_TAB_7
ESCOLHE_COR_TAB_7:
		mov 	al, [JogadorAtual]
		cmp 	al, 'X'
		je 		COLOCA_COR_X_TAB_7
		cmp	 	al, 'O'
		je 		COLOCA_COR_O_TAB_7
COLOCA_COR_X_TAB_7:
		mov 	al, 019h
		jmp 	PINTA_FUNDO_TAB_7

COLOCA_COR_O_TAB_7:
		mov 	al, 0EFh 
		jmp 	PINTA_FUNDO_TAB_7
PINTA_FUNDO_TAB_7:
		mov  	bx, 1606
		mov 	cx, 7
		MOV     AH, ' '
	ciclo_pinta_linha_1_TAB_7:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_1_TAB_7

		mov  	bx, 1766
		mov 	cx, 7
	ciclo_pinta_linha_2_TAB_7:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_2_TAB_7

		mov  	bx, 1926
		mov 	cx, 7
	ciclo_pinta_linha_3_TAB_7:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_3_TAB_7	
		jmp 	PROCURA_VITORIA_TOTAL


;############################################ TODA A LOGICA DO TABULEIRO 8 #############################
PROCURA_VITORIA_TAB_8_INICIO:
			mov     al, POSx
			mov     ah, POSy
			cmp     al, 13
			je      PROCURA_VITORIA_TAB_8_COLUNA_1
			cmp     al, 15
			je      PROCURA_VITORIA_TAB_8_COLUNA_2
			cmp     al, 17
			je      PROCURA_VITORIA_TAB_8_COLUNA_3
			jmp     CICLO
CONFIRMA_EMPATE_TAB_8:
			mov  ax, 0
			mov  al, 1             ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_Gerais+si], al
			jmp 	MUDA_JOGADOR
PROCURA_VITORIA_TAB_8_COLUNA_1:
			cmp     ah, 10
			je      PROCURA_VITORIA_TAB_8_POS_1
			cmp     ah, 11
			je      PROCURA_VITORIA_TAB_8_POS_4
			cmp     ah, 12
			je      PROCURA_VITORIA_TAB_8_POS_7
			jmp     CICLO


PROCURA_VITORIA_TAB_8_POS_1:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 1
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_1_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_1_O
			; MUDAR a combinaçao atual do array


ATUALIZA_ARRAY_TAB_8_ESPACO_1_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro8_X], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_X


ATUALIZA_ARRAY_TAB_8_ESPACO_1_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro8_O], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_O

PROCURA_VITORIA_TAB_8_POS_4:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 4
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_4_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_4_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_8_ESPACO_4_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro8_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_X

ATUALIZA_ARRAY_TAB_8_ESPACO_4_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro8_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_O

PROCURA_VITORIA_TAB_8_POS_7:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 7
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_7_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_7_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_8_ESPACO_7_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro8_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_X

ATUALIZA_ARRAY_TAB_8_ESPACO_7_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro8_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_O

PROCURA_VITORIA_TAB_8_COLUNA_2:
			cmp     ah, 10
			je      PROCURA_VITORIA_TAB_8_POS_2
			cmp     ah, 11
			je      PROCURA_VITORIA_TAB_8_POS_5
			cmp     ah, 12
			je      PROCURA_VITORIA_TAB_8_POS_8
			jmp     CICLO

PROCURA_VITORIA_TAB_8_POS_2:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 2
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_2_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_2_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_8_ESPACO_2_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro8_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_X


ATUALIZA_ARRAY_TAB_8_ESPACO_2_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro8_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_O

PROCURA_VITORIA_TAB_8_POS_5:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 5
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_5_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_5_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_8_ESPACO_5_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro8_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_X


ATUALIZA_ARRAY_TAB_8_ESPACO_5_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro8_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_O

PROCURA_VITORIA_TAB_8_POS_8:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 8
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_8_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_8_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_8_ESPACO_8_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro8_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_X


ATUALIZA_ARRAY_TAB_8_ESPACO_8_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro8_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_O

PROCURA_VITORIA_TAB_8_COLUNA_3:
			cmp     ah, 10
			je      PROCURA_VITORIA_TAB_8_POS_3
			cmp     ah, 11
			je      PROCURA_VITORIA_TAB_8_POS_6
			cmp     ah, 12
			je      PROCURA_VITORIA_TAB_8_POS_9
			jmp     CICLO

PROCURA_VITORIA_TAB_8_POS_3:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 3
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_3_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_3_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_8_ESPACO_3_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro8_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_X


ATUALIZA_ARRAY_TAB_8_ESPACO_3_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro8_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_O

PROCURA_VITORIA_TAB_8_POS_6:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 6
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_6_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_6_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_8_ESPACO_6_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro8_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_X


ATUALIZA_ARRAY_TAB_8_ESPACO_6_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro8_O+si], al 	; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_O


PROCURA_VITORIA_TAB_8_POS_9:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 9
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_9_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_8_ESPACO_9_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_8_ESPACO_9_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro8_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_X


ATUALIZA_ARRAY_TAB_8_ESPACO_9_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro8_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_8_FIM_O

PROCURA_VITORIA_TAB_8_FIM_X:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_8_COMB_1_FIM_X
PROCURA_VITORIA_TAB_8_COMB_1_FIM_X:		
		mov 	cx, 9
		lea 	bx, tabuleiro8_X
		lea     si, combinacao1
	compare_loop_8_comb_1_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_1_X
			cmp al, ah
			jne endComparacao_8_comb_1_X
		comparacao_nao_interessa_8_comb_1_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_1_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_1_X:
			jmp		PROCURA_VITORIA_TAB_8_COMB_2_FIM_X
PROCURA_VITORIA_TAB_8_COMB_2_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_X
		lea     si, combinacao2
	compare_loop_8_comb_2_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_2_X
			cmp al, ah
			jne endComparacao_8_comb_2_X
		comparacao_nao_interessa_8_comb_2_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_2_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_2_X:
			jmp		PROCURA_VITORIA_TAB_8_COMB_3_FIM_X
PROCURA_VITORIA_TAB_8_COMB_3_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_X
		lea     si, combinacao3
	compare_loop_8_comb_3_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_3_X
			cmp al, ah
			jne endComparacao_8_comb_3_X
		comparacao_nao_interessa_8_comb_3_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_3_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_3_X:
			jmp		PROCURA_VITORIA_TAB_8_COMB_4_FIM_X
PROCURA_VITORIA_TAB_8_COMB_4_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_X
		lea     si, combinacao4
	compare_loop_8_comb_4_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_4_X
			cmp al, ah
			jne endComparacao_8_comb_4_X
		comparacao_nao_interessa_8_comb_4_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_4_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_4_X:
			jmp		PROCURA_VITORIA_TAB_8_COMB_5_FIM_X
PROCURA_VITORIA_TAB_8_COMB_5_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_X
		lea     si, combinacao5
	compare_loop_8_comb_5_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_5_X
			cmp al, ah
			jne endComparacao_8_comb_5_X
		comparacao_nao_interessa_8_comb_5_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_5_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_5_X:
			jmp		PROCURA_VITORIA_TAB_8_COMB_6_FIM_X
PROCURA_VITORIA_TAB_8_COMB_6_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_X
		lea     si, combinacao6
	compare_loop_8_comb_6_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_6_X
			cmp al, ah
			jne endComparacao_8_comb_6_X
		comparacao_nao_interessa_8_comb_6_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_6_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_6_X:
			jmp		PROCURA_VITORIA_TAB_8_COMB_7_FIM_X
PROCURA_VITORIA_TAB_8_COMB_7_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_X
		lea     si, combinacao7
	compare_loop_8_comb_7_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_7_X
			cmp al, ah
			jne endComparacao_8_comb_7_X
		comparacao_nao_interessa_8_comb_7_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_7_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_7_X:
			jmp		PROCURA_VITORIA_TAB_8_COMB_8_FIM_X
PROCURA_VITORIA_TAB_8_COMB_8_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_X
		lea     si, combinacao8
	compare_loop_8_comb_8_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_8_X
			cmp al, ah
			jne endComparacao_8_comb_8_X
		comparacao_nao_interessa_8_comb_8_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_8_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_8_X:
			inc		contador8
			mov 	al, contador8
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_8
			jmp		MUDA_JOGADOR

PROCURA_VITORIA_TAB_8_FIM_O:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_8_COMB_1_FIM_O
PROCURA_VITORIA_TAB_8_COMB_1_FIM_O:		
		mov 	cx, 9
		lea 	bx, tabuleiro8_O
		lea     si, combinacao1
	compare_loop_8_comb_1_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_1_O
			cmp al, ah
			jne endComparacao_8_comb_1_O
		comparacao_nao_interessa_8_comb_1_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_1_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_1_O:
			jmp		PROCURA_VITORIA_TAB_8_COMB_2_FIM_O
PROCURA_VITORIA_TAB_8_COMB_2_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_O
		lea     si, combinacao2
	compare_loop_8_comb_2_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_2_O
			cmp al, ah
			jne endComparacao_8_comb_2_O
		comparacao_nao_interessa_8_comb_2_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_2_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_2_O:
			jmp		PROCURA_VITORIA_TAB_8_COMB_3_FIM_O
PROCURA_VITORIA_TAB_8_COMB_3_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_O
		lea     si, combinacao3
	compare_loop_8_comb_3_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_3_O
			cmp al, ah
			jne endComparacao_8_comb_3_O
		comparacao_nao_interessa_8_comb_3_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_3_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_3_O:
			jmp		PROCURA_VITORIA_TAB_8_COMB_4_FIM_O
PROCURA_VITORIA_TAB_8_COMB_4_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_O
		lea     si, combinacao4
	compare_loop_8_comb_4_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_4_O
			cmp al, ah
			jne endComparacao_8_comb_4_O
		comparacao_nao_interessa_8_comb_4_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_4_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_4_O:
			jmp		PROCURA_VITORIA_TAB_8_COMB_5_FIM_O
PROCURA_VITORIA_TAB_8_COMB_5_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_O
		lea     si, combinacao5
	compare_loop_8_comb_5_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_5_O
			cmp al, ah
			jne endComparacao_8_comb_5_O
		comparacao_nao_interessa_8_comb_5_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_5_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_5_O:
			jmp		PROCURA_VITORIA_TAB_8_COMB_6_FIM_O
PROCURA_VITORIA_TAB_8_COMB_6_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_O
		lea     si, combinacao6
	compare_loop_8_comb_6_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_6_O
			cmp al, ah
			jne endComparacao_8_comb_6_O
		comparacao_nao_interessa_8_comb_6_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_6_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_6_O:
			jmp		PROCURA_VITORIA_TAB_8_COMB_7_FIM_O
PROCURA_VITORIA_TAB_8_COMB_7_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_O
		lea     si, combinacao7
	compare_loop_8_comb_7_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_7_O
			cmp al, ah
			jne endComparacao_8_comb_7_O
		comparacao_nao_interessa_8_comb_7_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_7_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_7_O:
			jmp		PROCURA_VITORIA_TAB_8_COMB_8_FIM_O
PROCURA_VITORIA_TAB_8_COMB_8_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro8_O
		lea     si, combinacao8
	compare_loop_8_comb_8_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_8_comb_8_O
			cmp al, ah
			jne endComparacao_8_comb_8_O
		comparacao_nao_interessa_8_comb_8_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_8_comb_8_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_8
	endComparacao_8_comb_8_O:
			inc		contador8
			mov 	al, contador8
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_8
			jmp		MUDA_JOGADOR

MOSTRA_VITORIAS_MAIN_8:
		mov 	POSx, 57
		mov     POSy, 8
		goto_xy	POSx, POSy
		mov		CL, Car
		cmp		CL, 32		; S� escreve se for espa�o em branco
		JNE     MUDA_JOGADOR

		mov bx, 0
		mov bx, 1394

		MOV AH, BYTE PTR [JogadorAtual]    ; Load the character from the variable into AL
		MOV AL, BYTE PTR [JogadorAtual_Cor]  ; Load the color attribute from the 

		mov es:[bx], ah
		mov es:[bx+1], al		
		
		int		21H		
		jmp 	ESCOLHE_COR_TAB_8
ESCOLHE_COR_TAB_8:
		mov 	al, [JogadorAtual]
		cmp 	al, 'X'
		je 		COLOCA_COR_X_TAB_8
		cmp	 	al, 'O'
		je 		COLOCA_COR_O_TAB_8
COLOCA_COR_X_TAB_8:
		mov 	al, 019h
		jmp 	PINTA_FUNDO_TAB_8

COLOCA_COR_O_TAB_8:
		mov 	al, 0EFh 
		jmp 	PINTA_FUNDO_TAB_8
PINTA_FUNDO_TAB_8:
		mov  	bx, 1624
		mov 	cx, 7
		MOV     AH, ' '
	ciclo_pinta_linha_1_TAB_8:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_1_TAB_8

		mov  	bx, 1784
		mov 	cx, 7
	ciclo_pinta_linha_2_TAB_8:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_2_TAB_8

		mov  	bx, 1944
		mov 	cx, 7
	ciclo_pinta_linha_3_TAB_8:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_3_TAB_8
		jmp 	PROCURA_VITORIA_TOTAL


;############################################ TODA A LOGICA DO TABULEIRO 9 #############################
PROCURA_VITORIA_TAB_9_INICIO:
			mov     al, POSx
			mov     ah, POSy
			cmp     al, 22
			je      PROCURA_VITORIA_TAB_9_COLUNA_1
			cmp     al, 24
			je      PROCURA_VITORIA_TAB_9_COLUNA_2
			cmp     al, 26
			je      PROCURA_VITORIA_TAB_9_COLUNA_3
			jmp     CICLO
CONFIRMA_EMPATE_TAB_9:
			mov  ax, 0
			mov  al, 1             ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_Gerais+si], al
			jmp 	MUDA_JOGADOR
PROCURA_VITORIA_TAB_9_COLUNA_1:
			cmp     ah, 10
			je      PROCURA_VITORIA_TAB_9_POS_1
			cmp     ah, 11
			je      PROCURA_VITORIA_TAB_9_POS_4
			cmp     ah, 12
			je      PROCURA_VITORIA_TAB_9_POS_7
			jmp     CICLO


PROCURA_VITORIA_TAB_9_POS_1:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 1
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_1_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_1_O
			; MUDAR a combinaçao atual do array


ATUALIZA_ARRAY_TAB_9_ESPACO_1_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro9_X], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_X


ATUALIZA_ARRAY_TAB_9_ESPACO_1_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  [tabuleiro9_O], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_O

PROCURA_VITORIA_TAB_9_POS_4:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 4
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_4_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_4_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_9_ESPACO_4_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro9_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_X

ATUALIZA_ARRAY_TAB_9_ESPACO_4_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 3
			mov  [tabuleiro9_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_O

PROCURA_VITORIA_TAB_9_POS_7:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 7
			mov     proximoTab, cl
 			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_7_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_7_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_9_ESPACO_7_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro9_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_X

ATUALIZA_ARRAY_TAB_9_ESPACO_7_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 6
			mov  [tabuleiro9_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_O

PROCURA_VITORIA_TAB_9_COLUNA_2:
			cmp     ah, 10
			je      PROCURA_VITORIA_TAB_9_POS_2
			cmp     ah, 11
			je      PROCURA_VITORIA_TAB_9_POS_5
			cmp     ah, 12
			je      PROCURA_VITORIA_TAB_9_POS_8
			jmp     CICLO

PROCURA_VITORIA_TAB_9_POS_2:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 2
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_2_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_2_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_9_ESPACO_2_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro9_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_X


ATUALIZA_ARRAY_TAB_9_ESPACO_2_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 1
			mov  [tabuleiro9_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_O

PROCURA_VITORIA_TAB_9_POS_5:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 5
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_5_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_5_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_9_ESPACO_5_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro9_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_X


ATUALIZA_ARRAY_TAB_9_ESPACO_5_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 4
			mov  [tabuleiro9_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_O

PROCURA_VITORIA_TAB_9_POS_8:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 8
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_8_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_8_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_9_ESPACO_8_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro9_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_X


ATUALIZA_ARRAY_TAB_9_ESPACO_8_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 7
			mov  [tabuleiro9_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_O

PROCURA_VITORIA_TAB_9_COLUNA_3:
			cmp     ah, 10
			je      PROCURA_VITORIA_TAB_9_POS_3
			cmp     ah, 11
			je      PROCURA_VITORIA_TAB_9_POS_6
			cmp     ah, 12
			je      PROCURA_VITORIA_TAB_9_POS_9
			jmp     CICLO

PROCURA_VITORIA_TAB_9_POS_3:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 3
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_3_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_3_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_9_ESPACO_3_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro9_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_X


ATUALIZA_ARRAY_TAB_9_ESPACO_3_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 2
			mov  [tabuleiro9_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_O

PROCURA_VITORIA_TAB_9_POS_6:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 6
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_6_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_6_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_9_ESPACO_6_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro9_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_X


ATUALIZA_ARRAY_TAB_9_ESPACO_6_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 5
			mov  [tabuleiro9_O+si], al 	; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_O


PROCURA_VITORIA_TAB_9_POS_9:
			; Muda o proximo jogo para a posicao onde foi jogado este ( BONUS 1 )
			mov     cl, 9
			mov     proximoTab, cl
			; VER SE O JOGADOR é X ou O
			mov 	al, JogadorAtual
			cmp     al, 'X'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_9_X
			cmp     al, 'O'
			je      ATUALIZA_ARRAY_TAB_9_ESPACO_9_O
			; MUDAR a combinaçao atual do array

ATUALIZA_ARRAY_TAB_9_ESPACO_9_X:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro9_X+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_X


ATUALIZA_ARRAY_TAB_9_ESPACO_9_O:
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [tabuleiro9_O+si], al ; Move the value from AL into the memory location tabuleiro1_X
			jmp  PROCURA_VITORIA_TAB_9_FIM_O

PROCURA_VITORIA_TAB_9_FIM_X:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_9_COMB_1_FIM_X
PROCURA_VITORIA_TAB_9_COMB_1_FIM_X:		
		mov 	cx, 9
		lea 	bx, tabuleiro9_X
		lea     si, combinacao1
	compare_loop_9_comb_1_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_1_X
			cmp al, ah
			jne endComparacao_9_comb_1_X
		comparacao_nao_interessa_9_comb_1_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_1_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_1_X:
			jmp		PROCURA_VITORIA_TAB_9_COMB_2_FIM_X
PROCURA_VITORIA_TAB_9_COMB_2_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_X
		lea     si, combinacao2
	compare_loop_9_comb_2_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_2_X
			cmp al, ah
			jne endComparacao_9_comb_2_X
		comparacao_nao_interessa_9_comb_2_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_2_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_2_X:
			jmp		PROCURA_VITORIA_TAB_9_COMB_3_FIM_X
PROCURA_VITORIA_TAB_9_COMB_3_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_X
		lea     si, combinacao3
	compare_loop_9_comb_3_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_3_X
			cmp al, ah
			jne endComparacao_9_comb_3_X
		comparacao_nao_interessa_9_comb_3_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_3_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_3_X:
			jmp		PROCURA_VITORIA_TAB_9_COMB_4_FIM_X
PROCURA_VITORIA_TAB_9_COMB_4_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_X
		lea     si, combinacao4
	compare_loop_9_comb_4_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_4_X
			cmp al, ah
			jne endComparacao_9_comb_4_X
		comparacao_nao_interessa_9_comb_4_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_4_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_4_X:
			jmp		PROCURA_VITORIA_TAB_9_COMB_5_FIM_X
PROCURA_VITORIA_TAB_9_COMB_5_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_X
		lea     si, combinacao5
	compare_loop_9_comb_5_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_5_X
			cmp al, ah
			jne endComparacao_9_comb_5_X
		comparacao_nao_interessa_9_comb_5_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_5_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_5_X:
			jmp		PROCURA_VITORIA_TAB_9_COMB_6_FIM_X
PROCURA_VITORIA_TAB_9_COMB_6_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_X
		lea     si, combinacao6
	compare_loop_9_comb_6_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_6_X
			cmp al, ah
			jne endComparacao_9_comb_6_X
		comparacao_nao_interessa_9_comb_6_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_6_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_6_X:
			jmp		PROCURA_VITORIA_TAB_9_COMB_7_FIM_X
PROCURA_VITORIA_TAB_9_COMB_7_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_X
		lea     si, combinacao7
	compare_loop_9_comb_7_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_7_X
			cmp al, ah
			jne endComparacao_9_comb_7_X
		comparacao_nao_interessa_9_comb_7_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_7_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_7_X:
			jmp		PROCURA_VITORIA_TAB_9_COMB_8_FIM_X
PROCURA_VITORIA_TAB_9_COMB_8_FIM_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_X
		lea     si, combinacao8
	compare_loop_9_comb_8_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_8_X
			cmp al, ah
			jne endComparacao_9_comb_8_X
		comparacao_nao_interessa_9_comb_8_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_8_X

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_X+si], al   ; Move the value from AL into the memory location Vitorias_X
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_8_X:
			inc		contador9
			mov 	al, contador9
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_9
			jmp		MUDA_JOGADOR

PROCURA_VITORIA_TAB_9_FIM_O:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TAB_9_COMB_1_FIM_O
PROCURA_VITORIA_TAB_9_COMB_1_FIM_O:		
		mov 	cx, 9
		lea 	bx, tabuleiro9_O
		lea     si, combinacao1
	compare_loop_9_comb_1_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_1_O
			cmp al, ah
			jne endComparacao_9_comb_1_O
		comparacao_nao_interessa_9_comb_1_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_1_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_1_O:
			jmp		PROCURA_VITORIA_TAB_9_COMB_2_FIM_O
PROCURA_VITORIA_TAB_9_COMB_2_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_O
		lea     si, combinacao2
	compare_loop_9_comb_2_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_2_O
			cmp al, ah
			jne endComparacao_9_comb_2_O
		comparacao_nao_interessa_9_comb_2_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_2_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_2_O:
			jmp		PROCURA_VITORIA_TAB_9_COMB_3_FIM_O
PROCURA_VITORIA_TAB_9_COMB_3_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_O
		lea     si, combinacao3
	compare_loop_9_comb_3_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_3_O
			cmp al, ah
			jne endComparacao_9_comb_3_O
		comparacao_nao_interessa_9_comb_3_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_3_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_3_O:
			jmp		PROCURA_VITORIA_TAB_9_COMB_4_FIM_O
PROCURA_VITORIA_TAB_9_COMB_4_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_O
		lea     si, combinacao4
	compare_loop_9_comb_4_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_4_O
			cmp al, ah
			jne endComparacao_9_comb_4_O
		comparacao_nao_interessa_9_comb_4_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_4_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_4_O:
			jmp		PROCURA_VITORIA_TAB_9_COMB_5_FIM_O
PROCURA_VITORIA_TAB_9_COMB_5_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_O
		lea     si, combinacao5
	compare_loop_9_comb_5_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_5_O
			cmp al, ah
			jne endComparacao_9_comb_5_O
		comparacao_nao_interessa_9_comb_5_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_5_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_5_O:
			jmp		PROCURA_VITORIA_TAB_9_COMB_6_FIM_O
PROCURA_VITORIA_TAB_9_COMB_6_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_O
		lea     si, combinacao6
	compare_loop_9_comb_6_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_6_O
			cmp al, ah
			jne endComparacao_9_comb_6_O
		comparacao_nao_interessa_9_comb_6_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_6_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_6_O:
			jmp		PROCURA_VITORIA_TAB_9_COMB_7_FIM_O
PROCURA_VITORIA_TAB_9_COMB_7_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_O
		lea     si, combinacao7
	compare_loop_9_comb_7_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_7_O
			cmp al, ah
			jne endComparacao_9_comb_7_O
		comparacao_nao_interessa_9_comb_7_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_7_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_7_O:
			jmp		PROCURA_VITORIA_TAB_9_COMB_8_FIM_O
PROCURA_VITORIA_TAB_9_COMB_8_FIM_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, tabuleiro9_O
		lea     si, combinacao8
	compare_loop_9_comb_8_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_9_comb_8_O
			cmp al, ah
			jne endComparacao_9_comb_8_O
		comparacao_nao_interessa_9_comb_8_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_9_comb_8_O

			mov  ax, 0
			mov  al, 1              ; Move the value 1 into the AL register
			mov  si, 8
			mov  [Vitorias_O+si], al   ; Move the value from AL into the memory location Vitorias_O
			mov  [Vitorias_Gerais+si], al
			; jmp   MUDA_JOGADOR
			jmp 	MOSTRA_VITORIAS_MAIN_9
	endComparacao_9_comb_8_O:
			inc		contador9
			mov 	al, contador9
			cmp 	al, 9
			je 		CONFIRMA_EMPATE_TAB_9
			jmp		MUDA_JOGADOR

MOSTRA_VITORIAS_MAIN_9:
		mov 	POSx, 59
		mov     POSy, 8
		goto_xy	POSx, POSy
		mov		CL, Car
		cmp		CL, 32		; S� escreve se for espa�o em branco
		JNE     MUDA_JOGADOR

		mov bx, 0
		mov bx, 1398

		MOV AH, BYTE PTR [JogadorAtual]    ; Load the character from the variable into AL
		MOV AL, BYTE PTR [JogadorAtual_Cor]  ; Load the color attribute from the 

		mov es:[bx], ah
		mov es:[bx+1], al		
		
		int		21H		
		jmp 	ESCOLHE_COR_TAB_9
ESCOLHE_COR_TAB_9:
		mov 	al, [JogadorAtual]
		cmp 	al, 'X'
		je 		COLOCA_COR_X_TAB_9
		cmp	 	al, 'O'
		je 		COLOCA_COR_O_TAB_9
COLOCA_COR_X_TAB_9:
		mov 	al, 019h
		jmp 	PINTA_FUNDO_TAB_9

COLOCA_COR_O_TAB_9:
		mov 	al, 0EFh 
		jmp 	PINTA_FUNDO_TAB_9
PINTA_FUNDO_TAB_9:
		mov  	bx, 1642
		mov 	cx, 7
		MOV     AH, ' ' 
	ciclo_pinta_linha_1_TAB_9:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_1_TAB_9

		mov  	bx, 1802
		mov 	cx, 7
	ciclo_pinta_linha_2_TAB_9:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_2_TAB_9

		mov  	bx, 1962
		mov 	cx, 7
	ciclo_pinta_linha_3_TAB_9:

		mov es:[bx], ah
		mov es:[bx+1], al

		inc bx
		inc bx

		loop ciclo_pinta_linha_3_TAB_9
		jmp 	PROCURA_VITORIA_TOTAL


MUDA_JOGADOR:
			mov     al, num_jogadas
			cmp     al, 0
			je      fim
			mov 	al, JogadorAtual
			cmp 	al, 'O'
			je      MUDA_JOGADOR_PARA_X
			cmp 	al, 'X'
			je      MUDA_JOGADOR_PARA_O


PROCURA_VITORIA_TOTAL:
			; inc 	Empate_geral
			; mov 	al, Empate_geral
			; cmp 	al, 9
			; jmp 	PREPARA_FIM_DO_JOGO_EMPATE

			mov 	al, JogadorAtual
			cmp 	al, 'O'
			je      PROCURA_VITORIA_TOTAL_O
			cmp 	al, 'X'
			je      PROCURA_VITORIA_TOTAL_X
PROCURA_VITORIA_TOTAL_X:
		jmp		PROCURA_VITORIA_TOTAL_COMB_1_X
PROCURA_VITORIA_TOTAL_COMB_1_X:		
		mov 	cx, 9
		lea 	bx, Vitorias_X
		lea     si, combinacao1
	compare_loop_total_comb_1_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_1_X
			cmp al, ah
			jne endComparacao_total_comb_1_X
		comparacao_nao_interessa_total_comb_1_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_1_X

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_1_X:
			jmp		PROCURA_VITORIA_TOTAL_COMB_2_X
PROCURA_VITORIA_TOTAL_COMB_2_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_X
		lea     si, combinacao2
	compare_loop_total_comb_2_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_2_X
			cmp al, ah
			jne endComparacao_total_comb_2_X
		comparacao_nao_interessa_total_comb_2_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_2_X

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_2_X:
			jmp		PROCURA_VITORIA_TOTAL_COMB_3_X
PROCURA_VITORIA_TOTAL_COMB_3_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_X
		lea     si, combinacao3
	compare_loop_total_comb_3_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_3_X
			cmp al, ah
			jne endComparacao_total_comb_3_X
		comparacao_nao_interessa_total_comb_3_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_3_X

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_3_X:
			jmp		PROCURA_VITORIA_TOTAL_COMB_4_X
PROCURA_VITORIA_TOTAL_COMB_4_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_X
		lea     si, combinacao4
	compare_loop_total_comb_4_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_4_X
			cmp al, ah
			jne endComparacao_total_comb_4_X
		comparacao_nao_interessa_total_comb_4_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_4_X

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_4_X:
			jmp		PROCURA_VITORIA_TOTAL_COMB_5_X
PROCURA_VITORIA_TOTAL_COMB_5_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_X
		lea     si, combinacao5
	compare_loop_total_comb_5_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_5_X
			cmp al, ah
			jne endComparacao_total_comb_5_X
		comparacao_nao_interessa_total_comb_5_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_5_X

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_5_X:
			jmp		PROCURA_VITORIA_TOTAL_COMB_6_X
PROCURA_VITORIA_TOTAL_COMB_6_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_X
		lea     si, combinacao6
	compare_loop_total_comb_6_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_6_X
			cmp al, ah
			jne endComparacao_total_comb_6_X
		comparacao_nao_interessa_total_comb_6_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_6_X

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_6_X:
			jmp		PROCURA_VITORIA_TOTAL_COMB_7_X
PROCURA_VITORIA_TOTAL_COMB_7_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_X
		lea     si, combinacao7
	compare_loop_total_comb_7_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_7_X
			cmp al, ah
			jne endComparacao_total_comb_7_X
		comparacao_nao_interessa_total_comb_7_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_7_X

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_7_X:
			jmp		PROCURA_VITORIA_TOTAL_COMB_8_X
PROCURA_VITORIA_TOTAL_COMB_8_X:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_X
		lea     si, combinacao8
	compare_loop_total_comb_8_X:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_8_X
			cmp al, ah
			jne endComparacao_total_comb_8_X
		comparacao_nao_interessa_total_comb_8_X:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_8_X

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_8_X:
			jmp		MUDA_JOGADOR

PROCURA_VITORIA_TOTAL_O:
		; jmp     MUDA_JOGADOR
		jmp		PROCURA_VITORIA_TOTAL_COMB_1_O
PROCURA_VITORIA_TOTAL_COMB_1_O:		
		mov 	cx, 9
		lea 	bx, Vitorias_O
		lea     si, combinacao1
	compare_loop_total_comb_1_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_1_O
			cmp al, ah
			jne endComparacao_total_comb_1_O
		comparacao_nao_interessa_total_comb_1_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_1_O

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_1_O:
			jmp		PROCURA_VITORIA_TOTAL_COMB_2_O
PROCURA_VITORIA_TOTAL_COMB_2_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_O
		lea     si, combinacao2
	compare_loop_total_comb_2_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_2_O
			cmp al, ah
			jne endComparacao_total_comb_2_O
		comparacao_nao_interessa_total_comb_2_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_2_O

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_2_O:
			jmp		PROCURA_VITORIA_TOTAL_COMB_3_O
PROCURA_VITORIA_TOTAL_COMB_3_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_O
		lea     si, combinacao3
	compare_loop_total_comb_3_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_3_O
			cmp al, ah
			jne endComparacao_total_comb_3_O
		comparacao_nao_interessa_total_comb_3_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_3_O

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_3_O:
			jmp		PROCURA_VITORIA_TOTAL_COMB_4_O
PROCURA_VITORIA_TOTAL_COMB_4_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_O
		lea     si, combinacao4
	compare_loop_total_comb_4_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_4_O
			cmp al, ah
			jne endComparacao_total_comb_4_O
		comparacao_nao_interessa_total_comb_4_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_4_O

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_4_O:
			jmp		PROCURA_VITORIA_TOTAL_COMB_5_O
PROCURA_VITORIA_TOTAL_COMB_5_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_O
		lea     si, combinacao5
	compare_loop_total_comb_5_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_5_O
			cmp al, ah
			jne endComparacao_total_comb_5_O
		comparacao_nao_interessa_total_comb_5_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_5_O

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_5_O:
			jmp		PROCURA_VITORIA_TOTAL_COMB_6_O
PROCURA_VITORIA_TOTAL_COMB_6_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_O
		lea     si, combinacao6
	compare_loop_total_comb_6_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_6_O
			cmp al, ah
			jne endComparacao_total_comb_6_O
		comparacao_nao_interessa_total_comb_6_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_6_O

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_6_O:
			jmp		PROCURA_VITORIA_TOTAL_COMB_7_O
PROCURA_VITORIA_TOTAL_COMB_7_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_O
		lea     si, combinacao7
	compare_loop_total_comb_7_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_7_O
			cmp al, ah
			jne endComparacao_total_comb_7_O
		comparacao_nao_interessa_total_comb_7_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_7_O

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_7_O:
			jmp		PROCURA_VITORIA_TOTAL_COMB_8_O
PROCURA_VITORIA_TOTAL_COMB_8_O:
		; jmp     MUDA_JOGADOR
		mov 	cx, 9
		lea 	bx, Vitorias_O
		lea     si, combinacao8
	compare_loop_total_comb_8_O:
			; Compare the current elements
			mov al, [si]
			mov ah, [bx]
			cmp al, 1
			jne comparacao_nao_interessa_total_comb_8_O
			cmp al, ah
			jne endComparacao_total_comb_8_O
		comparacao_nao_interessa_total_comb_8_O:
			; Move to the next element
			inc si
			inc bx

			; Decrement the loop counter
			loop compare_loop_total_comb_8_O

			;Devolver o necessario para depois mostrar o vencedor

			jmp 	PREPARA_FIM_DO_JOGO_VITORIA
	endComparacao_total_comb_8_O:
			jmp		MUDA_JOGADOR


PREPARA_FIM_DO_JOGO_VITORIA:
			xor 	si, si
			mov 	al, 1
			mov     [JogoTerminado], al
			mov 	al, [JogadorAtual]				;Aqui esta estranho mas tem que ser assim
			cmp 	al, 'O'
			je 		VENCEDOR_O
			cmp 	al, 'X'
			je 		VENCEDOR_X

			; jmp		MUDA_JOGADOR
			jmp 	fim

VENCEDOR_X:
			mov 	[Winner], 'X'
	ciclo_copia_nome_X:
			cmp     si, 27
			je      fim
			mov 	al, [Player1_nome+si]
			mov     byte ptr [Winner_nome+si], al
			inc     si
			jmp     ciclo_copia_nome_X
			jmp 	fim
VENCEDOR_O:
			mov 	[Winner], 'O'
	ciclo_copia_nome_O:
			cmp     si, 27
			je      fim
			mov 	al, [Player2_nome+si]
			mov     byte ptr [Winner_nome+si], al
			inc     si
			jmp     ciclo_copia_nome_O
			jmp 	fim

PREPARA_FIM_DO_JOGO_EMPATE:
			mov 	al, 0
			mov     [JogoTerminado], al
			; jmp		MUDA_JOGADOR
			jmp 	fim

ESTEND_JOGO:		;Verificar se pode andar
			cmp 	al,48h
			jne		BAIXO_JOGO
			mov     cl, jogoAtual
			cmp     cl, 1                    ;Comparar de 1 a 9 e depois bloquear conforme
			je      ESTEND_JOGO_LINHA_1
			cmp     cl, 2                    
			je      ESTEND_JOGO_LINHA_1
			cmp     cl, 3                    
			je      ESTEND_JOGO_LINHA_1
			cmp     cl, 4                    
			je      ESTEND_JOGO_LINHA_2
			cmp     cl, 5                    
			je      ESTEND_JOGO_LINHA_2
			cmp     cl, 6                    
			je      ESTEND_JOGO_LINHA_2
			cmp     cl, 7                    
			je      ESTEND_JOGO_LINHA_3
			cmp     cl, 8                    
			je      ESTEND_JOGO_LINHA_3
			cmp     cl, 9                    
			je      ESTEND_JOGO_LINHA_3


ESTEND_JOGO_LINHA_1:
			mov     cl, POSy
			cmp     cl, 2
			je      CICLO
			dec		POSy		;cima
			jmp		CICLO

ESTEND_JOGO_LINHA_2:
			mov     cl, POSy
			cmp     cl, 6
			je      CICLO
			dec		POSy		;cima
			jmp		CICLO

ESTEND_JOGO_LINHA_3:
			mov     cl, POSy
			cmp     cl, 10
			je      CICLO
			dec		POSy		;cima
			jmp		CICLO


BAIXO_JOGO:		
			cmp		al,50h
			jne		ESQUERDA_JOGO
			mov     cl, jogoAtual
			cmp     cl, 1                    ;Comparar de 1 a 9 e depois bloquear conforme
			je      BAIXO_JOGO_LINHA_1
			cmp     cl, 2                    
			je      BAIXO_JOGO_LINHA_1
			cmp     cl, 3                    
			je      BAIXO_JOGO_LINHA_1
			cmp     cl, 4                    
			je      BAIXO_JOGO_LINHA_2
			cmp     cl, 5                    
			je      BAIXO_JOGO_LINHA_2
			cmp     cl, 6                    
			je      BAIXO_JOGO_LINHA_2
			cmp     cl, 7                    
			je      BAIXO_JOGO_LINHA_3
			cmp     cl, 8                    
			je      BAIXO_JOGO_LINHA_3
			cmp     cl, 9                    
			je      BAIXO_JOGO_LINHA_3

BAIXO_JOGO_LINHA_1:
			mov     cl, POSy
			cmp     cl, 4
			je      CICLO
			inc		POSy		;baixo
			jmp		CICLO

BAIXO_JOGO_LINHA_2:
			mov     cl, POSy
			cmp     cl, 8
			je      CICLO
			inc		POSy		;baixo
			jmp		CICLO

BAIXO_JOGO_LINHA_3:
			mov     cl, POSy
			cmp     cl, 12
			je      CICLO
			inc		POSy		;baixo
			jmp		CICLO


ESQUERDA_JOGO:
			cmp		al,4Bh
			jne		DIREITA_JOGO
			mov     cl, jogoAtual
			cmp     cl, 1                    ;Comparar de 1 a 9 e depois bloquear conforme
			je      ESQUERDA_JOGO_COLUNA_1
			cmp     cl, 4                    
			je      ESQUERDA_JOGO_COLUNA_1
			cmp     cl, 7                    
			je      ESQUERDA_JOGO_COLUNA_1
			cmp     cl, 2                    
			je      ESQUERDA_JOGO_COLUNA_2
			cmp     cl, 5                    
			je      ESQUERDA_JOGO_COLUNA_2
			cmp     cl, 8                    
			je      ESQUERDA_JOGO_COLUNA_2
			cmp     cl, 3                    
			je      ESQUERDA_JOGO_COLUNA_3
			cmp     cl, 6                    
			je      ESQUERDA_JOGO_COLUNA_3
			cmp     cl, 9                    
			je      ESQUERDA_JOGO_COLUNA_3

ESQUERDA_JOGO_COLUNA_1:
			mov     cl, POSx
			cmp     cl, 4
			je      CICLO
			dec		POSx		;Esquerda
			dec		POSx
			jmp		CICLO

ESQUERDA_JOGO_COLUNA_2:
			mov     cl, POSx
			cmp     cl, 13
			je      CICLO
			dec		POSx		;Esquerda
			dec		POSx
			jmp		CICLO

ESQUERDA_JOGO_COLUNA_3:
			mov     cl, POSx
			cmp     cl, 22
			je      CICLO
			dec		POSx		;Esquerda
			dec		POSx
			jmp		CICLO

DIREITA_JOGO:
			cmp		al,4Dh
			jne		CICLO
			mov     cl, jogoAtual
			cmp     cl, 1                    ;Comparar de 1 a 9 e depois bloquear conforme
			je      DIREITA_JOGO_COLUNA_1
			cmp     cl, 4                    
			je      DIREITA_JOGO_COLUNA_1
			cmp     cl, 7                    
			je      DIREITA_JOGO_COLUNA_1
			cmp     cl, 2                    
			je      DIREITA_JOGO_COLUNA_2
			cmp     cl, 5                    
			je      DIREITA_JOGO_COLUNA_2
			cmp     cl, 8                    
			je      DIREITA_JOGO_COLUNA_2
			cmp     cl, 3                    
			je      DIREITA_JOGO_COLUNA_3
			cmp     cl, 6                    
			je      DIREITA_JOGO_COLUNA_3
			cmp     cl, 9                    
			je      DIREITA_JOGO_COLUNA_3

DIREITA_JOGO_COLUNA_1:
			mov     cl, POSx
			cmp     cl, 8
			je      CICLO
			inc		POSx		;Direita
			inc		POSx
			jmp		CICLO

DIREITA_JOGO_COLUNA_2:
			mov     cl, POSx
			cmp     cl, 17
			je      CICLO
			inc		POSx		;Direita
			inc		POSx
			jmp		CICLO

DIREITA_JOGO_COLUNA_3:
			mov     cl, POSx
			cmp     cl, 26
			je      CICLO
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
		; mov dl, 'X'            ; Print 'X' character
		MOV AH, 'X'
		MOV AL, 9h

		mov bx, 552

		mov es:[bx], ah
		mov es:[bx+1], al	
		int 21h                ; Call interrupt 21h to print the character

		mov ah, 02h            ; Set the function to display a character
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
		; mov dl, 'O'            ; Print 'O' character
		MOV AH, 'O'
		MOV AL, 0Eh

		mov bx, 712

		mov es:[bx], ah
		mov es:[bx+1], al	
		int 21h                ; Call interrupt 21h to print the character

		mov ah, 02h            ; Set the function to display a character
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
; ########################################################################################
MOSTRA_FINAL PROC

		;abre ficheiro
        mov     ah,3dh		; Open File function
        mov     al,0		; Open for reading only
        lea     dx,Fich_final		; Load the address of the filename
        int     21h			; Trigger DOS interrupt 21h
        jc      erro_abrir		; Jump to error handler if CF (Carry Flag) is set
        mov     HandleFich,ax		; Store the file handle
        jmp     ler_ciclo_final		; Jump to the reading loop

erro_abrir:
        mov     ah,09h		; Print String function
        lea     dx,Erro_Open	; Load the address of the error message
        int     21h				; Trigger DOS interrupt 21h
        jmp     fim		 ; Jump to the end of the procedure

ler_ciclo_final:
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
		jmp		ler_ciclo_final		; Continue looping to read the next character

erro_ler:
        mov     ah,09h		; Print String function
        lea     dx,Erro_Ler_Msg		; Load the address of the error message
        int     21h			; Trigger DOS interrupt 21h

fecha_ficheiro:
		; Close the file
        mov     ah,3eh			 ; Close File function
        mov     bx,HandleFich		; File handle
        int     21h				; Trigger DOS interrupt 21h
        jnc     fim			; Jump to the end of the procedure if CF is not set

        mov     ah,09h			; Print String function
        lea     dx,Erro_Close		; Load the address of the error message
        Int     21h			 ; Trigger DOS interrupt 21h

fim:
	RET
MOSTRA_FINAL endp
; ######################################################################
MOSTRA_RESULTADO PROC
			mov 	al, [JogoTerminado]
			cmp 	al, 0
			je 		ESCREVE_EMPATE
			cmp 	al, 1
			je 		ESCREVE_VENCEDOR
			jmp 	fim
ESCREVE_VENCEDOR:
		mov     POSx, 31
		mov     POSy, 2
		goto_xy POSx, POSy
		mov dl, 'V'            ; Print 'X' character
		mov ah, 02h            ; Set the function to display a character
		int 21h                ; Call interrupt 21h to print the character
		inc POSx

		mov dl, 'E'
		int 21h
		inc POSx

		mov dl, 'N'
		int 21h
		inc POSx

		mov dl, 'C'
		int 21h
		inc POSx

		mov dl, 'E'
		int 21h
		inc POSx

		mov dl, 'D'
		int 21h
		inc POSx

		mov dl, 'O'
		int 21h
		inc POSx

		mov dl, 'R'
		int 21h
		jmp ESCREVE_VENCEDOR_NOME
ESCREVE_VENCEDOR_NOME:
		mov 	POSx, 22
		mov 	POSy, 6
		goto_xy POSx, POSy
		lea dx, Winner_nome   		; Load the address of the 'Player1_nome' string into the DX register
		mov ah, 09h            					; Set the function to display a string
		int 21h                					; Call interrupt 21h to print the string
		jmp ESCREVE_VENCEDOR_SIMBOLO

ESCREVE_VENCEDOR_SIMBOLO:
		mov     POSx, 34
		mov     POSy, 8
		goto_xy POSx, POSy
		; mov dl, [Winner]
		; mov ah, 02h            ; Set the function to display a character

		MOV AH, [Winner]
		MOV AL, [JogadorAtual_Cor]

		mov bx, 1348

		mov es:[bx], ah
		mov es:[bx+1], al	
		int 21h                ; Call interrupt 21h to print the character
		
		jmp fim
ESCREVE_EMPATE:
		mov     POSx, 32
		mov     POSy, 2
		goto_xy POSx, POSy
		mov dl, 'E'            ; Print 'X' character
		mov ah, 02h            ; Set the function to display a character
		int 21h                ; Call interrupt 21h to print the character
		inc POSx

		mov dl, 'M'
		int 21h
		inc POSx

		mov dl, 'P'
		int 21h
		inc POSx

		mov dl, 'A'
		int 21h
		inc POSx

		mov dl, 'T'
		int 21h
		inc POSx

		mov dl, 'E'
		int 21h
		jmp fim
fim:
	RET
MOSTRA_RESULTADO endp
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
		call		apaga_ecran
		call		IMP_FICH		;Abre o ficheiro de texto e imprime
		call        IMP_NOMES_JOGO		;Escreve o nome dos jogadores e os seus simbolos
		call 		AVATAR
		call		apaga_ecran
		goto_xy		0,0				;Mudar as coordenadas de inicio
		call        MOSTRA_FINAL
		call 		MOSTRA_RESULTADO         ;Vai mostrar o nome do jogador vencedor ou dizer empate
		goto_xy		0,22
		
		mov			ah,4CH
		INT			21H
Main	endp
Cseg	ends
end	Main