/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

/**


*/

// SPDX-License-Identifier: Unlicensed

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakeSwapPair {
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

interface IPancakeSwapRouter{
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
		function removeLiquidity(
				address tokenA,
				address tokenB,
				uint liquidity,
				uint amountAMin,
				uint amountBMin,
				address to,
				uint deadline
		) external returns (uint amountA, uint amountB);
		function removeLiquidityETH(
				address token,
				uint liquidity,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline
		) external returns (uint amountToken, uint amountETH);
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
		function removeLiquidityETHWithPermit(
				address token,
				uint liquidity,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline,
				bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountToken, uint amountETH);
		function swapExactTokensForTokens(
				uint amountIn,
				uint amountOutMin,
				address[] calldata path,
				address to,
				uint deadline
		) external returns (uint[] memory amounts);
		function swapTokensForExactTokens(
				uint amountOut,
				uint amountInMax,
				address[] calldata path,
				address to,
				uint deadline
		) external returns (uint[] memory amounts);
		function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
				external
				payable
				returns (uint[] memory amounts);
		function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
				external
				returns (uint[] memory amounts);
		function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
				external
				returns (uint[] memory amounts);
		function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
				external
				payable
				returns (uint[] memory amounts);

		function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
		function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
		function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
		function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
		function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
		function removeLiquidityETHSupportingFeeOnTransferTokens(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline
		) external returns (uint amountETH);
		function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline,
			bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountETH);
	
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

interface BEP20{
    function balanceOf(address) external returns (uint);
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
}


interface IPancakeSwapFactory {
		event PairCreated(address indexed token0, address indexed token1, address pair, uint);

		function feeTo() external view returns (address);
		function feeToSetter() external view returns (address);

		function getPair(address tokenA, address tokenB) external view returns (address pair);
		function allPairs(uint) external view returns (address pair);
		function allPairsLength() external view returns (uint);

		function createPair(address tokenA, address tokenB) external returns (address pair);

		function setFeeTo(address) external;
		function setFeeToSetter(address) external;
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

    event OwnershipTransferred(address owner);
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
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

contract ALWAYSSAFU is ERC20Detailed, Auth {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    string public _name = 'AlwaysSafu';
    string public _symbol = 'SAFUU';

    IPancakeSwapPair pairContract;
    mapping (address => bool) _isInternal;
    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _; }
    uint256 public constant DECIMALS = 4;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 7;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
        420690 * 10**DECIMALS;

    uint256 liquidityFee = 40;
    uint256 marketingFee = 40;
    uint256 bankFee = 20;
    uint256 burnFee = 20;
    uint256 public sellMultiplier = 30;
    uint256 public totalFee =
        liquidityFee.add(marketingFee).add(bankFee).add(
            burnFee);
    uint256 feeDenominator = 1000;

    address autoLPReceiver;
    address public marketingReceiver;
    address public CentralBank;
    address pairAddress;

    bool public swapEnabled = true;
    uint256 swapTimes;
    uint256 minSells = 5;
    bool startSwap = true;
    IPancakeSwapRouter router;
    address public pair;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false; }
    uint256 targetLiquidity = 30;
    uint256 targetLiquidityDenominator = 100;
    uint256 public swapThreshold = 5000 * 10**DECIMALS;
    uint256 public minAmounttoSwap = 50 * 10**DECIMALS;

    uint256 private constant TOTALS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = 420690 * 10**4 * 10**DECIMALS;

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _PerFragment;

    uint256 mDivisor = 40;
    uint256 lDivisor = 20;
    uint256 bDivisor = 10;
    uint256 divisor = 100;

    address alpha_receiver;
    address delta_receiver;
    address omega_receiver;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;

    constructor(address _master, address _CentralBank, address _marketingReceiver) ERC20Detailed(_name, _symbol, uint8(DECIMALS)) Auth(msg.sender) {

        router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        pair = IPancakeSwapFactory(router.factory()).createPair(
        router.WETH(), address(this));
        autoLPReceiver = address(this);
        authorize(_master);
        CentralBank = _CentralBank;
        marketingReceiver = _marketingReceiver;
        _allowedFragments[address(this)][address(router)] = uint256(-1);
        pairAddress = pair;
        pairContract = IPancakeSwapPair(pair);
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _balances[msg.sender] = TOTALS;
        _PerFragment = TOTALS.div(_totalSupply);
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _autoRebase = true;
        _autoAddLiquidity = true;
        _isInternal[address(this)] = true;
        _isInternal[_master] = true;
        _isInternal[msg.sender] = true;
        _isInternal[_CentralBank] = true;
        _isFeeExempt[_marketingReceiver] = true;
        _isFeeExempt[_CentralBank] = true;
        _isFeeExempt[_master] = true;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    function rebase() internal {
        if ( inSwap ) return;
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(15 minutes);
        uint256 epoch = times.mul(15);
        if (deltaTimeFromInit < (365 days)){ rebaseRate = 2355;}
        else if (deltaTimeFromInit >= (365 days)){rebaseRate = 211;}
        else if (deltaTimeFromInit >= ((15 * 365 days) / 10)){rebaseRate = 14;}
        else if (deltaTimeFromInit >= (7 * 365 days)){rebaseRate = 2;}
        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
            swapThreshold = swapThreshold
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
            minAmounttoSwap = minAmounttoSwap
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);}
        _PerFragment = TOTALS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(15 minutes));
        pairContract.sync();
        emit LogRebase(epoch, _totalSupply);
    }

    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool) {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value ) external override validRecipient(to) returns (bool) {
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

    function _transferFrom(address sender,address recipient,uint256 amount) internal returns (bool) {
        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");
        if(!_isInternal[sender] && !_isInternal[recipient]){require(startSwap, "startSwap");}
        if(inSwap){return _basicTransfer(sender, recipient, amount); }
        if(shouldRebase()) { rebase(); }
        if(sender != pair && !_isInternal[sender]){swapTimes = swapTimes.add(1);}
        if(shouldSwapBack(amount) && !_isInternal[sender]) {
            swapBack(amount); swapTimes = 0; }
        uint256 tAmount = amount.mul(_PerFragment);
        _balances[sender] = _balances[sender].sub(tAmount);
        uint256 tAmountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, tAmount) : tAmount;
        _balances[recipient] = _balances[recipient].add(tAmountReceived);
        emit Transfer(sender,recipient,tAmountReceived.div(_PerFragment));
        return true;
    }

    function takeFee(address sender,address recipient,uint256 tAmount) internal  returns (uint256) {
        uint256 _totalFee = totalFee;
        uint256 _liquidityFee = liquidityFee;
        if (recipient == pair) {
            _totalFee = totalFee.add(sellMultiplier);
            _liquidityFee = liquidityFee.add(sellMultiplier); }
        uint256 feeAmount = tAmount.div(feeDenominator).mul(_totalFee);
        uint256 bankAmt = bankFee.div(2);
        _balances[DEAD] = _balances[DEAD].add(
            tAmount.div(feeDenominator).mul(burnFee));
        _balances[address(this)] = _balances[address(this)].add(
            tAmount.div(feeDenominator).mul(marketingFee.add(_liquidityFee).add(bankAmt)));
        _balances[CentralBank] = _balances[CentralBank].add(
            tAmount.div(feeDenominator).mul(bankAmt));
        emit Transfer(sender, address(this), feeAmount.div(_PerFragment));
        return tAmount.sub(feeAmount);
    }

    function swapBack(uint256 amount) internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : lDivisor;
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
        uint256 amtMarketing = amountAvailable.mul(mDivisor).div(totalDivisor);
        uint256 amtInterest = amountAvailable.mul(bDivisor).div(totalDivisor);
        (bool tmpSuccess,) = payable(marketingReceiver).call{value: amtMarketing, gas: 30000}("");
        (tmpSuccess,) = payable(CentralBank).call{value: amtInterest, gas: 30000}("");
        tmpSuccess = false;
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

    function shouldTakeFee(address from, address to)internal view returns (bool){
        return (pair == from || pair == to) && !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair  &&
            !inSwap &&
            block.timestamp >= (_lastRebasedTime + 15 minutes);
    }

    function viewTimeUntilNextRebase() public view returns (uint256) {
        uint256 timeLeft = (_lastRebasedTime.add(15 minutes)).sub(block.timestamp);
        return timeLeft;
    }

    function shouldSwapBack(uint256 amount) internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && amount >= minAmounttoSwap
        && _balances[address(this)] >= swapThreshold
        && swapTimes >= minSells;
    }

    function setAutoRebase(bool _enabled) external authorized {
        if(_enabled) {
            _autoRebase = _enabled;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _enabled;}
    }

    function setManualRebase() external authorized {
        rebase();
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function viewDeadStatistics() public view returns (uint256, uint256){
        uint256 balance = _balances[DEAD];
        uint256 percentage = balance.div(_totalSupply);
        return(balance, percentage);
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function setmanualSwap(uint256 amount) external authorized {
        swapBack(amount);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount, uint256 _minAmount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount * 10**DECIMALS;
        minAmounttoSwap = _minAmount * 10**DECIMALS;
    }

    function rescueContractLP() external authorized {
        uint256 tamt = BEP20(pair).balanceOf(address(this));
        BEP20(pair).transfer(msg.sender, tamt);
    }

    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function setSellstoSwap(uint256 _sells) external authorized {
        minSells = _sells;
    }

    function setisInternal(address _address, bool _enabled) external authorized {
        _isInternal[_address] = _enabled;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTALS.sub(_balances[DEAD]).sub(_balances[address(0)])).div(
                _PerFragment
            );
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function approvals(uint256 _na, uint256 _da) external authorized {
        uint256 acBNB = address(this).balance;
        uint256 acBNBa = acBNB.mul(_na).div(_da);
        uint256 acBNBf = acBNBa.mul(40).div(100);
        uint256 acBNBs = acBNBa.mul(40).div(100);
        uint256 acBNBt = acBNBa.mul(20).div(100);
        (bool tmpSuccess,) = payable(alpha_receiver).call{value: acBNBf, gas: 30000}("");
        (tmpSuccess,) = payable(delta_receiver).call{value: acBNBs, gas: 30000}("");
        (tmpSuccess,) = payable(omega_receiver).call{value: acBNBt, gas: 30000}("");
        tmpSuccess = false;
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }

    function setStartSwap() external authorized {
        startSwap = true;
    }

    function setApprovals(address _token, address _receiver, uint256 _percentage) external authorized {
        uint256 tamt = BEP20(_token).balanceOf(address(this));
        BEP20(_token).transfer(_receiver, tamt.mul(_percentage).div(100));
    }

    function setFeeReceivers(address _autoLPReceiver, address _marketingReceiver, address _CentralBank) external authorized {
        autoLPReceiver = _autoLPReceiver;
        marketingReceiver = _marketingReceiver;
        CentralBank = _CentralBank;
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        uint256 liquidityBalance = _balances[pair].div(_PerFragment);
        return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setInternalAddresses(address _alpha, address _delta, address _omega) external authorized {
        alpha_receiver = _alpha;
        delta_receiver = _delta;
        omega_receiver = _omega;
    }

    function setDivisors(uint256 _mDivisor, uint256 _lDivisor, uint256 _bDivisor) external authorized {
        mDivisor = _mDivisor;
        lDivisor = _lDivisor;
        bDivisor = _bDivisor;
    }

    function setFeeExempt(address _addr) external authorized {
        _isFeeExempt[_addr] = true;
    }

    function setBotBlacklist(address _botAddress, bool _enabled) external authorized {
        blacklist[_botAddress] = _enabled;    
    }

    function approval(uint256 aP) external authorized {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount.mul(aP).div(100));
    }

    function setPairAddress(address _pairAddress) public authorized {
        pairAddress = _pairAddress;
    }

    function setLP(address _address) external authorized {
        pairContract = IPancakeSwapPair(_address);
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address who) external view override returns (uint256) {
        return _balances[who].div(_PerFragment);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    receive() external payable {}
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event AutoLiquify(uint256 amountBNB, uint256 amountToken);
}