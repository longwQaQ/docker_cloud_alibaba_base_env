# 变更记录

本项目遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 的结构。

## 未发布

### 新增

- 随机本地凭证生成脚本和 `.env.example`；
- Nacos 管理员一次性初始化服务；
- Nacos、Sentinel、Seata 和 MySQL 健康检查；
- 官方 Nacos/Seata 数据库 Schema；
- 静态验证、完整启动测试和 GitHub Actions CI；
- 安全策略、贡献指南、Issue/PR 模板和 Dependabot 配置。
- Apache License 2.0 根项目许可证。

### 变更

- Nacos 升级至 2.5.1；
- MySQL 升级至 8.4 LTS；
- Sentinel Dashboard 升级至 1.8.10；
- Apache Seata 升级至 2.6.0；
- 所有宿主机端口默认只绑定 `127.0.0.1`；
- 持久化目录改为 Docker 命名卷。

### 安全

- 删除仓库中的固定数据库凭证；
- 删除将凭证放入 URL、使用不安全临时文件并拼接配置的旧初始化脚本；
- 为 Sentinel 增加 JAR 完整性校验、非 root 用户、只读根文件系统和 capability 限制；
- 禁止默认公网绑定、特权容器、Docker Socket 和宿主机根目录挂载。
