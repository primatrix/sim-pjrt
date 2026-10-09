
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

0000000019e6a090 <xla::jellyfish::LloOpcodeName(xla::jellyfish::LloOpcode)>:
    19e6a090:	55                   	push   rbp
    19e6a091:	48 89 e5             	mov    rbp,rsp
    19e6a094:	41 57                	push   r15
    19e6a096:	41 56                	push   r14
    19e6a098:	41 55                	push   r13
    19e6a09a:	41 54                	push   r12
    19e6a09c:	53                   	push   rbx
    19e6a09d:	50                   	push   rax
    19e6a09e:	81 fe ce 01 00 00    	cmp    esi,0x1ce
    19e6a0a4:	0f 83 9d 00 00 00    	jae    19e6a147 <xla::jellyfish::LloOpcodeName(xla::jellyfish::LloOpcode)+0xb7>
    19e6a0aa:	48 89 fb             	mov    rbx,rdi
    19e6a0ad:	49 bc f6 ff ff ff ff 	movabs r12,0x7ffffffffffffff6
    19e6a0b4:	ff ff 7f 
    19e6a0b7:	0f b7 c6             	movzx  eax,si
    19e6a0ba:	48 8d 0d af fc 47 04 	lea    rcx,[rip+0x447fcaf]        # 1e2e9d70 <xla::jellyfish::LloOpcodeName(xla::jellyfish::LloOpcode)::opcode_name>
    19e6a0c1:	4c 8b 34 c1          	mov    r14,QWORD PTR [rcx+rax*8]
    19e6a0c5:	4c 89 f7             	mov    rdi,r14
    19e6a0c8:	e8 13 e0 c1 03       	call   1da880e0 <strlen@plt>
    19e6a0cd:	4c 39 e0             	cmp    rax,r12
    19e6a0d0:	77 7a                	ja     19e6a14c <xla::jellyfish::LloOpcodeName(xla::jellyfish::LloOpcode)+0xbc>
    19e6a0d2:	49 89 c7             	mov    r15,rax
    19e6a0d5:	48 83 f8 16          	cmp    rax,0x16
    19e6a0d9:	77 09                	ja     19e6a0e4 <xla::jellyfish::LloOpcodeName(xla::jellyfish::LloOpcode)+0x54>
    19e6a0db:	44 88 7b 17          	mov    BYTE PTR [rbx+0x17],r15b
    19e6a0df:	49 89 dc             	mov    r12,rbx
    19e6a0e2:	eb 3e                	jmp    19e6a122 <xla::jellyfish::LloOpcodeName(xla::jellyfish::LloOpcode)+0x92>
    19e6a0e4:	49 8d 44 24 02       	lea    rax,[r12+0x2]
    19e6a0e9:	4c 89 f9             	mov    rcx,r15
    19e6a0ec:	48 21 c1             	and    rcx,rax
    19e6a0ef:	48 83 c1 08          	add    rcx,0x8
    19e6a0f3:	48 83 f9 18          	cmp    rcx,0x18
    19e6a0f7:	41 bd 19 00 00 00    	mov    r13d,0x19
    19e6a0fd:	4c 0f 45 e9          	cmovne r13,rcx
    19e6a101:	4c 89 ef             	mov    rdi,r13
    19e6a104:	e8 77 50 9e 03       	call   1d84f180 <operator new(unsigned long)>
    19e6a109:	4c 89 e1             	mov    rcx,r12
    19e6a10c:	49 89 c4             	mov    r12,rax
    19e6a10f:	4a 8d 04 29          	lea    rax,[rcx+r13*1]
    19e6a113:	48 83 c0 0a          	add    rax,0xa
    19e6a117:	4c 89 23             	mov    QWORD PTR [rbx],r12
    19e6a11a:	4c 89 7b 08          	mov    QWORD PTR [rbx+0x8],r15
    19e6a11e:	48 89 43 10          	mov    QWORD PTR [rbx+0x10],rax
    19e6a122:	4c 89 e7             	mov    rdi,r12
    19e6a125:	4c 89 f6             	mov    rsi,r14
    19e6a128:	4c 89 fa             	mov    rdx,r15
    19e6a12b:	e8 40 51 9a 03       	call   1d80f270 <memmove>
    19e6a130:	43 c6 04 3c 00       	mov    BYTE PTR [r12+r15*1],0x0
    19e6a135:	48 89 d8             	mov    rax,rbx
    19e6a138:	48 83 c4 08          	add    rsp,0x8
    19e6a13c:	5b                   	pop    rbx
    19e6a13d:	41 5c                	pop    r12
    19e6a13f:	41 5d                	pop    r13
    19e6a141:	41 5e                	pop    r14
    19e6a143:	41 5f                	pop    r15
    19e6a145:	5d                   	pop    rbp
    19e6a146:	c3                   	ret
    19e6a147:	67 0f b9 40 12       	ud1    eax,DWORD PTR [eax+0x12]
    19e6a14c:	e8 af 58 83 f2       	call   c69fa00 <std::__u::basic_string<char, std::__u::char_traits<char>, std::__u::allocator<char> >::__throw_length_error()>
    19e6a151:	cc                   	int3
    19e6a152:	cc                   	int3
    19e6a153:	cc                   	int3
    19e6a154:	cc                   	int3
    19e6a155:	cc                   	int3
    19e6a156:	cc                   	int3
    19e6a157:	cc                   	int3
    19e6a158:	cc                   	int3
    19e6a159:	cc                   	int3
    19e6a15a:	cc                   	int3
    19e6a15b:	cc                   	int3
    19e6a15c:	cc                   	int3
    19e6a15d:	cc                   	int3
    19e6a15e:	cc                   	int3
    19e6a15f:	cc                   	int3

