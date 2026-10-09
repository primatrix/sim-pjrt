
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

00000000199b1e80 <_ZN3xla9jellyfish16LloRegionBuilder9VpackInstENS0_11VpackFormatEPNS0_8LloValueES4_>:
    199b1e80:	55                   	push   rbp
    199b1e81:	48 89 e5             	mov    rbp,rsp
    199b1e84:	53                   	push   rbx
    199b1e85:	50                   	push   rax
    199b1e86:	48 8b 1f             	mov    rbx,QWORD PTR [rdi]
    199b1e89:	bf 26 01 00 00       	mov    edi,0x126
    199b1e8e:	49 89 d8             	mov    r8,rbx
    199b1e91:	e8 8a 9d f6 ff       	call   1991bc20 <_ZN3xla9jellyfish14LloInstruction16CreateVectorPackENS0_9LloOpcodeENS0_11VpackFormatEPNS0_8LloValueES5_PNS0_9LloRegionE>
    199b1e96:	48 89 df             	mov    rdi,rbx
    199b1e99:	48 89 c6             	mov    rsi,rax
    199b1e9c:	31 d2                	xor    edx,edx
    199b1e9e:	48 83 c4 08          	add    rsp,0x8
    199b1ea2:	5b                   	pop    rbx
    199b1ea3:	5d                   	pop    rbp
    199b1ea4:	e9 57 89 fa ff       	jmp    1995a800 <_ZN3xla9jellyfish9LloRegion17AppendInstructionENSt3__u10unique_ptrINS0_14LloInstructionENS2_14default_deleteIS4_EEEENS2_8optionalINS0_14LloElementTypeEEE>
    199b1ea9:	cc                   	int3
    199b1eaa:	cc                   	int3
    199b1eab:	cc                   	int3
    199b1eac:	cc                   	int3
    199b1ead:	cc                   	int3
    199b1eae:	cc                   	int3
    199b1eaf:	cc                   	int3

