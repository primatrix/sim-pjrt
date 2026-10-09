
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

00000000199aa520 <_ZN3xla9jellyfish16LloRegionBuilder9VpackcB16EPNS0_8LloValueES3_>:
    199aa520:	55                   	push   rbp
    199aa521:	48 89 e5             	mov    rbp,rsp
    199aa524:	41 57                	push   r15
    199aa526:	41 56                	push   r14
    199aa528:	41 55                	push   r13
    199aa52a:	41 54                	push   r12
    199aa52c:	53                   	push   rbx
    199aa52d:	48 83 ec 18          	sub    rsp,0x18
    199aa531:	49 89 d6             	mov    r14,rdx
    199aa534:	49 89 f7             	mov    r15,rsi
    199aa537:	48 89 fb             	mov    rbx,rdi
    199aa53a:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199aa53d:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    199aa541:	48 8b 78 10          	mov    rdi,QWORD PTR [rax+0x10]
    199aa545:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199aa548:	be 02 00 00 00       	mov    esi,0x2
    199aa54d:	ff 90 70 04 00 00    	call   QWORD PTR [rax+0x470]
    199aa553:	84 c0                	test   al,al
    199aa555:	74 36                	je     199aa58d <_ZN3xla9jellyfish16LloRegionBuilder9VpackcB16EPNS0_8LloValueES3_+0x6d>
    199aa557:	48 8b 1b             	mov    rbx,QWORD PTR [rbx]
    199aa55a:	bf 26 01 00 00       	mov    edi,0x126
    199aa55f:	be 02 00 00 00       	mov    esi,0x2
    199aa564:	4c 89 f2             	mov    rdx,r14
    199aa567:	4c 89 f9             	mov    rcx,r15
    199aa56a:	49 89 d8             	mov    r8,rbx
    199aa56d:	e8 ae 16 f7 ff       	call   1991bc20 <_ZN3xla9jellyfish14LloInstruction16CreateVectorPackENS0_9LloOpcodeENS0_11VpackFormatEPNS0_8LloValueES5_PNS0_9LloRegionE>
    199aa572:	48 89 df             	mov    rdi,rbx
    199aa575:	48 89 c6             	mov    rsi,rax
    199aa578:	31 d2                	xor    edx,edx
    199aa57a:	48 83 c4 18          	add    rsp,0x18
    199aa57e:	5b                   	pop    rbx
    199aa57f:	41 5c                	pop    r12
    199aa581:	41 5d                	pop    r13
    199aa583:	41 5e                	pop    r14
    199aa585:	41 5f                	pop    r15
    199aa587:	5d                   	pop    rbp
    199aa588:	e9 73 02 fb ff       	jmp    1995a800 <_ZN3xla9jellyfish9LloRegion17AppendInstructionENSt3__u10unique_ptrINS0_14LloInstructionENS2_14default_deleteIS4_EEEENS2_8optionalINS0_14LloElementTypeEEE>
    199aa58d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    199aa590:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    199aa594:	48 8b 78 10          	mov    rdi,QWORD PTR [rax+0x10]
    199aa598:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199aa59b:	ff 90 f0 05 00 00    	call   QWORD PTR [rax+0x5f0]
    199aa5a1:	84 c0                	test   al,al
    199aa5a3:	0f 84 1e 01 00 00    	je     199aa6c7 <_ZN3xla9jellyfish16LloRegionBuilder9VpackcB16EPNS0_8LloValueES3_+0x1a7>
    199aa5a9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    199aa5ac:	48 8b 78 38          	mov    rdi,QWORD PTR [rax+0x38]
    199aa5b0:	be 10 00 00 00       	mov    esi,0x10
    199aa5b5:	e8 d6 64 fa ff       	call   19950a90 <_ZN3xla9jellyfish9LloModule17VectorU32ConstantEj>
    199aa5ba:	49 89 c4             	mov    r12,rax
    199aa5bd:	4c 89 ff             	mov    rdi,r15
    199aa5c0:	48 89 c6             	mov    rsi,rax
    199aa5c3:	ba 04 00 00 00       	mov    edx,0x4
    199aa5c8:	31 c9                	xor    ecx,ecx
    199aa5ca:	e8 b1 2a 03 00       	call   199dd080 <_ZN3xla9jellyfish14llo_simplifier15SimplifyShllU32EPNS0_8LloValueES3_NS0_12RegisterTypeEb>
    199aa5cf:	48 85 c0             	test   rax,rax
    199aa5d2:	74 15                	je     199aa5e9 <_ZN3xla9jellyfish16LloRegionBuilder9VpackcB16EPNS0_8LloValueES3_+0xc9>
    199aa5d4:	48 89 df             	mov    rdi,rbx
    199aa5d7:	be 13 00 00 00       	mov    esi,0x13
    199aa5dc:	48 89 c2             	mov    rdx,rax
    199aa5df:	e8 ec c4 fb ff       	call   19966ad0 <_ZN3xla9jellyfish16LloRegionBuilder6CastToENS0_14LloElementTypeEPNS0_8LloValueE>
    199aa5e4:	48 85 c0             	test   rax,rax
    199aa5e7:	75 23                	jne    199aa60c <_ZN3xla9jellyfish16LloRegionBuilder9VpackcB16EPNS0_8LloValueES3_+0xec>
    199aa5e9:	4c 8b 2b             	mov    r13,QWORD PTR [rbx]
    199aa5ec:	bf 9d 01 00 00       	mov    edi,0x19d
    199aa5f1:	4c 89 fe             	mov    rsi,r15
    199aa5f4:	4c 89 e2             	mov    rdx,r12
    199aa5f7:	4c 89 e9             	mov    rcx,r13
    199aa5fa:	e8 e1 0c f7 ff       	call   1991b2e0 <_ZN3xla9jellyfish14LloInstruction17CreateVectorBinopENS0_9LloOpcodeEPNS0_8LloValueES4_PNS0_9LloRegionE>
    199aa5ff:	4c 89 ef             	mov    rdi,r13
    199aa602:	48 89 c6             	mov    rsi,rax
    199aa605:	31 d2                	xor    edx,edx
    199aa607:	e8 f4 01 fb ff       	call   1995a800 <_ZN3xla9jellyfish9LloRegion17AppendInstructionENSt3__u10unique_ptrINS0_14LloInstructionENS2_14default_deleteIS4_EEEENS2_8optionalINS0_14LloElementTypeEEE>
    199aa60c:	48 89 df             	mov    rdi,rbx
    199aa60f:	be 13 00 00 00       	mov    esi,0x13
    199aa614:	48 89 c2             	mov    rdx,rax
    199aa617:	e8 b4 c4 fb ff       	call   19966ad0 <_ZN3xla9jellyfish16LloRegionBuilder6CastToENS0_14LloElementTypeEPNS0_8LloValueE>
    199aa61c:	49 89 c7             	mov    r15,rax
    199aa61f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    199aa622:	48 8b 78 38          	mov    rdi,QWORD PTR [rax+0x38]
    199aa626:	be 10 00 00 00       	mov    esi,0x10
    199aa62b:	e8 60 64 fa ff       	call   19950a90 <_ZN3xla9jellyfish9LloModule17VectorU32ConstantEj>
    199aa630:	49 89 c4             	mov    r12,rax
    199aa633:	4c 89 f7             	mov    rdi,r14
    199aa636:	48 89 c6             	mov    rsi,rax
    199aa639:	ba 04 00 00 00       	mov    edx,0x4
    199aa63e:	31 c9                	xor    ecx,ecx
