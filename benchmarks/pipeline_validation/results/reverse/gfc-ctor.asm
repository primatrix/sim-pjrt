
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

00000000193450f0 <xla::jellyfish::GfcCycleTable::GfcCycleTable(xla::jellyfish::Target const&)>:
    193450f0:	55                   	push   rbp
    193450f1:	48 89 e5             	mov    rbp,rsp
    193450f4:	41 57                	push   r15
    193450f6:	41 56                	push   r14
    193450f8:	53                   	push   rbx
    193450f9:	50                   	push   rax
    193450fa:	48 89 fb             	mov    rbx,rdi
    193450fd:	48 89 77 08          	mov    QWORD PTR [rdi+0x8],rsi
    19345101:	48 8d 05 b0 2f ef 04 	lea    rax,[rip+0x4ef2fb0]        # 1e2380b8 <vtable for xla::jellyfish::GfcCycleTable>
    19345108:	48 83 c0 10          	add    rax,0x10
    1934510c:	48 89 07             	mov    QWORD PTR [rdi],rax
    1934510f:	c5 f8 57 c0          	vxorps xmm0,xmm0,xmm0
    19345113:	c5 f8 11 47 10       	vmovups XMMWORD PTR [rdi+0x10],xmm0
    19345118:	bf 30 00 00 00       	mov    edi,0x30
    1934511d:	e8 5e a0 50 04       	call   1d84f180 <operator new(unsigned long)>
    19345122:	49 89 c6             	mov    r14,rax
    19345125:	48 89 c7             	mov    rdi,rax
    19345128:	e8 23 53 03 00       	call   1937a450 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x30>
    1934512d:	48 8b 73 10          	mov    rsi,QWORD PTR [rbx+0x10]
    19345131:	4c 89 73 10          	mov    QWORD PTR [rbx+0x10],r14
    19345135:	48 85 f6             	test   rsi,rsi
    19345138:	74 09                	je     19345143 <xla::jellyfish::GfcCycleTable::GfcCycleTable(xla::jellyfish::Target const&)+0x53>
    1934513a:	48 8d 7b 10          	lea    rdi,[rbx+0x10]
    1934513e:	e8 3d 02 00 00       	call   19345380 <xla::jellyfish::GfcCycleTable::EstimateTanCost() const+0x8>
    19345143:	bf 50 00 00 00       	mov    edi,0x50
    19345148:	e8 33 a0 50 04       	call   1d84f180 <operator new(unsigned long)>
    1934514d:	49 89 c7             	mov    r15,rax
    19345150:	48 89 c7             	mov    rdi,rax
    19345153:	e8 58 c4 01 00       	call   193615b0 <absl::container_internal::raw_hash_set<absl::container_internal::FlatHashMapPolicy<xla::jellyfish::MatmulModifier, std::__u::array<int, 11ul> >>::iterator absl::container_internal::raw_hash_set<absl::container_internal::FlatHashMapPolicy<xla::jellyfish::MatmulModifier, std::__u::array<int, 11ul> >>::find_large<xla::jellyfish::MatmulModifier>(xla::jellyfish::MatmulModifier const&)+0x1f70>
    19345158:	4c 8b 73 18          	mov    r14,QWORD PTR [rbx+0x18]
    1934515c:	4c 89 7b 18          	mov    QWORD PTR [rbx+0x18],r15
    19345160:	4d 85 f6             	test   r14,r14
    19345163:	74 1f                	je     19345184 <xla::jellyfish::GfcCycleTable::GfcCycleTable(xla::jellyfish::Target const&)+0x94>
    19345165:	4c 89 f7             	mov    rdi,r14
    19345168:	e8 e3 02 00 00       	call   19345450 <xla::jellyfish::GfcCycleTable::EstimateTanCost() const+0xd8>
    1934516d:	be 50 00 00 00       	mov    esi,0x50
    19345172:	4c 89 f7             	mov    rdi,r14
    19345175:	48 83 c4 08          	add    rsp,0x8
    19345179:	5b                   	pop    rbx
    1934517a:	41 5e                	pop    r14
    1934517c:	41 5f                	pop    r15
    1934517e:	5d                   	pop    rbp
    1934517f:	e9 ac 2f 74 04       	jmp    1da88130 <free@plt>
    19345184:	48 83 c4 08          	add    rsp,0x8
    19345188:	5b                   	pop    rbx
    19345189:	41 5e                	pop    r14
    1934518b:	41 5f                	pop    r15
    1934518d:	5d                   	pop    rbp
    1934518e:	c3                   	ret
    1934518f:	cc                   	int3

0000000019345190 <xla::jellyfish::GfcCycleTable::~GfcCycleTable()>:
    19345190:	55                   	push   rbp
    19345191:	48 89 e5             	mov    rbp,rsp
    19345194:	41 56                	push   r14
    19345196:	53                   	push   rbx
    19345197:	48 89 fb             	mov    rbx,rdi
    1934519a:	48 8d 05 17 2f ef 04 	lea    rax,[rip+0x4ef2f17]        # 1e2380b8 <vtable for xla::jellyfish::GfcCycleTable>
    193451a1:	48 83 c0 10          	add    rax,0x10
    193451a5:	48 89 07             	mov    QWORD PTR [rdi],rax
    193451a8:	4c 8b 77 18          	mov    r14,QWORD PTR [rdi+0x18]
    193451ac:	48 c7 47 18 00 00 00 	mov    QWORD PTR [rdi+0x18],0x0
    193451b3:	00 
    193451b4:	4d 85 f6             	test   r14,r14
    193451b7:	74 15                	je     193451ce <xla::jellyfish::GfcCycleTable::~GfcCycleTable()+0x3e>
    193451b9:	4c 89 f7             	mov    rdi,r14
    193451bc:	e8 8f 02 00 00       	call   19345450 <xla::jellyfish::GfcCycleTable::EstimateTanCost() const+0xd8>
    193451c1:	be 50 00 00 00       	mov    esi,0x50
    193451c6:	4c 89 f7             	mov    rdi,r14
    193451c9:	e8 62 2f 74 04       	call   1da88130 <free@plt>
    193451ce:	48 8b 73 10          	mov    rsi,QWORD PTR [rbx+0x10]
    193451d2:	48 c7 43 10 00 00 00 	mov    QWORD PTR [rbx+0x10],0x0
    193451d9:	00 
    193451da:	48 85 f6             	test   rsi,rsi
    193451dd:	74 10                	je     193451ef <xla::jellyfish::GfcCycleTable::~GfcCycleTable()+0x5f>
    193451df:	48                   	rex.W
