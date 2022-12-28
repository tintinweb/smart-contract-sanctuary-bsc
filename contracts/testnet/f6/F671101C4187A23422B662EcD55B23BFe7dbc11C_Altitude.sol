/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;
pragma abicoder v2;

/******************************************/
/*           IERC20 starts here           */
/******************************************/

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

/******************************************/
/*        IERC20Permit starts here        */
/******************************************/

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

/******************************************/
/*           Address starts here          */
/******************************************/

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

/******************************************/
/*          SafeERC20 starts here         */
/******************************************/

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

/******************************************/
/*           Context starts here          */
/******************************************/

// File: @openzeppelin/contracts/GSN/Context.sol

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/******************************************/
/*           Ownable starts here          */
/******************************************/

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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

/***************************************************/
/*   ILayerZeroUserApplicationConfig starts here   */
/***************************************************/

interface ILayerZeroUserApplicationConfig {
    // @notice set the configuration of the LayerZero messaging library of the specified version
    // @param _version - messaging library version
    // @param _chainId - the chainId for the pending config change
    // @param _configType - type of configuration. every messaging library has its own convention.
    // @param _config - configuration in the bytes. can encode arbitrary content.
    function setConfig(uint16 _version, uint16 _chainId, uint _configType, bytes calldata _config) external;

    // @notice set the send() LayerZero messaging library version to _version
    // @param _version - new messaging library version
    function setSendVersion(uint16 _version) external;

    // @notice set the lzReceive() LayerZero messaging library version to _version
    // @param _version - new messaging library version
    function setReceiveVersion(uint16 _version) external;

    // @notice Only when the UA needs to resume the message flow in blocking mode and clear the stored payload
    // @param _srcChainId - the chainId of the source chain
    // @param _srcAddress - the contract address of the source contract at the source chain
    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external;
}

/******************************************/
/*     ILayerZeroEndpoint starts here     */
/******************************************/

