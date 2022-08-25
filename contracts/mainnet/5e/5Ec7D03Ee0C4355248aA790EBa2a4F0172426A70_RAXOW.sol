/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

/*
           Welcome to Raxow Technology smart contract!
           As the Raxow team, with our project that will change all the balances in the crypto money world,
           we are designing a crypto architecture that can be used more easily in every area of
           your daily life and is valid everywhere.

​
           With the Raxow Mobile APP, we will turn the idea of using and
           spending your digital assets in a single wallet, equipped with a high-level security circle,
           into a real action in seconds

           WWW.RAXOW.COM
*/           


// SPDX-License-Identifier: MIT

// File: @openzeppelin\contracts\utils\Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin\contracts\access\Ownable.sol

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin\contracts\utils\math\SafeMath.sol

// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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

// File: @openzeppelin\contracts\security\ReentrancyGuard.sol

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: contracts\RAXOW.sol


pragma solidity ^0.8.0;
pragma abicoder v2;
interface IBEP2E {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint256);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
interface IPancakeswapV2Factory {
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

interface IPancakeSwapV2Pair {
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

interface IPancakeRouter01 {
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
}

// File: contracts\interfaces\IPancakeRouter02.sol

interface IPancakeRouter02 is IPancakeRouter01 {
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

//TODO - Inherit from ReentrancyGuard
contract RAXOW is Ownable, IBEP2E,ReentrancyGuard {
  using SafeMath for uint256;

  string public _name; //token name
  string public _symbol; //token symbol 
  uint private _totalSupply; //total supply
  uint256 private _rTotal;
  uint8 public _decimals; //the total number of decimal represenations
  bool private _paused;

  mapping(address => uint) private balances; //how token much does this address have
  mapping(address => mapping(address => uint)) private allowances; //the amount approved by the owner to be spent on their behalf
  mapping (address => uint256) private _rOwned;

  event Unpaused(address account); // Emitted when the pause is triggered by `account`.
  event Paused(address account); //Emitted when the pause is lifted by `account`.
  event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
  event SwapAndLiquifyEnabledUpdated(bool enabled);
  event SwapAndLiquify(
      uint256 tokensSwapped,
      uint256 ethReceived,
      uint256 tokensIntoLiqudity
  );

  modifier lockTheSwap {
      inSwapAndLiquify = true;
      _;
      inSwapAndLiquify = false;
  }

  //Wallet Addresses
  address payable private partnershipFundAddress;
  address payable private airdropFundAddress;
  address payable private marketingFundAddress;
  address payable private staffFundAddress;
  address payable private burnFundAddress;
  address payable private holdersFundAddress;

  //router address
  IPancakeRouter02 public pancakeswapV2Router;
  address public pancakeswapV2Pair;
  address public pancakeFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
  address public pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address public WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); //WBNB
  uint256 internal minLiquidityAmount; //the minimum amount of RAXOW token to add liquidity with
  uint256 private liquidityFee; //the liquidoty fee to be deducted from each trade
  uint256 private previousLiquidityFee = liquidityFee;
  uint256 private txFee;
  uint256 private previousTaxFee = txFee;
  uint256 private constant MAX = ~uint256(0);

  bool inSwapAndLiquify;
  bool public swapAndLiquifyEnabled = true;

  mapping (address => bool) private _isExcludedFromFee;
  mapping (address => bool) private _isExcluded;
  address[] private _excluded;

  uint256 private _buyFee;
  uint256 private _sellFee;

  bool private isPairCreated = false;
  address public routerAddress;

