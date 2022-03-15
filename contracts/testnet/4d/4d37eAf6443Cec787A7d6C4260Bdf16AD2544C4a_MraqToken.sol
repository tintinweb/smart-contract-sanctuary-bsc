/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, "Address: low-level call failed");
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {

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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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


// pragma solidity >=0.5.0;

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

// pragma solidity >=0.6.2;

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



// pragma solidity >=0.6.2;

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



interface ILottery {
    function getNumberOfTickets(address ticket_owner) external view returns (uint256);
    function getLastWinner() external view returns(address);
    function getMaxtickets() external view returns(uint256);
    function getLastLottery() external view returns(uint256);
    function getTicketPrice() external view returns(uint256);

}


contract Lottery is Ownable, ILottery {
    using SafeMath for uint256;
    using Address for address;

    address public _token;    

    uint256 public tikcet_price;
    uint256 public maxtickets;
    uint256 public lastLottery;
    uint256 public jackpotPrecentage;
    address public lastwinner;


    address[] participiants; //lottery participiants;
    mapping (address => uint256) tickets;
    address[] ticketsPool;

    constructor()  {
        _token = _msgSender();
        maxtickets=100;
        jackpotPrecentage=80;
        tikcet_price=100000*10**18;
    }

    modifier onlyToken() {
        require(_msgSender() == _token); _;
    }


    function buyickets(uint256 amount, address ticket_owner) external returns(bool){
	    if(tickets[ticket_owner]==0){
            require(amount<=maxtickets,"Can't buy more then max tickets");
		    participiants.push(ticket_owner);
		    tickets[ticket_owner]=amount;
	    }else {
            require(tickets[ticket_owner].sub(amount)>=maxtickets,"Can't buy more then max tickets");
		    tickets[ticket_owner]=tickets[ticket_owner].sub(amount);
	    }
        addticketpool(amount,ticket_owner);
        return true;
    }

    function setMaxtickets(uint256 number) external onlyOwner{
        maxtickets=number;
    }

    function getMaxtickets() external view returns(uint256){
        return maxtickets;
    }

    function getLastLottery() external view returns(uint256){
        return lastLottery;
    }
    

    function setTicketPrice(uint256 number) external onlyOwner{
        tikcet_price=number;
    }
    
   function getTicketPrice() external view returns(uint256){
        return tikcet_price;
    }

    //set get ticket price


    function getNumberOfTickets(address ticket_owner) external view returns (uint256){
        return tickets[ticket_owner];
    }

    function addticketpool(uint256 amount, address ticket_owner) internal{
	    uint256 i=0;
	    while(i<amount){
		    ticketsPool.push(ticket_owner);
		    i++;
	    }
    }

    function random() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty + block.timestamp)));
    }

    //reset lottery


    function resetlottery() internal{
    //reset tickets
	    uint256 i=0;
	    while(i<participiants.length){
		    tickets[participiants[i]]=0;
		    i++;
	    }
    //reset ticketsPool
	    i=0;
	    uint256 total=ticketsPool.length;
	    while(i<total){
		    ticketsPool.pop();
	    }

    //reset participiants
	    i=0;
	    total=participiants.length;
	    while(i<total){
		    participiants.pop();
	    }

}


    function launch_lottery() external {

	    uint256 totalTickets=ticketsPool.length;
        require(totalTickets>0,"Lottery can't launch");
	    uint256 winnerNumber=random().mod(totalTickets);
	    lastwinner=ticketsPool[winnerNumber];
	    lastLottery=block.timestamp;
    }

    function getLastWinner() external view returns(address){
        return lastwinner;
    }

    function claim_winner(address winner) external {
        require(winner==lastwinner, "Lottery reward can be claim only to winner");
	    uint256 reward=IBEP20(_token).balanceOf(address(this)).mul(jackpotPrecentage).div(100);
	    IBEP20(_token).transfer(winner,reward);
    }


}



interface IRocket {
    function setShare(address passanger, uint256 amount) external;
    function getGoal() external view returns(uint);
    function getRocketFuel() external view returns(uint);
    function getSharePerPassanger(address passanger) external view returns(uint256);
    function getTotalSharesForRewards() external view returns(uint256);
    function getRewardsPerShare() external view returns(uint256);
    function claimRocket() external;
    

}



