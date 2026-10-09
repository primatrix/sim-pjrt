
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

0000000019e69790 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE>:
    19e69790:	55                   	push   rbp
    19e69791:	48 89 e5             	mov    rbp,rsp
    19e69794:	53                   	push   rbx
    19e69795:	50                   	push   rax
    19e69796:	48 89 f8             	mov    rax,rdi
    19e69799:	89 f1                	mov    ecx,esi
    19e6979b:	48 8d 15 b6 9f d5 ef 	lea    rdx,[rip+0xffffffffefd59fb6]        # 9bc3758 <_ZTSN3xla9jellyfish17TargetEnvironmentE+0x2d0>
    19e697a2:	48 63 0c 8a          	movsxd rcx,DWORD PTR [rdx+rcx*4]
    19e697a6:	48 01 d1             	add    rcx,rdx
    19e697a9:	ff e1                	jmp    rcx
    19e697ab:	c5 f8 10 05 d8 98 0d 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffee0d98d8]        # 7f4308b <local_itoa.digits+0x216d26>
    19e697b2:	ee 
    19e697b3:	c5 f8 11 00          	vmovups XMMWORD PTR [rax],xmm0
    19e697b7:	48 b9 4d 59 54 6f 42 	movabs rcx,0x363166426f54594d
    19e697be:	66 31 36 
    19e697c1:	e9 1a 02 00 00       	jmp    19e699e0 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x250>
    19e697c6:	c6 40 17 12          	mov    BYTE PTR [rax+0x17],0x12
    19e697ca:	c5 f8 10 05 72 41 a5 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffeda54172]        # 78bd944 <_ZZN7strings16HumanReadableNum14DoubleToStringEdE5units+0x223f57>
    19e697d1:	ed 
    19e697d2:	c5 f8 11 00          	vmovups XMMWORD PTR [rax],xmm0
    19e697d6:	66 c7 40 10 46 4e    	mov    WORD PTR [rax+0x10],0x4e46
    19e697dc:	e9 1f 03 00 00       	jmp    19e69b00 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x370>
    19e697e1:	c6 40 17 0e          	mov    BYTE PTR [rax+0x17],0xe
    19e697e5:	48 b9 43 6f 6d 70 72 	movabs rcx,0x73736572706d6f43
    19e697ec:	65 73 73 
    19e697ef:	48 89 08             	mov    QWORD PTR [rax],rcx
    19e697f2:	48 b9 73 73 65 64 48 	movabs rcx,0x3631664864657373
    19e697f9:	66 31 36 
    19e697fc:	e9 69 02 00 00       	jmp    19e69a6a <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x2da>
    19e69801:	c6 40 17 0c          	mov    BYTE PTR [rax+0x17],0xc
    19e69805:	48 b9 43 6f 6d 70 72 	movabs rcx,0x73736572706d6f43
    19e6980c:	65 73 73 
    19e6980f:	48 89 08             	mov    QWORD PTR [rax],rcx
    19e69812:	c7 40 08 65 64 42 34 	mov    DWORD PTR [rax+0x8],0x34426465
    19e69819:	e9 eb 01 00 00       	jmp    19e69a09 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x279>
    19e6981e:	bf 20 00 00 00       	mov    edi,0x20
    19e69823:	48 89 c3             	mov    rbx,rax
    19e69826:	e8 55 59 9e 03       	call   1d84f180 <_Znwm>
    19e6982b:	48 89 c1             	mov    rcx,rax
    19e6982e:	48 89 d8             	mov    rax,rbx
    19e69831:	48 89 0b             	mov    QWORD PTR [rbx],rcx
    19e69834:	48 c7 43 08 19 00 00 	mov    QWORD PTR [rbx+0x8],0x19
    19e6983b:	00 
    19e6983c:	48 ba 19 00 00 00 00 	movabs rdx,0x8000000000000019
    19e69843:	00 00 80 
    19e69846:	48 83 c2 07          	add    rdx,0x7
    19e6984a:	48 89 53 10          	mov    QWORD PTR [rbx+0x10],rdx
    19e6984e:	c5 f8 10 05 d5 e6 8a 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffee8ae6d5]        # 8717f2b <nilstr+0x22c47>
    19e69855:	ee 
    19e69856:	c5 f8 11 01          	vmovups XMMWORD PTR [rcx],xmm0
    19e6985a:	c5 f8 10 05 d2 e6 8a 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffee8ae6d2]        # 8717f34 <nilstr+0x22c50>
    19e69861:	ee 
    19e69862:	c5 f8 11 41 09       	vmovups XMMWORD PTR [rcx+0x9],xmm0
    19e69867:	c6 41 19 00          	mov    BYTE PTR [rcx+0x19],0x0
    19e6986b:	48 83 c4 08          	add    rsp,0x8
    19e6986f:	5b                   	pop    rbx
    19e69870:	5d                   	pop    rbp
    19e69871:	c3                   	ret
    19e69872:	c6 40 17 0d          	mov    BYTE PTR [rax+0x17],0xd
    19e69876:	48 b9 49 6e 74 65 72 	movabs rcx,0x61656c7265746e49
    19e6987d:	6c 65 61 
    19e69880:	48 89 08             	mov    QWORD PTR [rax],rcx
    19e69883:	48 b9 6c 65 61 76 65 	movabs rcx,0x384264657661656c
    19e6988a:	64 42 38 
    19e6988d:	e9 ae 01 00 00       	jmp    19e69a40 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x2b0>
    19e69892:	c6 40 17 0d          	mov    BYTE PTR [rax+0x17],0xd
    19e69896:	48 b9 43 6f 6d 70 72 	movabs rcx,0x73736572706d6f43
    19e6989d:	65 73 73 
    19e698a0:	48 89 08             	mov    QWORD PTR [rax],rcx
    19e698a3:	48 b9 65 73 73 65 64 	movabs rcx,0x3631426465737365
    19e698aa:	42 31 36 
    19e698ad:	e9 8e 01 00 00       	jmp    19e69a40 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x2b0>
    19e698b2:	bf 19 00 00 00       	mov    edi,0x19
    19e698b7:	48 89 c3             	mov    rbx,rax
    19e698ba:	e8 c1 58 9e 03       	call   1d84f180 <_Znwm>
    19e698bf:	48 89 c1             	mov    rcx,rax
    19e698c2:	48 89 d8             	mov    rax,rbx
    19e698c5:	48 89 0b             	mov    QWORD PTR [rbx],rcx
    19e698c8:	48 c7 43 08 17 00 00 	mov    QWORD PTR [rbx+0x8],0x17
    19e698cf:	00 
    19e698d0:	48 ba 19 00 00 00 00 	movabs rdx,0x8000000000000019
    19e698d7:	00 00 80 
    19e698da:	c5 f8 10 05 d8 98 0d 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffee0d98d8]        # 7f431ba <local_itoa.digits+0x216e55>
    19e698e1:	ee 
    19e698e2:	c5 f8 11 01          	vmovups XMMWORD PTR [rcx],xmm0
    19e698e6:	48 89 53 10          	mov    QWORD PTR [rbx+0x10],rdx
    19e698ea:	48 ba 4d 32 54 6f 42 	movabs rdx,0x363166426f54324d
    19e698f1:	66 31 36 
    19e698f4:	e9 76 02 00 00       	jmp    19e69b6f <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x3df>
    19e698f9:	c6 40 17 14          	mov    BYTE PTR [rax+0x17],0x14
    19e698fd:	c5 f8 10 05 ce 43 f6 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffedf643ce]        # 7dcdcd3 <local_itoa.digits+0xa196e>
    19e69904:	ed 
    19e69905:	c5 f8 11 00          	vmovups XMMWORD PTR [rax],xmm0
    19e69909:	c7 40 10 54 6f 42 38 	mov    DWORD PTR [rax+0x10],0x38426f54
    19e69910:	e9 0d 02 00 00       	jmp    19e69b22 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x392>
    19e69915:	c6 40 17 0c          	mov    BYTE PTR [rax+0x17],0xc
    19e69919:	48 b9 43 6f 6d 70 72 	movabs rcx,0x73736572706d6f43
    19e69920:	65 73 73 
    19e69923:	48 89 08             	mov    QWORD PTR [rax],rcx
    19e69926:	c7 40 08 65 64 42 38 	mov    DWORD PTR [rax+0x8],0x38426465
    19e6992d:	e9 d7 00 00 00       	jmp    19e69a09 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x279>
    19e69932:	c6 40 17 0f          	mov    BYTE PTR [rax+0x17],0xf
    19e69936:	48 b9 49 6e 74 65 72 	movabs rcx,0x61656c7265746e49
    19e6993d:	6c 65 61 
    19e69940:	48 89 08             	mov    QWORD PTR [rax],rcx
    19e69943:	48 b9 61 76 65 64 42 	movabs rcx,0x3631664264657661
    19e6994a:	66 31 36 
    19e6994d:	48 89 48 07          	mov    QWORD PTR [rax+0x7],rcx
    19e69951:	c6 40 0f 00          	mov    BYTE PTR [rax+0xf],0x0
    19e69955:	48 83 c4 08          	add    rsp,0x8
    19e69959:	5b                   	pop    rbx
    19e6995a:	5d                   	pop    rbp
    19e6995b:	c3                   	ret
    19e6995c:	c6 40 17 14          	mov    BYTE PTR [rax+0x17],0x14
    19e69960:	c5 f8 10 05 f7 91 cc 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffeccc91f7]        # 6b32b5f <anon.f8f240e7663de982f5665866aa97a008.1.llvm.5049317257163802047+0x5e612>
    19e69967:	ec 
    19e69968:	c5 f8 11 00          	vmovups XMMWORD PTR [rax],xmm0
    19e6996c:	c7 40 10 72 6d 61 74 	mov    DWORD PTR [rax+0x10],0x74616d72
    19e69973:	e9 aa 01 00 00       	jmp    19e69b22 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x392>
    19e69978:	c6 40 17 0e          	mov    BYTE PTR [rax+0x17],0xe
    19e6997c:	48 b9 43 6f 6d 70 72 	movabs rcx,0x73736572706d6f43
    19e69983:	65 73 73 
    19e69986:	48 89 08             	mov    QWORD PTR [rax],rcx
    19e69989:	48 b9 73 73 65 64 42 	movabs rcx,0x3631664264657373
    19e69990:	66 31 36 
    19e69993:	e9 d2 00 00 00       	jmp    19e69a6a <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x2da>
    19e69998:	c5 f8 10 05 32 98 0d 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffee0d9832]        # 7f431d2 <local_itoa.digits+0x216e6d>
    19e6999f:	ee 
    19e699a0:	c5 f8 11 00          	vmovups XMMWORD PTR [rax],xmm0
    19e699a4:	48 b9 4d 32 54 6f 42 	movabs rcx,0x363166426f54324d
    19e699ab:	66 31 36 
    19e699ae:	eb 30                	jmp    19e699e0 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x250>
    19e699b0:	c6 40 17 0c          	mov    BYTE PTR [rax+0x17],0xc
    19e699b4:	48 b9 43 6f 6d 70 72 	movabs rcx,0x73736572706d6f43
    19e699bb:	65 73 73 
    19e699be:	48 89 08             	mov    QWORD PTR [rax],rcx
    19e699c1:	c7 40 08 65 64 42 32 	mov    DWORD PTR [rax+0x8],0x32426465
    19e699c8:	eb 3f                	jmp    19e69a09 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x279>
    19e699ca:	c5 f8 10 05 73 e5 8a 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffee8ae573]        # 8717f45 <nilstr+0x22c61>
    19e699d1:	ee 
    19e699d2:	c5 f8 11 00          	vmovups XMMWORD PTR [rax],xmm0
    19e699d6:	48 b9 4d 32 20 28 62 	movabs rcx,0x293866622820324d
    19e699dd:	66 38 29 
    19e699e0:	48 89 48 0e          	mov    QWORD PTR [rax+0xe],rcx
    19e699e4:	66 c7 40 16 00 16    	mov    WORD PTR [rax+0x16],0x1600
    19e699ea:	48 83 c4 08          	add    rsp,0x8
    19e699ee:	5b                   	pop    rbx
    19e699ef:	5d                   	pop    rbp
    19e699f0:	c3                   	ret
    19e699f1:	c6 40 17 0c          	mov    BYTE PTR [rax+0x17],0xc
    19e699f5:	48 b9 43 6f 6d 70 72 	movabs rcx,0x73736572706d6f43
    19e699fc:	65 73 73 
    19e699ff:	48 89 08             	mov    QWORD PTR [rax],rcx
    19e69a02:	c7 40 08 65 64 42 31 	mov    DWORD PTR [rax+0x8],0x31426465
    19e69a09:	c6 40 0c 00          	mov    BYTE PTR [rax+0xc],0x0
    19e69a0d:	48 83 c4 08          	add    rsp,0x8
    19e69a11:	5b                   	pop    rbx
    19e69a12:	5d                   	pop    rbp
    19e69a13:	c3                   	ret
    19e69a14:	c6 40 17 12          	mov    BYTE PTR [rax+0x17],0x12
    19e69a18:	c5 f8 10 05 ed 96 0d 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffee0d96ed]        # 7f4310d <local_itoa.digits+0x216da8>
    19e69a1f:	ee 
    19e69a20:	e9 d1 00 00 00       	jmp    19e69af6 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x366>
    19e69a25:	c6 40 17 0d          	mov    BYTE PTR [rax+0x17],0xd
    19e69a29:	48 b9 49 6e 74 65 72 	movabs rcx,0x61656c7265746e49
    19e69a30:	6c 65 61 
    19e69a33:	48 89 08             	mov    QWORD PTR [rax],rcx
    19e69a36:	48 b9 6c 65 61 76 65 	movabs rcx,0x344264657661656c
    19e69a3d:	64 42 34 
    19e69a40:	48 89 48 05          	mov    QWORD PTR [rax+0x5],rcx
    19e69a44:	c6 40 0d 00          	mov    BYTE PTR [rax+0xd],0x0
    19e69a48:	48 83 c4 08          	add    rsp,0x8
    19e69a4c:	5b                   	pop    rbx
    19e69a4d:	5d                   	pop    rbp
    19e69a4e:	c3                   	ret
    19e69a4f:	c6 40 17 0e          	mov    BYTE PTR [rax+0x17],0xe
    19e69a53:	48 b9 49 6e 74 65 72 	movabs rcx,0x61656c7265746e49
    19e69a5a:	6c 65 61 
    19e69a5d:	48 89 08             	mov    QWORD PTR [rax],rcx
    19e69a60:	48 b9 65 61 76 65 64 	movabs rcx,0x3631426465766165
    19e69a67:	42 31 36 
    19e69a6a:	48 89 48 06          	mov    QWORD PTR [rax+0x6],rcx
    19e69a6e:	c6 40 0e 00          	mov    BYTE PTR [rax+0xe],0x0
    19e69a72:	48 83 c4 08          	add    rsp,0x8
    19e69a76:	5b                   	pop    rbx
    19e69a77:	5d                   	pop    rbp
    19e69a78:	c3                   	ret
    19e69a79:	c6 40 17 12          	mov    BYTE PTR [rax+0x17],0x12
    19e69a7d:	c5 f8 10 05 bf 96 0d 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffee0d96bf]        # 7f43144 <local_itoa.digits+0x216ddf>
    19e69a84:	ee 
    19e69a85:	eb 6f                	jmp    19e69af6 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x366>
    19e69a87:	bf 20 00 00 00       	mov    edi,0x20
    19e69a8c:	48 89 c3             	mov    rbx,rax
    19e69a8f:	e8 ec 56 9e 03       	call   1d84f180 <_Znwm>
    19e69a94:	48 89 c1             	mov    rcx,rax
    19e69a97:	48 89 d8             	mov    rax,rbx
    19e69a9a:	48 89 0b             	mov    QWORD PTR [rbx],rcx
    19e69a9d:	48 c7 43 08 18 00 00 	mov    QWORD PTR [rbx+0x8],0x18
    19e69aa4:	00 
    19e69aa5:	48 ba 19 00 00 00 00 	movabs rdx,0x8000000000000019
    19e69aac:	00 00 80 
    19e69aaf:	48 83 c2 07          	add    rdx,0x7
    19e69ab3:	c5 f8 10 05 b7 95 0d 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffee0d95b7]        # 7f43072 <local_itoa.digits+0x216d0d>
    19e69aba:	ee 
    19e69abb:	c5 f8 11 01          	vmovups XMMWORD PTR [rcx],xmm0
    19e69abf:	48 89 53 10          	mov    QWORD PTR [rbx+0x10],rdx
    19e69ac3:	48 ba 46 6e 54 6f 42 	movabs rdx,0x363166426f546e46
    19e69aca:	66 31 36 
    19e69acd:	48 89 51 10          	mov    QWORD PTR [rcx+0x10],rdx
    19e69ad1:	c6 41 18 00          	mov    BYTE PTR [rcx+0x18],0x0
    19e69ad5:	48 83 c4 08          	add    rsp,0x8
    19e69ad9:	5b                   	pop    rbx
    19e69ada:	5d                   	pop    rbp
    19e69adb:	c3                   	ret
    19e69adc:	c6 40 17 12          	mov    BYTE PTR [rax+0x17],0x12
    19e69ae0:	c5 f8 10 05 93 96 0d 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffee0d9693]        # 7f4317b <local_itoa.digits+0x216e16>
    19e69ae7:	ee 
    19e69ae8:	eb 0c                	jmp    19e69af6 <_ZN3xla9jellyfish17VpackFormatStringENS0_11VpackFormatE+0x366>
    19e69aea:	c6 40 17 12          	mov    BYTE PTR [rax+0x17],0x12
    19e69aee:	c5 f8 10 05 d0 95 0d 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffee0d95d0]        # 7f430c6 <local_itoa.digits+0x216d61>
    19e69af5:	ee 
    19e69af6:	c5 f8 11 00          	vmovups XMMWORD PTR [rax],xmm0
    19e69afa:	66 c7 40 10 31 36    	mov    WORD PTR [rax+0x10],0x3631
    19e69b00:	c6 40 12 00          	mov    BYTE PTR [rax+0x12],0x0
    19e69b04:	48 83 c4 08          	add    rsp,0x8
    19e69b08:	5b                   	pop    rbx
    19e69b09:	5d                   	pop    rbp
    19e69b0a:	c3                   	ret
    19e69b0b:	c6 40 17 14          	mov    BYTE PTR [rax+0x17],0x14
    19e69b0f:	c5 f8 10 05 bd c8 22 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffee22c8bd]        # 80963d4 <local_itoa.digits+0x36a06f>
    19e69b16:	ee 
    19e69b17:	c5 f8 11 00          	vmovups XMMWORD PTR [rax],xmm0
    19e69b1b:	c7 40 10 54 6f 42 34 	mov    DWORD PTR [rax+0x10],0x34426f54
    19e69b22:	c6 40 14 00          	mov    BYTE PTR [rax+0x14],0x0
    19e69b26:	48 83 c4 08          	add    rsp,0x8
    19e69b2a:	5b                   	pop    rbx
    19e69b2b:	5d                   	pop    rbp
    19e69b2c:	c3                   	ret
    19e69b2d:	bf 19 00 00 00       	mov    edi,0x19
    19e69b32:	48 89 c3             	mov    rbx,rax
    19e69b35:	e8 46 56 9e 03       	call   1d84f180 <_Znwm>
    19e69b3a:	48 89 c1             	mov    rcx,rax
    19e69b3d:	48 89 d8             	mov    rax,rbx
    19e69b40:	48 89 0b             	mov    QWORD PTR [rbx],rcx
    19e69b43:	48 c7 43 08 17 00 00 	mov    QWORD PTR [rbx+0x8],0x17
    19e69b4a:	00 
    19e69b4b:	48 ba 19 00 00 00 00 	movabs rdx,0x8000000000000019
    19e69b52:	00 00 80 
    19e69b55:	c5 f8 10 05 31 96 0d 	vmovups xmm0,XMMWORD PTR [rip+0xffffffffee0d9631]        # 7f4318e <local_itoa.digits+0x216e29>
    19e69b5c:	ee 
    19e69b5d:	c5 f8 11 01          	vmovups XMMWORD PTR [rcx],xmm0
    19e69b61:	48 89 53 10          	mov    QWORD PTR [rbx+0x10],rdx
    19e69b65:	48 ba 4d 33 54 6f 42 	movabs rdx,0x363166426f54334d
    19e69b6c:	66 31 36 
    19e69b6f:	48 89 51 0f          	mov    QWORD PTR [rcx+0xf],rdx
    19e69b73:	c6 41 17 00          	mov    BYTE PTR [rcx+0x17],0x0
    19e69b77:	48 83 c4 08          	add    rsp,0x8
    19e69b7b:	5b                   	pop    rbx
    19e69b7c:	5d                   	pop    rbp
    19e69b7d:	c3                   	ret
    19e69b7e:	cc                   	int3
    19e69b7f:	cc                   	int3

