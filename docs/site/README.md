# sim-pjrt 中文文档站

基于 Astro Starlight 的本地静态文档站。无需运行模拟器或构建 XLA。

## 环境

- Node.js 22.12 或更新版本。
- npm 10.8.2 或更新版本。

## 本地阅读与编辑

```sh
cd docs/site
npm ci
npm run dev
```

访问 http://127.0.0.1:4321。服务仅监听本机。若在远程开发机运行，用 IDE 的端口转发将 4321 转发到自己的电脑。

## 构建与完整搜索

```sh
npm run build
npm run preview
```

访问终端打印的本地地址。全文搜索索引在构建阶段生成；验证搜索请使用 preview。

## 内容维护

- 中文文档：`src/content/docs/`。
- 导航和站点配置：`astro.config.mjs`。
- 少量主题样式：`src/styles/custom.css`。
- 依赖版本：`package.json` 和 `package-lock.json`，使用 `npm ci` 复现。

代码、命令和配置项保留原名。页面中的模拟器命令默认从仓库根目录运行。
修改模拟器行为时，同步更新对应指南、配置与限制。原始英文 README 保留详细参考，
`docs/iterations.md` 和 `docs/performance-plan.md` 保留开发证据与计划。

产物在 `dist/`，依赖、构建输出和 `.astro/` 均不提交。当前仅配置本地使用。
