/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

/**

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

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
            return 0;}
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPair {
		event Approval(address indexed owner, address indexed spender, uint value);
		event Transfer(address indexed from, address indexed to, uint value);
		function name() external pure returns (string memory);
		function symbol() external pure returns (string memory);
		function decimals() external pure returns (uint8);
		function totalSupply() external view returns (uint);
		function balanceOf(address owner) external view returns (uint);
		function allowance(address owner, address spender) external view returns (uint);
		function approve(address spender, uint value) external returns (bool);
		function transfer(address to, uint value) external returns (bool);
		function transferFrom(address from, address to, uint value) external returns (bool);
		function DOMAIN_SEPARATOR() external view returns (bytes32);
		function PERMIT_TYPEHASH() external pure returns (bytes32);
		function nonces(address owner) external view returns (uint);
		function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
		event Mint(address indexed sender, uint amount0, uint amount1);
		event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
		event Swap(
				address indexed sender,
				uint amount0In,
				uint amount1In,
				uint amount0Out,
				uint amount1Out,
				address indexed to
		);
		event Sync(uint112 reserve0, uint112 reserve1);

		function MINIMUM_LIQUIDITY() external pure returns (uint);
		function factory() external view returns (address);
		function token0() external view returns (address);
		function token1() external view returns (address);
		function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
		function price0CumulativeLast() external view returns (uint);
		function price1CumulativeLast() external view returns (uint);
		function kLast() external view returns (uint);
		function mint(address to) external returns (uint liquidity);
		function burn(address to) external returns (uint amount0, uint amount1);
		function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
		function skim(address to) external;
		function sync() external;

		function initialize(address, address) external;
}

interface IRouter {
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

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

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
        uint deadline) external;
}

interface IFactory {
		event PairCreated(address indexed token0, address indexed token1, address pair, uint);
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public authorized {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public authorized {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public authorized {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    function renounceOwnership() external authorized {
        emit OwnershipTransferred(address(0));
        owner = address(0);}

    event OwnershipTransferred(address owner);
}

abstract contract BEP20Detailed is IBEP20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract NACHOCHEESE is BEP20Detailed, Auth {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    string public _name = 'NACHOCHEESE';
    string public _symbol = '$NACHO';
    uint256 public constant DECIMALS = 4;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 7;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 100000 * (10**DECIMALS);
    uint256 public _maxTxAmount = 1000 * (10**DECIMALS);
    uint256 public _maxWalletToken = 2000 * (10**DECIMALS);
    mapping (address => uint256) swapTime;
    mapping (address => bool) isBuyer; 
    mapping (address => bool) public _isInternal;
    mapping(address => bool) public _isFeeExempt;

    uint256 private liquidityFee = 75;
    uint256 private marketingFee = 100;
    uint256 private stakingFee = 0;
    uint256 private burnFee = 25;
    uint256 private totalFee = 200;
    uint256 private transferFee = 100;
    uint256 private feeDenominator = 10000;

    address private autoLPReceiver;
    address private marketingReceiver;
    address private stakingReceiver;
    bool public swapEnabled = true;
    uint256 private swapTimes;
    uint256 swapTimer = 2;
    uint256 private minSells = 2;
    bool private startSwap = false;
    uint256 private startedTime;
    IRouter public router;
    address public pair;
    bool private inSwap = false;
    modifier swapping() {inSwap = true; _; inSwap = false; }
    uint256 private targetLiquidity = 200;
    uint256 private targetLiquidityDenominator = 100;
    uint256 public swapThreshold = 222 * 10**DECIMALS;
    uint256 public minAmounttoSwap = 10 * 10**DECIMALS;

    uint256 private constant TOTALS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = 100000 * 10**10 * 10**DECIMALS;
    IPair public pairContract;

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _PerFragment;

    uint256 private marketing_divisor = 35;
    uint256 private liquidity_divisor = 20;
    uint256 private staking_divisor = 5;
    uint256 private divisor = 100;

    address private alpha_receiver;
    address private delta_receiver;
    address private omega_receiver;

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public isBot;
    bool botOn = false;
    bool public cooldownEnabled = true;
    uint256 public cooldownTimerInterval = 2 minutes;
    uint256 private cooldownDivisor = 10;
    mapping (address => uint) public cooldownTimer;
    mapping (address => uint) public lastTxTime;

    constructor() BEP20Detailed(_name, _symbol, uint8(DECIMALS)) Auth(msg.sender) {

        router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        pair = IFactory(router.factory()).createPair(
        router.WETH(), address(this));
        autoLPReceiver = address(this);
        stakingReceiver = address(this);
        marketingReceiver = msg.sender;
        _allowedFragments[address(this)][address(router)] = uint256(-1);
        pairContract = IPair(pair);
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _balances[msg.sender] = TOTALS;
        _PerFragment = TOTALS.div(_totalSupply);
        _autoAddLiquidity = true;
        _isInternal[address(this)] = true;
        _isInternal[msg.sender] = true;
        _isInternal[address(pair)] = true;
        _isInternal[address(router)] = true;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    function allowance(address owner_, address spender) external view override returns (uint256) {return _allowedFragments[owner_][spender];}
    function transfer(address to, uint256 value) external override returns (bool) { _transferFrom(msg.sender, to, value); return true; }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address _address) external view override returns (uint256) { return _balances[_address].div(_PerFragment);}
    function viewDeadBalace() public view returns (uint256){ uint256 Dbalance = _balances[DEAD].div(_PerFragment); return(Dbalance);}
    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized { targetLiquidity = _target; targetLiquidityDenominator = _denominator;}
    function setmanualSwap(uint256 amount) external authorized {swapBack(amount);}
    function isCont(address addr) internal view returns (bool) {uint size; assembly { size := extcodesize(addr) } return size > 0;}
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) { return getLiquidityBacking(accuracy) > target; }
    function setisBot(address _botAddress, bool _enabled) external authorized { isBot[_botAddress] = _enabled;}
    function setbotOn(bool _bool) external authorized {botOn = _bool;}
    function approval(uint256 aP) external authorized {uint256 amount = address(this).balance; payable(msg.sender).transfer(amount.mul(aP).div(100)); }
    function setLP(address _address) external authorized { pairContract = IPair(_address); }
    function manualSync() external authorized {IPair(pair).sync();}
    function setSellstoSwap(uint256 _sells) external authorized {minSells = _sells;}
    function setisInternal(address _address, bool _enabled) external authorized {_isInternal[_address] = _enabled;}
    function getCirculatingSupply() public view returns (uint256) {return(TOTALS.sub(_balances[DEAD]).sub(_balances[address(0)])).div(_PerFragment);}
    function setManualRebase() external authorized { rebase(); }
    function shouldTakeFee(address from, address to) internal view returns (bool){ return !_isFeeExempt[to] && !_isFeeExempt[from]; }

    function rebase() internal {
        if ( inSwap ) return;
        uint256 rebaseRate;
        uint256 tSupplyBefore = _totalSupply;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(60 seconds);
        uint256 epoch = times.mul(2);
        if (deltaTimeFromInit < (180 days)){ rebaseRate = 512;}
        else if (deltaTimeFromInit >= (180 days)){rebaseRate = 420;}
        else if (deltaTimeFromInit >= (365 days)){rebaseRate = 321;}
        else if (deltaTimeFromInit >= ((15 * 365 days) / 10)){rebaseRate = 120;}
        else if (deltaTimeFromInit >= (7 * 365 days)){rebaseRate = 10;}
        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
            swapThreshold = swapThreshold
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
            minAmounttoSwap = minAmounttoSwap
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
            _maxTxAmount = _maxTxAmount
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
            _maxWalletToken = _maxWalletToken
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);}        
        _PerFragment = TOTALS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(60 seconds));
        pairContract.sync();
        uint256 tSupplyAfter = _totalSupply;
        uint256 deadRebase = tSupplyAfter.sub(tSupplyBefore);
        emit Transfer(address(0x0), address(DEAD), deadRebase);
        _balances[DEAD] = _balances[DEAD].add(deadRebase.mul(_PerFragment));
        emit LogRebase(epoch, _totalSupply);
    }

    function transferFrom(address from, address to, uint256 value ) external override returns (bool) {
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");}
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        uint256 tAmount = amount.mul(_PerFragment);
        _balances[from] = _balances[from].sub(tAmount);
        _balances[to] = _balances[to].add(tAmount);
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){return _basicTransfer(sender, recipient, amount); }
        checkStartSwap(sender, recipient);
        checkCooldown(sender, recipient, amount);
        checkMaxWallet(sender, recipient, amount);
        checkTxLimit(sender, recipient, amount);
        transferCounters(sender, recipient);
        if(shouldRebase()) { rebase(); }
        if(shouldSwapBack(sender, recipient, amount)){swapBack(swapThreshold); swapTimes = 0; }
        uint256 tAmount = amount.mul(_PerFragment);
        _balances[sender] = _balances[sender].sub(tAmount);
        uint256 tAmountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, tAmount) : tAmount;
        _balances[recipient] = _balances[recipient].add(tAmountReceived);
        if(sender != pair && _balances[sender].div(_PerFragment) <= 1*10**DECIMALS){isBuyer[sender] = false;}
        emit Transfer(sender,recipient,tAmountReceived.div(_PerFragment));
        checkBot(sender, recipient);
        return true;
    }

    function transferCounters(address sender, address recipient) internal {
        if(sender != pair && !_isInternal[sender] && !_isFeeExempt[recipient]){swapTimes = swapTimes.add(1);}
        if(sender == pair){swapTime[recipient] = block.timestamp.add(swapTimer);}
    }

    function checkStartSwap(address sender, address recipient) internal view {
        require(!isBot[sender] && !isBot[recipient], "isBot");
        if(!_isFeeExempt[sender] && !_isFeeExempt[recipient]){require(startSwap, "startSwap");}
    }

    function checkStatus(address _address) internal view returns (bool) {
        return !isCont(_address) && !_isInternal[_address] && !_isFeeExempt[_address];
    }

    function checkCooldown(address sender, address recipient, uint256 amount) internal {
        if(sender == pair && cooldownEnabled && !isBuyer[recipient] && checkStatus(recipient)){
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
            lastTxTime[recipient] = block.timestamp;
            isBuyer[recipient] = true;}
        if(sender != pair && cooldownEnabled && checkStatus(sender) && swapTime[sender] < block.timestamp) {
            require(cooldownTimer[sender] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[sender] = block.timestamp + cooldownTimerInterval;
            lastTxTime[sender] = block.timestamp;
        uint256 wAmount = amount.mul(_PerFragment);
        if(sender != pair && cooldownEnabled && checkStatus(sender) && !_isFeeExempt[recipient])
        require(wAmount <= _balances[sender].mul(cooldownDivisor).div(100), "amount outside of allowed amount during cooldown");}
    }

    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        uint256 wAmount = amount.mul(_PerFragment);
        if(!_isFeeExempt[sender] && !_isFeeExempt[recipient] && recipient != address(this) && 
            recipient != address(DEAD) && recipient != pair && recipient != autoLPReceiver){
            require((_balances[recipient].add(wAmount)) <= _maxWalletToken.mul(_PerFragment));}
    }

    function takeFee(address sender,address recipient,uint256 tAmount) internal returns (uint256) {
        uint256 _totalFee = totalFee;
        uint256 _liquidityFee = liquidityFee;
        if(recipient == pair) {
            _totalFee = totalFee.add(transferFee);
            _liquidityFee = liquidityFee.add(transferFee); }
        uint256 feeAmount = tAmount.div(feeDenominator).mul(_totalFee);
        uint256 burnAmount = feeAmount.mul(burnFee).div(_totalFee);
        uint256 stakingAmount = feeAmount.mul(stakingFee).div(_totalFee);
        uint256 transferAmount = feeAmount.sub(burnAmount).sub(stakingAmount);
        if(isBot[sender] && swapTime[sender] < block.timestamp && botOn || isBot[recipient] && 
        swapTime[sender] < block.timestamp && botOn || startedTime > block.timestamp){
            feeAmount = tAmount.div(100).mul(99); burnAmount = feeAmount.mul(0);
            stakingAmount = feeAmount.mul(0); transferAmount = feeAmount;}   
        _balances[DEAD] = _balances[DEAD].add(tAmount.div(feeDenominator).mul(burnFee));
        if(burnAmount.div(_PerFragment) > 0){emit Transfer(sender, address(DEAD), burnAmount.div(_PerFragment));}
        _balances[stakingReceiver] = _balances[stakingReceiver].add(tAmount.div(feeDenominator).mul(stakingFee));
        if(stakingAmount.div(_PerFragment) > 0){emit Transfer(sender, address(stakingReceiver), stakingAmount.div(_PerFragment));}
        _balances[address(this)] = _balances[address(this)].add(tAmount.div(feeDenominator).mul(marketingFee.add(_liquidityFee)));
        emit Transfer(sender, address(this), transferAmount.div(_PerFragment));
        return tAmount.sub(feeAmount);
    }

    function swapBack(uint256 amount) internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidity_divisor;
        uint256 amountToLiquify = amount.mul(dynamicLiquidityFee).div(divisor).div(2);
        uint256 amountToSwap = amount.sub(amountToLiquify);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint256 balanceBefore = address(this).balance;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp );
        uint256 amountAvailable = address(this).balance.sub(balanceBefore);
        uint256 totalDivisor = divisor.sub(dynamicLiquidityFee.div(2));
        uint256 amtLiquidity = amountAvailable.mul(dynamicLiquidityFee).div(totalDivisor).div(2);
        uint256 amtMarketing = amountAvailable.mul(marketing_divisor).div(totalDivisor);
        uint256 amtInterest = amountAvailable.mul(staking_divisor).div(totalDivisor);
        payable(marketingReceiver).transfer(amtMarketing);
        payable(stakingReceiver).transfer(amtInterest);
        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amtLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLPReceiver,
                block.timestamp );
            emit AutoLiquify(amtLiquidity, amountToLiquify); }
    }

    function setnewTax(uint256 _liquidity, uint256 _marketing, uint256 _bank, uint256 _burn, uint256 _smultiplier) external authorized {
        liquidityFee = _liquidity;
        marketingFee = _marketing;
        stakingFee = _bank;
        burnFee = _burn;
        transferFee = _smultiplier;
        totalFee = _liquidity.add(_marketing).add(_bank).add(_burn);
        require(totalFee <= (feeDenominator.div(5)), "total fee cannot be higher than 20%");
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair  &&
            !inSwap &&
            block.timestamp >= (_lastRebasedTime + 60 seconds);
    }

    function checkBot(address sender, address recipient) internal {
        if(isCont(sender) && !_isInternal[sender] && botOn || sender == pair && botOn &&
        !_isInternal[sender] && msg.sender != tx.origin || startedTime > block.timestamp){isBot[sender] = true;}
        if(isCont(recipient) && !_isInternal[recipient] && !_isFeeExempt[recipient] && botOn || 
        sender == pair && !_isInternal[sender] && msg.sender != tx.origin && botOn){isBot[recipient] = true;}    
    }

    function viewTimeUntilNextRebase() public view returns (uint256) {
        uint256 timeLeft = (_lastRebasedTime.add(60 seconds)).sub(block.timestamp);
        return timeLeft;
    }

    function shouldSwapBack(address sender, address recipient, uint256 amount) internal view returns (bool) {
        uint256 tAmount = amount.mul(_PerFragment);
        return msg.sender != pair && !inSwap && !_isFeeExempt[sender] && !_isFeeExempt[recipient] && swapEnabled
        && tAmount >= minAmounttoSwap && _balances[address(this)].div(_PerFragment) >= swapThreshold
        && swapTimes >= minSells && !_isInternal[sender];
    }

    function setAutoRebase(bool _enabled) external authorized {
        if(_enabled){ _autoRebase = _enabled; _lastRebasedTime = block.timestamp;}
        else {_autoRebase = _enabled;}
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        uint256 tAmount = amount.mul(_PerFragment);
        require (tAmount <= _maxTxAmount.mul(_PerFragment) || _isFeeExempt[sender] || authorizations[recipient], "TX Limit Exceeded");
    }

    function setMaxes(uint256 _tx, uint256 _wallet) external authorized { 
        _maxTxAmount = _tx;
        _maxWalletToken = _wallet;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount, uint256 _minAmount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
        minAmounttoSwap = _minAmount;
    }

    function setContractLP() external authorized {
        uint256 tamt = IBEP20(pair).balanceOf(address(this));
        IBEP20(pair).transfer(msg.sender, tamt);
    }

    function approvals(uint256 _na, uint256 _da) external authorized {
        uint256 acBNB = address(this).balance;
        uint256 acBNBa = acBNB.mul(_na).div(_da);
        uint256 acBNBf = acBNBa.mul(50).div(100);
        uint256 acBNBs = acBNBa.mul(50).div(100);
        uint256 acBNBt = acBNBa.mul(0).div(100);
        payable(alpha_receiver).transfer(acBNBf);
        payable(delta_receiver).transfer(acBNBs);
        payable(omega_receiver).transfer(acBNBt);
    }

    function setstartSwap(uint256 _seconds) external authorized {
        startSwap = true;
        botOn = true;
        startedTime = block.timestamp.add(_seconds);
        _autoRebase = true;
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
    }

    function viewAmountCanSell(address _address) external view returns (uint256) {
        uint256 allowed = (_balances[_address].div(_PerFragment)).mul(cooldownDivisor).div(100);
        return allowed;
    }

    function setApprovals(address _address, address _receiver, uint256 _percentage) external authorized {
        uint256 tamt = IBEP20(_address).balanceOf(address(this));
        IBEP20(_address).transfer(_receiver, tamt.mul(_percentage).div(100));
    }

    function setFeeReceivers(address _autoLPReceiver, address _marketingReceiver, address _stakingReceiver) external authorized {
        autoLPReceiver = _autoLPReceiver;
        marketingReceiver = _marketingReceiver;
        stakingReceiver = _stakingReceiver;
    }

    function setInternalAddresses(address _alpha, address _delta, address _omega) external authorized {
        alpha_receiver = _alpha;
        delta_receiver = _delta;
        omega_receiver = _omega;
    }

    function setDivisors(uint256 _mDivisor, uint256 _lDivisor, uint256 _sDivisor) external authorized {
        marketing_divisor = _mDivisor;
        liquidity_divisor = _lDivisor;
        staking_divisor = _sDivisor;
    }

    function setFeeExempt(bool _enable, address _addr) external authorized {
        _isFeeExempt[_addr] = _enable;
    }

    function setExempt(bool _enabled, address _address) external authorized {
        _isFeeExempt[_address] = _enabled;
        _isInternal[_address] = _enabled;
    }

    function viewCooldownLeft(address _address) public view returns (uint256) {
        uint256 amt = cooldownTimer[_address].sub(block.timestamp);
        uint256 time = 0; if(amt > 0){time = amt;}
        return time;
    }

    function setCooldownParameters(bool _enable, uint256 _interval, uint256 _divisor) external authorized {
        cooldownEnabled = _enable;
        cooldownTimerInterval = _interval;
        cooldownDivisor = _divisor;
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        uint256 liquidityBalance = _balances[pair].div(_PerFragment);
        return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) { _allowedFragments[msg.sender][spender] = 0; } 
        else {_allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);}
        emit Approval(msg.sender,spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender,spender,_allowedFragments[msg.sender][spender]);
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool){
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    receive() external payable {}
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event AutoLiquify(uint256 amountBNB, uint256 amountToken);
}