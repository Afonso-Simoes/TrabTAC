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
		Player1			db		?
		PLayer2			db		?
        HandleFich      dw      0
		Menu_nomes		db		0		;0 Ainda não foi escrito o nome do primeiro jogador
										;1 Já foi escrito o nome do primeiro mas não o do segundo
										;2 Já foram escritos os 2 e pode começar o jogo

		Fases_jogo		db		0		;0 O jogo está na fase de pedir os nomes
										;1 o jogo está na fase de jogar
        car_fich        db      ?


		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	2	; a linha pode ir de [1 .. 25]
		POSx			db	23	; POSx pode ir [1..80]	

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
			je		ESTEND
			CMP 	AL, 27		; ESCAPE para sair
			JE		FIM
			CMP     AL, 48		; Compara para ver se é '0' ZERO e se for o jogador joga
			;JE		JOGADA
			goto_xy	POSx,POSy 	; verifica se pode escrever o caracter no ecran
			mov		CL, Car
			cmp 	CL, "#"
			je		BLOQUEIA_MOVIMENTO
			cmp 	CL, ":"
			je		BLOQUEIA_MOVIMENTO
			cmp		CL, 32		; S� escreve se for espa�o em branco
			JNE 	LER_SETA
			mov		ah, 02h		; coloca o caracter lido no ecra
			mov		dl, al
			inc		POSx		;Direita
			int		21H	
			goto_xy	POSx,POSy
			
			jmp		LER_SETA

LER_SETA_NOMES:
			call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND
			CMP 	AL, 27		; ESCAPE para sair
			JE		FIM
			CMP     AL, 49		; '1' UM Para confirmar o nome ou para avançar para o jogo
			JE		CONFIRMA_NOME			
			CMP     AL, 48		; Compara para ver se apaga usando o '0'
			JE		DELETE
			goto_xy	POSx,POSy 	; verifica se pode escrever o caracter no ecran
			mov		CL, Car
			cmp		CL, 32		; S� escreve se for espa�o em branco
			JNE 	LER_SETA_NOMES
			mov		ah, 02h		; coloca o caracter lido no ecra
			mov		dl, al
			inc		POSx		;Direita
			int		21H	
			goto_xy	POSx,POSy
			
			jmp		LER_SETA_NOMES

			


CONFIRMA_NOME:
			mov 	ch, Menu_nomes
			cmp 	ch, 2
			je      COMECA_JOGO
			cmp     ch, 1
			je		CONFIRMA_JOGADOR2
			cmp 	ch, 0
			je		CONFIRMA_JOGADOR1
			jmp		fim


COMECA_JOGO:
			;passar para o ficheiro do jogo

			jmp 	fim
CONFIRMA_JOGADOR2:
			jmp 	CICLO

CONFIRMA_JOGADOR1:
			jmp 	CICLO

DELETE:
			mov		ah, 09h		; Function: Write character with attribute
			mov		al, 20h		; ASCII code for space
			mov		bh, 00h		; Page number (0)
			mov		bl, 07h		; Attribute: white on black
			mov		cx, 0001h	; Number of times to write the character
			int		10h			; Video interrupt
			jmp		CICLO

BLOQUEIA_MOVIMENTO:
			mov 	al, POSx
			cmp 	al, 23
			je 		INCREMENTA_POSX
			cmp 	al, 40
			je 		DECREMENTA_POSX
			jmp     LER_SETA_NOMES
				
INCREMENTA_POSX:
			inc		POSx
			jmp		LER_SETA_NOMES

DECREMENTA_POSX:
			dec		POSx
			jmp		LER_SETA_NOMES

ESTEND:		cmp 	al,48h
			jne		BAIXO
			dec		POSy		;cima
			jmp		CICLO

BAIXO:		cmp		al,50h
			jne		ESQUERDA
			inc 	POSy		;Baixo
			jmp		CICLO

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			dec		POSx		;Esquerda
			jmp		CICLO

DIREITA:
			cmp		al,4Dh
			jne		CICLO
			;jne		LER_SETA 
			inc		POSx		;Direita
			jmp		CICLO

fim:				
			RET
AVATAR		endp


;########################################################################
;Bloquear o personagem num quadrado
BLOQUEIA PROC
			
BLOQ_ESQERDA:

BLOQ_DIREITA:


BLOQ_CIMA:


BLOQ_BAIXO:


fim:	
		RET

BLOQUEIA endp 

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
		call		BLOQUEIA		;Chama a função que vai bloquear o cursor de sair de um espaço
		call		apaga_ecran
		call		IMP_FICH		;Abre o ficheiro de texto
		call 		AVATAR
		goto_xy		0,22
		
		mov			ah,4CH
		INT			21H
Main	endp
Cseg	ends
end	Main