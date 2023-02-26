.data
	matrix: .space 4
	res: .space 4
	aux: .space 4
	cerinta: .space 4
	dim: .space 4
	n: .space 4
	i: .space 4
	j: .space 4
	k: .space 4
	index: .space 4
	val: .space 4
	nr_leg: .space 404
	lungime_drum: .space 4
	nod_start: .space 4
	nod_final: .space 4
	fs: .asciz "%d"
	fp: .asciz "%d\n"
	new_line: .asciz "\n"
	
.text

matrix_mult:
	pushl %ebp
	movl %esp, %ebp

	pushl %ebx
	pushl %esi
	pushl %edi	
	
	movl 8(%ebp), %esi
	movl 12(%ebp), %edi
	movl 16(%ebp), %ebx
	subl $16, %esp
	
	# -16(%ebp) = i
	# -20(%ebp) = j
	# -24(%ebp) = k
	
	movl $0, -16(%ebp)
	for_i_proc:
		movl -16(%ebp), %ecx
		cmpl 20(%ebp), %ecx
		je return
		movl $0, -20(%ebp)
		for_j_proc:
			movl $0, -28(%ebp)
			
			movl -20(%ebp), %ecx
			cmpl 20(%ebp), %ecx
			je reinit_i
			movl $0, -24(%ebp)
			for_k_proc:
				movl -24(%ebp), %ecx
				cmpl 20(%ebp), %ecx
				je reinit_j
				
				movl -16(%ebp), %eax
				xorl %edx, %edx
				mull 20(%ebp)
				addl -24(%ebp), %eax
				movl (%esi, %eax, 4), %ecx
				
				movl -24(%ebp), %eax
				xorl %edx, %edx
				mull 20(%ebp)
				addl -20(%ebp), %eax
				
				movl (%edi, %eax, 4), %eax
				xorl %edx, %edx
				mull %ecx
				addl %eax, -28(%ebp)
				
				incl -24(%ebp)
				jmp for_k_proc
			reinit_j:
				movl -16(%ebp), %eax
				xorl %edx, %edx
				mull 20(%ebp)
				addl -20(%ebp), %eax
				
				movl -28(%ebp), %ecx
				movl %ecx, (%ebx, %eax, 4)
				
				incl -20(%ebp)
				jmp for_j_proc
		reinit_i:
			incl -16(%ebp)
			jmp for_i_proc
	
	return:		
		addl $16, %esp
		popl %edi
		popl %esi
		popl %ebx
		popl %ebp
		ret
.global main
main:
	pushl $cerinta
	pushl $fs
	call scanf
	addl $8, %esp
	
	pushl $n
	pushl $fs
	call scanf
	addl $8, %esp
		
	xorl %edx, %edx
	movl n, %eax         
	mull n
	movl $4, %ebx
	mull %ebx
	movl %eax, dim

# spatiul pentru matricea de adiacenta
#######################################################################
	movl $192, %eax		# EAX = codul apelului de sistem mmap2
	movl $0, %ebx		# EBX = adresa de inceput pentru alocarea memoriei
	movl dim, %ecx		# ECX = dimensiunea matricei de long-uri (n * n * 4)
	movl $0x3, %edx		# EDX = protectie PROT_READ | PROT_WRITE (putem sa scriem si sa citim in spatiul alocat)
	movl $0x22, %esi	# ESI = flag pentru MAP_PRIVATE | MAP_ANON / MAP_ANONYMOUS (MAP_PRIVATE -> memoria alocata nu va fi utilizata de catre alte procese, MAP_ANON -> este creat un spatiu anonim de memorie)
	 
	movl $-1, %edi		# EDI = -1, deoarece nu exista file descriptor daca avem MAP_ANON
	movl $0, %ebp		# EBP = 0, argumentul offset este setat la 0 daca avem MAP_ANON
	int $0x80
	
	movl %eax, matrix	# adresa spatiului alocat se afla in EAX, asa ca trebuie mutata in variabila corespunzatoare matricei
	
