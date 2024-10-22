; Autor reseni: jmeno prijmeni login

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
                daddi   r3, r0, msg ; vozrovy vypis: adresa msg do r4
                daddi   r4, r0, cipher
                daddi   r5, r0, key ; adresa klice do r6
                daddi   r6, r0, 3   ; delka klice
                daddi   r7, r0, 0   ; pocitadlo cyklu
                daddi   r8, r0, 0   ; index na klici
                daddi   r9, r0, 0  ; pricteni 0/odecteni = 1
                daddi   r10, r0, 26 ; hodnota preteceni

                daddi   r11, r0, 0
                daddi   r12, r0, 0
                daddi   r13, r0, 0
                daddi   r15, r0, 1 ; odd even check
                daddi   r16, r0, 0

encrypt_loop:
                lb      r11, 0(r3)          ; Load current character from msg into r11
                beqz    r11, end            ; If the character is null (end of string), exit loop

                lb      r12, 0(r5)          ; Load current key character into r12

                daddi     r11, r11, -96        ; Convert msg character to alphabet index (msg[i] - 'a')
                daddi     r12, r12, -96        ; Convert key character to alphabet index (key[j] - 'a')

                beqz    r15, minus

                daddi   r15, r0, 0
                add     r13, r11, r12       ; Add msg character and key character indices

                j after
minus:
                daddi   r15, r0, 1
                dsub    r13, r11, r12

after:
                ddiv    r13, r10            ; Divide by 26 (apply modulo 26)
                mfhi    r13                 ; Get remainder from division (r13 % 26)



                slti    r16, r13, 1         ; check if r13 is less than 0
                beqz    r16, no_adding
                daddi   r13, r13, 26
no_adding:
                daddi   r13, r13, 96        ; Convert back to ASCII (wrap within alphabet)
                sb      r13, 0(r4)          ; Store ciphered character in the cipher array

                daddi   r3, r3, 1           ; Move to the next character in msg
                daddi   r4, r4, 1           ; Move to the next character in cipher

                daddi   r8, r8, 1           ; Increment the key index

                ddiv    r8, r6              ; r8 = r8 % r6 (wrap the key index)
                mfhi    r8                  ; Get the remainder (r8 % r6)

                daddi   r5, r0, key         ; Reset key pointer to the start of the key
                dadd    r5, r5, r8          ; Adjust key pointer based on the wrapped key index

                j       encrypt_loop        ; Repeat for the next character

end:
                daddi r4, r0, cipher
                jal     print_string ; vypis pomoci print_string - viz nize

; NASLEDUJICI KOD NEMODIFIKUJTE!

                syscall 0   ; halt

print_string:   ; adresa retezce se ocekava v r4
                sw      r4, params_sys5(r0)
                daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
                syscall 5   ; systemova procedura - vypis retezce na terminal
                jr      r31 ; return - r31 je urcen na return address
