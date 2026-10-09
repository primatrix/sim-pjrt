
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

0000000019e68cb0 <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE>:
    19e68cb0:	55                   	push   rbp
    19e68cb1:	48 89 e5             	mov    rbp,rsp
    19e68cb4:	53                   	push   rbx
    19e68cb5:	50                   	push   rax
    19e68cb6:	48 89 fb             	mov    rbx,rdi
    19e68cb9:	89 f0                	mov    eax,esi
    19e68cbb:	48 8d 0d ba a8 d5 ef 	lea    rcx,[rip+0xffffffffefd5a8ba]        # 9bc357c <_ZTSN3xla9jellyfish17TargetEnvironmentE+0xf4>
    19e68cc2:	48 63 04 81          	movsxd rax,DWORD PTR [rcx+rax*4]
    19e68cc6:	48 01 c8             	add    rax,rcx
    19e68cc9:	ff e0                	jmp    rax
    19e68ccb:	48 8d 35 7b 6f 41 ee 	lea    rsi,[rip+0xffffffffee416f7b]        # 827fc4d <local_itoa.digits+0x5538e8>
    19e68cd2:	e9 35 02 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68cd7:	48 8d 35 22 ba db ec 	lea    rsi,[rip+0xffffffffecdbba22]        # 6c24700 <anon.de66683854b989ac240da9b5830f09df.25.llvm.14521404311210802531+0xcd9c7>
    19e68cde:	e9 29 02 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68ce3:	48 8d 35 ab 52 49 ee 	lea    rsi,[rip+0xffffffffee4952ab]        # 82fdf95 <local_itoa.digits+0x5d1c30>
    19e68cea:	e9 1d 02 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68cef:	48 8d 35 df 51 49 ee 	lea    rsi,[rip+0xffffffffee4951df]        # 82fded5 <local_itoa.digits+0x5d1b70>
    19e68cf6:	e9 11 02 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68cfb:	48 8d 35 a2 52 49 ee 	lea    rsi,[rip+0xffffffffee4952a2]        # 82fdfa4 <local_itoa.digits+0x5d1c3f>
    19e68d02:	e9 05 02 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68d07:	48 8d 35 c1 32 5f ee 	lea    rsi,[rip+0xffffffffee5f32c1]        # 845bfcf <local_itoa.digits+0x72fc6a>
    19e68d0e:	e9 f9 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68d13:	48 8d 35 b9 51 49 ee 	lea    rsi,[rip+0xffffffffee4951b9]        # 82fded3 <local_itoa.digits+0x5d1b6e>
    19e68d1a:	e9 ed 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68d1f:	48 8d 35 98 32 5f ee 	lea    rsi,[rip+0xffffffffee5f3298]        # 845bfbe <local_itoa.digits+0x72fc59>
    19e68d26:	e9 e1 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68d2b:	48 8d 35 9b 32 5f ee 	lea    rsi,[rip+0xffffffffee5f329b]        # 845bfcd <local_itoa.digits+0x72fc68>
    19e68d32:	e9 d5 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68d37:	48 8d 35 ab a4 0d ee 	lea    rsi,[rip+0xffffffffee0da4ab]        # 7f431e9 <local_itoa.digits+0x216e84>
    19e68d3e:	e9 c9 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68d43:	48 8d 35 1b 33 5f ee 	lea    rsi,[rip+0xffffffffee5f331b]        # 845c065 <local_itoa.digits+0x72fd00>
    19e68d4a:	e9 bd 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68d4f:	48 8d 35 50 a4 0d ee 	lea    rsi,[rip+0xffffffffee0da450]        # 7f431a6 <local_itoa.digits+0x216e41>
    19e68d56:	e9 b1 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68d5b:	48 8d 35 72 83 2a ee 	lea    rsi,[rip+0xffffffffee2a8372]        # 81110d4 <local_itoa.digits+0x3e4d6f>
    19e68d62:	e9 a5 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68d67:	48 8d 35 39 d2 40 ee 	lea    rsi,[rip+0xffffffffee40d239]        # 8275fa7 <local_itoa.digits+0x549c42>
    19e68d6e:	e9 99 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68d73:	48 8d 35 ce a6 0d ee 	lea    rsi,[rip+0xffffffffee0da6ce]        # 7f43448 <local_itoa.digits+0x2170e3>
    19e68d7a:	e9 8d 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68d7f:	48 8d 35 23 d2 40 ee 	lea    rsi,[rip+0xffffffffee40d223]        # 8275fa9 <local_itoa.digits+0x549c44>
    19e68d86:	e9 81 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68d8b:	48 8d 35 02 6a 41 ee 	lea    rsi,[rip+0xffffffffee416a02]        # 827f794 <local_itoa.digits+0x55342f>
    19e68d92:	e9 75 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68d97:	48 8d 35 b8 32 5f ee 	lea    rsi,[rip+0xffffffffee5f32b8]        # 845c056 <local_itoa.digits+0x72fcf1>
    19e68d9e:	e9 69 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68da3:	48 8d 35 53 a3 0d ee 	lea    rsi,[rip+0xffffffffee0da353]        # 7f430fd <local_itoa.digits+0x216d98>
    19e68daa:	e9 5d 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68daf:	48 8d 35 02 6b 41 ee 	lea    rsi,[rip+0xffffffffee416b02]        # 827f8b8 <local_itoa.digits+0x553553>
    19e68db6:	e9 51 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68dbb:	48 8d 35 74 bb 22 ee 	lea    rsi,[rip+0xffffffffee22bb74]        # 8094936 <local_itoa.digits+0x3685d1>
    19e68dc2:	e9 45 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68dc7:	48 8d 35 66 bb 22 ee 	lea    rsi,[rip+0xffffffffee22bb66]        # 8094934 <local_itoa.digits+0x3685cf>
    19e68dce:	e9 39 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68dd3:	48 8d 35 f0 6d 41 ee 	lea    rsi,[rip+0xffffffffee416df0]        # 827fbca <local_itoa.digits+0x553865>
    19e68dda:	e9 2d 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68ddf:	48 8d 35 c2 a3 0d ee 	lea    rsi,[rip+0xffffffffee0da3c2]        # 7f431a8 <local_itoa.digits+0x216e43>
    19e68de6:	e9 21 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68deb:	48 8d 35 da 6d 41 ee 	lea    rsi,[rip+0xffffffffee416dda]        # 827fbcc <local_itoa.digits+0x553867>
    19e68df2:	e9 15 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68df7:	48 8d 35 d1 6a 41 ee 	lea    rsi,[rip+0xffffffffee416ad1]        # 827f8cf <local_itoa.digits+0x55356a>
    19e68dfe:	e9 09 01 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e03:	48 8d 35 45 6e 41 ee 	lea    rsi,[rip+0xffffffffee416e45]        # 827fc4f <local_itoa.digits+0x5538ea>
    19e68e0a:	e9 fd 00 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e0f:	48 8d 35 dd 5d 39 ee 	lea    rsi,[rip+0xffffffffee395ddd]        # 81febf3 <local_itoa.digits+0x4d288e>
    19e68e16:	e9 f1 00 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e1b:	48 8d 35 c9 a3 0d ee 	lea    rsi,[rip+0xffffffffee0da3c9]        # 7f431eb <local_itoa.digits+0x216e86>
    19e68e22:	e9 e5 00 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e27:	48 8d 35 2a 32 5f ee 	lea    rsi,[rip+0xffffffffee5f322a]        # 845c058 <local_itoa.digits+0x72fcf3>
    19e68e2e:	e9 d9 00 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e33:	48 8d 35 0d 4b f6 ed 	lea    rsi,[rip+0xffffffffedf64b0d]        # 7dcd947 <local_itoa.digits+0xa15e2>
    19e68e3a:	e9 cd 00 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e3f:	48 8d 35 50 69 41 ee 	lea    rsi,[rip+0xffffffffee416950]        # 827f796 <local_itoa.digits+0x553431>
    19e68e46:	e9 c1 00 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e4b:	48 8d 35 f7 4a f6 ed 	lea    rsi,[rip+0xffffffffedf64af7]        # 7dcd949 <local_itoa.digits+0xa15e4>
    19e68e52:	e9 b5 00 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e57:	48 8d 35 a1 a2 0d ee 	lea    rsi,[rip+0xffffffffee0da2a1]        # 7f430ff <local_itoa.digits+0x216d9a>
    19e68e5e:	e9 a9 00 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e63:	48 8d 35 63 6a 41 ee 	lea    rsi,[rip+0xffffffffee416a63]        # 827f8cd <local_itoa.digits+0x553568>
    19e68e6a:	e9 9d 00 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e6f:	48 8d 35 0b 47 f6 ed 	lea    rsi,[rip+0xffffffffedf6470b]        # 7dcd581 <local_itoa.digits+0xa121c>
    19e68e76:	e9 91 00 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e7b:	48 8d 35 c8 a5 0d ee 	lea    rsi,[rip+0xffffffffee0da5c8]        # 7f4344a <local_itoa.digits+0x2170e5>
    19e68e82:	e9 85 00 00 00       	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e87:	48 8d 35 28 6a 41 ee 	lea    rsi,[rip+0xffffffffee416a28]        # 827f8b6 <local_itoa.digits+0x553551>
    19e68e8e:	eb 7c                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e90:	48 8d 35 5a 5d 39 ee 	lea    rsi,[rip+0xffffffffee395d5a]        # 81febf1 <local_itoa.digits+0x4d288c>
    19e68e97:	eb 73                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68e99:	48 8d 35 32 82 2a ee 	lea    rsi,[rip+0xffffffffee2a8232]        # 81110d2 <local_itoa.digits+0x3e4d6d>
    19e68ea0:	eb 6a                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68ea2:	48 8d 35 be 31 5f ee 	lea    rsi,[rip+0xffffffffee5f31be]        # 845c067 <local_itoa.digits+0x72fd02>
    19e68ea9:	eb 61                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68eab:	48 8d 35 b6 a6 22 ee 	lea    rsi,[rip+0xffffffffee22a6b6]        # 8093568 <local_itoa.digits+0x367203>
    19e68eb2:	eb 58                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68eb4:	48 8d 35 2a 82 2a ee 	lea    rsi,[rip+0xffffffffee2a822a]        # 81110e5 <local_itoa.digits+0x3e4d80>
    19e68ebb:	eb 4f                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68ebd:	48 8d 35 bf 46 f6 ed 	lea    rsi,[rip+0xffffffffedf646bf]        # 7dcd583 <local_itoa.digits+0xa121e>
    19e68ec4:	eb 46                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68ec6:	48 8d 35 c6 50 49 ee 	lea    rsi,[rip+0xffffffffee4950c6]        # 82fdf93 <local_itoa.digits+0x5d1c2e>
    19e68ecd:	eb 3d                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68ecf:	48 8d 35 94 a6 22 ee 	lea    rsi,[rip+0xffffffffee22a694]        # 809356a <local_itoa.digits+0x367205>
    19e68ed6:	eb 34                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68ed8:	48 8d 35 e3 4f 49 ee 	lea    rsi,[rip+0xffffffffee494fe3]        # 82fdec2 <local_itoa.digits+0x5d1b5d>
    19e68edf:	eb 2b                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68ee1:	48 8d 35 dc 4f 49 ee 	lea    rsi,[rip+0xffffffffee494fdc]        # 82fdec4 <local_itoa.digits+0x5d1b5f>
    19e68ee8:	eb 22                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68eea:	48 8d 35 f2 81 2a ee 	lea    rsi,[rip+0xffffffffee2a81f2]        # 81110e3 <local_itoa.digits+0x3e4d7e>
    19e68ef1:	eb 19                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68ef3:	48 8d 35 c2 30 5f ee 	lea    rsi,[rip+0xffffffffee5f30c2]        # 845bfbc <local_itoa.digits+0x72fc57>
    19e68efa:	eb 10                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68efc:	48 8d 35 9f 50 49 ee 	lea    rsi,[rip+0xffffffffee49509f]        # 82fdfa2 <local_itoa.digits+0x5d1c3d>
    19e68f03:	eb 07                	jmp    19e68f0c <_ZN3xla9jellyfish19GainLatchModeStringENS0_13GainLatchModeE+0x25c>
    19e68f05:	48 8d 35 f6 b7 db ec 	lea    rsi,[rip+0xffffffffecdbb7f6]        # 6c24702 <anon.de66683854b989ac240da9b5830f09df.25.llvm.14521404311210802531+0xcd9c9>
    19e68f0c:	48 8d 55 f7          	lea    rdx,[rbp-0x9]
    19e68f10:	48 89 df             	mov    rdi,rbx
    19e68f13:	e8 78 84 84 f2       	call   c6b1390 <_ZNSt3__u12basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEC2ILi0EEEPKcRKS4_>
    19e68f18:	48 89 d8             	mov    rax,rbx
    19e68f1b:	48 83 c4 08          	add    rsp,0x8
    19e68f1f:	5b                   	pop    rbx
    19e68f20:	5d                   	pop    rbp
    19e68f21:	c3                   	ret
    19e68f22:	cc                   	int3
    19e68f23:	cc                   	int3
    19e68f24:	cc                   	int3
    19e68f25:	cc                   	int3
    19e68f26:	cc                   	int3
    19e68f27:	cc                   	int3
    19e68f28:	cc                   	int3
    19e68f29:	cc                   	int3
    19e68f2a:	cc                   	int3
    19e68f2b:	cc                   	int3
    19e68f2c:	cc                   	int3
    19e68f2d:	cc                   	int3
    19e68f2e:	cc                   	int3
    19e68f2f:	cc                   	int3

