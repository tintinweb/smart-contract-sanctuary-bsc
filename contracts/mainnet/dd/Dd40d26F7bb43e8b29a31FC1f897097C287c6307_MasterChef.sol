/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: GPL-3.0-or-later Or MIT
// File: contracts\SafeMath.sol



pragma solidity >=0.6.0 <0.8.0;

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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts\IBEP20.sol

pragma solidity >=0.6.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

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

// File: contracts\Address.sol



pragma solidity >=0.6.2 <0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// File: contracts\SafeBEP20.sol



pragma solidity >=0.6.0 <0.8.0;




/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

// File: contracts\Context.sol



pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts\Ownable.sol



pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts\LTRBTToken.sol

/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

/**
        The new version of the LittleRabbit project
        Tax buy and sell 7% with buyback feature

        Telegram : https://t.me/littlerabbitchat
        Dex https://littlerabbitswap.com
        Website https://littlerabbitproject.com/

 */


pragma solidity 0.6.12;

//interfaces
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// main contract
contract  LittleRabbit is Context, IERC20, Ownable {

//custom
    IUniswapV2Router02 public uniswapV2Router;
//string
    string private _name = "Little Rabbit";
    string private _symbol = "LTRBT";
//bool
    bool public moveBnbToWallets = true;
    bool public swapAndLiquifyEnabled = true;
    bool public marketActive = false;
    bool public limitActive = true;
    bool public buyTimeLimit = true;
    bool private isInternalTransaction = false;
//address
    address public uniswapV2Pair;
    address public _MarketingWalletAddress = 0xAADCf09009cf7A6CCc623FF4aC64dceF345A8a04;
    address public _DevelopmentWalletAddress = 0xAADCf09009cf7A6CCc623FF4aC64dceF345A8a04;
    address public _Nft_treasuryWalletAddress = 0x89bb34eD95FDf749C55d878Ac0ED9A4cc752611e;
    address public _BuybackWalletAddress = 0x2A8fb72561e7601FE52bcd9b8502Da6da623Afa2;
    address[] private _excluded;

//uint
    uint public buyReflectionFee = 1;
    uint public sellReflectionFee = 1;
    uint public buyMarketingFee = 3;
    uint public sellMarketingFee = 3;
    uint public buyDevelopmentFee = 1;
    uint public sellDevelopmentFee = 1;
    uint public buyNft_treasuryFee = 1;
    uint public sellNft_treasuryFee = 1;
    uint public buyBuybackFee = 1;
    uint public sellBuybackFee = 2;
    uint public buyFee = buyReflectionFee + buyMarketingFee + buyDevelopmentFee + buyNft_treasuryFee + buyBuybackFee;
    uint public sellFee = sellReflectionFee + sellMarketingFee + sellDevelopmentFee + sellNft_treasuryFee + sellBuybackFee;
    uint public buySecondsLimit = 5;
    uint public maxBuyTx;
    uint public maxSellTx;
    uint public maxWallet;
    uint public intervalSecondsForSwap = 4;
    uint public minimumWeiForTokenomics = 1 * 10**14; // 0.0001 bnb
    uint private startTimeForSwap;
    uint private MarketActiveAt;
    uint private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 9;
    uint private _tTotal = 1_000_000_000_000_000 * 10 ** _decimals;
    uint private _rTotal = (MAX - (MAX % _tTotal));
    uint private _tFeeTotal;
    uint private _ReflectionFee;
    uint private _MarketingFee;
    uint private _DevelopmentFee;
    uint private _Nft_treasuryFee;
    uint private _BuybackFee;
    uint private _OldReflectionFee;
    uint private _OldMarketingFee;
    uint private _OldDevelopmentFee;
    uint private _OldNft_treasuryFee;
    uint private _OldBuybackFee;

//mapping
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public premarketUser;
    mapping (address => bool) public excludedFromFees;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => uint) public userLastBuy;
