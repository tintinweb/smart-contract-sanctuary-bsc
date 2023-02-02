/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: GPL-3.0-only

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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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
}

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

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity 0.8.17;




contract Proxy {
    using SafeERC20 for IERC20;

    event TransferForward(address indexed target, IERC20 indexed token, address sender, uint256 amount, uint256 commissions);
    event TransferBack(address indexed target, IERC20 indexed token, address sender, uint256 amount);
    event Claim(address indexed from, IERC20 token, uint256 amount);
    event AddCommission(address to, IERC20 token, uint256 amount);
    event Skim(IERC20 indexed token, address indexed to, uint256 amount);

    struct Commission {
        address to;
        uint256 amount;
    } 
    struct TokensIn {
        IERC20 token; 
        uint256 amount;
        bool directTransfer;
        Commission[] commissions;
    }
    struct ClaimantInfo {
        address claimant;
        IERC20 token;
        uint256 balance;
    }

    uint256 public claimantIdCount;
    mapping(IERC20 => uint256) public lastBalance;
    mapping(uint256 => ClaimantInfo) public claimantsInfo; //claimantsInfo[id] = ClaimantInfo;
    mapping(address => mapping(IERC20 => uint256)) public claimantIds; //claimantIds[address][IERC20] = id;

    receive() external payable {}

    function _transferAssetFrom(IERC20 token, uint256 amount) internal returns (uint256 balance) {
        balance = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);
        balance = token.balanceOf(address(this)) - balance;
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    function addToDistributions(address claimant, IERC20 token, uint256 amount) internal {
        uint256 claimantId = claimantIds[claimant][token];
        if (claimantId == 0) {
            ++claimantIdCount;
            claimantsInfo[claimantIdCount] = ClaimantInfo({
                claimant: claimant,
                token: token,
                balance: amount
            });
            claimantIds[claimant][token] = claimantIdCount;
        }
        else {
            claimantsInfo[claimantId].balance += amount;
        }
    }

    function getClaimantBalance(address claimant, IERC20 token) external view returns (uint256) {
        uint256 claimantId = claimantIds[claimant][token];
        return claimantsInfo[claimantId].balance;
    }

    function getClaimantsInfo(uint256 fromId, uint256 count) external view returns (ClaimantInfo[] memory claimantInfoList) {
        require(fromId > 0 && fromId <= claimantIdCount, "out of bounds");
        uint256 toId = fromId + count - 1;
        if (toId > claimantIdCount) {
            toId = claimantIdCount;
            count = toId - fromId + 1;
        }
        claimantInfoList = new ClaimantInfo[](count);
        uint256 currId = fromId;
        for (uint256 i = 0; i < count; i++) {
            claimantInfoList[i] = claimantsInfo[currId];
            ++currId;
        }
    }
    
    function tokenIn(address target, TokensIn calldata tokensIn, bytes memory data) external {
        // transfer token to target 
        TokensIn calldata transfer = tokensIn;
        uint256 totalCommissions;
        uint256 length2 = transfer.commissions.length;
        for (uint256 j = 0 ; j < length2 ; j++ ){
            Commission calldata commission = transfer.commissions[j];
            totalCommissions += commission.amount;
            addToDistributions(commission.to, tokensIn.token, commission.amount);   
            emit AddCommission(commission.to, tokensIn.token, commission.amount);
        }
        uint amount = transfer.amount - totalCommissions; 

        lastBalance[transfer.token] += totalCommissions;

        // transfer / approve tokens to target
        if (transfer.directTransfer) {
            uint256 actualTotalCommission = _transferAssetFrom(transfer.token, totalCommissions);
            require(actualTotalCommission == totalCommissions, "commission amount not matched");
            transfer.token.safeTransferFrom(msg.sender, target, amount);
        } else {
            uint256 actualAmount = _transferAssetFrom(transfer.token, transfer.amount);
            require(actualAmount == transfer.amount, "amount not matched");
            // optional, may make a list of tokens need to reset first
            transfer.token.safeApprove(target, 0);
            transfer.token.safeApprove(target, amount);
        }
        emit TransferForward(target, transfer.token, msg.sender, amount, totalCommissions);

        assembly {
            let ret := call(gas(), target, 0, add(0x20,data), mload(data), 0, 0)
            // returndatacopy(0, 0, returndatasize())
            if eq(0, ret) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
            returndatacopy(0, 0, returndatasize())
            return(0, returndatasize())
        }
    }
    function ethIn(address target, Commission[] calldata commissions, bytes memory data) external payable {
        // transfer ETH to target 
        uint256 totalCommissions;
        uint256 length2 = commissions.length;
        for (uint256 j = 0 ; j < length2 ; j++ ){
            Commission calldata commission = commissions[j];
            totalCommissions += commission.amount;
            addToDistributions(commission.to, IERC20(address(0)), commission.amount);  
            emit AddCommission(commission.to, IERC20(address(0)), commission.amount);
        }
        uint amount = msg.value - totalCommissions;

        lastBalance[IERC20(address(0))] += totalCommissions;

        emit TransferForward(target, IERC20(address(0)), msg.sender, amount, totalCommissions);

        assembly {
            let ret := call(gas(), target, amount, add(0x20,data), mload(data), 0, 0)
            // returndatacopy(0, 0, returndatasize())
            if eq(0, ret) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
            returndatacopy(0, 0, returndatasize())
            return(0, returndatasize())
        }
    }

    function proxyCall(address target, TokensIn[] calldata tokensIn, address to, IERC20[] calldata tokensOut, bytes memory data) external payable {
        // transfer token to target 
        uint256 length = tokensIn.length;
        uint ethAmount;
        for (uint256 i = 0 ; i < length ; i++) {
            TokensIn calldata transfer = tokensIn[i];
            uint256 totalCommissions;
            {
            uint256 length2 = transfer.commissions.length;
            for (uint256 j = 0 ; j < length2 ; j++ ){
                Commission calldata commission = transfer.commissions[j];
                totalCommissions += commission.amount;
                addToDistributions(commission.to, transfer.token, commission.amount); 
                emit AddCommission(commission.to, transfer.token, commission.amount);
            }
            }
            uint amount = transfer.amount - totalCommissions;
            lastBalance[transfer.token] += totalCommissions;

            if (address(transfer.token) == address(0)) {
                require(ethAmount == 0, "more than one ETH transfer");
                require(msg.value == transfer.amount, "ETH amount not matched");
                ethAmount = amount;
            } else {
                // transfer / approve tokens to target
                if (transfer.directTransfer) {     
                    uint256 actualTotalCommission = _transferAssetFrom(transfer.token, totalCommissions);
                    require(actualTotalCommission == totalCommissions, "commission amount not matched");          
                    transfer.token.safeTransferFrom(msg.sender, target, amount);
                } else {
                    uint256 actualAmount = _transferAssetFrom(transfer.token, transfer.amount);
                    require(actualAmount == transfer.amount, "amount not matched");
                    // optional, may make a list of tokens need to reset first
                    transfer.token.safeApprove(target, 0);
                    transfer.token.safeApprove(target, amount);
                }
            }
            emit TransferForward(target, transfer.token, msg.sender, amount, totalCommissions);
        }

        assembly {
            let ret := call(gas(), target, ethAmount, add(0x20,data), mload(data), 0, 0)
            // returndatacopy(0, 0, returndatasize())
            if eq(0, ret) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        // transfer token back
        length = tokensOut.length;
        for (uint256 i = 0 ; i < length ; i++) {
            uint256 amount;
            if (address(tokensOut[i]) == address(0)) {
                amount = address(this).balance - lastBalance[IERC20(address(0))];
                safeTransferETH(to, amount);
            } else  {
                amount = tokensOut[i].balanceOf(address(this)) - lastBalance[tokensOut[i]];
                tokensOut[i].safeTransfer(to, amount);
            }
            emit TransferBack(target, tokensOut[i], to, amount);
        }
        assembly {
            returndatacopy(0, 0, returndatasize())
            return(0, returndatasize())
        }
    }

    // commissions
    function _claim(IERC20 token) internal {
        uint256 claimantId = claimantIds[msg.sender][token];
        ClaimantInfo memory claimantInfo = claimantsInfo[claimantId];
        uint256 balance = claimantInfo.balance;
        claimantsInfo[claimantId].balance = 0;
        lastBalance[token] -= balance;
        if (address(token) == address(0)) {
            safeTransferETH(msg.sender, balance);
        } else {
            token.safeTransfer(msg.sender, balance);
        }
        emit Claim(msg.sender, token, balance);
    }

    function claim(IERC20 token) external {
        _claim(token);
    }

    function claimMultiple(IERC20[] calldata tokens) external {
        uint256 length = tokens.length;
        for (uint256 i ; i < length ; i++) {
            _claim(tokens[i]);
        }
    }

    // transfer excess tokens to caller
    function skim(IERC20[] calldata tokens) external {
        uint256 length = tokens.length;
        for (uint256 i = 0 ; i < length ; i++) {
            uint256 amount;
            IERC20 token = tokens[i];
            if (address(token) == address(0)) {
                amount = address(this).balance;
                amount = amount - lastBalance[IERC20(address(0))];
                safeTransferETH(msg.sender, amount);
            } else {
                amount = token.balanceOf(address(this));
                amount = amount - lastBalance[token];
                token.safeTransfer(msg.sender, amount);
            }
            emit Skim(token, msg.sender, amount);
        }
    }
}