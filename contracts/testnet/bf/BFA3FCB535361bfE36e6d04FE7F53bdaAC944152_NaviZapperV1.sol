/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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

interface IUniswapV2Router02 {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IExchange {
    function executeExchange(uint256 amount, bytes memory) external;
}

/**
 * @title A contract implementing a simple exchange on one Dex
 **/
contract ExchangeSimple is IExchange {
    using SafeERC20 for IERC20;

    function executeExchange(uint256 amount, bytes memory data)
        external
        override
    {
        (address exchange, address[] memory path) = abi.decode(
            data,
            (address, address[])
        );
        uint256[] memory amountOut = IUniswapV2Router02(exchange)
            .swapExactTokensForTokens(
                amount,
                0,
                path,
                address(this),
                block.timestamp
            );
        IERC20(path[path.length - 1]).safeTransfer(
            msg.sender,
            amountOut[amountOut.length - 1]
        );
    }
}

interface IStrategy {
    function borrowCallback(bytes memory data) external;

    function redeemCallback(bytes memory data, uint256 redeemAmount) external;

    function farmWithdrawCallback(
        bytes memory data,
        uint256 amount0,
        uint256 amount1
    ) external;

    //NFT, etc.
    function otherWithdrawCallback(
        bytes memory callbackData,
        bytes memory withdrawData
    ) external;
}

interface INaviOracle {
    function isBridged(uint32 id) external view returns (bool);

    function hasBridgedData(uint32 id) external view returns (bool);

    function isnToken(uint32 id) external view returns (bool);

    function hasPriceFeed(uint32 id) external view returns (bool);

    function tokenAddress(uint32 id) external view returns (address);

    function daoAddress(uint32 id) external view returns (address);

    function price(uint32 id) external view returns (uint256);

    function tokenExtra(uint32 id) external view returns (string memory);

    function maxId() external view returns (uint32);

    function idByTokenAddress(address token) external view returns (uint32);
}

interface IMarginable {
    /**
     * @notice IMarginable can credit itself, so account can be either net borrower(deposits=0) or
     * net depositer(borrows=0).
     * @dev This function returns USD value of free margin with LTV risk parameters applied
     */
    function netPosition(address account, uint32 data)
        external
        view
        returns (int256);

    /**
     * @notice Gets risk parameters
     */
    function getLTV() external view returns (uint256);

    function seizeAccount(address account, address seizeTo) external;

    function setParent(address newParent) external;

    function getTotalReserves() external view returns (uint256);

    function setBridgeBorrowsStatus(uint8 status) external;

    function authorizeStrategy(
        address strategy,
        address signatory,
        bool authorize
    ) external;
}

interface IFarmGroup is IMarginable {
    // this id is needed because index of farmGroup in farmController can change
    function farmGroupId() external view returns (uint8);

    function deposit(
        uint32 pair,
        uint32 farm,
        uint256 amount0,
        uint256 amount1,
        address account
    ) external;

    function getDepositsLength(address account) external view returns (uint256);

    struct Deposit {
        address farm;
        address pair;
        uint256 amount;
    }

    function getDeposit(address account, uint32 index)
        external
        view
        returns (Deposit memory);

    function getPairsLength() external view returns (uint256);

    function getPairAddress(uint32 index) external view returns (address);

    function getPairDeposits(uint32 index) external view returns (uint256);

    function getPair(uint32 pool)
        external
        view
        returns (address token0, address token1);

    function getFarm(uint32) external view returns (address);

    function getFarmPool(uint32) external view returns (address);

    function getReserves(uint32 index)
        external
        view
        returns (uint256[] memory r);

    function getFarmsLength() external view returns (uint256);
}

interface IFarmController {
    //amount in USD
    function hasEnoughMargin(address from, uint256 amount)
        external
        view
        returns (bool);

    //netPosition in USD
    function netPosition(address from, uint32 id)
        external
        view
        returns (int256);

    function getFarmsLength() external view returns (uint256);

