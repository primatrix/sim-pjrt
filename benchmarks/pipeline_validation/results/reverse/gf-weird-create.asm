
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

000000001991d850 <_ZN3xla9jellyfish14LloInstruction17CreateVectorWeirdENS_13PrimitiveTypeEPNS0_8LloValueEPNS0_9LloRegionE>:
    1991d850:	0f b7 46 1a          	movzx  eax,WORD PTR [rsi+0x1a]
    1991d854:	48 3d ce 01 00 00    	cmp    rax,0x1ce
    1991d85a:	0f 83 0d 02 00 00    	jae    1991da6d <_ZN3xla9jellyfish14LloInstruction17CreateVectorWeirdENS_13PrimitiveTypeEPNS0_8LloValueEPNS0_9LloRegionE+0x21d>
    1991d860:	55                   	push   rbp
    1991d861:	48 89 e5             	mov    rbp,rsp
    1991d864:	41 57                	push   r15
    1991d866:	41 56                	push   r14
    1991d868:	41 55                	push   r13
    1991d86a:	41 54                	push   r12
    1991d86c:	53                   	push   rbx
    1991d86d:	48 83 ec 58          	sub    rsp,0x58
    1991d871:	49 89 d6             	mov    r14,rdx
    1991d874:	49 89 f7             	mov    r15,rsi
    1991d877:	89 fb                	mov    ebx,edi
    1991d879:	48 8d 0d 10 a0 10 05 	lea    rcx,[rip+0x510a010]        # 1ea27890 <_ZN3xla9jellyfish8internal29opcode_produced_register_typeE>
    1991d880:	80 3c 01 04          	cmp    BYTE PTR [rcx+rax*1],0x4
    1991d884:	0f 85 06 01 00 00    	jne    1991d990 <_ZN3xla9jellyfish14LloInstruction17CreateVectorWeirdENS_13PrimitiveTypeEPNS0_8LloValueEPNS0_9LloRegionE+0x140>
    1991d88a:	83 fb 0b             	cmp    ebx,0xb
    1991d88d:	74 09                	je     1991d898 <_ZN3xla9jellyfish14LloInstruction17CreateVectorWeirdENS_13PrimitiveTypeEPNS0_8LloValueEPNS0_9LloRegionE+0x48>
    1991d88f:	83 fb 10             	cmp    ebx,0x10
    1991d892:	0f 85 8d 00 00 00    	jne    1991d925 <_ZN3xla9jellyfish14LloInstruction17CreateVectorWeirdENS_13PrimitiveTypeEPNS0_8LloValueEPNS0_9LloRegionE+0xd5>
    1991d898:	4c 89 7d b0          	mov    QWORD PTR [rbp-0x50],r15
    1991d89c:	48 c7 04 24 00 00 00 	mov    QWORD PTR [rsp],0x0
    1991d8a3:	00 
    1991d8a4:	48 8d 75 b0          	lea    rsi,[rbp-0x50]
    1991d8a8:	ba 01 00 00 00       	mov    edx,0x1
    1991d8ad:	bf ad 00 00 00       	mov    edi,0xad
    1991d8b2:	4c 89 f1             	mov    rcx,r14
    1991d8b5:	45 31 c0             	xor    r8d,r8d
    1991d8b8:	45 31 c9             	xor    r9d,r9d
    1991d8bb:	e8 40 a6 ff ff       	call   19917f00 <_ZN3xla9jellyfish14LloInstruction3NewENS0_9LloOpcodeEN4absl4SpanIKPNS0_8LloValueEEEPNS0_9LloRegionES6_NS0_19PredicationPolarityES6_>
    1991d8c0:	48 8b 48 38          	mov    rcx,QWORD PTR [rax+0x38]
    1991d8c4:	48 85 c9             	test   rcx,rcx
    1991d8c7:	0f 94 c2             	sete   dl
    1991d8ca:	85 db                	test   ebx,ebx
    1991d8cc:	40 0f 94 c6          	sete   sil
    1991d8d0:	40 84 d6             	test   sil,dl
    1991d8d3:	75 3e                	jne    1991d913 <_ZN3xla9jellyfish14LloInstruction17CreateVectorWeirdENS_13PrimitiveTypeEPNS0_8LloValueEPNS0_9LloRegionE+0xc3>
    1991d8d5:	48 85 c9             	test   rcx,rcx
    1991d8d8:	75 33                	jne    1991d90d <_ZN3xla9jellyfish14LloInstruction17CreateVectorWeirdENS_13PrimitiveTypeEPNS0_8LloValueEPNS0_9LloRegionE+0xbd>
    1991d8da:	bf 90 00 00 00       	mov    edi,0x90
    1991d8df:	49                   	rex.WB
