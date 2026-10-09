
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

00000000199f6230 <_ZNK3xla9jellyfish8LloValue15IsVunpackclBf16Ev>:
    199f6230:	66 81 7f 1a 09 01    	cmp    WORD PTR [rdi+0x1a],0x109
    199f6236:	75 29                	jne    199f6261 <_ZNK3xla9jellyfish8LloValue15IsVunpackclBf16Ev+0x31>
    199f6238:	55                   	push   rbp
    199f6239:	48 89 e5             	mov    rbp,rsp
    199f623c:	53                   	push   rbx
    199f623d:	50                   	push   rax
    199f623e:	48 89 fb             	mov    rbx,rdi
    199f6241:	e8 ba c2 f3 ff       	call   19932500 <_ZNK3xla9jellyfish14LloInstruction12vpack_formatEv>
    199f6246:	66 83 f8 01          	cmp    ax,0x1
    199f624a:	75 18                	jne    199f6264 <_ZNK3xla9jellyfish8LloValue15IsVunpackclBf16Ev+0x34>
    199f624c:	48 89 df             	mov    rdi,rbx
    199f624f:	e8 5c c3 f3 ff       	call   199325b0 <_ZNK3xla9jellyfish14LloInstruction21vunpack_sublane_indexEv>
    199f6254:	66 85 c0             	test   ax,ax
    199f6257:	0f 94 c0             	sete   al
    199f625a:	48 83 c4 08          	add    rsp,0x8
    199f625e:	5b                   	pop    rbx
    199f625f:	5d                   	pop    rbp
    199f6260:	c3                   	ret
    199f6261:	31 c0                	xor    eax,eax
    199f6263:	c3                   	ret
    199f6264:	31 c0                	xor    eax,eax
    199f6266:	48 83 c4 08          	add    rsp,0x8
    199f626a:	5b                   	pop    rbx
    199f626b:	5d                   	pop    rbp
    199f626c:	c3                   	ret
    199f626d:	cc                   	int3
    199f626e:	cc                   	int3
    199f626f:	cc                   	int3

00000000199f6270 <_ZNK3xla9jellyfish8LloValue15IsVunpackcuBf16Ev>:
    199f6270:	66 81 7f 1a 09 01    	cmp    WORD PTR [rdi+0x1a],0x109
    199f6276:	75 2a                	jne    199f62a2 <_ZNK3xla9jellyfish8LloValue15IsVunpackcuBf16Ev+0x32>
    199f6278:	55                   	push   rbp
    199f6279:	48 89 e5             	mov    rbp,rsp
    199f627c:	53                   	push   rbx
    199f627d:	50                   	push   rax
    199f627e:	48 89 fb             	mov    rbx,rdi
    199f6281:	e8 7a c2 f3 ff       	call   19932500 <_ZNK3xla9jellyfish14LloInstruction12vpack_formatEv>
    199f6286:	66 83 f8 01          	cmp    ax,0x1
    199f628a:	75 19                	jne    199f62a5 <_ZNK3xla9jellyfish8LloValue15IsVunpackcuBf16Ev+0x35>
    199f628c:	48 89 df             	mov    rdi,rbx
    199f628f:	e8 1c c3 f3 ff       	call   199325b0 <_ZNK3xla9jellyfish14LloInstruction21vunpack_sublane_indexEv>
    199f6294:	66 83 f8 01          	cmp    ax,0x1
    199f6298:	0f 94 c0             	sete   al
    199f629b:	48 83 c4 08          	add    rsp,0x8
    199f629f:	5b                   	pop    rbx
    199f62a0:	5d                   	pop    rbp
    199f62a1:	c3                   	ret
    199f62a2:	31 c0                	xor    eax,eax
    199f62a4:	c3                   	ret
    199f62a5:	31 c0                	xor    eax,eax
    199f62a7:	48 83 c4 08          	add    rsp,0x8
    199f62ab:	5b                   	pop    rbx
    199f62ac:	5d                   	pop    rbp
    199f62ad:	c3                   	ret
    199f62ae:	cc                   	int3
    199f62af:	cc                   	int3