0000000019e6a160 <xla::jellyfish::LloOpcodeString(xla::jellyfish::LloOpcode)>:
    19e6a160:	55                   	push   rbp
    19e6a161:	48 89 e5             	mov    rbp,rsp
    19e6a164:	41 57                	push   r15
    19e6a166:	41 56                	push   r14
    19e6a168:	41 55                	push   r13
    19e6a16a:	41 54                	push   r12
    19e6a16c:	53                   	push   rbx
    19e6a16d:	50                   	push   rax
    19e6a16e:	81 fe ce 01 00 00    	cmp    esi,0x1ce
    19e6a174:	0f 83 9d 00 00 00    	jae    19e6a217 <xla::jellyfish::LloOpcodeString(xla::jellyfish::LloOpcode)+0xb7>
    19e6a17a:	48 89 fb             	mov    rbx,rdi
    19e6a17d:	49 bc f6 ff ff ff ff 	movabs r12,0x7ffffffffffffff6
    19e6a184:	ff ff 7f 
    19e6a187:	0f b7 c6             	movzx  eax,si
    19e6a18a:	48 8d 0d 4f 0a 48 04 	lea    rcx,[rip+0x4480a4f]        # 1e2eabe0 <xla::jellyfish::LloOpcodeString(xla::jellyfish::LloOpcode)::opcode_string>
    19e6a191:	4c 8b 34 c1          	mov    r14,QWORD PTR [rcx+rax*8]
    19e6a195:	4c 89 f7             	mov    rdi,r14
    19e6a198:	e8 43 df c1 03       	call   1da880e0 <strlen@plt>
    19e6a19d:	4c 39 e0             	cmp    rax,r12
    19e6a1a0:	77 7a                	ja     19e6a21c <xla::jellyfish::LloOpcodeString(xla::jellyfish::LloOpcode)+0xbc>
    19e6a1a2:	49 89 c7             	mov    r15,rax
    19e6a1a5:	48 83 f8 16          	cmp    rax,0x16
    19e6a1a9:	77 09                	ja     19e6a1b4 <xla::jellyfish::LloOpcodeString(xla::jellyfish::LloOpcode)+0x54>
    19e6a1ab:	44 88 7b 17          	mov    BYTE PTR [rbx+0x17],r15b
    19e6a1af:	49 89 dc             	mov    r12,rbx
    19e6a1b2:	eb 3e                	jmp    19e6a1f2 <xla::jellyfish::LloOpcodeString(xla::jellyfish::LloOpcode)+0x92>
    19e6a1b4:	49 8d 44 24 02       	lea    rax,[r12+0x2]
    19e6a1b9:	4c 89 f9             	mov    rcx,r15
    19e6a1bc:	48 21 c1             	and    rcx,rax
    19e6a1bf:	48 83 c1 08          	add    rcx,0x8
    19e6a1c3:	48 83 f9 18          	cmp    rcx,0x18
    19e6a1c7:	41 bd 19 00 00 00    	mov    r13d,0x19
    19e6a1cd:	4c 0f 45 e9          	cmovne r13,rcx
    19e6a1d1:	4c 89 ef             	mov    rdi,r13
    19e6a1d4:	e8 a7 4f 9e 03       	call   1d84f180 <operator new(unsigned long)>
    19e6a1d9:	4c 89 e1             	mov    rcx,r12
    19e6a1dc:	49 89 c4             	mov    r12,rax
    19e6a1df:	4a 8d 04 29          	lea    rax,[rcx+r13*1]
    19e6a1e3:	48 83 c0 0a          	add    rax,0xa
    19e6a1e7:	4c 89 23             	mov    QWORD PTR [rbx],r12
    19e6a1ea:	4c 89 7b 08          	mov    QWORD PTR [rbx+0x8],r15
    19e6a1ee:	48 89 43 10          	mov    QWORD PTR [rbx+0x10],rax
    19e6a1f2:	4c 89 e7             	mov    rdi,r12
    19e6a1f5:	4c 89 f6             	mov    rsi,r14
    19e6a1f8:	4c 89 fa             	mov    rdx,r15
    19e6a1fb:	e8 70 50 9a 03       	call   1d80f270 <memmove>
    19e6a200:	43 c6 04 3c 00       	mov    BYTE PTR [r12+r15*1],0x0
    19e6a205:	48 89 d8             	mov    rax,rbx
    19e6a208:	48 83 c4 08          	add    rsp,0x8
    19e6a20c:	5b                   	pop    rbx
    19e6a20d:	41 5c                	pop    r12
    19e6a20f:	41 5d                	pop    r13
    19e6a211:	41 5e                	pop    r14
    19e6a213:	41 5f                	pop    r15
    19e6a215:	5d                   	pop    rbp
    19e6a216:	c3                   	ret
    19e6a217:	67 0f b9 40 12       	ud1    eax,DWORD PTR [eax+0x12]
    19e6a21c:	e8 df 57 83 f2       	call   c69fa00 <std::__u::basic_string<char, std::__u::char_traits<char>, std::__u::allocator<char> >::__throw_length_error()>
    19e6a221:	cc                   	int3
    19e6a222:	cc                   	int3
    19e6a223:	cc                   	int3
    19e6a224:	cc                   	int3
    19e6a225:	cc                   	int3
    19e6a226:	cc                   	int3
    19e6a227:	cc                   	int3
    19e6a228:	cc                   	int3
    19e6a229:	cc                   	int3
    19e6a22a:	cc                   	int3
    19e6a22b:	cc                   	int3
    19e6a22c:	cc                   	int3
    19e6a22d:	cc                   	int3
    19e6a22e:	cc                   	int3
    19e6a22f:	cc                   	int3

