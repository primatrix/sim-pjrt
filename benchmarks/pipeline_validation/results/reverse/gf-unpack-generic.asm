
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

00000000199b2550 <_ZN3xla9jellyfish16LloRegionBuilder11VunpackInstEjNS0_11VpackFormatEPNS0_8LloValueE>:
    199b2550:	55                   	push   rbp
    199b2551:	48 89 e5             	mov    rbp,rsp
    199b2554:	53                   	push   rbx
    199b2555:	50                   	push   rax
    199b2556:	48 8b 1f             	mov    rbx,QWORD PTR [rdi]
    199b2559:	bf 09 01 00 00       	mov    edi,0x109
    199b255e:	49 89 d8             	mov    r8,rbx
    199b2561:	e8 fa 9c f6 ff       	call   1991c260 <_ZN3xla9jellyfish14LloInstruction18CreateVectorUnpackENS0_9LloOpcodeEjNS0_11VpackFormatEPNS0_8LloValueEPNS0_9LloRegionE>
    199b2566:	48 89 df             	mov    rdi,rbx
    199b2569:	48 89 c6             	mov    rsi,rax
    199b256c:	31 d2                	xor    edx,edx
    199b256e:	48 83 c4 08          	add    rsp,0x8
    199b2572:	5b                   	pop    rbx
    199b2573:	5d                   	pop    rbp
    199b2574:	e9 87 82 fa ff       	jmp    1995a800 <_ZN3xla9jellyfish9LloRegion17AppendInstructionENSt3__u10unique_ptrINS0_14LloInstructionENS2_14default_deleteIS4_EEEENS2_8optionalINS0_14LloElementTypeEEE>
    199b2579:	cc                   	int3
    199b257a:	cc                   	int3
    199b257b:	cc                   	int3
    199b257c:	cc                   	int3
    199b257d:	cc                   	int3
    199b257e:	cc                   	int3
    199b257f:	cc                   	int3

