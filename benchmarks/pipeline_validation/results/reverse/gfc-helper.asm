
.venv/lib/python3.12/site-packages/libtpu/libtpu.so:     file format elf64-x86-64


Disassembly of section .text:

00000000193454e0 <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const>:
    193454e0:	55                   	push   rbp
    193454e1:	48 89 e5             	mov    rbp,rsp
    193454e4:	41 56                	push   r14
    193454e6:	53                   	push   rbx
    193454e7:	48 81 ec 80 00 00 00 	sub    rsp,0x80
    193454ee:	48 89 fb             	mov    rbx,rdi
    193454f1:	83 fa 20             	cmp    edx,0x20
    193454f4:	0f 87 15 02 00 00    	ja     1934570f <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x22f>
    193454fa:	89 d0                	mov    eax,edx
    193454fc:	48 8d 0d dd f1 4c f0 	lea    rcx,[rip+0xfffffffff04cf1dd]        # 98146e0 <typeinfo name for std::__u::__shared_ptr_emplace[abi:fqn240000]<xla::DeviceAssignment const, std::__u::allocator<xla::DeviceAssignment> >+0x380>
    19345503:	48 63 04 81          	movsxd rax,DWORD PTR [rcx+rax*4]
    19345507:	48 01 c8             	add    rax,rcx
    1934550a:	ff e0                	jmp    rax
    1934550c:	48 8b 76 18          	mov    rsi,QWORD PTR [rsi+0x18]
    19345510:	48 89 df             	mov    rdi,rbx
    19345513:	ba 2d 01 00 00       	mov    edx,0x12d
    19345518:	e9 5d 01 00 00       	jmp    1934567a <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x19a>
    1934551d:	48 8d 05 84 1c 51 ef 	lea    rax,[rip+0xffffffffef511c84]        # 88571a8 <nilstr+0x161ec4>
    19345524:	48 89 85 78 ff ff ff 	mov    QWORD PTR [rbp-0x88],rax
    1934552b:	48 c7 45 80 21 00 00 	mov    QWORD PTR [rbp-0x80],0x21
    19345532:	00 
    19345533:	4c 8d 75 b8          	lea    r14,[rbp-0x48]
    19345537:	89 d7                	mov    edi,edx
    19345539:	4c 89 f6             	mov    rsi,r14
    1934553c:	e8 ff b8 48 04       	call   1d7d0e40 <absl::numbers_internal::FastIntToBuffer(int, char*)>
    19345541:	4c 89 75 a8          	mov    QWORD PTR [rbp-0x58],r14
    19345545:	4c 29 f0             	sub    rax,r14
    19345548:	48 89 45 b0          	mov    QWORD PTR [rbp-0x50],rax
    1934554c:	0f 88 c6 01 00 00    	js     19345718 <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x238>
    19345552:	4c 8d 75 d8          	lea    r14,[rbp-0x28]
    19345556:	48 8d b5 78 ff ff ff 	lea    rsi,[rbp-0x88]
    1934555d:	48 8d 55 a8          	lea    rdx,[rbp-0x58]
    19345561:	4c 89 f7             	mov    rdi,r14
    19345564:	e8 27 e7 48 04       	call   1d7d3c90 <absl::StrCat(absl::AlphaNum const&, absl::AlphaNum const&)>
    19345569:	48 8d 15 b9 d3 a4 ed 	lea    rdx,[rip+0xffffffffeda4d3b9]        # 6d92929 <sqlite3_str_vappendf.zOrd+0xa56c2>
    19345570:	be aa 03 00 00       	mov    esi,0x3aa
    19345575:	4c 89 f7             	mov    rdi,r14
    19345578:	e8 63 29 43 04       	call   1d777ee0 <absl::Status absl::status_internal::MakeErrorStringRvalueImpl<3>(std::__u::basic_string<char, std::__u::char_traits<char>, std::__u::allocator<char> >&&, absl::SourceLocation)>
    1934557d:	48 89 03             	mov    QWORD PTR [rbx],rax
    19345580:	80 7d ef 00          	cmp    BYTE PTR [rbp-0x11],0x0
    19345584:	0f 89 76 01 00 00    	jns    19345700 <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x220>
    1934558a:	48 8b 7d d8          	mov    rdi,QWORD PTR [rbp-0x28]
    1934558e:	48 be ff ff ff ff ff 	movabs rsi,0x7fffffffffffffff
    19345595:	ff ff 7f 
    19345598:	48 23 75 e8          	and    rsi,QWORD PTR [rbp-0x18]
    1934559c:	e8 8f 2b 74 04       	call   1da88130 <free@plt>
    193455a1:	e9 5a 01 00 00       	jmp    19345700 <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x220>
    193455a6:	48 8b 76 18          	mov    rsi,QWORD PTR [rsi+0x18]
    193455aa:	48 89 df             	mov    rdi,rbx
    193455ad:	ba 47 01 00 00       	mov    edx,0x147
    193455b2:	b9 08 00 00 00       	mov    ecx,0x8
    193455b7:	e9 c3 00 00 00       	jmp    1934567f <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x19f>
    193455bc:	48 8b 76 18          	mov    rsi,QWORD PTR [rsi+0x18]
    193455c0:	48 89 df             	mov    rdi,rbx
    193455c3:	ba 47 01 00 00       	mov    edx,0x147
    193455c8:	e9 04 01 00 00       	jmp    193456d1 <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x1f1>
    193455cd:	48 8b 7e 10          	mov    rdi,QWORD PTR [rsi+0x10]
    193455d1:	be 0a 01 00 00       	mov    esi,0x10a
    193455d6:	ba 03 00 00 00       	mov    edx,0x3
    193455db:	e9 11 01 00 00       	jmp    193456f1 <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x211>
    193455e0:	48 8b 7e 10          	mov    rdi,QWORD PTR [rsi+0x10]
    193455e4:	be 51 01 00 00       	mov    esi,0x151
    193455e9:	e9 fe 00 00 00       	jmp    193456ec <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x20c>
    193455ee:	48 8b 76 18          	mov    rsi,QWORD PTR [rsi+0x18]
    193455f2:	48 89 df             	mov    rdi,rbx
    193455f5:	ba 46 01 00 00       	mov    edx,0x146
    193455fa:	e9 d2 00 00 00       	jmp    193456d1 <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x1f1>
    193455ff:	48 8b 7e 10          	mov    rdi,QWORD PTR [rsi+0x10]
    19345603:	be 55 01 00 00       	mov    esi,0x155
    19345608:	e9 df 00 00 00       	jmp    193456ec <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x20c>
    1934560d:	48 8b 7e 10          	mov    rdi,QWORD PTR [rsi+0x10]
    19345611:	be 53 01 00 00       	mov    esi,0x153
    19345616:	e9 d1 00 00 00       	jmp    193456ec <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x20c>
    1934561b:	48 8b 76 18          	mov    rsi,QWORD PTR [rsi+0x18]
    1934561f:	48 89 df             	mov    rdi,rbx
    19345622:	ba 44 01 00 00       	mov    edx,0x144
    19345627:	e9 a5 00 00 00       	jmp    193456d1 <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x1f1>
    1934562c:	48 8b 76 18          	mov    rsi,QWORD PTR [rsi+0x18]
    19345630:	48 89 df             	mov    rdi,rbx
    19345633:	ba 33 01 00 00       	mov    edx,0x133
    19345638:	eb 40                	jmp    1934567a <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x19a>
    1934563a:	48 8b 7e 10          	mov    rdi,QWORD PTR [rsi+0x10]
    1934563e:	be 13 01 00 00       	mov    esi,0x113
    19345643:	ba 03 00 00 00       	mov    edx,0x3
    19345648:	e9 a4 00 00 00       	jmp    193456f1 <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x211>
    1934564d:	48 8b 76 18          	mov    rsi,QWORD PTR [rsi+0x18]
    19345651:	48 89 df             	mov    rdi,rbx
    19345654:	ba 21 01 00 00       	mov    edx,0x121
    19345659:	eb 1f                	jmp    1934567a <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x19a>
    1934565b:	48 8b 76 18          	mov    rsi,QWORD PTR [rsi+0x18]
    1934565f:	48 89 df             	mov    rdi,rbx
    19345662:	ba 44 01 00 00       	mov    edx,0x144
    19345667:	b9 08 00 00 00       	mov    ecx,0x8
    1934566c:	eb 11                	jmp    1934567f <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x19f>
    1934566e:	48 8b 76 18          	mov    rsi,QWORD PTR [rsi+0x18]
    19345672:	48 89 df             	mov    rdi,rbx
    19345675:	ba 27 01 00 00       	mov    edx,0x127
    1934567a:	b9 03 00 00 00       	mov    ecx,0x3
    1934567f:	45 31 c0             	xor    r8d,r8d
    19345682:	e8 19 ec 01 00       	call   193642a0 <absl::container_internal::raw_hash_set<absl::container_internal::FlatHashMapPolicy<xla::jellyfish::MatmulModifier, std::__u::array<int, 11ul> >>::iterator absl::container_internal::raw_hash_set<absl::container_internal::FlatHashMapPolicy<xla::jellyfish::MatmulModifier, std::__u::array<int, 11ul> >>::find_large<xla::jellyfish::MatmulModifier>(xla::jellyfish::MatmulModifier const&)+0x4c60>
    19345687:	eb 77                	jmp    19345700 <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x220>
    19345689:	48 8b 7e 10          	mov    rdi,QWORD PTR [rsi+0x10]
    1934568d:	be 59 01 00 00       	mov    esi,0x159
    19345692:	eb 58                	jmp    193456ec <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x20c>
    19345694:	48 8b 76 18          	mov    rsi,QWORD PTR [rsi+0x18]
    19345698:	48 89 df             	mov    rdi,rbx
    1934569b:	ba 46 01 00 00       	mov    edx,0x146
    193456a0:	b9 08 00 00 00       	mov    ecx,0x8
    193456a5:	eb d8                	jmp    1934567f <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x19f>
    193456a7:	48 8b 76 18          	mov    rsi,QWORD PTR [rsi+0x18]
    193456ab:	48 89 df             	mov    rdi,rbx
    193456ae:	ba 45 01 00 00       	mov    edx,0x145
    193456b3:	b9 08 00 00 00       	mov    ecx,0x8
    193456b8:	eb c5                	jmp    1934567f <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x19f>
    193456ba:	48 8b 7e 10          	mov    rdi,QWORD PTR [rsi+0x10]
    193456be:	be 58 01 00 00       	mov    esi,0x158
    193456c3:	eb 27                	jmp    193456ec <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x20c>
    193456c5:	48 8b 76 18          	mov    rsi,QWORD PTR [rsi+0x18]
    193456c9:	48 89 df             	mov    rdi,rbx
    193456cc:	ba 45 01 00 00       	mov    edx,0x145
    193456d1:	b9 08 00 00 00       	mov    ecx,0x8
    193456d6:	41 b8 01 00 00 00    	mov    r8d,0x1
    193456dc:	e8 bf eb 01 00       	call   193642a0 <absl::container_internal::raw_hash_set<absl::container_internal::FlatHashMapPolicy<xla::jellyfish::MatmulModifier, std::__u::array<int, 11ul> >>::iterator absl::container_internal::raw_hash_set<absl::container_internal::FlatHashMapPolicy<xla::jellyfish::MatmulModifier, std::__u::array<int, 11ul> >>::find_large<xla::jellyfish::MatmulModifier>(xla::jellyfish::MatmulModifier const&)+0x4c60>
    193456e1:	eb 1d                	jmp    19345700 <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x220>
    193456e3:	48 8b 7e 10          	mov    rdi,QWORD PTR [rsi+0x10]
    193456e7:	be 5f 01 00 00       	mov    esi,0x15f
    193456ec:	ba 11 00 00 00       	mov    edx,0x11
    193456f1:	e8 ca bb 03 00       	call   193812c0 <xla::pufferfish::PufferfishBarnaCorePerformance::GetResourceUsage(xla::pufferfish::PufferfishBarnaCorePerformance::Instruction, xla::pufferfish::PufferfishBarnaCorePerformance::Resource) const+0x6ea0>
    193456f6:	89 43 08             	mov    DWORD PTR [rbx+0x8],eax
    193456f9:	48 c7 03 01 00 00 00 	mov    QWORD PTR [rbx],0x1
    19345700:	48 89 d8             	mov    rax,rbx
    19345703:	48 81 c4 80 00 00 00 	add    rsp,0x80
    1934570a:	5b                   	pop    rbx
    1934570b:	41 5e                	pop    r14
    1934570d:	5d                   	pop    rbp
    1934570e:	c3                   	ret
    1934570f:	c7 43 08 01 00 00 00 	mov    DWORD PTR [rbx+0x8],0x1
    19345716:	eb e1                	jmp    193456f9 <xla::jellyfish::GfcCycleTable::GetCyclesForThroughputHelper(xla::jellyfish::CycleTable::Instruction) const+0x219>
    19345718:	0f 0b                	ud2
    1934571a:	cc                   	int3
    1934571b:	cc                   	int3
    1934571c:	cc                   	int3
    1934571d:	cc                   	int3
    1934571e:	cc                   	int3
    1934571f:	cc                   	int3

