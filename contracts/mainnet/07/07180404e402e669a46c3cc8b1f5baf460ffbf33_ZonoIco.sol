/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// Sources flattened with hardhat v2.3.3 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/[email protected]



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
    constructor () {
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


// File @openzeppelin/contracts/token/ERC20/[email protected]



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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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


// File @openzeppelin/contracts/utils/[email protected]



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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]



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
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File contracts/libs/UniversalERC20.sol


pragma solidity ^0.8.4;

// File: contracts/UniversalERC20.sol
library UniversalERC20 {
    using SafeERC20 for IERC20;

    IERC20 private constant ZERO_ADDRESS =
        IERC20(0x0000000000000000000000000000000000000000);
    IERC20 private constant ETH_ADDRESS =
        IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        if (amount == 0) {
            return 0;
        }

        if (isETH(token)) {
            payable(address(uint160(to))).transfer(amount);
            return amount;
        } else {
            uint256 balanceBefore = token.balanceOf(to);
            token.safeTransfer(to, amount);
            uint256 balanceAfter = token.balanceOf(to);
            return balanceAfter - balanceBefore;
        }
    }

    function universalTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        if (amount == 0) {
            return 0;
        }

        if (isETH(token)) {
            require(
                from == msg.sender && msg.value >= amount,
                "Wrong useage of ETH.universalTransferFrom()"
            );
            if (to != address(this)) {
                payable(address(uint160(to))).transfer(amount);
            }
            if (msg.value > amount) {
                // refund redundant amount
                payable(msg.sender).transfer(msg.value - amount);
            }
            return amount;
        } else {
            uint256 balanceBefore = token.balanceOf(to);
            token.safeTransferFrom(from, to, amount);
            uint256 balanceAfter = token.balanceOf(to);
            return balanceAfter - balanceBefore;
        }
    }

    function universalTransferFromSenderToThis(IERC20 token, uint256 amount)
        internal
        returns (uint256)
    {
        if (amount == 0) {
            return 0;
        }

        if (isETH(token)) {
            if (msg.value > amount) {
                // Return remainder if exist
                payable(msg.sender).transfer(msg.value - amount);
            }
            return amount;
        } else {
            uint256 balanceBefore = token.balanceOf(address(this));
            token.safeTransferFrom(msg.sender, address(this), amount);
            uint256 balanceAfter = token.balanceOf(address(this));
            return balanceAfter - balanceBefore;
        }
    }

    function universalApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        if (!isETH(token)) {
            if (amount > 0 && token.allowance(address(this), to) > 0) {
                token.safeApprove(to, 0);
            }
            token.safeApprove(to, amount);
        }
    }

    function universalBalanceOf(IERC20 token, address who)
        internal
        view
        returns (uint256)
    {
        if (isETH(token)) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }

    function universalDecimals(IERC20 token) internal view returns (uint256) {
        if (isETH(token)) {
            return 18;
        }

        (bool success, bytes memory data) = address(token).staticcall{
            gas: 10000
        }(abi.encodeWithSignature("decimals()"));
        if (!success || data.length == 0) {
            (success, data) = address(token).staticcall{gas: 10000}(
                abi.encodeWithSignature("DECIMALS()")
            );
        }

        return (success && data.length > 0) ? abi.decode(data, (uint256)) : 18;
    }

    function isETH(IERC20 token) internal pure returns (bool) {
        return (address(token) == address(ZERO_ADDRESS) ||
            address(token) == address(ETH_ADDRESS));
    }
}


// File contracts/zono/ZonoIco.sol

pragma solidity ^0.8.0;


