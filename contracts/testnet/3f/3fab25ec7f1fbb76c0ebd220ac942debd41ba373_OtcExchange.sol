/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

// File: contracts/OtcErrors.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
    

error BaseTokenNotAllowed(address tokenBase);
error OrderIDDoesNotExists(
    address tokenBase, 
    uint256 orderID
    );
error InsufficientFunds(
    address tokenAddress, 
    uint256 tokenAmount, 
    uint256 tokenFunds
    );
error OrderNotActive(
    uint256 orderID, 
    address tokenBase, 
    bool orderClass
    );
error InvalidOwner(
    uint256 orderID, 
    address tokenBase, 
    bool orderClass
    );
error InvalidAmount(
    uint256 orderID, 
    address tokenBase, 
    bool orderClass
    );
error InsufficientFundsOnTakeOrderFixed(
    address tokenBase, 
    address tokenQuote, 
    uint256 senderBalance, 
    uint256 makerBalance, 
    bool orderType
    );
error InvalidFeesReceiver(address feesReceiver);
error FeesTooHigh(uint256 platformFees);
// File: contracts/OrderFixed.sol


pragma solidity ^0.8.16;


// structure
struct OrderFixed {
    address tokenBase;
    address tokenQuote;
    address maker;
    uint256 amountBase;
    uint256 amountQuote;
    uint256 price;
    uint256 decimalPrice;
    uint256 orderID;
    bool orderType;
    uint128 createdAt;
    uint128 expirationTime;
}



// File: contracts/IOrderFixed.sol


pragma solidity ^0.8.16;



interface IOrderFixed {


    event OrderFixedBuyCreated(
        bytes32 indexed orderID,
        uint256 amountBase,
        uint256 amountQuote,
        address indexed tokenBase,
        address indexed tokenQuote,
        uint128 expirationTime
    );
    event OrderFixedSellCreated(
        bytes32 indexed orderID,
        uint256 amountBase,
        uint256 amountQuote,
        address indexed tokenBase,
        address indexed tokenQuote
    );
    event OrderFixedFulFilled(
        bytes32 indexed orderID,
        address indexed tokenBase,
        address indexed tokenQuote
    );

    event OrderFixedCancelled(
        bytes32 indexed orderID,
        address indexed tokenBase,
        address indexed tokenQuote
    );

    event OrderFixedUpdated(
        bytes32 indexed orderID,
        address indexed tokenBase,
        address indexed tokenQuote,
        uint256 amountBase,
        uint256 price,
        bool orderType,
        uint128 creationTimestamp,
        uint128 expirationTime
    );

    /**
    *   @dev create an Escrew Order
    *
    *   @param tokenBase : address of the main token in the pair
    *   @param tokenQuote : address of the token being exchanged for the main token
    *   @param amountBase : amount of base tokens 
    *   @param amountQuote : amount of tokens exchanged for the main token
    *   @param price : price (all significant digits)
    *   @param decimalPrice : number or decimals for the price
    *   @param orderType : type of the order (true: buy, false: sell)
    *   @param expirationTime : expiration timestamp of the order 
    *
    *   Emits a {OrderEscrowBuyCreated} event
    *   Emits a {OrderEscrowSellCreated} event
    */
    function createOrderFixed(
        address tokenBase,
        address tokenQuote,
        uint256 amountBase,
        uint256 amountQuote,
        uint256 price,
        uint256 decimalPrice,
        bool orderType,
        uint128 expirationTime
    ) external returns (bool success);


    /**
    *   @dev Take an fixed Order (only total order filling is allowed)
    *
    *   @param orderID : unique id of the order being canceled
    *   @param tokenBase : address of the main token in the pair
    *   @param tokenQuote : address of the token being exchanged for the main token
    *
    *   Emits a {OrderFixedFulFilled} event

    */
    function takeOrderFixed(
        uint256 orderID,
        address tokenBase,
        address tokenQuote
    ) external returns (bool success);
    


    /**
    *   @dev Cancel a order already created
    *
    *   @param orderID : unique id of the order being canceled
    *   @param tokenBase : address of the main token in the pair
    *   @param tokenQuote : address of the token being exchanged for the main token
    *
    *   Emits a {OrderEscrowCancelled} event
    */
    function cancelOrderFixed(
        uint256 orderID,
        address tokenBase,
        address tokenQuote
    ) external returns (bool success);