interface ILayerZeroEndpoint is ILayerZeroUserApplicationConfig {
    // @notice send a LayerZero message to the specified address at a LayerZero endpoint.
    // @param _dstChainId - the destination chain identifier
    // @param _destination - the address on destination chain (in bytes). address length/format may vary by chains
    // @param _payload - a custom bytes payload to send to the destination contract
    // @param _refundAddress - if the source transaction is cheaper than the amount of value passed, refund the additional amount to this address
    // @param _zroPaymentAddress - the address of the ZRO token holder who would pay for the transaction
    // @param _adapterParams - parameters for custom functionality. ie: pay for a specified destination gasAmount, or receive airdropped native gas from the relayer on destination
    function send(uint16 _dstChainId, bytes calldata _destination, bytes calldata _payload, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable;

    // @notice used by the messaging library to publish verified payload
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source contract (as bytes) at the source chain
    // @param _dstAddress - the address on destination chain
    // @param _nonce - the unbound message ordering nonce
    // @param _gasLimit - the gas limit for external contract execution
    // @param _payload - verified payload to send to the destination contract
    function receivePayload(uint16 _srcChainId, bytes calldata _srcAddress, address _dstAddress, uint64 _nonce, uint _gasLimit, bytes calldata _payload) external;

    // @notice get the inboundNonce of a receiver from a source chain which could be EVM or non-EVM chain
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    function getInboundNonce(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (uint64);

    // @notice get the outboundNonce from this source chain which, consequently, is always an EVM
    // @param _srcAddress - the source chain contract address
    function getOutboundNonce(uint16 _dstChainId, address _srcAddress) external view returns (uint64);

    // @notice gets a quote in source native gas, for the amount that send() requires to pay for message delivery
    // @param _dstChainId - the destination chain identifier
    // @param _userApplication - the user app address on this EVM chain
    // @param _payload - the custom message to send over LayerZero
    // @param _payInZRO - if false, user app pays the protocol fee in native token
    // @param _adapterParam - parameters for the adapter service, e.g. send some dust native token to dstChain
    function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParam) external view returns (uint nativeFee, uint zroFee);

    // @notice get this Endpoint's immutable source identifier
    function getChainId() external view returns (uint16);

    // @notice the interface to retry failed message on this Endpoint destination
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    // @param _payload - the payload to be retried
    function retryPayload(uint16 _srcChainId, bytes calldata _srcAddress, bytes calldata _payload) external;

    // @notice query if any STORED payload (message blocking) at the endpoint.
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    function hasStoredPayload(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (bool);

    // @notice query if the _libraryAddress is valid for sending msgs.
    // @param _userApplication - the user app address on this EVM chain
    function getSendLibraryAddress(address _userApplication) external view returns (address);

    // @notice query if the _libraryAddress is valid for receiving msgs.
    // @param _userApplication - the user app address on this EVM chain
    function getReceiveLibraryAddress(address _userApplication) external view returns (address);

    // @notice query if the non-reentrancy guard for send() is on
    // @return true if the guard is on. false otherwise
    function isSendingPayload() external view returns (bool);

    // @notice query if the non-reentrancy guard for receive() is on
    // @return true if the guard is on. false otherwise
    function isReceivingPayload() external view returns (bool);

    // @notice get the configuration of the LayerZero messaging library of the specified version
    // @param _version - messaging library version
    // @param _chainId - the chainId for the pending config change
    // @param _userApplication - the contract address of the user application
    // @param _configType - type of configuration. every messaging library has its own convention.
    function getConfig(uint16 _version, uint16 _chainId, address _userApplication, uint _configType) external view returns (bytes memory);

    // @notice get the send() LayerZero messaging library version
    // @param _userApplication - the contract address of the user application
    function getSendVersion(address _userApplication) external view returns (uint16);

    // @notice get the lzReceive() LayerZero messaging library version
    // @param _userApplication - the contract address of the user application
    function getReceiveVersion(address _userApplication) external view returns (uint16);
}

/******************************************/
/*     ILayerZeroReceiver starts here     */
/******************************************/

interface ILayerZeroReceiver {
    // @notice LayerZero endpoint will invoke this function to deliver the message on the destination
    // @param _srcChainId - the source endpoint identifier
    // @param _srcAddress - the source sending contract address from the source chain
    // @param _nonce - the ordered message nonce
    // @param _payload - the signed payload is the UA bytes has encoded to be sent
    function lzReceive(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) external;
}

/******************************************/
/*        IAltitudeFee starts here        */
/******************************************/

interface IAltitudeFee {
    // @notice query the rebalance fee based on local liquidity.
    // @param idealBalance - the balance where local and remote liquidity pools are at equilibrium.
    // @param preBalance - balance of local liquidity pool before removal of liquidity.
    // @param amount - liquidity to be withdrawn from local liquidity pool.
    function getRebalanceFee(uint256 idealBalance, uint256 preBalance, uint256 amount) external view returns (uint256);

    // @notice query the parameters used to calculate the rebalance fee.
    function getFeeParameters() external view returns (uint256, uint256, uint256, uint256, uint256);
}

/******************************************/
/*          ILpToken starts here          */
/******************************************/

interface ILpToken {
    // @notice mint new LP tokens.
    // @param _to - address to mint new LP tokens to.
    // @param _amount - amount of LP tokens to mint.
    function mint(address _to, uint256 _amount) external;

    // @notice burn existing LP tokens.
    // @param _from - address to burn existing LP tokens from.
    // @param _amount - amount of LP tokens to burn.
    function burn(address _from, uint256 _amount) external;
}

/******************************************/
/*          IFactory starts here          */
/******************************************/

interface IFactory {
    // @notice deploy a LP token contract for a new chain path.
    // @param _name - name of the LP token.
    // @param _symbol - symbol of the LP token.
    function newLpToken(string memory _name, string memory _symbol) external returns (address);
}

/******************************************/
/*          ALTITUDE starts here          */
/******************************************/

contract Altitude is Ownable, ILayerZeroReceiver, ILayerZeroUserApplicationConfig {
    using SafeERC20 for IERC20;

    // CONSTANTS  
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));
    uint8 internal constant TYPE_SWAP = 1;
    uint8 internal constant TYPE_SWAP_CONFIRM = 2;
    uint8 internal constant TYPE_SWAP_REVOKE = 3;
    uint8 internal constant TYPE_ADD_LIQUIDITY = 4;
    uint8 internal constant TYPE_REMOVE_LIQUIDITY_LOCAL = 5;
    uint8 internal constant TYPE_REMOVE_LIQUIDITY_REMOTE = 6;
    uint8 internal constant TYPE_REMOVE_LIQUIDITY_REMOTE_CONFIRM = 7;
    uint8 internal constant TYPE_REMOVE_LIQUIDITY_REMOTE_REVOKE = 8;


    // STRUCTS
    struct ChainPath {
        bool ready;
        address srcToken;
        uint16 dstChainId;
        address dstToken;
        uint256 remoteLiquidity;
        uint256 localLiquidity;
        uint256 rewardPoolSize;
        address lpToken;
    }

    struct PendingTx {
        uint8 txType;
        ChainPath cp;
        uint256 amount;
        bytes from;
    }

