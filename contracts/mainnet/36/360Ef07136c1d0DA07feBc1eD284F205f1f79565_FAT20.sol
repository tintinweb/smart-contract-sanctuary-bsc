// SPDX-License-Identifier: MIT
/*

*/
pragma solidity ^0.8.7;

import "./Ownable.sol";
import "./ERC20.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";
import "./RewardDistributor.sol"; 

contract FAT20 is ERC20, Ownable {
    string constant _name = "FAT20 Token";
    string constant _symbol = "FAT20";
    uint8 constant _decimals = 18;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 _totalSupply = 100_000_000_000 * (10**_decimals);

    IUniswapV2Router02 public router;
    address public _routerAddress;
    address public pair;

    // Fee percentage
    uint256 public denominator = 10000;
    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public distributorGas = 300000;
    // sell cooldown
    uint256 public sellCooldown = 4 days;
    // swap enable
    bool public swapEnabled = true;

    uint256 public maxWalletSize = 2500; // 25% out of total supply
    uint256 public maxTxSize = 2500; // 25% out of wallet size
    uint256 public sellTriggerLimit = 1000; // 10% out of wallet size
    uint256 public additionalFee = 500; // 5% fee added when consecutive sells

    struct Fees {
        uint256 operationFee;
        uint256 rewardFee;
        uint256 premiumRewardFee;
        uint256 liquidityFee;
    }

    Fees public buyFees = Fees(200, 100, 300, 100);
    Fees public sellFees = Fees(400, 200, 800, 100);
    Fees public transferFees = Fees(50, 50, 150, 50);

    // threshold for token stored on the smart contract
    uint256 public _tokenThreshold = 500 * (10**_decimals);

    mapping(address => bool) public _isProtected;
    mapping(address => bool) public _isBlacklisted;
    mapping(address => bool) public _isFeeExempt;
    mapping(address => bool) public _isTxLimitExempt;
    mapping(address => bool) public _isDividendExempt;

    // for token lock
    mapping(address => bool) public _isTokenLocked;

    // for vesting period
    mapping(address => uint256) public _lastSellTime;
    mapping(address => uint256) public _currentSellCount;

    RewardDistributor public rewardDistributor;
    RewardDistributor public premiumRewardDistributor;
    address public _rewardAddress;
    address public _premiumRewardAddress;

    address public operator;
    address public treasury;
    address public rewardToken;
    address public governToken;

    // swapping check variable
    bool _isInSwap;

    // fee amounts stored on the smart contract
    uint256 public _operationFeeAmount;
    uint256 public _rewardFeeAmount;
    uint256 public _premiumRewardFeeAmount;
    uint256 public _liquidityFeeAmount;

    // stats count
    uint256 public blacklistedCount;
    uint256 public protectedCount;
    uint256 public lockedCount;

    constructor(address routerAddress, address operatorAddress, address rewardTokenAddress, address treasuryAddress) ERC20(_name, _symbol) {
        _routerAddress = routerAddress;
        operator = operatorAddress;
        rewardToken = rewardTokenAddress;
        treasury = treasuryAddress;

        router = IUniswapV2Router02(routerAddress);
        governToken = router.WETH();
        pair = IUniswapV2Factory(router.factory()).createPair(router.WETH(), address(this));

        rewardDistributor = new RewardDistributor(rewardToken, treasury, address(this), routerAddress);
        premiumRewardDistributor = new RewardDistributor(rewardToken, treasury, address(this), routerAddress);
        _rewardAddress = address(rewardDistributor);
        _premiumRewardAddress = address(premiumRewardDistributor);

        // fee exempt
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[operatorAddress] = true;
        _isFeeExempt[owner()] = true;
        _isFeeExempt[address(rewardDistributor)] = true;
        _isFeeExempt[address(premiumRewardDistributor)] = true;

        // dividend exempt
        _isDividendExempt[address(this)] = true;
        _isDividendExempt[address(rewardDistributor)] = true;
        _isDividendExempt[address(premiumRewardDistributor)] = true;
        _isDividendExempt[address(router)] = true;
        _isDividendExempt[owner()] = true;
        _isDividendExempt[DEAD] = true;

        // tx limit exempt
        _isTxLimitExempt[address(this)] = true;
        _isTxLimitExempt[address(rewardDistributor)] = true;
        _isTxLimitExempt[address(premiumRewardDistributor)] = true;
        _isTxLimitExempt[address(router)] = true;
        _isTxLimitExempt[owner()] = true;
        _isTxLimitExempt[DEAD] = true;

        _mint(owner(), _totalSupply);
    }

    // internal functions
    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != to, "FAT20: you can't transfer to yourself");
        require(from != address(0), "FAT20: transfer can't be done from zero address");
        require(to != address(0), "FAT20: transfer can't be done to zero address");
        require(amount > 0, "FAT20: amount should be greater than zero");
        require(_isBlacklisted[from] == false, "FAT20: from is blacklisted");
        require(_isBlacklisted[to] == false, "FAT20: to is blacklisted");
        require(!_isTokenLocked[from] && !_isProtected[from], "FAT20: from is locked");
        // when swapping, just do the normal transfer.
        if (_isInSwap) {
            super._transfer(from, to, amount);
            return;
        }

        // determine transaction type
        bool isSell = to == pair || to == _routerAddress;
        bool isBuy = !isSell && (from == pair || from == _routerAddress);
        bool isTransfer = !isSell && !isBuy;

        if(!isBuy) {
            require(!_isTokenLocked[to] && !_isProtected[to], "FAT20: to is locked");
        }

        if(!_isTxLimitExempt[from]) {
            checkTxSize(amount);
            if(isBuy)checkWalletSize(from, amount);
        }
        if(!_isTxLimitExempt[to] && isTransfer) {
            checkWalletSize(to, amount);
        }

        if (!_isFeeExempt[from]) {
            Fees memory currentFees;
            uint256 totalFee;
            if (isSell) {
                currentFees = sellFees;
                // Adaptive Shock Protection
                if((block.timestamp - _lastSellTime[from] < sellCooldown) && checkConsecutiveSellTriggered(from, amount)) {
                    _currentSellCount[from] += 1;
                    // add additional fee
                    currentFees.liquidityFee += _currentSellCount[from] * additionalFee / 4;
                    currentFees.operationFee += _currentSellCount[from] * additionalFee / 4;
                    currentFees.premiumRewardFee += _currentSellCount[from] * additionalFee / 4;
                    currentFees.rewardFee += _currentSellCount[from] * additionalFee / 4;
                } else {
                    _currentSellCount[from] = 0;
                }
                _lastSellTime[from] = block.timestamp;

            } else if (isBuy) {
                currentFees = buyFees;
            } else if (isTransfer) {
                currentFees = transferFees;
            }

            totalFee = currentFees.liquidityFee + currentFees.operationFee + currentFees.premiumRewardFee + currentFees.rewardFee;

            uint256 feeAmount = (amount * totalFee) / denominator;
            uint256 operationFee = (amount * currentFees.operationFee) / denominator;
            uint256 rewardFee = (amount * currentFees.rewardFee) / denominator;
            uint256 premiumRewardFee = (amount * currentFees.premiumRewardFee) / denominator;
            uint256 liquidityFee = feeAmount - operationFee - rewardFee - premiumRewardFee;
            amount -= feeAmount;

            uint256 normalShareholders = rewardDistributor.getNumberOfHolders();
            uint256 premiumShareholders = premiumRewardDistributor.getNumberOfHolders();

            _operationFeeAmount += operationFee;
            _liquidityFeeAmount += liquidityFee;

            if (normalShareholders == 0) {
                _operationFeeAmount += rewardFee;
            } else {
                _rewardFeeAmount += rewardFee;
            }
            if (premiumShareholders == 0) {
                _operationFeeAmount += premiumRewardFee;
            } else {
                _premiumRewardFeeAmount += premiumRewardFee;
            }
            super._transfer(from, address(this), feeAmount);
            if(shouldSwapBack()) {
                handleOperationFee();
                handleLiquidityFee();
                handlePremiumRewardFee();
                handleRewardFee();
            }
        }

        super._transfer(from, to, amount);

        if (!_isDividendExempt[from]) {
            try rewardDistributor.setShares(from, balanceOf(from)) {} catch {}
        }
        if (!_isDividendExempt[to]) {
            if(_isTokenLocked[to] || _isProtected[to]) {
                try premiumRewardDistributor.setShares(to, balanceOf(to)) {} catch {}    
            } else {
                try rewardDistributor.setShares(to, balanceOf(to)) {} catch {}
            }
        }

        try rewardDistributor.process(distributorGas) {} catch {}
        try premiumRewardDistributor.process(distributorGas) {} catch {}
    }

    function handlePremiumRewardFee() internal {
        if (_premiumRewardFeeAmount >= _tokenThreshold) {
            uint256 initialBalance = address(this).balance;
            swapTokensForETH(_premiumRewardFeeAmount);
            uint256 increasedAmount = address(this).balance - initialBalance;
            if (increasedAmount > 0) {
                _premiumRewardFeeAmount = 0;
                premiumRewardDistributor.deposit{ value: increasedAmount }();
            }
        }
    }

    function handleRewardFee() internal {
        if (_rewardFeeAmount >= _tokenThreshold) {
            uint256 initialBalance = address(this).balance;
            swapTokensForETH(_rewardFeeAmount);
            uint256 increasedAmount = address(this).balance - initialBalance;
            if (increasedAmount > 0) {
                _rewardFeeAmount = 0;
                rewardDistributor.deposit{ value: increasedAmount }();
            }
        }
    }

    function handleLiquidityFee() internal {
        if (_liquidityFeeAmount >= _tokenThreshold) {
            uint256 swapTokenAmount = _liquidityFeeAmount / 2;
            uint256 restTokenAmount = _liquidityFeeAmount - swapTokenAmount;

            uint256 initialETHBalance = address(this).balance;
            swapTokensForETH(swapTokenAmount);
            uint256 finalETHBalance = address(this).balance;
            uint256 diffETHBalance = finalETHBalance - initialETHBalance;

            if (diffETHBalance > 0) {
                addLiquidity(restTokenAmount, diffETHBalance);
                _liquidityFeeAmount = 0;
            }
        }
    }

    function handleOperationFee() internal {
        if (_operationFeeAmount >= _tokenThreshold) {
            uint256 increasedAmount = getIncreasedRewardAmount(_operationFeeAmount);            
            if (increasedAmount > 0) {
                _operationFeeAmount = 0;
                transferReward(operator, increasedAmount);
            }
        }
    }

    function getIncreasedRewardAmount(uint256 feeAmount) internal returns(uint256) {
        uint256 initialBalance = (rewardToken == governToken) ? address(this).balance : IERC20(rewardToken).balanceOf(address(this));
        if(rewardToken == governToken)
            swapTokensForETH(feeAmount);
        else 
            swapTokensForReward(feeAmount);
        uint256 finalBalance = (rewardToken == governToken) ? address(this).balance : IERC20(rewardToken).balanceOf(address(this));
        return finalBalance - initialBalance;
    }

    function transferReward(address to, uint256 rewardBalance) internal {
        if(rewardToken == governToken)
            payable(to).transfer(rewardBalance);
        else
            IERC20(rewardToken).transfer(to, rewardBalance);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), _routerAddress, tokenAmount);
        // add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }

    function swapTokensForETH(uint256 tokenAmount) private swapping {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), _routerAddress, tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForReward(uint256 tokenAmount) private swapping {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = rewardToken;

        _approve(address(this), _routerAddress, tokenAmount);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function unsetTokenLocked() external {
        require(_isTokenLocked[msg.sender], "FAT20: token is not even locked yet");
        require(!_isDividendExempt[msg.sender], "FAT20: sender is exempt from reward");

        handleUnsetTokenLocked(msg.sender);
    } 

    function handleUnsetTokenLocked(address shareholder) internal {
        lockedCount -= 1;
        _isTokenLocked[shareholder] = false;
        premiumRewardDistributor.claimRewards(shareholder);
        bool isReinvest = premiumRewardDistributor.getReinvest(shareholder);
        premiumRewardDistributor.setReinvest(shareholder, false);
        rewardDistributor.setReinvest(shareholder, isReinvest);

        rewardDistributor.setShares(shareholder, balanceOf(shareholder));
        premiumRewardDistributor.setShares(shareholder, 0);
    }

    function shouldSwapBack() internal view returns (bool) { // need to be modifed to internal
        return msg.sender != pair && !_isInSwap && swapEnabled;
    }

    function checkWalletSize(address shareholder, uint256 amount) internal view {
        uint256 walletSize = _totalSupply * maxWalletSize / denominator;
        require(walletSize > amount + balanceOf(shareholder), "FAT20: Exceeded max wallet size");
    }

    function checkTxSize(uint256 amount) internal view {
        uint256 walletSize = _totalSupply * maxWalletSize / denominator;
        uint256 txLimit = walletSize * maxTxSize / denominator;
        require(txLimit > amount, "FAT20: Exceeded max transaction size");
    }

    function checkConsecutiveSellTriggered(address shareholder, uint256 amount) internal view returns (bool) {
        uint256 walletSize = balanceOf(shareholder);
        uint256 txTriggerLimit = walletSize * sellTriggerLimit / denominator;
        if(amount > txTriggerLimit)
            return true;
        return false;
    }

    // external functions
    function setTokenLocked() public {
        require(!_isTokenLocked[msg.sender], "FAT20: token is already locked");
        require(!_isDividendExempt[msg.sender], "FAT20: sender is exempt from reward");
        _isTokenLocked[msg.sender] = true;
        lockedCount += 1;
        rewardDistributor.claimRewards(msg.sender);
        bool isReinvest = rewardDistributor.getReinvest(msg.sender);
        rewardDistributor.setReinvest(msg.sender, false);
        premiumRewardDistributor.setReinvest(msg.sender, isReinvest);
        premiumRewardDistributor.setShares(msg.sender, balanceOf(msg.sender));
        rewardDistributor.setShares(msg.sender, 0);
    }

    function claimRewards() external {
        require(!_isDividendExempt[msg.sender], "FAT20: sender is exempt from rewards");

        if (_isTokenLocked[msg.sender]) {
            premiumRewardDistributor.claimRewards(msg.sender);
        } else {
            rewardDistributor.claimRewards(msg.sender);
        }
    }

    function setReinvest(bool newIsReinvest) external {
        require(!_isDividendExempt[msg.sender], "FAT20: sender is exempt from rewards");

        if(_isTokenLocked[msg.sender]) {
            premiumRewardDistributor.setReinvest(msg.sender, newIsReinvest);
        } else {
            rewardDistributor.setReinvest(msg.sender, newIsReinvest);
        }
    }

    function getReinvest(address shareholder) external view returns(bool) {
        require(!_isDividendExempt[msg.sender], "FAT20: sender is exempt from rewards");
        
        bool isReinvested = false;
        if(_isTokenLocked[msg.sender]) {
            isReinvested = premiumRewardDistributor.getReinvest(shareholder);
        } else {
            isReinvested = rewardDistributor.getReinvest(shareholder);
        }
        return isReinvested;
    }

    function getTotalClaimed(address shareholder) external view returns (uint256) {
        uint256 premiumTotalClaimed = premiumRewardDistributor.getTotalClaimed(shareholder);
        uint256 totalClaimed = rewardDistributor.getTotalClaimed(shareholder);
        return premiumTotalClaimed + totalClaimed;
    }

    function getClaimableReward(address shareholder) external view returns (uint256) {
        if(_isTokenLocked[msg.sender]) {
            return premiumRewardDistributor.getClaimableReward(shareholder);
        }
        return rewardDistributor.getClaimableReward(shareholder);
    }

    function enableProtection() external {
        require(!_isProtected[msg.sender], "FAT20: shareholder is already protected");
        _isProtected[msg.sender] = true;
        protectedCount += 1;
        setTokenLocked();
    }

    function isLocked(address shareholder) external view returns(bool) {
        return _isTokenLocked[shareholder];
    }

    function isProtected(address shareholder) external view returns(bool) {
        return _isProtected[shareholder];
    }

    // only owner functions
    function disableProtection(address shareholder) external onlyOwner {
        require(_isProtected[shareholder], "FAT20: shareholder is not protected yet");
        _isProtected[shareholder] = false;
        protectedCount -= 1;
        handleUnsetTokenLocked(shareholder);
    }

    function setDividendExempt(address shareholder) external onlyOwner {
        require(!_isDividendExempt[shareholder], "FAT20: shareholder is already blacklisted");
        _isDividendExempt[shareholder] = true;

        try rewardDistributor.setShares(shareholder, 0) {} catch {}
        try premiumRewardDistributor.setShares(shareholder, 0) {} catch {}
    }

    function unsetDividendExempt(address shareholder) external onlyOwner {
        require(_isDividendExempt[shareholder], "FAT20: shareholder is not exempt from rewards");
        _isDividendExempt[shareholder] = false;
        try rewardDistributor.setShares(shareholder, balanceOf(shareholder)) {} catch {}
    }

    function setBlacklisted(address shareholder) external onlyOwner {
        require(!_isBlacklisted[shareholder], "FAT20: shareholder is already blacklisted");
        _isBlacklisted[shareholder] = true;
        blacklistedCount += 1;
    }

    function unsetBlacklisted(address shareholder) external onlyOwner {
        require(_isBlacklisted[shareholder], "FAT20: shareholder is not blacklisted");
        _isBlacklisted[shareholder] = false;
        blacklistedCount -= 1;
    }

    function setTxLimitExempt(address shareholder, bool isTxLimitExempt) external onlyOwner {
        _isTxLimitExempt[shareholder] = isTxLimitExempt;
    }

    function setDistributorGas(uint256 newDistributorGas) external onlyOwner {
        distributorGas = newDistributorGas;
    }

    function setBuyFees(Fees memory newBuyFees) external onlyOwner {
        buyFees = newBuyFees;
        
        uint256 operationFee = buyFees.operationFee / 2;
        uint256 liquidityFee = buyFees.liquidityFee / 2;
        uint256 rewardFee = buyFees.rewardFee / 2;
        uint256 premiumRewardFee = buyFees.premiumRewardFee / 2;
        
        rewardDistributor.setReinvestFees(operationFee, liquidityFee, rewardFee, premiumRewardFee);
        premiumRewardDistributor.setReinvestFees(operationFee, liquidityFee, rewardFee, premiumRewardFee);
    }

    function setSellFees(Fees memory newSellFees) external onlyOwner {
        sellFees = newSellFees;
    }

    function setTransferFees(Fees memory newTransferFees) external onlyOwner {
        transferFees = newTransferFees;
    }

    function setOperator(address newOperator) external onlyOwner {
        operator = newOperator;
    }

    function setRewardToken(address newRewardToken) external onlyOwner {
        rewardToken = newRewardToken;
    }

    function setTreasury(address newTreasury) external onlyOwner {
        treasury = newTreasury;
    }

    function setSellCooldown(uint256 newSellCooldown) external onlyOwner {
        sellCooldown = newSellCooldown;
    }

    function setSwapEnabled(bool newSwapEnabled) external onlyOwner {
        swapEnabled = newSwapEnabled;
    }

    function setMaxWalletSize(uint256 value) external onlyOwner {
        maxWalletSize = value;
    }

    function setMaxTxSize(uint256 value) external onlyOwner {
        maxTxSize = value;
    }

    function setSellTriggerLimit(uint256 value) external onlyOwner {
        sellTriggerLimit = value;
    }

    function setAdditionalFee(uint256 value) external onlyOwner {
        additionalFee = value;
    }    

    function setTokenThreshold(uint256 value) external onlyOwner {
        _tokenThreshold = value;
    }

    // only distributors can call these functions
    function addLiquidityFeeAmount(uint256 liquidityFee) external onlyDistributors {
        _liquidityFeeAmount += liquidityFee;
    }

    function addOperationFeeAmount(uint256 operationFee) external onlyDistributors {
        _operationFeeAmount += operationFee;
    }

    function addRewardFeeAmount(uint256 rewardFee) external onlyDistributors {
        _rewardFeeAmount += rewardFee;
    }

    function addPremiumRewardFeeAmount(uint256 premiumRewardFee) external onlyDistributors {
        _premiumRewardFeeAmount += premiumRewardFee;
    }

    /** ======= MODIFIERS ======= */
    modifier swapping() {
        _isInSwap = true;
        _;
        _isInSwap = false;
    }

    modifier onlyDistributors() {
        require(msg.sender == _rewardAddress || msg.sender == _premiumRewardAddress);
        _;
    }

    // fall back function
    receive() external payable {}
}