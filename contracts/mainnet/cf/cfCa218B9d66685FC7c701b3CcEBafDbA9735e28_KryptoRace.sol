/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

/**
 * KryptoRace ($KRC)
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

	function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

/**
 * @dev Main Contract module
 */
contract KryptoRace is IBEP20, ReentrancyGuard, Context, Ownable {
	using Address for address;
	using SafeBEP20 for IBEP20;
	using SafeMath for uint256;

	uint256 private _tFeeTotal;
	uint256 private _marketingFee;
    uint256 private _previousMarketingFee;
	uint256 private _maxTxAmount;
	bool private _inSwapTokens;

	string private constant _name         = "KryptoRace";
    string private constant _symbol       = "KRC";
	uint8 private constant _decimals      = 9;
	uint256 private constant _totalSupply = 10 * 10**12 * 10**_decimals; // 10T

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

	IPancakeRouter02 public immutable pancakeRouter;
    address public immutable pancakePair;

	mapping(address => bool) private _isLockedWallet;
    mapping(address => bool) private _isExcludedFromMax;
	mapping(address => bool) private _isExcludedFromFee;
	mapping(address => uint256) private _sellLimits;

	// custom variables system
	uint256 public buyMarketingFee   = 0;  // 0% Fee to Marketing wallet on buy
	uint256 public sellMarketingFee  = 0;  // 0% Fee to Marketing wallet on sell
	uint256 public otherMarketingFee = 0;  // 0% Fee to Marketing wallet on other transaction

	bool public isLockedSellEnabled                = false;
	bool public isKrcTokenMaxBalanceToSellEnabled  = true;
	uint256 public krcTokenMaxBalanceToSellPercent = 10; // 10%
	bool public isSellMaxTxAmountPerDolarEnabled   = true;
	uint256 public sellMaxTxAmountPerDolar         = 1000; // $1000 to sell of KryptoRace Token balance of the owner

	bool public isSwapTokensEnabled     = false;
	uint256 public numOfKrcTokensToSwap = _totalSupply / 2000; // number of tokens accumulated to exchange (0.05% of total supply)

	/**
	 * @dev For Pancakeswap Router V2, use:
	 * 0x10ED43C718714eb63d5aA57B78B54704E256024E to Mainnet Binance Smart Chain;
	 *
	 * For WBNB/BUSD Liquidity Pool Pair, use:
	 * 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16 to Mainnet Binance Smart Chain;
	 *
	 * For KryptoRace Token, use:
	 * 0xC32c009BAEF44c0dd2f4458434bd6481807D3298 to Mainnet Binance Smart Chain;
	 */
	IPancakeRouter02 private constant _pancakeRouterAddress = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
	IPancakePair private constant _bnbBusdPairAddress       = IPancakePair(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16);
	address private constant _kryptoRaceTokenAddress        = 0xC32c009BAEF44c0dd2f4458434bd6481807D3298;

	// burn address
	address private constant _burnAddress = 0x000000000000000000000000000000000000dEaD;

	// Dev's wallets
	address payable public constant marketingWallet = payable(0x5f3E7a61E55D25a415f76c38F528Ed6738d6108F);

	constructor() {
		// set totalSupply variable
		_balances[_msgSender()] = _totalSupply;

		emit Transfer(address(0), _msgSender(), _totalSupply);

		// Create a pancake pair for this new token, setting ethera token address
		pancakePair   = IPancakeFactory(_pancakeRouterAddress.factory()).createPair(address(this), _pancakeRouterAddress.WETH());
		pancakeRouter = _pancakeRouterAddress;

		// exclude owner, this contract, marketing wallet from limits of transaction
		_isExcludedFromMax[owner()]          = true;
		_isExcludedFromMax[address(this)]    = true;
		_isExcludedFromMax[marketingWallet]  = true;

		// exclude owner, this contract, marketing wallet from fees
		_isExcludedFromFee[owner()]          = true;
		_isExcludedFromFee[address(this)]    = true;
		_isExcludedFromFee[marketingWallet]  = true;
    }

	modifier lockTheSwap {
        _inSwapTokens = true;
        _;
        _inSwapTokens = false;
    }

	// to receive BNBs
    receive() external payable {
		if (msg.value != 0) { 
		    marketingWallet.transfer(msg.value);
		}
	}

	function totalFees() external view returns (uint256) { return _tFeeTotal; }

    function getOwner() external view override returns (address) { return owner(); }

    function name() external pure override returns (string memory) { return _name; }

    function symbol() external pure override returns (string memory) { return _symbol; }

    function decimals() external pure override returns (uint8) { return _decimals; }

    function totalSupply() public pure override returns (uint256) { return _totalSupply; }

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

	function setLockedSellEnabled(bool enabled) external onlyOwner {
		isLockedSellEnabled = enabled;
	}

	function setKrcTokenMaxBalanceToSellEnabled(bool enabled) external onlyOwner {
        isKrcTokenMaxBalanceToSellEnabled = enabled;
    }

	function setKrcTokenMaxBalanceToSellPercent(uint256 value) external onlyOwner {
		require(value >= 0 && value <= 100, "Value out of range: values between 0 and 100");

		krcTokenMaxBalanceToSellPercent = value;
	}

	function setSellMaxTxAmountPerDolarEnabled(bool enabled) external onlyOwner {
        isSellMaxTxAmountPerDolarEnabled = enabled;
    }

	function setSellMaxTxAmountPerDolar(uint256 value) external onlyOwner {
		(address busdTokenAddress, , , ) = _tokensInLiquidityPool(_bnbBusdPairAddress);

		require(value >= 1 && value <= IBEP20(busdTokenAddress).totalSupply().div(10**18), "Value out of range: values between 1 and total supply of BUSD");

	    sellMaxTxAmountPerDolar = value;
	}

	function setSwapTokensEnabled(bool enabled) external onlyOwner {
		isSwapTokensEnabled = enabled;
    }

	function setNumOfKrcTokensToSwap(uint256 value) external onlyOwner {
        (, uint256 maxValue, , ) = _tokensInLiquidityPool(IPancakePair(pancakePair));

        require(maxValue != 0, "Contract without liquidity!");
        require(value >= 0 && value <= maxValue.div(10**_decimals), "Value out of range: values between 0 and max of ETB in liquidity Pool");

		numOfKrcTokensToSwap = value.mul(10**_decimals);
    }

	function clearKrcTokens(uint256 amountPercent) external onlyOwner {
        require(amountPercent >= 0 && amountPercent <= 100, "Value out of range: values between 0 and 100");
		// gets the KRC tokens left over from contract
		uint256 krcAmount = balanceOf(address(this));

		if (krcAmount != 0) {
			_transfer(address(this), owner(), krcAmount.mul(amountPercent).div(10**2));
		}
    }

	function ClaimKrcTokens() external returns (bool success) {
		address sender            = _msgSender();
		IBEP20 krcPreSaleToken    = IBEP20(_kryptoRaceTokenAddress);
		uint256 krcPreSaleBalance = krcPreSaleToken.balanceOf(sender);

		require(krcPreSaleBalance != 0, "You have no KRC Presale balance");
		require(balanceOf(sender) == 0, "You already have KRC in your wallet");
		require(krcPreSaleToken.allowance(sender, address(this)) == krcPreSaleBalance, "it is necessary to approve this transaction");

		krcPreSaleToken.safeTransferFrom(sender, _burnAddress, krcPreSaleBalance);
		_transfer(address(this), sender, krcPreSaleBalance);

		return true;
    }

	function _transfer(address from, address to, uint256 amount) private nonReentrant {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount != 0, "Transfer amount must be greater than zero");

        // prevents transfer of blocked wallets
        require(!_isLockedWallet[from] && !_isLockedWallet[to], "Locked addresses cannot call this function");

		// lock sales
        if (to == pancakePair) { // Sell
            require(!isLockedSellEnabled, "Unable to sell tokens at the moment");
        }

        // exclude from max
        if (from != owner() && to != owner() && 
			!_isExcludedFromMax[from] && !_isExcludedFromMax[to]) {
			if (to == pancakePair) {
				(, uint256 krcTokenAmount, , uint256 bnbAmount) = _tokensInLiquidityPool(IPancakePair(pancakePair));

				_maxTxAmount = _krcTokensMaxPermited(from, krcTokenAmount, bnbAmount);
            }

            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

		// is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
		uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance     = contractTokenBalance >= numOfKrcTokensToSwap;

        if (overMinTokenBalance && !_inSwapTokens &&
		    from != pancakePair && isSwapTokensEnabled) {
            contractTokenBalance = numOfKrcTokensToSwap;
            // swap Tokens for BNB and transfer BNBs to Marketing Wallet 
            _swapAndtransferBnbToMarketing(contractTokenBalance);
        }

        // indicates if fee should be deducted from transfer
        bool takeFee = true;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        } else {
            // set _taxFee and _liquidityFee to buy or sell action
            if (from == pancakePair) { // Buy
				_marketingFee = buyMarketingFee;
            } else if (to == pancakePair) { // Sell
                _marketingFee = sellMarketingFee;
            } else { // other
                _marketingFee = otherMarketingFee;
            }
        }

        // transfer amount, it will take tax, burn fee
        if (!takeFee) _removeAllFee();

        (uint256 tTransferAmount, uint256 tMarketingFee) = _getTValues(amount);

		_balances[from] = _balances[from].sub(amount);
        _balances[to]   = _balances[to].add(tTransferAmount);

        emit Transfer(from, to, tTransferAmount);

		_transferFees(from, tMarketingFee);
        _tFeeTotal = _tFeeTotal.add(tMarketingFee);

        if (!takeFee) _restoreAllFee();
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
		address krcToken;
		uint256 krcAmount;
		address bnbToken;
		uint256 bnbAmount;

		if (token0 == pancakeRouter.WETH()) {
			bnbToken  = token0;
			bnbAmount = reserve0;
			krcToken  = token1;
			krcAmount = reserve1;
		} else if (token1 == pancakeRouter.WETH()) {
			bnbToken  = token1;
			bnbAmount = reserve1;
			krcToken  = token0;
			krcAmount = reserve0;
		}

		return (krcToken, krcAmount, bnbToken, bnbAmount);
    }

	function _krcTokensMaxPermited(address from, uint256 _krcInLiquidityPool, uint256 _bnbInLiquidityPool) private view returns (uint256) {
		// pre fixed values
		uint256 tokensPermited         = 0;
		uint256 krcTokenPermitedToSell = 0;
		uint256 maxOfKrcTokenPerDolar  = 0;
		// calcule balance of sender
		uint256 krcTokenBalance	= balanceOf(from);

		if (isKrcTokenMaxBalanceToSellEnabled) {
			krcTokenPermitedToSell = krcTokenBalance.mul(krcTokenMaxBalanceToSellPercent).div(10**2);
			tokensPermited         = krcTokenPermitedToSell;
		}
		if (isSellMaxTxAmountPerDolarEnabled) {
			// calcule max of BNBs per Dolar
			uint256 maxOfBnbPerDolar = _calculateMaxOfBNBPerDolar(from);
			// calcule max of tokens per BNB
			maxOfKrcTokenPerDolar = _calculateKRCTokensMaxPermited(maxOfBnbPerDolar, _krcInLiquidityPool, _bnbInLiquidityPool);
			tokensPermited        = maxOfKrcTokenPerDolar;
		}
		if (krcTokenPermitedToSell == 0 && maxOfKrcTokenPerDolar == 0) {
			tokensPermited = krcTokenBalance;
		}

		return tokensPermited;
    }

	function _swapAndtransferBnbToMarketing(uint256 tokenAmount) private lockTheSwap {
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
            marketingWallet,
            block.timestamp
        );
    }

	function _removeAllFee() private {
        if (_marketingFee == 0) return;

        _previousMarketingFee = _marketingFee;

		_marketingFee  = 0;
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 marketingFee   = _calculateMarketingFee(tAmount);
		uint256 transferAmount = tAmount.sub(marketingFee);

        return (transferAmount, marketingFee);
    }

	function _transferFees(address sender, uint256 marketingAmount) private {
        if (marketingAmount != 0) {
            _balances[address(this)] = _balances[address(this)].add(marketingAmount);

            emit Transfer(sender, address(this), marketingAmount);
        }
    }

	function _restoreAllFee() private {
        _marketingFee  = _previousMarketingFee;
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

	function _calculateKRCTokensMaxPermited(uint256 bnbPerDolar, uint256 _krcTokenInLP, uint256 _bnbInLP) private pure returns (uint256) {
		uint256 krcTokenPerBnb        = _krcTokenInLP.mul(10**18).div(_bnbInLP);
		uint256 maxOfKrcTokenPerDolar = krcTokenPerBnb.mul(bnbPerDolar).div(10**18);

		return maxOfKrcTokenPerDolar;
	}

    function _calculateMarketingFee(uint256 _amount) private view returns (uint256) { return _amount.mul(_marketingFee).div(10**2); }
}
/**
 * End contract
 * 
 * Developed by @tadryanom
 */