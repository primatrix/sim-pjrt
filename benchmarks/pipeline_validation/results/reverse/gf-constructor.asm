
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

000000001937a450 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x30>:
    1937a450:	55                   	push   rbp
    1937a451:	48 89 e5             	mov    rbp,rsp
    1937a454:	41 57                	push   r15
    1937a456:	41 56                	push   r14
    1937a458:	41 55                	push   r13
    1937a45a:	41 54                	push   r12
    1937a45c:	53                   	push   rbx
    1937a45d:	50                   	push   rax
    1937a45e:	48 89 fb             	mov    rbx,rdi
    1937a461:	bf 44 07 00 00       	mov    edi,0x744
    1937a466:	e8 15 4d 4d 04       	call   1d84f180 <operator new(unsigned long)>
    1937a46b:	48 89 03             	mov    QWORD PTR [rbx],rax
    1937a46e:	48 c7 43 10 d1 01 00 	mov    QWORD PTR [rbx+0x10],0x1d1
    1937a475:	00 
    1937a476:	ba 44 07 00 00       	mov    edx,0x744
    1937a47b:	48 89 c7             	mov    rdi,rax
    1937a47e:	be ff 00 00 00       	mov    esi,0xff
    1937a483:	e8 48 50 49 04       	call   1d80f4d0 <memset>
    1937a488:	48 c7 43 08 d1 01 00 	mov    QWORD PTR [rbx+0x8],0x1d1
    1937a48f:	00 
    1937a490:	4c 8d 63 18          	lea    r12,[rbx+0x18]
    1937a494:	4c 8d 6b 20          	lea    r13,[rbx+0x20]
    1937a498:	bf 98 2b 00 00       	mov    edi,0x2b98
    1937a49d:	e8 de 4c 4d 04       	call   1d84f180 <operator new(unsigned long)>
    1937a4a2:	49 89 c6             	mov    r14,rax
    1937a4a5:	48 89 43 18          	mov    QWORD PTR [rbx+0x18],rax
    1937a4a9:	48 c7 43 28 d1 01 00 	mov    QWORD PTR [rbx+0x28],0x1d1
    1937a4b0:	00 
    1937a4b1:	45 31 ff             	xor    r15d,r15d
    1937a4b4:	66 66 66 2e 0f 1f 84 	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
    1937a4bb:	00 00 00 00 00 
    1937a4c0:	bf 80 00 00 00       	mov    edi,0x80
    1937a4c5:	c5 f8 77             	vzeroupper
    1937a4c8:	e8 b3 4c 4d 04       	call   1d84f180 <operator new(unsigned long)>
    1937a4cd:	4b 89 04 3e          	mov    QWORD PTR [r14+r15*1],rax
    1937a4d1:	c5 f8 57 c0          	vxorps xmm0,xmm0,xmm0
    1937a4d5:	c5 fc 11 00          	vmovups YMMWORD PTR [rax],ymm0
    1937a4d9:	c5 fc 11 40 20       	vmovups YMMWORD PTR [rax+0x20],ymm0
    1937a4de:	c5 fc 11 40 40       	vmovups YMMWORD PTR [rax+0x40],ymm0
    1937a4e3:	c5 fc 11 40 60       	vmovups YMMWORD PTR [rax+0x60],ymm0
    1937a4e8:	4b c7 44 3e 10 20 00 	mov    QWORD PTR [r14+r15*1+0x10],0x20
    1937a4ef:	00 00 
    1937a4f1:	4b c7 44 3e 08 20 00 	mov    QWORD PTR [r14+r15*1+0x8],0x20
    1937a4f8:	00 00 
    1937a4fa:	49 83 c7 18          	add    r15,0x18
    1937a4fe:	49 81 ff 98 2b 00 00 	cmp    r15,0x2b98
    1937a505:	75 b9                	jne    1937a4c0 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0xa0>
    1937a507:	49 c7 45 00 d1 01 00 	mov    QWORD PTR [r13+0x0],0x1d1
    1937a50e:	00 
    1937a50f:	48 8d 4b 08          	lea    rcx,[rbx+0x8]
    1937a513:	48 83 39 00          	cmp    QWORD PTR [rcx],0x0
    1937a517:	0f 84 12 65 00 00    	je     19380a2f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x660f>
    1937a51d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a520:	c7 00 01 00 00 00    	mov    DWORD PTR [rax],0x1
    1937a526:	48 83 7b 08 01       	cmp    QWORD PTR [rbx+0x8],0x1
    1937a52b:	0f 86 00 65 00 00    	jbe    19380a31 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6611>
    1937a531:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a534:	c7 40 04 01 00 00 00 	mov    DWORD PTR [rax+0x4],0x1
    1937a53b:	48 83 7b 08 02       	cmp    QWORD PTR [rbx+0x8],0x2
    1937a540:	0f 86 ed 64 00 00    	jbe    19380a33 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6613>
    1937a546:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a549:	c7 40 08 02 00 00 00 	mov    DWORD PTR [rax+0x8],0x2
    1937a550:	48 83 7b 08 03       	cmp    QWORD PTR [rbx+0x8],0x3
    1937a555:	0f 86 da 64 00 00    	jbe    19380a35 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6615>
    1937a55b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a55e:	c7 40 0c 01 00 00 00 	mov    DWORD PTR [rax+0xc],0x1
    1937a565:	48 83 7b 08 04       	cmp    QWORD PTR [rbx+0x8],0x4
    1937a56a:	0f 86 c7 64 00 00    	jbe    19380a37 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6617>
    1937a570:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a573:	c7 40 10 01 00 00 00 	mov    DWORD PTR [rax+0x10],0x1
    1937a57a:	48 83 7b 08 05       	cmp    QWORD PTR [rbx+0x8],0x5
    1937a57f:	0f 86 b4 64 00 00    	jbe    19380a39 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6619>
    1937a585:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a588:	c7 40 14 01 00 00 00 	mov    DWORD PTR [rax+0x14],0x1
    1937a58f:	48 83 7b 08 06       	cmp    QWORD PTR [rbx+0x8],0x6
    1937a594:	0f 86 a1 64 00 00    	jbe    19380a3b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x661b>
    1937a59a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a59d:	c7 40 18 01 00 00 00 	mov    DWORD PTR [rax+0x18],0x1
    1937a5a4:	48 83 7b 08 07       	cmp    QWORD PTR [rbx+0x8],0x7
    1937a5a9:	0f 86 8e 64 00 00    	jbe    19380a3d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x661d>
    1937a5af:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a5b2:	c7 40 1c 01 00 00 00 	mov    DWORD PTR [rax+0x1c],0x1
    1937a5b9:	48 83 7b 08 08       	cmp    QWORD PTR [rbx+0x8],0x8
    1937a5be:	0f 86 7b 64 00 00    	jbe    19380a3f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x661f>
    1937a5c4:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a5c7:	c7 40 20 01 00 00 00 	mov    DWORD PTR [rax+0x20],0x1
    1937a5ce:	48 83 7b 08 09       	cmp    QWORD PTR [rbx+0x8],0x9
    1937a5d3:	0f 86 68 64 00 00    	jbe    19380a41 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6621>
    1937a5d9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a5dc:	c7 40 24 02 00 00 00 	mov    DWORD PTR [rax+0x24],0x2
    1937a5e3:	48 83 7b 08 0a       	cmp    QWORD PTR [rbx+0x8],0xa
    1937a5e8:	0f 86 55 64 00 00    	jbe    19380a43 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6623>
    1937a5ee:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a5f1:	c7 40 28 02 00 00 00 	mov    DWORD PTR [rax+0x28],0x2
    1937a5f8:	48 83 7b 08 0b       	cmp    QWORD PTR [rbx+0x8],0xb
    1937a5fd:	0f 86 42 64 00 00    	jbe    19380a45 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6625>
    1937a603:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a606:	c7 40 2c 01 00 00 00 	mov    DWORD PTR [rax+0x2c],0x1
    1937a60d:	48 83 7b 08 0c       	cmp    QWORD PTR [rbx+0x8],0xc
    1937a612:	0f 86 2f 64 00 00    	jbe    19380a47 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6627>
    1937a618:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a61b:	c7 40 30 01 00 00 00 	mov    DWORD PTR [rax+0x30],0x1
    1937a622:	48 83 7b 08 0d       	cmp    QWORD PTR [rbx+0x8],0xd
    1937a627:	0f 86 1c 64 00 00    	jbe    19380a49 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6629>
    1937a62d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a630:	c7 40 34 01 00 00 00 	mov    DWORD PTR [rax+0x34],0x1
    1937a637:	48 83 7b 08 0e       	cmp    QWORD PTR [rbx+0x8],0xe
    1937a63c:	0f 86 09 64 00 00    	jbe    19380a4b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x662b>
    1937a642:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a645:	c7 40 38 01 00 00 00 	mov    DWORD PTR [rax+0x38],0x1
    1937a64c:	48 83 7b 08 0f       	cmp    QWORD PTR [rbx+0x8],0xf
    1937a651:	0f 86 f6 63 00 00    	jbe    19380a4d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x662d>
    1937a657:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a65a:	c7 40 3c 01 00 00 00 	mov    DWORD PTR [rax+0x3c],0x1
    1937a661:	48 83 7b 08 10       	cmp    QWORD PTR [rbx+0x8],0x10
    1937a666:	0f 86 e3 63 00 00    	jbe    19380a4f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x662f>
    1937a66c:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a66f:	c7 40 40 01 00 00 00 	mov    DWORD PTR [rax+0x40],0x1
    1937a676:	48 83 7b 08 11       	cmp    QWORD PTR [rbx+0x8],0x11
    1937a67b:	0f 86 d0 63 00 00    	jbe    19380a51 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6631>
    1937a681:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a684:	c7 40 44 01 00 00 00 	mov    DWORD PTR [rax+0x44],0x1
    1937a68b:	48 83 7b 08 12       	cmp    QWORD PTR [rbx+0x8],0x12
    1937a690:	0f 86 bd 63 00 00    	jbe    19380a53 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6633>
    1937a696:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a699:	c7 40 48 01 00 00 00 	mov    DWORD PTR [rax+0x48],0x1
    1937a6a0:	48 83 7b 08 13       	cmp    QWORD PTR [rbx+0x8],0x13
    1937a6a5:	0f 86 aa 63 00 00    	jbe    19380a55 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6635>
    1937a6ab:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a6ae:	c7 40 4c 01 00 00 00 	mov    DWORD PTR [rax+0x4c],0x1
    1937a6b5:	48 83 7b 08 14       	cmp    QWORD PTR [rbx+0x8],0x14
    1937a6ba:	0f 86 97 63 00 00    	jbe    19380a57 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6637>
    1937a6c0:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a6c3:	c7 40 50 01 00 00 00 	mov    DWORD PTR [rax+0x50],0x1
    1937a6ca:	48 83 7b 08 15       	cmp    QWORD PTR [rbx+0x8],0x15
    1937a6cf:	0f 86 84 63 00 00    	jbe    19380a59 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6639>
    1937a6d5:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a6d8:	c7 40 54 01 00 00 00 	mov    DWORD PTR [rax+0x54],0x1
    1937a6df:	48 83 7b 08 16       	cmp    QWORD PTR [rbx+0x8],0x16
    1937a6e4:	0f 86 71 63 00 00    	jbe    19380a5b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x663b>
    1937a6ea:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a6ed:	c7 40 58 01 00 00 00 	mov    DWORD PTR [rax+0x58],0x1
    1937a6f4:	48 83 7b 08 17       	cmp    QWORD PTR [rbx+0x8],0x17
    1937a6f9:	0f 86 5e 63 00 00    	jbe    19380a5d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x663d>
    1937a6ff:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a702:	c7 40 5c 01 00 00 00 	mov    DWORD PTR [rax+0x5c],0x1
    1937a709:	48 83 7b 08 18       	cmp    QWORD PTR [rbx+0x8],0x18
    1937a70e:	0f 86 4b 63 00 00    	jbe    19380a5f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x663f>
    1937a714:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a717:	c7 40 60 01 00 00 00 	mov    DWORD PTR [rax+0x60],0x1
    1937a71e:	48 83 7b 08 19       	cmp    QWORD PTR [rbx+0x8],0x19
    1937a723:	0f 86 38 63 00 00    	jbe    19380a61 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6641>
    1937a729:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a72c:	c7 40 64 01 00 00 00 	mov    DWORD PTR [rax+0x64],0x1
    1937a733:	48 83 7b 08 1a       	cmp    QWORD PTR [rbx+0x8],0x1a
    1937a738:	0f 86 25 63 00 00    	jbe    19380a63 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6643>
    1937a73e:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a741:	c7 40 68 01 00 00 00 	mov    DWORD PTR [rax+0x68],0x1
    1937a748:	48 83 7b 08 1b       	cmp    QWORD PTR [rbx+0x8],0x1b
    1937a74d:	0f 86 12 63 00 00    	jbe    19380a65 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6645>
    1937a753:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a756:	c7 40 6c 01 00 00 00 	mov    DWORD PTR [rax+0x6c],0x1
    1937a75d:	48 83 7b 08 1c       	cmp    QWORD PTR [rbx+0x8],0x1c
    1937a762:	0f 86 ff 62 00 00    	jbe    19380a67 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6647>
    1937a768:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a76b:	c7 40 70 01 00 00 00 	mov    DWORD PTR [rax+0x70],0x1
    1937a772:	48 83 7b 08 1d       	cmp    QWORD PTR [rbx+0x8],0x1d
    1937a777:	0f 86 ec 62 00 00    	jbe    19380a69 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6649>
    1937a77d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a780:	c7 40 74 01 00 00 00 	mov    DWORD PTR [rax+0x74],0x1
    1937a787:	48 83 7b 08 1e       	cmp    QWORD PTR [rbx+0x8],0x1e
    1937a78c:	0f 86 d9 62 00 00    	jbe    19380a6b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x664b>
    1937a792:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a795:	c7 40 78 01 00 00 00 	mov    DWORD PTR [rax+0x78],0x1
    1937a79c:	48 83 7b 08 1f       	cmp    QWORD PTR [rbx+0x8],0x1f
    1937a7a1:	0f 86 c6 62 00 00    	jbe    19380a6d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x664d>
    1937a7a7:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a7aa:	c7 40 7c 01 00 00 00 	mov    DWORD PTR [rax+0x7c],0x1
    1937a7b1:	48 83 7b 08 20       	cmp    QWORD PTR [rbx+0x8],0x20
    1937a7b6:	0f 86 b3 62 00 00    	jbe    19380a6f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x664f>
    1937a7bc:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a7bf:	c7 80 80 00 00 00 01 	mov    DWORD PTR [rax+0x80],0x1
    1937a7c6:	00 00 00 
    1937a7c9:	48 83 7b 08 21       	cmp    QWORD PTR [rbx+0x8],0x21
    1937a7ce:	0f 86 9d 62 00 00    	jbe    19380a71 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6651>
    1937a7d4:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a7d7:	c7 80 84 00 00 00 01 	mov    DWORD PTR [rax+0x84],0x1
    1937a7de:	00 00 00 
    1937a7e1:	48 83 7b 08 22       	cmp    QWORD PTR [rbx+0x8],0x22
    1937a7e6:	0f 86 87 62 00 00    	jbe    19380a73 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6653>
    1937a7ec:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a7ef:	c7 80 88 00 00 00 01 	mov    DWORD PTR [rax+0x88],0x1
    1937a7f6:	00 00 00 
    1937a7f9:	48 83 7b 08 23       	cmp    QWORD PTR [rbx+0x8],0x23
    1937a7fe:	0f 86 71 62 00 00    	jbe    19380a75 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6655>
    1937a804:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a807:	c7 80 8c 00 00 00 01 	mov    DWORD PTR [rax+0x8c],0x1
    1937a80e:	00 00 00 
    1937a811:	48 83 7b 08 24       	cmp    QWORD PTR [rbx+0x8],0x24
    1937a816:	0f 86 5b 62 00 00    	jbe    19380a77 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6657>
    1937a81c:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a81f:	c7 80 90 00 00 00 01 	mov    DWORD PTR [rax+0x90],0x1
    1937a826:	00 00 00 
    1937a829:	48 83 7b 08 25       	cmp    QWORD PTR [rbx+0x8],0x25
    1937a82e:	0f 86 45 62 00 00    	jbe    19380a79 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6659>
    1937a834:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a837:	c7 80 94 00 00 00 02 	mov    DWORD PTR [rax+0x94],0x2
    1937a83e:	00 00 00 
    1937a841:	48 83 7b 08 26       	cmp    QWORD PTR [rbx+0x8],0x26
    1937a846:	0f 86 2f 62 00 00    	jbe    19380a7b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x665b>
    1937a84c:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a84f:	c7 80 98 00 00 00 02 	mov    DWORD PTR [rax+0x98],0x2
    1937a856:	00 00 00 
    1937a859:	48 83 7b 08 27       	cmp    QWORD PTR [rbx+0x8],0x27
    1937a85e:	0f 86 19 62 00 00    	jbe    19380a7d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x665d>
    1937a864:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a867:	c7 80 9c 00 00 00 02 	mov    DWORD PTR [rax+0x9c],0x2
    1937a86e:	00 00 00 
    1937a871:	48 83 7b 08 28       	cmp    QWORD PTR [rbx+0x8],0x28
    1937a876:	0f 86 03 62 00 00    	jbe    19380a7f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x665f>
    1937a87c:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a87f:	c7 80 a0 00 00 00 09 	mov    DWORD PTR [rax+0xa0],0x9
    1937a886:	00 00 00 
    1937a889:	48 83 7b 08 29       	cmp    QWORD PTR [rbx+0x8],0x29
    1937a88e:	0f 86 ed 61 00 00    	jbe    19380a81 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6661>
    1937a894:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a897:	c7 80 a4 00 00 00 09 	mov    DWORD PTR [rax+0xa4],0x9
    1937a89e:	00 00 00 
    1937a8a1:	48 83 7b 08 2a       	cmp    QWORD PTR [rbx+0x8],0x2a
    1937a8a6:	0f 86 d7 61 00 00    	jbe    19380a83 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6663>
    1937a8ac:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a8af:	c7 80 a8 00 00 00 09 	mov    DWORD PTR [rax+0xa8],0x9
    1937a8b6:	00 00 00 
    1937a8b9:	48 83 7b 08 2b       	cmp    QWORD PTR [rbx+0x8],0x2b
    1937a8be:	0f 86 c1 61 00 00    	jbe    19380a85 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6665>
    1937a8c4:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a8c7:	c7 80 ac 00 00 00 01 	mov    DWORD PTR [rax+0xac],0x1
    1937a8ce:	00 00 00 
    1937a8d1:	48 83 7b 08 2c       	cmp    QWORD PTR [rbx+0x8],0x2c
    1937a8d6:	0f 86 ab 61 00 00    	jbe    19380a87 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6667>
    1937a8dc:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a8df:	c7 80 b0 00 00 00 01 	mov    DWORD PTR [rax+0xb0],0x1
    1937a8e6:	00 00 00 
    1937a8e9:	48 83 7b 08 2d       	cmp    QWORD PTR [rbx+0x8],0x2d
    1937a8ee:	0f 86 95 61 00 00    	jbe    19380a89 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6669>
    1937a8f4:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a8f7:	c7 80 b4 00 00 00 03 	mov    DWORD PTR [rax+0xb4],0x3
    1937a8fe:	00 00 00 
    1937a901:	48 83 7b 20 2d       	cmp    QWORD PTR [rbx+0x20],0x2d
    1937a906:	0f 86 7f 61 00 00    	jbe    19380a8b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x666b>
    1937a90c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937a910:	48 83 b8 40 04 00 00 	cmp    QWORD PTR [rax+0x440],0x0
    1937a917:	00 
    1937a918:	0f 84 6f 61 00 00    	je     19380a8d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x666d>
    1937a91e:	48 8b 80 38 04 00 00 	mov    rax,QWORD PTR [rax+0x438]
    1937a925:	c7 00 02 00 00 00    	mov    DWORD PTR [rax],0x2
    1937a92b:	48 83 39 2e          	cmp    QWORD PTR [rcx],0x2e
    1937a92f:	0f 86 5a 61 00 00    	jbe    19380a8f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x666f>
    1937a935:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a938:	c7 80 b8 00 00 00 02 	mov    DWORD PTR [rax+0xb8],0x2
    1937a93f:	00 00 00 
    1937a942:	48 83 7b 08 2f       	cmp    QWORD PTR [rbx+0x8],0x2f
    1937a947:	0f 86 44 61 00 00    	jbe    19380a91 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6671>
    1937a94d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a950:	c7 80 bc 00 00 00 02 	mov    DWORD PTR [rax+0xbc],0x2
    1937a957:	00 00 00 
    1937a95a:	48 83 7b 08 30       	cmp    QWORD PTR [rbx+0x8],0x30
    1937a95f:	0f 86 2e 61 00 00    	jbe    19380a93 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6673>
    1937a965:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a968:	c7 80 c0 00 00 00 01 	mov    DWORD PTR [rax+0xc0],0x1
    1937a96f:	00 00 00 
    1937a972:	48 83 7b 20 30       	cmp    QWORD PTR [rbx+0x20],0x30
    1937a977:	0f 86 18 61 00 00    	jbe    19380a95 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6675>
    1937a97d:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937a981:	48 83 b8 88 04 00 00 	cmp    QWORD PTR [rax+0x488],0x1
    1937a988:	01 
    1937a989:	0f 86 08 61 00 00    	jbe    19380a97 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6677>
    1937a98f:	48 8b 80 80 04 00 00 	mov    rax,QWORD PTR [rax+0x480]
    1937a996:	c7 40 04 02 00 00 00 	mov    DWORD PTR [rax+0x4],0x2
    1937a99d:	48 83 39 31          	cmp    QWORD PTR [rcx],0x31
    1937a9a1:	0f 86 f2 60 00 00    	jbe    19380a99 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6679>
    1937a9a7:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a9aa:	c7 80 c4 00 00 00 01 	mov    DWORD PTR [rax+0xc4],0x1
    1937a9b1:	00 00 00 
    1937a9b4:	48 83 7b 08 32       	cmp    QWORD PTR [rbx+0x8],0x32
    1937a9b9:	0f 86 dc 60 00 00    	jbe    19380a9b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x667b>
    1937a9bf:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937a9c2:	c7 80 c8 00 00 00 02 	mov    DWORD PTR [rax+0xc8],0x2
    1937a9c9:	00 00 00 
    1937a9cc:	48 83 7b 20 32       	cmp    QWORD PTR [rbx+0x20],0x32
    1937a9d1:	0f 86 c6 60 00 00    	jbe    19380a9d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x667d>
    1937a9d7:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937a9db:	48 83 b8 b8 04 00 00 	cmp    QWORD PTR [rax+0x4b8],0x0
    1937a9e2:	00 
    1937a9e3:	0f 84 b6 60 00 00    	je     19380a9f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x667f>
    1937a9e9:	48 8b 80 b0 04 00 00 	mov    rax,QWORD PTR [rax+0x4b0]
    1937a9f0:	c7 00 02 00 00 00    	mov    DWORD PTR [rax],0x2
    1937a9f6:	49 83 7d 00 32       	cmp    QWORD PTR [r13+0x0],0x32
    1937a9fb:	0f 86 a0 60 00 00    	jbe    19380aa1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6681>
    1937aa01:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937aa05:	48 83 b8 b8 04 00 00 	cmp    QWORD PTR [rax+0x4b8],0x1
    1937aa0c:	01 
    1937aa0d:	0f 86 90 60 00 00    	jbe    19380aa3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6683>
    1937aa13:	48 8b 80 b0 04 00 00 	mov    rax,QWORD PTR [rax+0x4b0]
    1937aa1a:	c7 40 04 02 00 00 00 	mov    DWORD PTR [rax+0x4],0x2
    1937aa21:	48 83 39 33          	cmp    QWORD PTR [rcx],0x33
    1937aa25:	0f 86 7a 60 00 00    	jbe    19380aa5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6685>
    1937aa2b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937aa2e:	c7 80 cc 00 00 00 02 	mov    DWORD PTR [rax+0xcc],0x2
    1937aa35:	00 00 00 
    1937aa38:	48 83 7b 08 34       	cmp    QWORD PTR [rbx+0x8],0x34
    1937aa3d:	0f 86 64 60 00 00    	jbe    19380aa7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6687>
    1937aa43:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937aa46:	c7 80 d0 00 00 00 02 	mov    DWORD PTR [rax+0xd0],0x2
    1937aa4d:	00 00 00 
    1937aa50:	48 83 7b 08 35       	cmp    QWORD PTR [rbx+0x8],0x35
    1937aa55:	0f 86 4e 60 00 00    	jbe    19380aa9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6689>
    1937aa5b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937aa5e:	c7 80 d4 00 00 00 02 	mov    DWORD PTR [rax+0xd4],0x2
    1937aa65:	00 00 00 
    1937aa68:	48 83 7b 08 36       	cmp    QWORD PTR [rbx+0x8],0x36
    1937aa6d:	0f 86 38 60 00 00    	jbe    19380aab <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x668b>
    1937aa73:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937aa76:	c7 80 d8 00 00 00 02 	mov    DWORD PTR [rax+0xd8],0x2
    1937aa7d:	00 00 00 
    1937aa80:	48 83 7b 08 37       	cmp    QWORD PTR [rbx+0x8],0x37
    1937aa85:	0f 86 22 60 00 00    	jbe    19380aad <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x668d>
    1937aa8b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937aa8e:	c7 80 dc 00 00 00 02 	mov    DWORD PTR [rax+0xdc],0x2
    1937aa95:	00 00 00 
    1937aa98:	48 83 7b 08 38       	cmp    QWORD PTR [rbx+0x8],0x38
    1937aa9d:	0f 86 0c 60 00 00    	jbe    19380aaf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x668f>
    1937aaa3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937aaa6:	c7 80 e0 00 00 00 02 	mov    DWORD PTR [rax+0xe0],0x2
    1937aaad:	00 00 00 
    1937aab0:	48 83 7b 08 39       	cmp    QWORD PTR [rbx+0x8],0x39
    1937aab5:	0f 86 f6 5f 00 00    	jbe    19380ab1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6691>
    1937aabb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937aabe:	c7 80 e4 00 00 00 02 	mov    DWORD PTR [rax+0xe4],0x2
    1937aac5:	00 00 00 
    1937aac8:	48 83 7b 08 3a       	cmp    QWORD PTR [rbx+0x8],0x3a
    1937aacd:	0f 86 e0 5f 00 00    	jbe    19380ab3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6693>
    1937aad3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937aad6:	c7 80 e8 00 00 00 02 	mov    DWORD PTR [rax+0xe8],0x2
    1937aadd:	00 00 00 
    1937aae0:	48 83 7b 08 3b       	cmp    QWORD PTR [rbx+0x8],0x3b
    1937aae5:	0f 86 ca 5f 00 00    	jbe    19380ab5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6695>
    1937aaeb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937aaee:	c7 80 ec 00 00 00 02 	mov    DWORD PTR [rax+0xec],0x2
    1937aaf5:	00 00 00 
    1937aaf8:	48 83 7b 08 3c       	cmp    QWORD PTR [rbx+0x8],0x3c
    1937aafd:	0f 86 b4 5f 00 00    	jbe    19380ab7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6697>
    1937ab03:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ab06:	c7 80 f0 00 00 00 02 	mov    DWORD PTR [rax+0xf0],0x2
    1937ab0d:	00 00 00 
    1937ab10:	48 83 7b 08 3d       	cmp    QWORD PTR [rbx+0x8],0x3d
    1937ab15:	0f 86 9e 5f 00 00    	jbe    19380ab9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6699>
    1937ab1b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ab1e:	c7 80 f4 00 00 00 02 	mov    DWORD PTR [rax+0xf4],0x2
    1937ab25:	00 00 00 
    1937ab28:	48 83 7b 08 3e       	cmp    QWORD PTR [rbx+0x8],0x3e
    1937ab2d:	0f 86 88 5f 00 00    	jbe    19380abb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x669b>
    1937ab33:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ab36:	c7 80 f8 00 00 00 02 	mov    DWORD PTR [rax+0xf8],0x2
    1937ab3d:	00 00 00 
    1937ab40:	48 83 7b 08 3f       	cmp    QWORD PTR [rbx+0x8],0x3f
    1937ab45:	0f 86 72 5f 00 00    	jbe    19380abd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x669d>
    1937ab4b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ab4e:	c7 80 fc 00 00 00 02 	mov    DWORD PTR [rax+0xfc],0x2
    1937ab55:	00 00 00 
    1937ab58:	48 83 7b 08 40       	cmp    QWORD PTR [rbx+0x8],0x40
    1937ab5d:	0f 86 5c 5f 00 00    	jbe    19380abf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x669f>
    1937ab63:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ab66:	c7 80 00 01 00 00 02 	mov    DWORD PTR [rax+0x100],0x2
    1937ab6d:	00 00 00 
    1937ab70:	48 83 7b 08 41       	cmp    QWORD PTR [rbx+0x8],0x41
    1937ab75:	0f 86 46 5f 00 00    	jbe    19380ac1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66a1>
    1937ab7b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ab7e:	c7 80 04 01 00 00 02 	mov    DWORD PTR [rax+0x104],0x2
    1937ab85:	00 00 00 
    1937ab88:	48 83 7b 08 42       	cmp    QWORD PTR [rbx+0x8],0x42
    1937ab8d:	0f 86 30 5f 00 00    	jbe    19380ac3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66a3>
    1937ab93:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ab96:	c7 80 08 01 00 00 02 	mov    DWORD PTR [rax+0x108],0x2
    1937ab9d:	00 00 00 
    1937aba0:	48 83 7b 08 43       	cmp    QWORD PTR [rbx+0x8],0x43
    1937aba5:	0f 86 1a 5f 00 00    	jbe    19380ac5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66a5>
    1937abab:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937abae:	c7 80 0c 01 00 00 02 	mov    DWORD PTR [rax+0x10c],0x2
    1937abb5:	00 00 00 
    1937abb8:	48 83 7b 08 44       	cmp    QWORD PTR [rbx+0x8],0x44
    1937abbd:	0f 86 04 5f 00 00    	jbe    19380ac7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66a7>
    1937abc3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937abc6:	c7 80 10 01 00 00 02 	mov    DWORD PTR [rax+0x110],0x2
    1937abcd:	00 00 00 
    1937abd0:	48 83 7b 08 45       	cmp    QWORD PTR [rbx+0x8],0x45
    1937abd5:	0f 86 ee 5e 00 00    	jbe    19380ac9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66a9>
    1937abdb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937abde:	c7 80 14 01 00 00 02 	mov    DWORD PTR [rax+0x114],0x2
    1937abe5:	00 00 00 
    1937abe8:	48 83 7b 08 46       	cmp    QWORD PTR [rbx+0x8],0x46
    1937abed:	0f 86 d8 5e 00 00    	jbe    19380acb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66ab>
    1937abf3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937abf6:	c7 80 18 01 00 00 02 	mov    DWORD PTR [rax+0x118],0x2
    1937abfd:	00 00 00 
    1937ac00:	48 83 7b 08 47       	cmp    QWORD PTR [rbx+0x8],0x47
    1937ac05:	0f 86 c2 5e 00 00    	jbe    19380acd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66ad>
    1937ac0b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ac0e:	c7 80 1c 01 00 00 02 	mov    DWORD PTR [rax+0x11c],0x2
    1937ac15:	00 00 00 
    1937ac18:	48 83 7b 08 48       	cmp    QWORD PTR [rbx+0x8],0x48
    1937ac1d:	0f 86 ac 5e 00 00    	jbe    19380acf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66af>
    1937ac23:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ac26:	c7 80 20 01 00 00 02 	mov    DWORD PTR [rax+0x120],0x2
    1937ac2d:	00 00 00 
    1937ac30:	48 83 7b 08 49       	cmp    QWORD PTR [rbx+0x8],0x49
    1937ac35:	0f 86 96 5e 00 00    	jbe    19380ad1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66b1>
    1937ac3b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ac3e:	c7 80 24 01 00 00 02 	mov    DWORD PTR [rax+0x124],0x2
    1937ac45:	00 00 00 
    1937ac48:	48 83 7b 08 4a       	cmp    QWORD PTR [rbx+0x8],0x4a
    1937ac4d:	0f 86 80 5e 00 00    	jbe    19380ad3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66b3>
    1937ac53:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ac56:	c7 80 28 01 00 00 02 	mov    DWORD PTR [rax+0x128],0x2
    1937ac5d:	00 00 00 
    1937ac60:	48 83 7b 08 4b       	cmp    QWORD PTR [rbx+0x8],0x4b
    1937ac65:	0f 86 6a 5e 00 00    	jbe    19380ad5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66b5>
    1937ac6b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ac6e:	c7 80 2c 01 00 00 02 	mov    DWORD PTR [rax+0x12c],0x2
    1937ac75:	00 00 00 
    1937ac78:	48 83 7b 08 4c       	cmp    QWORD PTR [rbx+0x8],0x4c
    1937ac7d:	0f 86 54 5e 00 00    	jbe    19380ad7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66b7>
    1937ac83:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ac86:	c7 80 30 01 00 00 02 	mov    DWORD PTR [rax+0x130],0x2
    1937ac8d:	00 00 00 
    1937ac90:	48 83 7b 08 4d       	cmp    QWORD PTR [rbx+0x8],0x4d
    1937ac95:	0f 86 3e 5e 00 00    	jbe    19380ad9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66b9>
    1937ac9b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ac9e:	c7 80 34 01 00 00 02 	mov    DWORD PTR [rax+0x134],0x2
    1937aca5:	00 00 00 
    1937aca8:	48 83 7b 08 4e       	cmp    QWORD PTR [rbx+0x8],0x4e
    1937acad:	0f 86 28 5e 00 00    	jbe    19380adb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66bb>
    1937acb3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937acb6:	c7 80 38 01 00 00 02 	mov    DWORD PTR [rax+0x138],0x2
    1937acbd:	00 00 00 
    1937acc0:	48 83 7b 08 4f       	cmp    QWORD PTR [rbx+0x8],0x4f
    1937acc5:	0f 86 12 5e 00 00    	jbe    19380add <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66bd>
    1937accb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937acce:	c7 80 3c 01 00 00 02 	mov    DWORD PTR [rax+0x13c],0x2
    1937acd5:	00 00 00 
    1937acd8:	48 83 7b 08 50       	cmp    QWORD PTR [rbx+0x8],0x50
    1937acdd:	0f 86 fc 5d 00 00    	jbe    19380adf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66bf>
    1937ace3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ace6:	c7 80 40 01 00 00 02 	mov    DWORD PTR [rax+0x140],0x2
    1937aced:	00 00 00 
    1937acf0:	48 83 7b 08 51       	cmp    QWORD PTR [rbx+0x8],0x51
    1937acf5:	0f 86 e6 5d 00 00    	jbe    19380ae1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66c1>
    1937acfb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937acfe:	c7 80 44 01 00 00 02 	mov    DWORD PTR [rax+0x144],0x2
    1937ad05:	00 00 00 
    1937ad08:	48 83 7b 08 52       	cmp    QWORD PTR [rbx+0x8],0x52
    1937ad0d:	0f 86 d0 5d 00 00    	jbe    19380ae3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66c3>
    1937ad13:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ad16:	c7 80 48 01 00 00 02 	mov    DWORD PTR [rax+0x148],0x2
    1937ad1d:	00 00 00 
    1937ad20:	48 83 7b 08 53       	cmp    QWORD PTR [rbx+0x8],0x53
    1937ad25:	0f 86 ba 5d 00 00    	jbe    19380ae5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66c5>
    1937ad2b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ad2e:	c7 80 4c 01 00 00 02 	mov    DWORD PTR [rax+0x14c],0x2
    1937ad35:	00 00 00 
    1937ad38:	48 83 7b 08 54       	cmp    QWORD PTR [rbx+0x8],0x54
    1937ad3d:	0f 86 a4 5d 00 00    	jbe    19380ae7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66c7>
    1937ad43:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ad46:	c7 80 50 01 00 00 02 	mov    DWORD PTR [rax+0x150],0x2
    1937ad4d:	00 00 00 
    1937ad50:	48 83 7b 08 55       	cmp    QWORD PTR [rbx+0x8],0x55
    1937ad55:	0f 86 8e 5d 00 00    	jbe    19380ae9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66c9>
    1937ad5b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ad5e:	c7 80 54 01 00 00 02 	mov    DWORD PTR [rax+0x154],0x2
    1937ad65:	00 00 00 
    1937ad68:	48 83 7b 08 56       	cmp    QWORD PTR [rbx+0x8],0x56
    1937ad6d:	0f 86 78 5d 00 00    	jbe    19380aeb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66cb>
    1937ad73:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ad76:	c7 80 58 01 00 00 02 	mov    DWORD PTR [rax+0x158],0x2
    1937ad7d:	00 00 00 
    1937ad80:	48 83 7b 08 57       	cmp    QWORD PTR [rbx+0x8],0x57
    1937ad85:	0f 86 62 5d 00 00    	jbe    19380aed <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66cd>
    1937ad8b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ad8e:	c7 80 5c 01 00 00 02 	mov    DWORD PTR [rax+0x15c],0x2
    1937ad95:	00 00 00 
    1937ad98:	48 83 7b 08 58       	cmp    QWORD PTR [rbx+0x8],0x58
    1937ad9d:	0f 86 4c 5d 00 00    	jbe    19380aef <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66cf>
    1937ada3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ada6:	c7 80 60 01 00 00 02 	mov    DWORD PTR [rax+0x160],0x2
    1937adad:	00 00 00 
    1937adb0:	48 83 7b 08 59       	cmp    QWORD PTR [rbx+0x8],0x59
    1937adb5:	0f 86 36 5d 00 00    	jbe    19380af1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66d1>
    1937adbb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937adbe:	c7 80 64 01 00 00 02 	mov    DWORD PTR [rax+0x164],0x2
    1937adc5:	00 00 00 
    1937adc8:	48 83 7b 08 5a       	cmp    QWORD PTR [rbx+0x8],0x5a
    1937adcd:	0f 86 20 5d 00 00    	jbe    19380af3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66d3>
    1937add3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937add6:	c7 80 68 01 00 00 02 	mov    DWORD PTR [rax+0x168],0x2
    1937addd:	00 00 00 
    1937ade0:	48 83 7b 08 5b       	cmp    QWORD PTR [rbx+0x8],0x5b
    1937ade5:	0f 86 0a 5d 00 00    	jbe    19380af5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66d5>
    1937adeb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937adee:	c7 80 6c 01 00 00 02 	mov    DWORD PTR [rax+0x16c],0x2
    1937adf5:	00 00 00 
    1937adf8:	48 83 7b 08 5c       	cmp    QWORD PTR [rbx+0x8],0x5c
    1937adfd:	0f 86 f4 5c 00 00    	jbe    19380af7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66d7>
    1937ae03:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ae06:	c7 80 70 01 00 00 02 	mov    DWORD PTR [rax+0x170],0x2
    1937ae0d:	00 00 00 
    1937ae10:	48 83 7b 08 5d       	cmp    QWORD PTR [rbx+0x8],0x5d
    1937ae15:	0f 86 de 5c 00 00    	jbe    19380af9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66d9>
    1937ae1b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ae1e:	c7 80 74 01 00 00 01 	mov    DWORD PTR [rax+0x174],0x1
    1937ae25:	00 00 00 
    1937ae28:	48 83 7b 08 5e       	cmp    QWORD PTR [rbx+0x8],0x5e
    1937ae2d:	0f 86 c8 5c 00 00    	jbe    19380afb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66db>
    1937ae33:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ae36:	c7 80 78 01 00 00 02 	mov    DWORD PTR [rax+0x178],0x2
    1937ae3d:	00 00 00 
    1937ae40:	48 83 7b 08 5f       	cmp    QWORD PTR [rbx+0x8],0x5f
    1937ae45:	0f 86 b2 5c 00 00    	jbe    19380afd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66dd>
    1937ae4b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ae4e:	c7 80 7c 01 00 00 02 	mov    DWORD PTR [rax+0x17c],0x2
    1937ae55:	00 00 00 
    1937ae58:	48 83 7b 08 60       	cmp    QWORD PTR [rbx+0x8],0x60
    1937ae5d:	0f 86 9c 5c 00 00    	jbe    19380aff <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66df>
    1937ae63:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ae66:	c7 80 80 01 00 00 02 	mov    DWORD PTR [rax+0x180],0x2
    1937ae6d:	00 00 00 
    1937ae70:	48 83 7b 08 61       	cmp    QWORD PTR [rbx+0x8],0x61
    1937ae75:	0f 86 86 5c 00 00    	jbe    19380b01 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66e1>
    1937ae7b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ae7e:	c7 80 84 01 00 00 02 	mov    DWORD PTR [rax+0x184],0x2
    1937ae85:	00 00 00 
    1937ae88:	48 83 7b 08 62       	cmp    QWORD PTR [rbx+0x8],0x62
    1937ae8d:	0f 86 70 5c 00 00    	jbe    19380b03 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66e3>
    1937ae93:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ae96:	c7 80 88 01 00 00 02 	mov    DWORD PTR [rax+0x188],0x2
    1937ae9d:	00 00 00 
    1937aea0:	48 83 7b 08 63       	cmp    QWORD PTR [rbx+0x8],0x63
    1937aea5:	0f 86 5a 5c 00 00    	jbe    19380b05 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66e5>
    1937aeab:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937aeae:	c7 80 8c 01 00 00 02 	mov    DWORD PTR [rax+0x18c],0x2
    1937aeb5:	00 00 00 
    1937aeb8:	48 83 7b 08 64       	cmp    QWORD PTR [rbx+0x8],0x64
    1937aebd:	0f 86 44 5c 00 00    	jbe    19380b07 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66e7>
    1937aec3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937aec6:	c7 80 90 01 00 00 02 	mov    DWORD PTR [rax+0x190],0x2
    1937aecd:	00 00 00 
    1937aed0:	48 83 7b 08 65       	cmp    QWORD PTR [rbx+0x8],0x65
    1937aed5:	0f 86 2e 5c 00 00    	jbe    19380b09 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66e9>
    1937aedb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937aede:	c7 80 94 01 00 00 02 	mov    DWORD PTR [rax+0x194],0x2
    1937aee5:	00 00 00 
    1937aee8:	48 83 7b 08 66       	cmp    QWORD PTR [rbx+0x8],0x66
    1937aeed:	0f 86 18 5c 00 00    	jbe    19380b0b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66eb>
    1937aef3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937aef6:	c7 80 98 01 00 00 02 	mov    DWORD PTR [rax+0x198],0x2
    1937aefd:	00 00 00 
    1937af00:	48 83 7b 08 67       	cmp    QWORD PTR [rbx+0x8],0x67
    1937af05:	0f 86 02 5c 00 00    	jbe    19380b0d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66ed>
    1937af0b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937af0e:	c7 80 9c 01 00 00 02 	mov    DWORD PTR [rax+0x19c],0x2
    1937af15:	00 00 00 
    1937af18:	48 83 7b 08 68       	cmp    QWORD PTR [rbx+0x8],0x68
    1937af1d:	0f 86 ec 5b 00 00    	jbe    19380b0f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66ef>
    1937af23:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937af26:	c7 80 a0 01 00 00 02 	mov    DWORD PTR [rax+0x1a0],0x2
    1937af2d:	00 00 00 
    1937af30:	48 83 7b 08 69       	cmp    QWORD PTR [rbx+0x8],0x69
    1937af35:	0f 86 d6 5b 00 00    	jbe    19380b11 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66f1>
    1937af3b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937af3e:	c7 80 a4 01 00 00 02 	mov    DWORD PTR [rax+0x1a4],0x2
    1937af45:	00 00 00 
    1937af48:	48 83 7b 08 6a       	cmp    QWORD PTR [rbx+0x8],0x6a
    1937af4d:	0f 86 c0 5b 00 00    	jbe    19380b13 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66f3>
    1937af53:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937af56:	c7 80 a8 01 00 00 02 	mov    DWORD PTR [rax+0x1a8],0x2
    1937af5d:	00 00 00 
    1937af60:	48 83 7b 08 6b       	cmp    QWORD PTR [rbx+0x8],0x6b
    1937af65:	0f 86 aa 5b 00 00    	jbe    19380b15 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66f5>
    1937af6b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937af6e:	c7 80 ac 01 00 00 02 	mov    DWORD PTR [rax+0x1ac],0x2
    1937af75:	00 00 00 
    1937af78:	48 83 7b 08 6c       	cmp    QWORD PTR [rbx+0x8],0x6c
    1937af7d:	0f 86 94 5b 00 00    	jbe    19380b17 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66f7>
    1937af83:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937af86:	c7 80 b0 01 00 00 02 	mov    DWORD PTR [rax+0x1b0],0x2
    1937af8d:	00 00 00 
    1937af90:	48 83 7b 08 6d       	cmp    QWORD PTR [rbx+0x8],0x6d
    1937af95:	0f 86 7e 5b 00 00    	jbe    19380b19 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66f9>
    1937af9b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937af9e:	c7 80 b4 01 00 00 02 	mov    DWORD PTR [rax+0x1b4],0x2
    1937afa5:	00 00 00 
    1937afa8:	48 83 7b 08 6e       	cmp    QWORD PTR [rbx+0x8],0x6e
    1937afad:	0f 86 68 5b 00 00    	jbe    19380b1b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66fb>
    1937afb3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937afb6:	c7 80 b8 01 00 00 02 	mov    DWORD PTR [rax+0x1b8],0x2
    1937afbd:	00 00 00 
    1937afc0:	48 83 7b 08 6f       	cmp    QWORD PTR [rbx+0x8],0x6f
    1937afc5:	0f 86 52 5b 00 00    	jbe    19380b1d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66fd>
    1937afcb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937afce:	c7 80 bc 01 00 00 02 	mov    DWORD PTR [rax+0x1bc],0x2
    1937afd5:	00 00 00 
    1937afd8:	48 83 7b 08 70       	cmp    QWORD PTR [rbx+0x8],0x70
    1937afdd:	0f 86 3c 5b 00 00    	jbe    19380b1f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x66ff>
    1937afe3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937afe6:	c7 80 c0 01 00 00 02 	mov    DWORD PTR [rax+0x1c0],0x2
    1937afed:	00 00 00 
    1937aff0:	48 83 7b 08 71       	cmp    QWORD PTR [rbx+0x8],0x71
    1937aff5:	0f 86 26 5b 00 00    	jbe    19380b21 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6701>
    1937affb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937affe:	c7 80 c4 01 00 00 02 	mov    DWORD PTR [rax+0x1c4],0x2
    1937b005:	00 00 00 
    1937b008:	48 83 7b 08 72       	cmp    QWORD PTR [rbx+0x8],0x72
    1937b00d:	0f 86 10 5b 00 00    	jbe    19380b23 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6703>
    1937b013:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b016:	c7 80 c8 01 00 00 02 	mov    DWORD PTR [rax+0x1c8],0x2
    1937b01d:	00 00 00 
    1937b020:	48 83 7b 08 73       	cmp    QWORD PTR [rbx+0x8],0x73
    1937b025:	0f 86 fa 5a 00 00    	jbe    19380b25 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6705>
    1937b02b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b02e:	c7 80 cc 01 00 00 02 	mov    DWORD PTR [rax+0x1cc],0x2
    1937b035:	00 00 00 
    1937b038:	48 83 7b 08 74       	cmp    QWORD PTR [rbx+0x8],0x74
    1937b03d:	0f 86 e4 5a 00 00    	jbe    19380b27 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6707>
    1937b043:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b046:	c7 80 d0 01 00 00 02 	mov    DWORD PTR [rax+0x1d0],0x2
    1937b04d:	00 00 00 
    1937b050:	48 83 7b 08 75       	cmp    QWORD PTR [rbx+0x8],0x75
    1937b055:	0f 86 ce 5a 00 00    	jbe    19380b29 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6709>
    1937b05b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b05e:	c7 80 d4 01 00 00 02 	mov    DWORD PTR [rax+0x1d4],0x2
    1937b065:	00 00 00 
    1937b068:	48 83 7b 08 76       	cmp    QWORD PTR [rbx+0x8],0x76
    1937b06d:	0f 86 b8 5a 00 00    	jbe    19380b2b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x670b>
    1937b073:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b076:	c7 80 d8 01 00 00 02 	mov    DWORD PTR [rax+0x1d8],0x2
    1937b07d:	00 00 00 
    1937b080:	48 83 7b 08 77       	cmp    QWORD PTR [rbx+0x8],0x77
    1937b085:	0f 86 a2 5a 00 00    	jbe    19380b2d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x670d>
    1937b08b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b08e:	c7 80 dc 01 00 00 02 	mov    DWORD PTR [rax+0x1dc],0x2
    1937b095:	00 00 00 
    1937b098:	48 83 7b 08 78       	cmp    QWORD PTR [rbx+0x8],0x78
    1937b09d:	0f 86 8c 5a 00 00    	jbe    19380b2f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x670f>
    1937b0a3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b0a6:	c7 80 e0 01 00 00 02 	mov    DWORD PTR [rax+0x1e0],0x2
    1937b0ad:	00 00 00 
    1937b0b0:	48 83 7b 20 78       	cmp    QWORD PTR [rbx+0x20],0x78
    1937b0b5:	0f 86 76 5a 00 00    	jbe    19380b31 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6711>
    1937b0bb:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937b0bf:	48 83 b8 48 0b 00 00 	cmp    QWORD PTR [rax+0xb48],0x2
    1937b0c6:	02 
    1937b0c7:	0f 86 66 5a 00 00    	jbe    19380b33 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6713>
    1937b0cd:	48 8b 80 40 0b 00 00 	mov    rax,QWORD PTR [rax+0xb40]
    1937b0d4:	c7 40 08 01 00 00 00 	mov    DWORD PTR [rax+0x8],0x1
    1937b0db:	48 83 39 79          	cmp    QWORD PTR [rcx],0x79
    1937b0df:	0f 86 50 5a 00 00    	jbe    19380b35 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6715>
    1937b0e5:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b0e8:	c7 80 e4 01 00 00 02 	mov    DWORD PTR [rax+0x1e4],0x2
    1937b0ef:	00 00 00 
    1937b0f2:	48 83 7b 20 79       	cmp    QWORD PTR [rbx+0x20],0x79
    1937b0f7:	0f 86 3a 5a 00 00    	jbe    19380b37 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6717>
    1937b0fd:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937b101:	48 83 b8 60 0b 00 00 	cmp    QWORD PTR [rax+0xb60],0x2
    1937b108:	02 
    1937b109:	0f 86 2a 5a 00 00    	jbe    19380b39 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6719>
    1937b10f:	48 8b 80 58 0b 00 00 	mov    rax,QWORD PTR [rax+0xb58]
    1937b116:	c7 40 08 01 00 00 00 	mov    DWORD PTR [rax+0x8],0x1
    1937b11d:	48 83 39 7a          	cmp    QWORD PTR [rcx],0x7a
    1937b121:	0f 86 14 5a 00 00    	jbe    19380b3b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x671b>
    1937b127:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b12a:	c7 80 e8 01 00 00 02 	mov    DWORD PTR [rax+0x1e8],0x2
    1937b131:	00 00 00 
    1937b134:	48 83 7b 20 7a       	cmp    QWORD PTR [rbx+0x20],0x7a
    1937b139:	0f 86 fe 59 00 00    	jbe    19380b3d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x671d>
    1937b13f:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937b143:	48 83 b8 78 0b 00 00 	cmp    QWORD PTR [rax+0xb78],0x2
    1937b14a:	02 
    1937b14b:	0f 86 ee 59 00 00    	jbe    19380b3f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x671f>
    1937b151:	48 8b 80 70 0b 00 00 	mov    rax,QWORD PTR [rax+0xb70]
    1937b158:	c7 40 08 01 00 00 00 	mov    DWORD PTR [rax+0x8],0x1
    1937b15f:	48 83 39 7b          	cmp    QWORD PTR [rcx],0x7b
    1937b163:	0f 86 d8 59 00 00    	jbe    19380b41 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6721>
    1937b169:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b16c:	c7 80 ec 01 00 00 02 	mov    DWORD PTR [rax+0x1ec],0x2
    1937b173:	00 00 00 
    1937b176:	48 83 7b 20 7b       	cmp    QWORD PTR [rbx+0x20],0x7b
    1937b17b:	0f 86 c2 59 00 00    	jbe    19380b43 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6723>
    1937b181:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937b185:	48 83 b8 90 0b 00 00 	cmp    QWORD PTR [rax+0xb90],0x2
    1937b18c:	02 
    1937b18d:	0f 86 b2 59 00 00    	jbe    19380b45 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6725>
    1937b193:	48 8b 80 88 0b 00 00 	mov    rax,QWORD PTR [rax+0xb88]
    1937b19a:	c7 40 08 01 00 00 00 	mov    DWORD PTR [rax+0x8],0x1
    1937b1a1:	48 83 39 7c          	cmp    QWORD PTR [rcx],0x7c
    1937b1a5:	0f 86 9c 59 00 00    	jbe    19380b47 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6727>
    1937b1ab:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b1ae:	c7 80 f0 01 00 00 01 	mov    DWORD PTR [rax+0x1f0],0x1
    1937b1b5:	00 00 00 
    1937b1b8:	48 83 7b 08 7d       	cmp    QWORD PTR [rbx+0x8],0x7d
    1937b1bd:	0f 86 86 59 00 00    	jbe    19380b49 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6729>
    1937b1c3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b1c6:	c7 80 f4 01 00 00 02 	mov    DWORD PTR [rax+0x1f4],0x2
    1937b1cd:	00 00 00 
    1937b1d0:	48 83 7b 20 7d       	cmp    QWORD PTR [rbx+0x20],0x7d
    1937b1d5:	0f 86 70 59 00 00    	jbe    19380b4b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x672b>
    1937b1db:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937b1df:	48 83 b8 c0 0b 00 00 	cmp    QWORD PTR [rax+0xbc0],0x2
    1937b1e6:	02 
    1937b1e7:	0f 86 60 59 00 00    	jbe    19380b4d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x672d>
    1937b1ed:	48 8b 80 b8 0b 00 00 	mov    rax,QWORD PTR [rax+0xbb8]
    1937b1f4:	c7 40 08 02 00 00 00 	mov    DWORD PTR [rax+0x8],0x2
    1937b1fb:	48 83 39 7e          	cmp    QWORD PTR [rcx],0x7e
    1937b1ff:	0f 86 4a 59 00 00    	jbe    19380b4f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x672f>
    1937b205:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b208:	c7 80 f8 01 00 00 02 	mov    DWORD PTR [rax+0x1f8],0x2
    1937b20f:	00 00 00 
    1937b212:	48 83 7b 20 7e       	cmp    QWORD PTR [rbx+0x20],0x7e
    1937b217:	0f 86 34 59 00 00    	jbe    19380b51 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6731>
    1937b21d:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937b221:	48 83 b8 d8 0b 00 00 	cmp    QWORD PTR [rax+0xbd8],0x2
    1937b228:	02 
    1937b229:	0f 86 24 59 00 00    	jbe    19380b53 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6733>
    1937b22f:	48 8b 80 d0 0b 00 00 	mov    rax,QWORD PTR [rax+0xbd0]
    1937b236:	c7 40 08 02 00 00 00 	mov    DWORD PTR [rax+0x8],0x2
    1937b23d:	48 83 39 7f          	cmp    QWORD PTR [rcx],0x7f
    1937b241:	0f 86 0e 59 00 00    	jbe    19380b55 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6735>
    1937b247:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b24a:	c7 80 fc 01 00 00 02 	mov    DWORD PTR [rax+0x1fc],0x2
    1937b251:	00 00 00 
    1937b254:	48 83 7b 20 7f       	cmp    QWORD PTR [rbx+0x20],0x7f
    1937b259:	0f 86 f8 58 00 00    	jbe    19380b57 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6737>
    1937b25f:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937b263:	48 83 b8 f0 0b 00 00 	cmp    QWORD PTR [rax+0xbf0],0x2
    1937b26a:	02 
    1937b26b:	0f 86 e8 58 00 00    	jbe    19380b59 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6739>
    1937b271:	48 8b 80 e8 0b 00 00 	mov    rax,QWORD PTR [rax+0xbe8]
    1937b278:	c7 40 08 02 00 00 00 	mov    DWORD PTR [rax+0x8],0x2
    1937b27f:	48 81 39 80 00 00 00 	cmp    QWORD PTR [rcx],0x80
    1937b286:	0f 86 cf 58 00 00    	jbe    19380b5b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x673b>
    1937b28c:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b28f:	c7 80 00 02 00 00 01 	mov    DWORD PTR [rax+0x200],0x1
    1937b296:	00 00 00 
    1937b299:	48 81 7b 08 81 00 00 	cmp    QWORD PTR [rbx+0x8],0x81
    1937b2a0:	00 
    1937b2a1:	0f 86 b6 58 00 00    	jbe    19380b5d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x673d>
    1937b2a7:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b2aa:	c7 80 04 02 00 00 01 	mov    DWORD PTR [rax+0x204],0x1
    1937b2b1:	00 00 00 
    1937b2b4:	48 81 7b 08 82 00 00 	cmp    QWORD PTR [rbx+0x8],0x82
    1937b2bb:	00 
    1937b2bc:	0f 86 9d 58 00 00    	jbe    19380b5f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x673f>
    1937b2c2:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b2c5:	c7 80 08 02 00 00 02 	mov    DWORD PTR [rax+0x208],0x2
    1937b2cc:	00 00 00 
    1937b2cf:	48 81 7b 08 83 00 00 	cmp    QWORD PTR [rbx+0x8],0x83
    1937b2d6:	00 
    1937b2d7:	0f 86 84 58 00 00    	jbe    19380b61 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6741>
    1937b2dd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b2e0:	c7 80 0c 02 00 00 02 	mov    DWORD PTR [rax+0x20c],0x2
    1937b2e7:	00 00 00 
    1937b2ea:	48 81 7b 08 84 00 00 	cmp    QWORD PTR [rbx+0x8],0x84
    1937b2f1:	00 
    1937b2f2:	0f 86 6b 58 00 00    	jbe    19380b63 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6743>
    1937b2f8:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b2fb:	c7 80 10 02 00 00 02 	mov    DWORD PTR [rax+0x210],0x2
    1937b302:	00 00 00 
    1937b305:	48 81 7b 08 85 00 00 	cmp    QWORD PTR [rbx+0x8],0x85
    1937b30c:	00 
    1937b30d:	0f 86 52 58 00 00    	jbe    19380b65 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6745>
    1937b313:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b316:	c7 80 14 02 00 00 02 	mov    DWORD PTR [rax+0x214],0x2
    1937b31d:	00 00 00 
    1937b320:	48 81 7b 08 86 00 00 	cmp    QWORD PTR [rbx+0x8],0x86
    1937b327:	00 
    1937b328:	0f 86 39 58 00 00    	jbe    19380b67 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6747>
    1937b32e:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b331:	c7 80 18 02 00 00 02 	mov    DWORD PTR [rax+0x218],0x2
    1937b338:	00 00 00 
    1937b33b:	48 81 7b 08 87 00 00 	cmp    QWORD PTR [rbx+0x8],0x87
    1937b342:	00 
    1937b343:	0f 86 20 58 00 00    	jbe    19380b69 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6749>
    1937b349:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b34c:	c7 80 1c 02 00 00 02 	mov    DWORD PTR [rax+0x21c],0x2
    1937b353:	00 00 00 
    1937b356:	48 81 7b 08 88 00 00 	cmp    QWORD PTR [rbx+0x8],0x88
    1937b35d:	00 
    1937b35e:	0f 86 07 58 00 00    	jbe    19380b6b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x674b>
    1937b364:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b367:	c7 80 20 02 00 00 02 	mov    DWORD PTR [rax+0x220],0x2
    1937b36e:	00 00 00 
    1937b371:	48 81 7b 08 89 00 00 	cmp    QWORD PTR [rbx+0x8],0x89
    1937b378:	00 
    1937b379:	0f 86 ee 57 00 00    	jbe    19380b6d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x674d>
    1937b37f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b382:	c7 80 24 02 00 00 02 	mov    DWORD PTR [rax+0x224],0x2
    1937b389:	00 00 00 
    1937b38c:	48 81 7b 08 8a 00 00 	cmp    QWORD PTR [rbx+0x8],0x8a
    1937b393:	00 
    1937b394:	0f 86 d5 57 00 00    	jbe    19380b6f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x674f>
    1937b39a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b39d:	c7 80 28 02 00 00 02 	mov    DWORD PTR [rax+0x228],0x2
    1937b3a4:	00 00 00 
    1937b3a7:	48 81 7b 08 8b 00 00 	cmp    QWORD PTR [rbx+0x8],0x8b
    1937b3ae:	00 
    1937b3af:	0f 86 bc 57 00 00    	jbe    19380b71 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6751>
    1937b3b5:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b3b8:	c7 80 2c 02 00 00 02 	mov    DWORD PTR [rax+0x22c],0x2
    1937b3bf:	00 00 00 
    1937b3c2:	48 81 7b 08 8c 00 00 	cmp    QWORD PTR [rbx+0x8],0x8c
    1937b3c9:	00 
    1937b3ca:	0f 86 a3 57 00 00    	jbe    19380b73 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6753>
    1937b3d0:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b3d3:	c7 80 30 02 00 00 02 	mov    DWORD PTR [rax+0x230],0x2
    1937b3da:	00 00 00 
    1937b3dd:	48 81 7b 08 8d 00 00 	cmp    QWORD PTR [rbx+0x8],0x8d
    1937b3e4:	00 
    1937b3e5:	0f 86 8a 57 00 00    	jbe    19380b75 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6755>
    1937b3eb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b3ee:	c7 80 34 02 00 00 02 	mov    DWORD PTR [rax+0x234],0x2
    1937b3f5:	00 00 00 
    1937b3f8:	48 81 7b 08 8e 00 00 	cmp    QWORD PTR [rbx+0x8],0x8e
    1937b3ff:	00 
    1937b400:	0f 86 71 57 00 00    	jbe    19380b77 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6757>
    1937b406:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b409:	c7 80 38 02 00 00 02 	mov    DWORD PTR [rax+0x238],0x2
    1937b410:	00 00 00 
    1937b413:	48 81 7b 08 8f 00 00 	cmp    QWORD PTR [rbx+0x8],0x8f
    1937b41a:	00 
    1937b41b:	0f 86 58 57 00 00    	jbe    19380b79 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6759>
    1937b421:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b424:	c7 80 3c 02 00 00 02 	mov    DWORD PTR [rax+0x23c],0x2
    1937b42b:	00 00 00 
    1937b42e:	48 81 7b 08 90 00 00 	cmp    QWORD PTR [rbx+0x8],0x90
    1937b435:	00 
    1937b436:	0f 86 3f 57 00 00    	jbe    19380b7b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x675b>
    1937b43c:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b43f:	c7 80 40 02 00 00 02 	mov    DWORD PTR [rax+0x240],0x2
    1937b446:	00 00 00 
    1937b449:	48 81 7b 08 91 00 00 	cmp    QWORD PTR [rbx+0x8],0x91
    1937b450:	00 
    1937b451:	0f 86 26 57 00 00    	jbe    19380b7d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x675d>
    1937b457:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b45a:	c7 80 44 02 00 00 02 	mov    DWORD PTR [rax+0x244],0x2
    1937b461:	00 00 00 
    1937b464:	48 81 7b 08 92 00 00 	cmp    QWORD PTR [rbx+0x8],0x92
    1937b46b:	00 
    1937b46c:	0f 86 0d 57 00 00    	jbe    19380b7f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x675f>
    1937b472:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b475:	c7 80 48 02 00 00 02 	mov    DWORD PTR [rax+0x248],0x2
    1937b47c:	00 00 00 
    1937b47f:	48 81 7b 08 93 00 00 	cmp    QWORD PTR [rbx+0x8],0x93
    1937b486:	00 
    1937b487:	0f 86 f4 56 00 00    	jbe    19380b81 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6761>
    1937b48d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b490:	c7 80 4c 02 00 00 02 	mov    DWORD PTR [rax+0x24c],0x2
    1937b497:	00 00 00 
    1937b49a:	48 81 7b 08 94 00 00 	cmp    QWORD PTR [rbx+0x8],0x94
    1937b4a1:	00 
    1937b4a2:	0f 86 db 56 00 00    	jbe    19380b83 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6763>
    1937b4a8:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b4ab:	c7 80 50 02 00 00 02 	mov    DWORD PTR [rax+0x250],0x2
    1937b4b2:	00 00 00 
    1937b4b5:	48 81 7b 08 95 00 00 	cmp    QWORD PTR [rbx+0x8],0x95
    1937b4bc:	00 
    1937b4bd:	0f 86 c2 56 00 00    	jbe    19380b85 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6765>
    1937b4c3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b4c6:	c7 80 54 02 00 00 02 	mov    DWORD PTR [rax+0x254],0x2
    1937b4cd:	00 00 00 
    1937b4d0:	48 81 7b 08 96 00 00 	cmp    QWORD PTR [rbx+0x8],0x96
    1937b4d7:	00 
    1937b4d8:	0f 86 a9 56 00 00    	jbe    19380b87 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6767>
    1937b4de:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b4e1:	c7 80 58 02 00 00 02 	mov    DWORD PTR [rax+0x258],0x2
    1937b4e8:	00 00 00 
    1937b4eb:	48 81 7b 08 97 00 00 	cmp    QWORD PTR [rbx+0x8],0x97
    1937b4f2:	00 
    1937b4f3:	0f 86 90 56 00 00    	jbe    19380b89 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6769>
    1937b4f9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b4fc:	c7 80 5c 02 00 00 02 	mov    DWORD PTR [rax+0x25c],0x2
    1937b503:	00 00 00 
    1937b506:	48 81 7b 08 98 00 00 	cmp    QWORD PTR [rbx+0x8],0x98
    1937b50d:	00 
    1937b50e:	0f 86 77 56 00 00    	jbe    19380b8b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x676b>
    1937b514:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b517:	c7 80 60 02 00 00 02 	mov    DWORD PTR [rax+0x260],0x2
    1937b51e:	00 00 00 
    1937b521:	48 81 7b 08 99 00 00 	cmp    QWORD PTR [rbx+0x8],0x99
    1937b528:	00 
    1937b529:	0f 86 5e 56 00 00    	jbe    19380b8d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x676d>
    1937b52f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b532:	c7 80 64 02 00 00 02 	mov    DWORD PTR [rax+0x264],0x2
    1937b539:	00 00 00 
    1937b53c:	48 81 7b 08 9a 00 00 	cmp    QWORD PTR [rbx+0x8],0x9a
    1937b543:	00 
    1937b544:	0f 86 45 56 00 00    	jbe    19380b8f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x676f>
    1937b54a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b54d:	c7 80 68 02 00 00 02 	mov    DWORD PTR [rax+0x268],0x2
    1937b554:	00 00 00 
    1937b557:	48 81 7b 08 9b 00 00 	cmp    QWORD PTR [rbx+0x8],0x9b
    1937b55e:	00 
    1937b55f:	0f 86 2c 56 00 00    	jbe    19380b91 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6771>
    1937b565:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b568:	c7 80 6c 02 00 00 02 	mov    DWORD PTR [rax+0x26c],0x2
    1937b56f:	00 00 00 
    1937b572:	48 81 7b 08 9c 00 00 	cmp    QWORD PTR [rbx+0x8],0x9c
    1937b579:	00 
    1937b57a:	0f 86 13 56 00 00    	jbe    19380b93 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6773>
    1937b580:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b583:	c7 80 70 02 00 00 02 	mov    DWORD PTR [rax+0x270],0x2
    1937b58a:	00 00 00 
    1937b58d:	48 81 7b 08 9d 00 00 	cmp    QWORD PTR [rbx+0x8],0x9d
    1937b594:	00 
    1937b595:	0f 86 fa 55 00 00    	jbe    19380b95 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6775>
    1937b59b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b59e:	c7 80 74 02 00 00 02 	mov    DWORD PTR [rax+0x274],0x2
    1937b5a5:	00 00 00 
    1937b5a8:	48 81 7b 08 9e 00 00 	cmp    QWORD PTR [rbx+0x8],0x9e
    1937b5af:	00 
    1937b5b0:	0f 86 e1 55 00 00    	jbe    19380b97 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6777>
    1937b5b6:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b5b9:	c7 80 78 02 00 00 02 	mov    DWORD PTR [rax+0x278],0x2
    1937b5c0:	00 00 00 
    1937b5c3:	48 81 7b 08 9f 00 00 	cmp    QWORD PTR [rbx+0x8],0x9f
    1937b5ca:	00 
    1937b5cb:	0f 86 c8 55 00 00    	jbe    19380b99 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6779>
    1937b5d1:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b5d4:	c7 80 7c 02 00 00 02 	mov    DWORD PTR [rax+0x27c],0x2
    1937b5db:	00 00 00 
    1937b5de:	48 81 7b 08 a0 00 00 	cmp    QWORD PTR [rbx+0x8],0xa0
    1937b5e5:	00 
    1937b5e6:	0f 86 af 55 00 00    	jbe    19380b9b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x677b>
    1937b5ec:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b5ef:	c7 80 80 02 00 00 02 	mov    DWORD PTR [rax+0x280],0x2
    1937b5f6:	00 00 00 
    1937b5f9:	48 81 7b 08 a1 00 00 	cmp    QWORD PTR [rbx+0x8],0xa1
    1937b600:	00 
    1937b601:	0f 86 96 55 00 00    	jbe    19380b9d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x677d>
    1937b607:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b60a:	c7 80 84 02 00 00 02 	mov    DWORD PTR [rax+0x284],0x2
    1937b611:	00 00 00 
    1937b614:	48 81 7b 08 a2 00 00 	cmp    QWORD PTR [rbx+0x8],0xa2
    1937b61b:	00 
    1937b61c:	0f 86 7d 55 00 00    	jbe    19380b9f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x677f>
    1937b622:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b625:	c7 80 88 02 00 00 02 	mov    DWORD PTR [rax+0x288],0x2
    1937b62c:	00 00 00 
    1937b62f:	48 81 7b 08 a3 00 00 	cmp    QWORD PTR [rbx+0x8],0xa3
    1937b636:	00 
    1937b637:	0f 86 64 55 00 00    	jbe    19380ba1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6781>
    1937b63d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b640:	c7 80 8c 02 00 00 02 	mov    DWORD PTR [rax+0x28c],0x2
    1937b647:	00 00 00 
    1937b64a:	48 81 7b 08 a4 00 00 	cmp    QWORD PTR [rbx+0x8],0xa4
    1937b651:	00 
    1937b652:	0f 86 4b 55 00 00    	jbe    19380ba3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6783>
    1937b658:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b65b:	c7 80 90 02 00 00 02 	mov    DWORD PTR [rax+0x290],0x2
    1937b662:	00 00 00 
    1937b665:	48 81 7b 08 a5 00 00 	cmp    QWORD PTR [rbx+0x8],0xa5
    1937b66c:	00 
    1937b66d:	0f 86 32 55 00 00    	jbe    19380ba5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6785>
    1937b673:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b676:	c7 80 94 02 00 00 02 	mov    DWORD PTR [rax+0x294],0x2
    1937b67d:	00 00 00 
    1937b680:	48 81 7b 08 a6 00 00 	cmp    QWORD PTR [rbx+0x8],0xa6
    1937b687:	00 
    1937b688:	0f 86 19 55 00 00    	jbe    19380ba7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6787>
    1937b68e:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b691:	c7 80 98 02 00 00 02 	mov    DWORD PTR [rax+0x298],0x2
    1937b698:	00 00 00 
    1937b69b:	48 81 7b 08 a7 00 00 	cmp    QWORD PTR [rbx+0x8],0xa7
    1937b6a2:	00 
    1937b6a3:	0f 86 00 55 00 00    	jbe    19380ba9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6789>
    1937b6a9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b6ac:	c7 80 9c 02 00 00 02 	mov    DWORD PTR [rax+0x29c],0x2
    1937b6b3:	00 00 00 
    1937b6b6:	48 81 7b 08 a8 00 00 	cmp    QWORD PTR [rbx+0x8],0xa8
    1937b6bd:	00 
    1937b6be:	0f 86 e7 54 00 00    	jbe    19380bab <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x678b>
    1937b6c4:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b6c7:	c7 80 a0 02 00 00 02 	mov    DWORD PTR [rax+0x2a0],0x2
    1937b6ce:	00 00 00 
    1937b6d1:	48 81 7b 08 a9 00 00 	cmp    QWORD PTR [rbx+0x8],0xa9
    1937b6d8:	00 
    1937b6d9:	0f 86 ce 54 00 00    	jbe    19380bad <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x678d>
    1937b6df:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b6e2:	c7 80 a4 02 00 00 02 	mov    DWORD PTR [rax+0x2a4],0x2
    1937b6e9:	00 00 00 
    1937b6ec:	48 81 7b 08 aa 00 00 	cmp    QWORD PTR [rbx+0x8],0xaa
    1937b6f3:	00 
    1937b6f4:	0f 86 b5 54 00 00    	jbe    19380baf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x678f>
    1937b6fa:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b6fd:	c7 80 a8 02 00 00 02 	mov    DWORD PTR [rax+0x2a8],0x2
    1937b704:	00 00 00 
    1937b707:	48 81 7b 08 ab 00 00 	cmp    QWORD PTR [rbx+0x8],0xab
    1937b70e:	00 
    1937b70f:	0f 86 9c 54 00 00    	jbe    19380bb1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6791>
    1937b715:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b718:	c7 80 ac 02 00 00 02 	mov    DWORD PTR [rax+0x2ac],0x2
    1937b71f:	00 00 00 
    1937b722:	48 81 7b 08 ac 00 00 	cmp    QWORD PTR [rbx+0x8],0xac
    1937b729:	00 
    1937b72a:	0f 86 83 54 00 00    	jbe    19380bb3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6793>
    1937b730:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b733:	c7 80 b0 02 00 00 02 	mov    DWORD PTR [rax+0x2b0],0x2
    1937b73a:	00 00 00 
    1937b73d:	48 81 7b 08 ad 00 00 	cmp    QWORD PTR [rbx+0x8],0xad
    1937b744:	00 
    1937b745:	0f 86 6a 54 00 00    	jbe    19380bb5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6795>
    1937b74b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b74e:	c7 80 b4 02 00 00 02 	mov    DWORD PTR [rax+0x2b4],0x2
    1937b755:	00 00 00 
    1937b758:	48 81 7b 08 ae 00 00 	cmp    QWORD PTR [rbx+0x8],0xae
    1937b75f:	00 
    1937b760:	0f 86 51 54 00 00    	jbe    19380bb7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6797>
    1937b766:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b769:	c7 80 b8 02 00 00 02 	mov    DWORD PTR [rax+0x2b8],0x2
    1937b770:	00 00 00 
    1937b773:	48 81 7b 08 af 00 00 	cmp    QWORD PTR [rbx+0x8],0xaf
    1937b77a:	00 
    1937b77b:	0f 86 38 54 00 00    	jbe    19380bb9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6799>
    1937b781:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b784:	c7 80 bc 02 00 00 02 	mov    DWORD PTR [rax+0x2bc],0x2
    1937b78b:	00 00 00 
    1937b78e:	48 81 7b 08 b0 00 00 	cmp    QWORD PTR [rbx+0x8],0xb0
    1937b795:	00 
    1937b796:	0f 86 1f 54 00 00    	jbe    19380bbb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x679b>
    1937b79c:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b79f:	c7 80 c0 02 00 00 02 	mov    DWORD PTR [rax+0x2c0],0x2
    1937b7a6:	00 00 00 
    1937b7a9:	48 81 7b 08 b1 00 00 	cmp    QWORD PTR [rbx+0x8],0xb1
    1937b7b0:	00 
    1937b7b1:	0f 86 06 54 00 00    	jbe    19380bbd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x679d>
    1937b7b7:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b7ba:	c7 80 c4 02 00 00 02 	mov    DWORD PTR [rax+0x2c4],0x2
    1937b7c1:	00 00 00 
    1937b7c4:	48 81 7b 08 b2 00 00 	cmp    QWORD PTR [rbx+0x8],0xb2
    1937b7cb:	00 
    1937b7cc:	0f 86 ed 53 00 00    	jbe    19380bbf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x679f>
    1937b7d2:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b7d5:	c7 80 c8 02 00 00 02 	mov    DWORD PTR [rax+0x2c8],0x2
    1937b7dc:	00 00 00 
    1937b7df:	48 81 7b 08 b3 00 00 	cmp    QWORD PTR [rbx+0x8],0xb3
    1937b7e6:	00 
    1937b7e7:	0f 86 d4 53 00 00    	jbe    19380bc1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67a1>
    1937b7ed:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b7f0:	c7 80 cc 02 00 00 02 	mov    DWORD PTR [rax+0x2cc],0x2
    1937b7f7:	00 00 00 
    1937b7fa:	48 81 7b 08 b4 00 00 	cmp    QWORD PTR [rbx+0x8],0xb4
    1937b801:	00 
    1937b802:	0f 86 bb 53 00 00    	jbe    19380bc3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67a3>
    1937b808:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b80b:	c7 80 d0 02 00 00 02 	mov    DWORD PTR [rax+0x2d0],0x2
    1937b812:	00 00 00 
    1937b815:	48 81 7b 08 b5 00 00 	cmp    QWORD PTR [rbx+0x8],0xb5
    1937b81c:	00 
    1937b81d:	0f 86 a2 53 00 00    	jbe    19380bc5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67a5>
    1937b823:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b826:	c7 80 d4 02 00 00 02 	mov    DWORD PTR [rax+0x2d4],0x2
    1937b82d:	00 00 00 
    1937b830:	48 81 7b 08 b6 00 00 	cmp    QWORD PTR [rbx+0x8],0xb6
    1937b837:	00 
    1937b838:	0f 86 89 53 00 00    	jbe    19380bc7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67a7>
    1937b83e:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b841:	c7 80 d8 02 00 00 02 	mov    DWORD PTR [rax+0x2d8],0x2
    1937b848:	00 00 00 
    1937b84b:	48 81 7b 08 b7 00 00 	cmp    QWORD PTR [rbx+0x8],0xb7
    1937b852:	00 
    1937b853:	0f 86 70 53 00 00    	jbe    19380bc9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67a9>
    1937b859:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b85c:	c7 80 dc 02 00 00 02 	mov    DWORD PTR [rax+0x2dc],0x2
    1937b863:	00 00 00 
    1937b866:	48 81 7b 08 b8 00 00 	cmp    QWORD PTR [rbx+0x8],0xb8
    1937b86d:	00 
    1937b86e:	0f 86 57 53 00 00    	jbe    19380bcb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67ab>
    1937b874:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b877:	c7 80 e0 02 00 00 02 	mov    DWORD PTR [rax+0x2e0],0x2
    1937b87e:	00 00 00 
    1937b881:	48 81 7b 08 b9 00 00 	cmp    QWORD PTR [rbx+0x8],0xb9
    1937b888:	00 
    1937b889:	0f 86 3e 53 00 00    	jbe    19380bcd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67ad>
    1937b88f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b892:	c7 80 e4 02 00 00 02 	mov    DWORD PTR [rax+0x2e4],0x2
    1937b899:	00 00 00 
    1937b89c:	48 81 7b 08 ba 00 00 	cmp    QWORD PTR [rbx+0x8],0xba
    1937b8a3:	00 
    1937b8a4:	0f 86 25 53 00 00    	jbe    19380bcf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67af>
    1937b8aa:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b8ad:	c7 80 e8 02 00 00 02 	mov    DWORD PTR [rax+0x2e8],0x2
    1937b8b4:	00 00 00 
    1937b8b7:	48 81 7b 08 bb 00 00 	cmp    QWORD PTR [rbx+0x8],0xbb
    1937b8be:	00 
    1937b8bf:	0f 86 0c 53 00 00    	jbe    19380bd1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67b1>
    1937b8c5:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b8c8:	c7 80 ec 02 00 00 02 	mov    DWORD PTR [rax+0x2ec],0x2
    1937b8cf:	00 00 00 
    1937b8d2:	48 81 7b 08 bc 00 00 	cmp    QWORD PTR [rbx+0x8],0xbc
    1937b8d9:	00 
    1937b8da:	0f 86 f3 52 00 00    	jbe    19380bd3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67b3>
    1937b8e0:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b8e3:	c7 80 f0 02 00 00 02 	mov    DWORD PTR [rax+0x2f0],0x2
    1937b8ea:	00 00 00 
    1937b8ed:	48 81 7b 08 bd 00 00 	cmp    QWORD PTR [rbx+0x8],0xbd
    1937b8f4:	00 
    1937b8f5:	0f 86 da 52 00 00    	jbe    19380bd5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67b5>
    1937b8fb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b8fe:	c7 80 f4 02 00 00 02 	mov    DWORD PTR [rax+0x2f4],0x2
    1937b905:	00 00 00 
    1937b908:	48 81 7b 08 be 00 00 	cmp    QWORD PTR [rbx+0x8],0xbe
    1937b90f:	00 
    1937b910:	0f 86 c1 52 00 00    	jbe    19380bd7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67b7>
    1937b916:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b919:	c7 80 f8 02 00 00 02 	mov    DWORD PTR [rax+0x2f8],0x2
    1937b920:	00 00 00 
    1937b923:	48 81 7b 08 bf 00 00 	cmp    QWORD PTR [rbx+0x8],0xbf
    1937b92a:	00 
    1937b92b:	0f 86 a8 52 00 00    	jbe    19380bd9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67b9>
    1937b931:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b934:	c7 80 fc 02 00 00 02 	mov    DWORD PTR [rax+0x2fc],0x2
    1937b93b:	00 00 00 
    1937b93e:	48 81 7b 08 c0 00 00 	cmp    QWORD PTR [rbx+0x8],0xc0
    1937b945:	00 
    1937b946:	0f 86 8f 52 00 00    	jbe    19380bdb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67bb>
    1937b94c:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b94f:	c7 80 00 03 00 00 02 	mov    DWORD PTR [rax+0x300],0x2
    1937b956:	00 00 00 
    1937b959:	48 81 7b 08 c1 00 00 	cmp    QWORD PTR [rbx+0x8],0xc1
    1937b960:	00 
    1937b961:	0f 86 76 52 00 00    	jbe    19380bdd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67bd>
    1937b967:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b96a:	c7 80 04 03 00 00 02 	mov    DWORD PTR [rax+0x304],0x2
    1937b971:	00 00 00 
    1937b974:	48 81 7b 08 c2 00 00 	cmp    QWORD PTR [rbx+0x8],0xc2
    1937b97b:	00 
    1937b97c:	0f 86 5d 52 00 00    	jbe    19380bdf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67bf>
    1937b982:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b985:	c7 80 08 03 00 00 02 	mov    DWORD PTR [rax+0x308],0x2
    1937b98c:	00 00 00 
    1937b98f:	48 81 7b 08 c3 00 00 	cmp    QWORD PTR [rbx+0x8],0xc3
    1937b996:	00 
    1937b997:	0f 86 44 52 00 00    	jbe    19380be1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67c1>
    1937b99d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b9a0:	c7 80 0c 03 00 00 02 	mov    DWORD PTR [rax+0x30c],0x2
    1937b9a7:	00 00 00 
    1937b9aa:	48 81 7b 08 c4 00 00 	cmp    QWORD PTR [rbx+0x8],0xc4
    1937b9b1:	00 
    1937b9b2:	0f 86 2b 52 00 00    	jbe    19380be3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67c3>
    1937b9b8:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b9bb:	c7 80 10 03 00 00 02 	mov    DWORD PTR [rax+0x310],0x2
    1937b9c2:	00 00 00 
    1937b9c5:	48 81 7b 08 c5 00 00 	cmp    QWORD PTR [rbx+0x8],0xc5
    1937b9cc:	00 
    1937b9cd:	0f 86 12 52 00 00    	jbe    19380be5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67c5>
    1937b9d3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b9d6:	c7 80 14 03 00 00 02 	mov    DWORD PTR [rax+0x314],0x2
    1937b9dd:	00 00 00 
    1937b9e0:	48 81 7b 08 c6 00 00 	cmp    QWORD PTR [rbx+0x8],0xc6
    1937b9e7:	00 
    1937b9e8:	0f 86 f9 51 00 00    	jbe    19380be7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67c7>
    1937b9ee:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937b9f1:	c7 80 18 03 00 00 02 	mov    DWORD PTR [rax+0x318],0x2
    1937b9f8:	00 00 00 
    1937b9fb:	48 81 7b 08 c7 00 00 	cmp    QWORD PTR [rbx+0x8],0xc7
    1937ba02:	00 
    1937ba03:	0f 86 e0 51 00 00    	jbe    19380be9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67c9>
    1937ba09:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ba0c:	c7 80 1c 03 00 00 02 	mov    DWORD PTR [rax+0x31c],0x2
    1937ba13:	00 00 00 
    1937ba16:	48 81 7b 08 c8 00 00 	cmp    QWORD PTR [rbx+0x8],0xc8
    1937ba1d:	00 
    1937ba1e:	0f 86 c7 51 00 00    	jbe    19380beb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67cb>
    1937ba24:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ba27:	c7 80 20 03 00 00 02 	mov    DWORD PTR [rax+0x320],0x2
    1937ba2e:	00 00 00 
    1937ba31:	48 81 7b 08 c9 00 00 	cmp    QWORD PTR [rbx+0x8],0xc9
    1937ba38:	00 
    1937ba39:	0f 86 ae 51 00 00    	jbe    19380bed <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67cd>
    1937ba3f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ba42:	c7 80 24 03 00 00 02 	mov    DWORD PTR [rax+0x324],0x2
    1937ba49:	00 00 00 
    1937ba4c:	48 81 7b 08 ca 00 00 	cmp    QWORD PTR [rbx+0x8],0xca
    1937ba53:	00 
    1937ba54:	0f 86 95 51 00 00    	jbe    19380bef <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67cf>
    1937ba5a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ba5d:	c7 80 28 03 00 00 02 	mov    DWORD PTR [rax+0x328],0x2
    1937ba64:	00 00 00 
    1937ba67:	48 81 7b 08 cb 00 00 	cmp    QWORD PTR [rbx+0x8],0xcb
    1937ba6e:	00 
    1937ba6f:	0f 86 7c 51 00 00    	jbe    19380bf1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67d1>
    1937ba75:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ba78:	c7 80 2c 03 00 00 02 	mov    DWORD PTR [rax+0x32c],0x2
    1937ba7f:	00 00 00 
    1937ba82:	48 81 7b 08 cc 00 00 	cmp    QWORD PTR [rbx+0x8],0xcc
    1937ba89:	00 
    1937ba8a:	0f 86 63 51 00 00    	jbe    19380bf3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67d3>
    1937ba90:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ba93:	c7 80 30 03 00 00 02 	mov    DWORD PTR [rax+0x330],0x2
    1937ba9a:	00 00 00 
    1937ba9d:	48 81 7b 08 cd 00 00 	cmp    QWORD PTR [rbx+0x8],0xcd
    1937baa4:	00 
    1937baa5:	0f 86 4a 51 00 00    	jbe    19380bf5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67d5>
    1937baab:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937baae:	c7 80 34 03 00 00 02 	mov    DWORD PTR [rax+0x334],0x2
    1937bab5:	00 00 00 
    1937bab8:	48 81 7b 08 ce 00 00 	cmp    QWORD PTR [rbx+0x8],0xce
    1937babf:	00 
    1937bac0:	0f 86 31 51 00 00    	jbe    19380bf7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67d7>
    1937bac6:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bac9:	c7 80 38 03 00 00 02 	mov    DWORD PTR [rax+0x338],0x2
    1937bad0:	00 00 00 
    1937bad3:	48 81 7b 08 cf 00 00 	cmp    QWORD PTR [rbx+0x8],0xcf
    1937bada:	00 
    1937badb:	0f 86 18 51 00 00    	jbe    19380bf9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67d9>
    1937bae1:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bae4:	c7 80 3c 03 00 00 02 	mov    DWORD PTR [rax+0x33c],0x2
    1937baeb:	00 00 00 
    1937baee:	48 81 7b 08 d0 00 00 	cmp    QWORD PTR [rbx+0x8],0xd0
    1937baf5:	00 
    1937baf6:	0f 86 ff 50 00 00    	jbe    19380bfb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67db>
    1937bafc:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937baff:	c7 80 40 03 00 00 02 	mov    DWORD PTR [rax+0x340],0x2
    1937bb06:	00 00 00 
    1937bb09:	48 81 7b 08 d1 00 00 	cmp    QWORD PTR [rbx+0x8],0xd1
    1937bb10:	00 
    1937bb11:	0f 86 e6 50 00 00    	jbe    19380bfd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67dd>
    1937bb17:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bb1a:	c7 80 44 03 00 00 01 	mov    DWORD PTR [rax+0x344],0x1
    1937bb21:	00 00 00 
    1937bb24:	48 81 7b 08 d2 00 00 	cmp    QWORD PTR [rbx+0x8],0xd2
    1937bb2b:	00 
    1937bb2c:	0f 86 cd 50 00 00    	jbe    19380bff <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67df>
    1937bb32:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bb35:	c7 80 48 03 00 00 01 	mov    DWORD PTR [rax+0x348],0x1
    1937bb3c:	00 00 00 
    1937bb3f:	48 81 7b 08 d3 00 00 	cmp    QWORD PTR [rbx+0x8],0xd3
    1937bb46:	00 
    1937bb47:	0f 86 b4 50 00 00    	jbe    19380c01 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67e1>
    1937bb4d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bb50:	c7 80 4c 03 00 00 01 	mov    DWORD PTR [rax+0x34c],0x1
    1937bb57:	00 00 00 
    1937bb5a:	48 81 7b 08 d4 00 00 	cmp    QWORD PTR [rbx+0x8],0xd4
    1937bb61:	00 
    1937bb62:	0f 86 9b 50 00 00    	jbe    19380c03 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67e3>
    1937bb68:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bb6b:	c7 80 50 03 00 00 01 	mov    DWORD PTR [rax+0x350],0x1
    1937bb72:	00 00 00 
    1937bb75:	48 81 7b 08 d5 00 00 	cmp    QWORD PTR [rbx+0x8],0xd5
    1937bb7c:	00 
    1937bb7d:	0f 86 82 50 00 00    	jbe    19380c05 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67e5>
    1937bb83:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bb86:	c7 80 54 03 00 00 01 	mov    DWORD PTR [rax+0x354],0x1
    1937bb8d:	00 00 00 
    1937bb90:	48 81 7b 08 d6 00 00 	cmp    QWORD PTR [rbx+0x8],0xd6
    1937bb97:	00 
    1937bb98:	0f 86 69 50 00 00    	jbe    19380c07 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67e7>
    1937bb9e:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bba1:	c7 80 58 03 00 00 01 	mov    DWORD PTR [rax+0x358],0x1
    1937bba8:	00 00 00 
    1937bbab:	48 81 7b 08 d7 00 00 	cmp    QWORD PTR [rbx+0x8],0xd7
    1937bbb2:	00 
    1937bbb3:	0f 86 50 50 00 00    	jbe    19380c09 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67e9>
    1937bbb9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bbbc:	c7 80 5c 03 00 00 01 	mov    DWORD PTR [rax+0x35c],0x1
    1937bbc3:	00 00 00 
    1937bbc6:	48 81 7b 08 d8 00 00 	cmp    QWORD PTR [rbx+0x8],0xd8
    1937bbcd:	00 
    1937bbce:	0f 86 37 50 00 00    	jbe    19380c0b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67eb>
    1937bbd4:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bbd7:	c7 80 60 03 00 00 01 	mov    DWORD PTR [rax+0x360],0x1
    1937bbde:	00 00 00 
    1937bbe1:	48 81 7b 08 d9 00 00 	cmp    QWORD PTR [rbx+0x8],0xd9
    1937bbe8:	00 
    1937bbe9:	0f 86 1e 50 00 00    	jbe    19380c0d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67ed>
    1937bbef:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bbf2:	c7 80 64 03 00 00 01 	mov    DWORD PTR [rax+0x364],0x1
    1937bbf9:	00 00 00 
    1937bbfc:	48 81 7b 08 da 00 00 	cmp    QWORD PTR [rbx+0x8],0xda
    1937bc03:	00 
    1937bc04:	0f 86 05 50 00 00    	jbe    19380c0f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67ef>
    1937bc0a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bc0d:	c7 80 68 03 00 00 01 	mov    DWORD PTR [rax+0x368],0x1
    1937bc14:	00 00 00 
    1937bc17:	48 81 7b 08 db 00 00 	cmp    QWORD PTR [rbx+0x8],0xdb
    1937bc1e:	00 
    1937bc1f:	0f 86 ec 4f 00 00    	jbe    19380c11 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67f1>
    1937bc25:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bc28:	c7 80 6c 03 00 00 01 	mov    DWORD PTR [rax+0x36c],0x1
    1937bc2f:	00 00 00 
    1937bc32:	48 81 7b 08 dc 00 00 	cmp    QWORD PTR [rbx+0x8],0xdc
    1937bc39:	00 
    1937bc3a:	0f 86 d3 4f 00 00    	jbe    19380c13 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67f3>
    1937bc40:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bc43:	c7 80 70 03 00 00 01 	mov    DWORD PTR [rax+0x370],0x1
    1937bc4a:	00 00 00 
    1937bc4d:	48 81 7b 08 dd 00 00 	cmp    QWORD PTR [rbx+0x8],0xdd
    1937bc54:	00 
    1937bc55:	0f 86 ba 4f 00 00    	jbe    19380c15 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67f5>
    1937bc5b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bc5e:	c7 80 74 03 00 00 01 	mov    DWORD PTR [rax+0x374],0x1
    1937bc65:	00 00 00 
    1937bc68:	48 81 7b 08 de 00 00 	cmp    QWORD PTR [rbx+0x8],0xde
    1937bc6f:	00 
    1937bc70:	0f 86 a1 4f 00 00    	jbe    19380c17 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67f7>
    1937bc76:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bc79:	c7 80 78 03 00 00 01 	mov    DWORD PTR [rax+0x378],0x1
    1937bc80:	00 00 00 
    1937bc83:	48 81 7b 08 df 00 00 	cmp    QWORD PTR [rbx+0x8],0xdf
    1937bc8a:	00 
    1937bc8b:	0f 86 88 4f 00 00    	jbe    19380c19 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67f9>
    1937bc91:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bc94:	c7 80 7c 03 00 00 01 	mov    DWORD PTR [rax+0x37c],0x1
    1937bc9b:	00 00 00 
    1937bc9e:	48 81 7b 08 e0 00 00 	cmp    QWORD PTR [rbx+0x8],0xe0
    1937bca5:	00 
    1937bca6:	0f 86 6f 4f 00 00    	jbe    19380c1b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67fb>
    1937bcac:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bcaf:	c7 80 80 03 00 00 01 	mov    DWORD PTR [rax+0x380],0x1
    1937bcb6:	00 00 00 
    1937bcb9:	48 81 7b 08 e1 00 00 	cmp    QWORD PTR [rbx+0x8],0xe1
    1937bcc0:	00 
    1937bcc1:	0f 86 56 4f 00 00    	jbe    19380c1d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67fd>
    1937bcc7:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bcca:	c7 80 84 03 00 00 01 	mov    DWORD PTR [rax+0x384],0x1
    1937bcd1:	00 00 00 
    1937bcd4:	48 81 7b 08 e2 00 00 	cmp    QWORD PTR [rbx+0x8],0xe2
    1937bcdb:	00 
    1937bcdc:	0f 86 3d 4f 00 00    	jbe    19380c1f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x67ff>
    1937bce2:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bce5:	c7 80 88 03 00 00 01 	mov    DWORD PTR [rax+0x388],0x1
    1937bcec:	00 00 00 
    1937bcef:	48 81 7b 08 e3 00 00 	cmp    QWORD PTR [rbx+0x8],0xe3
    1937bcf6:	00 
    1937bcf7:	0f 86 24 4f 00 00    	jbe    19380c21 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6801>
    1937bcfd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bd00:	c7 80 8c 03 00 00 01 	mov    DWORD PTR [rax+0x38c],0x1
    1937bd07:	00 00 00 
    1937bd0a:	48 81 7b 08 e4 00 00 	cmp    QWORD PTR [rbx+0x8],0xe4
    1937bd11:	00 
    1937bd12:	0f 86 0b 4f 00 00    	jbe    19380c23 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6803>
    1937bd18:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bd1b:	c7 80 90 03 00 00 01 	mov    DWORD PTR [rax+0x390],0x1
    1937bd22:	00 00 00 
    1937bd25:	48 81 7b 08 e5 00 00 	cmp    QWORD PTR [rbx+0x8],0xe5
    1937bd2c:	00 
    1937bd2d:	0f 86 f2 4e 00 00    	jbe    19380c25 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6805>
    1937bd33:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bd36:	c7 80 94 03 00 00 01 	mov    DWORD PTR [rax+0x394],0x1
    1937bd3d:	00 00 00 
    1937bd40:	48 81 7b 08 e6 00 00 	cmp    QWORD PTR [rbx+0x8],0xe6
    1937bd47:	00 
    1937bd48:	0f 86 d9 4e 00 00    	jbe    19380c27 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6807>
    1937bd4e:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bd51:	c7 80 98 03 00 00 01 	mov    DWORD PTR [rax+0x398],0x1
    1937bd58:	00 00 00 
    1937bd5b:	48 81 7b 08 e7 00 00 	cmp    QWORD PTR [rbx+0x8],0xe7
    1937bd62:	00 
    1937bd63:	0f 86 c0 4e 00 00    	jbe    19380c29 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6809>
    1937bd69:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bd6c:	c7 80 9c 03 00 00 01 	mov    DWORD PTR [rax+0x39c],0x1
    1937bd73:	00 00 00 
    1937bd76:	48 81 7b 08 e8 00 00 	cmp    QWORD PTR [rbx+0x8],0xe8
    1937bd7d:	00 
    1937bd7e:	0f 86 a7 4e 00 00    	jbe    19380c2b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x680b>
    1937bd84:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bd87:	c7 80 a0 03 00 00 01 	mov    DWORD PTR [rax+0x3a0],0x1
    1937bd8e:	00 00 00 
    1937bd91:	48 81 7b 08 e9 00 00 	cmp    QWORD PTR [rbx+0x8],0xe9
    1937bd98:	00 
    1937bd99:	0f 86 8e 4e 00 00    	jbe    19380c2d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x680d>
    1937bd9f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bda2:	c7 80 a4 03 00 00 01 	mov    DWORD PTR [rax+0x3a4],0x1
    1937bda9:	00 00 00 
    1937bdac:	48 81 7b 08 ea 00 00 	cmp    QWORD PTR [rbx+0x8],0xea
    1937bdb3:	00 
    1937bdb4:	0f 86 75 4e 00 00    	jbe    19380c2f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x680f>
    1937bdba:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bdbd:	c7 80 a8 03 00 00 01 	mov    DWORD PTR [rax+0x3a8],0x1
    1937bdc4:	00 00 00 
    1937bdc7:	48 81 7b 08 eb 00 00 	cmp    QWORD PTR [rbx+0x8],0xeb
    1937bdce:	00 
    1937bdcf:	0f 86 5c 4e 00 00    	jbe    19380c31 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6811>
    1937bdd5:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bdd8:	c7 80 ac 03 00 00 01 	mov    DWORD PTR [rax+0x3ac],0x1
    1937bddf:	00 00 00 
    1937bde2:	48 81 7b 08 ec 00 00 	cmp    QWORD PTR [rbx+0x8],0xec
    1937bde9:	00 
    1937bdea:	0f 86 43 4e 00 00    	jbe    19380c33 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6813>
    1937bdf0:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bdf3:	c7 80 b0 03 00 00 01 	mov    DWORD PTR [rax+0x3b0],0x1
    1937bdfa:	00 00 00 
    1937bdfd:	48 81 7b 08 ed 00 00 	cmp    QWORD PTR [rbx+0x8],0xed
    1937be04:	00 
    1937be05:	0f 86 2a 4e 00 00    	jbe    19380c35 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6815>
    1937be0b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937be0e:	c7 80 b4 03 00 00 01 	mov    DWORD PTR [rax+0x3b4],0x1
    1937be15:	00 00 00 
    1937be18:	48 81 7b 08 ee 00 00 	cmp    QWORD PTR [rbx+0x8],0xee
    1937be1f:	00 
    1937be20:	0f 86 11 4e 00 00    	jbe    19380c37 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6817>
    1937be26:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937be29:	c7 80 b8 03 00 00 01 	mov    DWORD PTR [rax+0x3b8],0x1
    1937be30:	00 00 00 
    1937be33:	48 81 7b 08 ef 00 00 	cmp    QWORD PTR [rbx+0x8],0xef
    1937be3a:	00 
    1937be3b:	0f 86 f8 4d 00 00    	jbe    19380c39 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6819>
    1937be41:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937be44:	c7 80 bc 03 00 00 01 	mov    DWORD PTR [rax+0x3bc],0x1
    1937be4b:	00 00 00 
    1937be4e:	48 81 7b 08 f0 00 00 	cmp    QWORD PTR [rbx+0x8],0xf0
    1937be55:	00 
    1937be56:	0f 86 df 4d 00 00    	jbe    19380c3b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x681b>
    1937be5c:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937be5f:	c7 80 c0 03 00 00 01 	mov    DWORD PTR [rax+0x3c0],0x1
    1937be66:	00 00 00 
    1937be69:	48 81 7b 08 f1 00 00 	cmp    QWORD PTR [rbx+0x8],0xf1
    1937be70:	00 
    1937be71:	0f 86 c6 4d 00 00    	jbe    19380c3d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x681d>
    1937be77:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937be7a:	c7 80 c4 03 00 00 01 	mov    DWORD PTR [rax+0x3c4],0x1
    1937be81:	00 00 00 
    1937be84:	48 81 7b 08 f2 00 00 	cmp    QWORD PTR [rbx+0x8],0xf2
    1937be8b:	00 
    1937be8c:	0f 86 ad 4d 00 00    	jbe    19380c3f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x681f>
    1937be92:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937be95:	c7 80 c8 03 00 00 01 	mov    DWORD PTR [rax+0x3c8],0x1
    1937be9c:	00 00 00 
    1937be9f:	48 81 7b 08 f3 00 00 	cmp    QWORD PTR [rbx+0x8],0xf3
    1937bea6:	00 
    1937bea7:	0f 86 94 4d 00 00    	jbe    19380c41 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6821>
    1937bead:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937beb0:	c7 80 cc 03 00 00 01 	mov    DWORD PTR [rax+0x3cc],0x1
    1937beb7:	00 00 00 
    1937beba:	48 81 7b 08 f4 00 00 	cmp    QWORD PTR [rbx+0x8],0xf4
    1937bec1:	00 
    1937bec2:	0f 86 7b 4d 00 00    	jbe    19380c43 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6823>
    1937bec8:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937becb:	c7 80 d0 03 00 00 01 	mov    DWORD PTR [rax+0x3d0],0x1
    1937bed2:	00 00 00 
    1937bed5:	48 81 7b 08 f5 00 00 	cmp    QWORD PTR [rbx+0x8],0xf5
    1937bedc:	00 
    1937bedd:	0f 86 62 4d 00 00    	jbe    19380c45 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6825>
    1937bee3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bee6:	c7 80 d4 03 00 00 01 	mov    DWORD PTR [rax+0x3d4],0x1
    1937beed:	00 00 00 
    1937bef0:	48 81 7b 08 f6 00 00 	cmp    QWORD PTR [rbx+0x8],0xf6
    1937bef7:	00 
    1937bef8:	0f 86 49 4d 00 00    	jbe    19380c47 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6827>
    1937befe:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bf01:	c7 80 d8 03 00 00 01 	mov    DWORD PTR [rax+0x3d8],0x1
    1937bf08:	00 00 00 
    1937bf0b:	48 81 7b 08 f7 00 00 	cmp    QWORD PTR [rbx+0x8],0xf7
    1937bf12:	00 
    1937bf13:	0f 86 30 4d 00 00    	jbe    19380c49 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6829>
    1937bf19:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bf1c:	c7 80 dc 03 00 00 01 	mov    DWORD PTR [rax+0x3dc],0x1
    1937bf23:	00 00 00 
    1937bf26:	48 81 7b 08 f8 00 00 	cmp    QWORD PTR [rbx+0x8],0xf8
    1937bf2d:	00 
    1937bf2e:	0f 86 17 4d 00 00    	jbe    19380c4b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x682b>
    1937bf34:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bf37:	c7 80 e0 03 00 00 01 	mov    DWORD PTR [rax+0x3e0],0x1
    1937bf3e:	00 00 00 
    1937bf41:	48 81 7b 08 f9 00 00 	cmp    QWORD PTR [rbx+0x8],0xf9
    1937bf48:	00 
    1937bf49:	0f 86 fe 4c 00 00    	jbe    19380c4d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x682d>
    1937bf4f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bf52:	c7 80 e4 03 00 00 01 	mov    DWORD PTR [rax+0x3e4],0x1
    1937bf59:	00 00 00 
    1937bf5c:	48 81 7b 08 fa 00 00 	cmp    QWORD PTR [rbx+0x8],0xfa
    1937bf63:	00 
    1937bf64:	0f 86 e5 4c 00 00    	jbe    19380c4f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x682f>
    1937bf6a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bf6d:	c7 80 e8 03 00 00 01 	mov    DWORD PTR [rax+0x3e8],0x1
    1937bf74:	00 00 00 
    1937bf77:	48 81 7b 08 fb 00 00 	cmp    QWORD PTR [rbx+0x8],0xfb
    1937bf7e:	00 
    1937bf7f:	0f 86 cc 4c 00 00    	jbe    19380c51 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6831>
    1937bf85:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bf88:	c7 80 ec 03 00 00 01 	mov    DWORD PTR [rax+0x3ec],0x1
    1937bf8f:	00 00 00 
    1937bf92:	48 81 7b 08 fc 00 00 	cmp    QWORD PTR [rbx+0x8],0xfc
    1937bf99:	00 
    1937bf9a:	0f 86 b3 4c 00 00    	jbe    19380c53 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6833>
    1937bfa0:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bfa3:	c7 80 f0 03 00 00 01 	mov    DWORD PTR [rax+0x3f0],0x1
    1937bfaa:	00 00 00 
    1937bfad:	48 81 7b 08 fd 00 00 	cmp    QWORD PTR [rbx+0x8],0xfd
    1937bfb4:	00 
    1937bfb5:	0f 86 9a 4c 00 00    	jbe    19380c55 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6835>
    1937bfbb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bfbe:	c7 80 f4 03 00 00 01 	mov    DWORD PTR [rax+0x3f4],0x1
    1937bfc5:	00 00 00 
    1937bfc8:	48 81 7b 08 fe 00 00 	cmp    QWORD PTR [rbx+0x8],0xfe
    1937bfcf:	00 
    1937bfd0:	0f 86 81 4c 00 00    	jbe    19380c57 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6837>
    1937bfd6:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bfd9:	c7 80 f8 03 00 00 02 	mov    DWORD PTR [rax+0x3f8],0x2
    1937bfe0:	00 00 00 
    1937bfe3:	48 81 7b 08 ff 00 00 	cmp    QWORD PTR [rbx+0x8],0xff
    1937bfea:	00 
    1937bfeb:	0f 86 68 4c 00 00    	jbe    19380c59 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6839>
    1937bff1:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937bff4:	c7 80 fc 03 00 00 02 	mov    DWORD PTR [rax+0x3fc],0x2
    1937bffb:	00 00 00 
    1937bffe:	48 81 7b 08 00 01 00 	cmp    QWORD PTR [rbx+0x8],0x100
    1937c005:	00 
    1937c006:	0f 86 4f 4c 00 00    	jbe    19380c5b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x683b>
    1937c00c:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c00f:	c7 80 00 04 00 00 02 	mov    DWORD PTR [rax+0x400],0x2
    1937c016:	00 00 00 
    1937c019:	48 81 7b 08 01 01 00 	cmp    QWORD PTR [rbx+0x8],0x101
    1937c020:	00 
    1937c021:	0f 86 36 4c 00 00    	jbe    19380c5d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x683d>
    1937c027:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c02a:	c7 80 04 04 00 00 02 	mov    DWORD PTR [rax+0x404],0x2
    1937c031:	00 00 00 
    1937c034:	48 81 7b 08 02 01 00 	cmp    QWORD PTR [rbx+0x8],0x102
    1937c03b:	00 
    1937c03c:	0f 86 1d 4c 00 00    	jbe    19380c5f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x683f>
    1937c042:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c045:	c7 80 08 04 00 00 02 	mov    DWORD PTR [rax+0x408],0x2
    1937c04c:	00 00 00 
    1937c04f:	48 81 7b 08 03 01 00 	cmp    QWORD PTR [rbx+0x8],0x103
    1937c056:	00 
    1937c057:	0f 86 04 4c 00 00    	jbe    19380c61 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6841>
    1937c05d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c060:	c7 80 0c 04 00 00 02 	mov    DWORD PTR [rax+0x40c],0x2
    1937c067:	00 00 00 
    1937c06a:	48 81 7b 08 04 01 00 	cmp    QWORD PTR [rbx+0x8],0x104
    1937c071:	00 
    1937c072:	0f 86 eb 4b 00 00    	jbe    19380c63 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6843>
    1937c078:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c07b:	c7 80 10 04 00 00 02 	mov    DWORD PTR [rax+0x410],0x2
    1937c082:	00 00 00 
    1937c085:	48 81 7b 08 05 01 00 	cmp    QWORD PTR [rbx+0x8],0x105
    1937c08c:	00 
    1937c08d:	0f 86 d2 4b 00 00    	jbe    19380c65 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6845>
    1937c093:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c096:	c7 80 14 04 00 00 02 	mov    DWORD PTR [rax+0x414],0x2
    1937c09d:	00 00 00 
    1937c0a0:	48 81 7b 08 06 01 00 	cmp    QWORD PTR [rbx+0x8],0x106
    1937c0a7:	00 
    1937c0a8:	0f 86 b9 4b 00 00    	jbe    19380c67 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6847>
    1937c0ae:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c0b1:	c7 80 18 04 00 00 02 	mov    DWORD PTR [rax+0x418],0x2
    1937c0b8:	00 00 00 
    1937c0bb:	48 81 7b 08 07 01 00 	cmp    QWORD PTR [rbx+0x8],0x107
    1937c0c2:	00 
    1937c0c3:	0f 86 a0 4b 00 00    	jbe    19380c69 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6849>
    1937c0c9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c0cc:	c7 80 1c 04 00 00 0a 	mov    DWORD PTR [rax+0x41c],0xa
    1937c0d3:	00 00 00 
    1937c0d6:	48 81 7b 20 07 01 00 	cmp    QWORD PTR [rbx+0x20],0x107
    1937c0dd:	00 
    1937c0de:	0f 86 87 4b 00 00    	jbe    19380c6b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x684b>
    1937c0e4:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c0e8:	48 83 b8 b0 18 00 00 	cmp    QWORD PTR [rax+0x18b0],0x3
    1937c0ef:	03 
    1937c0f0:	0f 86 77 4b 00 00    	jbe    19380c6d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x684d>
    1937c0f6:	48 8b 80 a8 18 00 00 	mov    rax,QWORD PTR [rax+0x18a8]
    1937c0fd:	c7 40 0c 00 00 00 00 	mov    DWORD PTR [rax+0xc],0x0
    1937c104:	48 81 39 08 01 00 00 	cmp    QWORD PTR [rcx],0x108
    1937c10b:	0f 86 5e 4b 00 00    	jbe    19380c6f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x684f>
    1937c111:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c114:	c7 80 20 04 00 00 0a 	mov    DWORD PTR [rax+0x420],0xa
    1937c11b:	00 00 00 
    1937c11e:	48 81 7b 20 08 01 00 	cmp    QWORD PTR [rbx+0x20],0x108
    1937c125:	00 
    1937c126:	0f 86 45 4b 00 00    	jbe    19380c71 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6851>
    1937c12c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c130:	48 83 b8 c8 18 00 00 	cmp    QWORD PTR [rax+0x18c8],0x3
    1937c137:	03 
    1937c138:	0f 86 35 4b 00 00    	jbe    19380c73 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6853>
    1937c13e:	48 8b 80 c0 18 00 00 	mov    rax,QWORD PTR [rax+0x18c0]
    1937c145:	c7 40 0c 00 00 00 00 	mov    DWORD PTR [rax+0xc],0x0
    1937c14c:	48 81 39 09 01 00 00 	cmp    QWORD PTR [rcx],0x109
    1937c153:	0f 86 1c 4b 00 00    	jbe    19380c75 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6855>
    1937c159:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c15c:	c7 80 24 04 00 00 0a 	mov    DWORD PTR [rax+0x424],0xa
    1937c163:	00 00 00 
    1937c166:	48 81 7b 20 09 01 00 	cmp    QWORD PTR [rbx+0x20],0x109
    1937c16d:	00 
    1937c16e:	0f 86 03 4b 00 00    	jbe    19380c77 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6857>
    1937c174:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c178:	48 83 b8 e0 18 00 00 	cmp    QWORD PTR [rax+0x18e0],0x3
    1937c17f:	03 
    1937c180:	0f 86 f3 4a 00 00    	jbe    19380c79 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6859>
    1937c186:	48 8b 80 d8 18 00 00 	mov    rax,QWORD PTR [rax+0x18d8]
    1937c18d:	c7 40 0c 00 00 00 00 	mov    DWORD PTR [rax+0xc],0x0
    1937c194:	48 81 39 0a 01 00 00 	cmp    QWORD PTR [rcx],0x10a
    1937c19b:	0f 86 da 4a 00 00    	jbe    19380c7b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x685b>
    1937c1a1:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c1a4:	c7 80 28 04 00 00 0a 	mov    DWORD PTR [rax+0x428],0xa
    1937c1ab:	00 00 00 
    1937c1ae:	48 81 7b 20 0a 01 00 	cmp    QWORD PTR [rbx+0x20],0x10a
    1937c1b5:	00 
    1937c1b6:	0f 86 c1 4a 00 00    	jbe    19380c7d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x685d>
    1937c1bc:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c1c0:	48 83 b8 f8 18 00 00 	cmp    QWORD PTR [rax+0x18f8],0x3
    1937c1c7:	03 
    1937c1c8:	0f 86 b1 4a 00 00    	jbe    19380c7f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x685f>
    1937c1ce:	48 8b 80 f0 18 00 00 	mov    rax,QWORD PTR [rax+0x18f0]
    1937c1d5:	c7 40 0c 00 00 00 00 	mov    DWORD PTR [rax+0xc],0x0
    1937c1dc:	48 81 39 0b 01 00 00 	cmp    QWORD PTR [rcx],0x10b
    1937c1e3:	0f 86 98 4a 00 00    	jbe    19380c81 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6861>
    1937c1e9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c1ec:	c7 80 2c 04 00 00 0a 	mov    DWORD PTR [rax+0x42c],0xa
    1937c1f3:	00 00 00 
    1937c1f6:	48 81 7b 20 0b 01 00 	cmp    QWORD PTR [rbx+0x20],0x10b
    1937c1fd:	00 
    1937c1fe:	0f 86 7f 4a 00 00    	jbe    19380c83 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6863>
    1937c204:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c208:	48 83 b8 10 19 00 00 	cmp    QWORD PTR [rax+0x1910],0x3
    1937c20f:	03 
    1937c210:	0f 86 6f 4a 00 00    	jbe    19380c85 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6865>
    1937c216:	48 8b 80 08 19 00 00 	mov    rax,QWORD PTR [rax+0x1908]
    1937c21d:	c7 40 0c 00 00 00 00 	mov    DWORD PTR [rax+0xc],0x0
    1937c224:	48 81 39 0c 01 00 00 	cmp    QWORD PTR [rcx],0x10c
    1937c22b:	0f 86 56 4a 00 00    	jbe    19380c87 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6867>
    1937c231:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c234:	c7 80 30 04 00 00 0a 	mov    DWORD PTR [rax+0x430],0xa
    1937c23b:	00 00 00 
    1937c23e:	48 81 7b 20 0c 01 00 	cmp    QWORD PTR [rbx+0x20],0x10c
    1937c245:	00 
    1937c246:	0f 86 3d 4a 00 00    	jbe    19380c89 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6869>
    1937c24c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c250:	48 83 b8 28 19 00 00 	cmp    QWORD PTR [rax+0x1928],0x3
    1937c257:	03 
    1937c258:	0f 86 2d 4a 00 00    	jbe    19380c8b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x686b>
    1937c25e:	48 8b 80 20 19 00 00 	mov    rax,QWORD PTR [rax+0x1920]
    1937c265:	c7 40 0c 00 00 00 00 	mov    DWORD PTR [rax+0xc],0x0
    1937c26c:	48 81 39 0d 01 00 00 	cmp    QWORD PTR [rcx],0x10d
    1937c273:	0f 86 14 4a 00 00    	jbe    19380c8d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x686d>
    1937c279:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c27c:	c7 80 34 04 00 00 0a 	mov    DWORD PTR [rax+0x434],0xa
    1937c283:	00 00 00 
    1937c286:	48 81 7b 20 0d 01 00 	cmp    QWORD PTR [rbx+0x20],0x10d
    1937c28d:	00 
    1937c28e:	0f 86 fb 49 00 00    	jbe    19380c8f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x686f>
    1937c294:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c298:	48 83 b8 40 19 00 00 	cmp    QWORD PTR [rax+0x1940],0x3
    1937c29f:	03 
    1937c2a0:	0f 86 eb 49 00 00    	jbe    19380c91 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6871>
    1937c2a6:	48 8b 80 38 19 00 00 	mov    rax,QWORD PTR [rax+0x1938]
    1937c2ad:	c7 40 0c 00 00 00 00 	mov    DWORD PTR [rax+0xc],0x0
    1937c2b4:	48 81 39 0e 01 00 00 	cmp    QWORD PTR [rcx],0x10e
    1937c2bb:	0f 86 d2 49 00 00    	jbe    19380c93 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6873>
    1937c2c1:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c2c4:	c7 80 38 04 00 00 0a 	mov    DWORD PTR [rax+0x438],0xa
    1937c2cb:	00 00 00 
    1937c2ce:	48 81 7b 20 0e 01 00 	cmp    QWORD PTR [rbx+0x20],0x10e
    1937c2d5:	00 
    1937c2d6:	0f 86 b9 49 00 00    	jbe    19380c95 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6875>
    1937c2dc:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c2e0:	48 83 b8 58 19 00 00 	cmp    QWORD PTR [rax+0x1958],0x3
    1937c2e7:	03 
    1937c2e8:	0f 86 a9 49 00 00    	jbe    19380c97 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6877>
    1937c2ee:	48 8b 80 50 19 00 00 	mov    rax,QWORD PTR [rax+0x1950]
    1937c2f5:	c7 40 0c 00 00 00 00 	mov    DWORD PTR [rax+0xc],0x0
    1937c2fc:	48 81 39 0f 01 00 00 	cmp    QWORD PTR [rcx],0x10f
    1937c303:	0f 86 90 49 00 00    	jbe    19380c99 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6879>
    1937c309:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c30c:	c7 80 3c 04 00 00 0a 	mov    DWORD PTR [rax+0x43c],0xa
    1937c313:	00 00 00 
    1937c316:	48 81 7b 20 0f 01 00 	cmp    QWORD PTR [rbx+0x20],0x10f
    1937c31d:	00 
    1937c31e:	0f 86 77 49 00 00    	jbe    19380c9b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x687b>
    1937c324:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c328:	48 83 b8 70 19 00 00 	cmp    QWORD PTR [rax+0x1970],0x3
    1937c32f:	03 
    1937c330:	0f 86 67 49 00 00    	jbe    19380c9d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x687d>
    1937c336:	48 8b 80 68 19 00 00 	mov    rax,QWORD PTR [rax+0x1968]
    1937c33d:	c7 40 0c 00 00 00 00 	mov    DWORD PTR [rax+0xc],0x0
    1937c344:	48 81 39 10 01 00 00 	cmp    QWORD PTR [rcx],0x110
    1937c34b:	0f 86 4e 49 00 00    	jbe    19380c9f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x687f>
    1937c351:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c354:	c7 80 40 04 00 00 0b 	mov    DWORD PTR [rax+0x440],0xb
    1937c35b:	00 00 00 
    1937c35e:	48 81 7b 20 10 01 00 	cmp    QWORD PTR [rbx+0x20],0x110
    1937c365:	00 
    1937c366:	0f 86 35 49 00 00    	jbe    19380ca1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6881>
    1937c36c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c370:	48 83 b8 88 19 00 00 	cmp    QWORD PTR [rax+0x1988],0x3
    1937c377:	03 
    1937c378:	0f 86 25 49 00 00    	jbe    19380ca3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6883>
    1937c37e:	48 8b 80 80 19 00 00 	mov    rax,QWORD PTR [rax+0x1980]
    1937c385:	c7 40 0c 01 00 00 00 	mov    DWORD PTR [rax+0xc],0x1
    1937c38c:	48 81 39 11 01 00 00 	cmp    QWORD PTR [rcx],0x111
    1937c393:	0f 86 0c 49 00 00    	jbe    19380ca5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6885>
    1937c399:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c39c:	c7 80 44 04 00 00 0b 	mov    DWORD PTR [rax+0x444],0xb
    1937c3a3:	00 00 00 
    1937c3a6:	48 81 7b 20 11 01 00 	cmp    QWORD PTR [rbx+0x20],0x111
    1937c3ad:	00 
    1937c3ae:	0f 86 f3 48 00 00    	jbe    19380ca7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6887>
    1937c3b4:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c3b8:	48 83 b8 a0 19 00 00 	cmp    QWORD PTR [rax+0x19a0],0x3
    1937c3bf:	03 
    1937c3c0:	0f 86 e3 48 00 00    	jbe    19380ca9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6889>
    1937c3c6:	48 8b 80 98 19 00 00 	mov    rax,QWORD PTR [rax+0x1998]
    1937c3cd:	c7 40 0c 01 00 00 00 	mov    DWORD PTR [rax+0xc],0x1
    1937c3d4:	48 81 39 12 01 00 00 	cmp    QWORD PTR [rcx],0x112
    1937c3db:	0f 86 ca 48 00 00    	jbe    19380cab <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x688b>
    1937c3e1:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c3e4:	c7 80 48 04 00 00 0b 	mov    DWORD PTR [rax+0x448],0xb
    1937c3eb:	00 00 00 
    1937c3ee:	48 81 7b 20 12 01 00 	cmp    QWORD PTR [rbx+0x20],0x112
    1937c3f5:	00 
    1937c3f6:	0f 86 b1 48 00 00    	jbe    19380cad <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x688d>
    1937c3fc:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c400:	48 83 b8 b8 19 00 00 	cmp    QWORD PTR [rax+0x19b8],0x3
    1937c407:	03 
    1937c408:	0f 86 a1 48 00 00    	jbe    19380caf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x688f>
    1937c40e:	48 8b 80 b0 19 00 00 	mov    rax,QWORD PTR [rax+0x19b0]
    1937c415:	c7 40 0c 01 00 00 00 	mov    DWORD PTR [rax+0xc],0x1
    1937c41c:	48 81 39 13 01 00 00 	cmp    QWORD PTR [rcx],0x113
    1937c423:	0f 86 88 48 00 00    	jbe    19380cb1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6891>
    1937c429:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c42c:	c7 80 4c 04 00 00 0b 	mov    DWORD PTR [rax+0x44c],0xb
    1937c433:	00 00 00 
    1937c436:	48 81 7b 20 13 01 00 	cmp    QWORD PTR [rbx+0x20],0x113
    1937c43d:	00 
    1937c43e:	0f 86 6f 48 00 00    	jbe    19380cb3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6893>
    1937c444:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c448:	48 83 b8 d0 19 00 00 	cmp    QWORD PTR [rax+0x19d0],0x3
    1937c44f:	03 
    1937c450:	0f 86 5f 48 00 00    	jbe    19380cb5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6895>
    1937c456:	48 8b 80 c8 19 00 00 	mov    rax,QWORD PTR [rax+0x19c8]
    1937c45d:	c7 40 0c 01 00 00 00 	mov    DWORD PTR [rax+0xc],0x1
    1937c464:	48 81 39 14 01 00 00 	cmp    QWORD PTR [rcx],0x114
    1937c46b:	0f 86 46 48 00 00    	jbe    19380cb7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6897>
    1937c471:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c474:	c7 80 50 04 00 00 0b 	mov    DWORD PTR [rax+0x450],0xb
    1937c47b:	00 00 00 
    1937c47e:	48 81 7b 20 14 01 00 	cmp    QWORD PTR [rbx+0x20],0x114
    1937c485:	00 
    1937c486:	0f 86 2d 48 00 00    	jbe    19380cb9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6899>
    1937c48c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c490:	48 83 b8 e8 19 00 00 	cmp    QWORD PTR [rax+0x19e8],0x3
    1937c497:	03 
    1937c498:	0f 86 1d 48 00 00    	jbe    19380cbb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x689b>
    1937c49e:	48 8b 80 e0 19 00 00 	mov    rax,QWORD PTR [rax+0x19e0]
    1937c4a5:	c7 40 0c 01 00 00 00 	mov    DWORD PTR [rax+0xc],0x1
    1937c4ac:	48 81 39 15 01 00 00 	cmp    QWORD PTR [rcx],0x115
    1937c4b3:	0f 86 04 48 00 00    	jbe    19380cbd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x689d>
    1937c4b9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c4bc:	c7 80 54 04 00 00 0b 	mov    DWORD PTR [rax+0x454],0xb
    1937c4c3:	00 00 00 
    1937c4c6:	48 81 7b 20 15 01 00 	cmp    QWORD PTR [rbx+0x20],0x115
    1937c4cd:	00 
    1937c4ce:	0f 86 eb 47 00 00    	jbe    19380cbf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x689f>
    1937c4d4:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c4d8:	48 83 b8 00 1a 00 00 	cmp    QWORD PTR [rax+0x1a00],0x3
    1937c4df:	03 
    1937c4e0:	0f 86 db 47 00 00    	jbe    19380cc1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68a1>
    1937c4e6:	48 8b 80 f8 19 00 00 	mov    rax,QWORD PTR [rax+0x19f8]
    1937c4ed:	c7 40 0c 01 00 00 00 	mov    DWORD PTR [rax+0xc],0x1
    1937c4f4:	48 81 39 16 01 00 00 	cmp    QWORD PTR [rcx],0x116
    1937c4fb:	0f 86 c2 47 00 00    	jbe    19380cc3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68a3>
    1937c501:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c504:	c7 80 58 04 00 00 0b 	mov    DWORD PTR [rax+0x458],0xb
    1937c50b:	00 00 00 
    1937c50e:	48 81 7b 20 16 01 00 	cmp    QWORD PTR [rbx+0x20],0x116
    1937c515:	00 
    1937c516:	0f 86 a9 47 00 00    	jbe    19380cc5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68a5>
    1937c51c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c520:	48 83 b8 18 1a 00 00 	cmp    QWORD PTR [rax+0x1a18],0x3
    1937c527:	03 
    1937c528:	0f 86 99 47 00 00    	jbe    19380cc7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68a7>
    1937c52e:	48 8b 80 10 1a 00 00 	mov    rax,QWORD PTR [rax+0x1a10]
    1937c535:	c7 40 0c 01 00 00 00 	mov    DWORD PTR [rax+0xc],0x1
    1937c53c:	48 81 39 17 01 00 00 	cmp    QWORD PTR [rcx],0x117
    1937c543:	0f 86 80 47 00 00    	jbe    19380cc9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68a9>
    1937c549:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c54c:	c7 80 5c 04 00 00 0b 	mov    DWORD PTR [rax+0x45c],0xb
    1937c553:	00 00 00 
    1937c556:	48 81 7b 20 17 01 00 	cmp    QWORD PTR [rbx+0x20],0x117
    1937c55d:	00 
    1937c55e:	0f 86 67 47 00 00    	jbe    19380ccb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68ab>
    1937c564:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c568:	48 83 b8 30 1a 00 00 	cmp    QWORD PTR [rax+0x1a30],0x3
    1937c56f:	03 
    1937c570:	0f 86 57 47 00 00    	jbe    19380ccd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68ad>
    1937c576:	48 8b 80 28 1a 00 00 	mov    rax,QWORD PTR [rax+0x1a28]
    1937c57d:	c7 40 0c 01 00 00 00 	mov    DWORD PTR [rax+0xc],0x1
    1937c584:	48 81 39 18 01 00 00 	cmp    QWORD PTR [rcx],0x118
    1937c58b:	0f 86 3e 47 00 00    	jbe    19380ccf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68af>
    1937c591:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c594:	c7 80 60 04 00 00 0b 	mov    DWORD PTR [rax+0x460],0xb
    1937c59b:	00 00 00 
    1937c59e:	48 81 7b 20 18 01 00 	cmp    QWORD PTR [rbx+0x20],0x118
    1937c5a5:	00 
    1937c5a6:	0f 86 25 47 00 00    	jbe    19380cd1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68b1>
    1937c5ac:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c5b0:	48 83 b8 48 1a 00 00 	cmp    QWORD PTR [rax+0x1a48],0x3
    1937c5b7:	03 
    1937c5b8:	0f 86 15 47 00 00    	jbe    19380cd3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68b3>
    1937c5be:	48 8b 80 40 1a 00 00 	mov    rax,QWORD PTR [rax+0x1a40]
    1937c5c5:	c7 40 0c 01 00 00 00 	mov    DWORD PTR [rax+0xc],0x1
    1937c5cc:	48 81 39 19 01 00 00 	cmp    QWORD PTR [rcx],0x119
    1937c5d3:	0f 86 fc 46 00 00    	jbe    19380cd5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68b5>
    1937c5d9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c5dc:	c7 80 64 04 00 00 01 	mov    DWORD PTR [rax+0x464],0x1
    1937c5e3:	00 00 00 
    1937c5e6:	48 81 7b 08 1a 01 00 	cmp    QWORD PTR [rbx+0x8],0x11a
    1937c5ed:	00 
    1937c5ee:	0f 86 e3 46 00 00    	jbe    19380cd7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68b7>
    1937c5f4:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c5f7:	c7 80 68 04 00 00 01 	mov    DWORD PTR [rax+0x468],0x1
    1937c5fe:	00 00 00 
    1937c601:	48 81 7b 08 1b 01 00 	cmp    QWORD PTR [rbx+0x8],0x11b
    1937c608:	00 
    1937c609:	0f 86 ca 46 00 00    	jbe    19380cd9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68b9>
    1937c60f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c612:	c7 80 6c 04 00 00 01 	mov    DWORD PTR [rax+0x46c],0x1
    1937c619:	00 00 00 
    1937c61c:	48 81 7b 08 1c 01 00 	cmp    QWORD PTR [rbx+0x8],0x11c
    1937c623:	00 
    1937c624:	0f 86 b1 46 00 00    	jbe    19380cdb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68bb>
    1937c62a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c62d:	c7 80 70 04 00 00 01 	mov    DWORD PTR [rax+0x470],0x1
    1937c634:	00 00 00 
    1937c637:	48 81 7b 08 1d 01 00 	cmp    QWORD PTR [rbx+0x8],0x11d
    1937c63e:	00 
    1937c63f:	0f 86 98 46 00 00    	jbe    19380cdd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68bd>
    1937c645:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c648:	c7 80 74 04 00 00 01 	mov    DWORD PTR [rax+0x474],0x1
    1937c64f:	00 00 00 
    1937c652:	48 81 7b 08 1e 01 00 	cmp    QWORD PTR [rbx+0x8],0x11e
    1937c659:	00 
    1937c65a:	0f 86 7f 46 00 00    	jbe    19380cdf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68bf>
    1937c660:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c663:	c7 80 78 04 00 00 01 	mov    DWORD PTR [rax+0x478],0x1
    1937c66a:	00 00 00 
    1937c66d:	48 81 7b 08 1f 01 00 	cmp    QWORD PTR [rbx+0x8],0x11f
    1937c674:	00 
    1937c675:	0f 86 66 46 00 00    	jbe    19380ce1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68c1>
    1937c67b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c67e:	c7 80 7c 04 00 00 01 	mov    DWORD PTR [rax+0x47c],0x1
    1937c685:	00 00 00 
    1937c688:	48 81 7b 08 20 01 00 	cmp    QWORD PTR [rbx+0x8],0x120
    1937c68f:	00 
    1937c690:	0f 86 4d 46 00 00    	jbe    19380ce3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68c3>
    1937c696:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c699:	c7 80 80 04 00 00 01 	mov    DWORD PTR [rax+0x480],0x1
    1937c6a0:	00 00 00 
    1937c6a3:	48 81 7b 08 21 01 00 	cmp    QWORD PTR [rbx+0x8],0x121
    1937c6aa:	00 
    1937c6ab:	0f 86 34 46 00 00    	jbe    19380ce5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68c5>
    1937c6b1:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c6b4:	c7 80 84 04 00 00 d3 	mov    DWORD PTR [rax+0x484],0xd3
    1937c6bb:	00 00 00 
    1937c6be:	48 81 7b 20 21 01 00 	cmp    QWORD PTR [rbx+0x20],0x121
    1937c6c5:	00 
    1937c6c6:	0f 86 1b 46 00 00    	jbe    19380ce7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68c7>
    1937c6cc:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c6d0:	48 83 b8 20 1b 00 00 	cmp    QWORD PTR [rax+0x1b20],0x4
    1937c6d7:	04 
    1937c6d8:	0f 86 0b 46 00 00    	jbe    19380ce9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68c9>
    1937c6de:	48 8b 80 18 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b18]
    1937c6e5:	c7 40 10 10 00 00 00 	mov    DWORD PTR [rax+0x10],0x10
    1937c6ec:	49 81 7d 00 21 01 00 	cmp    QWORD PTR [r13+0x0],0x121
    1937c6f3:	00 
    1937c6f4:	0f 86 f1 45 00 00    	jbe    19380ceb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68cb>
    1937c6fa:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c6fe:	48 83 b8 20 1b 00 00 	cmp    QWORD PTR [rax+0x1b20],0x5
    1937c705:	05 
    1937c706:	0f 86 e1 45 00 00    	jbe    19380ced <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68cd>
    1937c70c:	48 8b 80 18 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b18]
    1937c713:	c7 40 14 04 00 00 00 	mov    DWORD PTR [rax+0x14],0x4
    1937c71a:	49 81 7d 00 21 01 00 	cmp    QWORD PTR [r13+0x0],0x121
    1937c721:	00 
    1937c722:	0f 86 c7 45 00 00    	jbe    19380cef <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68cf>
    1937c728:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c72c:	48 83 b8 20 1b 00 00 	cmp    QWORD PTR [rax+0x1b20],0x6
    1937c733:	06 
    1937c734:	0f 86 b7 45 00 00    	jbe    19380cf1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68d1>
    1937c73a:	48 8b 80 18 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b18]
    1937c741:	c7 40 18 09 00 00 00 	mov    DWORD PTR [rax+0x18],0x9
    1937c748:	49 81 7d 00 21 01 00 	cmp    QWORD PTR [r13+0x0],0x121
    1937c74f:	00 
    1937c750:	0f 86 9d 45 00 00    	jbe    19380cf3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68d3>
    1937c756:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c75a:	48 83 b8 20 1b 00 00 	cmp    QWORD PTR [rax+0x1b20],0x7
    1937c761:	07 
    1937c762:	0f 86 8d 45 00 00    	jbe    19380cf5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68d5>
    1937c768:	48 8b 80 18 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b18]
    1937c76f:	c7 40 1c 03 00 00 00 	mov    DWORD PTR [rax+0x1c],0x3
    1937c776:	48 81 39 22 01 00 00 	cmp    QWORD PTR [rcx],0x122
    1937c77d:	0f 86 74 45 00 00    	jbe    19380cf7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68d7>
    1937c783:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c786:	c7 80 88 04 00 00 d3 	mov    DWORD PTR [rax+0x488],0xd3
    1937c78d:	00 00 00 
    1937c790:	48 81 7b 20 22 01 00 	cmp    QWORD PTR [rbx+0x20],0x122
    1937c797:	00 
    1937c798:	0f 86 5b 45 00 00    	jbe    19380cf9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68d9>
    1937c79e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c7a2:	48 83 b8 38 1b 00 00 	cmp    QWORD PTR [rax+0x1b38],0x4
    1937c7a9:	04 
    1937c7aa:	0f 86 4b 45 00 00    	jbe    19380cfb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68db>
    1937c7b0:	48 8b 80 30 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b30]
    1937c7b7:	c7 40 10 10 00 00 00 	mov    DWORD PTR [rax+0x10],0x10
    1937c7be:	49 81 7d 00 22 01 00 	cmp    QWORD PTR [r13+0x0],0x122
    1937c7c5:	00 
    1937c7c6:	0f 86 31 45 00 00    	jbe    19380cfd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68dd>
    1937c7cc:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c7d0:	48 83 b8 38 1b 00 00 	cmp    QWORD PTR [rax+0x1b38],0x5
    1937c7d7:	05 
    1937c7d8:	0f 86 21 45 00 00    	jbe    19380cff <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68df>
    1937c7de:	48 8b 80 30 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b30]
    1937c7e5:	c7 40 14 04 00 00 00 	mov    DWORD PTR [rax+0x14],0x4
    1937c7ec:	49 81 7d 00 22 01 00 	cmp    QWORD PTR [r13+0x0],0x122
    1937c7f3:	00 
    1937c7f4:	0f 86 07 45 00 00    	jbe    19380d01 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68e1>
    1937c7fa:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c7fe:	48 83 b8 38 1b 00 00 	cmp    QWORD PTR [rax+0x1b38],0x6
    1937c805:	06 
    1937c806:	0f 86 f7 44 00 00    	jbe    19380d03 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68e3>
    1937c80c:	48 8b 80 30 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b30]
    1937c813:	c7 40 18 09 00 00 00 	mov    DWORD PTR [rax+0x18],0x9
    1937c81a:	49 81 7d 00 22 01 00 	cmp    QWORD PTR [r13+0x0],0x122
    1937c821:	00 
    1937c822:	0f 86 dd 44 00 00    	jbe    19380d05 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68e5>
    1937c828:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c82c:	48 83 b8 38 1b 00 00 	cmp    QWORD PTR [rax+0x1b38],0x7
    1937c833:	07 
    1937c834:	0f 86 cd 44 00 00    	jbe    19380d07 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68e7>
    1937c83a:	48 8b 80 30 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b30]
    1937c841:	c7 40 1c 03 00 00 00 	mov    DWORD PTR [rax+0x1c],0x3
    1937c848:	48 81 39 23 01 00 00 	cmp    QWORD PTR [rcx],0x123
    1937c84f:	0f 86 b4 44 00 00    	jbe    19380d09 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68e9>
    1937c855:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c858:	c7 80 8c 04 00 00 d3 	mov    DWORD PTR [rax+0x48c],0xd3
    1937c85f:	00 00 00 
    1937c862:	48 81 7b 20 23 01 00 	cmp    QWORD PTR [rbx+0x20],0x123
    1937c869:	00 
    1937c86a:	0f 86 9b 44 00 00    	jbe    19380d0b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68eb>
    1937c870:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c874:	48 83 b8 50 1b 00 00 	cmp    QWORD PTR [rax+0x1b50],0x4
    1937c87b:	04 
    1937c87c:	0f 86 8b 44 00 00    	jbe    19380d0d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68ed>
    1937c882:	48 8b 80 48 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b48]
    1937c889:	c7 40 10 10 00 00 00 	mov    DWORD PTR [rax+0x10],0x10
    1937c890:	49 81 7d 00 23 01 00 	cmp    QWORD PTR [r13+0x0],0x123
    1937c897:	00 
    1937c898:	0f 86 71 44 00 00    	jbe    19380d0f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68ef>
    1937c89e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c8a2:	48 83 b8 50 1b 00 00 	cmp    QWORD PTR [rax+0x1b50],0x5
    1937c8a9:	05 
    1937c8aa:	0f 86 61 44 00 00    	jbe    19380d11 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68f1>
    1937c8b0:	48 8b 80 48 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b48]
    1937c8b7:	c7 40 14 04 00 00 00 	mov    DWORD PTR [rax+0x14],0x4
    1937c8be:	49 81 7d 00 23 01 00 	cmp    QWORD PTR [r13+0x0],0x123
    1937c8c5:	00 
    1937c8c6:	0f 86 47 44 00 00    	jbe    19380d13 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68f3>
    1937c8cc:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c8d0:	48 83 b8 50 1b 00 00 	cmp    QWORD PTR [rax+0x1b50],0x6
    1937c8d7:	06 
    1937c8d8:	0f 86 37 44 00 00    	jbe    19380d15 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68f5>
    1937c8de:	48 8b 80 48 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b48]
    1937c8e5:	c7 40 18 09 00 00 00 	mov    DWORD PTR [rax+0x18],0x9
    1937c8ec:	49 81 7d 00 23 01 00 	cmp    QWORD PTR [r13+0x0],0x123
    1937c8f3:	00 
    1937c8f4:	0f 86 1d 44 00 00    	jbe    19380d17 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68f7>
    1937c8fa:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c8fe:	48 83 b8 50 1b 00 00 	cmp    QWORD PTR [rax+0x1b50],0x7
    1937c905:	07 
    1937c906:	0f 86 0d 44 00 00    	jbe    19380d19 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68f9>
    1937c90c:	48 8b 80 48 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b48]
    1937c913:	c7 40 1c 03 00 00 00 	mov    DWORD PTR [rax+0x1c],0x3
    1937c91a:	48 81 39 24 01 00 00 	cmp    QWORD PTR [rcx],0x124
    1937c921:	0f 86 f4 43 00 00    	jbe    19380d1b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68fb>
    1937c927:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c92a:	c7 80 90 04 00 00 d3 	mov    DWORD PTR [rax+0x490],0xd3
    1937c931:	00 00 00 
    1937c934:	48 81 7b 20 24 01 00 	cmp    QWORD PTR [rbx+0x20],0x124
    1937c93b:	00 
    1937c93c:	0f 86 db 43 00 00    	jbe    19380d1d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68fd>
    1937c942:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c946:	48 83 b8 68 1b 00 00 	cmp    QWORD PTR [rax+0x1b68],0x4
    1937c94d:	04 
    1937c94e:	0f 86 cb 43 00 00    	jbe    19380d1f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x68ff>
    1937c954:	48 8b 80 60 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b60]
    1937c95b:	c7 40 10 10 00 00 00 	mov    DWORD PTR [rax+0x10],0x10
    1937c962:	49 81 7d 00 24 01 00 	cmp    QWORD PTR [r13+0x0],0x124
    1937c969:	00 
    1937c96a:	0f 86 b1 43 00 00    	jbe    19380d21 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6901>
    1937c970:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c974:	48 83 b8 68 1b 00 00 	cmp    QWORD PTR [rax+0x1b68],0x5
    1937c97b:	05 
    1937c97c:	0f 86 a1 43 00 00    	jbe    19380d23 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6903>
    1937c982:	48 8b 80 60 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b60]
    1937c989:	c7 40 14 04 00 00 00 	mov    DWORD PTR [rax+0x14],0x4
    1937c990:	49 81 7d 00 24 01 00 	cmp    QWORD PTR [r13+0x0],0x124
    1937c997:	00 
    1937c998:	0f 86 87 43 00 00    	jbe    19380d25 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6905>
    1937c99e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c9a2:	48 83 b8 68 1b 00 00 	cmp    QWORD PTR [rax+0x1b68],0x6
    1937c9a9:	06 
    1937c9aa:	0f 86 77 43 00 00    	jbe    19380d27 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6907>
    1937c9b0:	48 8b 80 60 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b60]
    1937c9b7:	c7 40 18 09 00 00 00 	mov    DWORD PTR [rax+0x18],0x9
    1937c9be:	49 81 7d 00 24 01 00 	cmp    QWORD PTR [r13+0x0],0x124
    1937c9c5:	00 
    1937c9c6:	0f 86 5d 43 00 00    	jbe    19380d29 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6909>
    1937c9cc:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937c9d0:	48 83 b8 68 1b 00 00 	cmp    QWORD PTR [rax+0x1b68],0x7
    1937c9d7:	07 
    1937c9d8:	0f 86 4d 43 00 00    	jbe    19380d2b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x690b>
    1937c9de:	48 8b 80 60 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b60]
    1937c9e5:	c7 40 1c 03 00 00 00 	mov    DWORD PTR [rax+0x1c],0x3
    1937c9ec:	48 81 39 25 01 00 00 	cmp    QWORD PTR [rcx],0x125
    1937c9f3:	0f 86 34 43 00 00    	jbe    19380d2d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x690d>
    1937c9f9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937c9fc:	c7 80 94 04 00 00 d3 	mov    DWORD PTR [rax+0x494],0xd3
    1937ca03:	00 00 00 
    1937ca06:	48 81 7b 20 25 01 00 	cmp    QWORD PTR [rbx+0x20],0x125
    1937ca0d:	00 
    1937ca0e:	0f 86 1b 43 00 00    	jbe    19380d2f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x690f>
    1937ca14:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ca18:	48 83 b8 80 1b 00 00 	cmp    QWORD PTR [rax+0x1b80],0x4
    1937ca1f:	04 
    1937ca20:	0f 86 0b 43 00 00    	jbe    19380d31 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6911>
    1937ca26:	48 8b 80 78 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b78]
    1937ca2d:	c7 40 10 10 00 00 00 	mov    DWORD PTR [rax+0x10],0x10
    1937ca34:	49 81 7d 00 25 01 00 	cmp    QWORD PTR [r13+0x0],0x125
    1937ca3b:	00 
    1937ca3c:	0f 86 f1 42 00 00    	jbe    19380d33 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6913>
    1937ca42:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ca46:	48 83 b8 80 1b 00 00 	cmp    QWORD PTR [rax+0x1b80],0x5
    1937ca4d:	05 
    1937ca4e:	0f 86 e1 42 00 00    	jbe    19380d35 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6915>
    1937ca54:	48 8b 80 78 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b78]
    1937ca5b:	c7 40 14 04 00 00 00 	mov    DWORD PTR [rax+0x14],0x4
    1937ca62:	49 81 7d 00 25 01 00 	cmp    QWORD PTR [r13+0x0],0x125
    1937ca69:	00 
    1937ca6a:	0f 86 c7 42 00 00    	jbe    19380d37 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6917>
    1937ca70:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ca74:	48 83 b8 80 1b 00 00 	cmp    QWORD PTR [rax+0x1b80],0x6
    1937ca7b:	06 
    1937ca7c:	0f 86 b7 42 00 00    	jbe    19380d39 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6919>
    1937ca82:	48 8b 80 78 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b78]
    1937ca89:	c7 40 18 09 00 00 00 	mov    DWORD PTR [rax+0x18],0x9
    1937ca90:	49 81 7d 00 25 01 00 	cmp    QWORD PTR [r13+0x0],0x125
    1937ca97:	00 
    1937ca98:	0f 86 9d 42 00 00    	jbe    19380d3b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x691b>
    1937ca9e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937caa2:	48 83 b8 80 1b 00 00 	cmp    QWORD PTR [rax+0x1b80],0x7
    1937caa9:	07 
    1937caaa:	0f 86 8d 42 00 00    	jbe    19380d3d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x691d>
    1937cab0:	48 8b 80 78 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b78]
    1937cab7:	c7 40 1c 03 00 00 00 	mov    DWORD PTR [rax+0x1c],0x3
    1937cabe:	48 81 39 26 01 00 00 	cmp    QWORD PTR [rcx],0x126
    1937cac5:	0f 86 74 42 00 00    	jbe    19380d3f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x691f>
    1937cacb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937cace:	c7 80 98 04 00 00 d3 	mov    DWORD PTR [rax+0x498],0xd3
    1937cad5:	00 00 00 
    1937cad8:	48 81 7b 20 26 01 00 	cmp    QWORD PTR [rbx+0x20],0x126
    1937cadf:	00 
    1937cae0:	0f 86 5b 42 00 00    	jbe    19380d41 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6921>
    1937cae6:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937caea:	48 83 b8 98 1b 00 00 	cmp    QWORD PTR [rax+0x1b98],0x4
    1937caf1:	04 
    1937caf2:	0f 86 4b 42 00 00    	jbe    19380d43 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6923>
    1937caf8:	48 8b 80 90 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b90]
    1937caff:	c7 40 10 10 00 00 00 	mov    DWORD PTR [rax+0x10],0x10
    1937cb06:	49 81 7d 00 26 01 00 	cmp    QWORD PTR [r13+0x0],0x126
    1937cb0d:	00 
    1937cb0e:	0f 86 31 42 00 00    	jbe    19380d45 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6925>
    1937cb14:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cb18:	48 83 b8 98 1b 00 00 	cmp    QWORD PTR [rax+0x1b98],0x5
    1937cb1f:	05 
    1937cb20:	0f 86 21 42 00 00    	jbe    19380d47 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6927>
    1937cb26:	48 8b 80 90 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b90]
    1937cb2d:	c7 40 14 04 00 00 00 	mov    DWORD PTR [rax+0x14],0x4
    1937cb34:	49 81 7d 00 26 01 00 	cmp    QWORD PTR [r13+0x0],0x126
    1937cb3b:	00 
    1937cb3c:	0f 86 07 42 00 00    	jbe    19380d49 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6929>
    1937cb42:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cb46:	48 83 b8 98 1b 00 00 	cmp    QWORD PTR [rax+0x1b98],0x6
    1937cb4d:	06 
    1937cb4e:	0f 86 f7 41 00 00    	jbe    19380d4b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x692b>
    1937cb54:	48 8b 80 90 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b90]
    1937cb5b:	c7 40 18 09 00 00 00 	mov    DWORD PTR [rax+0x18],0x9
    1937cb62:	49 81 7d 00 26 01 00 	cmp    QWORD PTR [r13+0x0],0x126
    1937cb69:	00 
    1937cb6a:	0f 86 dd 41 00 00    	jbe    19380d4d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x692d>
    1937cb70:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cb74:	48 83 b8 98 1b 00 00 	cmp    QWORD PTR [rax+0x1b98],0x7
    1937cb7b:	07 
    1937cb7c:	0f 86 cd 41 00 00    	jbe    19380d4f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x692f>
    1937cb82:	48 8b 80 90 1b 00 00 	mov    rax,QWORD PTR [rax+0x1b90]
    1937cb89:	c7 40 1c 03 00 00 00 	mov    DWORD PTR [rax+0x1c],0x3
    1937cb90:	48 81 39 27 01 00 00 	cmp    QWORD PTR [rcx],0x127
    1937cb97:	0f 86 b4 41 00 00    	jbe    19380d51 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6931>
    1937cb9d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937cba0:	c7 80 9c 04 00 00 d3 	mov    DWORD PTR [rax+0x49c],0xd3
    1937cba7:	00 00 00 
    1937cbaa:	48 81 7b 20 27 01 00 	cmp    QWORD PTR [rbx+0x20],0x127
    1937cbb1:	00 
    1937cbb2:	0f 86 9b 41 00 00    	jbe    19380d53 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6933>
    1937cbb8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cbbc:	48 83 b8 b0 1b 00 00 	cmp    QWORD PTR [rax+0x1bb0],0x4
    1937cbc3:	04 
    1937cbc4:	0f 86 8b 41 00 00    	jbe    19380d55 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6935>
    1937cbca:	48 8b 80 a8 1b 00 00 	mov    rax,QWORD PTR [rax+0x1ba8]
    1937cbd1:	c7 40 10 14 00 00 00 	mov    DWORD PTR [rax+0x10],0x14
    1937cbd8:	49 81 7d 00 27 01 00 	cmp    QWORD PTR [r13+0x0],0x127
    1937cbdf:	00 
    1937cbe0:	0f 86 71 41 00 00    	jbe    19380d57 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6937>
    1937cbe6:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cbea:	48 83 b8 b0 1b 00 00 	cmp    QWORD PTR [rax+0x1bb0],0x5
    1937cbf1:	05 
    1937cbf2:	0f 86 61 41 00 00    	jbe    19380d59 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6939>
    1937cbf8:	48 8b 80 a8 1b 00 00 	mov    rax,QWORD PTR [rax+0x1ba8]
    1937cbff:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937cc06:	49 81 7d 00 27 01 00 	cmp    QWORD PTR [r13+0x0],0x127
    1937cc0d:	00 
    1937cc0e:	0f 86 47 41 00 00    	jbe    19380d5b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x693b>
    1937cc14:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cc18:	48 83 b8 b0 1b 00 00 	cmp    QWORD PTR [rax+0x1bb0],0x6
    1937cc1f:	06 
    1937cc20:	0f 86 37 41 00 00    	jbe    19380d5d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x693d>
    1937cc26:	48 8b 80 a8 1b 00 00 	mov    rax,QWORD PTR [rax+0x1ba8]
    1937cc2d:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937cc34:	49 81 7d 00 27 01 00 	cmp    QWORD PTR [r13+0x0],0x127
    1937cc3b:	00 
    1937cc3c:	0f 86 1d 41 00 00    	jbe    19380d5f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x693f>
    1937cc42:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cc46:	48 83 b8 b0 1b 00 00 	cmp    QWORD PTR [rax+0x1bb0],0x7
    1937cc4d:	07 
    1937cc4e:	0f 86 0d 41 00 00    	jbe    19380d61 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6941>
    1937cc54:	48 8b 80 a8 1b 00 00 	mov    rax,QWORD PTR [rax+0x1ba8]
    1937cc5b:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937cc62:	48 81 39 28 01 00 00 	cmp    QWORD PTR [rcx],0x128
    1937cc69:	0f 86 f4 40 00 00    	jbe    19380d63 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6943>
    1937cc6f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937cc72:	c7 80 a0 04 00 00 d3 	mov    DWORD PTR [rax+0x4a0],0xd3
    1937cc79:	00 00 00 
    1937cc7c:	48 81 7b 20 28 01 00 	cmp    QWORD PTR [rbx+0x20],0x128
    1937cc83:	00 
    1937cc84:	0f 86 db 40 00 00    	jbe    19380d65 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6945>
    1937cc8a:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cc8e:	48 83 b8 c8 1b 00 00 	cmp    QWORD PTR [rax+0x1bc8],0x4
    1937cc95:	04 
    1937cc96:	0f 86 cb 40 00 00    	jbe    19380d67 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6947>
    1937cc9c:	48 8b 80 c0 1b 00 00 	mov    rax,QWORD PTR [rax+0x1bc0]
    1937cca3:	c7 40 10 14 00 00 00 	mov    DWORD PTR [rax+0x10],0x14
    1937ccaa:	49 81 7d 00 28 01 00 	cmp    QWORD PTR [r13+0x0],0x128
    1937ccb1:	00 
    1937ccb2:	0f 86 b1 40 00 00    	jbe    19380d69 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6949>
    1937ccb8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ccbc:	48 83 b8 c8 1b 00 00 	cmp    QWORD PTR [rax+0x1bc8],0x5
    1937ccc3:	05 
    1937ccc4:	0f 86 a1 40 00 00    	jbe    19380d6b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x694b>
    1937ccca:	48 8b 80 c0 1b 00 00 	mov    rax,QWORD PTR [rax+0x1bc0]
    1937ccd1:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937ccd8:	49 81 7d 00 28 01 00 	cmp    QWORD PTR [r13+0x0],0x128
    1937ccdf:	00 
    1937cce0:	0f 86 87 40 00 00    	jbe    19380d6d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x694d>
    1937cce6:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ccea:	48 83 b8 c8 1b 00 00 	cmp    QWORD PTR [rax+0x1bc8],0x6
    1937ccf1:	06 
    1937ccf2:	0f 86 77 40 00 00    	jbe    19380d6f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x694f>
    1937ccf8:	48 8b 80 c0 1b 00 00 	mov    rax,QWORD PTR [rax+0x1bc0]
    1937ccff:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937cd06:	49 81 7d 00 28 01 00 	cmp    QWORD PTR [r13+0x0],0x128
    1937cd0d:	00 
    1937cd0e:	0f 86 5d 40 00 00    	jbe    19380d71 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6951>
    1937cd14:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cd18:	48 83 b8 c8 1b 00 00 	cmp    QWORD PTR [rax+0x1bc8],0x7
    1937cd1f:	07 
    1937cd20:	0f 86 4d 40 00 00    	jbe    19380d73 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6953>
    1937cd26:	48 8b 80 c0 1b 00 00 	mov    rax,QWORD PTR [rax+0x1bc0]
    1937cd2d:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937cd34:	48 81 39 29 01 00 00 	cmp    QWORD PTR [rcx],0x129
    1937cd3b:	0f 86 34 40 00 00    	jbe    19380d75 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6955>
    1937cd41:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937cd44:	c7 80 a4 04 00 00 d3 	mov    DWORD PTR [rax+0x4a4],0xd3
    1937cd4b:	00 00 00 
    1937cd4e:	48 81 7b 20 29 01 00 	cmp    QWORD PTR [rbx+0x20],0x129
    1937cd55:	00 
    1937cd56:	0f 86 1b 40 00 00    	jbe    19380d77 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6957>
    1937cd5c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cd60:	48 83 b8 e0 1b 00 00 	cmp    QWORD PTR [rax+0x1be0],0x4
    1937cd67:	04 
    1937cd68:	0f 86 0b 40 00 00    	jbe    19380d79 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6959>
    1937cd6e:	48 8b 80 d8 1b 00 00 	mov    rax,QWORD PTR [rax+0x1bd8]
    1937cd75:	c7 40 10 14 00 00 00 	mov    DWORD PTR [rax+0x10],0x14
    1937cd7c:	49 81 7d 00 29 01 00 	cmp    QWORD PTR [r13+0x0],0x129
    1937cd83:	00 
    1937cd84:	0f 86 f1 3f 00 00    	jbe    19380d7b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x695b>
    1937cd8a:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cd8e:	48 83 b8 e0 1b 00 00 	cmp    QWORD PTR [rax+0x1be0],0x5
    1937cd95:	05 
    1937cd96:	0f 86 e1 3f 00 00    	jbe    19380d7d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x695d>
    1937cd9c:	48 8b 80 d8 1b 00 00 	mov    rax,QWORD PTR [rax+0x1bd8]
    1937cda3:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937cdaa:	49 81 7d 00 29 01 00 	cmp    QWORD PTR [r13+0x0],0x129
    1937cdb1:	00 
    1937cdb2:	0f 86 c7 3f 00 00    	jbe    19380d7f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x695f>
    1937cdb8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cdbc:	48 83 b8 e0 1b 00 00 	cmp    QWORD PTR [rax+0x1be0],0x6
    1937cdc3:	06 
    1937cdc4:	0f 86 b7 3f 00 00    	jbe    19380d81 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6961>
    1937cdca:	48 8b 80 d8 1b 00 00 	mov    rax,QWORD PTR [rax+0x1bd8]
    1937cdd1:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937cdd8:	49 81 7d 00 29 01 00 	cmp    QWORD PTR [r13+0x0],0x129
    1937cddf:	00 
    1937cde0:	0f 86 9d 3f 00 00    	jbe    19380d83 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6963>
    1937cde6:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cdea:	48 83 b8 e0 1b 00 00 	cmp    QWORD PTR [rax+0x1be0],0x7
    1937cdf1:	07 
    1937cdf2:	0f 86 8d 3f 00 00    	jbe    19380d85 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6965>
    1937cdf8:	48 8b 80 d8 1b 00 00 	mov    rax,QWORD PTR [rax+0x1bd8]
    1937cdff:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937ce06:	48 81 39 2a 01 00 00 	cmp    QWORD PTR [rcx],0x12a
    1937ce0d:	0f 86 74 3f 00 00    	jbe    19380d87 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6967>
    1937ce13:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ce16:	c7 80 a8 04 00 00 d3 	mov    DWORD PTR [rax+0x4a8],0xd3
    1937ce1d:	00 00 00 
    1937ce20:	48 81 7b 20 2a 01 00 	cmp    QWORD PTR [rbx+0x20],0x12a
    1937ce27:	00 
    1937ce28:	0f 86 5b 3f 00 00    	jbe    19380d89 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6969>
    1937ce2e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ce32:	48 83 b8 f8 1b 00 00 	cmp    QWORD PTR [rax+0x1bf8],0x4
    1937ce39:	04 
    1937ce3a:	0f 86 4b 3f 00 00    	jbe    19380d8b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x696b>
    1937ce40:	48 8b 80 f0 1b 00 00 	mov    rax,QWORD PTR [rax+0x1bf0]
    1937ce47:	c7 40 10 14 00 00 00 	mov    DWORD PTR [rax+0x10],0x14
    1937ce4e:	49 81 7d 00 2a 01 00 	cmp    QWORD PTR [r13+0x0],0x12a
    1937ce55:	00 
    1937ce56:	0f 86 31 3f 00 00    	jbe    19380d8d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x696d>
    1937ce5c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ce60:	48 83 b8 f8 1b 00 00 	cmp    QWORD PTR [rax+0x1bf8],0x5
    1937ce67:	05 
    1937ce68:	0f 86 21 3f 00 00    	jbe    19380d8f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x696f>
    1937ce6e:	48 8b 80 f0 1b 00 00 	mov    rax,QWORD PTR [rax+0x1bf0]
    1937ce75:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937ce7c:	49 81 7d 00 2a 01 00 	cmp    QWORD PTR [r13+0x0],0x12a
    1937ce83:	00 
    1937ce84:	0f 86 07 3f 00 00    	jbe    19380d91 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6971>
    1937ce8a:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ce8e:	48 83 b8 f8 1b 00 00 	cmp    QWORD PTR [rax+0x1bf8],0x6
    1937ce95:	06 
    1937ce96:	0f 86 f7 3e 00 00    	jbe    19380d93 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6973>
    1937ce9c:	48 8b 80 f0 1b 00 00 	mov    rax,QWORD PTR [rax+0x1bf0]
    1937cea3:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937ceaa:	49 81 7d 00 2a 01 00 	cmp    QWORD PTR [r13+0x0],0x12a
    1937ceb1:	00 
    1937ceb2:	0f 86 dd 3e 00 00    	jbe    19380d95 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6975>
    1937ceb8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cebc:	48 83 b8 f8 1b 00 00 	cmp    QWORD PTR [rax+0x1bf8],0x7
    1937cec3:	07 
    1937cec4:	0f 86 cd 3e 00 00    	jbe    19380d97 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6977>
    1937ceca:	48 8b 80 f0 1b 00 00 	mov    rax,QWORD PTR [rax+0x1bf0]
    1937ced1:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937ced8:	48 81 39 2b 01 00 00 	cmp    QWORD PTR [rcx],0x12b
    1937cedf:	0f 86 b4 3e 00 00    	jbe    19380d99 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6979>
    1937cee5:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937cee8:	c7 80 ac 04 00 00 d3 	mov    DWORD PTR [rax+0x4ac],0xd3
    1937ceef:	00 00 00 
    1937cef2:	48 81 7b 20 2b 01 00 	cmp    QWORD PTR [rbx+0x20],0x12b
    1937cef9:	00 
    1937cefa:	0f 86 9b 3e 00 00    	jbe    19380d9b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x697b>
    1937cf00:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cf04:	48 83 b8 10 1c 00 00 	cmp    QWORD PTR [rax+0x1c10],0x4
    1937cf0b:	04 
    1937cf0c:	0f 86 8b 3e 00 00    	jbe    19380d9d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x697d>
    1937cf12:	48 8b 80 08 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c08]
    1937cf19:	c7 40 10 14 00 00 00 	mov    DWORD PTR [rax+0x10],0x14
    1937cf20:	49 81 7d 00 2b 01 00 	cmp    QWORD PTR [r13+0x0],0x12b
    1937cf27:	00 
    1937cf28:	0f 86 71 3e 00 00    	jbe    19380d9f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x697f>
    1937cf2e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cf32:	48 83 b8 10 1c 00 00 	cmp    QWORD PTR [rax+0x1c10],0x5
    1937cf39:	05 
    1937cf3a:	0f 86 61 3e 00 00    	jbe    19380da1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6981>
    1937cf40:	48 8b 80 08 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c08]
    1937cf47:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937cf4e:	49 81 7d 00 2b 01 00 	cmp    QWORD PTR [r13+0x0],0x12b
    1937cf55:	00 
    1937cf56:	0f 86 47 3e 00 00    	jbe    19380da3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6983>
    1937cf5c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cf60:	48 83 b8 10 1c 00 00 	cmp    QWORD PTR [rax+0x1c10],0x6
    1937cf67:	06 
    1937cf68:	0f 86 37 3e 00 00    	jbe    19380da5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6985>
    1937cf6e:	48 8b 80 08 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c08]
    1937cf75:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937cf7c:	49 81 7d 00 2b 01 00 	cmp    QWORD PTR [r13+0x0],0x12b
    1937cf83:	00 
    1937cf84:	0f 86 1d 3e 00 00    	jbe    19380da7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6987>
    1937cf8a:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cf8e:	48 83 b8 10 1c 00 00 	cmp    QWORD PTR [rax+0x1c10],0x7
    1937cf95:	07 
    1937cf96:	0f 86 0d 3e 00 00    	jbe    19380da9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6989>
    1937cf9c:	48 8b 80 08 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c08]
    1937cfa3:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937cfaa:	48 81 39 2c 01 00 00 	cmp    QWORD PTR [rcx],0x12c
    1937cfb1:	0f 86 f4 3d 00 00    	jbe    19380dab <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x698b>
    1937cfb7:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937cfba:	c7 80 b0 04 00 00 d3 	mov    DWORD PTR [rax+0x4b0],0xd3
    1937cfc1:	00 00 00 
    1937cfc4:	48 81 7b 20 2c 01 00 	cmp    QWORD PTR [rbx+0x20],0x12c
    1937cfcb:	00 
    1937cfcc:	0f 86 db 3d 00 00    	jbe    19380dad <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x698d>
    1937cfd2:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937cfd6:	48 83 b8 28 1c 00 00 	cmp    QWORD PTR [rax+0x1c28],0x4
    1937cfdd:	04 
    1937cfde:	0f 86 cb 3d 00 00    	jbe    19380daf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x698f>
    1937cfe4:	48 8b 80 20 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c20]
    1937cfeb:	c7 40 10 14 00 00 00 	mov    DWORD PTR [rax+0x10],0x14
    1937cff2:	49 81 7d 00 2c 01 00 	cmp    QWORD PTR [r13+0x0],0x12c
    1937cff9:	00 
    1937cffa:	0f 86 b1 3d 00 00    	jbe    19380db1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6991>
    1937d000:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d004:	48 83 b8 28 1c 00 00 	cmp    QWORD PTR [rax+0x1c28],0x5
    1937d00b:	05 
    1937d00c:	0f 86 a1 3d 00 00    	jbe    19380db3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6993>
    1937d012:	48 8b 80 20 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c20]
    1937d019:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937d020:	49 81 7d 00 2c 01 00 	cmp    QWORD PTR [r13+0x0],0x12c
    1937d027:	00 
    1937d028:	0f 86 87 3d 00 00    	jbe    19380db5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6995>
    1937d02e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d032:	48 83 b8 28 1c 00 00 	cmp    QWORD PTR [rax+0x1c28],0x6
    1937d039:	06 
    1937d03a:	0f 86 77 3d 00 00    	jbe    19380db7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6997>
    1937d040:	48 8b 80 20 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c20]
    1937d047:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937d04e:	49 81 7d 00 2c 01 00 	cmp    QWORD PTR [r13+0x0],0x12c
    1937d055:	00 
    1937d056:	0f 86 5d 3d 00 00    	jbe    19380db9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6999>
    1937d05c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d060:	48 83 b8 28 1c 00 00 	cmp    QWORD PTR [rax+0x1c28],0x7
    1937d067:	07 
    1937d068:	0f 86 4d 3d 00 00    	jbe    19380dbb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x699b>
    1937d06e:	48 8b 80 20 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c20]
    1937d075:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937d07c:	48 81 39 2d 01 00 00 	cmp    QWORD PTR [rcx],0x12d
    1937d083:	0f 86 34 3d 00 00    	jbe    19380dbd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x699d>
    1937d089:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d08c:	c7 80 b4 04 00 00 cc 	mov    DWORD PTR [rax+0x4b4],0xcc
    1937d093:	00 00 00 
    1937d096:	48 81 7b 20 2d 01 00 	cmp    QWORD PTR [rbx+0x20],0x12d
    1937d09d:	00 
    1937d09e:	0f 86 1b 3d 00 00    	jbe    19380dbf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x699f>
    1937d0a4:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d0a8:	48 83 b8 40 1c 00 00 	cmp    QWORD PTR [rax+0x1c40],0x5
    1937d0af:	05 
    1937d0b0:	0f 86 0b 3d 00 00    	jbe    19380dc1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69a1>
    1937d0b6:	48 8b 80 38 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c38]
    1937d0bd:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937d0c4:	49 81 7d 00 2d 01 00 	cmp    QWORD PTR [r13+0x0],0x12d
    1937d0cb:	00 
    1937d0cc:	0f 86 f1 3c 00 00    	jbe    19380dc3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69a3>
    1937d0d2:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d0d6:	48 83 b8 40 1c 00 00 	cmp    QWORD PTR [rax+0x1c40],0x6
    1937d0dd:	06 
    1937d0de:	0f 86 e1 3c 00 00    	jbe    19380dc5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69a5>
    1937d0e4:	48 8b 80 38 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c38]
    1937d0eb:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937d0f2:	49 81 7d 00 2d 01 00 	cmp    QWORD PTR [r13+0x0],0x12d
    1937d0f9:	00 
    1937d0fa:	0f 86 c7 3c 00 00    	jbe    19380dc7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69a7>
    1937d100:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d104:	48 83 b8 40 1c 00 00 	cmp    QWORD PTR [rax+0x1c40],0x7
    1937d10b:	07 
    1937d10c:	0f 86 b7 3c 00 00    	jbe    19380dc9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69a9>
    1937d112:	48 8b 80 38 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c38]
    1937d119:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937d120:	48 81 39 2e 01 00 00 	cmp    QWORD PTR [rcx],0x12e
    1937d127:	0f 86 9e 3c 00 00    	jbe    19380dcb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69ab>
    1937d12d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d130:	c7 80 b8 04 00 00 cc 	mov    DWORD PTR [rax+0x4b8],0xcc
    1937d137:	00 00 00 
    1937d13a:	48 81 7b 20 2e 01 00 	cmp    QWORD PTR [rbx+0x20],0x12e
    1937d141:	00 
    1937d142:	0f 86 85 3c 00 00    	jbe    19380dcd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69ad>
    1937d148:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d14c:	48 83 b8 58 1c 00 00 	cmp    QWORD PTR [rax+0x1c58],0x5
    1937d153:	05 
    1937d154:	0f 86 75 3c 00 00    	jbe    19380dcf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69af>
    1937d15a:	48 8b 80 50 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c50]
    1937d161:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937d168:	49 81 7d 00 2e 01 00 	cmp    QWORD PTR [r13+0x0],0x12e
    1937d16f:	00 
    1937d170:	0f 86 5b 3c 00 00    	jbe    19380dd1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69b1>
    1937d176:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d17a:	48 83 b8 58 1c 00 00 	cmp    QWORD PTR [rax+0x1c58],0x6
    1937d181:	06 
    1937d182:	0f 86 4b 3c 00 00    	jbe    19380dd3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69b3>
    1937d188:	48 8b 80 50 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c50]
    1937d18f:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937d196:	49 81 7d 00 2e 01 00 	cmp    QWORD PTR [r13+0x0],0x12e
    1937d19d:	00 
    1937d19e:	0f 86 31 3c 00 00    	jbe    19380dd5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69b5>
    1937d1a4:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d1a8:	48 83 b8 58 1c 00 00 	cmp    QWORD PTR [rax+0x1c58],0x7
    1937d1af:	07 
    1937d1b0:	0f 86 21 3c 00 00    	jbe    19380dd7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69b7>
    1937d1b6:	48 8b 80 50 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c50]
    1937d1bd:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937d1c4:	48 81 39 2f 01 00 00 	cmp    QWORD PTR [rcx],0x12f
    1937d1cb:	0f 86 08 3c 00 00    	jbe    19380dd9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69b9>
    1937d1d1:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d1d4:	c7 80 bc 04 00 00 cc 	mov    DWORD PTR [rax+0x4bc],0xcc
    1937d1db:	00 00 00 
    1937d1de:	48 81 7b 20 2f 01 00 	cmp    QWORD PTR [rbx+0x20],0x12f
    1937d1e5:	00 
    1937d1e6:	0f 86 ef 3b 00 00    	jbe    19380ddb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69bb>
    1937d1ec:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d1f0:	48 83 b8 70 1c 00 00 	cmp    QWORD PTR [rax+0x1c70],0x5
    1937d1f7:	05 
    1937d1f8:	0f 86 df 3b 00 00    	jbe    19380ddd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69bd>
    1937d1fe:	48 8b 80 68 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c68]
    1937d205:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937d20c:	49 81 7d 00 2f 01 00 	cmp    QWORD PTR [r13+0x0],0x12f
    1937d213:	00 
    1937d214:	0f 86 c5 3b 00 00    	jbe    19380ddf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69bf>
    1937d21a:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d21e:	48 83 b8 70 1c 00 00 	cmp    QWORD PTR [rax+0x1c70],0x6
    1937d225:	06 
    1937d226:	0f 86 b5 3b 00 00    	jbe    19380de1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69c1>
    1937d22c:	48 8b 80 68 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c68]
    1937d233:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937d23a:	49 81 7d 00 2f 01 00 	cmp    QWORD PTR [r13+0x0],0x12f
    1937d241:	00 
    1937d242:	0f 86 9b 3b 00 00    	jbe    19380de3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69c3>
    1937d248:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d24c:	48 83 b8 70 1c 00 00 	cmp    QWORD PTR [rax+0x1c70],0x7
    1937d253:	07 
    1937d254:	0f 86 8b 3b 00 00    	jbe    19380de5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69c5>
    1937d25a:	48 8b 80 68 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c68]
    1937d261:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937d268:	48 81 39 30 01 00 00 	cmp    QWORD PTR [rcx],0x130
    1937d26f:	0f 86 72 3b 00 00    	jbe    19380de7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69c7>
    1937d275:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d278:	c7 80 c0 04 00 00 cc 	mov    DWORD PTR [rax+0x4c0],0xcc
    1937d27f:	00 00 00 
    1937d282:	48 81 7b 20 30 01 00 	cmp    QWORD PTR [rbx+0x20],0x130
    1937d289:	00 
    1937d28a:	0f 86 59 3b 00 00    	jbe    19380de9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69c9>
    1937d290:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d294:	48 83 b8 88 1c 00 00 	cmp    QWORD PTR [rax+0x1c88],0x5
    1937d29b:	05 
    1937d29c:	0f 86 49 3b 00 00    	jbe    19380deb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69cb>
    1937d2a2:	48 8b 80 80 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c80]
    1937d2a9:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937d2b0:	49 81 7d 00 30 01 00 	cmp    QWORD PTR [r13+0x0],0x130
    1937d2b7:	00 
    1937d2b8:	0f 86 2f 3b 00 00    	jbe    19380ded <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69cd>
    1937d2be:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d2c2:	48 83 b8 88 1c 00 00 	cmp    QWORD PTR [rax+0x1c88],0x6
    1937d2c9:	06 
    1937d2ca:	0f 86 1f 3b 00 00    	jbe    19380def <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69cf>
    1937d2d0:	48 8b 80 80 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c80]
    1937d2d7:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937d2de:	49 81 7d 00 30 01 00 	cmp    QWORD PTR [r13+0x0],0x130
    1937d2e5:	00 
    1937d2e6:	0f 86 05 3b 00 00    	jbe    19380df1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69d1>
    1937d2ec:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d2f0:	48 83 b8 88 1c 00 00 	cmp    QWORD PTR [rax+0x1c88],0x7
    1937d2f7:	07 
    1937d2f8:	0f 86 f5 3a 00 00    	jbe    19380df3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69d3>
    1937d2fe:	48 8b 80 80 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c80]
    1937d305:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937d30c:	48 81 39 31 01 00 00 	cmp    QWORD PTR [rcx],0x131
    1937d313:	0f 86 dc 3a 00 00    	jbe    19380df5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69d5>
    1937d319:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d31c:	c7 80 c4 04 00 00 cc 	mov    DWORD PTR [rax+0x4c4],0xcc
    1937d323:	00 00 00 
    1937d326:	48 81 7b 20 31 01 00 	cmp    QWORD PTR [rbx+0x20],0x131
    1937d32d:	00 
    1937d32e:	0f 86 c3 3a 00 00    	jbe    19380df7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69d7>
    1937d334:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d338:	48 83 b8 a0 1c 00 00 	cmp    QWORD PTR [rax+0x1ca0],0x5
    1937d33f:	05 
    1937d340:	0f 86 b3 3a 00 00    	jbe    19380df9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69d9>
    1937d346:	48 8b 80 98 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c98]
    1937d34d:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937d354:	49 81 7d 00 31 01 00 	cmp    QWORD PTR [r13+0x0],0x131
    1937d35b:	00 
    1937d35c:	0f 86 99 3a 00 00    	jbe    19380dfb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69db>
    1937d362:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d366:	48 83 b8 a0 1c 00 00 	cmp    QWORD PTR [rax+0x1ca0],0x6
    1937d36d:	06 
    1937d36e:	0f 86 89 3a 00 00    	jbe    19380dfd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69dd>
    1937d374:	48 8b 80 98 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c98]
    1937d37b:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937d382:	49 81 7d 00 31 01 00 	cmp    QWORD PTR [r13+0x0],0x131
    1937d389:	00 
    1937d38a:	0f 86 6f 3a 00 00    	jbe    19380dff <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69df>
    1937d390:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d394:	48 83 b8 a0 1c 00 00 	cmp    QWORD PTR [rax+0x1ca0],0x7
    1937d39b:	07 
    1937d39c:	0f 86 5f 3a 00 00    	jbe    19380e01 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69e1>
    1937d3a2:	48 8b 80 98 1c 00 00 	mov    rax,QWORD PTR [rax+0x1c98]
    1937d3a9:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937d3b0:	48 81 39 32 01 00 00 	cmp    QWORD PTR [rcx],0x132
    1937d3b7:	0f 86 46 3a 00 00    	jbe    19380e03 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69e3>
    1937d3bd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d3c0:	c7 80 c8 04 00 00 cc 	mov    DWORD PTR [rax+0x4c8],0xcc
    1937d3c7:	00 00 00 
    1937d3ca:	48 81 7b 20 32 01 00 	cmp    QWORD PTR [rbx+0x20],0x132
    1937d3d1:	00 
    1937d3d2:	0f 86 2d 3a 00 00    	jbe    19380e05 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69e5>
    1937d3d8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d3dc:	48 83 b8 b8 1c 00 00 	cmp    QWORD PTR [rax+0x1cb8],0x5
    1937d3e3:	05 
    1937d3e4:	0f 86 1d 3a 00 00    	jbe    19380e07 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69e7>
    1937d3ea:	48 8b 80 b0 1c 00 00 	mov    rax,QWORD PTR [rax+0x1cb0]
    1937d3f1:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937d3f8:	49 81 7d 00 32 01 00 	cmp    QWORD PTR [r13+0x0],0x132
    1937d3ff:	00 
    1937d400:	0f 86 03 3a 00 00    	jbe    19380e09 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69e9>
    1937d406:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d40a:	48 83 b8 b8 1c 00 00 	cmp    QWORD PTR [rax+0x1cb8],0x6
    1937d411:	06 
    1937d412:	0f 86 f3 39 00 00    	jbe    19380e0b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69eb>
    1937d418:	48 8b 80 b0 1c 00 00 	mov    rax,QWORD PTR [rax+0x1cb0]
    1937d41f:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937d426:	49 81 7d 00 32 01 00 	cmp    QWORD PTR [r13+0x0],0x132
    1937d42d:	00 
    1937d42e:	0f 86 d9 39 00 00    	jbe    19380e0d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69ed>
    1937d434:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d438:	48 83 b8 b8 1c 00 00 	cmp    QWORD PTR [rax+0x1cb8],0x7
    1937d43f:	07 
    1937d440:	0f 86 c9 39 00 00    	jbe    19380e0f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69ef>
    1937d446:	48 8b 80 b0 1c 00 00 	mov    rax,QWORD PTR [rax+0x1cb0]
    1937d44d:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937d454:	48 81 39 33 01 00 00 	cmp    QWORD PTR [rcx],0x133
    1937d45b:	0f 86 b0 39 00 00    	jbe    19380e11 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69f1>
    1937d461:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d464:	c7 80 cc 04 00 00 cc 	mov    DWORD PTR [rax+0x4cc],0xcc
    1937d46b:	00 00 00 
    1937d46e:	48 81 7b 20 33 01 00 	cmp    QWORD PTR [rbx+0x20],0x133
    1937d475:	00 
    1937d476:	0f 86 97 39 00 00    	jbe    19380e13 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69f3>
    1937d47c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d480:	48 83 b8 d0 1c 00 00 	cmp    QWORD PTR [rax+0x1cd0],0x5
    1937d487:	05 
    1937d488:	0f 86 87 39 00 00    	jbe    19380e15 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69f5>
    1937d48e:	48 8b 80 c8 1c 00 00 	mov    rax,QWORD PTR [rax+0x1cc8]
    1937d495:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937d49c:	49 81 7d 00 33 01 00 	cmp    QWORD PTR [r13+0x0],0x133
    1937d4a3:	00 
    1937d4a4:	0f 86 6d 39 00 00    	jbe    19380e17 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69f7>
    1937d4aa:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d4ae:	48 83 b8 d0 1c 00 00 	cmp    QWORD PTR [rax+0x1cd0],0x6
    1937d4b5:	06 
    1937d4b6:	0f 86 5d 39 00 00    	jbe    19380e19 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69f9>
    1937d4bc:	48 8b 80 c8 1c 00 00 	mov    rax,QWORD PTR [rax+0x1cc8]
    1937d4c3:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937d4ca:	49 81 7d 00 33 01 00 	cmp    QWORD PTR [r13+0x0],0x133
    1937d4d1:	00 
    1937d4d2:	0f 86 43 39 00 00    	jbe    19380e1b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69fb>
    1937d4d8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d4dc:	48 83 b8 d0 1c 00 00 	cmp    QWORD PTR [rax+0x1cd0],0x7
    1937d4e3:	07 
    1937d4e4:	0f 86 33 39 00 00    	jbe    19380e1d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69fd>
    1937d4ea:	48 8b 80 c8 1c 00 00 	mov    rax,QWORD PTR [rax+0x1cc8]
    1937d4f1:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937d4f8:	48 81 39 34 01 00 00 	cmp    QWORD PTR [rcx],0x134
    1937d4ff:	0f 86 1a 39 00 00    	jbe    19380e1f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x69ff>
    1937d505:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d508:	c7 80 d0 04 00 00 cc 	mov    DWORD PTR [rax+0x4d0],0xcc
    1937d50f:	00 00 00 
    1937d512:	48 81 7b 20 34 01 00 	cmp    QWORD PTR [rbx+0x20],0x134
    1937d519:	00 
    1937d51a:	0f 86 01 39 00 00    	jbe    19380e21 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a01>
    1937d520:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d524:	48 83 b8 e8 1c 00 00 	cmp    QWORD PTR [rax+0x1ce8],0x5
    1937d52b:	05 
    1937d52c:	0f 86 f1 38 00 00    	jbe    19380e23 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a03>
    1937d532:	48 8b 80 e0 1c 00 00 	mov    rax,QWORD PTR [rax+0x1ce0]
    1937d539:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937d540:	49 81 7d 00 34 01 00 	cmp    QWORD PTR [r13+0x0],0x134
    1937d547:	00 
    1937d548:	0f 86 d7 38 00 00    	jbe    19380e25 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a05>
    1937d54e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d552:	48 83 b8 e8 1c 00 00 	cmp    QWORD PTR [rax+0x1ce8],0x6
    1937d559:	06 
    1937d55a:	0f 86 c7 38 00 00    	jbe    19380e27 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a07>
    1937d560:	48 8b 80 e0 1c 00 00 	mov    rax,QWORD PTR [rax+0x1ce0]
    1937d567:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937d56e:	49 81 7d 00 34 01 00 	cmp    QWORD PTR [r13+0x0],0x134
    1937d575:	00 
    1937d576:	0f 86 ad 38 00 00    	jbe    19380e29 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a09>
    1937d57c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d580:	48 83 b8 e8 1c 00 00 	cmp    QWORD PTR [rax+0x1ce8],0x7
    1937d587:	07 
    1937d588:	0f 86 9d 38 00 00    	jbe    19380e2b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a0b>
    1937d58e:	48 8b 80 e0 1c 00 00 	mov    rax,QWORD PTR [rax+0x1ce0]
    1937d595:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937d59c:	48 81 39 35 01 00 00 	cmp    QWORD PTR [rcx],0x135
    1937d5a3:	0f 86 84 38 00 00    	jbe    19380e2d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a0d>
    1937d5a9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d5ac:	c7 80 d4 04 00 00 cc 	mov    DWORD PTR [rax+0x4d4],0xcc
    1937d5b3:	00 00 00 
    1937d5b6:	48 81 7b 20 35 01 00 	cmp    QWORD PTR [rbx+0x20],0x135
    1937d5bd:	00 
    1937d5be:	0f 86 6b 38 00 00    	jbe    19380e2f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a0f>
    1937d5c4:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d5c8:	48 83 b8 00 1d 00 00 	cmp    QWORD PTR [rax+0x1d00],0x5
    1937d5cf:	05 
    1937d5d0:	0f 86 5b 38 00 00    	jbe    19380e31 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a11>
    1937d5d6:	48 8b 80 f8 1c 00 00 	mov    rax,QWORD PTR [rax+0x1cf8]
    1937d5dd:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937d5e4:	49 81 7d 00 35 01 00 	cmp    QWORD PTR [r13+0x0],0x135
    1937d5eb:	00 
    1937d5ec:	0f 86 41 38 00 00    	jbe    19380e33 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a13>
    1937d5f2:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d5f6:	48 83 b8 00 1d 00 00 	cmp    QWORD PTR [rax+0x1d00],0x6
    1937d5fd:	06 
    1937d5fe:	0f 86 31 38 00 00    	jbe    19380e35 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a15>
    1937d604:	48 8b 80 f8 1c 00 00 	mov    rax,QWORD PTR [rax+0x1cf8]
    1937d60b:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937d612:	49 81 7d 00 35 01 00 	cmp    QWORD PTR [r13+0x0],0x135
    1937d619:	00 
    1937d61a:	0f 86 17 38 00 00    	jbe    19380e37 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a17>
    1937d620:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d624:	48 83 b8 00 1d 00 00 	cmp    QWORD PTR [rax+0x1d00],0x7
    1937d62b:	07 
    1937d62c:	0f 86 07 38 00 00    	jbe    19380e39 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a19>
    1937d632:	48 8b 80 f8 1c 00 00 	mov    rax,QWORD PTR [rax+0x1cf8]
    1937d639:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937d640:	48 81 39 36 01 00 00 	cmp    QWORD PTR [rcx],0x136
    1937d647:	0f 86 ee 37 00 00    	jbe    19380e3b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a1b>
    1937d64d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d650:	c7 80 d8 04 00 00 cc 	mov    DWORD PTR [rax+0x4d8],0xcc
    1937d657:	00 00 00 
    1937d65a:	48 81 7b 20 36 01 00 	cmp    QWORD PTR [rbx+0x20],0x136
    1937d661:	00 
    1937d662:	0f 86 d5 37 00 00    	jbe    19380e3d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a1d>
    1937d668:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d66c:	48 83 b8 18 1d 00 00 	cmp    QWORD PTR [rax+0x1d18],0x5
    1937d673:	05 
    1937d674:	0f 86 c5 37 00 00    	jbe    19380e3f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a1f>
    1937d67a:	48 8b 80 10 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d10]
    1937d681:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937d688:	49 81 7d 00 36 01 00 	cmp    QWORD PTR [r13+0x0],0x136
    1937d68f:	00 
    1937d690:	0f 86 ab 37 00 00    	jbe    19380e41 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a21>
    1937d696:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d69a:	48 83 b8 18 1d 00 00 	cmp    QWORD PTR [rax+0x1d18],0x6
    1937d6a1:	06 
    1937d6a2:	0f 86 9b 37 00 00    	jbe    19380e43 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a23>
    1937d6a8:	48 8b 80 10 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d10]
    1937d6af:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937d6b6:	49 81 7d 00 36 01 00 	cmp    QWORD PTR [r13+0x0],0x136
    1937d6bd:	00 
    1937d6be:	0f 86 81 37 00 00    	jbe    19380e45 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a25>
    1937d6c4:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d6c8:	48 83 b8 18 1d 00 00 	cmp    QWORD PTR [rax+0x1d18],0x7
    1937d6cf:	07 
    1937d6d0:	0f 86 71 37 00 00    	jbe    19380e47 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a27>
    1937d6d6:	48 8b 80 10 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d10]
    1937d6dd:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937d6e4:	48 81 39 37 01 00 00 	cmp    QWORD PTR [rcx],0x137
    1937d6eb:	0f 86 58 37 00 00    	jbe    19380e49 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a29>
    1937d6f1:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d6f4:	c7 80 dc 04 00 00 cc 	mov    DWORD PTR [rax+0x4dc],0xcc
    1937d6fb:	00 00 00 
    1937d6fe:	48 81 7b 20 37 01 00 	cmp    QWORD PTR [rbx+0x20],0x137
    1937d705:	00 
    1937d706:	0f 86 3f 37 00 00    	jbe    19380e4b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a2b>
    1937d70c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d710:	48 83 b8 30 1d 00 00 	cmp    QWORD PTR [rax+0x1d30],0x5
    1937d717:	05 
    1937d718:	0f 86 2f 37 00 00    	jbe    19380e4d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a2d>
    1937d71e:	48 8b 80 28 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d28]
    1937d725:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937d72c:	49 81 7d 00 37 01 00 	cmp    QWORD PTR [r13+0x0],0x137
    1937d733:	00 
    1937d734:	0f 86 15 37 00 00    	jbe    19380e4f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a2f>
    1937d73a:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d73e:	48 83 b8 30 1d 00 00 	cmp    QWORD PTR [rax+0x1d30],0x6
    1937d745:	06 
    1937d746:	0f 86 05 37 00 00    	jbe    19380e51 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a31>
    1937d74c:	48 8b 80 28 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d28]
    1937d753:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937d75a:	49 81 7d 00 37 01 00 	cmp    QWORD PTR [r13+0x0],0x137
    1937d761:	00 
    1937d762:	0f 86 eb 36 00 00    	jbe    19380e53 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a33>
    1937d768:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d76c:	48 83 b8 30 1d 00 00 	cmp    QWORD PTR [rax+0x1d30],0x7
    1937d773:	07 
    1937d774:	0f 86 db 36 00 00    	jbe    19380e55 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a35>
    1937d77a:	48 8b 80 28 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d28]
    1937d781:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937d788:	48 81 39 38 01 00 00 	cmp    QWORD PTR [rcx],0x138
    1937d78f:	0f 86 c2 36 00 00    	jbe    19380e57 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a37>
    1937d795:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d798:	c7 80 e0 04 00 00 cc 	mov    DWORD PTR [rax+0x4e0],0xcc
    1937d79f:	00 00 00 
    1937d7a2:	48 81 7b 20 38 01 00 	cmp    QWORD PTR [rbx+0x20],0x138
    1937d7a9:	00 
    1937d7aa:	0f 86 a9 36 00 00    	jbe    19380e59 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a39>
    1937d7b0:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d7b4:	48 83 b8 48 1d 00 00 	cmp    QWORD PTR [rax+0x1d48],0x5
    1937d7bb:	05 
    1937d7bc:	0f 86 99 36 00 00    	jbe    19380e5b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a3b>
    1937d7c2:	48 8b 80 40 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d40]
    1937d7c9:	c7 40 14 08 00 00 00 	mov    DWORD PTR [rax+0x14],0x8
    1937d7d0:	49 81 7d 00 38 01 00 	cmp    QWORD PTR [r13+0x0],0x138
    1937d7d7:	00 
    1937d7d8:	0f 86 7f 36 00 00    	jbe    19380e5d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a3d>
    1937d7de:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d7e2:	48 83 b8 48 1d 00 00 	cmp    QWORD PTR [rax+0x1d48],0x6
    1937d7e9:	06 
    1937d7ea:	0f 86 6f 36 00 00    	jbe    19380e5f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a3f>
    1937d7f0:	48 8b 80 40 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d40]
    1937d7f7:	c7 40 18 0d 00 00 00 	mov    DWORD PTR [rax+0x18],0xd
    1937d7fe:	49 81 7d 00 38 01 00 	cmp    QWORD PTR [r13+0x0],0x138
    1937d805:	00 
    1937d806:	0f 86 55 36 00 00    	jbe    19380e61 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a41>
    1937d80c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d810:	48 83 b8 48 1d 00 00 	cmp    QWORD PTR [rax+0x1d48],0x7
    1937d817:	07 
    1937d818:	0f 86 45 36 00 00    	jbe    19380e63 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a43>
    1937d81e:	48 8b 80 40 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d40]
    1937d825:	c7 40 1c 07 00 00 00 	mov    DWORD PTR [rax+0x1c],0x7
    1937d82c:	48 81 39 39 01 00 00 	cmp    QWORD PTR [rcx],0x139
    1937d833:	0f 86 2c 36 00 00    	jbe    19380e65 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a45>
    1937d839:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d83c:	c7 80 e4 04 00 00 d3 	mov    DWORD PTR [rax+0x4e4],0xd3
    1937d843:	00 00 00 
    1937d846:	48 81 7b 20 39 01 00 	cmp    QWORD PTR [rbx+0x20],0x139
    1937d84d:	00 
    1937d84e:	0f 86 13 36 00 00    	jbe    19380e67 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a47>
    1937d854:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d858:	48 83 b8 60 1d 00 00 	cmp    QWORD PTR [rax+0x1d60],0x4
    1937d85f:	04 
    1937d860:	0f 86 03 36 00 00    	jbe    19380e69 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a49>
    1937d866:	48 8b 80 58 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d58]
    1937d86d:	c7 40 10 10 00 00 00 	mov    DWORD PTR [rax+0x10],0x10
    1937d874:	49 81 7d 00 39 01 00 	cmp    QWORD PTR [r13+0x0],0x139
    1937d87b:	00 
    1937d87c:	0f 86 e9 35 00 00    	jbe    19380e6b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a4b>
    1937d882:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d886:	48 83 b8 60 1d 00 00 	cmp    QWORD PTR [rax+0x1d60],0x5
    1937d88d:	05 
    1937d88e:	0f 86 d9 35 00 00    	jbe    19380e6d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a4d>
    1937d894:	48 8b 80 58 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d58]
    1937d89b:	c7 40 14 04 00 00 00 	mov    DWORD PTR [rax+0x14],0x4
    1937d8a2:	49 81 7d 00 39 01 00 	cmp    QWORD PTR [r13+0x0],0x139
    1937d8a9:	00 
    1937d8aa:	0f 86 bf 35 00 00    	jbe    19380e6f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a4f>
    1937d8b0:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d8b4:	48 83 b8 60 1d 00 00 	cmp    QWORD PTR [rax+0x1d60],0x6
    1937d8bb:	06 
    1937d8bc:	0f 86 af 35 00 00    	jbe    19380e71 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a51>
    1937d8c2:	48 8b 80 58 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d58]
    1937d8c9:	c7 40 18 09 00 00 00 	mov    DWORD PTR [rax+0x18],0x9
    1937d8d0:	49 81 7d 00 39 01 00 	cmp    QWORD PTR [r13+0x0],0x139
    1937d8d7:	00 
    1937d8d8:	0f 86 95 35 00 00    	jbe    19380e73 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a53>
    1937d8de:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d8e2:	48 83 b8 60 1d 00 00 	cmp    QWORD PTR [rax+0x1d60],0x7
    1937d8e9:	07 
    1937d8ea:	0f 86 85 35 00 00    	jbe    19380e75 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a55>
    1937d8f0:	48 8b 80 58 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d58]
    1937d8f7:	c7 40 1c 03 00 00 00 	mov    DWORD PTR [rax+0x1c],0x3
    1937d8fe:	48 81 39 3a 01 00 00 	cmp    QWORD PTR [rcx],0x13a
    1937d905:	0f 86 6c 35 00 00    	jbe    19380e77 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a57>
    1937d90b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d90e:	c7 80 e8 04 00 00 d3 	mov    DWORD PTR [rax+0x4e8],0xd3
    1937d915:	00 00 00 
    1937d918:	48 81 7b 20 3a 01 00 	cmp    QWORD PTR [rbx+0x20],0x13a
    1937d91f:	00 
    1937d920:	0f 86 53 35 00 00    	jbe    19380e79 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a59>
    1937d926:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d92a:	48 83 b8 78 1d 00 00 	cmp    QWORD PTR [rax+0x1d78],0x4
    1937d931:	04 
    1937d932:	0f 86 43 35 00 00    	jbe    19380e7b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a5b>
    1937d938:	48 8b 80 70 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d70]
    1937d93f:	c7 40 10 10 00 00 00 	mov    DWORD PTR [rax+0x10],0x10
    1937d946:	49 81 7d 00 3a 01 00 	cmp    QWORD PTR [r13+0x0],0x13a
    1937d94d:	00 
    1937d94e:	0f 86 29 35 00 00    	jbe    19380e7d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a5d>
    1937d954:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d958:	48 83 b8 78 1d 00 00 	cmp    QWORD PTR [rax+0x1d78],0x5
    1937d95f:	05 
    1937d960:	0f 86 19 35 00 00    	jbe    19380e7f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a5f>
    1937d966:	48 8b 80 70 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d70]
    1937d96d:	c7 40 14 04 00 00 00 	mov    DWORD PTR [rax+0x14],0x4
    1937d974:	49 81 7d 00 3a 01 00 	cmp    QWORD PTR [r13+0x0],0x13a
    1937d97b:	00 
    1937d97c:	0f 86 ff 34 00 00    	jbe    19380e81 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a61>
    1937d982:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d986:	48 83 b8 78 1d 00 00 	cmp    QWORD PTR [rax+0x1d78],0x6
    1937d98d:	06 
    1937d98e:	0f 86 ef 34 00 00    	jbe    19380e83 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a63>
    1937d994:	48 8b 80 70 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d70]
    1937d99b:	c7 40 18 09 00 00 00 	mov    DWORD PTR [rax+0x18],0x9
    1937d9a2:	49 81 7d 00 3a 01 00 	cmp    QWORD PTR [r13+0x0],0x13a
    1937d9a9:	00 
    1937d9aa:	0f 86 d5 34 00 00    	jbe    19380e85 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a65>
    1937d9b0:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d9b4:	48 83 b8 78 1d 00 00 	cmp    QWORD PTR [rax+0x1d78],0x7
    1937d9bb:	07 
    1937d9bc:	0f 86 c5 34 00 00    	jbe    19380e87 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a67>
    1937d9c2:	48 8b 80 70 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d70]
    1937d9c9:	c7 40 1c 03 00 00 00 	mov    DWORD PTR [rax+0x1c],0x3
    1937d9d0:	48 81 39 3b 01 00 00 	cmp    QWORD PTR [rcx],0x13b
    1937d9d7:	0f 86 ac 34 00 00    	jbe    19380e89 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a69>
    1937d9dd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937d9e0:	c7 80 ec 04 00 00 d3 	mov    DWORD PTR [rax+0x4ec],0xd3
    1937d9e7:	00 00 00 
    1937d9ea:	48 81 7b 20 3b 01 00 	cmp    QWORD PTR [rbx+0x20],0x13b
    1937d9f1:	00 
    1937d9f2:	0f 86 93 34 00 00    	jbe    19380e8b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a6b>
    1937d9f8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937d9fc:	48 83 b8 90 1d 00 00 	cmp    QWORD PTR [rax+0x1d90],0x4
    1937da03:	04 
    1937da04:	0f 86 83 34 00 00    	jbe    19380e8d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a6d>
    1937da0a:	48 8b 80 88 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d88]
    1937da11:	c7 40 10 10 00 00 00 	mov    DWORD PTR [rax+0x10],0x10
    1937da18:	49 81 7d 00 3b 01 00 	cmp    QWORD PTR [r13+0x0],0x13b
    1937da1f:	00 
    1937da20:	0f 86 69 34 00 00    	jbe    19380e8f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a6f>
    1937da26:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937da2a:	48 83 b8 90 1d 00 00 	cmp    QWORD PTR [rax+0x1d90],0x5
    1937da31:	05 
    1937da32:	0f 86 59 34 00 00    	jbe    19380e91 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a71>
    1937da38:	48 8b 80 88 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d88]
    1937da3f:	c7 40 14 04 00 00 00 	mov    DWORD PTR [rax+0x14],0x4
    1937da46:	49 81 7d 00 3b 01 00 	cmp    QWORD PTR [r13+0x0],0x13b
    1937da4d:	00 
    1937da4e:	0f 86 3f 34 00 00    	jbe    19380e93 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a73>
    1937da54:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937da58:	48 83 b8 90 1d 00 00 	cmp    QWORD PTR [rax+0x1d90],0x6
    1937da5f:	06 
    1937da60:	0f 86 2f 34 00 00    	jbe    19380e95 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a75>
    1937da66:	48 8b 80 88 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d88]
    1937da6d:	c7 40 18 09 00 00 00 	mov    DWORD PTR [rax+0x18],0x9
    1937da74:	49 81 7d 00 3b 01 00 	cmp    QWORD PTR [r13+0x0],0x13b
    1937da7b:	00 
    1937da7c:	0f 86 15 34 00 00    	jbe    19380e97 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a77>
    1937da82:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937da86:	48 83 b8 90 1d 00 00 	cmp    QWORD PTR [rax+0x1d90],0x7
    1937da8d:	07 
    1937da8e:	0f 86 05 34 00 00    	jbe    19380e99 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a79>
    1937da94:	48 8b 80 88 1d 00 00 	mov    rax,QWORD PTR [rax+0x1d88]
    1937da9b:	c7 40 1c 03 00 00 00 	mov    DWORD PTR [rax+0x1c],0x3
    1937daa2:	48 81 39 3c 01 00 00 	cmp    QWORD PTR [rcx],0x13c
    1937daa9:	0f 86 ec 33 00 00    	jbe    19380e9b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a7b>
    1937daaf:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937dab2:	c7 80 f0 04 00 00 01 	mov    DWORD PTR [rax+0x4f0],0x1
    1937dab9:	00 00 00 
    1937dabc:	48 81 7b 08 3d 01 00 	cmp    QWORD PTR [rbx+0x8],0x13d
    1937dac3:	00 
    1937dac4:	0f 86 d3 33 00 00    	jbe    19380e9d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a7d>
    1937daca:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937dacd:	c7 80 f4 04 00 00 01 	mov    DWORD PTR [rax+0x4f4],0x1
    1937dad4:	00 00 00 
    1937dad7:	48 81 7b 08 3e 01 00 	cmp    QWORD PTR [rbx+0x8],0x13e
    1937dade:	00 
    1937dadf:	0f 86 ba 33 00 00    	jbe    19380e9f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a7f>
    1937dae5:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937dae8:	c7 80 f8 04 00 00 01 	mov    DWORD PTR [rax+0x4f8],0x1
    1937daef:	00 00 00 
    1937daf2:	48 81 7b 08 3f 01 00 	cmp    QWORD PTR [rbx+0x8],0x13f
    1937daf9:	00 
    1937dafa:	0f 86 a1 33 00 00    	jbe    19380ea1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a81>
    1937db00:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937db03:	c7 80 fc 04 00 00 01 	mov    DWORD PTR [rax+0x4fc],0x1
    1937db0a:	00 00 00 
    1937db0d:	48 81 7b 08 40 01 00 	cmp    QWORD PTR [rbx+0x8],0x140
    1937db14:	00 
    1937db15:	0f 86 88 33 00 00    	jbe    19380ea3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a83>
    1937db1b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937db1e:	c7 80 00 05 00 00 01 	mov    DWORD PTR [rax+0x500],0x1
    1937db25:	00 00 00 
    1937db28:	48 81 7b 20 40 01 00 	cmp    QWORD PTR [rbx+0x20],0x140
    1937db2f:	00 
    1937db30:	0f 86 6f 33 00 00    	jbe    19380ea5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a85>
    1937db36:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937db3a:	48 83 b8 08 1e 00 00 	cmp    QWORD PTR [rax+0x1e08],0x8
    1937db41:	08 
    1937db42:	0f 86 5f 33 00 00    	jbe    19380ea7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a87>
    1937db48:	48 8b 80 00 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e00]
    1937db4f:	c7 40 20 34 00 00 00 	mov    DWORD PTR [rax+0x20],0x34
    1937db56:	48 81 39 41 01 00 00 	cmp    QWORD PTR [rcx],0x141
    1937db5d:	0f 86 46 33 00 00    	jbe    19380ea9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a89>
    1937db63:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937db66:	c7 80 04 05 00 00 01 	mov    DWORD PTR [rax+0x504],0x1
    1937db6d:	00 00 00 
    1937db70:	48 81 7b 20 41 01 00 	cmp    QWORD PTR [rbx+0x20],0x141
    1937db77:	00 
    1937db78:	0f 86 2d 33 00 00    	jbe    19380eab <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a8b>
    1937db7e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937db82:	48 83 b8 20 1e 00 00 	cmp    QWORD PTR [rax+0x1e20],0x8
    1937db89:	08 
    1937db8a:	0f 86 1d 33 00 00    	jbe    19380ead <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a8d>
    1937db90:	48 8b 80 18 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e18]
    1937db97:	c7 40 20 34 00 00 00 	mov    DWORD PTR [rax+0x20],0x34
    1937db9e:	48 81 39 42 01 00 00 	cmp    QWORD PTR [rcx],0x142
    1937dba5:	0f 86 04 33 00 00    	jbe    19380eaf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a8f>
    1937dbab:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937dbae:	c7 80 08 05 00 00 01 	mov    DWORD PTR [rax+0x508],0x1
    1937dbb5:	00 00 00 
    1937dbb8:	48 81 7b 20 42 01 00 	cmp    QWORD PTR [rbx+0x20],0x142
    1937dbbf:	00 
    1937dbc0:	0f 86 eb 32 00 00    	jbe    19380eb1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a91>
    1937dbc6:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937dbca:	48 83 b8 38 1e 00 00 	cmp    QWORD PTR [rax+0x1e38],0x8
    1937dbd1:	08 
    1937dbd2:	0f 86 db 32 00 00    	jbe    19380eb3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a93>
    1937dbd8:	48 8b 80 30 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e30]
    1937dbdf:	c7 40 20 34 00 00 00 	mov    DWORD PTR [rax+0x20],0x34
    1937dbe6:	48 81 39 43 01 00 00 	cmp    QWORD PTR [rcx],0x143
    1937dbed:	0f 86 c2 32 00 00    	jbe    19380eb5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a95>
    1937dbf3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937dbf6:	c7 80 0c 05 00 00 01 	mov    DWORD PTR [rax+0x50c],0x1
    1937dbfd:	00 00 00 
    1937dc00:	48 81 7b 20 43 01 00 	cmp    QWORD PTR [rbx+0x20],0x143
    1937dc07:	00 
    1937dc08:	0f 86 a9 32 00 00    	jbe    19380eb7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a97>
    1937dc0e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937dc12:	48 83 b8 50 1e 00 00 	cmp    QWORD PTR [rax+0x1e50],0x8
    1937dc19:	08 
    1937dc1a:	0f 86 99 32 00 00    	jbe    19380eb9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a99>
    1937dc20:	48 8b 80 48 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e48]
    1937dc27:	c7 40 20 34 00 00 00 	mov    DWORD PTR [rax+0x20],0x34
    1937dc2e:	48 81 39 44 01 00 00 	cmp    QWORD PTR [rcx],0x144
    1937dc35:	0f 86 80 32 00 00    	jbe    19380ebb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a9b>
    1937dc3b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937dc3e:	c7 80 10 05 00 00 04 	mov    DWORD PTR [rax+0x510],0x4
    1937dc45:	00 00 00 
    1937dc48:	48 81 7b 20 44 01 00 	cmp    QWORD PTR [rbx+0x20],0x144
    1937dc4f:	00 
    1937dc50:	0f 86 67 32 00 00    	jbe    19380ebd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a9d>
    1937dc56:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937dc5a:	48 83 b8 68 1e 00 00 	cmp    QWORD PTR [rax+0x1e68],0x9
    1937dc61:	09 
    1937dc62:	0f 86 57 32 00 00    	jbe    19380ebf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6a9f>
    1937dc68:	48 8b 80 60 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e60]
    1937dc6f:	c7 40 24 02 00 00 00 	mov    DWORD PTR [rax+0x24],0x2
    1937dc76:	49 81 7d 00 44 01 00 	cmp    QWORD PTR [r13+0x0],0x144
    1937dc7d:	00 
    1937dc7e:	0f 86 3d 32 00 00    	jbe    19380ec1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6aa1>
    1937dc84:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937dc88:	48 83 b8 68 1e 00 00 	cmp    QWORD PTR [rax+0x1e68],0xa
    1937dc8f:	0a 
    1937dc90:	0f 86 2d 32 00 00    	jbe    19380ec3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6aa3>
    1937dc96:	48 8b 80 60 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e60]
    1937dc9d:	c7 40 28 01 00 00 00 	mov    DWORD PTR [rax+0x28],0x1
    1937dca4:	49 81 7d 00 44 01 00 	cmp    QWORD PTR [r13+0x0],0x144
    1937dcab:	00 
    1937dcac:	0f 86 13 32 00 00    	jbe    19380ec5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6aa5>
    1937dcb2:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937dcb6:	48 83 b8 68 1e 00 00 	cmp    QWORD PTR [rax+0x1e68],0xb
    1937dcbd:	0b 
    1937dcbe:	0f 86 03 32 00 00    	jbe    19380ec7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6aa7>
    1937dcc4:	48 8b 80 60 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e60]
    1937dccb:	c7 40 2c 03 00 00 00 	mov    DWORD PTR [rax+0x2c],0x3
    1937dcd2:	49 81 7d 00 44 01 00 	cmp    QWORD PTR [r13+0x0],0x144
    1937dcd9:	00 
    1937dcda:	0f 86 e9 31 00 00    	jbe    19380ec9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6aa9>
    1937dce0:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937dce4:	48 83 b8 68 1e 00 00 	cmp    QWORD PTR [rax+0x1e68],0xc
    1937dceb:	0c 
    1937dcec:	0f 86 d9 31 00 00    	jbe    19380ecb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6aab>
    1937dcf2:	48 8b 80 60 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e60]
    1937dcf9:	c7 40 30 09 00 00 00 	mov    DWORD PTR [rax+0x30],0x9
    1937dd00:	48 81 39 45 01 00 00 	cmp    QWORD PTR [rcx],0x145
    1937dd07:	0f 86 c0 31 00 00    	jbe    19380ecd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6aad>
    1937dd0d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937dd10:	c7 80 14 05 00 00 08 	mov    DWORD PTR [rax+0x514],0x8
    1937dd17:	00 00 00 
    1937dd1a:	48 81 7b 20 45 01 00 	cmp    QWORD PTR [rbx+0x20],0x145
    1937dd21:	00 
    1937dd22:	0f 86 a7 31 00 00    	jbe    19380ecf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6aaf>
    1937dd28:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937dd2c:	48 83 b8 80 1e 00 00 	cmp    QWORD PTR [rax+0x1e80],0x9
    1937dd33:	09 
    1937dd34:	0f 86 97 31 00 00    	jbe    19380ed1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ab1>
    1937dd3a:	48 8b 80 78 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e78]
    1937dd41:	c7 40 24 06 00 00 00 	mov    DWORD PTR [rax+0x24],0x6
    1937dd48:	49 81 7d 00 45 01 00 	cmp    QWORD PTR [r13+0x0],0x145
    1937dd4f:	00 
    1937dd50:	0f 86 7d 31 00 00    	jbe    19380ed3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ab3>
    1937dd56:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937dd5a:	48 83 b8 80 1e 00 00 	cmp    QWORD PTR [rax+0x1e80],0xa
    1937dd61:	0a 
    1937dd62:	0f 86 6d 31 00 00    	jbe    19380ed5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ab5>
    1937dd68:	48 8b 80 78 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e78]
    1937dd6f:	c7 40 28 05 00 00 00 	mov    DWORD PTR [rax+0x28],0x5
    1937dd76:	49 81 7d 00 45 01 00 	cmp    QWORD PTR [r13+0x0],0x145
    1937dd7d:	00 
    1937dd7e:	0f 86 53 31 00 00    	jbe    19380ed7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ab7>
    1937dd84:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937dd88:	48 83 b8 80 1e 00 00 	cmp    QWORD PTR [rax+0x1e80],0xb
    1937dd8f:	0b 
    1937dd90:	0f 86 43 31 00 00    	jbe    19380ed9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ab9>
    1937dd96:	48 8b 80 78 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e78]
    1937dd9d:	c7 40 2c 07 00 00 00 	mov    DWORD PTR [rax+0x2c],0x7
    1937dda4:	49 81 7d 00 45 01 00 	cmp    QWORD PTR [r13+0x0],0x145
    1937ddab:	00 
    1937ddac:	0f 86 29 31 00 00    	jbe    19380edb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6abb>
    1937ddb2:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ddb6:	48 83 b8 80 1e 00 00 	cmp    QWORD PTR [rax+0x1e80],0xc
    1937ddbd:	0c 
    1937ddbe:	0f 86 19 31 00 00    	jbe    19380edd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6abd>
    1937ddc4:	48 8b 80 78 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e78]
    1937ddcb:	c7 40 30 0d 00 00 00 	mov    DWORD PTR [rax+0x30],0xd
    1937ddd2:	48 81 39 46 01 00 00 	cmp    QWORD PTR [rcx],0x146
    1937ddd9:	0f 86 00 31 00 00    	jbe    19380edf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6abf>
    1937dddf:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937dde2:	c7 80 18 05 00 00 08 	mov    DWORD PTR [rax+0x518],0x8
    1937dde9:	00 00 00 
    1937ddec:	48 81 7b 20 46 01 00 	cmp    QWORD PTR [rbx+0x20],0x146
    1937ddf3:	00 
    1937ddf4:	0f 86 e7 30 00 00    	jbe    19380ee1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ac1>
    1937ddfa:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ddfe:	48 83 b8 98 1e 00 00 	cmp    QWORD PTR [rax+0x1e98],0x9
    1937de05:	09 
    1937de06:	0f 86 d7 30 00 00    	jbe    19380ee3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ac3>
    1937de0c:	48 8b 80 90 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e90]
    1937de13:	c7 40 24 06 00 00 00 	mov    DWORD PTR [rax+0x24],0x6
    1937de1a:	49 81 7d 00 46 01 00 	cmp    QWORD PTR [r13+0x0],0x146
    1937de21:	00 
    1937de22:	0f 86 bd 30 00 00    	jbe    19380ee5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ac5>
    1937de28:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937de2c:	48 83 b8 98 1e 00 00 	cmp    QWORD PTR [rax+0x1e98],0xa
    1937de33:	0a 
    1937de34:	0f 86 ad 30 00 00    	jbe    19380ee7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ac7>
    1937de3a:	48 8b 80 90 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e90]
    1937de41:	c7 40 28 05 00 00 00 	mov    DWORD PTR [rax+0x28],0x5
    1937de48:	49 81 7d 00 46 01 00 	cmp    QWORD PTR [r13+0x0],0x146
    1937de4f:	00 
    1937de50:	0f 86 93 30 00 00    	jbe    19380ee9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ac9>
    1937de56:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937de5a:	48 83 b8 98 1e 00 00 	cmp    QWORD PTR [rax+0x1e98],0xb
    1937de61:	0b 
    1937de62:	0f 86 83 30 00 00    	jbe    19380eeb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6acb>
    1937de68:	48 8b 80 90 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e90]
    1937de6f:	c7 40 2c 07 00 00 00 	mov    DWORD PTR [rax+0x2c],0x7
    1937de76:	49 81 7d 00 46 01 00 	cmp    QWORD PTR [r13+0x0],0x146
    1937de7d:	00 
    1937de7e:	0f 86 69 30 00 00    	jbe    19380eed <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6acd>
    1937de84:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937de88:	48 83 b8 98 1e 00 00 	cmp    QWORD PTR [rax+0x1e98],0xc
    1937de8f:	0c 
    1937de90:	0f 86 59 30 00 00    	jbe    19380eef <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6acf>
    1937de96:	48 8b 80 90 1e 00 00 	mov    rax,QWORD PTR [rax+0x1e90]
    1937de9d:	c7 40 30 0d 00 00 00 	mov    DWORD PTR [rax+0x30],0xd
    1937dea4:	48 81 39 47 01 00 00 	cmp    QWORD PTR [rcx],0x147
    1937deab:	0f 86 40 30 00 00    	jbe    19380ef1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ad1>
    1937deb1:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937deb4:	c7 80 1c 05 00 00 08 	mov    DWORD PTR [rax+0x51c],0x8
    1937debb:	00 00 00 
    1937debe:	48 81 7b 20 47 01 00 	cmp    QWORD PTR [rbx+0x20],0x147
    1937dec5:	00 
    1937dec6:	0f 86 27 30 00 00    	jbe    19380ef3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ad3>
    1937decc:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ded0:	48 83 b8 b0 1e 00 00 	cmp    QWORD PTR [rax+0x1eb0],0x9
    1937ded7:	09 
    1937ded8:	0f 86 17 30 00 00    	jbe    19380ef5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ad5>
    1937dede:	48 8b 80 a8 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ea8]
    1937dee5:	c7 40 24 06 00 00 00 	mov    DWORD PTR [rax+0x24],0x6
    1937deec:	49 81 7d 00 47 01 00 	cmp    QWORD PTR [r13+0x0],0x147
    1937def3:	00 
    1937def4:	0f 86 fd 2f 00 00    	jbe    19380ef7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ad7>
    1937defa:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937defe:	48 83 b8 b0 1e 00 00 	cmp    QWORD PTR [rax+0x1eb0],0xa
    1937df05:	0a 
    1937df06:	0f 86 ed 2f 00 00    	jbe    19380ef9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ad9>
    1937df0c:	48 8b 80 a8 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ea8]
    1937df13:	c7 40 28 05 00 00 00 	mov    DWORD PTR [rax+0x28],0x5
    1937df1a:	49 81 7d 00 47 01 00 	cmp    QWORD PTR [r13+0x0],0x147
    1937df21:	00 
    1937df22:	0f 86 d3 2f 00 00    	jbe    19380efb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6adb>
    1937df28:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937df2c:	48 83 b8 b0 1e 00 00 	cmp    QWORD PTR [rax+0x1eb0],0xb
    1937df33:	0b 
    1937df34:	0f 86 c3 2f 00 00    	jbe    19380efd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6add>
    1937df3a:	48 8b 80 a8 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ea8]
    1937df41:	c7 40 2c 07 00 00 00 	mov    DWORD PTR [rax+0x2c],0x7
    1937df48:	49 81 7d 00 47 01 00 	cmp    QWORD PTR [r13+0x0],0x147
    1937df4f:	00 
    1937df50:	0f 86 a9 2f 00 00    	jbe    19380eff <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6adf>
    1937df56:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937df5a:	48 83 b8 b0 1e 00 00 	cmp    QWORD PTR [rax+0x1eb0],0xc
    1937df61:	0c 
    1937df62:	0f 86 99 2f 00 00    	jbe    19380f01 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ae1>
    1937df68:	48 8b 80 a8 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ea8]
    1937df6f:	c7 40 30 0d 00 00 00 	mov    DWORD PTR [rax+0x30],0xd
    1937df76:	48 81 39 48 01 00 00 	cmp    QWORD PTR [rcx],0x148
    1937df7d:	0f 86 80 2f 00 00    	jbe    19380f03 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ae3>
    1937df83:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937df86:	c7 80 20 05 00 00 04 	mov    DWORD PTR [rax+0x520],0x4
    1937df8d:	00 00 00 
    1937df90:	48 81 7b 20 48 01 00 	cmp    QWORD PTR [rbx+0x20],0x148
    1937df97:	00 
    1937df98:	0f 86 67 2f 00 00    	jbe    19380f05 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ae5>
    1937df9e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937dfa2:	48 83 b8 c8 1e 00 00 	cmp    QWORD PTR [rax+0x1ec8],0x9
    1937dfa9:	09 
    1937dfaa:	0f 86 57 2f 00 00    	jbe    19380f07 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ae7>
    1937dfb0:	48 8b 80 c0 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ec0]
    1937dfb7:	c7 40 24 02 00 00 00 	mov    DWORD PTR [rax+0x24],0x2
    1937dfbe:	49 81 7d 00 48 01 00 	cmp    QWORD PTR [r13+0x0],0x148
    1937dfc5:	00 
    1937dfc6:	0f 86 3d 2f 00 00    	jbe    19380f09 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ae9>
    1937dfcc:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937dfd0:	48 83 b8 c8 1e 00 00 	cmp    QWORD PTR [rax+0x1ec8],0xa
    1937dfd7:	0a 
    1937dfd8:	0f 86 2d 2f 00 00    	jbe    19380f0b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6aeb>
    1937dfde:	48 8b 80 c0 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ec0]
    1937dfe5:	c7 40 28 01 00 00 00 	mov    DWORD PTR [rax+0x28],0x1
    1937dfec:	49 81 7d 00 48 01 00 	cmp    QWORD PTR [r13+0x0],0x148
    1937dff3:	00 
    1937dff4:	0f 86 13 2f 00 00    	jbe    19380f0d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6aed>
    1937dffa:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937dffe:	48 83 b8 c8 1e 00 00 	cmp    QWORD PTR [rax+0x1ec8],0xb
    1937e005:	0b 
    1937e006:	0f 86 03 2f 00 00    	jbe    19380f0f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6aef>
    1937e00c:	48 8b 80 c0 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ec0]
    1937e013:	c7 40 2c 03 00 00 00 	mov    DWORD PTR [rax+0x2c],0x3
    1937e01a:	49 81 7d 00 48 01 00 	cmp    QWORD PTR [r13+0x0],0x148
    1937e021:	00 
    1937e022:	0f 86 e9 2e 00 00    	jbe    19380f11 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6af1>
    1937e028:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e02c:	48 83 b8 c8 1e 00 00 	cmp    QWORD PTR [rax+0x1ec8],0xc
    1937e033:	0c 
    1937e034:	0f 86 d9 2e 00 00    	jbe    19380f13 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6af3>
    1937e03a:	48 8b 80 c0 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ec0]
    1937e041:	c7 40 30 09 00 00 00 	mov    DWORD PTR [rax+0x30],0x9
    1937e048:	48 81 39 49 01 00 00 	cmp    QWORD PTR [rcx],0x149
    1937e04f:	0f 86 c0 2e 00 00    	jbe    19380f15 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6af5>
    1937e055:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937e058:	c7 80 24 05 00 00 08 	mov    DWORD PTR [rax+0x524],0x8
    1937e05f:	00 00 00 
    1937e062:	48 81 7b 20 49 01 00 	cmp    QWORD PTR [rbx+0x20],0x149
    1937e069:	00 
    1937e06a:	0f 86 a7 2e 00 00    	jbe    19380f17 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6af7>
    1937e070:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e074:	48 83 b8 e0 1e 00 00 	cmp    QWORD PTR [rax+0x1ee0],0x9
    1937e07b:	09 
    1937e07c:	0f 86 97 2e 00 00    	jbe    19380f19 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6af9>
    1937e082:	48 8b 80 d8 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ed8]
    1937e089:	c7 40 24 06 00 00 00 	mov    DWORD PTR [rax+0x24],0x6
    1937e090:	49 81 7d 00 49 01 00 	cmp    QWORD PTR [r13+0x0],0x149
    1937e097:	00 
    1937e098:	0f 86 7d 2e 00 00    	jbe    19380f1b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6afb>
    1937e09e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e0a2:	48 83 b8 e0 1e 00 00 	cmp    QWORD PTR [rax+0x1ee0],0xa
    1937e0a9:	0a 
    1937e0aa:	0f 86 6d 2e 00 00    	jbe    19380f1d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6afd>
    1937e0b0:	48 8b 80 d8 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ed8]
    1937e0b7:	c7 40 28 05 00 00 00 	mov    DWORD PTR [rax+0x28],0x5
    1937e0be:	49 81 7d 00 49 01 00 	cmp    QWORD PTR [r13+0x0],0x149
    1937e0c5:	00 
    1937e0c6:	0f 86 53 2e 00 00    	jbe    19380f1f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6aff>
    1937e0cc:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e0d0:	48 83 b8 e0 1e 00 00 	cmp    QWORD PTR [rax+0x1ee0],0xb
    1937e0d7:	0b 
    1937e0d8:	0f 86 43 2e 00 00    	jbe    19380f21 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b01>
    1937e0de:	48 8b 80 d8 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ed8]
    1937e0e5:	c7 40 2c 07 00 00 00 	mov    DWORD PTR [rax+0x2c],0x7
    1937e0ec:	49 81 7d 00 49 01 00 	cmp    QWORD PTR [r13+0x0],0x149
    1937e0f3:	00 
    1937e0f4:	0f 86 29 2e 00 00    	jbe    19380f23 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b03>
    1937e0fa:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e0fe:	48 83 b8 e0 1e 00 00 	cmp    QWORD PTR [rax+0x1ee0],0xc
    1937e105:	0c 
    1937e106:	0f 86 19 2e 00 00    	jbe    19380f25 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b05>
    1937e10c:	48 8b 80 d8 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ed8]
    1937e113:	c7 40 30 0d 00 00 00 	mov    DWORD PTR [rax+0x30],0xd
    1937e11a:	48 81 39 4a 01 00 00 	cmp    QWORD PTR [rcx],0x14a
    1937e121:	0f 86 00 2e 00 00    	jbe    19380f27 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b07>
    1937e127:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937e12a:	c7 80 28 05 00 00 08 	mov    DWORD PTR [rax+0x528],0x8
    1937e131:	00 00 00 
    1937e134:	48 81 7b 20 4a 01 00 	cmp    QWORD PTR [rbx+0x20],0x14a
    1937e13b:	00 
    1937e13c:	0f 86 e7 2d 00 00    	jbe    19380f29 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b09>
    1937e142:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e146:	48 83 b8 f8 1e 00 00 	cmp    QWORD PTR [rax+0x1ef8],0x9
    1937e14d:	09 
    1937e14e:	0f 86 d7 2d 00 00    	jbe    19380f2b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b0b>
    1937e154:	48 8b 80 f0 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ef0]
    1937e15b:	c7 40 24 06 00 00 00 	mov    DWORD PTR [rax+0x24],0x6
    1937e162:	49 81 7d 00 4a 01 00 	cmp    QWORD PTR [r13+0x0],0x14a
    1937e169:	00 
    1937e16a:	0f 86 bd 2d 00 00    	jbe    19380f2d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b0d>
    1937e170:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e174:	48 83 b8 f8 1e 00 00 	cmp    QWORD PTR [rax+0x1ef8],0xa
    1937e17b:	0a 
    1937e17c:	0f 86 ad 2d 00 00    	jbe    19380f2f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b0f>
    1937e182:	48 8b 80 f0 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ef0]
    1937e189:	c7 40 28 05 00 00 00 	mov    DWORD PTR [rax+0x28],0x5
    1937e190:	49 81 7d 00 4a 01 00 	cmp    QWORD PTR [r13+0x0],0x14a
    1937e197:	00 
    1937e198:	0f 86 93 2d 00 00    	jbe    19380f31 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b11>
    1937e19e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e1a2:	48 83 b8 f8 1e 00 00 	cmp    QWORD PTR [rax+0x1ef8],0xb
    1937e1a9:	0b 
    1937e1aa:	0f 86 83 2d 00 00    	jbe    19380f33 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b13>
    1937e1b0:	48 8b 80 f0 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ef0]
    1937e1b7:	c7 40 2c 07 00 00 00 	mov    DWORD PTR [rax+0x2c],0x7
    1937e1be:	49 81 7d 00 4a 01 00 	cmp    QWORD PTR [r13+0x0],0x14a
    1937e1c5:	00 
    1937e1c6:	0f 86 69 2d 00 00    	jbe    19380f35 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b15>
    1937e1cc:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e1d0:	48 83 b8 f8 1e 00 00 	cmp    QWORD PTR [rax+0x1ef8],0xc
    1937e1d7:	0c 
    1937e1d8:	0f 86 59 2d 00 00    	jbe    19380f37 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b17>
    1937e1de:	48 8b 80 f0 1e 00 00 	mov    rax,QWORD PTR [rax+0x1ef0]
    1937e1e5:	c7 40 30 0d 00 00 00 	mov    DWORD PTR [rax+0x30],0xd
    1937e1ec:	48 81 39 4b 01 00 00 	cmp    QWORD PTR [rcx],0x14b
    1937e1f3:	0f 86 40 2d 00 00    	jbe    19380f39 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b19>
    1937e1f9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937e1fc:	c7 80 2c 05 00 00 08 	mov    DWORD PTR [rax+0x52c],0x8
    1937e203:	00 00 00 
    1937e206:	48 81 7b 20 4b 01 00 	cmp    QWORD PTR [rbx+0x20],0x14b
    1937e20d:	00 
    1937e20e:	0f 86 27 2d 00 00    	jbe    19380f3b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b1b>
    1937e214:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e218:	48 83 b8 10 1f 00 00 	cmp    QWORD PTR [rax+0x1f10],0x9
    1937e21f:	09 
    1937e220:	0f 86 17 2d 00 00    	jbe    19380f3d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b1d>
    1937e226:	48 8b 80 08 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f08]
    1937e22d:	c7 40 24 06 00 00 00 	mov    DWORD PTR [rax+0x24],0x6
    1937e234:	49 81 7d 00 4b 01 00 	cmp    QWORD PTR [r13+0x0],0x14b
    1937e23b:	00 
    1937e23c:	0f 86 fd 2c 00 00    	jbe    19380f3f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b1f>
    1937e242:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e246:	48 83 b8 10 1f 00 00 	cmp    QWORD PTR [rax+0x1f10],0xa
    1937e24d:	0a 
    1937e24e:	0f 86 ed 2c 00 00    	jbe    19380f41 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b21>
    1937e254:	48 8b 80 08 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f08]
    1937e25b:	c7 40 28 05 00 00 00 	mov    DWORD PTR [rax+0x28],0x5
    1937e262:	49 81 7d 00 4b 01 00 	cmp    QWORD PTR [r13+0x0],0x14b
    1937e269:	00 
    1937e26a:	0f 86 d3 2c 00 00    	jbe    19380f43 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b23>
    1937e270:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e274:	48 83 b8 10 1f 00 00 	cmp    QWORD PTR [rax+0x1f10],0xb
    1937e27b:	0b 
    1937e27c:	0f 86 c3 2c 00 00    	jbe    19380f45 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b25>
    1937e282:	48 8b 80 08 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f08]
    1937e289:	c7 40 2c 07 00 00 00 	mov    DWORD PTR [rax+0x2c],0x7
    1937e290:	49 81 7d 00 4b 01 00 	cmp    QWORD PTR [r13+0x0],0x14b
    1937e297:	00 
    1937e298:	0f 86 a9 2c 00 00    	jbe    19380f47 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b27>
    1937e29e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e2a2:	48 83 b8 10 1f 00 00 	cmp    QWORD PTR [rax+0x1f10],0xc
    1937e2a9:	0c 
    1937e2aa:	0f 86 99 2c 00 00    	jbe    19380f49 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b29>
    1937e2b0:	48 8b 80 08 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f08]
    1937e2b7:	c7 40 30 0d 00 00 00 	mov    DWORD PTR [rax+0x30],0xd
    1937e2be:	48 81 39 4c 01 00 00 	cmp    QWORD PTR [rcx],0x14c
    1937e2c5:	0f 86 80 2c 00 00    	jbe    19380f4b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b2b>
    1937e2cb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937e2ce:	c7 80 30 05 00 00 01 	mov    DWORD PTR [rax+0x530],0x1
    1937e2d5:	00 00 00 
    1937e2d8:	48 81 7b 20 4c 01 00 	cmp    QWORD PTR [rbx+0x20],0x14c
    1937e2df:	00 
    1937e2e0:	0f 86 67 2c 00 00    	jbe    19380f4d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b2d>
    1937e2e6:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e2ea:	48 83 b8 28 1f 00 00 	cmp    QWORD PTR [rax+0x1f28],0xd
    1937e2f1:	0d 
    1937e2f2:	0f 86 57 2c 00 00    	jbe    19380f4f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b2f>
    1937e2f8:	48 8b 80 20 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f20]
    1937e2ff:	c7 40 34 23 00 00 00 	mov    DWORD PTR [rax+0x34],0x23
    1937e306:	49 81 7d 00 4c 01 00 	cmp    QWORD PTR [r13+0x0],0x14c
    1937e30d:	00 
    1937e30e:	0f 86 3d 2c 00 00    	jbe    19380f51 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b31>
    1937e314:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e318:	48 83 b8 28 1f 00 00 	cmp    QWORD PTR [rax+0x1f28],0xe
    1937e31f:	0e 
    1937e320:	0f 86 2d 2c 00 00    	jbe    19380f53 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b33>
    1937e326:	48 8b 80 20 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f20]
    1937e32d:	c7 40 38 22 00 00 00 	mov    DWORD PTR [rax+0x38],0x22
    1937e334:	49 81 7d 00 4c 01 00 	cmp    QWORD PTR [r13+0x0],0x14c
    1937e33b:	00 
    1937e33c:	0f 86 13 2c 00 00    	jbe    19380f55 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b35>
    1937e342:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e346:	48 83 b8 28 1f 00 00 	cmp    QWORD PTR [rax+0x1f28],0xf
    1937e34d:	0f 
    1937e34e:	0f 86 03 2c 00 00    	jbe    19380f57 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b37>
    1937e354:	48 8b 80 20 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f20]
    1937e35b:	c7 40 3c 28 00 00 00 	mov    DWORD PTR [rax+0x3c],0x28
    1937e362:	49 81 7d 00 4c 01 00 	cmp    QWORD PTR [r13+0x0],0x14c
    1937e369:	00 
    1937e36a:	0f 86 e9 2b 00 00    	jbe    19380f59 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b39>
    1937e370:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e374:	48 83 b8 28 1f 00 00 	cmp    QWORD PTR [rax+0x1f28],0x10
    1937e37b:	10 
    1937e37c:	0f 86 d9 2b 00 00    	jbe    19380f5b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b3b>
    1937e382:	48 8b 80 20 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f20]
    1937e389:	c7 40 40 12 00 00 00 	mov    DWORD PTR [rax+0x40],0x12
    1937e390:	48 81 39 4d 01 00 00 	cmp    QWORD PTR [rcx],0x14d
    1937e397:	0f 86 c0 2b 00 00    	jbe    19380f5d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b3d>
    1937e39d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937e3a0:	c7 80 34 05 00 00 01 	mov    DWORD PTR [rax+0x534],0x1
    1937e3a7:	00 00 00 
    1937e3aa:	48 81 7b 20 4d 01 00 	cmp    QWORD PTR [rbx+0x20],0x14d
    1937e3b1:	00 
    1937e3b2:	0f 86 a7 2b 00 00    	jbe    19380f5f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b3f>
    1937e3b8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e3bc:	48 83 b8 40 1f 00 00 	cmp    QWORD PTR [rax+0x1f40],0xd
    1937e3c3:	0d 
    1937e3c4:	0f 86 97 2b 00 00    	jbe    19380f61 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b41>
    1937e3ca:	48 8b 80 38 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f38]
    1937e3d1:	c7 40 34 23 00 00 00 	mov    DWORD PTR [rax+0x34],0x23
    1937e3d8:	49 81 7d 00 4d 01 00 	cmp    QWORD PTR [r13+0x0],0x14d
    1937e3df:	00 
    1937e3e0:	0f 86 7d 2b 00 00    	jbe    19380f63 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b43>
    1937e3e6:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e3ea:	48 83 b8 40 1f 00 00 	cmp    QWORD PTR [rax+0x1f40],0xe
    1937e3f1:	0e 
    1937e3f2:	0f 86 6d 2b 00 00    	jbe    19380f65 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b45>
    1937e3f8:	48 8b 80 38 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f38]
    1937e3ff:	c7 40 38 22 00 00 00 	mov    DWORD PTR [rax+0x38],0x22
    1937e406:	49 81 7d 00 4d 01 00 	cmp    QWORD PTR [r13+0x0],0x14d
    1937e40d:	00 
    1937e40e:	0f 86 53 2b 00 00    	jbe    19380f67 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b47>
    1937e414:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e418:	48 83 b8 40 1f 00 00 	cmp    QWORD PTR [rax+0x1f40],0xf
    1937e41f:	0f 
    1937e420:	0f 86 43 2b 00 00    	jbe    19380f69 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b49>
    1937e426:	48 8b 80 38 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f38]
    1937e42d:	c7 40 3c 28 00 00 00 	mov    DWORD PTR [rax+0x3c],0x28
    1937e434:	49 81 7d 00 4d 01 00 	cmp    QWORD PTR [r13+0x0],0x14d
    1937e43b:	00 
    1937e43c:	0f 86 29 2b 00 00    	jbe    19380f6b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b4b>
    1937e442:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e446:	48 83 b8 40 1f 00 00 	cmp    QWORD PTR [rax+0x1f40],0x10
    1937e44d:	10 
    1937e44e:	0f 86 19 2b 00 00    	jbe    19380f6d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b4d>
    1937e454:	48 8b 80 38 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f38]
    1937e45b:	c7 40 40 12 00 00 00 	mov    DWORD PTR [rax+0x40],0x12
    1937e462:	49 81 7d 00 4d 01 00 	cmp    QWORD PTR [r13+0x0],0x14d
    1937e469:	00 
    1937e46a:	0f 86 ff 2a 00 00    	jbe    19380f6f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b4f>
    1937e470:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e474:	48 83 b8 40 1f 00 00 	cmp    QWORD PTR [rax+0x1f40],0x11
    1937e47b:	11 
    1937e47c:	0f 86 ef 2a 00 00    	jbe    19380f71 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b51>
    1937e482:	48 8b 80 38 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f38]
    1937e489:	c7 40 44 03 00 00 00 	mov    DWORD PTR [rax+0x44],0x3
    1937e490:	48 81 39 4e 01 00 00 	cmp    QWORD PTR [rcx],0x14e
    1937e497:	0f 86 d6 2a 00 00    	jbe    19380f73 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b53>
    1937e49d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937e4a0:	c7 80 38 05 00 00 01 	mov    DWORD PTR [rax+0x538],0x1
    1937e4a7:	00 00 00 
    1937e4aa:	48 81 7b 20 4e 01 00 	cmp    QWORD PTR [rbx+0x20],0x14e
    1937e4b1:	00 
    1937e4b2:	0f 86 bd 2a 00 00    	jbe    19380f75 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b55>
    1937e4b8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e4bc:	48 83 b8 58 1f 00 00 	cmp    QWORD PTR [rax+0x1f58],0xd
    1937e4c3:	0d 
    1937e4c4:	0f 86 ad 2a 00 00    	jbe    19380f77 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b57>
    1937e4ca:	48 8b 80 50 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f50]
    1937e4d1:	c7 40 34 23 00 00 00 	mov    DWORD PTR [rax+0x34],0x23
    1937e4d8:	49 81 7d 00 4e 01 00 	cmp    QWORD PTR [r13+0x0],0x14e
    1937e4df:	00 
    1937e4e0:	0f 86 93 2a 00 00    	jbe    19380f79 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b59>
    1937e4e6:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e4ea:	48 83 b8 58 1f 00 00 	cmp    QWORD PTR [rax+0x1f58],0xe
    1937e4f1:	0e 
    1937e4f2:	0f 86 83 2a 00 00    	jbe    19380f7b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b5b>
    1937e4f8:	48 8b 80 50 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f50]
    1937e4ff:	c7 40 38 22 00 00 00 	mov    DWORD PTR [rax+0x38],0x22
    1937e506:	49 81 7d 00 4e 01 00 	cmp    QWORD PTR [r13+0x0],0x14e
    1937e50d:	00 
    1937e50e:	0f 86 69 2a 00 00    	jbe    19380f7d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b5d>
    1937e514:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e518:	48 83 b8 58 1f 00 00 	cmp    QWORD PTR [rax+0x1f58],0xf
    1937e51f:	0f 
    1937e520:	0f 86 59 2a 00 00    	jbe    19380f7f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b5f>
    1937e526:	48 8b 80 50 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f50]
    1937e52d:	c7 40 3c 28 00 00 00 	mov    DWORD PTR [rax+0x3c],0x28
    1937e534:	49 81 7d 00 4e 01 00 	cmp    QWORD PTR [r13+0x0],0x14e
    1937e53b:	00 
    1937e53c:	0f 86 3f 2a 00 00    	jbe    19380f81 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b61>
    1937e542:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e546:	48 83 b8 58 1f 00 00 	cmp    QWORD PTR [rax+0x1f58],0x10
    1937e54d:	10 
    1937e54e:	0f 86 2f 2a 00 00    	jbe    19380f83 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b63>
    1937e554:	48 8b 80 50 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f50]
    1937e55b:	c7 40 40 12 00 00 00 	mov    DWORD PTR [rax+0x40],0x12
    1937e562:	49 81 7d 00 4e 01 00 	cmp    QWORD PTR [r13+0x0],0x14e
    1937e569:	00 
    1937e56a:	0f 86 15 2a 00 00    	jbe    19380f85 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b65>
    1937e570:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e574:	48 83 b8 58 1f 00 00 	cmp    QWORD PTR [rax+0x1f58],0x11
    1937e57b:	11 
    1937e57c:	0f 86 05 2a 00 00    	jbe    19380f87 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b67>
    1937e582:	48 8b 80 50 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f50]
    1937e589:	c7 40 44 03 00 00 00 	mov    DWORD PTR [rax+0x44],0x3
    1937e590:	48 81 39 4f 01 00 00 	cmp    QWORD PTR [rcx],0x14f
    1937e597:	0f 86 ec 29 00 00    	jbe    19380f89 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b69>
    1937e59d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937e5a0:	c7 80 3c 05 00 00 01 	mov    DWORD PTR [rax+0x53c],0x1
    1937e5a7:	00 00 00 
    1937e5aa:	48 81 7b 20 4f 01 00 	cmp    QWORD PTR [rbx+0x20],0x14f
    1937e5b1:	00 
    1937e5b2:	0f 86 d3 29 00 00    	jbe    19380f8b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b6b>
    1937e5b8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e5bc:	48 83 b8 70 1f 00 00 	cmp    QWORD PTR [rax+0x1f70],0xd
    1937e5c3:	0d 
    1937e5c4:	0f 86 c3 29 00 00    	jbe    19380f8d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b6d>
    1937e5ca:	48 8b 80 68 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f68]
    1937e5d1:	c7 40 34 23 00 00 00 	mov    DWORD PTR [rax+0x34],0x23
    1937e5d8:	49 81 7d 00 4f 01 00 	cmp    QWORD PTR [r13+0x0],0x14f
    1937e5df:	00 
    1937e5e0:	0f 86 a9 29 00 00    	jbe    19380f8f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b6f>
    1937e5e6:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e5ea:	48 83 b8 70 1f 00 00 	cmp    QWORD PTR [rax+0x1f70],0xe
    1937e5f1:	0e 
    1937e5f2:	0f 86 99 29 00 00    	jbe    19380f91 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b71>
    1937e5f8:	48 8b 80 68 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f68]
    1937e5ff:	c7 40 38 22 00 00 00 	mov    DWORD PTR [rax+0x38],0x22
    1937e606:	49 81 7d 00 4f 01 00 	cmp    QWORD PTR [r13+0x0],0x14f
    1937e60d:	00 
    1937e60e:	0f 86 7f 29 00 00    	jbe    19380f93 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b73>
    1937e614:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e618:	48 83 b8 70 1f 00 00 	cmp    QWORD PTR [rax+0x1f70],0xf
    1937e61f:	0f 
    1937e620:	0f 86 6f 29 00 00    	jbe    19380f95 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b75>
    1937e626:	48 8b 80 68 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f68]
    1937e62d:	c7 40 3c 28 00 00 00 	mov    DWORD PTR [rax+0x3c],0x28
    1937e634:	49 81 7d 00 4f 01 00 	cmp    QWORD PTR [r13+0x0],0x14f
    1937e63b:	00 
    1937e63c:	0f 86 55 29 00 00    	jbe    19380f97 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b77>
    1937e642:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e646:	48 83 b8 70 1f 00 00 	cmp    QWORD PTR [rax+0x1f70],0x10
    1937e64d:	10 
    1937e64e:	0f 86 45 29 00 00    	jbe    19380f99 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b79>
    1937e654:	48 8b 80 68 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f68]
    1937e65b:	c7 40 40 12 00 00 00 	mov    DWORD PTR [rax+0x40],0x12
    1937e662:	49 81 7d 00 4f 01 00 	cmp    QWORD PTR [r13+0x0],0x14f
    1937e669:	00 
    1937e66a:	0f 86 2b 29 00 00    	jbe    19380f9b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b7b>
    1937e670:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e674:	48 83 b8 70 1f 00 00 	cmp    QWORD PTR [rax+0x1f70],0x11
    1937e67b:	11 
    1937e67c:	0f 86 1b 29 00 00    	jbe    19380f9d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b7d>
    1937e682:	48 8b 80 68 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f68]
    1937e689:	c7 40 44 03 00 00 00 	mov    DWORD PTR [rax+0x44],0x3
    1937e690:	48 81 39 50 01 00 00 	cmp    QWORD PTR [rcx],0x150
    1937e697:	0f 86 02 29 00 00    	jbe    19380f9f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b7f>
    1937e69d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937e6a0:	c7 80 40 05 00 00 01 	mov    DWORD PTR [rax+0x540],0x1
    1937e6a7:	00 00 00 
    1937e6aa:	48 81 7b 20 50 01 00 	cmp    QWORD PTR [rbx+0x20],0x150
    1937e6b1:	00 
    1937e6b2:	0f 86 e9 28 00 00    	jbe    19380fa1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b81>
    1937e6b8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e6bc:	48 83 b8 88 1f 00 00 	cmp    QWORD PTR [rax+0x1f88],0x11
    1937e6c3:	11 
    1937e6c4:	0f 86 d9 28 00 00    	jbe    19380fa3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b83>
    1937e6ca:	48 8b 80 80 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f80]
    1937e6d1:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937e6d8:	48 81 39 51 01 00 00 	cmp    QWORD PTR [rcx],0x151
    1937e6df:	0f 86 c0 28 00 00    	jbe    19380fa5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b85>
    1937e6e5:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937e6e8:	c7 80 44 05 00 00 7f 	mov    DWORD PTR [rax+0x544],0x7f
    1937e6ef:	00 00 00 
    1937e6f2:	48 81 7b 20 51 01 00 	cmp    QWORD PTR [rbx+0x20],0x151
    1937e6f9:	00 
    1937e6fa:	0f 86 a7 28 00 00    	jbe    19380fa7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b87>
    1937e700:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e704:	48 83 b8 a0 1f 00 00 	cmp    QWORD PTR [rax+0x1fa0],0x12
    1937e70b:	12 
    1937e70c:	0f 86 97 28 00 00    	jbe    19380fa9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b89>
    1937e712:	48 8b 80 98 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f98]
    1937e719:	c7 40 48 28 00 00 00 	mov    DWORD PTR [rax+0x48],0x28
    1937e720:	49 81 7d 00 51 01 00 	cmp    QWORD PTR [r13+0x0],0x151
    1937e727:	00 
    1937e728:	0f 86 7d 28 00 00    	jbe    19380fab <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b8b>
    1937e72e:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e732:	48 83 b8 a0 1f 00 00 	cmp    QWORD PTR [rax+0x1fa0],0x13
    1937e739:	13 
    1937e73a:	0f 86 6d 28 00 00    	jbe    19380fad <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b8d>
    1937e740:	48 8b 80 98 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f98]
    1937e747:	c7 40 4c 2c 00 00 00 	mov    DWORD PTR [rax+0x4c],0x2c
    1937e74e:	49 81 7d 00 51 01 00 	cmp    QWORD PTR [r13+0x0],0x151
    1937e755:	00 
    1937e756:	0f 86 53 28 00 00    	jbe    19380faf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b8f>
    1937e75c:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e760:	48 83 b8 a0 1f 00 00 	cmp    QWORD PTR [rax+0x1fa0],0x14
    1937e767:	14 
    1937e768:	0f 86 43 28 00 00    	jbe    19380fb1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b91>
    1937e76e:	48 8b 80 98 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f98]
    1937e775:	c7 40 50 19 00 00 00 	mov    DWORD PTR [rax+0x50],0x19
    1937e77c:	49 81 7d 00 51 01 00 	cmp    QWORD PTR [r13+0x0],0x151
    1937e783:	00 
    1937e784:	0f 86 29 28 00 00    	jbe    19380fb3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b93>
    1937e78a:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e78e:	48 83 b8 a0 1f 00 00 	cmp    QWORD PTR [rax+0x1fa0],0x15
    1937e795:	15 
    1937e796:	0f 86 19 28 00 00    	jbe    19380fb5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b95>
    1937e79c:	48 8b 80 98 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f98]
    1937e7a3:	c7 40 54 03 00 00 00 	mov    DWORD PTR [rax+0x54],0x3
    1937e7aa:	49 81 7d 00 51 01 00 	cmp    QWORD PTR [r13+0x0],0x151
    1937e7b1:	00 
    1937e7b2:	0f 86 ff 27 00 00    	jbe    19380fb7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b97>
    1937e7b8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e7bc:	48 83 b8 a0 1f 00 00 	cmp    QWORD PTR [rax+0x1fa0],0x11
    1937e7c3:	11 
    1937e7c4:	0f 86 ef 27 00 00    	jbe    19380fb9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b99>
    1937e7ca:	48 8b 80 98 1f 00 00 	mov    rax,QWORD PTR [rax+0x1f98]
    1937e7d1:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937e7d8:	48 81 39 52 01 00 00 	cmp    QWORD PTR [rcx],0x152
    1937e7df:	0f 86 d6 27 00 00    	jbe    19380fbb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b9b>
    1937e7e5:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937e7e8:	c7 80 48 05 00 00 01 	mov    DWORD PTR [rax+0x548],0x1
    1937e7ef:	00 00 00 
    1937e7f2:	48 81 7b 20 52 01 00 	cmp    QWORD PTR [rbx+0x20],0x152
    1937e7f9:	00 
    1937e7fa:	0f 86 bd 27 00 00    	jbe    19380fbd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b9d>
    1937e800:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e804:	48 83 b8 b8 1f 00 00 	cmp    QWORD PTR [rax+0x1fb8],0x11
    1937e80b:	11 
    1937e80c:	0f 86 ad 27 00 00    	jbe    19380fbf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6b9f>
    1937e812:	48 8b 80 b0 1f 00 00 	mov    rax,QWORD PTR [rax+0x1fb0]
    1937e819:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937e820:	48 81 39 53 01 00 00 	cmp    QWORD PTR [rcx],0x153
    1937e827:	0f 86 94 27 00 00    	jbe    19380fc1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ba1>
    1937e82d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937e830:	c7 80 4c 05 00 00 65 	mov    DWORD PTR [rax+0x54c],0x65
    1937e837:	00 00 00 
    1937e83a:	48 81 7b 20 53 01 00 	cmp    QWORD PTR [rbx+0x20],0x153
    1937e841:	00 
    1937e842:	0f 86 7b 27 00 00    	jbe    19380fc3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ba3>
    1937e848:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e84c:	48 83 b8 d0 1f 00 00 	cmp    QWORD PTR [rax+0x1fd0],0x12
    1937e853:	12 
    1937e854:	0f 86 6b 27 00 00    	jbe    19380fc5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ba5>
    1937e85a:	48 8b 80 c8 1f 00 00 	mov    rax,QWORD PTR [rax+0x1fc8]
    1937e861:	c7 40 48 08 00 00 00 	mov    DWORD PTR [rax+0x48],0x8
    1937e868:	49 81 7d 00 53 01 00 	cmp    QWORD PTR [r13+0x0],0x153
    1937e86f:	00 
    1937e870:	0f 86 51 27 00 00    	jbe    19380fc7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ba7>
    1937e876:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e87a:	48 83 b8 d0 1f 00 00 	cmp    QWORD PTR [rax+0x1fd0],0x13
    1937e881:	13 
    1937e882:	0f 86 41 27 00 00    	jbe    19380fc9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ba9>
    1937e888:	48 8b 80 c8 1f 00 00 	mov    rax,QWORD PTR [rax+0x1fc8]
    1937e88f:	c7 40 4c 0b 00 00 00 	mov    DWORD PTR [rax+0x4c],0xb
    1937e896:	49 81 7d 00 53 01 00 	cmp    QWORD PTR [r13+0x0],0x153
    1937e89d:	00 
    1937e89e:	0f 86 27 27 00 00    	jbe    19380fcb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bab>
    1937e8a4:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e8a8:	48 83 b8 d0 1f 00 00 	cmp    QWORD PTR [rax+0x1fd0],0x14
    1937e8af:	14 
    1937e8b0:	0f 86 17 27 00 00    	jbe    19380fcd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bad>
    1937e8b6:	48 8b 80 c8 1f 00 00 	mov    rax,QWORD PTR [rax+0x1fc8]
    1937e8bd:	c7 40 50 23 00 00 00 	mov    DWORD PTR [rax+0x50],0x23
    1937e8c4:	49 81 7d 00 53 01 00 	cmp    QWORD PTR [r13+0x0],0x153
    1937e8cb:	00 
    1937e8cc:	0f 86 fd 26 00 00    	jbe    19380fcf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6baf>
    1937e8d2:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e8d6:	48 83 b8 d0 1f 00 00 	cmp    QWORD PTR [rax+0x1fd0],0x15
    1937e8dd:	15 
    1937e8de:	0f 86 ed 26 00 00    	jbe    19380fd1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bb1>
    1937e8e4:	48 8b 80 c8 1f 00 00 	mov    rax,QWORD PTR [rax+0x1fc8]
    1937e8eb:	c7 40 54 03 00 00 00 	mov    DWORD PTR [rax+0x54],0x3
    1937e8f2:	49 81 7d 00 53 01 00 	cmp    QWORD PTR [r13+0x0],0x153
    1937e8f9:	00 
    1937e8fa:	0f 86 d3 26 00 00    	jbe    19380fd3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bb3>
    1937e900:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e904:	48 83 b8 d0 1f 00 00 	cmp    QWORD PTR [rax+0x1fd0],0x11
    1937e90b:	11 
    1937e90c:	0f 86 c3 26 00 00    	jbe    19380fd5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bb5>
    1937e912:	48 8b 80 c8 1f 00 00 	mov    rax,QWORD PTR [rax+0x1fc8]
    1937e919:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937e920:	48 81 39 54 01 00 00 	cmp    QWORD PTR [rcx],0x154
    1937e927:	0f 86 aa 26 00 00    	jbe    19380fd7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bb7>
    1937e92d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937e930:	c7 80 50 05 00 00 01 	mov    DWORD PTR [rax+0x550],0x1
    1937e937:	00 00 00 
    1937e93a:	48 81 7b 20 54 01 00 	cmp    QWORD PTR [rbx+0x20],0x154
    1937e941:	00 
    1937e942:	0f 86 91 26 00 00    	jbe    19380fd9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bb9>
    1937e948:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e94c:	48 83 b8 e8 1f 00 00 	cmp    QWORD PTR [rax+0x1fe8],0x11
    1937e953:	11 
    1937e954:	0f 86 81 26 00 00    	jbe    19380fdb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bbb>
    1937e95a:	48 8b 80 e0 1f 00 00 	mov    rax,QWORD PTR [rax+0x1fe0]
    1937e961:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937e968:	48 81 39 55 01 00 00 	cmp    QWORD PTR [rcx],0x155
    1937e96f:	0f 86 68 26 00 00    	jbe    19380fdd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bbd>
    1937e975:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937e978:	c7 80 54 05 00 00 71 	mov    DWORD PTR [rax+0x554],0x71
    1937e97f:	00 00 00 
    1937e982:	48 81 7b 20 55 01 00 	cmp    QWORD PTR [rbx+0x20],0x155
    1937e989:	00 
    1937e98a:	0f 86 4f 26 00 00    	jbe    19380fdf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bbf>
    1937e990:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e994:	48 83 b8 00 20 00 00 	cmp    QWORD PTR [rax+0x2000],0x12
    1937e99b:	12 
    1937e99c:	0f 86 3f 26 00 00    	jbe    19380fe1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bc1>
    1937e9a2:	48 8b 80 f8 1f 00 00 	mov    rax,QWORD PTR [rax+0x1ff8]
    1937e9a9:	c7 40 48 04 00 00 00 	mov    DWORD PTR [rax+0x48],0x4
    1937e9b0:	49 81 7d 00 55 01 00 	cmp    QWORD PTR [r13+0x0],0x155
    1937e9b7:	00 
    1937e9b8:	0f 86 25 26 00 00    	jbe    19380fe3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bc3>
    1937e9be:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e9c2:	48 83 b8 00 20 00 00 	cmp    QWORD PTR [rax+0x2000],0x13
    1937e9c9:	13 
    1937e9ca:	0f 86 15 26 00 00    	jbe    19380fe5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bc5>
    1937e9d0:	48 8b 80 f8 1f 00 00 	mov    rax,QWORD PTR [rax+0x1ff8]
    1937e9d7:	c7 40 4c 14 00 00 00 	mov    DWORD PTR [rax+0x4c],0x14
    1937e9de:	49 81 7d 00 55 01 00 	cmp    QWORD PTR [r13+0x0],0x155
    1937e9e5:	00 
    1937e9e6:	0f 86 fb 25 00 00    	jbe    19380fe7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bc7>
    1937e9ec:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937e9f0:	48 83 b8 00 20 00 00 	cmp    QWORD PTR [rax+0x2000],0x14
    1937e9f7:	14 
    1937e9f8:	0f 86 eb 25 00 00    	jbe    19380fe9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bc9>
    1937e9fe:	48 8b 80 f8 1f 00 00 	mov    rax,QWORD PTR [rax+0x1ff8]
    1937ea05:	c7 40 50 27 00 00 00 	mov    DWORD PTR [rax+0x50],0x27
    1937ea0c:	49 81 7d 00 55 01 00 	cmp    QWORD PTR [r13+0x0],0x155
    1937ea13:	00 
    1937ea14:	0f 86 d1 25 00 00    	jbe    19380feb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bcb>
    1937ea1a:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ea1e:	48 83 b8 00 20 00 00 	cmp    QWORD PTR [rax+0x2000],0x15
    1937ea25:	15 
    1937ea26:	0f 86 c1 25 00 00    	jbe    19380fed <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bcd>
    1937ea2c:	48 8b 80 f8 1f 00 00 	mov    rax,QWORD PTR [rax+0x1ff8]
    1937ea33:	c7 40 54 03 00 00 00 	mov    DWORD PTR [rax+0x54],0x3
    1937ea3a:	49 81 7d 00 55 01 00 	cmp    QWORD PTR [r13+0x0],0x155
    1937ea41:	00 
    1937ea42:	0f 86 a7 25 00 00    	jbe    19380fef <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bcf>
    1937ea48:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ea4c:	48 83 b8 00 20 00 00 	cmp    QWORD PTR [rax+0x2000],0x11
    1937ea53:	11 
    1937ea54:	0f 86 97 25 00 00    	jbe    19380ff1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bd1>
    1937ea5a:	48 8b 80 f8 1f 00 00 	mov    rax,QWORD PTR [rax+0x1ff8]
    1937ea61:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937ea68:	48 81 39 56 01 00 00 	cmp    QWORD PTR [rcx],0x156
    1937ea6f:	0f 86 7e 25 00 00    	jbe    19380ff3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bd3>
    1937ea75:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ea78:	c7 80 58 05 00 00 01 	mov    DWORD PTR [rax+0x558],0x1
    1937ea7f:	00 00 00 
    1937ea82:	48 81 7b 20 56 01 00 	cmp    QWORD PTR [rbx+0x20],0x156
    1937ea89:	00 
    1937ea8a:	0f 86 65 25 00 00    	jbe    19380ff5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bd5>
    1937ea90:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ea94:	48 83 b8 18 20 00 00 	cmp    QWORD PTR [rax+0x2018],0x11
    1937ea9b:	11 
    1937ea9c:	0f 86 55 25 00 00    	jbe    19380ff7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bd7>
    1937eaa2:	48 8b 80 10 20 00 00 	mov    rax,QWORD PTR [rax+0x2010]
    1937eaa9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937eab0:	48 81 39 57 01 00 00 	cmp    QWORD PTR [rcx],0x157
    1937eab7:	0f 86 3c 25 00 00    	jbe    19380ff9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bd9>
    1937eabd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937eac0:	c7 80 5c 05 00 00 7a 	mov    DWORD PTR [rax+0x55c],0x7a
    1937eac7:	00 00 00 
    1937eaca:	48 81 7b 20 57 01 00 	cmp    QWORD PTR [rbx+0x20],0x157
    1937ead1:	00 
    1937ead2:	0f 86 23 25 00 00    	jbe    19380ffb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bdb>
    1937ead8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937eadc:	48 83 b8 30 20 00 00 	cmp    QWORD PTR [rax+0x2030],0x12
    1937eae3:	12 
    1937eae4:	0f 86 13 25 00 00    	jbe    19380ffd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bdd>
    1937eaea:	48 8b 80 28 20 00 00 	mov    rax,QWORD PTR [rax+0x2028]
    1937eaf1:	c7 40 48 28 00 00 00 	mov    DWORD PTR [rax+0x48],0x28
    1937eaf8:	49 81 7d 00 57 01 00 	cmp    QWORD PTR [r13+0x0],0x157
    1937eaff:	00 
    1937eb00:	0f 86 f9 24 00 00    	jbe    19380fff <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bdf>
    1937eb06:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937eb0a:	48 83 b8 30 20 00 00 	cmp    QWORD PTR [rax+0x2030],0x13
    1937eb11:	13 
    1937eb12:	0f 86 e9 24 00 00    	jbe    19381001 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6be1>
    1937eb18:	48 8b 80 28 20 00 00 	mov    rax,QWORD PTR [rax+0x2028]
    1937eb1f:	c7 40 4c 2b 00 00 00 	mov    DWORD PTR [rax+0x4c],0x2b
    1937eb26:	49 81 7d 00 57 01 00 	cmp    QWORD PTR [r13+0x0],0x157
    1937eb2d:	00 
    1937eb2e:	0f 86 cf 24 00 00    	jbe    19381003 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6be3>
    1937eb34:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937eb38:	48 83 b8 30 20 00 00 	cmp    QWORD PTR [rax+0x2030],0x14
    1937eb3f:	14 
    1937eb40:	0f 86 bf 24 00 00    	jbe    19381005 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6be5>
    1937eb46:	48 8b 80 28 20 00 00 	mov    rax,QWORD PTR [rax+0x2028]
    1937eb4d:	c7 40 50 27 00 00 00 	mov    DWORD PTR [rax+0x50],0x27
    1937eb54:	49 81 7d 00 57 01 00 	cmp    QWORD PTR [r13+0x0],0x157
    1937eb5b:	00 
    1937eb5c:	0f 86 a5 24 00 00    	jbe    19381007 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6be7>
    1937eb62:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937eb66:	48 83 b8 30 20 00 00 	cmp    QWORD PTR [rax+0x2030],0x15
    1937eb6d:	15 
    1937eb6e:	0f 86 95 24 00 00    	jbe    19381009 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6be9>
    1937eb74:	48 8b 80 28 20 00 00 	mov    rax,QWORD PTR [rax+0x2028]
    1937eb7b:	c7 40 54 03 00 00 00 	mov    DWORD PTR [rax+0x54],0x3
    1937eb82:	49 81 7d 00 57 01 00 	cmp    QWORD PTR [r13+0x0],0x157
    1937eb89:	00 
    1937eb8a:	0f 86 7b 24 00 00    	jbe    1938100b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6beb>
    1937eb90:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937eb94:	48 83 b8 30 20 00 00 	cmp    QWORD PTR [rax+0x2030],0x11
    1937eb9b:	11 
    1937eb9c:	0f 86 6b 24 00 00    	jbe    1938100d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bed>
    1937eba2:	48 8b 80 28 20 00 00 	mov    rax,QWORD PTR [rax+0x2028]
    1937eba9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937ebb0:	48 81 39 58 01 00 00 	cmp    QWORD PTR [rcx],0x158
    1937ebb7:	0f 86 52 24 00 00    	jbe    1938100f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bef>
    1937ebbd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ebc0:	c7 80 60 05 00 00 7f 	mov    DWORD PTR [rax+0x560],0x7f
    1937ebc7:	00 00 00 
    1937ebca:	48 81 7b 20 58 01 00 	cmp    QWORD PTR [rbx+0x20],0x158
    1937ebd1:	00 
    1937ebd2:	0f 86 39 24 00 00    	jbe    19381011 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bf1>
    1937ebd8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ebdc:	48 83 b8 48 20 00 00 	cmp    QWORD PTR [rax+0x2048],0xd
    1937ebe3:	0d 
    1937ebe4:	0f 86 29 24 00 00    	jbe    19381013 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bf3>
    1937ebea:	48 8b 80 40 20 00 00 	mov    rax,QWORD PTR [rax+0x2040]
    1937ebf1:	c7 40 34 23 00 00 00 	mov    DWORD PTR [rax+0x34],0x23
    1937ebf8:	49 81 7d 00 58 01 00 	cmp    QWORD PTR [r13+0x0],0x158
    1937ebff:	00 
    1937ec00:	0f 86 0f 24 00 00    	jbe    19381015 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bf5>
    1937ec06:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ec0a:	48 83 b8 48 20 00 00 	cmp    QWORD PTR [rax+0x2048],0xe
    1937ec11:	0e 
    1937ec12:	0f 86 ff 23 00 00    	jbe    19381017 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bf7>
    1937ec18:	48 8b 80 40 20 00 00 	mov    rax,QWORD PTR [rax+0x2040]
    1937ec1f:	c7 40 38 22 00 00 00 	mov    DWORD PTR [rax+0x38],0x22
    1937ec26:	49 81 7d 00 58 01 00 	cmp    QWORD PTR [r13+0x0],0x158
    1937ec2d:	00 
    1937ec2e:	0f 86 e5 23 00 00    	jbe    19381019 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bf9>
    1937ec34:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ec38:	48 83 b8 48 20 00 00 	cmp    QWORD PTR [rax+0x2048],0xf
    1937ec3f:	0f 
    1937ec40:	0f 86 d5 23 00 00    	jbe    1938101b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bfb>
    1937ec46:	48 8b 80 40 20 00 00 	mov    rax,QWORD PTR [rax+0x2040]
    1937ec4d:	c7 40 3c 28 00 00 00 	mov    DWORD PTR [rax+0x3c],0x28
    1937ec54:	49 81 7d 00 58 01 00 	cmp    QWORD PTR [r13+0x0],0x158
    1937ec5b:	00 
    1937ec5c:	0f 86 bb 23 00 00    	jbe    1938101d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bfd>
    1937ec62:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ec66:	48 83 b8 48 20 00 00 	cmp    QWORD PTR [rax+0x2048],0x10
    1937ec6d:	10 
    1937ec6e:	0f 86 ab 23 00 00    	jbe    1938101f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6bff>
    1937ec74:	48 8b 80 40 20 00 00 	mov    rax,QWORD PTR [rax+0x2040]
    1937ec7b:	c7 40 40 12 00 00 00 	mov    DWORD PTR [rax+0x40],0x12
    1937ec82:	49 81 7d 00 58 01 00 	cmp    QWORD PTR [r13+0x0],0x158
    1937ec89:	00 
    1937ec8a:	0f 86 91 23 00 00    	jbe    19381021 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c01>
    1937ec90:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ec94:	48 83 b8 48 20 00 00 	cmp    QWORD PTR [rax+0x2048],0x11
    1937ec9b:	11 
    1937ec9c:	0f 86 81 23 00 00    	jbe    19381023 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c03>
    1937eca2:	48 8b 80 40 20 00 00 	mov    rax,QWORD PTR [rax+0x2040]
    1937eca9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937ecb0:	48 81 39 59 01 00 00 	cmp    QWORD PTR [rcx],0x159
    1937ecb7:	0f 86 68 23 00 00    	jbe    19381025 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c05>
    1937ecbd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ecc0:	c7 80 64 05 00 00 7f 	mov    DWORD PTR [rax+0x564],0x7f
    1937ecc7:	00 00 00 
    1937ecca:	48 81 7b 20 59 01 00 	cmp    QWORD PTR [rbx+0x20],0x159
    1937ecd1:	00 
    1937ecd2:	0f 86 4f 23 00 00    	jbe    19381027 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c07>
    1937ecd8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ecdc:	48 83 b8 60 20 00 00 	cmp    QWORD PTR [rax+0x2060],0xd
    1937ece3:	0d 
    1937ece4:	0f 86 3f 23 00 00    	jbe    19381029 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c09>
    1937ecea:	48 8b 80 58 20 00 00 	mov    rax,QWORD PTR [rax+0x2058]
    1937ecf1:	c7 40 34 23 00 00 00 	mov    DWORD PTR [rax+0x34],0x23
    1937ecf8:	49 81 7d 00 59 01 00 	cmp    QWORD PTR [r13+0x0],0x159
    1937ecff:	00 
    1937ed00:	0f 86 25 23 00 00    	jbe    1938102b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c0b>
    1937ed06:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ed0a:	48 83 b8 60 20 00 00 	cmp    QWORD PTR [rax+0x2060],0xe
    1937ed11:	0e 
    1937ed12:	0f 86 15 23 00 00    	jbe    1938102d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c0d>
    1937ed18:	48 8b 80 58 20 00 00 	mov    rax,QWORD PTR [rax+0x2058]
    1937ed1f:	c7 40 38 22 00 00 00 	mov    DWORD PTR [rax+0x38],0x22
    1937ed26:	49 81 7d 00 59 01 00 	cmp    QWORD PTR [r13+0x0],0x159
    1937ed2d:	00 
    1937ed2e:	0f 86 fb 22 00 00    	jbe    1938102f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c0f>
    1937ed34:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ed38:	48 83 b8 60 20 00 00 	cmp    QWORD PTR [rax+0x2060],0xf
    1937ed3f:	0f 
    1937ed40:	0f 86 eb 22 00 00    	jbe    19381031 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c11>
    1937ed46:	48 8b 80 58 20 00 00 	mov    rax,QWORD PTR [rax+0x2058]
    1937ed4d:	c7 40 3c 28 00 00 00 	mov    DWORD PTR [rax+0x3c],0x28
    1937ed54:	49 81 7d 00 59 01 00 	cmp    QWORD PTR [r13+0x0],0x159
    1937ed5b:	00 
    1937ed5c:	0f 86 d1 22 00 00    	jbe    19381033 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c13>
    1937ed62:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ed66:	48 83 b8 60 20 00 00 	cmp    QWORD PTR [rax+0x2060],0x10
    1937ed6d:	10 
    1937ed6e:	0f 86 c1 22 00 00    	jbe    19381035 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c15>
    1937ed74:	48 8b 80 58 20 00 00 	mov    rax,QWORD PTR [rax+0x2058]
    1937ed7b:	c7 40 40 12 00 00 00 	mov    DWORD PTR [rax+0x40],0x12
    1937ed82:	49 81 7d 00 59 01 00 	cmp    QWORD PTR [r13+0x0],0x159
    1937ed89:	00 
    1937ed8a:	0f 86 a7 22 00 00    	jbe    19381037 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c17>
    1937ed90:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ed94:	48 83 b8 60 20 00 00 	cmp    QWORD PTR [rax+0x2060],0x11
    1937ed9b:	11 
    1937ed9c:	0f 86 97 22 00 00    	jbe    19381039 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c19>
    1937eda2:	48 8b 80 58 20 00 00 	mov    rax,QWORD PTR [rax+0x2058]
    1937eda9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937edb0:	48 81 39 5a 01 00 00 	cmp    QWORD PTR [rcx],0x15a
    1937edb7:	0f 86 7e 22 00 00    	jbe    1938103b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c1b>
    1937edbd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937edc0:	c7 80 68 05 00 00 7f 	mov    DWORD PTR [rax+0x568],0x7f
    1937edc7:	00 00 00 
    1937edca:	48 81 7b 20 5a 01 00 	cmp    QWORD PTR [rbx+0x20],0x15a
    1937edd1:	00 
    1937edd2:	0f 86 65 22 00 00    	jbe    1938103d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c1d>
    1937edd8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937eddc:	48 83 b8 78 20 00 00 	cmp    QWORD PTR [rax+0x2078],0xd
    1937ede3:	0d 
    1937ede4:	0f 86 55 22 00 00    	jbe    1938103f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c1f>
    1937edea:	48 8b 80 70 20 00 00 	mov    rax,QWORD PTR [rax+0x2070]
    1937edf1:	c7 40 34 23 00 00 00 	mov    DWORD PTR [rax+0x34],0x23
    1937edf8:	49 81 7d 00 5a 01 00 	cmp    QWORD PTR [r13+0x0],0x15a
    1937edff:	00 
    1937ee00:	0f 86 3b 22 00 00    	jbe    19381041 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c21>
    1937ee06:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ee0a:	48 83 b8 78 20 00 00 	cmp    QWORD PTR [rax+0x2078],0xe
    1937ee11:	0e 
    1937ee12:	0f 86 2b 22 00 00    	jbe    19381043 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c23>
    1937ee18:	48 8b 80 70 20 00 00 	mov    rax,QWORD PTR [rax+0x2070]
    1937ee1f:	c7 40 38 22 00 00 00 	mov    DWORD PTR [rax+0x38],0x22
    1937ee26:	49 81 7d 00 5a 01 00 	cmp    QWORD PTR [r13+0x0],0x15a
    1937ee2d:	00 
    1937ee2e:	0f 86 11 22 00 00    	jbe    19381045 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c25>
    1937ee34:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ee38:	48 83 b8 78 20 00 00 	cmp    QWORD PTR [rax+0x2078],0xf
    1937ee3f:	0f 
    1937ee40:	0f 86 01 22 00 00    	jbe    19381047 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c27>
    1937ee46:	48 8b 80 70 20 00 00 	mov    rax,QWORD PTR [rax+0x2070]
    1937ee4d:	c7 40 3c 28 00 00 00 	mov    DWORD PTR [rax+0x3c],0x28
    1937ee54:	49 81 7d 00 5a 01 00 	cmp    QWORD PTR [r13+0x0],0x15a
    1937ee5b:	00 
    1937ee5c:	0f 86 e7 21 00 00    	jbe    19381049 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c29>
    1937ee62:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ee66:	48 83 b8 78 20 00 00 	cmp    QWORD PTR [rax+0x2078],0x10
    1937ee6d:	10 
    1937ee6e:	0f 86 d7 21 00 00    	jbe    1938104b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c2b>
    1937ee74:	48 8b 80 70 20 00 00 	mov    rax,QWORD PTR [rax+0x2070]
    1937ee7b:	c7 40 40 12 00 00 00 	mov    DWORD PTR [rax+0x40],0x12
    1937ee82:	49 81 7d 00 5a 01 00 	cmp    QWORD PTR [r13+0x0],0x15a
    1937ee89:	00 
    1937ee8a:	0f 86 bd 21 00 00    	jbe    1938104d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c2d>
    1937ee90:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ee94:	48 83 b8 78 20 00 00 	cmp    QWORD PTR [rax+0x2078],0x11
    1937ee9b:	11 
    1937ee9c:	0f 86 ad 21 00 00    	jbe    1938104f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c2f>
    1937eea2:	48 8b 80 70 20 00 00 	mov    rax,QWORD PTR [rax+0x2070]
    1937eea9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937eeb0:	48 81 39 5b 01 00 00 	cmp    QWORD PTR [rcx],0x15b
    1937eeb7:	0f 86 94 21 00 00    	jbe    19381051 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c31>
    1937eebd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937eec0:	c7 80 6c 05 00 00 7f 	mov    DWORD PTR [rax+0x56c],0x7f
    1937eec7:	00 00 00 
    1937eeca:	48 81 7b 20 5b 01 00 	cmp    QWORD PTR [rbx+0x20],0x15b
    1937eed1:	00 
    1937eed2:	0f 86 7b 21 00 00    	jbe    19381053 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c33>
    1937eed8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937eedc:	48 83 b8 90 20 00 00 	cmp    QWORD PTR [rax+0x2090],0xd
    1937eee3:	0d 
    1937eee4:	0f 86 6b 21 00 00    	jbe    19381055 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c35>
    1937eeea:	48 8b 80 88 20 00 00 	mov    rax,QWORD PTR [rax+0x2088]
    1937eef1:	c7 40 34 23 00 00 00 	mov    DWORD PTR [rax+0x34],0x23
    1937eef8:	49 81 7d 00 5b 01 00 	cmp    QWORD PTR [r13+0x0],0x15b
    1937eeff:	00 
    1937ef00:	0f 86 51 21 00 00    	jbe    19381057 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c37>
    1937ef06:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ef0a:	48 83 b8 90 20 00 00 	cmp    QWORD PTR [rax+0x2090],0xe
    1937ef11:	0e 
    1937ef12:	0f 86 41 21 00 00    	jbe    19381059 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c39>
    1937ef18:	48 8b 80 88 20 00 00 	mov    rax,QWORD PTR [rax+0x2088]
    1937ef1f:	c7 40 38 22 00 00 00 	mov    DWORD PTR [rax+0x38],0x22
    1937ef26:	49 81 7d 00 5b 01 00 	cmp    QWORD PTR [r13+0x0],0x15b
    1937ef2d:	00 
    1937ef2e:	0f 86 27 21 00 00    	jbe    1938105b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c3b>
    1937ef34:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ef38:	48 83 b8 90 20 00 00 	cmp    QWORD PTR [rax+0x2090],0xf
    1937ef3f:	0f 
    1937ef40:	0f 86 17 21 00 00    	jbe    1938105d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c3d>
    1937ef46:	48 8b 80 88 20 00 00 	mov    rax,QWORD PTR [rax+0x2088]
    1937ef4d:	c7 40 3c 28 00 00 00 	mov    DWORD PTR [rax+0x3c],0x28
    1937ef54:	49 81 7d 00 5b 01 00 	cmp    QWORD PTR [r13+0x0],0x15b
    1937ef5b:	00 
    1937ef5c:	0f 86 fd 20 00 00    	jbe    1938105f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c3f>
    1937ef62:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ef66:	48 83 b8 90 20 00 00 	cmp    QWORD PTR [rax+0x2090],0x10
    1937ef6d:	10 
    1937ef6e:	0f 86 ed 20 00 00    	jbe    19381061 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c41>
    1937ef74:	48 8b 80 88 20 00 00 	mov    rax,QWORD PTR [rax+0x2088]
    1937ef7b:	c7 40 40 12 00 00 00 	mov    DWORD PTR [rax+0x40],0x12
    1937ef82:	49 81 7d 00 5b 01 00 	cmp    QWORD PTR [r13+0x0],0x15b
    1937ef89:	00 
    1937ef8a:	0f 86 d3 20 00 00    	jbe    19381063 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c43>
    1937ef90:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937ef94:	48 83 b8 90 20 00 00 	cmp    QWORD PTR [rax+0x2090],0x11
    1937ef9b:	11 
    1937ef9c:	0f 86 c3 20 00 00    	jbe    19381065 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c45>
    1937efa2:	48 8b 80 88 20 00 00 	mov    rax,QWORD PTR [rax+0x2088]
    1937efa9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937efb0:	48 81 39 5c 01 00 00 	cmp    QWORD PTR [rcx],0x15c
    1937efb7:	0f 86 aa 20 00 00    	jbe    19381067 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c47>
    1937efbd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937efc0:	c7 80 70 05 00 00 7f 	mov    DWORD PTR [rax+0x570],0x7f
    1937efc7:	00 00 00 
    1937efca:	48 81 7b 20 5c 01 00 	cmp    QWORD PTR [rbx+0x20],0x15c
    1937efd1:	00 
    1937efd2:	0f 86 91 20 00 00    	jbe    19381069 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c49>
    1937efd8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937efdc:	48 83 b8 a8 20 00 00 	cmp    QWORD PTR [rax+0x20a8],0xd
    1937efe3:	0d 
    1937efe4:	0f 86 81 20 00 00    	jbe    1938106b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c4b>
    1937efea:	48 8b 80 a0 20 00 00 	mov    rax,QWORD PTR [rax+0x20a0]
    1937eff1:	c7 40 34 23 00 00 00 	mov    DWORD PTR [rax+0x34],0x23
    1937eff8:	49 81 7d 00 5c 01 00 	cmp    QWORD PTR [r13+0x0],0x15c
    1937efff:	00 
    1937f000:	0f 86 67 20 00 00    	jbe    1938106d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c4d>
    1937f006:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f00a:	48 83 b8 a8 20 00 00 	cmp    QWORD PTR [rax+0x20a8],0xe
    1937f011:	0e 
    1937f012:	0f 86 57 20 00 00    	jbe    1938106f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c4f>
    1937f018:	48 8b 80 a0 20 00 00 	mov    rax,QWORD PTR [rax+0x20a0]
    1937f01f:	c7 40 38 22 00 00 00 	mov    DWORD PTR [rax+0x38],0x22
    1937f026:	49 81 7d 00 5c 01 00 	cmp    QWORD PTR [r13+0x0],0x15c
    1937f02d:	00 
    1937f02e:	0f 86 3d 20 00 00    	jbe    19381071 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c51>
    1937f034:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f038:	48 83 b8 a8 20 00 00 	cmp    QWORD PTR [rax+0x20a8],0xf
    1937f03f:	0f 
    1937f040:	0f 86 2d 20 00 00    	jbe    19381073 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c53>
    1937f046:	48 8b 80 a0 20 00 00 	mov    rax,QWORD PTR [rax+0x20a0]
    1937f04d:	c7 40 3c 28 00 00 00 	mov    DWORD PTR [rax+0x3c],0x28
    1937f054:	49 81 7d 00 5c 01 00 	cmp    QWORD PTR [r13+0x0],0x15c
    1937f05b:	00 
    1937f05c:	0f 86 13 20 00 00    	jbe    19381075 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c55>
    1937f062:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f066:	48 83 b8 a8 20 00 00 	cmp    QWORD PTR [rax+0x20a8],0x10
    1937f06d:	10 
    1937f06e:	0f 86 03 20 00 00    	jbe    19381077 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c57>
    1937f074:	48 8b 80 a0 20 00 00 	mov    rax,QWORD PTR [rax+0x20a0]
    1937f07b:	c7 40 40 12 00 00 00 	mov    DWORD PTR [rax+0x40],0x12
    1937f082:	49 81 7d 00 5c 01 00 	cmp    QWORD PTR [r13+0x0],0x15c
    1937f089:	00 
    1937f08a:	0f 86 e9 1f 00 00    	jbe    19381079 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c59>
    1937f090:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f094:	48 83 b8 a8 20 00 00 	cmp    QWORD PTR [rax+0x20a8],0x11
    1937f09b:	11 
    1937f09c:	0f 86 d9 1f 00 00    	jbe    1938107b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c5b>
    1937f0a2:	48 8b 80 a0 20 00 00 	mov    rax,QWORD PTR [rax+0x20a0]
    1937f0a9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937f0b0:	48 81 39 5d 01 00 00 	cmp    QWORD PTR [rcx],0x15d
    1937f0b7:	0f 86 c0 1f 00 00    	jbe    1938107d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c5d>
    1937f0bd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937f0c0:	c7 80 74 05 00 00 7f 	mov    DWORD PTR [rax+0x574],0x7f
    1937f0c7:	00 00 00 
    1937f0ca:	48 81 7b 20 5d 01 00 	cmp    QWORD PTR [rbx+0x20],0x15d
    1937f0d1:	00 
    1937f0d2:	0f 86 a7 1f 00 00    	jbe    1938107f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c5f>
    1937f0d8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f0dc:	48 83 b8 c0 20 00 00 	cmp    QWORD PTR [rax+0x20c0],0xd
    1937f0e3:	0d 
    1937f0e4:	0f 86 97 1f 00 00    	jbe    19381081 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c61>
    1937f0ea:	48 8b 80 b8 20 00 00 	mov    rax,QWORD PTR [rax+0x20b8]
    1937f0f1:	c7 40 34 23 00 00 00 	mov    DWORD PTR [rax+0x34],0x23
    1937f0f8:	49 81 7d 00 5d 01 00 	cmp    QWORD PTR [r13+0x0],0x15d
    1937f0ff:	00 
    1937f100:	0f 86 7d 1f 00 00    	jbe    19381083 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c63>
    1937f106:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f10a:	48 83 b8 c0 20 00 00 	cmp    QWORD PTR [rax+0x20c0],0xe
    1937f111:	0e 
    1937f112:	0f 86 6d 1f 00 00    	jbe    19381085 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c65>
    1937f118:	48 8b 80 b8 20 00 00 	mov    rax,QWORD PTR [rax+0x20b8]
    1937f11f:	c7 40 38 22 00 00 00 	mov    DWORD PTR [rax+0x38],0x22
    1937f126:	49 81 7d 00 5d 01 00 	cmp    QWORD PTR [r13+0x0],0x15d
    1937f12d:	00 
    1937f12e:	0f 86 53 1f 00 00    	jbe    19381087 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c67>
    1937f134:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f138:	48 83 b8 c0 20 00 00 	cmp    QWORD PTR [rax+0x20c0],0xf
    1937f13f:	0f 
    1937f140:	0f 86 43 1f 00 00    	jbe    19381089 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c69>
    1937f146:	48 8b 80 b8 20 00 00 	mov    rax,QWORD PTR [rax+0x20b8]
    1937f14d:	c7 40 3c 28 00 00 00 	mov    DWORD PTR [rax+0x3c],0x28
    1937f154:	49 81 7d 00 5d 01 00 	cmp    QWORD PTR [r13+0x0],0x15d
    1937f15b:	00 
    1937f15c:	0f 86 29 1f 00 00    	jbe    1938108b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c6b>
    1937f162:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f166:	48 83 b8 c0 20 00 00 	cmp    QWORD PTR [rax+0x20c0],0x10
    1937f16d:	10 
    1937f16e:	0f 86 19 1f 00 00    	jbe    1938108d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c6d>
    1937f174:	48 8b 80 b8 20 00 00 	mov    rax,QWORD PTR [rax+0x20b8]
    1937f17b:	c7 40 40 12 00 00 00 	mov    DWORD PTR [rax+0x40],0x12
    1937f182:	49 81 7d 00 5d 01 00 	cmp    QWORD PTR [r13+0x0],0x15d
    1937f189:	00 
    1937f18a:	0f 86 ff 1e 00 00    	jbe    1938108f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c6f>
    1937f190:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f194:	48 83 b8 c0 20 00 00 	cmp    QWORD PTR [rax+0x20c0],0x11
    1937f19b:	11 
    1937f19c:	0f 86 ef 1e 00 00    	jbe    19381091 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c71>
    1937f1a2:	48 8b 80 b8 20 00 00 	mov    rax,QWORD PTR [rax+0x20b8]
    1937f1a9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937f1b0:	48 81 39 5e 01 00 00 	cmp    QWORD PTR [rcx],0x15e
    1937f1b7:	0f 86 d6 1e 00 00    	jbe    19381093 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c73>
    1937f1bd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937f1c0:	c7 80 78 05 00 00 7f 	mov    DWORD PTR [rax+0x578],0x7f
    1937f1c7:	00 00 00 
    1937f1ca:	48 81 7b 20 5e 01 00 	cmp    QWORD PTR [rbx+0x20],0x15e
    1937f1d1:	00 
    1937f1d2:	0f 86 bd 1e 00 00    	jbe    19381095 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c75>
    1937f1d8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f1dc:	48 83 b8 d8 20 00 00 	cmp    QWORD PTR [rax+0x20d8],0xd
    1937f1e3:	0d 
    1937f1e4:	0f 86 ad 1e 00 00    	jbe    19381097 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c77>
    1937f1ea:	48 8b 80 d0 20 00 00 	mov    rax,QWORD PTR [rax+0x20d0]
    1937f1f1:	c7 40 34 23 00 00 00 	mov    DWORD PTR [rax+0x34],0x23
    1937f1f8:	49 81 7d 00 5e 01 00 	cmp    QWORD PTR [r13+0x0],0x15e
    1937f1ff:	00 
    1937f200:	0f 86 93 1e 00 00    	jbe    19381099 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c79>
    1937f206:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f20a:	48 83 b8 d8 20 00 00 	cmp    QWORD PTR [rax+0x20d8],0xe
    1937f211:	0e 
    1937f212:	0f 86 83 1e 00 00    	jbe    1938109b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c7b>
    1937f218:	48 8b 80 d0 20 00 00 	mov    rax,QWORD PTR [rax+0x20d0]
    1937f21f:	c7 40 38 22 00 00 00 	mov    DWORD PTR [rax+0x38],0x22
    1937f226:	49 81 7d 00 5e 01 00 	cmp    QWORD PTR [r13+0x0],0x15e
    1937f22d:	00 
    1937f22e:	0f 86 69 1e 00 00    	jbe    1938109d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c7d>
    1937f234:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f238:	48 83 b8 d8 20 00 00 	cmp    QWORD PTR [rax+0x20d8],0xf
    1937f23f:	0f 
    1937f240:	0f 86 59 1e 00 00    	jbe    1938109f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c7f>
    1937f246:	48 8b 80 d0 20 00 00 	mov    rax,QWORD PTR [rax+0x20d0]
    1937f24d:	c7 40 3c 28 00 00 00 	mov    DWORD PTR [rax+0x3c],0x28
    1937f254:	49 81 7d 00 5e 01 00 	cmp    QWORD PTR [r13+0x0],0x15e
    1937f25b:	00 
    1937f25c:	0f 86 3f 1e 00 00    	jbe    193810a1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c81>
    1937f262:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f266:	48 83 b8 d8 20 00 00 	cmp    QWORD PTR [rax+0x20d8],0x10
    1937f26d:	10 
    1937f26e:	0f 86 2f 1e 00 00    	jbe    193810a3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c83>
    1937f274:	48 8b 80 d0 20 00 00 	mov    rax,QWORD PTR [rax+0x20d0]
    1937f27b:	c7 40 40 12 00 00 00 	mov    DWORD PTR [rax+0x40],0x12
    1937f282:	49 81 7d 00 5e 01 00 	cmp    QWORD PTR [r13+0x0],0x15e
    1937f289:	00 
    1937f28a:	0f 86 15 1e 00 00    	jbe    193810a5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c85>
    1937f290:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f294:	48 83 b8 d8 20 00 00 	cmp    QWORD PTR [rax+0x20d8],0x11
    1937f29b:	11 
    1937f29c:	0f 86 05 1e 00 00    	jbe    193810a7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c87>
    1937f2a2:	48 8b 80 d0 20 00 00 	mov    rax,QWORD PTR [rax+0x20d0]
    1937f2a9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937f2b0:	48 81 39 5f 01 00 00 	cmp    QWORD PTR [rcx],0x15f
    1937f2b7:	0f 86 ec 1d 00 00    	jbe    193810a9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c89>
    1937f2bd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937f2c0:	c7 80 7c 05 00 00 8d 	mov    DWORD PTR [rax+0x57c],0x8d
    1937f2c7:	00 00 00 
    1937f2ca:	48 81 7b 20 5f 01 00 	cmp    QWORD PTR [rbx+0x20],0x15f
    1937f2d1:	00 
    1937f2d2:	0f 86 d3 1d 00 00    	jbe    193810ab <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c8b>
    1937f2d8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f2dc:	48 83 b8 f0 20 00 00 	cmp    QWORD PTR [rax+0x20f0],0x16
    1937f2e3:	16 
    1937f2e4:	0f 86 c3 1d 00 00    	jbe    193810ad <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c8d>
    1937f2ea:	48 8b 80 e8 20 00 00 	mov    rax,QWORD PTR [rax+0x20e8]
    1937f2f1:	c7 40 58 15 00 00 00 	mov    DWORD PTR [rax+0x58],0x15
    1937f2f8:	49 81 7d 00 5f 01 00 	cmp    QWORD PTR [r13+0x0],0x15f
    1937f2ff:	00 
    1937f300:	0f 86 a9 1d 00 00    	jbe    193810af <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c8f>
    1937f306:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f30a:	48 83 b8 f0 20 00 00 	cmp    QWORD PTR [rax+0x20f0],0x17
    1937f311:	17 
    1937f312:	0f 86 99 1d 00 00    	jbe    193810b1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c91>
    1937f318:	48 8b 80 e8 20 00 00 	mov    rax,QWORD PTR [rax+0x20e8]
    1937f31f:	c7 40 5c 32 00 00 00 	mov    DWORD PTR [rax+0x5c],0x32
    1937f326:	49 81 7d 00 5f 01 00 	cmp    QWORD PTR [r13+0x0],0x15f
    1937f32d:	00 
    1937f32e:	0f 86 7f 1d 00 00    	jbe    193810b3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c93>
    1937f334:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f338:	48 83 b8 f0 20 00 00 	cmp    QWORD PTR [rax+0x20f0],0x18
    1937f33f:	18 
    1937f340:	0f 86 6f 1d 00 00    	jbe    193810b5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c95>
    1937f346:	48 8b 80 e8 20 00 00 	mov    rax,QWORD PTR [rax+0x20e8]
    1937f34d:	c7 40 60 32 00 00 00 	mov    DWORD PTR [rax+0x60],0x32
    1937f354:	49 81 7d 00 5f 01 00 	cmp    QWORD PTR [r13+0x0],0x15f
    1937f35b:	00 
    1937f35c:	0f 86 55 1d 00 00    	jbe    193810b7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c97>
    1937f362:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f366:	48 83 b8 f0 20 00 00 	cmp    QWORD PTR [rax+0x20f0],0x19
    1937f36d:	19 
    1937f36e:	0f 86 45 1d 00 00    	jbe    193810b9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c99>
    1937f374:	48 8b 80 e8 20 00 00 	mov    rax,QWORD PTR [rax+0x20e8]
    1937f37b:	c7 40 64 20 00 00 00 	mov    DWORD PTR [rax+0x64],0x20
    1937f382:	49 81 7d 00 5f 01 00 	cmp    QWORD PTR [r13+0x0],0x15f
    1937f389:	00 
    1937f38a:	0f 86 2b 1d 00 00    	jbe    193810bb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c9b>
    1937f390:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f394:	48 83 b8 f0 20 00 00 	cmp    QWORD PTR [rax+0x20f0],0x11
    1937f39b:	11 
    1937f39c:	0f 86 1b 1d 00 00    	jbe    193810bd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c9d>
    1937f3a2:	48 8b 80 e8 20 00 00 	mov    rax,QWORD PTR [rax+0x20e8]
    1937f3a9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937f3b0:	48 81 39 60 01 00 00 	cmp    QWORD PTR [rcx],0x160
    1937f3b7:	0f 86 02 1d 00 00    	jbe    193810bf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6c9f>
    1937f3bd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937f3c0:	c7 80 80 05 00 00 8d 	mov    DWORD PTR [rax+0x580],0x8d
    1937f3c7:	00 00 00 
    1937f3ca:	48 81 7b 20 60 01 00 	cmp    QWORD PTR [rbx+0x20],0x160
    1937f3d1:	00 
    1937f3d2:	0f 86 e9 1c 00 00    	jbe    193810c1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ca1>
    1937f3d8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f3dc:	48 83 b8 08 21 00 00 	cmp    QWORD PTR [rax+0x2108],0x16
    1937f3e3:	16 
    1937f3e4:	0f 86 d9 1c 00 00    	jbe    193810c3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ca3>
    1937f3ea:	48 8b 80 00 21 00 00 	mov    rax,QWORD PTR [rax+0x2100]
    1937f3f1:	c7 40 58 15 00 00 00 	mov    DWORD PTR [rax+0x58],0x15
    1937f3f8:	49 81 7d 00 60 01 00 	cmp    QWORD PTR [r13+0x0],0x160
    1937f3ff:	00 
    1937f400:	0f 86 bf 1c 00 00    	jbe    193810c5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ca5>
    1937f406:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f40a:	48 83 b8 08 21 00 00 	cmp    QWORD PTR [rax+0x2108],0x17
    1937f411:	17 
    1937f412:	0f 86 af 1c 00 00    	jbe    193810c7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ca7>
    1937f418:	48 8b 80 00 21 00 00 	mov    rax,QWORD PTR [rax+0x2100]
    1937f41f:	c7 40 5c 32 00 00 00 	mov    DWORD PTR [rax+0x5c],0x32
    1937f426:	49 81 7d 00 60 01 00 	cmp    QWORD PTR [r13+0x0],0x160
    1937f42d:	00 
    1937f42e:	0f 86 95 1c 00 00    	jbe    193810c9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ca9>
    1937f434:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f438:	48 83 b8 08 21 00 00 	cmp    QWORD PTR [rax+0x2108],0x18
    1937f43f:	18 
    1937f440:	0f 86 85 1c 00 00    	jbe    193810cb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cab>
    1937f446:	48 8b 80 00 21 00 00 	mov    rax,QWORD PTR [rax+0x2100]
    1937f44d:	c7 40 60 32 00 00 00 	mov    DWORD PTR [rax+0x60],0x32
    1937f454:	49 81 7d 00 60 01 00 	cmp    QWORD PTR [r13+0x0],0x160
    1937f45b:	00 
    1937f45c:	0f 86 6b 1c 00 00    	jbe    193810cd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cad>
    1937f462:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f466:	48 83 b8 08 21 00 00 	cmp    QWORD PTR [rax+0x2108],0x19
    1937f46d:	19 
    1937f46e:	0f 86 5b 1c 00 00    	jbe    193810cf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6caf>
    1937f474:	48 8b 80 00 21 00 00 	mov    rax,QWORD PTR [rax+0x2100]
    1937f47b:	c7 40 64 20 00 00 00 	mov    DWORD PTR [rax+0x64],0x20
    1937f482:	49 81 7d 00 60 01 00 	cmp    QWORD PTR [r13+0x0],0x160
    1937f489:	00 
    1937f48a:	0f 86 41 1c 00 00    	jbe    193810d1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cb1>
    1937f490:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f494:	48 83 b8 08 21 00 00 	cmp    QWORD PTR [rax+0x2108],0x11
    1937f49b:	11 
    1937f49c:	0f 86 31 1c 00 00    	jbe    193810d3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cb3>
    1937f4a2:	48 8b 80 00 21 00 00 	mov    rax,QWORD PTR [rax+0x2100]
    1937f4a9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937f4b0:	48 81 39 61 01 00 00 	cmp    QWORD PTR [rcx],0x161
    1937f4b7:	0f 86 18 1c 00 00    	jbe    193810d5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cb5>
    1937f4bd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937f4c0:	c7 80 84 05 00 00 8d 	mov    DWORD PTR [rax+0x584],0x8d
    1937f4c7:	00 00 00 
    1937f4ca:	48 81 7b 20 61 01 00 	cmp    QWORD PTR [rbx+0x20],0x161
    1937f4d1:	00 
    1937f4d2:	0f 86 ff 1b 00 00    	jbe    193810d7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cb7>
    1937f4d8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f4dc:	48 83 b8 20 21 00 00 	cmp    QWORD PTR [rax+0x2120],0x16
    1937f4e3:	16 
    1937f4e4:	0f 86 ef 1b 00 00    	jbe    193810d9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cb9>
    1937f4ea:	48 8b 80 18 21 00 00 	mov    rax,QWORD PTR [rax+0x2118]
    1937f4f1:	c7 40 58 15 00 00 00 	mov    DWORD PTR [rax+0x58],0x15
    1937f4f8:	49 81 7d 00 61 01 00 	cmp    QWORD PTR [r13+0x0],0x161
    1937f4ff:	00 
    1937f500:	0f 86 d5 1b 00 00    	jbe    193810db <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cbb>
    1937f506:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f50a:	48 83 b8 20 21 00 00 	cmp    QWORD PTR [rax+0x2120],0x17
    1937f511:	17 
    1937f512:	0f 86 c5 1b 00 00    	jbe    193810dd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cbd>
    1937f518:	48 8b 80 18 21 00 00 	mov    rax,QWORD PTR [rax+0x2118]
    1937f51f:	c7 40 5c 32 00 00 00 	mov    DWORD PTR [rax+0x5c],0x32
    1937f526:	49 81 7d 00 61 01 00 	cmp    QWORD PTR [r13+0x0],0x161
    1937f52d:	00 
    1937f52e:	0f 86 ab 1b 00 00    	jbe    193810df <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cbf>
    1937f534:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f538:	48 83 b8 20 21 00 00 	cmp    QWORD PTR [rax+0x2120],0x18
    1937f53f:	18 
    1937f540:	0f 86 9b 1b 00 00    	jbe    193810e1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cc1>
    1937f546:	48 8b 80 18 21 00 00 	mov    rax,QWORD PTR [rax+0x2118]
    1937f54d:	c7 40 60 32 00 00 00 	mov    DWORD PTR [rax+0x60],0x32
    1937f554:	49 81 7d 00 61 01 00 	cmp    QWORD PTR [r13+0x0],0x161
    1937f55b:	00 
    1937f55c:	0f 86 81 1b 00 00    	jbe    193810e3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cc3>
    1937f562:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f566:	48 83 b8 20 21 00 00 	cmp    QWORD PTR [rax+0x2120],0x19
    1937f56d:	19 
    1937f56e:	0f 86 71 1b 00 00    	jbe    193810e5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cc5>
    1937f574:	48 8b 80 18 21 00 00 	mov    rax,QWORD PTR [rax+0x2118]
    1937f57b:	c7 40 64 20 00 00 00 	mov    DWORD PTR [rax+0x64],0x20
    1937f582:	49 81 7d 00 61 01 00 	cmp    QWORD PTR [r13+0x0],0x161
    1937f589:	00 
    1937f58a:	0f 86 57 1b 00 00    	jbe    193810e7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cc7>
    1937f590:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f594:	48 83 b8 20 21 00 00 	cmp    QWORD PTR [rax+0x2120],0x11
    1937f59b:	11 
    1937f59c:	0f 86 47 1b 00 00    	jbe    193810e9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cc9>
    1937f5a2:	48 8b 80 18 21 00 00 	mov    rax,QWORD PTR [rax+0x2118]
    1937f5a9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937f5b0:	48 81 39 62 01 00 00 	cmp    QWORD PTR [rcx],0x162
    1937f5b7:	0f 86 2e 1b 00 00    	jbe    193810eb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ccb>
    1937f5bd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937f5c0:	c7 80 88 05 00 00 8d 	mov    DWORD PTR [rax+0x588],0x8d
    1937f5c7:	00 00 00 
    1937f5ca:	48 81 7b 20 62 01 00 	cmp    QWORD PTR [rbx+0x20],0x162
    1937f5d1:	00 
    1937f5d2:	0f 86 15 1b 00 00    	jbe    193810ed <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ccd>
    1937f5d8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f5dc:	48 83 b8 38 21 00 00 	cmp    QWORD PTR [rax+0x2138],0x16
    1937f5e3:	16 
    1937f5e4:	0f 86 05 1b 00 00    	jbe    193810ef <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ccf>
    1937f5ea:	48 8b 80 30 21 00 00 	mov    rax,QWORD PTR [rax+0x2130]
    1937f5f1:	c7 40 58 15 00 00 00 	mov    DWORD PTR [rax+0x58],0x15
    1937f5f8:	49 81 7d 00 62 01 00 	cmp    QWORD PTR [r13+0x0],0x162
    1937f5ff:	00 
    1937f600:	0f 86 eb 1a 00 00    	jbe    193810f1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cd1>
    1937f606:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f60a:	48 83 b8 38 21 00 00 	cmp    QWORD PTR [rax+0x2138],0x17
    1937f611:	17 
    1937f612:	0f 86 db 1a 00 00    	jbe    193810f3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cd3>
    1937f618:	48 8b 80 30 21 00 00 	mov    rax,QWORD PTR [rax+0x2130]
    1937f61f:	c7 40 5c 32 00 00 00 	mov    DWORD PTR [rax+0x5c],0x32
    1937f626:	49 81 7d 00 62 01 00 	cmp    QWORD PTR [r13+0x0],0x162
    1937f62d:	00 
    1937f62e:	0f 86 c1 1a 00 00    	jbe    193810f5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cd5>
    1937f634:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f638:	48 83 b8 38 21 00 00 	cmp    QWORD PTR [rax+0x2138],0x18
    1937f63f:	18 
    1937f640:	0f 86 b1 1a 00 00    	jbe    193810f7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cd7>
    1937f646:	48 8b 80 30 21 00 00 	mov    rax,QWORD PTR [rax+0x2130]
    1937f64d:	c7 40 60 32 00 00 00 	mov    DWORD PTR [rax+0x60],0x32
    1937f654:	49 81 7d 00 62 01 00 	cmp    QWORD PTR [r13+0x0],0x162
    1937f65b:	00 
    1937f65c:	0f 86 97 1a 00 00    	jbe    193810f9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cd9>
    1937f662:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f666:	48 83 b8 38 21 00 00 	cmp    QWORD PTR [rax+0x2138],0x19
    1937f66d:	19 
    1937f66e:	0f 86 87 1a 00 00    	jbe    193810fb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cdb>
    1937f674:	48 8b 80 30 21 00 00 	mov    rax,QWORD PTR [rax+0x2130]
    1937f67b:	c7 40 64 20 00 00 00 	mov    DWORD PTR [rax+0x64],0x20
    1937f682:	49 81 7d 00 62 01 00 	cmp    QWORD PTR [r13+0x0],0x162
    1937f689:	00 
    1937f68a:	0f 86 6d 1a 00 00    	jbe    193810fd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cdd>
    1937f690:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f694:	48 83 b8 38 21 00 00 	cmp    QWORD PTR [rax+0x2138],0x11
    1937f69b:	11 
    1937f69c:	0f 86 5d 1a 00 00    	jbe    193810ff <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cdf>
    1937f6a2:	48 8b 80 30 21 00 00 	mov    rax,QWORD PTR [rax+0x2130]
    1937f6a9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937f6b0:	48 81 39 63 01 00 00 	cmp    QWORD PTR [rcx],0x163
    1937f6b7:	0f 86 44 1a 00 00    	jbe    19381101 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ce1>
    1937f6bd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937f6c0:	c7 80 8c 05 00 00 8d 	mov    DWORD PTR [rax+0x58c],0x8d
    1937f6c7:	00 00 00 
    1937f6ca:	48 81 7b 20 63 01 00 	cmp    QWORD PTR [rbx+0x20],0x163
    1937f6d1:	00 
    1937f6d2:	0f 86 2b 1a 00 00    	jbe    19381103 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ce3>
    1937f6d8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f6dc:	48 83 b8 50 21 00 00 	cmp    QWORD PTR [rax+0x2150],0x16
    1937f6e3:	16 
    1937f6e4:	0f 86 1b 1a 00 00    	jbe    19381105 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ce5>
    1937f6ea:	48 8b 80 48 21 00 00 	mov    rax,QWORD PTR [rax+0x2148]
    1937f6f1:	c7 40 58 15 00 00 00 	mov    DWORD PTR [rax+0x58],0x15
    1937f6f8:	49 81 7d 00 63 01 00 	cmp    QWORD PTR [r13+0x0],0x163
    1937f6ff:	00 
    1937f700:	0f 86 01 1a 00 00    	jbe    19381107 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ce7>
    1937f706:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f70a:	48 83 b8 50 21 00 00 	cmp    QWORD PTR [rax+0x2150],0x17
    1937f711:	17 
    1937f712:	0f 86 f1 19 00 00    	jbe    19381109 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ce9>
    1937f718:	48 8b 80 48 21 00 00 	mov    rax,QWORD PTR [rax+0x2148]
    1937f71f:	c7 40 5c 32 00 00 00 	mov    DWORD PTR [rax+0x5c],0x32
    1937f726:	49 81 7d 00 63 01 00 	cmp    QWORD PTR [r13+0x0],0x163
    1937f72d:	00 
    1937f72e:	0f 86 d7 19 00 00    	jbe    1938110b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ceb>
    1937f734:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f738:	48 83 b8 50 21 00 00 	cmp    QWORD PTR [rax+0x2150],0x18
    1937f73f:	18 
    1937f740:	0f 86 c7 19 00 00    	jbe    1938110d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ced>
    1937f746:	48 8b 80 48 21 00 00 	mov    rax,QWORD PTR [rax+0x2148]
    1937f74d:	c7 40 60 32 00 00 00 	mov    DWORD PTR [rax+0x60],0x32
    1937f754:	49 81 7d 00 63 01 00 	cmp    QWORD PTR [r13+0x0],0x163
    1937f75b:	00 
    1937f75c:	0f 86 ad 19 00 00    	jbe    1938110f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cef>
    1937f762:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f766:	48 83 b8 50 21 00 00 	cmp    QWORD PTR [rax+0x2150],0x19
    1937f76d:	19 
    1937f76e:	0f 86 9d 19 00 00    	jbe    19381111 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cf1>
    1937f774:	48 8b 80 48 21 00 00 	mov    rax,QWORD PTR [rax+0x2148]
    1937f77b:	c7 40 64 20 00 00 00 	mov    DWORD PTR [rax+0x64],0x20
    1937f782:	49 81 7d 00 63 01 00 	cmp    QWORD PTR [r13+0x0],0x163
    1937f789:	00 
    1937f78a:	0f 86 83 19 00 00    	jbe    19381113 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cf3>
    1937f790:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f794:	48 83 b8 50 21 00 00 	cmp    QWORD PTR [rax+0x2150],0x11
    1937f79b:	11 
    1937f79c:	0f 86 73 19 00 00    	jbe    19381115 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cf5>
    1937f7a2:	48 8b 80 48 21 00 00 	mov    rax,QWORD PTR [rax+0x2148]
    1937f7a9:	c7 40 44 04 00 00 00 	mov    DWORD PTR [rax+0x44],0x4
    1937f7b0:	48 81 39 64 01 00 00 	cmp    QWORD PTR [rcx],0x164
    1937f7b7:	0f 86 5a 19 00 00    	jbe    19381117 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cf7>
    1937f7bd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937f7c0:	c7 80 90 05 00 00 91 	mov    DWORD PTR [rax+0x590],0x91
    1937f7c7:	00 00 00 
    1937f7ca:	48 81 7b 20 64 01 00 	cmp    QWORD PTR [rbx+0x20],0x164
    1937f7d1:	00 
    1937f7d2:	0f 86 41 19 00 00    	jbe    19381119 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cf9>
    1937f7d8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f7dc:	48 83 b8 68 21 00 00 	cmp    QWORD PTR [rax+0x2168],0x16
    1937f7e3:	16 
    1937f7e4:	0f 86 31 19 00 00    	jbe    1938111b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cfb>
    1937f7ea:	48 8b 80 60 21 00 00 	mov    rax,QWORD PTR [rax+0x2160]
    1937f7f1:	c7 40 58 19 00 00 00 	mov    DWORD PTR [rax+0x58],0x19
    1937f7f8:	49 81 7d 00 64 01 00 	cmp    QWORD PTR [r13+0x0],0x164
    1937f7ff:	00 
    1937f800:	0f 86 17 19 00 00    	jbe    1938111d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cfd>
    1937f806:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f80a:	48 83 b8 68 21 00 00 	cmp    QWORD PTR [rax+0x2168],0x17
    1937f811:	17 
    1937f812:	0f 86 07 19 00 00    	jbe    1938111f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6cff>
    1937f818:	48 8b 80 60 21 00 00 	mov    rax,QWORD PTR [rax+0x2160]
    1937f81f:	c7 40 5c 30 00 00 00 	mov    DWORD PTR [rax+0x5c],0x30
    1937f826:	49 81 7d 00 64 01 00 	cmp    QWORD PTR [r13+0x0],0x164
    1937f82d:	00 
    1937f82e:	0f 86 ed 18 00 00    	jbe    19381121 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d01>
    1937f834:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f838:	48 83 b8 68 21 00 00 	cmp    QWORD PTR [rax+0x2168],0x18
    1937f83f:	18 
    1937f840:	0f 86 dd 18 00 00    	jbe    19381123 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d03>
    1937f846:	48 8b 80 60 21 00 00 	mov    rax,QWORD PTR [rax+0x2160]
    1937f84d:	c7 40 60 36 00 00 00 	mov    DWORD PTR [rax+0x60],0x36
    1937f854:	49 81 7d 00 64 01 00 	cmp    QWORD PTR [r13+0x0],0x164
    1937f85b:	00 
    1937f85c:	0f 86 c3 18 00 00    	jbe    19381125 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d05>
    1937f862:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f866:	48 83 b8 68 21 00 00 	cmp    QWORD PTR [rax+0x2168],0x19
    1937f86d:	19 
    1937f86e:	0f 86 b3 18 00 00    	jbe    19381127 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d07>
    1937f874:	48 8b 80 60 21 00 00 	mov    rax,QWORD PTR [rax+0x2160]
    1937f87b:	c7 40 64 24 00 00 00 	mov    DWORD PTR [rax+0x64],0x24
    1937f882:	49 81 7d 00 64 01 00 	cmp    QWORD PTR [r13+0x0],0x164
    1937f889:	00 
    1937f88a:	0f 86 99 18 00 00    	jbe    19381129 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d09>
    1937f890:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f894:	48 83 b8 68 21 00 00 	cmp    QWORD PTR [rax+0x2168],0x11
    1937f89b:	11 
    1937f89c:	0f 86 89 18 00 00    	jbe    1938112b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d0b>
    1937f8a2:	48 8b 80 60 21 00 00 	mov    rax,QWORD PTR [rax+0x2160]
    1937f8a9:	c7 40 44 08 00 00 00 	mov    DWORD PTR [rax+0x44],0x8
    1937f8b0:	48 81 39 65 01 00 00 	cmp    QWORD PTR [rcx],0x165
    1937f8b7:	0f 86 70 18 00 00    	jbe    1938112d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d0d>
    1937f8bd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937f8c0:	c7 80 94 05 00 00 91 	mov    DWORD PTR [rax+0x594],0x91
    1937f8c7:	00 00 00 
    1937f8ca:	48 81 7b 20 65 01 00 	cmp    QWORD PTR [rbx+0x20],0x165
    1937f8d1:	00 
    1937f8d2:	0f 86 57 18 00 00    	jbe    1938112f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d0f>
    1937f8d8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f8dc:	48 83 b8 80 21 00 00 	cmp    QWORD PTR [rax+0x2180],0x16
    1937f8e3:	16 
    1937f8e4:	0f 86 47 18 00 00    	jbe    19381131 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d11>
    1937f8ea:	48 8b 80 78 21 00 00 	mov    rax,QWORD PTR [rax+0x2178]
    1937f8f1:	c7 40 58 19 00 00 00 	mov    DWORD PTR [rax+0x58],0x19
    1937f8f8:	49 81 7d 00 65 01 00 	cmp    QWORD PTR [r13+0x0],0x165
    1937f8ff:	00 
    1937f900:	0f 86 2d 18 00 00    	jbe    19381133 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d13>
    1937f906:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f90a:	48 83 b8 80 21 00 00 	cmp    QWORD PTR [rax+0x2180],0x17
    1937f911:	17 
    1937f912:	0f 86 1d 18 00 00    	jbe    19381135 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d15>
    1937f918:	48 8b 80 78 21 00 00 	mov    rax,QWORD PTR [rax+0x2178]
    1937f91f:	c7 40 5c 30 00 00 00 	mov    DWORD PTR [rax+0x5c],0x30
    1937f926:	49 81 7d 00 65 01 00 	cmp    QWORD PTR [r13+0x0],0x165
    1937f92d:	00 
    1937f92e:	0f 86 03 18 00 00    	jbe    19381137 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d17>
    1937f934:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f938:	48 83 b8 80 21 00 00 	cmp    QWORD PTR [rax+0x2180],0x18
    1937f93f:	18 
    1937f940:	0f 86 f3 17 00 00    	jbe    19381139 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d19>
    1937f946:	48 8b 80 78 21 00 00 	mov    rax,QWORD PTR [rax+0x2178]
    1937f94d:	c7 40 60 36 00 00 00 	mov    DWORD PTR [rax+0x60],0x36
    1937f954:	49 81 7d 00 65 01 00 	cmp    QWORD PTR [r13+0x0],0x165
    1937f95b:	00 
    1937f95c:	0f 86 d9 17 00 00    	jbe    1938113b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d1b>
    1937f962:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f966:	48 83 b8 80 21 00 00 	cmp    QWORD PTR [rax+0x2180],0x19
    1937f96d:	19 
    1937f96e:	0f 86 c9 17 00 00    	jbe    1938113d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d1d>
    1937f974:	48 8b 80 78 21 00 00 	mov    rax,QWORD PTR [rax+0x2178]
    1937f97b:	c7 40 64 24 00 00 00 	mov    DWORD PTR [rax+0x64],0x24
    1937f982:	49 81 7d 00 65 01 00 	cmp    QWORD PTR [r13+0x0],0x165
    1937f989:	00 
    1937f98a:	0f 86 af 17 00 00    	jbe    1938113f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d1f>
    1937f990:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f994:	48 83 b8 80 21 00 00 	cmp    QWORD PTR [rax+0x2180],0x11
    1937f99b:	11 
    1937f99c:	0f 86 9f 17 00 00    	jbe    19381141 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d21>
    1937f9a2:	48 8b 80 78 21 00 00 	mov    rax,QWORD PTR [rax+0x2178]
    1937f9a9:	c7 40 44 08 00 00 00 	mov    DWORD PTR [rax+0x44],0x8
    1937f9b0:	48 81 39 66 01 00 00 	cmp    QWORD PTR [rcx],0x166
    1937f9b7:	0f 86 86 17 00 00    	jbe    19381143 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d23>
    1937f9bd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937f9c0:	c7 80 98 05 00 00 91 	mov    DWORD PTR [rax+0x598],0x91
    1937f9c7:	00 00 00 
    1937f9ca:	48 81 7b 20 66 01 00 	cmp    QWORD PTR [rbx+0x20],0x166
    1937f9d1:	00 
    1937f9d2:	0f 86 6d 17 00 00    	jbe    19381145 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d25>
    1937f9d8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937f9dc:	48 83 b8 98 21 00 00 	cmp    QWORD PTR [rax+0x2198],0x16
    1937f9e3:	16 
    1937f9e4:	0f 86 5d 17 00 00    	jbe    19381147 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d27>
    1937f9ea:	48 8b 80 90 21 00 00 	mov    rax,QWORD PTR [rax+0x2190]
    1937f9f1:	c7 40 58 19 00 00 00 	mov    DWORD PTR [rax+0x58],0x19
    1937f9f8:	49 81 7d 00 66 01 00 	cmp    QWORD PTR [r13+0x0],0x166
    1937f9ff:	00 
    1937fa00:	0f 86 43 17 00 00    	jbe    19381149 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d29>
    1937fa06:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fa0a:	48 83 b8 98 21 00 00 	cmp    QWORD PTR [rax+0x2198],0x17
    1937fa11:	17 
    1937fa12:	0f 86 33 17 00 00    	jbe    1938114b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d2b>
    1937fa18:	48 8b 80 90 21 00 00 	mov    rax,QWORD PTR [rax+0x2190]
    1937fa1f:	c7 40 5c 30 00 00 00 	mov    DWORD PTR [rax+0x5c],0x30
    1937fa26:	49 81 7d 00 66 01 00 	cmp    QWORD PTR [r13+0x0],0x166
    1937fa2d:	00 
    1937fa2e:	0f 86 19 17 00 00    	jbe    1938114d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d2d>
    1937fa34:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fa38:	48 83 b8 98 21 00 00 	cmp    QWORD PTR [rax+0x2198],0x18
    1937fa3f:	18 
    1937fa40:	0f 86 09 17 00 00    	jbe    1938114f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d2f>
    1937fa46:	48 8b 80 90 21 00 00 	mov    rax,QWORD PTR [rax+0x2190]
    1937fa4d:	c7 40 60 36 00 00 00 	mov    DWORD PTR [rax+0x60],0x36
    1937fa54:	49 81 7d 00 66 01 00 	cmp    QWORD PTR [r13+0x0],0x166
    1937fa5b:	00 
    1937fa5c:	0f 86 ef 16 00 00    	jbe    19381151 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d31>
    1937fa62:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fa66:	48 83 b8 98 21 00 00 	cmp    QWORD PTR [rax+0x2198],0x19
    1937fa6d:	19 
    1937fa6e:	0f 86 df 16 00 00    	jbe    19381153 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d33>
    1937fa74:	48 8b 80 90 21 00 00 	mov    rax,QWORD PTR [rax+0x2190]
    1937fa7b:	c7 40 64 24 00 00 00 	mov    DWORD PTR [rax+0x64],0x24
    1937fa82:	49 81 7d 00 66 01 00 	cmp    QWORD PTR [r13+0x0],0x166
    1937fa89:	00 
    1937fa8a:	0f 86 c5 16 00 00    	jbe    19381155 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d35>
    1937fa90:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fa94:	48 83 b8 98 21 00 00 	cmp    QWORD PTR [rax+0x2198],0x11
    1937fa9b:	11 
    1937fa9c:	0f 86 b5 16 00 00    	jbe    19381157 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d37>
    1937faa2:	48 8b 80 90 21 00 00 	mov    rax,QWORD PTR [rax+0x2190]
    1937faa9:	c7 40 44 08 00 00 00 	mov    DWORD PTR [rax+0x44],0x8
    1937fab0:	48 81 39 67 01 00 00 	cmp    QWORD PTR [rcx],0x167
    1937fab7:	0f 86 9c 16 00 00    	jbe    19381159 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d39>
    1937fabd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fac0:	c7 80 9c 05 00 00 91 	mov    DWORD PTR [rax+0x59c],0x91
    1937fac7:	00 00 00 
    1937faca:	48 81 7b 20 67 01 00 	cmp    QWORD PTR [rbx+0x20],0x167
    1937fad1:	00 
    1937fad2:	0f 86 83 16 00 00    	jbe    1938115b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d3b>
    1937fad8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fadc:	48 83 b8 b0 21 00 00 	cmp    QWORD PTR [rax+0x21b0],0x16
    1937fae3:	16 
    1937fae4:	0f 86 73 16 00 00    	jbe    1938115d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d3d>
    1937faea:	48 8b 80 a8 21 00 00 	mov    rax,QWORD PTR [rax+0x21a8]
    1937faf1:	c7 40 58 19 00 00 00 	mov    DWORD PTR [rax+0x58],0x19
    1937faf8:	49 81 7d 00 67 01 00 	cmp    QWORD PTR [r13+0x0],0x167
    1937faff:	00 
    1937fb00:	0f 86 59 16 00 00    	jbe    1938115f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d3f>
    1937fb06:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fb0a:	48 83 b8 b0 21 00 00 	cmp    QWORD PTR [rax+0x21b0],0x17
    1937fb11:	17 
    1937fb12:	0f 86 49 16 00 00    	jbe    19381161 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d41>
    1937fb18:	48 8b 80 a8 21 00 00 	mov    rax,QWORD PTR [rax+0x21a8]
    1937fb1f:	c7 40 5c 30 00 00 00 	mov    DWORD PTR [rax+0x5c],0x30
    1937fb26:	49 81 7d 00 67 01 00 	cmp    QWORD PTR [r13+0x0],0x167
    1937fb2d:	00 
    1937fb2e:	0f 86 2f 16 00 00    	jbe    19381163 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d43>
    1937fb34:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fb38:	48 83 b8 b0 21 00 00 	cmp    QWORD PTR [rax+0x21b0],0x18
    1937fb3f:	18 
    1937fb40:	0f 86 1f 16 00 00    	jbe    19381165 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d45>
    1937fb46:	48 8b 80 a8 21 00 00 	mov    rax,QWORD PTR [rax+0x21a8]
    1937fb4d:	c7 40 60 36 00 00 00 	mov    DWORD PTR [rax+0x60],0x36
    1937fb54:	49 81 7d 00 67 01 00 	cmp    QWORD PTR [r13+0x0],0x167
    1937fb5b:	00 
    1937fb5c:	0f 86 05 16 00 00    	jbe    19381167 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d47>
    1937fb62:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fb66:	48 83 b8 b0 21 00 00 	cmp    QWORD PTR [rax+0x21b0],0x19
    1937fb6d:	19 
    1937fb6e:	0f 86 f5 15 00 00    	jbe    19381169 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d49>
    1937fb74:	48 8b 80 a8 21 00 00 	mov    rax,QWORD PTR [rax+0x21a8]
    1937fb7b:	c7 40 64 24 00 00 00 	mov    DWORD PTR [rax+0x64],0x24
    1937fb82:	49 81 7d 00 67 01 00 	cmp    QWORD PTR [r13+0x0],0x167
    1937fb89:	00 
    1937fb8a:	0f 86 db 15 00 00    	jbe    1938116b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d4b>
    1937fb90:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fb94:	48 83 b8 b0 21 00 00 	cmp    QWORD PTR [rax+0x21b0],0x11
    1937fb9b:	11 
    1937fb9c:	0f 86 cb 15 00 00    	jbe    1938116d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d4d>
    1937fba2:	48 8b 80 a8 21 00 00 	mov    rax,QWORD PTR [rax+0x21a8]
    1937fba9:	c7 40 44 08 00 00 00 	mov    DWORD PTR [rax+0x44],0x8
    1937fbb0:	48 81 39 68 01 00 00 	cmp    QWORD PTR [rcx],0x168
    1937fbb7:	0f 86 b2 15 00 00    	jbe    1938116f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d4f>
    1937fbbd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fbc0:	c7 80 a0 05 00 00 91 	mov    DWORD PTR [rax+0x5a0],0x91
    1937fbc7:	00 00 00 
    1937fbca:	48 81 7b 20 68 01 00 	cmp    QWORD PTR [rbx+0x20],0x168
    1937fbd1:	00 
    1937fbd2:	0f 86 99 15 00 00    	jbe    19381171 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d51>
    1937fbd8:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fbdc:	48 83 b8 c8 21 00 00 	cmp    QWORD PTR [rax+0x21c8],0x16
    1937fbe3:	16 
    1937fbe4:	0f 86 89 15 00 00    	jbe    19381173 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d53>
    1937fbea:	48 8b 80 c0 21 00 00 	mov    rax,QWORD PTR [rax+0x21c0]
    1937fbf1:	c7 40 58 19 00 00 00 	mov    DWORD PTR [rax+0x58],0x19
    1937fbf8:	49 81 7d 00 68 01 00 	cmp    QWORD PTR [r13+0x0],0x168
    1937fbff:	00 
    1937fc00:	0f 86 6f 15 00 00    	jbe    19381175 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d55>
    1937fc06:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fc0a:	48 83 b8 c8 21 00 00 	cmp    QWORD PTR [rax+0x21c8],0x17
    1937fc11:	17 
    1937fc12:	0f 86 5f 15 00 00    	jbe    19381177 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d57>
    1937fc18:	48 8b 80 c0 21 00 00 	mov    rax,QWORD PTR [rax+0x21c0]
    1937fc1f:	c7 40 5c 30 00 00 00 	mov    DWORD PTR [rax+0x5c],0x30
    1937fc26:	49 81 7d 00 68 01 00 	cmp    QWORD PTR [r13+0x0],0x168
    1937fc2d:	00 
    1937fc2e:	0f 86 45 15 00 00    	jbe    19381179 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d59>
    1937fc34:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fc38:	48 83 b8 c8 21 00 00 	cmp    QWORD PTR [rax+0x21c8],0x18
    1937fc3f:	18 
    1937fc40:	0f 86 35 15 00 00    	jbe    1938117b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d5b>
    1937fc46:	48 8b 80 c0 21 00 00 	mov    rax,QWORD PTR [rax+0x21c0]
    1937fc4d:	c7 40 60 36 00 00 00 	mov    DWORD PTR [rax+0x60],0x36
    1937fc54:	49 81 7d 00 68 01 00 	cmp    QWORD PTR [r13+0x0],0x168
    1937fc5b:	00 
    1937fc5c:	0f 86 1b 15 00 00    	jbe    1938117d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d5d>
    1937fc62:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fc66:	48 83 b8 c8 21 00 00 	cmp    QWORD PTR [rax+0x21c8],0x19
    1937fc6d:	19 
    1937fc6e:	0f 86 0b 15 00 00    	jbe    1938117f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d5f>
    1937fc74:	48 8b 80 c0 21 00 00 	mov    rax,QWORD PTR [rax+0x21c0]
    1937fc7b:	c7 40 64 24 00 00 00 	mov    DWORD PTR [rax+0x64],0x24
    1937fc82:	49 81 7d 00 68 01 00 	cmp    QWORD PTR [r13+0x0],0x168
    1937fc89:	00 
    1937fc8a:	0f 86 f1 14 00 00    	jbe    19381181 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d61>
    1937fc90:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fc94:	48 83 b8 c8 21 00 00 	cmp    QWORD PTR [rax+0x21c8],0x11
    1937fc9b:	11 
    1937fc9c:	0f 86 e1 14 00 00    	jbe    19381183 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d63>
    1937fca2:	48 8b 80 c0 21 00 00 	mov    rax,QWORD PTR [rax+0x21c0]
    1937fca9:	c7 40 44 08 00 00 00 	mov    DWORD PTR [rax+0x44],0x8
    1937fcb0:	48 81 39 69 01 00 00 	cmp    QWORD PTR [rcx],0x169
    1937fcb7:	0f 86 c8 14 00 00    	jbe    19381185 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d65>
    1937fcbd:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fcc0:	c7 80 a4 05 00 00 01 	mov    DWORD PTR [rax+0x5a4],0x1
    1937fcc7:	00 00 00 
    1937fcca:	48 81 7b 08 6a 01 00 	cmp    QWORD PTR [rbx+0x8],0x16a
    1937fcd1:	00 
    1937fcd2:	0f 86 af 14 00 00    	jbe    19381187 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d67>
    1937fcd8:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fcdb:	c7 80 a8 05 00 00 01 	mov    DWORD PTR [rax+0x5a8],0x1
    1937fce2:	00 00 00 
    1937fce5:	48 81 7b 08 6b 01 00 	cmp    QWORD PTR [rbx+0x8],0x16b
    1937fcec:	00 
    1937fced:	0f 86 96 14 00 00    	jbe    19381189 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d69>
    1937fcf3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fcf6:	c7 80 ac 05 00 00 01 	mov    DWORD PTR [rax+0x5ac],0x1
    1937fcfd:	00 00 00 
    1937fd00:	48 81 7b 08 6c 01 00 	cmp    QWORD PTR [rbx+0x8],0x16c
    1937fd07:	00 
    1937fd08:	0f 86 7d 14 00 00    	jbe    1938118b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d6b>
    1937fd0e:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fd11:	c7 80 b0 05 00 00 01 	mov    DWORD PTR [rax+0x5b0],0x1
    1937fd18:	00 00 00 
    1937fd1b:	48 81 7b 08 6d 01 00 	cmp    QWORD PTR [rbx+0x8],0x16d
    1937fd22:	00 
    1937fd23:	0f 86 64 14 00 00    	jbe    1938118d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d6d>
    1937fd29:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fd2c:	c7 80 b4 05 00 00 01 	mov    DWORD PTR [rax+0x5b4],0x1
    1937fd33:	00 00 00 
    1937fd36:	48 81 7b 08 6e 01 00 	cmp    QWORD PTR [rbx+0x8],0x16e
    1937fd3d:	00 
    1937fd3e:	0f 86 4b 14 00 00    	jbe    1938118f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d6f>
    1937fd44:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fd47:	c7 80 b8 05 00 00 01 	mov    DWORD PTR [rax+0x5b8],0x1
    1937fd4e:	00 00 00 
    1937fd51:	48 81 7b 08 6f 01 00 	cmp    QWORD PTR [rbx+0x8],0x16f
    1937fd58:	00 
    1937fd59:	0f 86 32 14 00 00    	jbe    19381191 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d71>
    1937fd5f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fd62:	c7 80 bc 05 00 00 01 	mov    DWORD PTR [rax+0x5bc],0x1
    1937fd69:	00 00 00 
    1937fd6c:	48 81 7b 08 70 01 00 	cmp    QWORD PTR [rbx+0x8],0x170
    1937fd73:	00 
    1937fd74:	0f 86 19 14 00 00    	jbe    19381193 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d73>
    1937fd7a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fd7d:	c7 80 c0 05 00 00 01 	mov    DWORD PTR [rax+0x5c0],0x1
    1937fd84:	00 00 00 
    1937fd87:	48 81 7b 08 71 01 00 	cmp    QWORD PTR [rbx+0x8],0x171
    1937fd8e:	00 
    1937fd8f:	0f 86 00 14 00 00    	jbe    19381195 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d75>
    1937fd95:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fd98:	c7 80 c4 05 00 00 07 	mov    DWORD PTR [rax+0x5c4],0x7
    1937fd9f:	00 00 00 
    1937fda2:	48 81 7b 08 72 01 00 	cmp    QWORD PTR [rbx+0x8],0x172
    1937fda9:	00 
    1937fdaa:	0f 86 e7 13 00 00    	jbe    19381197 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d77>
    1937fdb0:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fdb3:	c7 80 c8 05 00 00 07 	mov    DWORD PTR [rax+0x5c8],0x7
    1937fdba:	00 00 00 
    1937fdbd:	48 81 7b 08 73 01 00 	cmp    QWORD PTR [rbx+0x8],0x173
    1937fdc4:	00 
    1937fdc5:	0f 86 ce 13 00 00    	jbe    19381199 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d79>
    1937fdcb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fdce:	c7 80 cc 05 00 00 07 	mov    DWORD PTR [rax+0x5cc],0x7
    1937fdd5:	00 00 00 
    1937fdd8:	48 81 7b 08 74 01 00 	cmp    QWORD PTR [rbx+0x8],0x174
    1937fddf:	00 
    1937fde0:	0f 86 b5 13 00 00    	jbe    1938119b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d7b>
    1937fde6:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fde9:	c7 80 d0 05 00 00 07 	mov    DWORD PTR [rax+0x5d0],0x7
    1937fdf0:	00 00 00 
    1937fdf3:	48 81 7b 08 75 01 00 	cmp    QWORD PTR [rbx+0x8],0x175
    1937fdfa:	00 
    1937fdfb:	0f 86 9c 13 00 00    	jbe    1938119d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d7d>
    1937fe01:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fe04:	c7 80 d4 05 00 00 07 	mov    DWORD PTR [rax+0x5d4],0x7
    1937fe0b:	00 00 00 
    1937fe0e:	48 81 7b 08 76 01 00 	cmp    QWORD PTR [rbx+0x8],0x176
    1937fe15:	00 
    1937fe16:	0f 86 83 13 00 00    	jbe    1938119f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d7f>
    1937fe1c:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fe1f:	c7 80 d8 05 00 00 07 	mov    DWORD PTR [rax+0x5d8],0x7
    1937fe26:	00 00 00 
    1937fe29:	48 81 7b 08 77 01 00 	cmp    QWORD PTR [rbx+0x8],0x177
    1937fe30:	00 
    1937fe31:	0f 86 6a 13 00 00    	jbe    193811a1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d81>
    1937fe37:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fe3a:	c7 80 dc 05 00 00 07 	mov    DWORD PTR [rax+0x5dc],0x7
    1937fe41:	00 00 00 
    1937fe44:	48 81 7b 08 78 01 00 	cmp    QWORD PTR [rbx+0x8],0x178
    1937fe4b:	00 
    1937fe4c:	0f 86 51 13 00 00    	jbe    193811a3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d83>
    1937fe52:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fe55:	c7 80 e0 05 00 00 07 	mov    DWORD PTR [rax+0x5e0],0x7
    1937fe5c:	00 00 00 
    1937fe5f:	48 81 7b 08 79 01 00 	cmp    QWORD PTR [rbx+0x8],0x179
    1937fe66:	00 
    1937fe67:	0f 86 38 13 00 00    	jbe    193811a5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d85>
    1937fe6d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fe70:	c7 80 e4 05 00 00 01 	mov    DWORD PTR [rax+0x5e4],0x1
    1937fe77:	00 00 00 
    1937fe7a:	48 81 7b 08 7a 01 00 	cmp    QWORD PTR [rbx+0x8],0x17a
    1937fe81:	00 
    1937fe82:	0f 86 1f 13 00 00    	jbe    193811a7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d87>
    1937fe88:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fe8b:	c7 80 e8 05 00 00 01 	mov    DWORD PTR [rax+0x5e8],0x1
    1937fe92:	00 00 00 
    1937fe95:	48 81 7b 08 7b 01 00 	cmp    QWORD PTR [rbx+0x8],0x17b
    1937fe9c:	00 
    1937fe9d:	0f 86 06 13 00 00    	jbe    193811a9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d89>
    1937fea3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fea6:	c7 80 ec 05 00 00 01 	mov    DWORD PTR [rax+0x5ec],0x1
    1937fead:	00 00 00 
    1937feb0:	48 81 7b 20 7b 01 00 	cmp    QWORD PTR [rbx+0x20],0x17b
    1937feb7:	00 
    1937feb8:	0f 86 ed 12 00 00    	jbe    193811ab <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d8b>
    1937febe:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    1937fec2:	48 83 b8 90 23 00 00 	cmp    QWORD PTR [rax+0x2390],0x1a
    1937fec9:	1a 
    1937feca:	0f 86 dd 12 00 00    	jbe    193811ad <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d8d>
    1937fed0:	48 8b 80 88 23 00 00 	mov    rax,QWORD PTR [rax+0x2388]
    1937fed7:	c7 40 68 02 00 00 00 	mov    DWORD PTR [rax+0x68],0x2
    1937fede:	48 81 39 7c 01 00 00 	cmp    QWORD PTR [rcx],0x17c
    1937fee5:	0f 86 c4 12 00 00    	jbe    193811af <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d8f>
    1937feeb:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937feee:	c7 80 f0 05 00 00 01 	mov    DWORD PTR [rax+0x5f0],0x1
    1937fef5:	00 00 00 
    1937fef8:	48 81 7b 08 7d 01 00 	cmp    QWORD PTR [rbx+0x8],0x17d
    1937feff:	00 
    1937ff00:	0f 86 ab 12 00 00    	jbe    193811b1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d91>
    1937ff06:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ff09:	c7 80 f4 05 00 00 01 	mov    DWORD PTR [rax+0x5f4],0x1
    1937ff10:	00 00 00 
    1937ff13:	48 81 7b 08 7e 01 00 	cmp    QWORD PTR [rbx+0x8],0x17e
    1937ff1a:	00 
    1937ff1b:	0f 86 92 12 00 00    	jbe    193811b3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d93>
    1937ff21:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ff24:	c7 80 f8 05 00 00 01 	mov    DWORD PTR [rax+0x5f8],0x1
    1937ff2b:	00 00 00 
    1937ff2e:	48 81 7b 08 7f 01 00 	cmp    QWORD PTR [rbx+0x8],0x17f
    1937ff35:	00 
    1937ff36:	0f 86 79 12 00 00    	jbe    193811b5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d95>
    1937ff3c:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ff3f:	c7 80 fc 05 00 00 01 	mov    DWORD PTR [rax+0x5fc],0x1
    1937ff46:	00 00 00 
    1937ff49:	48 81 7b 08 80 01 00 	cmp    QWORD PTR [rbx+0x8],0x180
    1937ff50:	00 
    1937ff51:	0f 86 60 12 00 00    	jbe    193811b7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d97>
    1937ff57:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ff5a:	c7 80 00 06 00 00 01 	mov    DWORD PTR [rax+0x600],0x1
    1937ff61:	00 00 00 
    1937ff64:	48 81 7b 08 81 01 00 	cmp    QWORD PTR [rbx+0x8],0x181
    1937ff6b:	00 
    1937ff6c:	0f 86 47 12 00 00    	jbe    193811b9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d99>
    1937ff72:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ff75:	c7 80 04 06 00 00 01 	mov    DWORD PTR [rax+0x604],0x1
    1937ff7c:	00 00 00 
    1937ff7f:	48 81 7b 08 82 01 00 	cmp    QWORD PTR [rbx+0x8],0x182
    1937ff86:	00 
    1937ff87:	0f 86 2e 12 00 00    	jbe    193811bb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d9b>
    1937ff8d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ff90:	c7 80 08 06 00 00 01 	mov    DWORD PTR [rax+0x608],0x1
    1937ff97:	00 00 00 
    1937ff9a:	48 81 7b 08 83 01 00 	cmp    QWORD PTR [rbx+0x8],0x183
    1937ffa1:	00 
    1937ffa2:	0f 86 15 12 00 00    	jbe    193811bd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d9d>
    1937ffa8:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ffab:	c7 80 0c 06 00 00 01 	mov    DWORD PTR [rax+0x60c],0x1
    1937ffb2:	00 00 00 
    1937ffb5:	48 81 7b 08 84 01 00 	cmp    QWORD PTR [rbx+0x8],0x184
    1937ffbc:	00 
    1937ffbd:	0f 86 fc 11 00 00    	jbe    193811bf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6d9f>
    1937ffc3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ffc6:	c7 80 10 06 00 00 01 	mov    DWORD PTR [rax+0x610],0x1
    1937ffcd:	00 00 00 
    1937ffd0:	48 81 7b 08 85 01 00 	cmp    QWORD PTR [rbx+0x8],0x185
    1937ffd7:	00 
    1937ffd8:	0f 86 e3 11 00 00    	jbe    193811c1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6da1>
    1937ffde:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937ffe1:	c7 80 14 06 00 00 01 	mov    DWORD PTR [rax+0x614],0x1
    1937ffe8:	00 00 00 
    1937ffeb:	48 81 7b 08 86 01 00 	cmp    QWORD PTR [rbx+0x8],0x186
    1937fff2:	00 
    1937fff3:	0f 86 ca 11 00 00    	jbe    193811c3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6da3>
    1937fff9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1937fffc:	c7 80 18 06 00 00 01 	mov    DWORD PTR [rax+0x618],0x1
    19380003:	00 00 00 
    19380006:	48 81 7b 08 87 01 00 	cmp    QWORD PTR [rbx+0x8],0x187
    1938000d:	00 
    1938000e:	0f 86 b1 11 00 00    	jbe    193811c5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6da5>
    19380014:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380017:	c7 80 1c 06 00 00 01 	mov    DWORD PTR [rax+0x61c],0x1
    1938001e:	00 00 00 
    19380021:	48 81 7b 08 88 01 00 	cmp    QWORD PTR [rbx+0x8],0x188
    19380028:	00 
    19380029:	0f 86 98 11 00 00    	jbe    193811c7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6da7>
    1938002f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380032:	c7 80 20 06 00 00 02 	mov    DWORD PTR [rax+0x620],0x2
    19380039:	00 00 00 
    1938003c:	48 81 7b 08 89 01 00 	cmp    QWORD PTR [rbx+0x8],0x189
    19380043:	00 
    19380044:	0f 86 7f 11 00 00    	jbe    193811c9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6da9>
    1938004a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938004d:	c7 80 24 06 00 00 02 	mov    DWORD PTR [rax+0x624],0x2
    19380054:	00 00 00 
    19380057:	48 81 7b 08 8a 01 00 	cmp    QWORD PTR [rbx+0x8],0x18a
    1938005e:	00 
    1938005f:	0f 86 66 11 00 00    	jbe    193811cb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dab>
    19380065:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380068:	c7 80 28 06 00 00 02 	mov    DWORD PTR [rax+0x628],0x2
    1938006f:	00 00 00 
    19380072:	48 81 7b 08 8b 01 00 	cmp    QWORD PTR [rbx+0x8],0x18b
    19380079:	00 
    1938007a:	0f 86 4d 11 00 00    	jbe    193811cd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dad>
    19380080:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380083:	c7 80 2c 06 00 00 02 	mov    DWORD PTR [rax+0x62c],0x2
    1938008a:	00 00 00 
    1938008d:	48 81 7b 08 8c 01 00 	cmp    QWORD PTR [rbx+0x8],0x18c
    19380094:	00 
    19380095:	0f 86 34 11 00 00    	jbe    193811cf <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6daf>
    1938009b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938009e:	c7 80 30 06 00 00 02 	mov    DWORD PTR [rax+0x630],0x2
    193800a5:	00 00 00 
    193800a8:	48 81 7b 08 8d 01 00 	cmp    QWORD PTR [rbx+0x8],0x18d
    193800af:	00 
    193800b0:	0f 86 1b 11 00 00    	jbe    193811d1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6db1>
    193800b6:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193800b9:	c7 80 34 06 00 00 02 	mov    DWORD PTR [rax+0x634],0x2
    193800c0:	00 00 00 
    193800c3:	48 81 7b 08 8e 01 00 	cmp    QWORD PTR [rbx+0x8],0x18e
    193800ca:	00 
    193800cb:	0f 86 02 11 00 00    	jbe    193811d3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6db3>
    193800d1:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193800d4:	c7 80 38 06 00 00 02 	mov    DWORD PTR [rax+0x638],0x2
    193800db:	00 00 00 
    193800de:	48 81 7b 08 8f 01 00 	cmp    QWORD PTR [rbx+0x8],0x18f
    193800e5:	00 
    193800e6:	0f 86 e9 10 00 00    	jbe    193811d5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6db5>
    193800ec:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193800ef:	c7 80 3c 06 00 00 01 	mov    DWORD PTR [rax+0x63c],0x1
    193800f6:	00 00 00 
    193800f9:	48 81 7b 08 90 01 00 	cmp    QWORD PTR [rbx+0x8],0x190
    19380100:	00 
    19380101:	0f 86 d0 10 00 00    	jbe    193811d7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6db7>
    19380107:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938010a:	c7 80 40 06 00 00 01 	mov    DWORD PTR [rax+0x640],0x1
    19380111:	00 00 00 
    19380114:	48 81 7b 08 91 01 00 	cmp    QWORD PTR [rbx+0x8],0x191
    1938011b:	00 
    1938011c:	0f 86 b7 10 00 00    	jbe    193811d9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6db9>
    19380122:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380125:	c7 80 44 06 00 00 01 	mov    DWORD PTR [rax+0x644],0x1
    1938012c:	00 00 00 
    1938012f:	48 81 7b 08 92 01 00 	cmp    QWORD PTR [rbx+0x8],0x192
    19380136:	00 
    19380137:	0f 86 9e 10 00 00    	jbe    193811db <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dbb>
    1938013d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380140:	c7 80 48 06 00 00 01 	mov    DWORD PTR [rax+0x648],0x1
    19380147:	00 00 00 
    1938014a:	48 81 7b 08 93 01 00 	cmp    QWORD PTR [rbx+0x8],0x193
    19380151:	00 
    19380152:	0f 86 85 10 00 00    	jbe    193811dd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dbd>
    19380158:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938015b:	c7 80 4c 06 00 00 01 	mov    DWORD PTR [rax+0x64c],0x1
    19380162:	00 00 00 
    19380165:	48 81 7b 08 94 01 00 	cmp    QWORD PTR [rbx+0x8],0x194
    1938016c:	00 
    1938016d:	0f 86 6c 10 00 00    	jbe    193811df <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dbf>
    19380173:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380176:	c7 80 50 06 00 00 01 	mov    DWORD PTR [rax+0x650],0x1
    1938017d:	00 00 00 
    19380180:	48 81 7b 08 95 01 00 	cmp    QWORD PTR [rbx+0x8],0x195
    19380187:	00 
    19380188:	0f 86 53 10 00 00    	jbe    193811e1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dc1>
    1938018e:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380191:	c7 80 54 06 00 00 01 	mov    DWORD PTR [rax+0x654],0x1
    19380198:	00 00 00 
    1938019b:	48 81 7b 08 96 01 00 	cmp    QWORD PTR [rbx+0x8],0x196
    193801a2:	00 
    193801a3:	0f 86 3a 10 00 00    	jbe    193811e3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dc3>
    193801a9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193801ac:	c7 80 58 06 00 00 03 	mov    DWORD PTR [rax+0x658],0x3
    193801b3:	00 00 00 
    193801b6:	48 81 7b 08 97 01 00 	cmp    QWORD PTR [rbx+0x8],0x197
    193801bd:	00 
    193801be:	0f 86 21 10 00 00    	jbe    193811e5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dc5>
    193801c4:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193801c7:	c7 80 5c 06 00 00 03 	mov    DWORD PTR [rax+0x65c],0x3
    193801ce:	00 00 00 
    193801d1:	48 81 7b 08 98 01 00 	cmp    QWORD PTR [rbx+0x8],0x198
    193801d8:	00 
    193801d9:	0f 86 08 10 00 00    	jbe    193811e7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dc7>
    193801df:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193801e2:	c7 80 60 06 00 00 03 	mov    DWORD PTR [rax+0x660],0x3
    193801e9:	00 00 00 
    193801ec:	48 81 7b 08 99 01 00 	cmp    QWORD PTR [rbx+0x8],0x199
    193801f3:	00 
    193801f4:	0f 86 ef 0f 00 00    	jbe    193811e9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dc9>
    193801fa:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193801fd:	c7 80 64 06 00 00 01 	mov    DWORD PTR [rax+0x664],0x1
    19380204:	00 00 00 
    19380207:	48 81 7b 08 9a 01 00 	cmp    QWORD PTR [rbx+0x8],0x19a
    1938020e:	00 
    1938020f:	0f 86 d6 0f 00 00    	jbe    193811eb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dcb>
    19380215:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380218:	c7 80 68 06 00 00 01 	mov    DWORD PTR [rax+0x668],0x1
    1938021f:	00 00 00 
    19380222:	48 81 7b 08 9b 01 00 	cmp    QWORD PTR [rbx+0x8],0x19b
    19380229:	00 
    1938022a:	0f 86 bd 0f 00 00    	jbe    193811ed <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dcd>
    19380230:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380233:	c7 80 6c 06 00 00 01 	mov    DWORD PTR [rax+0x66c],0x1
    1938023a:	00 00 00 
    1938023d:	48 81 7b 08 9c 01 00 	cmp    QWORD PTR [rbx+0x8],0x19c
    19380244:	00 
    19380245:	0f 86 a4 0f 00 00    	jbe    193811ef <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dcf>
    1938024b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938024e:	c7 80 70 06 00 00 01 	mov    DWORD PTR [rax+0x670],0x1
    19380255:	00 00 00 
    19380258:	48 81 7b 08 9d 01 00 	cmp    QWORD PTR [rbx+0x8],0x19d
    1938025f:	00 
    19380260:	0f 86 8b 0f 00 00    	jbe    193811f1 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dd1>
    19380266:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380269:	c7 80 74 06 00 00 01 	mov    DWORD PTR [rax+0x674],0x1
    19380270:	00 00 00 
    19380273:	48 81 7b 08 9e 01 00 	cmp    QWORD PTR [rbx+0x8],0x19e
    1938027a:	00 
    1938027b:	0f 86 72 0f 00 00    	jbe    193811f3 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dd3>
    19380281:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380284:	c7 80 78 06 00 00 01 	mov    DWORD PTR [rax+0x678],0x1
    1938028b:	00 00 00 
    1938028e:	48 81 7b 08 9f 01 00 	cmp    QWORD PTR [rbx+0x8],0x19f
    19380295:	00 
    19380296:	0f 86 59 0f 00 00    	jbe    193811f5 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dd5>
    1938029c:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938029f:	c7 80 7c 06 00 00 01 	mov    DWORD PTR [rax+0x67c],0x1
    193802a6:	00 00 00 
    193802a9:	48 81 7b 08 a0 01 00 	cmp    QWORD PTR [rbx+0x8],0x1a0
    193802b0:	00 
    193802b1:	0f 86 40 0f 00 00    	jbe    193811f7 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dd7>
    193802b7:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193802ba:	c7 80 80 06 00 00 01 	mov    DWORD PTR [rax+0x680],0x1
    193802c1:	00 00 00 
    193802c4:	48 81 7b 08 a1 01 00 	cmp    QWORD PTR [rbx+0x8],0x1a1
    193802cb:	00 
    193802cc:	0f 86 27 0f 00 00    	jbe    193811f9 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dd9>
    193802d2:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193802d5:	c7 80 84 06 00 00 01 	mov    DWORD PTR [rax+0x684],0x1
    193802dc:	00 00 00 
    193802df:	48 81 7b 20 a1 01 00 	cmp    QWORD PTR [rbx+0x20],0x1a1
    193802e6:	00 
    193802e7:	0f 86 0e 0f 00 00    	jbe    193811fb <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ddb>
    193802ed:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    193802f1:	48 83 b8 20 27 00 00 	cmp    QWORD PTR [rax+0x2720],0x1b
    193802f8:	1b 
    193802f9:	0f 86 fe 0e 00 00    	jbe    193811fd <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ddd>
    193802ff:	48 8b 80 18 27 00 00 	mov    rax,QWORD PTR [rax+0x2718]
    19380306:	c7 40 6c 04 00 00 00 	mov    DWORD PTR [rax+0x6c],0x4
    1938030d:	48 81 39 a2 01 00 00 	cmp    QWORD PTR [rcx],0x1a2
    19380314:	0f 86 e5 0e 00 00    	jbe    193811ff <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ddf>
    1938031a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938031d:	c7 80 88 06 00 00 01 	mov    DWORD PTR [rax+0x688],0x1
    19380324:	00 00 00 
    19380327:	48 81 7b 20 a2 01 00 	cmp    QWORD PTR [rbx+0x20],0x1a2
    1938032e:	00 
    1938032f:	0f 86 cc 0e 00 00    	jbe    19381201 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6de1>
    19380335:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    19380339:	48 83 b8 38 27 00 00 	cmp    QWORD PTR [rax+0x2738],0x1c
    19380340:	1c 
    19380341:	0f 86 bc 0e 00 00    	jbe    19381203 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6de3>
    19380347:	48 8b 80 30 27 00 00 	mov    rax,QWORD PTR [rax+0x2730]
    1938034e:	c7 40 70 01 00 00 00 	mov    DWORD PTR [rax+0x70],0x1
    19380355:	48 81 39 a3 01 00 00 	cmp    QWORD PTR [rcx],0x1a3
    1938035c:	0f 86 a3 0e 00 00    	jbe    19381205 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6de5>
    19380362:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380365:	c7 80 8c 06 00 00 07 	mov    DWORD PTR [rax+0x68c],0x7
    1938036c:	00 00 00 
    1938036f:	48 81 7b 08 a4 01 00 	cmp    QWORD PTR [rbx+0x8],0x1a4
    19380376:	00 
    19380377:	0f 86 8a 0e 00 00    	jbe    19381207 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6de7>
    1938037d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380380:	c7 80 90 06 00 00 07 	mov    DWORD PTR [rax+0x690],0x7
    19380387:	00 00 00 
    1938038a:	48 81 7b 08 a5 01 00 	cmp    QWORD PTR [rbx+0x8],0x1a5
    19380391:	00 
    19380392:	0f 86 71 0e 00 00    	jbe    19381209 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6de9>
    19380398:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938039b:	c7 80 94 06 00 00 07 	mov    DWORD PTR [rax+0x694],0x7
    193803a2:	00 00 00 
    193803a5:	48 81 7b 08 a6 01 00 	cmp    QWORD PTR [rbx+0x8],0x1a6
    193803ac:	00 
    193803ad:	0f 86 58 0e 00 00    	jbe    1938120b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6deb>
    193803b3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193803b6:	c7 80 98 06 00 00 07 	mov    DWORD PTR [rax+0x698],0x7
    193803bd:	00 00 00 
    193803c0:	48 81 7b 08 a7 01 00 	cmp    QWORD PTR [rbx+0x8],0x1a7
    193803c7:	00 
    193803c8:	0f 86 3f 0e 00 00    	jbe    1938120d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ded>
    193803ce:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193803d1:	c7 80 9c 06 00 00 07 	mov    DWORD PTR [rax+0x69c],0x7
    193803d8:	00 00 00 
    193803db:	48 81 7b 08 a8 01 00 	cmp    QWORD PTR [rbx+0x8],0x1a8
    193803e2:	00 
    193803e3:	0f 86 26 0e 00 00    	jbe    1938120f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6def>
    193803e9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193803ec:	c7 80 a0 06 00 00 07 	mov    DWORD PTR [rax+0x6a0],0x7
    193803f3:	00 00 00 
    193803f6:	48 81 7b 08 a9 01 00 	cmp    QWORD PTR [rbx+0x8],0x1a9
    193803fd:	00 
    193803fe:	0f 86 0d 0e 00 00    	jbe    19381211 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6df1>
    19380404:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380407:	c7 80 a4 06 00 00 07 	mov    DWORD PTR [rax+0x6a4],0x7
    1938040e:	00 00 00 
    19380411:	48 81 7b 08 aa 01 00 	cmp    QWORD PTR [rbx+0x8],0x1aa
    19380418:	00 
    19380419:	0f 86 f4 0d 00 00    	jbe    19381213 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6df3>
    1938041f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380422:	c7 80 a8 06 00 00 07 	mov    DWORD PTR [rax+0x6a8],0x7
    19380429:	00 00 00 
    1938042c:	48 81 7b 08 ab 01 00 	cmp    QWORD PTR [rbx+0x8],0x1ab
    19380433:	00 
    19380434:	0f 86 db 0d 00 00    	jbe    19381215 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6df5>
    1938043a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938043d:	c7 80 ac 06 00 00 07 	mov    DWORD PTR [rax+0x6ac],0x7
    19380444:	00 00 00 
    19380447:	48 81 7b 20 ab 01 00 	cmp    QWORD PTR [rbx+0x20],0x1ab
    1938044e:	00 
    1938044f:	0f 86 c2 0d 00 00    	jbe    19381217 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6df7>
    19380455:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    19380459:	48 83 b8 10 28 00 00 	cmp    QWORD PTR [rax+0x2810],0x1d
    19380460:	1d 
    19380461:	0f 86 b2 0d 00 00    	jbe    19381219 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6df9>
    19380467:	48 8b 80 08 28 00 00 	mov    rax,QWORD PTR [rax+0x2808]
    1938046e:	c7 40 74 05 00 00 00 	mov    DWORD PTR [rax+0x74],0x5
    19380475:	48 81 39 ac 01 00 00 	cmp    QWORD PTR [rcx],0x1ac
    1938047c:	0f 86 99 0d 00 00    	jbe    1938121b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dfb>
    19380482:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380485:	c7 80 b0 06 00 00 07 	mov    DWORD PTR [rax+0x6b0],0x7
    1938048c:	00 00 00 
    1938048f:	48 81 7b 20 ac 01 00 	cmp    QWORD PTR [rbx+0x20],0x1ac
    19380496:	00 
    19380497:	0f 86 80 0d 00 00    	jbe    1938121d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dfd>
    1938049d:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    193804a1:	48 83 b8 28 28 00 00 	cmp    QWORD PTR [rax+0x2828],0x1d
    193804a8:	1d 
    193804a9:	0f 86 70 0d 00 00    	jbe    1938121f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6dff>
    193804af:	48 8b 80 20 28 00 00 	mov    rax,QWORD PTR [rax+0x2820]
    193804b6:	c7 40 74 05 00 00 00 	mov    DWORD PTR [rax+0x74],0x5
    193804bd:	48 81 39 ad 01 00 00 	cmp    QWORD PTR [rcx],0x1ad
    193804c4:	0f 86 57 0d 00 00    	jbe    19381221 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e01>
    193804ca:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193804cd:	c7 80 b4 06 00 00 07 	mov    DWORD PTR [rax+0x6b4],0x7
    193804d4:	00 00 00 
    193804d7:	48 81 7b 20 ad 01 00 	cmp    QWORD PTR [rbx+0x20],0x1ad
    193804de:	00 
    193804df:	0f 86 3e 0d 00 00    	jbe    19381223 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e03>
    193804e5:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    193804e9:	48 83 b8 40 28 00 00 	cmp    QWORD PTR [rax+0x2840],0x1d
    193804f0:	1d 
    193804f1:	0f 86 2e 0d 00 00    	jbe    19381225 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e05>
    193804f7:	48 8b 80 38 28 00 00 	mov    rax,QWORD PTR [rax+0x2838]
    193804fe:	c7 40 74 05 00 00 00 	mov    DWORD PTR [rax+0x74],0x5
    19380505:	48 81 39 ae 01 00 00 	cmp    QWORD PTR [rcx],0x1ae
    1938050c:	0f 86 15 0d 00 00    	jbe    19381227 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e07>
    19380512:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380515:	c7 80 b8 06 00 00 07 	mov    DWORD PTR [rax+0x6b8],0x7
    1938051c:	00 00 00 
    1938051f:	48 81 7b 20 ae 01 00 	cmp    QWORD PTR [rbx+0x20],0x1ae
    19380526:	00 
    19380527:	0f 86 fc 0c 00 00    	jbe    19381229 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e09>
    1938052d:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    19380531:	48 83 b8 58 28 00 00 	cmp    QWORD PTR [rax+0x2858],0x1d
    19380538:	1d 
    19380539:	0f 86 ec 0c 00 00    	jbe    1938122b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e0b>
    1938053f:	48 8b 80 50 28 00 00 	mov    rax,QWORD PTR [rax+0x2850]
    19380546:	c7 40 74 05 00 00 00 	mov    DWORD PTR [rax+0x74],0x5
    1938054d:	48 81 39 af 01 00 00 	cmp    QWORD PTR [rcx],0x1af
    19380554:	0f 86 d3 0c 00 00    	jbe    1938122d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e0d>
    1938055a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938055d:	c7 80 bc 06 00 00 07 	mov    DWORD PTR [rax+0x6bc],0x7
    19380564:	00 00 00 
    19380567:	48 81 7b 20 af 01 00 	cmp    QWORD PTR [rbx+0x20],0x1af
    1938056e:	00 
    1938056f:	0f 86 ba 0c 00 00    	jbe    1938122f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e0f>
    19380575:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    19380579:	48 83 b8 70 28 00 00 	cmp    QWORD PTR [rax+0x2870],0x1e
    19380580:	1e 
    19380581:	0f 86 aa 0c 00 00    	jbe    19381231 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e11>
    19380587:	48 8b 80 68 28 00 00 	mov    rax,QWORD PTR [rax+0x2868]
    1938058e:	c7 40 78 07 00 00 00 	mov    DWORD PTR [rax+0x78],0x7
    19380595:	48 81 39 b0 01 00 00 	cmp    QWORD PTR [rcx],0x1b0
    1938059c:	0f 86 91 0c 00 00    	jbe    19381233 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e13>
    193805a2:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193805a5:	c7 80 c0 06 00 00 07 	mov    DWORD PTR [rax+0x6c0],0x7
    193805ac:	00 00 00 
    193805af:	48 81 7b 20 b0 01 00 	cmp    QWORD PTR [rbx+0x20],0x1b0
    193805b6:	00 
    193805b7:	0f 86 78 0c 00 00    	jbe    19381235 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e15>
    193805bd:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    193805c1:	48 83 b8 88 28 00 00 	cmp    QWORD PTR [rax+0x2888],0x1e
    193805c8:	1e 
    193805c9:	0f 86 68 0c 00 00    	jbe    19381237 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e17>
    193805cf:	48 8b 80 80 28 00 00 	mov    rax,QWORD PTR [rax+0x2880]
    193805d6:	c7 40 78 07 00 00 00 	mov    DWORD PTR [rax+0x78],0x7
    193805dd:	48 81 39 b1 01 00 00 	cmp    QWORD PTR [rcx],0x1b1
    193805e4:	0f 86 4f 0c 00 00    	jbe    19381239 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e19>
    193805ea:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193805ed:	c7 80 c4 06 00 00 07 	mov    DWORD PTR [rax+0x6c4],0x7
    193805f4:	00 00 00 
    193805f7:	48 81 7b 20 b1 01 00 	cmp    QWORD PTR [rbx+0x20],0x1b1
    193805fe:	00 
    193805ff:	0f 86 36 0c 00 00    	jbe    1938123b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e1b>
    19380605:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    19380609:	48 83 b8 a0 28 00 00 	cmp    QWORD PTR [rax+0x28a0],0x1e
    19380610:	1e 
    19380611:	0f 86 26 0c 00 00    	jbe    1938123d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e1d>
    19380617:	48 8b 80 98 28 00 00 	mov    rax,QWORD PTR [rax+0x2898]
    1938061e:	c7 40 78 07 00 00 00 	mov    DWORD PTR [rax+0x78],0x7
    19380625:	48 81 39 b2 01 00 00 	cmp    QWORD PTR [rcx],0x1b2
    1938062c:	0f 86 0d 0c 00 00    	jbe    1938123f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e1f>
    19380632:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380635:	c7 80 c8 06 00 00 07 	mov    DWORD PTR [rax+0x6c8],0x7
    1938063c:	00 00 00 
    1938063f:	48 81 7b 20 b2 01 00 	cmp    QWORD PTR [rbx+0x20],0x1b2
    19380646:	00 
    19380647:	0f 86 f4 0b 00 00    	jbe    19381241 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e21>
    1938064d:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    19380651:	48 83 b8 b8 28 00 00 	cmp    QWORD PTR [rax+0x28b8],0x1e
    19380658:	1e 
    19380659:	0f 86 e4 0b 00 00    	jbe    19381243 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e23>
    1938065f:	48 8b 80 b0 28 00 00 	mov    rax,QWORD PTR [rax+0x28b0]
    19380666:	c7 40 78 07 00 00 00 	mov    DWORD PTR [rax+0x78],0x7
    1938066d:	48 81 39 b3 01 00 00 	cmp    QWORD PTR [rcx],0x1b3
    19380674:	0f 86 cb 0b 00 00    	jbe    19381245 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e25>
    1938067a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938067d:	c7 80 cc 06 00 00 07 	mov    DWORD PTR [rax+0x6cc],0x7
    19380684:	00 00 00 
    19380687:	48 81 7b 20 b3 01 00 	cmp    QWORD PTR [rbx+0x20],0x1b3
    1938068e:	00 
    1938068f:	0f 86 b2 0b 00 00    	jbe    19381247 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e27>
    19380695:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    19380699:	48 83 b8 d0 28 00 00 	cmp    QWORD PTR [rax+0x28d0],0x1e
    193806a0:	1e 
    193806a1:	0f 86 a2 0b 00 00    	jbe    19381249 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e29>
    193806a7:	48 8b 80 c8 28 00 00 	mov    rax,QWORD PTR [rax+0x28c8]
    193806ae:	c7 40 78 07 00 00 00 	mov    DWORD PTR [rax+0x78],0x7
    193806b5:	48 81 39 b4 01 00 00 	cmp    QWORD PTR [rcx],0x1b4
    193806bc:	0f 86 89 0b 00 00    	jbe    1938124b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e2b>
    193806c2:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193806c5:	c7 80 d0 06 00 00 07 	mov    DWORD PTR [rax+0x6d0],0x7
    193806cc:	00 00 00 
    193806cf:	48 81 7b 20 b4 01 00 	cmp    QWORD PTR [rbx+0x20],0x1b4
    193806d6:	00 
    193806d7:	0f 86 70 0b 00 00    	jbe    1938124d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e2d>
    193806dd:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    193806e1:	48 83 b8 e8 28 00 00 	cmp    QWORD PTR [rax+0x28e8],0x1e
    193806e8:	1e 
    193806e9:	0f 86 60 0b 00 00    	jbe    1938124f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e2f>
    193806ef:	48 8b 80 e0 28 00 00 	mov    rax,QWORD PTR [rax+0x28e0]
    193806f6:	c7 40 78 07 00 00 00 	mov    DWORD PTR [rax+0x78],0x7
    193806fd:	48 81 39 b5 01 00 00 	cmp    QWORD PTR [rcx],0x1b5
    19380704:	0f 86 47 0b 00 00    	jbe    19381251 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e31>
    1938070a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938070d:	c7 80 d4 06 00 00 31 	mov    DWORD PTR [rax+0x6d4],0x31
    19380714:	00 00 00 
    19380717:	48 81 7b 08 b6 01 00 	cmp    QWORD PTR [rbx+0x8],0x1b6
    1938071e:	00 
    1938071f:	0f 86 2e 0b 00 00    	jbe    19381253 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e33>
    19380725:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380728:	c7 80 d8 06 00 00 03 	mov    DWORD PTR [rax+0x6d8],0x3
    1938072f:	00 00 00 
    19380732:	48 81 7b 20 b6 01 00 	cmp    QWORD PTR [rbx+0x20],0x1b6
    19380739:	00 
    1938073a:	0f 86 15 0b 00 00    	jbe    19381255 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e35>
    19380740:	49 8b 04 24          	mov    rax,QWORD PTR [r12]
    19380744:	48 83 b8 18 29 00 00 	cmp    QWORD PTR [rax+0x2918],0x1f
    1938074b:	1f 
    1938074c:	0f 86 05 0b 00 00    	jbe    19381257 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e37>
    19380752:	48 8b 80 10 29 00 00 	mov    rax,QWORD PTR [rax+0x2910]
    19380759:	c7 40 7c 03 00 00 00 	mov    DWORD PTR [rax+0x7c],0x3
    19380760:	48 81 39 b7 01 00 00 	cmp    QWORD PTR [rcx],0x1b7
    19380767:	0f 86 ec 0a 00 00    	jbe    19381259 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e39>
    1938076d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380770:	c7 80 dc 06 00 00 01 	mov    DWORD PTR [rax+0x6dc],0x1
    19380777:	00 00 00 
    1938077a:	48 81 7b 08 b8 01 00 	cmp    QWORD PTR [rbx+0x8],0x1b8
    19380781:	00 
    19380782:	0f 86 d3 0a 00 00    	jbe    1938125b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e3b>
    19380788:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938078b:	c7 80 e0 06 00 00 01 	mov    DWORD PTR [rax+0x6e0],0x1
    19380792:	00 00 00 
    19380795:	48 81 7b 08 b9 01 00 	cmp    QWORD PTR [rbx+0x8],0x1b9
    1938079c:	00 
    1938079d:	0f 86 ba 0a 00 00    	jbe    1938125d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e3d>
    193807a3:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193807a6:	c7 80 e4 06 00 00 01 	mov    DWORD PTR [rax+0x6e4],0x1
    193807ad:	00 00 00 
    193807b0:	48 81 7b 08 ba 01 00 	cmp    QWORD PTR [rbx+0x8],0x1ba
    193807b7:	00 
    193807b8:	0f 86 a1 0a 00 00    	jbe    1938125f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e3f>
    193807be:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193807c1:	c7 80 e8 06 00 00 05 	mov    DWORD PTR [rax+0x6e8],0x5
    193807c8:	00 00 00 
    193807cb:	48 81 7b 08 bb 01 00 	cmp    QWORD PTR [rbx+0x8],0x1bb
    193807d2:	00 
    193807d3:	0f 86 88 0a 00 00    	jbe    19381261 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e41>
    193807d9:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193807dc:	c7 80 ec 06 00 00 06 	mov    DWORD PTR [rax+0x6ec],0x6
    193807e3:	00 00 00 
    193807e6:	48 81 7b 08 bc 01 00 	cmp    QWORD PTR [rbx+0x8],0x1bc
    193807ed:	00 
    193807ee:	0f 86 6f 0a 00 00    	jbe    19381263 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e43>
    193807f4:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193807f7:	c7 80 f0 06 00 00 05 	mov    DWORD PTR [rax+0x6f0],0x5
    193807fe:	00 00 00 
    19380801:	48 81 7b 08 bd 01 00 	cmp    QWORD PTR [rbx+0x8],0x1bd
    19380808:	00 
    19380809:	0f 86 56 0a 00 00    	jbe    19381265 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e45>
    1938080f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380812:	c7 80 f4 06 00 00 01 	mov    DWORD PTR [rax+0x6f4],0x1
    19380819:	00 00 00 
    1938081c:	48 81 7b 08 be 01 00 	cmp    QWORD PTR [rbx+0x8],0x1be
    19380823:	00 
    19380824:	0f 86 3d 0a 00 00    	jbe    19381267 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e47>
    1938082a:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938082d:	c7 80 f8 06 00 00 02 	mov    DWORD PTR [rax+0x6f8],0x2
    19380834:	00 00 00 
    19380837:	48 81 7b 08 bf 01 00 	cmp    QWORD PTR [rbx+0x8],0x1bf
    1938083e:	00 
    1938083f:	0f 86 24 0a 00 00    	jbe    19381269 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e49>
    19380845:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380848:	c7 80 fc 06 00 00 02 	mov    DWORD PTR [rax+0x6fc],0x2
    1938084f:	00 00 00 
    19380852:	48 81 7b 08 c0 01 00 	cmp    QWORD PTR [rbx+0x8],0x1c0
    19380859:	00 
    1938085a:	0f 86 0b 0a 00 00    	jbe    1938126b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e4b>
    19380860:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380863:	c7 80 00 07 00 00 02 	mov    DWORD PTR [rax+0x700],0x2
    1938086a:	00 00 00 
    1938086d:	48 81 7b 08 c1 01 00 	cmp    QWORD PTR [rbx+0x8],0x1c1
    19380874:	00 
    19380875:	0f 86 f2 09 00 00    	jbe    1938126d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e4d>
    1938087b:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938087e:	c7 80 04 07 00 00 02 	mov    DWORD PTR [rax+0x704],0x2
    19380885:	00 00 00 
    19380888:	48 81 7b 08 c2 01 00 	cmp    QWORD PTR [rbx+0x8],0x1c2
    1938088f:	00 
    19380890:	0f 86 d9 09 00 00    	jbe    1938126f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e4f>
    19380896:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380899:	c7 80 08 07 00 00 02 	mov    DWORD PTR [rax+0x708],0x2
    193808a0:	00 00 00 
    193808a3:	48 81 7b 08 c3 01 00 	cmp    QWORD PTR [rbx+0x8],0x1c3
    193808aa:	00 
    193808ab:	0f 86 c0 09 00 00    	jbe    19381271 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e51>
    193808b1:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193808b4:	c7 80 0c 07 00 00 02 	mov    DWORD PTR [rax+0x70c],0x2
    193808bb:	00 00 00 
    193808be:	48 81 7b 08 c4 01 00 	cmp    QWORD PTR [rbx+0x8],0x1c4
    193808c5:	00 
    193808c6:	0f 86 a7 09 00 00    	jbe    19381273 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e53>
    193808cc:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193808cf:	c7 80 10 07 00 00 02 	mov    DWORD PTR [rax+0x710],0x2
    193808d6:	00 00 00 
    193808d9:	48 81 7b 08 c5 01 00 	cmp    QWORD PTR [rbx+0x8],0x1c5
    193808e0:	00 
    193808e1:	0f 86 8e 09 00 00    	jbe    19381275 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e55>
    193808e7:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193808ea:	c7 80 14 07 00 00 02 	mov    DWORD PTR [rax+0x714],0x2
    193808f1:	00 00 00 
    193808f4:	48 81 7b 08 c6 01 00 	cmp    QWORD PTR [rbx+0x8],0x1c6
    193808fb:	00 
    193808fc:	0f 86 75 09 00 00    	jbe    19381277 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e57>
    19380902:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380905:	c7 80 18 07 00 00 02 	mov    DWORD PTR [rax+0x718],0x2
    1938090c:	00 00 00 
    1938090f:	48 81 7b 08 c7 01 00 	cmp    QWORD PTR [rbx+0x8],0x1c7
    19380916:	00 
    19380917:	0f 86 5c 09 00 00    	jbe    19381279 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e59>
    1938091d:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380920:	c7 80 1c 07 00 00 02 	mov    DWORD PTR [rax+0x71c],0x2
    19380927:	00 00 00 
    1938092a:	48 81 7b 08 c8 01 00 	cmp    QWORD PTR [rbx+0x8],0x1c8
    19380931:	00 
    19380932:	0f 86 43 09 00 00    	jbe    1938127b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e5b>
    19380938:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938093b:	c7 80 20 07 00 00 02 	mov    DWORD PTR [rax+0x720],0x2
    19380942:	00 00 00 
    19380945:	48 81 7b 08 c9 01 00 	cmp    QWORD PTR [rbx+0x8],0x1c9
    1938094c:	00 
    1938094d:	0f 86 2a 09 00 00    	jbe    1938127d <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e5d>
    19380953:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380956:	c7 80 24 07 00 00 02 	mov    DWORD PTR [rax+0x724],0x2
    1938095d:	00 00 00 
    19380960:	48 81 7b 08 ca 01 00 	cmp    QWORD PTR [rbx+0x8],0x1ca
    19380967:	00 
    19380968:	0f 86 11 09 00 00    	jbe    1938127f <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e5f>
    1938096e:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380971:	c7 80 28 07 00 00 02 	mov    DWORD PTR [rax+0x728],0x2
    19380978:	00 00 00 
    1938097b:	48 81 7b 08 cb 01 00 	cmp    QWORD PTR [rbx+0x8],0x1cb
    19380982:	00 
    19380983:	0f 86 f8 08 00 00    	jbe    19381281 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e61>
    19380989:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1938098c:	c7 80 2c 07 00 00 02 	mov    DWORD PTR [rax+0x72c],0x2
    19380993:	00 00 00 
    19380996:	48 81 7b 08 cc 01 00 	cmp    QWORD PTR [rbx+0x8],0x1cc
    1938099d:	00 
    1938099e:	0f 86 df 08 00 00    	jbe    19381283 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e63>
    193809a4:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193809a7:	c7 80 30 07 00 00 02 	mov    DWORD PTR [rax+0x730],0x2
    193809ae:	00 00 00 
    193809b1:	48 81 7b 08 cd 01 00 	cmp    QWORD PTR [rbx+0x8],0x1cd
    193809b8:	00 
    193809b9:	0f 86 c6 08 00 00    	jbe    19381285 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e65>
    193809bf:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193809c2:	c7 80 34 07 00 00 02 	mov    DWORD PTR [rax+0x734],0x2
    193809c9:	00 00 00 
    193809cc:	48 81 7b 08 ce 01 00 	cmp    QWORD PTR [rbx+0x8],0x1ce
    193809d3:	00 
    193809d4:	0f 86 ad 08 00 00    	jbe    19381287 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e67>
    193809da:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193809dd:	c7 80 38 07 00 00 02 	mov    DWORD PTR [rax+0x738],0x2
    193809e4:	00 00 00 
    193809e7:	48 81 7b 08 cf 01 00 	cmp    QWORD PTR [rbx+0x8],0x1cf
    193809ee:	00 
    193809ef:	0f 86 94 08 00 00    	jbe    19381289 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e69>
    193809f5:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    193809f8:	c7 80 3c 07 00 00 02 	mov    DWORD PTR [rax+0x73c],0x2
    193809ff:	00 00 00 
    19380a02:	48 81 7b 08 d0 01 00 	cmp    QWORD PTR [rbx+0x8],0x1d0
    19380a09:	00 
    19380a0a:	0f 86 7b 08 00 00    	jbe    1938128b <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6e6b>
    19380a10:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    19380a13:	c7 80 40 07 00 00 02 	mov    DWORD PTR [rax+0x740],0x2
    19380a1a:	00 00 00 
    19380a1d:	48 83 c4 08          	add    rsp,0x8
    19380a21:	5b                   	pop    rbx
    19380a22:	41 5c                	pop    r12
    19380a24:	41 5d                	pop    r13
    19380a26:	41 5e                	pop    r14
    19380a28:	41 5f                	pop    r15
    19380a2a:	5d                   	pop    rbp
    19380a2b:	c5 f8 77             	vzeroupper
    19380a2e:	c3                   	ret