    ILayerZeroEndpoint public layerZeroEndpoint;
    IAltitudeFee public altitudeFee;
    IFactory public altitudeFactory;
    ChainPath[] public chainPaths;
    address public feeTo;
    mapping(uint16 => mapping(address => uint256)) public chainPathIndexLookup; // lookup for chainPath by chainId => token => index
    mapping(uint16 => mapping(uint8 => uint256)) public gasLookup;              // lookup for gas fee by chainId => function => gas
    mapping(uint16 => bytes) public trustedRemoteLookup;
    mapping(address => PendingTx[]) public pendingTransactions;

    // EVENTS
    event Swap(uint16 _dstChainId, address _dstToken, uint256 _amount, bytes _to);
    event AddLiquidity(uint16 _dstChainId, address _dstToken, uint256 _amount);
    event RemoveLiquidityLocal(uint16 _dstChainId, address _dstToken, uint256 _amount);
    event RemoveLiquidityRemote(uint16 _dstChainId, address _dstToken, uint256 _amount, address _to);
    event Remote_Swap(uint16 _srcChainId, address _Token, uint256 _amount, address _to);
    event Callback_Swap_Confirm(uint16 _srcChainId, address _Token, uint256 _amount, address _to);
    event Callback_Swap_Revoke(uint16 _srcChainId, address _Token, uint256 _amount, address _to);
    event Remote_AddLiquidity(uint16 _srcChainId, address _dstToken, uint256 _amount);
    event Remote_RemoveLiquidityLocal(uint16 _srcChainId, address _dstToken, uint256 _amount);
    event Remote_RemoveLiquidityRemote(uint16 _srcChainId, address _dstToken, uint256 _amount, address _to);
    event Callback_RemoveLiquidityRemote_Confirm(uint16 _srcChainId, address _dstToken, uint256 _amount, address _to);
    event Callback_RemoveLiquidityRemote_Revoke(uint16 _srcChainId, address _dstToken, uint256 _amount, address _to);

    constructor(address _endpoint, address _altitudeFee, address _altitudeFactory) {
        layerZeroEndpoint = ILayerZeroEndpoint(_endpoint);
        altitudeFee = IAltitudeFee(_altitudeFee);
        altitudeFactory = IFactory(_altitudeFactory);
    }

/******************************************/
/*           ADMIN starts here            */
/******************************************/

    /**
     * @dev Add a new chain and token pair for swapping.
     * @param _srcToken Token on the local chain.
     * @param _dstChainId Destination chain ID.
     * @param _dstToken Token on the destination chain.
     * @param _name Name of the associated LP token.
     * @param _symbol Symbol of the associated LP token.
     */
    function addChainPath(address _srcToken, uint16 _dstChainId, address _dstToken, string memory _name, string memory _symbol) external onlyOwner {
        for (uint256 i = 0; i < chainPaths.length; ++i) {
            ChainPath memory cp = chainPaths[i];
            bool exists = cp.dstChainId == _dstChainId && cp.dstToken == _dstToken;
            require(!exists, "Altitude: cant createChainPath of existing _dstChainId and _dstToken");
        }
        chainPathIndexLookup[_dstChainId][_dstToken] = chainPaths.length;
        address lpToken = altitudeFactory.newLpToken(_name, _symbol);
        chainPaths.push(ChainPath(false, _srcToken, _dstChainId, _dstToken, 0, 0, 0, lpToken));
    }

    /**
     * @dev Enable swapping for a chain and token pair.
     * @param _dstChainId Destination chain ID.
     * @param _dstToken Token on the destination chain.
     */
    function activateChainPath(uint16 _dstChainId, address _dstToken) external onlyOwner {
        ChainPath storage cp = getAndCheckCP(_dstChainId, _dstToken);
        require(cp.ready == false, "Altitude: chainPath is already active");
        // this func will only be called once
        cp.ready = true;
    }

    /**
     * @dev Set the Alititude contract for a destination chain.
     * @param _dstChainId Destination chain ID.
     * @param _dstAltitudeAddress Address of the Altitude contract at the destination chain.
     */
    function setTrustedRemoteLookup(uint16 _dstChainId, bytes calldata _dstAltitudeAddress) external onlyOwner {
        trustedRemoteLookup[_dstChainId] = abi.encodePacked(_dstAltitudeAddress, address(this));
    }

    /**
     * @dev Set the gas limit for a function type at a destination chain.
     * @param _dstChainId Destination chain ID.
     * @param _functionType Target function (SWAP, ADD, REMOVE, REDEEM).
     * @param _gasAmount Gas limit used by the target function.
     */
    function setGasAmount(uint16 _dstChainId, uint8 _functionType, uint256 _gasAmount) external onlyOwner {
        require(_functionType >= 1 && _functionType <= 8, "Altitude: invalid _functionType");
        gasLookup[_dstChainId][_functionType] = _gasAmount;
    }

