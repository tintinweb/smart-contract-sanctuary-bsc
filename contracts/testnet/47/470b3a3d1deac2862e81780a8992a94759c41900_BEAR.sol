/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.7.4;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeSwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IPancakeSwapFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

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

    constructor() {
        _owner = msg.sender;
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
    uint256 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 decimals_
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

    function decimals() public view returns (uint256) {
        return _decimals;
    }
}

contract BEAR is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
	
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
	
    string public constant _name = "WhatsBearish";
    string public constant _symbol = "BEAR";
    uint256 public constant _decimals = 5;

    IPancakeSwapPair public pairContract;
    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }
	
    uint256 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint256 public constant RATE_DECIMALS = 13;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 325 * 10**3 * 10**DECIMALS;

    uint256[] public liquidityFee;
    uint256[] public bearChestFee;
    uint256[] public bearPotFee;
    uint256[] public dirtHoleFee;
	
	uint256 private bearChestFeeTotal;
	uint256 private liquidityFeeTotal;
	uint256 private bearPotFeeTotal;
	
    uint256 private constant feeDenominator = 10000;
	
	uint256 public swapAtAmount = 1000 * 10**DECIMALS;
	
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
	
    //address payable public bearChestReceiver = payable(0x564d52A8475E787e9eB31EF2e13C8B50438dc0f3);
	address payable public bearChestReceiver = payable(0x760c5A41b67BE0b8E208Da61c9654d5aad1e92f2);
    address payable public bearPot = payable(0x11A18a72cf1966d9d3034e0099c8210747B3CE7b);
	
    address public pairAddress;
    IPancakeSwapRouter public router;
    address public pair;
	
    bool inSwap = false;
	
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = 325 * 10**7 * 10**DECIMALS;

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;

    constructor() ERC20Detailed("WhatsBearish", "BEAR", uint256(DECIMALS)) Ownable() {
        router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pair = IPancakeSwapFactory(router.factory()).createPair(router.WETH(), address(this));
		
        _allowedFragments[address(this)][address(router)] = uint256(-1);
		
        pairAddress = pair;
        pairContract = IPancakeSwapPair(pair);
		
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[bearChestReceiver] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
		
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
		
        _autoRebase = true;
        _autoAddLiquidity = true;
        
		_isFeeExempt[bearChestReceiver] = true;
        _isFeeExempt[address(this)] = true;
		
		liquidityFee.push(160);
		liquidityFee.push(200);
		liquidityFee.push(160);
		
		bearChestFee.push(216);
		bearChestFee.push(270);
		bearChestFee.push(216);
		
		bearPotFee.push(264);
		bearPotFee.push(330);
		bearPotFee.push(264);
		
		dirtHoleFee.push(160);
		dirtHoleFee.push(200);
		dirtHoleFee.push(160);
		
        _transferOwnership(bearChestReceiver);
        emit Transfer(address(0x0), bearChestReceiver, _totalSupply);
    }
	
	receive() external payable {}
	
    function rebase() internal {
        if (inSwap) return;
        uint256 rebaseRate;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(5 minutes);
        uint256 epoch = times.mul(5);
		
        rebaseRate = 852302771;
        
		for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply.mul((10**RATE_DECIMALS).add(rebaseRate)).div(10**RATE_DECIMALS);
        }
		
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(5 minutes));

        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
    }

    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool) {
        _transferFrom(msg.sender, to, value);
        return true;
    }
	
    function transferFrom(address from, address to, uint256 value) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != uint256(-1)) 
		{
            _allowedFragments[from][msg.sender] = _allowedFragments[from][ msg.sender].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }
	
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");
		
        if (shouldRebase()) {
            rebase();
        }
		
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
		
		if(shouldTakeFee(sender, recipient))
		{
		     uint256 fees = takeFee(sender, recipient, gonAmount);
             _gonBalances[recipient] = _gonBalances[recipient].add(gonAmount).sub(fees);
			 emit Transfer(sender, recipient, (gonAmount).sub(fees).div(_gonsPerFragment));
		}
		else
		{
             _gonBalances[recipient] = _gonBalances[recipient].add(gonAmount);
			 emit Transfer(sender, recipient, (gonAmount).div(_gonsPerFragment));
		}
        return true;
    }
	
    function takeFee(address sender, address recipient, uint256 gonAmount) internal returns (uint256) {
        uint256 feeAmount; 
		
		uint256 _liquidityFee = gonAmount.mul(recipient != pair && sender != pair ? liquidityFee[2] : recipient==pair ? liquidityFee[1] : liquidityFee[0]).div(feeDenominator);
		         liquidityFeeTotal = liquidityFeeTotal.add(_liquidityFee);
				 
		uint256 _bearChestFee = gonAmount.mul(recipient != pair && sender != pair ? bearChestFee[2] : recipient==pair ? bearChestFee[1] : bearChestFee[0]).div(feeDenominator);
		         bearChestFeeTotal = bearChestFeeTotal.add(_bearChestFee);
				 
		uint256 _bearPotFee = gonAmount.mul(recipient != pair && sender != pair ? bearPotFee[2] : recipient==pair ? bearPotFee[1] : bearPotFee[0]).div(feeDenominator);
		         bearPotFeeTotal = bearPotFeeTotal.add(_bearPotFee);
				 
        uint256 _dirtHoleFee = gonAmount.mul(recipient != pair && sender != pair ? dirtHoleFee[2] : recipient==pair ? dirtHoleFee[1] : dirtHoleFee[0]).div(feeDenominator);
       
	    _gonBalances[DEAD] = _gonBalances[DEAD].add(_dirtHoleFee);
		_gonBalances[address(this)] = _gonBalances[address(this)].add(_liquidityFee).add(_bearChestFee).add(_bearPotFee);
		
		feeAmount = _liquidityFee.add(_bearChestFee).add(_bearPotFee).add(_dirtHoleFee);
		
		emit Transfer(sender, address(this), feeAmount.sub(_dirtHoleFee).div(_gonsPerFragment));
		emit Transfer(sender, DEAD, _dirtHoleFee.div(_gonsPerFragment));
		return feeAmount;
    }
	
    function shouldTakeFee(address from, address to) internal view returns (bool) {
        return (pair == from || pair == to) && !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return _autoRebase && (_totalSupply < MAX_SUPPLY) && msg.sender != pair && !inSwap && block.timestamp >= (_lastRebasedTime + 5 minutes);
    }
	
    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag)  {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } 
		else {
            _autoRebase = _flag;
        }
    }
	
    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) 
		{
            _allowedFragments[msg.sender][spender] = 0;
        } 
		else 
		{
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender].add(addedValue);
		
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool) {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div( _gonsPerFragment);
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }
	
    function setLiquidityFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(bearChestFee[0].add(bearPotFee[0]).add(dirtHoleFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(bearChestFee[1].add(bearPotFee[1]).add(dirtHoleFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(bearChestFee[2].add(bearPotFee[2]).add(dirtHoleFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		liquidityFee[0] = buy;
		liquidityFee[1] = sell;
		liquidityFee[2] = p2p;
	}
	
	function setBearChestFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(liquidityFee[0].add(bearPotFee[0]).add(dirtHoleFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(liquidityFee[1].add(bearPotFee[1]).add(dirtHoleFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(liquidityFee[2].add(bearPotFee[2]).add(dirtHoleFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		bearChestFee[0] = buy;
		bearChestFee[1] = sell;
		bearChestFee[2] = p2p;
	}
	
	function setBearPotFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(liquidityFee[0].add(bearChestFee[0]).add(dirtHoleFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(liquidityFee[1].add(bearChestFee[1]).add(dirtHoleFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(liquidityFee[2].add(bearChestFee[2]).add(dirtHoleFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		bearPotFee[0] = buy;
		bearPotFee[1] = sell;
		bearPotFee[2] = p2p;
	}
	
	function setDirtHoleFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(liquidityFee[0].add(bearChestFee[0]).add(bearPotFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(liquidityFee[1].add(bearChestFee[1]).add(bearPotFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(liquidityFee[2].add(bearChestFee[2]).add(bearPotFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		dirtHoleFee[0] = buy;
		dirtHoleFee[1] = sell;
		dirtHoleFee[2] = p2p;
	}
	
    function getLiquidityBacking(uint256 accuracy) external view returns (uint256) {
        uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
        return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setWhitelist(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = true;
    }
	
	function removeFromWhitelist(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = false;
    }
	
    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require( isContract(_botAddress), "only contract address, not allowed externally owned account");
        blacklist[_botAddress] = _flag;
    }

    function setPairAddress(address _pairAddress) external onlyOwner {
        pairAddress = _pairAddress;
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) external view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr)}
        return size > 0;
    }
	
	function migrateTokens(address tokenAddress, address to, uint256 amount)  public onlyOwner {
        IERC20(tokenAddress).transfer(to, amount);
    }
	
	function migrateBNB(address payable recipient) public onlyOwner {
        recipient.transfer(address(this).balance);
    }
	
	function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
  	     require(amount <= _totalSupply, "Amount cannot be over the total supply.");
		 swapAtAmount = amount;
  	}
}