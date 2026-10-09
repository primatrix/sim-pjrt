
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

000000000f212760 <_ZN3xla9jellyfish14LloMathBuilder6VweirdENS1_5ValueE>:
     f212760:	55                   	push   rbp
     f212761:	48 89 e5             	mov    rbp,rsp
     f212764:	41 57                	push   r15
     f212766:	41 56                	push   r14
     f212768:	53                   	push   rbx
     f212769:	48 81 ec 28 01 00 00 	sub    rsp,0x128
     f212770:	48 8b 06             	mov    rax,QWORD PTR [rsi]
     f212773:	48 0f ba e0 20       	bt     rax,0x20
     f212778:	0f 82 a7 02 00 00    	jb     f212a25 <_ZN3xla9jellyfish14LloMathBuilder6VweirdENS1_5ValueE+0x2c5>
     f21277e:	49 89 f6             	mov    r14,rsi
     f212781:	48 89 fb             	mov    rbx,rdi
     f212784:	89 c1                	mov    ecx,eax
     f212786:	48 8d 15 5f b4 fc f9 	lea    rdx,[rip+0xfffffffff9fcb45f]        # 91ddbec <_ZTSZN3xla9jellyfish9QrEmitter4EmitEvE3$_1+0x107>
     f21278d:	48 63 0c 8a          	movsxd rcx,DWORD PTR [rdx+rcx*4]
     f212791:	48 01 d1             	add    rcx,rdx
     f212794:	ff e1                	jmp    rcx
     f212796:	49 8b 46 08          	mov    rax,QWORD PTR [r14+0x8]
     f21279a:	48 83 f8 01          	cmp    rax,0x1
     f21279e:	0f 86 b3 02 00 00    	jbe    f212a57 <_ZN3xla9jellyfish14LloMathBuilder6VweirdENS1_5ValueE+0x2f7>
     f2127a4:	a8 01                	test   al,0x1
     f2127a6:	74 3b                	je     f2127e3 <_ZN3xla9jellyfish14LloMathBuilder6VweirdENS1_5ValueE+0x83>
     f2127a8:	4d 8b 76 10          	mov    r14,QWORD PTR [r14+0x10]
     f2127ac:	eb 39                	jmp    f2127e7 <_ZN3xla9jellyfish14LloMathBuilder6VweirdENS1_5ValueE+0x87>
     f2127ae:	48 89 85 28 ff ff ff 	mov    QWORD PTR [rbp-0xd8],rax
     f2127b5:	4d 8d 7e 08          	lea    r15,[r14+0x8]
     f2127b9:	48 c7 85 30 ff ff ff 	mov    QWORD PTR [rbp-0xd0],0x0
     f2127c0:	00 00 00 00 
     f2127c4:	49 8b 46 08          	mov    rax,QWORD PTR [r14+0x8]
     f2127c8:	48 83 f8 02          	cmp    rax,0x2
     f2127cc:	72 46                	jb     f212814 <_ZN3xla9jellyfish14LloMathBuilder6VweirdENS1_5ValueE+0xb4>
     f2127ce:	a8 01                	test   al,0x1
     f2127d0:	74 2d                	je     f2127ff <_ZN3xla9jellyfish14LloMathBuilder6VweirdENS1_5ValueE+0x9f>
     f2127d2:	48 8d bd 30 ff ff ff 	lea    rdi,[rbp-0xd0]
     f2127d9:	4c 89 fe             	mov    rsi,r15
     f2127dc:	e8 ff c4 fb ff       	call   f1cece0 <_ZN4absl23inlined_vector_internal7StorageIPN3xla9jellyfish8LloValueELm4ENSt3__u9allocatorIS5_EEE8InitFromERKS9_>
     f2127e1:	eb 31                	jmp    f212814 <_ZN3xla9jellyfish14LloMathBuilder6VweirdENS1_5ValueE+0xb4>
     f2127e3:	49 83 c6 10          	add    r14,0x10
     f2127e7:	49 8b 36             	mov    rsi,QWORD PTR [r14]
     f2127ea:	48 89 df             	mov    rdi,rbx
     f2127ed:	48 81 c4 28 01 00 00 	add    rsp,0x128
     f2127f4:	5b                   	pop    rbx
     f2127f5:	41 5e                	pop    r14
     f2127f7:	41 5f                	pop    r15
     f2127f9:	5d                   	pop    rbp
     f2127fa:	e9 f1 d3 78 0a       	jmp    1999fbf0 <_ZN3xla9jellyfish16LloRegionBuilder9VweirdF32EPNS0_8LloValueE>
     f2127ff:	48 89 85 30 ff ff ff 	mov    QWORD PTR [rbp-0xd0],rax
     f212806:	c4 c1 7c 10 46 10    	vmovups ymm0,YMMWORD PTR [r14+0x10]
     f21280c:	c5 fc 11 85 38 ff ff 	vmovups YMMWORD PTR [rbp-0xc8],ymm0
     f212813:	ff 
     f212814:	48 8d bd f8 fe ff ff 	lea    rdi,[rbp-0x108]
     f21281b:	48 8d 95 28 ff ff ff 	lea    rdx,[rbp-0xd8]
     f212822:	c5 f8 77             	vzeroupper
     f212825:	e8 96 a4 ff ff       	call   f20ccc0 <_ZN3xla9jellyfish14LloMathBuilder5VrealENS1_5ValueE>
     f21282a:	f6                   	.byte 0xf6
     f21282b:	85 30                	test   DWORD PTR [rax],esi
     f21282d:	ff                   	(bad)
     f21282e:	ff                   	(bad)
     f21282f:	ff                   	.byte 0xff
