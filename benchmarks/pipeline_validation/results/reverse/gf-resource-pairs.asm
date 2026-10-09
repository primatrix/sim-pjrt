
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

0000000019360330 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xcf0>:
    19360330:	55                   	push   rbp
    19360331:	48 89 e5             	mov    rbp,rsp
    19360334:	41 57                	push   r15
    19360336:	41 56                	push   r14
    19360338:	41 55                	push   r13
    1936033a:	41 54                	push   r12
    1936033c:	53                   	push   rbx
    1936033d:	48 83 ec 48          	sub    rsp,0x48
    19360341:	49 89 d4             	mov    r12,rdx
    19360344:	48 89 f3             	mov    rbx,rsi
    19360347:	49 89 ff             	mov    r15,rdi
    1936034a:	48 89 f7             	mov    rdi,rsi
    1936034d:	e8 0e 03 00 00       	call   19360660 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1020>
    19360352:	41 89 c6             	mov    r14d,eax
    19360355:	4c 89 e7             	mov    rdi,r12
    19360358:	e8 03 03 00 00       	call   19360660 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1020>
    1936035d:	41 89 c5             	mov    r13d,eax
    19360360:	48 89 5d c0          	mov    QWORD PTR [rbp-0x40],rbx
    19360364:	0f b7 4b 1c          	movzx  ecx,WORD PTR [rbx+0x1c]
    19360368:	89 c8                	mov    eax,ecx
    1936036a:	c1 e8 07             	shr    eax,0x7
    1936036d:	83 e0 03             	and    eax,0x3
    19360370:	48 ba 00 00 00 00 01 	movabs rdx,0x100000000
    19360377:	00 00 00 
    1936037a:	48 09 d0             	or     rax,rdx
    1936037d:	31 ff                	xor    edi,edi
    1936037f:	f7 c1 00 02 00 00    	test   ecx,0x200
    19360385:	48 0f 44 c7          	cmove  rax,rdi
    19360389:	4c 89 65 b8          	mov    QWORD PTR [rbp-0x48],r12
    1936038d:	41 0f b7 74 24 1c    	movzx  esi,WORD PTR [r12+0x1c]
    19360393:	89 f1                	mov    ecx,esi
    19360395:	c1 e9 07             	shr    ecx,0x7
    19360398:	83 e1 03             	and    ecx,0x3
    1936039b:	48 09 d1             	or     rcx,rdx
    1936039e:	f7 c6 00 02 00 00    	test   esi,0x200
    193603a4:	ba 00 00 00 00       	mov    edx,0x0
    193603a9:	48 89 55 d0          	mov    QWORD PTR [rbp-0x30],rdx
    193603ad:	48 0f 44 cf          	cmove  rcx,rdi
    193603b1:	48 89 c6             	mov    rsi,rax
    193603b4:	48 c1 ee 20          	shr    rsi,0x20
    193603b8:	48 89 ca             	mov    rdx,rcx
    193603bb:	48 c1 ea 20          	shr    rdx,0x20
    193603bf:	40 38 d6             	cmp    sil,dl
    193603c2:	0f 94 c3             	sete   bl
    193603c5:	40 84 f2             	test   dl,sil
    193603c8:	74 0e                	je     193603d8 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xd98>
    193603ca:	48 85 d2             	test   rdx,rdx
    193603cd:	0f 84 0c 02 00 00    	je     193605df <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xf9f>
    193603d3:	39 c8                	cmp    eax,ecx
    193603d5:	0f 94 c3             	sete   bl
    193603d8:	49 8b bf d0 01 00 00 	mov    rdi,QWORD PTR [r15+0x1d0]
    193603df:	e8 ac 0e 02 00       	call   19381290 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x6e70>
    193603e4:	48 89 45 a8          	mov    QWORD PTR [rbp-0x58],rax
    193603e8:	48 89 55 b0          	mov    QWORD PTR [rbp-0x50],rdx
    193603ec:	48 85 d2             	test   rdx,rdx
    193603ef:	0f 84 d7 01 00 00    	je     193605cc <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xf8c>
    193603f5:	84 db                	test   bl,bl
    193603f7:	0f 84 2d 01 00 00    	je     1936052a <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xeea>
    193603fd:	48 c7 45 d0 00 00 00 	mov    QWORD PTR [rbp-0x30],0x0
    19360404:	00 
    19360405:	41 0f b7 de          	movzx  ebx,r14w
    19360409:	41 0f b7 c5          	movzx  eax,r13w
    1936040d:	89 45 cc             	mov    DWORD PTR [rbp-0x34],eax
    19360410:	45 31 e4             	xor    r12d,r12d
    19360413:	eb 37                	jmp    1936044c <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xe0c>
    19360415:	48 8d 15 3c 7f 4b f0 	lea    rdx,[rip+0xfffffffff04b7f3c]        # 9818358 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0x63c>
    1936041c:	48 63 04 8a          	movsxd rax,DWORD PTR [rdx+rcx*4]
    19360420:	48 01 d0             	add    rax,rdx
    19360423:	ff e0                	jmp    rax
    19360425:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
    1936042c:	00 00 00 00 
    19360430:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    19360434:	44 39 f0             	cmp    eax,r14d
    19360437:	41 0f 4e c6          	cmovle eax,r14d
    1936043b:	48 89 45 d0          	mov    QWORD PTR [rbp-0x30],rax
    1936043f:	49 ff c4             	inc    r12
    19360442:	4c 39 65 b0          	cmp    QWORD PTR [rbp-0x50],r12
    19360446:	0f 84 80 01 00 00    	je     193605cc <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xf8c>
    1936044c:	48 8b 45 a8          	mov    rax,QWORD PTR [rbp-0x58]
    19360450:	46 0f b6 2c 20       	movzx  r13d,BYTE PTR [rax+r12*1]
    19360455:	49 8b bf d0 01 00 00 	mov    rdi,QWORD PTR [r15+0x1d0]
    1936045c:	89 de                	mov    esi,ebx
    1936045e:	44 89 ea             	mov    edx,r13d
    19360461:	e8 5a 0e 02 00       	call   193812c0 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x6ea0>
    19360466:	85 c0                	test   eax,eax
    19360468:	74 d5                	je     1936043f <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xdff>
    1936046a:	41 89 c6             	mov    r14d,eax
    1936046d:	49 8b bf d0 01 00 00 	mov    rdi,QWORD PTR [r15+0x1d0]
    19360474:	8b 75 cc             	mov    esi,DWORD PTR [rbp-0x34]
    19360477:	44 89 ea             	mov    edx,r13d
    1936047a:	e8 41 0e 02 00       	call   193812c0 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x6ea0>
    1936047f:	85 c0                	test   eax,eax
    19360481:	74 bc                	je     1936043f <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xdff>
    19360483:	41 83 fd 1f          	cmp    r13d,0x1f
    19360487:	77 b6                	ja     1936043f <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xdff>
    19360489:	44 89 e8             	mov    eax,r13d
    1936048c:	48 8d 0d 15 7b 4b f0 	lea    rcx,[rip+0xfffffffff04b7b15]        # 9817fa8 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0x28c>
    19360493:	48 63 04 81          	movsxd rax,DWORD PTR [rcx+rax*4]
    19360497:	48 01 c8             	add    rax,rcx
    1936049a:	ff e0                	jmp    rax
    1936049c:	48 8b 45 c0          	mov    rax,QWORD PTR [rbp-0x40]
    193604a0:	0f b7 40 1a          	movzx  eax,WORD PTR [rax+0x1a]
    193604a4:	8d 88 76 ff ff ff    	lea    ecx,[rax-0x8a]
    193604aa:	81 f9 cb 00 00 00    	cmp    ecx,0xcb
    193604b0:	77 47                	ja     193604f9 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xeb9>
    193604b2:	48 8d 15 6f 7b 4b f0 	lea    rdx,[rip+0xfffffffff04b7b6f]        # 9818028 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0x30c>
    193604b9:	48 63 04 8a          	movsxd rax,DWORD PTR [rdx+rcx*4]
    193604bd:	48 01 d0             	add    rax,rdx
    193604c0:	ff e0                	jmp    rax
    193604c2:	48 8b 45 b8          	mov    rax,QWORD PTR [rbp-0x48]
    193604c6:	0f b7 40 1a          	movzx  eax,WORD PTR [rax+0x1a]
    193604ca:	8d 88 76 ff ff ff    	lea    ecx,[rax-0x8a]
    193604d0:	81 f9 cb 00 00 00    	cmp    ecx,0xcb
    193604d6:	0f 86 39 ff ff ff    	jbe    19360415 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xdd5>
    193604dc:	83 f8 3a             	cmp    eax,0x3a
    193604df:	77 2f                	ja     19360510 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xed0>
    193604e1:	89 c0                	mov    eax,eax
    193604e3:	48 b9 00 00 00 00 00 	movabs rcx,0x620000000000000
    193604ea:	00 20 06 
    193604ed:	48 0f a3 c1          	bt     rcx,rax
    193604f1:	0f 82 39 ff ff ff    	jb     19360430 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xdf0>
    193604f7:	eb 17                	jmp    19360510 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xed0>
    193604f9:	83 f8 3a             	cmp    eax,0x3a
    193604fc:	77 12                	ja     19360510 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xed0>
    193604fe:	89 c0                	mov    eax,eax
    19360500:	48 b9 00 00 00 00 00 	movabs rcx,0x620000000000000
    19360507:	00 20 06 
    1936050a:	48 0f a3 c1          	bt     rcx,rax
    1936050e:	72 b2                	jb     193604c2 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xe82>
    19360510:	48 8b 7d c0          	mov    rdi,QWORD PTR [rbp-0x40]
    19360514:	48 8b 75 b8          	mov    rsi,QWORD PTR [rbp-0x48]
    19360518:	e8 43 bf 5d 00       	call   1993c460 <_ZN3xla9jellyfish32LloInstructionsPushOrPopSameFifoEPKNS0_8LloValueES3_>
    1936051d:	84 c0                	test   al,al
    1936051f:	0f 85 0b ff ff ff    	jne    19360430 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xdf0>
    19360525:	e9 15 ff ff ff       	jmp    1936043f <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xdff>
    1936052a:	48 c7 45 d0 00 00 00 	mov    QWORD PTR [rbp-0x30],0x0
    19360531:	00 
    19360532:	45 0f b7 f6          	movzx  r14d,r14w
    19360536:	41 0f b7 c5          	movzx  eax,r13w
    1936053a:	89 45 cc             	mov    DWORD PTR [rbp-0x34],eax
    1936053d:	31 db                	xor    ebx,ebx
    1936053f:	eb 27                	jmp    19360568 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xf28>
    19360541:	66 66 66 66 66 66 2e 	data16 data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
    19360548:	0f 1f 84 00 00 00 00 
    1936054f:	00 
    19360550:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    19360554:	44 39 e8             	cmp    eax,r13d
    19360557:	41 0f 4e c5          	cmovle eax,r13d
    1936055b:	48 89 45 d0          	mov    QWORD PTR [rbp-0x30],rax
    1936055f:	48 ff c3             	inc    rbx
    19360562:	48 39 5d b0          	cmp    QWORD PTR [rbp-0x50],rbx
    19360566:	74 64                	je     193605cc <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xf8c>
    19360568:	48 8b 45 a8          	mov    rax,QWORD PTR [rbp-0x58]
    1936056c:	44 0f b6 24 18       	movzx  r12d,BYTE PTR [rax+rbx*1]
    19360571:	49 8b bf d0 01 00 00 	mov    rdi,QWORD PTR [r15+0x1d0]
    19360578:	44 89 f6             	mov    esi,r14d
    1936057b:	44 89 e2             	mov    edx,r12d
    1936057e:	e8 3d 0d 02 00       	call   193812c0 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x6ea0>
    19360583:	85 c0                	test   eax,eax
    19360585:	74 d8                	je     1936055f <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xf1f>
    19360587:	41 89 c5             	mov    r13d,eax
    1936058a:	49 8b bf d0 01 00 00 	mov    rdi,QWORD PTR [r15+0x1d0]
    19360591:	8b 75 cc             	mov    esi,DWORD PTR [rbp-0x34]
    19360594:	44 89 e2             	mov    edx,r12d
    19360597:	e8 24 0d 02 00       	call   193812c0 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x6ea0>
    1936059c:	85 c0                	test   eax,eax
    1936059e:	74 bf                	je     1936055f <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xf1f>
    193605a0:	41 83 fc 1f          	cmp    r12d,0x1f
    193605a4:	77 b9                	ja     1936055f <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xf1f>
    193605a6:	44 89 e0             	mov    eax,r12d
    193605a9:	48 8d 0d 78 79 4b f0 	lea    rcx,[rip+0xfffffffff04b7978]        # 9817f28 <_ZTSN3xla9ghostlite21LatencyTableGhostliteE+0x20c>
    193605b0:	48 63 04 81          	movsxd rax,DWORD PTR [rcx+rax*4]
    193605b4:	48 01 c8             	add    rax,rcx
    193605b7:	ff e0                	jmp    rax
    193605b9:	48 8b 7d c0          	mov    rdi,QWORD PTR [rbp-0x40]
    193605bd:	48 8b 75 b8          	mov    rsi,QWORD PTR [rbp-0x48]
    193605c1:	e8 9a be 5d 00       	call   1993c460 <_ZN3xla9jellyfish32LloInstructionsPushOrPopSameFifoEPKNS0_8LloValueES3_>
    193605c6:	84 c0                	test   al,al
    193605c8:	75 86                	jne    19360550 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xf10>
    193605ca:	eb 93                	jmp    1936055f <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xf1f>
    193605cc:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    193605d0:	48 83 c4 48          	add    rsp,0x48
    193605d4:	5b                   	pop    rbx
    193605d5:	41 5c                	pop    r12
    193605d7:	41 5d                	pop    r13
    193605d9:	41 5e                	pop    r14
    193605db:	41 5f                	pop    r15
    193605dd:	5d                   	pop    rbp
    193605de:	c3                   	ret
    193605df:	0f 0b                	ud2
    193605e1:	48 8d 35 25 d5 a2 ed 	lea    rsi,[rip+0xffffffffeda2d525]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    193605e8:	48 8d 5d 98          	lea    rbx,[rbp-0x68]
    193605ec:	48 89 df             	mov    rdi,rbx
    193605ef:	ba 37 04 00 00       	mov    edx,0x437
    193605f4:	e8 dd f0 71 04       	call   1da7f6d6 <_ZN4absl12log_internal15LogMessageFatalC1EPKci>
    193605f9:	48 8d 35 62 db 46 ef 	lea    rsi,[rip+0xffffffffef46db62]        # 87ce162 <nilstr+0xd8e7e>
    19360600:	48 89 df             	mov    rdi,rbx
    19360603:	e8 98 c5 a7 f3       	call   cddcba0 <_ZN4absl12log_internal10LogMessagelsILi43EEERS1_RAT__Kc>
    19360608:	48 89 c7             	mov    rdi,rax
    1936060b:	48 8b 75 c0          	mov    rsi,QWORD PTR [rbp-0x40]
    1936060f:	e8 1c 63 d4 f5       	call   f0a6930 <_ZN4absl12log_internal10LogMessagelsIN3xla9jellyfish8LloValueEEERS1_RKT_>
    19360614:	48 89 c7             	mov    rdi,rax
    19360617:	e8 e4 42 43 04       	call   1d794900 <_ZN4absl12log_internal10LogMessage5FlushEv>
    1936061c:	48 89 df             	mov    rdi,rbx
    1936061f:	e8 2c f1 71 04       	call   1da7f750 <_ZN4absl12log_internal15LogMessageFatalD1Ev>
    19360624:	48 8d 35 e2 d4 a2 ed 	lea    rsi,[rip+0xffffffffeda2d4e2]        # 6d8db0d <sqlite3_str_vappendf.zOrd+0xa08a6>
    1936062b:	48 8d 5d 98          	lea    rbx,[rbp-0x68]
    1936062f:	48 89 df             	mov    rdi,rbx
    19360632:	ba 1c 04 00 00       	mov    edx,0x41c
    19360637:	e8 9a f0 71 04       	call   1da7f6d6 <_ZN4absl12log_internal15LogMessageFatalC1EPKci>
    1936063c:	48 8d 35 4f 97 9a ed 	lea    rsi,[rip+0xffffffffed9a974f]        # 6d09d92 <sqlite3_str_vappendf.zOrd+0x1cb2b>
    19360643:	48 89 df             	mov    rdi,rbx
    19360646:	e8 95 70 41 f3       	call   c7776e0 <_ZN4absl12log_internal10LogMessagelsILi14EEERS1_RAT__Kc>
    1936064b:	48 89 c7             	mov    rdi,rax
    1936064e:	e8 ad 42 43 04       	call   1d794900 <_ZN4absl12log_internal10LogMessage5FlushEv>
    19360653:	48 89 df             	mov    rdi,rbx
    19360656:	e8 f5 f0 71 04       	call   1da7f750 <_ZN4absl12log_internal15LogMessageFatalD1Ev>
    1936065b:	cc                   	int3
    1936065c:	cc                   	int3
    1936065d:	cc                   	int3
    1936065e:	cc                   	int3
    1936065f:	cc                   	int3
