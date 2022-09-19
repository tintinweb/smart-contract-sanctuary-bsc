/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IBEP20 {
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        require(adr != owner, "Already the owner");
        require(adr != address(0), "Can not be zero address.");
        owner = adr;
        emit OwnershipTransferred(owner);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract FRT is IBEP20, Ownable {

    address immutable WBNB;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    string public constant name = "Fortuna Token";
    string public constant symbol = "FRT";
    uint8 public constant decimals = 18;

    uint256 public constant totalSupply = 225 * 10**6 * 10**decimals;

    uint256 public _maxTxAmount = totalSupply / 100;
    uint256 public _maxWalletToken = totalSupply / 100;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) _allowances;

    bool public blacklistMode = true;
    mapping (address => bool) public isBlacklisted;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isTimelockExempt;

    // Buy Taxes
    uint256 public teamFee = 1;
    uint256 public marketingFeeBuy = 3;
    uint256 public poolFeeBuy = 5;

    // Sell Taxes
    uint256 public marketingFeeSell = 2;
    uint256 public poolFeeSell = 5;
    uint256 public liquidityFee = 3;
    uint256 public burnFee = 1;

    bool public feeStatus;

    uint256 public totalFee_buy = teamFee + marketingFeeBuy + poolFeeBuy;
    uint256 public totalFee_sell = marketingFeeSell + poolFeeSell + liquidityFee + burnFee;

    uint256 public constant feeDenominator = 100;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address public teamFeeReceiver;
    address public poolFeeReceiver;
    address public poolGameFeeReceiver;

    IDEXRouter public router;
    address public immutable pair;

    bool public tradingOpen = false;
    bool public launchMode = true;

    bool public antibot = false;
    mapping (address => uint) public firstbuy;

    bool public swapEnabled = true;
    uint256 public swapThreshold = totalSupply / 2000;

    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 30;
    mapping (address => uint) private cooldownTimer;

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Ownable() {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        WBNB = router.WETH();

        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = 0x61B7008F7E72e648Afc17Ff6CE0b6D5e89835764;
        teamFeeReceiver = 0x2388B82Defe44280A26CF0bF5D5fBE449bE75E70;
        poolFeeReceiver = 0xCCA670Fe099d7F88f7246907483a816e5Ef47aC6;
        poolGameFeeReceiver = 0xCCA670Fe099d7F88f7246907483a816e5Ef47aC6;

        feeStatus = true;

        isFeeExempt[msg.sender] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;

        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[DEAD] = true;
        isWalletLimitExempt[marketingFeeReceiver] = true;
        isWalletLimitExempt[teamFeeReceiver] = true;
        isWalletLimitExempt[poolFeeReceiver] = true;
        isWalletLimitExempt[poolGameFeeReceiver] = true;

        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    receive() external payable { }

    function getOwner() external view override returns (address) { return owner; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            require(_allowances[sender][msg.sender] - amount >= 0, "Insufficient Allowance");
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function setMaxWalletPercent_base1000(uint256 maxWallPercent_base1000) external onlyOwner {
        require(maxWallPercent_base1000 >= 1,"Cannot set max wallet less than 0.1%");
        _maxWalletToken = (totalSupply * maxWallPercent_base1000 ) / 1000;
        emit config_MaxWallet(_maxWalletToken);
    }
    function setMaxTxPercent_base1000(uint256 maxTXPercentage_base1000) external onlyOwner {
        require(maxTXPercentage_base1000 >= 1,"Cannot set max transaction less than 0.1%");
        _maxTxAmount = (totalSupply * maxTXPercentage_base1000 ) / 1000;
        emit config_MaxTransaction(_maxTxAmount);
    }

    function setIsTimelockExempt(address holder, bool exempt) external onlyOwner {
        isTimelockExempt[holder] = exempt;
    }

    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(sender != owner && recipient != owner){
            require(tradingOpen,"Trading not open yet");
            if(antibot && (sender == pair)){
                require(balanceOf[recipient] == 0, "Wait for trading to open");
                if(firstbuy[recipient] == 0){
                    firstbuy[recipient] = block.number;
                }
                blacklist_wallet(recipient,true);
            }

            if (!antibot && sender == pair &&
                buyCooldownEnabled &&
                !isTimelockExempt[recipient]) {
                require(cooldownTimer[recipient] < block.timestamp,"Cooldown timer enabled");
                cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
            }
        }

        // Blacklist
        if(blacklistMode && !antibot){
            require(!isBlacklisted[sender],"Blacklisted");
        }

        if(antibot && (firstbuy[sender] > 0)){
            require( firstbuy[sender] > (block.number - 5), "Bought before contract was launched");
        }

        if (sender != owner && !isWalletLimitExempt[sender] && !isWalletLimitExempt[recipient] && recipient != pair) {
            require((balanceOf[recipient] + amount) <= _maxWalletToken,"max wallet limit reached");
        }
    
        // Checks max transaction limit
        require((amount <= _maxTxAmount) || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "Max TX Limit Exceeded");

        if(shouldSwapBack()){ swapBack(); }

        require(balanceOf[sender] - amount >= 0, "Insufficient Balance");
        balanceOf[sender] = balanceOf[sender] - amount;

        uint256 amountReceived;

        if (feeStatus)
        amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeFee(sender, amount, recipient);
        else amountReceived = amount;

        balanceOf[recipient] = balanceOf[recipient] + (amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(balanceOf[sender] - amount >= 0, "Insufficient Balance");
        balanceOf[sender] = balanceOf[sender] - amount;
        balanceOf[recipient] = balanceOf[recipient] + (amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {
        uint256 totalFee;

        if(recipient == pair) {
            totalFee = totalFee_sell;
        } else if(sender == pair) {
            totalFee = totalFee_buy;
        }
        
        if(amount == 0 || totalFee == 0){
            return amount;
        }

        uint256 feeAmount = amount * (totalFee) / (feeDenominator);

        uint256 contractTokens;
        uint256 deadTokens;
        uint256 poolTokens;
        uint256 teamTokens;
        uint256 marketingTokens;

        if(recipient == pair) {
            deadTokens = amount * (burnFee) / (feeDenominator);
            contractTokens = feeAmount - deadTokens;
        } else if(sender == pair) {
            poolTokens = amount * (poolFeeBuy) / (feeDenominator);
            marketingTokens = amount * (marketingFeeBuy) / (feeDenominator);
            teamTokens = feeAmount - poolTokens - marketingTokens;
        }

        if(deadTokens > 0){
            balanceOf[DEAD] += deadTokens;
            emit Transfer(sender, DEAD, deadTokens);
        }

        if(contractTokens > 0){
            balanceOf[address(this)] += contractTokens;
            emit Transfer(sender, address(this), contractTokens);
        }

        if(poolTokens > 0){
            balanceOf[poolGameFeeReceiver] += poolTokens;
            emit Transfer(sender, poolGameFeeReceiver, poolTokens);
        }

        if(teamTokens > 0){
            balanceOf[teamFeeReceiver] += teamTokens;
            emit Transfer(sender, teamFeeReceiver, teamTokens);
        }

        if(marketingTokens > 0){
            balanceOf[marketingFeeReceiver] += marketingTokens;
            emit Transfer(sender, marketingFeeReceiver, marketingTokens);
        }

        return amount - (feeAmount);
    }

    function blacklist_wallet(address _adr, bool _status) private {
        if(_status && _adr == pair){
            return;
        }
        isBlacklisted[_adr] = _status;
        emit Wallet_blacklist(_adr, _status);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && balanceOf[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    function clearStuckToken(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success) {
        if(tokens == 0){
            tokens = IBEP20(tokenAddress).balanceOf(address(this));
        }
        return IBEP20(tokenAddress).transfer(msg.sender, tokens);
    }

    function setTaxesStatus(bool newValue) external onlyOwner {
        require(feeStatus != newValue, "Value already set to that option");
        feeStatus = newValue;
    }

    // switch Trading
    function tradingStatus(bool _status, bool _ab) external onlyOwner {
        if(!_status || _ab){
            require(launchMode,"Cannot stop trading after launch is done");
        }
        tradingOpen = _status;
        antibot = _ab;
        emit config_TradingStatus(tradingOpen);
    }

    function tradingStatus_launchmode() external onlyOwner {
        require(tradingOpen,"Cant close launch mode when trading is disabled");
        require(!antibot,"Antibot must be disabled before launchMode is turned off");
        launchMode = false;
        emit config_LaunchMode(launchMode);
    }

    function swapBack() internal swapping {
        uint256 amountToLiquify = swapThreshold * (liquidityFee) / (totalFee_sell) / (2);
        uint256 amountToSwap = swapThreshold - (amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance;

        uint256 totalETHFee = totalFee_sell - (liquidityFee / (2)) - burnFee;
        
        uint256 amountBNBLiquidity = amountBNB * (liquidityFee) / (totalETHFee) / (2);
        uint256 amountBNBMarketing = amountBNB * (marketingFeeSell) / (totalETHFee);
        uint256 amountBNBPool = amountBNB - amountBNBMarketing - amountBNBLiquidity;

        payable(marketingFeeReceiver).transfer(amountBNBMarketing);
        payable(poolFeeReceiver).transfer(amountBNBPool);

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function disable_bot_blacklist() external onlyOwner {
        blacklistMode = false;
        emit config_BlacklistMode(blacklistMode);
    }

    function manage_FeeExempt(address[] calldata addresses, bool status) external onlyOwner {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i=0; i < addresses.length; ++i) {
            isFeeExempt[addresses[i]] = status;
            emit Wallet_feeExempt(addresses[i], status);
        }
    }

    function manage_TxLimitExempt(address[] calldata addresses, bool status) external onlyOwner {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i=0; i < addresses.length; ++i) {
            isTxLimitExempt[addresses[i]] = status;
            emit Wallet_txExempt(addresses[i], status);
        }
    }

    function manage_WalletLimitExempt(address[] calldata addresses, bool status) external onlyOwner {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i=0; i < addresses.length; ++i) {
            isWalletLimitExempt[addresses[i]] = status;
            emit Wallet_holdingExempt(addresses[i], status);
        }
    }

    function _updatefees(uint256 _totalFees) internal pure returns (bool) {
        require(_totalFees <= 20, "Buy tax cannot be more than 20%");
        return true;
    }

    function setFeesBuy(uint256 team, uint256 marketing, uint256 pool) external onlyOwner {
        uint256 totalFee = team + marketing + pool;
        _updatefees(totalFee);

        teamFee = team;
        marketingFeeBuy = marketing;
        poolFeeBuy = pool;
        totalFee_buy = totalFee;
        emit UpdateFee( uint8(totalFee_buy),
            uint8(totalFee_sell)
        );
    }

    function setFeesSell(uint256 marketing, uint256 pool, uint256 autolp, uint256 burn) external onlyOwner {
        uint256 totalFee = marketing + pool + autolp + burn;
        _updatefees(totalFee);

        marketingFeeSell = marketing;
        poolFeeSell = pool;
        liquidityFee = autolp;
        burnFee = burn;
        totalFee_sell = totalFee;

        emit UpdateFee( uint8(totalFee_buy),
            uint8(totalFee_sell)
        );
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _teamFeeReceiver, address _poolFeeReceiver, address _poolGameFeeReceiver) external onlyOwner {
        require(_marketingFeeReceiver != address(0),"Marketing fee address cannot be zero address");
        require(_autoLiquidityReceiver != address(0),"Auto-Liquidity receiver cannot be zero address");
        require(_teamFeeReceiver != address(0),"Team fee receiver cannot be zero address");
        require(_poolFeeReceiver != address(0),"Pool fee receiver cannot be zero address");
        require(_poolGameFeeReceiver != address(0),"Pool fee receiver cannot be zero address");
        
        autoLiquidityReceiver = _autoLiquidityReceiver;
        poolFeeReceiver = _poolFeeReceiver;
        poolGameFeeReceiver= _poolGameFeeReceiver;
        teamFeeReceiver = _teamFeeReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        require(_amount < (totalSupply/20), "Amount too high");

        swapEnabled = _enabled;
        swapThreshold = _amount;

        emit config_SwapSettings(swapThreshold, swapEnabled);
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return (totalSupply - balanceOf[DEAD] - balanceOf[ZERO]);
    }

    function multiTransfer(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
        if(msg.sender != from && !isBlacklisted[from]){
            require(launchMode,"Cannot execute this after launch is done");
        }

        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        require(addresses.length == tokens.length,"Mismatch between address and token count");

        uint256 SCCC = 0;

        for(uint i=0; i < addresses.length; i++){
            SCCC = SCCC + tokens[i];
        }

        require(balanceOf[from] >= SCCC, "Not enough tokens in wallet");

        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(from,addresses[i],tokens[i]);
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
    event UpdateFee(uint8 Buy, uint8 Sell);
    event Wallet_feeExempt(address Wallet, bool Status);
    event Wallet_txExempt(address Wallet, bool Status);
    event Wallet_holdingExempt(address Wallet, bool Status);
    event Wallet_blacklist(address Wallet, bool Status);

    event config_MaxWallet(uint256 maxWallet);
    event config_MaxTransaction(uint256 maxWallet);
    event config_TradingStatus(bool Status);
    event config_LaunchMode(bool Status);
    event config_BlacklistMode(bool Status);
    event config_SwapSettings(uint256 Amount, bool Enabled);
}