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
                daddi   r4, r0, msg ; vozrovy vypis: adresa msg do r4
                daddi   r5, r0, cipher
                daddi   r6, r0, key ; adresa klice do r6
                daddi   r7, r0, 3   ; delka klice
                daddi   r8, r0, 0   ; pocitadlo cyklu
                daddi   r9, r0, 0   ; index na klici
                daddi   r10, r0, 0  ; pricteni 0/odecteni = 1
                daddi   r11, r0, 26 ; hodnota preteceni

encrypt_loop:
                lb r12, 0(r4)
                beqz r12, end

                lb r13, 0(r6)

                sub r12, r12, 97    ;konvertujeme char na pozici v abecede 0...25(a...z)
                sub r13, r13, 97    ;konvertujeme char na pozici v abecede 0...25(a...z)

                add r15, r12, r13   ;charakter posunuty o sifru v r15

                div r15, r15, 26    ;konvertuje preteceni na index v abecede
                add r15, r15, 97

                sb r15, 0(r5)

                daddi r4, r4, 1
                daddi r5, r5, 1

                daddi r9, r9, 1

                div r9, r7
                mfhi r9

                daddi r6, r0, key
                dadd  r6, r6, r9

                j encrypt_loop

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
