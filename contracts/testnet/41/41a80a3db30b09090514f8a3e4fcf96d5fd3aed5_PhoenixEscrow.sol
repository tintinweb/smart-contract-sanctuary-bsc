/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol


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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Permit.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Permit.sol)

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol


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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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

// File: escrow.sol


pragma solidity ^0.8.0;


contract PhoenixEscrow {
    using SafeERC20 for IERC20;

    // address of the owner of the contract
    address private owner;
    // address of the subOwner of the contract
    address private subOwner;

    /* Escrow Status
        0 = active,
        1 = released,
        2 = requestedRefund,
        3 = refunded,
        4 = claimed
    */

    struct Escrow {
        uint256 id;
        address buyer;
        address seller;
        uint256 value;
        uint256 startTime;
        uint256 endTime;
        uint256 status;
        address tokenAddress;
    }

    // mapping to store escrow details
    mapping(uint256 => Escrow) private escrows;

    // counter for escrow IDs
    uint256 private escrowIdCounter;

    // Mapping to track the lock status of each escrow
    mapping(uint256 => bool) private escrowLocks;

    /* Fees Vaults */
    // New escrow fees vault
    address private createEscrowFeesVualt;
    // Claim escrow fees vault
    address private claimEscrowFeesVualt;

    /// Define a struct to hold token fees
    struct Fees {
        uint256 createFee;
        uint256 claimFee;
    }

    // Define a struct to hold token information
    struct Token {
        address tokenAddress;
        Fees fees;
    }

    // Define an array to store token information
    Token[] private tokens;

    // Define a mapping to store token indexes
    mapping(address => uint256) private tokenIndexes;

    // Define a mapping to store if a token already exists
    mapping(address => bool) private tokenExists;

    // Event to emit when a token is added
    event TokenAdded(
        address indexed tokenAddress,
        uint256 createFee,
        uint256 claimFee
    );

    // Event to emit when a token is removed
    event TokenRemoved(address indexed tokenAddress);

    // Event to emit when a token's fee is updated
    event TokenFeeUpdated(address indexed tokenAddress, uint256 fee);

    constructor() {
        owner = msg.sender;
    }

    // change subowner
    function addSubOwner(address newSubOwner) public {
        require(msg.sender == owner, "Only the owner can add sub-owners");
        require(
            newSubOwner != owner,
            "Sub-owner address cannot be the same as owner's address"
        );
        require(
            newSubOwner != subOwner,
            "New Sub-owner address cannot be the same as the old subOwner's address"
        );
        subOwner = newSubOwner;
    }

    // remove subowner
    function removeSubOwner() public {
        require(msg.sender == owner, "Only the owner can remove sub-owners");
        subOwner = address(0);
    }

    // set newly created escrow fees vault
    function setCreateEscrowVault(address newCreateEscrowVault) public {
        require(
            msg.sender == owner || msg.sender == subOwner,
            "Only the owner/subOwner can change newly created escrow vault"
        );
        createEscrowFeesVualt = newCreateEscrowVault;
    }

    // set claim escrow fees vault
    function setClaimEscrowVault(address newClaimEscrowVault) public {
        require(
            msg.sender == owner || msg.sender == subOwner,
            "Only the owner/subOwner can change claim escrow vault"
        );
        claimEscrowFeesVualt = newClaimEscrowVault;
    }

    // Function to get the newly escrow fees
    function getCreateEscrowVualtAddress() public view returns (address) {
        require(
            msg.sender == owner || msg.sender == subOwner,
            "Only the owner/subOwner can change newly created escrow vault"
        );
        return createEscrowFeesVualt;
    }

    // Function to get the claim escrow fees
    function getClaimEscrowVault() public view returns (address) {
        require(
            msg.sender == owner || msg.sender == subOwner,
            "Only the owner/subOwner can change claim escrow vault"
        );
        return claimEscrowFeesVualt;
    }

    // Function to add a new token address and fees
    function addTokenAddress(
        address tokenAddress,
        uint256 createFee,
        uint256 claimFee
    ) public {
        // Check if the token already exists
        require(!tokenExists[tokenAddress], "Token already exists");

        // Create a new Token object and store it in the tokens array
        Token memory token = Token(tokenAddress, Fees(createFee, claimFee));
        tokenIndexes[tokenAddress] = tokens.length;
        tokens.push(token);

        // Set the tokenExists mapping to true
        tokenExists[tokenAddress] = true;

        // Emit a TokenAdded event
        emit TokenAdded(tokenAddress, createFee, claimFee);
    }

    // Function to set the create fee for a specific token
    function setTokenCreateFee(address tokenAddress, uint256 fee) public {
        // Check if the token exists
        require(tokenExists[tokenAddress], "Token does not exist");

        // Get the index of the token in the tokens array
        uint256 index = tokenIndexes[tokenAddress];

        // Update the fee for the token
        tokens[index].fees.createFee = fee;

        // Emit a TokenFeeUpdated event
        emit TokenFeeUpdated(tokenAddress, fee);
    }

    // Function to set the claim fee for a specific token
    function setTokenClaimFee(address tokenAddress, uint256 fee) public {
        // Check if the token exists
        require(tokenExists[tokenAddress], "Token does not exist");

        // Get the index of the token in the tokens array
        uint256 index = tokenIndexes[tokenAddress];

        // Update the fee for the token
        tokens[index].fees.claimFee = fee;

        // Emit a TokenFeeUpdated event
        emit TokenFeeUpdated(tokenAddress, fee);
    }

    function removeTokenAddress(address tokenAddress) public {
        // Check if the token exists
        require(tokenExists[tokenAddress], "Token does not exist");

        // Get the index of the token in the tokens array
        uint256 index = tokenIndexes[tokenAddress];

        // If the token is not the last token in the array, swap it with the last token
        if (index != tokens.length - 1) {
            Token storage lastToken = tokens[tokens.length - 1];
            tokens[index] = lastToken;
            tokenIndexes[lastToken.tokenAddress] = index;
        }

        // Remove the token from the tokens array
        tokens.pop();
        delete tokenIndexes[tokenAddress];
        delete tokenExists[tokenAddress];

        // Emit a TokenRemoved event
        emit TokenRemoved(tokenAddress);
    }

    // Function to get the fees for a specific token
    function getTokenFees(address tokenAddress)
        public
        view
        returns (Fees memory)
    {
        // Check if the token exists
        require(tokenExists[tokenAddress], "Token does not exist");

        // Get the index of the token in the tokens array and return its fees
        uint256 index = tokenIndexes[tokenAddress];
        return tokens[index].fees;
    }

    // Function to get all tokens and their fees
    function getAllTokensAndFees() public view returns (Token[] memory) {
        // Return the entire tokens array
        return tokens;
    }

    // Function to create a new escrow
    function createEscrow(
        address _seller,
        uint256 _value,
        uint256 _duration,
        address _tokenAddress
    ) public {
        require(_seller != address(0), "Invalid seller address");
        require(_seller != msg.sender, "Invalid seller address");
        require(_value > 0, "Invalid escrow value");
        require(_duration > 0, "Invalid escrow end time");
        // Check if the token exists
        require(tokenExists[_tokenAddress], "Token does not exist");

        // Get the index of the token in the tokens array
        uint256 index = tokenIndexes[_tokenAddress];
        uint256 _durationInSeconds = _duration * 86400;

        uint256 fee = (_value * tokens[index].fees.createFee) / 100;
        uint256 remainingValue = _value - fee;

        IERC20 token = IERC20(_tokenAddress);
        // transfer fees to the new escrow fees vault
        token.safeTransferFrom(msg.sender, createEscrowFeesVualt, fee);
        // transfer funds to the escrow contract and fees wallet
        token.safeTransferFrom(msg.sender, address(this), remainingValue);

        // Increment the escrow ID counter
        escrowIdCounter++;

        // Create the new escrow object
        Escrow memory newEscrow = Escrow({
            id: escrowIdCounter,
            buyer: msg.sender,
            seller: _seller,
            value: remainingValue,
            startTime: block.timestamp,
            endTime: block.timestamp + _durationInSeconds,
            status: 0,
            tokenAddress: _tokenAddress
        });

        // Add the new escrow to the mapping
        escrows[escrowIdCounter] = newEscrow;
    }

    // Function to get the user's escrows
    function getUserEscrows() public view returns (Escrow[] memory) {
        uint256 escrowCount = 0;

        // Count the number of escrows associated with the user
        for (uint256 i = 0; i <= escrowIdCounter; i++) {
            if (
                escrows[i].buyer == msg.sender ||
                escrows[i].seller == msg.sender
            ) {
                escrowCount++;
            }
        }

        // Create a new array to hold the user's escrows
        Escrow[] memory userEscrows = new Escrow[](escrowCount);
        escrowCount = 0;

        // Add the user's escrows to the new array
        for (uint256 i = 0; i <= escrowIdCounter; i++) {
            if (
                escrows[i].buyer == msg.sender ||
                escrows[i].seller == msg.sender
            ) {
                userEscrows[escrowCount] = escrows[i];
                escrowCount++;
            }
        }

        return userEscrows;
    }
}