0000000019e69b80 <_ZN3xla9jellyfish26VpackFormatSublanesIndicesENS0_11VpackFormatE>:
    19e69b80:	89 f8                	mov    eax,edi
    19e69b82:	48 8d 0d 3b 9c d5 ef 	lea    rcx,[rip+0xffffffffefd59c3b]        # 9bc37c4 <_ZTSN3xla9jellyfish17TargetEnvironmentE+0x33c>
    19e69b89:	8b 04 81             	mov    eax,DWORD PTR [rcx+rax*4]
    19e69b8c:	c3                   	ret
    19e69b8d:	cc                   	int3
    19e69b8e:	cc                   	int3
    19e69b8f:	cc                   	int3

0000000019e69b90 <_ZN3xla9jellyfish19BitDataFormatStringENS0_13BitDataFormatE>:
    19e69b90:	48 89 f8             	mov    rax,rdi
    19e69b93:	83 fe 02             	cmp    esi,0x2
    19e69b96:	74 2e                	je     19e69bc6 <_ZN3xla9jellyfish19BitDataFormatStringENS0_13BitDataFormatE+0x36>
    19e69b98:	83 fe 01             	cmp    esi,0x1
    19e69b9b:	75 52                	jne    19e69bef <_ZN3xla9jellyfish19BitDataFormatStringENS0_13BitDataFormatE+0x5f>
    19e69b9d:	c6 40 17 0e          	mov    BYTE PTR [rax+0x17],0xe
    19e69ba1:	48 b9 43 6f 6d 70 72 	movabs rcx,0x73736572706d6f43
    19e69ba8:	65 73 73 
    19e69bab:	48 89 08             	mov    QWORD PTR [rax],rcx
    19e69bae:	48 b9 73 73 65 64 20 	movabs rcx,0x3631422064657373
    19e69bb5:	42 31 36 
    19e69bb8:	48 89 48 06          	mov    QWORD PTR [rax+0x6],rcx
    19e69bbc:	b9 0e 00 00 00       	mov    ecx,0xe
    19e69bc1:	c6 04 08 00          	mov    BYTE PTR [rax+rcx*1],0x0
    19e69bc5:	c3                   	ret
    19e69bc6:	c6 40 17 0d          	mov    BYTE PTR [rax+0x17],0xd
    19e69bca:	48 b9 43 6f 6d 70 72 	movabs rcx,0x73736572706d6f43
    19e69bd1:	65 73 73 
    19e69bd4:	48 89 08             	mov    QWORD PTR [rax],rcx
    19e69bd7:	48 b9 65 73 73 65 64 	movabs rcx,0x3842206465737365
    19e69bde:	20 42 38 
    19e69be1:	48 89 48 05          	mov    QWORD PTR [rax+0x5],rcx
    19e69be5:	b9 0d 00 00 00       	mov    ecx,0xd
    19e69bea:	c6 04 08 00          	mov    BYTE PTR [rax+rcx*1],0x0
    19e69bee:	c3                   	ret
    19e69bef:	c6 40 17 03          	mov    BYTE PTR [rax+0x17],0x3
    19e69bf3:	66 c7 00 42 33       	mov    WORD PTR [rax],0x3342
    19e69bf8:	c6 40 02 32          	mov    BYTE PTR [rax+0x2],0x32
    19e69bfc:	b9 03 00 00 00       	mov    ecx,0x3
    19e69c01:	c6 04 08 00          	mov    BYTE PTR [rax+rcx*1],0x0
    19e69c05:	c3                   	ret
    19e69c06:	cc                   	int3
    19e69c07:	cc                   	int3
    19e69c08:	cc                   	int3
    19e69c09:	cc                   	int3
    19e69c0a:	cc                   	int3
    19e69c0b:	cc                   	int3
    19e69c0c:	cc                   	int3
    19e69c0d:	cc                   	int3
    19e69c0e:	cc                   	int3
    19e69c0f:	cc                   	int3