0000000019e68f30 <_ZN3xla9jellyfish26GainLatchModePackingFactorENS0_13GainLatchModeE>:
    19e68f30:	89 f8                	mov    eax,edi
    19e68f32:	48 8d 0d 13 a7 d5 ef 	lea    rcx,[rip+0xffffffffefd5a713]        # 9bc364c <_ZTSN3xla9jellyfish17TargetEnvironmentE+0x1c4>
    19e68f39:	0f b6 04 08          	movzx  eax,BYTE PTR [rax+rcx*1]
    19e68f3d:	c3                   	ret
    19e68f3e:	cc                   	int3
    19e68f3f:	cc                   	int3

0000000019e68f40 <_ZN3xla9jellyfishlsERNSt3__u13basic_ostreamIcNS1_11char_traitsIcEEEENS0_13GainLatchModeE>:
    19e68f40:	55                   	push   rbp
    19e68f41:	48 89 e5             	mov    rbp,rsp
    19e68f44:	41 56                	push   r14
    19e68f46:	53                   	push   rbx
    19e68f47:	48 83 ec 20          	sub    rsp,0x20
    19e68f4b:	48 89 fb             	mov    rbx,rdi
    19e68f4e:	4c                   	rex.WR
    19e68f4f:	8d                   	.byte 0x8d
