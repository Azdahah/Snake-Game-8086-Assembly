bits 16
org 100h

		call hide_cursor
	start:
		call start_playing
		call show_game_over
		jmp start

    delay:
    mov ah, 0          
    int 1Ah
    mov bx, dx          

    .wait_tick:
    mov ah, 0
    int 1Ah
    sub dx, bx
    cmp dx, 2      
    jb .wait_tick
    ret 
    
    play_tone:
    push dx
    push bx

    mov bx, 65535      
    div ax                
    mov bx, dx

    mov al, bl
    out 42h, al
    mov al, bh
    out 42h, al

    in al, 61h
    or al, 03h
    out 61h, al


.wait:
    loop .wait

 
    in al, 61h
    and al, 0FCh
    out 61h, al

    pop bx
    pop dx
    ret

	exit_process:
			mov ah, 4ch
			int 21h
			ret

	buffer_clear:
			mov bx, 0
		.next:	
			mov byte [buffer + bx], ' '
			inc bx
			cmp bx, 2000
			jnz .next
			ret
		
	
	buffer_write:
		mov di, buffer
		mov al, 80
		mul dl
		add ax, cx
		add di, ax
		mov byte [di], bl
		ret

	buffer_read:
		mov di, buffer
		mov al, 80
		mul dl
		add ax, cx
		add di, ax
		mov bl, [di]
		ret
	
	buffer_print_string:
		.next:
			mov al, [si]
			cmp al, 0
			jz .end
			mov byte [buffer + di], al
			inc di
			inc si
			jmp .next
		.end:
			ret
		
    draw_border:
    mov di, 0
.top_bottom:
    mov byte [buffer + 3*80 + di], 196   
    mov byte [buffer + 24*80 + di], 196    
    inc di
    cmp di, 80
    jne .top_bottom

    ; ----- left & right -----
    mov di, 3*80
.sides:
    mov byte [buffer + di], 179            ; left
    mov byte [buffer + di + 79], 179       ; right
    add di, 80
    cmp di, 24*80
    jne .sides

    ; ----- corners -----
    mov byte [buffer + 3*80], 218         ; +
    mov byte [buffer + 3*80 + 79], 191     ; +
    mov byte [buffer + 24*80], 192         ; +
    mov byte [buffer + 24*80 + 79], 217    ; +  
    ret                           

print_score:
    ; ---- print label ----
    mov si, .text
    mov di, 2*80 + 33        ; row 2, centered
    call buffer_print_string

    ; ---- print digits (fixed width) ----
    mov ax, [score]
    mov cx, 6               ; number of digits
    mov di, 2*80 + 41 + 5   ; RIGHTMOST digit position

.next_digit:
    xor dx, dx
    mov bx, 10
    div bx                  ; AX = AX / 10, DX = remainder
    add dl, '0'
    mov [buffer + di], dl
    dec di
    loop .next_digit
    ret

.text:
    db " SCORE: ", 0


	update_snake_direction:
			mov ah, 1
			int 16h
			jz .end
			mov ah, 0h ; retrieve key from buffer
			int 16h
			cmp al, 27 ; ESC
			jz exit_process
			cmp ah, 48h ; up
			jz .up
			cmp ah, 50h ; down
			jz .down
			cmp ah, 4bh; left
			jz .left
			cmp ah, 4dh; right
			jz .right
			jmp update_snake_direction
		.up:
			mov byte [s_dir], 8
			jmp update_snake_direction
		.down:
			mov byte [s_dir], 4
			jmp update_snake_direction
		.left:
			mov byte [s_dir], 2
			jmp update_snake_direction
		.right:
			mov byte [s_dir], 1
			jmp update_snake_direction
		.end:
			ret
		
	update_snake_head:
			mov al, [s_y]
			mov byte [s_py], al
			mov al, [s_x]
			mov byte [s_px], al
			mov ah, [s_dir]
			cmp ah, 8 
			jz .up
			cmp ah, 4 
			jz .down
			cmp ah, 2
			jz .left
			cmp ah, 1
			jz .right
		.up:
			dec word [s_y]
			jmp .end
		.down:
			inc word [s_y]
			jmp .end
		.left:
			dec word [s_x]
			jmp .end
		.right:
			inc word [s_x]
		.end:
			mov bl, [s_dir]
			mov ch, 0
			mov cl, [s_px]
			mov dl, [s_py]
			call buffer_write
			ret

	check_snake_new_position:
			mov ch, 0
			mov cl, [s_x]
			mov dh, 0
			mov dl, [s_y]
			call buffer_read
			cmp bl, 8
			jle .set_game_over
			cmp bl, '*'
			je .food
			cmp bl, ' '
			je .empty_space
		.set_game_over:
			cmp al, 1
			mov byte [is_game_over], al 
		.write_new_head:
			mov bl, 1
			mov ch, 0
			mov cl, [s_x]
			mov ch, 0
			mov dl, [s_y]
			call buffer_write
			ret
		.food:
			inc dword [score]   
			mov ax, 800       
            mov cx, 20000     
            call play_tone

			call .write_new_head
			call create_food
			jmp .end
		.empty_space:
			call update_snake_tail
			call .write_new_head
		.end:
			ret

	update_snake_tail:
			mov al, [s_ty]
			mov byte [s_tpy], al
			mov al, [s_tx]
			mov byte [s_tpx], al
			mov ch, 0
			mov cl, [s_tx]
			mov dh, 0
			mov dl, [s_ty]
			call buffer_read
			cmp bl, 8 ; up
			jz .up
			cmp bl, 4 ; down
			jz .down
			cmp bl, 2; left
			jz .left
			cmp bl, 1; right
			jz .right
			jmp exit_process
		.up:
			dec word [s_ty]
			jmp .end
		.down:
			inc word [s_ty]
			jmp .end
		.left:
			dec word [s_tx]
			jmp .end
		.right:
			inc word [s_tx]
		.end:
			mov bl, ' '
			mov ch, 0
			mov cl, [s_tpx]
			mov ch, 0
			mov dl, [s_tpy]
			call buffer_write
		ret

	create_initial_foods:
			mov cx, 10
		.again:
			push cx
			call create_food
			pop cx
			loop .again

	
