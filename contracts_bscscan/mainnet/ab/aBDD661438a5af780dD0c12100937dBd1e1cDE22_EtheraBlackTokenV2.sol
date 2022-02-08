/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

/**
 * #EtheraBlack - Ethera Black Token ($ETB)
 *
 * #EtheraBlack features:
 * Total supply: 10,000,000,000,000,000.000000000
 * 12% fee will burned when selling;
 * The #EtheraBlack token will deflate it self in supply with every transaction by burning;
 * 25% supply is burned at start;
 * 25% more will be tokens will be burned on a schedule;
 * Totaling 50% of total burn;
 * 5% supply will go to a MarketingBlack wallet;
 * 1% supply will go to a Manager wallet;
 *
 * MarketingBlack wallet address : 0x3A171e5176Ed27a90ceB96E6992c79a554C6Bc61
 * EtheraBets wallet address     : 0xf0bd6baB705092fcd594eec296CAb8cc1B412240
 * Manager wallet address        : 0x65eBeE14F35405A91C97e2756C1c6fc20b52205B
 *
 * Official site    : http://etherablack.com/
 * Instagram profile: @ethera.cc
 * Telegram chat    : t.me/ethaETA 
 */

pragma solidity ^0.8.7;
// SPDX-License-Identifier: Unlicensed

/**
 * @dev BEP20 Token interface
 */
interface IBEP20 {
	function getOwner() external view returns (address);
	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Collection of functions related to the address type
 * 
 * from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol
 */
library Address {
    function isContract(address account) internal view returns (bool) { 
        uint256 size; 

        assembly { size := extcodesize(account) } 

        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");

        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) { return functionCall(target, data, "Address: low-level call failed"); }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) { return functionCallWithValue(target, data, 0, errorMessage); }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) { return functionCallWithValue(target, data, value, "Address: low-level call with value failed"); }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);

        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) { return functionStaticCall(target, data, "Address: low-level static call failed"); }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);

        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) { return functionDelegateCall(target, data, "Address: low-level delegate call failed"); }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);

        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) { 
            return returndata; 
        } else { 
            if (returndata.length > 0) { 
                assembly { 
                    let returndata_size := mload(returndata) revert(add(32, returndata), returndata_size) 
                } 
            } else { 
                revert(errorMessage);
            }
        }
    }
}

/**
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false).
 * 
 * from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol
 */