0000000019345720 <std::__u::__function::__policy_func<std::__u::unique_ptr<xla::jellyfish::CycleTable, std::__u::default_delete<xla::jellyfish::CycleTable> > (xla::jellyfish::Target const&)>::__empty_func(std::__u::__function::__policy_storage const*, xla::jellyfish::Target const&)>:
    19345720:	55                   	push   rbp
    19345721:	48 89 e5             	mov    rbp,rsp
    19345724:	e8 17 bf 3a f3       	call   c6f1640 <std::__u::__throw_bad_function_call()>
    19345729:	cc                   	int3
    1934572a:	cc                   	int3
    1934572b:	cc                   	int3
    1934572c:	cc                   	int3
    1934572d:	cc                   	int3
    1934572e:	cc                   	int3
    1934572f:	cc                   	int3

0000000019345730 <std::__u::unique_ptr<xla::jellyfish::CycleTable, std::__u::default_delete<xla::jellyfish::CycleTable> > std::__u::__function::__policy_func<std::__u::unique_ptr<xla::jellyfish::CycleTable, std::__u::default_delete<xla::jellyfish::CycleTable> > (xla::jellyfish::Target const&)>::__call_func<util_registration::FunctionRegistry<tpu::TpuVersion, std::__u::unique_ptr<xla::jellyfish::CycleTable, std::__u::default_delete<xla::jellyfish::CycleTable> > (xla::jellyfish::Target const&)>::FunctionWrapper>(std::__u::__function::__policy_storage const*, xla::jellyfish::Target const&)>:
    19345730:	48 8b 07             	mov    rax,QWORD PTR [rdi]
    19345733:	48 8b 38             	mov    rdi,QWORD PTR [rax]
    19345736:	ff 67 10             	jmp    QWORD PTR [rdi+0x10]
    19345739:	cc                   	int3
    1934573a:	cc                   	int3
    1934573b:	cc                   	int3
    1934573c:	cc                   	int3
    1934573d:	cc                   	int3
    1934573e:	cc                   	int3
    1934573f:	cc                   	int3

