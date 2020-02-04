.MODEL small
.DATA
	string DB "Zadatak 2", 10, '$'
	unosmsg DB "Unesite 10 brojeva:", 10, '$'
	rezmsg DB "Srednja vrednost (celobrojni deo) je: $"
	ostatak DB "Ostatak srednje vrednosti je: $"
	elementi DB "Elementi niza su:", 10, '$'
	
	niz DB 10 DUP (0)
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


;; ucitaj broj sa tastature u ax
scan_ax proc near
	push dx
	xor dx, dx		; rezultat je u pocetku 0
	
scan_byte:
	mov ah, 01h		; ucitamo karakter
	int 21h
	
	cmp al, 0Dh		; proverimo je li karakter novi red
	je kraj			; ako jeste, uneli smo ceo broj
	
	; da bismo pomnozili dx sa 10 moramo da ga kopiramo u ax
	push ax			; sacuvamo ax jer cemo da ga menjamo
	mov ax, dx		; kopiramo dx u ax da bismo ga pomnozili
	mov dx, 10		
	mul dx			; mnozimo ax sa 10
	mov dx, ax		; i rezultat vracamo u dx
	pop ax			; vracamo sacuvanu (nepromenjenu) vrednost ax-a nazad
	
	sub al, '0'		; pretvaramo karakter u cifru
	add dl, al		; dodamo dobijenu cifru na rezultat
	jmp scan_byte	; ucitavamo sledeci karakter
	
kraj:
	mov ax, dx		; dobijeni rezultat stavljamo u ax
	pop dx			; dx vracamo na vrednost pre poziva procedure
	ret

scan_ax endp


; racuna srednju vrednost i ispisuje rezultat
srednja_vrednost proc near
	mov dx, 10			; delimo sa 10
	div dl
	
	xor dx, dx			; postavljamo ceo dx na 0
	mov dl, ah			; nize bite postavljamo na ostatak od deljenja
	xor ah, ah			; vise bite ax stavljamo na 0,
						; tako nam u ax ostaje samo rezultat deljenja
	
	push ax
	push dx
	
	; poruka za srednju vrednost
	lea dx, rezmsg
	mov ah, 09h
	int 21h

	pop dx
	pop ax
	
	call print_ax		; ispisujemo kolicnik
	
	mov ax, dx			; u ax stavljamo ostatak deljenja

	push ax
	
	; poruka za ostatak
	lea dx, ostatak
	mov ah, 09h
	int 21h

	pop ax

	call print_ax		; ispisujemo ostatak
	
	ret

srednja_vrednost endp


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
	
	; poruka za unos brojeva
	lea dx, unosmsg
	mov ah, 09h
	int 21h
	
	xor cx, cx			; postavljamo brojac na nulu
	xor dx, dx			; postavljamo sumu na nulu
	
unos_broja:
	cmp cx, 10			; proveravamo je li zavrsena petlja
	je kraj_unosa		; ako jese, prekidamo unos
	
	call scan_ax		; unosimo broj
	mov di, cx			; u di smestamo indeks niza
	mov niz[di], al		; na niz[index] ubacujemo uneti broj (1 bajt)
	
	add dx, ax
	
	inc cx				; uvecavamo brojac
	jmp unos_broja
	
kraj_unosa:
	mov ax, dx			; stavi rezultat u ax, i ispisi ga pomocu procedure
	call srednja_vrednost

	; poruka za ispis elemenata
	lea dx, elementi
	mov ah, 09h
	int 21h
	
	xor cx, cx			; pocetna vrednost brojaca je 0
	xor ax, ax			; postavimo ax na 0 jer koristimo samo deo registra
	
ispis_brojeva:
	cmp cx, 10			; proveravamo je li zavrsena petlja
	je kraj_ispisa		; ako jese, prekidamo unos
	
	mov si, cx			; u si smestamo indeks niza
	mov al, niz[si]		; u al citamo element niza sa indeksa (1 bajt)
	call print_ax		; ispisujemo element
	
	inc cx				; uvecavamo brojac
	jmp ispis_brojeva
	
kraj_ispisa:
	
	; kraj programa
	mov ax, 4c00h
	int 21h
	
end Start