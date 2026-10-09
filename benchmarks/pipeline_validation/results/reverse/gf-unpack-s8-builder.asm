
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

00000000199b4ed0 <_ZN3xla9jellyfish16LloRegionBuilder11Vunpack0CI8EPNS0_8LloValueEb>:
    199b4ed0:	55                   	push   rbp
    199b4ed1:	48 89 e5             	mov    rbp,rsp
    199b4ed4:	41 57                	push   r15
    199b4ed6:	41 56                	push   r14
    199b4ed8:	41 55                	push   r13
    199b4eda:	41 54                	push   r12
    199b4edc:	53                   	push   rbx
    199b4edd:	48 83 ec 18          	sub    rsp,0x18
    199b4ee1:	41 89 d6             	mov    r14d,edx
    199b4ee4:	49 89 f7             	mov    r15,rsi
    199b4ee7:	48 89 fb             	mov    rbx,rdi
    199b4eea:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199b4eed:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    199b4ef1:	48 8b 78 10          	mov    rdi,QWORD PTR [rax+0x10]
    199b4ef5:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199b4ef8:	be 03 00 00 00       	mov    esi,0x3
    199b4efd:	31 d2                	xor    edx,edx
    199b4eff:	ff 90 80 04 00 00    	call   QWORD PTR [rax+0x480]
    199b4f05:	84 c0                	test   al,al
    199b4f07:	0f 84 91 00 00 00    	je     199b4f9e <_ZN3xla9jellyfish16LloRegionBuilder11Vunpack0CI8EPNS0_8LloValueEb+0xce>
    199b4f0d:	4c 8b 23             	mov    r12,QWORD PTR [rbx]
    199b4f10:	bf 09 01 00 00       	mov    edi,0x109
    199b4f15:	31 f6                	xor    esi,esi
    199b4f17:	ba 03 00 00 00       	mov    edx,0x3
    199b4f1c:	4c 89 f9             	mov    rcx,r15
    199b4f1f:	4d 89 e0             	mov    r8,r12
    199b4f22:	e8 39 73 f6 ff       	call   1991c260 <_ZN3xla9jellyfish14LloInstruction18CreateVectorUnpackENS0_9LloOpcodeEjNS0_11VpackFormatEPNS0_8LloValueEPNS0_9LloRegionE>
    199b4f27:	4c 89 e7             	mov    rdi,r12
    199b4f2a:	48 89 c6             	mov    rsi,rax
    199b4f2d:	31 d2                	xor    edx,edx
    199b4f2f:	e8 cc 58 fa ff       	call   1995a800 <_ZN3xla9jellyfish9LloRegion17AppendInstructionENSt3__u10unique_ptrINS0_14LloInstructionENS2_14default_deleteIS4_EEEENS2_8optionalINS0_14LloElementTypeEEE>
    199b4f34:	49 89 c7             	mov    r15,rax
    199b4f37:	45 84 f6             	test   r14b,r14b
    199b4f3a:	74 05                	je     199b4f41 <_ZN3xla9jellyfish16LloRegionBuilder11Vunpack0CI8EPNS0_8LloValueEb+0x71>
    199b4f3c:	4c 89 f8             	mov    rax,r15
    199b4f3f:	eb 4e                	jmp    199b4f8f <_ZN3xla9jellyfish16LloRegionBuilder11Vunpack0CI8EPNS0_8LloValueEb+0xbf>
    199b4f41:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    199b4f44:	48 8b 78 38          	mov    rdi,QWORD PTR [rax+0x38]
    199b4f48:	be ff 00 00 00       	mov    esi,0xff
    199b4f4d:	e8 3e bb f9 ff       	call   19950a90 <_ZN3xla9jellyfish9LloModule17VectorU32ConstantEj>
    199b4f52:	49 89 c6             	mov    r14,rax
    199b4f55:	4c 89 ff             	mov    rdi,r15
    199b4f58:	48 89 c6             	mov    rsi,rax
    199b4f5b:	ba 04 00 00 00       	mov    edx,0x4
    199b4f60:	31 c9                	xor    ecx,ecx
    199b4f62:	e8 09 63 02 00       	call   199db270 <_ZN3xla9jellyfish14llo_simplifier14SimplifyAndU32EPNS0_8LloValueES3_NS0_12RegisterTypeEb>
    199b4f67:	48 85 c0             	test   rax,rax
    199b4f6a:	75 23                	jne    199b4f8f <_ZN3xla9jellyfish16LloRegionBuilder11Vunpack0CI8EPNS0_8LloValueEb+0xbf>
    199b4f6c:	48 8b 1b             	mov    rbx,QWORD PTR [rbx]
    199b4f6f:	bf 5c 01 00 00       	mov    edi,0x15c
    199b4f74:	4c 89 fe             	mov    rsi,r15
    199b4f77:	4c 89 f2             	mov    rdx,r14
    199b4f7a:	48 89 d9             	mov    rcx,rbx
    199b4f7d:	e8 5e 63 f6 ff       	call   1991b2e0 <_ZN3xla9jellyfish14LloInstruction17CreateVectorBinopENS0_9LloOpcodeEPNS0_8LloValueES4_PNS0_9LloRegionE>
    199b4f82:	48 89 df             	mov    rdi,rbx
    199b4f85:	48 89 c6             	mov    rsi,rax
    199b4f88:	31 d2                	xor    edx,edx
    199b4f8a:	e8 71 58 fa ff       	call   1995a800 <_ZN3xla9jellyfish9LloRegion17AppendInstructionENSt3__u10unique_ptrINS0_14LloInstructionENS2_14default_deleteIS4_EEEENS2_8optionalINS0_14LloElementTypeEEE>
    199b4f8f:	48 83 c4 18          	add    rsp,0x18
    199b4f93:	5b                   	pop    rbx
    199b4f94:	41 5c                	pop    r12
    199b4f96:	41 5d                	pop    r13
    199b4f98:	41 5e                	pop    r14
    199b4f9a:	41 5f                	pop    r15
    199b4f9c:	5d                   	pop    rbp
    199b4f9d:	c3                   	ret
    199b4f9e:	bf 20 00 00 00       	mov    edi,0x20
    199b4fa3:	e8 d8 a1 e9 03       	call   1d84f180 <_Znwm>
    199b4fa8:	c5 f8 57 c0          	vxorps xmm0,xmm0,xmm0
    199b4fac:	c5 fc 11 00          	vmovups YMMWORD PTR [rax],ymm0
    199b4fb0:	48 89 45 d0          	mov    QWORD PTR [rbp-0x30],rax
    199b4fb4:	4c 8d 6d c0          	lea    r13,[rbp-0x40]
    199b4fb8:	4c 8d 65 d0          	lea    r12,[rbp-0x30]
    199b4fbc:	48 c7 45 c0 2d 38 00 	mov    QWORD PTR [rbp-0x40],0x382d
    199b4fc3:	00 
    199b4fc4:	48 8d 0d d7 4b 3c ed 	lea    rcx,[rip+0xffffffffed3c4bd7]        # 6d79ba2 <sqlite3_str_vappendf.zOrd+0x8c93b>
    199b4fcb:	48 89 4d c8          	mov    QWORD PTR [rbp-0x38],rcx
    199b4fcf:	48 89 c7             	mov    rdi,rax
    199b4fd2:	48 8d 35 52 28 d3 ee 	lea    rsi,[rip+0xffffffffeed32852]        # 86e782b <_ZZN4absl9SymbolizeEPKvPciE9kEllipsis+0x28244>
    199b4fd9:	4c 89 ea             	mov    rdx,r13
    199b4fdc:	c5 f8 77             	vzeroupper
    199b4fdf:	e8 3c 44 f8 ff       	call   19939420 <_ZNSt3__u11make_uniqueIN3xla9jellyfish13StatusWrapperEJRNS3_11CheckFailerERA41_KcN4absl14SourceLocationEETnNS_9enable_ifIXntsr8is_arrayIT_EE5valueEiE4typeELi0EEENS_10unique_ptrISC_NS_14default_deleteISC_EEEEDpOT0_>
    199b4fe4:	48 8b 0b             	mov    rcx,QWORD PTR [rbx]
    199b4fe7:	48 8b 79 38          	mov    rdi,QWORD PTR [rcx+0x38]
    199b4feb:	48 89 c6             	mov    rsi,rax
    199b4fee:	e8 dd cd f9 ff       	call   19951dd0 <_ZN3xla9jellyfish9LloModule12UpdateStatusENSt3__u10unique_ptrINS0_13StatusWrapperENS2_14default_deleteIS4_EEEE>
    199b4ff3:	4c 89 e7             	mov    rdi,r12
    199b4ff6:	31 f6                	xor    esi,esi
    199b4ff8:	e8 a3 8d f5 f4       	call   e90dda0 <_ZNSt3__u10unique_ptrIN3xla9jellyfish13StatusWrapper11CheckFailerENS_14default_deleteIS4_EEEaSEDn>
    199b4ffd:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    199b5001:	48 85 c0             	test   rax,rax
    199b5004:	0f 84 03 ff ff ff    	je     199b4f0d <_ZN3xla9jellyfish16LloRegionBuilder11Vunpack0CI8EPNS0_8LloValueEb+0x3d>
    199b500a:	eb b0                	jmp    199b4fbc <_ZN3xla9jellyfish16LloRegionBuilder11Vunpack0CI8EPNS0_8LloValueEb+0xec>
    199b500c:	cc                   	int3
    199b500d:	cc                   	int3
    199b500e:	cc                   	int3
    199b500f:	cc                   	int3