    /**
     * @dev Deposit into chain path's reward pool.
     * @param _dstChainId Destination chain ID.
     * @param _dstToken Token on the destination chain.
     * @param _amount Amount of reward tokens to deposit.
     */
    function depositRewardPool(uint16 _dstChainId, address _dstToken, uint256 _amount) external onlyOwner {
        ChainPath storage cp = getAndCheckCP(_dstChainId, _dstToken);
        IERC20(cp.srcToken).transferFrom(msg.sender, address(this), _amount);
        cp.rewardPoolSize += _amount;
    }

    /**
     * @dev Withdraw from chain path's reward pool.
     * @param _dstChainId Destination chain ID.
     * @param _dstToken Token on the destination chain.
     * @param _amount Amount of reward tokens to withdraw.
     */
    function withdrawRewardPool(uint16 _dstChainId, address _dstToken, uint256 _amount, address _to) external onlyOwner {
        ChainPath storage cp = getAndCheckCP(_dstChainId, _dstToken);  
        require(cp.rewardPoolSize >= _amount, "Altitude: not enough funds in reward pool.");
        IERC20(cp.srcToken).transferFrom(address(this), _to, _amount);
        cp.rewardPoolSize -= _amount;
    }

    /**
     * @dev Set the protocol fee receiving address.
     */
    function setFeeTo(address _feeTo) external onlyOwner {
        require(_feeTo != address(0), "Altitude: recipient can't be zero address.");
        feeTo = _feeTo;
    }

    function setFeeContract(address _newFeeContract) external onlyOwner {
        altitudeFee = IAltitudeFee(_newFeeContract);
    }

/******************************************/
/*           LOCAL starts here            */
/******************************************/

    /**
     * @dev Swap local tokens for tokens on another chain.
     * @param _dstChainId ID of destination chain.
     * @param _dstToken Address of token on the destination chain (in).
     * @param _amount Amount of tokens to swap.
     * @param _to Address of recipient on the destination chain.
     */
    function swap(uint16 _dstChainId, address _dstToken, uint256 _amount, bytes memory _to) public payable {
        // (1) LOCAL:                                                              (Tokens IN)                     
        // (2) REMOTE CONFIRM:      remoteLiquidity ++      localLiquidity --      (Tokens OUT)     
        //     LOCAL CONFIRM:       remoteLiquidity --      localLiquidity ++
        //     REMOTE REVOKE:           
        //     LOCAL REVOKE:                                                       (Tokens OUT)  
        ChainPath storage cp = getAndCheckCP(_dstChainId, _dstToken);
        require(cp.remoteLiquidity >= _amount, "Altitude: not enough liquidity");
        // Deposit tokens without increasing local liquidity to prevent loss of funds in unconfirmed swap.
        IERC20(cp.srcToken).safeTransferFrom(msg.sender, address(this), _amount);

        bytes memory payload = abi.encode(TYPE_SWAP, abi.encodePacked(cp.srcToken), _amount, _to, abi.encodePacked(msg.sender));
        executeLayerZero(TYPE_SWAP, cp, payload);

        emit Swap(_dstChainId, _dstToken, _amount, _to);
    }

    /**
     * @dev Add liquidity for swaps.
     * @param _dstChainId ID of destination chain.
     * @param _dstToken Address of token on the destination chain.
     * @param _amount Amount of tokens to add as liquidity.
     */
    function addLiquidity(uint16 _dstChainId, address _dstToken, uint256 _amount) public payable {
        //     LOCAL:               localLiquidity ++      (Tokens IN / LP Tokens OUT)               
        //     REMOTE:              remoteLiquidity ++        
        ChainPath storage cp = getAndCheckCP(_dstChainId, _dstToken);
        require(cp.ready == true, "Altitude: chainPath is not active");

        IERC20(cp.srcToken).safeTransferFrom(msg.sender, address(this), _amount);
        ILpToken(cp.lpToken).mint(msg.sender, _amount);
        cp.localLiquidity += _amount;

        bytes memory payload = abi.encode(TYPE_ADD_LIQUIDITY, abi.encodePacked(cp.srcToken), _amount);
        executeLayerZero(TYPE_ADD_LIQUIDITY, cp, payload);

        emit AddLiquidity(_dstChainId, _dstToken, _amount);
    }