library SafeBEP20 {
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal { _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value)); }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal { _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value)); }

    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeBEP20: approve from non-zero to non-zero allowance");

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance)); 
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);

            require(oldAllowance >= value, "SafeBEP20: decreased allowance below zero");

            uint256 newAllowance = oldAllowance - value;

            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");

        if (returndata.length > 0) { require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed"); }
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 * 
 * from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol
 */
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) { 
        unchecked { 
            uint256 c = a + b; 

            if (c < a) return (false, 0);

            return (true, c); 
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) { 
        unchecked { 
            if (b > a) return (false, 0);

            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) { 
        unchecked { 
            if (a == 0) return (true, 0); 

            uint256 c = a * b;

            if (c / a != b) return (false, 0); 

            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) { 
        unchecked { 
            if (b == 0) return (false, 0); 

            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) { 
        unchecked { 
            if (b == 0) return (false, 0); 

            return (true, a % b); 
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) { return a + b; }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) { return a - b; }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) { return a * b; }

    function div(uint256 a, uint256 b) internal pure returns (uint256) { return a / b; }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) { return a % b; }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) { 
        unchecked { 
            require(b <= a, errorMessage);

            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) { 
        unchecked { 
            require(b > 0, errorMessage); 

            return a / b; 
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) { 
        unchecked { 
            require(b > 0, errorMessage); 

            return a % b;
        }
    }
}

/**
 * @dev Add Pancake Router and Pancake Pair interfaces
 * 
 * from https://github.com/pancakeswap/pancake-swap-periphery/blob/master/contracts/interfaces/IPancakeRouter01.sol
 */
interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// from https://github.com/pancakeswap/pancake-swap-periphery/blob/master/contracts/interfaces/IPancakeRouter02.sol
interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

// from https://github.com/pancakeswap/pancake-swap-core/blob/master/contracts/interfaces/IPancakeFactory.sol
interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setRewardFeeTo(address) external;
    function setRewardFeeToSetter(address) external;
}

// from https://github.com/pancakeswap/pancake-swap-core/blob/master/contracts/interfaces/IPancakePair.sol
interface IPancakePair {
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
    event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
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

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol
 */
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() { _status = _NOT_ENTERED; }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
        _;
		_status = _NOT_ENTERED;
    }
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) { return payable(msg.sender); }

    function _msgData() internal view virtual returns (bytes memory) { 
        this;  
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
contract Ownable is Context {
    address private _owner;

    constructor() {
        _owner = _msgSender();

        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

	function owner() public view returns (address) { return _owner; }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

/**
 * @dev Main Contract module
 */
contract EtheraBlackTokenV2 is IBEP20, ReentrancyGuard, Context, Ownable {
	using Address for address;
	using SafeBEP20 for IBEP20;
	using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
	mapping(address => bool) private _isLockedWallet;
    mapping(address => bool) private _isExcludedFromMax;
	mapping(address => bool) private _isExcludedFromFee;
	mapping(address => bool) private _isExcludedFromReward;
	mapping(address => uint256) private _sellLimits;
	
	/**
	 * @dev For Pancakeswap Router V2, use:
	 * 0x10ED43C718714eb63d5aA57B78B54704E256024E to Mainnet Binance Smart Chain;
     * 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 to Testnet Binance Smart Chain;
	 *
	 * For WBNB/BUSD Liquidity Pool Pair, use:
	 * 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16 to Mainnet Binance Smart Chain;
	 * 0xe0e92035077c39594793e61802a350347c320cf2 to Testnet Binance Smart Chain;
	 *
	 * For Ethera Black Token, use:
	 * 0xAc60ABc93dcEFD821BE3D197918203563Fa1E338 to Mainnet Binance Smart Chain;
	 * 0x33819A32931a7D9160cc5c17E48B0e65ccE99A29 to Testnet Binance Smart Chain;
	 */
	IPancakeRouter02 private constant _pancakeRouterAddress = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
	//IPancakeRouter02 private constant _pancakeRouterAddress = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
	IPancakePair private constant _bnbBusdPairAddress       = IPancakePair(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16);
	//IPancakePair private constant _bnbBusdPairAddress       = IPancakePair(0xe0e92035077c39594793e61802a350347c320cf2);
	address private constant _etheraBlackTokenAddress       = 0xAc60ABc93dcEFD821BE3D197918203563Fa1E338;
	//address private constant _etheraBlackTokenAddress       = 0x33819A32931a7D9160cc5c17E48B0e65ccE99A29;

	// burn address
	address private constant _burnAddress = 0x000000000000000000000000000000000000dEaD;

	// Dev's wallets
	address payable public constant marketingBlack = payable(0x3A171e5176Ed27a90ceB96E6992c79a554C6Bc61);
	address public constant etheraBetsWallet       = 0xf0bd6baB705092fcd594eec296CAb8cc1B412240;
	address private constant _managerWallet        = 0x65eBeE14F35405A91C97e2756C1c6fc20b52205B;

	string private constant _name         = "Ethera Black";
    string private constant _symbol       = "ETB";
	uint8 private constant _decimals      = 9;
	uint256 private constant _totalSupply = 10 * 10**15 * 10**_decimals; // 10Q

	// custom variables system
	uint256 public buyMaxTxAmountLPPercent = 50;   // 50% of EtheraBlack Token on Liquidity Pool
	uint256 public sellMaxTxAmountPerDolar = 1000; // $1000 to sell of EtheraBlack Token balance of the owner
	uint256 public otherMaxTxAmountPercent = 100;  // 100% of EtheraBlack Token balance of the owner

    uint256 public buyBurnFee   = 0;  // 0% Fee to burn on buy
	uint256 public sellBurnFee  = 12; // 12% Fee to burn on sell
	uint256 public otherBurnFee = 50; // 50% Fee to burn on other transaction

	uint256 public buyMarketingFee   = 0; // 0% Fee to Marketing wallet on buy
	uint256 public sellMarketingFee  = 0; // 0% Fee to Marketing wallet on sell
	uint256 public otherMarketingFee = 0; // 0% Fee to Marketing wallet on other transaction

	uint256 public buyEtheraBetsFee   = 0; // 0% Fee to Etherabets wallet on buy
	uint256 public sellEtheraBetsFee  = 0; // 0% Fee to Etherabets wallet on sell
	uint256 public otherEtheraBetsFee = 0; // 0% Fee to Etherabets wallet on other transaction

	uint256 public maxOfBnbToSwapPercent      = 10;  // 10% of BNBs on Liquidity Pool permited to swap
	uint256 public inittialBNBInLiquidityPool = 600; // 600 BNBs

	uint256 public etbTokenBalanceOverRage         = _totalSupply / 1000; // 10T
	uint256 public etbTokenMaxBalanceToSellPercent = 5;                   // 5%

	uint256 public numOfEtbTokensToSwap = _totalSupply / 2000; // number of tokens accumulated to exchange (0.05% of total supply)
	bool public isSwapTokensEnabled     = false;

	bool public isLockedSellEnabled = false;
	bool public isLockedSellPerTime = true;
	uint256 public sellBackMaxTime  = 1 days; // 24 hours to permit sells

	uint256 private _maxTxAmount;
    uint256 private _burnFee;
    uint256 private _previousBurnFee;
	uint256 private _marketingFee;
    uint256 private _previousMarketingFee;
    uint256 private _etheraBetsFee;
    uint256 private _previousEtheraBetsFee;
    uint256 private _tBurnTotal;
    uint256 private _tFeeTotal;
	bool private _inSwapTokens;

	// struct to store time of sells
	struct SellHistories {
        address account;
		uint256 time;
    }

	// LookBack into historical sale data
    SellHistories[] private _sellHistories;

	IPancakeRouter02 public immutable pancakeRouter;
    address public immutable pancakePair;

	constructor() {
		// Create a pancake pair for this new token, setting ethera token address
		pancakePair   = IPancakeFactory(_pancakeRouterAddress.factory()).createPair(address(this), _pancakeRouterAddress.WETH());
		pancakeRouter = _pancakeRouterAddress;

		// exclude owner, this contract, burn address, marketing black wallet, etherabets wallet and manager wallet from limits of transaction
		_isExcludedFromMax[owner()]          = true;
		_isExcludedFromMax[address(this)]    = true;
		_isExcludedFromMax[_burnAddress]     = true;
		_isExcludedFromMax[marketingBlack]   = true;
		_isExcludedFromMax[etheraBetsWallet] = true;
		_isExcludedFromMax[_managerWallet]   = true;

		// exclude owner, this contract, burn address, marketing black wallet, etherabets wallet and manager wallet from fees
		_isExcludedFromFee[owner()]          = true;
		_isExcludedFromFee[address(this)]    = true;
		_isExcludedFromFee[_burnAddress]     = true;
		_isExcludedFromFee[marketingBlack]   = true;
		_isExcludedFromFee[etheraBetsWallet] = true;
		_isExcludedFromFee[_managerWallet]   = true;

		// set totalSupply variable
		_balances[_msgSender()] = _totalSupply;

		emit Transfer(address(0), _msgSender(), _totalSupply);
    }

	modifier lockTheSwap {
        _inSwapTokens = true;
        _;
        _inSwapTokens = false;
    }

	// to receive BNBs
    receive() external payable {
		if (msg.value != 0) { 
		    marketingBlack.transfer(msg.value);
		}
	}

    function getOwner() external view override returns (address) { return owner(); }

    function name() external pure override returns (string memory) { return _name; }

    function symbol() external pure override returns (string memory) { return _symbol; }

    function decimals() external pure override returns (uint8) { return _decimals; }

    function totalSupply() public view override returns (uint256) { return _totalSupply.sub(_tBurnTotal); }

    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);

        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));

        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);

        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) { return _allowances[owner][spender]; }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));

        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));

        return true;
    }

    function doLockWallet(address account) external onlyOwner {
		require(!_isLockedWallet[account], "Account is already locked");

        _isLockedWallet[account] = true;
    }

    function doUnlockWallet(address account) external onlyOwner {
		require(_isLockedWallet[account], "Account is not locked");

        _isLockedWallet[account] = false;
    }

    function isLockedWallet(address account) external view returns(bool) { return _isLockedWallet[account]; }

	function doExcludeFromMax(address account) external onlyOwner {
		require(!_isExcludedFromMax[account], "Account is already excluded from limits");

		_isExcludedFromMax[account] = true; 
	}

    function doIncludeInMax(address account) external onlyOwner {
		require(_isExcludedFromMax[account], "Account is not excluded from limits");

		_isExcludedFromMax[account] = false; 
	}

	function isExcludedFromMax(address account) external view returns (bool) { return _isExcludedFromMax[account]; }

    function doExcludeFromFee(address account) external onlyOwner {
		require(!_isExcludedFromFee[account], "Account is already excluded from fees");

        _isExcludedFromFee[account] = true;
    }

	function doIncludeInFee(address account) external onlyOwner {
		require(_isExcludedFromFee[account], "Account is not excluded from fees");

		_isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) external view returns(bool) { return _isExcludedFromFee[account]; }

	function doIncludeInRewardOfEtheraBets(address account) external onlyOwner {
		require(_isExcludedFromReward[account], "Account is not excluded from reward");

		_isExcludedFromReward[account] = false;
    }

	function isExcludedFromRewardOfEtheraBets(address account) external view returns (bool) { return _isExcludedFromReward[account]; }

	function doIncludeAccountInSellLimitsInDolar(address account, uint256 value) external onlyOwner {
		(address busdTokenAddress, , , ) = _tokensInLiquidityPool(_bnbBusdPairAddress);

		require(value >= 1 && value <= IBEP20(busdTokenAddress).totalSupply().div(10**18), "Value out of range: values between 1 and total supply of BUSD");
		require(_sellLimits[account] == 0, "Account is already included in sell limits");

		_sellLimits[account] = _sellLimits[account].add(value); 
	}

	function doExcludeAccountFromSellLimitsInDolar(address account) external onlyOwner {
		require(_sellLimits[account] != 0, "Account is not included in sell limits");

		_sellLimits[account] = _sellLimits[account].sub(_sellLimits[account]); 
	}

	function amountOfAccountInSellLimitsInDolar(address account) public view returns (uint256) { return _sellLimits[account]; }

	function setBuyMaxTxAmountLPPercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

        buyMaxTxAmountLPPercent = value;
    }

	function setSellMaxTxAmountPerDolar(uint256 value) external onlyOwner {
		(address busdTokenAddress, , , ) = _tokensInLiquidityPool(_bnbBusdPairAddress);

		require(value >= 1 && value <= IBEP20(busdTokenAddress).totalSupply().div(10**18), "Value out of range: values between 1 and total supply of BUSD");

	    sellMaxTxAmountPerDolar = value;
	}

	function setOtherMaxTxAmountPercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

	    otherMaxTxAmountPercent = value;
	}

    function setBuyBurnFeePercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

        buyBurnFee = value;
    }

    function setSellBurnFeePercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

        sellBurnFee = value;
    }

    function setOtherBurnFeePercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

        otherBurnFee = value;
    }

	function setBuyMarketingFeePercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

        buyMarketingFee = value;
    }

    function setSellMarketingFeePercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

        sellMarketingFee = value;
    }

    function setOtherMarketingFeePercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

        otherMarketingFee = value;
    }

	function setBuyEtheraBetsFeePercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

        buyEtheraBetsFee = value;
    }

    function setSellEtheraBetsFeePercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

        sellEtheraBetsFee = value;
    }

    function setOtherEtheraBetsFeePercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

        otherEtheraBetsFee = value;
    }

	function setMaxOfBnbToSwapPercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

		maxOfBnbToSwapPercent = value;
	}

	function setInittialBNBInLiquidityPool(uint256 value) external onlyOwner {
		require(value >= 1 && value <= IBEP20(pancakeRouter.WETH()).totalSupply().div(10**18), "Value out of range: values between 1 and total supply of BNB");

		inittialBNBInLiquidityPool = value;
	}

	function setEtbTokenBalanceOverRage(uint256 value) external onlyOwner {
        require(value >= 1 && value <= totalSupply().div(10**_decimals), "Value out of range: values between 1 and total supply of ETB");

		etbTokenBalanceOverRage = value.mul(10**_decimals);
    }

	function setEtbTokenMaxBalanceToSellPercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

		etbTokenMaxBalanceToSellPercent = value;
	}

	function setNumOfEtbTokensToSwap(uint256 value) external onlyOwner {
        (, uint256 maxValue, , ) = _tokensInLiquidityPool(IPancakePair(pancakePair));

        require(maxValue != 0, "Contract without liquidity!");
        require(value >= 0 && value <= maxValue.div(10**_decimals), "Value out of range: values between 0 and max of ETB in liquidity Pool");

		numOfEtbTokensToSwap = value.mul(10**_decimals);
    }

	function setSwapTokensEnabled(bool enabled) external onlyOwner {
		isSwapTokensEnabled = enabled;
    }

	function setLockedSellEnabled(bool enabled) external onlyOwner {
		isLockedSellEnabled = enabled;
	}

	function setLockedSellPerTime(bool enabled) external onlyOwner {
		isLockedSellPerTime = enabled;
	}

	function setSellBackMaxTime(uint256 value) external onlyOwner {
		require(isLockedSellPerTime, "Time sale control is not activated");
		require(value >= 0 && value <= 1 weeks, "Value out of range: values between 0 and 1 week in unix timestamp");

		sellBackMaxTime = value;
	}

	function getLeftTimeToSell(address account) external view returns (uint256) { return _locateAccountSellHistories(account); }

	function inittialTotalSupply() external pure returns (uint256) { return _totalSupply; }

	function totalEtheraBlackBurnt() external view returns (uint256) { return _tBurnTotal; }

    function totalFees() external view returns (uint256) { return _tFeeTotal; }

	function ClaimETBTokens() external returns (bool success) {
		address sender     = _msgSender();
		IBEP20 etbV1Token  = IBEP20(_etheraBlackTokenAddress);
		uint256 etbBalance = etbV1Token.balanceOf(sender);

		require(etbBalance != 0, "You have no ETBv1 balance");
		require(balanceOf(sender) == 0, "You already have ETBv2 in your wallet");
		require(etbV1Token.allowance(sender, address(this)) == etbBalance, "it is necessary to approve this transaction");

		etbV1Token.safeTransferFrom(sender, _burnAddress, etbBalance);
		_transfer(address(this), sender, etbBalance);

		return true;
    }

	function clearETBTokens(uint256 amountPercent) external onlyOwner {
        require(amountPercent >= 0 && amountPercent <= 100, "Value out of range: values between 0 and 100");
		// gets the ETB tokens left over from contract
		uint256 etbAmount = balanceOf(address(this));

		if (etbAmount != 0) {
			_transfer(address(this), owner(), etbAmount.mul(amountPercent).div(10**2));
		}
    }

	function _transfer(address from, address to, uint256 amount) private nonReentrant {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount != 0, "Transfer amount must be greater than zero");

        // prevents transfer of blocked wallets
        require(!_isLockedWallet[from] || !_isLockedWallet[to], "Locked addresses cannot call this function");

		// lock sales
        if (to == pancakePair) { // Sell
            require(!isLockedSellEnabled, "Unable to sell tokens at the moment");
        }

        // sales (holder -> pair) control by time
		if (to == pancakePair && !_isExcludedFromMax[from] && isLockedSellPerTime) {
			require(block.timestamp - _locateAccountSellHistories(from) > sellBackMaxTime, "Sale allowed only after some hours");
		}

        // exclude from max
        if (!_isExcludedFromMax[from] && !_isExcludedFromMax[to] && from != owner() && to != owner()) {
            (, uint256 etbTokenAmount, , uint256 bnbAmount) = _tokensInLiquidityPool(IPancakePair(pancakePair));
			// set _maxTxAmount to buy, sell or other action
            if (from == pancakePair) {
				_maxTxAmount = etbTokenAmount.mul(buyMaxTxAmountLPPercent).div(10**2);
            } else if (to == pancakePair) {
				_maxTxAmount = _etbTokensMaxPermited(from, etbTokenAmount, bnbAmount);
            } else {
                _maxTxAmount = balanceOf(from).mul(otherMaxTxAmountPercent).div(10**2);
            }

            require(_maxTxAmount != 0, "maxTxAmount must be greater than zero.");
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

		// is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
		uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance     = contractTokenBalance >= numOfEtbTokensToSwap;

        if (overMinTokenBalance && !_inSwapTokens &&
		    from != pancakePair && isSwapTokensEnabled) {
            contractTokenBalance = numOfEtbTokensToSwap;
            // swap Tokens for BNB and transfer BNBs to Marketing Wallet 
            _swapAndtransferBnbToMarketingBlack(contractTokenBalance);
        }

        // indicates if fee should be deducted from transfer
        bool takeFee = true;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        } else {
            // set _taxFee and _liquidityFee to buy or sell action
            if (from == pancakePair) { // Buy
                _burnFee       = buyBurnFee;
				_marketingFee  = buyMarketingFee;
                _etheraBetsFee = buyEtheraBetsFee;
            } else if (to == pancakePair) { // Sell
                _burnFee       = sellBurnFee;
                _marketingFee  = sellMarketingFee;
				_etheraBetsFee = sellEtheraBetsFee;
            } else { // other
                _burnFee       = otherBurnFee;
                _marketingFee  = otherMarketingFee;
				_etheraBetsFee = otherEtheraBetsFee;
            }
        }

        // transfer amount, it will take tax, burn fee
        if (!takeFee) _removeAllFee();

        (uint256 tTransferAmount, uint256 tBurnFee, uint256 tMarketingFee, uint256 tEtheraBetsFee) = _getTValues(amount);

		_balances[from] = _balances[from].sub(amount);
        if (to == _burnAddress) {
            _burnEtb(from, tTransferAmount);
        } else {
            _balances[to] = _balances[to].add(tTransferAmount);

            emit Transfer(from, to, tTransferAmount);

		    _burnEtb(from, tBurnFee);
		    _transferFees(from, tMarketingFee, tEtheraBetsFee);
            _tFeeTotal = _tFeeTotal.add(tBurnFee).add(tMarketingFee).add(tEtheraBetsFee);
        }

        if (!takeFee) _restoreAllFee();

		// buys (pair -> holder) and sales (holder -> pair) control by time
        if (from == pancakePair && !_isExcludedFromMax[to] && isLockedSellPerTime) { // Buy
			uint256 timeCtrlToBuy = _locateAccountSellHistories(to);

            /** 
             * sale time lock valid only for the first purchase, 
             * from the second purchase onwards it will not be included in the record,
             * if time lock expires will be add the current time, 
             * the investor can sell their tokens at any time the sale lock expires.
             */
            if (timeCtrlToBuy == 0 || block.timestamp - timeCtrlToBuy > sellBackMaxTime) { 
				_addAccountSellHistories(to);
			}
		} else if (to == pancakePair && !_isExcludedFromMax[from] && isLockedSellPerTime) { // Sell
			_addAccountSellHistories(from);
			if (!_isExcludedFromReward[from]) {
			    _isExcludedFromReward[from] = true;
		    }
			// clear list of the old holders
			_removeOldSellHistories();
		}
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
 
        emit Approval(owner, spender, amount);
    }

    function _tokensInLiquidityPool(IPancakePair _tokenLiquidityPool) private view returns (address, uint256, address, uint256) {
		address token0                         = _tokenLiquidityPool.token0();
		address token1                         = _tokenLiquidityPool.token1();
		(uint256 reserve0, uint256 reserve1, ) = _tokenLiquidityPool.getReserves();
		address etbToken;
		uint256 etbAmount;
		address bnbToken;
		uint256 bnbAmount;

		if (token0 == pancakeRouter.WETH()) {
			bnbToken  = token0;
			bnbAmount = reserve0;
			etbToken  = token1;
			etbAmount = reserve1;
		} else if (token1 == pancakeRouter.WETH()) {
			bnbToken  = token1;
			bnbAmount = reserve1;
			etbToken  = token0;
			etbAmount = reserve0;
		}

		return (etbToken, etbAmount, bnbToken, bnbAmount);
    }

    function _locateAccountSellHistories(address account) private view returns (uint256) {
        uint256 time = 0;

		for (uint256 i = 0; i < _sellHistories.length; i++) {
            if (_sellHistories[i].account == account) {
				time = _sellHistories[i].time;
                break;
            }
        }

		return time;
    }

	function _etbTokensMaxPermited(address from, uint256 _etbInLiquidityPool, uint256 _bnbInLiquidityPool) private view returns (uint256) {
		// pre fixed values
		uint256 tokensPermited         = 0;
		uint256 etbTokenPermitedToSell = 0;
		uint256 bnbPermitedToSell      = 0;
		// calcule balance of sender
		uint256 etbTokenBalance	 = balanceOf(from);
		// calcule reserve of BNB at Liquidity Pool
		uint256 bnbReservedInLP	 = _calculateBNBReservedInLiquidityPool();
		// calcule max of BNBs per Dolar
		uint256 maxOfBnbPerDolar = _calculateMaxOfBNBPerDolar(from);
		// calcule max of Ethera Black tokens per BNB
		(uint256 etbTokenPerBnb, uint256 maxOfEtbTokenPerDolar) = _calculateETBTokensMaxPermited(maxOfBnbPerDolar, _etbInLiquidityPool, _bnbInLiquidityPool);

		if (etbTokenBalance > etbTokenBalanceOverRage) {
			etbTokenPermitedToSell = etbTokenBalance.mul(etbTokenMaxBalanceToSellPercent).div(10**2);
		}
		if (_bnbInLiquidityPool > bnbReservedInLP) {
			bnbPermitedToSell = _bnbInLiquidityPool.sub(bnbReservedInLP);
			tokensPermited    = etbTokenPerBnb.mul(bnbPermitedToSell).div(10**18);
			if (etbTokenPermitedToSell != 0 && tokensPermited > etbTokenPermitedToSell) {
				tokensPermited = etbTokenPermitedToSell;
			}
			if (tokensPermited > maxOfEtbTokenPerDolar) {
				tokensPermited = maxOfEtbTokenPerDolar;
			}
		}

		return tokensPermited;
    }

	function _swapAndtransferBnbToMarketingBlack(uint256 tokenAmount) private lockTheSwap {
        // generate the pancake pair path of etb -> wbnb
        address[] memory path = new address[](2);

        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        _approve(address(this), address(pancakeRouter), tokenAmount);

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            marketingBlack,
            block.timestamp
        );
    }

	function _removeAllFee() private {
        if (_burnFee == 0 && _marketingFee == 0 && _etheraBetsFee == 0) return;

        _previousBurnFee       = _burnFee;
        _previousMarketingFee  = _marketingFee;
        _previousEtheraBetsFee = _etheraBetsFee;

		_burnFee       = 0;
		_marketingFee  = 0;
		_etheraBetsFee = 0;
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 burnFee        = _calculateBurnFee(tAmount);
        uint256 marketingFee   = _calculateMarketingFee(tAmount);
        uint256 etheraBetsFee  = _calculateEtheraBetsFee(tAmount);
		uint256 transferAmount = tAmount.sub(burnFee).sub(marketingFee).sub(etheraBetsFee);

        return (transferAmount, burnFee, marketingFee, etheraBetsFee);
    }

    function _burnEtb(address sender, uint256 burnAmount) private {
	    if (burnAmount != 0) {
			emit Transfer(sender, _burnAddress, burnAmount);

            _tBurnTotal = _tBurnTotal.add(burnAmount);
	    }
    }

	function _transferFees(address sender, uint256 marketingAmount, uint256 etheraBetsAmount) private {
        if (marketingAmount != 0) {
            _balances[address(this)] = _balances[address(this)].add(marketingAmount);

            emit Transfer(sender, address(this), marketingAmount);
        }
		if (etheraBetsAmount != 0) {
            _balances[etheraBetsWallet] = _balances[etheraBetsWallet].add(etheraBetsAmount);

            emit Transfer(sender, etheraBetsWallet, etheraBetsAmount);
        }
    }

	function _restoreAllFee() private {
	    _burnFee       = _previousBurnFee;
        _marketingFee  = _previousMarketingFee;
		_etheraBetsFee = _previousEtheraBetsFee;
    }

    function _addAccountSellHistories(address account) private {
		SellHistories memory sellHistory;

        sellHistory.account = account;
		sellHistory.time    = block.timestamp;
        _sellHistories.push(sellHistory);
	}

    function _removeOldSellHistories() private {
        uint256 i                        = 0;
        uint256 maxStartTimeForHistories = block.timestamp - sellBackMaxTime;

        for (uint256 j = 0; j < _sellHistories.length; j++) {
            if (_sellHistories[j].time >= maxStartTimeForHistories) {
                if (_sellHistories[j].time != _sellHistories[i].time) {
                    _sellHistories[i].account = _sellHistories[j].account;
				    _sellHistories[i].time    = _sellHistories[j].time;
                }
                i++;
            }
        }

        uint256 removedCnt = _sellHistories.length - i;

        for (uint256 j = 0; j < removedCnt; j++) {
			_sellHistories.pop();
        }
    }

	function _calculateBNBReservedInLiquidityPool() private view returns (uint256) {
		uint256 bnbOfPercent     = inittialBNBInLiquidityPool.mul(maxOfBnbToSwapPercent).div(10**2);
		uint256 bnbReservedInLP	 = inittialBNBInLiquidityPool.sub(bnbOfPercent);

		bnbReservedInLP	= bnbReservedInLP.mul(10**18);

		return bnbReservedInLP;
	}

	function _calculateMaxOfBNBPerDolar(address account) private view returns (uint256) {
		// check account limited to sell
		uint256 limitPerAccountInDolar                   = amountOfAccountInSellLimitsInDolar(account);
		(, uint256 busdTokenAmount, , uint256 bnbAmount) = _tokensInLiquidityPool(_bnbBusdPairAddress);
		uint256 bnbPerDolar                              = bnbAmount.mul(10**18).div(busdTokenAmount);
		uint256 maxOfBnbPerDolar                         = bnbPerDolar.mul(sellMaxTxAmountPerDolar);

		if (limitPerAccountInDolar !=0 ) {
			maxOfBnbPerDolar = bnbPerDolar.mul(limitPerAccountInDolar);
		}

		return maxOfBnbPerDolar;
	}

	function _calculateETBTokensMaxPermited(uint256 bnbPerDolar, uint256 _etbTokenInLP, uint256 _bnbInLP) private pure returns (uint256, uint256) {
		uint256 etbTokenPerBnb        = _etbTokenInLP.mul(10**18).div(_bnbInLP);
		uint256 maxOfEtbTokenPerDolar = etbTokenPerBnb.mul(bnbPerDolar).div(10**18);

		return (etbTokenPerBnb, maxOfEtbTokenPerDolar);
	}

    function _calculateBurnFee(uint256 _amount) private view returns (uint256) { return _amount.mul(_burnFee).div(10**2); }

    function _calculateMarketingFee(uint256 _amount) private view returns (uint256) { return _amount.mul(_marketingFee).div(10**2); }

	function _calculateEtheraBetsFee(uint256 _amount) private view returns (uint256) { return _amount.mul(_etheraBetsFee).div(10**2); }
}
/**
 * End contract
 * 
 * Developed by @tadryanom Ethera.cc
 */