00000000199b2580 <_ZN3xla9jellyfish16LloRegionBuilder25VunpackAndJoinLowerB4ToB8EPNS0_8LloValueES3_>:
    199b2580:	55                   	push   rbp
    199b2581:	48 89 e5             	mov    rbp,rsp
    199b2584:	41 57                	push   r15
    199b2586:	41 56                	push   r14
    199b2588:	41 55                	push   r13
    199b258a:	41 54                	push   r12
    199b258c:	53                   	push   rbx
    199b258d:	48 83 ec 18          	sub    rsp,0x18
    199b2591:	48 89 d3             	mov    rbx,rdx
    199b2594:	49 89 f6             	mov    r14,rsi
    199b2597:	49 89 ff             	mov    r15,rdi
    199b259a:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199b259d:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    199b25a1:	48 8b 78 10          	mov    rdi,QWORD PTR [rax+0x10]
    199b25a5:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199b25a8:	be 18 00 00 00       	mov    esi,0x18
    199b25ad:	31 d2                	xor    edx,edx
    199b25af:	ff 90 80 04 00 00    	call   QWORD PTR [rax+0x480]
    199b25b5:	84 c0                	test   al,al
    199b25b7:	74 32                	je     199b25eb <_ZN3xla9jellyfish16LloRegionBuilder25VunpackAndJoinLowerB4ToB8EPNS0_8LloValueES3_+0x6b>
    199b25b9:	4d 8b 3f             	mov    r15,QWORD PTR [r15]
    199b25bc:	bf 0c 01 00 00       	mov    edi,0x10c
    199b25c1:	4c 89 f6             	mov    rsi,r14
    199b25c4:	48 89 da             	mov    rdx,rbx
    199b25c7:	4c 89 f9             	mov    rcx,r15
    199b25ca:	e8 11 8d f6 ff       	call   1991b2e0 <_ZN3xla9jellyfish14LloInstruction17CreateVectorBinopENS0_9LloOpcodeEPNS0_8LloValueES4_PNS0_9LloRegionE>
    199b25cf:	4c 89 ff             	mov    rdi,r15
    199b25d2:	48 89 c6             	mov    rsi,rax
    199b25d5:	31 d2                	xor    edx,edx
    199b25d7:	e8 24 82 fa ff       	call   1995a800 <_ZN3xla9jellyfish9LloRegion17AppendInstructionENSt3__u10unique_ptrINS0_14LloInstructionENS2_14default_deleteIS4_EEEENS2_8optionalINS0_14LloElementTypeEEE>
    199b25dc:	48 83 c4 18          	add    rsp,0x18
    199b25e0:	5b                   	pop    rbx
    199b25e1:	41 5c                	pop    r12
    199b25e3:	41 5d                	pop    r13
    199b25e5:	41 5e                	pop    r14
    199b25e7:	41 5f                	pop    r15
    199b25e9:	5d                   	pop    rbp
    199b25ea:	c3                   	ret
    199b25eb:	bf 20 00 00 00       	mov    edi,0x20
    199b25f0:	e8 8b cb e9 03       	call   1d84f180 <_Znwm>
    199b25f5:	c5 f8 57 c0          	vxorps xmm0,xmm0,xmm0
    199b25f9:	c5 fc 11 00          	vmovups YMMWORD PTR [rax],ymm0
    199b25fd:	48 89 45 d0          	mov    QWORD PTR [rbp-0x30],rax
    199b2601:	4c 8d 6d c0          	lea    r13,[rbp-0x40]
    199b2605:	4c 8d 65 d0          	lea    r12,[rbp-0x30]
    199b2609:	48 c7 45 c0 a6 35 00 	mov    QWORD PTR [rbp-0x40],0x35a6
    199b2610:	00 
    199b2611:	48 8d 0d 8a 75 3c ed 	lea    rcx,[rip+0xffffffffed3c758a]        # 6d79ba2 <sqlite3_str_vappendf.zOrd+0x8c93b>
    199b2618:	48 89 4d c8          	mov    QWORD PTR [rbp-0x38],rcx
    199b261c:	48 89 c7             	mov    rdi,rax
    199b261f:	48 8d 35 9d 5a d6 ee 	lea    rsi,[rip+0xffffffffeed65a9d]        # 87180c3 <nilstr+0x22ddf>
    199b2626:	4c 89 ea             	mov    rdx,r13
    199b2629:	c5 f8 77             	vzeroupper
    199b262c:	e8 df bb f6 ff       	call   1991e210 <_ZNSt3__u11make_uniqueIN3xla9jellyfish13StatusWrapperEJRNS3_11CheckFailerERA69_KcN4absl14SourceLocationEETnNS_9enable_ifIXntsr8is_arrayIT_EE5valueEiE4typeELi0EEENS_10unique_ptrISC_NS_14default_deleteISC_EEEEDpOT0_>
    199b2631:	49 8b 0f             	mov    rcx,QWORD PTR [r15]
    199b2634:	48 8b 79 38          	mov    rdi,QWORD PTR [rcx+0x38]
    199b2638:	48 89 c6             	mov    rsi,rax
    199b263b:	e8 90 f7 f9 ff       	call   19951dd0 <_ZN3xla9jellyfish9LloModule12UpdateStatusENSt3__u10unique_ptrINS0_13StatusWrapperENS2_14default_deleteIS4_EEEE>
    199b2640:	4c 89 e7             	mov    rdi,r12
    199b2643:	31 f6                	xor    esi,esi
    199b2645:	e8 56 b7 f5 f4       	call   e90dda0 <_ZNSt3__u10unique_ptrIN3xla9jellyfish13StatusWrapper11CheckFailerENS_14default_deleteIS4_EEEaSEDn>
    199b264a:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    199b264e:	48 85 c0             	test   rax,rax
    199b2651:	0f 84 62 ff ff ff    	je     199b25b9 <_ZN3xla9jellyfish16LloRegionBuilder25VunpackAndJoinLowerB4ToB8EPNS0_8LloValueES3_+0x39>
    199b2657:	eb b0                	jmp    199b2609 <_ZN3xla9jellyfish16LloRegionBuilder25VunpackAndJoinLowerB4ToB8EPNS0_8LloValueES3_+0x89>
    199b2659:	cc                   	int3
    199b265a:	cc                   	int3
    199b265b:	cc                   	int3
    199b265c:	cc                   	int3
    199b265d:	cc                   	int3
    199b265e:	cc                   	int3
    199b265f:	cc                   	int3

