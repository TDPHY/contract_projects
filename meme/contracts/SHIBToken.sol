// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title SHIB风格Meme代币合约
 * @dev 实现代币税机制、流动性池集成和交易限制功能
 * 基于ERC20标准，集成SHIB代币的经济模型特性
 */
contract SHIBToken is ERC20, Ownable {
    using SafeMath for uint256;
    
    // 代币税相关参数
    uint256 public taxRate = 5; // 默认5%交易税
    uint256 public constant MAX_TAX_RATE = 10; // 最大税率10%
    
    // 税收分配比例
    uint256 public liquidityPoolShare = 40; // 40%注入流动性池
    uint256 public burnShare = 30; // 30%代币销毁
    uint256 public treasuryShare = 30; // 30%进入国库
    
    // 流动性池地址
    address public liquidityPool;
    address public treasuryWallet;
    
    // 交易限制参数
    uint256 public maxTransactionAmount = 1000000 * 10**18; // 单笔最大交易量
    uint256 public maxWalletBalance = 5000000 * 10**18; // 单个钱包最大持币量
    uint256 public cooldownPeriod = 300; // 交易冷却时间（秒）
    
    // 交易记录
    mapping(address => uint256) private _lastTransactionTime;
    mapping(address => bool) private _isExcludedFromTax;
    mapping(address => bool) private _isExcludedFromLimit;
    
    // 事件定义
    event TaxApplied(address indexed from, uint256 amount, uint256 taxAmount);
    event LiquidityAdded(uint256 tokenAmount, uint256 ethAmount);
    event TradingRestrictionsUpdated(uint256 maxTx, uint256 maxWallet, uint256 cooldown);
    
    /**
     * @dev 构造函数，初始化代币
     * @param name 代币名称
     * @param symbol 代币符号
     * @param initialSupply 初始供应量
     * @param treasury 国库地址
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address treasury
    ) ERC20(name, symbol) {
        require(treasury != address(0), "Invalid treasury address");
        
        treasuryWallet = treasury;
        
        // 将合约创建者和国库地址排除在交易限制之外
        _isExcludedFromTax[msg.sender] = true;
        _isExcludedFromTax[treasury] = true;
        _isExcludedFromLimit[msg.sender] = true;
        _isExcludedFromLimit[treasury] = true;
        
        // 铸造初始供应量给合约创建者
        _mint(msg.sender, initialSupply);
    }
    
    /**
     * @dev 重写transfer函数，应用代币税和交易限制
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        _validateTransfer(msg.sender, to, amount);
        
        if (_isExcludedFromTax[msg.sender] || _isExcludedFromTax[to]) {
            // 排除地址不征税
            super.transfer(to, amount);
        } else {
            // 应用代币税
            uint256 taxAmount = amount.mul(taxRate).div(100);
            uint256 transferAmount = amount.sub(taxAmount);
            
            // 执行转账
            super.transfer(to, transferAmount);
            
            // 处理税收
            _processTax(msg.sender, taxAmount);
            
            emit TaxApplied(msg.sender, amount, taxAmount);
        }
        
        return true;
    }
    
    /**
     * @dev 重写transferFrom函数，应用代币税和交易限制
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        _validateTransfer(from, to, amount);
        
        if (_isExcludedFromTax[from] || _isExcludedFromTax[to]) {
            // 排除地址不征税
            super.transferFrom(from, to, amount);
        } else {
            // 应用代币税
            uint256 taxAmount = amount.mul(taxRate).div(100);
            uint256 transferAmount = amount.sub(taxAmount);
            
            // 执行转账
            super.transferFrom(from, to, transferAmount);
            
            // 处理税收
            _processTax(from, taxAmount);
            
            emit TaxApplied(from, amount, taxAmount);
        }
        
        return true;
    }
    
    /**
     * @dev 验证交易是否符合限制条件
     */
    function _validateTransfer(address from, address to, uint256 amount) internal {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        
        // 检查交易限制（排除地址不受限制）
        if (!_isExcludedFromLimit[from] && !_isExcludedFromLimit[to]) {
            require(amount <= maxTransactionAmount, "Exceeds max transaction amount");
            require(balanceOf(to).add(amount) <= maxWalletBalance, "Exceeds max wallet balance");
            
            // 检查交易冷却时间
            require(
                block.timestamp >= _lastTransactionTime[from].add(cooldownPeriod),
                "Cooldown period not elapsed"
            );
            
            _lastTransactionTime[from] = block.timestamp;
        }
    }
    
    /**
     * @dev 处理税收分配
     */
    function _processTax(address from, uint256 taxAmount) internal {
        if (taxAmount == 0) return;
        
        // 计算分配金额
        uint256 liquidityAmount = taxAmount.mul(liquidityPoolShare).div(100);
        uint256 burnAmount = taxAmount.mul(burnShare).div(100);
        uint256 treasuryAmount = taxAmount.sub(liquidityAmount).sub(burnAmount);
        
        // 执行分配
        if (burnAmount > 0) {
            _burn(from, burnAmount);
        }
        
        if (treasuryAmount > 0) {
            super.transfer(treasuryWallet, treasuryAmount);
        }
        
        if (liquidityAmount > 0 && liquidityPool != address(0)) {
            super.transfer(liquidityPool, liquidityAmount);
        }
    }
    
    /**
     * @dev 设置流动性池地址
     */
    function setLiquidityPool(address pool) external onlyOwner {
        require(pool != address(0), "Invalid liquidity pool address");
        liquidityPool = pool;
        _isExcludedFromTax[pool] = true;
        _isExcludedFromLimit[pool] = true;
    }
    
    /**
     * @dev 设置税率（仅管理员）
     */
    function setTaxRate(uint256 newRate) external onlyOwner {
        require(newRate <= MAX_TAX_RATE, "Tax rate too high");
        taxRate = newRate;
    }
    
    /**
     * @dev 设置税收分配比例
     */
    function setTaxDistribution(
        uint256 liquidityShare,
        uint256 burnShare_,
        uint256 treasuryShare_
    ) external onlyOwner {
        require(liquidityShare.add(burnShare_).add(treasuryShare_) == 100, "Shares must sum to 100");
        
        liquidityPoolShare = liquidityShare;
        burnShare = burnShare_;
        treasuryShare = treasuryShare_;
    }
    
    /**
     * @dev 更新交易限制参数
     */
    function updateTradingRestrictions(
        uint256 maxTx,
        uint256 maxWallet,
        uint256 cooldown
    ) external onlyOwner {
        require(maxTx > 0, "Max transaction must be greater than zero");
        require(maxWallet > 0, "Max wallet must be greater than zero");
        
        maxTransactionAmount = maxTx;
        maxWalletBalance = maxWallet;
        cooldownPeriod = cooldown;
        
        emit TradingRestrictionsUpdated(maxTx, maxWallet, cooldown);
    }
    
    /**
     * @dev 排除地址从税收和限制
     */
    function excludeFromTaxAndLimit(address account, bool excluded) external onlyOwner {
        _isExcludedFromTax[account] = excluded;
        _isExcludedFromLimit[account] = excluded;
    }
    
    /**
     * @dev 手动添加流动性（模拟功能）
     */
    function manualAddLiquidity(uint256 tokenAmount, uint256 ethAmount) external payable onlyOwner {
        require(liquidityPool != address(0), "Liquidity pool not set");
        require(msg.value == ethAmount, "ETH amount mismatch");
        
        // 在实际实现中，这里会调用DEX路由器的addLiquidityETH函数
        // 这里简化为直接转账到流动性池
        super.transfer(liquidityPool, tokenAmount);
        payable(liquidityPool).transfer(ethAmount);
        
        emit LiquidityAdded(tokenAmount, ethAmount);
    }
    
    /**
     * @dev 获取地址是否被排除
     */
    function isExcludedFromTax(address account) external view returns (bool) {
        return _isExcludedFromTax[account];
    }
    
    function isExcludedFromLimit(address account) external view returns (bool) {
        return _isExcludedFromLimit[account];
    }
    
    /**
     * @dev 获取最后一次交易时间
     */
    function getLastTransactionTime(address account) external view returns (uint256) {
        return _lastTransactionTime[account];
    }
    
    /**
     * @dev 紧急停止交易（仅管理员）
     */
    function emergencyPause() external onlyOwner {
        maxTransactionAmount = 0;
        cooldownPeriod = type(uint256).max;
    }
    
    /**
     * @dev 恢复交易
     */
    function resumeTrading(uint256 maxTx, uint256 cooldown) external onlyOwner {
        maxTransactionAmount = maxTx;
        cooldownPeriod = cooldown;
    }
}