; Autor reseni: Václav Sovák xsovakv00

; Projekt 2 - INP 2024
; Vigenerova sifra na architekture MIPS64

; DATA SEGMENT
                .data
msg:            .asciiz "vaclavsovak" ; sem doplnte vase "jmenoprijmeni"
cipher:         .space  31 ; misto pro zapis zasifrovaneho textu
key:            .asciiz "sov" ;klic pro sifrovani stringu
; zde si muzete nadefinovat vlastni promenne ci konstanty,
; napr. hodnoty posuvu pro jednotlive znaky sifrovacho klice

params_sys5:    .space  8 ; misto pro ulozeni adresy pocatku
                          ; retezce pro vypis pomoci syscall 5
                          ; (viz nize "funkce" print_string)

; CODE SEGMENT
                .text

main:           ; ZDE NAHRADTE KOD VASIM RESENIM
                daddi   r3, r0, msg     ; registr pro zpravu k zasifrovani (vaclavsovak)
                daddi   r4, r0, cipher  ; registr pro budouci sifru
                daddi   r5, r0, key     ; registr pro klic (sov)
                daddi   r6, r0, 3       ; delka klice
                daddi   r8, r0, 0       ; ukazatel na char v klici
                daddi   r9, r0, 0       ; nahradni registr
                daddi   r10, r0, 26     ; dylka abecedy

                daddi   r11, r0, 0      ; misto pro prvni charakter ze zpravy
                daddi   r12, r0, 0      ; misto pro prvni charakter z klice
                daddi   r13, r0, 0      ; misto pro posunuty charakter o klic
                daddi   r15, r0, 1      ; skace mezi 0 & 1 podle toho se rozhoduje odcitani nebo scitani
                daddi   r16, r0, 0      ; registr pro kontrolu intervalu (-∞ ; 0˃

encrypt_loop:
                lb      r11, 0(r3)              ; nacte charakter ukazatele na zpravu
                beqz    r11, end                ; pokud je charakter 0, ukonci cyklus
                lb      r12, 0(r5)              ; nacte charakter ukazatele z klice

                daddi     r11, r11, -96         ; prevede pismeno z ascii hodnoty na 1 - 26
                daddi     r12, r12, -96         ; to same pro charakter z klice 1 - 26

                beqz    r15, minus              ; pokud je registr (soucet | rozdil) nula, preskoci na krok minus (bude se odcitat)
                daddi   r15, r0, 0              ; pokud neskoci tak nastavi do registru nulu, aby se priste skocilo
                add     r13, r11, r12           ; secte klic a zpravu dohromady a ulozi do r13

                j after                         ; skoci na after (vyhne se rozdilu)
minus:
                daddi   r15, r0, 1              ; nastavi registr (soucet | rozdil) na 1 (bude se scitat)
                dsub    r13, r11, r12           ; odecte klic od zpravy a ulozi do r13

after:
                ddiv    r13, r10                ; modulo 26 pro detekci preteceni
                mfhi    r13                     ; ziska zbytek po deleni z registru HI

                slti    r16, r13, 1             ; rozhodne (ANO|NE)(1|0) jestli je hodnota v r13 mensi nez 1 (-∞ ; 0˃
                beqz    r16, no_adding          ; pokud je v r16 nula tak preskoci pricteni 26
                daddi   r13, r13, 26            ; neskocil, takze se pricte 26
no_adding:
                daddi   r13, r13, 96            ; prevede hodnotu sifrovaneho charakteru na ascii hodnotu
                sb      r13, 0(r4)              ; ulozi hodnotu do registru r4

                daddi   r3, r3, 1               ; inkrementuje ukazatel na dalsi charakter ve zprave
                daddi   r4, r4, 1               ; inkrementuje ukazatel na dalsi charakter sifry
                daddi   r8, r8, 1               ; inkrementuje ukazatel klice

                ddiv    r8, r6                  ; provede modulo klice s delkou klice
                mfhi    r8                      ; zbytek ulozi do r8

                daddi   r5, r0, key             ; nejprve resetujeme ukazatel na klic
                dadd    r5, r5, r8              ; nacte zbytek jako ukazatel na klic (zajisten cyklismus)
                j       encrypt_loop            ; skoci na pocatek cyklu (zpracovava dalsi charakter)

end:
                daddi   r4, r0, cipher          ; ukazatel na zacatek sifry
                jal     print_string            ; vypis pomoci print_string - viz nize

; NASLEDUJICI KOD NEMODIFIKUJTE!

                syscall 0   ; halt

print_string:   ; adresa retezce se ocekava v r4
                sw      r4, params_sys5(r0)
                daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
                syscall 5   ; systemova procedura - vypis retezce na terminal
                jr      r31 ; return - r31 je urcen na return address