    /**
     * @dev Remove local liquidity for swaps.
     * @param _dstChainId ID of destination chain.
     * @param _dstToken Address of token on the destination chain.
     * @param _amount Amount of tokens to remove from liquidity.
     */
    function removeLiquidityLocal(uint16 _dstChainId, address _dstToken, uint256 _amount) public payable {
        //     LOCAL:               localLiquidity --      (Tokens OUT / LP Tokens BURN)               
        //     REMOTE:              remoteLiquidity --  
        ChainPath storage cp = getAndCheckCP(_dstChainId, _dstToken);
        require(cp.localLiquidity >= _amount, "Altitude: not enough liquidity");

        ILpToken(cp.lpToken).burn(msg.sender, _amount);
        cp.localLiquidity -= _amount;
        IERC20(cp.srcToken).safeTransfer(msg.sender, _amount);

        bytes memory payload = abi.encode(TYPE_REMOVE_LIQUIDITY_LOCAL, abi.encodePacked(cp.srcToken), _amount);
        executeLayerZero(TYPE_REMOVE_LIQUIDITY_LOCAL, cp, payload);

        emit RemoveLiquidityLocal(_dstChainId, _dstToken, _amount);
    }

    /**
     * @dev Remove remote liquidity for swaps.
     * @param _dstChainId ID of destination chain.
     * @param _dstToken Address of token on the destination chain (in).
     * @param _amount Amount of tokens to remove from liquidity.
     */
    function removeLiquidityRemote(uint16 _dstChainId, address _dstToken, uint256 _amount, bytes memory _to) public payable {
        // (1) LOCAL:                                                              (LP Tokens IN)                     
        // (2) REMOTE CONFIRM:                              localLiquidity --      (Tokens OUT)     
        //     LOCAL CONFIRM:       remoteLiquidity --      
        //     REMOTE REVOKE:                                                      (LP Tokens OUT)
        //     LOCAL REVOKE:                                                       (LP Tokens BURN) 
        ChainPath storage cp = getAndCheckCP(_dstChainId, _dstToken);
        require(cp.remoteLiquidity >= _amount, "Altitude: not enough liquidity");
        require(IERC20(cp.lpToken).balanceOf(msg.sender) >= _amount, "Altitude: not enough LP tokens");
        // Burn LP Tokens only after confirmation to prevent loss of funds in unconfirmed withdrawal.
        IERC20(cp.lpToken).safeTransferFrom(msg.sender, address(this), _amount);
        
        bytes memory payload = abi.encode(TYPE_REMOVE_LIQUIDITY_REMOTE, abi.encodePacked(cp.srcToken), _amount, _to, abi.encodePacked(msg.sender));
        executeLayerZero(TYPE_REMOVE_LIQUIDITY_REMOTE, cp, payload);
        
        emit RemoveLiquidityRemote(_dstChainId, _dstToken, _amount, msg.sender);
    }

    /**
     * @dev Confirm swap or withdrawal.
     * @param _Id Id of pending swap or withdrawal.
     */
    function confirmPendingTransaction(uint256 _Id) public payable {
        PendingTx storage pt = pendingTransactions[msg.sender][_Id];
        ChainPath storage cp = pt.cp;

        // SWAP REMOTE CONFIRM
        if (pt.txType == TYPE_SWAP) {
            require(cp.localLiquidity >= pt.amount, "Altitude: not enough liquidity");
            // rebalance fee applies when swap moves local liquidity away from liquidity equilibrium. Deposit into local reward pool.
            (uint256 rebalanceFee, uint256 protocolFee) = getFees(cp.dstChainId, cp.dstToken, pt.amount);
            uint256 swapAmount = pt.amount - (rebalanceFee + protocolFee);
            // rebalance reward applies when swap moves local liquidity to liquidity equilibrium. Disburse from local reward pool.
            uint256 rebalanceReward = getRebalanceReward(cp.dstChainId, cp.dstToken, pt.amount);
            cp.rewardPoolSize -= rebalanceReward;
            cp.rewardPoolSize += rebalanceFee;
            cp.localLiquidity -= swapAmount;
            cp.remoteLiquidity += pt.amount;
            IERC20(cp.srcToken).safeTransfer(msg.sender, swapAmount + rebalanceReward);
            IERC20(cp.srcToken).safeTransfer(feeTo, protocolFee);
            bytes memory payload = abi.encode(TYPE_SWAP_CONFIRM, abi.encodePacked(cp.srcToken), pt.amount, swapAmount, msg.sender);
            executeLayerZero(TYPE_SWAP_CONFIRM, cp, payload);

        // REMOVE LIQUIDITY REMOTE CONFIRM
        } else if (pt.txType == TYPE_REMOVE_LIQUIDITY_REMOTE) {
            require(cp.localLiquidity >= pt.amount, "Altitude: not enough liquidity");
            // apply protocol fee when removing liquidity across chains.
            (, uint256 protocolFee) = getFees(cp.dstChainId, cp.dstToken, pt.amount);
            uint256 swapAmount = pt.amount - protocolFee;
            cp.localLiquidity -= swapAmount;
            IERC20(cp.srcToken).safeTransfer(msg.sender, swapAmount);
            IERC20(cp.srcToken).safeTransfer(feeTo, protocolFee);
            bytes memory payload = abi.encode(TYPE_REMOVE_LIQUIDITY_REMOTE_CONFIRM, abi.encodePacked(cp.srcToken), pt.amount, swapAmount, msg.sender);
            executeLayerZero(TYPE_REMOVE_LIQUIDITY_REMOTE_CONFIRM, cp, payload);
        }
        delete pendingTransactions[msg.sender][_Id];
    }

