
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

000000001935f8a0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x260>:
    1935f8a0:	55                   	push   rbp
    1935f8a1:	48 89 e5             	mov    rbp,rsp
    1935f8a4:	41 57                	push   r15
    1935f8a6:	41 56                	push   r14
    1935f8a8:	53                   	push   rbx
    1935f8a9:	50                   	push   rax
    1935f8aa:	49 89 fe             	mov    r14,rdi
    1935f8ad:	e8 0e 5f fe ff       	call   193457c0 <_ZN3xla9jellyfish12LatencyTableC2EN3tpu10TpuVersionE>
    1935f8b2:	c5 f8 57 c0          	vxorps xmm0,xmm0,xmm0
    1935f8b6:	c4 c1 7c 11 86 b0 01 	vmovups YMMWORD PTR [r14+0x1b0],ymm0
    1935f8bd:	00 00 
    1935f8bf:	c4 c1 7c 11 86 a0 01 	vmovups YMMWORD PTR [r14+0x1a0],ymm0
    1935f8c6:	00 00 
    1935f8c8:	c4 c1 7c 11 86 80 01 	vmovups YMMWORD PTR [r14+0x180],ymm0
    1935f8cf:	00 00 
    1935f8d1:	c4 c1 7c 11 86 60 01 	vmovups YMMWORD PTR [r14+0x160],ymm0
    1935f8d8:	00 00 
    1935f8da:	c4 c1 7c 11 86 40 01 	vmovups YMMWORD PTR [r14+0x140],ymm0
    1935f8e1:	00 00 
    1935f8e3:	c4 c1 7c 11 86 20 01 	vmovups YMMWORD PTR [r14+0x120],ymm0
    1935f8ea:	00 00 
    1935f8ec:	c4 c1 7c 11 86 00 01 	vmovups YMMWORD PTR [r14+0x100],ymm0
    1935f8f3:	00 00 
    1935f8f5:	c4 c1 7c 11 86 e0 00 	vmovups YMMWORD PTR [r14+0xe0],ymm0
    1935f8fc:	00 00 
    1935f8fe:	c4 c1 7c 11 86 c0 00 	vmovups YMMWORD PTR [r14+0xc0],ymm0
    1935f905:	00 00 
    1935f907:	c4 c1 7c 11 86 a0 00 	vmovups YMMWORD PTR [r14+0xa0],ymm0
    1935f90e:	00 00 
    1935f910:	c4 c1 7c 11 86 80 00 	vmovups YMMWORD PTR [r14+0x80],ymm0
    1935f917:	00 00 
    1935f919:	c4 c1 7c 11 46 60    	vmovups YMMWORD PTR [r14+0x60],ymm0
    1935f91f:	c4 c1 7c 11 46 40    	vmovups YMMWORD PTR [r14+0x40],ymm0
    1935f925:	c4 c1 7c 11 46 20    	vmovups YMMWORD PTR [r14+0x20],ymm0
    1935f92b:	48 8d 05 fe 8e ed 04 	lea    rax,[rip+0x4ed8efe]        # 1e238830 <_ZZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish16MatmulDataFormatEjEEJEE18GetPolicyFunctionsEvE5value+0x48>
    1935f932:	48 8d 48 10          	lea    rcx,[rax+0x10]
    1935f936:	49 89 0e             	mov    QWORD PTR [r14],rcx
    1935f939:	48 83 c0 50          	add    rax,0x50
    1935f93d:	49 89 46 18          	mov    QWORD PTR [r14+0x18],rax
    1935f941:	0f b6 05 38 85 7e 05 	movzx  eax,BYTE PTR [rip+0x57e8538]        # 1eb47e80 <_ZGVZN3xla9ghostlite12_GLOBAL__N_124GetSharedMxuLatencyTableEvE18mxu_latency_shared+0x10>
    1935f948:	84 c0                	test   al,al
    1935f94a:	0f 84 18 06 00 00    	je     1935ff68 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x928>
    1935f950:	49 8d 5e 18          	lea    rbx,[r14+0x18]
    1935f954:	48 8b 05 1d 85 7e 05 	mov    rax,QWORD PTR [rip+0x57e851d]        # 1eb47e78 <_ZGVZN3xla9ghostlite12_GLOBAL__N_124GetSharedMxuLatencyTableEvE18mxu_latency_shared+0x8>
    1935f95b:	49 89 86 d0 01 00 00 	mov    QWORD PTR [r14+0x1d0],rax
    1935f962:	0f b6 05 27 85 7e 05 	movzx  eax,BYTE PTR [rip+0x57e8527]        # 1eb47e90 <_ZGVZN3xla9ghostlite12_GLOBAL__N_124GetSharedMxuLatencyTableEvE18mxu_latency_shared+0x20>
    1935f969:	84 c0                	test   al,al
    1935f96b:	0f 84 3b 06 00 00    	je     1935ffac <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x96c>
    1935f971:	48 8b 05 10 85 7e 05 	mov    rax,QWORD PTR [rip+0x57e8510]        # 1eb47e88 <_ZGVZN3xla9ghostlite12_GLOBAL__N_124GetSharedMxuLatencyTableEvE18mxu_latency_shared+0x18>
    1935f978:	49 89 86 d8 01 00 00 	mov    QWORD PTR [r14+0x1d8],rax
    1935f97f:	48 89 df             	mov    rdi,rbx
    1935f982:	c5 f8 77             	vzeroupper
    1935f985:	e8 76 67 fe ff       	call   19346100 <_ZN3xla9jellyfish23XluConflictPenaltyTable25InitializeConflictLatencyEv>
    1935f98a:	48 89 df             	mov    rdi,rbx
    1935f98d:	31 f6                	xor    esi,esi
    1935f98f:	ba 02 00 00 00       	mov    edx,0x2
    1935f994:	31 c9                	xor    ecx,ecx
    1935f996:	41 b8 2c 00 00 00    	mov    r8d,0x2c
    1935f99c:	e8 4f 68 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935f9a1:	48 89 df             	mov    rdi,rbx
    1935f9a4:	31 f6                	xor    esi,esi
    1935f9a6:	ba 02 00 00 00       	mov    edx,0x2
    1935f9ab:	b9 01 00 00 00       	mov    ecx,0x1
    1935f9b0:	41 b8 32 00 00 00    	mov    r8d,0x32
    1935f9b6:	e8 35 68 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935f9bb:	48 89 df             	mov    rdi,rbx
    1935f9be:	31 f6                	xor    esi,esi
    1935f9c0:	ba 03 00 00 00       	mov    edx,0x3
    1935f9c5:	31 c9                	xor    ecx,ecx
    1935f9c7:	41 b8 2c 00 00 00    	mov    r8d,0x2c
    1935f9cd:	e8 1e 68 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935f9d2:	48 89 df             	mov    rdi,rbx
    1935f9d5:	31 f6                	xor    esi,esi
    1935f9d7:	ba 03 00 00 00       	mov    edx,0x3
    1935f9dc:	b9 01 00 00 00       	mov    ecx,0x1
    1935f9e1:	41 b8 2c 00 00 00    	mov    r8d,0x2c
    1935f9e7:	e8 04 68 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935f9ec:	48 89 df             	mov    rdi,rbx
    1935f9ef:	31 f6                	xor    esi,esi
    1935f9f1:	ba 04 00 00 00       	mov    edx,0x4
    1935f9f6:	31 c9                	xor    ecx,ecx
    1935f9f8:	41 b8 20 00 00 00    	mov    r8d,0x20
    1935f9fe:	e8 ed 67 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fa03:	48 89 df             	mov    rdi,rbx
    1935fa06:	31 f6                	xor    esi,esi
    1935fa08:	ba 04 00 00 00       	mov    edx,0x4
    1935fa0d:	b9 01 00 00 00       	mov    ecx,0x1
    1935fa12:	41 b8 1c 00 00 00    	mov    r8d,0x1c
    1935fa18:	e8 d3 67 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fa1d:	48 89 df             	mov    rdi,rbx
    1935fa20:	be 01 00 00 00       	mov    esi,0x1
    1935fa25:	ba 02 00 00 00       	mov    edx,0x2
    1935fa2a:	31 c9                	xor    ecx,ecx
    1935fa2c:	41 b8 30 00 00 00    	mov    r8d,0x30
    1935fa32:	e8 b9 67 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fa37:	48 89 df             	mov    rdi,rbx
    1935fa3a:	be 01 00 00 00       	mov    esi,0x1
    1935fa3f:	ba 02 00 00 00       	mov    edx,0x2
    1935fa44:	b9 01 00 00 00       	mov    ecx,0x1
    1935fa49:	41 b8 36 00 00 00    	mov    r8d,0x36
    1935fa4f:	e8 9c 67 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fa54:	48 89 df             	mov    rdi,rbx
    1935fa57:	be 01 00 00 00       	mov    esi,0x1
    1935fa5c:	ba 03 00 00 00       	mov    edx,0x3
    1935fa61:	31 c9                	xor    ecx,ecx
    1935fa63:	41 b8 30 00 00 00    	mov    r8d,0x30
    1935fa69:	e8 82 67 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fa6e:	48 89 df             	mov    rdi,rbx
    1935fa71:	be 01 00 00 00       	mov    esi,0x1
    1935fa76:	ba 03 00 00 00       	mov    edx,0x3
    1935fa7b:	b9 01 00 00 00       	mov    ecx,0x1
    1935fa80:	41 b8 30 00 00 00    	mov    r8d,0x30
    1935fa86:	e8 65 67 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fa8b:	48 89 df             	mov    rdi,rbx
    1935fa8e:	be 01 00 00 00       	mov    esi,0x1
    1935fa93:	ba 04 00 00 00       	mov    edx,0x4
    1935fa98:	31 c9                	xor    ecx,ecx
    1935fa9a:	41 b8 24 00 00 00    	mov    r8d,0x24
    1935faa0:	e8 4b 67 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935faa5:	48 89 df             	mov    rdi,rbx
    1935faa8:	be 01 00 00 00       	mov    esi,0x1
    1935faad:	ba 04 00 00 00       	mov    edx,0x4
    1935fab2:	b9 01 00 00 00       	mov    ecx,0x1
    1935fab7:	41 b8 20 00 00 00    	mov    r8d,0x20
    1935fabd:	e8 2e 67 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fac2:	48 89 df             	mov    rdi,rbx
    1935fac5:	31 f6                	xor    esi,esi
    1935fac7:	ba 05 00 00 00       	mov    edx,0x5
    1935facc:	31 c9                	xor    ecx,ecx
    1935face:	41 b8 15 00 00 00    	mov    r8d,0x15
    1935fad4:	e8 17 67 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fad9:	48 89 df             	mov    rdi,rbx
    1935fadc:	31 f6                	xor    esi,esi
    1935fade:	ba 05 00 00 00       	mov    edx,0x5
    1935fae3:	b9 01 00 00 00       	mov    ecx,0x1
    1935fae8:	41 b8 10 00 00 00    	mov    r8d,0x10
    1935faee:	e8 fd 66 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935faf3:	48 89 df             	mov    rdi,rbx
    1935faf6:	be 01 00 00 00       	mov    esi,0x1
    1935fafb:	ba 05 00 00 00       	mov    edx,0x5
    1935fb00:	31 c9                	xor    ecx,ecx
    1935fb02:	41 b8 19 00 00 00    	mov    r8d,0x19
    1935fb08:	e8 e3 66 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fb0d:	48 89 df             	mov    rdi,rbx
    1935fb10:	be 01 00 00 00       	mov    esi,0x1
    1935fb15:	ba 05 00 00 00       	mov    edx,0x5
    1935fb1a:	b9 01 00 00 00       	mov    ecx,0x1
    1935fb1f:	41 b8 14 00 00 00    	mov    r8d,0x14
    1935fb25:	e8 c6 66 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fb2a:	48 89 df             	mov    rdi,rbx
    1935fb2d:	be 05 00 00 00       	mov    esi,0x5
    1935fb32:	31 d2                	xor    edx,edx
    1935fb34:	31 c9                	xor    ecx,ecx
    1935fb36:	41 b8 1e 00 00 00    	mov    r8d,0x1e
    1935fb3c:	e8 af 66 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fb41:	48 89 df             	mov    rdi,rbx
    1935fb44:	be 05 00 00 00       	mov    esi,0x5
    1935fb49:	31 d2                	xor    edx,edx
    1935fb4b:	b9 01 00 00 00       	mov    ecx,0x1
    1935fb50:	41 b8 23 00 00 00    	mov    r8d,0x23
    1935fb56:	e8 95 66 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fb5b:	48 89 df             	mov    rdi,rbx
    1935fb5e:	be 05 00 00 00       	mov    esi,0x5
    1935fb63:	ba 01 00 00 00       	mov    edx,0x1
    1935fb68:	31 c9                	xor    ecx,ecx
    1935fb6a:	41 b8 1e 00 00 00    	mov    r8d,0x1e
    1935fb70:	e8 7b 66 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fb75:	48 89 df             	mov    rdi,rbx
    1935fb78:	be 05 00 00 00       	mov    esi,0x5
    1935fb7d:	ba 01 00 00 00       	mov    edx,0x1
    1935fb82:	b9 01 00 00 00       	mov    ecx,0x1
    1935fb87:	41 b8 23 00 00 00    	mov    r8d,0x23
    1935fb8d:	e8 5e 66 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fb92:	48 89 df             	mov    rdi,rbx
    1935fb95:	be 05 00 00 00       	mov    esi,0x5
    1935fb9a:	ba 02 00 00 00       	mov    edx,0x2
    1935fb9f:	31 c9                	xor    ecx,ecx
    1935fba1:	41 b8 1d 00 00 00    	mov    r8d,0x1d
    1935fba7:	e8 44 66 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fbac:	48 89 df             	mov    rdi,rbx
    1935fbaf:	be 05 00 00 00       	mov    esi,0x5
    1935fbb4:	ba 02 00 00 00       	mov    edx,0x2
    1935fbb9:	b9 01 00 00 00       	mov    ecx,0x1
    1935fbbe:	41 b8 28 00 00 00    	mov    r8d,0x28
    1935fbc4:	e8 27 66 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fbc9:	48 89 df             	mov    rdi,rbx
    1935fbcc:	be 05 00 00 00       	mov    esi,0x5
    1935fbd1:	ba 03 00 00 00       	mov    edx,0x3
    1935fbd6:	31 c9                	xor    ecx,ecx
    1935fbd8:	41 b8 1d 00 00 00    	mov    r8d,0x1d
    1935fbde:	e8 0d 66 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fbe3:	48 89 df             	mov    rdi,rbx
    1935fbe6:	be 05 00 00 00       	mov    esi,0x5
    1935fbeb:	ba 03 00 00 00       	mov    edx,0x3
    1935fbf0:	b9 01 00 00 00       	mov    ecx,0x1
    1935fbf5:	41 b8 22 00 00 00    	mov    r8d,0x22
    1935fbfb:	e8 f0 65 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fc00:	48 89 df             	mov    rdi,rbx
    1935fc03:	be 05 00 00 00       	mov    esi,0x5
    1935fc08:	ba 04 00 00 00       	mov    edx,0x4
    1935fc0d:	31 c9                	xor    ecx,ecx
    1935fc0f:	41 b8 11 00 00 00    	mov    r8d,0x11
    1935fc15:	e8 d6 65 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fc1a:	48 89 df             	mov    rdi,rbx
    1935fc1d:	be 05 00 00 00       	mov    esi,0x5
    1935fc22:	ba 04 00 00 00       	mov    edx,0x4
    1935fc27:	b9 01 00 00 00       	mov    ecx,0x1
    1935fc2c:	41 b8 12 00 00 00    	mov    r8d,0x12
    1935fc32:	e8 b9 65 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fc37:	48 89 df             	mov    rdi,rbx
    1935fc3a:	be 02 00 00 00       	mov    esi,0x2
    1935fc3f:	31 d2                	xor    edx,edx
    1935fc41:	31 c9                	xor    ecx,ecx
    1935fc43:	41 b8 2c 00 00 00    	mov    r8d,0x2c
    1935fc49:	e8 a2 65 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fc4e:	48 89 df             	mov    rdi,rbx
    1935fc51:	be 02 00 00 00       	mov    esi,0x2
    1935fc56:	31 d2                	xor    edx,edx
    1935fc58:	b9 01 00 00 00       	mov    ecx,0x1
    1935fc5d:	41 b8 26 00 00 00    	mov    r8d,0x26
    1935fc63:	e8 88 65 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fc68:	48 89 df             	mov    rdi,rbx
    1935fc6b:	be 03 00 00 00       	mov    esi,0x3
    1935fc70:	31 d2                	xor    edx,edx
    1935fc72:	31 c9                	xor    ecx,ecx
    1935fc74:	41 b8 0c 00 00 00    	mov    r8d,0xc
    1935fc7a:	e8 71 65 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fc7f:	48 89 df             	mov    rdi,rbx
    1935fc82:	be 03 00 00 00       	mov    esi,0x3
    1935fc87:	31 d2                	xor    edx,edx
    1935fc89:	b9 01 00 00 00       	mov    ecx,0x1
    1935fc8e:	41 b8 0c 00 00 00    	mov    r8d,0xc
    1935fc94:	e8 57 65 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fc99:	48 89 df             	mov    rdi,rbx
    1935fc9c:	be 04 00 00 00       	mov    esi,0x4
    1935fca1:	31 d2                	xor    edx,edx
    1935fca3:	31 c9                	xor    ecx,ecx
    1935fca5:	41 b8 10 00 00 00    	mov    r8d,0x10
    1935fcab:	e8 40 65 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fcb0:	48 89 df             	mov    rdi,rbx
    1935fcb3:	be 04 00 00 00       	mov    esi,0x4
    1935fcb8:	31 d2                	xor    edx,edx
    1935fcba:	b9 01 00 00 00       	mov    ecx,0x1
    1935fcbf:	41 b8 14 00 00 00    	mov    r8d,0x14
    1935fcc5:	e8 26 65 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fcca:	48 89 df             	mov    rdi,rbx
    1935fccd:	be 02 00 00 00       	mov    esi,0x2
    1935fcd2:	ba 01 00 00 00       	mov    edx,0x1
    1935fcd7:	31 c9                	xor    ecx,ecx
    1935fcd9:	41 b8 2c 00 00 00    	mov    r8d,0x2c
    1935fcdf:	e8 0c 65 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fce4:	48 89 df             	mov    rdi,rbx
    1935fce7:	be 02 00 00 00       	mov    esi,0x2
    1935fcec:	ba 01 00 00 00       	mov    edx,0x1
    1935fcf1:	b9 01 00 00 00       	mov    ecx,0x1
    1935fcf6:	41 b8 26 00 00 00    	mov    r8d,0x26
    1935fcfc:	e8 ef 64 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fd01:	48 89 df             	mov    rdi,rbx
    1935fd04:	be 03 00 00 00       	mov    esi,0x3
    1935fd09:	ba 01 00 00 00       	mov    edx,0x1
    1935fd0e:	31 c9                	xor    ecx,ecx
    1935fd10:	41 b8 0c 00 00 00    	mov    r8d,0xc
    1935fd16:	e8 d5 64 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fd1b:	48 89 df             	mov    rdi,rbx
    1935fd1e:	be 03 00 00 00       	mov    esi,0x3
    1935fd23:	ba 01 00 00 00       	mov    edx,0x1
    1935fd28:	b9 01 00 00 00       	mov    ecx,0x1
    1935fd2d:	41 b8 0c 00 00 00    	mov    r8d,0xc
    1935fd33:	e8 b8 64 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fd38:	48 89 df             	mov    rdi,rbx
    1935fd3b:	be 04 00 00 00       	mov    esi,0x4
    1935fd40:	ba 01 00 00 00       	mov    edx,0x1
    1935fd45:	31 c9                	xor    ecx,ecx
    1935fd47:	41 b8 10 00 00 00    	mov    r8d,0x10
    1935fd4d:	e8 9e 64 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fd52:	48 89 df             	mov    rdi,rbx
    1935fd55:	be 04 00 00 00       	mov    esi,0x4
    1935fd5a:	ba 01 00 00 00       	mov    edx,0x1
    1935fd5f:	b9 01 00 00 00       	mov    ecx,0x1
    1935fd64:	41 b8 14 00 00 00    	mov    r8d,0x14
    1935fd6a:	e8 81 64 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fd6f:	48 89 df             	mov    rdi,rbx
    1935fd72:	be 02 00 00 00       	mov    esi,0x2
    1935fd77:	ba 05 00 00 00       	mov    edx,0x5
    1935fd7c:	31 c9                	xor    ecx,ecx
    1935fd7e:	41 b8 28 00 00 00    	mov    r8d,0x28
    1935fd84:	e8 67 64 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fd89:	48 89 df             	mov    rdi,rbx
    1935fd8c:	be 02 00 00 00       	mov    esi,0x2
    1935fd91:	ba 05 00 00 00       	mov    edx,0x5
    1935fd96:	b9 01 00 00 00       	mov    ecx,0x1
    1935fd9b:	41 b8 1d 00 00 00    	mov    r8d,0x1d
    1935fda1:	e8 4a 64 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fda6:	48 89 df             	mov    rdi,rbx
    1935fda9:	be 03 00 00 00       	mov    esi,0x3
    1935fdae:	ba 05 00 00 00       	mov    edx,0x5
    1935fdb3:	31 c9                	xor    ecx,ecx
    1935fdb5:	41 b8 08 00 00 00    	mov    r8d,0x8
    1935fdbb:	e8 30 64 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fdc0:	48 89 df             	mov    rdi,rbx
    1935fdc3:	be 03 00 00 00       	mov    esi,0x3
    1935fdc8:	ba 05 00 00 00       	mov    edx,0x5
    1935fdcd:	b9 01 00 00 00       	mov    ecx,0x1
    1935fdd2:	41 b8 03 00 00 00    	mov    r8d,0x3
    1935fdd8:	e8 13 64 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fddd:	48 89 df             	mov    rdi,rbx
    1935fde0:	be 04 00 00 00       	mov    esi,0x4
    1935fde5:	ba 05 00 00 00       	mov    edx,0x5
    1935fdea:	31 c9                	xor    ecx,ecx
    1935fdec:	41 b8 04 00 00 00    	mov    r8d,0x4
    1935fdf2:	e8 f9 63 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fdf7:	48 89 df             	mov    rdi,rbx
    1935fdfa:	be 04 00 00 00       	mov    esi,0x4
    1935fdff:	ba 05 00 00 00       	mov    edx,0x5
    1935fe04:	b9 01 00 00 00       	mov    ecx,0x1
    1935fe09:	41 b8 03 00 00 00    	mov    r8d,0x3
    1935fe0f:	e8 dc 63 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fe14:	48 89 df             	mov    rdi,rbx
    1935fe17:	be 03 00 00 00       	mov    esi,0x3
    1935fe1c:	ba 02 00 00 00       	mov    edx,0x2
    1935fe21:	31 c9                	xor    ecx,ecx
    1935fe23:	41 b8 03 00 00 00    	mov    r8d,0x3
    1935fe29:	e8 c2 63 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fe2e:	48 89 df             	mov    rdi,rbx
    1935fe31:	be 03 00 00 00       	mov    esi,0x3
    1935fe36:	ba 02 00 00 00       	mov    edx,0x2
    1935fe3b:	b9 01 00 00 00       	mov    ecx,0x1
    1935fe40:	41 b8 09 00 00 00    	mov    r8d,0x9
    1935fe46:	e8 a5 63 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fe4b:	48 89 df             	mov    rdi,rbx
    1935fe4e:	be 03 00 00 00       	mov    esi,0x3
    1935fe53:	ba 04 00 00 00       	mov    edx,0x4
    1935fe58:	31 c9                	xor    ecx,ecx
    1935fe5a:	41 b8 07 00 00 00    	mov    r8d,0x7
    1935fe60:	e8 8b 63 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fe65:	48 89 df             	mov    rdi,rbx
    1935fe68:	be 03 00 00 00       	mov    esi,0x3
    1935fe6d:	ba 04 00 00 00       	mov    edx,0x4
    1935fe72:	b9 01 00 00 00       	mov    ecx,0x1
    1935fe77:	41 b8 03 00 00 00    	mov    r8d,0x3
    1935fe7d:	e8 6e 63 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fe82:	48 89 df             	mov    rdi,rbx
    1935fe85:	be 04 00 00 00       	mov    esi,0x4
    1935fe8a:	ba 02 00 00 00       	mov    edx,0x2
    1935fe8f:	31 c9                	xor    ecx,ecx
    1935fe91:	41 b8 0f 00 00 00    	mov    r8d,0xf
    1935fe97:	e8 54 63 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fe9c:	48 89 df             	mov    rdi,rbx
    1935fe9f:	be 04 00 00 00       	mov    esi,0x4
    1935fea4:	ba 02 00 00 00       	mov    edx,0x2
    1935fea9:	b9 01 00 00 00       	mov    ecx,0x1
    1935feae:	41 b8 19 00 00 00    	mov    r8d,0x19
    1935feb4:	e8 37 63 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935feb9:	48 89 df             	mov    rdi,rbx
    1935febc:	be 04 00 00 00       	mov    esi,0x4
    1935fec1:	ba 03 00 00 00       	mov    edx,0x3
    1935fec6:	31 c9                	xor    ecx,ecx
    1935fec8:	41 b8 0f 00 00 00    	mov    r8d,0xf
    1935fece:	e8 1d 63 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fed3:	48 89 df             	mov    rdi,rbx
    1935fed6:	be 04 00 00 00       	mov    esi,0x4
    1935fedb:	ba 03 00 00 00       	mov    edx,0x3
    1935fee0:	b9 01 00 00 00       	mov    ecx,0x1
    1935fee5:	41 b8 13 00 00 00    	mov    r8d,0x13
    1935feeb:	e8 00 63 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935fef0:	48 89 df             	mov    rdi,rbx
    1935fef3:	be 02 00 00 00       	mov    esi,0x2
    1935fef8:	ba 03 00 00 00       	mov    edx,0x3
    1935fefd:	31 c9                	xor    ecx,ecx
    1935feff:	41 b8 23 00 00 00    	mov    r8d,0x23
    1935ff05:	e8 e6 62 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935ff0a:	48 89 df             	mov    rdi,rbx
    1935ff0d:	be 02 00 00 00       	mov    esi,0x2
    1935ff12:	ba 03 00 00 00       	mov    edx,0x3
    1935ff17:	b9 01 00 00 00       	mov    ecx,0x1
    1935ff1c:	41 b8 1d 00 00 00    	mov    r8d,0x1d
    1935ff22:	e8 c9 62 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935ff27:	48 89 df             	mov    rdi,rbx
    1935ff2a:	be 02 00 00 00       	mov    esi,0x2
    1935ff2f:	ba 04 00 00 00       	mov    edx,0x4
    1935ff34:	31 c9                	xor    ecx,ecx
    1935ff36:	41 b8 27 00 00 00    	mov    r8d,0x27
    1935ff3c:	e8 af 62 fe ff       	call   193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935ff41:	48 89 df             	mov    rdi,rbx
    1935ff44:	be 02 00 00 00       	mov    esi,0x2
    1935ff49:	ba 04 00 00 00       	mov    edx,0x4
    1935ff4e:	b9 01 00 00 00       	mov    ecx,0x1
    1935ff53:	41 b8 1d 00 00 00    	mov    r8d,0x1d
    1935ff59:	48 83 c4 08          	add    rsp,0x8
    1935ff5d:	5b                   	pop    rbx
    1935ff5e:	41 5e                	pop    r14
    1935ff60:	41 5f                	pop    r15
    1935ff62:	5d                   	pop    rbp
    1935ff63:	e9 88 62 fe ff       	jmp    193461f0 <_ZN3xla9jellyfish23XluConflictPenaltyTable28SetXluConflictPenaltyBetweenENS1_12XluInstrTypeES2_ji>
    1935ff68:	48 8d 3d 11 7f 7e 05 	lea    rdi,[rip+0x57e7f11]        # 1eb47e80 <_ZGVZN3xla9ghostlite12_GLOBAL__N_124GetSharedMxuLatencyTableEvE18mxu_latency_shared+0x10>
    1935ff6f:	c5 f8 77             	vzeroupper
    1935ff72:	e8 84 0f 72 04       	call   1da80efb <__cxa_guard_acquire>
    1935ff77:	85 c0                	test   eax,eax
    1935ff79:	0f 84 d1 f9 ff ff    	je     1935f950 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x310>
    1935ff7f:	bf 30 00 00 00       	mov    edi,0x30
    1935ff84:	e8 f7 f1 4e 04       	call   1d84f180 <_Znwm>
    1935ff89:	48 89 c3             	mov    rbx,rax
    1935ff8c:	48 89 c7             	mov    rdi,rax
    1935ff8f:	e8 bc a4 01 00       	call   1937a450 <_ZNK3xla10pufferfish30PufferfishBarnaCorePerformance16GetResourceUsageENS1_11InstructionENS1_8ResourceE+0x30>
    1935ff94:	48 89 1d dd 7e 7e 05 	mov    QWORD PTR [rip+0x57e7edd],rbx        # 1eb47e78 <_ZGVZN3xla9ghostlite12_GLOBAL__N_124GetSharedMxuLatencyTableEvE18mxu_latency_shared+0x8>
    1935ff9b:	48 8d 3d de 7e 7e 05 	lea    rdi,[rip+0x57e7ede]        # 1eb47e80 <_ZGVZN3xla9ghostlite12_GLOBAL__N_124GetSharedMxuLatencyTableEvE18mxu_latency_shared+0x10>
    1935ffa2:	e8 6d 10 72 04       	call   1da81014 <__cxa_guard_release>
    1935ffa7:	e9 a4 f9 ff ff       	jmp    1935f950 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x310>
    1935ffac:	48 8d 3d dd 7e 7e 05 	lea    rdi,[rip+0x57e7edd]        # 1eb47e90 <_ZGVZN3xla9ghostlite12_GLOBAL__N_124GetSharedMxuLatencyTableEvE18mxu_latency_shared+0x20>
    1935ffb3:	c5 f8 77             	vzeroupper
    1935ffb6:	e8 40 0f 72 04       	call   1da80efb <__cxa_guard_acquire>
    1935ffbb:	85 c0                	test   eax,eax
    1935ffbd:	0f 84 ae f9 ff ff    	je     1935f971 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x331>
    1935ffc3:	bf 50 00 00 00       	mov    edi,0x50
    1935ffc8:	e8 b3 f1 4e 04       	call   1d84f180 <_Znwm>
    1935ffcd:	49 89 c7             	mov    r15,rax
    1935ffd0:	48 89 c7             	mov    rdi,rax
    1935ffd3:	e8 d8 15 00 00       	call   193615b0 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x1f70>
    1935ffd8:	4c 89 3d a9 7e 7e 05 	mov    QWORD PTR [rip+0x57e7ea9],r15        # 1eb47e88 <_ZGVZN3xla9ghostlite12_GLOBAL__N_124GetSharedMxuLatencyTableEvE18mxu_latency_shared+0x18>
    1935ffdf:	48 8d 3d aa 7e 7e 05 	lea    rdi,[rip+0x57e7eaa]        # 1eb47e90 <_ZGVZN3xla9ghostlite12_GLOBAL__N_124GetSharedMxuLatencyTableEvE18mxu_latency_shared+0x20>
    1935ffe6:	e8 29 10 72 04       	call   1da81014 <__cxa_guard_release>
    1935ffeb:	e9 81 f9 ff ff       	jmp    1935f971 <_ZN4absl18container_internal12raw_hash_setINS0_17FlatHashMapPolicyIN3xla9jellyfish14MatmulModifierENSt3__u5arrayIiLm11EEEEEJEE10find_largeIS5_EENSA_8iteratorERKS5_+0x331>
    1935fff0:	b8 07 00 00 00       	mov    eax,0x7
    1935fff5:	c3                   	ret
    1935fff6:	cc                   	int3
    1935fff7:	cc                   	int3
    1935fff8:	cc                   	int3
    1935fff9:	cc                   	int3
    1935fffa:	cc                   	int3
    1935fffb:	cc                   	int3
    1935fffc:	cc                   	int3
    1935fffd:	cc                   	int3
    1935fffe:	cc                   	int3
    1935ffff:	cc                   	int3
