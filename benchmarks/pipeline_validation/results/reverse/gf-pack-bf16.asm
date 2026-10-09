
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

00000000199b2d90 <_ZN3xla9jellyfish16LloRegionBuilder10VpackCBf16EPNS0_8LloValueES3_>:
    199b2d90:	55                   	push   rbp
    199b2d91:	48 89 e5             	mov    rbp,rsp
    199b2d94:	41 57                	push   r15
    199b2d96:	41 56                	push   r14
    199b2d98:	53                   	push   rbx
    199b2d99:	50                   	push   rax
    199b2d9a:	48 89 d3             	mov    rbx,rdx
    199b2d9d:	49 89 f6             	mov    r14,rsi
    199b2da0:	49 89 ff             	mov    r15,rdi
    199b2da3:	48 89 d7             	mov    rdi,rdx
    199b2da6:	ba 04 00 00 00       	mov    edx,0x4
    199b2dab:	e8 d0 38 03 00       	call   199e6680 <_ZN3xla9jellyfish14llo_simplifier25SimplifyPackCompressedF16EPNS0_8LloValueES3_NS0_12RegisterTypeE>
    199b2db0:	48 85 c0             	test   rax,rax
    199b2db3:	74 0b                	je     199b2dc0 <_ZN3xla9jellyfish16LloRegionBuilder10VpackCBf16EPNS0_8LloValueES3_+0x30>
    199b2db5:	48 83 c4 08          	add    rsp,0x8
    199b2db9:	5b                   	pop    rbx
    199b2dba:	41 5e                	pop    r14
    199b2dbc:	41 5f                	pop    r15
    199b2dbe:	5d                   	pop    rbp
    199b2dbf:	c3                   	ret
    199b2dc0:	4c 89 ff             	mov    rdi,r15
    199b2dc3:	4c 89 f6             	mov    rsi,r14
    199b2dc6:	48 89 da             	mov    rdx,rbx
    199b2dc9:	48 83 c4 08          	add    rsp,0x8
    199b2dcd:	5b                   	pop    rbx
    199b2dce:	41 5e                	pop    r14
    199b2dd0:	41 5f                	pop    r15
    199b2dd2:	5d                   	pop    rbp
    199b2dd3:	e9 08 00 00 00       	jmp    199b2de0 <_ZN3xla9jellyfish16LloRegionBuilder14VpackCBf16InstEPNS0_8LloValueES3_>
    199b2dd8:	cc                   	int3
    199b2dd9:	cc                   	int3
    199b2dda:	cc                   	int3
    199b2ddb:	cc                   	int3
    199b2ddc:	cc                   	int3
    199b2ddd:	cc                   	int3
    199b2dde:	cc                   	int3
    199b2ddf:	cc                   	int3

