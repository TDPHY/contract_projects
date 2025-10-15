const { ethers } = require("hardhat");

async function performanceTest() {
  console.log("⚡ Starting performance test...");
  
  const Stake = await ethers.getContractFactory("MetaNodeStake");
  const stakeAddress = process.env.STAKE_CONTRACT_ADDRESS;
  
  if (!stakeAddress) {
    console.log("❌ STAKE_CONTRACT_ADDRESS environment variable is required");
    return;
  }

  const stake = Stake.attach(stakeAddress);
  const [deployer] = await ethers.getSigners();

  console.log("📊 Performance Metrics:");

  // 测试质押操作
  console.log("🧪 Testing stake operation...");
  const stakeAmount = ethers.parseEther("0.1");
  
  const stakeStart = Date.now();
  try {
    const tx = await stake.stake(0, stakeAmount, { value: stakeAmount });
    const receipt = await tx.wait();
    const stakeEnd = Date.now();
    
    console.log(`✅ Stake operation: ${stakeEnd - stakeStart}ms`);
    console.log(`⛽ Gas used: ${receipt.gasUsed.toString()}`);
  } catch (error) {
    console.log("❌ Stake operation failed:", error.message);
  }

  // 测试奖励计算
  console.log("🧪 Testing reward calculation...");
  const rewardStart = Date.now();
  try {
    const pending = await stake.pendingMetaNode(0, deployer.address);
    const rewardEnd = Date.now();
    
    console.log(`✅ Reward calculation: ${rewardEnd - rewardStart}ms`);
    console.log(`💰 Pending rewards: ${pending.toString()}`);
  } catch (error) {
    console.log("❌ Reward calculation failed:", error.message);
  }

  // 测试解质押操作
  console.log("🧪 Testing withdraw operation...");
  const withdrawStart = Date.now();
  try {
    const tx = await stake.withdraw(0, stakeAmount);
    const receipt = await tx.wait();
    const withdrawEnd = Date.now();
    
    console.log(`✅ Withdraw operation: ${withdrawEnd - withdrawStart}ms`);
    console.log(`⛽ Gas used: ${receipt.gasUsed.toString()}`);
  } catch (error) {
    console.log("❌ Withdraw operation failed:", error.message);
  }

  console.log("📈 Performance test completed!");
}

performanceTest()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Performance test failed:", error);
    process.exit(1);
  });