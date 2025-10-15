# SHIB风格Meme代币项目

## 项目概述

本项目实现了一个完整的SHIB风格Meme代币合约，包含代币税机制、流动性池集成和交易限制功能。基于ERC20标准，采用Solidity开发，支持完整的部署、测试和前端集成。

## 项目结构

```
meme/
├── contracts/                 # 智能合约目录
│   └── SHIBToken.sol          # 主合约文件
├── scripts/                   # 部署脚本目录
│   └── deploy.js              # 合约部署脚本
├── test/                      # 测试文件目录
│   └── SHIBToken.test.js      # 合约测试套件
├── docs/                      # 技术文档目录
│   ├── 00路线图.md            # 技术路线图
│   ├── 01基础能力建设.md      # 基础技术文档
│   ├── 02合约设计模式.md      # 设计模式文档
│   ├── 03MEME专属功能开发.md  # 核心功能文档
│   ├── 04安全增强.md          # 安全文档（空）
│   └── 05进阶架构.md          # 进阶架构文档
├── 理论知识梳理.md            # 理论知识文档
├── 操作指南.md                # 使用操作指南
├── package.json               # 项目依赖配置
├── hardhat.config.js          # Hardhat配置
├── .env.example               # 环境变量示例
└── README.md                  # 项目说明文档
```

## 核心功能特性

### 1. 代币税机制
- **动态税率调节**：支持1-10%的可配置税率
- **税收分配路由**：灵活配置流动性池、销毁和国库分配比例
- **排除地址机制**：特定地址可免除税收

### 2. 流动性池集成
- **自动流动性注入**：交易税部分自动注入流动性池
- **流动性锁定**：支持流动性锁定机制
- **DEX安全交互**：集成Uniswap等DEX的安全交互

### 3. 交易限制功能
- **交易额度限制**：防止大额交易操纵市场
- **钱包余额限制**：控制单个钱包的最大持币量
- **交易冷却时间**：防止高频交易攻击

### 4. 安全增强
- **权限控制系统**：基于Ownable的管理员权限
- **紧急停止机制**：紧急情况下暂停交易
- **边界安全检查**：全面的输入验证和边界检查

## 快速开始

### 环境要求
- Node.js 16.0+
- npm 或 yarn
- Hardhat 开发框架

### 安装依赖
```bash
cd meme
npm install
```

### 配置环境
```bash
# 复制环境变量示例文件
cp .env.example .env

# 编辑.env文件，填入实际配置
# PRIVATE_KEY=你的私钥
# ETHERSCAN_API_KEY=你的API密钥
```

### 编译合约
```bash
npm run compile
```

### 运行测试
```bash
npm run test
```

### 部署合约
```bash
# 部署到本地网络
npm run deploy

# 部署到Goerli测试网
npm run deploy:goerli

# 部署到Sepolia测试网
npm run deploy:sepolia
```

## 合约功能详解

### 代币税机制
```solidity
// 5%交易税，分配比例：40%流动性，30%销毁，30%国库
function transfer(address to, uint256 amount) public override returns (bool) {
    // 税收计算和应用
    uint256 taxAmount = amount.mul(taxRate).div(100);
    uint256 transferAmount = amount.sub(taxAmount);
    
    // 税收分配处理
    _processTax(msg.sender, taxAmount);
}
```

### 交易限制
```solidity
// 交易验证逻辑
function _validateTransfer(address from, address to, uint256 amount) internal {
    require(amount <= maxTransactionAmount, "超过最大交易量");
    require(balanceOf(to).add(amount) <= maxWalletBalance, "超过最大钱包余额");
    require(block.timestamp >= _lastTransactionTime[from].add(cooldownPeriod), "冷却时间未到");
}
```

## 测试覆盖

项目包含完整的测试套件，覆盖以下功能：

- ✅ 合约初始化和参数设置
- ✅ 代币税计算和应用
- ✅ 交易限制强制执行
- ✅ 管理员功能权限控制
- ✅ 边界情况和错误处理
- ✅ 紧急操作功能

运行测试命令：
```bash
npm run test
```

## 部署指南

### 1. 准备部署环境
- 确保有足够的测试网ETH用于Gas费
- 配置正确的网络RPC端点
- 设置安全的私钥环境变量

### 2. 执行部署脚本
```javascript
// 部署参数配置
const tokenConfig = {
    name: "SHIB Style Meme Token",
    symbol: "SSMT", 
    initialSupply: "1000000000", // 10亿代币
    taxRate: 5, // 5%税率
    // ... 其他参数
};
```

### 3. 部署后配置
- 设置流动性池地址
- 配置税收分配比例
- 设置合理的交易限制参数
- 将重要地址排除在限制之外

## 前端集成

### Web3集成示例
```javascript
import { ethers } from 'ethers';

const tokenContract = new ethers.Contract(
    contractAddress,
    SHIBTokenABI,
    provider
);

// 获取代币信息
const tokenInfo = await tokenContract.getTokenInfo();

// 执行转账
const tx = await tokenContract.transfer(recipient, amount);
```

### React组件示例
提供完整的React组件示例，支持：
- 代币余额查询
- 转账操作
- 税收信息显示
- 交易限制提示

## 安全最佳实践

### 合约安全
- 使用最新Solidity版本（0.8.19）
- 集成OpenZeppelin安全库
- 全面的输入验证和边界检查
- 权限分离和最小权限原则

### 部署安全
- 在测试网充分测试后再部署主网
- 使用多签钱包管理合约权限
- 定期进行安全审计

### 运营安全
- 设置合理的交易限制参数
- 监控合约活动和安全事件
- 建立应急响应机制

## 技术文档

项目包含完整的技术文档体系：

1. **理论知识梳理** - 代币税、流动性池、交易限制的理论分析
2. **操作指南** - 详细的部署和使用说明
3. **技术路线图** - 项目开发的技术规划
4. **设计模式文档** - 合约架构和设计模式说明

## 贡献指南

欢迎贡献代码和改进建议：

1. Fork项目仓库
2. 创建特性分支
3. 提交更改并编写测试
4. 发起Pull Request

## 许可证

本项目采用MIT许可证，详见LICENSE文件。

## 支持与联系

如有问题或需要技术支持，请通过以下方式联系：
- 创建GitHub Issue
- 查看项目文档
- 参考技术社区讨论

---

**注意**：本项目为教育目的开发，实际部署前请进行充分的安全测试和审计。加密货币投资存在风险，请谨慎操作。