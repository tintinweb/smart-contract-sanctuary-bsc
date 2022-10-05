// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import './utils/Address.sol';
import './utils/Context.sol';

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for EIP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        EIP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        EIP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {EIP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        EIP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        EIP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        EIP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(EIP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// JUST FOR TEST //

interface Iluckblocks {
    
    event LotteryLog(uint256 timestamp,address adrs, string message,uint number,string message2,uint choosennumber1);

    function getLatestPrice() external view returns (uint);
    
    function autoSpin(address _caller) external;
    
    function BT5124(address player,uint256 ticketValue,uint number1,uint number2) external;

    function amountOfRegisters() external view returns(uint);
    function currentJackpotInWei() external view returns(uint256);
    function autoSpinTimestamp() external view returns(uint256);
    function getJackpotWinnerByLotteryId(uint256 _requestCounter) external view returns (address);
    function ourLastWinner() external view returns(address);
    function ourLastJackpotWinner() external view returns(address);
    function lastJackpotTimestamp() external view returns(uint256);

    function ForfeitTicket(uint256 index) external;

}

interface Iluckblocks3 {
    event LotteryLog(uint256 timestamp,address adrs, string message,uint number,string message2,uint choosennumber1);

    function getLatestPrice() external view returns (uint);
    
    function autoSpin(address _caller) external;
    
    function BuyTicket(address player,uint256 ticketValue,uint number1,uint number2,uint number3) external;

    function amountOfRegisters() external view returns(uint);
    function currentJackpotInWei() external view returns(uint256);
    function autoSpinTimestamp() external view returns(uint256);
    function getJackpotWinnerByLotteryId(uint256 _requestCounter) external view returns (address);
    function ourLastWinner() external view returns(address);
    function ourLastJackpotWinner() external view returns(address);
    function lastJackpotTimestamp() external view returns(uint256);

    function ForfeitTicket(uint256 index) external;

}

interface Iluckblocks4 {
    event LotteryLog(uint256 timestamp,address adrs, string message,uint number,string message2,uint choosennumber1);

    function getLatestPrice() external view returns (uint);
    
    function autoSpin(address _caller) external;
    
    function BuyTicket(address player,uint256 ticketValue,uint number1,uint number2,uint number3,uint number4) external;

    function amountOfRegisters() external view returns(uint);
    function currentJackpotInWei() external view returns(uint256);
    function autoSpinTimestamp() external view returns(uint256);
    function getJackpotWinnerByLotteryId(uint256 _requestCounter) external view returns (address);
    function ourLastWinner() external view returns(address);
    function ourLastJackpotWinner() external view returns(address);
    function lastJackpotTimestamp() external view returns(uint256);

    function ForfeitTicket(uint256 index) external;

}

// JUST FOR TEST //

interface IUniswapV2Factory {
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

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

// Using consensys implementation of ERC-20, because of decimals

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

abstract contract EIP20 {
    /* This is a slight change to the EIP20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance The balance
    function balanceOf(address _owner) virtual public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) virtual public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success);


   // ERC20 burnable functions
   function mint(address _recipient, uint256 _amount) virtual public;

   function burnFrom(address from, uint256 _amount) virtual public;
    
    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender, uint256 _value) virtual public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) virtual public view returns (uint256 remaining);

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/*
Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
*/


contract Unisynths is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for EIP20;

    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    // Swap Router
    IUniswapV2Router02 public uniswapRouter;


    // token to deposit
    EIP20 public usd;
    EIP20 public krstm;
    EIP20 public btc;
    EIP20 public eth;
    EIP20 public matic;

    address usdTrading = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address krstmTrading = 0x8BaBbB98678facC7342735486C851ABD7A0d17Ca;
    address btcTrading = 0x8a9424745056Eb399FD19a0EC26A14316684e274;
    address ethTrading = 0x8a9424745056Eb399FD19a0EC26A14316684e274;
    address maticTrading = 0x8a9424745056Eb399FD19a0EC26A14316684e274;


    uint256 sdrUSD = 57813 * 10**13;
    uint256 sdrCNY = 109930 * 10**13;
    uint256 sdrYEN = 134520 * 10**13;
    uint256 sdrGBP = 8087 * 10**13;
    uint256 sdrEUR = 37379 * 10**13;


    // synthetics assets
     struct Token {
        bytes32 ticker;
        address tokenAddress;
        address priceFeed;
    }
    
    mapping(bytes32 => Token) public tokens;
    bytes32[] public tokenList;

    Iluckblocks public luckblocksB;
    Iluckblocks public luckblocksK;
    Iluckblocks3 public luckblocksE;
    Iluckblocks4 public luckblocksM;

    // contract parameters
 

    event MintToken(address indexed user, bytes32 token,uint256 amount);
    event BurnToken(address indexed user, bytes32 token,uint256 amount);

    constructor() {

        IUniswapV2Router02 _uniswapRouter = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // (0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);
        
        uniswapRouter = _uniswapRouter;

        Iluckblocks _luckblocksB = Iluckblocks(0x70C2857475c554cc181cB70AC88Efb77553748f7);

        luckblocksB = _luckblocksB;

        Iluckblocks _luckblocksK = Iluckblocks(0x07E9D1604055709504E9e2d654cF779E1989FeEb);

        luckblocksK = _luckblocksK;

        Iluckblocks3 _luckblocksE = Iluckblocks3(0x07E9D1604055709504E9e2d654cF779E1989FeEb);

        luckblocksE = _luckblocksE;

        Iluckblocks4 _luckblocksM = Iluckblocks4(0x07E9D1604055709504E9e2d654cF779E1989FeEb);

        luckblocksM = _luckblocksM;

        EIP20 _krstm = EIP20(0x8BaBbB98678facC7342735486C851ABD7A0d17Ca);

        krstm = _krstm;

        EIP20 _btc = EIP20(0x8a9424745056Eb399FD19a0EC26A14316684e274);

        btc = _btc;

        EIP20 _eth = EIP20(0x8a9424745056Eb399FD19a0EC26A14316684e274);

        eth = _eth;

        EIP20 _matic = EIP20(0x8a9424745056Eb399FD19a0EC26A14316684e274);

        matic = _matic;

        EIP20 _usd = EIP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

        usd = _usd;


    }

    function getTokens() 
      external 
      view 
      returns(Token[] memory) {
      Token[] memory _tokens = new Token[](tokenList.length);
      for (uint i = 0; i < tokenList.length; i++) {
        _tokens[i] = Token(
          tokens[tokenList[i]].ticker,
          tokens[tokenList[i]].tokenAddress,
          tokens[tokenList[i]].priceFeed
        );
      }
      return _tokens;
    }


    /**
     * Returns the latest price from chainlink oracle
     */
    function getLatestPrice(bytes32 _ticker) public view returns (uint256) {

        AggregatorV3Interface priceFeed = AggregatorV3Interface(tokens[_ticker].priceFeed);
                
        (
        uint80 roundID, 
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        require(timeStamp > 0, "Round not complete");
        return uint256(price) * 1e10;
    } 
    
    /**
     * Returns the latest price based on LP pair
     */
     function getLatestPriceLP(
        address _tokenIn,
        address _tokenOut,
        uint _amountIn
    ) public view returns (uint) {
        address[] memory path;
        path = new address[](3);
        path[0] = _tokenIn;
        path[1] = uniswapRouter.WETH();
        path[2] = _tokenOut;
        

        // same length of path
        uint[] memory amountOutMins = uniswapRouter.getAmountsOut(
            _amountIn,
            path
        );
             return amountOutMins[path.length - 1];
    }

    //special synths getter
    function getBoldPrice(bytes32 _kBTC, bytes32 _kGOLD) public view returns (uint256) {
      
        uint256 btcprice = getLatestPrice(_kBTC); // kBTC
        uint256 goldprice = getLatestPrice(_kGOLD);    // kGOLD

        uint256 sharebtc = btcprice.mul(60).div(100);
        uint256 sharegold = goldprice.mul(40).div(100);

        
        uint256 synthPrice = sharebtc.add(sharegold);

        return synthPrice;
    } 

    function getSdrPrice(bytes32 _kCNY, bytes32 _kYEN , bytes32 _kGBP , bytes32 _kEUR) public view returns (uint256) {

        uint256 cnyprice = getLatestPrice(_kCNY); // kCNY
        uint256 yenprice = getLatestPrice(_kYEN);   // kYEN
        uint256 gbpprice = getLatestPrice(_kGBP);   // kGBP
        uint256 eurprice = getLatestPrice(_kEUR);  // kEUR

        uint256 cnyamountprice = (sdrCNY.mul(cnyprice)) / 10**18;
        uint256 yenamountprice = (sdrYEN.mul(yenprice)) / 10**18;  
        uint256 gbpamountprice = (sdrGBP.mul(gbpprice)) / 10**18; 
        uint256 euramountprice = (sdrEUR.mul(eurprice)) / 10**18;


        uint256 synthPrice = cnyamountprice + yenamountprice + gbpamountprice + euramountprice + sdrUSD;

        return synthPrice;
    } 

    // Mint trough luckblocks functions
    function betBTC() public {
        uint256 amountNecessary = 5 * 10**18;
        usd.safeTransferFrom(address(msg.sender), address(this), amountNecessary);
        usd.approve(address(luckblocksB), amountNecessary);
        luckblocksB.BT5124(address(this),amountNecessary,3,6);
    }
    function betKRSTM() public {
        uint256 amountNecessary = 20 * 10**18;
        usd.safeTransferFrom(address(msg.sender), address(this), amountNecessary);
        usd.approve(address(luckblocksK), amountNecessary);
        luckblocksK.BT5124(address(this),amountNecessary,3,6);
    }
    function betETH() public {
        uint256 amountNecessary = 200 * 10**18;
        usd.safeTransferFrom(address(msg.sender), address(this), amountNecessary);
        usd.approve(address(luckblocksE), amountNecessary);
        luckblocksE.BuyTicket(address(this),amountNecessary,3,10,15);
    }
    function betMATIC() public {
        uint256 amountNecessary = 2000 * 10**18;
        usd.safeTransferFrom(address(msg.sender), address(this), amountNecessary);
        usd.approve(address(luckblocksM), amountNecessary);
        luckblocksM.BuyTicket(address(this),amountNecessary,3,5,17,21);
    }

    function betMATICOver() public {
        uint256 amountNecessary = 2000 * 10**18;
        usd.approve(address(luckblocksM), amountNecessary);
        luckblocksM.BuyTicket(address(this),amountNecessary,3,5,17,21);
    }
  
    function swapTokens(address token,address token2,uint256 tokenAmount) private {
        // generate the swap pair path of tokens
        address[] memory path = new address[](3);
        path[0] = token;
        path[1] = uniswapRouter.WETH();
        path[2] = token2;

        EIP20(token).approve(address(uniswapRouter), tokenAmount);

        // make the swap
        uniswapRouter.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of Tokens out
            path,
            address(this), // The contract
            block.timestamp + 300
        );
    }

    function swapTokensToUSD(uint256 tokenAmount) private {
        // generate the swap pair path of tokens
        address[] memory path = new address[](3);
        path[0] = krstmTrading;
        path[1] = uniswapRouter.WETH();
        path[2] = usdTrading;

        krstm.approve(address(uniswapRouter), tokenAmount);

        // make the swap
        uniswapRouter.swapTokensForExactTokens(
            tokenAmount,
            1000000000000000000000, // to garantee the trade - 1000 tokens
            path,
            address(this), // The contract
            block.timestamp + 300
        );
    }

    /// Mint Synthetic asset supplying stablecoin.

    function mintSynth(bytes32 _ticker,uint256 _amount) tokenExist(_ticker) nonReentrant public {
        
        require(_amount == 5 * 10**18 || _amount == 20 * 10**18 || _amount == 200 * 10**18 || _amount == 2000 * 10**18 , "amount of usd required are exactly 5, 20, 200 or 2000.");
        require(usd.balanceOf(msg.sender) >= _amount, "Not Enough Balance to mint synth");

        bytes32 kBOLD = bytes32("0x6b424f4c44");
        bytes32 kSDR = bytes32("0x6b534452");
        
        uint256 synthPrice;

        if(_amount == 5 * 10**18){
            betBTC();
        } else if(_amount == 20 * 10**18){
            betKRSTM();
        } else if(_amount == 200 * 10**18){
            betETH();
        } else {
            betMATIC();
        }

        if(usd.balanceOf(address(this)) > getTotalMinted().mul(5) && usd.balanceOf(address(this)) > 10000 * 10**18){

           // in case contract is over collaterized safely (5x+) it does additional play to get more reserve, fill the luckblock jackpots and distribute more revenue trough ecosystem        
           betMATICOver();

        }

        if(_ticker == kBOLD){
            
            bytes32 kBTC = bytes32("0x6b425443");
            bytes32 kGOLD = bytes32("0x6b474f4c44");

            synthPrice = getBoldPrice(kBTC,kGOLD);

        } else if (_ticker == kSDR){
            
            bytes32 kCNY = bytes32("0x6b434e59");
            bytes32 kYEN = bytes32("0x6b59454e");
            bytes32 kGBP = bytes32("0x6b474250");
            bytes32 kEUR = bytes32("0x6b455552");

            synthPrice = getSdrPrice(kCNY,kYEN,kGBP,kEUR);

        }  else {

            synthPrice = getLatestPrice(_ticker);
       
        }

        if(krstm.balanceOf(msg.sender) < 5 * 10**18){
            // charge 1% fee
            _amount = _amount.mul(99).div(100);  
        }

        uint256 amountMint = (_amount * 10**18).div(synthPrice);

        EIP20(tokens[_ticker].tokenAddress).mint(msg.sender, amountMint);

        emit MintToken(msg.sender,_ticker,amountMint);
    }
    
    function burnSynth(bytes32 _ticker,uint256 _amount) tokenExist(_ticker) nonReentrant public {
        
        require(EIP20(tokens[_ticker].tokenAddress).balanceOf(msg.sender) >= _amount , "You don't have enough tokens to burn/sell.");      
        require(getTotalSupply() >= getTotalMinted().mul(80).div(100), "Supplied reserve tokens value is less than 80% overcollaterized.");
     

        bytes32 kBOLD = bytes32("0x6b424f4c44");
        bytes32 kSDR = bytes32("0x6b534452");

        uint256 synthPrice;

        if(_ticker == kBOLD){
            
            bytes32 kBTC = bytes32("0x6b425443");
            bytes32 kGOLD = bytes32("0x6b474f4c44");

            synthPrice = getBoldPrice(kBTC,kGOLD);

        } else if (_ticker == kSDR){
            
            bytes32 kCNY = bytes32("0x6b434e59");
            bytes32 kYEN = bytes32("0x6b59454e");
            bytes32 kGBP = bytes32("0x6b474250");
            bytes32 kEUR = bytes32("0x6b455552");

            synthPrice = getSdrPrice(kCNY,kYEN,kGBP,kEUR);

        } else {

            synthPrice = getLatestPrice(_ticker);
        
        }

        uint256 amountToSend = (_amount.mul(synthPrice)) / 10**18;

        if(krstm.balanceOf(msg.sender) < 5 * 10**18){
            // charge 1% fee
            amountToSend = amountToSend.mul(99).div(100);  
        }

        require(amountToSend <= getTotalSupply().mul(50).div(100) , "amount to send is more than 50% of total reserve.");


        uint256 krstmprice = getLatestPriceLP(krstmTrading,usdTrading,1 * 10**18);
        krstmprice = krstmprice.mul(95).div(100); // accounting for slippage.

        // in case of contract accumulating jackpot wins it swap to KRSTM
        if(matic.balanceOf(address(this)) > 0){

            swapTokens(maticTrading,krstmTrading,matic.balanceOf(address(this)));

        } else if (btc.balanceOf(address(this)) > 0){
                 
            swapTokens(btcTrading,krstmTrading,btc.balanceOf(address(this)));
        
        } else if (eth.balanceOf(address(this)) > 0){
            swapTokens(ethTrading,krstmTrading,eth.balanceOf(address(this)));
        }

      
        // logic to send usd to user
        if (usd.balanceOf(address(this)) <= amountToSend.mul(60).div(100)){


          if (usd.balanceOf(address(this)) < amountToSend.mul(30).div(100)){


            if(krstm.balanceOf(address(this)) >= (amountToSend * 10**18).div(krstmprice)){
                
                swapTokensToUSD(amountToSend);
            
            }

          } else{
            
            uint256 amountdivided = amountToSend.mul(70).div(100);
            uint256 krstmtosell = (amountdivided * 10**18).div(krstmprice);
            if(krstmtosell > 0){
                if(krstm.balanceOf(address(this)) >= krstmtosell){

                    swapTokensToUSD(amountdivided);
                
                }
            }
          }

        } else if(usd.balanceOf(address(this)) > getTotalMinted().mul(5) && usd.balanceOf(address(this)) > 10000 * 10**18){

           // in case contract is over collaterized safely (5x+) it does additional play to get more reserve, fill the luckblock jackpots and distribute more revenue trough ecosystem        
           betMATICOver();

        } else{

            uint256 amountdivided = amountToSend.mul(40).div(100);
            uint256 krstmtosell = (amountdivided * 10**18).div(krstmprice);
            if(krstmtosell > 0){
                if(krstm.balanceOf(address(this)) >= krstmtosell){

                    swapTokensToUSD(amountdivided);
                
                }
            }

        }

        
        require (usd.balanceOf(address(this)) >= amountToSend,"Reserve usd is less than value to send.");
        
        usd.transfer(msg.sender,amountToSend);
    
        // burn synth
        EIP20(tokens[_ticker].tokenAddress).burnFrom(msg.sender, _amount);
        
        emit BurnToken(msg.sender,_ticker,_amount);
        
    }
    
    /* Admin Functions */
    
    function addToken(
        bytes32 ticker,
        address tokenAddress,
        address priceFeed)
        onlyOwner()
        external {
        tokens[ticker] = Token(ticker, tokenAddress, priceFeed);
        tokenList.push(ticker);
    }

    function editToken(
        bytes32 ticker,
        address tokenAddress,
        address priceFeed)
        onlyOwner()
        tokenExist(ticker)
        external {
        tokens[ticker].tokenAddress = tokenAddress; 
        tokens[ticker].priceFeed = priceFeed;
        tokens[ticker] = Token(ticker, tokenAddress, priceFeed);
    }

    function setStableToken(address _usdAddress) public onlyOwner() {
        usd = EIP20(_usdAddress);
        usdTrading = _usdAddress;
    }

    function setSdrBasket(uint256 _usd,uint256 _cny,uint256 _yen,uint256 _eur,uint256 _gbp) public onlyOwner() {
     
     sdrUSD = _usd * 10**13;
     sdrCNY = _cny * 10**13;
     sdrYEN = _yen * 10**13;
     sdrGBP = _gbp * 10**13;
     sdrEUR = _eur * 10**13;

    }

    /// @dev Obtain the reserve balance value of this contract
    /// @return wei balance of contract
    function getTotalSupply() public view returns (uint256) {
        // Return reserve balance in usd
        uint256 usdReserve = usd.balanceOf(address(this));
        uint256 krstmReserve = krstm.balanceOf(address(this));

        uint256 krstmprice = getLatestPriceLP(krstmTrading,usdTrading,1 * 10**18);
        krstmprice = krstmprice.mul(95).div(100); // accounting for slippage.
        
        uint256 krstmUsdReserve = (krstmReserve.mul(krstmprice)) / 10**18;

        uint256 totalReserveUsd = usdReserve.add(krstmUsdReserve);

        return totalReserveUsd;
    }

    /// @dev Obtain the minted tokens total mkcap value
    /// @return wei balance of contract
    function getTotalMinted() public view returns (uint256) {
         uint256 totalmkcap;
        // Return reserve balance in usd
          Token[] memory _tokens = new Token[](tokenList.length);
            for (uint i = 0; i < tokenList.length; i++) {

                uint256 totalsupply = EIP20(tokens[tokenList[i]].tokenAddress).totalSupply();
                uint256 tokenprice = getLatestPrice(tokens[tokenList[i]].ticker);
                
                uint256 mkcap = (totalsupply.mul(tokenprice)) / 10**18;

                totalmkcap += mkcap;
            }

        return totalmkcap;
    }

    function previewMintAmount(bytes32 _ticker, uint256 _amountUSD) public view returns (uint256) {
        
        bytes32 kBOLD = bytes32("0x6b424f4c44");
        bytes32 kSDR = bytes32("0x6b534452");

        uint256 synthPrice;

        if(_ticker == kBOLD){
            
            bytes32 kBTC = bytes32("0x6b425443");
            bytes32 kGOLD = bytes32("0x6b474f4c44");

            synthPrice = getBoldPrice(kBTC,kGOLD);

        } else if (_ticker == kSDR){
            
            bytes32 kCNY = bytes32("0x6b434e59");
            bytes32 kYEN = bytes32("0x6b59454e");
            bytes32 kGBP = bytes32("0x6b474250");
            bytes32 kEUR = bytes32("0x6b455552");

            synthPrice = getSdrPrice(kCNY,kYEN,kGBP,kEUR);

        } else {

            synthPrice = getLatestPrice(_ticker);
        
        }
        
        return (_amountUSD * 10**18) / synthPrice;

    }

    function previewReturnOnBurn(bytes32 _ticker, uint256 _amountTKN) public view returns (uint256) {
        
        bytes32 kBOLD = bytes32("0x6b424f4c44");
        bytes32 kSDR = bytes32("0x6b534452");

        uint256 synthPrice;

        if(_ticker == kBOLD){
            
            bytes32 kBTC = bytes32("0x6b425443");
            bytes32 kGOLD = bytes32("0x6b474f4c44");

            synthPrice = getBoldPrice(kBTC,kGOLD);

        } else if (_ticker == kSDR){
            
            bytes32 kCNY = bytes32("0x6b434e59");
            bytes32 kYEN = bytes32("0x6b59454e");
            bytes32 kGBP = bytes32("0x6b474250");
            bytes32 kEUR = bytes32("0x6b455552");

            synthPrice = getSdrPrice(kCNY,kYEN,kGBP,kEUR);

        } else {

            synthPrice = getLatestPrice(_ticker);
        
        }

       return (_amountTKN * synthPrice) / 10**18;

    }

    modifier tokenExist(bytes32 ticker) {
        require(
            tokens[ticker].tokenAddress != address(0),
            'this token does not exist'
        );
        _;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
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