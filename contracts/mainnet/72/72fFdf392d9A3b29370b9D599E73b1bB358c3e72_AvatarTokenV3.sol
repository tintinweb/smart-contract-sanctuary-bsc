/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


library IterableMapping {
    
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint256) {
        return map.values[key];
    }

    // start with 0 based. -1 not exists
    function getIndexOfKey(Map storage map, address key) public view returns (int256) {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set( Map storage map, address key, uint256 val ) public {
        // change value in second
        if (map.inserted[key]) {
            map.values[key] = val;
        } else { // setting value in first
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length; // save the index
            map.keys.push(key);  // add key
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }
        delete map.inserted[key];
        delete map.values[key];
        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];
        map.indexOf[lastKey] = index;
        delete map.indexOf[key];
        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

interface IUniswapV2Factory {

    // events
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    
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



interface IUniswapV2Router01 {
    
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
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);
    
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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
    
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);
        
    function swapTokensForExactETH(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline)
        external
        returns (uint256[] memory amounts);
        
    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        returns (uint256[] memory amounts);
        
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);
    
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


interface IAvatarToken {

    // methods
    function techInfo() external view returns(uint launchTs, uint unlockPerYear, uint totalBal, uint unlockBal, address addr);

    function balanceOf(address user_) external view returns (uint256);
    function totalSupply() external view returns (uint);
    function baseSupply() external view returns (uint);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);

    function setTechAddress(address addr_) external;
    function extractTech() external returns (bool);

    function transfer(address to_, uint value_) external returns (bool);
    function transferFrom(address from_, address to_, uint256 value_) external returns (bool);
    function approve(address spender_, uint256 value_) external returns (bool);

    function allowance(address own_, address spender_) external view returns (uint256);

    function increaseApproval(address spender_, uint addedValue_) external returns (bool);
    function decreaseApproval(address spender_, uint subtractedValue_) external returns (bool);

    function mint(uint amount_) external;
    function burn(uint amount_) external;

    function setBurnFeeRatePerTx(uint newRate_) external;
    function getBurnFeeRatePerTx() external view returns (uint);
    
    function excludeFee(address account) external;
    function includeFee(address account) external;
    function isExcludedFee(address account) external view returns(bool);
}


interface IAvatarTokenV3 is IERC20Metadata {

    event AdjustFee(uint256 newFee_);
    event ExcludedFee(address account, bool bYes);

    function baseSupply() external view returns (uint256);
    function extractTech() external returns (bool);
    
    function increaseApproval(address spender_, uint256 addedValue_) external returns (bool);
    function decreaseApproval(address spender_, uint256 subtractedValue_) external returns (bool);
    
    function burn(uint amount_) external;
    function burnFrom(address from_, uint256 amount_) external;
    
    function getFee() external view returns (uint);
    function isExcludedFee(address account) external view returns(bool);

    function setAmmPair(address pair_, bool hasPair_) external;

    function getBot(address acc_) external view returns (uint256);
    function getNumberOfBots() external view returns (uint256);
    function resetBot(address acc_, uint256 lockTs_) external;
    
    function setMinTsForSwap(uint newSecs_) external;
}


