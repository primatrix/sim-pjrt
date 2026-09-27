---
title: 路线图
description: 聚焦 Final LLO 计时模型、真实 TPU 校准与误差验证。
---

当前仅保留 libtpu → bundles 计时、CPU 输出模拟、Virtual HBM 和原生 XProf。

## P0：计时准确性与真机验证

### 真实 TPU 基准与校准

尽早在有硬件或已有实验捕获后，从孤立 attention 开始建立对照基准，记录源码版本、形状、dtype、拓扑、预热与重复配置。用对应局部调用的真实设备区间识别模型缺口、校准参数，再在未参与拟合的形状、拓扑和 serving 工作负载上验证并公布误差。

CPU wall-clock 不能作为 TPU 观测值。只有可辨识的参数才能拟合，覆盖 compute-bound 内核并不能独立确定 HBM 带宽。

### Final LLO 计时模型

Final LLO 计时器已接入执行路径，已支持标量值可确定的循环、分支、phi、spill/reload 和 DMA 操作数。继续补齐跳转延迟槽、运行时输入相关控制流、跨 kernel 标量参数绑定和指令延迟。静态 bundle 数不等于实际执行次数；先覆盖对应路径的语义，再拟合硬件参数。

已有部分 DMA 完成等待、credit 和资源串行化支持。继续补齐通用同步协议、collective 同步与共享链路争用；根据目标工作负载补充路由、归约算术、端点 HBM 流量、子组通信与重新分片覆盖。

当前结构见[架构](/architecture/)。
