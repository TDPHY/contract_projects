require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

/**
 * Hardhat配置文件
 * 配置网络、编译选项和插件设置
 */

const { 
  GOERLI_RPC_URL, 
  SEPOLIA_RPC_URL, 
  PRIVATE_KEY, 
  ETHERSCAN_API_KEY 
} = process.env;

module.exports = {
  // 默认网络配置
  defaultNetwork: "hardhat",
  
  // 网络配置
  networks: {
    // 本地开发网络
    hardhat: {
      chainId: 31337,
      allowUnlimitedContractSize: false,
    },
    
    // 本地开发网络（带账户）
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
    },
    
    // Goerli测试网配置
    goerli: {
      url: GOERLI_RPC_URL || "https://eth-goerli.g.alchemy.com/v2/demo",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 5,
      gas: 2100000,
      gasPrice: 8000000000,
    },
    
    // Sepolia测试网配置
    sepolia: {
      url: SEPOLIA_RPC_URL || "https://eth-sepolia.g.alchemy.com/v2/demo",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 11155111,
      gas: 2100000,
      gasPrice: 2000000000,
    },
    
    // 主网配置（谨慎使用）
    mainnet: {
      url: process.env.MAINNET_RPC_URL || "",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 1,
      gasPrice: 30000000000, // 30 gwei
    }
  },
  
  // 编译器配置
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: false,
    },
  },
  
  // 路径配置
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  
  // Etherscan验证配置
  etherscan: {
    apiKey: {
      mainnet: ETHERSCAN_API_KEY || "",
      goerli: ETHERSCAN_API_KEY || "",
      sepolia: ETHERSCAN_API_KEY || "",
    }
  },
  
  // 类型链配置
  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },
  
  // Gas报告配置
  gasReporter: {
    enabled: process.env.REPORT_GAS ? true : false,
    currency: "USD",
    coinmarketcap: process.env.COINMARKETCAP_API_KEY || "",
  },
  
  // 合约大小检查
  contractSizer: {
    alphaSort: true,
    runOnCompile: false,
    disambiguatePaths: false,
  }
};

// 环境变量检查
if (!PRIVATE_KEY) {
  console.warn("⚠️  未设置PRIVATE_KEY环境变量，部分网络功能可能受限");
  console.log("💡 请在.env文件中设置：PRIVATE_KEY=你的私钥");
}

if (!ETHERSCAN_API_KEY) {
  console.warn("⚠️  未设置ETHERSCAN_API_KEY环境变量，合约验证功能不可用");
}