0000000019e69c10 <_ZN3xla9jellyfish29VpackcFormatFromPackingFactorEl>:
    19e69c10:	f3 48 0f b8 c7       	popcnt rax,rdi
    19e69c15:	83 f8 01             	cmp    eax,0x1
    19e69c18:	75 1a                	jne    19e69c34 <_ZN3xla9jellyfish29VpackcFormatFromPackingFactorEl+0x24>
    19e69c1a:	f3 48 0f bc c7       	tzcnt  rax,rdi
    19e69c1f:	48 ff c8             	dec    rax
    19e69c22:	48 83 f8 04          	cmp    rax,0x4
    19e69c26:	77 0c                	ja     19e69c34 <_ZN3xla9jellyfish29VpackcFormatFromPackingFactorEl+0x24>
    19e69c28:	48 8d 0d 01 9c d5 ef 	lea    rcx,[rip+0xffffffffefd59c01]        # 9bc3830 <_ZTSN3xla9jellyfish17TargetEnvironmentE+0x3a8>
    19e69c2f:	0f b6 04 08          	movzx  eax,BYTE PTR [rax+rcx*1]
    19e69c33:	c3                   	ret
    19e69c34:	31 c0                	xor    eax,eax
    19e69c36:	c3                   	ret
    19e69c37:	cc                   	int3
    19e69c38:	cc                   	int3
    19e69c39:	cc                   	int3
    19e69c3a:	cc                   	int3
    19e69c3b:	cc                   	int3
    19e69c3c:	cc                   	int3
    19e69c3d:	cc                   	int3
    19e69c3e:	cc                   	int3
    19e69c3f:	cc                   	int3