00000000199b2de0 <_ZN3xla9jellyfish16LloRegionBuilder14VpackCBf16InstEPNS0_8LloValueES3_>:
    199b2de0:	55                   	push   rbp
    199b2de1:	48 89 e5             	mov    rbp,rsp
    199b2de4:	41 57                	push   r15
    199b2de6:	41 56                	push   r14
    199b2de8:	41 55                	push   r13
    199b2dea:	41 54                	push   r12
    199b2dec:	53                   	push   rbx
    199b2ded:	48 83 ec 18          	sub    rsp,0x18
    199b2df1:	49 89 d6             	mov    r14,rdx
    199b2df4:	48 89 f3             	mov    rbx,rsi
    199b2df7:	49 89 ff             	mov    r15,rdi
    199b2dfa:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199b2dfd:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    199b2e01:	48 8b 78 10          	mov    rdi,QWORD PTR [rax+0x10]
    199b2e05:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199b2e08:	be 01 00 00 00       	mov    esi,0x1
    199b2e0d:	ff 90 70 04 00 00    	call   QWORD PTR [rax+0x470]
    199b2e13:	84 c0                	test   al,al
    199b2e15:	74 37                	je     199b2e4e <_ZN3xla9jellyfish16LloRegionBuilder14VpackCBf16InstEPNS0_8LloValueES3_+0x6e>
    199b2e17:	4d 8b 3f             	mov    r15,QWORD PTR [r15]
    199b2e1a:	bf 26 01 00 00       	mov    edi,0x126
    199b2e1f:	be 01 00 00 00       	mov    esi,0x1
    199b2e24:	4c 89 f2             	mov    rdx,r14
    199b2e27:	48 89 d9             	mov    rcx,rbx
    199b2e2a:	4d 89 f8             	mov    r8,r15
    199b2e2d:	e8 ee 8d f6 ff       	call   1991bc20 <_ZN3xla9jellyfish14LloInstruction16CreateVectorPackENS0_9LloOpcodeENS0_11VpackFormatEPNS0_8LloValueES5_PNS0_9LloRegionE>
    199b2e32:	4c 89 ff             	mov    rdi,r15
    199b2e35:	48 89 c6             	mov    rsi,rax
    199b2e38:	31 d2                	xor    edx,edx
    199b2e3a:	e8 c1 79 fa ff       	call   1995a800 <_ZN3xla9jellyfish9LloRegion17AppendInstructionENSt3__u10unique_ptrINS0_14LloInstructionENS2_14default_deleteIS4_EEEENS2_8optionalINS0_14LloElementTypeEEE>
    199b2e3f:	48 83 c4 18          	add    rsp,0x18
    199b2e43:	5b                   	pop    rbx
    199b2e44:	41 5c                	pop    r12
    199b2e46:	41 5d                	pop    r13
    199b2e48:	41 5e                	pop    r14
    199b2e4a:	41 5f                	pop    r15
    199b2e4c:	5d                   	pop    rbp
    199b2e4d:	c3                   	ret
    199b2e4e:	bf 20 00 00 00       	mov    edi,0x20
    199b2e53:	e8 28 c3 e9 03       	call   1d84f180 <_Znwm>
    199b2e58:	c5 f8 57 c0          	vxorps xmm0,xmm0,xmm0
    199b2e5c:	c5 fc 11 00          	vmovups YMMWORD PTR [rax],ymm0
    199b2e60:	48 89 45 d0          	mov    QWORD PTR [rbp-0x30],rax
    199b2e64:	4c 8d 6d c0          	lea    r13,[rbp-0x40]
    199b2e68:	4c 8d 65 d0          	lea    r12,[rbp-0x30]
    199b2e6c:	48 c7 45 c0 9a 36 00 	mov    QWORD PTR [rbp-0x40],0x369a
    199b2e73:	00 
    199b2e74:	48 8d 0d 27 6d 3c ed 	lea    rcx,[rip+0xffffffffed3c6d27]        # 6d79ba2 <sqlite3_str_vappendf.zOrd+0x8c93b>
    199b2e7b:	48 89 4d c8          	mov    QWORD PTR [rbp-0x38],rcx
    199b2e7f:	48 89 c7             	mov    rdi,rax
    199b2e82:	48 8d 35 cb 49 d3 ee 	lea    rsi,[rip+0xffffffffeed349cb]        # 86e7854 <_ZZN4absl9SymbolizeEPKvPciE9kEllipsis+0x2826d>
    199b2e89:	4c 89 ea             	mov    rdx,r13
    199b2e8c:	c5 f8 77             	vzeroupper
    199b2e8f:	e8 0c 49 f7 ff       	call   199277a0 <_ZNSt3__u11make_uniqueIN3xla9jellyfish13StatusWrapperEJRNS3_11CheckFailerERA39_KcN4absl14SourceLocationEETnNS_9enable_ifIXntsr8is_arrayIT_EE5valueEiE4typeELi0EEENS_10unique_ptrISC_NS_14default_deleteISC_EEEEDpOT0_>
    199b2e94:	49 8b 0f             	mov    rcx,QWORD PTR [r15]
    199b2e97:	48 8b 79 38          	mov    rdi,QWORD PTR [rcx+0x38]
    199b2e9b:	48 89 c6             	mov    rsi,rax
    199b2e9e:	e8 2d ef f9 ff       	call   19951dd0 <_ZN3xla9jellyfish9LloModule12UpdateStatusENSt3__u10unique_ptrINS0_13StatusWrapperENS2_14default_deleteIS4_EEEE>
    199b2ea3:	4c 89 e7             	mov    rdi,r12
    199b2ea6:	31 f6                	xor    esi,esi
    199b2ea8:	e8 f3 ae f5 f4       	call   e90dda0 <_ZNSt3__u10unique_ptrIN3xla9jellyfish13StatusWrapper11CheckFailerENS_14default_deleteIS4_EEEaSEDn>
    199b2ead:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    199b2eb1:	48 85 c0             	test   rax,rax
    199b2eb4:	0f 84 5d ff ff ff    	je     199b2e17 <_ZN3xla9jellyfish16LloRegionBuilder14VpackCBf16InstEPNS0_8LloValueES3_+0x37>
    199b2eba:	eb b0                	jmp    199b2e6c <_ZN3xla9jellyfish16LloRegionBuilder14VpackCBf16InstEPNS0_8LloValueES3_+0x8c>
    199b2ebc:	cc                   	int3
    199b2ebd:	cc                   	int3
    199b2ebe:	cc                   	int3
    199b2ebf:	cc                   	int3