00000000199b2660 <_ZN3xla9jellyfish16LloRegionBuilder25VunpackAndJoinUpperB4ToB8EPNS0_8LloValueES3_>:
    199b2660:	55                   	push   rbp
    199b2661:	48 89 e5             	mov    rbp,rsp
    199b2664:	41 57                	push   r15
    199b2666:	41 56                	push   r14
    199b2668:	41 55                	push   r13
    199b266a:	41 54                	push   r12
    199b266c:	53                   	push   rbx
    199b266d:	48 83 ec 18          	sub    rsp,0x18
    199b2671:	48 89 d3             	mov    rbx,rdx
    199b2674:	49 89 f6             	mov    r14,rsi
    199b2677:	49 89 ff             	mov    r15,rdi
    199b267a:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199b267d:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    199b2681:	48 8b 78 10          	mov    rdi,QWORD PTR [rax+0x10]
    199b2685:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199b2688:	be 18 00 00 00       	mov    esi,0x18
    199b268d:	31 d2                	xor    edx,edx
    199b268f:	ff 90 80 04 00 00    	call   QWORD PTR [rax+0x480]
    199b2695:	84 c0                	test   al,al
    199b2697:	74 32                	je     199b26cb <_ZN3xla9jellyfish16LloRegionBuilder25VunpackAndJoinUpperB4ToB8EPNS0_8LloValueES3_+0x6b>
    199b2699:	4d 8b 3f             	mov    r15,QWORD PTR [r15]
    199b269c:	bf 0d 01 00 00       	mov    edi,0x10d
    199b26a1:	4c 89 f6             	mov    rsi,r14
    199b26a4:	48 89 da             	mov    rdx,rbx
    199b26a7:	4c 89 f9             	mov    rcx,r15
    199b26aa:	e8 31 8c f6 ff       	call   1991b2e0 <_ZN3xla9jellyfish14LloInstruction17CreateVectorBinopENS0_9LloOpcodeEPNS0_8LloValueES4_PNS0_9LloRegionE>
    199b26af:	4c 89 ff             	mov    rdi,r15
    199b26b2:	48 89 c6             	mov    rsi,rax
    199b26b5:	31 d2                	xor    edx,edx
    199b26b7:	e8 44 81 fa ff       	call   1995a800 <_ZN3xla9jellyfish9LloRegion17AppendInstructionENSt3__u10unique_ptrINS0_14LloInstructionENS2_14default_deleteIS4_EEEENS2_8optionalINS0_14LloElementTypeEEE>
    199b26bc:	48 83 c4 18          	add    rsp,0x18
    199b26c0:	5b                   	pop    rbx
    199b26c1:	41 5c                	pop    r12
    199b26c3:	41 5d                	pop    r13
    199b26c5:	41 5e                	pop    r14
    199b26c7:	41 5f                	pop    r15
    199b26c9:	5d                   	pop    rbp
    199b26ca:	c3                   	ret
    199b26cb:	bf 20 00 00 00       	mov    edi,0x20
    199b26d0:	e8 ab ca e9 03       	call   1d84f180 <_Znwm>
    199b26d5:	c5 f8 57 c0          	vxorps xmm0,xmm0,xmm0
    199b26d9:	c5 fc 11 00          	vmovups YMMWORD PTR [rax],ymm0
    199b26dd:	48 89 45 d0          	mov    QWORD PTR [rbp-0x30],rax
    199b26e1:	4c 8d 6d c0          	lea    r13,[rbp-0x40]
    199b26e5:	4c 8d 65 d0          	lea    r12,[rbp-0x30]
    199b26e9:	48 c7 45 c0 ae 35 00 	mov    QWORD PTR [rbp-0x40],0x35ae
    199b26f0:	00 
    199b26f1:	48 8d 0d aa 74 3c ed 	lea    rcx,[rip+0xffffffffed3c74aa]        # 6d79ba2 <sqlite3_str_vappendf.zOrd+0x8c93b>
    199b26f8:	48 89 4d c8          	mov    QWORD PTR [rbp-0x38],rcx
    199b26fc:	48 89 c7             	mov    rdi,rax
    199b26ff:	48 8d 35 bd 59 d6 ee 	lea    rsi,[rip+0xffffffffeed659bd]        # 87180c3 <nilstr+0x22ddf>
    199b2706:	4c 89 ea             	mov    rdx,r13
    199b2709:	c5 f8 77             	vzeroupper
    199b270c:	e8 ff ba f6 ff       	call   1991e210 <_ZNSt3__u11make_uniqueIN3xla9jellyfish13StatusWrapperEJRNS3_11CheckFailerERA69_KcN4absl14SourceLocationEETnNS_9enable_ifIXntsr8is_arrayIT_EE5valueEiE4typeELi0EEENS_10unique_ptrISC_NS_14default_deleteISC_EEEEDpOT0_>
    199b2711:	49 8b 0f             	mov    rcx,QWORD PTR [r15]
    199b2714:	48 8b 79 38          	mov    rdi,QWORD PTR [rcx+0x38]
    199b2718:	48 89 c6             	mov    rsi,rax
    199b271b:	e8 b0 f6 f9 ff       	call   19951dd0 <_ZN3xla9jellyfish9LloModule12UpdateStatusENSt3__u10unique_ptrINS0_13StatusWrapperENS2_14default_deleteIS4_EEEE>
    199b2720:	4c 89 e7             	mov    rdi,r12
    199b2723:	31 f6                	xor    esi,esi
    199b2725:	e8 76 b6 f5 f4       	call   e90dda0 <_ZNSt3__u10unique_ptrIN3xla9jellyfish13StatusWrapper11CheckFailerENS_14default_deleteIS4_EEEaSEDn>
    199b272a:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    199b272e:	48 85 c0             	test   rax,rax
    199b2731:	0f 84 62 ff ff ff    	je     199b2699 <_ZN3xla9jellyfish16LloRegionBuilder25VunpackAndJoinUpperB4ToB8EPNS0_8LloValueES3_+0x39>
    199b2737:	eb b0                	jmp    199b26e9 <_ZN3xla9jellyfish16LloRegionBuilder25VunpackAndJoinUpperB4ToB8EPNS0_8LloValueES3_+0x89>
    199b2739:	cc                   	int3
    199b273a:	cc                   	int3
    199b273b:	cc                   	int3
    199b273c:	cc                   	int3
    199b273d:	cc                   	int3
    199b273e:	cc                   	int3
    199b273f:	cc                   	int3