0000000019e6a230 <xla::jellyfish::LloOpcodeMnemonicName(xla::jellyfish::LloOpcode)>:
    19e6a230:	55                   	push   rbp
    19e6a231:	48 89 e5             	mov    rbp,rsp
    19e6a234:	41 57                	push   r15
    19e6a236:	41 56                	push   r14
    19e6a238:	41 55                	push   r13
    19e6a23a:	41 54                	push   r12
    19e6a23c:	53                   	push   rbx
    19e6a23d:	50                   	push   rax
    19e6a23e:	81 fe ce 01 00 00    	cmp    esi,0x1ce
    19e6a244:	0f 83 9d 00 00 00    	jae    19e6a2e7 <xla::jellyfish::LloOpcodeMnemonicName(xla::jellyfish::LloOpcode)+0xb7>
    19e6a24a:	48 89 fb             	mov    rbx,rdi
    19e6a24d:	49 bc f6 ff ff ff ff 	movabs r12,0x7ffffffffffffff6
    19e6a254:	ff ff 7f 
    19e6a257:	0f b7 c6             	movzx  eax,si
    19e6a25a:	48 8d 0d ef 17 48 04 	lea    rcx,[rip+0x44817ef]        # 1e2eba50 <xla::jellyfish::LloOpcodeMnemonicName(xla::jellyfish::LloOpcode)::mnemonic_string>
    19e6a261:	4c 8b 34 c1          	mov    r14,QWORD PTR [rcx+rax*8]
    19e6a265:	4c 89 f7             	mov    rdi,r14
    19e6a268:	e8 73 de c1 03       	call   1da880e0 <strlen@plt>
    19e6a26d:	4c 39 e0             	cmp    rax,r12
    19e6a270:	77 7a                	ja     19e6a2ec <xla::jellyfish::LloOpcodeMnemonicName(xla::jellyfish::LloOpcode)+0xbc>
    19e6a272:	49 89 c7             	mov    r15,rax
    19e6a275:	48 83 f8 16          	cmp    rax,0x16
    19e6a279:	77 09                	ja     19e6a284 <xla::jellyfish::LloOpcodeMnemonicName(xla::jellyfish::LloOpcode)+0x54>
    19e6a27b:	44 88 7b 17          	mov    BYTE PTR [rbx+0x17],r15b
    19e6a27f:	49 89 dc             	mov    r12,rbx
    19e6a282:	eb 3e                	jmp    19e6a2c2 <xla::jellyfish::LloOpcodeMnemonicName(xla::jellyfish::LloOpcode)+0x92>
    19e6a284:	49 8d 44 24 02       	lea    rax,[r12+0x2]
    19e6a289:	4c 89 f9             	mov    rcx,r15
    19e6a28c:	48 21 c1             	and    rcx,rax
    19e6a28f:	48 83 c1 08          	add    rcx,0x8
    19e6a293:	48 83 f9 18          	cmp    rcx,0x18
    19e6a297:	41 bd 19 00 00 00    	mov    r13d,0x19
    19e6a29d:	4c 0f 45 e9          	cmovne r13,rcx
    19e6a2a1:	4c 89 ef             	mov    rdi,r13
    19e6a2a4:	e8 d7 4e 9e 03       	call   1d84f180 <operator new(unsigned long)>
    19e6a2a9:	4c 89 e1             	mov    rcx,r12
    19e6a2ac:	49 89 c4             	mov    r12,rax
    19e6a2af:	4a 8d 04 29          	lea    rax,[rcx+r13*1]
    19e6a2b3:	48 83 c0 0a          	add    rax,0xa
    19e6a2b7:	4c 89 23             	mov    QWORD PTR [rbx],r12
    19e6a2ba:	4c 89 7b 08          	mov    QWORD PTR [rbx+0x8],r15
    19e6a2be:	48 89 43 10          	mov    QWORD PTR [rbx+0x10],rax
    19e6a2c2:	4c 89 e7             	mov    rdi,r12
    19e6a2c5:	4c 89 f6             	mov    rsi,r14
    19e6a2c8:	4c 89 fa             	mov    rdx,r15
    19e6a2cb:	e8 a0 4f 9a 03       	call   1d80f270 <memmove>
    19e6a2d0:	43 c6 04 3c 00       	mov    BYTE PTR [r12+r15*1],0x0
    19e6a2d5:	48 89 d8             	mov    rax,rbx
    19e6a2d8:	48 83 c4 08          	add    rsp,0x8
    19e6a2dc:	5b                   	pop    rbx
    19e6a2dd:	41 5c                	pop    r12
    19e6a2df:	41 5d                	pop    r13
    19e6a2e1:	41 5e                	pop    r14
    19e6a2e3:	41 5f                	pop    r15
    19e6a2e5:	5d                   	pop    rbp
    19e6a2e6:	c3                   	ret
    19e6a2e7:	67 0f b9 40 12       	ud1    eax,DWORD PTR [eax+0x12]
    19e6a2ec:	e8 0f 57 83 f2       	call   c69fa00 <std::__u::basic_string<char, std::__u::char_traits<char>, std::__u::allocator<char> >::__throw_length_error()>
    19e6a2f1:	cc                   	int3
    19e6a2f2:	cc                   	int3
    19e6a2f3:	cc                   	int3
    19e6a2f4:	cc                   	int3
    19e6a2f5:	cc                   	int3
    19e6a2f6:	cc                   	int3
    19e6a2f7:	cc                   	int3
    19e6a2f8:	cc                   	int3
    19e6a2f9:	cc                   	int3
    19e6a2fa:	cc                   	int3
    19e6a2fb:	cc                   	int3
    19e6a2fc:	cc                   	int3
    19e6a2fd:	cc                   	int3
    19e6a2fe:	cc                   	int3
    19e6a2ff:	cc                   	int3

0000000019e6a300 <xla::jellyfish::ResultFifoEntryCount(xla::jellyfish::ResultFifo, tpu::TpuVersion)>:
    19e6a300:	55                   	push   rbp
    19e6a301:	48 89 e5             	mov    rbp,rsp
    19e6a304:	53                   	push   rbx
    19e6a305:	48 83 ec 18          	sub    rsp,0x18
    19e6a309:	89 75 f4             	mov    DWORD PTR [rbp-0xc],esi
    19e6a30c:	89 f8                	mov    eax,edi
    19e6a30e:	48                   	rex.W
    19e6a30f:	8d                   	.byte 0x8d
