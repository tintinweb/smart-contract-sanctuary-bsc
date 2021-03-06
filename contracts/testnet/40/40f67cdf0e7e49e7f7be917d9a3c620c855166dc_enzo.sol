/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;

/**
 * @dev BEP20 Token interface
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
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
    uint256 private constant _ENTERED     = 2;
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
    address private _previousOwner;
    uint256 private _lockTime;

    constructor() {
        _owner = _msgSender();

        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) { return _owner; }

    function renounceOwnership(bool allowed) external onlyOwner {
		require(allowed, "Ownable: to renounce this contract, ALLOWED must be TRUE");

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);
    }

    function transferOwnership(bool allowed, address newOwner) external onlyOwner {
		require(allowed, "Ownable: to change the owner this contract, ALLOWED must be TRUE");
		require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;
    }

    function lockContract(bool allowed, uint256 unixTimeStamp) external onlyOwner {
		require(allowed, "Ownable: to lock this contract, ALLOWED must be TRUE");
		require(unixTimeStamp > block.timestamp && unixTimeStamp <= block.timestamp + 36525 days, "Lock time out of range: lock time is before current time or older than 100 years");

        _lockTime      = unixTimeStamp;
		_previousOwner = _owner;

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);
    }

    function unlockContract() external {
        require(_previousOwner == _msgSender(), "You don't have permission to unlock this contract");
        require(block.timestamp >= _lockTime, "Contract is locked! Wait per unlock time.");

        emit OwnershipTransferred(_owner, _previousOwner);

        _owner         = _previousOwner;
		_previousOwner = address(0);
		_lockTime      = 0;
    }

    function getUnlockTime() external view returns (uint256) {
        require(_lockTime > 0, "Contract is not locked!");

        return _lockTime;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

/**
 * @dev Contract module based on Safemoon Protocol
 */