contract Rocket is Ownable,IRocket {
    using SafeMath for uint256;
    using Address for address;

    address public _token;

    struct Share {
        uint256 amount;
        uint256 timeStamp;
    }

    address[] passangers;
    mapping (address => uint256) passangerIndexes;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalRewards;
    uint256 public RewardsPerShare;
    uint256 public RewardsPerShareAccuracyFactor = 10 ** 36;

   // uint256 public minPeriod = 1 hours;
    uint256 public minHoldPeriod; 
   // uint256 public minDistribution = 1 * (10 ** 18);

    uint256 public totalSharesForRewards;

    uint256 currentIndex;

    uint256 public rocketLaunchDate;
    uint256 public rocketThreshold;

    bool public RocketFlying=false;

    address[] rewardPassingers;
    mapping (address => uint256) RewardShare;
     


    IUniswapV2Router02 public uniswapV2Router;    
    address public WBNB;

    modifier onlyToken() {
        require(_msgSender() == _token); _;
    }

    constructor()  {
        uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // testnet 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        WBNB = uniswapV2Router.WETH();
        _token = _msgSender();
        //minimal period of holding tokens for getting rewards 
        minHoldPeriod = 0; //1 hours; // 


    }

    receive() external payable {}


    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        uniswapV2Router = IUniswapV2Router02(newAddress);
        WBNB = uniswapV2Router.WETH();
    }


    //-------------------------- BEGIN EDITING FUNCTIONS ----------------------------------

    // Allows admin to create a new rocket trashold with a corresponding value.
    function prepareRocket( uint256 _newValue) external onlyOwner {
        if(rocketThreshold==0) rocketThreshold=_newValue;
    }
    
    //return goal
    function getGoal() external view override returns(uint256){
        return rocketThreshold;
    }
    //get rocket flying
    function getRocketFlying() external view returns(bool){
        return RocketFlying;
    }
    //return current rocket fuel
    function getRocketFuel() external view override returns(uint256){
        return address(this).balance;
    }

    //return shares for address
    function getSharePerPassanger(address passanger) external view returns(uint256){
        return shares[passanger].amount;
    }
    //return total shares eligible for rewards
    function getTotalSharesForRewards() external view returns(uint256){
        return totalSharesForRewards;
    }
    //return rewards tokens per share 
    function getRewardsPerShare() external view returns(uint256){
        return RewardsPerShare;
    }

    function setMinHoldPeriod(uint256 period) external onlyOwner {
        minHoldPeriod=period;
    }

   
    // Allows admin to manually select new rocket fuel
    function overrideGoal(uint256 newRocketThreshold) external onlyOwner returns (uint256) {
        rocketThreshold = newRocketThreshold;
        return rocketThreshold;
    }


    //rocket engine
    function launchRocket() public  {

        uint256 fuelBalance = address(this).balance;
        require(fuelBalance >= rocketThreshold, "Rocket launch not allowed before threshold");
        rocketLaunchDate=block.timestamp;
        //
        buyReflectTokens(rocketThreshold, address(this));
        
        //calcuclate total share more then 1 token and at least minimal perod hold tokens.
        updateTotalSharesForRewards();
        currentIndex =0;
        RocketFlying = true;
        RewardsPerShare = RewardsPerShareAccuracyFactor.mul(totalRewards).div(totalSharesForRewards);
        //distribute tokens 
        //distributeAllRewards();
        //calculate new goal
        calculateNewGoal();

    }


    function setShare(address passanger, uint256 amount) external override onlyToken {
      
        if(amount > 0 && shares[passanger].amount == 0){
            addPassanger(passanger);
            shares[passanger].timeStamp=block.timestamp;

        }else if(amount == 0 && shares[passanger].amount > 0){
            removePassanger(passanger);
        }

        totalShares = totalShares.sub(shares[passanger].amount).add(amount);
        shares[passanger].amount = amount;
    }

    function buyReflectTokens(uint256 amount, address to) internal {
        uint256 balanceBefore = IBEP20(address(_token)).balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = _token;

        IBEP20(WBNB).approve(address(uniswapV2Router), amount);

         uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            to, // Burn address
            block.timestamp.add(300)
        );
        
        uint256 newAmount = IBEP20(address(_token)).balanceOf(address(this)).sub(balanceBefore);

        totalRewards = newAmount;
        
    }

    function distributeReward(address passanger) internal {
        if(RewardShare[passanger] == 0){ return; }


        uint256 amount = getUnpaidEarnings(passanger);
        if(IBEP20(address(_token)).balanceOf(address(this))<amount){
            amount=IBEP20(address(_token)).balanceOf(address(this));
        }
        if(amount > 0){
            IBEP20(address(_token)).transfer(passanger, amount);
            RewardShare[passanger]=0;
        }
    }

    function updateTotalSharesForRewards() internal{
        totalSharesForRewards = 0;
        uint256 passangerCount = passangers.length;
        uint256 i = 0;
        while(i<passangerCount){
            if(shares[passangers[i]].timeStamp<=rocketLaunchDate-minHoldPeriod){
                totalSharesForRewards=totalSharesForRewards.add(shares[passangers[i]].amount);
                rewardPassingers.push(passangers[i]);
                RewardShare[passangers[i]]=shares[passangers[i]].amount;
            }
            i++;
        }

    }

    function distributeAllRewards(uint256 gas) external{
        uint256 passangerCount = rewardPassingers.length;
        uint256 i = currentIndex;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();    

        while(gasUsed < gas && i<passangerCount){
                distributeReward(rewardPassingers[i]);
            
            i++;

            uint256 newGasLeft = gasleft();

    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}

    		gasLeft = newGasLeft;
        }
        currentIndex=i;

        //if all rewards distributed stop flight and reset passingers eligable for rewards
        if(currentIndex>=rewardPassingers.length){
            RocketFlying =false;
            while(rewardPassingers.length>0){
                rewardPassingers.pop();
            }
        }


    } 


    //manual claim

    function claimRocket() external {
        distributeReward(_msgSender());
    }

    function getUnpaidEarnings(address passanger) public view returns (uint256) {
        if(RewardShare[passanger] == 0){ return 0; }

        uint256 passangerTotalBountys = getCumulativeRewards(RewardShare[passanger]);

        return passangerTotalBountys;
    }

    function getCumulativeRewards(uint256 share) internal view returns (uint256) {
        return share.mul(RewardsPerShare).div(RewardsPerShareAccuracyFactor);
    }

    function addPassanger(address passanger) internal {
        passangerIndexes[passanger] = passangers.length;
        passangers.push(passanger);
    }

    function removePassanger(address passanger) internal {
        passangers[passangerIndexes[passanger]] = passangers[passangers.length-1];
        passangerIndexes[passangers[passangers.length-1]] = passangerIndexes[passanger];
        passangers.pop();
    }

    // Rescue bnb that is sent here by mistake
    function rescueBNB(uint256 amount, address to) external onlyOwner{
        payable(to).transfer(amount);
      }

    // Rescue tokens that are sent here by mistake
    function rescueToken(IBEP20 token, uint256 amount, address to) external onlyOwner {
        if( token.balanceOf(address(this)) < amount ) {
            amount = token.balanceOf(address(this));
        }
        token.transfer(to, amount);
    }

    function calculateNewGoal() internal {
        
        address pair = IUniswapV2Factory(uniswapV2Router.factory())
        .getPair(_token, uniswapV2Router.WETH());
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pair).getReserves();
        
        uint256 ratio = reserve1.mul(RewardsPerShareAccuracyFactor).div(reserve0);
        rocketThreshold=IBEP20(_token).totalSupply().mul(ratio).div(RewardsPerShareAccuracyFactor).div(10); //10% marketcapa
    }

    

}

