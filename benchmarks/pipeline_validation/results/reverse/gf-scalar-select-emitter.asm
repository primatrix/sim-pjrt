
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

000000001578c0d0 <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE>:
    1578c0d0:	55                   	push   rbp
    1578c0d1:	48 89 e5             	mov    rbp,rsp
    1578c0d4:	41 57                	push   r15
    1578c0d6:	41 56                	push   r14
    1578c0d8:	41 55                	push   r13
    1578c0da:	41 54                	push   r12
    1578c0dc:	53                   	push   rbx
    1578c0dd:	48 81 ec b8 00 00 00 	sub    rsp,0xb8
    1578c0e4:	48 89 f3             	mov    rbx,rsi
    1578c0e7:	49 89 fe             	mov    r14,rdi
    1578c0ea:	e8 f1 e6 ff ff       	call   1578a7e0 <_ZNK3xla9jellyfish13CodeGenerator26PredicationFromInstructionERKNS0_14LloInstructionE>
    1578c0ef:	89 45 d0             	mov    DWORD PTR [rbp-0x30],eax
    1578c0f2:	48 c1 e8 20          	shr    rax,0x20
    1578c0f6:	88 45 d4             	mov    BYTE PTR [rbp-0x2c],al
    1578c0f9:	48 8d 7d d0          	lea    rdi,[rbp-0x30]
    1578c0fd:	e8 de 7c 2d 04       	call   19a63de0 <_ZNK3xla9jellyfish11Predication17is_always_executeEv>
    1578c102:	84 c0                	test   al,al
    1578c104:	0f 84 ed 02 00 00    	je     1578c3f7 <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x327>
    1578c10a:	48 63 43 f0          	movsxd rax,DWORD PTR [rbx-0x10]
    1578c10e:	0f b7 4b 1c          	movzx  ecx,WORD PTR [rbx+0x1c]
    1578c112:	83 e1 03             	and    ecx,0x3
    1578c115:	48 89 c6             	mov    rsi,rax
    1578c118:	48 29 ce             	sub    rsi,rcx
    1578c11b:	85 f6                	test   esi,esi
    1578c11d:	0f 8e 03 03 00 00    	jle    1578c426 <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x356>
    1578c123:	48 c1 e0 03          	shl    rax,0x3
    1578c127:	48 89 d9             	mov    rcx,rbx
    1578c12a:	48 29 c1             	sub    rcx,rax
    1578c12d:	48 8b 71 f0          	mov    rsi,QWORD PTR [rcx-0x10]
    1578c131:	0f b7 46 1a          	movzx  eax,WORD PTR [rsi+0x1a]
    1578c135:	48 3d ce 01 00 00    	cmp    rax,0x1ce
    1578c13b:	0f 83 bc 03 00 00    	jae    1578c4fd <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x42d>
    1578c141:	48 8d 0d 48 b7 29 09 	lea    rcx,[rip+0x929b748]        # 1ea27890 <_ZN3xla9jellyfish8internal29opcode_produced_register_typeE>
    1578c148:	80 3c 01 01          	cmp    BYTE PTR [rcx+rax*1],0x1
    1578c14c:	0f 85 89 02 00 00    	jne    1578c3db <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x30b>
    1578c152:	4d 8b 3e             	mov    r15,QWORD PTR [r14]
    1578c155:	4c 89 f7             	mov    rdi,r14
    1578c158:	e8 93 d4 ff ff       	call   157895f0 <_ZNK3xla9jellyfish13CodeGenerator13GetRegnoOrDieERKNS0_8LloValueE>
    1578c15d:	89 45 d0             	mov    DWORD PTR [rbp-0x30],eax
    1578c160:	c6 45 d4 00          	mov    BYTE PTR [rbp-0x2c],0x0
    1578c164:	4d 8d af 98 01 00 00 	lea    r13,[r15+0x198]
    1578c16b:	41 8b 87 a0 01 00 00 	mov    eax,DWORD PTR [r15+0x1a0]
    1578c172:	89 45 c0             	mov    DWORD PTR [rbp-0x40],eax
    1578c175:	4d 8d a7 7c 01 00 00 	lea    r12,[r15+0x17c]
    1578c17c:	49 8d 97 88 01 00 00 	lea    rdx,[r15+0x188]
    1578c183:	4c 89 ef             	mov    rdi,r13
    1578c186:	4c 89 e6             	mov    rsi,r12
    1578c189:	e8 42 35 01 00       	call   1579f6d0 <_ZNSt3__u6vectorIN3xla9jellyfish10IsaEmitter10SavedStateENS_9allocatorIS4_EEE12emplace_backIJRNS2_11PredicationERNS_17basic_string_viewIcNS_11char_traitsIcEEEEEEERS4_DpOT_>
    1578c18e:	48 8d 7d d0          	lea    rdi,[rbp-0x30]
    1578c192:	e8 49 7c 2d 04       	call   19a63de0 <_ZNK3xla9jellyfish11Predication17is_always_executeEv>
    1578c197:	49 8b 8f a0 01 00 00 	mov    rcx,QWORD PTR [r15+0x1a0]
    1578c19e:	48 85 c9             	test   rcx,rcx
    1578c1a1:	0f 84 b9 02 00 00    	je     1578c460 <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x390>
    1578c1a7:	49 8b 97 98 01 00 00 	mov    rdx,QWORD PTR [r15+0x198]
    1578c1ae:	48 c1 e1 05          	shl    rcx,0x5
    1578c1b2:	88 44 0a e1          	mov    BYTE PTR [rdx+rcx*1-0x1f],al
    1578c1b6:	49 8b 87 a0 01 00 00 	mov    rax,QWORD PTR [r15+0x1a0]
    1578c1bd:	48 85 c0             	test   rax,rax
    1578c1c0:	0f 84 9c 02 00 00    	je     1578c462 <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x392>
    1578c1c6:	49 8b 4d 00          	mov    rcx,QWORD PTR [r13+0x0]
    1578c1ca:	48 c1 e0 05          	shl    rax,0x5
    1578c1ce:	8b 55 c0             	mov    edx,DWORD PTR [rbp-0x40]
    1578c1d1:	89 54 01 e4          	mov    DWORD PTR [rcx+rax*1-0x1c],edx
    1578c1d5:	0f b6 45 d4          	movzx  eax,BYTE PTR [rbp-0x2c]
    1578c1d9:	41 88 44 24 04       	mov    BYTE PTR [r12+0x4],al
    1578c1de:	8b 45 d0             	mov    eax,DWORD PTR [rbp-0x30]
    1578c1e1:	41 89 04 24          	mov    DWORD PTR [r12],eax
    1578c1e5:	4c 89 f7             	mov    rdi,r14
    1578c1e8:	48 89 de             	mov    rsi,rbx
    1578c1eb:	e8 c0 db ff ff       	call   15789db0 <_ZNK3xla9jellyfish13CodeGenerator7GetSregERKNS0_8LloValueE>
    1578c1f0:	41 89 c4             	mov    r12d,eax
    1578c1f3:	48 63 43 f0          	movsxd rax,DWORD PTR [rbx-0x10]
    1578c1f7:	0f b7 4b 1c          	movzx  ecx,WORD PTR [rbx+0x1c]
    1578c1fb:	83 e1 03             	and    ecx,0x3
    1578c1fe:	48 89 c6             	mov    rsi,rax
    1578c201:	48 29 ce             	sub    rsi,rcx
    1578c204:	83 fe 01             	cmp    esi,0x1
    1578c207:	0f 8e 57 02 00 00    	jle    1578c464 <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x394>
    1578c20d:	b9 01 00 00 00       	mov    ecx,0x1
    1578c212:	48 29 c1             	sub    rcx,rax
    1578c215:	48 8b 54 cb f0       	mov    rdx,QWORD PTR [rbx+rcx*8-0x10]
    1578c21a:	48 8d bd 50 ff ff ff 	lea    rdi,[rbp-0xb0]
    1578c221:	4c 89 f6             	mov    rsi,r14
    1578c224:	e8 77 de ff ff       	call   1578a0a0 <_ZNK3xla9jellyfish13CodeGenerator12GetSregOrImmERKNS0_8LloValueE>
    1578c229:	49 8b 07             	mov    rax,QWORD PTR [r15]
    1578c22c:	48 8b 8d 70 ff ff ff 	mov    rcx,QWORD PTR [rbp-0x90]
    1578c233:	48 89 4c 24 20       	mov    QWORD PTR [rsp+0x20],rcx
    1578c238:	c5 fc 10 85 50 ff ff 	vmovups ymm0,YMMWORD PTR [rbp-0xb0]
    1578c23f:	ff 
    1578c240:	c5 fc 11 04 24       	vmovups YMMWORD PTR [rsp],ymm0
    1578c245:	4c 89 ff             	mov    rdi,r15
    1578c248:	44 89 e6             	mov    esi,r12d
    1578c24b:	ba 7c 01 00 00       	mov    edx,0x17c
    1578c250:	c5 f8 77             	vzeroupper
    1578c253:	ff 90 20 01 00 00    	call   QWORD PTR [rax+0x120]
    1578c259:	49 89 c5             	mov    r13,rax
    1578c25c:	48 63 43 f0          	movsxd rax,DWORD PTR [rbx-0x10]
    1578c260:	0f b7 4b 1c          	movzx  ecx,WORD PTR [rbx+0x1c]
    1578c264:	83 e1 03             	and    ecx,0x3
    1578c267:	48 89 c6             	mov    rsi,rax
    1578c26a:	48 29 ce             	sub    rsi,rcx
    1578c26d:	85 f6                	test   esi,esi
    1578c26f:	0f 8e fd 01 00 00    	jle    1578c472 <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x3a2>
    1578c275:	48 c1 e0 03          	shl    rax,0x3
    1578c279:	48 89 d9             	mov    rcx,rbx
    1578c27c:	48 29 c1             	sub    rcx,rax
    1578c27f:	48 8b 71 f0          	mov    rsi,QWORD PTR [rcx-0x10]
    1578c283:	0f b7 46 1a          	movzx  eax,WORD PTR [rsi+0x1a]
    1578c287:	48 3d ce 01 00 00    	cmp    rax,0x1ce
    1578c28d:	0f 83 6f 02 00 00    	jae    1578c502 <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x432>
    1578c293:	48 8d 0d f6 b5 29 09 	lea    rcx,[rip+0x929b5f6]        # 1ea27890 <_ZN3xla9jellyfish8internal29opcode_produced_register_typeE>
    1578c29a:	80 3c 01 01          	cmp    BYTE PTR [rcx+rax*1],0x1
    1578c29e:	0f 85 37 01 00 00    	jne    1578c3db <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x30b>
    1578c2a4:	4c 89 75 a0          	mov    QWORD PTR [rbp-0x60],r14
    1578c2a8:	4c 89 f7             	mov    rdi,r14
    1578c2ab:	e8 40 d3 ff ff       	call   157895f0 <_ZNK3xla9jellyfish13CodeGenerator13GetRegnoOrDieERKNS0_8LloValueE>
    1578c2b0:	89 45 c8             	mov    DWORD PTR [rbp-0x38],eax
    1578c2b3:	c6 45 cc 01          	mov    BYTE PTR [rbp-0x34],0x1
    1578c2b7:	49 8d bd 98 01 00 00 	lea    rdi,[r13+0x198]
    1578c2be:	45 8b b5 a0 01 00 00 	mov    r14d,DWORD PTR [r13+0x1a0]
    1578c2c5:	4d 8d a5 7c 01 00 00 	lea    r12,[r13+0x17c]
    1578c2cc:	4c 89 ea             	mov    rdx,r13
    1578c2cf:	48 81 c2 88 01 00 00 	add    rdx,0x188
    1578c2d6:	4c 89 e6             	mov    rsi,r12
    1578c2d9:	e8 f2 33 01 00       	call   1579f6d0 <_ZNSt3__u6vectorIN3xla9jellyfish10IsaEmitter10SavedStateENS_9allocatorIS4_EEE12emplace_backIJRNS2_11PredicationERNS_17basic_string_viewIcNS_11char_traitsIcEEEEEEERS4_DpOT_>
    1578c2de:	48 8d 7d c8          	lea    rdi,[rbp-0x38]
    1578c2e2:	e8 f9 7a 2d 04       	call   19a63de0 <_ZNK3xla9jellyfish11Predication17is_always_executeEv>
    1578c2e7:	49 8b 8d a0 01 00 00 	mov    rcx,QWORD PTR [r13+0x1a0]
    1578c2ee:	48 85 c9             	test   rcx,rcx
    1578c2f1:	0f 84 b2 01 00 00    	je     1578c4a9 <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x3d9>
    1578c2f7:	49 8b 95 98 01 00 00 	mov    rdx,QWORD PTR [r13+0x198]
    1578c2fe:	48 c1 e1 05          	shl    rcx,0x5
    1578c302:	88 44 0a e1          	mov    BYTE PTR [rdx+rcx*1-0x1f],al
    1578c306:	49 8b 85 a0 01 00 00 	mov    rax,QWORD PTR [r13+0x1a0]
    1578c30d:	48 85 c0             	test   rax,rax
    1578c310:	0f 84 95 01 00 00    	je     1578c4ab <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x3db>
    1578c316:	49 8d 8d 98 01 00 00 	lea    rcx,[r13+0x198]
    1578c31d:	48 8b 09             	mov    rcx,QWORD PTR [rcx]
    1578c320:	48 c1 e0 05          	shl    rax,0x5
    1578c324:	44 89 74 01 e4       	mov    DWORD PTR [rcx+rax*1-0x1c],r14d
    1578c329:	0f b6 45 cc          	movzx  eax,BYTE PTR [rbp-0x34]
    1578c32d:	41 88 44 24 04       	mov    BYTE PTR [r12+0x4],al
    1578c332:	8b 45 c8             	mov    eax,DWORD PTR [rbp-0x38]
    1578c335:	41 89 04 24          	mov    DWORD PTR [r12],eax
    1578c339:	4c 8b 65 a0          	mov    r12,QWORD PTR [rbp-0x60]
    1578c33d:	4c 89 e7             	mov    rdi,r12
    1578c340:	48 89 de             	mov    rsi,rbx
    1578c343:	e8 68 da ff ff       	call   15789db0 <_ZNK3xla9jellyfish13CodeGenerator7GetSregERKNS0_8LloValueE>
    1578c348:	48 63 53 f0          	movsxd rdx,DWORD PTR [rbx-0x10]
    1578c34c:	0f b7 4b 1c          	movzx  ecx,WORD PTR [rbx+0x1c]
    1578c350:	83 e1 03             	and    ecx,0x3
    1578c353:	48 89 d6             	mov    rsi,rdx
    1578c356:	48 29 ce             	sub    rsi,rcx
    1578c359:	83 fe 02             	cmp    esi,0x2
    1578c35c:	0f 8e 4b 01 00 00    	jle    1578c4ad <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x3dd>
    1578c362:	b9 02 00 00 00       	mov    ecx,0x2
    1578c367:	48 29 d1             	sub    rcx,rdx
    1578c36a:	44 89 75 bc          	mov    DWORD PTR [rbp-0x44],r14d
    1578c36e:	41 89 c6             	mov    r14d,eax
    1578c371:	48 8b 54 cb f0       	mov    rdx,QWORD PTR [rbx+rcx*8-0x10]
    1578c376:	48 8d bd 78 ff ff ff 	lea    rdi,[rbp-0x88]
    1578c37d:	4c 89 e6             	mov    rsi,r12
    1578c380:	e8 1b dd ff ff       	call   1578a0a0 <_ZNK3xla9jellyfish13CodeGenerator12GetSregOrImmERKNS0_8LloValueE>
    1578c385:	49 8b 45 00          	mov    rax,QWORD PTR [r13+0x0]
    1578c389:	48 8b 4d 98          	mov    rcx,QWORD PTR [rbp-0x68]
    1578c38d:	48 89 4c 24 20       	mov    QWORD PTR [rsp+0x20],rcx
    1578c392:	c5 fc 10 85 78 ff ff 	vmovups ymm0,YMMWORD PTR [rbp-0x88]
    1578c399:	ff 
    1578c39a:	c5 fc 11 04 24       	vmovups YMMWORD PTR [rsp],ymm0
    1578c39f:	4c 89 ef             	mov    rdi,r13
    1578c3a2:	44 89 f6             	mov    esi,r14d
    1578c3a5:	ba 7c 01 00 00       	mov    edx,0x17c
    1578c3aa:	c5 f8 77             	vzeroupper
    1578c3ad:	ff 90 20 01 00 00    	call   QWORD PTR [rax+0x120]
    1578c3b3:	4c 89 ef             	mov    rdi,r13
    1578c3b6:	8b 75 bc             	mov    esi,DWORD PTR [rbp-0x44]
    1578c3b9:	e8 72 35 01 00       	call   1579f930 <_ZN3xla9jellyfish10IsaEmitter17RestoreSavedStateEi>
    1578c3be:	4c 89 ff             	mov    rdi,r15
    1578c3c1:	8b 75 c0             	mov    esi,DWORD PTR [rbp-0x40]
    1578c3c4:	e8 67 35 01 00       	call   1579f930 <_ZN3xla9jellyfish10IsaEmitter17RestoreSavedStateEi>
    1578c3c9:	48 81 c4 b8 00 00 00 	add    rsp,0xb8
    1578c3d0:	5b                   	pop    rbx
    1578c3d1:	41 5c                	pop    r12
    1578c3d3:	41 5d                	pop    r13
    1578c3d5:	41 5e                	pop    r14
    1578c3d7:	41 5f                	pop    r15
    1578c3d9:	5d                   	pop    rbp
    1578c3da:	c3                   	ret
    1578c3db:	48 8d 35 86 27 5d f1 	lea    rsi,[rip+0xfffffffff15d2786]        # 6d5eb68 <sqlite3_str_vappendf.zOrd+0x71901>
    1578c3e2:	48 8d 0d 06 c6 fa f2 	lea    rcx,[rip+0xfffffffff2fac606]        # 87389ef <nilstr+0x4370b>
    1578c3e9:	48 8d 5d a8          	lea    rbx,[rbp-0x58]
    1578c3ed:	48 89 df             	mov    rdi,rbx
    1578c3f0:	ba 56 04 00 00       	mov    edx,0x456
    1578c3f5:	eb 1a                	jmp    1578c411 <_ZN3xla9jellyfish13CodeGenerator16EmitScalarSelectERKNS0_14LloInstructionE+0x341>
    1578c3f7:	48 8d 35 6a 27 5d f1 	lea    rsi,[rip+0xfffffffff15d276a]        # 6d5eb68 <sqlite3_str_vappendf.zOrd+0x71901>
    1578c3fe:	48 8d 0d b5 5a fd f2 	lea    rcx,[rip+0xfffffffff2fd5ab5]        # 8761eba <nilstr+0x6cbd6>
    1578c405:	48 8d 5d a8          	lea    rbx,[rbp-0x58]
    1578c409:	48 89 df             	mov    rdi,rbx
    1578c40c:	ba ff 05 00 00       	mov    edx,0x5ff
    1578c411:	e8 d0 32 2f 08       	call   1da7f6e6 <_ZN4absl12log_internal15LogMessageFatalC1EPKciS3_>
    1578c416:	48 89 df             	mov    rdi,rbx
    1578c419:	e8 e2 84 00 08       	call   1d794900 <_ZN4absl12log_internal10LogMessage5FlushEv>
    1578c41e:	48                   	rex.W
    1578c41f:	89                   	.byte 0x89
