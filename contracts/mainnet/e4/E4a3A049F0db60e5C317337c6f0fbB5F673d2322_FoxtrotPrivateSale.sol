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
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "contracts/utils/Whitelist.sol";

/**
 * @title Automatic Private sale
 * @author Michael Araque
 * @notice A contract that manages a Public Private Sale, purchase, claiming and vesting time
 */

contract FoxtrotPrivateSale is Whitelist {
    enum InvestorTrace {
        CLAIMED,
        LOCKED,
        TOTAL,
        BUSD_INVESTED
    }

    enum ContractDates {
        CLAIM_START,
        SALE_START,
        SALE_END,
        VESTING_PERIOD
    }

    mapping(address => bool) private firstClaim;
    mapping(address => mapping(InvestorTrace => uint256)) private accounting;
    mapping(ContractDates => uint256) private dates;

    event UpdatePrivateSaleStatus(bool isOpen);
    event ClaimToken(address tokenAddress, uint256 tokenAmount);
    event Invest(address investor, uint256 busdAmount, uint256 tokenAmount);

    address public busdContract;
    address public tokenContract;
    address public companyVault;

    bool public isPrivateSaleOpen;
    bool public isClaimEnabled;
    uint256 private tokensSoldCounter;
    uint256 public totalBusdInvested;

    uint256 private immutable TGE_PERCENT = 8;
    uint256 private immutable AFTER_TGE_BLOCK_TIME = 90 days;
    uint256 private immutable FXD_PRICE = 25000000000000000 wei;
    uint256 private immutable MIN_BUSD_ACCEPTED = 1 ether;
    uint256 private constant MAX_AMOUNT_TOKEN = 32_250_000 ether;

    constructor(address _companyVault, address _busdContract) {
        companyVault = _companyVault;
        busdContract = _busdContract;
        tokenContract = address(0);
        Whitelist.isWhitelistEnabled = true;

        tokensSoldCounter = MAX_AMOUNT_TOKEN;

        dates[ContractDates.SALE_START] = 1665504776;
        dates[ContractDates.VESTING_PERIOD] = 360 days;

        isPrivateSaleOpen = true;
    }

    /**
     * @dev This function allows to invest in the private sale
     * @param amount Amount in BUSD to be invested in wei format
     */
    function invest(uint256 amount) public onlyWhitelisted {
        require(isPrivateSaleOpen, "FXD: Private Sale is closed");

        require(
            IERC20(busdContract).balanceOf(msg.sender) >= amount,
            "FXD: Insufficient BUSD"
        );
        require(
            IERC20(busdContract).allowance(msg.sender, address(this)) >= amount,
            "FXD: First grant allowance"
        );
        require(
            block.timestamp >= dates[ContractDates.SALE_START],
            "FXD: Private Sale not started yet"
        );

        if (Whitelist.isWhitelistEnabled) {
            require(
                accounting[msg.sender][InvestorTrace.BUSD_INVESTED] <=
                    Whitelist.amount[msg.sender] &&
                    amount <= Whitelist.amount[msg.sender] &&
                    accounting[msg.sender][InvestorTrace.BUSD_INVESTED] +
                        amount <=
                    Whitelist.amount[msg.sender],
                "FXD: Private Sale purchase limit"
            );
        }

        if (tokensSoldCounter >= getTokenAmount(MIN_BUSD_ACCEPTED, FXD_PRICE))
            require(amount >= MIN_BUSD_ACCEPTED, "FXD: Minimum amount 1 BUSD");

        uint256 tokensAmount = getTokenAmount(amount, FXD_PRICE);
        require(
            tokensSoldCounter > 0 && tokensSoldCounter >= tokensAmount,
            "FXD: Private complete"
        );

        handleInvestment(msg.sender, tokensAmount, amount);
        SafeERC20.safeTransferFrom(
            IERC20(busdContract),
            msg.sender,
            companyVault,
            amount
        );

        emit Invest(msg.sender, amount, tokensAmount);
    }

    /**
     * @notice This method is added to handle extremly rare cases where
     *         investor can't invest directly on Dapp
     * @param to Investor address
     * @param amount Amount to be invested in wei
     */
    function manualInvest(address to, uint256 amount) public onlyOwner {
        uint256 tokensAmount = getTokenAmount(amount, FXD_PRICE);
        handleInvestment(to, tokensAmount, amount);
        emit Invest(to, amount, tokensAmount);
    }

    /**
     * @param from Investor address
     * @param tokensAmount Amount to be invested in wei
     * @param busdAmount Amount in BUSD to be invested in wei format
     */
    function handleInvestment(
        address from,
        uint256 tokensAmount,
        uint256 busdAmount
    ) internal {
        tokensSoldCounter -= tokensAmount;
        totalBusdInvested += busdAmount;
        accounting[from][InvestorTrace.BUSD_INVESTED] += busdAmount;
        accounting[from][InvestorTrace.LOCKED] += tokensAmount;
        accounting[from][InvestorTrace.TOTAL] += tokensAmount;
    }

    /**
     * @dev ClaimToken Emit event
     * @notice This method is the main method to claim tokens
     */
    function claim() external onlyWhitelisted {
        require(isClaimEnabled, "FXD: Claim status inactive");
        require(
            accounting[msg.sender][InvestorTrace.LOCKED] > 0,
            "FXD: Already claimed your tokens"
        );

        if (!isElegibleForFirstClaim(msg.sender))
            require(
                block.timestamp >= dates[ContractDates.CLAIM_START],
                "FXD: Can't claim, 90 days cliff"
            );

        uint256 claimableTokens = handleClaim(msg.sender);
        SafeERC20.safeTransfer(
            IERC20(tokenContract),
            msg.sender,
            claimableTokens
        );

        emit ClaimToken(tokenContract, claimableTokens);
    }

    /**
     * @param from Address of the investor
     * @return uint256 Returns the total claimable amount of tokens
     */
    function handleClaim(address from) internal returns (uint256) {
        uint256 claimableTokens = getClaimableAmountOfTokens(from);

        if (isElegibleForFirstClaim(from) && isClaimEnabled) {
            firstClaim[msg.sender] = true;
        }

        accounting[from][InvestorTrace.LOCKED] -= claimableTokens;
        accounting[from][InvestorTrace.CLAIMED] += claimableTokens;

        return claimableTokens;
    }

    /**
     * @notice This method is a little middleware that handle if the investor
     *         is elegible for first claim
     * @param investor Address of the investor
     */
    function isElegibleForFirstClaim(address investor)
        public
        view
        returns (bool)
    {
        return !firstClaim[investor];
    }

    /**
     * @param from Address of the investor
     * @return uint256 Returns the total amount of token tha the investor can claim
     */
    function getClaimableAmountOfTokens(address from)
        public
        view
        returns (uint256)
    {
        uint256 _TGEPercent = getTGEPercent(from);

        if (
            isElegibleForFirstClaim(from) &&
            isClaimEnabled &&
            dates[ContractDates.CLAIM_START] != 0
        ) {
            return _TGEPercent;
        } else if (
            block.timestamp < dates[ContractDates.CLAIM_START] ||
            dates[ContractDates.CLAIM_START] == 0
        ) {
            return 0;
        } else if (
            block.timestamp >=
            dates[ContractDates.CLAIM_START] +
                dates[ContractDates.VESTING_PERIOD]
        ) {
            return accounting[from][InvestorTrace.LOCKED];
        } else {
            uint256 amount = (((accounting[from][InvestorTrace.TOTAL] -
                _TGEPercent) *
                (block.timestamp - dates[ContractDates.CLAIM_START])) /
                dates[ContractDates.VESTING_PERIOD]) -
                (totalClaimedOf(from) - _TGEPercent);
            return amount;
        }
    }

    /**
     * @dev This method is used to calculate the amount of tokens that available on his
     *      account in the TGE event
     * @param from Address of the investor
     */
    function getTGEPercent(address from)
        internal
        view
        virtual
        returns (uint256)
    {
        return (accounting[from][InvestorTrace.TOTAL] * TGE_PERCENT) / 100;
    }

    /**
     * @notice Enabled first claim and active cliff time of 3 months
     */
    function changeClaimStatus() external onlyOwner returns (bool) {
        require(!isClaimEnabled, "FXD: Claim already enabled");
        isClaimEnabled = true;
        dates[ContractDates.CLAIM_START] =
            block.timestamp +
            AFTER_TGE_BLOCK_TIME;
        return true;
    }

    /**
     * @notice This method returns the exact date when the tokens
     *         start to vesting
     */
    function claimStartAt() external view returns (uint256) {
        return dates[ContractDates.CLAIM_START];
    }

    /**
     * @param from Address of the wallet that previously invested
     * @return uint256 Returns the total amount of tokens that are locked
     */
    function totalLockedOf(address from) public view returns (uint256) {
        return accounting[from][InvestorTrace.LOCKED];
    }

    /**
     * @param from Address of the wallet that previously invested
     * @return uint256 Returns the amount of tokens that were already claimed
     */
    function totalClaimedOf(address from) public view returns (uint256) {
        return accounting[from][InvestorTrace.CLAIMED];
    }

    /**
     * @param from Address of the wallet that previously invested
     * @return uint256 Returns the the total amount of tokens
     */
    function totalOf(address from) public view returns (uint256) {
        return accounting[from][InvestorTrace.TOTAL];
    }

    /**
     * @param from Address of the wallet that previously invested
     * @return uint256 Returns the amount of tokens that can be claimed
     */
    function availableOf(address from) external view returns (uint256) {
        return getClaimableAmountOfTokens(from);
    }

    /**
     * @param from Address of the wallet that previously invested
     * @return uint256 Returns the total of BUSD invested by the investor
     */
    function totalBusdInvestedOf(address from) public view returns (uint256) {
        return accounting[from][InvestorTrace.BUSD_INVESTED];
    }

    /**
     * @param from Address of the investor
     * @return total Total of buyed tokens by the investor
     * @return claimed Total of tokens that were already claimed
     * @return locked Total of tokens that are locked
     * @return available Total of tokens that can be claimed
     */
    function investorAccounting(address from)
        external
        view
        returns (
            uint256 total,
            uint256 claimed,
            uint256 locked,
            uint256 available,
            uint256 busd
        )
    {
        total = totalOf(from);
        claimed = totalClaimedOf(from);
        locked = totalLockedOf(from);
        available = getClaimableAmountOfTokens(from);
        busd = totalBusdInvestedOf(from);
    }

    /**
     * @param from Address of the investor
     * @return uint256 Returns the total amount of tokens that the investor has invested
     */
    function historicalBalance(address from) external view returns (uint256) {
        return (accounting[from][InvestorTrace.LOCKED] +
            accounting[from][InvestorTrace.CLAIMED]);
    }

    /**
     * @param amount Amount in wei
     * @param tokenPrice Price of the token in wei
     * @return uint256 Amount without decimals
     */
    function getTokenAmount(uint256 amount, uint256 tokenPrice)
        internal
        pure
        returns (uint256)
    {
        return (amount / tokenPrice) * (10**18);
    }

    /**
     * @notice This method is a helper function that allows to close the private sale manually
     */
    function setSaleEnd() external onlyOwner {
        isPrivateSaleOpen = false;
        emit UpdatePrivateSaleStatus(false);
    }

    /**
     * @notice This method is a helper function that allows to open the private sale manually
     */
    function openPrivateSale() external onlyOwner {
        isPrivateSaleOpen = true;
        emit UpdatePrivateSaleStatus(true);
    }

    /**
     * @return bool Show is the privatesale is open or closed
     */
    function showPrivateSaleStatus() external view returns (bool) {
        return isPrivateSaleOpen;
    }

    /**
     * @param fxdToken Contract address of FXD Token
     */
    function setContractToken(address fxdToken)
        external
        onlyOwner
        returns (bool)
    {
        tokenContract = fxdToken;
        return true;
    }

    /**
     * @param token Address of the contract
     * @return uint256 Return balance of the tokens contained in this address
     */
    function balance(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    /**
     * @notice This method allow the owner of the contract to transfer specific
     *         amount of non Foxtrot tokens to a specific address manually
     * @param token Address of the token contract
     * @param receiver Address of the wallet that will receive the tokens
     * @param amount Amount of tokens to be transfered
     */
    function withdraw(
        address token,
        address receiver,
        uint256 amount
    ) external onlyOwner returns (bool) {
        require(
            token != tokenContract,
            "FXD: You can't withdraw Foxtrot Tokens"
        );
        IERC20 Token = IERC20(token);
        require(
            Token.balanceOf(address(this)) >= amount,
            "FXD: Insufficient amount"
        );
        Token.transfer(receiver, amount);
        return true;
    }

    /**
     * @notice Return all excess tokens in the Private Sale Contract
     *         to the Foxtrot Command (FXD) Contract
     */
    function purgeNonSelledTokens() external onlyOwner {
        SafeERC20.safeTransfer(
            IERC20(tokenContract),
            tokenContract,
            tokensSoldCounter
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable {
    bool public isWhitelistEnabled;

    mapping(address => bool) public whitelist;
    mapping(address => uint256) public amount;

    event WhitelistedAddressAdded(address addr, uint256 amount);
    event WhitelistedAddressRemoved(address addr);
    event WhitelistEnabled(address who);
    event WhitelistDisabled(address who);

    modifier onlyWhitelisted() {
        if (isWhitelistEnabled) {
            require(whitelist[msg.sender], "FXD: Not on the whitelist");
        }
        _;
    }

    function addAddressToWhitelist(address addr, uint256 _amount)
        public
        onlyOwner
        returns (bool success)
    {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            amount[addr] = _amount;
            emit WhitelistedAddressAdded(addr, _amount);
            success = true;
        }
    }

    function addAddressesToWhitelist(
        address[] calldata addrs,
        uint256[] calldata _amount
    ) public onlyOwner returns (bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i], _amount[i])) {
                success = true;
            }
        }
    }

    function removeAddressFromWhitelist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            amount[addr] = 0;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    function removeAddressesFromWhitelist(address[] calldata addrs)
        public
        onlyOwner
        returns (bool success)
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    function disableWhitelist() external onlyOwner {
        isWhitelistEnabled = false;
        emit WhitelistDisabled(msg.sender);
    }

    function enableWhitelist() external onlyOwner {
        isWhitelistEnabled = true;
        emit WhitelistEnabled(msg.sender);
    }

}