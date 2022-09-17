/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

library LaunchPadStorage {
    enum RefundType {Burn, Refund}
    enum WhitelistType {
        NoWhitelist, // 不使用白名单
        UseWhitelist // 使用白名单
    }
    enum State {Upcoming, Inprogress, Ended, Cancelled, Failed}

    struct PoolStates {
        State state;
        uint256 finishTime;
        uint256 totalRaised;
        uint256 totalVolumePurchased;
        uint256 publicSaleStartTime;
        uint256 liquidityUnlockTime;
        uint256 totalVestedTokens;
        uint256 lockId;
        string poolDetails;
        bool completedKyc;
        string kycDetails;
        bool completedAudit;
        string auditDetails;
    }

    struct PoolSettings {
        address token;
        address currency;
        uint256 startTime;
        uint256 endTime;
        uint256 rate;
        uint256[2] contributionSetting;
        uint256 softCap;
        uint256 hardCap;
        uint256 liquidityListingRate;
        uint256 liquidityLockDays;
        uint256 liquidityPercent;
        uint256 ethFeePercent;
        uint256 tokenFeePercent;
        uint256 tokensForLiquidity;
    }

    struct OwnerVestingSettings {
        uint256 totalVestingTokens; //总的待释放数量
        uint256 tgeLockDuration; //结束launchpad后锁定时间 s
        uint256 cycle; //第一轮释放以后，每轮间隔时间 s
        uint256 tgeReleaseTokens; //第一轮释放的数量
        uint256 cycleReleaseTokens; //后面每轮释放的数量
        uint256 tokensFeeAmount;
    }
    //1000 300 60 500 200
    //借宿launchpad后过300秒，释放500token，
    //第一轮 500
    //第二轮 700
    //第三轮 900
    //第四轮 1000

    struct ContributorVestingSettings {
        uint256 tgeReleasePct;
        uint256 cycleReleasePct;
        uint256 cycle;
    }
}


interface ILaunchPadPool {
  
  function initialize(
    LaunchPadStorage.PoolSettings memory _poolSettings,
    address _router,
    address _owner,
    address _whiteList,
    uint256 _publicSaleStartTime,
    uint8 _whiteListType,
    uint8 _refundType,
    string memory _poolDetails
  ) external;

  function initializeContributorVesting(
    LaunchPadStorage.ContributorVestingSettings memory _contributorVestingSettings
  ) external;

  function initializeOwnerVesting(
    LaunchPadStorage.OwnerVestingSettings memory _ownerVestingSettings
  ) external;

  function cancel() external;

  function claim() external;

  function contribute() payable external;

  function contribute(uint256 _amount) external;

  function finalize() external;

  function version() external view returns(uint8);

  function getPoolStatus() external view returns(uint8);

}


interface ILaunchPadFactory {

    function createPool(
        address _owner,
        address _router,
        LaunchPadStorage.PoolSettings memory _poolSettings,
        LaunchPadStorage.OwnerVestingSettings memory _ownerVestingSettings,
        LaunchPadStorage.ContributorVestingSettings memory _contributorVestingSettings,
        uint256 _publicSaleStartTime,
        uint8 _whiteListType,
        uint8 _refundType,
        string memory _poolDetails
    ) external payable returns(address pool);

    function feeTo() external view returns(address);

    function manager() external view returns(address);

    function recordContribution(address user, address pool) external;

    function governance() external view returns(address);

    function pinkLock() external view returns(address);

    function whiteUserToken() external view returns(address);

    function whiteUserPrice() external view returns(uint256);
  
}


interface IUniswapV2Factory {
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


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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


interface IWhiteList {

  function initialize(address _manager, address _pool) external;

  function setSelledMaxCount(uint256 _max) external;

  function sellWhiteUser(address user) external;

  function addWhitelistedUser(address user) external;
    
  function removeWhitelistedUser(address user) external;

