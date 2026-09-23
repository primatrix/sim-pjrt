import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'http://127.0.0.1:4321',
  server: { host: '127.0.0.1', port: 4321 },
  integrations: [
    starlight({
      title: 'sim-pjrt',
      description: '在 CPU 上探索 JAX 与 TPU 工作负载的执行、存储和性能模型。',
      defaultLocale: 'root',
      locales: { root: { label: '简体中文', lang: 'zh-CN' } },
      favicon: '/favicon.svg',
      customCss: ['./src/styles/custom.css'],
      sidebar: [
        { label: '开始', items: [
          { label: '项目概览', slug: 'overview' },
          { label: '快速开始', slug: 'getting-started' },
        ] },
        { label: '使用指南', items: [
          { label: 'Virtual HBM', slug: 'guides/virtual-hbm' },
          { label: '张量并行与重新分片', slug: 'guides/tensor-parallelism' },
          { label: 'Pallas 内核', slug: 'guides/pallas' },
          { label: 'XProf 性能分析', slug: 'guides/profiling' },
        ] },
        { label: '原理与参考', items: [
          { label: '架构与执行流程', slug: 'architecture' },
          { label: '环境变量', slug: 'reference/configuration' },
          { label: '支持范围与限制', slug: 'reference/limitations' },
        ] },
        { label: '开发', items: [
          { label: '测试与验证', slug: 'development/testing' },
          { label: '路线图', slug: 'development/roadmap' },
        ] },
      ],
    }),
  ],
});