// Avatar Token V3
contract AvatarTokenV3 is IAvatarTokenV3, Ownable {
    
    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;

    struct TechInfo {
        uint launchTs;
        uint unlockPerYear;
        uint totalBal;
        uint unlockBal;
        address addr;
    }

    uint256 private constant MAX_UINT = ~uint256(0);
    uint256 constant TOKEN_UNIT = 10**18;
    int private constant MAX_TECH_LOCK_YEARS = 8;
    uint256 private constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 private constant MAX_SUPPLY = 3 * 10**8 * TOKEN_UNIT;                                   // 300 million

    string private _name = "Avatar Token V3";
    string private _symbol = "ATAR";

    uint256 private _totalSupply;
    uint256 private _baseSupply = 3 * 10**7 * TOKEN_UNIT;
    uint256 private _feeTx = 20;

    mapping(address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    mapping (address => bool) private _excludedFees;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    IERC20 public usdtToken;

    address public initPoolAddr;

    mapping(address => bool) private _ammPairs;
    mapping(address => uint256) private _swaplist;
    IterableMapping.Map private _botlist;
    uint256 private _minSwapSecs = 15 * 1 seconds;

    // tech stake
    TechInfo public techInfo;
    uint256 public launchTs;

    // old ATAR
    IAvatarToken private atar_v1;

    constructor() {
        
        atar_v1 = IAvatarToken(0x6Cac69efdA85888DCE4D7576bc8E366f4F444B28);                       // ATAR v1
        initPoolAddr = 0x8Fce2C303878E3Fe5B40e4E301EdC8E5A1E3d8af;                                // Init LP Addr by AVATAR
        usdtToken = IERC20(0x55d398326f99059fF775485246999027B3197955);                           // USDT
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);         // Pancakeswap Router 

        launchTs = block.timestamp;
        (techInfo.launchTs, techInfo.unlockPerYear, techInfo.totalBal, techInfo.unlockBal, techInfo.addr) = atar_v1.techInfo();

        ////////////////////////////
        
        //exclude owner and this contract from fee
        _excludedFees[_msgSender()] = true;
        _excludedFees[address(this)] = true;

        // mint tech
        _mint(address(this), techInfo.totalBal);                                                      // 36,000,000 ATAR for Tech

        // create pair
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), address(usdtToken));
        if ( uniswapV2Pair != address(0) ) {
            _ammPairs[uniswapV2Pair] = true;
        }

        _mint(owner(), atar_v1.totalSupply() - techInfo.totalBal);
    }

    receive() external payable {}

    //////////////////////////////////////////////////////////////////////////////

    function balanceOf(address user_) public override view returns (uint256) {
        return _balances[user_];
    }

    function totalSupply() public override view returns (uint) {
        return _totalSupply;
    }

    function baseSupply() public override view returns (uint) {
        return _baseSupply;
    }

    function decimals() public override pure returns (uint8) {
        return 18;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function name() public override view returns (string memory) {
        return _name;
    }
    
    function getFee() public view override returns (uint) {
        return _feeTx;
    }

    function isExcludedFee(address account) public override view returns(bool) {
        return _excludedFees[account];
    }

    function setExcludeFee(address account_, bool bSet_) public onlyOwner {
        _excludedFees[account_] = bSet_;
        emit ExcludedFee(account_, bSet_);
    }

    function setAmmPair(address pair_, bool hasPair_) public override onlyOwner {
        _ammPairs[pair_] = hasPair_;
    }

    function getBot(address acc_) public view override returns (uint256) {
        return _botlist.get(acc_);
    }

    function getNumberOfBots() public view override returns (uint256) {
        return _botlist.size();
    }

    function resetBot(address acc_, uint256 lockTs_) public override onlyOwner {
        _botlist.set(acc_, lockTs_);
    }

    function setMinTsForSwap(uint newSecs_) public override onlyOwner {
        _minSwapSecs = newSecs_;
    }
    
    // extract part of the tech
    function extractTech() public override returns (bool) {

        require(techInfo.addr != address(0), "et1");
        require(techInfo.totalBal > techInfo.unlockBal, "et2");
        require(_balances[address(this)] > 0, "et3");

        uint _elapsed = 0;
        int _days = int((block.timestamp - techInfo.launchTs) / SECONDS_PER_DAY);
        int _years = int(_days / 365);
        if ( _years < MAX_TECH_LOCK_YEARS ) {
            _elapsed = uint(_years) * techInfo.unlockPerYear;
        }
        else {
            _elapsed = techInfo.totalBal;
        }

        require(techInfo.unlockBal < _elapsed, "et5");

        uint _expect = _elapsed.sub(techInfo.unlockBal);
        techInfo.unlockBal = techInfo.unlockBal.add(_expect);

        _transfer(address(this), techInfo.addr, _expect, _expect);
        return true;
    }

    // transfer
    function transfer(address to_, uint value_) public override returns (bool) {
        return _transferFrom(_msgSender(), to_, value_);
    }

    // transferFrom
    function transferFrom(address from_, address to_, uint256 value_) public override returns (bool) {
        require(value_ <= _allowed[from_][_msgSender()], "tf1");
        _transferFrom(from_, to_, value_);
        if (_allowed[from_][_msgSender()] < MAX_UINT) {
            _allowed[from_][_msgSender()] = _allowed[from_][_msgSender()].sub(value_);
        }
        return true;
    }

    function approve(address spender_, uint256 amount_) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender_, amount_);
        return true;
    }

    function allowance(address own_, address spender_) public override view returns (uint256) {
        return _allowed[own_][spender_];
    }

    function increaseApproval(address spender_, uint addedValue_) public override returns (bool) {
        address owner_ = _msgSender();
        _approve(owner_, spender_, _allowed[owner_][spender_] + addedValue_);
        return true;
    }

    function decreaseApproval(address spender_, uint subtractedValue_) public override returns (bool) {
        address owner_ = _msgSender();
        uint256 curAllowance_ = _allowed[owner_][spender_];
        if (subtractedValue_ > curAllowance_ ) {
            subtractedValue_ = curAllowance_;
        }
        unchecked {
            _approve(owner_, spender_, curAllowance_ - subtractedValue_);
        }
        return true;
    }

    function burn(uint amount_) public override {
        return _burn(_msgSender(), amount_);
    }

    function burnFrom(address from_, uint amount_) public override {
        _approve(from_, _msgSender(), _allowed[from_][_msgSender()].sub(amount_, "ERC20: decreased allowance below zero"));
        _burn(from_, amount_);
    }

    function _approve(address owner_, address spender_, uint256 amount_) internal {
        require(owner_ != address(0), "a1");
        require(spender_ != address(0), "a2");
        _allowed[owner_][spender_] = amount_;
        emit Approval(owner_, spender_, amount_);
    }

    function _spendAllowance(address owner_, address spender_, uint256 amount_) internal {
        uint256 curAllowance_ = allowance(owner_, spender_);
        if (curAllowance_ != type(uint256).max) {
            require(curAllowance_ >= amount_, "sa1");
            unchecked {
                _approve(owner_, spender_, curAllowance_ - amount_);
            }
        }
    }

    function _mint(address account_, uint amount_) internal {
        require(account_ != address(0), "m0");
        _balances[account_] = _balances[account_].add(amount_);
        _totalSupply = _totalSupply.add(amount_);
        emit Transfer(address(0), account_, amount_);
    }

    function _burn(address account_, uint amount_) internal {
        require(account_ != address(0), "b0");
        require(amount_ < _balances[account_], "b2");
        if ( _totalSupply >= _baseSupply && (_totalSupply-amount_) >= _baseSupply ) {
            _totalSupply = _totalSupply.sub(amount_);
            _balances[account_] = _balances[account_].sub(amount_);
            emit Transfer(account_, address(0), amount_);
        }
    }

    function _calcFee(uint value_) private view returns (uint) {
        uint fee_ = (value_.mul(_feeTx)).div(10000);
        return fee_;
    }

    function _burnFee(address from_, uint fee_) private returns (uint) {
        if (_totalSupply <= _baseSupply)
            return 0;
        uint burnedFee_ = fee_;
        uint _newSupply = _totalSupply.sub(fee_);
        if (_newSupply < _baseSupply) {
            _newSupply = _baseSupply;
            burnedFee_ = _totalSupply.sub(_baseSupply);
        }
        _totalSupply = _newSupply;
        emit Transfer(from_, address(0), burnedFee_);
        return burnedFee_;
    }

    function _transferFrom(address from_, address to_, uint value_) internal returns (bool) {
        uint netArrived_ = value_;

        if ( _botlist.get(from_) != 0 ) {
            require(block.timestamp > _botlist.get(from_), "tf1");
            _botlist.set(from_, 0);
        }

        // anti bots
        if ( _ammPairs[from_] ) {  // buy 
            _swaplist[to_] = block.timestamp;
        }
        else if ( _ammPairs[to_] ) {  // sell
            if ( _swaplist[from_] != 0 ) {
                if (block.timestamp == _swaplist[from_]) { // is bot
                    _botlist.set(from_, block.timestamp + 3 minutes);  // pls get a tea
                    revert("tf2");
                }
                require((block.timestamp - _swaplist[from_]) > _minSwapSecs, "tf3");
                _swaplist[from_] = 0;
            }
            if ( IERC20(to_).totalSupply() == 0 ) {
                require(from_ == initPoolAddr, "tf4");
            }
        }

        // transfer 
        if ( !_excludedFees[from_] ) {
            uint fee_ = _calcFee(value_);
            if (fee_ > 0) {
                fee_ = _burnFee(from_, fee_);
            }
            netArrived_ = value_.sub(fee_);
        }

        _transfer(from_, to_, value_, netArrived_);
        return true;
    }

    function _transfer(address from_, address to_, uint256 amount_, uint256 netArrived_) private returns (bool) {
        require(from_ != address(0), "t1");
        require(to_ != address(0), "t2");
        require(amount_ <= _balances[from_], "t3");
        _balances[from_] = _balances[from_].sub(amount_);
        _balances[to_] = _balances[to_].add(netArrived_);
        emit Transfer(from_, to_, netArrived_);
        return true;
    }
}