  constructor(address _routerAddress ,address _marketingFundAddress,uint256 _txFee,uint256 _liquidityPoolFee,uint256 _lpBuyFee,uint256 _lpSellFee) { //payable
      _name = "RAXOW TECHNOLOGY"; 
      _symbol = "RAXOW";
      _decimals = 18;
      _totalSupply = 1000000000 * 10 ** 18;
      _paused = false;
      marketingFundAddress = payable(_marketingFundAddress);
      routerAddress = _routerAddress;
      txFee = _txFee;
      liquidityFee = _liquidityPoolFee;
      _buyFee = _lpBuyFee;
      _sellFee = _lpSellFee;
      minLiquidityAmount = (_totalSupply * 2 / 10000) * 10 ** _decimals;
      //exclude owner and this contract from fee
      _isExcludedFromFee[msg.sender] = true;
      _isExcludedFromFee[address(this)] = true;
      balances[msg.sender] = balances[msg.sender].add(_totalSupply);
      emit Transfer(address(0), msg.sender, _totalSupply);
  }

  /**
  * @dev Modifier to make a function callable only when the contract is not paused.
  *
  * Requirements:
  *
  * - The contract must not be paused.
  */
  modifier whenNotPaused() {
    require(!paused(), "Pausable: paused");
     _;
  }

  /**
  * @dev Modifier to make a function callable only when the contract is paused.
  *
  * Requirements:
  *
  * - The contract must be paused.
  */
  modifier whenPaused() {
    require(paused(), "Pausable: not paused");
    _;
  }

  modifier liquidityPairCreated(){
    require(isPairCreated == true,"BEP2E: Liquidity Pair Does Not Exist");
    _;
  }

  modifier liquidityPairNotCreated(){
    require(isPairCreated == false,"BEP2E: Liquity Pair Exists");
    _;
  }

    modifier swapIsenabled(){
        require(swapAndLiquifyEnabled == true,"Swap Is Not Enabled");
        _;
    }

    modifier swapIsNotEnabled(){
        require(swapAndLiquifyEnabled == false,"Swap Is Enabled");
        _;
    }
  /**
  * @dev Returns true if the contract is paused, and false otherwise.
  */
  function paused() public view returns (bool) {
    return _paused;
  }
   
  /**
  * @notice token name
  * @return string token name
  */
  function name() public view override returns(string memory){
    return _name;
  }

  /** 
  * @notice token symbol
  * @return string symbol. The Token Symbol
  */
  function symbol() public view override returns(string memory){
    return _symbol;
  }

  /**
  * @notice the total number of decimals for the RAXOW token
  * @return uint number of decimals
  */
  function decimals() public view override returns(uint){
    return _decimals;
  }

  /**
  * @notice the total token supply in circulation
  * @return uint total supply
  */
  function totalSupply() public view override returns(uint){
    return _totalSupply;
  }

  /**
  * @notice should return the address of the contract owner
  * @return address the owner address specified in the Ownable contract
  */
  function getOwner() public view override returns (address){
    return owner();
  }
  
  /**
  * @notice how much token balance does this address have
  * @dev the account should not be the zero address , address(0)
  * @param _account account the address to which we want to determine their token balance
  * @return uint the total balance of the specied address
  */
  function balanceOf(address _account) public view override returns (uint256){
      return balances[_account];
  }

  /**
  * @notice transfer a specicied amount pf tokens to a recipient address
  * @dev the recipient address should not be an empty address address(0)
  * @dev the sender's total balance must be equal to or greater than the amount specified
  * @dev the nonReentrant modifier protects this function from reentrancy attacks
  * @param _recipient address the person receiving the tokens
  * @param _amount uint the amount of tokens to be sent to the specied address as the recepient
  * @return bool success if the transfer was successfull otherwise false
  */
  function transfer(address _recipient, uint _amount) public override whenNotPaused returns (bool){ //nonReentrant
      _transfer(msg.sender, _recipient, _amount);
      return true;
  }

