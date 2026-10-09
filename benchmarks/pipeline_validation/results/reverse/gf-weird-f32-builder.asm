
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

000000001999fbf0 <_ZN3xla9jellyfish16LloRegionBuilder9VweirdF32EPNS0_8LloValueE>:
    1999fbf0:	55                   	push   rbp
    1999fbf1:	48 89 e5             	mov    rbp,rsp
    1999fbf4:	41 56                	push   r14
    1999fbf6:	53                   	push   rbx
    1999fbf7:	48 89 f3             	mov    rbx,rsi
    1999fbfa:	49 89 fe             	mov    r14,rdi
    1999fbfd:	48 89 f7             	mov    rdi,rsi
    1999fc00:	be 0b 00 00 00       	mov    esi,0xb
    1999fc05:	ba 03 00 00 00       	mov    edx,0x3
    1999fc0a:	e8 21 ef 03 00       	call   199deb30 <_ZN3xla9jellyfish14llo_simplifier14SimplifyVweirdEPNS0_8LloValueENS_13PrimitiveTypeENS0_12RegisterTypeE>
    1999fc0f:	48 85 c0             	test   rax,rax
    1999fc12:	74 05                	je     1999fc19 <_ZN3xla9jellyfish16LloRegionBuilder9VweirdF32EPNS0_8LloValueE+0x29>
    1999fc14:	5b                   	pop    rbx
    1999fc15:	41 5e                	pop    r14
    1999fc17:	5d                   	pop    rbp
    1999fc18:	c3                   	ret
    1999fc19:	4d 8b 36             	mov    r14,QWORD PTR [r14]
    1999fc1c:	bf 0b 00 00 00       	mov    edi,0xb
    1999fc21:	48 89 de             	mov    rsi,rbx
    1999fc24:	4c 89 f2             	mov    rdx,r14
    1999fc27:	e8 24 dc f7 ff       	call   1991d850 <_ZN3xla9jellyfish14LloInstruction17CreateVectorWeirdENS_13PrimitiveTypeEPNS0_8LloValueEPNS0_9LloRegionE>
    1999fc2c:	4c 89 f7             	mov    rdi,r14
    1999fc2f:	48 89 c6             	mov    rsi,rax
    1999fc32:	31 d2                	xor    edx,edx
    1999fc34:	5b                   	pop    rbx
    1999fc35:	41 5e                	pop    r14
    1999fc37:	5d                   	pop    rbp
    1999fc38:	e9 c3 ab fb ff       	jmp    1995a800 <_ZN3xla9jellyfish9LloRegion17AppendInstructionENSt3__u10unique_ptrINS0_14LloInstructionENS2_14default_deleteIS4_EEEENS2_8optionalINS0_14LloElementTypeEEE>
    1999fc3d:	cc                   	int3
    1999fc3e:	cc                   	int3
    1999fc3f:	cc                   	int3