    /**
    *   @dev Update a selected fixed order 
    * 
    *   @param orderID : unique id of the order being created
    *   @param tokenBase : address of the main token in the pair
    *   @param tokenQuote : address of the token being exchanged for the main token
    *   @param amountBase : amount of base tokens 
    *   @param price : price (all significant digits)
    *   @param expirationTime : expiration time of the fixed order 
    *   @return success : true if the order has been successfully created
    *   Emits a {OrderFixedUpdated} event
    */
    function updateOrderFixed(
        uint256 orderID, 
        address tokenBase, 
        address tokenQuote, 
        uint256 amountBase, 
        uint256 price,
        uint128 expirationTime
    ) external returns (bool success);


    /**
     *   @dev Return a selected fixed order
     *   @param orderID : ID of the examined order
     *   @param tokenBase : The address of the main token market
     *   @return orderSelected : the order being selected
     */
    function getOrderFixed(
        uint256 orderID,
        address tokenBase
    ) external view returns (OrderFixed memory orderSelected);

}
// File: contracts/OrderEscrow.sol


pragma solidity ^0.8.16;



struct OrderEscrow{
    address tokenBase;
    address tokenQuote;
    address maker;
    uint256 amountBase;
    uint256 amountQuote;
    uint256 price;
    uint256 decimalPrice;
    uint256 orderID;
    bool orderType;
    uint256 createdAt;
}



// File: contracts/IOrderEscrow.sol


pragma solidity ^0.8.16;


/**
 * @dev Interface of the Escrow order
 *
 */
interface IOrderEscrow {


    event OrderEscrowBuyCreated(
        bytes32 indexed orderID,
        uint256 amountBase,
        uint256 amountQuote,
        address indexed tokenBase,
        address indexed tokenQuote
    );
    event OrderEscrowSellCreated(
        bytes32 indexed orderID,
        uint256 amountBase,
        uint256 amountQuote,
        address indexed tokenBase,
        address indexed tokenQuote
    );
    event OrderEscrowPartialFilled(
        bytes32 indexed orderID,
        uint256 amountLastBase,
        uint256 amountLastQuote
    );
    event OrderEscrowFulFilled(
        bytes32 indexed orderID,
        address indexed tokenBase,
        address indexed tokenQuote
    );

    event OrderEscrowCancelled(
        bytes32 indexed orderID,
        address indexed tokenBase,
        address indexed tokenQuote
    );

    event OrderEscrowUpdated(
        bytes32 indexed orderID,
        address indexed tokenBase,
        address indexed tokenQuote,
        uint256 amountBase,
        uint256 price,
        bool orderType,
        uint256 creationTimestamp
    );



    /**
    *   @dev create an Escrew Order
    *
    *   @param tokenBase : address of the main token in the pair
    *   @param tokenQuote : address of the token being exchanged for the main token
    *   @param amountBase : amount of base tokens 
    *   @param amountQuote : amount of tokens exchanged for the main token
    *   @param price : price (all significant digits)
    *   @param decimalPrice : number or decimals for the price
    *   @param orderType : type of the order (true: buy, false: sell)
    *   @return success : true if the order has been successfully created
    *
    *   Emits a {OrderEscrowBuyCreated} event
    *   Emits a {OrderEscrowSellCreated} event
    */
    function createOrderEscrow(
        address tokenBase,
        address tokenQuote,
        uint256 amountBase,
        uint256 amountQuote,
        uint256 price,
        uint256 decimalPrice,
        bool orderType
    ) external returns (bool success);


    /**
    *   @dev Take an escrow Order (only total order filling is allowed)
    *
    *   @param orderID : unique id of the order being canceled
    *   @param tokenBase : address of the main token in the pair
    *   @param tokenQuote : address of the token being exchanged for the main token
    *   @param amountToken  : amount of tokens being either purchased or sold
    *   @return success : true if the order has been successfully taken
    *   Emits a {OrderEscrowPartialFilled} event if the order has been partially filled
    *   Emits a {OrderEscrowFulFilled} event if the order has been fulfilled

    */
    function takeOrderEscrow(
        uint256 orderID,
        address tokenBase,
        address tokenQuote,
        uint256 amountToken
    ) external returns (bool success);
    


