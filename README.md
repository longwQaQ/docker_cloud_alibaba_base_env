# Spring Cloud Alibaba 本地基础环境

使用 Docker Compose 启动一套仅面向本地开发和集成测试的 Spring Cloud Alibaba 基础环境。

## 组件

| 组件 | 版本 | 本机地址 |
|---|---|---|
| Nacos | 2.5.1 | <http://127.0.0.1:8848/nacos> |
| MySQL | 8.4 LTS | `127.0.0.1:3306` |
| Sentinel Dashboard | 1.8.10 | <http://127.0.0.1:8858> |
| Apache Seata | 2.6.0 | `127.0.0.1:8091` |

所有端口默认只绑定 `127.0.0.1`，数据库和日志使用 Docker 命名卷持久化。

## 前置条件

- Docker Engine 或 Docker Desktop
- Docker Compose v2
- Bash 和 OpenSSL（仅用于生成本地凭证）

## 快速开始

```bash
./scripts/init-env.sh
docker compose config --quiet
docker compose up -d --build
docker compose ps
```

本地凭证保存在权限为 `600` 的 `.env` 中，该文件已被 Git 忽略。Nacos 管理员用户名为 `nacos`，Sentinel 用户名默认为 `sentinel`，密码均从 `.env` 读取。

初始化容器会通过 Nacos 官方管理员初始化接口写入随机密码，不使用默认密码。不要把本项目直接部署到公网或生产环境。

如果端口已被占用，可在 `.env` 中修改 `MYSQL_PORT`、`NACOS_HTTP_PORT`、`NACOS_GRPC_PORT`、`SENTINEL_PORT` 或 `SEATA_PORT`。

## 停止与清理

停止服务并保留数据：

```bash
docker compose down
```

删除所有本地数据卷：

```bash
docker compose down --volumes
```

第二条命令会永久删除本项目的 MySQL、Nacos 和 Seata 数据，请先确认不再需要。

## 安全设计

- `.env` 不进入版本控制，初始化脚本生成随机数据库、Nacos 服务身份和 Sentinel 凭证。
- 管理端口只绑定回环地址；如需局域网访问，必须显式修改 `BIND_ADDRESS` 并配置防火墙。
- Nacos 开启认证，只暴露必要的健康和指标管理端点。
- Sentinel 镜像由官方 Release JAR 构建，并在构建时校验 SHA-256。
- Sentinel 以非 root 用户和只读根文件系统运行，并移除 Linux capabilities。
- MySQL 使用官方 8.4 LTS 镜像，Nacos 与 Seata 使用独立数据库，应用不使用 root 账号。
- 服务共享独立的 Compose 网络，宿主机只发布明确声明且绑定回环地址的端口。

更完整的信任边界、已知限制和漏洞报告方式见 [SECURITY.md](SECURITY.md)。

## 数据库初始化

首次创建 MySQL 数据卷时，`mysql/init` 下的脚本会依次执行：

1. 创建 Seata 数据库并授权应用账号；
2. 导入 Nacos 2.5.1 官方 MySQL Schema；
3. 导入 Apache Seata 2.6.0 官方 MySQL Schema。

已有数据卷不会重复执行初始化脚本。升级 Schema 前请备份数据并阅读对应上游迁移说明。

## 版本更新

升级组件时不要只修改镜像标签：

1. 阅读 Nacos、Seata、Sentinel 和 MySQL 的官方 Release Notes；
2. 同步更新数据库 Schema 和 `seata/application.yml`；
3. 更新 Sentinel JAR 的版本与 SHA-256；
4. 运行 `./scripts/validate.sh` 和 `docker compose build sentinel`；
5. 使用全新数据卷执行一次完整启动测试，再验证已有数据升级。

`./scripts/smoke-test.sh` 会使用独立的临时 Compose 项目执行完整启动验证，并在结束后删除该测试项目的数据卷，不会删除默认项目的数据。

上游版本依据：[Nacos 2.5.1](https://github.com/alibaba/nacos/releases/tag/2.5.1)、[Apache Seata 2.6.0](https://github.com/apache/incubator-seata/releases/tag/v2.6.0)、[Sentinel 1.8.10](https://github.com/alibaba/Sentinel/releases/tag/1.8.10) 和 [MySQL 官方镜像](https://hub.docker.com/_/mysql)。

## 贡献

提交 Issue 或 Pull Request 前请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可证

本项目采用 [Apache License 2.0](LICENSE)。仓库中引用或同步的第三方组件、数据库 Schema 和构建产物仍遵循其各自的上游许可证与声明。