    function getFarms(uint32 index) external view returns (IFarmGroup);
}

interface InTokenForEther {
    function compensateFee(
        address from,
        address to,
        uint256 amount
    ) external;
}

interface InToken {
    function getUnderlying() external view returns (address);

    function getPriceId() external view returns (uint32);

    function getTotalReserves() external view returns (uint256);

    function getCash() external view returns (uint256);

    function getTotalBorrows() external view returns (uint256);

    function getReserveFactor() external view returns (uint256);

    function balanceOfUnderlying(address owner) external view returns (uint256);

    function redeemByStrategy(
        uint256 redeemTokensIn,
        uint256 redeemAmountIn,
        address redeemer,
        bytes memory data
    ) external;

    function borrowByStrategy(
        uint256 borrowAmount,
        address borrower,
        bytes memory data
    ) external;

    function borrowBalance(address account) external view returns (uint256);

    function burnDebtFor(address sender, uint256 amount) external;

    function bridgeDeposits(address account) external view returns (uint256);

    function bridgeBorrows(address account) external view returns (uint256);
}

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/**
 * @title Fixed point WAD\RAY math contract
 * @notice Implements the fixed point arithmetic operations for WAD numbers (18 decimals) and RAY (27 decimals)
 * @dev Wad functions have a [w] prefix: wmul, wdiv. Ray functions have a [r] prefix: rmul, rdiv, rpow.
 * @author https://github.com/dapphub/ds-math
 **/

contract DSMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x >= y ? x : y;
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {
        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {
        return x >= y ? x : y;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    //rounds to zero if x*y < WAD / 2
    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    //rounds to zero if x*y < WAD / 2
    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    //rounds to zero if x*y < WAD / 2
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    //rounds to zero if x*y < RAY / 2
    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC1820Registry.sol)

/**
 * @dev Interface of the global ERC1820 Registry, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1820[EIP]. Accounts may register
 * implementers for interfaces in this registry, as well as query support.
 *
 * Implementers may be shared by multiple accounts, and can also implement more
 * than a single interface for each account. Contracts can implement interfaces
 * for themselves, but externally-owned accounts (EOA) must delegate this to a
 * contract.
 *
 * {IERC165} interfaces can also be queried via the registry.
 *
 * For an in-depth explanation and source code analysis, see the EIP text.
 */
interface IERC1820Registry {
    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);

    /**
     * @dev Sets `newManager` as the manager for `account`. A manager of an
     * account is able to set interface implementers for it.
     *
     * By default, each account is its own manager. Passing a value of `0x0` in
     * `newManager` will reset the manager to this initial state.
     *
     * Emits a {ManagerChanged} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     */
    function setManager(address account, address newManager) external;

    /**
     * @dev Returns the manager for `account`.
     *
     * See {setManager}.
     */
    function getManager(address account) external view returns (address);

    /**
     * @dev Sets the `implementer` contract as ``account``'s implementer for
     * `interfaceHash`.
     *
     * `account` being the zero address is an alias for the caller's address.
     * The zero address can also be used in `implementer` to remove an old one.
     *
     * See {interfaceHash} to learn how these are created.
     *
     * Emits an {InterfaceImplementerSet} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     * - `interfaceHash` must not be an {IERC165} interface id (i.e. it must not
     * end in 28 zeroes).
     * - `implementer` must implement {IERC1820Implementer} and return true when
     * queried for support, unless `implementer` is the caller. See
     * {IERC1820Implementer-canImplementInterfaceForAddress}.
     */
    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external;

    /**
     * @dev Returns the implementer of `interfaceHash` for `account`. If no such
     * implementer is registered, returns the zero address.
     *
     * If `interfaceHash` is an {IERC165} interface id (i.e. it ends with 28
     * zeroes), `account` will be queried for support of it.
     *
     * `account` being the zero address is an alias for the caller's address.
     */
    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);

