/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
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

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: PaymentSplitterV2.sol


// Based on OpenZeppelin Contracts (last updated v4.7.0) (finance/PaymentSplitter.sol)

pragma solidity ^0.8.0;




contract PaymentSplitterV2 is Context {
  event PayeeAdded(address account, uint256 shares);
  event PaymentReleased(address to, uint256 amount);
  event ERC20PaymentReleased(IERC20 indexed token, address to, uint256 amount);
  event PaymentReceived(address from, uint256 amount);
  event StateReset();

  uint256 private _totalShares;
  uint256 private _totalReleased;

  mapping(address => uint256) private _shares;
  mapping(address => uint256) private _released;
  address[] private _payees;

  mapping(IERC20 => uint256) private _erc20TotalReleased;
  mapping(IERC20 => mapping(address => uint256)) private _erc20Released;

  /**
    * @dev Creates an instance of `PaymentSplitterV2` where each account in
    * `payees` is assigned the number of shares at the matching position in the
    * `shares` array.
    *
    * All addresses in `payees` must be non-zero. Both arrays must have the same
    * non-zero length, and there must be no duplicates in `payees`.
    */
  constructor(address[] memory payees, uint256[] memory shares_) payable {
    _setPayees(payees, shares_);
  }

  function _setPayees(address[] memory payees, uint256[] memory shares_)
      private {
    require(
      payees.length == shares_.length,
      "PaymentSplitterV2: payees and shares length mismatch"
    );
    require(payees.length > 0, "PaymentSplitterV2: no payees");

    for (uint256 i = 0; i < payees.length; i++) {
      _addPayee(payees[i], shares_[i]);
    }
  }

  // Original PaymentSplitter function.
  receive() external payable virtual {
    emit PaymentReceived(_msgSender(), msg.value);
  }

  /**
    * @dev Getter for the total shares held by payees.
    */
  function totalShares() public view returns (uint256) {
    return _totalShares;
  }

  /**
    * @dev Getter for the total amount of Ether already released.
    */
  function totalReleased() public view returns (uint256) {
    return _totalReleased;
  }

  /**
    * @dev Getter for the total amount of `token` already released. `token`
    * should be the address of an IERC20 contract.
    */
  function totalReleased(IERC20 token) public view returns (uint256) {
    return _erc20TotalReleased[token];
  }

  /**
    * @dev Getter for the amount of shares held by an account.
    */
  function shares(address account) public view returns (uint256) {
    return _shares[account];
  }

  function getMultipleShares(address[] calldata accounts)
      public view returns (uint256[] memory) {
    uint num_accounts = accounts.length;
    uint[] memory account_shares = new uint[](num_accounts);

    for (uint i_account = 0; i_account < num_accounts; ++i_account) {
      address account = accounts[i_account];
      account_shares[i_account] = shares(account);
    }

    return account_shares;
  }

  /**
    * @dev Getter for the amount of Ether already released to a payee.
    */
  function released(address account) public view returns (uint256) {
    return _released[account];
  }

  function getMultipleReleased(address[] calldata accounts)
      public view returns (uint256[] memory) {
    uint num_accounts = accounts.length;
    uint[] memory account_released = new uint[](num_accounts);

    for (uint i_account = 0; i_account < num_accounts; ++i_account) {
      address account = accounts[i_account];
      account_released[i_account] = released(account);
    }

    return account_released;
  }

  /**
    * @dev Getter for the amount of `token` tokens already released to a payee.
    * `token` should be the address of an IERC20 contract.
    */
  function released(IERC20 token, address account)
      public view returns (uint256) {
    return _erc20Released[token][account];
  }

  /**
    * @dev Getter for the address of the payee number `index`.
    */
  function payee(uint256 index) public view returns (address) {
    return _payees[index];
  }

  function getAllPayees() public view returns (address[] memory) {
    return _payees;
  }

  /**
    * @dev Triggers a transfer to `account` of the amount of Ether they are
    * owed, according to their percentage of the total shares.
    */
  function release(uint balance_main_token, address payable account)
      internal virtual {
    require(_shares[account] > 0, "PaymentSplitterV2: account has no shares");

    uint256 payment = balance_main_token * _shares[account] / _totalShares;
    if (payment == 0) {
      return;
    }

    _released[account] += payment;
    _totalReleased += payment;

    Address.sendValue(account, payment);
    emit PaymentReleased(account, payment);
  }

  /**
    * @dev Triggers a transfer to `account` of the amount of `token` tokens they
    * are owed, according to their percentage of the total shares. `token` must
    * be the address of an IERC20 contract.
    */
  function release(IERC20 token, uint balance_token, address account)
      internal virtual {
    require(_shares[account] > 0, "PaymentSplitterV2: account has no shares");

    uint256 payment = balance_token * _shares[account] / _totalShares;
    if (payment == 0) {
      return;
    }

    _erc20Released[token][account] += payment;
    _erc20TotalReleased[token] += payment;

    SafeERC20.safeTransfer(token, account, payment);
    emit ERC20PaymentReleased(token, account, payment);
  }

  /**
    * @dev Add a new payee to the contract.
    * @param account The address of the payee to add.
    * @param shares_ The number of shares owned by the payee.
    */
  function _addPayee(address account, uint256 shares_) private {
    require(
      account != address(0),
      "PaymentSplitterV2: account is the zero address"
    );
    require(shares_ > 0, "PaymentSplitterV2: shares are 0");
    require(
      _shares[account] == 0,
      "PaymentSplitterV2: account already has shares"
    );

    _payees.push(account);
    _shares[account] = shares_;
    _totalShares = _totalShares + shares_;
    emit PayeeAdded(account, shares_);
  }

  // %%%%% New, custom logic %%%%%

  /**
    * Release all the argument tokens for all the shareholders.
    * Theoretically, resets the balances of the contract to 0.
    * Practically, due to float precision, the balances might be non-zero, but
    * close to it.
    */
  function releaseTokensInternal(address[] memory token_addresses)
      internal {
    uint num_payees = _payees.length;
    uint num_token_addresses = token_addresses.length;
    
    uint balance_main_token;
    uint[] memory balance_tokens = new uint[](token_addresses.length);
    // Populate the current balances that will be split.
    balance_main_token = address(this).balance;
    for (uint i_token = 0; i_token < num_token_addresses; ++i_token) {
      address token_address = token_addresses[i_token];
      balance_tokens[i_token] = IERC20(token_address).balanceOf(address(this));
    }

    // Send every payee their share.
    for (uint i_payee = 0; i_payee < num_payees; ++i_payee) {
      address payable curr_payee = payable(_payees[i_payee]);

      release(balance_main_token, curr_payee);  // Release the main token.

      for (uint i_token = 0; i_token < num_token_addresses; ++i_token) {
        address token_address = token_addresses[i_token];
        uint token_balance = balance_tokens[i_token];
        release(IERC20(token_address), token_balance, curr_payee);
      }
    }
  }

  // Reset the payees and their shares.
  function resetPayees() private {
    uint num_payees = _payees.length;

    for (uint i_payee = 0; i_payee < num_payees; ++i_payee) {
        address curr_payee = _payees[i_payee];
        
        _shares[curr_payee] = 0;
    }
    _totalShares = 0;
    
    delete _payees;
  }

  function setNewPayeesInternal(address[] memory payees,
      uint256[] memory shares_) internal {
    resetPayees();
    _setPayees(payees, shares_);
  }
}

