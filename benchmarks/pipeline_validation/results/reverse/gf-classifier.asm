
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

0000000019360660 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1020>:
    19360660:	55                   	push   rbp
    19360661:	48 89 e5             	mov    rbp,rsp
    19360664:	41 57                	push   r15
    19360666:	41 56                	push   r14
    19360668:	53                   	push   rbx
    19360669:	48 83 ec 28          	sub    rsp,0x28
    1936066d:	48 8d 05 6c ca 73 05 	lea    rax,[rip+0x573ca6c]        # 1ea9d0e0 <_GLOBAL_OFFSET_TABLE_>
    19360674:	0f b7 4f 1a          	movzx  ecx,WORD PTR [rdi+0x1a]
    19360678:	48 ba 9a 80 bd e3 ff 	movabs rdx,0xffffffffe3bd809a
    1936067f:	ff ff ff 
    19360682:	48 8d 34 10          	lea    rsi,[rax+rdx*1]
    19360686:	41 b8 12 01 00 00    	mov    r8d,0x112
    1936068c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    19360690:	49 89 f1             	mov    r9,rsi
    19360693:	4c 89 c6             	mov    rsi,r8
    19360696:	48 d1 ee             	shr    rsi,1
    19360699:	49 89 f2             	mov    r10,rsi
    1936069c:	49 f7 d2             	not    r10
    1936069f:	4d 01 c2             	add    r10,r8
    193606a2:	66 41 39 0c b1       	cmp    WORD PTR [r9+rsi*4],cx
    193606a7:	4c 0f 43 d6          	cmovae r10,rsi
    193606ab:	49 8d 74 b1 04       	lea    rsi,[r9+rsi*4+0x4]
    193606b0:	49 0f 43 f1          	cmovae rsi,r9
    193606b4:	4d 89 d0             	mov    r8,r10
    193606b7:	4d 85 d2             	test   r10,r10
    193606ba:	75 d4                	jne    19360690 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1050>
    193606bc:	48 01 d0             	add    rax,rdx
    193606bf:	48 05 48 04 00 00    	add    rax,0x448
    193606c5:	48 39 c6             	cmp    rsi,rax
    193606c8:	74 09                	je     193606d3 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1093>
    193606ca:	66 3b 0e             	cmp    cx,WORD PTR [rsi]
    193606cd:	0f 83 9c 00 00 00    	jae    1936076f <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x112f>
    193606d3:	8d 81 1b ff ff ff    	lea    eax,[rcx-0xe5]
    193606d9:	66 83 f8 f5          	cmp    ax,0xfff5
    193606dd:	0f 83 a6 04 00 00    	jae    19360b89 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1549>
    193606e3:	66 b8 9f 01          	mov    ax,0x19f
    193606e7:	81 f9 66 01 00 00    	cmp    ecx,0x166
    193606ed:	0f 8f e3 00 00 00    	jg     193607d6 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1196>
    193606f3:	ff c9                	dec    ecx
    193606f5:	81 f9 a4 00 00 00    	cmp    ecx,0xa4
    193606fb:	0f 87 f9 00 00 00    	ja     193607fa <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x11ba>
    19360701:	48 8d 05 80 7f 4b f0 	lea    rax,[rip+0xfffffffff04b7f80]        # 9818688 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0x96c>
    19360708:	48 63 0c 88          	movsxd rcx,DWORD PTR [rax+rcx*4]
    1936070c:	48 01 c1             	add    rcx,rax
    1936070f:	ff e1                	jmp    rcx
    19360711:	48 89 fb             	mov    rbx,rdi
    19360714:	e8 a7 f6 5c 00       	call   1992fdc0 <_ZNK3xla9jellyfish14LloInstruction10latch_modeEv>
    19360719:	41 89 c6             	mov    r14d,eax
    1936071c:	88 45 d8             	mov    BYTE PTR [rbp-0x28],al
    1936071f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19360722:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    19360726:	48 8b 78 10          	mov    rdi,QWORD PTR [rax+0x10]
    1936072a:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    1936072d:	41 0f b6 de          	movzx  ebx,r14b
    19360731:	89 de                	mov    esi,ebx
    19360733:	ff 90 38 03 00 00    	call   QWORD PTR [rax+0x338]
    19360739:	84 c0                	test   al,al
    1936073b:	0f 84 93 04 00 00    	je     19360bd4 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1594>
    19360741:	41 80 fe 34          	cmp    r14b,0x34
    19360745:	0f 83 4f 05 00 00    	jae    19360c9a <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x165a>
    1936074b:	48 b8 03 0c 00 00 00 	movabs rax,0xf000000000c03
    19360752:	00 0f 00 
    19360755:	48 0f a3 d8          	bt     rax,rbx
    19360759:	0f 83 3b 05 00 00    	jae    19360c9a <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x165a>
    1936075f:	48 8d 05 9a 82 4b f0 	lea    rax,[rip+0xfffffffff04b829a]        # 9818a00 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xce4>
    19360766:	0f b7 04 58          	movzx  eax,WORD PTR [rax+rbx*2]
    1936076a:	e9 19 01 00 00       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    1936076f:	0f b7 46 02          	movzx  eax,WORD PTR [rsi+0x2]
    19360773:	e9 10 01 00 00       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360778:	48 89 fb             	mov    rbx,rdi
    1936077b:	e8 40 f6 5c 00       	call   1992fdc0 <_ZNK3xla9jellyfish14LloInstruction10latch_modeEv>
    19360780:	41 89 c6             	mov    r14d,eax
    19360783:	88 45 d8             	mov    BYTE PTR [rbp-0x28],al
    19360786:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19360789:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    1936078d:	48 8b 78 10          	mov    rdi,QWORD PTR [rax+0x10]
    19360791:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    19360794:	41 0f b6 de          	movzx  ebx,r14b
    19360798:	89 de                	mov    esi,ebx
    1936079a:	ff 90 38 03 00 00    	call   QWORD PTR [rax+0x338]
    193607a0:	84 c0                	test   al,al
    193607a2:	0f 84 10 04 00 00    	je     19360bb8 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1578>
    193607a8:	41 80 fe 34          	cmp    r14b,0x34
    193607ac:	0f 83 05 05 00 00    	jae    19360cb7 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1677>
    193607b2:	48 b8 03 0c 00 00 00 	movabs rax,0xf000000000c03
    193607b9:	00 0f 00 
    193607bc:	48 0f a3 d8          	bt     rax,rbx
    193607c0:	0f 83 f1 04 00 00    	jae    19360cb7 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1677>
    193607c6:	48 8d 05 9b 82 4b f0 	lea    rax,[rip+0xfffffffff04b829b]        # 9818a68 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xd4c>
    193607cd:	0f b7 04 58          	movzx  eax,WORD PTR [rax+rbx*2]
    193607d1:	e9 b2 00 00 00       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    193607d6:	81 f9 67 01 00 00    	cmp    ecx,0x167
    193607dc:	0f 84 cf 01 00 00    	je     193609b1 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1371>
    193607e2:	81 f9 6b 01 00 00    	cmp    ecx,0x16b
    193607e8:	0f 84 14 01 00 00    	je     19360902 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x12c2>
    193607ee:	81 f9 ac 01 00 00    	cmp    ecx,0x1ac
    193607f4:	0f 84 8e 00 00 00    	je     19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    193607fa:	48 8d 35 0c d3 a2 ed 	lea    rsi,[rip+0xffffffffeda2d30c]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360801:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360805:	49 89 fe             	mov    r14,rdi
    19360808:	48 89 df             	mov    rdi,rbx
    1936080b:	ba fb 02 00 00       	mov    edx,0x2fb
    19360810:	e8 c1 ee 71 04       	call   1da7f6d6 <_ZN4absl12log_internal15LogMessageFatalC1EPKci>
    19360815:	48 8d 35 a1 57 50 ef 	lea    rsi,[rip+0xffffffffef5057a1]        # 8865fbd <nilstr+0x170cd9>
    1936081c:	48 89 df             	mov    rdi,rbx
    1936081f:	e8 8c 6d 36 f3       	call   c6c75b0 <_ZN4absl12log_internal10LogMessagelsILi26EEERS1_RAT__Kc>
    19360824:	41 0f b7 4e 1a       	movzx  ecx,WORD PTR [r14+0x1a]
    19360829:	e9 10 05 00 00       	jmp    19360d3e <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x16fe>
    1936082e:	49 89 ff             	mov    r15,rdi
    19360831:	e8 8a 04 5d 00       	call   19930cc0 <_ZNK3xla9jellyfish14LloInstruction18matmul_data_formatEv>
    19360836:	fe c8                	dec    al
    19360838:	3c 0a                	cmp    al,0xa
    1936083a:	0f 83 94 04 00 00    	jae    19360cd4 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1694>
    19360840:	0f b6 c0             	movzx  eax,al
    19360843:	b9 07 03 00 00       	mov    ecx,0x307
    19360848:	0f a3 c1             	bt     ecx,eax
    1936084b:	0f 83 83 04 00 00    	jae    19360cd4 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1694>
    19360851:	48 8d 0d 94 81 4b f0 	lea    rcx,[rip+0xfffffffff04b8194]        # 98189ec <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xcd0>
    19360858:	eb 2a                	jmp    19360884 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1244>
    1936085a:	49 89 ff             	mov    r15,rdi
    1936085d:	e8 5e 04 5d 00       	call   19930cc0 <_ZNK3xla9jellyfish14LloInstruction18matmul_data_formatEv>
    19360862:	fe c8                	dec    al
    19360864:	3c 0a                	cmp    al,0xa
    19360866:	0f 83 7d 04 00 00    	jae    19360ce9 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x16a9>
    1936086c:	0f b6 c0             	movzx  eax,al
    1936086f:	b9 03 03 00 00       	mov    ecx,0x303
    19360874:	0f a3 c1             	bt     ecx,eax
    19360877:	0f 83 6c 04 00 00    	jae    19360ce9 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x16a9>
    1936087d:	48 8d 0d 54 81 4b f0 	lea    rcx,[rip+0xfffffffff04b8154]        # 98189d8 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xcbc>
    19360884:	0f b7 04 41          	movzx  eax,WORD PTR [rcx+rax*2]
    19360888:	48 83 c4 28          	add    rsp,0x28
    1936088c:	5b                   	pop    rbx
    1936088d:	41 5e                	pop    r14
    1936088f:	41 5f                	pop    r15
    19360891:	5d                   	pop    rbp
    19360892:	c3                   	ret
    19360893:	e8 18 f1 5c 00       	call   1992f9b0 <_ZNK3xla9jellyfish14LloInstruction3iarEv>
    19360898:	48 b9 ff ff ff ff 01 	movabs rcx,0x1ffffffff
    1936089f:	00 00 00 
    193608a2:	48 21 c1             	and    rcx,rax
    193608a5:	48 b8 00 00 00 00 01 	movabs rax,0x100000000
    193608ac:	00 00 00 
    193608af:	31 d2                	xor    edx,edx
    193608b1:	48 39 c1             	cmp    rcx,rax
    193608b4:	0f 95 c2             	setne  dl
    193608b7:	8d 04 55 69 01 00 00 	lea    eax,[rdx*2+0x169]
    193608be:	eb c8                	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    193608c0:	e8 eb f0 5c 00       	call   1992f9b0 <_ZNK3xla9jellyfish14LloInstruction3iarEv>
    193608c5:	48 b9 ff ff ff ff 01 	movabs rcx,0x1ffffffff
    193608cc:	00 00 00 
    193608cf:	48 21 c1             	and    rcx,rax
    193608d2:	48 ba 00 00 00 00 01 	movabs rdx,0x100000000
    193608d9:	00 00 00 
    193608dc:	31 c0                	xor    eax,eax
    193608de:	48 39 d1             	cmp    rcx,rdx
    193608e1:	0f 95 c0             	setne  al
    193608e4:	05 ab 01 00 00       	add    eax,0x1ab
    193608e9:	eb 9d                	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    193608eb:	48 89 fb             	mov    rbx,rdi
    193608ee:	e8 ad 3c 43 fc       	call   157945a0 <_ZNK3xla9jellyfish14LloInstruction24set_permute_pattern_modeEv>
    193608f3:	48 89 df             	mov    rdi,rbx
    193608f6:	83 f8 04             	cmp    eax,0x4
    193608f9:	73 07                	jae    19360902 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x12c2>
    193608fb:	0d 4c 01 00 00       	or     eax,0x14c
    19360900:	eb 86                	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360902:	e8 f9 87 fe ff       	call   19349100 <_ZN3xla9jellyfish14LloInstruction9FromValueINS0_8LloValueEQsr3stdE7same_asIT_S3_EEEPKS1_PKS4_>
    19360907:	48 89 c7             	mov    rdi,rax
    1936090a:	e8 71 68 5d 00       	call   19937180 <_ZNK3xla9jellyfish14LloInstruction10comparisonEv>
    1936090f:	48 89 45 d8          	mov    QWORD PTR [rbp-0x28],rax
    19360913:	66 89 55 e0          	mov    WORD PTR [rbp-0x20],dx
    19360917:	48 89 c1             	mov    rcx,rax
    1936091a:	48 c1 e9 20          	shr    rcx,0x20
    1936091e:	48 83 f9 04          	cmp    rcx,0x4
    19360922:	0f 84 6c 01 00 00    	je     19360a94 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1454>
    19360928:	83 f9 08             	cmp    ecx,0x8
    1936092b:	0f 84 4c 01 00 00    	je     19360a7d <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x143d>
    19360931:	83 f9 0b             	cmp    ecx,0xb
    19360934:	0f 85 24 04 00 00    	jne    19360d5e <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x171e>
    1936093a:	3c 06                	cmp    al,0x6
    1936093c:	0f 83 1c 04 00 00    	jae    19360d5e <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x171e>
    19360942:	48 8d 0d 87 81 4b f0 	lea    rcx,[rip+0xfffffffff04b8187]        # 9818ad0 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xdb4>
    19360949:	0f b6 c0             	movzx  eax,al
    1936094c:	e9 33 ff ff ff       	jmp    19360884 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1244>
    19360951:	e8 5a f0 5c 00       	call   1992f9b0 <_ZNK3xla9jellyfish14LloInstruction3iarEv>
    19360956:	48 0f ba e0 20       	bt     rax,0x20
    1936095b:	0f 83 bd 02 00 00    	jae    19360c1e <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x15de>
    19360961:	83 f8 01             	cmp    eax,0x1
    19360964:	66 b8 b4 01          	mov    ax,0x1b4
    19360968:	66 83 d8 00          	sbb    ax,0x0
    1936096c:	e9 17 ff ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360971:	e8 3a f0 5c 00       	call   1992f9b0 <_ZNK3xla9jellyfish14LloInstruction3iarEv>
    19360976:	48 0f ba e0 20       	bt     rax,0x20
    1936097b:	0f 83 bc 02 00 00    	jae    19360c3d <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x15fd>
    19360981:	83 f8 01             	cmp    eax,0x1
    19360984:	66 b8 b2 01          	mov    ax,0x1b2
    19360988:	66 83 d8 00          	sbb    ax,0x0
    1936098c:	e9 f7 fe ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360991:	e8 1a f0 5c 00       	call   1992f9b0 <_ZNK3xla9jellyfish14LloInstruction3iarEv>
    19360996:	48 0f ba e0 20       	bt     rax,0x20
    1936099b:	0f 83 bb 02 00 00    	jae    19360c5c <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x161c>
    193609a1:	83 f8 01             	cmp    eax,0x1
    193609a4:	66 b8 b0 01          	mov    ax,0x1b0
    193609a8:	66 83 d8 00          	sbb    ax,0x0
    193609ac:	e9 d7 fe ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    193609b1:	e8 4a 87 fe ff       	call   19349100 <_ZN3xla9jellyfish14LloInstruction9FromValueINS0_8LloValueEQsr3stdE7same_asIT_S3_EEEPKS1_PKS4_>
    193609b6:	48 89 c7             	mov    rdi,rax
    193609b9:	e8 c2 67 5d 00       	call   19937180 <_ZNK3xla9jellyfish14LloInstruction10comparisonEv>
    193609be:	48 89 45 d8          	mov    QWORD PTR [rbp-0x28],rax
    193609c2:	66 89 55 e0          	mov    WORD PTR [rbp-0x20],dx
    193609c6:	48 89 c1             	mov    rcx,rax
    193609c9:	48 c1 e9 20          	shr    rcx,0x20
    193609cd:	83 c1 fd             	add    ecx,0xfffffffd
    193609d0:	83 f9 0d             	cmp    ecx,0xd
    193609d3:	0f 87 f2 03 00 00    	ja     19360dcb <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x178b>
    193609d9:	48 8d 35 50 7f 4b f0 	lea    rsi,[rip+0xfffffffff04b7f50]        # 9818930 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xc14>
    193609e0:	48 63 0c 8e          	movsxd rcx,DWORD PTR [rsi+rcx*4]
    193609e4:	48 01 f1             	add    rcx,rsi
    193609e7:	ff e1                	jmp    rcx
    193609e9:	3c 06                	cmp    al,0x6
    193609eb:	0f 83 da 03 00 00    	jae    19360dcb <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x178b>
    193609f1:	83 e0 07             	and    eax,0x7
    193609f4:	48 8d 0d 11 81 4b f0 	lea    rcx,[rip+0xfffffffff04b8111]        # 9818b0c <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xdf0>
    193609fb:	0f b6 04 08          	movzx  eax,BYTE PTR [rax+rcx*1]
    193609ff:	e9 84 fe ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360a04:	e8 a7 ef 5c 00       	call   1992f9b0 <_ZNK3xla9jellyfish14LloInstruction3iarEv>
    19360a09:	48 b9 ff ff ff ff 01 	movabs rcx,0x1ffffffff
    19360a10:	00 00 00 
    19360a13:	48 21 c1             	and    rcx,rax
    19360a16:	48 ba 00 00 00 00 01 	movabs rdx,0x100000000
    19360a1d:	00 00 00 
    19360a20:	31 c0                	xor    eax,eax
    19360a22:	48 39 d1             	cmp    rcx,rdx
    19360a25:	0f 95 c0             	setne  al
    19360a28:	05 ad 01 00 00       	add    eax,0x1ad
    19360a2d:	e9 56 fe ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360a32:	e8 79 ef 5c 00       	call   1992f9b0 <_ZNK3xla9jellyfish14LloInstruction3iarEv>
    19360a37:	48 0f ba e0 20       	bt     rax,0x20
    19360a3c:	0f 83 39 02 00 00    	jae    19360c7b <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x163b>
    19360a42:	31 c9                	xor    ecx,ecx
    19360a44:	85 c0                	test   eax,eax
    19360a46:	0f 95 c1             	setne  cl
    19360a49:	8d 04 4d 6d 01 00 00 	lea    eax,[rcx*2+0x16d]
    19360a50:	e9 33 fe ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360a55:	e8 a6 f2 5c 00       	call   1992fd00 <_ZNK3xla9jellyfish14LloInstruction11vxpose_modeEv>
    19360a5a:	88 45 d8             	mov    BYTE PTR [rbp-0x28],al
    19360a5d:	3c 04                	cmp    al,0x4
    19360a5f:	77 53                	ja     19360ab4 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1474>
    19360a61:	0f b6 c0             	movzx  eax,al
    19360a64:	48 8d 0d b1 7e 4b f0 	lea    rcx,[rip+0xfffffffff04b7eb1]        # 981891c <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xc00>
    19360a6b:	48 63 04 81          	movsxd rax,DWORD PTR [rcx+rax*4]
    19360a6f:	48 01 c8             	add    rax,rcx
    19360a72:	ff e0                	jmp    rax
    19360a74:	66 b8 51 01          	mov    ax,0x151
    19360a78:	e9 0b fe ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360a7d:	3c 06                	cmp    al,0x6
    19360a7f:	0f 83 d9 02 00 00    	jae    19360d5e <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x171e>
    19360a85:	48 8d 0d 5c 80 4b f0 	lea    rcx,[rip+0xfffffffff04b805c]        # 9818ae8 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xdcc>
    19360a8c:	0f b6 c0             	movzx  eax,al
    19360a8f:	e9 f0 fd ff ff       	jmp    19360884 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1244>
    19360a94:	3c 06                	cmp    al,0x6
    19360a96:	0f 83 c2 02 00 00    	jae    19360d5e <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x171e>
    19360a9c:	48 8d 0d 39 80 4b f0 	lea    rcx,[rip+0xfffffffff04b8039]        # 9818adc <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xdc0>
    19360aa3:	0f b6 c0             	movzx  eax,al
    19360aa6:	e9 d9 fd ff ff       	jmp    19360884 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1244>
    19360aab:	66 b8 55 01          	mov    ax,0x155
    19360aaf:	e9 d4 fd ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360ab4:	66 b8 9f 01          	mov    ax,0x19f
    19360ab8:	e9 cb fd ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360abd:	66 b8 53 01          	mov    ax,0x153
    19360ac1:	e9 c2 fd ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360ac6:	84 d2                	test   dl,dl
    19360ac8:	0f 84 91 00 00 00    	je     19360b5f <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x151f>
    19360ace:	3c 06                	cmp    al,0x6
    19360ad0:	0f 83 9d 02 00 00    	jae    19360d73 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1733>
    19360ad6:	83 e0 07             	and    eax,0x7
    19360ad9:	48 8d 0d 14 80 4b f0 	lea    rcx,[rip+0xfffffffff04b8014]        # 9818af4 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xdd8>
    19360ae0:	0f b6 04 08          	movzx  eax,BYTE PTR [rax+rcx*1]
    19360ae4:	e9 9f fd ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360ae9:	3c 06                	cmp    al,0x6
    19360aeb:	0f 83 82 02 00 00    	jae    19360d73 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1733>
    19360af1:	83 e0 07             	and    eax,0x7
    19360af4:	48 8d 0d 05 80 4b f0 	lea    rcx,[rip+0xfffffffff04b8005]        # 9818b00 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xde4>
    19360afb:	0f b6 04 08          	movzx  eax,BYTE PTR [rax+rcx*1]
    19360aff:	e9 84 fd ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360b04:	84 d2                	test   dl,dl
    19360b06:	74 6c                	je     19360b74 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1534>
    19360b08:	3c 06                	cmp    al,0x6
    19360b0a:	0f 83 63 02 00 00    	jae    19360d73 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1733>
    19360b10:	83 e0 07             	and    eax,0x7
    19360b13:	48 8d 0d e0 7f 4b f0 	lea    rcx,[rip+0xfffffffff04b7fe0]        # 9818afa <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xdde>
    19360b1a:	0f b6 04 08          	movzx  eax,BYTE PTR [rax+rcx*1]
    19360b1e:	e9 65 fd ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360b23:	8d 48 fe             	lea    ecx,[rax-0x2]
    19360b26:	80 f9 04             	cmp    cl,0x4
    19360b29:	0f 83 44 02 00 00    	jae    19360d73 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1733>
    19360b2f:	c0 e1 04             	shl    cl,0x4
    19360b32:	48 b8 f1 00 f0 00 f3 	movabs rax,0xf200f300f000f1
    19360b39:	00 f2 00 
    19360b3c:	48 d3 e8             	shr    rax,cl
    19360b3f:	e9 44 fd ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360b44:	3c 06                	cmp    al,0x6
    19360b46:	0f 83 27 02 00 00    	jae    19360d73 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1733>
    19360b4c:	83 e0 07             	and    eax,0x7
    19360b4f:	48 8d 0d b0 7f 4b f0 	lea    rcx,[rip+0xfffffffff04b7fb0]        # 9818b06 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xdea>
    19360b56:	0f b6 04 08          	movzx  eax,BYTE PTR [rax+rcx*1]
    19360b5a:	e9 29 fd ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360b5f:	48 89 c1             	mov    rcx,rax
    19360b62:	31 c0                	xor    eax,eax
    19360b64:	80 f9 04             	cmp    cl,0x4
    19360b67:	0f 94 c0             	sete   al
    19360b6a:	0d e6 00 00 00       	or     eax,0xe6
    19360b6f:	e9 14 fd ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360b74:	48 89 c1             	mov    rcx,rax
    19360b77:	31 c0                	xor    eax,eax
    19360b79:	80 f9 04             	cmp    cl,0x4
    19360b7c:	0f 94 c0             	sete   al
    19360b7f:	0d fc 00 00 00       	or     eax,0xfc
    19360b84:	e9 ff fc ff ff       	jmp    19360888 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1248>
    19360b89:	48 8d 35 bd bb 8f ed 	lea    rsi,[rip+0xffffffffed8fbbbd]        # 6c5c74d <anon.de66683854b989ac240da9b5830f09df.25.llvm.14521404311210802531+0x105a14>
    19360b90:	48 8d 0d 18 8c 3e ef 	lea    rcx,[rip+0xffffffffef3e8c18]        # 87497af <nilstr+0x544cb>
    19360b97:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360b9b:	48 89 df             	mov    rdi,rbx
    19360b9e:	ba 7c 04 00 00       	mov    edx,0x47c
    19360ba3:	e8 3e eb 71 04       	call   1da7f6e6 <_ZN4absl12log_internal15LogMessageFatalC1EPKciS3_>
    19360ba8:	48 89 df             	mov    rdi,rbx
    19360bab:	e8 50 3d 43 04       	call   1d794900 <_ZN4absl12log_internal10LogMessage5FlushEv>
    19360bb0:	48 89 df             	mov    rdi,rbx
    19360bb3:	e8 98 eb 71 04       	call   1da7f750 <_ZN4absl12log_internal15LogMessageFatalD1Ev>
    19360bb8:	48 8d 35 4e cf a2 ed 	lea    rsi,[rip+0xffffffffeda2cf4e]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360bbf:	48 8d 0d 55 9f 3a ef 	lea    rcx,[rip+0xffffffffef3a9f55]        # 870ab1b <nilstr+0x15837>
    19360bc6:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360bca:	48 89 df             	mov    rdi,rbx
    19360bcd:	ba 07 02 00 00       	mov    edx,0x207
    19360bd2:	eb 1a                	jmp    19360bee <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x15ae>
    19360bd4:	48 8d 35 32 cf a2 ed 	lea    rsi,[rip+0xffffffffeda2cf32]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360bdb:	48 8d 0d 39 9f 3a ef 	lea    rcx,[rip+0xffffffffef3a9f39]        # 870ab1b <nilstr+0x15837>
    19360be2:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360be6:	48 89 df             	mov    rdi,rbx
    19360be9:	ba ee 01 00 00       	mov    edx,0x1ee
    19360bee:	e8 f3 ea 71 04       	call   1da7f6e6 <_ZN4absl12log_internal15LogMessageFatalC1EPKciS3_>
    19360bf3:	48 8d 35 78 f8 4f ef 	lea    rsi,[rip+0xffffffffef4ff878]        # 8860472 <nilstr+0x16b18e>
    19360bfa:	48 89 df             	mov    rdi,rbx
    19360bfd:	e8 6e 97 46 f3       	call   c7ca370 <_ZN4absl12log_internal10LogMessagelsILi28EEERS1_RAT__Kc>
    19360c02:	48 8d 75 d8          	lea    rsi,[rbp-0x28]
    19360c06:	48 89 c7             	mov    rdi,rax
    19360c09:	e8 02 d5 5f fc       	call   1595e110 <_ZN4absl12log_internal10LogMessagelsIN3xla9jellyfish13GainLatchModeEEERS1_RKT_>
    19360c0e:	48 89 c7             	mov    rdi,rax
    19360c11:	e8 ea 3c 43 04       	call   1d794900 <_ZN4absl12log_internal10LogMessage5FlushEv>
    19360c16:	48 89 df             	mov    rdi,rbx
    19360c19:	e8 32 eb 71 04       	call   1da7f750 <_ZN4absl12log_internal15LogMessageFatalD1Ev>
    19360c1e:	48 8d 35 e8 ce a2 ed 	lea    rsi,[rip+0xffffffffeda2cee8]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360c25:	48 8d 0d 2f e5 3f ef 	lea    rcx,[rip+0xffffffffef3fe52f]        # 875f15b <nilstr+0x69e77>
    19360c2c:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360c30:	48 89 df             	mov    rdi,rbx
    19360c33:	ba 5c 02 00 00       	mov    edx,0x25c
    19360c38:	e9 66 ff ff ff       	jmp    19360ba3 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1563>
    19360c3d:	48 8d 35 c9 ce a2 ed 	lea    rsi,[rip+0xffffffffeda2cec9]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360c44:	48 8d 0d 10 e5 3f ef 	lea    rcx,[rip+0xffffffffef3fe510]        # 875f15b <nilstr+0x69e77>
    19360c4b:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360c4f:	48 89 df             	mov    rdi,rbx
    19360c52:	ba 68 02 00 00       	mov    edx,0x268
    19360c57:	e9 47 ff ff ff       	jmp    19360ba3 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1563>
    19360c5c:	48 8d 35 aa ce a2 ed 	lea    rsi,[rip+0xffffffffeda2ceaa]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360c63:	48 8d 0d f1 e4 3f ef 	lea    rcx,[rip+0xffffffffef3fe4f1]        # 875f15b <nilstr+0x69e77>
    19360c6a:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360c6e:	48 89 df             	mov    rdi,rbx
    19360c71:	ba 62 02 00 00       	mov    edx,0x262
    19360c76:	e9 28 ff ff ff       	jmp    19360ba3 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1563>
    19360c7b:	48 8d 35 8b ce a2 ed 	lea    rsi,[rip+0xffffffffeda2ce8b]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360c82:	48 8d 0d d2 e4 3f ef 	lea    rcx,[rip+0xffffffffef3fe4d2]        # 875f15b <nilstr+0x69e77>
    19360c89:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360c8d:	48 89 df             	mov    rdi,rbx
    19360c90:	ba 6e 02 00 00       	mov    edx,0x26e
    19360c95:	e9 09 ff ff ff       	jmp    19360ba3 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1563>
    19360c9a:	48 8d 35 6c ce a2 ed 	lea    rsi,[rip+0xffffffffeda2ce6c]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360ca1:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360ca5:	48 89 df             	mov    rdi,rbx
    19360ca8:	ba fe 01 00 00       	mov    edx,0x1fe
    19360cad:	e8 24 ea 71 04       	call   1da7f6d6 <_ZN4absl12log_internal15LogMessageFatalC1EPKci>
    19360cb2:	e9 3c ff ff ff       	jmp    19360bf3 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x15b3>
    19360cb7:	48 8d 35 4f ce a2 ed 	lea    rsi,[rip+0xffffffffeda2ce4f]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360cbe:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360cc2:	48 89 df             	mov    rdi,rbx
    19360cc5:	ba 17 02 00 00       	mov    edx,0x217
    19360cca:	e8 07 ea 71 04       	call   1da7f6d6 <_ZN4absl12log_internal15LogMessageFatalC1EPKci>
    19360ccf:	e9 1f ff ff ff       	jmp    19360bf3 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x15b3>
    19360cd4:	48 8d 35 32 ce a2 ed 	lea    rsi,[rip+0xffffffffeda2ce32]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360cdb:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360cdf:	48 89 df             	mov    rdi,rbx
    19360ce2:	ba e4 01 00 00       	mov    edx,0x1e4
    19360ce7:	eb 13                	jmp    19360cfc <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x16bc>
    19360ce9:	48 8d 35 1d ce a2 ed 	lea    rsi,[rip+0xffffffffeda2ce1d]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360cf0:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360cf4:	48 89 df             	mov    rdi,rbx
    19360cf7:	ba d1 01 00 00       	mov    edx,0x1d1
    19360cfc:	e8 d5 e9 71 04       	call   1da7f6d6 <_ZN4absl12log_internal15LogMessageFatalC1EPKci>
    19360d01:	48 8d 35 4a 55 4b ef 	lea    rsi,[rip+0xffffffffef4b554a]        # 8816252 <nilstr+0x120f6e>
    19360d08:	48 89 df             	mov    rdi,rbx
    19360d0b:	e8 e0 99 a6 f3       	call   cdca6f0 <_ZN4absl12log_internal10LogMessagelsILi21EEERS1_RAT__Kc>
    19360d10:	49 89 c6             	mov    r14,rax
    19360d13:	4c 89 ff             	mov    rdi,r15
    19360d16:	e8 a5 ff 5c 00       	call   19930cc0 <_ZNK3xla9jellyfish14LloInstruction18matmul_data_formatEv>
    19360d1b:	88 45 e7             	mov    BYTE PTR [rbp-0x19],al
    19360d1e:	48 8d 75 e7          	lea    rsi,[rbp-0x19]
    19360d22:	4c 89 f7             	mov    rdi,r14
    19360d25:	e8 76 d7 d9 f5       	call   f0fe4a0 <_ZN4absl12log_internal10LogMessagelsIN3xla9jellyfish16MatmulDataFormatEEERS1_RKT_>
    19360d2a:	48 8d 35 0b ec 4f ef 	lea    rsi,[rip+0xffffffffef4fec0b]        # 885f93c <nilstr+0x16a658>
    19360d31:	48 89 c7             	mov    rdi,rax
    19360d34:	e8 a7 69 41 f3       	call   c7776e0 <_ZN4absl12log_internal10LogMessagelsILi14EEERS1_RAT__Kc>
    19360d39:	41 0f b7 4f 1a       	movzx  ecx,WORD PTR [r15+0x1a]
    19360d3e:	66 89 4d d8          	mov    WORD PTR [rbp-0x28],cx
    19360d42:	48 8d 75 d8          	lea    rsi,[rbp-0x28]
    19360d46:	48 89 c7             	mov    rdi,rax
    19360d49:	e8 02 16 50 f5       	call   e862350 <_ZN4absl12log_internal10LogMessagelsIN3xla9jellyfish9LloOpcodeEEERS1_RKT_>
    19360d4e:	48 89 c7             	mov    rdi,rax
    19360d51:	e8 aa 3b 43 04       	call   1d794900 <_ZN4absl12log_internal10LogMessage5FlushEv>
    19360d56:	48 89 df             	mov    rdi,rbx
    19360d59:	e8 f2 e9 71 04       	call   1da7f750 <_ZN4absl12log_internal15LogMessageFatalD1Ev>
    19360d5e:	48 8d 35 a8 cd a2 ed 	lea    rsi,[rip+0xffffffffeda2cda8]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360d65:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360d69:	48 89 df             	mov    rdi,rbx
    19360d6c:	ba 56 02 00 00       	mov    edx,0x256
    19360d71:	eb 6b                	jmp    19360dde <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x179e>
    19360d73:	48 8d 35 93 cd a2 ed 	lea    rsi,[rip+0xffffffffeda2cd93]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360d7a:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360d7e:	48 89 df             	mov    rdi,rbx
    19360d81:	ba c9 02 00 00       	mov    edx,0x2c9
    19360d86:	eb 56                	jmp    19360dde <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x179e>
    19360d88:	48 8d 35 7e cd a2 ed 	lea    rsi,[rip+0xffffffffeda2cd7e]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360d8f:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360d93:	48 89 df             	mov    rdi,rbx
    19360d96:	ba f5 02 00 00       	mov    edx,0x2f5
    19360d9b:	e8 36 e9 71 04       	call   1da7f6d6 <_ZN4absl12log_internal15LogMessageFatalC1EPKci>
    19360da0:	48 8d 35 28 e9 4f ef 	lea    rsi,[rip+0xffffffffef4fe928]        # 885f6cf <nilstr+0x16a3eb>
    19360da7:	48 89 df             	mov    rdi,rbx
    19360daa:	e8 c1 f6 34 f3       	call   c6b0470 <_ZN4absl12log_internal10LogMessagelsILi19EEERS1_RAT__Kc>
    19360daf:	48 8d 75 d8          	lea    rsi,[rbp-0x28]
    19360db3:	48 89 c7             	mov    rdi,rax
    19360db6:	e8 65 d5 4f f6       	call   f85e320 <_ZN4absl12log_internal10LogMessagelsIN3xla9jellyfish10VxposeModeEEERS1_RKT_>
    19360dbb:	48 89 c7             	mov    rdi,rax
    19360dbe:	e8 3d 3b 43 04       	call   1d794900 <_ZN4absl12log_internal10LogMessage5FlushEv>
    19360dc3:	48 89 df             	mov    rdi,rbx
    19360dc6:	e8 85 e9 71 04       	call   1da7f750 <_ZN4absl12log_internal15LogMessageFatalD1Ev>
    19360dcb:	48 8d 35 3b cd a2 ed 	lea    rsi,[rip+0xffffffffeda2cd3b]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    19360dd2:	48 8d 5d c8          	lea    rbx,[rbp-0x38]
    19360dd6:	48 89 df             	mov    rdi,rbx
    19360dd9:	ba db 02 00 00       	mov    edx,0x2db
    19360dde:	e8 f3 e8 71 04       	call   1da7f6d6 <_ZN4absl12log_internal15LogMessageFatalC1EPKci>
    19360de3:	48 8d 35 6e e7 4f ef 	lea    rsi,[rip+0xffffffffef4fe76e]        # 885f558 <nilstr+0x16a274>
    19360dea:	48 89 df             	mov    rdi,rbx
    19360ded:	e8                   	.byte 0xe8
    19360dee:	2e                   	cs
    19360def:	89                   	.byte 0x89