//event
    event MarketingCollected(uint256 amount);
    event DevelopmentCollected(uint256 amount);
    event NftTreasuryCollected(uint256 amount);
    event BuyBackCollected(uint256 amount);
    event ExcludedFromFees(address indexed user, bool state);
    event SwapSystemChanged(bool status, uint256 intervalSecondsToWait);
    event MoveBnbToWallets(bool state);
    event LimitChanged(uint maxsell, uint maxbuy, uint maxwallt);

    // accept bnb for autoswap
    receive() external payable {
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
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }
    function setFees() private {
        buyFee = buyReflectionFee + buyMarketingFee + buyDevelopmentFee + buyNft_treasuryFee;
        sellFee = sellReflectionFee + sellMarketingFee + sellDevelopmentFee + sellNft_treasuryFee;
    }

    function excludeFromReward(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }
    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    function setMoveBnbToWallets(bool state) external onlyOwner {
        moveBnbToWallets = state;
        emit MoveBnbToWallets(state);
    }
    function excludeFromFee(address account) external onlyOwner {
        excludedFromFees[account] = true;
        emit ExcludedFromFees(account,true);
    }
    function includeInFee(address account) external onlyOwner {
        excludedFromFees[account] = false;
        emit ExcludedFromFees(account,false);
    }
    function set_Fees(bool isBuy, uint reflection, uint marketing, uint development, uint nftreasury, uint bback) public onlyOwner{
        require(reflection+marketing+development+nftreasury+bback <= 20, "Fees too high");
        if(isBuy == true){
            buyReflectionFee = reflection;
            buyMarketingFee = marketing;
            buyDevelopmentFee = development;
            buyNft_treasuryFee = nftreasury;
            buyBuybackFee = bback;
        }else if(isBuy == false){
            sellReflectionFee = reflection;
            sellMarketingFee = marketing;
            sellDevelopmentFee = development;
            sellNft_treasuryFee = nftreasury;
            sellBuybackFee = bback;
        }
        setFees();
    }
    function setMinimumWeiForTokenomics(uint _value) external onlyOwner {
        minimumWeiForTokenomics = _value;
    }
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount) private view returns (uint256 rAmount, uint256 rTransferAmount, uint256 rFee,
                                                               uint256 tTransferAmount, uint256 tFee, uint256 tMarketing,
                                                               uint256 tDevelopment, uint256 tNft_treasury, uint256 tBuyback) {
        (tTransferAmount, tFee, tMarketing, tDevelopment, tNft_treasury, tBuyback) = _getTValues(tAmount);
        (rAmount, rTransferAmount, rFee) = _getRValues(tAmount, tFee, tMarketing, tDevelopment, tNft_treasury, tBuyback, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tMarketing, tDevelopment, tNft_treasury, tBuyback);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment, uint256 tNft_treasury, uint256 tBuyback) {
        tFee = calculateReflectionFee(tAmount);
        tMarketing = calculateMarketingFee(tAmount);
        tDevelopment = calculateDevelopmentFee(tAmount);
        tNft_treasury = calculateNft_treasuryFee(tAmount);
        tBuyback = calculateBuybackFee(tAmount);
        tTransferAmount = tAmount - tFee - tMarketing - tDevelopment - tNft_treasury - tBuyback;
        return (tTransferAmount, tFee, tMarketing, tDevelopment, tNft_treasury, tBuyback);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment, uint256 tNft_treasury, uint256 tBuyback, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rMarketing = tMarketing * currentRate;
        uint256 rDevelopment = tDevelopment * currentRate;
        uint256 rNft_treasury = tNft_treasury * currentRate;
        uint rBuyback = tBuyback * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rMarketing - rDevelopment - rNft_treasury - rBuyback;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    function _takeMarketing(uint256 tMarketing) private {
        uint256 currentRate =  _getRate();
        uint256 rMarketing = tMarketing * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rMarketing;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tMarketing;
    }
    function _takeDevelopment(uint256 tDevelopment) private {
        uint256 currentRate =  _getRate();
        uint256 rDevelopment = tDevelopment * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rDevelopment;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tDevelopment;
    }
    function _takeNft_treasury(uint256 tNft_treasury) private {
        uint256 currentRate =  _getRate();
        uint256 rNft_treasury = tNft_treasury * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rNft_treasury;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tNft_treasury;
    }
    function _takeBuyback(uint256 tBuyback) private {
        uint256 currentRate =  _getRate();
        uint256 rBuyback = tBuyback * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rBuyback;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tBuyback;
    }

    function calculateReflectionFee(uint256 _amount) private view returns (uint256) {
        return _amount * _ReflectionFee / 10**2;
    }
    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount * _MarketingFee / 10**2;
    }
    function calculateDevelopmentFee(uint256 _amount) private view returns (uint256) {
        return _amount * _DevelopmentFee / 10**2;
    }
    function calculateNft_treasuryFee(uint256 _amount) private view returns (uint256) {
        return _amount * _Nft_treasuryFee / 10**2;
    }
    function calculateBuybackFee(uint256 _amount) private view returns (uint256) {
        return _amount * _BuybackFee / 10**2;
    }
    function setOldFees() private {
        _OldReflectionFee = _ReflectionFee;
        _OldMarketingFee = _MarketingFee;
        _OldDevelopmentFee = _DevelopmentFee;
        _OldNft_treasuryFee = _Nft_treasuryFee;
        _OldBuybackFee = _BuybackFee;
    }
    function shutdownFees() private {
        _ReflectionFee = 0;
        _MarketingFee = 0;
        _DevelopmentFee = 0;
        _Nft_treasuryFee = 0;
        _BuybackFee = 0;
    }
    function setFeesByType(uint tradeType) private {
        //buy
        if(tradeType == 1) {
            _ReflectionFee = buyReflectionFee;
            _MarketingFee = buyMarketingFee;
            _DevelopmentFee = buyDevelopmentFee;
            _Nft_treasuryFee = buyNft_treasuryFee;
            _BuybackFee = buyBuybackFee;
        }
        //sell
        else if(tradeType == 2) {
            _ReflectionFee = sellReflectionFee;
            _MarketingFee = sellMarketingFee;
            _DevelopmentFee = sellDevelopmentFee;
            _Nft_treasuryFee = sellNft_treasuryFee;
            _BuybackFee = sellBuybackFee;
        }
    }
    function restoreFees() private {
        _ReflectionFee = _OldReflectionFee;
        _MarketingFee = _OldMarketingFee;
        _DevelopmentFee = _OldDevelopmentFee;
        _Nft_treasuryFee = _OldNft_treasuryFee;
        _BuybackFee = _OldBuybackFee;
    }

    modifier CheckDisableFees(bool isEnabled, uint tradeType, address from) {
        if(!isEnabled) {
            setOldFees();
            shutdownFees();
            _;
            restoreFees();
        } else {
            //buy & sell
            if(tradeType == 1 || tradeType == 2) {
                setOldFees();
                setFeesByType(tradeType);
                _;
                restoreFees();
            }
            // no wallet to wallet tax
            else {
                setOldFees();
                shutdownFees();
                _;
                restoreFees();
            }
        }
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return excludedFromFees[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    modifier FastTx() {
        isInternalTransaction = true;
        _;
        isInternalTransaction = false;
    }
    function sendToWallet(uint amount) private {
        uint256 marketing_part = amount * sellMarketingFee / 100;
        uint256 development_part = amount * sellDevelopmentFee / 100;
        uint256 nft_treasury_part = amount * sellNft_treasuryFee / 100;
        uint256 buyback_part = amount * sellBuybackFee / 100;
        (bool success, ) = payable(_MarketingWalletAddress).call{value: marketing_part}("");
        if(success) {
            emit MarketingCollected(marketing_part);
        }
        (bool success1, ) = payable(_DevelopmentWalletAddress).call{value: development_part}("");
        if(success1) {
            emit DevelopmentCollected(development_part);
        }
        (bool success2, ) = payable(_Nft_treasuryWalletAddress).call{value: nft_treasury_part}("");
        if(success2) {
            emit NftTreasuryCollected(nft_treasury_part);
        }
        (bool success3, ) = payable(_BuybackWalletAddress).call{value: buyback_part}("");
        if(success3) {
            emit BuyBackCollected(buyback_part);
        }
    }

    function swapAndLiquify(uint256 _tokensToSwap) private FastTx {
        swapTokensForEth(_tokensToSwap);
    }
// utility functions
    function transferForeignToken(address _token, address _to, uint _value) external onlyOwner returns(bool _sent){
        if(_value == 0) {
            _value = IERC20(_token).balanceOf(address(this));
        }
        _sent = IERC20(_token).transfer(_to, _value);
    }
    function Sweep() external onlyOwner {
        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function betterTransferOwnership(address newOwner) public onlyOwner {
        _transfer(msg.sender,newOwner,balanceOf(msg.sender));
        excludedFromFees[owner()] = false;
        premarketUser[owner()] = false;
        excludedFromFees[newOwner] = true;
        premarketUser[newOwner] = true;
        transferOwnership(newOwner);
    }
//switch functions
    function ActivateMarket() external onlyOwner {
        require(!marketActive);
        marketActive = true;
        MarketActiveAt = block.timestamp;
    }
//set functions
    function setLimits(uint maxTokenSellTX, uint maxTokenBuyTX, uint maxWalletz) public onlyOwner {
        require(maxTokenSellTX >= ((_tTotal / 100) / 2)/10**_decimals);
        maxBuyTx = maxTokenBuyTX * 10 ** _decimals;
        maxSellTx = maxTokenSellTX * 10 ** _decimals;
        maxWallet = maxWalletz * 10 ** _decimals;
        emit LimitChanged(maxTokenSellTX,maxTokenBuyTX,maxWalletz);
    }
    function setMarketingAddress(address _value) external onlyOwner {
        _MarketingWalletAddress = _value;
    }
    function setDevelopmentAddress(address _value) external onlyOwner {
        _DevelopmentWalletAddress = _value;
    }
    function setNft_treasuryAddress(address _value) external onlyOwner {
        _Nft_treasuryWalletAddress = _value;
    }
    function setNft_BuybackWalletAddress(address _value) external onlyOwner {
        _BuybackWalletAddress = _value;
    }
    function setSwapAndLiquify(bool _state, uint _intervalSecondsForSwap) external onlyOwner {
        swapAndLiquifyEnabled = _state;
        intervalSecondsForSwap = _intervalSecondsForSwap;
        emit SwapSystemChanged(_state,_intervalSecondsForSwap);
    }
// mappings functions
    function editPowerUser(address _target, bool _status) external onlyOwner {
        premarketUser[_target] = _status;
        excludedFromFees[_target] = _status;
    }
    function editPremarketUser(address _target, bool _status) external onlyOwner {
        premarketUser[_target] = _status;
    }
    function editExcludedFromFees(address _target, bool _status) external onlyOwner {
        excludedFromFees[_target] = _status;
    }
    function editBatchExcludedFromFees(address[] memory _address, bool _status) external onlyOwner {
        for(uint i=0; i< _address.length; i++){
            address adr = _address[i];
            excludedFromFees[adr] = _status;
        }
    }
    function editAutomatedMarketMakerPairs(address _target, bool _status) external onlyOwner {
        automatedMarketMakerPairs[_target] = _status;
    }
// operational functions
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _transfer(address from, address to, uint256 amount) private {
        uint trade_type = 0;
        bool takeFee = true;
        require(from != address(0), "ERC20: transfer from the zero address");
    // market status flag
        if(!marketActive) {
            require(premarketUser[from],"cannot trade before the market opening");
        }
    // normal transaction
        if(!isInternalTransaction) {
        // tx limits
            //buy
            if(automatedMarketMakerPairs[from]) {
                trade_type = 1;
                if(limitActive && !premarketUser[to]){
                    require(amount<= maxBuyTx && amount+balanceOf(to) <= maxWallet, "buy limits");
                    if(buyTimeLimit){
                        require(block.timestamp >= userLastBuy[to]+buySecondsLimit, "time buy limit");
                        userLastBuy[to] = block.timestamp;
                    }
                }
            }
            //sell
            else if(automatedMarketMakerPairs[to]) {
                trade_type = 2;
                if(limitActive && !premarketUser[from]){
                    require(amount<= maxSellTx );

                }
                // liquidity generator for tokenomics
                if (swapAndLiquifyEnabled && 
                    balanceOf(uniswapV2Pair) > 0 &&
                    startTimeForSwap + intervalSecondsForSwap <= block.timestamp
                    ) {
                        startTimeForSwap = block.timestamp;
                        swapAndLiquify(balanceOf(address(this)));
                }
            }
            // send converted bnb from fees to respective wallets
            if(moveBnbToWallets) {
                uint256 remaningBnb = address(this).balance;
                if(remaningBnb > minimumWeiForTokenomics) {
                    sendToWallet(remaningBnb);
                }
            }
        }
        //if any account belongs to excludedFromFees account then remove the fee
        if(excludedFromFees[from] || excludedFromFees[to]){
            takeFee = false;
        }
        // transfer tokens
        _tokenTransfer(from,to,amount,takeFee,trade_type);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee, uint tradeType) private CheckDisableFees(takeFee,tradeType,sender) {
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment, uint256 tNft_Treasury, uint256 tBuyback) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevelopment(tDevelopment);
        _takeNft_treasury(tNft_Treasury);
        _takeBuyback(tBuyback);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment, uint256 tNft_Treasury, uint256 tBuyback) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevelopment(tDevelopment);
        _takeNft_treasury(tNft_Treasury);
        _takeBuyback(tBuyback);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment, uint256 tNft_Treasury, uint256 tBuyback) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevelopment(tDevelopment);
        _takeNft_treasury(tNft_Treasury);
        _takeBuyback(tBuyback);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevelopment, uint256 tNft_Treasury, uint256 tBuyback) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevelopment(tDevelopment);
        _takeNft_treasury(tNft_Treasury);
        _takeBuyback(tBuyback);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function KKMigration(address[] memory _address, uint256[] memory _amount) external onlyOwner {
        require(_amount.length == _amount.length,"wrong address:amount rows");
        for(uint i=0; i< _amount.length; i++){
            address adr = _address[i];
            uint amnt = _amount[i] *10**decimals();
            (uint256 rAmount, uint256 rTransferAmount,,,,,,,) = _getValues(amnt);
            _rOwned[owner()] = _rOwned[owner()] - rAmount;
            _rOwned[adr] = _rOwned[adr] + rTransferAmount;
            emit Transfer(owner(),adr,amnt);
        } 
    }
}


