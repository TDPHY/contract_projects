# MetaNode Stake Project

一个基于区块链的质押系统，支持多种代币的质押，并基于用户质押的代币数量和时间长度分配 MetaNode 代币作为奖励。

## 项目结构

```
stake/
├── stake-contract/          # 智能合约项目
│   ├── contracts/           # 智能合约代码
│   ├── test/                # 测试文件
│   ├── scripts/             # 部署脚本
│   └── ignition/            # Hardhat Ignition 模块
├── stake-fe/                # 前端项目
│   ├── src/                 # 源代码
│   ├── pages/               # Next.js 页面
│   └── components/          # React 组件
└── docs/                    # 文档
```

## 功能特性

### 智能合约功能
- ✅ 支持 ETH 和 ERC20 代币质押
- ✅ 多质押池管理
- ✅ 奖励分配机制
- ✅ 解质押锁定机制
- ✅ 管理员权限控制
- ✅ 合约可升级 (UUPS)
- ✅ 暂停/恢复功能

### 前端功能
- ✅ 钱包连接 (RainbowKit)
- ✅ ETH 质押界面
- ✅ 解质押界面
- ✅ 奖励领取界面
- ✅ 响应式设计

## 快速开始

### 前置要求
- Node.js 16+
- npm 或 yarn
- Hardhat
- MetaMask 钱包

### 1. 智能合约部署

#### 环境配置
```bash
cd stake-contract
cp .env.example .env
# 编辑 .env 文件，填入你的配置
```

#### 安装依赖
```bash
npm install
```

#### 编译合约
```bash
npx hardhat compile
```

#### 运行测试
```bash
npx hardhat test
```

#### 部署到 Sepolia 测试网
```bash
npx hardhat run scripts/deploy.js --network sepolia
```

### 2. 前端运行

#### 环境配置
```bash
cd stake-fe
cp .env.example .env
# 编辑 .env 文件，填入合约地址
```

#### 安装依赖
```bash
npm install
```

#### 启动开发服务器
```bash
npm run dev
```

访问 http://localhost:3000 查看应用。

## 合约功能说明

### 主要功能

#### 质押
- 支持 ETH 和 ERC20 代币质押
- 最小质押金额限制
- 实时奖励计算

#### 解质押
- 解质押请求机制
- 锁定期设置
- 批量解质押支持

#### 奖励领取
- 随时领取奖励
- 奖励自动计算
- 安全转账机制

### 管理员功能
- 添加/更新质押池
- 设置池权重
- 暂停/恢复功能
- 合约升级

## 测试覆盖

项目包含完整的测试套件，覆盖：
- ✅ 基础功能测试
- ✅ ERC20 代币质押测试
- ✅ 边界条件测试
- ✅ 权限控制测试
- ✅ 奖励计算测试

运行测试：
```bash
cd stake-contract
npx hardhat test
```

## 安全考虑

- 使用 OpenZeppelin 安全库
- 重入攻击防护
- 输入验证
- 权限控制
- 安全数学运算

## 部署说明

### 测试网部署
1. 配置 Sepolia RPC URL 和私钥
2. 部署 MetaNode 代币合约
3. 部署 MetaNodeStake 合约
4. 配置前端环境变量

### 主网部署
1. 进行安全审计
2. 配置主网环境
3. 分阶段部署
4. 监控合约状态

## 开发指南

### 添加新功能
1. 在 `contracts/` 中添加新合约
2. 编写对应的测试用例
3. 更新前端界面
4. 更新部署脚本

### 代码规范
- 使用 Solidity 0.8.20+
- 遵循 OpenZeppelin 标准
- 编写完整的注释
- 保持测试覆盖率高

## 故障排除

### 常见问题

**合约部署失败**
- 检查环境变量配置
- 确认账户余额充足
- 验证网络连接

**前端连接问题**
- 检查合约地址配置
- 确认网络匹配
- 检查钱包连接状态

### 获取帮助
- 查看测试用例了解功能用法
- 检查控制台错误信息
- 参考 OpenZeppelin 文档

## 贡献指南

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License