// File: Subscriptions.sol


pragma solidity >=0.4.22 <0.9.0;



contract Subscriptions is PaymentSplitterV2 {
  // ----- Helpful constants -----
  // Mainnet BSC token contract addresses.
  address public constant contractUSDC = 
    0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
  address public constant contractUSDT =
    0x55d398326f99059fF775485246999027B3197955;
  address public constant contractBUSD =
    0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

  // Testnet BSC token contract addresses.
  // Couldn't find USDC on testnet pancake swap, so used Testnet DAI instead.
  // address public constant contractUSDC = 
  //     0x8a9424745056Eb399FD19a0EC26A14316684e274;
  // address public constant contractUSDT =
  //     0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
  // address public constant contractBUSD =
  //     0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

  // ===== Accepted payment tokens =====
  // Addresses of the considered tokens' BEP-20 smart contracts.
  address[] public considered_tokens;
  // Used to activate / deactivate a token for payment.
  mapping(address => bool) token_acceptances;
  
  // ===== Subscription tiers =====
  // All tiers are indexed from 1 in the stored state. tier_*[0] must be
  // ignored.
  // NOTE: When an array of tiers' details is passed as argument, the arguments
  // are expected to be indexed from 0, i.e.
  // tier_property_stored[i_tier] == tier_property_argument[i_tier - 1].
  bool[] public tier_availabilities;
  uint[] public tier_durations_days;  // Tier durations in days.
  // Dict<tier_id, Dict<token_contract, base_price>>.
  mapping(uint => mapping(address => uint)) public tier_base_prices;

  // ===== Discounts =====
  uint public discount_denominator;
  // Used together with the discount_denominator to compute discounts.
  // Dict<wallet_address, discount>.
  mapping(address => uint) public discount_numerators;

  // ===== User info =====
  mapping(address => uint) public user_first_subscription_timestamps;
  mapping(address => uint) public user_latest_subscription_timestamps;
  mapping(address => uint) public user_tiers;  // Real tiers are indexed from 1.

  // ===== Admin addresses =====
  address public master_admin;
  address[] public admin_addresses;

  // ===== Logging events =====
  event NewSubscription(
    uint timestamp,
    address subscriber,
    uint i_tier, uint tier_duration_days,
    address token_address, uint tier_price_in_token
  );

  event NewDiscountSet(
    uint timestamp,
    address user,
    uint discount_numerator, uint discount_denominator
  );

  modifier onlyMasterAdmin {
    require(
      msg.sender == master_admin,
      "Only the Master Administrator can call this function."
    );

    _;
  }

  modifier onlyAdmin {
    require(
      isAdmin(msg.sender) == true,
      "Only the administrators can call this function."
    );

    _;
  }

  constructor(
      // PaymentSplitter arguments.
      address[] memory payees_, uint256[] memory shares_,
      // tier_* arguments are indexed from 0.
      // i.e. tier_*argument_[0] <=> tier_*state[1].
      uint[] memory tier_durations_days_,
      uint[] memory tier_base_prices_usdc_,
      uint[] memory tier_base_prices_usdt_,
      uint[] memory tier_base_prices_busd_,
      address master_admin_, address[] memory admin_addresses_,
      uint discount_denominator_
    )
    PaymentSplitterV2(payees_, shares_)
    payable {

    // %%%%% Initialize accepted BEP-20 tokens: USDC, USDT and BUSD %%%%%
    considered_tokens.push(contractUSDC);  // Index 0: Binance-Peg USDC.
    token_acceptances[contractUSDC] = true;

    considered_tokens.push(contractUSDT);  // Index 1: Binance-Peg Tether.
    token_acceptances[contractUSDT] = true;

    considered_tokens.push(contractBUSD);  // Index 2: Binance-Peg BUSD.
    token_acceptances[contractBUSD] = true;

    // %%%%% Initialize the original tiers %%%%%%
    uint num_tiers = tier_durations_days_.length;

    tier_durations_days.push(0); // Tier id 0 is not used.
    for (uint i_tier = 1; i_tier <= num_tiers; ++i_tier) {
      // tier_durations_days[1] = tier_durations_days_[0].
      tier_durations_days.push(tier_durations_days_[i_tier - 1]);
    }

    require(
      tier_base_prices_usdc_.length == num_tiers,
      "The number of tier USDC base prices doesn't match the number of tier "
      "durations."
    );
    require(
      tier_base_prices_usdt_.length == num_tiers,
      "The number of tier USDT base prices doesn't match the number of tier "
      "durations."
    );
    require(
      tier_base_prices_busd_.length == num_tiers,
      "The number of tier BUSD base prices doesn't match the number of tier "
      "durations."
    );

    // Set the initial base prices.
    for (uint i_tier = 1; i_tier <= num_tiers; ++i_tier) {
      tier_base_prices[i_tier][contractUSDC] =
        tier_base_prices_usdc_[i_tier - 1];
      tier_base_prices[i_tier][contractUSDT] =
        tier_base_prices_usdt_[i_tier - 1];
      tier_base_prices[i_tier][contractBUSD] =
        tier_base_prices_busd_[i_tier - 1];
    }

    // Initially deactivate all tiers.
    for (uint i_tier = 0; i_tier <= num_tiers; ++i_tier) {
      tier_availabilities.push(false);
    }

    // %%%%% Initialize discounts %%%%%
    discount_denominator = discount_denominator_;

    // %%%%% Initialize Admin team %%%%%
    master_admin = master_admin_;
    admin_addresses = admin_addresses_;
    
    bool master_admin_in_admins = false;
    uint num_admins = admin_addresses.length;
    for (uint i_admin = 0; i_admin < num_admins; ++i_admin) {
      if (admin_addresses[i_admin] == master_admin) {
        master_admin_in_admins = true;
        break;
      }
    }
    if (master_admin_in_admins == false) {
      admin_addresses.push(master_admin);
    }
  }

  // $$$$$ Subscribing & Upgrading logic $$$$$
  function subscribe(uint i_tier, address token_address) external {
    // Check that the tier exists and is available to buy.
    require(isExistingTier(i_tier) == true, "Invalid tier id.");
    require(tier_availabilities[i_tier] == true,
      "New subscriptions for this tier are closed at the moment.");
    
    // Check that the payment token is ok.
    require(isTokenAccepted(token_address) == true,
      "Provided token is not accepted for payment.");
    
    // Check that the user is ok.
    require(isUserSubscribed(msg.sender) == false,
      "User is already subscribed. User should upgrade instead.");

    uint tier_price_for_user = getTierPriceInTokenForUser(i_tier, token_address,
      msg.sender);
    // Trigger the payment.
    bool payment_succeded = IERC20(token_address).transferFrom(msg.sender,
      address(this), tier_price_for_user);
    require(payment_succeded == true, "Failed to transfer the payment tokens.");

    // Register the user as currently subscribed.
    user_tiers[msg.sender] = i_tier;
    user_latest_subscription_timestamps[msg.sender] = block.timestamp;
    if (user_first_subscription_timestamps[msg.sender] == 0) {
      user_first_subscription_timestamps[msg.sender] = block.timestamp;
    }

    emit NewSubscription(
      block.timestamp,
      msg.sender,
      i_tier,
      tier_durations_days[i_tier],
      token_address,
      tier_price_for_user
    );
  }

  function upgrade(uint i_new_tier, address token_address) external {
    // Check that the tier exists and is available to buy.
    require(isExistingTier(i_new_tier) == true, "Invalid new tier id.");
    require(tier_availabilities[i_new_tier] == true,
      "New subscriptions for this tier are closed at the moment.");
    
    // Check that the payment token is ok.
    require(isTokenAccepted(token_address) == true,
      "Provided token is not accepted for payment.");
    
    // Check that the user is ok.
    require(isUserSubscribed(msg.sender) == true,
      "User doesn't have another active subscription to upgrade from.");

    uint i_old_tier = user_tiers[msg.sender];

    // Cannot upgrade to the existing tier.
    require(
      i_new_tier != i_old_tier,
      "Cannot upgrade to the tier you are already subscribed to."
    );

    uint old_tier_price = getTierPriceInTokenForUser(i_old_tier, token_address,
      msg.sender);
    uint new_tier_price = getTierPriceInTokenForUser(i_new_tier, token_address,
      msg.sender);
    uint tier_price_difference = new_tier_price - old_tier_price;
    
    require(tier_price_difference >= 0, "Downgrading is not possible.");

    // Trigger the payment.
    if (tier_price_difference > 0) {
      bool payment_succeded = IERC20(token_address).transferFrom(msg.sender,
        address(this), tier_price_difference);
      require(
        payment_succeded == true,
        "Failed to transfer the payment tokens."
      );
    }

    // Update the user's stored tier.
    user_tiers[msg.sender] = i_new_tier;
  }

  // ##### Administrative logic for considered-for-payment tokens #####
  function addConsideredToken(address new_token_address,
      uint[] memory new_token_tier_base_prices, bool is_new_token_accepted)
      public onlyAdmin {
    require(isTokenConsidered(new_token_address) == false,
      "Token is already considered for payment.");
    
    uint num_tiers = getNumberOfTiers();
    require(
      new_token_tier_base_prices.length == num_tiers,
      "You must specify the base price in the new token for all existing tiers."
    );

    considered_tokens.push(new_token_address);
    for (uint i_tier = 1; i_tier <= num_tiers; ++i_tier) {
      tier_base_prices[i_tier][new_token_address] =
        new_token_tier_base_prices[i_tier - 1];
    }

    token_acceptances[new_token_address] = is_new_token_accepted;
  }

  function acceptTokenForPayment(address token_address) public onlyAdmin {
    _setConsideredTokenAcceptance(token_address, true);
  }

  function forbidTokenForPayment(address token_address) public onlyAdmin {
    _setConsideredTokenAcceptance(token_address, false);
  }

  function setAllConsideredTokensAcceptances(
      bool[] memory new_is_token_accepted_array) public onlyAdmin {
    require(
      new_is_token_accepted_array.length == considered_tokens.length,
      "You must provide new acceptance bool statuses for all the stored "
      "considered tokens."
    );
    
    for (uint i_token = 0; i_token < considered_tokens.length; ++i_token) {
      address token_address = considered_tokens[i_token];
      token_acceptances[token_address] = new_is_token_accepted_array[i_token];
    }
  }

  // ##### Administrative logic for tiers #####
  // Returns the new tier's i_tier.
  function addTier(
    bool is_new_tier_purchasable,
    uint new_tier_duration_days,
    uint[] memory new_tier_base_prices
  ) public onlyAdmin returns (uint) {
    require(
      new_tier_base_prices.length == considered_tokens.length,
      "You must provide base prices for all the considered tokens in their "
      "stored order."
    );

    tier_availabilities.push(is_new_tier_purchasable);
    tier_durations_days.push(new_tier_duration_days);
    uint i_new_tier = getNumberOfTiers();

    setTierBasePricesForAllConsideredTokens(i_new_tier, new_tier_base_prices);

    return i_new_tier;
  }

  function activateTier(uint i_tier) public onlyAdmin {
    _setTierAvailability(i_tier, true);
  }

  function deactivateTier(uint i_tier) public onlyAdmin {
    _setTierAvailability(i_tier, false);
  }

  function activateAllTiers() public onlyAdmin {
    uint num_tiers = getNumberOfTiers();

    for (uint i_tier = 1; i_tier <= num_tiers; ++i_tier) {
      activateTier(i_tier);
    }
  }

  function deactivateAllTiers() public onlyAdmin {
    uint num_tiers = getNumberOfTiers();

    for (uint i_tier = 1; i_tier <= num_tiers; ++i_tier) {
      deactivateTier(i_tier);
    }
  }

  function setTierDurationInDays(uint i_tier, uint new_tier_duration_days)
      public onlyAdmin {
    require(isExistingTier(i_tier) == true, "Invalid tier id");

    tier_durations_days[i_tier] = new_tier_duration_days;
  }

  function setAllTierDurationsInDays(uint[] memory new_tier_durations_days)
      public onlyAdmin {
    uint num_tiers = getNumberOfTiers();
    require(
      new_tier_durations_days.length == num_tiers,
      "Please provide new durations for all existing tiers."
    );

    for (uint i_tier = 1; i_tier <= num_tiers; ++i_tier) {
      tier_durations_days[i_tier] = new_tier_durations_days[i_tier - 1];
    }
  }

  function setTierBasePriceInToken(uint i_tier, address token_address,
      uint new_tier_base_price_token) public onlyAdmin {
    require(isExistingTier(i_tier) == true, "Invalid tier id");
    require(
      isTokenConsidered(token_address) == true,
      "Provided token is not considered for payment."
    );
    require(
      new_tier_base_price_token >= 0,
      "The new base price cannot be negative."
    );  // Arg is uint, should never happen.

    tier_base_prices[i_tier][token_address] = new_tier_base_price_token;
  }

  // The order of base prices in the tokens' currency (e.g. USDC, USDT, BUSD)
  // must match the order of the token smart contract addresses in
  // considered_tokens and a base price must be provided even for the tokens
  // that are not accepted anymore (token_acceptances[token_address] == false).
  function setTierBasePricesForAllConsideredTokens(uint i_tier,
      uint[] memory new_tier_base_price_in_all_tokens) public onlyAdmin {
    require(isExistingTier(i_tier) == true, "Invalid tier id");

    uint num_considered_tokens = considered_tokens.length;
    
    require(
      new_tier_base_price_in_all_tokens.length == num_considered_tokens,
      "Base prices were not provided for all the considered tokens. Check "
      "again and also respect the token order."
    );

    for (uint i_token = 0; i_token < num_considered_tokens; ++i_token) {
      address token_address = considered_tokens[i_token];
      
      tier_base_prices[i_tier][token_address] =
        new_tier_base_price_in_all_tokens[i_token];
    }
  }

  // ##### Administrative logic for user info #####
  function setUserFirstSubscriptionTimestamp(address user,
      uint first_subscription_timestamp) public onlyAdmin {
    require(
      first_subscription_timestamp <= block.timestamp,
      "First subscription timestamp cannot be set in the future."
    );
    
    user_first_subscription_timestamps[user] = first_subscription_timestamp;
    
    if (
      user_latest_subscription_timestamps[user] <
      user_first_subscription_timestamps[user]
    ) {
      user_latest_subscription_timestamps[user] =
        user_first_subscription_timestamps[user];
    }
  }

  function setMultipleUserFirstSubscriptionTimestamps(
    address[] calldata users, uint[] calldata first_subscription_timestamps
  ) public onlyAdmin {
    uint num_users = users.length;
    require(
      num_users == first_subscription_timestamps.length,
      "The number of users and timestamps must match."
    );

    for (uint i_user = 0; i_user < num_users; ++i_user) {
      setUserFirstSubscriptionTimestamp(users[i_user],
        first_subscription_timestamps[i_user]);
    }
  }

  function setUserLatestSubscriptionTimestamp(address user,
      uint latest_subscription_timestamp) public onlyAdmin {
    require(
      latest_subscription_timestamp <= block.timestamp,
      "Latest subscription timestamp cannot be set in the future."
    );

    user_latest_subscription_timestamps[user] = latest_subscription_timestamp;

    if (
      (user_first_subscription_timestamps[user] == 0) ||
      (
        user_first_subscription_timestamps[user] >
        user_latest_subscription_timestamps[user]
      )
    ) {
      user_first_subscription_timestamps[user] = user_latest_subscription_timestamps[user];
    }
  }

  function setMultipleUserLatestSubscriptionTimestamps(
    address[] calldata users, uint[] calldata latest_subscription_timestamps
  ) public onlyAdmin {
    uint num_users = users.length;
    require(
      num_users == latest_subscription_timestamps.length,
      "The number of users and timestamps must match."
    );

    for (uint i_user = 0; i_user < num_users; ++i_user) {
      setUserLatestSubscriptionTimestamp(users[i_user], latest_subscription_timestamps[i_user]);
    }
  }

  function setUserTier(address user, uint new_i_tier) public onlyAdmin {
    require(isExistingTier(new_i_tier) == true, "Invalid tier id.");

    user_tiers[user] = new_i_tier;
    setUserLatestSubscriptionTimestamp(user, block.timestamp);
  }

  function setMultipleUserTiers(address[] calldata users,
      uint[] calldata new_i_tiers) public onlyAdmin {
    uint num_users = users.length;
    require(
      num_users == new_i_tiers.length,
      "The number of users and tiers must match."
    );

    for (uint i_user = 0; i_user < num_users; ++i_user) {
      setUserTier(users[i_user], new_i_tiers[i_user]);
    }
  }

  // ##### Administrative logic for Discounts #####
  function setDiscountNumerator(address user, uint new_discount_numerator)
      public onlyAdmin {
    require(
      new_discount_numerator >= 0, 
      "A discount cannot be negative, i.e. make the tiers cost more."
    );
    require(
      new_discount_numerator <= discount_denominator,
      "A discount cannot be larger than 100%."
    );
    
    discount_numerators[user] = new_discount_numerator;
    emit NewDiscountSet(
      block.timestamp,
      user,
      discount_numerators[user],
      discount_denominator
    );
  }

  function setDiscountNumerators(address[] calldata users,
      uint[] calldata new_discount_numerators) public onlyAdmin {
    require(
      users.length == new_discount_numerators.length,
      "The number of users and new discount numerators must match."
    );
    
    uint num_new_discounts = users.length;
    for (uint i_discount = 0; i_discount < num_new_discounts; ++i_discount) {
      address user = users[i_discount];
      uint new_discount_numerator = new_discount_numerators[i_discount];

      setDiscountNumerator(user, new_discount_numerator);
    }
  }

  // Warning: calling this alone will mess up older discount_numerators. Avoid
  // calling this function externally.
  function setDiscountDenominator(uint new_discount_denominator)
      public onlyAdmin {
    require(
      new_discount_denominator >= 0,
      "The discount denominator cannot be negative."
    );
    
    discount_denominator = new_discount_denominator;
  }

  function setDiscountDenominatorAndNumerators(uint new_discount_denominator,
      address[] calldata users, uint[] calldata new_discount_numerators)
      public onlyAdmin {
    setDiscountDenominator(new_discount_denominator);
    setDiscountNumerators(users, new_discount_numerators);
  }

  // ##### Administrative logic for admin info #####
  function addAdmin(address new_admin) public onlyMasterAdmin {
    require(isAdmin(new_admin) == false, "User is already an administrator.");

    admin_addresses.push(new_admin);
  }

  function addAdmins(address[] calldata new_admins) public onlyMasterAdmin {
    uint num_new_admins = new_admins.length;
    for (uint i_admin = 0; i_admin < num_new_admins; ++i_admin) {
      addAdmin(new_admins[i_admin]);
    }
  }

  function removeAdmin(address removed_admin) public onlyMasterAdmin {
    require(
      isAdmin(removed_admin) == true,
      "User to be removed is not an administrator."
    );

    uint num_admins = admin_addresses.length;
    uint i_removed_admin = 0;
    for (uint i_admin = 0; i_admin < num_admins; ++i_admin) {
      if (removed_admin == admin_addresses[i_admin]) {
        i_removed_admin = i_admin;
        break;
      }
    }

    admin_addresses[i_removed_admin] =
      admin_addresses[admin_addresses.length - 1];
    admin_addresses.pop();
  }

  function removeAdmins(address[] calldata removed_admins)
      public onlyMasterAdmin {
    uint num_removed_admins = removed_admins.length;
    for (
      uint i_removed_admin = 0; i_removed_admin < num_removed_admins;
      ++i_removed_admin
    ) {
      removeAdmin(removed_admins[i_removed_admin]);
    }
  }

  // ##### Administrative logic for payees #####
  function setNewPayees(address[] memory payees, uint256[] memory shares_)
      public onlyMasterAdmin {
    setNewPayeesInternal(payees, shares_);
  }

  function releaseTokens(address[] memory token_addresses)
      public onlyMasterAdmin {
    releaseTokensInternal(token_addresses);
  }

  function releaseAllConsideredTokens() public onlyMasterAdmin {
    releaseTokensInternal(considered_tokens);
  }

  // ----- Helpers -----
  function _setTierAvailability(uint i_tier, bool tier_availability)
      public onlyAdmin {
    require(isExistingTier(i_tier) == true, "Invalid tier id.");
    require(
      tier_availabilities[i_tier] != tier_availability,
      "The tier's stored availability is already set to the given argument."
    );

    tier_availabilities[i_tier] = tier_availability;
  }

  function _setConsideredTokenAcceptance(address token_address, bool acceptance)
      public onlyAdmin {
    require(
      isTokenConsidered(token_address) == true,
      "Token is not among the tokens considered to be ever used."
    );
    require(
      token_acceptances[token_address] != acceptance,
      "Token acceptance is already set to the given argument."
    );

    token_acceptances[token_address] = acceptance;
  }

  // ----- Getters -----
  // --- Accepted payment tokens ---
  function isTokenConsidered(address token_address) public view returns (bool) {
    uint num_considered_tokens = considered_tokens.length;

    for (uint i_token = 0; i_token < num_considered_tokens; ++i_token) {
      if (token_address == considered_tokens[i_token]) {
        return true;
      }
    }

    return false;
  }

  function getConsideredTokens() public view returns (address[] memory) {
    return considered_tokens;
  }

  function isTokenAccepted(address token_address) public view returns (bool) {
    return isTokenConsidered(token_address) && token_acceptances[token_address];
  }

  // Returns an array of bools representing the acceptance status of the
  // considered tokens, in the same order as the one in considered_tokens;
  function getTokenAcceptances() public view returns (bool[] memory) {
    bool[] memory acceptances = new bool[](considered_tokens.length);

    for (uint i_token = 0; i_token < considered_tokens.length; ++i_token) {
      address token_address = considered_tokens[i_token];

      acceptances[i_token] = token_acceptances[token_address];
    }

    return acceptances;
  }

  function getNumAcceptedTokens() public view returns (uint) {
    uint num_accepted_tokens = 0;
    uint num_considered_tokens = considered_tokens.length;
    for (uint i_token = 0; i_token < num_considered_tokens; ++i_token) {
      address considered_token_address = considered_tokens[i_token];
      if (token_acceptances[considered_token_address] == true) {
        ++num_accepted_tokens;
      }
    }

    return num_accepted_tokens;
  }

  function getAcceptedTokens() public view returns (address[] memory) {
    uint num_accepted_tokens = getNumAcceptedTokens();
    address[] memory accepted_tokens = new address[](num_accepted_tokens);
    uint i_accepted_token = 0;

    uint num_considered_tokens = considered_tokens.length;
    for (uint i_token = 0; i_token < num_considered_tokens; ++i_token) {
      address considered_token_address = considered_tokens[i_token];
      if (token_acceptances[considered_token_address] == true) {
        accepted_tokens[i_accepted_token] = considered_token_address;
        ++i_accepted_token;
      }
    }

    return accepted_tokens;
  }

  // --- Subscription tiers & Discounts ---
  // Returns the total number of tiers (both available and unavailable), i.e.
  // the number of tiers that were added at some point.
  function getNumberOfTiers() public view returns (uint) {
    // Must account for the fact that tier id 0 is never used, i.e. indexing
    // of stored tiers starts from 1 (tier_stored_prop[0] is dummy always).
    return tier_availabilities.length - 1;
  }

  function isExistingTier(uint i_tier) public view returns (bool) {
    uint num_tiers = getNumberOfTiers();
    
    return (1 <= i_tier) && (i_tier <= num_tiers);
  }

  function getTierAvailability(uint i_tier) public view returns (bool) {
    require(isExistingTier(i_tier) == true, "Invalid tier id.");

    return tier_availabilities[i_tier];
  }

  function getTierAvailabilities() public view returns (bool[] memory) {
    return tier_availabilities;
  }

  function getTierDurationInDays(uint i_tier) public view returns (uint) {
    require(isExistingTier(i_tier) == true, "Invalid tier id.");

    return tier_durations_days[i_tier];
  }

  function getTierDurationsInDays() public view returns (uint[] memory) {
    return tier_durations_days;
  }

  function getTierBasePriceInToken(uint i_tier, address token_address)
      public view returns (uint) {
    require(isExistingTier(i_tier) == true, "Invalid tier id.");
    require(
      isTokenConsidered(token_address) == true,
      "Provided token is not considered for payment."
    );
  
    return tier_base_prices[i_tier][token_address];
  }

  function getTierBasePricesInAllConsideredTokens(uint i_tier)
      public view returns (uint[] memory) {
    require(isExistingTier(i_tier) == true, "Invalid tier id.");

    uint[] memory base_prices_for_tier = new uint[](considered_tokens.length);
    for (uint i_token = 0; i_token < considered_tokens.length; ++i_token) {
      address token_address = considered_tokens[i_token];
      base_prices_for_tier[i_token] = tier_base_prices[i_tier][token_address];
    }

    return base_prices_for_tier;
  }

  // ---> Discounts
  function getDiscountDenominator() public view returns (uint) {
    return discount_denominator;
  }

  function getDiscountNumeratorForUser(address user)
      public view returns (uint) {
    return discount_numerators[user];
  }

  function getAbsoluteDiscountForTierInTokenForUser(
      uint i_tier, address token_address, address user)
      public view returns (uint) {
    uint base_tier_price = getTierBasePriceInToken(i_tier, token_address);
    uint discount_numerator_for_user = getDiscountNumeratorForUser(user);

    if (discount_denominator <= 0) {
      return 0;
    }
    if (discount_numerator_for_user <= 0) {
      return 0;
    }
    if (discount_numerator_for_user > discount_denominator) {
      // Something bad happened related to setDiscountDenominator.
      return 0;
    }

    return (
      base_tier_price * discount_numerator_for_user / discount_denominator
    );
  }

  // Note: any integer clamping will affect the absolute discount making it
  // possibly smaller due to the float to int conversion, so the tier price can
  // only be a bit larger than the final discounted price, but never smaller.
  function getTierPriceInTokenForUser(uint i_tier, address token_address,
      address user) public view returns (uint) {
    uint base_tier_price = getTierBasePriceInToken(i_tier, token_address);
    uint discount_absolute = getAbsoluteDiscountForTierInTokenForUser(
      i_tier, token_address, user
    );
    
    return base_tier_price - discount_absolute;
  }

  function getTierPriceInAllAcceptedTokensForUser(uint i_tier, address user)
      public view returns (address[] memory, uint[] memory) {
    address[] memory accepted_tokens = getAcceptedTokens();
    uint num_accepted_tokens = accepted_tokens.length;
    uint[] memory prices = new uint[](num_accepted_tokens);

    for (uint i_token = 0; i_token < num_accepted_tokens; ++i_token) {
      address accepted_token = accepted_tokens[i_token];
      uint price_for_user = getTierPriceInTokenForUser(i_tier, accepted_token,
          user);
      
      prices[i_token] = price_for_user;
    }

    return (accepted_tokens, prices);
  }

  // --- User info ---
  function getUserFirstSubscriptionTimestamp(address user)
      public view returns (uint) {
    return user_first_subscription_timestamps[user];
  }

  function getUserLatestSubscriptionTimestamp(address user)
      public view returns (uint) {
    return user_latest_subscription_timestamps[user];
  }

  function getUserTier(address user) public view returns (uint) {
    return user_tiers[user];
  }

  function isUserSubscribed(address user) public view returns (bool) {
    if (user_latest_subscription_timestamps[user] == 0) {
      // User never subscribed.
      return false;
    }

    uint num_seconds_passed = (
      block.timestamp - user_latest_subscription_timestamps[user]
    );
    uint num_days_passed = num_seconds_passed / (60 * 60 * 24);
    if (num_days_passed >= tier_durations_days[user_tiers[user]]) {
      // User's last subscription expired.
      return false;
    }

    return true;
  }

  function getSecondsPassedFromCurrentSubscription(address user)
      public view returns (uint) {
    require(
      isUserSubscribed(user) == true,
      "User is not currently subscribed."
    );

    return (block.timestamp - user_latest_subscription_timestamps[user]);
  }

  function getDaysPassedFromCurrentSubscription(address user)
      public view returns (uint) {
    uint num_seconds_passed = getSecondsPassedFromCurrentSubscription(user);

    return num_seconds_passed / (60 * 60 * 24);
  }

  function getSecondsRemainingFromCurrentSubscription(address user)
      public view returns (uint) {
    // Checks that the user is subscribed.
    uint num_passed_seconds = getSecondsPassedFromCurrentSubscription(user);
    uint tier_duration_days = tier_durations_days[user_tiers[user]];
    uint tier_duration_seconds = tier_duration_days * 24 * 60 * 60;

    return tier_duration_seconds - num_passed_seconds;
  }

  function getDaysRemainingFromCurrentSubscription(address user)
      public view returns (uint) {
    uint num_remaining_seconds =
      getSecondsRemainingFromCurrentSubscription(user);

    return num_remaining_seconds / (60 * 60 * 24);
  }

  // --- Admin addresses ---
  function getMasterAdminAddress() public view returns (address) {
    return master_admin;
  }

  function getAdminAddresses() public view returns (address[] memory) {
    return admin_addresses;
  }

  function isAdmin(address user) public view returns (bool) {
    bool is_admin = false;
    for (uint i_admin = 0; i_admin < admin_addresses.length; ++i_admin) {
      if (user == admin_addresses[i_admin]) {
        is_admin = true;
        break;
      }
    }

    return is_admin;
  }
}