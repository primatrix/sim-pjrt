
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

0000000019360000 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x9c0>:
    19360000:	55                   	push   rbp
    19360001:	48 89 e5             	mov    rbp,rsp
    19360004:	53                   	push   rbx
    19360005:	50                   	push   rax
    19360006:	48 89 f3             	mov    rbx,rsi
    19360009:	48 8b bf d0 01 00 00 	mov    rdi,QWORD PTR [rdi+0x1d0]
    19360010:	89 d6                	mov    esi,edx
    19360012:	e8 89 12 02 00       	call   193812a0 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x6e80>
    19360017:	48 85 db             	test   rbx,rbx
    1936001a:	74 44                	je     19360060 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xa20>
    1936001c:	0f b7 4b 1a          	movzx  ecx,WORD PTR [rbx+0x1a]
    19360020:	81 c1 74 ff ff ff    	add    ecx,0xffffff74
    19360026:	66 83 f9 09          	cmp    cx,0x9
    1936002a:	77 34                	ja     19360060 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xa20>
    1936002c:	48 89 df             	mov    rdi,rbx
    1936002f:	89 c3                	mov    ebx,eax
    19360031:	e8 8a fd 5c 00       	call   1992fdc0 <_ZNK3xla9jellyfish14LloInstruction10latch_modeEv>
    19360036:	0f b6 f8             	movzx  edi,al
    19360039:	e8 92 8a b0 00       	call   19e68ad0 <_ZN3xla9jellyfish20LatchModeIsTransposeENS0_13GainLatchModeE>
    1936003e:	89 c1                	mov    ecx,eax
    19360040:	89 d8                	mov    eax,ebx
    19360042:	84 c9                	test   cl,cl
    19360044:	75 1a                	jne    19360060 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0xa20>
    19360046:	89 c1                	mov    ecx,eax
    19360048:	c1 e9 1f             	shr    ecx,0x1f
    1936004b:	01 c1                	add    ecx,eax
    1936004d:	d1 f9                	sar    ecx,1
    1936004f:	25 01 00 00 80       	and    eax,0x80000001
    19360054:	31 d2                	xor    edx,edx
    19360056:	83 f8 01             	cmp    eax,0x1
    19360059:	0f 94 c2             	sete   dl
    1936005c:	01 ca                	add    edx,ecx
    1936005e:	89 d0                	mov    eax,edx
    19360060:	48 83 c4 08          	add    rsp,0x8
    19360064:	5b                   	pop    rbx
    19360065:	5d                   	pop    rbp
    19360066:	c3                   	ret
    19360067:	cc                   	int3
    19360068:	cc                   	int3
    19360069:	cc                   	int3
    1936006a:	cc                   	int3
    1936006b:	cc                   	int3
    1936006c:	cc                   	int3
    1936006d:	cc                   	int3
    1936006e:	cc                   	int3
    1936006f:	cc                   	int3
