
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

0000000019360ef0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x18b0>:
    19360ef0:	55                   	push   rbp
    19360ef1:	48 89 e5             	mov    rbp,rsp
    19360ef4:	41 57                	push   r15
    19360ef6:	41 56                	push   r14
    19360ef8:	41 55                	push   r13
    19360efa:	41 54                	push   r12
    19360efc:	53                   	push   rbx
    19360efd:	48 83 ec 38          	sub    rsp,0x38
    19360f01:	44 0f b7 76 1a       	movzx  r14d,WORD PTR [rsi+0x1a]
    19360f06:	41 8d 86 17 ff ff ff 	lea    eax,[r14-0xe9]
    19360f0d:	45 31 e4             	xor    r12d,r12d
    19360f10:	66 83 f8 04          	cmp    ax,0x4
    19360f14:	73 12                	jae    19360f28 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x18e8>
    19360f16:	44 89 e0             	mov    eax,r12d
    19360f19:	48 83 c4 38          	add    rsp,0x38
    19360f1d:	5b                   	pop    rbx
    19360f1e:	41 5c                	pop    r12
    19360f20:	41 5d                	pop    r13
    19360f22:	41 5e                	pop    r14
    19360f24:	41 5f                	pop    r15
    19360f26:	5d                   	pop    rbp
    19360f27:	c3                   	ret
    19360f28:	48 89 f3             	mov    rbx,rsi
    19360f2b:	49 89 ff             	mov    r15,rdi
    19360f2e:	0f b7 42 1a          	movzx  eax,WORD PTR [rdx+0x1a]
    19360f32:	48 89 45 b0          	mov    QWORD PTR [rbp-0x50],rax
    19360f36:	48 89 f7             	mov    rdi,rsi
    19360f39:	48 89 55 d0          	mov    QWORD PTR [rbp-0x30],rdx
    19360f3d:	48 89 d6             	mov    rsi,rdx
    19360f40:	e8 db b6 5d 00       	call   1993c620 <_ZN3xla9jellyfish37LloInstructionsPopAndThenPushSameFifoEPKNS0_8LloValueES3_>
    19360f45:	84 c0                	test   al,al
    19360f47:	0f 84 7f 00 00 00    	je     19360fcc <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x198c>
    19360f4d:	48 8b 7d d0          	mov    rdi,QWORD PTR [rbp-0x30]
    19360f51:	4c 63 6f f0          	movsxd r13,DWORD PTR [rdi-0x10]
    19360f55:	4d 85 ed             	test   r13,r13
    19360f58:	74 27                	je     19360f81 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1941>
    19360f5a:	4c 89 7d c0          	mov    QWORD PTR [rbp-0x40],r15
    19360f5e:	4c 8d 7f f0          	lea    r15,[rdi-0x10]
    19360f62:	49 c1 e5 03          	shl    r13,0x3
    19360f66:	49 f7 dd             	neg    r13
    19360f69:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    19360f70:	4b 39 1c 2f          	cmp    QWORD PTR [r15+r13*1],rbx
    19360f74:	74 24                	je     19360f9a <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x195a>
    19360f76:	49 83 c5 08          	add    r13,0x8
    19360f7a:	75 f4                	jne    19360f70 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1930>
    19360f7c:	4d 89 fd             	mov    r13,r15
    19360f7f:	eb 1c                	jmp    19360f9d <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x195d>
    19360f81:	48 89 de             	mov    rsi,rbx
    19360f84:	e8 87 33 69 00       	call   199f4310 <_ZNK3xla9jellyfish8LloValue15OperandUseCountEPKS1_>
    19360f89:	45 31 e4             	xor    r12d,r12d
    19360f8c:	48 85 c0             	test   rax,rax
    19360f8f:	7e 85                	jle    19360f16 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x18d6>
    19360f91:	b0 01                	mov    al,0x1
    19360f93:	31 c9                	xor    ecx,ecx
    19360f95:	e9 63 04 00 00       	jmp    193613fd <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1dbd>
    19360f9a:	4d 01 fd             	add    r13,r15
    19360f9d:	4d 39 fd             	cmp    r13,r15
    19360fa0:	0f 95 c0             	setne  al
    19360fa3:	89 45 cc             	mov    DWORD PTR [rbp-0x34],eax
    19360fa6:	48 89 de             	mov    rsi,rbx
    19360fa9:	e8 62 33 69 00       	call   199f4310 <_ZNK3xla9jellyfish8LloValue15OperandUseCountEPKS1_>
    19360fae:	8b 4d cc             	mov    ecx,DWORD PTR [rbp-0x34]
    19360fb1:	48 85 c0             	test   rax,rax
    19360fb4:	0f 9f c0             	setg   al
    19360fb7:	38 c1                	cmp    cl,al
    19360fb9:	0f 85 3e 04 00 00    	jne    193613fd <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1dbd>
    19360fbf:	4d 39 fd             	cmp    r13,r15
    19360fc2:	4c 8b 7d c0          	mov    r15,QWORD PTR [rbp-0x40]
    19360fc6:	0f 84 4a ff ff ff    	je     19360f16 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x18d6>
    19360fcc:	45 0f b7 ee          	movzx  r13d,r14w
    19360fd0:	44 89 ef             	mov    edi,r13d
    19360fd3:	e8 88 86 69 00       	call   199f9660 <_ZN3xla9jellyfish28LloOpcodeIsPseudoInstructionENS0_9LloOpcodeE>
    19360fd8:	84 c0                	test   al,al
    19360fda:	74 19                	je     19360ff5 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x19b5>
    19360fdc:	4c 89 ff             	mov    rdi,r15
    19360fdf:	48 89 de             	mov    rsi,rbx
    19360fe2:	48 83 c4 38          	add    rsp,0x38
    19360fe6:	5b                   	pop    rbx
    19360fe7:	41 5c                	pop    r12
    19360fe9:	41 5d                	pop    r13
    19360feb:	41 5e                	pop    r14
    19360fed:	41 5f                	pop    r15
    19360fef:	5d                   	pop    rbp
    19360ff0:	e9 7b f0 ff ff       	jmp    19360070 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xa30>
    19360ff5:	44 0f b7 65 b0       	movzx  r12d,WORD PTR [rbp-0x50]
    19360ffa:	44 89 e7             	mov    edi,r12d
    19360ffd:	e8 5e 86 69 00       	call   199f9660 <_ZN3xla9jellyfish28LloOpcodeIsPseudoInstructionENS0_9LloOpcodeE>
    19361002:	84 c0                	test   al,al
    19361004:	74 6a                	je     19361070 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1a30>
    19361006:	48 89 df             	mov    rdi,rbx
    19361009:	e8 52 f6 ff ff       	call   19360660 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1020>
    1936100e:	49 8b bf d0 01 00 00 	mov    rdi,QWORD PTR [r15+0x1d0]
    19361015:	0f b7 f0             	movzx  esi,ax
    19361018:	e8 83 02 02 00       	call   193812a0 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x6e80>
    1936101d:	41 89 c4             	mov    r12d,eax
    19361020:	0f b7 43 1a          	movzx  eax,WORD PTR [rbx+0x1a]
    19361024:	05 74 ff ff ff       	add    eax,0xffffff74
    19361029:	66 83 f8 09          	cmp    ax,0x9
    1936102d:	0f 87 e3 fe ff ff    	ja     19360f16 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x18d6>
    19361033:	48 89 df             	mov    rdi,rbx
    19361036:	e8 85 ed 5c 00       	call   1992fdc0 <_ZNK3xla9jellyfish14LloInstruction10latch_modeEv>
    1936103b:	0f b6 f8             	movzx  edi,al
    1936103e:	e8 8d 7a b0 00       	call   19e68ad0 <_ZN3xla9jellyfish20LatchModeIsTransposeENS0_13GainLatchModeE>
    19361043:	84 c0                	test   al,al
    19361045:	0f 85 cb fe ff ff    	jne    19360f16 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x18d6>
    1936104b:	44 89 e0             	mov    eax,r12d
    1936104e:	c1 e8 1f             	shr    eax,0x1f
    19361051:	44 01 e0             	add    eax,r12d
    19361054:	d1 f8                	sar    eax,1
    19361056:	41 81 e4 01 00 00 80 	and    r12d,0x80000001
    1936105d:	31 c9                	xor    ecx,ecx
    1936105f:	41 83 fc 01          	cmp    r12d,0x1
    19361063:	0f 94 c1             	sete   cl
    19361066:	01 c1                	add    ecx,eax
    19361068:	41 89 cc             	mov    r12d,ecx
    1936106b:	e9 a6 fe ff ff       	jmp    19360f16 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x18d6>
    19361070:	45 8d 4e b0          	lea    r9d,[r14-0x50]
    19361074:	66 41 83 f9 09       	cmp    r9w,0x9
    19361079:	0f 87 af 00 00 00    	ja     1936112e <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1aee>
    1936107f:	48 8b 45 b0          	mov    rax,QWORD PTR [rbp-0x50]
    19361083:	83 c0 b0             	add    eax,0xffffffb0
    19361086:	66 83 f8 09          	cmp    ax,0x9
    1936108a:	48 8b 55 d0          	mov    rdx,QWORD PTR [rbp-0x30]
    1936108e:	77 66                	ja     193610f6 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1ab6>
    19361090:	0f b7 4b 1c          	movzx  ecx,WORD PTR [rbx+0x1c]
    19361094:	89 c8                	mov    eax,ecx
    19361096:	c1 e8 07             	shr    eax,0x7
    19361099:	83 e0 03             	and    eax,0x3
    1936109c:	49 b8 00 00 00 00 01 	movabs r8,0x100000000
    193610a3:	00 00 00 
    193610a6:	4c 09 c0             	or     rax,r8
    193610a9:	31 f6                	xor    esi,esi
    193610ab:	f7 c1 00 02 00 00    	test   ecx,0x200
    193610b1:	48 0f 44 c6          	cmove  rax,rsi
    193610b5:	0f b7 7a 1c          	movzx  edi,WORD PTR [rdx+0x1c]
    193610b9:	89 f9                	mov    ecx,edi
    193610bb:	c1 e9 07             	shr    ecx,0x7
    193610be:	83 e1 03             	and    ecx,0x3
    193610c1:	4c 09 c1             	or     rcx,r8
    193610c4:	f7 c7 00 02 00 00    	test   edi,0x200
    193610ca:	48 0f 44 ce          	cmove  rcx,rsi
    193610ce:	48 89 c7             	mov    rdi,rax
    193610d1:	48 c1 ef 20          	shr    rdi,0x20
    193610d5:	48 89 ce             	mov    rsi,rcx
    193610d8:	48 c1 ee 20          	shr    rsi,0x20
    193610dc:	40 84 fe             	test   sil,dil
    193610df:	0f 84 d4 02 00 00    	je     193613b9 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1d79>
    193610e5:	48 85 f6             	test   rsi,rsi
    193610e8:	0f 84 84 03 00 00    	je     19361472 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1e32>
    193610ee:	39 c8                	cmp    eax,ecx
    193610f0:	0f 85 cc 02 00 00    	jne    193613c2 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1d82>
    193610f6:	44 89 65 cc          	mov    DWORD PTR [rbp-0x34],r12d
    193610fa:	44 89 4d c0          	mov    DWORD PTR [rbp-0x40],r9d
    193610fe:	41 bc 01 00 00 00    	mov    r12d,0x1
    19361104:	66 41 83 fe 56       	cmp    r14w,0x56
    19361109:	0f 84 8e 00 00 00    	je     1936119d <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1b5d>
    1936110f:	48 8b 45 b0          	mov    rax,QWORD PTR [rbp-0x50]
    19361113:	83 f0 50             	xor    eax,0x50
    19361116:	41 83 e6 5e          	and    r14d,0x5e
    1936111a:	41 83 f6 50          	xor    r14d,0x50
    1936111e:	45 31 e4             	xor    r12d,r12d
    19361121:	66 41 09 c6          	or     r14w,ax
    19361125:	41 0f 95 c4          	setne  r12b
    19361129:	41 ff c4             	inc    r12d
    1936112c:	eb 6f                	jmp    1936119d <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1b5d>
    1936112e:	44 89 65 cc          	mov    DWORD PTR [rbp-0x34],r12d
    19361132:	44 89 4d c0          	mov    DWORD PTR [rbp-0x40],r9d
    19361136:	48 89 df             	mov    rdi,rbx
    19361139:	e8 22 f5 ff ff       	call   19360660 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1020>
    1936113e:	49 8b bf d0 01 00 00 	mov    rdi,QWORD PTR [r15+0x1d0]
    19361145:	0f b7 f0             	movzx  esi,ax
    19361148:	e8 53 01 02 00       	call   193812a0 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x6e80>
    1936114d:	41 89 c4             	mov    r12d,eax
    19361150:	0f b7 43 1a          	movzx  eax,WORD PTR [rbx+0x1a]
    19361154:	05 74 ff ff ff       	add    eax,0xffffff74
    19361159:	66 83 f8 09          	cmp    ax,0x9
    1936115d:	77 3a                	ja     19361199 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1b59>
    1936115f:	48 89 df             	mov    rdi,rbx
    19361162:	e8 59 ec 5c 00       	call   1992fdc0 <_ZNK3xla9jellyfish14LloInstruction10latch_modeEv>
    19361167:	0f b6 f8             	movzx  edi,al
    1936116a:	e8 61 79 b0 00       	call   19e68ad0 <_ZN3xla9jellyfish20LatchModeIsTransposeENS0_13GainLatchModeE>
    1936116f:	84 c0                	test   al,al
    19361171:	48 8b 55 d0          	mov    rdx,QWORD PTR [rbp-0x30]
    19361175:	75 26                	jne    1936119d <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1b5d>
    19361177:	44 89 e0             	mov    eax,r12d
    1936117a:	c1 e8 1f             	shr    eax,0x1f
    1936117d:	44 01 e0             	add    eax,r12d
    19361180:	d1 f8                	sar    eax,1
    19361182:	41 81 e4 01 00 00 80 	and    r12d,0x80000001
    19361189:	31 c9                	xor    ecx,ecx
    1936118b:	41 83 fc 01          	cmp    r12d,0x1
    1936118f:	0f 94 c1             	sete   cl
    19361192:	01 c1                	add    ecx,eax
    19361194:	41 89 cc             	mov    r12d,ecx
    19361197:	eb 04                	jmp    1936119d <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1b5d>
    19361199:	48 8b 55 d0          	mov    rdx,QWORD PTR [rbp-0x30]
    1936119d:	49 8b 07             	mov    rax,QWORD PTR [r15]
    193611a0:	4c 89 ff             	mov    rdi,r15
    193611a3:	48 89 de             	mov    rsi,rbx
    193611a6:	ff 50 28             	call   QWORD PTR [rax+0x28]
    193611a9:	44 89 65 bc          	mov    DWORD PTR [rbp-0x44],r12d
    193611ad:	84 c0                	test   al,al
    193611af:	44 8b 75 cc          	mov    r14d,DWORD PTR [rbp-0x34]
    193611b3:	75 52                	jne    19361207 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1bc7>
    193611b5:	44 89 ef             	mov    edi,r13d
    193611b8:	e8 83 ff eb f3       	call   d221140 <_ZN3xla9jellyfish16LloOpcodeUsesMxuENS0_9LloOpcodeE>
    193611bd:	45 31 e4             	xor    r12d,r12d
    193611c0:	84 c0                	test   al,al
    193611c2:	74 43                	je     19361207 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1bc7>
    193611c4:	44 89 f7             	mov    edi,r14d
    193611c7:	e8 74 ff eb f3       	call   d221140 <_ZN3xla9jellyfish16LloOpcodeUsesMxuENS0_9LloOpcodeE>
    193611cc:	84 c0                	test   al,al
    193611ce:	74 37                	je     19361207 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1bc7>
    193611d0:	4d 8b b7 d8 01 00 00 	mov    r14,QWORD PTR [r15+0x1d8]
    193611d7:	48 89 df             	mov    rdi,rbx
    193611da:	e8 21 7f fe ff       	call   19349100 <_ZN3xla9jellyfish14LloInstruction9FromValueINS0_8LloValueEQsr3stdE7same_asIT_S3_EEEPKS1_PKS4_>
    193611df:	48 89 c3             	mov    rbx,rax
    193611e2:	48 8b 7d d0          	mov    rdi,QWORD PTR [rbp-0x30]
    193611e6:	e8 15 7f fe ff       	call   19349100 <_ZN3xla9jellyfish14LloInstruction9FromValueINS0_8LloValueEQsr3stdE7same_asIT_S3_EEEPKS1_PKS4_>
    193611eb:	4c 89 f7             	mov    rdi,r14
    193611ee:	48 89 de             	mov    rsi,rbx
    193611f1:	48 89 c2             	mov    rdx,rax
    193611f4:	48 83 c4 38          	add    rsp,0x38
    193611f8:	5b                   	pop    rbx
    193611f9:	41 5c                	pop    r12
    193611fb:	41 5d                	pop    r13
    193611fd:	41 5e                	pop    r14
    193611ff:	41 5f                	pop    r15
    19361201:	5d                   	pop    rbp
    19361202:	e9 19 2c 00 00       	jmp    19363e20 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x47e0>
    19361207:	44 89 ef             	mov    edi,r13d
    1936120a:	e8 11 84 69 00       	call   199f9620 <_ZN3xla9jellyfish22LloOpcodeIsBf16EupPushENS0_9LloOpcodeE>
    1936120f:	84 c0                	test   al,al
    19361211:	74 19                	je     1936122c <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1bec>
    19361213:	44 89 f7             	mov    edi,r14d
    19361216:	e8 05 84 69 00       	call   199f9620 <_ZN3xla9jellyfish22LloOpcodeIsBf16EupPushENS0_9LloOpcodeE>
    1936121b:	84 c0                	test   al,al
    1936121d:	74 0d                	je     1936122c <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1bec>
    1936121f:	41 83 fc 03          	cmp    r12d,0x3
    19361223:	b8 02 00 00 00       	mov    eax,0x2
    19361228:	44 0f 4c e0          	cmovl  r12d,eax
    1936122c:	48 8b 55 d0          	mov    rdx,QWORD PTR [rbp-0x30]
    19361230:	4c 89 ff             	mov    rdi,r15
    19361233:	48 89 de             	mov    rsi,rbx
    19361236:	e8 45 4c fe ff       	call   19345e80 <_ZNK3xla9jellyfish12LatencyTable31HasSetPermutePatternReservationEPKNS0_8LloValueES4_>
    1936123b:	84 c0                	test   al,al
    1936123d:	0f 84 85 00 00 00    	je     193612c8 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1c88>
    19361243:	45 89 e6             	mov    r14d,r12d
    19361246:	4c 89 ff             	mov    rdi,r15
    19361249:	48 89 de             	mov    rsi,rbx
    1936124c:	e8 bf fb ff ff       	call   19360e10 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x17d0>
    19361251:	41 89 c4             	mov    r12d,eax
    19361254:	0f b7 43 1c          	movzx  eax,WORD PTR [rbx+0x1c]
    19361258:	89 c1                	mov    ecx,eax
    1936125a:	c1 e9 07             	shr    ecx,0x7
    1936125d:	83 e1 03             	and    ecx,0x3
    19361260:	48 ba 00 00 00 00 01 	movabs rdx,0x100000000
    19361267:	00 00 00 
    1936126a:	48 09 ca             	or     rdx,rcx
    1936126d:	45 31 ed             	xor    r13d,r13d
    19361270:	a9 00 02 00 00       	test   eax,0x200
    19361275:	4c 0f 45 ea          	cmovne r13,rdx
    19361279:	4c 89 e8             	mov    rax,r13
    1936127c:	48 c1 e8 20          	shr    rax,0x20
    19361280:	0f 84 bd 01 00 00    	je     19361443 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1e03>
    19361286:	45 39 e6             	cmp    r14d,r12d
    19361289:	45 0f 4f e6          	cmovg  r12d,r14d
    1936128d:	4d 8d 77 18          	lea    r14,[r15+0x18]
    19361291:	4c 89 f7             	mov    rdi,r14
    19361294:	48 89 de             	mov    rsi,rbx
    19361297:	e8 04 4d fe ff       	call   19345fa0 <_ZNK3xla9jellyfish23XluConflictPenaltyTable15GetXluInstrTypeEPKNS0_8LloValueE>
    1936129c:	89 45 cc             	mov    DWORD PTR [rbp-0x34],eax
    1936129f:	4c 89 f7             	mov    rdi,r14
    193612a2:	4c 8b 75 d0          	mov    r14,QWORD PTR [rbp-0x30]
    193612a6:	4c 89 f6             	mov    rsi,r14
    193612a9:	e8 f2 4c fe ff       	call   19345fa0 <_ZNK3xla9jellyfish23XluConflictPenaltyTable15GetXluInstrTypeEPKNS0_8LloValueE>
    193612ae:	49 8d 7f 18          	lea    rdi,[r15+0x18]
    193612b2:	8b 75 cc             	mov    esi,DWORD PTR [rbp-0x34]
    193612b5:	89 c2                	mov    edx,eax
    193612b7:	44 89 e9             	mov    ecx,r13d
    193612ba:	e8 71 4f fe ff       	call   19346230 <_ZNK3xla9jellyfish23XluConflictPenaltyTable25XluConflictPenaltyBetweenENS1_12XluInstrTypeES2_j>
    193612bf:	41 39 c4             	cmp    r12d,eax
    193612c2:	44 0f 4e e0          	cmovle r12d,eax
    193612c6:	eb 04                	jmp    193612cc <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1c8c>
    193612c8:	4c 8b 75 d0          	mov    r14,QWORD PTR [rbp-0x30]
    193612cc:	49 8d 7f 18          	lea    rdi,[r15+0x18]
    193612d0:	48 89 de             	mov    rsi,rbx
    193612d3:	4c 89 f2             	mov    rdx,r14
    193612d6:	e8 15 53 fe ff       	call   193465f0 <_ZNK3xla9jellyfish23XluConflictPenaltyTable32IsFinalTransposeFollowedByResultEPKNS0_8LloValueES4_>
    193612db:	84 c0                	test   al,al
    193612dd:	74 4a                	je     19361329 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1ce9>
    193612df:	0f b7 43 1a          	movzx  eax,WORD PTR [rbx+0x1a]
    193612e3:	05 1b ff ff ff       	add    eax,0xffffff1b
    193612e8:	66 83 f8 f5          	cmp    ax,0xfff5
    193612ec:	0f 83 35 01 00 00    	jae    19361427 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1de7>
    193612f2:	4c 8b 6d d0          	mov    r13,QWORD PTR [rbp-0x30]
    193612f6:	41 0f b7 45 1a       	movzx  eax,WORD PTR [r13+0x1a]
    193612fb:	05 1b ff ff ff       	add    eax,0xffffff1b
    19361300:	66 83 f8 f5          	cmp    ax,0xfff5
    19361304:	8b 4d bc             	mov    ecx,DWORD PTR [rbp-0x44]
    19361307:	4d 8d 77 18          	lea    r14,[r15+0x18]
    1936130b:	0f 83 16 01 00 00    	jae    19361427 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1de7>
    19361311:	49 8b 06             	mov    rax,QWORD PTR [r14]
    19361314:	4c 89 f7             	mov    rdi,r14
    19361317:	48 89 de             	mov    rsi,rbx
    1936131a:	4c 89 ea             	mov    rdx,r13
    1936131d:	ff 50 18             	call   QWORD PTR [rax+0x18]
    19361320:	41 39 c4             	cmp    r12d,eax
    19361323:	44 0f 4e e0          	cmovle r12d,eax
    19361327:	eb 08                	jmp    19361331 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1cf1>
    19361329:	4c 8b 6d d0          	mov    r13,QWORD PTR [rbp-0x30]
    1936132d:	4d 8d 77 18          	lea    r14,[r15+0x18]
    19361331:	4c 89 f7             	mov    rdi,r14
    19361334:	48 89 de             	mov    rsi,rbx
    19361337:	4c 89 ea             	mov    rdx,r13
    1936133a:	e8 91 53 fe ff       	call   193466d0 <_ZNK3xla9jellyfish23XluConflictPenaltyTable22ArePushesToSameXluFifoEPKNS0_8LloValueES4_>
    1936133f:	84 c0                	test   al,al
    19361341:	74 15                	je     19361358 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1d18>
    19361343:	4c 89 f7             	mov    rdi,r14
    19361346:	48 89 de             	mov    rsi,rbx
    19361349:	4c 89 ea             	mov    rdx,r13
    1936134c:	e8 0f 4f fe ff       	call   19346260 <_ZNK3xla9jellyfish23XluConflictPenaltyTable25XluConflictPenaltyBetweenEPKNS0_8LloValueES4_>
    19361351:	41 39 c4             	cmp    r12d,eax
    19361354:	44 0f 4e e0          	cmovle r12d,eax
    19361358:	8b 45 c0             	mov    eax,DWORD PTR [rbp-0x40]
    1936135b:	66 83 f8 0a          	cmp    ax,0xa
    1936135f:	0f 92 45 d0          	setb   BYTE PTR [rbp-0x30]
    19361363:	4c 89 ff             	mov    rdi,r15
    19361366:	48 89 de             	mov    rsi,rbx
    19361369:	4c 89 ea             	mov    rdx,r13
    1936136c:	e8 bf 46 fe ff       	call   19345a30 <_ZNK3xla9jellyfish12LatencyTable29IsSetIarFollowedByIndexedLoadEPKNS0_8LloValueES4_>
    19361371:	41 83 fc 08          	cmp    r12d,0x8
    19361375:	41 be 07 00 00 00    	mov    r14d,0x7
    1936137b:	45 0f 4d f4          	cmovge r14d,r12d
    1936137f:	84 c0                	test   al,al
    19361381:	45 0f 44 f4          	cmove  r14d,r12d
    19361385:	48 8b 45 b0          	mov    rax,QWORD PTR [rbp-0x50]
    19361389:	83 c0 b0             	add    eax,0xffffffb0
    1936138c:	66 83 f8 0a          	cmp    ax,0xa
    19361390:	0f 92 c0             	setb   al
    19361393:	0a 45 d0             	or     al,BYTE PTR [rbp-0x30]
    19361396:	3c 01                	cmp    al,0x1
    19361398:	75 05                	jne    1936139f <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1d5f>
    1936139a:	8b 45 bc             	mov    eax,DWORD PTR [rbp-0x44]
    1936139d:	eb 0e                	jmp    193613ad <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1d6d>
    1936139f:	4c 89 ff             	mov    rdi,r15
    193613a2:	48 89 de             	mov    rsi,rbx
    193613a5:	4c 89 ea             	mov    rdx,r13
    193613a8:	e8 83 ef ff ff       	call   19360330 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xcf0>
    193613ad:	41 39 c6             	cmp    r14d,eax
    193613b0:	41 0f 4f c6          	cmovg  eax,r14d
    193613b4:	e9 60 fb ff ff       	jmp    19360f19 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x18d9>
    193613b9:	40 38 f7             	cmp    dil,sil
    193613bc:	0f 84 34 fd ff ff    	je     193610f6 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1ab6>
    193613c2:	49 8b 07             	mov    rax,QWORD PTR [r15]
    193613c5:	4c 89 ff             	mov    rdi,r15
    193613c8:	48 89 de             	mov    rsi,rbx
    193613cb:	ff 50 28             	call   QWORD PTR [rax+0x28]
    193613ce:	45 31 e4             	xor    r12d,r12d
    193613d1:	84 c0                	test   al,al
    193613d3:	0f 84 3d fb ff ff    	je     19360f16 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x18d6>
    193613d9:	48 89 df             	mov    rdi,rbx
    193613dc:	e8 7f f2 ff ff       	call   19360660 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1020>
    193613e1:	0f b7 d0             	movzx  edx,ax
    193613e4:	4c 89 ff             	mov    rdi,r15
    193613e7:	48 89 de             	mov    rsi,rbx
    193613ea:	48 83 c4 38          	add    rsp,0x38
    193613ee:	5b                   	pop    rbx
    193613ef:	41 5c                	pop    r12
    193613f1:	41 5d                	pop    r13
    193613f3:	41 5e                	pop    r14
    193613f5:	41 5f                	pop    r15
    193613f7:	5d                   	pop    rbp
    193613f8:	e9 03 ec ff ff       	jmp    19360000 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x9c0>
    193613fd:	0f b6 f9             	movzx  edi,cl
    19361400:	0f b6 f0             	movzx  esi,al
    19361403:	48 8d 15 79 24 24 ef 	lea    rdx,[rip+0xffffffffef242479]        # 85a3883 <local_itoa.digits+0x87751e>
    1936140a:	e8 d1 10 43 04       	call   1d7924e0 <_ZN4absl12log_internal17MakeCheckOpStringIbbEEPKcT_T0_S3_>
    1936140f:	48 8d 35 b4 e7 8f ed 	lea    rsi,[rip+0xffffffffed8fe7b4]        # 6c5fbca <anon.de66683854b989ac240da9b5830f09df.25.llvm.14521404311210802531+0x108e91>
    19361416:	48 8d 5d a0          	lea    rbx,[rbp-0x60]
    1936141a:	48 89 df             	mov    rdi,rbx
    1936141d:	ba ef 03 00 00       	mov    edx,0x3ef
    19361422:	48 89 c1             	mov    rcx,rax
    19361425:	eb 36                	jmp    1936145d <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1e1d>
    19361427:	48 8d 35 1f b3 8f ed 	lea    rsi,[rip+0xffffffffed8fb31f]        # 6c5c74d <anon.de66683854b989ac240da9b5830f09df.25.llvm.14521404311210802531+0x105a14>
    1936142e:	48 8d 0d 7a 83 3e ef 	lea    rcx,[rip+0xffffffffef3e837a]        # 87497af <nilstr+0x544cb>
    19361435:	48 8d 5d a0          	lea    rbx,[rbp-0x60]
    19361439:	48 89 df             	mov    rdi,rbx
    1936143c:	ba 7c 04 00 00       	mov    edx,0x47c
    19361441:	eb 1a                	jmp    1936145d <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1e1d>
    19361443:	48 8d 35 c3 c6 a2 ed 	lea    rsi,[rip+0xffffffffeda2c6c3]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    1936144a:	48 8d 0d 6b fd 3f ef 	lea    rcx,[rip+0xffffffffef3ffd6b]        # 87611bc <nilstr+0x6bed8>
    19361451:	48 8d 5d a0          	lea    rbx,[rbp-0x60]
    19361455:	48 89 df             	mov    rdi,rbx
    19361458:	ba 91 04 00 00       	mov    edx,0x491
    1936145d:	e8 84 e2 71 04       	call   1da7f6e6 <_ZN4absl12log_internal15LogMessageFatalC1EPKciS3_>
    19361462:	48 89 df             	mov    rdi,rbx
    19361465:	e8 96 34 43 04       	call   1d794900 <_ZN4absl12log_internal10LogMessage5FlushEv>
    1936146a:	48 89 df             	mov    rdi,rbx
    1936146d:	e8 de e2 71 04       	call   1da7f750 <_ZN4absl12log_internal15LogMessageFatalD1Ev>
    19361472:	0f 0b                	ud2
    19361474:	cc                   	int3
    19361475:	cc                   	int3
    19361476:	cc                   	int3
    19361477:	cc                   	int3
    19361478:	cc                   	int3
    19361479:	cc                   	int3
    1936147a:	cc                   	int3
    1936147b:	cc                   	int3
    1936147c:	cc                   	int3
    1936147d:	cc                   	int3
    1936147e:	cc                   	int3
    1936147f:	cc                   	int3
