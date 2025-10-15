// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Test, console2} from "forge-std/Test.sol";

import {MetaNodeStake} from "../contracts/MetaNodeStake.sol";
import {MockMetaNode} from "../contracts/shared/MockMetaNode.sol";
import {MockERC20} from "../contracts/shared/MockERC20.sol";

contract MetaNodeStakeTest is Test {
    MetaNodeStake public MetaNodeStake;
    MockMetaNode public MetaNode;
    MockERC20 public mockERC20;
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public admin = address(this);

    fallback() external payable {
    }

    receive() external payable {
    }

    function setUp() public {
        MetaNode = new MockMetaNode();
        mockERC20 = new MockERC20("TestToken", "TEST");
        MetaNodeStake = new MetaNodeStake();
        MetaNodeStake.initialize
        (
            MetaNode,
            100,
            100000000,
            3000000000000000000
        );
        
        // Fund test users
        MetaNode.mint(user1, 1000 ether);
        MetaNode.mint(user2, 1000 ether);
        mockERC20.mint(user1, 1000 ether);
        mockERC20.mint(user2, 1000 ether);
    }

    function test_AddPool() public {
        // Add nativeCurrency pool
        address _stTokenAddress = address(0x0);
        uint256 _poolWeight = 100;
        uint256 _minDepositAmount = 100;
        uint256 _withdrawLockedBlocks = 100;
        bool _withUpdate = true;

        MetaNodeStake.addPool(_stTokenAddress, _poolWeight, _minDepositAmount, _withdrawLockedBlocks, _withUpdate);

        (
          address stTokenAddress, 
          uint256 poolWeight, 
          uint256 lastRewardBlock,
          uint256 accMetaNodePerShare,
          uint256 stTokenAmount,
          uint256 minDepositAmount, 
          uint256 withdrawLockedBlocks
        )  = MetaNodeStake.pool(0);
        assertEq(stTokenAddress, _stTokenAddress);
        assertEq(poolWeight, _poolWeight);
        assertEq(minDepositAmount, _minDepositAmount);
        assertEq(withdrawLockedBlocks, _withdrawLockedBlocks);
        assertEq(stTokenAmount, 0);
        assertEq(lastRewardBlock, 100);
        assertEq(accMetaNodePerShare, 0);
    }

    function test_massUpdatePools() public {
        test_AddPool();
        MetaNodeStake.massUpdatePools();
        (
          address stTokenAddress, 
          uint256 poolWeight, 
          uint256 lastRewardBlock,
          uint256 accMetaNodePerShare,
          uint256 stTokenAmount,
          uint256 minDepositAmount, 
          uint256 withdrawLockedBlocks
        )  = MetaNodeStake.pool(0);
        assertEq(minDepositAmount, 100);
        assertEq(withdrawLockedBlocks, 100);
        assertEq(lastRewardBlock, 100);

        vm.roll(1000);
        MetaNodeStake.massUpdatePools();
        (
          stTokenAddress, 
          poolWeight, 
          lastRewardBlock,
          accMetaNodePerShare,
          stTokenAmount,
          minDepositAmount, 
          withdrawLockedBlocks
        )  = MetaNodeStake.pool(0);
        assertEq(minDepositAmount, 100);
        assertEq(withdrawLockedBlocks, 100);
        assertEq(lastRewardBlock, 1000);
    }

    function test_SetPoolWeight() public {
        test_AddPool();
        uint256 preTotalPoolWeight = MetaNodeStake.totalPoolWeight();
        
        
        MetaNodeStake.setPoolWeight(0, 200, false);
        (
          address stTokenAddress, 
          uint256 poolWeight, 
          uint256 lastRewardBlock,
          uint256 accMetaNodePerShare,
          uint256 stTokenAmount,
          uint256 minDepositAmount, 
          uint256 withdrawLockedBlocks
        )  = MetaNodeStake.pool(0);
        uint256 totalPoolWeight = MetaNodeStake.totalPoolWeight();
        uint256 expectedTotalPoolWeight = preTotalPoolWeight - 100 + 200;
        assertEq(poolWeight, 200);
        assertEq(totalPoolWeight, expectedTotalPoolWeight);
    }

    function test_DepositnativeCurrency() public {
        test_AddPool();
        (
          address stTokenAddress, 
          uint256 poolWeight, 
          uint256 lastRewardBlock,
          uint256 accMetaNodePerShare,
          uint256 stTokenAmount,
          uint256 minDepositAmount, 
          uint256 withdrawLockedBlocks
        ) = MetaNodeStake.pool(0);
        uint256 prePoolStTokenAmount = stTokenAmount;

        (
          uint256 stAmount,
          uint256 finishedMetaNode,
          uint256 pendingMetaNode
        ) = MetaNodeStake.user(0, address(this));
        uint256 preStAmount = stAmount;
        uint256 preFinishedMetaNode = finishedMetaNode;
        uint256 prePendingMetaNode = pendingMetaNode;

        // First deposit
        address(MetaNodeStake).call{value: 100}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );
        (
          stTokenAddress, 
          poolWeight, 
          lastRewardBlock,
          accMetaNodePerShare,
          stTokenAmount,
          minDepositAmount, 
          withdrawLockedBlocks
        )  = MetaNodeStake.pool(0);

        (
          stAmount,
          finishedMetaNode,
          pendingMetaNode
        ) = MetaNodeStake.user(0, address(this));

        uint256 expectedStAmount = preStAmount + 100;
        uint256 expectedFinishedMetaNode = preFinishedMetaNode;
        uint256 expectedTotoalStTokenAmount = prePoolStTokenAmount + 100;

        assertEq(stAmount, expectedStAmount);
        assertEq(finishedMetaNode, expectedFinishedMetaNode);
        assertEq(stTokenAmount, expectedTotoalStTokenAmount);

        // more deposit
        address(MetaNodeStake).call{value: 200 ether}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );

        vm.roll(2000000);
        MetaNodeStake.unstake(0, 100);
        address(MetaNodeStake).call{value: 300 ether}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );

        vm.roll(3000000);
        MetaNodeStake.unstake(0, 100);
        address(MetaNodeStake).call{value: 400 ether}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );

        vm.roll(4000000);
        MetaNodeStake.unstake(0, 100);
        address(MetaNodeStake).call{value: 500 ether}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );

        vm.roll(5000000);
        MetaNodeStake.unstake(0, 100);
        address(MetaNodeStake).call{value: 600 ether}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );

        vm.roll(6000000);
        MetaNodeStake.unstake(0, 100);
        address(MetaNodeStake).call{value: 700 ether}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );

        MetaNodeStake.withdraw(0);
    }

    function test_Unstake() public {
        test_DepositnativeCurrency();
        
        vm.roll(1000);
        MetaNodeStake.unstake(0, 100);

        (
          uint256 stAmount,
          uint256 finishedMetaNode,
          uint256 pendingMetaNode
        ) = MetaNodeStake.user(0, address(this));
        assertEq(stAmount, 0);
        assertEq(finishedMetaNode, 0);
        assertGt(pendingMetaNode, 0);

        (
          address stTokenAddress, 
          uint256 poolWeight, 
          uint256 lastRewardBlock,
          uint256 accMetaNodePerShare,
          uint256 stTokenAmount,
          uint256 minDepositAmount, 
          uint256 withdrawLockedBlocks
        ) = MetaNodeStake.pool(0);

        uint256 expectStTokenAmount = 0;
        assertEq(stTokenAmount, expectStTokenAmount);
    }

    function test_Withdraw() public {
        test_Unstake();
        uint256 preContractBalance = address(MetaNodeStake).balance;
        uint256 preUserBalance = address(this).balance;
      
        vm.roll(10000);
        MetaNodeStake.withdraw(0);

        uint256 postContractBalance = address(MetaNodeStake).balance;
        uint256 postUserBalance = address(this).balance;
        assertLt(postContractBalance, preContractBalance);
        assertGt(postUserBalance, preUserBalance);
    }

    function test_ClaimAfterDeposit() public {
        test_DepositnativeCurrency();
        MetaNode.transfer(address(MetaNodeStake), 100000000000);
        uint256 preUserMetaNodeBalance = MetaNode.balanceOf(address(this));

        vm.roll(10000);
        MetaNodeStake.claim(0);

        uint256 postUserMetaNodeBalance = MetaNode.balanceOf(address(this));
        assertGt(postUserMetaNodeBalance, preUserMetaNodeBalance);
    }

    function test_ClaimAfterUnstake() public {
        test_Unstake();
        MetaNode.transfer(address(MetaNodeStake), 100000000000);
        uint256 preUserMetaNodeBalance = MetaNode.balanceOf(address(this));

        vm.roll(10000);
        MetaNodeStake.claim(0);

        uint256 postUserMetaNodeBalance = MetaNode.balanceOf(address(this));
        assertGt(postUserMetaNodeBalance, preUserMetaNodeBalance);
    }

    function test_ClaimAfterWithdraw() public {
        test_Withdraw();
        MetaNode.transfer(address(MetaNodeStake), 100000000000);
        uint256 preUserMetaNodeBalance = MetaNode.balanceOf(address(this));

        vm.roll(10000);
        MetaNodeStake.claim(0);

        uint256 postUserMetaNodeBalance = MetaNode.balanceOf(address(this));
        assertGt(postUserMetaNodeBalance, preUserMetaNodeBalance);
    }

    function addPool(uint256 index, address stTokenAddress) public {
        address _stTokenAddress = stTokenAddress;
        uint256 _poolWeight = 100;
        uint256 _minDepositAmount = 100;
        uint256 _withdrawLockedBlocks = 100;
        bool _withUpdate = true;

        MetaNodeStake.addPool(_stTokenAddress, _poolWeight, _minDepositAmount, _withdrawLockedBlocks, _withUpdate);
    }

    // ERC20代币质押池测试
    function test_AddERC20Pool() public {
        address _stTokenAddress = address(mockERC20);
        uint256 _poolWeight = 200;
        uint256 _minDepositAmount = 50;
        uint256 _withdrawLockedBlocks = 200;
        bool _withUpdate = true;

        MetaNodeStake.addPool(_stTokenAddress, _poolWeight, _minDepositAmount, _withdrawLockedBlocks, _withUpdate);

        (
          address stTokenAddress, 
          uint256 poolWeight, 
          uint256 lastRewardBlock,
          uint256 accMetaNodePerShare,
          uint256 stTokenAmount,
          uint256 minDepositAmount, 
          uint256 withdrawLockedBlocks
        )  = MetaNodeStake.pool(1);
        assertEq(stTokenAddress, _stTokenAddress);
        assertEq(poolWeight, _poolWeight);
        assertEq(minDepositAmount, _minDepositAmount);
        assertEq(withdrawLockedBlocks, _withdrawLockedBlocks);
    }

    function test_DepositERC20() public {
        test_AddERC20Pool();
        
        // 授权合约使用代币
        vm.prank(user1);
        mockERC20.approve(address(MetaNodeStake), 1000 ether);

        // 质押ERC20代币
        vm.prank(user1);
        MetaNodeStake.deposit(1, 100 ether);

        // 检查质押余额
        uint256 stakedAmount = MetaNodeStake.stakingBalance(1, user1);
        assertEq(stakedAmount, 100 ether);
    }

    function test_UnstakeERC20() public {
        test_DepositERC20();
        
        vm.prank(user1);
        MetaNodeStake.unstake(1, 50 ether);

        uint256 stakedAmount = MetaNodeStake.stakingBalance(1, user1);
        assertEq(stakedAmount, 50 ether);
    }

    function test_WithdrawERC20() public {
        test_UnstakeERC20();
        
        // 等待解锁期
        vm.roll(block.number + 201);
        
        uint256 preBalance = mockERC20.balanceOf(user1);
        vm.prank(user1);
        MetaNodeStake.withdraw(1);
        uint256 postBalance = mockERC20.balanceOf(user1);
        
        assertGt(postBalance, preBalance);
    }

    // 边界条件测试
    function test_DepositBelowMinimum() public {
        test_AddPool();
        
        // 尝试质押低于最小金额
        vm.expectRevert();
        address(MetaNodeStake).call{value: 50}(
            abi.encodeWithSignature("depositETH()")
        );
    }

    function test_UnstakeMoreThanStaked() public {
        test_DepositnativeCurrency();
        
        vm.expectRevert();
        MetaNodeStake.unstake(0, 1000 ether); // 尝试解质押超过质押数量
    }

    function test_WithdrawBeforeUnlock() public {
        test_Unstake();
        
        // 尝试在解锁前提取
        vm.expectRevert();
        MetaNodeStake.withdraw(0);
    }

    function test_ClaimWithNoRewards() public {
        test_AddPool();
        
        // 没有质押的情况下尝试领取奖励
        uint256 preBalance = MetaNode.balanceOf(user1);
        vm.prank(user1);
        MetaNodeStake.claim(0);
        uint256 postBalance = MetaNode.balanceOf(user1);
        
        assertEq(postBalance, preBalance); // 余额应该不变
    }

    // 权限测试
    function test_OnlyAdminCanAddPool() public {
        vm.prank(user1);
        vm.expectRevert();
        MetaNodeStake.addPool(address(mockERC20), 100, 100, 100, true);
    }

    function test_OnlyAdminCanPause() public {
        vm.prank(user1);
        vm.expectRevert();
        MetaNodeStake.pauseWithdraw();
    }

    // 多用户测试
    function test_MultipleUsersStaking() public {
        test_AddPool();
        
        // 用户1质押
        vm.deal(user1, 1000 ether);
        vm.prank(user1);
        address(MetaNodeStake).call{value: 100 ether}(
            abi.encodeWithSignature("depositETH()")
        );

        // 用户2质押
        vm.deal(user2, 1000 ether);
        vm.prank(user2);
        address(MetaNodeStake).call{value: 200 ether}(
            abi.encodeWithSignature("depositETH()")
        );

        // 检查总质押量
        (, , , , uint256 totalStaked, , ) = MetaNodeStake.pool(0);
        assertEq(totalStaked, 300 ether);

        // 检查用户质押量
        uint256 user1Staked = MetaNodeStake.stakingBalance(0, user1);
        uint256 user2Staked = MetaNodeStake.stakingBalance(0, user2);
        assertEq(user1Staked, 100 ether);
        assertEq(user2Staked, 200 ether);
    }

    // 奖励计算测试
    function test_RewardCalculation() public {
        test_DepositnativeCurrency();
        
        // 转移一些奖励代币到合约
        MetaNode.transfer(address(MetaNodeStake), 1000 ether);
        
        // 前进一些区块
        vm.roll(block.number + 1000);
        
        // 检查待领取奖励
        uint256 pendingReward = MetaNodeStake.pendingMetaNode(0, address(this));
        assertGt(pendingReward, 0);
        
        // 领取奖励
        uint256 preBalance = MetaNode.balanceOf(address(this));
        MetaNodeStake.claim(0);
        uint256 postBalance = MetaNode.balanceOf(address(this));
        
        assertGt(postBalance, preBalance);
    }

    // 池权重更新测试
    function test_PoolWeightUpdateAffectsRewards() public {
        test_DepositnativeCurrency();
        test_AddERC20Pool();
        
        // 质押到两个池
        vm.deal(user1, 1000 ether);
        vm.prank(user1);
        address(MetaNodeStake).call{value: 100 ether}(
            abi.encodeWithSignature("depositETH()")
        );
        
        vm.prank(user1);
        mockERC20.approve(address(MetaNodeStake), 1000 ether);
        vm.prank(user1);
        MetaNodeStake.deposit(1, 100 ether);
        
        // 检查初始奖励分配
        uint256 ethPoolReward = MetaNodeStake.pendingMetaNode(0, user1);
        uint256 erc20PoolReward = MetaNodeStake.pendingMetaNode(1, user1);
        
        // 更新池权重
        MetaNodeStake.setPoolWeight(1, 400, true);
        
        // 前进区块
        vm.roll(block.number + 1000);
        
        // 检查新的奖励分配
        uint256 newEthPoolReward = MetaNodeStake.pendingMetaNode(0, user1);
        uint256 newErc20PoolReward = MetaNodeStake.pendingMetaNode(1, user1);
        
        // ERC20池的奖励应该增加更多
        assertGt(newErc20PoolReward - erc20PoolReward, newEthPoolReward - ethPoolReward);
    }
}