
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

00000000193615b0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1f70>:
    193615b0:	55                   	push   rbp
    193615b1:	48 89 e5             	mov    rbp,rsp
    193615b4:	41 57                	push   r15
    193615b6:	41 56                	push   r14
    193615b8:	41 55                	push   r13
    193615ba:	41 54                	push   r12
    193615bc:	53                   	push   rbx
    193615bd:	48 81 ec 18 01 00 00 	sub    rsp,0x118
    193615c4:	48 c7 07 00 00 00 00 	mov    QWORD PTR [rdi],0x0
    193615cb:	48 8d 47 10          	lea    rax,[rdi+0x10]
    193615cf:	48 89 85 48 ff ff ff 	mov    QWORD PTR [rbp-0xb8],rax
    193615d6:	48 c7 47 10 00 00 00 	mov    QWORD PTR [rdi+0x10],0x0
    193615dd:	00 
    193615de:	48 8d 47 20          	lea    rax,[rdi+0x20]
    193615e2:	48 89 85 d8 fe ff ff 	mov    QWORD PTR [rbp-0x128],rax
    193615e9:	48 c7 47 20 00 00 00 	mov    QWORD PTR [rdi+0x20],0x0
    193615f0:	00 
    193615f1:	48 c7 47 30 00 00 00 	mov    QWORD PTR [rdi+0x30],0x0
    193615f8:	00 
    193615f9:	48 8d 47 40          	lea    rax,[rdi+0x40]
    193615fd:	48 89 85 d0 fe ff ff 	mov    QWORD PTR [rbp-0x130],rax
    19361604:	48 89 bd 40 ff ff ff 	mov    QWORD PTR [rbp-0xc0],rdi
    1936160b:	48 c7 47 40 01 00 00 	mov    QWORD PTR [rdi+0x40],0x1
    19361612:	00 
    19361613:	31 d2                	xor    edx,edx
    19361615:	31 c0                	xor    eax,eax
    19361617:	4c 8b ad 40 ff ff ff 	mov    r13,QWORD PTR [rbp-0xc0]
    1936161e:	e9 a0 05 00 00       	jmp    19361bc3 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x2583>
    19361623:	66 66 66 66 2e 0f 1f 	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
    1936162a:	84 00 00 00 00 00 
    19361630:	b3 07                	mov    bl,0x7
    19361632:	41 b7 05             	mov    r15b,0x5
    19361635:	41 c1 e4 18          	shl    r12d,0x18
    19361639:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    1936163d:	c7 45 84 01 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x1
    19361644:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    19361647:	c7 45 8c 01 00 00 00 	mov    DWORD PTR [rbp-0x74],0x1
    1936164e:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    19361652:	c7 45 94 02 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x2
    19361659:	c6 45 98 0a          	mov    BYTE PTR [rbp-0x68],0xa
    1936165d:	c7 45 9c 07 00 00 00 	mov    DWORD PTR [rbp-0x64],0x7
    19361664:	48 8d 45 80          	lea    rax,[rbp-0x80]
    19361668:	48 89 85 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],rax
    1936166f:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x4
    19361676:	04 00 00 00 
    1936167a:	41 8d bc 24 01 00 01 	lea    edi,[r12+0x10001]
    19361681:	00 
    19361682:	48 8d b5 50 ff ff ff 	lea    rsi,[rbp-0xb0]
    19361689:	48 8d 15 48 72 ed 04 	lea    rdx,[rip+0x4ed7248]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    19361690:	4c 89 e9             	mov    rcx,r13
    19361693:	e8 58 13 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    19361698:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    1936169c:	c7 45 84 03 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x3
    193616a3:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    193616a6:	c7 45 8c 02 00 00 00 	mov    DWORD PTR [rbp-0x74],0x2
    193616ad:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    193616b1:	c7 45 94 04 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x4
    193616b8:	4c 8d 75 80          	lea    r14,[rbp-0x80]
    193616bc:	4c 89 b5 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],r14
    193616c3:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x3
    193616ca:	03 00 00 00 
    193616ce:	41 8d bc 24 01 01 01 	lea    edi,[r12+0x10101]
    193616d5:	00 
    193616d6:	48 8d b5 50 ff ff ff 	lea    rsi,[rbp-0xb0]
    193616dd:	48 8d 15 f4 71 ed 04 	lea    rdx,[rip+0x4ed71f4]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    193616e4:	4c 89 e9             	mov    rcx,r13
    193616e7:	e8 04 13 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    193616ec:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    193616f0:	c7 45 84 03 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x3
    193616f7:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    193616fa:	c7 45 8c 02 00 00 00 	mov    DWORD PTR [rbp-0x74],0x2
    19361701:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    19361705:	c7 45 94 04 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x4
    1936170c:	c6 45 98 0a          	mov    BYTE PTR [rbp-0x68],0xa
    19361710:	c7 45 9c 09 00 00 00 	mov    DWORD PTR [rbp-0x64],0x9
    19361717:	4c 89 b5 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],r14
    1936171e:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x4
    19361725:	04 00 00 00 
    19361729:	41 8d bc 24 02 00 01 	lea    edi,[r12+0x10002]
    19361730:	00 
    19361731:	48 8d b5 50 ff ff ff 	lea    rsi,[rbp-0xb0]
    19361738:	4c 8d 35 99 71 ed 04 	lea    r14,[rip+0x4ed7199]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    1936173f:	4c 89 f2             	mov    rdx,r14
    19361742:	4c 89 e9             	mov    rcx,r13
    19361745:	e8 a6 12 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    1936174a:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    1936174e:	c7 45 84 07 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x7
    19361755:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    19361758:	c7 45 8c 06 00 00 00 	mov    DWORD PTR [rbp-0x74],0x6
    1936175f:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    19361763:	c7 45 94 08 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x8
    1936176a:	48 8d 45 80          	lea    rax,[rbp-0x80]
    1936176e:	48 89 85 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],rax
    19361775:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x3
    1936177c:	03 00 00 00 
    19361780:	41 8d bc 24 02 01 01 	lea    edi,[r12+0x10102]
    19361787:	00 
    19361788:	48 8d b5 50 ff ff ff 	lea    rsi,[rbp-0xb0]
    1936178f:	4c 89 f2             	mov    rdx,r14
    19361792:	4c 89 e9             	mov    rcx,r13
    19361795:	e8 56 12 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    1936179a:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    1936179e:	c7 45 84 03 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x3
    193617a5:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    193617a8:	c7 45 8c 02 00 00 00 	mov    DWORD PTR [rbp-0x74],0x2
    193617af:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    193617b3:	c7 45 94 04 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x4
    193617ba:	c6 45 98 0a          	mov    BYTE PTR [rbp-0x68],0xa
    193617be:	c7 45 9c 09 00 00 00 	mov    DWORD PTR [rbp-0x64],0x9
    193617c5:	48 8d 45 80          	lea    rax,[rbp-0x80]
    193617c9:	48 89 85 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],rax
    193617d0:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x4
    193617d7:	04 00 00 00 
    193617db:	41 8d bc 24 0a 00 01 	lea    edi,[r12+0x1000a]
    193617e2:	00 
    193617e3:	4c 8d b5 50 ff ff ff 	lea    r14,[rbp-0xb0]
    193617ea:	4c 89 f6             	mov    rsi,r14
    193617ed:	48 8d 15 e4 70 ed 04 	lea    rdx,[rip+0x4ed70e4]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    193617f4:	4c 89 e9             	mov    rcx,r13
    193617f7:	e8 f4 11 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    193617fc:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    19361800:	c7 45 84 07 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x7
    19361807:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    1936180a:	c7 45 8c 06 00 00 00 	mov    DWORD PTR [rbp-0x74],0x6
    19361811:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    19361815:	c7 45 94 08 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x8
    1936181c:	48 8d 45 80          	lea    rax,[rbp-0x80]
    19361820:	48 89 85 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],rax
    19361827:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x3
    1936182e:	03 00 00 00 
    19361832:	41 8d bc 24 0a 01 01 	lea    edi,[r12+0x1010a]
    19361839:	00 
    1936183a:	4c 89 f6             	mov    rsi,r14
    1936183d:	48 8d 15 94 70 ed 04 	lea    rdx,[rip+0x4ed7094]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    19361844:	4c 89 e9             	mov    rcx,r13
    19361847:	e8 a4 11 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    1936184c:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    19361850:	c7 45 84 03 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x3
    19361857:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    1936185a:	c7 45 8c 02 00 00 00 	mov    DWORD PTR [rbp-0x74],0x2
    19361861:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    19361865:	c7 45 94 04 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x4
    1936186c:	c6 45 98 0a          	mov    BYTE PTR [rbp-0x68],0xa
    19361870:	c7 45 9c 09 00 00 00 	mov    DWORD PTR [rbp-0x64],0x9
    19361877:	4c 8d 75 80          	lea    r14,[rbp-0x80]
    1936187b:	4c 89 b5 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],r14
    19361882:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x4
    19361889:	04 00 00 00 
    1936188d:	41 8d bc 24 09 00 01 	lea    edi,[r12+0x10009]
    19361894:	00 
    19361895:	48 8d b5 50 ff ff ff 	lea    rsi,[rbp-0xb0]
    1936189c:	48 8d 15 35 70 ed 04 	lea    rdx,[rip+0x4ed7035]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    193618a3:	4c 89 e9             	mov    rcx,r13
    193618a6:	e8 45 11 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    193618ab:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    193618af:	c7 45 84 07 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x7
    193618b6:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    193618b9:	c7 45 8c 06 00 00 00 	mov    DWORD PTR [rbp-0x74],0x6
    193618c0:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    193618c4:	c7 45 94 08 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x8
    193618cb:	4c 89 b5 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],r14
    193618d2:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x3
    193618d9:	03 00 00 00 
    193618dd:	41 8d bc 24 09 01 01 	lea    edi,[r12+0x10109]
    193618e4:	00 
    193618e5:	48 8d b5 50 ff ff ff 	lea    rsi,[rbp-0xb0]
    193618ec:	48 8d 15 e5 6f ed 04 	lea    rdx,[rip+0x4ed6fe5]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    193618f3:	4c 89 e9             	mov    rcx,r13
    193618f6:	e8 f5 10 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    193618fb:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    193618ff:	c7 45 84 01 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x1
    19361906:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    19361909:	c7 45 8c 01 00 00 00 	mov    DWORD PTR [rbp-0x74],0x1
    19361910:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    19361914:	c7 45 94 02 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x2
    1936191b:	c6 45 98 0a          	mov    BYTE PTR [rbp-0x68],0xa
    1936191f:	c7 45 9c 07 00 00 00 	mov    DWORD PTR [rbp-0x64],0x7
    19361926:	4c 89 b5 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],r14
    1936192d:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x4
    19361934:	04 00 00 00 
    19361938:	41 8d bc 24 01 00 03 	lea    edi,[r12+0x30001]
    1936193f:	00 
    19361940:	48 8d b5 50 ff ff ff 	lea    rsi,[rbp-0xb0]
    19361947:	49 89 f6             	mov    r14,rsi
    1936194a:	48 8d 15 87 6f ed 04 	lea    rdx,[rip+0x4ed6f87]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    19361951:	4c 89 e9             	mov    rcx,r13
    19361954:	e8 97 10 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    19361959:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    1936195d:	c7 45 84 03 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x3
    19361964:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    19361967:	c7 45 8c 02 00 00 00 	mov    DWORD PTR [rbp-0x74],0x2
    1936196e:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    19361972:	c7 45 94 04 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x4
    19361979:	48 8d 45 80          	lea    rax,[rbp-0x80]
    1936197d:	48 89 85 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],rax
    19361984:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x3
    1936198b:	03 00 00 00 
    1936198f:	41 8d bc 24 01 01 03 	lea    edi,[r12+0x30101]
    19361996:	00 
    19361997:	4c 89 f6             	mov    rsi,r14
    1936199a:	48 8d 15 37 6f ed 04 	lea    rdx,[rip+0x4ed6f37]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    193619a1:	4c 89 e9             	mov    rcx,r13
    193619a4:	e8 47 10 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    193619a9:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    193619ad:	c7 45 84 03 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x3
    193619b4:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    193619b7:	c7 45 8c 02 00 00 00 	mov    DWORD PTR [rbp-0x74],0x2
    193619be:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    193619c2:	c7 45 94 04 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x4
    193619c9:	c6 45 98 0a          	mov    BYTE PTR [rbp-0x68],0xa
    193619cd:	c7 45 9c 09 00 00 00 	mov    DWORD PTR [rbp-0x64],0x9
    193619d4:	4c 8d 75 80          	lea    r14,[rbp-0x80]
    193619d8:	4c 89 b5 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],r14
    193619df:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x4
    193619e6:	04 00 00 00 
    193619ea:	41 8d bc 24 02 00 03 	lea    edi,[r12+0x30002]
    193619f1:	00 
    193619f2:	48 8d b5 50 ff ff ff 	lea    rsi,[rbp-0xb0]
    193619f9:	48 8d 15 d8 6e ed 04 	lea    rdx,[rip+0x4ed6ed8]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    19361a00:	4c 89 e9             	mov    rcx,r13
    19361a03:	e8 e8 0f 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    19361a08:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    19361a0c:	c7 45 84 07 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x7
    19361a13:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    19361a16:	c7 45 8c 06 00 00 00 	mov    DWORD PTR [rbp-0x74],0x6
    19361a1d:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    19361a21:	c7 45 94 08 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x8
    19361a28:	4c 89 b5 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],r14
    19361a2f:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x3
    19361a36:	03 00 00 00 
    19361a3a:	41 8d bc 24 02 01 03 	lea    edi,[r12+0x30102]
    19361a41:	00 
    19361a42:	48 8d b5 50 ff ff ff 	lea    rsi,[rbp-0xb0]
    19361a49:	48 8d 15 88 6e ed 04 	lea    rdx,[rip+0x4ed6e88]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    19361a50:	4c 89 e9             	mov    rcx,r13
    19361a53:	e8 98 0f 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    19361a58:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    19361a5c:	c7 45 84 03 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x3
    19361a63:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    19361a66:	c7 45 8c 02 00 00 00 	mov    DWORD PTR [rbp-0x74],0x2
    19361a6d:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    19361a71:	c7 45 94 04 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x4
    19361a78:	c6 45 98 0a          	mov    BYTE PTR [rbp-0x68],0xa
    19361a7c:	c7 45 9c 09 00 00 00 	mov    DWORD PTR [rbp-0x64],0x9
    19361a83:	4c 89 b5 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],r14
    19361a8a:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x4
    19361a91:	04 00 00 00 
    19361a95:	41 8d bc 24 0a 00 03 	lea    edi,[r12+0x3000a]
    19361a9c:	00 
    19361a9d:	48 8d b5 50 ff ff ff 	lea    rsi,[rbp-0xb0]
    19361aa4:	49 89 f6             	mov    r14,rsi
    19361aa7:	48 8d 15 2a 6e ed 04 	lea    rdx,[rip+0x4ed6e2a]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    19361aae:	4c 89 e9             	mov    rcx,r13
    19361ab1:	e8 3a 0f 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    19361ab6:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    19361aba:	c7 45 84 07 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x7
    19361ac1:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    19361ac4:	c7 45 8c 06 00 00 00 	mov    DWORD PTR [rbp-0x74],0x6
    19361acb:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    19361acf:	c7 45 94 08 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x8
    19361ad6:	48 8d 45 80          	lea    rax,[rbp-0x80]
    19361ada:	48 89 85 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],rax
    19361ae1:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x3
    19361ae8:	03 00 00 00 
    19361aec:	41 8d bc 24 0a 01 03 	lea    edi,[r12+0x3010a]
    19361af3:	00 
    19361af4:	4c 89 f6             	mov    rsi,r14
    19361af7:	48 8d 15 da 6d ed 04 	lea    rdx,[rip+0x4ed6dda]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    19361afe:	4c 89 e9             	mov    rcx,r13
    19361b01:	e8 ea 0e 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    19361b06:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    19361b0a:	c7 45 84 03 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x3
    19361b11:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    19361b14:	c7 45 8c 02 00 00 00 	mov    DWORD PTR [rbp-0x74],0x2
    19361b1b:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    19361b1f:	c7 45 94 04 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x4
    19361b26:	c6 45 98 0a          	mov    BYTE PTR [rbp-0x68],0xa
    19361b2a:	c7 45 9c 09 00 00 00 	mov    DWORD PTR [rbp-0x64],0x9
    19361b31:	48 8d 45 80          	lea    rax,[rbp-0x80]
    19361b35:	48 89 85 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],rax
    19361b3c:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x4
    19361b43:	04 00 00 00 
    19361b47:	41 8d bc 24 09 00 03 	lea    edi,[r12+0x30009]
    19361b4e:	00 
    19361b4f:	4c 89 f6             	mov    rsi,r14
    19361b52:	48 8d 15 7f 6d ed 04 	lea    rdx,[rip+0x4ed6d7f]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    19361b59:	4c 89 e9             	mov    rcx,r13
    19361b5c:	e8 8f 0e 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    19361b61:	44 88 7d 80          	mov    BYTE PTR [rbp-0x80],r15b
    19361b65:	c7 45 84 07 00 00 00 	mov    DWORD PTR [rbp-0x7c],0x7
    19361b6c:	88 5d 88             	mov    BYTE PTR [rbp-0x78],bl
    19361b6f:	c7 45 8c 06 00 00 00 	mov    DWORD PTR [rbp-0x74],0x6
    19361b76:	c6 45 90 08          	mov    BYTE PTR [rbp-0x70],0x8
    19361b7a:	c7 45 94 08 00 00 00 	mov    DWORD PTR [rbp-0x6c],0x8
    19361b81:	48 8d 45 80          	lea    rax,[rbp-0x80]
    19361b85:	48 89 85 50 ff ff ff 	mov    QWORD PTR [rbp-0xb0],rax
    19361b8c:	48 c7 85 58 ff ff ff 	mov    QWORD PTR [rbp-0xa8],0x3
    19361b93:	03 00 00 00 
    19361b97:	41 81 cc 09 01 03 00 	or     r12d,0x30109
    19361b9e:	44 89 e7             	mov    edi,r12d
    19361ba1:	4c 89 f6             	mov    rsi,r14
    19361ba4:	48 8d 15 2d 6d ed 04 	lea    rdx,[rip+0x4ed6d2d]        # 1e2388d8 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0xf0>
    19361bab:	4c 89 e9             	mov    rcx,r13
    19361bae:	e8 3d 0e 00 00       	call   193629f0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x33b0>
    19361bb3:	b8 01 00 00 00       	mov    eax,0x1
    19361bb8:	f6 85 f0 fe ff ff 01 	test   BYTE PTR [rbp-0x110],0x1
    19361bbf:	b2 01                	mov    dl,0x1
    19361bc1:	75 30                	jne    19361bf3 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x25b3>
    19361bc3:	48 8d 0d ea 6f 4b f0 	lea    rcx,[rip+0xfffffffff04b6fea]        # 9818bb4 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xe98>
    19361bca:	44 0f b6 24 08       	movzx  r12d,BYTE PTR [rax+rcx*1]
    19361bcf:	41 83 fc 01          	cmp    r12d,0x1
    19361bd3:	48 89 95 f0 fe ff ff 	mov    QWORD PTR [rbp-0x110],rdx
    19361bda:	0f 84 50 fa ff ff    	je     19361630 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1ff0>
    19361be0:	45 85 e4             	test   r12d,r12d
    19361be3:	0f 85 43 0d 00 00    	jne    1936292c <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x32ec>
    19361be9:	b3 06                	mov    bl,0x6
    19361beb:	41 b7 04             	mov    r15b,0x4
    19361bee:	e9 42 fa ff ff       	jmp    19361635 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1ff5>
