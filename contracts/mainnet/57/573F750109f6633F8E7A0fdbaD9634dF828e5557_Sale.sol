/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;

interface IERC20 {

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



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
 
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

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

    constructor() public {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
        {
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

interface Refer {
    function setRelationship(address bindAddr, address currentAddr) external;
}

/*
*/
contract Sale is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    Refer public refer;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public redeemTime;
    //record if the buyer has bought
    mapping(address => bool) public purchasedBuyer;
    mapping(address => bool) public firstClaimableMap;
    //if purchasedAmount(targetToken's amountFactor) is 0, mean the guy didn't buy it, or it has redeemed
    mapping(address => uint256) public purchasedAmountFactor;

    //which address to withdraw, only keep message!!!!!
    //for bsc
    mapping(address => address) public purchasedBuyerBscAddress;
    //an auxiliary array for loop
    address[] public purchasedList;
    address[] public purchasedListBscAddress;

    IERC20 public targetToken;
    //sourceToken => price
    mapping(IERC20 => uint256) public sourceAmounts;//need source token amount per subscription, zero for not allowed

    uint256 public targetAmountFactor;//redeem target token amount per subscription, normally it is 1
    uint256 public targetCurrentSupply;//for targetAmountFactor
    //purchased Amount to Token
    uint256 public targetTokenMultiplicationFactor;

    //immutable
    uint256 public targetTotalSupply;//for targetAmountFactor

    // IERC20 public checkToken;
    // uint256 public checkTokenMinimum;

    bool public whiteListActivated;
    mapping(address => bool) public whiteList;

    bool public secondClaim;

    uint256 public purchaseFee = 0.002 ether;
    address public feeManager;
    address public rewardManager;

    event Purchase(address indexed buyer, address sourceToken, uint256 sourceAmount, uint256 targetAmountFactor,address bscAddress);
    event Redeem(address indexed buyer, uint256 targetAmount);
    event Disqualification(address indexed buyer, uint256 targetAmountFactor);

    constructor(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _redeemTime,
        IERC20[] memory _sourceTokens,
        IERC20 _targetToken,
        uint256[] memory _sourceAmounts,
        uint256 _targetAmountFactor,
        uint256 _targetCurrentSupply,
        uint256 _targetTokenMultiplicationFactor,
        bool _whiteListActivated,
        address _feeManager,
        address _refer,
        address _rewardManager
    ) public {
        require(_startTime < _endTime, "_startTime < _endTime");
        require(_endTime < _redeemTime, "_endTime< _redeemTime");
        require(_sourceTokens.length == _sourceAmounts.length, "_sourceTokens.length == _sourceAmounts.length");
        startTime = _startTime;
        endTime = _endTime;
        redeemTime = _redeemTime;
        for (uint256 i = 0; i < _sourceTokens.length; i++) {
            sourceAmounts[_sourceTokens[i]] = _sourceAmounts[i];
        }
        targetToken = _targetToken;
        targetAmountFactor = _targetAmountFactor;
        targetCurrentSupply = _targetCurrentSupply;
        targetTotalSupply = _targetCurrentSupply;
        targetTokenMultiplicationFactor = _targetTokenMultiplicationFactor;
        whiteListActivated = _whiteListActivated;
        feeManager = _feeManager;
        refer = Refer(_refer);
        rewardManager = _rewardManager;
    }

    modifier inPurchase(){
        require(startTime <= block.timestamp, "IDO has not started");
        require(block.timestamp < endTime, "IDO has end");
        _;
    }

    modifier inRedeem(){
        require(redeemTime <= block.timestamp, "Redeem has not started");
        _;
    }

    modifier isTargetTokenReady(){
        require(address(targetToken) != address(0), "Target token addres not set");
        require(targetTokenMultiplicationFactor > 0, "targetTokenMultiplicationFactor should not be zero");
        _;
    }

//    modifier qualified(){
//        if (address(checkToken) != address(0)) {
//            require(checkToken.balanceOf(msg.sender) >= checkTokenMinimum);
//        }
//        _;
//    }

//    modifier white(){
//        if (whiteListActivated) {
//            require(whiteList[_msgSender()] == true, "You are not permitted to ido, or have participated");
//        }
//        _;
//    }

    modifier chargeFee(){
        require(msg.value >= purchaseFee);
        payable(feeManager).transfer(msg.value);
        _;
    }

    function setSecondClaim(bool flag) external onlyOwner {
        secondClaim = flag;
    }

    function setRefer(address _addr) external onlyOwner {
        refer = Refer(_addr);
    }

    function setFeeManager(address _addr) external onlyOwner {
        feeManager = _addr;
    }

    function setRewardManager(address _addr) external onlyOwner {
        rewardManager = _addr;
    }

    function purchasedListLength() view external returns (uint256){
        return purchasedList.length;
    }

    function purchasedListBscAddressLength() view external returns (uint256){
        return purchasedListBscAddress.length;
    }

    //only for front end
    function isPermittedAndQualified() view external returns (bool, string memory){
        // if (address(checkToken) != address(0)) {
        //     if (checkToken.balanceOf(_msgSender()) < checkTokenMinimum) {
        //         return (false, "checkTokenMinimum fails");
        //     }
        // }
        if (whiteListActivated) {
            if (whiteList[_msgSender()] == false) {
                return (false, "whiteList fails");
            }
        }

        return (true, "ok");
    }

    function redeemable(address buyer) view external returns (bool){
        if (block.timestamp < redeemTime) {
            return false;
        }
        if (purchasedAmountFactor[buyer] == uint256(0)) {
            return false;
        }
        return true;
    }


    function purchase(IERC20 sourceToken, address bscAddress, address referAddress) inPurchase nonReentrant /*qualified*/ /*white*/ chargeFee payable external {
        require(bscAddress != address(0), "bscAddress can not be 0x00");
        address buyer = _msgSender();
        require(purchasedBuyer[buyer] == false, "You have bought");
        require(targetCurrentSupply >= targetAmountFactor, "Not enough target quota");
        uint256 sourceAmount = sourceAmounts[sourceToken];
        require(sourceAmount >= 0, "Source token is not permitted");

        purchasedBuyer[buyer] = true;
        firstClaimableMap[buyer] = true;
        purchasedBuyerBscAddress[_msgSender()] = bscAddress;
        // twice is not allowed
        purchasedAmountFactor[buyer] = targetAmountFactor;
        require(purchasedList.length == purchasedListBscAddress.length, "purchasedList.length == purchasedListBscAddress.length");
        purchasedList.push(buyer);
        purchasedListBscAddress.push(bscAddress);

        refer.setRelationship(referAddress, bscAddress);

        targetCurrentSupply = targetCurrentSupply.sub(targetAmountFactor);

        uint256 reward = sourceAmount.div(100).mul(20);
        uint256 extra = sourceAmount.sub(reward);
        SafeERC20.safeTransferFrom(sourceToken, buyer, feeManager, extra);
        SafeERC20.safeTransferFrom(sourceToken, buyer, rewardManager, reward);

        emit Purchase(buyer, address(sourceToken), sourceAmount, targetAmountFactor,bscAddress);
    }


    /*
    before redeem, target token must be transferred into this contract
    */
    function redeem() inRedeem isTargetTokenReady nonReentrant chargeFee payable external {
        address buyer = _msgSender();
        require(firstClaimableMap[buyer] == true, "already redeem first claim");
        uint256 amountFactor = purchasedAmountFactor[buyer];
        require(amountFactor != uint256(0), "You didn't purchase or you have redeemed, or you have disqualified");

        uint256 amount = amountFactor.mul(targetTokenMultiplicationFactor).div(2);
        uint256 balance = targetToken.balanceOf(address(this));
        require(balance >= amount, "Target token balance not enough");
        SafeERC20.safeTransfer(targetToken, buyer, amount);
        firstClaimableMap[buyer] = false;
        emit Redeem(buyer, amount);
    }

    function secondRedeem() inRedeem isTargetTokenReady nonReentrant chargeFee payable external {
        address buyer = _msgSender();
        require(secondClaim == true, "second claim not start");
        uint256 amountFactor = purchasedAmountFactor[buyer];
        require(amountFactor != uint256(0), "You didn't purchase or you have redeemed, or you have disqualified");

        purchasedAmountFactor[buyer] = 0;
        uint256 amount = amountFactor.mul(targetTokenMultiplicationFactor).div(2);
        uint256 balance = targetToken.balanceOf(address(this));
        require(balance >= amount, "Target token balance not enough");
        SafeERC20.safeTransfer(targetToken, buyer, amount);
        firstClaimableMap[buyer] = false;
        emit Redeem(buyer, amount);
    }

    //force to flush data at any time
    function disqualify(address buyer, uint256 amountFactor) onlyOwner external {
        purchasedAmountFactor[buyer] = amountFactor;
        emit Disqualification(buyer, amountFactor);
    }

    //admin can transfer any token in emergency
    function transferSourceToken(IERC20 tokenAddress, address to) onlyOwner external {
        uint256 amount = tokenAddress.balanceOf(address(this));
        SafeERC20.safeTransfer(tokenAddress, to, amount);
    }

    //admin can transfer any eth in emergency
    function transferETH(address to) onlyOwner external {
        uint256 amount = address(this).balance;
        if (amount > 0) {
            payable(to).transfer(amount);
        }
    }

    function initSet(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _redeemTime
    ) onlyOwner external {
        require(block.timestamp < _startTime, "updateConfig must happens before it starts");


        require(_startTime < _endTime, "_startTime < _endTime");
        require(_endTime < _redeemTime, "_endTime < _redeemTime");

        startTime = _startTime;
        endTime = _endTime;
        redeemTime = _redeemTime;
    }
    
    function setEndTime(uint256 _endTime) onlyOwner external{
        require(startTime < _endTime, "startTime < _endTime");
        require(_endTime < redeemTime, "_endTime < redeemTime");
        endTime = _endTime;
    }
    
    function setRedeemTime(uint256 _redeemTime) onlyOwner external{
        require(_redeemTime > endTime, "_endTime < redeemTime");
        redeemTime = _redeemTime;
    }
    
    function setStartTime(uint256 _startTime) onlyOwner external{
        require(block.timestamp < _startTime, "updateConfig must happens before it starts");
        require(_startTime < endTime, "_startTime < endTime");
        startTime = _startTime;
    }

    function updateConfig(
        uint256 _endTime,
        uint256 _redeemTime
    ) onlyOwner external {
        require(block.timestamp < endTime, "updateConfig must happens before it ends");

        if (_endTime == 0) {
            _endTime = block.timestamp;
        }


        require(startTime < _endTime, "_startTime < _endTime");
        require(_endTime < _redeemTime, "_endTime < _redeemTime");

        require(block.timestamp <= _endTime, "new endTime must not before now");

        endTime = _endTime;
        redeemTime = _redeemTime;
    }

    function changeRedeemTime(uint256 _redeemTime) onlyOwner external {
        if (_redeemTime == uint256(0)) {
            _redeemTime = block.timestamp;
        }
        require(endTime < _redeemTime, "endTime < _redeemTime");
        redeemTime = _redeemTime;
    }

    //usually, it should not be invoked
    function changeTargetAmountFactor(uint256 _targetAmountFactor) onlyOwner external {
        targetAmountFactor = _targetAmountFactor;
    }

    function changeTargetTokenAndMultiplicationFacto(IERC20 _targetToken, uint256 _targetTokenMultiplicationFactor) onlyOwner external {
        targetToken = _targetToken;
        targetTokenMultiplicationFactor = _targetTokenMultiplicationFactor;
    }

    function changeSourceTokenAmount(IERC20 _sourceToken, uint256 _sourceAmount) onlyOwner external {
        sourceAmounts[_sourceToken] = _sourceAmount;
    }

    // function changeCheckToken(IERC20 _checkToken, uint256 _checkTokenMinimum) onlyOwner external {
    //     checkToken = _checkToken;
    //     checkTokenMinimum = _checkTokenMinimum;
    // }

    function changeWhiteListActivated(bool _whiteListActivated) onlyOwner external {
        whiteListActivated = _whiteListActivated;
    }

    function addWhiteList(address[] calldata users) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            whiteList[users[i]] = true;
        }
    }

    function changeFee(address _feeManager, uint256 _purchaseFee) onlyOwner external {
        feeManager = _feeManager;
        purchaseFee = _purchaseFee;
    }
    
    function getCurrentTimestamp() public view returns (uint256) {
        return block.timestamp;
    }
}