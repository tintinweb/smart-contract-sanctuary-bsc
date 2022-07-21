/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// File: @openzeppelin\contracts\utils\Context.sol

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

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// File: @openzeppelin\contracts\utils\Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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

// File: @openzeppelin\contracts\token\ERC20\utils\SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;


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

// File: lib\pancake\IPancakePair.sol

pragma solidity >=0.5.0;

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

// File: lib\pancake\IPancakeRouter01.sol

pragma solidity >=0.6.2;

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

// File: lib\pancake\IPancakeRouter02.sol

pragma solidity >=0.6.2;
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

// File: lib\pancake\IPancakeFactory.sol

pragma solidity >=0.5.0;

interface IPancakeFactory {
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

// File: contracts\ILPAward.sol


pragma solidity >=0.4.22 <0.9.0;


// ｅ
abstract contract ILPAward is Ownable {
  function approveAmountToStake(
        address erc20Address,
        address[] calldata toAddresss_,
        uint256[] calldata values_
    ) public virtual onlyOwner {}

    function increaseAllowanceToStake(
        address erc20Address,
        address[] calldata toAddresss_,
        uint256[] calldata values_
    ) public virtual onlyOwner {}

    // ヨ
    function allowance(
        address erc20Address,
        address owner,
        address spender
    ) public view virtual returns (uint256) {}

   function allowance(
        address erc20Address,
        address spender
    ) public view virtual returns (uint256) {}
}

// File: contracts\LpStake.sol

pragma solidity ^0.8.0;
abstract contract LPStake is Ownable {
    using SafeERC20 for IERC20;

    // 0xF8f6FE7aA9015b88F972527D18aC321550831E2d mainnet
    address public immutable _awardToken; // erc20token
    //0xa4470800821C9AC1c3d85d27AF74BCb01971E47D mainnet
    address public immutable _lpTokenAddress;

    //
    uint256 public lastRewardBlock;
    //sum
    uint256 public _accAwardTokenPerShare;
    // 1041666666666666
    uint256 public _awardTokenPerBlock;
    //
    mapping(address => UserInfo) public userInfos;

    address public _tokenAddr0;
    address public _tokenAddr1;
    address public _swapV2Router; //pancake Router for mainnet
    IPancakeRouter02 private uniswapV2Router02;
    IPancakePair uniswapV2Pair;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    address _lPAwardAddress; // ?

    constructor(
        address swapV2Router,
        address awardToken,
        address lpTokenAddress,
        address lPAwardAddress,
        uint256 awardTokenPerBlock
    ) Ownable() {
        _swapV2Router = swapV2Router;
        _awardToken = awardToken;
        _lPAwardAddress = lPAwardAddress;
        _awardTokenPerBlock = awardTokenPerBlock;
        _lpTokenAddress = lpTokenAddress;
        uniswapV2Router02 = IPancakeRouter02(_swapV2Router);
        uniswapV2Pair = IPancakePair(_lpTokenAddress);
    }

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 reward);

    function update() public {
        uint256 nowBlock = block.number;
        if (nowBlock <= lastRewardBlock) {
            return;
        }
        uint256 lpSupply = IERC20(_lpTokenAddress).balanceOf(address(this));
        if (lpSupply == 0) {
            lastRewardBlock = nowBlock;
            return;
        }
        uint256 awardTokenReward = (nowBlock - lastRewardBlock) *
            _awardTokenPerBlock;
        _accAwardTokenPerShare += (awardTokenReward * 1e12) / lpSupply;
        lastRewardBlock = nowBlock;
    }

    // Deposit LP tokens to Stake for awardToken allocation.
    function deposit(uint256 _amount) public {
        UserInfo storage user = userInfos[msg.sender];
        update();
        if (user.amount > 0) {
            uint256 pending = (user.amount * _accAwardTokenPerShare) /
                1e12 -
                user.rewardDebt;
            withdrawsForAwardToken(msg.sender, pending, true);
        }
        user.amount = user.amount + _amount;
        user.rewardDebt = (user.amount * _accAwardTokenPerShare) / 1e12;
        IERC20(_lpTokenAddress).safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        emit Deposit(msg.sender, _amount);
    }

    // View function to see pending AwardToken on frontend.
    function pendingAwardToken(address _user) external view returns (uint256) {
        UserInfo storage user = userInfos[_user];
        uint256 __accAwardTokenPerShare = _accAwardTokenPerShare;
        uint256 lpSupply = IERC20(_lpTokenAddress).balanceOf(address(this));
        if (block.number > lastRewardBlock && lpSupply != 0) {
            uint256 AwardTokenReward = (block.number - lastRewardBlock) *
                _awardTokenPerBlock;
            __accAwardTokenPerShare += (AwardTokenReward * 1e12) / lpSupply;
        }
        return (user.amount * __accAwardTokenPerShare) / 1e12 - user.rewardDebt;
    }

    //
    function deposit(
        uint256 _amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        IPancakePair(_lpTokenAddress).permit(
            msg.sender,
            address(this),
            _amount,
            deadline,
            v,
            r,
            s
        );
        deposit(_amount);
    }