contract ZonoIco is Ownable {
    using SafeERC20 for IERC20;
    using Address for address payable;
    using UniversalERC20 for IERC20;

    struct ContributeData {
        uint256 amount;
        bool claimed;
    }

    IERC20 private immutable _icoToken;
    address payable private immutable _icoOwner; // ICO owner wallet address
    address payable private immutable _icoTreasury; // ICO treasury wallet address
    uint16 private immutable _treasuryFee; // ICO treasury fee

    uint256 private _startDate = 1665093600; // When to start ICO - Oct 6, 2022 22:00:00 UTC
    uint256 private _endDate = 1665612000; // When to end ICO - Oct 12, 2022 22:00:00 UTC
    uint256 private _claimDate = 1665619200; // When to claim ICO - Oct 13, 2022 00:00:00 UTC

    uint256 private _hardcap = 2000000 ether; // hard cap
    uint256 private _softcap = 1000000 ether; // softcap
    uint256 private _icoPrice = 0.0005 ether; // token price
    uint256 private _minPerUser = 100 ether; // min amount per user
    uint256 private _maxPerUser = 250000 ether; // max amount per user

    bool private _fundsWithdrawn;
    uint256 private _totalContributed; // Total contributed amount in buy token
    uint256 private _totalClaimed; // Total claimed amount in buy token
    mapping(address => ContributeData) private _contributedPerUser; // User contributed amount in buy token

    constructor(
        IERC20 icoToken_,
        address payable icoTreasury_,
        address payable icoOwner_,
        uint16 treasuryFee_
    ) {
        icoToken_.balanceOf(address(this)); // To check the IERC20 contract
        _icoToken = icoToken_;

        require(
            icoOwner_ != address(0) && icoTreasury_ != address(0),
            "Invalid owner / treasury"
        );
        _icoOwner = icoOwner_;
        _icoTreasury = icoTreasury_;
        _treasuryFee = treasuryFee_;
    }

    /**
     * @dev Contribute ICO
     *
     * Only available when ICO is opened
     */
    function contribute() external payable {
        require(
            block.timestamp >= _startDate && block.timestamp < _endDate,
            "ICO not opened"
        );

        uint256 contributeAmount = msg.value;
        ContributeData storage userContributeData = _contributedPerUser[
            _msgSender()
        ];

        uint256 contributedSoFar = userContributeData.amount + contributeAmount;
        require(
            contributedSoFar >= _minPerUser && contributedSoFar <= _maxPerUser,
            "Out of limit"
        );

        userContributeData.amount = contributedSoFar;
        _totalContributed += contributeAmount;

        require(_totalContributed <= _hardcap, "Reached hardcap");
    }

    /**
     * @dev Claim tokens from his contributed amount
     *
     * Only available after claim date
     */
    function claimTokens() external {
        require(block.timestamp > _claimDate, "Wait more");
        ContributeData storage userContributedData = _contributedPerUser[
            _msgSender()
        ];
        require(!userContributedData.claimed, "Already claimed");
        uint256 userContributedAmount = userContributedData.amount;
        require(userContributedAmount > 0, "Not contributed");

        uint256 userRequiredAmount = (userContributedAmount *
            10**(_icoToken.universalDecimals())) / _icoPrice;

        if (userRequiredAmount > 0) {
            _icoToken.safeTransfer(_msgSender(), userRequiredAmount);
        }
        userContributedData.claimed = true;
        _totalContributed += userContributedAmount;
    }

    /**
     * @dev Finalize ICO when it was filled or by some reasons
     *
     * It should indicate claim date
     * Only ICO owner is allowed to call this function
     */
    function finalizeIco(uint256 claimDate_) external {
        require(_msgSender() == _icoOwner, "Unpermitted");
        require(block.timestamp < _endDate, "Already finished");
        require(block.timestamp < claimDate_, "Invalid claim date");
        if (_startDate > block.timestamp) {
            _startDate = block.timestamp;
        }
        _endDate = block.timestamp;
        _claimDate = claimDate_;
    }

    /**
     * @dev Withdraw remained tokens
     *
     * Only ICO owner is allowed to call this function
     */
    function withdrawRemainedTokens() external {
        require(_msgSender() == _icoOwner, "Unpermitted");
        require(block.timestamp >= _endDate, "ICO not finished");
        uint256 contractTokens = _icoToken.balanceOf(address(this));
        uint256 unclaimedTokens = ((_totalContributed - _totalClaimed) *
            10**(_icoToken.universalDecimals())) / _icoPrice;

        _icoToken.safeTransfer(_msgSender(), contractTokens - unclaimedTokens);
    }

    /**
     * @dev Withdraw contributed funds
     *
     * Only ICO owner is allowed to call this function
     */
    function withdrawFunds() external {
        require(_msgSender() == _icoOwner, "Unpermitted");
        require(block.timestamp >= _endDate, "ICO not finished");
        require(!_fundsWithdrawn, "Already withdrawn");

        // Transfer treasury funds first
        uint256 treasuryFunds = (_totalContributed * _treasuryFee) / 10000;
        _icoTreasury.sendValue(treasuryFunds);

        // Transfer redundant funds
        _icoOwner.sendValue(_totalContributed - treasuryFunds);

        _fundsWithdrawn = true;
    }

    function viewIcoToken() external view returns (address) {
        return address(_icoToken);
    }

    function viewIcoOwner() external view returns (address payable) {
        return _icoOwner;
    }

    function viewIcoTreasury() external view returns (address payable) {
        return _icoTreasury;
    }

    function viewTreasuryFee() external view returns (uint16) {
        return _treasuryFee;
    }

    function viewTotalContributed() external view returns (uint256) {
        return _totalContributed;
    }

    function viewTotalClaimed() external view returns (uint256) {
        return _totalClaimed;
    }

    function viewUserContributed(address account_)
        external
        view
        returns (uint256, bool)
    {
        return (
            _contributedPerUser[account_].amount,
            _contributedPerUser[account_].claimed
        );
    }

    /**
     * @dev Update ICO start / end / claim date
     *
     * Only owner is allowed to call this function
     */
    function updateIcoDates(
        uint256 startDate_,
        uint256 endDate_,
        uint256 claimDate_
    ) external onlyOwner {
        require(block.timestamp < _startDate, "ICO already started");
        require(block.timestamp < startDate_, "Must be future time");
        require(startDate_ < endDate_, "startDate must before endDate");
        require(endDate_ < claimDate_, "endDate must before claimDate");

        _startDate = startDate_;
        _endDate = endDate_;
        _claimDate = claimDate_;
    }

    function viewIcoDates()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (_startDate, _endDate, _claimDate);
    }

    /**
     * @dev Update ICO hardcap / softcap
     *
     * Only owner is allowed to call this function
     */
    function updateCap(uint256 softcap_, uint256 hardcap_) external onlyOwner {
        require(block.timestamp < _startDate, "ICO already started");
        require(hardcap_ > 0 && softcap_ > 0, "Non zero values");
        require(softcap_ <= hardcap_, "Invalid values");
        _hardcap = hardcap_;
        _softcap = softcap_;
    }

    function viewCap() external view returns (uint256, uint256) {
        return (_softcap, _hardcap);
    }

    /**
     * @dev Update user contribute min / max limitation
     *
     * Only owner is allowed to call this function
     */
    function updateLimitation(uint256 minPerUser_, uint256 maxPerUser_)
        external
        onlyOwner
    {
        require(minPerUser_ <= maxPerUser_, "Invalid values");
        require(maxPerUser_ > 0, "Invalid max value");
        _minPerUser = minPerUser_;
        _maxPerUser = maxPerUser_;
    }

    function viewLimitation() external view returns (uint256, uint256) {
        return (_minPerUser, _maxPerUser);
    }

    /**
     * @dev Update ICO price
     *
     * Only owner is allowed to call this function
     */
    function updateIcoPrice(uint256 icoPrice_) external onlyOwner {
        require(block.timestamp < _startDate, "ICO already started");
        require(icoPrice_ > 0, "Invalid price");
        _icoPrice = icoPrice_;
    }

    function viewIcoPrice() external view returns (uint256) {
        return _icoPrice;
    }

    /**
     * @dev Recover ETH sent to the contract
     *
     * Only owner allowed to call this function
     */
    function recoverETH() external onlyOwner {
        require(_fundsWithdrawn, "Not available until withdraw funds");
        uint256 etherBalance = address(this).balance;
        require(etherBalance > 0, "No ETH");
        payable(_msgSender()).transfer(etherBalance);
    }

    /**
     * @dev It allows the admin to recover tokens sent to the contract
     * @param token_: the address of the token to withdraw
     * @param amount_: the number of tokens to withdraw
     *
     * This function is only callable by owner
     */
    function recoverToken(address token_, uint256 amount_) external onlyOwner {
        require(token_ != address(_icoToken), "Not allowed token");
        require(amount_ > 0, "Non zero value");
        IERC20(token_).safeTransfer(_msgSender(), amount_);
    }

    /**
     * @dev To receive ETH in the ICO contract
     */
    receive() external payable {}
}