  /**
  * @notice transfer the specidied amount of tokens from the sender address to the recipient address
  * @dev both the sender and recipient address should not be the empty address, address(0)
  * @dev the amount of tokens being moved from the sender to the recipient address should 
  * @dev not be less than the sender's total balances
  * @dev the nonReentrant modifier protects this function from reentrancy attacks
  * @param _sender address
  * @param _recipient address
  * @param _amount uint
  * @return bool if the transfer event was successfull
  */
  function transferFrom(address _sender, address _recipient, uint _amount) public override whenNotPaused returns (bool) {
    _transfer(_sender, _recipient, _amount);
    _approve(_sender, _msgSender(), allowances[_sender][msg.sender].sub(_amount, "BEP2E: transfer amount exceeds allowance"));
    return true;
  }

  /**
  * @notice returns the amount that owner appoved as allowance for the spender
  * @dev both the owner and spender addresses should not be empty addresse address(0)
  * @param _owner address the owner address
  * @param _spender address the spender address
  * @return uint, the amount approved for spending
  */
  function allowance(address _owner, address _spender) public override view returns (uint256) {
    return allowances[_owner][_spender];
  }

  /**
  * @notice enables the token holder to add a new address than can spend the tokens on their behalf
  * @dev the spender address should not be an empty address(0)
  * @dev the amount to be approved should not be less than the sender's balance
  * @param _spender address, the approved address
  * @param _amount uint , the amount to approved by the token holder
  * @return bool true if success otherwise false
  */
  function approve(address _spender, uint _amount) public override whenNotPaused returns (bool) {
    _approve(msg.sender, _spender, _amount);
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   * @param _spender address 
   * @param _addedValue uint 
   * @return bool true if success otherwise false
   */
  function increaseAllowance(address _spender, uint _addedValue) public whenNotPaused returns (bool) {
    _approve(msg.sender, _spender, allowances[msg.sender][_spender].add(_addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to spender by the caller
   * @param _spender address 
   * @param _subtractedValue uint
   * @return bool true if success otherwise false
   */
  function decreaseAllowance(address _spender, uint _subtractedValue) public whenNotPaused returns (bool) {
    uint currentAllowance = allowances[msg.sender][_spender];
    require(currentAllowance >= _subtractedValue,"BEP2E: Insufficient Allowance");
    _approve(msg.sender, _spender, allowances[msg.sender][_spender].sub(_subtractedValue));
    return true;
  }

  /**
   * @dev Destroys amount tokens from account, reducing the
   * total supply.
   * @dev account cannot be the zero address.
   * @dev account must have at least amount tokens.
   * @param _account address
   * @param _amount uint
   * @return bool true if success otherwise false
   */
  function burn(address _account, uint _amount) public onlyOwner whenNotPaused returns(bool){
    _burn(_account, _amount);
    return true;
  }

  /**
  * @dev Triggers stopped state.
  *
  * Requirements:
  *
  * - The contract must not be paused.
  */
  function pause() public onlyOwner whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
  * @dev Returns to normal state.
  *
  * Requirements:
  *
  * - The contract must be paused.
  */
  function unpause() public onlyOwner whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }

  /**
  * @notice creates a liquidity pool pair for the RAXOW/WBNB(BNB) tokens if not created yet
  * @dev should be called before
  */
  function createLiquidityPoolPair() public liquidityPairNotCreated onlyOwner returns(bool success){
    IPancakeRouter02 _pancakeSwapV2Router = IPancakeRouter02(routerAddress);
    pancakeswapV2Pair = IPancakeswapV2Factory(_pancakeSwapV2Router.factory()).createPair(address(this), _pancakeSwapV2Router.WETH()); 
    pancakeswapV2Router = _pancakeSwapV2Router;
    isPairCreated == true;
    return true;
  }

  /**
  * @notice sets a new pancakeswapv2 router address
  * @dev can only be triggered by the contract owner
  * @param _newRouter address
  */
  function setRouterAddress(address _newRouter) external liquidityPairCreated onlyOwner {
    require(_newRouter != address(0),"Invalid Router Address");
    IPancakeRouter02 _pancakeSwapV2Router = IPancakeRouter02(_newRouter);
    pancakeswapV2Pair = IPancakeswapV2Factory(_pancakeSwapV2Router.factory()).createPair(address(this), _pancakeSwapV2Router.WETH()); 
    pancakeswapV2Router = _pancakeSwapV2Router;
    routerAddress = _newRouter;
  }

  /**
  * @notice enables the contract owner to set the pancakeswap liquidityFee
  * @param _liquidityFee uint256
  */
  function setLiquidityFee(uint256 _liquidityFee) external onlyOwner() {
      require(_liquidityFee != 0,"BEP2E: Fee cannot be zero");
      liquidityFee = _liquidityFee;
  }

  function setLiquidityPoolBuyFee(uint256 _fee) external onlyOwner{
    require(_fee != 0,"BEP2E: Fee cannot be zero");
    _buyFee = _fee;
  }

  function setLiquidityPoolSellFee(uint256 _fee) external onlyOwner{
    require(_fee != 0,"BEP2E: Fee cannot be zero");
    _sellFee = _fee;
  }

  function setSwapAndLiquifyEnabled() public onlyOwner swapIsNotEnabled  {
      swapAndLiquifyEnabled = true;
      emit SwapAndLiquifyEnabledUpdated(true);
  }

  /**
  * @notice calculates the liquidityfee based on yhe provided amount
  * @param _amount the amount to calculate the liquidity fee against
  */
  function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
      return _amount.mul(liquidityFee).div(
            10**2
        );
  }

  function calculateTaxFee(uint256 _amount) private view returns (uint256) {
      return _amount.mul(txFee).div(
          10**2
      );
  }
  
  function removeAllFee() private {
      if(txFee == 0 && liquidityFee == 0) return;

      previousTaxFee = txFee;
      previousLiquidityFee = liquidityFee;

      txFee = 0;
      liquidityFee = 0;
  }

  function restoreAllFee() private {
      txFee = previousTaxFee;
      liquidityFee = previousLiquidityFee;
  }

  //to recieve BNB from pancakeswapV2Router when swaping
  receive() external payable {}

  function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
      uint256 half = contractTokenBalance.div(2);
      uint256 otherHalf = contractTokenBalance.sub(half);
      uint256 initialBalance = address(this).balance;
      swapTokensForBnb(half); 
      uint256 newBalance = address(this).balance.sub(initialBalance);
      addLiquidity(otherHalf, newBalance);
      emit SwapAndLiquify(half, newBalance, otherHalf);
  }

  /**
  * @dev swaps RAXOW/WBNB tokens
  * @param _tokenAmount uint256
  */
  function swapTokensForBnb(uint256 _tokenAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = pancakeswapV2Router.WETH();
    _approve(address(this), address(pancakeswapV2Router), _tokenAmount);
    pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      _tokenAmount,
      0, // accept any amount of BNB
      path,
      address(this),
      block.timestamp
    );
  }