# spatiul pentru matricea rezultat res
#######################################################################

	movl $192, %eax		
	movl $0, %ebx
	movl dim, %ecx		
	movl $0x3, %edx		
	movl $0x22, %esi	
	movl $-1, %edi		
	movl $0, %ebp
	int $0x80
	
	movl %eax, res

# spatiul pentru matricea auxiliara aux
#######################################################################
	
	movl $192, %eax		
	movl $0, %ebx
	movl dim, %ecx
	movl $0x3, %edx		
	movl $0x22, %esi	
	movl $-1, %edi		
	movl $0, %ebp
	int $0x80
	
	movl %eax, aux
#######################################################################
	
	xorl %ecx, %ecx
	movl %ecx, index
	
	citire_nr_leg:
		movl index, %ecx
		cmpl n, %ecx
		je citire_leg
		
		lea nr_leg, %esi
		movl index, %eax
		xorl %edx, %edx
		movl $4, %ebx
		mull %ebx
		addl %eax, %esi
		
		pusha
		pushl %esi
		pushl $fs
		call scanf
		addl $8, %esp
		popa
		
		incl index
		jmp citire_nr_leg
	
	citire_leg:
		movl $0, i
		for_i_1:
			movl i, %ecx
			cmpl n, %ecx
			je solve_cerinta3
			movl $0, j
			for_j_1:
				movl j, %edx
				cmpl nr_leg( , %ecx, 4), %edx
				je reinit1
				
				pusha
				pushl $val
				pushl $fs
				call scanf
				addl $8, %esp
				popa
				
				movl i, %eax
				xorl %edx, %edx
				mull n
				addl val, %eax
				mov matrix, %esi
				movl $1, (%esi, %eax, 4)
				
				incl j
				jmp for_j_1
			reinit1:
				incl i
				jmp for_i_1
		
	solve_cerinta3:
		citire:
			pushl $lungime_drum
			pushl $fs
			call scanf
			addl $8, %esp
				
			pushl $nod_start
			pushl $fs
			call scanf
			addl $8, %esp
				
			pushl $nod_final
			pushl $fs
			call scanf
			addl $8, %esp
			
		prep_matrice_aux:
				movl $0, i
				for_i_2:
					movl i, %ecx
					cmpl n, %ecx
					je inmultire
					movl $0, j
					for_j_2:
						movl j, %ecx
						cmpl n, %ecx
						je reinit2
						
						movl i, %eax
						xorl %edx, %edx
						mull n
						addl j, %eax
						mov matrix, %esi
						mov aux, %edi
						movl (%esi, %eax, 4), %ebx
						movl %ebx, (%edi, %eax, 4)
						
						incl j
						jmp for_j_2
						
					reinit2:
						incl i
						jmp for_i_2
			inmultire:
				decl lungime_drum
				movl $0, index
				for_i_3:
					movl index, %ecx
					cmpl lungime_drum, %ecx
					je afisare
					
					pushl n
					pushl res
					pushl aux
					pushl matrix
					call matrix_mult
					addl $16, %esp
					
					copiere:
						movl $0, i
						for_i_4:
							movl i, %ecx
							cmpl n, %ecx
							je reinit3
							movl $0, j
							for_j_4:
								movl j, %ecx
								cmpl n, %ecx
								je reinit4
								movl i, %eax
								xorl %edx, %edx
								mull n
								addl j, %eax
								mov res, %esi
								mov aux, %edi
								movl (%esi, %eax, 4), %ebx
								movl %ebx, (%edi, %eax, 4)
								
								incl j
								jmp for_j_4
							reinit4:
								incl i
								jmp for_i_4
					reinit3:
						incl index
						jmp for_i_3
				
	afisare:
		movl nod_start, %eax
		xorl %edx, %edx
		mull n
		addl nod_final, %eax
		mov res, %esi
		movl (%esi, %eax, 4), %ebx
		pushl %ebx
		pushl $fp
		call printf
		addl $8, %esp
		
		pushl $0
		call fflush
		addl $4, %esp
			
exit:
	movl $1, %eax
	xorl %ebx, %ebx
	int $0x80	