    /**
     * @dev Revoke swap or withdrawal.
     * @param _Id Id of pending swap or withdrawal.
     */
    function revokePendingTransaction(uint256 _Id) public payable {
        PendingTx storage pt = pendingTransactions[msg.sender][_Id];
        ChainPath storage cp = pt.cp;

        // SWAP REMOTE REVOKE
        if (pt.txType == TYPE_SWAP) {
            bytes memory payload = abi.encode(TYPE_SWAP_REVOKE, abi.encodePacked(cp.srcToken), pt.amount, pt.from);
            executeLayerZero(TYPE_SWAP_REVOKE, cp, payload);

        // REMOVE LIQUIDITY REMOTE REVOKE
        } else if (pt.txType == TYPE_REMOVE_LIQUIDITY_REMOTE) {
            bytes memory payload = abi.encode(TYPE_REMOVE_LIQUIDITY_REMOTE_REVOKE, abi.encodePacked(cp.srcToken), pt.amount, pt.from);
            executeLayerZero(TYPE_REMOVE_LIQUIDITY_REMOTE_REVOKE, cp, payload);
        }
        delete pendingTransactions[msg.sender][_Id];
    }

    /**
     * @dev Route messages containing a target to LayerZero.
     */
    function executeLayerZero(uint8 functionType, ChainPath storage cp, bytes memory payload) internal {
        bytes memory adapterParams = getAndCheckGasFee(functionType, cp.dstChainId, payload);
        layerZeroEndpoint.send{value: msg.value}(cp.dstChainId, trustedRemoteLookup[cp.dstChainId], payload, payable(msg.sender), address(this), adapterParams);
    }

/******************************************/
/*           REMOTE starts here           */
/******************************************/