contract MraqToken is  IBEP20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    
    bool private swapping;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) _isExcludedFromRocket;
    mapping (address => bool) private _isExcludedFromMaxTx;


    uint256 private _totalSupply;

    string public _name = "Mraq Token";
    string public _symbol = "MRQ";
    uint8 public _decimals = 18;  
    uint256 _initialSupply= 100*10**9*10**_decimals;
    address public WBNB; // WBNB address testnet
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    address payable public _marketingAddress = payable(0x8D9E9904cA8602BC1a0ed7Df0BdF61b3a5198fCf); // Marketing Address

    Rocket rocket;
    address public _rocketAddress;
    Lottery lottery;
    address public _lotteryAddress;

    uint256 private marketingFee = 200;
    uint256 private rocketFee = 200;
    uint256 private burnFee = 100;
    uint256 private liquidityFee = 300;
    uint256 private totalFee=marketingFee.add(rocketFee).add(burnFee).add(liquidityFee);
    
    uint256 private feeDenominator = 10000;




    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public _maxTxAmount = 500 * 10**6 * 10**_decimals; //0,5%
    uint256 private numTokensSellToAddToLiquidity = 20 * 10**6 * 10**_decimals; //0,05%

    // use by default 300,000 gas to process auto-claiming rocket rewards
    uint256 public gasForProcessing = 300000;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event BuyLotteryTicket(uint256 amount, address ticket_owner);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );



    constructor(){
        //
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
          IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //testnet
                

         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        WBNB = uniswapV2Router.WETH();
        rocket = new Rocket();
        _rocketAddress = address(rocket);

        lottery = new Lottery();
        _lotteryAddress = address(lottery);

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_marketingAddress] = true;
        _isExcludedFromFees[_rocketAddress] = true;

        _isExcludedFromRocket[address(this)]=true;
        _isExcludedFromRocket[deadAddress]=true;
        _isExcludedFromRocket[address(0)]=true;
        _isExcludedFromRocket[_rocketAddress]=true;
        _isExcludedFromRocket[uniswapV2Pair]=true;


        _isExcludedFromMaxTx[address(this)]=true;
        _isExcludedFromMaxTx[owner()]=true;
        _isExcludedFromMaxTx[_rocketAddress]=true;
        _isExcludedFromMaxTx[deadAddress]=true;
        _isExcludedFromMaxTx[address(0)]=true;
        _isExcludedFromMaxTx[_marketingAddress]=true;

    
        _mint(_msgSender(), _initialSupply);
    }



    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    receive() external payable {}


    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if(!_isExcludedFromMaxTx[from] && !_isExcludedFromMaxTx[to]){
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }
  //      if(from != owner() && to != owner()) {
  //          require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
  //      }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= numTokensSellToAddToLiquidity;
        bool sell = to==uniswapV2Pair; //sell token
        bool buy = from==uniswapV2Pair; //buy token

        if (contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }
        
        if( canSwap &&
            sell &&
            !buy &&
            !swapping &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;
            
            uint256 totalFees = totalFee;

            uint256 feeTokens = contractTokenBalance.mul(marketingFee.add(rocketFee)).div(totalFees);
            swapAndSendToFee(feeTokens);

            uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
            swapAndLiquify(swapTokens);

            //uint256 burnTokens = contractTokenBalance.mul(burnFee).div(totalFees);
            uint256 burnTokens = balanceOf(address(this));
            _burn(address(this),burnTokens);

            //uint256 sellTokens = balanceOf(address(this));
            //swapAndSendDividends(sellTokens);

            swapping = false;
        }

        bool takeFee = !swapping;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee && (buy || sell)) {
			uint256 feePercent = rocketFee.add(liquidityFee).add(marketingFee).add(burnFee);

			uint256 fees = amount.mul(feePercent).div(feeDenominator);

        	amount = amount.sub(fees);

            _transferToken(from, address(this), fees);
        }
        
        _transferToken(from, to, amount);

     
    }

    function swapAndSendToFee(uint256 tokens) internal {
                
        uint256 fee = marketingFee.add(rocketFee);
        uint256 initialWBNBBalance = address(this).balance;

        swapTokensForEth(tokens);
        uint256 toSplit = address(this).balance.sub(initialWBNBBalance);
        uint256 toMarketing = toSplit.mul(marketingFee).div(fee);
        payable(_marketingAddress).transfer(toMarketing);
        payable(_rocketAddress).transfer(toSplit.sub(toMarketing));

    }

    // get rocket goal, fuel
    
    function getRocketGoal() external view virtual returns (uint256){
        return rocket.getGoal();

    }

    function getRocketFuel() external view virtual returns (uint256){
        return rocket.getRocketFuel();

    }

    function setRocketGoal(uint256 goal)external virtual onlyOwner{
        rocket.prepareRocket(goal);
    }

    
    //manual launch rocket
    function LaunchRocket()external virtual onlyOwner{
        rocket.launchRocket();
    }



    function getShare(address passanger)external view virtual returns(uint256){
        return rocket.getSharePerPassanger(passanger);
    }

    function getTotalRewardShareAndRate()external view virtual returns(uint256,uint256){
        return (rocket.getTotalSharesForRewards(),rocket.getRewardsPerShare());
    }
   
    function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }


    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        emit SwapTokensForETH(tokenAmount, path);
    }

    function swapETHForTokens(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

      // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp.add(300)
        );
        
        emit SwapETHForTokens(amount, path);
    }
    function _transferToken(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");


        _balances[sender] = _balances[sender].sub(amount, "Token: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);

    
        if(!_isExcludedFromRocket[sender]){ try rocket.setShare(sender, _balances[sender]) {} catch {} }
        if(!_isExcludedFromRocket[recipient]){ try rocket.setShare(recipient, _balances[recipient]) {} catch {} }

        //check rocket and launch 

        if(rocket.getRocketFuel()>=rocket.getGoal() && rocket.getGoal()>0 && !swapping && !rocket.getRocketFlying()){
         //   swapping=true;
            try rocket.launchRocket() {} catch{}
         //   swapping=false;
        }

        // distribute rewards
        if(rocket.getRocketFlying()){
            swapping=true;
            rocket.distributeAllRewards(gasForProcessing);
            swapping=false;
        }

        emit Transfer(sender, recipient, amount);
    }


    function buyLotteryTicket(uint256 amount)external returns(bool){

        require(balanceOf(_msgSender())>=amount.mul(lottery.getTicketPrice()),"Token: Amount exceeds token balance");
        bool bought=lottery.buyickets(amount,_msgSender());
        if(bought){
            _transfer(_msgSender(), _lotteryAddress, amount.mul(lottery.getTicketPrice()));
            emit BuyLotteryTicket(amount, _msgSender());
            return true;
        }
        return false;
    }

    function lunchLottery() external onlyOwner{
        lottery.launch_lottery();
        lottery.claim_winner(lottery.getLastWinner());
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual  override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override  returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {BEP20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual  override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

 
    
    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
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






}