0000000019345740 <void* std::__u::__function::__policy::__large_clone<util_registration::FunctionRegistry<tpu::TpuVersion, std::__u::unique_ptr<xla::jellyfish::CycleTable, std::__u::default_delete<xla::jellyfish::CycleTable> > (xla::jellyfish::Target const&)>::FunctionWrapper>(void const*)>:
    19345740:	55                   	push   rbp
    19345741:	48 89 e5             	mov    rbp,rsp
    19345744:	53                   	push   rbx
    19345745:	50                   	push   rax
    19345746:	48 89 fb             	mov    rbx,rdi
    19345749:	bf 10 00 00 00       	mov    edi,0x10
    1934574e:	e8 2d 9a 50 04       	call   1d84f180 <operator new(unsigned long)>
    19345753:	48 8b 4b 08          	mov    rcx,QWORD PTR [rbx+0x8]
    19345757:	c5 f8 10 03          	vmovups xmm0,XMMWORD PTR [rbx]
    1934575b:	c5 f8 11 00          	vmovups XMMWORD PTR [rax],xmm0
    1934575f:	48 85 c9             	test   rcx,rcx
    19345762:	74 05                	je     19345769 <void* std::__u::__function::__policy::__large_clone<util_registration::FunctionRegistry<tpu::TpuVersion, std::__u::unique_ptr<xla::jellyfish::CycleTable, std::__u::default_delete<xla::jellyfish::CycleTable> > (xla::jellyfish::Target const&)>::FunctionWrapper>(void const*)+0x29>
    19345764:	f0 48 ff 41 08       	lock inc QWORD PTR [rcx+0x8]
    19345769:	48 83 c4 08          	add    rsp,0x8
    1934576d:	5b                   	pop    rbx
    1934576e:	5d                   	pop    rbp
    1934576f:	c3                   	ret