  /**
  * @dev Adds Liquidity for the RAXOW/WBNB tokens
  * @param _RAXOWTokenAmount uint256 the RAXOW token amount
  * @param _bnbTokenAmount uint256 the WBNB token amount
  */
  function addLiquidity(uint256 _RAXOWTokenAmount, uint256 _bnbTokenAmount) private{
    _approve(address(this), address(pancakeswapV2Router), _RAXOWTokenAmount);
    pancakeswapV2Router.addLiquidityETH{value: _bnbTokenAmount}(
        address(this),
        _RAXOWTokenAmount,
        0, // slippage is unavoidable
        0, // slippage is unavoidable
        owner(),
        block.timestamp
    );
  }

  /**
  * @notice removes RAXOW/WBNB liquidity
  * @param _liquidityAmountToRemove uint256 the amount to tokens to remove from the RAXOW/BNB Liquidity pool
  * @notice TO-DO check that the liquidity amount to remove is not greator than the amount addedd previously as liquidity
  */
  function removeLiquidity(uint256 _liquidityAmountToRemove) public onlyOwner{
    pancakeswapV2Router.removeLiquidityETH(
      address(this),
      _liquidityAmountToRemove,
      0,
      0, 
      owner(),
      block.timestamp
      );
  }

  function excludeFromReward(address _account) public onlyOwner() {
        require(!_isExcluded[_account], "Account is already excluded");
        _isExcluded[_account] = true;
        _excluded.push(_account);
  }