    function lzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 /*_nonce*/, bytes memory _payload) external override {
        require(msg.sender == address(layerZeroEndpoint));
        require(
            _srcAddress.length == trustedRemoteLookup[_srcChainId].length && keccak256(_srcAddress) == keccak256(trustedRemoteLookup[_srcChainId]),
            "Altitude: Invalid source sender address. owner should call setTrustedSource() to enable source contract"
        );
        
        uint8 functionType;
        assembly {
            functionType := mload(add(_payload, 32))
        }

        // SWAP (DESTINATION)   
        if (functionType == TYPE_SWAP) {
            (, bytes memory token, uint256 amount, bytes memory to, bytes memory from) = abi.decode(_payload, (uint8, bytes, uint256, bytes, bytes));
            address toAddress;
            address srcTokenAddress;
            assembly {
                toAddress := mload(add(to, 20))
                srcTokenAddress := mload(add(token, 20))
            }
            ChainPath storage cp = getAndCheckCP(_srcChainId, srcTokenAddress);
            pendingTransactions[toAddress].push(PendingTx(TYPE_SWAP, cp, amount, from));

            emit Remote_Swap(_srcChainId, srcTokenAddress, amount, toAddress);

        // SWAP CONFIRM (CALLBACK)
        } else if (functionType == TYPE_SWAP_CONFIRM) {
            (, bytes memory token, uint256 amount, uint256 swapAmount, bytes memory to) = abi.decode(_payload, (uint8, bytes, uint256, uint256, bytes));
            address toAddress;
            address srcTokenAddress;
            assembly {
                toAddress := mload(add(to, 20))
                srcTokenAddress := mload(add(token, 20))
            }
            ChainPath storage cp = getAndCheckCP(_srcChainId, srcTokenAddress);
            cp.localLiquidity += amount;
            cp.remoteLiquidity -= swapAmount;

            emit Callback_Swap_Confirm(_srcChainId, srcTokenAddress, swapAmount, toAddress);
        
        // SWAP REVOKE (CALLBACK)  
        } else if (functionType == TYPE_SWAP_REVOKE) {
            (, bytes memory token, uint256 amount, bytes memory to) = abi.decode(_payload, (uint8, bytes, uint256, bytes));
            address toAddress;
            address srcTokenAddress;
            assembly {
                toAddress := mload(add(to, 20))
                srcTokenAddress := mload(add(token, 20))
            }
            ChainPath storage cp = getAndCheckCP(_srcChainId, srcTokenAddress);
            IERC20(cp.srcToken).safeTransfer(toAddress, amount);

            emit Callback_Swap_Revoke(_srcChainId, srcTokenAddress, amount, toAddress);

        // ADD LIQUIDITY (DESTINATION)      
        } else if (functionType == TYPE_ADD_LIQUIDITY) {
            (, bytes memory token, uint256 amount) = abi.decode(_payload, (uint8, bytes, uint256));
            address srcTokenAddress;
            assembly {
                srcTokenAddress := mload(add(token, 20))
            }
            ChainPath storage cp = getAndCheckCP(_srcChainId, srcTokenAddress);
            cp.remoteLiquidity += amount;

            emit Remote_AddLiquidity(_srcChainId, srcTokenAddress, amount);

        // REMOVE LIQUIDITY LOCAL (DESTINATION)     
        } else if (functionType == TYPE_REMOVE_LIQUIDITY_LOCAL) {
            (, bytes memory token, uint256 amount) = abi.decode(_payload, (uint8, bytes, uint256));
            address srcTokenAddress;
            assembly {
                srcTokenAddress := mload(add(token, 20))
            }
            ChainPath storage cp = getAndCheckCP(_srcChainId, srcTokenAddress);
            cp.remoteLiquidity -= amount;

            emit Remote_RemoveLiquidityLocal(_srcChainId, srcTokenAddress, amount);

        // REMOVE LIQUIDITY REMOTE (DESTINATION) 
        } else if (functionType == TYPE_REMOVE_LIQUIDITY_REMOTE) {
            (, bytes memory token, uint256 amount, bytes memory to, bytes memory from) = abi.decode(_payload, (uint8, bytes, uint256, bytes, bytes));
            address toAddress;
            address srcTokenAddress;
            assembly {
                toAddress := mload(add(to, 20))
                srcTokenAddress := mload(add(token, 20))
            }
            ChainPath storage cp = getAndCheckCP(_srcChainId, srcTokenAddress);
            pendingTransactions[toAddress].push(PendingTx(TYPE_REMOVE_LIQUIDITY_REMOTE, cp, amount, from));

            emit Remote_RemoveLiquidityRemote(_srcChainId, srcTokenAddress, amount, toAddress);

        // REMOVE LIQUIDITY REMOTE CONFIRM (CALLBACK)
        } else if (functionType == TYPE_SWAP_CONFIRM) {
            (, bytes memory token, uint256 amount, uint256 swapAmount, bytes memory to) = abi.decode(_payload, (uint8, bytes, uint256, uint256, bytes));
            address toAddress;
            address srcTokenAddress;
            assembly {
                toAddress := mload(add(to, 20))
                srcTokenAddress := mload(add(token, 20))
            }
            ChainPath storage cp = getAndCheckCP(_srcChainId, srcTokenAddress);
            cp.remoteLiquidity -= swapAmount;
            ILpToken(cp.lpToken).burn(address(this), amount);

            emit Callback_RemoveLiquidityRemote_Confirm(_srcChainId, srcTokenAddress, swapAmount, toAddress);
        
        // REMOVE LIQUIDITY REMOTE REVOKE (CALLBACK)      
        } else if (functionType == TYPE_SWAP_REVOKE) {
            (, bytes memory token, uint256 amount, bytes memory to) = abi.decode(_payload, (uint8, bytes, uint256, bytes));
            address toAddress;
            address srcTokenAddress;
            assembly {
                toAddress := mload(add(to, 20))
                srcTokenAddress := mload(add(token, 20))
            }
            ChainPath storage cp = getAndCheckCP(_srcChainId, srcTokenAddress);
            IERC20(cp.lpToken).transfer(toAddress, amount);

            emit Callback_RemoveLiquidityRemote_Revoke(_srcChainId, srcTokenAddress, amount, toAddress);
        }

    }

