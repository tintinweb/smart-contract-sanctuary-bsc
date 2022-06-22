// SPDX-License-Identifier: MIT

/**

MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWWWWWWWWWWWWWMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMWWNXXKKKKKKKXXXXKKKKKKXXNWWMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMWNXKKKKXXNWWWWMMWWWWMWWWWNXXXKKKXNWMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMWNXKKKXNWMMMMMMMMMNOdxKWMMMMMMMMWNXKKKXNWMMMMMMMMMMMMMM
MMMMMMMMMMMMMWXKKKNWMMMMMMMMMMMMNx:;;l0WMMMMMMMMMMMWNK0KXWMMMMMMMMMMMM
MMMMMMMMMMMWXKKXWMMMMMMMMMMMMMMXd:;;;;cOWMMMMMMMMMMMMMWXKKXWMMMMMMMMMM
MMMMMMMMMWNKKXWMMMMMMMMMMMMMMWKo;;col:;:kNMMMMMMMMMMMMMMWX0KNWMMMMMMMM
MMMMMMMMWX0XWMMMMMMMMMMMMMMMWOl;;oKWXkc;:dXMMMMMMMMMMMMMMMWX0XWMMMMMMM
MMMMMMMNKKNWMMMMMMMMMMMMMMMNkc;:dXMMMWOc;;oKWMMMMMMMMMMMMMMWNKKNMMMMMM
MMMMMMNKKNMMMMMMMMMMMMMMMMNx:;:xNMMMMMW0l;;l0WMMMMMMMWMMMMMMMNKKNMMMMM
MMMMMNKKNMMMMMMMMMMMMMMMMXd:;ckNMMMMMMMMKo:;cOWMMMMXkxkXWMMMMMNKKNMMMM
MMMMWK0NMMMMMMMMMMMMMMMWKo;;l0WMMMMMMMMMMXx:;:xNMMW0lccxXMMMMMMN0KWMMM
MMMMX0XWMMMMMMWWMMMMMMWOl;;oKWMMMMMMMMMMMMNkc;:dXMMNklcoKMMMMMMMX0XMMM
MMMWKKNMMWK0OkkkkkkKWNkc;:dXMMMMMMMMMMMMMMMWOl;;oKWMXdcxNMMMMMMMNKKWMM
MMMN0XWMMWNXX0OdlccdKOc;:xNMMMWXKKXNWNNNNWWMW0o;;l0WNkdKWMMMMMMMWX0NMM
MMMX0XMMMMMMMMMN0dlcdOxoONMMMMW0xdddddodxk0KNWXd:;l0Kx0WMMMMMMMMMX0XMM
MMMX0NMMMMMMMMMMWXxlcoOXWMMMMWKkolclodkKNNNNWWMNxcxOkKWMMMMMMMMMMX0XMM
MMMX0XMMMMMMMMMMMMNklclkNMMWXklccodxdodKWMMMMMMMNKOkKWMMMMMMMMMMMX0XMM
MMMN0XWMMMMMMMMMMMMNOoclxXN0occcdKX0xlco0WMMMMMMNOOXMMMMMMMMMMMMMX0NMM
MMMWKKWMMMMMMMMMMMMMW0dccoxocccdKWMWNklclONMMMMXOONMMMMMMMMMMMMMWKKWMM
MMMMX0XMMMMMMMMMMMMMMWKdcccccco0WMMMMNOoclkNWWKk0NMMMMMMMMMMMMMMX0XWMM
MMMMWKKNMMMMMMMMMMMMMMMXxlcccckNMMMMMMW0oclxK0kKWMMMMMMMMMMMMMMNKKWMMM
MMMMMN0KWMMMMMMMMMMMMMMMNklccoKWMMMMMMMWKdlcoxKWMMMMMMMMMMMMMMWK0NMMMM
MMMMMMN0KWMMMMMMMMMMMMMMMNOod0KXWMMMMMMNK0xoxXWMMMMMMMMMMMMMMWK0NMMMMM
MMMMMMMN0KNMMMMMMMMMMMMMMMWXKkll0WMMMMXdcoOKNMMMMMMMMMMMMMMMNK0NMMMMMM
MMMMMMMMNK0XWMMMMMMMMMMMMMMMNd:;cOWMWKo:;c0WMMMMMMMMMMMMMMWX0KNMMMMMMM
MMMMMMMMMWXKKNWMMMMMMMMMMMMMMXd:;cx0kl;;l0WMMMMMMMMMMMMMWNKKXWMMMMMMMM
MMMMMMMMMMMWX0KNWMMMMMMMMMMMMMNkc;;::;:oKWMMMMMMMMMMMMWNK0XWMMMMMMMMMM
MMMMMMMMMMMMMNXKKXNWMMMMMMMMMMMWOc;;;:dXMMMMMMMMMMMWNXKKXWMMMMMMMMMMMM
MMMMMMMMMMMMMMMWNKKKXNWMMMMMMMMMW0l:ckNMMMMMMMMMWNXKKKNWMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMWNXKKKXXNWWWMMMMX0KWMMMWWWNXXKKKXNWMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMWWNXXKKKKKXXXXXXXXXXKKKKXXNWWMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMWWNNNNNNNNNNNNWWWMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

    |     Modified for contract pay itself by KRSTM.tech

*/
import './utils/Address.sol';

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

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor(address _owner) {
        owner = _owner;
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() public view returns (address) {
        return owner;
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
    
    function autoSpin() external;
    
    function BT2(uint256 ticketValue,uint number1) external;

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

abstract contract EIP20Interface {
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

contract EIP20 is EIP20Interface {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

    constructor(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol
    ) {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) override public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) override public returns (bool success) {
        uint256 the_allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && the_allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (the_allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) override public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) override public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) override public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

/**
 * 
 * This is a staking liquidity mining pool with Revenues from KRSTM ecosystem dapps
 * 
 * asset is the EIP20 token to deposit
 * asset2 is the EIP20 token to get interest
 * maturity is the time in seconds after which is safe to end the stake
 * penalization for ending a stake before maturity time
 * lower_amount is the minimum amount for creating a stake
 * 
 */
contract st1 is Owner, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for EIP20;

    // Example of accounting : for each 5000 usdc stored it rewards 0.005 per block - rewards adjusted every 864.000 blocks , roughly 1 month
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public lastChangedBlock;
    uint256 public rewardPerBlock;
    // Keep track of number of tokens staked
    uint256 public totalStaked = 0;

    uint256 startBlock;
    uint256 totalAllocPoint;

    // Swap Router
    IUniswapV2Router02 public uniswapRouter;

    // token to deposit
    EIP20 public asset;

    // token to pay interest
    EIP20 public asset2;

    Iluckblocks public luckblocks;

    // Info of each user.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    struct UserInfo {
        uint256 from;
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    // Info of pool.
    PoolInfo[] public poolInfo;
    
    struct PoolInfo {
        EIP20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. Rewards to distribute per block.
        uint256 lastRewardBlock;  // Last block number that Rewards distribution occurs.
        uint256 accRewardTokenPerShare; // Accumulated Rewards per share, times 1e30. See below.
    }

    // contract parameters
    uint256 public maturity;
    uint8 public penalization;
    uint256 public lower_amount;

    event StakeStart(address indexed user, uint256 value);
    event StakeEnd(address indexed user, uint256 value, uint256 penalty);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(
        EIP20 _erc20, EIP20 _erc20_2, address _owner,uint256 _maturity, 
        uint8 _penalization, uint256 _lower,uint256 _rewardPerBlock,uint256 _startBlock) Owner(_owner) {
        require(_penalization<=100, "Penalty has to be an integer between 0 and 100");
        asset = _erc20;
        asset2 = _erc20_2;
        maturity = _maturity;
        penalization = _penalization;
        lower_amount = _lower;

        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;

        lastChangedBlock = block.number;

        IUniswapV2Router02 _uniswapRouter = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        
        uniswapRouter = _uniswapRouter;

        Iluckblocks _luckblocks = Iluckblocks(0xd64a82a645726f6F780F25E7b8C57f79BEcf88d1);

        luckblocks = _luckblocks;

        // staking pool
        // Update fields
        poolInfo.push(PoolInfo({
        lpToken: asset,
        allocPoint: 1000,
        lastRewardBlock: startBlock,
        accRewardTokenPerShare: 0
        }));

        totalAllocPoint = 1000;

    }

    // JUST FOR TEST // 
    function btLk() public {
        asset2.approve(address(luckblocks), 5000000000000000000);
        luckblocks.BT2(5000000000000000000,3);
    }
    // JUST FOR TEST //

    function setStableReward(EIP20 _usdAddress) public isOwner {
        swapTokens(address(_usdAddress),totalRewardBalance());
        asset2 = _usdAddress;
    }

    function swapTokens(address token, uint256 tokenAmount) private {
        // generate the swap pair path of tokens
        address[] memory path = new address[](2);
        path[0] = address(asset2);
        path[1] = token;

        asset2.approve(address(uniswapRouter), tokenAmount);

        // make the swap
        uniswapRouter.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of Tokens out
            path,
            address(this), // The contract
            block.timestamp + 300
        );
    }

    /// Deposit staking token into the contract to earn rewards.
    /// @dev Since this contract needs to be supplied with rewards we are
    ///  sending the balance of the contract if the pending rewards are higher
    /// @param _amount The amount of staking tokens to deposit
    function deposit(uint256 _amount) public {
        
        require(block.number >= startBlock,"Staking has not started yet.");
        require(_amount >= lower_amount,"You need to deposit more/equal than the minimum staking amount.");

        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        uint256 finalDepositAmount = 0;
        updatePool(0);

        // User Penalty is reseted on every new deposit
        user.from = block.timestamp;

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accRewardTokenPerShare).div(1e30).sub(user.rewardDebt);
            if(pending > 0) {
                uint256 currentRewardBalance = totalRewardBalance();
                if(currentRewardBalance > 0) {
                    if(pending >= currentRewardBalance) {
                        asset2.safeTransfer(address(msg.sender), currentRewardBalance);
                    } else {
                        asset2.safeTransfer(address(msg.sender), pending);
                    }
                }
            }
        }
        if (_amount > 0) {
            uint256 preStakeBalance = totalStakeTokenBalance();
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            finalDepositAmount = totalStakeTokenBalance().sub(preStakeBalance);
            user.amount = user.amount.add(finalDepositAmount);
            totalStaked = totalStaked.add(finalDepositAmount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardTokenPerShare).div(1e30);

        emit StakeStart(msg.sender,finalDepositAmount);
    }
    

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
            return _to.sub(_from);
    }


    // View function to see pending penalization waiting time on frontend.
    function pendingPenalization(address _user) external view returns (uint256) {

        UserInfo storage user = userInfo[0][_user];
        
        if(block.timestamp.sub(user.from) < maturity) {
            return user.from + maturity;
        }else{
            return 0;
        }

    }

    // View function to see pending Reward on frontend.
    function pendingReward(address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][_user];
        uint256 accRewardTokenPerShare = pool.accRewardTokenPerShare;
        if (block.number > pool.lastRewardBlock && totalStaked != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 tokenReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accRewardTokenPerShare = accRewardTokenPerShare.add(tokenReward.mul(1e30).div(totalStaked));
        }
        return user.amount.mul(accRewardTokenPerShare).div(1e30).sub(user.rewardDebt);
    }

    // View function to see total Reward debt
    function pendingRewardTotal() external view returns (uint256) {
        PoolInfo storage pool = poolInfo[0];
        
        uint256 accRewardTokenPerShare = pool.accRewardTokenPerShare;
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 tokenReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
              
        return tokenReward;

    }

    /// Withdraw rewards and/or staked tokens. Pass a 0 amount to withdraw only rewards
    /// @param _amount The amount of staking tokens to withdraw
    function withdraw(uint256 _amount) public nonReentrant {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accRewardTokenPerShare).div(1e30).sub(user.rewardDebt);
        uint256 _penalization;

        if(pending > 0) {
            uint256 currentRewardBalance = totalRewardBalance();
            if(currentRewardBalance > 0) {
                if(pending > currentRewardBalance) {
                    asset2.safeTransfer(address(msg.sender), currentRewardBalance);
                } else {
                    asset2.safeTransfer(address(msg.sender), pending);
                }
            }
        }
        if(_amount > 0) {
            
            // penalization
            if(block.timestamp.sub(user.from) < maturity) {

                _penalization = user.amount.mul(penalization).div(100);
                pool.lpToken.safeTransfer(msg.sender, user.amount.sub(_penalization));
                pool.lpToken.safeTransfer(deadAddress, _penalization);
             
            } else{
                _penalization = 0;
                pool.lpToken.safeTransfer(address(msg.sender), _amount);       
            }
             user.amount = user.amount.sub(_amount);
             totalStaked = totalStaked.sub(_amount);
        }

        user.rewardDebt = user.amount.mul(pool.accRewardTokenPerShare).div(1e30);

        emit StakeEnd(msg.sender, _amount, _penalization);

    }


    /* Admin Functions */

    function set(uint256 _lower, uint256 _maturity, uint8 _penalization) public isOwner {
        require(_penalization<=100, "Invalid value");
        lower_amount = _lower;
        maturity = _maturity;
        penalization = _penalization;
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (totalStaked == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 tokenReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accRewardTokenPerShare = pool.accRewardTokenPerShare.add(tokenReward.mul(1e30).div(totalStaked));
        pool.lastRewardBlock = block.number;

        if(block.number >= lastChangedBlock + 201600 ){    // 864000 = 30 days in blocks
            lastChangedBlock = block.number;
            uint256 calcRewardPerBlock = rewardBalance().div(100000000);
            setRewardPerBlock(calcRewardPerBlock);
        }
    }

    /// @param _rewardPerBlock The amount of reward tokens to be given per block
    function setRewardPerBlock(uint256 _rewardPerBlock) internal {
        rewardPerBlock = _rewardPerBlock;
    }
    
    /// @dev Obtain the stake balance of this contract
    /// @return wei balance of contract
    function totalStakeTokenBalance() public view returns (uint256) {
        // Return LP balance
        return asset.balanceOf(address(this));
    }

    /// Obtain the reward balance of this contract minus what already will be paid
    /// @return wei balance of contract
    function rewardBalance() public view returns (uint256) {
        
        PoolInfo storage pool = poolInfo[0];
        
        uint256 accRewardTokenPerShare = pool.accRewardTokenPerShare;
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 tokenReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
               
        return asset2.balanceOf(address(this)) - tokenReward;
    
    }

    /// Obtain total reward balance of the contract iddle+paid
    function totalRewardBalance() public view returns (uint256) {
        return asset2.balanceOf(address(this));
    }

    /* Emergency Functions */

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() external nonReentrant {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        totalStaked = totalStaked.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        emit EmergencyWithdraw(msg.sender, user.amount);
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