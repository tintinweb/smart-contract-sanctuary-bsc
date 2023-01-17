// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This treasury contract has been developed by brewlabs.info
 */
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./libs/IUniFactory.sol";
import "./libs/IUniRouter02.sol";

interface IStaking {
    function performanceFee() external view returns (uint256);
    function setServiceInfo(address _addr, uint256 _fee) external;
}

interface IFarm {
    function setBuyBackWallet(address _addr) external;
}

contract BrewlabsTreasury is Ownable {
    using SafeERC20 for IERC20;

    bool private isInitialized;
    uint256 private constant TIME_UNIT = 1 days;
    uint256 private constant PERCENT_PRECISION = 10000;

    IERC20 public token;
    address public dividendToken;
    address public pair;
    address private constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    uint256 public period = 30; // 30 days
    uint256 public withdrawalLimit = 500; // 5% of total supply
    uint256 public liquidityWithdrawalLimit = 2000; // 20% of LP supply
    uint256 public buybackRate = 9500; // 95%
    uint256 public addLiquidityRate = 9400; // 94%
    uint256 public stakingRate = 1500; // 15%

    uint256 private startTime;
    uint256 private sumWithdrawals = 0;
    uint256 private sumLiquidityWithdrawals = 0;

    address public uniRouterAddress;
    address[] public bnbToTokenPath;
    address[] public bnbToDividendPath;
    address[] public dividendToTokenPath;
    uint256 public slippageFactor = 8300; // 17%
    uint256 public constant slippageFactorUL = 9950;

    event Initialized(
        address token,
        address dividendToken,
        address router,
        address[] bnbToTokenPath,
        address[] bnbToDividendPath,
        address[] dividendToTokenPath
    );

    event TokenBuyBack(uint256 amountETH, uint256 amountToken);
    event TokenBuyBackFromDividend(uint256 amount, uint256 amountToken);
    event LiquidityAdded(uint256 amountETH, uint256 amountToken, uint256 liquidity);
    event LiquidityWithdrawn(uint256 amount);
    event Withdrawn(uint256 amount);
    event Harvested(address account, uint256 amount);
    event Swapped(address token, uint256 amountETH, uint256 amountToken);

    event BnbHarvested(address to, uint256 amount);
    event EmergencyWithdrawn();
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);
    event BusdHarvested(address to, uint256[] amounts);
    event UsdcHarvested(address to, uint256[] amounts);

    event SetSwapConfig(
        address router,
        uint256 slipPage,
        address[] bnbToTokenPath,
        address[] bnbToDividendPath,
        address[] dividendToTokenPath
    );
    event TransferBuyBackWallet(address staking, address wallet);
    event AddLiquidityRateUpdated(uint256 percent);
    event BuybackRateUpdated(uint256 percent);
    event SetStakingRateUpdated(uint256 percent);
    event PeriodUpdated(uint256 duration);
    event LiquidityWithdrawLimitUpdated(uint256 percent);
    event WithdrawLimitUpdated(uint256 percent);

    constructor() {}

    /**
     * @notice Initialize the contract
     * @param _token: token address
     * @param _dividendToken: reflection token address
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _bnbToTokenPath: swap path to buy Token
     * @param _bnbToDividendPath: swap path to buy dividend token
     * @param _dividendToTokenPath: swap path to buy Token with dividend token
     */
    function initialize(
        IERC20 _token,
        address _dividendToken,
        address _uniRouter,
        address[] memory _bnbToTokenPath,
        address[] memory _bnbToDividendPath,
        address[] memory _dividendToTokenPath
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");
        require(_uniRouter != address(0x0), "invalid address");
        require(address(_token) != address(0x0), "invalid token address");

        // Make this contract initialized
        isInitialized = true;

        token = _token;
        dividendToken = _dividendToken;
        pair = IUniV2Factory(IUniRouter02(_uniRouter).factory()).getPair(_bnbToTokenPath[0], address(token));

        uniRouterAddress = _uniRouter;
        bnbToTokenPath = _bnbToTokenPath;
        bnbToDividendPath = _bnbToDividendPath;
        dividendToTokenPath = _dividendToTokenPath;

        emit Initialized(
            address(_token), _dividendToken, _uniRouter, _bnbToTokenPath, _bnbToDividendPath, _dividendToTokenPath
            );
    }

    /**
     * @notice Buy token from BNB
     */
    function buyBack() external onlyOwner {
        uint256 ethAmt = address(this).balance;
        ethAmt = (ethAmt * buybackRate) / PERCENT_PRECISION;

        if (ethAmt > 0) {
            uint256 _tokenAmt = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            emit TokenBuyBack(ethAmt, _tokenAmt);
        }
    }

    /**
     * @notice Buy token from BNB and transfer token to staking pool
     */
    function buyBackStakeBNB(address _staking) external onlyOwner {
        uint256 ethAmt = address(this).balance;
        ethAmt = (ethAmt * buybackRate) / PERCENT_PRECISION;
        if (ethAmt > 0) {
            uint256 _tokenAmt = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            emit TokenBuyBack(ethAmt, _tokenAmt);

            token.safeTransfer(_staking, _tokenAmt * stakingRate / PERCENT_PRECISION);
        }
    }

    /**
     * @notice Buy token from reflections and transfer token to staking pool
     */
    function buyBackStakeDividend(address _staking) external onlyOwner {
        if (dividendToken == address(0x0)) return;

        uint256 reflections = IERC20(dividendToken).balanceOf(address(this));
        if (reflections > 0) {
            uint256 _tokenAmt = _safeSwap(reflections, dividendToTokenPath, address(this));
            emit TokenBuyBackFromDividend(reflections, _tokenAmt);

            token.safeTransfer(_staking, _tokenAmt * stakingRate / PERCENT_PRECISION);
        }
    }

    /**
     * @notice Buy token from reflections
     */
    function buyBackFromDividend() external onlyOwner {
        if (dividendToken == address(0x0)) return;

        uint256 reflections = IERC20(dividendToken).balanceOf(address(this));
        if (reflections > 0) {
            uint256 _tokenAmt = _safeSwap(reflections, dividendToTokenPath, address(this));
            emit TokenBuyBackFromDividend(reflections, _tokenAmt);
        }
    }

    /**
     * @notice Add liquidity
     */
    function addLiquidity() external onlyOwner {
        uint256 ethAmt = address(this).balance;
        ethAmt = (ethAmt * addLiquidityRate) / PERCENT_PRECISION / 2;

        if (ethAmt > 0) {
            uint256 _tokenAmt = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            emit TokenBuyBack(ethAmt, _tokenAmt);

            (uint256 amountToken, uint256 amountETH, uint256 liquidity) =
                _addLiquidityEth(address(token), ethAmt, _tokenAmt, address(this));
            emit LiquidityAdded(amountETH, amountToken, liquidity);
        }
    }

    /**
     * @notice Swap and harvest reflection for token
     * @param _to: receiver address
     */
    function harvest(address _to) external onlyOwner {
        uint256 ethAmt = address(this).balance;
        ethAmt = (ethAmt * buybackRate) / PERCENT_PRECISION;

        if (dividendToken == address(0x0)) {
            if (ethAmt > 0) {
                payable(_to).transfer(ethAmt);
                emit Harvested(_to, ethAmt);
            }
        } else {
            if (ethAmt > 0) {
                uint256 _tokenAmt = _safeSwapEth(ethAmt, bnbToDividendPath, address(this));
                emit Swapped(dividendToken, ethAmt, _tokenAmt);
            }

            uint256 tokenAmt = IERC20(dividendToken).balanceOf(address(this));
            if (tokenAmt > 0) {
                IERC20(dividendToken).transfer(_to, tokenAmt);
                emit Harvested(_to, tokenAmt);
            }
        }
    }

    function harvestBNB(address _to) external onlyOwner {
        require(_to != address(0x0), "invalid address");
        uint256 ethAmt = address(this).balance;
        payable(_to).transfer(ethAmt);
        emit BnbHarvested(_to, ethAmt);
    }

    function harvestBUSD(address _to) external onlyOwner {
        require(_to != address(0x0), "invalid address");
        uint256 ethAmt = address(this).balance;
        ethAmt = (ethAmt * buybackRate) / PERCENT_PRECISION;

        if (ethAmt == 0) return;

        address[] memory path = new address[](2);
        path[0] = IUniRouter02(uniRouterAddress).WETH();
        path[1] = BUSD;

        uint256[] memory amounts =
            IUniRouter02(uniRouterAddress).swapExactETHForTokens{value: ethAmt}(0, path, _to, block.timestamp + 600);

        emit BusdHarvested(_to, amounts);
    }

    function harvestUSDC(address _to) external onlyOwner {
        require(_to != address(0x0), "invalid address");
        uint256 ethAmt = address(this).balance;
        ethAmt = (ethAmt * buybackRate) / PERCENT_PRECISION;

        if (ethAmt == 0) return;

        address[] memory path = new address[](2);
        path[0] = IUniRouter02(uniRouterAddress).WETH();
        path[1] = USDC;

        uint256[] memory amounts =
            IUniRouter02(uniRouterAddress).swapExactETHForTokens{value: ethAmt}(0, path, _to, block.timestamp + 600);
        emit UsdcHarvested(_to, amounts);
    }

    /**
     * @notice Withdraw token as much as maximum 5% of total supply
     * @param _amount: amount to withdraw
     */
    function withdraw(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if (block.timestamp - startTime > period * TIME_UNIT) {
            startTime = block.timestamp;
            sumWithdrawals = 0;
        }

        uint256 limit = (withdrawalLimit * (token.totalSupply())) / PERCENT_PRECISION;
        require(sumWithdrawals + _amount <= limit, "exceed maximum withdrawal limit for 30 days");

        token.safeTransfer(msg.sender, _amount);
        emit Withdrawn(_amount);
    }

    /**
     * @notice Withdraw liquidity
     * @param _amount: amount to withdraw
     */
    function withdrawLiquidity(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = IERC20(pair).balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if (block.timestamp - startTime > period * TIME_UNIT) {
            startTime = block.timestamp;
            sumLiquidityWithdrawals = 0;
        }

        uint256 limit = (liquidityWithdrawalLimit * (IERC20(pair).totalSupply())) / PERCENT_PRECISION;
        require(sumLiquidityWithdrawals + _amount <= limit, "exceed maximum LP withdrawal limit for 30 days");

        IERC20(pair).safeTransfer(msg.sender, _amount);
        emit LiquidityWithdrawn(_amount);
    }

    /**
     * @notice Withdraw tokens
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if (tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }

        tokenAmt = IERC20(pair).balanceOf(address(this));
        if (tokenAmt > 0) {
            IERC20(pair).transfer(msg.sender, tokenAmt);
        }

        uint256 ethAmt = address(this).balance;
        if (ethAmt > 0) {
            payable(msg.sender).transfer(ethAmt);
        }
        emit EmergencyWithdrawn();
    }

    /**
     * @notice Set duration for withdraw limit
     * @param _period: duration
     */
    function setWithdrawalLimitPeriod(uint256 _period) external onlyOwner {
        require(_period >= 10, "small period");
        period = _period;
        emit PeriodUpdated(_period);
    }

    /**
     * @notice Set liquidity withdraw limit
     * @param _percent: percentage of LP supply in point
     */
    function setLiquidityWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < PERCENT_PRECISION, "Invalid percentage");

        liquidityWithdrawalLimit = _percent;
        emit LiquidityWithdrawLimitUpdated(_percent);
    }

    /**
     * @notice Set withdraw limit
     * @param _percent: percentage of total supply in point
     */
    function setWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < PERCENT_PRECISION, "Invalid percentage");

        withdrawalLimit = _percent;
        emit WithdrawLimitUpdated(_percent);
    }

    /**
     * @notice Set buyback rate
     * @param _percent: percentage in point
     */
    function setBuybackRate(uint256 _percent) external onlyOwner {
        require(_percent < PERCENT_PRECISION, "Invalid percentage");

        buybackRate = _percent;
        emit BuybackRateUpdated(_percent);
    }

    /**
     * @notice Set addliquidy rate
     * @param _percent: percentage in point
     */
    function setAddLiquidityRate(uint256 _percent) external onlyOwner {
        require(_percent < PERCENT_PRECISION, "Invalid percentage");

        addLiquidityRate = _percent;
        emit AddLiquidityRateUpdated(_percent);
    }

    /**
     * @notice Set percentage to transfer tokens
     * @param _percent: percentage in point
     */
    function setStakingRate(uint256 _percent) external onlyOwner {
        require(_percent < PERCENT_PRECISION, "Invalid percentage");

        stakingRate = _percent;
        emit SetStakingRateUpdated(_percent);
    }

    /**
     * @notice Set buyback wallet of farm contract
     * @param _uniRouter: dex router address
     * @param _slipPage: slip page for swap
     * @param _bnbToTokenPath: bnb-token swap path
     * @param _bnbToDividendPath: bnb-token swap path
     * @param _dividendToTokenPath: bnb-token swap path
     */
    function setSwapSettings(
        address _uniRouter,
        uint256 _slipPage,
        address[] memory _bnbToTokenPath,
        address[] memory _bnbToDividendPath,
        address[] memory _dividendToTokenPath
    ) external onlyOwner {
        require(_uniRouter != address(0x0), "invalid address");
        require(_slipPage <= slippageFactorUL, "_slippage too high");

        uniRouterAddress = _uniRouter;
        slippageFactor = _slipPage;
        bnbToTokenPath = _bnbToTokenPath;
        bnbToDividendPath = _bnbToDividendPath;
        dividendToTokenPath = _dividendToTokenPath;

        emit SetSwapConfig(_uniRouter, _slipPage, _bnbToTokenPath, _bnbToDividendPath, _dividendToTokenPath);
    }

    /**
     * @notice set buyback wallet of farm contract
     * @param _farm: farm contract address
     * @param _addr: buyback wallet address
     */
    function setFarmServiceInfo(address _farm, address _addr) external onlyOwner {
        require(_farm != address(0x0) && _addr != address(0x0), "Invalid Address");
        IFarm(_farm).setBuyBackWallet(_addr);

        emit TransferBuyBackWallet(_farm, _addr);
    }

    /**
     * @notice set buyback wallet of staking contract
     * @param _staking: staking contract address
     * @param _addr: buyback wallet address
     */
    function setStakingServiceInfo(address _staking, address _addr) external onlyOwner {
        require(_staking != address(0x0) && _addr != address(0x0), "Invalid Address");
        uint256 _fee = IStaking(_staking).performanceFee();
        IStaking(_staking).setServiceInfo(_addr, _fee);

        emit TransferBuyBackWallet(_staking, _addr);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function rescueTokens(address _token) external onlyOwner {
        require(
            _token != address(token) && _token != dividendToken && _token != pair,
            "Cannot be token & dividend token, pair"
        );

        uint256 _tokenAmount;
        if (_token == address(0x0)) {
            _tokenAmount = address(this).balance;
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            _tokenAmount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
        }
        emit AdminTokenRecovered(_token, _tokenAmount);
    }

    /**
     *
     * Internal Methods
     *
     */

    /**
     * @notice get token from ETH via swap.
     * @param _amountIn: eth amount to swap
     * @param _path: swap path
     * @param _to: receiver address
     */
    function _safeSwapEth(uint256 _amountIn, address[] memory _path, address _to) internal returns (uint256) {
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        address _token = _path[_path.length - 1];
        uint256 beforeAmt = IERC20(_token).balanceOf(address(this));
        IUniRouter02(uniRouterAddress).swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amountIn}(
            (amountOut * slippageFactor) / PERCENT_PRECISION, _path, _to, block.timestamp + 600
        );
        uint256 afterAmt = IERC20(_token).balanceOf(address(this));

        return afterAmt - beforeAmt;
    }

    /**
     * @notice swap token based on path.
     * @param _amountIn: token amount to swap
     * @param _path: swap path
     * @param _to: receiver address
     */
    function _safeSwap(uint256 _amountIn, address[] memory _path, address _to) internal returns (uint256) {
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        IERC20(_path[0]).safeApprove(uniRouterAddress, _amountIn);

        address _token = _path[_path.length - 1];
        uint256 beforeAmt = IERC20(_token).balanceOf(address(this));
        IUniRouter02(uniRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn, (amountOut * slippageFactor) / PERCENT_PRECISION, _path, _to, block.timestamp + 600
        );
        uint256 afterAmt = IERC20(_token).balanceOf(address(this));

        return afterAmt - beforeAmt;
    }

    /**
     * @notice add token-BNB liquidity.
     * @param _token: token address
     * @param _ethAmt: eth amount to add liquidity
     * @param _tokenAmt: token amount to add liquidity
     * @param _to: receiver address
     */
    function _addLiquidityEth(address _token, uint256 _ethAmt, uint256 _tokenAmt, address _to)
        internal
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity)
    {
        IERC20(_token).safeIncreaseAllowance(uniRouterAddress, _tokenAmt);

        (amountToken, amountETH, liquidity) = IUniRouter02(uniRouterAddress).addLiquidityETH{value: _ethAmt}(
            address(_token), _tokenAmt, 0, 0, _to, block.timestamp + 600
        );

        IERC20(_token).safeApprove(uniRouterAddress, uint256(0));
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniRouter01 {
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

    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

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

    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IUniRouter01.sol";

interface IUniRouter02 is IUniRouter01 {
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