
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

000000001999ea00 <_ZN3xla9jellyfish16LloRegionBuilder9VpackiB16EPNS0_8LloValueES3_>:
    1999ea00:	55                   	push   rbp
    1999ea01:	48 89 e5             	mov    rbp,rsp
    1999ea04:	41 57                	push   r15
    1999ea06:	41 56                	push   r14
    1999ea08:	41 55                	push   r13
    1999ea0a:	41 54                	push   r12
    1999ea0c:	53                   	push   rbx
    1999ea0d:	50                   	push   rax
    1999ea0e:	49 89 d6             	mov    r14,rdx
    1999ea11:	49 89 f4             	mov    r12,rsi
    1999ea14:	48 89 fb             	mov    rbx,rdi
    1999ea17:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    1999ea1a:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    1999ea1e:	48 8b 78 10          	mov    rdi,QWORD PTR [rax+0x10]
    1999ea22:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    1999ea25:	be 08 00 00 00       	mov    esi,0x8
    1999ea2a:	ff 90 70 04 00 00    	call   QWORD PTR [rax+0x470]
    1999ea30:	4c 8b 3b             	mov    r15,QWORD PTR [rbx]
    1999ea33:	84 c0                	test   al,al
    1999ea35:	74 20                	je     1999ea57 <_ZN3xla9jellyfish16LloRegionBuilder9VpackiB16EPNS0_8LloValueES3_+0x57>
    1999ea37:	bf 26 01 00 00       	mov    edi,0x126
    1999ea3c:	be 08 00 00 00       	mov    esi,0x8
    1999ea41:	4c 89 f2             	mov    rdx,r14
    1999ea44:	4c 89 e1             	mov    rcx,r12
    1999ea47:	4d 89 f8             	mov    r8,r15
    1999ea4a:	e8 d1 d1 f7 ff       	call   1991bc20 <_ZN3xla9jellyfish14LloInstruction16CreateVectorPackENS0_9LloOpcodeENS0_11VpackFormatEPNS0_8LloValueES5_PNS0_9LloRegionE>
    1999ea4f:	4c 89 ff             	mov    rdi,r15
    1999ea52:	e9 f7 00 00 00       	jmp    1999eb4e <_ZN3xla9jellyfish16LloRegionBuilder9VpackiB16EPNS0_8LloValueES3_+0x14e>
    1999ea57:	49 8b 7f 38          	mov    rdi,QWORD PTR [r15+0x38]
    1999ea5b:	be ff ff 00 00       	mov    esi,0xffff
    1999ea60:	e8 2b 20 fb ff       	call   19950a90 <_ZN3xla9jellyfish9LloModule17VectorU32ConstantEj>
    1999ea65:	49 89 c5             	mov    r13,rax
    1999ea68:	4c 89 e7             	mov    rdi,r12
    1999ea6b:	48 89 c6             	mov    rsi,rax
    1999ea6e:	ba 04 00 00 00       	mov    edx,0x4
    1999ea73:	31 c9                	xor    ecx,ecx
    1999ea75:	e8 f6 c7 03 00       	call   199db270 <_ZN3xla9jellyfish14llo_simplifier14SimplifyAndU32EPNS0_8LloValueES3_NS0_12RegisterTypeEb>
    1999ea7a:	49 89 c7             	mov    r15,rax
    1999ea7d:	48 85 c0             	test   rax,rax
    1999ea80:	75 26                	jne    1999eaa8 <_ZN3xla9jellyfish16LloRegionBuilder9VpackiB16EPNS0_8LloValueES3_+0xa8>
    1999ea82:	4c 8b 3b             	mov    r15,QWORD PTR [rbx]
    1999ea85:	bf 5c 01 00 00       	mov    edi,0x15c
    1999ea8a:	4c 89 e6             	mov    rsi,r12
    1999ea8d:	4c 89 ea             	mov    rdx,r13
    1999ea90:	4c 89 f9             	mov    rcx,r15
    1999ea93:	e8 48 c8 f7 ff       	call   1991b2e0 <_ZN3xla9jellyfish14LloInstruction17CreateVectorBinopENS0_9LloOpcodeEPNS0_8LloValueES4_PNS0_9LloRegionE>
    1999ea98:	4c 89 ff             	mov    rdi,r15
    1999ea9b:	48 89 c6             	mov    rsi,rax
    1999ea9e:	31 d2                	xor    edx,edx
    1999eaa0:	e8 5b bd fb ff       	call   1995a800 <_ZN3xla9jellyfish9LloRegion17AppendInstructionENSt3__u10unique_ptrINS0_14LloInstructionENS2_14default_deleteIS4_EEEENS2_8optionalINS0_14LloElementTypeEEE>
    1999eaa5:	49 89 c7             	mov    r15,rax
    1999eaa8:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1999eaab:	48 8b 78 38          	mov    rdi,QWORD PTR [rax+0x38]
    1999eaaf:	be 10 00 00 00       	mov    esi,0x10
    1999eab4:	e8 d7 1f fb ff       	call   19950a90 <_ZN3xla9jellyfish9LloModule17VectorU32ConstantEj>
    1999eab9:	49 89 c4             	mov    r12,rax
    1999eabc:	4c 89 f7             	mov    rdi,r14
    1999eabf:	48 89 c6             	mov    rsi,rax
    1999eac2:	ba 04 00 00 00       	mov    edx,0x4
    1999eac7:	31 c9                	xor    ecx,ecx
    1999eac9:	e8 b2 e5 03 00       	call   199dd080 <_ZN3xla9jellyfish14llo_simplifier15SimplifyShllU32EPNS0_8LloValueES3_NS0_12RegisterTypeEb>
    1999eace:	48 85 c0             	test   rax,rax
    1999ead1:	74 18                	je     1999eaeb <_ZN3xla9jellyfish16LloRegionBuilder9VpackiB16EPNS0_8LloValueES3_+0xeb>
    1999ead3:	48 89 df             	mov    rdi,rbx
    1999ead6:	be 13 00 00 00       	mov    esi,0x13
    1999eadb:	48 89 c2             	mov    rdx,rax
    1999eade:	e8 ed 7f fc ff       	call   19966ad0 <_ZN3xla9jellyfish16LloRegionBuilder6CastToENS0_14LloElementTypeEPNS0_8LloValueE>
    1999eae3:	49 89 c5             	mov    r13,rax
    1999eae6:	48 85 c0             	test   rax,rax
    1999eae9:	75 26                	jne    1999eb11 <_ZN3xla9jellyfish16LloRegionBuilder9VpackiB16EPNS0_8LloValueES3_+0x111>
    1999eaeb:	4c 8b 2b             	mov    r13,QWORD PTR [rbx]
    1999eaee:	bf 9d 01 00 00       	mov    edi,0x19d
    1999eaf3:	4c 89 f6             	mov    rsi,r14
    1999eaf6:	4c 89 e2             	mov    rdx,r12
    1999eaf9:	4c 89 e9             	mov    rcx,r13
    1999eafc:	e8                   	.byte 0xe8
    1999eafd:	df c7                	ffreep st(7)
    1999eaff:	f7                   	.byte 0xf7
