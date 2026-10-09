
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

0000000019357980 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)>:
    19357980:	55                   	push   rbp
    19357981:	48 89 e5             	mov    rbp,rsp
    19357984:	41 57                	push   r15
    19357986:	41 56                	push   r14
    19357988:	53                   	push   rbx
    19357989:	48 83 ec 28          	sub    rsp,0x28
    1935798d:	0f b7 47 1a          	movzx  eax,WORD PTR [rdi+0x1a]
    19357991:	8d 88 1b ff ff ff    	lea    ecx,[rax-0xe5]
    19357997:	66 83 f9 f4          	cmp    cx,0xfff4
    1935799b:	0f 87 75 04 00 00    	ja     19357e16 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x496>
    193579a1:	48 8d 0d 38 57 74 05 	lea    rcx,[rip+0x5745738]        # 1ea9d0e0 <_GLOBAL_OFFSET_TABLE_>
    193579a8:	48 ba 7a 7c bd e3 ff 	movabs rdx,0xffffffffe3bd7c7a
    193579af:	ff ff ff 
    193579b2:	48 8d 34 11          	lea    rsi,[rcx+rdx*1]
    193579b6:	41 b8 08 01 00 00    	mov    r8d,0x108
    193579bc:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    193579c0:	49 89 f1             	mov    r9,rsi
    193579c3:	4c 89 c6             	mov    rsi,r8
    193579c6:	48 d1 ee             	shr    rsi,1
    193579c9:	49 89 f2             	mov    r10,rsi
    193579cc:	49 f7 d2             	not    r10
    193579cf:	4d 01 c2             	add    r10,r8
    193579d2:	66 41 39 04 b1       	cmp    WORD PTR [r9+rsi*4],ax
    193579d7:	4c 0f 43 d6          	cmovae r10,rsi
    193579db:	49 8d 74 b1 04       	lea    rsi,[r9+rsi*4+0x4]
    193579e0:	49 0f 43 f1          	cmovae rsi,r9
    193579e4:	4d 89 d0             	mov    r8,r10
    193579e7:	4d 85 d2             	test   r10,r10
    193579ea:	75 d4                	jne    193579c0 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x40>
    193579ec:	48 01 d1             	add    rcx,rdx
    193579ef:	48 81 c1 20 04 00 00 	add    rcx,0x420
    193579f6:	48 39 ce             	cmp    rsi,rcx
    193579f9:	74 05                	je     19357a00 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x80>
    193579fb:	66 3b 06             	cmp    ax,WORD PTR [rsi]
    193579fe:	73 77                	jae    19357a77 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0xf7>
    19357a00:	8d 48 ff             	lea    ecx,[rax-0x1]
    19357a03:	81 f9 a4 00 00 00    	cmp    ecx,0xa4
    19357a09:	0f 87 fe 00 00 00    	ja     19357b0d <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x18d>
    19357a0f:	48 8d 05 7a f8 4b f0 	lea    rax,[rip+0xfffffffff04bf87a]        # 9817290 <xla::viperfish::MxuLatencyTable::MxuLatencyTable()::kMsrs+0x16d>
    19357a16:	48 63 0c 88          	movsxd rcx,DWORD PTR [rax+rcx*4]
    19357a1a:	48 01 c1             	add    rcx,rax
    19357a1d:	ff e1                	jmp    rcx
    19357a1f:	48 89 fb             	mov    rbx,rdi
    19357a22:	e8 99 83 5d 00       	call   1992fdc0 <xla::jellyfish::LloInstruction::latch_mode() const>
    19357a27:	41 89 c6             	mov    r14d,eax
    19357a2a:	88 45 d8             	mov    BYTE PTR [rbp-0x28],al
    19357a2d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19357a30:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    19357a34:	48 8b 78 10          	mov    rdi,QWORD PTR [rax+0x10]
    19357a38:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    19357a3b:	41 0f b6 de          	movzx  ebx,r14b
    19357a3f:	89 de                	mov    esi,ebx
    19357a41:	ff 90 38 03 00 00    	call   QWORD PTR [rax+0x338]
    19357a47:	84 c0                	test   al,al
    19357a49:	0f 84 f6 03 00 00    	je     19357e45 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x4c5>
    19357a4f:	41 80 fe 1a          	cmp    r14b,0x1a
    19357a53:	0f 83 ce 04 00 00    	jae    19357f27 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x5a7>
    19357a59:	b8 03 cc ff 03       	mov    eax,0x3ffcc03
    19357a5e:	0f a3 d8             	bt     eax,ebx
    19357a61:	0f 83 c0 04 00 00    	jae    19357f27 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x5a7>
    19357a67:	48 8d 05 d6 02 4c f0 	lea    rax,[rip+0xfffffffff04c02d6]        # 9817d44 <typeinfo name for xla::ghostlite::LatencyTableGhostlite+0x28>
    19357a6e:	0f b7 04 58          	movzx  eax,WORD PTR [rax+rbx*2]
    19357a72:	e9 8b 00 00 00       	jmp    19357b02 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x182>
    19357a77:	0f b7 46 02          	movzx  eax,WORD PTR [rsi+0x2]
    19357a7b:	e9 82 00 00 00       	jmp    19357b02 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x182>
    19357a80:	49 89 fe             	mov    r14,rdi
    19357a83:	e8 38 83 5d 00       	call   1992fdc0 <xla::jellyfish::LloInstruction::latch_mode() const>
    19357a88:	89 c3                	mov    ebx,eax
    19357a8a:	88 45 d8             	mov    BYTE PTR [rbp-0x28],al
    19357a8d:	49 8b 06             	mov    rax,QWORD PTR [r14]
    19357a90:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    19357a94:	48 8b 78 10          	mov    rdi,QWORD PTR [rax+0x10]
    19357a98:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    19357a9b:	0f b6 f3             	movzx  esi,bl
    19357a9e:	ff 90 38 03 00 00    	call   QWORD PTR [rax+0x338]
    19357aa4:	84 c0                	test   al,al
    19357aa6:	0f 84 b5 03 00 00    	je     19357e61 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x4e1>
    19357aac:	80 c3 f6             	add    bl,0xf6
    19357aaf:	66 b8 5f 01          	mov    ax,0x15f
    19357ab3:	80 fb 0f             	cmp    bl,0xf
    19357ab6:	77 4a                	ja     19357b02 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x182>
    19357ab8:	0f b6 c3             	movzx  eax,bl
    19357abb:	48 8d 0d 1e de 57 ef 	lea    rcx,[rip+0xffffffffef57de1e]        # 88d58e0 <ZSTD_overlapCopy8.dec32table+0x320>
    19357ac2:	eb 3a                	jmp    19357afe <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x17e>
    19357ac4:	49 89 ff             	mov    r15,rdi
    19357ac7:	e8 f4 91 5d 00       	call   19930cc0 <xla::jellyfish::LloInstruction::matmul_data_format() const>
    19357acc:	fe c8                	dec    al
    19357ace:	3c 08                	cmp    al,0x8
    19357ad0:	0f 83 6e 04 00 00    	jae    19357f44 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x5c4>
    19357ad6:	0f b6 c0             	movzx  eax,al
    19357ad9:	48 8d 0d 60 cb 56 ef 	lea    rcx,[rip+0xffffffffef56cb60]        # 88c4640 <llvm::RetCC_PPC64_ELF_FIS(unsigned int, llvm::MVT, llvm::MVT, llvm::CCValAssign::LocInfo, llvm::ISD::ArgFlagsTy, llvm::Type*, llvm::CCState&)::RegList6+0x310>
    19357ae0:	eb 1c                	jmp    19357afe <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x17e>
    19357ae2:	49 89 ff             	mov    r15,rdi
    19357ae5:	e8 d6 91 5d 00       	call   19930cc0 <xla::jellyfish::LloInstruction::matmul_data_format() const>
    19357aea:	fe c8                	dec    al
    19357aec:	3c 08                	cmp    al,0x8
    19357aee:	0f 83 65 04 00 00    	jae    19357f59 <xla::ghostlite::(anonymous namespace)::GetGhostliteInstruction(xla::jellyfish::LloValue const*)+0x5d9>
    19357af4:	0f b6 c0             	movzx  eax,al
    19357af7:	48 8d 0d 62 1d 56 ef 	lea    rcx,[rip+0xffffffffef561d62]        # 88b9860 <(anonymous namespace)::AArch64InstructionSelector::emitTestBit(llvm::Register, unsigned long, bool, llvm::MachineBasicBlock*, llvm::MachineIRBuilder&) const::OpcTable+0x4b0>
    19357afe:	0f                   	.byte 0xf
    19357aff:	b7                   	.byte 0xb7