// File: contracts\LTRBTMasterChef.sol



pragma solidity 0.6.12;






// MasterChef is the master of Ltrbt. He can make Ltrbt and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once LTRBT is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of LTRBTs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accLtrbtPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accLtrbtPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. LTRBTs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that LTRBTs distribution occurs.
        uint256 accLtrbtPerShare;   // Accumulated LTRBTs per share, times 1e12. See below.
        uint16 depositFeeBP;      // Deposit fee in basis points
    }

    // The LTRBT TOKEN!
    LittleRabbit public ltrbt;
    // Dev address.
    address public devaddr;
    // LTRBT tokens created per block.
    uint256 public ltrbtPerBlock;
    // Bonus muliplier for early ltrbt makers.
    uint256 public constant BONUS_MULTIPLIER = 1;
    // Deposit Fee address
    address public feeAddress;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when LTRBT mining starts.
    uint256 public startBlock;
    // Deposited amount LTRBT in MasterChef
    uint256 public depositedLtrbt;

    uint256 public mintedAmount;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        LittleRabbit _ltrbt,
        address _devaddr,
        address _feeAddress,
        uint256 _ltrbtPerBlock,
        uint256 _startBlock
    ) public {
        ltrbt = _ltrbt;
        devaddr = _devaddr;
        feeAddress = _feeAddress;
        ltrbtPerBlock = _ltrbtPerBlock;
        startBlock = _startBlock;
        mintedAmount = 0;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IBEP20 _lpToken, uint16 _depositFeeBP, bool _withUpdate) public onlyOwner {
        require(_depositFeeBP <= 10000, "add: invalid deposit fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accLtrbtPerShare: 0,
            depositFeeBP: _depositFeeBP
        }));
    }

    // Update the given pool's LTRBT allocation point and deposit fee. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFeeBP, bool _withUpdate) public onlyOwner {
        require(_depositFeeBP <= 10000, "set: invalid deposit fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending LTRBTs on frontend.
    function pendingLtrbt(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accLtrbtPerShare = pool.accLtrbtPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (_pid == 0){
            lpSupply = depositedLtrbt;
        }
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 ltrbtReward = multiplier.mul(ltrbtPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accLtrbtPerShare = accLtrbtPerShare.add(ltrbtReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accLtrbtPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));        
        if (_pid == 0){
            lpSupply = depositedLtrbt;
        }
        if (lpSupply <= 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 ltrbtReward = multiplier.mul(ltrbtPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        safeLtrbtTransfer(devaddr, ltrbtReward.div(10));
        safeLtrbtTransfer(address(this), ltrbtReward);
        mintedAmount = mintedAmount.add(ltrbtReward.div(10));
        mintedAmount = mintedAmount.add(ltrbtReward);
        // ltrbt.mint(devaddr, ltrbtReward.div(10));
        // ltrbt.mint(address(this), ltrbtReward);
        pool.accLtrbtPerShare = pool.accLtrbtPerShare.add(ltrbtReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for LTRBT allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        require (_pid != 0, 'deposit LTRBT by staking');

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accLtrbtPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeLtrbtTransfer(msg.sender, pending);
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            if(pool.depositFeeBP > 0){
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                pool.lpToken.safeTransfer(feeAddress, depositFee);
                user.amount = user.amount.add(_amount).sub(depositFee);
            }else{
                user.amount = user.amount.add(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accLtrbtPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        require (_pid != 0, 'withdraw LTRBT by unstaking');

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accLtrbtPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeLtrbtTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accLtrbtPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }
    

        // Stake LTRBT tokens to MasterChef
    function enterStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accLtrbtPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeLtrbtTransfer(msg.sender, pending);
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            depositedLtrbt = depositedLtrbt.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accLtrbtPerShare).div(1e12);
        emit Deposit(msg.sender, 0, _amount);
    }

    // Withdraw LTRBT tokens from STAKING.
    function leaveStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accLtrbtPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeLtrbtTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            depositedLtrbt = depositedLtrbt.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accLtrbtPerShare).div(1e12);
        emit Withdraw(msg.sender, 0, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Safe ltrbt transfer function, just in case if rounding error causes pool to not have enough LTRBTs.
    function safeLtrbtTransfer(address _to, uint256 _amount) internal {
        uint256 ltrbtBal = ltrbt.balanceOf(address(this));
        if (_amount > ltrbtBal) {
            ltrbt.transfer(_to, ltrbtBal);
        } else {
            ltrbt.transfer(_to, _amount);
        }
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    function setFeeAddress(address _feeAddress) public{
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        feeAddress = _feeAddress;
    }

    //Pancake has to add hidden dummy pools inorder to alter the emission, here we make it simple and transparent to all.
    function updateEmissionRate(uint256 _ltrbtPerBlock) public onlyOwner {
        massUpdatePools();
        ltrbtPerBlock = _ltrbtPerBlock;
    }

    function setStartBlock(uint256 _startBlock) public onlyOwner {
        startBlock = _startBlock;

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            if (pool.lastRewardBlock < startBlock) {
                pool.lastRewardBlock = startBlock;
            }
        }
    }
}