  function includeInReward(address _account) external onlyOwner() {
      require(_isExcluded[_account], "Account is already included");
      for (uint256 i = 0; i < _excluded.length; i++) {
          if (_excluded[i] == _account) {
              _excluded[i] = _excluded[_excluded.length - 1];
              balances[_account] = 0;
              _isExcluded[_account] = false;
              _excluded.pop();
              break;
        }
      }
  }

  function withdraw(uint256 _amount) public onlyOwner nonReentrant returns(bool success){
    uint256 accountBalance= address(this).balance;
    require(accountBalance >= _amount,"RAXOW: Insufficient Withdrawal Balance");
    payable(msg.sender).transfer(_amount);
    return true;
  }

  /**
  * -- INTERNAL FUNCTIONS -- 
  */
  function _getChainID() private view returns (uint256) {
    uint256 id;
    assembly {
        id := chainid()
    }
    return id;
}
  /**
  * @dev Moves tokens amount from sender to recipient.
  * @dev _sender cannot be the zero address.
  * @dev recipient cannot be the zero address.
  * @dev sender must have a balance of at least amount
  * @param _sender address thes account sending the tokens amount
  * @param _recipient address the account receiving the tokens
  * @param _amount uint the token amount to be sent
  */
  function _transfer(address _sender, address _recipient, uint _amount) internal virtual {
    require(_sender != address(0), "BEP2E: transfer from the zero address");
    require(_recipient != address(0), "BEP2E: transfer to the zero address");

    _beforeTokenTransfer(_sender, _recipient, _amount);

    uint senderBalance = balances[_sender];

    require(senderBalance >= _amount, "BEP2E: transfer amount exceeds balance");

    uint256 chainId = _getChainID(); //block.chainid
    
    if(chainId == 97) //bsc testnet
    {
      balances[_sender] = balances[_sender].sub(_amount);
      balances[_recipient] = balances[_recipient].add(_amount);
      emit Transfer(_sender, _recipient, _amount);
    }
    else if(chainId == 56){ //bsc mainnet
      uint256 contractTokenBalance = balanceOf(address(this));
      //is the token balance of this contract address over the min number of
      // tokens that we need to initiate a swap + liquidity lock?
      //also, don't get caught in a circular liquidity event.
      //also, don't swap & liquify if sender is uniswap pair.
      bool overMinTokenBalance = contractTokenBalance >= minLiquidityAmount;
      if (
          isPairCreated == true &&
          overMinTokenBalance &&
          !inSwapAndLiquify &&
          _sender != pancakeswapV2Pair &&
          swapAndLiquifyEnabled
      ) {
            contractTokenBalance = minLiquidityAmount;
            swapAndLiquify(contractTokenBalance);
        }
          
        bool takeFee = true;
        if(_isExcludedFromFee[_sender] || _isExcludedFromFee[_recipient]){
            takeFee = false;
        }
      //transfer amount, it will take tax, burn, liquidity fee
        _transferTokens(_sender,_recipient,_amount,takeFee); 
      }   
  }

  function _takeLiquidity(uint256 _tLiquidity) private {
      if(_isExcluded[address(this)]){
        balances[address(this)] = balances[address(this)].add(_tLiquidity);
      }
  }

  function _takeFee(uint256 tDev) private {
        if(_isExcluded[marketingFundAddress]){
          balances[marketingFundAddress] = balances[marketingFundAddress].add(tDev);
        }
  }