    /**
     * @dev Returns the interface hash for an `interfaceName`, as defined in the
     * corresponding
     * https://eips.ethereum.org/EIPS/eip-1820#interface-name[section of the EIP].
     */
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    /**
     * @notice Updates the cache with whether the contract implements an ERC165 interface or not.
     * @param account Address of the contract for which to update the cache.
     * @param interfaceId ERC165 interface for which to update the cache.
     */
    function updateERC165Cache(address account, bytes4 interfaceId) external;

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not.
     * If the result is not cached a direct lookup on the contract address is performed.
     * If the result is not cached or the cached value is out-of-date, the cache MUST be updated manually by calling
     * {updateERC165Cache} with the contract address.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not without using nor updating the cache.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);
}

interface INaviController {
    function authorizeStrategyBySig(bytes calldata params) external;
}

/**
 * @title A strategy for depositing tokens to UniswapV2 pool
 * @notice Can exchange, borrow and redeem token from nTokens, but not from other farms
 * @dev This strategy uses technique similar to flash loan and can create or modify a leveraged position.
 **/
contract NaviZapperV1 is Ownable, ReentrancyGuard, IStrategy {
    using SafeERC20 for IERC20;
    INaviOracle public immutable oracle;
    IFarmController public immutable farms;
    InTokenForEther public immutable feeCompensator;
    INaviController public immutable controller;
    address private tok;
    mapping(address => uint32) private nonces; // to exclude transaction signature reuse

    IExchange[] private authorizedExchanges;

    function getNounce(address addr) external view returns (uint32) {
        return nonces[addr];
    }

    struct ExecuteStrategyParams {
        bytes exchangeData;
        uint32 idTokenBorrow;
        uint256 amountBorrow;
        uint32 farmGroup;
        uint32 pool;
        uint32 farm;
    }
    struct ExecuteBySigParams {
        uint256 fee;
        uint32 nonce;
        uint256 expiry;
        bytes32 schema;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    struct State {
        address signatory;
        uint8 tokenIndex;
    }
    ExecuteBySigParams private sig;
    ExecuteStrategyParams private params;
    State private state;
    address[] private exchangeToken;
    uint256[] private exchangeAmount;
    bytes[] private exchangeData;
    uint8[] private exchanges;

    constructor(
        address farms_,
        address oracle_,
        address feeCompensator_,
        address controller_
    ) Ownable() {
        farms = IFarmController(farms_);
        oracle = INaviOracle(oracle_);
        feeCompensator = InTokenForEther(feeCompensator_);
        controller = INaviController(controller_);
        authorizedExchanges.push(new ExchangeSimple());
    }

    function getAuthorizedExchangesLength() external view returns (uint256) {
        return authorizedExchanges.length;
    }

    function getAuthorizedExchange(uint8 index)
        external
        view
        returns (address)
    {
        return address(authorizedExchanges[index]);
    }

    function authorizeExchange(address newExchange) external onlyOwner {
        authorizedExchanges.push(IExchange(newExchange));
    }

    function removeExchange(uint8 index) external onlyOwner {
        authorizedExchanges[index] = authorizedExchanges[
            authorizedExchanges.length - 1
        ];
        authorizedExchanges.pop();
    }

    function executeBySigWithPermit(
        bytes calldata paramData,
        bytes calldata sigData,
        bytes calldata permitData
    ) external {
        controller.authorizeStrategyBySig(permitData);
        executeBySig(paramData, sigData);
    }

    function executeBySig(bytes calldata paramData, bytes calldata sigData)
        public
        nonReentrant
    {
        sig = abi.decode(sigData, (ExecuteBySigParams));
        params = abi.decode(paramData, (ExecuteStrategyParams));
        require(
            block.timestamp <= sig.expiry,
            "NaviZapper::executeBySig: Signature expired"
        );
        bytes memory encoded = abi.encodePacked(
            params.exchangeData,
            params.idTokenBorrow,
            params.amountBorrow,
            params.farmGroup,
            params.pool,
            params.farm,
            sig.fee,
            address(this),
            sig.nonce,
            sig.expiry
        );
        bytes32 data = keccak256(encoded);
        data = keccak256(abi.encodePacked(sig.schema, data));
        state.signatory = ecrecover(data, sig.v, sig.r, sig.s);
        require(
            state.signatory != address(0),
            "Navi::executeBySig: Invalid signature"
        );
        require(
            sig.nonce > nonces[state.signatory],
            "Navi::executeBySig: Invalid nonce"
        );

        nonces[state.signatory] = sig.nonce;
        (exchangeToken, exchangeAmount, exchangeData, exchanges) = abi.decode(
            params.exchangeData,
            (address[], uint256[], bytes[], uint8[])
        );
        executeInternal();
        if (sig.fee > 0)
            feeCompensator.compensateFee(state.signatory, msg.sender, sig.fee);
    }

    function executeWithPermit(
        bytes calldata paramData,
        bytes calldata permitData
    ) external {
        controller.authorizeStrategyBySig(permitData);
        executeStrategy(paramData);
    }

    function executeStrategy(bytes calldata paramData) public nonReentrant {
        params = abi.decode(paramData, (ExecuteStrategyParams));
        state.signatory = msg.sender;
        (exchangeToken, exchangeAmount, exchangeData, exchanges) = abi.decode(
            params.exchangeData,
            (address[], uint256[], bytes[], uint8[])
        );
        executeInternal();
    }

    IERC1820Registry internal constant _erc1820 =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    function isnToken() internal view returns (bool) {
        return
            _erc1820.getInterfaceImplementer(tok, keccak256("NaviToken")) ==
            tok;
    }

    function executeInternal() internal {
        for (; state.tokenIndex < exchangeToken.length; ) {
            tok = exchangeToken[state.tokenIndex];
            uint256 amount = exchangeAmount[state.tokenIndex];
            if (isnToken()) {
                InToken(tok).redeemByStrategy(0, amount, state.signatory, "");
            } else {
                if (tok != address(0))
                    IERC20(tok).safeTransferFrom(
                        state.signatory,
                        address(this),
                        amount
                    ); //else TODO wrap & tranfer WETH
                doExchange(tok, amount);
            }
        }
        if (params.idTokenBorrow > 0) {
            tok = oracle.tokenAddress(params.idTokenBorrow);
            InToken(tok).borrowByStrategy(
                params.amountBorrow,
                state.signatory,
                ""
            );
        }
        doDeposit();
    }

    function borrowCallback(bytes memory) public override {
        require(msg.sender == tok, "unauthorized call");
        tok = address(this);
        doExchange(InToken(msg.sender).getUnderlying(), params.amountBorrow);
        doDeposit();
    }

    function redeemCallback(bytes memory, uint256 redeemAmount)
        public
        override
    {
        require(msg.sender == tok, "unauthorized call");
        tok = address(this);
        doExchange(InToken(msg.sender).getUnderlying(), redeemAmount);
        executeInternal();
    }

    function doExchange(address token, uint256 amount) internal {
        //TODO check & wrap WETH
        uint8 xchg = exchanges[state.tokenIndex];
        if (xchg < authorizedExchanges.length) {
            IERC20(token).safeTransfer(
                address(authorizedExchanges[xchg]),
                amount
            );
            authorizedExchanges[xchg].executeExchange(
                amount,
                exchangeData[state.tokenIndex]
            );
        }
        state.tokenIndex++;
    }

    function doDeposit() internal {
        IFarmGroup farmGroup = farms.getFarms(params.farmGroup);
        (address token0, address token1) = farmGroup.getPair(params.pool);

        uint256 amount0 = IERC20(token0).balanceOf(address(this));
        uint256 amount1 = IERC20(token1).balanceOf(address(this));

        IERC20(token0).safeApprove(address(farmGroup), amount0);
        IERC20(token1).safeApprove(address(farmGroup), amount1);
        farmGroup.deposit(
            params.pool,
            params.farm,
            amount0,
            amount1,
            state.signatory
        );
    }

    function sweepToken(IERC20 token) external {
        token.transfer(owner(), token.balanceOf(address(this)));
    }

    function farmWithdrawCallback(
        bytes memory data,
        uint256 amount0,
        uint256 amount1
    ) external override {}

    function otherWithdrawCallback(
        bytes memory callbackData,
        bytes memory withdrawData
    ) external override {}
}