  function setWhitelistedUsers(address[] memory users, bool add) external;

  function isUserWhitelisted(address user) external returns (bool);
  
}


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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


// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol
// Subject to the MIT license.
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

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }
}


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)
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


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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


// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)
/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)
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


contract LaunchPadPool is ILaunchPadPool, ReentrancyGuard, Ownable {
  using EnumerableSet for EnumerableSet.AddressSet;
  using EnumerableSet for EnumerableSet.UintSet;
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  uint8 private constant VERSION = 1;
  uint256 private constant PENALTYRATE = 10;

  IWhiteList public whiteList;
  ILaunchPadFactory public factory; 
  IUniswapV2Router02 public router;
  address private weth;
  address private pair;
  uint8 private decimalsToken;

  LaunchPadStorage.ContributorVestingSettings public contributorVestingSettings;
  LaunchPadStorage.OwnerVestingSettings public ownerVestingSettings;
  LaunchPadStorage.PoolSettings public poolSettings;
  LaunchPadStorage.PoolStates public poolStates;
  LaunchPadStorage.RefundType public refundType; 
  LaunchPadStorage.WhitelistType public whiteListType; 

  EnumerableSet.AddressSet private contributors;
  mapping(address => uint256) public claimedOf;      // token
  mapping(address => uint256) public contributionOf; // bnb
  mapping(address => uint256) public refundedOf;     // bnb

  // uint256 public totalClaimed;

  // uint256 public liquidityBalance; 
  // uint256 public minimumLockTime;

  bool private hasOwnerVesting = false;
  uint256 private ownerVestingCycleCount;
  bool private hasContributorVesting = false;
  uint256 private contributorVestingCycleCount;

  event Claimed(address indexed user, uint256 volum, uint256 total);
  event Contributed(address indexed user, address currency, uint256 amount, uint256 volume, uint256 totalVolume);
  event Cancelled(uint256 timestamp);
  event Finalized(address pair, uint256 liquidity, uint256 timestamp);
  event KycUpdated(string kycDetails,uint256 timestamp);
  event AuditUpdated(bool completed,uint256 timestamp);
  event PoolUpdated(uint256 timestamp);
  event LiquidityWithdrawn(uint256 amount, uint256 timestamp);
  event VestingTokenWithdrawn(uint256 amount, uint256 timestamp);
  event WithdrawnContribution(address indexed user, uint256 amount);
  event EmergencyWithdrawContribution(address indexed user,address currency, uint256 amount, uint256 totalRaised);
  event BuyWhiteUser(address indexed user);

  modifier _onlyFactory() {
    require(address(factory) == msg.sender, "Not factory!");
    _;
  }

  modifier _onlyGovernance() {
    require(address(factory.governance()) == msg.sender, "Not governance!");
    _;
  }

  modifier _pooIsOngoing() {
    require(poolStates.state == LaunchPadStorage.State.Upcoming, "pool not Inprogress status");
    require(poolSettings.startTime < block.timestamp, "Pool not started yet!");
    require(poolSettings.endTime > block.timestamp, "pool endDate passed!");
    _;
  }

  modifier _isFinalize() {
    require(poolStates.state == LaunchPadStorage.State.Ended, "pool not end");
    _;
  }

  modifier _depositMinandMax(
    address _sender,
    uint256 _amount
  ) {
    uint256 amountParticipated = contributionOf[_sender];
    uint256 be = amountParticipated.add(_amount);
    require(poolSettings.contributionSetting[0] <= be, "need over min");
    require(poolSettings.contributionSetting[1] >= be, "need less max");
    _;
  }

  modifier _hardCapNotPassed(uint256 _amount) {
    uint256 _beforeBalance = poolStates.totalRaised;

    uint256 sum = poolStates.totalRaised.add(_amount);
    require(sum <= poolSettings.hardCap, "hardCap reached!");
    assert(sum > _beforeBalance);
    _;
  }

  constructor() {}

  receive() external payable {
    revert("Call contribute()");
  }

  function initialize(
    LaunchPadStorage.PoolSettings memory _poolSettings,
    address _router,
    address _owner,
    address _whiteList,
    uint256 _publicSaleStartTime,
    uint8 _whiteListType,
    uint8 _refundType,
    string memory _poolDetails
  ) external override {
    //todo 需要增加require
    require(poolStates.publicSaleStartTime == 0, "initialized");
    require(_publicSaleStartTime > block.timestamp, "publicSaleStartTime config err");

    poolSettings = _poolSettings;

    poolStates.publicSaleStartTime = _publicSaleStartTime;
    poolStates.finishTime = _poolSettings.endTime;
    poolStates.state = LaunchPadStorage.State.Upcoming;
    poolStates.poolDetails = _poolDetails;

    super._transferOwnership(_owner);

    router = IUniswapV2Router02(_router);
    weth = router.WETH();
    pair = IUniswapV2Factory(router.factory()).getPair(poolSettings.token, poolSettings.currency);
    if(pair == address(0)) {
      pair = IUniswapV2Factory(router.factory()).createPair(poolSettings.token, poolSettings.currency);
    }
    decimalsToken = IERC20(poolSettings.token).decimals();

    factory = ILaunchPadFactory(msg.sender);

    whiteList = IWhiteList(_whiteList);
    whiteList.initialize(_owner, address(this));
    whiteListType = LaunchPadStorage.WhitelistType(_whiteListType);
    refundType = LaunchPadStorage.RefundType(_refundType);
  }

  function initializeContributorVesting(
    LaunchPadStorage.ContributorVestingSettings memory _contributorVestingSettings
  ) external override _onlyFactory {
    if (_contributorVestingSettings.tgeReleasePct > 0 || 
      _contributorVestingSettings.cycleReleasePct >0) {

      hasContributorVesting = true;
      contributorVestingSettings = _contributorVestingSettings;
      contributorVestingCycleCount = (100 - contributorVestingSettings.tgeReleasePct)
                                     .divCeil(contributorVestingSettings.cycleReleasePct);
    }
  }

  function initializeOwnerVesting(
    LaunchPadStorage.OwnerVestingSettings memory _ownerVestingSettings
  ) external override _onlyFactory {

    if(_ownerVestingSettings.totalVestingTokens > 0) {

      hasOwnerVesting = true;
      ownerVestingSettings = _ownerVestingSettings;
      ownerVestingCycleCount = ownerVestingSettings.totalVestingTokens.sub(ownerVestingSettings.tgeReleaseTokens)
                               .divCeil(ownerVestingSettings.cycleReleaseTokens);
    }
  }

  function cancel() external override onlyOwner {
    require(poolStates.state  != LaunchPadStorage.State.Ended, "pool ended");
    poolStates.state  = LaunchPadStorage.State.Cancelled;
    emit Cancelled(block.timestamp);
  }

  function finalize() external override onlyOwner {
    require(poolStates.totalRaised >= poolSettings.softCap, "softCap not pass");
    // 达到hardcap就允许结束launchpad
    if(poolStates.totalRaised < poolSettings.hardCap) {
      require(block.timestamp > poolSettings.endTime, "pool not end!");
    }

    poolStates.state  = LaunchPadStorage.State.Ended;
    poolStates.finishTime = block.timestamp;

    // 付费 token
    uint256 tokenFee = poolStates.totalVolumePurchased.mul(poolSettings.tokenFeePercent).div(100);

    IERC20(poolSettings.token).transfer(factory.feeTo(), tokenFee);
    // 付费 bnb
    uint256 currencyFee = poolStates.totalRaised.mul(poolSettings.ethFeePercent).div(100);
    if(poolSettings.currency == weth) {
      payable(factory.feeTo()).transfer(currencyFee);
    } else {
      IERC20(poolSettings.currency).transfer(factory.feeTo(), currencyFee);
    }

    uint256 actualCurrencyAmount = poolStates.totalRaised.sub(currencyFee);

    uint256 lpCurrencyAmount = actualCurrencyAmount.mul(poolSettings.liquidityPercent).div(100);
    uint256 lpTokenAmount = lpCurrencyAmount.mul(poolSettings.liquidityListingRate)
                            .mul(10**decimalsToken)
                            .div(10**18);
    uint256 liquidity = addLiquidity(lpTokenAmount, lpCurrencyAmount);

    // 将剩下的募集到的bnb转给项目方
    uint256 projectAmount = actualCurrencyAmount.sub(lpCurrencyAmount);
    if(poolSettings.currency == weth) {
      payable(msg.sender).transfer(projectAmount);
    } else {
      IERC20(poolSettings.currency).transfer(msg.sender, projectAmount);
    }

    // 处理多余的token
    refundToken();

    emit Finalized(pair, liquidity, block.timestamp);
  }


  function refundToken() internal {
    // 未到达硬顶
    if(poolStates.totalRaised < poolSettings.hardCap) {
      
      uint256 _restCap = poolSettings.hardCap.sub(poolStates.totalRaised);
      //uint256 _refundAmount = _restCap.mul(poolSettings.rate).mul(10**decimalsToken).div(10**18);
      uint256 _refundSaleAmount = _restCap.mul(poolSettings.rate).mul(10**decimalsToken).div(10**18);
      //预售得到的总额减去平台费用
      uint256 currencyFee = poolStates.totalRaised.mul(poolSettings.ethFeePercent).div(100);
      uint256 actualCurrencyAmount = poolStates.totalRaised.sub(currencyFee);
      //实际注入流动池的数量
      uint256 lpCurrencyAmount = actualCurrencyAmount.mul(poolSettings.liquidityPercent).div(100);
      uint256 lpTokenAmount = lpCurrencyAmount.mul(poolSettings.liquidityListingRate).mul(10**decimalsToken).div(10**18);

      //创建预售达到硬顶预估的LP货币数量tokensForLiquidity
     // uint256 SalecurrencyFee = poolSettings.hardCap.mul(poolSettings.ethFeePercent).div(100);
     // uint256 SaleCurrency = poolSettings.hardCap.sub(SalecurrencyFee);
     // uint256 lpSaleCurrency = SaleCurrency.mul(poolSettings.liquidityPercent).div(100);
     // uint256 SaleLpAmount = lpSaleCurrency.mul(poolSettings.liquidityListingRate).mul(10**decimalsToken).div(10**18);
     // uint256 _refundLpAmount = SaleLpAmount.sub(lpTokenAmount);

      uint256 _refundLpAmount = poolSettings.tokensForLiquidity.sub(lpTokenAmount);

      uint256 _refundAmount = _refundLpAmount.add(_refundSaleAmount);

      if(refundType == LaunchPadStorage.RefundType.Burn) {
        IERC20(poolSettings.token).transfer(address(0x000000000000000000000000000000000000dEaD), _refundAmount);
      } else {
        IERC20(poolSettings.token).transfer(owner(), _refundAmount);
      }
    }
  }


  function setUseWhiteList(uint8 _whiteListType) public onlyOwner {
    whiteListType = LaunchPadStorage.WhitelistType(_whiteListType);
  }

  function setRefundType(uint8 _refundType) public onlyOwner {
    refundType = LaunchPadStorage.RefundType(_refundType);
  }

  function checkWhiteUser(address _user) internal {
    if(whiteListType == LaunchPadStorage.WhitelistType.UseWhitelist) {
      if(!whiteList.isUserWhitelisted(_user)) {
        require(block.timestamp > poolStates.publicSaleStartTime, "not public sale");
      }
    }
  }

  function contribute() 
  payable 
  external 
  override
  nonReentrant 
  _pooIsOngoing 
  _depositMinandMax(msg.sender, msg.value)
  _hardCapNotPassed(msg.value)
  {
    uint256 _amount = msg.value;
    address _sender = msg.sender;
    require(_amount > 0, "No WEI found!");
    checkWhiteUser(_sender);

    poolStates.totalRaised = poolStates.totalRaised.add(_amount);
    poolStates.totalVolumePurchased += _amount.mul(poolSettings.rate).mul(10**decimalsToken).div(10**18);

    if(contributors.contains(_sender)) {
      contributionOf[_sender] = contributionOf[_sender].add(_amount);
    } else {
      contributors.add(_sender);
      contributionOf[_sender] = _amount;
      factory.recordContribution(_sender, address(this));
    }

    emit Contributed(_sender, poolSettings.currency, _amount, contributionOf[_sender], block.timestamp);
  }

  // 使用稳定币作为currency
  function contribute(uint256 _amount) 
  external
  override
  nonReentrant 
  _pooIsOngoing 
  _depositMinandMax(msg.sender, _amount)
  _hardCapNotPassed(_amount)
  {
    address _sender = msg.sender;
    require(_amount > 0, "No WEI found!");
    checkWhiteUser(_sender);

    safeTransferFromEnsureExactAmount(poolSettings.currency, _sender, address(this), _amount);
    poolStates.totalRaised = poolStates.totalRaised.add(_amount);
    poolStates.totalVolumePurchased += _amount.mul(poolSettings.rate).mul(10**decimalsToken).div(10**18);

    if(contributors.contains(_sender)) {
      contributionOf[_sender] = contributionOf[_sender].add(_amount);
    } else {
      contributors.add(_sender);
      contributionOf[_sender] = _amount;
      factory.recordContribution(_sender, address(this));
    }

    emit Contributed(_sender, poolSettings.currency, _amount, contributionOf[_sender], block.timestamp);
  }

  function claim() external override nonReentrant _isFinalize {
    uint256 withdrawableAmountByNow = withdrawableContributorVestingTokens(msg.sender);
    require(withdrawableAmountByNow > 0, "No withdrawable by now");
    claimedOf[msg.sender] = claimedOf[msg.sender].add(withdrawableAmountByNow);
    IERC20(poolSettings.token).transfer(msg.sender, withdrawableAmountByNow);

    emit Claimed(msg.sender, withdrawableAmountByNow, withdrawableAmountByNow);
  }

  function withdrawableContributorVestingTokens(address user) 
  public view returns(uint256) {
    uint256 allAmount = withdrawableTokens(user);
    if(allAmount == 0){
      return 0;
    }

    uint256 withdrawableAmount = allAmount;
    // 有vesting period
    if(hasContributorVesting) {
      withdrawableAmount = allAmount.mul(contributorVestingSettings.tgeReleasePct).div(100);

      uint256 cycleDuration = block.timestamp.sub(poolStates.finishTime);
      uint256 count = cycleDuration.div(contributorVestingSettings.cycle);
      if(count > contributorVestingCycleCount) {
        withdrawableAmount = allAmount;
      } else if(count > 0) {
        uint256 cyclePcts = count.mul(contributorVestingSettings.cycleReleasePct);
        withdrawableAmount += allAmount.mul(cyclePcts);
      }

      if(withdrawableAmount > allAmount) {
        withdrawableAmount = allAmount;
      }
    }

    uint256 withdrawableAmountByNow = withdrawableAmount.sub(claimedOf[user]);
    return withdrawableAmountByNow;
  }

  function withdrawableTokens(address user) public view returns(uint256) {
    if (poolStates.state  != LaunchPadStorage.State.Ended) {
      return 0;
    }
    if (contributionOf[user] == 0) {
      return 0;
    }
    uint256 amount = contributionOf[user].mul(poolSettings.rate)
                    .mul(10**decimalsToken).div(10**18);
    return amount;
  }

  function distributeRefund(uint256 start, uint256 end) external onlyOwner {
    require(poolStates.state  == LaunchPadStorage.State.Cancelled, "not cancelled");
    require(start <= end, "index err");

    if (end >= contributors.length()) {
      end = contributors.length() - 1;
    }

    for(uint256 i = start; i < end; i++) {

      address user = contributors.at(i);
      refundedOf[user] = contributionOf[user] - refundedOf[user];
      if(refundedOf[user] > 0) {
        if(poolSettings.currency == weth) {
          payable(user).transfer(refundedOf[user]);
        } else {
          IERC20(poolSettings.currency).transfer(user, refundedOf[user]);
        }
      }

    }

  }

  function distributionCompleted(uint8 distributedType) external view returns(bool) {

  }

  // function getContributionAmount(address user_) external view returns(uint256, uint256) {

  // }

  function getContributionSettings() external view returns(uint256 min, uint256 max) {
    return (poolSettings.contributionSetting[0], poolSettings.contributionSetting[1]);
  }

  function getFeeSettings() external view returns(uint256 currency, uint256 token) {
    return (poolSettings.ethFeePercent, poolSettings.tokenFeePercent);

  }

  // function getUndistributedIndexes(uint8 distributedType) external view returns(uint256[] memory) {

  // }

  // function recover(address to_, uint256 amount_) external {

  // }

  function setPublicSaleStartTime(uint256 _publicSaleStartTime) external onlyOwner {
    poolStates.publicSaleStartTime = _publicSaleStartTime;
  }

  // function setupHoldToken(address _token, uint8 _minAmount) external onlyOwner {

  // }

  // function tokenHoldSettings() external view returns(address token, uint256 amount) {

  // }

  function getPoolStatus() external view override returns(uint8) {
    return uint8(poolStates.state);
  }

  function updateCompletedAudit(bool completed_) external _onlyGovernance {
    poolStates.completedAudit = completed_;
    emit AuditUpdated(poolStates.completedAudit, block.timestamp);
  }

  function updateAuditDetails(string memory auditDetails_) external _onlyGovernance {
    poolStates.auditDetails = auditDetails_;
    emit AuditUpdated(true, block.timestamp);
  }

  function updateCompletedKyc(bool completed_) external _onlyGovernance {
    poolStates.completedKyc = completed_;
  }

  function updateKycDetails(string memory kycDetails_) external _onlyGovernance { 
    poolStates.kycDetails = kycDetails_;
    emit KycUpdated(poolStates.kycDetails, block.timestamp);
  }

  function updatePoolDetails(string memory details_) external onlyOwner { 
    poolStates.poolDetails = details_;
    emit PoolUpdated(block.timestamp);
  }


  function emergencyWithdraw(
    address payable to_, 
    uint256 amount_
  ) external _onlyGovernance {
    uint256 amount = address(this).balance;
    if(amount_ > amount){
      amount_ = amount;
    }
    to_.transfer(amount_);
  }

  function emergencyWithdrawToken(
    address token_,
    address to_, 
    uint256 amount_
  ) external _onlyGovernance {
    uint256 poolAmount = IERC20(token_).balanceOf(address(this));
    if(amount_ > poolAmount){
      amount_ = poolAmount;
    }
    IERC20(token_).transfer(to_, amount_);
  }

  function emergencyWithdraw(
    address to_, 
    address token_
  ) public _onlyGovernance {
    uint256 poolAmount = IERC20(token_).balanceOf(address(this));
    IERC20(token_).transfer(to_, poolAmount);
  }

  // owner 取消launchpad后取回token
  function withdrawCancelledTokens() external onlyOwner {
    require(poolStates.state == LaunchPadStorage.State.Cancelled, "not cancelled");
    uint256 poolAmount = IERC20(poolSettings.token).balanceOf(address(this));
    IERC20(poolSettings.token).transfer(msg.sender, poolAmount);
  }

  // 用户参与的bnb 未结束之前提回，扣除10%的bnb,扣除的罚款转到feeTo
  function withdrawContribution() external {
    require(poolStates.state != LaunchPadStorage.State.Ended, "pool finanlized");

    uint256 _amount = contributionOf[msg.sender];
    require(_amount > 0, "No contribution");
    contributionOf[msg.sender] = 0;
    // contributors.remove(msg.sender);
    poolStates.totalRaised =  poolStates.totalRaised.sub(_amount);
    poolStates.totalVolumePurchased -= _amount.mul(poolSettings.rate).mul(10**decimalsToken).div(10**18);

    if(block.timestamp < poolSettings.endTime && 
       poolStates.state != LaunchPadStorage.State.Cancelled) { // 未结束 扣除10%
      uint256 punishment = _amount.mul(PENALTYRATE).div(100);
      uint256 amount = _amount.sub(punishment);
      if(poolSettings.currency == weth) {
        payable(factory.feeTo()).transfer(punishment);
        payable(msg.sender).transfer(amount);
      } else {
        IERC20(poolSettings.currency).transfer(factory.feeTo(), punishment);
        IERC20(poolSettings.currency).transfer(msg.sender, amount);
      }
      // contributors.remove(msg.sender);
      emit WithdrawnContribution(msg.sender, amount);
    } else {
      //时间到后,需要取消了且未达到软顶才能提现
      if(poolStates.state != LaunchPadStorage.State.Cancelled) {
        require(poolStates.totalRaised < poolSettings.softCap, "wait to finalize!!!");
      }

      if(poolSettings.currency == weth) {
        payable(msg.sender).transfer(_amount);
      } else {
        IERC20(poolSettings.currency).transfer(msg.sender, _amount);
      }
      emit WithdrawnContribution(msg.sender, _amount);
    }

  }

  function withdrawCurrency() 
  external 
  onlyOwner
  _isFinalize  
  {
    if(poolSettings.currency == weth) {
      uint256 _ethAmount = address(this).balance;
      payable(msg.sender).transfer(_ethAmount);
    } else {
      uint256 _tokenAmount = IERC20(poolSettings.currency).balanceOf(address(this));
      IERC20(poolSettings.currency).transfer(msg.sender, _tokenAmount);
    }

  }

  function withdrawLiquidity() external _isFinalize onlyOwner {
    //LP 解锁后 提取LP
    uint256 duration = block.timestamp.sub(poolStates.finishTime);
    require(duration > poolSettings.liquidityLockDays, "liquidityLockDays err");
    uint256 _amount = IERC20(pair).balanceOf(address(this));
    require(_amount > 0, "liquidity is zero");
    IERC20(pair).transfer(msg.sender, _amount);
    emit LiquidityWithdrawn(_amount, block.timestamp);
  }

  function withdrawVestingToken() 
    external 
    _isFinalize 
    onlyOwner 
  {
    uint256 withdrawableAmounts = withdrawableVestingToken();
    if(withdrawableAmounts > 0) {
      poolStates.totalVestedTokens = poolStates.totalVestedTokens.add(withdrawableAmounts);
      IERC20(poolSettings.token).transfer(msg.sender, withdrawableAmounts);

      emit VestingTokenWithdrawn(withdrawableAmounts, block.timestamp);
    }
  }

  function withdrawableVestingToken() public view returns(uint256) {
    if(poolStates.state != LaunchPadStorage.State.Ended) {
      return 0;
    }
    if(!hasOwnerVesting) {
      return 0;
    }

    uint256 claimableVestingAmount = 0;  
    uint256 duration = block.timestamp.sub(poolStates.finishTime);
    if(duration <= ownerVestingSettings.tgeLockDuration) {
      return 0;
    }
    claimableVestingAmount = claimableVestingAmount.add(ownerVestingSettings.tgeReleaseTokens); // 第一次释放的token

    uint256 cycleDuration = duration.sub(ownerVestingSettings.tgeLockDuration);
    uint256 count = cycleDuration.div(ownerVestingSettings.cycle);
    if(count > ownerVestingCycleCount) {
      claimableVestingAmount = ownerVestingSettings.totalVestingTokens; // 所有的team vesting token
    } else if(count > 0) {
      uint256 cycleAmounts = count.mul(ownerVestingSettings.cycleReleaseTokens);
      claimableVestingAmount = claimableVestingAmount.add(cycleAmounts);
    }

    if(claimableVestingAmount > ownerVestingSettings.totalVestingTokens) {
      claimableVestingAmount = ownerVestingSettings.totalVestingTokens;
    }

    uint256 claimableVestingAmountByNow = claimableVestingAmount.sub(poolStates.totalVestedTokens);
    return claimableVestingAmountByNow;
  }

  function version() external pure override returns(uint8){
      return VERSION;
  }

  function safeTransferFromEnsureExactAmount(
    address _token,
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    uint256 oldRecipientBalance = IERC20(_token).balanceOf(recipient);
    IERC20(_token).safeTransferFrom(sender, recipient, amount);
    uint256 newRecipientBalance = IERC20(_token).balanceOf(recipient);
    require(
      newRecipientBalance - oldRecipientBalance == amount,
      "Not enough token was transfered"
    );
  }

  function addLiquidity(
    uint256 tokenAmount, 
    uint256 currencyAmount
  ) private returns(uint256 liquidity) {
    // approve token transfer to cover all possible scenarios
    IERC20(poolSettings.token).approve(address(router), tokenAmount);

    // add the liquidity
    if(poolSettings.currency == weth) {
      ( , , liquidity ) = router.addLiquidityETH{value: currencyAmount}(
          poolSettings.token,
          tokenAmount,
          0, // slippage is unavoidable
          0, // slippage is unavoidable
          address(this),
          block.timestamp
      );
    } else {
      // approve currency transfer to cover all possible scenarios
      IERC20(poolSettings.currency).approve(address(router), currencyAmount);

      ( , , liquidity ) = router.addLiquidity(
          poolSettings.token,
          poolSettings.currency,
          tokenAmount,
          currencyAmount,
          0, // slippage is unavoidable
          0, // slippage is unavoidable
          address(this),
          block.timestamp
      );
    }

  }

  function getContributorCount() public view returns(uint256) {
    return contributors.length();
  }

  function getContributors(uint256 start, uint256 end) 
  external view returns(address[] memory, uint256[] memory) {
    if (end >= contributors.length()) {
      end = contributors.length() - 1;
    }
    uint256 length = end - start + 1;
    address[] memory users = new address[](length);
    uint256[] memory amounts = new uint256[](length);
    uint256 currentIndex = 0;
    for (uint256 i = start; i <= end; i++) {
      address user = contributors.at(i);
      users[currentIndex] = user;
      amounts[currentIndex] = contributionOf[user];
      currentIndex++;
    }
    return (users, amounts);
  }

  function setWhiteUserMaxCount(uint256 _max) external _onlyGovernance {
    whiteList.setSelledMaxCount(_max);
  }

  // 用户用平台币购买白名单，不能取消，平台币转给平台；买了以后，白名单不能被项目方取消，
  function buyWhiteUserByToken() external {
    address _whiteUserToken = factory.whiteUserToken();
    uint256 _amount = factory.whiteUserPrice();
    require(_whiteUserToken != address(0), "token not set");
    require(_amount > 0, "white user price not set");

    IERC20(_whiteUserToken).safeTransferFrom(msg.sender, factory.governance(), _amount);
    whiteList.sellWhiteUser(msg.sender);
    emit BuyWhiteUser(msg.sender);
  }

}