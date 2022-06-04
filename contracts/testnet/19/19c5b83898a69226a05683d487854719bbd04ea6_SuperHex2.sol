/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// SPDX-License-Identifier: MIT


pragma solidity 0.7.4;

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

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address owner_) {
        _owner = owner_;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

contract SuperHex2 is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string private _name = "Super Hex2";
    string private _symbol = "SHEX2";
    uint8 private _decimals = 18;

    mapping(address => uint256) _rBalance;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) _isFeeExempt;

    uint256 public liquidityFee = 4;
    uint256 public treasuryFee  = 5;
    uint256 public insuranceFee = 3;
    uint256 public burnFee      = 2;
    uint256 public totalFee     = liquidityFee + treasuryFee + insuranceFee + burnFee;

    uint256 public additionalFeeOnSell = 2;

    address public treasuryWallet  = 0x90318e34E12d56da66A23eC998f0EA3A687C8AC7;
    address public insuranceWallet = 0x1F94cbd74e4A705011b128aFeF306541b071b5D8;

    IPancakeSwapRouter public router;
    address public pair;
    IPancakeSwapPair public pairContract;

    uint8 private constant RATE_DECIMALS = 7;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 1000000 * (10**18);
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 public constant MAX_SUPPLY = 10000000 * (10**18);
    uint256 private constant rSupply = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 public _totalSupply;
    uint256 private swapThreshold = rSupply / 1000;
    uint256 private rate;

    bool public tradingOpen = false;

    bool public swapEnabled = true;
    bool inSwap = false;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    bool public _autoRebase;
    uint256 public rebaseRate = 4660;
    uint256 public _lastRebasedTime;
    uint256 public rebase_count;

    constructor(address newOwner) ERC20Detailed(_name, _symbol, _decimals) Ownable(newOwner) {

        router = IPancakeSwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); 
        pair = IPancakeSwapFactory(router.factory()).createPair(router.WETH(),address(this));
        _allowances[address(this)][address(router)] = uint256(-1);

        pairContract = IPancakeSwapPair(pair);
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        rate = rSupply.div(_totalSupply);

        _isFeeExempt[newOwner] = true;
        _isFeeExempt[address(this)] = true;

        _lastRebasedTime = block.timestamp;
        _autoRebase = false;

        _rBalance[newOwner] = rSupply;
        emit Transfer(address(0x0), newOwner, _totalSupply);
    }

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    function rebase() internal {
        
        if ( inSwap ) return;
        rebase_count++;

        _totalSupply = _totalSupply
            .mul((10**RATE_DECIMALS).add(rebaseRate))
            .div(10**RATE_DECIMALS);

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
            _autoRebase = false;
        }

        rate = rSupply.div(_totalSupply);
        _lastRebasedTime = block.timestamp;

        pairContract.sync();

        emit LogRebase(rebase_count, _totalSupply);
    }

    function transfer(address to, uint256 value)
        external
        override
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        
        if (_allowances[from][msg.sender] != uint256(-1)) {
            _allowances[from][msg.sender] = _allowances[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 rAmount = amount.mul(rate);
        _rBalance[from] = _rBalance[from].sub(rAmount);
        _rBalance[to] = _rBalance[to].add(rAmount);
        emit Transfer(from, to, amount);
        return true;
    }

    function openTrading() external onlyOwner {
        tradingOpen = true;
        _autoRebase = true;
        _lastRebasedTime = block.timestamp;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
		require(recipient != address(0), "ERC20: transfer to the zero address");
        if (inSwap) { return _basicTransfer(sender, recipient, amount); }

        if(!_isFeeExempt[sender] && !_isFeeExempt[recipient]){
            require(tradingOpen,"Trading not open yet");
        }
        
        uint256 rAmount = amount.mul(rate);

        if (shouldRebase()) { rebase(); }

        if (shouldSwapBack()) { swapBack(); }

        _rBalance[sender] = _rBalance[sender].sub(rAmount, "Insufficient Balance");

        uint256 amountReceived = (_isFeeExempt[sender] || _isFeeExempt[recipient]) ? rAmount : takeFee(sender, rAmount, (recipient == pair));
        _rBalance[recipient] = _rBalance[recipient].add(amountReceived);


        emit Transfer(sender, recipient, amountReceived.div(rate));
        return true;
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _rBalance[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 tokensToSell = balanceOf(address(this));

        uint256 amountToLiquify = tokensToSell.div(totalFee).mul(liquidityFee).div(2);
        uint256 amountToBurn    = tokensToSell.div(totalFee).mul(burnFee);
        uint256 amountToSwap = tokensToSell.sub(amountToLiquify).sub(amountToBurn);

        _basicTransfer(address(this), DEAD, amountToBurn);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2)).sub(burnFee);
        
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBTreasury  = amountBNB.mul(treasuryFee).div(totalBNBFee);
        uint256 amountBNBInsurance = amountBNB.mul(insuranceFee).div(totalBNBFee);

        if(amountBNBTreasury > 0) {
            payable(treasuryWallet).transfer(amountBNBTreasury);
        }
        if(amountBNBInsurance > 0) {
            payable(insuranceWallet).transfer(amountBNBInsurance);
        }

        if(amountBNBLiquidity > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                DEAD,
                block.timestamp
            );
        }
    } 

    function takeFee(address sender, uint256 rAmount, bool isSell) internal returns (uint256) {
        uint256 _finalFee = totalFee;
        if(isSell){
            _finalFee += additionalFeeOnSell;
        } 

        uint256 feeAmount = rAmount.div(100).mul(_finalFee);

        _rBalance[address(this)] = _rBalance[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount.div(rate));

        return rAmount.sub(feeAmount);
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        return 
            (pair == from || pair == to) &&
            !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair  &&
            !inSwap &&
            block.timestamp >= (_lastRebasedTime + 30 minutes);
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowances[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowances[msg.sender][spender] = 0;
        } else {
            _allowances[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowances[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowances[msg.sender][spender] = _allowances[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowances[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }

    function setFees(uint256 _liquidityFee, uint256 _burnFee, uint256 _treasuryFee, uint256 _insuranceFee, uint256 _additionalFeeOnSell) external onlyOwner {
        liquidityFee        = _liquidityFee;
        burnFee             = _burnFee;
        treasuryFee         = _treasuryFee;
        insuranceFee        = _insuranceFee;
        totalFee            = _liquidityFee.add(_burnFee).add(_treasuryFee).add(_insuranceFee);
        additionalFeeOnSell = _additionalFeeOnSell;
        require((totalFee.add(_additionalFeeOnSell)) <= 25, "Fees cannot be more than 25%");
    }

    function setIsFeeExempt(address holder, bool exempt) public onlyOwner {
        _isFeeExempt[holder] = exempt;
    }

    function setTreasuryWallet(address newWallet) external onlyOwner() {
        treasuryWallet = newWallet;
    }

    function setInsuranceWallet(address newWallet) external onlyOwner() {
        insuranceWallet = newWallet;
    }

    function setSwapBackSettings(bool _enabled, uint256 _percentage_base100000) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = rSupply.div(100000).mul(_percentage_base100000);
    }

    function checkSwapThreshold() external view returns (uint256) {
        return swapThreshold.div(rate);
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address account) public view override returns (uint256) {
        return _rBalance[account].div(rate);
    }

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim native tokens");
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    receive() external payable {}
}