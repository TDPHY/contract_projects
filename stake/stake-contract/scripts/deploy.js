const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

async function main() {
  console.log("🚀 Starting MetaNodeStake deployment...");

  // 从环境变量获取配置
  const MetaNodeToken = process.env.METANODE_TOKEN_ADDRESS;
  const startBlock = parseInt(process.env.START_BLOCK) || 6529999;
  const endBlock = parseInt(process.env.END_BLOCK) || 9529999;
  const MetaNodePerBlock = process.env.METANODE_PER_BLOCK || "20000000000000000";

  // 验证配置
  if (!MetaNodeToken) {
    throw new Error("METANODE_TOKEN_ADDRESS environment variable is required");
  }

  console.log("📋 Deployment Configuration:");
  console.log(`- MetaNode Token: ${MetaNodeToken}`);
  console.log(`- Start Block: ${startBlock}`);
  console.log(`- End Block: ${endBlock}`);
  console.log(`- MetaNode Per Block: ${MetaNodePerBlock}`);

  // 获取部署者账户
  const [deployer] = await ethers.getSigners();
  console.log(`👤 Deploying contracts with account: ${deployer.address}`);

  // 部署 MetaNodeStake 合约
  console.log("📦 Deploying MetaNodeStake...");
  const Stake = await ethers.getContractFactory("MetaNodeStake");
  
  const s = await upgrades.deployProxy(
    Stake,
    [MetaNodeToken, startBlock, endBlock, MetaNodePerBlock],
    { 
      initializer: "initialize",
      kind: "uups"
    }
  );

  await s.waitForDeployment();
  const stakeAddress = await s.getAddress();
  
  console.log("✅ MetaNodeStake deployed to:", stakeAddress);
  console.log("🔗 Proxy address:", stakeAddress);

  // 验证部署
  console.log("🔍 Verifying deployment...");
  const metaNode = await s.MetaNode();
  const startBlockActual = await s.startBlock();
  const endBlockActual = await s.endBlock();
  const metaNodePerBlockActual = await s.MetaNodePerBlock();

  console.log("✅ Deployment verified:");
  console.log(`- MetaNode Token: ${metaNode}`);
  console.log(`- Start Block: ${startBlockActual}`);
  console.log(`- End Block: ${endBlockActual}`);
  console.log(`- MetaNode Per Block: ${metaNodePerBlockActual}`);

  // 保存部署信息到文件
  const deploymentInfo = {
    network: "sepolia",
    timestamp: new Date().toISOString(),
    deployer: deployer.address,
    contracts: {
      MetaNodeStake: {
        address: stakeAddress,
        implementation: await upgrades.erc1967.getImplementationAddress(stakeAddress),
        proxy: stakeAddress,
        startBlock: startBlockActual.toString(),
        endBlock: endBlockActual.toString(),
        metaNodePerBlock: metaNodePerBlockActual.toString()
      },
      MetaNodeToken: {
        address: MetaNodeToken
      }
    }
  };

  const fs = require('fs');
  fs.writeFileSync('deployment-info.json', JSON.stringify(deploymentInfo, null, 2));
  
  console.log("📄 Deployment info saved to deployment-info.json");
  console.log("🎉 Deployment completed successfully!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });