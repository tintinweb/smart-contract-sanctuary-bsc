/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

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
/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

library Constants {

  /*
   * Common settings
   */
  uint256 internal constant PERCENT_PRECISION = 1e4;
  uint256 public constant ADMIN_FEE_PERCENT = 10_00; // 10%

  /*
   * Planets
   */
  uint8 public constant PLANET_LEVELS_NUMBER = 50;
  uint8 public constant NEXT_PLANET_THRESHOLD = 30;

  /*
   * Game
   */
  uint256 public constant BUY_ENERGY_MIN_VALUE = 0.004 ether;
  uint256 public constant TOKENS_WITHDRAW_LIMIT = 150_00; // 150 %

  uint256 public constant ENERGY_FOR_BNB = 2_500_000;
  uint256 public constant ENERGY_FOR_CRYSTAL = 110_00; // 110%

  /*
   * NFT sell
   */
  uint256 public constant NFT_PRICE = 0.1 ether;
  uint256 public constant NFT_MAX_SUPPLY = 10_000;

}
library GameModels {

  uint8 public constant REF_LEVELS_NUMBER = 7;

  struct Player {
    address referrer;
    address[] referrals;
    uint256[REF_LEVELS_NUMBER] referralsNumber;
    uint256 turnover;
    uint256[REF_LEVELS_NUMBER] turnoverLines;

    uint256 invested;
    uint256 referralRewardFromBuyEnergy;
    uint256 referralRewardFromExchange;
    uint256 withdrawn;
    uint256 withdrawnCrystals;
    uint256[2][REF_LEVELS_NUMBER] referralRewards;

    // Achievements
    uint256 xp;
    uint8 level;
  }

  struct PlayerBalance {
    uint256 energy;
    uint256 crystals;

    uint256 lastCollectionTime;
    uint256 lastRocketPushTime;
  }

}

interface IPancakeRouter {
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

interface ICommonInterface {

  // ERC-20

  function mint(address to, uint256 amount) external;

  function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

  // ERC-721

  function ownerOf(uint256 tokenId) external view returns (address);

  function safeTransferFrom(address from, address to, uint256 tokenId) external;

  // Character NFT

  function level(uint256 tokenId) external view returns (uint8);

  function markAsUsed(address playerAddr, uint256 tokenId) external;

  function upgrade(address playerAddr, uint256 tokenId, uint8 toLevel) external;

  function BNB_RECEIVER_ADDRESS() external returns (address);

}

library Events {

  event Registration(
    address indexed playerAddr,
    address indexed referrerAddr,
    uint256 registrationNumber,
    uint256 timestamp
  );

  event BuyEnergy(
    address indexed playerAddr,
    uint256 bnbAmount,
    uint256 timestamp
  );

  event ExchangeCrystals(
    address indexed playerAddr,
    uint256 crystals,
    uint256 timestamp
  );

  event ReferralReward(
    address indexed receiverAddr,
    address indexed payerAddr,
    uint256 rewardAmount, // SGT tokens or Energy amount
    uint256 bnbAmount,
    uint8 rewardType, // 0 - from buy energy, 1 - from crystals exchange
    uint256 timestamp
  );

  event UpgradePlanet(
    address indexed playerAddr,
    uint8 indexed planetIdx,
    uint8 boughtLevels,
    uint8 resultLevel,
    uint256 timestamp
  );

  event AttachCharacter(
    address indexed playerAddr,
    uint256 tokenId,
    uint256 timestamp
  );

  event DetachCharacter(
    address indexed playerAddr,
    uint256 tokenId,
    uint256 timestamp
  );

  event UpgradeCharacter(
    address indexed playerAddr,
    uint256 indexed chracterTokenId,
    uint8 toLevel
  );

  event RatingUpdate(
    address indexed playerAddr,
    uint256 rating,
    uint256 timestamp
  );

  event CollectResources(
    address indexed playerAddr,
    uint256 energy,
    uint256 crystals,
    uint256 timestamp
  );

  event WithdrawCrystals(
    address indexed playerAddr,
    uint256 crystals,
    uint256 bnbValue,
    uint256 timestamp
  );

  event PushRocket(
    address indexed playerAddr,
    uint256 timestamp
  );

  event GetETHDust(
    uint256 amount
  );

  event CollectAchievementReward(
    address indexed playerAddr,
    uint8 indexed level,
    uint256 timestamp
  );

}

contract SpaceGame is Ownable, IERC721Receiver { //TODO: rename contract

  using SafeERC20 for IERC20;

  uint8 public constant PLANETS_NUMBER = 8;
  uint256[PLANETS_NUMBER] public PLANET_LEVEL_PRICE = [
    1_0 ether,
    2_7 ether,
    7_5 ether,
    20_0 ether,
    55_0 ether,
    145_0 ether,
    400_0 ether,
    1_000_0 ether
  ];

  uint8 public constant ACHIEVEMENTS_NUMBER = 12;
  uint256[ACHIEVEMENTS_NUMBER] public ACHIEVEMENTS_XP = [
    0,
    50_000,
    200_000,
    500_000,
    1_350_000,
    3_225_000,
    5_725_000,
    8_850_000,
    12_725_000,
    23_500_000,
    45_000_000,
    80_000_000
  ];

  uint256[ACHIEVEMENTS_NUMBER] public ACHIEVEMENTS_REWARDS = [
    0,
    1_500 ether,
    6_000 ether,
    15_000 ether,
    40_000 ether,
    96_000 ether,
    171_000 ether,
    265_000 ether,
    381_000 ether,
    700_000 ether,
    1_300_000 ether,
    2_300_000 ether
  ];

  uint8 public constant CHARACTER_LEVELS = 20;
  uint256[CHARACTER_LEVELS] public CHARACTER_LEVEL_UPGARE_PRICE_BNB = [
    0.001 ether, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    0.01 ether, 0, 0, 0, 0.02 ether,
    0, 0, 0, 0, 0.05 ether
  ];
  uint256[CHARACTER_LEVELS] public CHARACTER_LEVEL_UPGARE_PRICE_CRYSTALS = [
    0, 6_2 ether, 9_3 ether, 12_3 ether, 15_4 ether,
    18_5 ether, 21_6 ether, 24_7 ether, 27_8 ether, 30_9 ether,
    0, 39_9 ether, 49_7 ether, 60_5 ether, 0,
    64_0 ether, 78_2 ether, 93_7 ether, 114_0 ether, 0
  ];

  uint8 public constant REFERRAL_LEVELS_NUMBER = 5;
  uint8 public constant MAX_REFERRAL_LEVELS_NUMBER = 7;
  uint256[MAX_REFERRAL_LEVELS_NUMBER] public REFERRAL_PERCENTS = [5_00, 2_00, 1_00, 1_00, 1_00, 1_00, 1_00]; // 5%, 2%, 1%, 1%, 1%, 1%, 1%

  address immutable public DEFAULT_REFERRER;
  address immutable public PROMOTION_ADDRESS;
  address immutable public NFT_TOKEN_ADDRESS;
  address immutable public ERC20_TOKEN_ADDRESS;
  address public LP_TOKEN_ADDRESS; //TODO: add method to change address of the LP and Pancake Router
  address public PANCAKE_ROUTER_ADDRESS;

  mapping(address => GameModels.Player) public players;
  mapping(address => GameModels.PlayerBalance) public balances;
  mapping(address => uint8[PLANETS_NUMBER]) planets;
  mapping(address => uint256) characters;

  uint8 public TOKENS_BUY_BACK_PERCENT = 10;

  uint256 public totalUsers;
  uint256 public totalSpent;
  uint256[PLANETS_NUMBER] public unlockedPlanets;
  uint256[PLANETS_NUMBER] public unlockedPlanetLevels;
  uint256 public totalCrystalsWithdrawn;

  constructor(
    address defaultReferrerAddress,
    address promotionAddress,
    address nftTokenAddress,
    address erc20TokenAddress,
    address lpTokenContractAddress
  ) {
    require(defaultReferrerAddress != address(0x0), "Invalid default referrer address");
    require(Address.isContract(lpTokenContractAddress), "Invalid LP-token contract address");

    DEFAULT_REFERRER = defaultReferrerAddress;
    PROMOTION_ADDRESS = promotionAddress;

    NFT_TOKEN_ADDRESS = nftTokenAddress;

    ERC20_TOKEN_ADDRESS = erc20TokenAddress;
    LP_TOKEN_ADDRESS = lpTokenContractAddress;

    PANCAKE_ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  }

  receive() external payable {
    if (msg.value > 0) {
      payable(PROMOTION_ADDRESS).transfer(msg.value);
    }
  }

  function buyEnergy(address referrer) external payable {
    require(msg.value >= Constants.BUY_ENERGY_MIN_VALUE, "Minimal amount is 0.004 BNB");

    GameModels.Player storage player = players[msg.sender];
    // Register player and init referral connections
    if (player.referrer == address(0x0)) {
      if (referrer == address(0x0) || referrer == msg.sender || players[referrer].referrer == address(0x0)) {
        referrer = DEFAULT_REFERRER;
      }
      player.referrer = referrer;
      players[referrer].referrals.push(msg.sender);

      totalUsers++;

      emit Events.RatingUpdate(referrer, getRating(referrer), block.timestamp);

      emit Events.Registration(
        msg.sender, referrer, totalUsers, block.timestamp
      );
    }

    player.invested+= msg.value;
    balances[msg.sender].energy+= msg.value * Constants.ENERGY_FOR_BNB;

    totalSpent+= msg.value;

    // Achievements XP
    uint256 xp = msg.value * Constants.ENERGY_FOR_BNB * Constants.PERCENT_PRECISION / 1 ether;
    player.xp+= xp * getXPMultiplier(msg.sender);
    emit Events.RatingUpdate(msg.sender, getRating(msg.sender), block.timestamp);

    // Distribute referral reward
    uint256 tokensAmount = getTokensAmount(msg.value);
    address ref = player.referrer;
    for (uint8 i = 0; i < MAX_REFERRAL_LEVELS_NUMBER; i++) {
      if (i < REFERRAL_LEVELS_NUMBER || getReferralLevelsNumber(ref) > i) {
        uint256 tokensRewardAmount = tokensAmount * REFERRAL_PERCENTS[i] / Constants.PERCENT_PRECISION;
        uint256 bnbRewardAmount = msg.value * REFERRAL_PERCENTS[i] / Constants.PERCENT_PRECISION;

        ICommonInterface(ERC20_TOKEN_ADDRESS).mint(ref, tokensRewardAmount);
        players[ref].referralRewardFromBuyEnergy+= bnbRewardAmount;
        players[ref].referralRewards[i][0]+= bnbRewardAmount;

        emit Events.ReferralReward(
          ref,
          msg.sender,
          tokensRewardAmount,
          bnbRewardAmount,
          0,
          block.timestamp
        );
      }

      // Achievements XP
      if (i == 0) {
        players[ref].xp+= xp * getXPMultiplier(ref) / 2;
        emit Events.RatingUpdate(ref, getRating(ref), block.timestamp);
      } else if (i == 1) {
        players[ref].xp+= xp * getXPMultiplier(ref) / 4;
        emit Events.RatingUpdate(ref, getRating(ref), block.timestamp);
      }

      // Turnover
      players[ref].turnover+= msg.value;
      players[ref].turnoverLines[i]+= msg.value;

      players[ref].referralsNumber[i]++;

      ref = players[ref].referrer;
      if (ref == address(0x0)) {
        ref = DEFAULT_REFERRER;
      }
    }

    payable(owner()).transfer(msg.value * Constants.ADMIN_FEE_PERCENT / Constants.PERCENT_PRECISION);
    //TODO: emit BNB transfer to owner event

    // Liquidity
    buyBackTokens(address(this).balance * uint256(TOKENS_BUY_BACK_PERCENT) / 100);
    addLiquidity(address(this).balance);

    emit Events.BuyEnergy(
      msg.sender, msg.value, block.timestamp
    );
  }

  function upgradePlanet(uint8 planetIdx, uint8 levelsToBuy) external {
    require(!Address.isContract(msg.sender), "Buyer shouldn't be a contract"); //TODO: do we need this?
    require(planetIdx >= 0 && planetIdx < PLANETS_NUMBER, "Invalid planet index");
    require(planetIdx == 0 || planets[msg.sender][planetIdx - 1] >= Constants.NEXT_PLANET_THRESHOLD, "This planed is closed. Upgrade previous planet first.");
    require(levelsToBuy <= Constants.PLANET_LEVELS_NUMBER, "Invalid levels to buy amount");

    if (planets[msg.sender][planetIdx] + levelsToBuy > Constants.PLANET_LEVELS_NUMBER) {
      levelsToBuy = Constants.PLANET_LEVELS_NUMBER - planets[msg.sender][planetIdx];
    }
    require(levelsToBuy > 0, "Invalid levels to buy amount");

    collectCrystalsAndEnergy();

    uint256 energyAmount = levelsToBuy * PLANET_LEVEL_PRICE[planetIdx];
    require(balances[msg.sender].energy >= energyAmount, "Not enough energy on the balance");

    if (planets[msg.sender][planetIdx] == 0) {
      unlockedPlanets[planetIdx]++;
    }
    unlockedPlanetLevels[planetIdx]+= levelsToBuy;

    balances[msg.sender].energy-= energyAmount;
    planets[msg.sender][planetIdx]+= levelsToBuy;

    emit Events.UpgradePlanet(
      msg.sender, planetIdx, levelsToBuy, planets[msg.sender][planetIdx], block.timestamp
    );
  }

  function mayBeCollected(address playerAddr) public view returns (uint256 energy, uint256 crystals) {
    if (balances[playerAddr].lastCollectionTime == 0 || balances[playerAddr].lastCollectionTime == block.timestamp) {
      return (0 , 0);
    }

    GameModels.PlayerBalance memory balance = balances[playerAddr];
    uint256 startTime = balance.lastCollectionTime;
    uint256 endTime = block.timestamp;
    if (startTime < balance.lastRocketPushTime) {
      startTime = balance.lastRocketPushTime;
    }
    if (endTime > balance.lastRocketPushTime + getRocketFlightDuration(playerAddr)) {
      endTime = balance.lastRocketPushTime + getRocketFlightDuration(playerAddr);
    }

    if (startTime >= endTime) {
      return (0 , 0);
    }
    uint256 time = endTime - startTime;

    uint256 profit = 0;
    for (uint8 planetIdx = 0; planetIdx < PLANETS_NUMBER; planetIdx++) {
      if (planets[playerAddr][planetIdx] > 0) {
        profit+= PLANET_LEVEL_PRICE[planetIdx] * planets[playerAddr][planetIdx];
      } else {
        break;
      }
    }

    if (profit == 0) {
      return (0 , 0);
    }
    profit= profit * time * 24 hours / 30 minutes / 30 days;
    crystals = profit * getPerformanceRatio(playerAddr) / Constants.PERCENT_PRECISION;

    return (profit - crystals, crystals);
  }

  function collectCrystalsAndEnergy() public {
    GameModels.PlayerBalance storage balance = balances[msg.sender];

    if (balance.lastCollectionTime == 0) {
      balance.lastCollectionTime = block.timestamp;
      balance.lastRocketPushTime = block.timestamp;

      return;
    }

    (uint256 energy, uint256 crystals) = mayBeCollected(msg.sender);
    if (energy == 0 || crystals == 0) {
      return;
    }

    balance.energy+= energy;
    balance.crystals+= crystals;
    balance.lastCollectionTime = block.timestamp;

    emit Events.CollectResources(
      msg.sender, energy, crystals, block.timestamp
    );
  }

  function instantBalance(address playerAddr) external view returns (uint256, uint256) {
    GameModels.PlayerBalance memory balance = balances[playerAddr];

    (uint256 energy, uint256 crystals) = mayBeCollected(playerAddr);

    return (balance.energy + energy, balance.crystals + crystals);
  }

  /**
   * Change crystals on energy.
   *
   * @param crystalsAmount Crystals to change amount in Wei.
   */
  function changeCrystalsForEnergy(uint256 crystalsAmount) external {
    require(crystalsAmount > 0, "Invalid crystals amount");

    collectCrystalsAndEnergy();
    require(crystalsAmount <= balances[msg.sender].crystals, "Not enough crystals on the balance");

    balances[msg.sender].crystals-= crystalsAmount;
    balances[msg.sender].energy+= crystalsAmount * Constants.ENERGY_FOR_CRYSTAL / Constants.PERCENT_PRECISION;

    // Distribute referral reward in energy
    address ref = players[msg.sender].referrer;
    for (uint8 i = 0; i < MAX_REFERRAL_LEVELS_NUMBER; i++) {
      if (i < REFERRAL_LEVELS_NUMBER || getReferralLevelsNumber(ref) > i) {
        uint256 rewardAmount = crystalsAmount * REFERRAL_PERCENTS[i] / Constants.PERCENT_PRECISION;
        uint256 bnbRewardAmount = rewardAmount / Constants.ENERGY_FOR_BNB;

        balances[ref].energy+= rewardAmount;
        players[ref].referralRewardFromExchange+= bnbRewardAmount;
        players[ref].referralRewards[i][1]+= bnbRewardAmount;

        emit Events.ReferralReward(
          ref,
          msg.sender,
          rewardAmount,
          bnbRewardAmount,
          1,
          block.timestamp
        );
      }

      ref = players[ref].referrer;
      if (ref == address(0x0)) {
        ref = DEFAULT_REFERRER;
      }
    }

    emit Events.ExchangeCrystals(
      msg.sender, crystalsAmount, block.timestamp
    );
  }

  /**
   * Withdraw crystals as ERC-20 project token.
   *
   * @param crystalsAmount Crystals to change amount in Wei.
   */
  function withdrawCrystals(uint256 crystalsAmount) external {
    require(crystalsAmount > 0, "Invalid crystals amount");

    collectCrystalsAndEnergy();
    require(crystalsAmount <= balances[msg.sender].crystals, "Not enough crystals on the balance");

    uint256 tokensMayBeWithdrawn = mayBeWithdrawn(msg.sender);
    require(tokensMayBeWithdrawn > 0, "You have reached withdrawal limit");
    if (crystalsAmount > tokensMayBeWithdrawn) {
      crystalsAmount = tokensMayBeWithdrawn;
    }

    GameModels.Player storage player = players[msg.sender];
    uint256 value = getBNBAmount(crystalsAmount);

    player.withdrawn+= value;
    player.withdrawnCrystals+= crystalsAmount;
    totalCrystalsWithdrawn+= crystalsAmount;

    balances[msg.sender].crystals-= crystalsAmount;

    ICommonInterface(ERC20_TOKEN_ADDRESS).mint(msg.sender, crystalsAmount);

    emit Events.WithdrawCrystals(
      msg.sender, crystalsAmount, value, block.timestamp
    );
  }

  function mayBeWithdrawn(address playerAddr) public view returns (uint256) {
    GameModels.Player memory player = players[playerAddr];

    uint256 bnbAmount =
      (player.invested + player.referralRewardFromExchange) * Constants.TOKENS_WITHDRAW_LIMIT / Constants.PERCENT_PRECISION
      - player.withdrawn;

    return getTokensAmount(bnbAmount);
  }

  function attachCharacter(uint256 tokenId) external {
    require(characters[msg.sender] == 0, "You have already attached other character");
    require(ICommonInterface(NFT_TOKEN_ADDRESS).ownerOf(tokenId) == msg.sender, "You are not an owner of this NFT");

    collectCrystalsAndEnergy();

    ICommonInterface(NFT_TOKEN_ADDRESS).safeTransferFrom(msg.sender, address(this), tokenId);
    characters[msg.sender] = tokenId;

    ICommonInterface(NFT_TOKEN_ADDRESS).markAsUsed(msg.sender, tokenId);

    emit Events.AttachCharacter(
      msg.sender, tokenId, block.timestamp
    );

    // push rocket
    balances[msg.sender].lastRocketPushTime = block.timestamp;
  }

  function detachCharacter() external {
    require(characters[msg.sender] > 0, "You have no attached character");
    require(
      ICommonInterface(NFT_TOKEN_ADDRESS).ownerOf(characters[msg.sender]) == address(this),
      "We have no this NFT on the contract"
    );

    collectCrystalsAndEnergy();

    ICommonInterface(NFT_TOKEN_ADDRESS).safeTransferFrom(address(this), msg.sender, characters[msg.sender]);
    emit Events.DetachCharacter(
      msg.sender, characters[msg.sender], block.timestamp
    );
    characters[msg.sender] = 0;

    // push rocket
    balances[msg.sender].lastRocketPushTime = block.timestamp;
  }

  function upgradeCharacter(uint8 toLevel) external payable {
    require(toLevel <= 20, "Invalid level value");
    require(characters[msg.sender] > 0, "You have no attached character");
    require(
      ICommonInterface(NFT_TOKEN_ADDRESS).ownerOf(characters[msg.sender]) == address(this),
      "Character NFT isn't attached to the game"
    );

    uint8 characterLvl = ICommonInterface(NFT_TOKEN_ADDRESS).level(characters[msg.sender]);
    require(characterLvl < 20, "You have reached the maximum level");
    require(toLevel > characterLvl, "You can't downgrade character");

    collectCrystalsAndEnergy();

    uint256 upgradePriceBNB = 0;
    uint256 upgradePriceCrystals = 0;
    for (uint8 lvl = characterLvl; lvl < toLevel; lvl++) {
      upgradePriceBNB+= CHARACTER_LEVEL_UPGARE_PRICE_BNB[lvl];
      upgradePriceCrystals+= CHARACTER_LEVEL_UPGARE_PRICE_CRYSTALS[lvl];
    }

    if (upgradePriceBNB > 0) {
      require(msg.value == upgradePriceBNB, "Invalid upgrade BNB amount");

      payable(ICommonInterface(NFT_TOKEN_ADDRESS).BNB_RECEIVER_ADDRESS()).transfer(msg.value);
    }

    if (upgradePriceCrystals > 0) {
      require(
        balances[msg.sender].crystals >= upgradePriceCrystals,
        "Insufficient crystals balance"
      );

      balances[msg.sender].crystals-= upgradePriceCrystals;
    }
    ICommonInterface(NFT_TOKEN_ADDRESS).upgrade(msg.sender, characters[msg.sender], toLevel);

    emit Events.RatingUpdate(msg.sender, getRating(msg.sender), block.timestamp);

    emit Events.UpgradeCharacter(msg.sender, characters[msg.sender], toLevel);

    // push rocket
    balances[msg.sender].lastRocketPushTime = block.timestamp;
  }

  function pushRocket() external {
    collectCrystalsAndEnergy();

    balances[msg.sender].lastRocketPushTime = block.timestamp;

    emit Events.PushRocket(msg.sender, block.timestamp);
  }

  /**
   * Returns tuple with last rocket push time and actual rocket flight duratioin for the user.
   *
   * @param playerAddr Address of the player.
   *
   * @return lastRocketPushTime Last timestamp when rocket was pushed by the player.
   * @return duration Actual rocket flight duration calculated regarding to the active NFT characted.
   */
  function getRocketState(address playerAddr) external view returns (uint256 lastRocketPushTime, uint256 duration) {
    return (balances[playerAddr].lastRocketPushTime, getRocketFlightDuration(playerAddr));
  }

  function getBNBAmount(uint256 tokensAmount) public view returns(uint256) {
    (uint256 reserve0, uint256 reserve1, ) = IPancakePair(LP_TOKEN_ADDRESS).getReserves();

    return tokensAmount * reserve1 / reserve0;
  }

  function getTokensAmount(uint256 amount) public view returns(uint256) {
    (uint256 reserve0, uint256 reserve1, ) = IPancakePair(LP_TOKEN_ADDRESS).getReserves();

    return amount * reserve0 / reserve1;
  }

  function getTokenLiquidity() external view returns (
    uint256 liquidityBNB,
    uint256 liquiditySGT
  ) {
    (liquiditySGT, liquidityBNB, ) = IPancakePair(LP_TOKEN_ADDRESS).getReserves();
  }

  function buyBackTokens(uint256 bnbAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // Wrapped BNB (WBNB)
    path[1] = ERC20_TOKEN_ADDRESS;

    IPancakeRouter(PANCAKE_ROUTER_ADDRESS).swapExactETHForTokens {value: bnbAmount} (
      0,
      path,
      PROMOTION_ADDRESS,
      block.timestamp + 5 minutes
    );

    //TODO: emit event
  }

  function addLiquidity(uint256 bnbAmount) private {
    uint256 amount = getTokensAmount(bnbAmount);

    ICommonInterface(ERC20_TOKEN_ADDRESS).mint(address(this), amount);
    ICommonInterface(ERC20_TOKEN_ADDRESS).increaseAllowance(PANCAKE_ROUTER_ADDRESS, amount);

    //TODO: emit AddLiquidity(bnbAmount, amount, block.timestamp + 5 minutes);

    (uint256 amountToken, uint256 amountBNB, uint256 liquidity) = IPancakeRouter(PANCAKE_ROUTER_ADDRESS).addLiquidityETH {value: bnbAmount} (
      ERC20_TOKEN_ADDRESS,
      amount,
      0,
      0,
      address(this),
      block.timestamp + 5 minutes
    );

    //TODO: emit LiquidityAdded(amountBNB, amountToken, liquidity);

    //TODO: burn LP tokens
  }

  function addLiquidityManually(uint256 bnbAmount) external onlyOwner {
    addLiquidity(bnbAmount);
  }

  function retrieveLPTokens(uint256 amount) external onlyOwner {
    if (amount == 0) {
      amount = IERC20(LP_TOKEN_ADDRESS).balanceOf(address(this));
    }

    IERC20(LP_TOKEN_ADDRESS).safeTransfer(msg.sender, amount);
  }

  function retrieveBNB(uint256 amount) external onlyOwner {
    if (amount == 0) {
      amount = address(this).balance;
    }

    payable(msg.sender).transfer(amount);
  }

  function changePancakeRouterAddress(address newAddr) external onlyOwner {
    require(newAddr != address(0x0) && Address.isContract(newAddr), "Invalid PancakeRouter address");
    require(newAddr != PANCAKE_ROUTER_ADDRESS, "Address is already setted");

    PANCAKE_ROUTER_ADDRESS = newAddr;
  }

  function changeTokensBuyBackPercent(uint8 percent) external onlyOwner {
    require(percent > 0 && percent <= 100, "Invalid percent value");

    TOKENS_BUY_BACK_PERCENT = percent;
  }

  function getReferralLevelsNumber(address playerAddr) public view returns (uint8 refLevelsNumber) {
    if (characters[playerAddr] == 0) {
      return REFERRAL_LEVELS_NUMBER;
    }

    uint8 characterLvl = ICommonInterface(NFT_TOKEN_ADDRESS).level(characters[playerAddr]);
    if (characterLvl >= 15) {
      return (REFERRAL_LEVELS_NUMBER + 2);
    } else if (characterLvl >= 11) {
      return (REFERRAL_LEVELS_NUMBER + 1);
    }

    return REFERRAL_LEVELS_NUMBER;
  }

  /**
   * Returns performance ration in Crystals percent (will be increase with upgrades).
   *
   * @param playerAddr Address of the player.
   *
   * @return performanceRatio Percent of Crystals part ratio (normalized with precision).
   */
  function getPerformanceRatio(address playerAddr) public view returns (uint256 performanceRatio) {
    if (characters[playerAddr] == 0) {
      return 40_00;
    }

    uint8 characterLvl = ICommonInterface(NFT_TOKEN_ADDRESS).level(characters[playerAddr]);

    return (40_00 + 1_00 * uint256(characterLvl));
  }

  function getRocketFlightDuration(address playerAddr) public view returns (uint256 rocketFlyDuration) {
    if (characters[playerAddr] == 0) {
      return (24 hours / 10);
    }

    uint8 characterLvl = ICommonInterface(NFT_TOKEN_ADDRESS).level(characters[playerAddr]);
    if (characterLvl >= 19) {
      return (24 hours + 240 hours) / 10;
    } else if (characterLvl >= 16) {
      return (24 hours + 144 hours) / 10;
    } else if (characterLvl >= 14) {
      return (24 hours + 120 hours) / 10;
    } else if (characterLvl >= 10) {
      return (24 hours + 96 hours) / 10;
    } else if (characterLvl >= 8) {
      return (24 hours + 72 hours) / 10;
    } else if (characterLvl >= 5) {
      return (24 hours + 48 hours) / 10;
    } else if (characterLvl >= 2) {
      return (24 hours + 24 hours) / 10;
    } else if (characterLvl == 1) {
      return (24 hours + 12 hours) / 10;
    }

    return (24 hours / 10);
  }

  function getXPMultiplier(address playerAddr) public view returns (uint256 xpMultiplier) {
    if (characters[playerAddr] == 0) {
      return Constants.PERCENT_PRECISION;
    }

    uint8 characterLvl = ICommonInterface(NFT_TOKEN_ADDRESS).level(characters[playerAddr]);
    if (characterLvl >= 13) {
      return Constants.PERCENT_PRECISION + 30_00;
    } else if (characterLvl >= 11) {
      return Constants.PERCENT_PRECISION + 25_00;
    } else if (characterLvl >= 9) {
      return Constants.PERCENT_PRECISION + 20_00;
    } else if (characterLvl >= 7) {
      return Constants.PERCENT_PRECISION + 15_00;
    } else if (characterLvl >= 5) {
      return Constants.PERCENT_PRECISION + 10_00;
    } else if (characterLvl >= 3) {
      return Constants.PERCENT_PRECISION + 5_00;
    }

    return Constants.PERCENT_PRECISION;
  }

  function getRatingMultiplier(address playerAddr) public view returns (uint256 ratingMultiplier) {
    if (characters[playerAddr] == 0) {
      return Constants.PERCENT_PRECISION;
    }

    uint8 characterLvl = ICommonInterface(NFT_TOKEN_ADDRESS).level(characters[playerAddr]);

    return Constants.PERCENT_PRECISION + uint256(characterLvl) * 10_00;
  }

  function getRating(address playerAddr) public view returns (uint256 rating) {
    return (players[playerAddr].xp + players[playerAddr].referrals.length * 50_000 * Constants.PERCENT_PRECISION * Constants.PERCENT_PRECISION)
      * getRatingMultiplier(playerAddr) / Constants.PERCENT_PRECISION
      / Constants.PERCENT_PRECISION
      / Constants.PERCENT_PRECISION;
  }

  function collectAchievementReward() external {
    GameModels.Player storage player = players[msg.sender];

    uint8 lvl = player.level + 1;
    while (lvl < ACHIEVEMENTS_NUMBER) {
      if (player.xp >= ACHIEVEMENTS_XP[lvl] * Constants.PERCENT_PRECISION * Constants.PERCENT_PRECISION) {
        balances[msg.sender].energy+= ACHIEVEMENTS_REWARDS[lvl];
        lvl++;
      } else {
        break;
      }
    }

    player.level = lvl - 1;

    emit Events.CollectAchievementReward(msg.sender, player.level, block.timestamp);
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external pure returns (bytes4) {
    return this.onERC721Received.selector; // bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))
  }

  function referrals(address playerAddr) external view returns (address[] memory) {
    return players[playerAddr].referrals;
  }

  function commonReferralStats(address playerAddr) external view returns (
    address referrer,
    uint256 referralsCount,
    uint256 structureVolume,
    uint256 turnover,
    address[] memory referralsList,
    uint256[MAX_REFERRAL_LEVELS_NUMBER] memory referralsNumber,
    uint256[MAX_REFERRAL_LEVELS_NUMBER] memory turnoverLines
  ) {
    GameModels.Player memory player = players[playerAddr];

    for (uint8 i = 0; i < MAX_REFERRAL_LEVELS_NUMBER; i++) {
      structureVolume+= player.referralsNumber[i];
    }

    return (
      player.referrer,
      player.referrals.length,
      structureVolume,
      player.turnover,
      player.referrals,
      player.referralsNumber,
      player.turnoverLines
    );
  }

  function getReferralRewards(address playerAddr) external view returns (
    uint256[] memory referralRewardsFromBuyEnergy, uint256[] memory referralRewardsFromExchange
  ) {
    GameModels.Player memory player = players[playerAddr];

    referralRewardsFromBuyEnergy = new uint256[](MAX_REFERRAL_LEVELS_NUMBER);
    referralRewardsFromExchange = new uint256[](MAX_REFERRAL_LEVELS_NUMBER);

    for (uint8 i = 0; i < MAX_REFERRAL_LEVELS_NUMBER; i++) {
      referralRewardsFromBuyEnergy[i] = player.referralRewards[i][0];
      referralRewardsFromExchange[i] = player.referralRewards[i][1];
    }
  }

  function getPlanetsStats() external view returns (
    uint256[] memory unlockedPlanetsStats,
    uint256[] memory unlockedPlanetLevelsStats
  ) {
    unlockedPlanetsStats = new uint256[](PLANETS_NUMBER);
    unlockedPlanetLevelsStats = new uint256[](PLANETS_NUMBER);

    for (uint8 i = 0; i < PLANETS_NUMBER; i++) {
      unlockedPlanetsStats[i] = unlockedPlanets[i];
      unlockedPlanetLevelsStats[i] = unlockedPlanetLevels[i];
    }
  }

  function getPlayerPlanets(address playerAddr) external view returns (uint8[PLANETS_NUMBER] memory) {
    return planets[playerAddr];
  }

  function buyEnergy() external payable {
    payable(msg.sender).transfer(msg.value);

    //TODO: emit correspond event?
  }

}