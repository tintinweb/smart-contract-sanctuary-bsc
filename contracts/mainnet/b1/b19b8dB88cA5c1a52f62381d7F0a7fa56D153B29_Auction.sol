// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Auction is Ownable {
    using SafeERC20 for IERC20;
    address public immutable BUSD;
    bool public active;
    uint256 public buyLimit;
    mapping (address => address) public receiver;
    mapping (address => uint256) public fee; // 1 = 0.01%

    struct auctionInfo {
        uint256 startPrice;
        uint256 bottomPrice;
        uint256 offeringAmount;
        uint256 soldAmount;
        uint256 lastPrice;
        uint256 soldUSD;
        uint16 sensitivity;
        uint32 startTime;
        uint32 endTime;
        uint32 lastBuy;
        bool claimedUSD;
    }

    mapping(address => auctionInfo) public token;

    event OnBuy (address _buyer, address _token, uint256 _tokenAmount, uint256 _busdAmount, uint256 _price);
    event OnClaimUSD (address _token, uint256 _busdAmount);
    event OnAddAuction (address _token);
    event OnWithdraw (address _token, uint256 _tokenAmount);
    event OnSetActive (bool _status);
    event OnSetBuyLimit (uint256 _busdLimit);
    event OnSetSensitivity (address _token, uint16 _sensitivity);
    event OnSetReceiver (address _token, address _receiver);

    modifier isActive {
        require(active == true, "Inactive");
        _;
    }

    constructor (address _BUSD) {
        active = true;
        BUSD = _BUSD;
        buyLimit = 10000000000000000000000;
    }

    function buy (
        address _token,
        uint256 _tokenAmount,
        uint256 _busdAmount,
        uint256 _timeout,
        uint256 _slippage
    ) public isActive {
        require (block.timestamp <= _timeout, "Timeout");
        require (IERC20(BUSD).balanceOf(_msgSender()) >= _busdAmount, "BUSD is not enough");
        require (block.timestamp <= token[_token].endTime, "Auction already is over");
        require (block.timestamp >= token[_token].startTime, "Auction is not start yet");
        IERC20(BUSD).transferFrom(_msgSender(), address(this), _busdAmount);
        if (receiver[_token] != address(0)) {
            transferToReceiver(_token, _busdAmount);
        }
        uint256 boughtAmount = quoteTokenAmount(_token, _busdAmount);
        uint256 newPrice = quoteTokenPrice(_token, _busdAmount);
        require ( newPrice <= (_busdAmount * 10 ** 18 / _tokenAmount) * (_slippage + 10000) / 10000, "Slippage too high");
        IERC20(_token).transfer(_msgSender(), boughtAmount);
        token[_token].lastPrice = newPrice;
        token[_token].lastBuy = uint32(block.timestamp);
        token[_token].soldAmount += boughtAmount;
        token[_token].soldUSD += _busdAmount;
        emit OnBuy (_msgSender(), _token, boughtAmount, _busdAmount, newPrice);
    }

    function transferToReceiver (
        address _token,
        uint256 _busdAmount
    ) internal {
        if (fee[_token] != 0 ) {
            uint256 feeAmount = _busdAmount * fee[_token] / 10000;
            IERC20(BUSD).transfer(receiver[_token], _busdAmount - feeAmount);
            IERC20(BUSD).transfer(owner(), feeAmount);
        } else {
            IERC20(BUSD).transfer(receiver[_token], _busdAmount);
        }
    }

    /// Owner Function ///

    function addAuction (
        address _token,
        uint256 _startPrice,
        uint256 _bottomPrice,
        uint256 _offeringAmount,
        uint16 _sensitivity,
        uint32 _startTime,
        uint32 _endTime,
        address _receiver,
        uint256 _fee
    ) public onlyOwner {
        require (_startTime < _endTime, "Start time must be lower than End time");
        bool noNeedClaim;
        if (_receiver != address(0)) {
            noNeedClaim = true;
        } else {
            noNeedClaim = false;
        }
        token[_token] = auctionInfo(
            _startPrice,
            _bottomPrice,
            _offeringAmount,
            0,
            _startPrice,
            0,
            _sensitivity,
            _startTime,
            _endTime,
            _startTime,
            noNeedClaim
        );
        receiver[_token] = _receiver;
        fee[_token] = _fee;
        IERC20(_token).transferFrom(_msgSender(), address(this), _offeringAmount);
        emit OnAddAuction(_token);
    }

    function setSensitivity (
        address _token,
        uint16 _sensitivity
    ) public onlyOwner {
        require(_sensitivity > 0, "Must be greater than zero");
        token[_token].sensitivity = _sensitivity;
        emit OnSetSensitivity(_token, _sensitivity);
    }

    function setReceiver (
        address _token,
        address _receiver
    ) public onlyOwner {
        require (_receiver != address(0), "Receiver cannot be zero address");
        require (block.timestamp < token[_token].startTime, "Cannot change receiver during auction");
        receiver[_token] = _receiver;
        emit OnSetReceiver(_token, _receiver);
    }

    function claimFund (
        address _token
    ) public onlyOwner {
        require(token[_token].claimedUSD == false, "Already claimed");
        require(block.timestamp > token[_token].endTime, "Not over yet");
        require(receiver[_token] == address(0), "No need to claim");
        IERC20(BUSD).transfer(_msgSender(), token[_token].soldUSD);
        token[_token].claimedUSD = true;
        emit OnClaimUSD(_token, token[_token].soldUSD);
    }

    function withdraw (
        address _token
    ) public onlyOwner {
        require(block.timestamp > token[_token].endTime || block.timestamp < token[_token].startTime, "Not over yet");
        IERC20(_token).transfer(_msgSender(), IERC20(_token).balanceOf(address(this)));
        emit OnWithdraw (_token, IERC20(_token).balanceOf(address(this)));
    }

    function setActive (
        bool _status
    ) public onlyOwner {
        active = _status;
        emit OnSetActive (_status);
    }

    function setBuyLimit (
        uint256 _busdLimit
    ) public onlyOwner {
        require (_busdLimit > 0, 'Limit cannot be zero');
        buyLimit = _busdLimit;
        emit OnSetBuyLimit (_busdLimit);
    }

    /// View Function ///

    function tokenPrice (
        address _token
    ) view public returns(uint256) {
        uint256 currentTime;
        if ( block.timestamp >= token[_token].endTime ) {
            currentTime = token[_token].endTime;
        } else if ( block.timestamp < token[_token].startTime ) {
            currentTime = token[_token].startTime;
        } else {
            currentTime = block.timestamp;
        }
        uint256 _lastPrice = token[_token].lastPrice - (( token[_token].startPrice - token[_token].bottomPrice ) / ( token[_token].endTime - token[_token].startTime ) * ( currentTime - token[_token].lastBuy ));
        return _lastPrice;
    }

    function quoteTokenAmount (
        address _token,
        uint256 _busdAmount
    ) view public returns(uint256) {
        uint256 newPrice = quoteTokenPrice(_token, _busdAmount);
        uint256 quoteAmount = _busdAmount * 10 ** 18 / newPrice;
        return quoteAmount;
    }

    function quoteTokenPrice (
        address _token,
        uint256 _busdAmount
    ) view public returns(uint256) {
        uint256 estAmount = _busdAmount * 10 ** 18 / tokenPrice(_token);
        uint256 newPrice = (estAmount * 10 ** 18 / token[_token].offeringAmount * 100 / token[_token].sensitivity) * token[_token].startPrice / 10 ** 18 + tokenPrice(_token);
        return newPrice;
    }

    function quoteTokenEst (
        address _token,
        uint256 _busdAmount
    ) view public returns(uint256) {
        uint256 estAmount = _busdAmount * 10 ** 18 / tokenPrice(_token);
        return estAmount;
    }

    function tokenRemaining (
        address _token
    ) view public returns(uint256) {
        return token[_token].offeringAmount - token[_token].soldAmount;
    }

}