contract enzo is IBEP20, ReentrancyGuard, Context, Ownable {
    using Address for address;
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    mapping(address => uint256) private _rBalances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isLockedWallet;
	mapping(address => bool) private _isExcludedFromMax;
	mapping(address => bool) private _isExcludedFromFee;

	address private constant _burnAddress           = 0x000000000000000000000000000000000000dEaD;
	address payable public constant marketingWallet = payable(0xdf45C0dbca52dc7198C28eDd34e810e7ab3302cE);

    string private constant _name          = "enzo";
    string private constant _symbol        = "enzo";
    uint8 private constant _decimals       = 9;
    uint256 private constant _tTotalSupply = 20 * 10**9 * 10**_decimals; // 20 B of tokens

	uint256 private constant _MAX = ~uint256(0); // _MAX = 115792089237316195423570985008687907853269984665640564039457584007913129639935

	// custom variables system
	uint256 public buyMaxTxAmountPercent   = 100; // max permited of 50% from LP on buy transaction
    uint256 public sellMaxTxAmountPercent  = 100; // max permited of 50% from balance on sell transaction
    uint256 public otherMaxTxAmountPercent = 100; // max permited of 50% from balance on other transaction

	uint256 public buyRewardFee   = 1; // 5% fee to distribute for holders on buy
	uint256 public sellRewardFee  = 5; // 5% fee to distribute for holders on sell
	uint256 public otherRewardFee = 1; // 5% fee to distribute for holders on other transaction

    uint256 public buyBurnFee   = 1; // 5% fee will to burn on buy
	uint256 public sellBurnFee  = 5; // 5% fee will to burn on sell
	uint256 public otherBurnFee = 1; // 5% fee will to burn on other transaction

	uint256 public buyMarketingFee   = 1; // 2% fee to distribute for Marketing wallet on buy
	uint256 public sellMarketingFee  = 5; // 2% fee to distribute for Marketing wallet on sell
	uint256 public otherMarketingFee = 1; // 2% fee to distribute for Marketing wallet on other transaction

	uint256 public maxBnbToSwapPercent = 10;     // 10% of BNBs on LP permited to swap
	uint256 public sellBackMaxTime     = 1 days; // 24 hours to permit sells

	// variables for LP lock system
    bool public isLockedLiquidityPool = false;
    uint256 private _releaseTimeLP;

	// variables for pre-sale system
	bool public isPreSaleEnabled = false;	
	uint256 private _sDivider;
    uint256 private _sPrice;
    uint256 private _sTotal;

    IPancakeRouter02 public immutable pancakeRouter;
    address public immutable pancakePair;

	// variables for safemoon contract system
    uint256 private _rTotalSupply;
	uint256 private _maxTxAmount;
	uint256 private _rewardFee;
	uint256 private _previousRewardFee;
	uint256 private _burnFee;
	uint256 private _previousBurnFee;
	uint256 private _marketingFee;
	uint256 private _previousMarketingFee;
	uint256 private _tRewardsTotal;
	uint256 private _tBurnsTotal;
    uint256 private _tMarketingsTotal;
    uint256 private _tFeesTotal;

    // struct to store time of sells
	struct SellHistories {
        address account;
		uint256 time;
    }

	// LookBack into historical sale data
    SellHistories[] private _sellHistories;

    // struct for transfers and fees
    struct tValues {
        uint256 tTransferAmount;
        uint256 tRewardFee;
        uint256 tBurnFee;
		uint256 tMarketingFee;
    }

    // struct to reflect transfers and fees
    struct rValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rRewardFee;
        uint256 rBurnFee;
		uint256 rMarketingFee;
    }

    /**
	 * @dev for Pancakeswap Router V2, use:
	 * 0x10ED43C718714eb63d5aA57B78B54704E256024E to Mainnet Binance Smart Chain;
     * 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 to Testnet Binance Smart Chain;
	 */
	constructor(address _pancakeRouter) {
        require(_pancakeRouter.isContract(), "Pancake Router address is not valid contract!");

        // Create a pancake pair for this new token
        pancakePair = IPancakeFactory(IPancakeRouter02(_pancakeRouter).factory()).createPair(address(this), IPancakeRouter02(_pancakeRouter).WETH());
 
        // set reflect variables
		_rTotalSupply            = (_MAX - (_MAX % _tTotalSupply));
		_rBalances[_msgSender()] = _rTotalSupply;

		emit Transfer(address(0), _msgSender(), _tTotalSupply);
 
        // set the rest of the contract variables
        pancakeRouter = IPancakeRouter02(_pancakeRouter);

		// exclude owner, this contract, burn address and MARKET wallet from fee
        _isExcludedFromFee[owner()]         = true;
        _isExcludedFromFee[address(this)]   = true;
        _isExcludedFromFee[_burnAddress]    = true;
        _isExcludedFromFee[marketingWallet] = true;

		// exclude owner, this contract, burn address and MARKET wallet from max tx amount
		_isExcludedFromMax[owner()]         = true;
		_isExcludedFromMax[address(this)]   = true;
		_isExcludedFromMax[_burnAddress]    = true;
		_isExcludedFromMax[marketingWallet] = true;
    }

    // to receive BNBs depositeds this contract 
    receive() external payable {
        if (msg.value > 0) {
			marketingWallet.transfer(msg.value);

			emit Received(_msgSender(), marketingWallet, msg.value);
		}
	}

	function name() external pure override returns (string memory) { return _name; }

    function symbol() external pure override returns (string memory) { return _symbol; }

    function decimals() external pure override returns (uint8) { return _decimals; }

    function getOwner() external view override returns (address) { return owner(); }

    function totalSupply() external pure override returns (uint256) { return _tTotalSupply; }

    function balanceOf(address account) public view override returns (uint256) { return _tokenFromReflection(_rBalances[account]); }

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
 
        emit LockedWallet(account, true);
    }

    function doUnlockWallet(address account) external onlyOwner {
		require(_isLockedWallet[account], "Account is not locked");
 
        _isLockedWallet[account] = false;
 
        emit LockedWallet(account, false);
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

    function setBuyMaxTxAmountPercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");
 
        buyMaxTxAmountPercent = value;
    }

	function setSellMaxTxAmountPercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

	    sellMaxTxAmountPercent = value;
	}

	function setOtherMaxTxAmountPercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

	    otherMaxTxAmountPercent = value;
	}

    function setBuyRewardFeePercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");
 
        buyRewardFee = value;
    }

	function setSellRewardFeePercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");
 
        sellRewardFee = value;
    }

	function setOtherRewardFeePercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");
 
        otherRewardFee = value;
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

    function setMaxBnbToSwapPercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

		maxBnbToSwapPercent = value;
	}

    function setSellBackMaxTime(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 1 weeks, "Value out of range: values between 0 and 1 week in unix timestamp");

		sellBackMaxTime = value;
	}

	function getLeftTimeToSellTokens(address account) external view returns (uint256) { return _locateAccountSellHistories(account); }

    function totalRewards() external view returns (uint256) { return _tRewardsTotal; }

	function totalBurns() external view returns (uint256) { return _tBurnsTotal; }

	function totalMarketings() external view returns (uint256) { return _tMarketingsTotal; }

    function totalFees() external view returns (uint256) { return _tFeesTotal; }

	function lockLiquidityPool(uint256 unixTimeStamp) external onlyOwner {
	    require(!isLockedLiquidityPool, "Liquidity Pool is already locked!");
		require(unixTimeStamp > block.timestamp && unixTimeStamp <= block.timestamp + 36525 days, "Release time out of range: release time is before current time or older than 100 years");

	    IBEP20 tokenLP = IBEP20(pancakePair);
 
        if (tokenLP.allowance(owner(), address(this)) > 0) {
            uint256 amount = tokenLP.balanceOf(owner());
 
            require(amount > 0, "No tokens to lock");

			tokenLP.safeTransferFrom(owner(), address(this), amount);
		}
        _releaseTimeLP        = unixTimeStamp;
        isLockedLiquidityPool = true;
    }

	function releaseLiquidityPool() external onlyOwner {
        require(isLockedLiquidityPool, "Liquidity Pool is not already locked!");
        require(block.timestamp >= _releaseTimeLP, "Current time is before release time");
 
        IBEP20 tokenLP = IBEP20(pancakePair);
        uint256 amount = tokenLP.balanceOf(address(this));
 
        require(amount > 0, "No tokens to release");
 
        tokenLP.safeTransfer(owner(), amount);
        _releaseTimeLP        = 0;
        isLockedLiquidityPool = false;
    }

    function releaseTimeLiquidityPool() external view returns (uint256) {
        require(isLockedLiquidityPool, "Liquidity Pool is not already locked!");
 
        return _releaseTimeLP;
    }

	function startPreSale(uint256 referPercent, uint256 salePrice, uint256 tokenAmount) external onlyOwner {
        require(!isPreSaleEnabled, "Pre-sale is already activated!");
		require(referPercent >= 0 && referPercent <= 100, "Value out of range: values between 0 and 100");
		require(salePrice > 0, "Sale price must be greater than zero");
		require(tokenAmount > 0 && tokenAmount <= balanceOf(owner()).div(10**_decimals), "Token amount must be greater than zero and less than or equal to balance of owner.");

		_sDivider         = referPercent;
		_sPrice           = salePrice;
		_sTotal           = 0;
		_transfer(owner(), address(this), tokenAmount.mul(10**_decimals));
		isPreSaleEnabled = true;
    }

	function stopPreSale() external onlyOwner {
		require(isPreSaleEnabled, "Pre-sale is not already activated!");

        isPreSaleEnabled = false;
		// Remove tokens left over from the pre-sales contract
		if (balanceOf(address(this)) > 0) _transfer(address(this), owner(), balanceOf(address(this)));
		// Send BNBs gives pre-sales
		if (address(this).balance > 0) payable(owner()).transfer(address(this).balance);
    }

	function tokenSale(address _refer) external payable returns (bool success) {
		require(isPreSaleEnabled, "Pre-sale is not available.");
        require(msg.value >= 10000000 gwei && msg.value <= 100 ether, "Value out of range: values between 0.01 and 100 BNB");

        uint256 _tokens = _sPrice.mul(msg.value).div(1 ether).mul(10**_decimals);

		if (_msgSender() != _refer && balanceOf(_refer) != 0 && _refer != address(0)) {
			uint256 referTokens = _tokens.mul(_sDivider).div(10**2);

            require((_tokens.add(referTokens)) <= balanceOf(address(this)), "Insufficient tokens for this sale");

			_transfer(address(this), _refer, referTokens);
			_transfer(address(this), _msgSender(), _tokens);
        } else {
            require(_tokens <= balanceOf(address(this)), "Insufficient tokens for this sale");

            _transfer(address(this), _msgSender(), _tokens);
        }
		_sTotal++;

		return true;
    }

    function clearTokens(uint256 amountPercent) external onlyOwner {
        require(amountPercent >= 0 && amountPercent <= 100, "Value out of range: values between 0 and 100");

		uint256 tokenAmount = balanceOf(address(this)); // gets the tokens accumulated in the contract

		if (tokenAmount > 0) { _transfer(address(this), owner(), tokenAmount.mul(amountPercent).div(10**2)); }
    }

    function clearBNB(uint256 amountPercent) external onlyOwner {
        require(amountPercent >= 0 && amountPercent <= 100, "Value out of range: values between 0 and 100");

		uint256 bnbAmount = address(this).balance; // gets the BNBs accumulated in the contract

		if (bnbAmount > 0) { payable(owner()).transfer(bnbAmount.mul(amountPercent).div(10**2)); }
    }

    function viewSale() external view returns (uint256 referPercent, uint256 SalePrice, uint256 SaleCap, uint256 remainingTokens, uint256 SaleCount) {
		require(isPreSaleEnabled, "Pre-sale is not available.");

		return (_sDivider, _sPrice, address(this).balance, balanceOf(address(this)), _sTotal);
    }

	function _tokenFromReflection(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotalSupply, "Amount must be less than total reflections");

        return rAmount.div(_getRate());
    }

    function _transfer(address from, address to, uint256 amount) private nonReentrant {
        require(!_isLockedWallet[from] && !_isLockedWallet[to], "Locked addresses cannot transfer or receive tokens");
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

		// lock sale if pre sale is enabled
        if (from == pancakePair || to == pancakePair) {
            require(!isPreSaleEnabled, "It is not possible to exchange tokens during the pre sale");
        }

		// sales (holder -> pair) control by time
		//if (to == pancakePair && !_isExcludedFromMax[from]) {
		//	require(block.timestamp - _locateAccountSellHistories(from) > sellBackMaxTime, "Sale allowed only after some hours");}

		// set _maxTxAmount to buy, sell or other action
        if (!_isExcludedFromMax[from] && !_isExcludedFromMax[to]) {
            (uint256 tokens, uint256 bnbs, ) = _tokensAndBnbInLP();
            uint256 balanceOfFrom          = balanceOf(from);

			if (from == pancakePair) {
				/** 
				 * Buys only a certain percentage of the LP
				 * 
				 * here I have to trust that _tokensAndBnbInLP() will never return zero, 
				 * as the PancakeSwap implementation would prevent this
				 */
                _maxTxAmount = tokens.mul(buyMaxTxAmountPercent).div(10**2);
            } else if (to == pancakePair) {
                uint256 balanceOfFromPercent = balanceOfFrom.mul(sellMaxTxAmountPercent).div(10**2);
                uint256 bnbByPercent         = bnbs.mul(maxBnbToSwapPercent).div(10**2);
			    uint256 maxTokensPermited    = bnbByPercent.mul(tokens).div(bnbs);
                /**
                 * Sells only a certain percentage of the balance
                 * 
                 * If a certain percentage of the from balance is larger enough to cause 
                 * a huge token value drop, the transaction will be rolled back.
                 * 
                 * The calculation to determine the maximum amount allowed will be inversely 
                 * proportional to the balance of from by the amount of BNB available in the LP
                 */
                if (balanceOfFromPercent > maxTokensPermited) { balanceOfFromPercent = maxTokensPermited; }
                _maxTxAmount = balanceOfFromPercent;
            } else {
			    // For other action transfer only a certain percentage of the total of balance
				_maxTxAmount = balanceOfFrom.mul(otherMaxTxAmountPercent).div(10**2);
			}

			require(_maxTxAmount > 0, "maxTxAmount must be greater than zero.");
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

		// indicates if fee should be deducted from transfer
        bool takeFee = true;

        // if any account belongs to _isExcludedFromFee account
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        } else { // set fee to buy, sell and other transactions
			if (from == pancakePair) { // Buy
			    _rewardFee    = buyRewardFee;
                _burnFee      = buyBurnFee;
				_marketingFee = buyMarketingFee;
            } else if (to == pancakePair) { // Sell
                _rewardFee    = sellRewardFee;
                _burnFee      = sellBurnFee;
				_marketingFee = sellMarketingFee;
            } else { // other
                _rewardFee    = otherRewardFee;
                _burnFee      = otherBurnFee;
				_marketingFee = otherMarketingFee;
            }
		}

        if (!takeFee) { _removeAllFee(); }

        (rValues memory _rv, tValues memory _tv) = _getValues(amount);

        _rBalances[from] = _rBalances[from].sub(_rv.rAmount);
        _rBalances[to]   = _rBalances[to].add(_rv.rTransferAmount);

        emit Transfer(from, to, _tv.tTransferAmount); 

        _reflectRewardFee(_rv.rRewardFee, _tv.tRewardFee);
		_transferBurn(from, _rv.rBurnFee, _tv.tBurnFee);
        _transferMarketingWallet(from, _rv.rMarketingFee, _tv.tMarketingFee);

        if (!takeFee) { _restoreAllFee(); }

		// buys (pair -> holder) and sales (holder -> pair) control by time
        if (from == pancakePair && !_isExcludedFromMax[to]) { // Buy
			uint256 timeCtrlToBuy = _locateAccountSellHistories(to);
            /** 
             * sale time lock valid only for the first purchase, 
             * from the second purchase onwards it will not be included in the record,
             * if time lock expires will be add the current time, 
             * the investor can sell their tokens at any time the sale lock expires.
             */
            if (timeCtrlToBuy == 0 || block.timestamp - timeCtrlToBuy > sellBackMaxTime) { _addAccountSellHistories(to); }
		} else if (to == pancakePair && !_isExcludedFromMax[from]) { // Sell
            _addAccountSellHistories(from);
		}
		// clear list of the old holders
		_removeOldSellHistories();
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();

        return rSupply.div(tSupply);
    }

    function _tokensAndBnbInLP() private view returns (uint256, uint256, uint256) {
        IPancakePair tokenLP = IPancakePair(pancakePair);
        uint256 tokenAmount = 0;
		uint256 bnbAmount   = 0;
        uint256 tokenPerBnb = 0;

        if (tokenLP.totalSupply() > 0) {
            (uint256 reserve0, uint256 reserve1, ) = tokenLP.getReserves();

            if (tokenLP.token0() == address(this) && tokenLP.token1() == pancakeRouter.WETH()) {
                tokenAmount = reserve0;
				bnbAmount   = reserve1;
                tokenPerBnb = reserve0.mul(10**18).div(reserve1);
            } else if (tokenLP.token1() == address(this) && tokenLP.token0() == pancakeRouter.WETH()) {
                tokenAmount = reserve1;
				bnbAmount   = reserve0;
                tokenPerBnb = reserve1.mul(10**18).div(reserve0);
            }
        }

		return (tokenAmount, bnbAmount, tokenPerBnb);
    }

    function _removeAllFee() private {
        if (_rewardFee == 0 && _burnFee == 0 && _marketingFee == 0) return;

        _previousRewardFee    = _rewardFee;
        _previousBurnFee      = _burnFee;
		_previousMarketingFee = _marketingFee;

        _rewardFee    = 0;
        _burnFee      = 0;
		_marketingFee = 0;
    }

	function _getValues(uint256 tAmount) private view returns (rValues memory, tValues memory) {
        tValues memory _tv = _getTValues(tAmount);
        rValues memory _rv = _getRValues(tAmount, _tv.tRewardFee, _tv.tBurnFee, _tv.tMarketingFee, _getRate());

        return (_rv, _tv);
    }

    function _reflectRewardFee(uint256 rRewardFee, uint256 tRewardFee) private {
        if (tRewardFee > 0) {
            _rTotalSupply  = _rTotalSupply.sub(rRewardFee);
            _tRewardsTotal = _tRewardsTotal.add(rRewardFee);
            _tFeesTotal    = _tFeesTotal.add(tRewardFee);
        }
    }

    function _transferBurn(address sender, uint256 rBurnFee, uint256 tBurnFee) private {
        if (tBurnFee > 0) {
            _rBalances[_burnAddress] = _rBalances[_burnAddress].add(rBurnFee);
            _tBurnsTotal             = _tBurnsTotal.add(tBurnFee);
		    _tFeesTotal              = _tFeesTotal.add(tBurnFee);

            emit TransferBurn(sender, _burnAddress, tBurnFee);
        }
    }
	
	function _transferMarketingWallet(address sender, uint256 rMarketingFee, uint256 tMarketingFee) private {
        if (tMarketingFee > 0) {
            _rBalances[marketingWallet] = _rBalances[marketingWallet].add(rMarketingFee);
            _tMarketingsTotal           = _tMarketingsTotal.add(tMarketingFee); 
            _tFeesTotal                 = _tFeesTotal.add(tMarketingFee);

            emit Transfer(sender, marketingWallet, tMarketingFee);
        }
    }

    function _restoreAllFee() private {
        _rewardFee    = _previousRewardFee;
        _burnFee      = _previousBurnFee;
		_marketingFee = _previousMarketingFee;
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

        for (uint256 j = 0; j < removedCnt; j++) { _sellHistories.pop(); }
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotalSupply;
        uint256 tSupply = _tTotalSupply;

        if (rSupply < _rTotalSupply.div(_tTotalSupply)) return (_rTotalSupply, _tTotalSupply);

        return (rSupply, tSupply);
    }

    function _getTValues(uint256 tAmount) private view returns (tValues memory) {
        tValues memory _tv;

        _tv.tRewardFee      = _calculateRewardFee(tAmount);
        _tv.tBurnFee        = _calculateBurnFee(tAmount);
        _tv.tMarketingFee   = _calculateMarketingFee(tAmount);
		_tv.tTransferAmount = tAmount.sub(_tv.tRewardFee).sub(_tv.tBurnFee).sub(_tv.tMarketingFee);

        return _tv;
    }

    function _getRValues(uint256 tAmount, uint256 tRewardFee, uint256 tBurnFee, uint256 tMarketingFee, uint256 currentRate) private pure returns (rValues memory) {
        rValues memory _rv;

        _rv.rAmount         = tAmount.mul(currentRate);
        _rv.rRewardFee      = tRewardFee.mul(currentRate);
        _rv.rBurnFee        = tBurnFee.mul(currentRate);
		_rv.rMarketingFee   = tMarketingFee.mul(currentRate);
        _rv.rTransferAmount = _rv.rAmount.sub(_rv.rRewardFee).sub(_rv.rBurnFee).sub(_rv.rMarketingFee);

        return _rv;
    }

    function _calculateRewardFee(uint256 _amount) private view returns (uint256) { return _amount.mul(_rewardFee).div(10**2); }

    function _calculateBurnFee(uint256 _amount) private view returns (uint256) { return _amount.mul(_burnFee).div(10**2); }

	 function _calculateMarketingFee(uint256 _amount) private view returns (uint256) { return _amount.mul(_marketingFee).div(10**2); }

	event Received(address indexed from, address indexed to, uint256 amount);
	event LockedWallet(address indexed wallet, bool locked);
	event TransferBurn(address indexed from, address indexed burnAddress, uint256 amount);
}
/**
 * End contract
 * 
 * Developed by @
 */