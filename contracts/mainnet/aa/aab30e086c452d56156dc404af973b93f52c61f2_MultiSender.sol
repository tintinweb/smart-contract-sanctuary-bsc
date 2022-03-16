/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

/**
 * ███╗   ███╗██╗   ██╗██╗  ████████╗██╗   ███████╗███████╗███╗   ██╗██████╗ ███████╗██████╗ 
 * ████╗ ████║██║   ██║██║  ╚══██╔══╝██║   ██╔════╝██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗
 * ██╔████╔██║██║   ██║██║     ██║   ██║   ███████╗█████╗  ██╔██╗ ██║██║  ██║█████╗  ██████╔╝
 * ██║╚██╔╝██║██║   ██║██║     ██║   ██║   ╚════██║██╔══╝  ██║╚██╗██║██║  ██║██╔══╝  ██╔══██╗
 * ██║ ╚═╝ ██║╚██████╔╝███████╗██║   ██║██╗███████║███████╗██║ ╚████║██████╔╝███████╗██║  ██║
 * ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
      return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
      return msg.data;
    }

    function _msgValue() internal view virtual returns (uint256) {
      return msg.value;
    }
}

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

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "MultiSender: APPROVE_FAILED");
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "MultiSender: TRANSFER_FAILED");
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "MultiSender: TRANSFER_FROM_FAILED");
    }
    
    // sends ETH or an erc20 token
    function safeTransferBaseToken(address token, address payable to, uint value, bool isERC20) internal {
        if (!isERC20) {
            to.transfer(value);
        } else {
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), "MultiSender: TRANSFER_FAILED");
        }
    }
}

contract MultiSender is Ownable {
  using Address for address;
  using SafeERC20 for IERC20;

  struct TokenInfo {
    string name;
    string symbol;
    uint256 decimal;
  }

  address public tokenAddressForDistribution;
  TokenInfo public tokenInfo;

  uint256 private _serviceFee = 0.25 ether;

  address[] private _arrayInitiator;
  address[] private _receivers;
  mapping(address => uint256) public multiSendingInfo;

  constructor () {}

  /** 
   * @dev Send tokens to multiple address with amount passed in amounts_ array
   * from the contract. Tokens need to be deposited to the contract to be sent
   * by the contract.
   *
   * @param tokenAddress_ Token address to be sent
   * @param receivers_ Address list to receive token specified by the address
   * @param amounts_ Token amounts to be sent to each addresses
   */
  function multiSendTokenFromContractAt(address tokenAddress_, address[] memory receivers_, uint256[] memory amounts_) public onlyOwner {
    require(tokenAddress_ != address(0), "MultiSender: Address can't be zero address");
    require(tokenAddress_ != address(this), "MultiSender: Can't set as self address");
    require(IERC20(tokenAddress_).balanceOf(address(this)) > 0, "MultiSender: Insufficient tokens to send");
    require(receivers_.length > 0, "MultiSender: Receiver length should be greater than zero");
    require(receivers_.length == amounts_.length, "MultiSender: Receiver length should be same as amounts length");

    uint256 totalSupplyToDistribute = 0;
    for (uint256 i = 0; i < receivers_.length; i++) {
      totalSupplyToDistribute += amounts_[i];
    }

    require(IERC20(tokenAddress_).balanceOf(address(this)) >= totalSupplyToDistribute, "MultiSender: Insufficient tokens to send");

    for (uint256 i = 0; i < receivers_.length; i++) {
      TransferHelper.safeTransfer(address(tokenAddressForDistribution), address(receivers_[i]), amounts_[i]);
    }
  }

  /** 
   * @dev Send tokens to multiple address with amount passed in amounts_ array
   * from the wallet linked to the contract. Tokens need to be deposited to th
   * e contract to be sent by the contract.
   *
   * [===== IMPORTANT =====]
   * Need to increase allowance between wallet and the contract from the token
   * smart contract
   *
   * @param tokenAddress_ Token address to be sent
   * @param receivers_ Address list to receive token specified by the address
   * @param amounts_ Token amounts to be sent to each addresses
   */
  function multiSendTokensFromWalletAt(address tokenAddress_, address[] memory receivers_, uint256[] memory amounts_) public {
    require(_msgValue() > _serviceFee, "MultiSender: Must pay appropreate fee");
    require(tokenAddress_ != address(0), "MultiSender: Address can't be zero address");
    require(tokenAddress_ != address(this), "MultiSender: Can't set as self address");
    require(IERC20(tokenAddress_).balanceOf(_msgSender()) > 0, "MultiSender: Insufficient tokens to send");
    require(receivers_.length > 0, "MultiSender: Receiver length should be greater than zero");
    require(receivers_.length == amounts_.length, "MultiSender: Receiver length should be same as amounts length");

    uint256 totalSupplyToDistribute = 0;
    for (uint256 i = 0; i < receivers_.length; i++) {
      totalSupplyToDistribute += amounts_[i];
    }

    require(IERC20(tokenAddress_).balanceOf(_msgSender()) >= totalSupplyToDistribute, "MultiSender: Insufficient tokens to send");

    for (uint256 i = 0; i < receivers_.length; i++) {
      TransferHelper.safeTransferFrom(address(tokenAddressForDistribution), address(_msgSender()), address(receivers_[i]), amounts_[i]);
    }
  }

  function addReceiver(address to_, uint256 amount_) public onlyOwner {
    require(to_ != address(0), "MultiSender: Can't send to zero address");
    require(to_ != address(this), "MultiSender: Can't send to self address");
    require(amount_ > 0, "MultiSender: Amount should be greater than zero");

    _receivers.push(to_);
    multiSendingInfo[to_] = amount_;
  }

  function addReceivers(address[] memory receivers_, uint256[] memory amounts_) public onlyOwner {
    require(receivers_.length > 0, "MultiSender: Address list should be greater than zero");
    require(receivers_.length == amounts_.length, "MultiSender: Need to have same length of tos and amounts");

    for (uint256 i = 0; i < receivers_.length; i++) {
      _receivers.push(receivers_[i]);
      multiSendingInfo[receivers_[i]] = amounts_[i];
    }
  }

  function initAddressList() public onlyOwner {
    // This overwrite is not for gas saving solution
    _receivers = _arrayInitiator;
  }

  function distributeTokens() public onlyOwner {
    require(_receivers.length > 0, "MultiSender: Don't have addresses to send tokens");

    for (uint256 i = 0; i < _receivers.length; i++) {
      TransferHelper.safeTransfer(address(tokenAddressForDistribution), address(_receivers[i]), multiSendingInfo[_receivers[i]]);
    }
  }

  function setTokenForDistribution (address newAddress_) public onlyOwner {
    require(newAddress_ != address(0), "MultiSender: Address can't be zero address");
    require(newAddress_ != address(this), "MultiSender: Can't set as self address");
    
    tokenAddressForDistribution = newAddress_;

    tokenInfo.name = IERC20Metadata(tokenAddressForDistribution).name();
    tokenInfo.symbol = IERC20Metadata(tokenAddressForDistribution).symbol();
    tokenInfo.decimal = IERC20Metadata(tokenAddressForDistribution).decimals();
  }

  function getTokenSupplyForDistrubution () public view returns (uint256) {
    return IERC20(tokenAddressForDistribution).balanceOf(address(this));
  }

  function serviceFee() public view returns (uint256) {
    return _serviceFee;
  }

  function setServiceFee(uint256 fee_) public onlyOwner {
    require(fee_ < 1 ether, "MultiSender: Too greedy");

    _serviceFee = fee_;
  }

  function reClaimCoin (address to_) public onlyOwner {
      require(to_ != address(0), "MultiSender: claim to the zero address");

      payable(to_).transfer(address(this).balance);
  }

  function reClaimToken (address token_, address to_) public onlyOwner {
      require(to_ != address(0), "MultiSender: claim to the zero address");
      require(token_ != address(0), "MultiSender: claim to the zero address");
      require(token_ != address(this), "MultiSender: self withdraw");

      uint256 tokenBalance = IERC20(token_).balanceOf(address(this));
      IERC20(token_).transfer(to_, tokenBalance);
  }
}