    // Withdraw LP tokens from Stake.LP?
    function withdraw(uint256 _amount) external {
        UserInfo storage user = userInfos[msg.sender];
        require(user.amount >= _amount, "Stake: not good");
        update();
        uint256 pending = (user.amount * _accAwardTokenPerShare) /
            1e12 -
            user.rewardDebt;
        withdrawsForAwardToken(msg.sender, pending, false);
        user.amount = user.amount - _amount;
        user.rewardDebt = (user.amount * _accAwardTokenPerShare) / 1e12;
        IERC20(_lpTokenAddress).safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _amount);
    }

    //?
    function emergencyWithdraw() external {
        UserInfo storage user = userInfos[msg.sender];
        uint256 _outAmount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        IERC20(_lpTokenAddress).safeTransfer(address(msg.sender), _outAmount);
        emit EmergencyWithdraw(msg.sender, _outAmount);
    }

    //
    function claim() external {
        UserInfo storage user = userInfos[msg.sender];
        require(user.amount > 0, "Stake: no stake");
        update();
        uint256 pending = (user.amount * _accAwardTokenPerShare) /
            1e12 -
            user.rewardDebt;
        withdrawsForAwardToken(msg.sender, pending, true);
        user.rewardDebt = (user.amount * _accAwardTokenPerShare) / 1e12;
        emit Claim(msg.sender, pending);
    }

    function adminTransferOutERC20(address contract_, address recipient_)
        external
        onlyOwner
    {
        require(contract_ != _lpTokenAddress, "Stake: It can't be LP");
        IERC20 erc20Contract = IERC20(contract_);
        uint256 _value = erc20Contract.balanceOf(address(this));
        require(_value > 0, "Stake: no money");
        erc20Contract.safeTransfer(recipient_, _value);
    }

    //(_musttruefalse)
    function withdrawsForAwardToken(
        address _to,
        uint256 _amount,
        bool _must
    ) internal virtual{
        uint256 awardTokenPoolBal = IERC20(_awardToken).allowance(
            _lPAwardAddress,
            address(this)
        );
        require(
            !_must || awardTokenPoolBal >= _amount,
            "Stake: insufficient fund"
        );
        uint256 outAmount = (
            _amount <= awardTokenPoolBal ? _amount : awardTokenPoolBal
        );
        IERC20(_awardToken).transferFrom(_lPAwardAddress, _to, outAmount);
    }
}

// File: contracts\IUserParent2.sol

pragma solidity ^0.8.0;

abstract contract IUserParent2{
    function getParent(address addr) public virtual view  returns (address){}
    function isInNoBurnAddress(address addr) public virtual view  returns (bool){}
    function burn(uint256 amount) public virtual {}
    
}

// File: contracts\LandLpStake2.sol


pragma solidity >=0.4.22 <0.9.0;
contract LandLpStake2 is LPStake {
    using SafeERC20 for IERC20;
    uint256 awardsTotal = 0;
    uint256 _token1AwardLimint; // 
    uint256[10] private newAccountAwards = [
        1000,
        800,
        500,
        300,
        200,
        200,
        200,
        100,
        100,
        100
    ]; // 1W

    constructor(
        address swapV2Router,
        address awardToken, // 
        address lpTokenAddress,
        address lPAwardAddress,
        uint256 awardTokenPerBlock,
        uint256 token1AwardLimint
    )
        LPStake(
            swapV2Router,
            awardToken,
            lpTokenAddress,
            lPAwardAddress,
            awardTokenPerBlock
        )
    {
        for (uint256 index = 0; index < newAccountAwards.length; index++) {
            awardsTotal = awardsTotal + newAccountAwards[index];
        }
        _token1AwardLimint = token1AwardLimint;
    }

    function getToken1Value(address addr) public view returns (uint256) {
        if (uniswapV2Pair.totalSupply() == 0) {
            return 0;
        }
        address token1 = uniswapV2Pair.token1();
        if (_awardToken == token1) {
            token1 = uniswapV2Pair.token0();
        }
        uint256 balanceOfToken1 = IERC20(token1).balanceOf(_lpTokenAddress);
        if (balanceOfToken1 == 0) {
            return 0;
        }
        return
            (userInfos[addr].amount * balanceOfToken1) /
            uniswapV2Pair.totalSupply();
    }

    //(_musttruefalse)
    function withdrawsForAwardToken(
        address _to,
        uint256 _amount,
        bool _must
    ) internal override {
        uint256 awardTokenPoolBal = IERC20(_awardToken).allowance(
            _lPAwardAddress,
            address(this)
        );
        require(
            !_must || awardTokenPoolBal >= _amount,
            "Stake: insufficient fund"
        );
        uint256 outAmount = (
            _amount <= awardTokenPoolBal ? _amount : awardTokenPoolBal
        );

        IERC20(_awardToken).transferFrom(
            _lPAwardAddress,
            address(this),
            outAmount
        ); //

        // 
        if (IUserParent2(_awardToken).isInNoBurnAddress(_to)) {
            IERC20(_awardToken).transfer(_to, outAmount);
            return;
        }
        uint256 awardAmount = (outAmount * awardsTotal) / 10000;

        address parentAddress = IUserParent2(_awardToken).getParent(_to);
        if (parentAddress == address(0)) {
            IUserParent2(_awardToken).burn(awardAmount);
        } else {
            uint256 burnAmount = awardAmount;
            for (uint256 index = 0; index < newAccountAwards.length; index++) {
                uint256 singleAwardAmount = (outAmount *
                    newAccountAwards[index]) / 10000;
                if (getToken1Value(parentAddress) >= _token1AwardLimint) {
                    // 
                    burnAmount = burnAmount - singleAwardAmount;
                    IERC20(_awardToken).transfer(
                        parentAddress,
                        singleAwardAmount
                    );
                }
                parentAddress = IUserParent2(_awardToken).getParent(
                    parentAddress
                );
                if (parentAddress == address(0)) {
                    break;
                }
            }
            if (burnAmount > 0) {
                IUserParent2(_awardToken).burn(burnAmount);
            }
        }
        IERC20(_awardToken).transfer(_to, outAmount - awardAmount);
    }
}