  //handles final token transfer taking into consideration the liquidity fees
  function _transferTokens(address _sender, address _recipient, uint256 _amount, bool takeFee) private returns(bool success){
    balances[_sender] = balances[_sender].sub(_amount);
    uint256 amountReceived = (takeFee) ? takeTaxes(_sender, _recipient, _amount) : _amount;
    balances[_recipient] = balances[_recipient].add(amountReceived);

    (,uint256 txFeeAmount,uint256 liquidityFeeAmount ) = _getFeeAmountValues(_amount);
    _takeLiquidity(liquidityFeeAmount);
    _takeFee(txFeeAmount);
    emit Transfer(_sender, _recipient, amountReceived);
    return true;
  }
  
  function takeTaxes(address from, address to, uint256 amount) internal returns (uint256) {
      uint256 currentFee;
      if (from == pancakeswapV2Pair) {
          currentFee = _buyFee;
      } else if (to == pancakeswapV2Pair) {
          currentFee = _sellFee;
       } else {
           currentFee = txFee;
       }


       uint256 feeAmount = amount * currentFee / 10000;


       balances[address(this)] = balances[address(this)].add(feeAmount);
       emit Transfer(from, address(this), feeAmount);


       return amount - feeAmount;
  }

  function _getFeeAmountValues(uint256 _tAmount) private view returns (uint256, uint256, uint256) {
      uint256 tFee = calculateTaxFee(_tAmount);
      uint256 tLiquidity = calculateLiquidityFee(_tAmount);
      uint256 tTransferAmount = _tAmount.sub(tFee).sub(tLiquidity);
      return (tTransferAmount, tFee, tLiquidity);
  }

  /**
   * @dev Destroys amount tokens from account, reducing the
   * total supply.
   * @dev account cannot be the zero address.
   * @dev account must have at least amount tokens.
   * @param _account address
   * @param _amount uint 
   */
  function _burn(address _account, uint _amount) internal virtual {
    require(_account != address(0), "BEP2E: burn from the zero address");

    _beforeTokenTransfer(_account, address(0), _amount);

    uint accountBalance = balances[_account];
    require(accountBalance >= _amount,"BEP2E: burn amount exceeds balance");

    balances[_account] = balances[_account].sub(_amount);
    _totalSupply = _totalSupply.sub(_amount);
    emit Transfer(_account, address(0), _amount);
    _afterTokenTransfer(_account, address(0), _amount);
  }

  /**
   * @dev Sets amount as the allowance of spender over the owner`s tokens.
   * @dev owner cannot be the zero address.
   * @dev spender cannot be the zero address.
   * @param _owner address
   * @param _spender address
   * @param _amount uint  
   */
  function _approve(address _owner, address _spender, uint _amount) internal virtual {
    require(_owner != address(0), "BEP2E: approve from the zero address");
    require(_spender != address(0), "BEP2E: approve to the zero address");

    allowances[_owner][_spender] = _amount;
    emit Approval(_owner, _spender, _amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   * @param _account address
   * @param _amount uint 
   */
  function _burnFrom(address _account, uint _amount) internal virtual {
    _burn(_account, _amount);
    _approve(_account, msg.sender, allowances[_account][msg.sender].sub(_amount));
  }

  /**
  * @dev Hook that is called before any transfer of tokens. This includes
  * minting and burning.
  *
  * Calling conditions:
  *
  * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
  * will be transferred to `to`.
  * - when `from` is zero, `amount` tokens will be minted for `to`.
  * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
  * - `from` and `to` are never both zero.
  *
  * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
  */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}


  /**
  * @dev Hook that is called after any transfer of tokens. This includes
  * minting and burning.
  *
  * Calling conditions:
  *
  * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
  * has been transferred to `to`.
  * - when `from` is zero, `amount` tokens have been minted for `to`.
  * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
  * - `from` and `to` are never both zero.
  *
  * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
  */
  function _afterTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}  
}