    /**
    *   @dev Cancel a order already created
    *
    *   @param orderID : unique id of the order being canceled
    *   @param tokenBase : address of the main token in the pair
    *   @param tokenQuote : address of the token being exchanged for the main token
    *
    *   Emits a {OrderEscrowCancelled} event
    */
    function cancelOrderEscrow(
        uint256 orderID,
        address tokenBase,
        address tokenQuote
    ) external returns (bool success);

    /**
    *   @dev Update a selected fixed order 
    * 
    *   @param orderID : unique id of the order being created
    *   @param tokenBase : address of the main token in the pair
    *   @param tokenQuote : address of the token being exchanged for the main token
    *   @param amountBase : amount of base tokens 
    *   @param price : price (all significant digits)
    *   @return success : true if the order has been successfully created
    *   Emits a {OrderFixedUpdated} event
    */
    function updateOrderEscrow(
        uint256 orderID, 
        address tokenBase, 
        address tokenQuote, 
        uint256 amountBase, 
        uint256 price
    ) external returns (bool success);

    /**
     *   @dev Return a selected escrow order
     *   @param orderID ID of the examined order
     *   @param tokenBase The address of the main token market
     */
    function getOrderEscrow(
        uint256 orderID,
        address tokenBase
    ) external view returns (OrderEscrow memory orderSelected);

}
// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
}

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: contracts/OtcExchange.sol


pragma solidity ^0.8.16;