create_food:
.try_again:
    mov ah, 0
    int 1Ah

    mov ax, dx
    and ax, 0FFFh
    mul dx
    mov dx, ax

    mov ax, dx
    mov cx, 2000
    xor dx, dx
    div cx
    mov bx, dx          

    mov ax, bx
    mov dx, 0
    mov cx, 80
    div cx              

    cmp ax, 4           
    jb .try_again
    cmp ax, 23          
    ja .try_again
    cmp dx, 1           
    jb .try_again
    cmp dx, 78          
    ja .try_again
    ; ---------------------------------------

    mov al, [buffer + bx]
    cmp al, ' '
    jnz .try_again

    mov byte [buffer + bx], '*'
    ret


	reset:
			mov ax, 0
			mov word [score], ax
			mov byte [is_game_over], al
			mov al, 8
			mov byte [s_dir], al
			mov al, 40
			mov byte [s_x], al
			mov byte [s_px], al
			mov byte [s_tpx], al
			mov byte [s_tx], al
			mov al, 15
			mov byte [s_y], al
			mov byte [s_py], al
			mov byte [s_ty], al
			mov byte [s_tpy], al
			ret

	start_playing:
			call reset		
			call buffer_clear
			call draw_border
			call create_initial_foods
		.main_loop:
			mov si, 2
			call delay
		
			call update_snake_direction
			call update_snake_head
			call check_snake_new_position
			call print_score
			call buffer_render
		
			mov al, [is_game_over]
			cmp al, 0
			jz .main_loop
			ret

	                   
	show_game_over:   
	            
            mov ax, 400            
            mov cx, 65535           
            call play_tone
            mov ax, 300             
            mov cx, 65535
            call play_tone          

			mov si, .text_1
			mov di, 880 + 32
			call buffer_print_string
			mov si, .text_2
			mov di, 960 + 32
			call buffer_print_string
			mov si, .text_1
			mov di, 1040 + 32
			call buffer_print_string
			call buffer_render
			mov si, 48
			call delay
			call clear_keyboard_buffer
			mov ah, 0
			int 16h
			ret
		.text_1:
			db "               ", 0
		.text_2:
			db "   GAME OVER NOOB  ", 0 
	buffer_render:
			mov ax, 0b800h
			mov es, ax
			mov di, buffer
			mov si, 0
		.next:
			mov bl, [di]
			cmp bl, 8
			jz .is_snake
			cmp bl, 4
			jz .is_snake
			cmp bl, 2
			jz .is_snake
			cmp bl, 1
			jz .is_snake
			
            
			mov bh, 02h          ; white on black
            jmp .write
		.is_snake:
			mov bl, 219        ; snake block
            mov bh, 0Ah
            jmp .write     
		.write:
			mov byte [es:si], bl
			mov byte [es:si+1], bh
			inc di
			add si, 2
			cmp si, 4000
			jnz .next
			ret
hide_cursor:
			mov ah, 02h
			mov bh, 0
			mov dh, 25
			mov dl, 0
			int 10h
			ret

	clear_keyboard_buffer:
			mov ah, 1
			int 16h
			jz .end
			mov ah, 0h 
			int 16h
			jmp clear_keyboard_buffer
		.end:
			ret
section .bss
		score resw 1
		is_game_over resb 1
		s_dir resb 1
		s_x resb 1
		s_y resb 1
		s_px resb 1
		s_py resb 1
		s_tx resb 1
		s_ty resb 1
		s_tpx resb 1
		s_tpy resb 1

		buffer resb 2000