0000000019345770 <void std::__u::__function::__policy::__large_destroy<util_registration::FunctionRegistry<tpu::TpuVersion, std::__u::unique_ptr<xla::jellyfish::CycleTable, std::__u::default_delete<xla::jellyfish::CycleTable> > (xla::jellyfish::Target const&)>::FunctionWrapper>(void*)>:
    19345770:	48 85 ff             	test   rdi,rdi
    19345773:	74 47                	je     193457bc <void std::__u::__function::__policy::__large_destroy<util_registration::FunctionRegistry<tpu::TpuVersion, std::__u::unique_ptr<xla::jellyfish::CycleTable, std::__u::default_delete<xla::jellyfish::CycleTable> > (xla::jellyfish::Target const&)>::FunctionWrapper>(void*)+0x4c>
    19345775:	55                   	push   rbp
    19345776:	48 89 e5             	mov    rbp,rsp
    19345779:	41 56                	push   r14
    1934577b:	53                   	push   rbx
    1934577c:	48 8b 5f 08          	mov    rbx,QWORD PTR [rdi+0x8]
    19345780:	48 85 db             	test   rbx,rbx
    19345783:	74 29                	je     193457ae <void std::__u::__function::__policy::__large_destroy<util_registration::FunctionRegistry<tpu::TpuVersion, std::__u::unique_ptr<xla::jellyfish::CycleTable, std::__u::default_delete<xla::jellyfish::CycleTable> > (xla::jellyfish::Target const&)>::FunctionWrapper>(void*)+0x3e>
    19345785:	48 c7 c0 ff ff ff ff 	mov    rax,0xffffffffffffffff
    1934578c:	f0 48 0f c1 43 08    	lock xadd QWORD PTR [rbx+0x8],rax
    19345792:	48 85 c0             	test   rax,rax
    19345795:	75 17                	jne    193457ae <void std::__u::__function::__policy::__large_destroy<util_registration::FunctionRegistry<tpu::TpuVersion, std::__u::unique_ptr<xla::jellyfish::CycleTable, std::__u::default_delete<xla::jellyfish::CycleTable> > (xla::jellyfish::Target const&)>::FunctionWrapper>(void*)+0x3e>
    19345797:	48 8b 03             	mov    rax,QWORD PTR [rbx]
    1934579a:	49 89 fe             	mov    r14,rdi
    1934579d:	48 89 df             	mov    rdi,rbx
    193457a0:	ff 50 10             	call   QWORD PTR [rax+0x10]
    193457a3:	48 89 df             	mov    rdi,rbx
    193457a6:	e8 25 98 50 04       	call   1d84efd0 <std::__u::__shared_weak_count::__release_weak()>
    193457ab:	4c 89 f7             	mov    rdi,r14
    193457ae:	be 10 00 00 00       	mov    esi,0x10
    193457b3:	5b                   	pop    rbx
    193457b4:	41 5e                	pop    r14
    193457b6:	5d                   	pop    rbp
    193457b7:	e9 74 29 74 04       	jmp    1da88130 <free@plt>
    193457bc:	c3                   	ret
    193457bd:	cc                   	int3
    193457be:	cc                   	int3
    193457bf:	cc                   	int3
