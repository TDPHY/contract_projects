const { ethers } = require("hardhat");

/**
 * SHIB风格Meme代币部署脚本
 * 部署合约并配置初始参数
 */

async function main() {
  console.log("🚀 开始部署SHIB风格Meme代币合约...");
  
  // 获取部署者账户
  const [deployer] = await ethers.getSigners();
  console.log("📝 部署者地址:", deployer.address);
  console.log("💰 部署者余额:", ethers.utils.formatEther(await deployer.getBalance()), "ETH");

  // 部署参数配置
  const tokenConfig = {
    name: "SHIB Style Meme Token",
    symbol: "SSMT",
    initialSupply: ethers.utils.parseEther("1000000000"), // 10亿代币
    treasuryWallet: deployer.address, // 使用部署者地址作为临时国库
    taxRate: 5, // 初始税率5%
    liquidityShare: 40, // 流动性池分配40%
    burnShare: 30, // 销毁分配30%
    treasuryShare: 30, // 国库分配30%
    maxTransaction: ethers.utils.parseEther("1000000"), // 最大交易量100万
    maxWallet: ethers.utils.parseEther("5000000"), // 最大钱包余额500万
    cooldown: 300 // 冷却时间300秒
  };

  console.log("\n📋 部署配置:");
  console.log("代币名称:", tokenConfig.name);
  console.log("代币符号:", tokenConfig.symbol);
  console.log("初始供应量:", ethers.utils.formatEther(tokenConfig.initialSupply), "SSMT");
  console.log("国库地址:", tokenConfig.treasuryWallet);
  console.log("初始税率:", tokenConfig.taxRate, "%");

  // 部署合约
  console.log("\n⏳ 正在部署合约...");
  const SHIBToken = await ethers.getContractFactory("SHIBToken");
  const token = await SHIBToken.deploy(
    tokenConfig.name,
    tokenConfig.symbol,
    tokenConfig.initialSupply,
    tokenConfig.treasuryWallet
  );

  console.log("⏳ 等待合约部署确认...");
  await token.deployed();
  
  console.log("✅ 合约部署成功!");
  console.log("📄 合约地址:", token.address);
  console.log("🔗 交易哈希:", token.deployTransaction.hash);

  // 配置合约参数
  console.log("\n⚙️ 正在配置合约参数...");
  
  // 设置税收分配比例
  console.log("📊 设置税收分配比例...");
  const taxTx = await token.setTaxDistribution(
    tokenConfig.liquidityShare,
    tokenConfig.burnShare,
    tokenConfig.treasuryShare
  );
  await taxTx.wait();
  console.log("✅ 税收分配设置完成");

  // 设置交易限制
  console.log("🛡️ 设置交易限制...");
  const limitTx = await token.updateTradingRestrictions(
    tokenConfig.maxTransaction,
    tokenConfig.maxWallet,
    tokenConfig.cooldown
  );
  await limitTx.wait();
  console.log("✅ 交易限制设置完成");

  // 验证配置
  console.log("\n🔍 验证合约配置...");
  
  const actualTaxRate = await token.taxRate();
  const actualLiquidityShare = await token.liquidityPoolShare();
  const actualMaxTx = await token.maxTransactionAmount();
  
  console.log("📊 实际税率:", actualTaxRate.toString(), "%");
  console.log("💧 流动性分配:", actualLiquidityShare.toString(), "%");
  console.log("📈 最大交易量:", ethers.utils.formatEther(actualMaxTx), "SSMT");

  // 保存部署信息到文件
  const deploymentInfo = {
    contractAddress: token.address,
    deployer: deployer.address,
    network: (await ethers.provider.getNetwork()).name,
    deploymentTime: new Date().toISOString(),
    config: tokenConfig
  };

  console.log("\n📁 部署信息已保存");
  console.log("🌐 网络:", deploymentInfo.network);
  console.log("⏰ 部署时间:", deploymentInfo.deploymentTime);

  // 输出使用说明
  console.log("\n🎯 部署完成！下一步操作:");
  console.log("1. 将流动性池地址设置为合约的流动性池");
  console.log("2. 将重要地址（如DEX路由器）排除在税收和限制之外");
  console.log("3. 测试代币转账和税收功能");
  console.log("4. 配置前端应用集成");

  return deploymentInfo;
}

// 错误处理
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ 部署失败:", error);
    process.exit(1);
  });

module.exports = { main };