contract OtcExchange is IOrderEscrow, IOrderFixed, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 private _platformFee;
    uint256 private _platformFeeDivider;
    uint256 private _totalTrades;
    uint256 private _totalOrders;

    uint256 private _priceDecimals = 18;

    // address

    address private _feeReceiver;
    address DEAD = address(0x0000000000000000000000000000000000000000);
    address zero = address(0x000000000000000000000000000000000000dEaD);

    // mappings
    mapping(address => bool) private availableBaseTokens;

    //  mapping(uint256 => Order) public orders;
    mapping(address => uint256) private lastOrderIDPerToken;

    mapping(address => mapping(uint256 => OrderEscrow)) private marketsEscrow;
    mapping(address => mapping(uint256 => OrderFixed)) private marketsFixed;

    mapping(uint256 => bool) private availableOrderIDs;

    event EmergencySweep(
        address _feeReceiver, 
        uint256 amountRescued
    );
    // modifiers

    modifier canTakeOrder(
        uint256 orderID,
        address tokenBase,
        bool orderClass
    ) {
        if(!availableBaseTokens[tokenBase])
            revert BaseTokenNotAllowed(tokenBase);

        if( !isActive(orderID, tokenBase, orderClass) )
            revert OrderNotActive(orderID, tokenBase, orderClass);
        _;
    }

    modifier canCancelOrder(
        uint256 orderID,
        address tokenBase,
        bool orderClass
    ) {
        if(!availableBaseTokens[tokenBase])
            revert BaseTokenNotAllowed(tokenBase);
        if( !isActive(orderID, tokenBase, orderClass) )
            revert OrderNotActive(orderID, tokenBase, orderClass);
        if( msg.sender != getMaker(orderID, tokenBase, orderClass))
            revert InvalidOwner(orderID, tokenBase, orderClass);

        _;
    }

    modifier canUpdateOrder(
        uint256 orderID,
        address tokenBase,
        uint256 amountBase,
        bool orderClass
    ) {
        if(!availableBaseTokens[tokenBase])
            revert BaseTokenNotAllowed(tokenBase);
        if( !isActive(orderID, tokenBase, orderClass) )
            revert OrderNotActive(orderID, tokenBase, orderClass);
        if( msg.sender != getMaker(orderID, tokenBase, orderClass))
            revert InvalidOwner(orderID, tokenBase, orderClass);
        if( amountBase <= 0 )
            revert InvalidAmount(orderID, tokenBase, orderClass);
        _;
    }

    constructor() payable {
        // to be changed
        _platformFee = 10;
        _platformFeeDivider = 1000;
    }

    function createOrderFixed(
        address tokenBase,
        address tokenQuote,
        uint256 amountQuote,
        uint256 amountBase,
        uint256 price,
        uint256 decimalPrice,
        bool orderType,
        uint128 expirationTime
    )  external 
       nonReentrant 
       returns (bool success) {
        if(!availableBaseTokens[tokenBase])
            revert BaseTokenNotAllowed(tokenBase);

        uint256 thisOrderID = lastOrderIDPerToken[tokenBase] + 1;

        // transfer funds

        if (orderType) {
            // buy order
            IERC20 tokenQuoteERC = IERC20(tokenQuote);
            uint256 userBalance = tokenQuoteERC.balanceOf(msg.sender);
            if (userBalance < amountQuote) {
                revert InsufficientFunds(
                    tokenBase,
                    amountQuote,
                    userBalance
                );
            }

            emit OrderFixedBuyCreated(
                bytes32(thisOrderID),
                amountBase,
                amountQuote,
                tokenBase,
                tokenQuote,
                expirationTime
            );

  


        } else {
            //sell order
            IERC20 tokenBaseERC = IERC20(tokenBase);
            uint256 userBalance = tokenBaseERC.balanceOf(address(msg.sender));
            if (userBalance < amountBase) {
                revert InsufficientFunds(
                    tokenBase,
                    amountBase,
                    userBalance
                );
            }


            emit OrderFixedSellCreated(
                bytes32(thisOrderID),
                amountBase,
                amountQuote,
                tokenBase,
                tokenQuote
            );

        }

        marketsFixed[tokenBase][thisOrderID] = OrderFixed(
            tokenBase,
            tokenQuote,
            msg.sender,
            amountBase,
            amountQuote,
            price,
            decimalPrice,
            thisOrderID,
            orderType,
            uint128(block.timestamp),
            expirationTime
        );
        lastOrderIDPerToken[tokenBase] = thisOrderID;

        availableOrderIDs[thisOrderID] = true; 
        _totalOrders = _totalOrders + 1;

        return true;
    }

    function takeOrderFixed(
        uint256 orderID,
        address tokenBase,
        address tokenQuote
    ) external 
      canTakeOrder(orderID, tokenBase, true) 
      nonReentrant 
      returns (bool success) {
        IERC20 tokenQuoteERC = IERC20(tokenQuote);
        IERC20 tokenBaseERC = IERC20(tokenBase);

        OrderFixed memory orderSelected = marketsFixed[tokenBase][orderID];

        if (orderSelected.orderType) {
            // buy order
            if(
                IERC20(tokenBase).balanceOf(msg.sender) <=
                    orderSelected.amountBase || 
                IERC20(tokenQuote).balanceOf(orderSelected.maker) <= 
                    orderSelected.amountQuote
            )
            revert InsufficientFundsOnTakeOrderFixed(
                tokenBase,
                tokenQuote,
                IERC20(tokenBase).balanceOf(msg.sender),
                IERC20(tokenQuote).balanceOf(orderSelected.maker),
                orderSelected.orderType
            );
          
            // transfer the base tokens to the buyer minus the fees

            tokenBaseERC.safeTransferFrom(
                msg.sender,
                orderSelected.maker,
                orderSelected.amountBase - ( (orderSelected.amountBase * _platformFee) / _platformFeeDivider)
            );



            // transfer the quote token to the seller minus the fees
            tokenQuoteERC.safeTransferFrom(
                orderSelected.maker,
                msg.sender,
                orderSelected.amountQuote -  ( (orderSelected.amountQuote * _platformFee) / _platformFeeDivider)
            );
       
            // transfer the fees to the platform 

            tokenBaseERC.safeTransferFrom(
                msg.sender,
                _feeReceiver,
               ( (orderSelected.amountBase * _platformFee) / _platformFeeDivider)
            );

            tokenQuoteERC.safeTransferFrom(
                orderSelected.maker,
                _feeReceiver,
                orderSelected.amountQuote -  ( (orderSelected.amountQuote * _platformFee) / _platformFeeDivider)
            );

            // order fulfilled, delete from the market orders
            delete marketsFixed[tokenBase][orderID];
            delete availableOrderIDs[orderID];
            emit OrderFixedFulFilled(bytes32(orderID), tokenBase, tokenQuote);

            return true;

        } else {
            // sell order
            if(
                    IERC20(tokenBase).balanceOf(orderSelected.maker) <=
                        orderSelected.amountBase || 
                    IERC20(tokenQuote).balanceOf(msg.sender) <= 
                        orderSelected.amountQuote
                )
                revert InsufficientFundsOnTakeOrderFixed(
                    tokenBase,
                    tokenQuote,
                    IERC20(tokenQuote).balanceOf(msg.sender),
                    IERC20(tokenBase).balanceOf(orderSelected.maker),
                    orderSelected.orderType
                );
                

            // transfer the quote token to the seller (maker)
            tokenQuoteERC.transferFrom(
                msg.sender,
                orderSelected.maker,
                orderSelected.amountQuote - ( (orderSelected.amountQuote * _platformFee) / _platformFeeDivider)
            );

            // transfer the base tokens to the buyer (sender)
            tokenBaseERC.transferFrom(
                orderSelected.maker,
                msg.sender,
                orderSelected.amountBase -  ( (orderSelected.amountBase * _platformFee) / _platformFeeDivider)
            );

            
            // transfer the fees to the platform 

            tokenBaseERC.safeTransferFrom(
                orderSelected.maker,
                _feeReceiver,
               ( (orderSelected.amountBase * _platformFee) / _platformFeeDivider)
            );


            tokenQuoteERC.safeTransferFrom(
                msg.sender,
                _feeReceiver,
               ( (orderSelected.amountQuote * _platformFee) / _platformFeeDivider)
            );


            // check if order is fully filled
            delete marketsEscrow[tokenBase][orderID];
            delete availableOrderIDs[orderID];



            emit OrderEscrowFulFilled(bytes32(orderID), tokenBase, tokenQuote);
            return true;
        }
    }

    function cancelOrderFixed(
        uint256 orderID,
        address tokenBase,
        address tokenQuote
    ) external
      canCancelOrder(orderID, tokenBase, true) 
      nonReentrant
      returns (bool success) {
        delete marketsEscrow[tokenBase][orderID];
        delete availableOrderIDs[orderID]; 

        emit OrderFixedCancelled(bytes32(orderID), tokenBase, tokenQuote);
        return true;
    }

    function updateOrderFixed(
        uint256 orderID,
        address tokenBase,
        address tokenQuote,
        uint256 amountBase,
        uint256 price,
        uint128 expirationTime
    ) external
      canUpdateOrder(orderID, tokenBase, amountBase, true) 
      nonReentrant
      returns (bool success) {
        if (!availableOrderIDs[orderID]) {
            revert OrderIDDoesNotExists({
                tokenBase: tokenBase,
                orderID: orderID
            });
        }

        OrderFixed memory oldOrder = marketsFixed[tokenBase][orderID];
        uint256 amountQuote = amountBase * (price / 10**oldOrder.decimalPrice);

        marketsFixed[tokenBase][orderID] = OrderFixed(
            tokenBase,
            tokenQuote,
            oldOrder.maker,
            amountBase,
            amountQuote,
            price,
            oldOrder.decimalPrice,
            orderID,
            oldOrder.orderType,
            uint128(block.timestamp),
            expirationTime
        );

        emit OrderFixedUpdated(
            bytes32(orderID),
            tokenBase,
            tokenQuote,
            amountBase,
            price,
            oldOrder.orderType,
            uint128(block.timestamp),
            expirationTime
        );
        return true;
    }

    function createOrderEscrow(
        address tokenBase,
        address tokenQuote,
        uint256 amountBase,
        uint256 amountQuote,
        uint256 price,
        uint256 decimalPrice,
        bool orderType
    ) external
      nonReentrant
      returns (bool success) {
        if(!availableBaseTokens[tokenBase])
            revert BaseTokenNotAllowed(tokenBase);

        uint256 thisOrderID = lastOrderIDPerToken[tokenBase] + 1;

        // transfer funds

        if (orderType) {
            IERC20 tokenQuoteERC = IERC20(tokenQuote);
            uint256 userBalance = tokenQuoteERC.balanceOf(address(msg.sender));
            if (userBalance < amountQuote) {
                revert InsufficientFunds(
                    tokenQuote,
                    amountQuote,
                    userBalance
                );
            }


            tokenQuoteERC.safeTransferFrom(
                msg.sender,
                address(this),
                amountQuote
            );

            emit OrderEscrowBuyCreated(
                bytes32(thisOrderID),
                amountBase,
                amountQuote,
                tokenBase,
                tokenQuote
            );

        } else {
            IERC20 tokenBaseERC = IERC20(tokenBase);
            uint256 userBalance = tokenBaseERC.balanceOf(address(msg.sender));
            if (userBalance < amountBase) {
                revert InsufficientFunds(
                    tokenBase,
                    amountBase,
                    userBalance
                );
            }


            tokenBaseERC.safeTransferFrom(
                msg.sender,
                address(this),
                amountBase
            );

            emit OrderEscrowSellCreated(
                bytes32(thisOrderID),
                amountBase,
                amountQuote,
                tokenBase,
                tokenQuote
            );
        }

        marketsEscrow[tokenBase][thisOrderID] = OrderEscrow(
            tokenBase,
            tokenQuote,
            msg.sender,
            amountBase,
            amountQuote,
            price,
            decimalPrice,
            thisOrderID,
            orderType,
            block.timestamp
        );

        lastOrderIDPerToken[tokenBase] = thisOrderID;
        availableOrderIDs[thisOrderID] = true;
        return true;
    }

    function takeOrderEscrow(
        uint256 orderID,
        address tokenQuote,
        address tokenBase,
        uint256 amountToken 
    ) external 
      canTakeOrder(orderID, tokenBase, false) 
      nonReentrant
      returns (bool success) {

        
        OrderEscrow memory orderSelected = marketsEscrow[tokenBase][orderID];

        if (orderSelected.orderType) {
            /// buy order
            if( 
                amountToken < 0 || amountToken > orderSelected.amountBase
            )
                revert InvalidAmount(
                    orderID,
                    tokenBase,
                    orderSelected.orderType 
                    );

            uint256 amountQuote = (amountToken /
                (10**orderSelected.decimalPrice)) * orderSelected.price;

            if(
                amountToken > IERC20(tokenBase).balanceOf(msg.sender)
            )
                revert InsufficientFunds(
                    tokenBase,
                    amountToken,
                    IERC20(tokenBase).balanceOf(msg.sender)                   
                );


            IERC20(tokenBase).transferFrom(
                msg.sender,
                orderSelected.maker,
                amountToken -  ( (amountToken * _platformFee) / _platformFeeDivider)
            );

            IERC20(tokenQuote).transfer(
                msg.sender,
                amountQuote -  ( (amountQuote * _platformFee) / _platformFeeDivider)
            );


            // take fees

            // check if order is fully filled

            marketsEscrow[tokenBase][orderID].amountBase =
                orderSelected.amountBase -
                amountToken;

            marketsEscrow[tokenBase][orderID].amountQuote =
                orderSelected.amountQuote -
                amountQuote;

            if (orderSelected.amountBase == 0) {
                delete marketsEscrow[tokenBase][orderID];

                delete availableOrderIDs[orderID];
                emit OrderEscrowFulFilled(
                    bytes32(orderID),
                    tokenBase,
                    tokenQuote
                );
                return true;
            }

            emit OrderEscrowPartialFilled(
                bytes32(orderID),
                amountToken,
                orderSelected.amountBase
            );

            return true;
        } else {
            // sell order

            if(
                amountToken > 0 || amountToken > orderSelected.amountQuote
            )
            revert InvalidAmount( 
                orderID,
                tokenBase, 
                orderSelected.orderType
            );

            uint256 amountBase = (amountToken *
                (10**orderSelected.decimalPrice)) / orderSelected.price;

            if(
                amountToken > IERC20(tokenQuote).balanceOf(msg.sender)
            )
                revert InsufficientFunds( 
                    tokenQuote, 
                    amountToken,   
                    IERC20(tokenQuote).balanceOf(msg.sender)
                );


            IERC20(tokenQuote).transferFrom(
                msg.sender,
                orderSelected.maker,
                amountToken - ( (amountToken * _platformFee) / _platformFeeDivider)
            );
            


            IERC20(tokenQuote).transferFrom(
                msg.sender,
                orderSelected.maker,
                (amountToken * _platformFee) / _platformFeeDivider
            );


            IERC20(tokenBase).transfer(
                msg.sender,
                amountBase - ( (amountBase * _platformFee) / _platformFeeDivider)
            );

            // take fees

            IERC20(tokenBase).transfer(
                _feeReceiver,
                ( (amountBase * _platformFee) / _platformFeeDivider)
            );

            IERC20(tokenQuote).transferFrom(
                msg.sender,
                _feeReceiver,
                ( (amountToken * _platformFee) / _platformFeeDivider)
            );

            marketsEscrow[tokenBase][orderID].amountQuote =
                marketsEscrow[tokenBase][orderID].amountQuote -
                amountToken;


            if (marketsEscrow[tokenBase][orderID].amountQuote == 0) {
                delete marketsEscrow[tokenBase][orderID];
                delete availableOrderIDs[orderID];
                emit OrderEscrowFulFilled(
                    bytes32(orderID),
                    tokenBase,
                    tokenQuote
                );


                return true;
            }
         
            emit OrderEscrowPartialFilled(
                bytes32(orderID),
                marketsEscrow[tokenBase][orderID].amountBase,
                marketsEscrow[tokenBase][orderID].amountQuote
            );

            return true;
             
        }
    }

    function cancelOrderEscrow(
        uint256 orderID,
        address tokenBase,
        address tokenQuote
    ) external 
      canCancelOrder(orderID, tokenBase, false)
      nonReentrant
      returns (bool success) {
        OrderEscrow memory _orderToBeDeleted = marketsEscrow[tokenBase][
            orderID
        ];

        if (_orderToBeDeleted.orderType) {
            // buy order

            IERC20 tokenQuoteERC = IERC20(tokenQuote);
            tokenQuoteERC.transfer(
                msg.sender, 
                _orderToBeDeleted.amountQuote
            );

        } else {
            // sell order

            IERC20 tokenBaseERC = IERC20(tokenBase);
            tokenBaseERC.transfer(
                address(this),
                _orderToBeDeleted.amountBase
            );
        }

        delete marketsEscrow[tokenBase][orderID];
        delete availableOrderIDs[orderID];

        emit OrderEscrowCancelled(bytes32(orderID), tokenBase, tokenQuote);

        return true;
    }

    function updateOrderEscrow(
        uint256 orderID,
        address tokenBase,
        address tokenQuote,
        uint256 amountBase,
        uint256 price
    ) external 
      canUpdateOrder(orderID, tokenBase, amountBase, false)
      nonReentrant
      returns (bool success) {
        if (!availableOrderIDs[orderID]) {
            revert OrderIDDoesNotExists({
                tokenBase: tokenBase,
                orderID: orderID
            });
        }

        OrderEscrow memory oldOrder = marketsEscrow[tokenBase][orderID];        
        uint256 amountQuote = amountBase * (price / 10**oldOrder.decimalPrice);


        if( oldOrder.orderType){
            // buy order

            if( amountQuote > oldOrder.amountQuote){
                
                IERC20(tokenQuote).safeTransferFrom(
                    msg.sender,
                    address(this),
                    (amountQuote - oldOrder.amountQuote)
                );

            }            

            else{
                IERC20(tokenQuote).safeTransfer(
                    msg.sender,
                    (oldOrder.amountQuote - amountQuote)
                );
                
            }

        }
        else{
            // sell order
            if( amountBase > oldOrder.amountBase){

                IERC20(tokenBase).safeTransferFrom(
                    msg.sender,
                    address(this),
                    (amountBase - oldOrder.amountBase)
                );

            }            

            else{
                IERC20(tokenBase).safeTransfer(
                    msg.sender,
                    (oldOrder.amountBase - amountBase)
                );
                
            }   
            }

  
        marketsEscrow[tokenBase][orderID] = OrderEscrow(
            tokenBase,
            tokenQuote,
            oldOrder.maker,
            amountBase,
            amountQuote,
            price,
            oldOrder.decimalPrice,
            orderID,
            oldOrder.orderType,
            block.timestamp
        );

        emit OrderEscrowUpdated(
            bytes32(orderID),
            tokenBase,
            tokenQuote,
            amountBase,
            price,
            oldOrder.orderType,
            block.timestamp
        );

        return true;
    }

    // getter functions

    /**
     *   @dev Return the address of the platform's fees reciever.
     */
    function getfeeReceiver() external view returns (address feeReceiver) {
        return _feeReceiver;
    }

    /**
     *   @dev Function that returns the total amount of orders divided by type and the
     *   total amount of trades.
     */
    function getPlatformStatistics()
        external
        view
        returns (
            uint256 totalOrders,
            uint256 totalTrades
        )
    {
        return (_totalOrders, _totalTrades);
    }

    // setter functions

    /**
     *   @dev Set the reciever of the escrow platform fees
     *   @param feeReceiver address of the wallet recieving the platform fees
     */
    function setfeeReceiver(address feeReceiver) external onlyOwner {
        if(feeReceiver == DEAD || feeReceiver == zero)
            revert InvalidFeesReceiver(feeReceiver);

        _feeReceiver = feeReceiver;
    }


    /**
     *   @dev Set the amount of fees taken by the escrow platform
     *   @param platformFee quantity of fees for going to the platform 
     */
    function setFees(uint256 platformFee) external onlyOwner {
        if( platformFee < 20)
            revert FeesTooHigh( platformFee );

        _platformFee = platformFee;
    }


    /**
     *   @dev Add a Token to the list of available traded tokens
     *   @param newTokenBase The address of the new token available for trading
     *   Emits a {} event
     */
    function addTokenMarket(address newTokenBase) external onlyOwner {
        if (
            newTokenBase == DEAD ||
            newTokenBase == zero ||
            availableBaseTokens[newTokenBase]
        ) {
            revert BaseTokenNotAllowed(
                newTokenBase
            );
        }
        availableBaseTokens[newTokenBase] = true;
    }


    /**
     *   @dev Check wether a certain fixed order is active or wether a certain escrow order exists
     *   @param orderID ID of the examined order
     *   @param tokenBase address of the main token in the order
     *   @param orderClass type of order (true = fixed , false = escrow)
     *   @return true if the fixed order with "orderID" is active or the escrow order exists 
     *   Emits a {} event
     */
    function isActive(
        uint256 orderID,
        address tokenBase,
        bool orderClass
    ) internal view returns (bool) {
        if (orderClass) {
            // fixed order
            return (marketsFixed[tokenBase][orderID].expirationTime >
                block.timestamp);
        } else {
            return (availableOrderIDs[orderID]);
        }
    }

    /**
     *   @dev Return the maker of a selected order
     *   @param orderID ID of the examined order
     *   @param tokenBase address of the main token in the order
     *   @param orderClass type of order (true = fixed , false = escrow)
     *   @return maker the order maker address 
     *   Emits a {} event
     */
    function getMaker(
        uint256 orderID,
        address tokenBase,
        bool orderClass
    ) internal view returns (address maker) {
        if (orderClass) {
            // fixed order
            return (marketsFixed[tokenBase][orderID].maker);
        } else {
            // escrow order
            return (marketsEscrow[tokenBase][orderID].maker);
        }
    }

    function getOrderFixed(
        uint256 orderID,
        address tokenBase
    ) external view returns (OrderFixed memory orderSelected){

        return  marketsFixed[tokenBase][orderID];
    }


    function getOrderEscrow(
        uint256 orderID,
        address tokenBase
    ) external view returns (OrderEscrow memory orderSelected){
        
        return marketsEscrow[tokenBase][orderID];
    }

    /**
     *   @dev Last order for the selected token market
     *   @param tokenBase The address of the main token market
     *   @return orderID the id of the last order on the base token market
     */
    function getLastOrderIDPerToken(
        address tokenBase
    ) external view returns (uint256 orderID){
        return lastOrderIDPerToken[tokenBase];
    }

    /**
     * @dev withdraw ETH erroneusly sent to the contracts
     */
    function emergencySweep() external onlyOwner {

        uint256 balance = address(this).balance;
        payable(_feeReceiver).transfer(balance);

        emit EmergencySweep(_feeReceiver, balance);
    }

}