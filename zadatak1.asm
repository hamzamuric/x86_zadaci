.MODEL small
.DATA
	string DB "Zadatak 1", 10, '$'
	unosmsg DB "Unesite broj: $"
	rezmsg DB "Dobijeni rezultat je: $"
.STACK
.CODE

;; ispisi broj iz ax na ekran
print_ax proc near
	push ax
	push cx
	push dx
	
	cmp ax, 0	; ako je broj negativan ispisi minus
	jg pozitivan
	
	; ispis minusa
	push ax
	mov dl, '-'
	mov ah, 02h
	int 21h
	pop ax
	
	neg ax		; prebaci negativan broj u pozitivan

pozitivan:
	xor cx, cx	; broj cifara je na pocetku 0
	
lbl:
	mov dx, 10
	div dl		; podeli ax sa 10
	xor dx, dx	; dx = 0
	mov dl, ah	; stavi ostatak u dx
	
	push dx		; ostatak (poslednju cirfu) stavi na stek
	inc cx		; povecaj broj cifara
	xor ah, ah	; gornje bite ax postavi na 0. ax == al
	
	cmp ax, 0	; ako ax nije nula ponovi proces
	jne lbl
	
printing:
	cmp cx, 0	; ako nije ostalo vise cifara, idi na kraj
	je kraj
	
	pop dx		; uzmi jednu cifru
	add dx, '0'	; pretvori cifru u karakter
	mov ah, 02h	; ispisi uzetu cifru
	int 21h
	dec cx		; smanji broj cifara za 1
	jmp printing
	
kraj:
	mov dl, 0Ah	; dodaj novi red
	mov ah, 02h
	int 21h
	
	pop dx
	pop cx
	pop ax
	ret
	
print_ax endp


fact proc near
	push bx
	push cx
	push dx
	
	mov bx, ax	; u bx stavljamo koliko puta ce se petlja izvrsiti
	inc bx
	mov cx, 1	; brojac je na pocetku 1
	mov ax, 1	; rezultat je na pocetku 1
	
calc:
	cmp cx, bx	; ako smo stigli do zeljene vrednosi, prekidamo petlju
	je kraj
	
	mul cx		; pomnozi dosadasnji rezultat sa trenutnim brojacem
	inc cx		; uvecaj brojac
	jmp calc
	
kraj:
	pop dx
	pop cx
	pop bx
	ret
	
fact endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          START          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Start:
	mov ax, @DATA
	mov ds, ax
	
	; pocetna poruka
	lea dx, string
	mov ah, 09h
	int 21h
	
	; poruka za unos broja
	lea dx, unosmsg
	mov ah, 09h
	int 21h
	
	mov ah, 01h			; unosimo karakter
	int 21h
	
	xor bx, bx
	mov bl, al			; prebacujemo ga u bx
	sub bx, '0'			; pretvaramo ga u cifru
	inc bx
	
	mov dl, 0Ah			; ispisujemo novi red posle unete cifre
	mov ah, 02h
	int 21h

	xor dx, dx			; postavljamo rezultat na nulu
	mov cx, 1			; pocetna vrednost brojaca je 1
	
racunanje:
	cmp cx, bx			; ako je petlja zavrsena prekidamo racunanje
	je kraj_racunanja
	
	mov ax, cx			; racunamo faktorijel trenutne vrednosti brojaca
	call fact
	
	push cx
	and cx, 1			; proveravamo je li brojac paran
	jnz nema_minus		; ako nije, rezultat ostaje isti
	neg ax				; ako jeste, negiramo rezultat (rez *= -1)
	
nema_minus:
	pop cx
	add dx, ax			; dodajemo trenutni rezultat na ukupni rezultat
	
	inc cx				; uvecavamo brojac
	jmp racunanje

kraj_racunanja:

	; poruka za rezultat
	push dx
	lea dx, rezmsg
	mov ah, 09h
	int 21h
	pop dx
	
	; ispis rezultata
	mov ax, dx
	call print_ax
	
	; kraj programa
	mov ax, 4c00h
	int 21h
	
end Start