0000000019e69c40 <_ZN3xla9jellyfishlsERNSt3__u13basic_ostreamIcNS1_11char_traitsIcEEEENS0_13BitDataFormatE>:
    19e69c40:	55                   	push   rbp
    19e69c41:	48 89 e5             	mov    rbp,rsp
    19e69c44:	53                   	push   rbx
    19e69c45:	48 83 ec 18          	sub    rsp,0x18
    19e69c49:	48 89 fb             	mov    rbx,rdi
    19e69c4c:	83 fe 02             	cmp    esi,0x2
    19e69c4f:	74 2c                	je     19e69c7d <_ZN3xla9jellyfishlsERNSt3__u13basic_ostreamIcNS1_11char_traitsIcEEEENS0_13BitDataFormatE+0x3d>
    19e69c51:	83 fe 01             	cmp    esi,0x1
    19e69c54:	75 4e                	jne    19e69ca4 <_ZN3xla9jellyfishlsERNSt3__u13basic_ostreamIcNS1_11char_traitsIcEEEENS0_13BitDataFormatE+0x64>
    19e69c56:	c6 45 f7 0e          	mov    BYTE PTR [rbp-0x9],0xe
    19e69c5a:	48 b8 43 6f 6d 70 72 	movabs rax,0x73736572706d6f43
    19e69c61:	65 73 73 
    19e69c64:	48 89 45 e0          	mov    QWORD PTR [rbp-0x20],rax
    19e69c68:	48 b8 73 73 65 64 20 	movabs rax,0x3631422064657373
    19e69c6f:	42 31 36 
    19e69c72:	48 89 45 e6          	mov    QWORD PTR [rbp-0x1a],rax
    19e69c76:	ba 0e 00 00 00       	mov    edx,0xe
    19e69c7b:	eb 3a                	jmp    19e69cb7 <_ZN3xla9jellyfishlsERNSt3__u13basic_ostreamIcNS1_11char_traitsIcEEEENS0_13BitDataFormatE+0x77>
    19e69c7d:	c6 45 f7 0d          	mov    BYTE PTR [rbp-0x9],0xd
    19e69c81:	48 b8 43 6f 6d 70 72 	movabs rax,0x73736572706d6f43
    19e69c88:	65 73 73 
    19e69c8b:	48 89 45 e0          	mov    QWORD PTR [rbp-0x20],rax
    19e69c8f:	48 b8 65 73 73 65 64 	movabs rax,0x3842206465737365
    19e69c96:	20 42 38 
    19e69c99:	48 89 45 e5          	mov    QWORD PTR [rbp-0x1b],rax
    19e69c9d:	ba 0d 00 00 00       	mov    edx,0xd
    19e69ca2:	eb 13                	jmp    19e69cb7 <_ZN3xla9jellyfishlsERNSt3__u13basic_ostreamIcNS1_11char_traitsIcEEEENS0_13BitDataFormatE+0x77>
    19e69ca4:	c6 45 f7 03          	mov    BYTE PTR [rbp-0x9],0x3
    19e69ca8:	66 c7 45 e0 42 33    	mov    WORD PTR [rbp-0x20],0x3342
    19e69cae:	c6 45 e2 32          	mov    BYTE PTR [rbp-0x1e],0x32
    19e69cb2:	ba 03 00 00 00       	mov    edx,0x3
    19e69cb7:	c6 44 15 e0 00       	mov    BYTE PTR [rbp+rdx*1-0x20],0x0
    19e69cbc:	48 8d 75 e0          	lea    rsi,[rbp-0x20]
    19e69cc0:	48 89 df             	mov    rdi,rbx
    19e69cc3:	e8 88 5a 83 f2       	call   c69f750 <_ZNSt3__u24__put_character_sequenceIcNS_11char_traitsIcEEEERNS_13basic_ostreamIT_T0_EES7_PKS4_m>
    19e69cc8:	80 7d f7 00          	cmp    BYTE PTR [rbp-0x9],0x0
    19e69ccc:	79 17                	jns    19e69ce5 <_ZN3xla9jellyfishlsERNSt3__u13basic_ostreamIcNS1_11char_traitsIcEEEENS0_13BitDataFormatE+0xa5>
    19e69cce:	48 8b 7d e0          	mov    rdi,QWORD PTR [rbp-0x20]
    19e69cd2:	48 be ff ff ff ff ff 	movabs rsi,0x7fffffffffffffff
    19e69cd9:	ff ff 7f 
    19e69cdc:	48 23 75 f0          	and    rsi,QWORD PTR [rbp-0x10]