00000000199b2740 <_ZN3xla9jellyfish16LloRegionBuilder14SpackWithShapeEPNS0_8LloValueERKNS_5ShapeE>:
    199b2740:	55                   	push   rbp
    199b2741:	48 89 e5             	mov    rbp,rsp
    199b2744:	41 57                	push   r15
    199b2746:	41 56                	push   r14
    199b2748:	41 55                	push   r13
    199b274a:	41 54                	push   r12
    199b274c:	53                   	push   rbx
    199b274d:	48 83 ec 18          	sub    rsp,0x18
    199b2751:	49 89 d7             	mov    r15,rdx
    199b2754:	48 89 f3             	mov    rbx,rsi
    199b2757:	49 89 fe             	mov    r14,rdi
    199b275a:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199b275d:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    199b2761:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
    199b2765:	4c 8b a0 38 05 00 00 	mov    r12,QWORD PTR [rax+0x538]
    199b276c:	4c 89 e7             	mov    rdi,r12
    199b276f:	48 89 d6             	mov    rsi,rdx
    199b2772:	e8 39 ed 4c 00       	call   19e814b0 <_ZN3xla9jellyfish16TransferSizeUtil25ShouldPackPREDAsSingleBitERKN3tpu11TpuTopologyERKNS_5ShapeE>
    199b2777:	41 89 c5             	mov    r13d,eax
    199b277a:	4c 89 ff             	mov    rdi,r15
    199b277d:	e8 be 15 cf f2       	call   c6a3d40 <_ZNK3xla5Shape12element_typeEv>
    199b2782:	41 0f b6 d5          	movzx  edx,r13b
    199b2786:	4c 89 e7             	mov    rdi,r12
    199b2789:	89 c6                	mov    esi,eax
    199b278b:	e8 30 f0 4c 00       	call   19e817c0 <_ZN3xla9jellyfish16TransferSizeUtil20ElementPackingFactorERKN3tpu11TpuTopologyENS_13PrimitiveTypeEb>
