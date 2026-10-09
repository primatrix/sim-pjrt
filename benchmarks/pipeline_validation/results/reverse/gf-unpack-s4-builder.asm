
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

00000000199b5d70 <_ZN3xla9jellyfish16LloRegionBuilder15VunpackLowerCS4EPNS0_8LloValueE>:
    199b5d70:	55                   	push   rbp
    199b5d71:	48 89 e5             	mov    rbp,rsp
    199b5d74:	41 57                	push   r15
    199b5d76:	41 56                	push   r14
    199b5d78:	41 55                	push   r13
    199b5d7a:	41 54                	push   r12
    199b5d7c:	53                   	push   rbx
    199b5d7d:	48 83 ec 18          	sub    rsp,0x18
    199b5d81:	48 89 f3             	mov    rbx,rsi
    199b5d84:	49 89 fe             	mov    r14,rdi
    199b5d87:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199b5d8a:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    199b5d8e:	48 8b 78 10          	mov    rdi,QWORD PTR [rax+0x10]
    199b5d92:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199b5d95:	be 04 00 00 00       	mov    esi,0x4
    199b5d9a:	31 d2                	xor    edx,edx
    199b5d9c:	ff 90 80 04 00 00    	call   QWORD PTR [rax+0x480]
    199b5da2:	84 c0                	test   al,al
    199b5da4:	74 36                	je     199b5ddc <_ZN3xla9jellyfish16LloRegionBuilder15VunpackLowerCS4EPNS0_8LloValueE+0x6c>
    199b5da6:	4d 8b 36             	mov    r14,QWORD PTR [r14]
    199b5da9:	bf 09 01 00 00       	mov    edi,0x109
    199b5dae:	31 f6                	xor    esi,esi
    199b5db0:	ba 04 00 00 00       	mov    edx,0x4
    199b5db5:	48 89 d9             	mov    rcx,rbx
    199b5db8:	4d 89 f0             	mov    r8,r14
    199b5dbb:	e8 a0 64 f6 ff       	call   1991c260 <_ZN3xla9jellyfish14LloInstruction18CreateVectorUnpackENS0_9LloOpcodeEjNS0_11VpackFormatEPNS0_8LloValueEPNS0_9LloRegionE>
    199b5dc0:	4c 89 f7             	mov    rdi,r14
    199b5dc3:	48 89 c6             	mov    rsi,rax
    199b5dc6:	31 d2                	xor    edx,edx
    199b5dc8:	e8 33 4a fa ff       	call   1995a800 <_ZN3xla9jellyfish9LloRegion17AppendInstructionENSt3__u10unique_ptrINS0_14LloInstructionENS2_14default_deleteIS4_EEEENS2_8optionalINS0_14LloElementTypeEEE>
    199b5dcd:	48 83 c4 18          	add    rsp,0x18
    199b5dd1:	5b                   	pop    rbx
    199b5dd2:	41 5c                	pop    r12
    199b5dd4:	41 5d                	pop    r13
    199b5dd6:	41 5e                	pop    r14
    199b5dd8:	41 5f                	pop    r15
    199b5dda:	5d                   	pop    rbp
    199b5ddb:	c3                   	ret
    199b5ddc:	bf 20 00 00 00       	mov    edi,0x20
    199b5de1:	e8 9a 93 e9 03       	call   1d84f180 <_Znwm>
    199b5de6:	c5 f8 57 c0          	vxorps xmm0,xmm0,xmm0
    199b5dea:	c5 fc 11 00          	vmovups YMMWORD PTR [rax],ymm0
    199b5dee:	48 89 45 d0          	mov    QWORD PTR [rbp-0x30],rax
    199b5df2:	4c 8d 3d 32 1a d3 ee 	lea    r15,[rip+0xffffffffeed31a32]        # 86e782b <_ZZN4absl9SymbolizeEPKvPciE9kEllipsis+0x28244>
    199b5df9:	4c 8d 65 c0          	lea    r12,[rbp-0x40]
    199b5dfd:	4c 8d 6d d0          	lea    r13,[rbp-0x30]
    199b5e01:	48 c7 45 c0 2a 39 00 	mov    QWORD PTR [rbp-0x40],0x392a
    199b5e08:	00 
    199b5e09:	48 8d 0d 92 3d 3c ed 	lea    rcx,[rip+0xffffffffed3c3d92]        # 6d79ba2 <sqlite3_str_vappendf.zOrd+0x8c93b>
    199b5e10:	48 89 4d c8          	mov    QWORD PTR [rbp-0x38],rcx
    199b5e14:	48 89 c7             	mov    rdi,rax
    199b5e17:	4c 89 fe             	mov    rsi,r15
    199b5e1a:	4c 89 e2             	mov    rdx,r12
    199b5e1d:	c5 f8 77             	vzeroupper
    199b5e20:	e8 fb 35 f8 ff       	call   19939420 <_ZNSt3__u11make_uniqueIN3xla9jellyfish13StatusWrapperEJRNS3_11CheckFailerERA41_KcN4absl14SourceLocationEETnNS_9enable_ifIXntsr8is_arrayIT_EE5valueEiE4typeELi0EEENS_10unique_ptrISC_NS_14default_deleteISC_EEEEDpOT0_>
    199b5e25:	49 8b 0e             	mov    rcx,QWORD PTR [r14]
    199b5e28:	48 8b 79 38          	mov    rdi,QWORD PTR [rcx+0x38]
    199b5e2c:	48 89 c6             	mov    rsi,rax
    199b5e2f:	e8 9c bf f9 ff       	call   19951dd0 <_ZN3xla9jellyfish9LloModule12UpdateStatusENSt3__u10unique_ptrINS0_13StatusWrapperENS2_14default_deleteIS4_EEEE>
    199b5e34:	4c 89 ef             	mov    rdi,r13
    199b5e37:	31 f6                	xor    esi,esi
    199b5e39:	e8 62 7f f5 f4       	call   e90dda0 <_ZNSt3__u10unique_ptrIN3xla9jellyfish13StatusWrapper11CheckFailerENS_14default_deleteIS4_EEEaSEDn>
    199b5e3e:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    199b5e42:	48 85 c0             	test   rax,rax
    199b5e45:	0f 84 5b ff ff ff    	je     199b5da6 <_ZN3xla9jellyfish16LloRegionBuilder15VunpackLowerCS4EPNS0_8LloValueE+0x36>
    199b5e4b:	eb b4                	jmp    199b5e01 <_ZN3xla9jellyfish16LloRegionBuilder15VunpackLowerCS4EPNS0_8LloValueE+0x91>
    199b5e4d:	cc                   	int3
    199b5e4e:	cc                   	int3
    199b5e4f:	cc                   	int3