/******************************************/
/*             FEE starts here            */
/******************************************/

    function getFees(uint16 _dstChainId, address _dstToken, uint256 _amount) public view returns (uint256 rebalanceFee, uint256 protocolFee) {
        ChainPath memory cp = getAndCheckCP(_dstChainId, _dstToken);
        uint256 idealBalance = (cp.localLiquidity + cp.remoteLiquidity) / 2;
        rebalanceFee = altitudeFee.getRebalanceFee(idealBalance, cp.localLiquidity, _amount);
        (uint256 P,,,,) = altitudeFee.getFeeParameters();
        protocolFee = _amount * P / 1e18;
    }

    function getRebalanceReward(uint16 _dstChainId, address _dstToken, uint256 _amount) public view returns (uint256 rebalanceReward) {
        ChainPath memory cp = getAndCheckCP(_dstChainId, _dstToken);
        uint256 idealBalance = (cp.localLiquidity + cp.remoteLiquidity) / 2;
        if (cp.remoteLiquidity < idealBalance) {
            uint256 remoteLiquidityDeficit = idealBalance - cp.remoteLiquidity;
            rebalanceReward = cp.rewardPoolSize * _amount / remoteLiquidityDeficit;
            if (rebalanceReward > cp.rewardPoolSize) {
                rebalanceReward = cp.rewardPoolSize;
            }
        } 
    }

/******************************************/
/*            VIEW starts here            */
/******************************************/

    function getAndCheckCP(uint16 _dstChainId, address _dstToken) internal view returns (ChainPath storage) {
        require(chainPaths.length > 0, "Altitude: no chainpaths exist");
        ChainPath storage cp = chainPaths[chainPathIndexLookup[_dstChainId][_dstToken]];
        require(cp.dstChainId == _dstChainId && cp.dstToken == _dstToken, "Altitude: local chainPath does not exist");
        return cp;
    }

    function getChainPath(uint16 _dstChainId, address _dstToken) external view returns (ChainPath memory) {
        ChainPath memory cp = chainPaths[chainPathIndexLookup[_dstChainId][_dstToken]];
        require(cp.dstChainId == _dstChainId && cp.dstToken == _dstToken, "Altitude: local chainPath does not exist");
        return cp;
    }

    function getAndCheckGasFee(uint8 _type, uint16 _dstChainId, bytes memory _payload) internal view returns (bytes memory adapterParams) {
        uint16 version = 1;
        uint256 gasForDestinationLzReceive = gasLookup[_dstChainId][_type];
        adapterParams = abi.encodePacked(version, gasForDestinationLzReceive);
        // get the fees we need to pay to LayerZero for message delivery
        (uint256 nativeFee, ) = layerZeroEndpoint.estimateFees(_dstChainId, address(this), _payload, false, adapterParams);
        require(msg.value >= nativeFee, "Altitude: insufficient msg.value to pay to LayerZero for message delivery.");
    }

    function quoteLayerZeroFee(uint8 _type, uint16 _dstChainId, address _dstToken, bytes memory _target, bytes memory _from) external view returns (uint256) {
        ChainPath memory cp = getAndCheckCP(_dstChainId, _dstToken);
        bytes memory payload;
        if(_type == 1 || _type == 6) {
        payload = abi.encode(TYPE_SWAP, abi.encodePacked(cp.srcToken), 0, _target, _from);
        } else if (_type == 2 || _type == 3 || _type == 7 || _type == 8) {
        payload = abi.encode(TYPE_SWAP_CONFIRM, abi.encodePacked(cp.srcToken), 0, _target);
        } else if (_type == 4 || _type == 5) {
        payload = abi.encode(TYPE_ADD_LIQUIDITY, abi.encodePacked(cp.srcToken), 0);
        }
        
        uint16 version = 1;
        uint256 gasForDestinationLzReceive = gasLookup[_dstChainId][_type];
        bytes memory adapterParams = abi.encodePacked(version, gasForDestinationLzReceive);
        // get the fees we need to pay to LayerZero for message delivery
        (uint256 nativeFee, ) = layerZeroEndpoint.estimateFees(_dstChainId, address(this), payload, false, adapterParams);
        return (nativeFee);
    }

    function viewPendingTx() public view returns (PendingTx[] memory) {
        return (pendingTransactions[msg.sender]);
    }

/******************************************/
/*           CONFIG starts here           */
/******************************************/

    function setConfig(uint16 _version, uint16 _chainId, uint256 _configType, bytes calldata _config) external override onlyOwner {
        layerZeroEndpoint.setConfig(_version, _chainId, _configType, _config);
    }

    function setSendVersion(uint16 version) external override onlyOwner {
        layerZeroEndpoint.setSendVersion(version);
    }

    function setReceiveVersion(uint16 version) external override onlyOwner {
        layerZeroEndpoint.setReceiveVersion(version);
    }

    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external override onlyOwner {
        layerZeroEndpoint.forceResumeReceive(_srcChainId, _srcAddress);
    }

    fallback() external payable {}
    receive() external payable {}
}