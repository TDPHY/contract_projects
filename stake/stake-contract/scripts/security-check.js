const { ethers } = require("hardhat");

async function main() {
  console.log("🔒 Starting security check...");
  
  // 获取合约实例
  const Stake = await ethers.getContractFactory("MetaNodeStake");
  const stakeAddress = process.env.STAKE_CONTRACT_ADDRESS;
  
  if (!stakeAddress) {
    console.log("❌ STAKE_CONTRACT_ADDRESS environment variable is required");
    return;
  }

  const stake = Stake.attach(stakeAddress);
  
  console.log("📋 Security Checklist:");
  
  // 1. 检查管理员权限
  try {
    const owner = await stake.owner();
    console.log(`✅ Owner: ${owner}`);
  } catch (error) {
    console.log("❌ Failed to get owner:", error.message);
  }

  // 2. 检查暂停状态
  try {
    const paused = await stake.paused();
    console.log(`✅ Paused status: ${paused}`);
  } catch (error) {
    console.log("❌ Failed to get paused status:", error.message);
  }

  // 3. 检查池数量
  try {
    const poolLength = await stake.poolLength();
    console.log(`✅ Pool length: ${poolLength}`);
  } catch (error) {
    console.log("❌ Failed to get pool length:", error.message);
  }

  // 4. 检查代币地址
  try {
    const metaNode = await stake.MetaNode();
    console.log(`✅ MetaNode token: ${metaNode}`);
  } catch (error) {
    console.log("❌ Failed to get MetaNode token:", error.message);
  }

  // 5. 检查区块设置
  try {
    const startBlock = await stake.startBlock();
    const endBlock = await stake.endBlock();
    console.log(`✅ Start block: ${startBlock}`);
    console.log(`✅ End block: ${endBlock}`);
  } catch (error) {
    console.log("❌ Failed to get block settings:", error.message);
  }

  console.log("🔍 Security check completed!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Security check failed:", error);
    process.exit(1);
  });