
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

0000000019360070 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xa30>:
    19360070:	55                   	push   rbp
    19360071:	48 89 e5             	mov    rbp,rsp
    19360074:	41 57                	push   r15
    19360076:	41 56                	push   r14
    19360078:	41 54                	push   r12
    1936007a:	53                   	push   rbx
    1936007b:	48 83 ec 10          	sub    rsp,0x10
    1936007f:	49 89 f7             	mov    r15,rsi
    19360082:	48 89 fb             	mov    rbx,rdi
    19360085:	4c 8d 25 54 d0 73 05 	lea    r12,[rip+0x573d054]        # 1ea9d0e0 <_GLOBAL_OFFSET_TABLE_>
    1936008c:	44 0f b7 76 1a       	movzx  r14d,WORD PTR [rsi+0x1a]
    19360091:	44 89 f7             	mov    edi,r14d
    19360094:	e8 67 95 69 00       	call   199f9600 <_ZN3xla9jellyfish31LloOpcodeIsPseudoEupInstructionENS0_9LloOpcodeE>
    19360099:	84 c0                	test   al,al
    1936009b:	0f 84 ed 00 00 00    	je     1936018e <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xb4e>
    193600a1:	b9 12 00 00 00       	mov    ecx,0x12
    193600a6:	48 8d 05 bb 88 4b f0 	lea    rax,[rip+0xfffffffff04b88bb]        # 9818968 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xc4c>
    193600ad:	0f 1f 00             	nop    DWORD PTR [rax]
    193600b0:	48 89 c2             	mov    rdx,rax
    193600b3:	48 89 c8             	mov    rax,rcx
    193600b6:	48 d1 e8             	shr    rax,1
    193600b9:	48 89 c6             	mov    rsi,rax
    193600bc:	48 f7 d6             	not    rsi
    193600bf:	48 01 ce             	add    rsi,rcx
    193600c2:	66 44 39 34 82       	cmp    WORD PTR [rdx+rax*4],r14w
    193600c7:	48 0f 43 f0          	cmovae rsi,rax
    193600cb:	48 8d 44 82 04       	lea    rax,[rdx+rax*4+0x4]
    193600d0:	48 0f 43 c2          	cmovae rax,rdx
    193600d4:	48 89 f1             	mov    rcx,rsi
    193600d7:	48 85 f6             	test   rsi,rsi
    193600da:	75 d4                	jne    193600b0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xa70>
    193600dc:	48 8d 0d cd 88 4b f0 	lea    rcx,[rip+0xfffffffff04b88cd]        # 98189b0 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xc94>
    193600e3:	48 39 c8             	cmp    rax,rcx
    193600e6:	74 0f                	je     193600f7 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xab7>
    193600e8:	66 44 3b 30          	cmp    r14w,WORD PTR [rax]
    193600ec:	48 8d 0d bd 88 4b f0 	lea    rcx,[rip+0xfffffffff04b88bd]        # 98189b0 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0xc94>
    193600f3:	48 0f 43 c8          	cmovae rcx,rax
    193600f7:	48 b8 9a 80 bd e3 ff 	movabs rax,0xffffffffe3bd809a
    193600fe:	ff ff ff 
    19360101:	49 8d 14 04          	lea    rdx,[r12+rax*1]
    19360105:	0f b7 49 02          	movzx  ecx,WORD PTR [rcx+0x2]
    19360109:	be 12 01 00 00       	mov    esi,0x112
    1936010e:	66 90                	xchg   ax,ax
    19360110:	48 89 d7             	mov    rdi,rdx
    19360113:	48 89 f2             	mov    rdx,rsi
    19360116:	48 d1 ea             	shr    rdx,1
    19360119:	49 89 d0             	mov    r8,rdx
    1936011c:	49 f7 d0             	not    r8
    1936011f:	49 01 f0             	add    r8,rsi
    19360122:	66 39 0c 97          	cmp    WORD PTR [rdi+rdx*4],cx
    19360126:	4c 0f 43 c2          	cmovae r8,rdx
    1936012a:	48 8d 54 97 04       	lea    rdx,[rdi+rdx*4+0x4]
    1936012f:	48 0f 43 d7          	cmovae rdx,rdi
    19360133:	4c 89 c6             	mov    rsi,r8
    19360136:	4d 85 c0             	test   r8,r8
    19360139:	75 d5                	jne    19360110 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xad0>
    1936013b:	49 8d 34 04          	lea    rsi,[r12+rax*1]
    1936013f:	48 81 c6 48 04 00 00 	add    rsi,0x448
    19360146:	48 39 f2             	cmp    rdx,rsi
    19360149:	74 0f                	je     1936015a <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xb1a>
    1936014b:	66 3b 0a             	cmp    cx,WORD PTR [rdx]
    1936014e:	49 8d b4 04 48 04 00 	lea    rsi,[r12+rax*1+0x448]
    19360155:	00 
    19360156:	48 0f 43 f2          	cmovae rsi,rdx
    1936015a:	0f b7 76 02          	movzx  esi,WORD PTR [rsi+0x2]
    1936015e:	48 8b bb d0 01 00 00 	mov    rdi,QWORD PTR [rbx+0x1d0]
    19360165:	e8 36 11 02 00       	call   193812a0 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x6e80>
    1936016a:	41 89 c6             	mov    r14d,eax
    1936016d:	48 8b bb d0 01 00 00 	mov    rdi,QWORD PTR [rbx+0x1d0]
    19360174:	be a0 01 00 00       	mov    esi,0x1a0
    19360179:	e8 22 11 02 00       	call   193812a0 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x6e80>
    1936017e:	44 01 f0             	add    eax,r14d
    19360181:	48 83 c4 10          	add    rsp,0x10
    19360185:	5b                   	pop    rbx
    19360186:	41 5c                	pop    r12
    19360188:	41 5e                	pop    r14
    1936018a:	41 5f                	pop    r15
    1936018c:	5d                   	pop    rbp
    1936018d:	c3                   	ret
    1936018e:	41 81 fe 82 00 00 00 	cmp    r14d,0x82
    19360195:	7f 2e                	jg     193601c5 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xb85>
    19360197:	41 83 fe 2e          	cmp    r14d,0x2e
    1936019b:	0f 87 3f 01 00 00    	ja     193602e0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xca0>
    193601a1:	44 89 f0             	mov    eax,r14d
    193601a4:	48 b9 e1 00 00 00 00 	movabs rcx,0x1500000000e1
    193601ab:	15 00 00 
    193601ae:	48 0f a3 c1          	bt     rcx,rax
    193601b2:	73 3e                	jae    193601f2 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xbb2>
    193601b4:	48 8b bb d0 01 00 00 	mov    rdi,QWORD PTR [rbx+0x1d0]
    193601bb:	be 1b 00 00 00       	mov    esi,0x1b
    193601c0:	e9 f2 00 00 00       	jmp    193602b7 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xc77>
    193601c5:	41 81 fe 87 00 00 00 	cmp    r14d,0x87
    193601cc:	7e 63                	jle    19360231 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xbf1>
    193601ce:	41 81 fe 88 00 00 00 	cmp    r14d,0x88
    193601d5:	0f 84 ed 00 00 00    	je     193602c8 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xc88>
    193601db:	41 81 fe ee 00 00 00 	cmp    r14d,0xee
    193601e2:	74 d0                	je     193601b4 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xb74>
    193601e4:	41 81 fe f0 00 00 00 	cmp    r14d,0xf0
    193601eb:	74 c7                	je     193601b4 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xb74>
    193601ed:	e9 ee 00 00 00       	jmp    193602e0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xca0>
    193601f2:	48 b9 00 00 00 00 00 	movabs rcx,0x600000000000
    193601f9:	60 00 00 
    193601fc:	48 0f a3 c1          	bt     rcx,rax
    19360200:	72 45                	jb     19360247 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xc07>
    19360202:	48 83 f8 0e          	cmp    rax,0xe
    19360206:	0f 85 d4 00 00 00    	jne    193602e0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xca0>
    1936020c:	48 8b bb d0 01 00 00 	mov    rdi,QWORD PTR [rbx+0x1d0]
    19360213:	be b5 01 00 00       	mov    esi,0x1b5
    19360218:	e8 83 10 02 00       	call   193812a0 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x6e80>
    1936021d:	41 89 c6             	mov    r14d,eax
    19360220:	48 8b bb d0 01 00 00 	mov    rdi,QWORD PTR [rbx+0x1d0]
    19360227:	be b7 01 00 00       	mov    esi,0x1b7
    1936022c:	e9 48 ff ff ff       	jmp    19360179 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xb39>
    19360231:	41 81 fe 83 00 00 00 	cmp    r14d,0x83
    19360238:	74 0d                	je     19360247 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xc07>
    1936023a:	41 81 fe 85 00 00 00 	cmp    r14d,0x85
    19360241:	0f 85 99 00 00 00    	jne    193602e0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xca0>
    19360247:	48 b8 9a 80 bd e3 ff 	movabs rax,0xffffffffe3bd809a
    1936024e:	ff ff ff 
    19360251:	49 8d 0c 04          	lea    rcx,[r12+rax*1]
    19360255:	ba 12 01 00 00       	mov    edx,0x112
    1936025a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    19360260:	48 89 ce             	mov    rsi,rcx
    19360263:	48 89 d1             	mov    rcx,rdx
    19360266:	48 d1 e9             	shr    rcx,1
    19360269:	48 89 cf             	mov    rdi,rcx
    1936026c:	48 f7 d7             	not    rdi
    1936026f:	48 01 d7             	add    rdi,rdx
    19360272:	66 44 39 34 8e       	cmp    WORD PTR [rsi+rcx*4],r14w
    19360277:	48 0f 43 f9          	cmovae rdi,rcx
    1936027b:	48 8d 4c 8e 04       	lea    rcx,[rsi+rcx*4+0x4]
    19360280:	48 0f 43 ce          	cmovae rcx,rsi
    19360284:	48 89 fa             	mov    rdx,rdi
    19360287:	48 85 ff             	test   rdi,rdi
    1936028a:	75 d4                	jne    19360260 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xc20>
    1936028c:	49 8d 14 04          	lea    rdx,[r12+rax*1]
    19360290:	48 81 c2 48 04 00 00 	add    rdx,0x448
    19360297:	48 39 d1             	cmp    rcx,rdx
    1936029a:	74 10                	je     193602ac <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xc6c>
    1936029c:	66 44 3b 31          	cmp    r14w,WORD PTR [rcx]
    193602a0:	49 8d 94 04 48 04 00 	lea    rdx,[r12+rax*1+0x448]
    193602a7:	00 
    193602a8:	48 0f 43 d1          	cmovae rdx,rcx
    193602ac:	0f b7 72 02          	movzx  esi,WORD PTR [rdx+0x2]
    193602b0:	48 8b bb d0 01 00 00 	mov    rdi,QWORD PTR [rbx+0x1d0]
    193602b7:	48 83 c4 10          	add    rsp,0x10
    193602bb:	5b                   	pop    rbx
    193602bc:	41 5c                	pop    r12
    193602be:	41 5e                	pop    r14
    193602c0:	41 5f                	pop    r15
    193602c2:	5d                   	pop    rbp
    193602c3:	e9 d8 0f 02 00       	jmp    193812a0 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x6e80>
    193602c8:	48 8b bb d0 01 00 00 	mov    rdi,QWORD PTR [rbx+0x1d0]
    193602cf:	be 1b 00 00 00       	mov    esi,0x1b
    193602d4:	e8 c7 0f 02 00       	call   193812a0 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x6e80>
    193602d9:	01 c0                	add    eax,eax
    193602db:	e9 a1 fe ff ff       	jmp    19360181 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xb41>
    193602e0:	48 8d 35 26 d8 a2 ed 	lea    rsi,[rip+0xffffffffeda2d826]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    193602e7:	48 8d 5d d0          	lea    rbx,[rbp-0x30]
    193602eb:	48 89 df             	mov    rdi,rbx
    193602ee:	ba ed 03 00 00       	mov    edx,0x3ed
    193602f3:	e8 de f3 71 04       	call   1da7f6d6 <_ZN4absl12log_internal15LogMessageFatalC1EPKci>
    193602f8:	48 8d 35 bf f7 4c ef 	lea    rsi,[rip+0xffffffffef4cf7bf]        # 882fabe <nilstr+0x13a7da>
    193602ff:	48 89 df             	mov    rdi,rbx
    19360302:	e8 e9 51 34 f3       	call   c6a54f0 <_ZN4absl12log_internal10LogMessagelsILi32EEERS1_RAT__Kc>
    19360307:	48 89 c7             	mov    rdi,rax
    1936030a:	4c 89 fe             	mov    rsi,r15
    1936030d:	e8 1e 66 d4 f5       	call   f0a6930 <_ZN4absl12log_internal10LogMessagelsIN3xla9jellyfish8LloValueEEERS1_RKT_>
    19360312:	48 89 c7             	mov    rdi,rax
    19360315:	e8 e6 45 43 04       	call   1d794900 <_ZN4absl12log_internal10LogMessage5FlushEv>
    1936031a:	48 89 df             	mov    rdi,rbx
    1936031d:	e8 2e f4 71 04       	call   1da7f750 <_ZN4absl12log_internal15LogMessageFatalD1Ev>
    19360322:	cc                   	int3
    19360323:	cc                   	int3
    19360324:	cc                   	int3
    19360325:	cc                   	int3
    19360326:	cc                   	int3
    19360327:	cc                   	int3
    19360328:	cc                   	int3
    19360329:	cc                   	int3
    1936032a:	cc                   	int3
    1936032b:	cc                   	int3
    1936032c:	cc                   	int3
    1936032d:	cc                   	int3
    1936032e:	cc                   	int3
    1936032f:	cc                   	int3