00000000199b1eb0 <_ZN3xla9jellyfish16LloRegionBuilder17VpackAndReplicateEPNS0_8LloValueERKNS_5ShapeE>:
    199b1eb0:	55                   	push   rbp
    199b1eb1:	48 89 e5             	mov    rbp,rsp
    199b1eb4:	41 57                	push   r15
    199b1eb6:	41 56                	push   r14
    199b1eb8:	41 55                	push   r13
    199b1eba:	41 54                	push   r12
    199b1ebc:	53                   	push   rbx
    199b1ebd:	48 83 ec 28          	sub    rsp,0x28
    199b1ec1:	49 89 d7             	mov    r15,rdx
    199b1ec4:	49 89 f6             	mov    r14,rsi
    199b1ec7:	48 89 fb             	mov    rbx,rdi
    199b1eca:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    199b1ecd:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    199b1ed1:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
    199b1ed5:	4c 8b a0 38 05 00 00 	mov    r12,QWORD PTR [rax+0x538]
    199b1edc:	4c 89 e7             	mov    rdi,r12
    199b1edf:	48 89 d6             	mov    rsi,rdx
    199b1ee2:	e8 c9 f5 4c 00       	call   19e814b0 <_ZN3xla9jellyfish16TransferSizeUtil25ShouldPackPREDAsSingleBitERKN3tpu11TpuTopologyERKNS_5ShapeE>
    199b1ee7:	41 89 c5             	mov    r13d,eax
    199b1eea:	4c 89 ff             	mov    rdi,r15
    199b1eed:	e8 4e 1e cf f2       	call   c6a3d40 <_ZNK3xla5Shape12element_typeEv>
    199b1ef2:	41 0f b6 d5          	movzx  edx,r13b
    199b1ef6:	4c 89 e7             	mov    rdi,r12
    199b1ef9:	89 c6                	mov    esi,eax
    199b1efb:	e8 c0 f8 4c 00       	call   19e817c0 <_ZN3xla9jellyfish16TransferSizeUtil20ElementPackingFactorERKN3tpu11TpuTopologyENS_13PrimitiveTypeEb>
    199b1f00:	89 45 d4             	mov    DWORD PTR [rbp-0x2c],eax
    199b1f03:	83 f8 01             	cmp    eax,0x1
    199b1f06:	0f 84 7d 01 00 00    	je     199b2089 <_ZN3xla9jellyfish16LloRegionBuilder17VpackAndReplicateEPNS0_8LloValueERKNS_5ShapeE+0x1d9>
    199b1f0c:	4c 89 ff             	mov    rdi,r15
    199b1f0f:	e8 2c 1e cf f2       	call   c6a3d40 <_ZNK3xla5Shape12element_typeEv>
    199b1f14:	83 f8 10             	cmp    eax,0x10
    199b1f17:	75 35                	jne    199b1f4e <_ZN3xla9jellyfish16LloRegionBuilder17VpackAndReplicateEPNS0_8LloValueERKNS_5ShapeE+0x9e>
    199b1f19:	4c 89 f7             	mov    rdi,r14
    199b1f1c:	4c 89 f6             	mov    rsi,r14
    199b1f1f:	ba 04 00 00 00       	mov    edx,0x4
    199b1f24:	e8 f7 44 03 00       	call   199e6420 <_ZN3xla9jellyfish14llo_simplifier15SimplifyPackF16EPNS0_8LloValueES3_NS0_12RegisterTypeE>
    199b1f29:	48 85 c0             	test   rax,rax
    199b1f2c:	0f 85 5a 01 00 00    	jne    199b208c <_ZN3xla9jellyfish16LloRegionBuilder17VpackAndReplicateEPNS0_8LloValueERKNS_5ShapeE+0x1dc>
    199b1f32:	48 89 df             	mov    rdi,rbx
    199b1f35:	4c 89 f6             	mov    rsi,r14
    199b1f38:	4c 89 f2             	mov    rdx,r14
    199b1f3b:	48 83 c4 28          	add    rsp,0x28
    199b1f3f:	5b                   	pop    rbx
    199b1f40:	41 5c                	pop    r12
    199b1f42:	41 5d                	pop    r13
    199b1f44:	41 5e                	pop    r14
    199b1f46:	41 5f                	pop    r15
    199b1f48:	5d                   	pop    rbp
    199b1f49:	e9 52 fe ff ff       	jmp    199b1da0 <_ZN3xla9jellyfish16LloRegionBuilder13VpackBf16InstEPNS0_8LloValueES3_>
    199b1f4e:	4c 89 ff             	mov    rdi,r15
    199b1f51:	e8 ea 1d cf f2       	call   c6a3d40 <_ZNK3xla5Shape12element_typeEv>
    199b1f56:	83 f8 24             	cmp    eax,0x24
    199b1f59:	77 2a                	ja     199b1f85 <_ZN3xla9jellyfish16LloRegionBuilder17VpackAndReplicateEPNS0_8LloValueERKNS_5ShapeE+0xd5>
    199b1f5b:	89 c0                	mov    eax,eax
    199b1f5d:	48 b9 00 1c 99 33 1b 	movabs rcx,0x1b33991c00
    199b1f64:	00 00 00 
    199b1f67:	48 0f a3 c1          	bt     rcx,rax
    199b1f6b:	73 18                	jae    199b1f85 <_ZN3xla9jellyfish16LloRegionBuilder17VpackAndReplicateEPNS0_8LloValueERKNS_5ShapeE+0xd5>
    199b1f6d:	4c 89 ff             	mov    rdi,r15
    199b1f70:	e8 cb 1d cf f2       	call   c6a3d40 <_ZNK3xla5Shape12element_typeEv>
    199b1f75:	48 89 df             	mov    rdi,rbx
    199b1f78:	4c 89 f6             	mov    rsi,r14
    199b1f7b:	89 c2                	mov    edx,eax
    199b1f7d:	e8 5e b7 ff ff       	call   199ad6e0 <_ZN3xla9jellyfish16LloRegionBuilder20VcvtF32ToNarrowFloatEPNS0_8LloValueENS_13PrimitiveTypeE>
    199b1f82:	49 89 c6             	mov    r14,rax
    199b1f85:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    199b1f88:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    199b1f8c:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
    199b1f90:	4c 8b a0 38 05 00 00 	mov    r12,QWORD PTR [rax+0x538]
    199b1f97:	4c 89 e7             	mov    rdi,r12
    199b1f9a:	4c 89 fe             	mov    rsi,r15
    199b1f9d:	e8 0e f5 4c 00       	call   19e814b0 <_ZN3xla9jellyfish16TransferSizeUtil25ShouldPackPREDAsSingleBitERKN3tpu11TpuTopologyERKNS_5ShapeE>
    199b1fa2:	41 89 c5             	mov    r13d,eax
    199b1fa5:	4c 89 ff             	mov    rdi,r15
    199b1fa8:	e8 93 1d cf f2       	call   c6a3d40 <_ZNK3xla5Shape12element_typeEv>
    199b1fad:	41 0f b6 d5          	movzx  edx,r13b
    199b1fb1:	4c 89 e7             	mov    rdi,r12
    199b1fb4:	89 c6                	mov    esi,eax
    199b1fb6:	e8 05 f8 4c 00       	call   19e817c0 <_ZN3xla9jellyfish16TransferSizeUtil20ElementPackingFactorERKN3tpu11TpuTopologyENS_13PrimitiveTypeEb>
    199b1fbb:	48 83 f8 02          	cmp    rax,0x2
    199b1fbf:	7c 11                	jl     199b1fd2 <_ZN3xla9jellyfish16LloRegionBuilder17VpackAndReplicateEPNS0_8LloValueERKNS_5ShapeE+0x122>
    199b1fc1:	48 89 df             	mov    rdi,rbx
    199b1fc4:	4c 89 f6             	mov    rsi,r14
    199b1fc7:	4c 89 f2             	mov    rdx,r14
    199b1fca:	e8 31 ca fe ff       	call   1999ea00 <_ZN3xla9jellyfish16LloRegionBuilder9VpackiB16EPNS0_8LloValueES3_>
    199b1fcf:	49 89 c6             	mov    r14,rax
    199b1fd2:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    199b1fd5:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    199b1fd9:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
    199b1fdd:	4c 8b a0 38 05 00 00 	mov    r12,QWORD PTR [rax+0x538]
    199b1fe4:	4c 89 e7             	mov    rdi,r12
    199b1fe7:	4c 89 fe             	mov    rsi,r15
    199b1fea:	e8 c1 f4 4c 00       	call   19e814b0 <_ZN3xla9jellyfish16TransferSizeUtil25ShouldPackPREDAsSingleBitERKN3tpu11TpuTopologyERKNS_5ShapeE>
    199b1fef:	41 89 c5             	mov    r13d,eax
    199b1ff2:	4c 89 ff             	mov    rdi,r15
    199b1ff5:	e8 46 1d cf f2       	call   c6a3d40 <_ZNK3xla5Shape12element_typeEv>
    199b1ffa:	41 0f b6 d5          	movzx  edx,r13b
    199b1ffe:	4c 89 e7             	mov    rdi,r12
    199b2001:	89 c6                	mov    esi,eax
    199b2003:	e8 b8 f7 4c 00       	call   19e817c0 <_ZN3xla9jellyfish16TransferSizeUtil20ElementPackingFactorERKN3tpu11TpuTopologyENS_13PrimitiveTypeEb>
    199b2008:	48 83 f8 04          	cmp    rax,0x4
    199b200c:	7c 11                	jl     199b201f <_ZN3xla9jellyfish16LloRegionBuilder17VpackAndReplicateEPNS0_8LloValueERKNS_5ShapeE+0x16f>
    199b200e:	48 89 df             	mov    rdi,rbx
    199b2011:	4c 89 f6             	mov    rsi,r14
    199b2014:	4c 89 f2             	mov    rdx,r14
    199b2017:	e8 d4 00 00 00       	call   199b20f0 <_ZN3xla9jellyfish16LloRegionBuilder8VpackiB8EPNS0_8LloValueES3_>
    199b201c:	49 89 c6             	mov    r14,rax
    199b201f:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    199b2022:	48 8b 40 38          	mov    rax,QWORD PTR [rax+0x38]
    199b2026:	48 8b 40 10          	mov    rax,QWORD PTR [rax+0x10]
    199b202a:	4c 8b a0 38 05 00 00 	mov    r12,QWORD PTR [rax+0x538]
    199b2031:	4c 89 e7             	mov    rdi,r12
    199b2034:	4c 89 fe             	mov    rsi,r15
    199b2037:	e8 74 f4 4c 00       	call   19e814b0 <_ZN3xla9jellyfish16TransferSizeUtil25ShouldPackPREDAsSingleBitERKN3tpu11TpuTopologyERKNS_5ShapeE>
    199b203c:	41 89 c5             	mov    r13d,eax
    199b203f:	4c 89 ff             	mov    rdi,r15
    199b2042:	e8 f9 1c cf f2       	call   c6a3d40 <_ZNK3xla5Shape12element_typeEv>
    199b2047:	41 0f b6 d5          	movzx  edx,r13b
    199b204b:	4c 89 e7             	mov    rdi,r12
    199b204e:	89 c6                	mov    esi,eax
    199b2050:	e8 6b f7 4c 00       	call   19e817c0 <_ZN3xla9jellyfish16TransferSizeUtil20ElementPackingFactorERKN3tpu11TpuTopologyENS_13PrimitiveTypeEb>
    199b2055:	48 83 f8 08          	cmp    rax,0x8
    199b2059:	7c 11                	jl     199b206c <_ZN3xla9jellyfish16LloRegionBuilder17VpackAndReplicateEPNS0_8LloValueERKNS_5ShapeE+0x1bc>
    199b205b:	48 89 df             	mov    rdi,rbx
    199b205e:	4c 89 f6             	mov    rsi,r14
    199b2061:	4c 89 f2             	mov    rdx,r14
    199b2064:	e8 47 02 00 00       	call   199b22b0 <_ZN3xla9jellyfish16LloRegionBuilder8VpackiB4EPNS0_8LloValueES3_>
    199b2069:	49 89 c6             	mov    r14,rax
    199b206c:	c7 45 b8 08 00 00 00 	mov    DWORD PTR [rbp-0x48],0x8
    199b2073:	48 8d 7d d4          	lea    rdi,[rbp-0x2c]
    199b2077:	48 8d 75 b8          	lea    rsi,[rbp-0x48]
    199b207b:	e8 f0 03 00 00       	call   199b2470 <_ZN3xla9jellyfish8internal18LloCheckForFailureIKiiLNS1_10LloCheckOpE3EEENSt3__u10unique_ptrINS0_13StatusWrapper11CheckFailerENS5_14default_deleteIS8_EEEERKT_RKT0_>
    199b2080:	48 89 45 c8          	mov    QWORD PTR [rbp-0x38],rax
    199b2084:	48 85 c0             	test   rax,rax
    199b2087:	75 12                	jne    199b209b <_ZN3xla9jellyfish16LloRegionBuilder17VpackAndReplicateEPNS0_8LloValueERKNS_5ShapeE+0x1eb>
    199b2089:	4c 89 f0             	mov    rax,r14
    199b208c:	48 83 c4 28          	add    rsp,0x28
