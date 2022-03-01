/**
 *Submitted for verification at BscScan.com on 2022-03-01
*/

// SPDX-License-Identifier: NONE

pragma solidity >=0.8.0;
pragma abicoder v2;

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


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

    constructor () {
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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *a
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        require(b > 0, errorMessage);
        return a % b;
    }
}


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


library SafeERC20 {
    using SafeMath for uint256;
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
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

contract MultiFeeDistribution is ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    struct Reward {
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        uint256 penaltyPeriodFinish;
        uint256 penaltyRewardRate;
        uint256 penaltyLastUpdateTime;
        uint256 penaltyRewardPerTokenStored;
    }

    struct Balances {
        uint256 total;
        uint256 locked;
        uint256 staked;
    }

    struct LockedBalance {
        uint256 amount;
        uint256 unlockTime;
    }

    struct StakedBalance {
        uint256 amount;
        uint256 unlockTime;
        uint256 reward;
        uint256 userRewardPerTokenPaid;
    }

    struct RewardData {
        uint256 amount;
    }



    IERC20 public immutable stakingToken;
    address public rewardToken;
    mapping(address => Reward) public rewardData;

    // Duration that rewards are streamed over
    uint256  constant rewardsDuration = 200000;

    // Duration of lock/earned penalty period
    uint256  constant lockDuration =  1200;

    uint[3] public penaltyPercentage;

    uint public denominator=10000;
  
    // distributor -> is approved to add rewards
    mapping(address => bool) public rewardDistributors;

    // user -> amount
    mapping(address =>  uint256) public userLockedRewardPerTokenPaid;
    mapping(address => uint256) public lockedRewards;

    mapping(address =>  uint256) public userPenaltyRewardPerTokenPaid;
    mapping(address => uint256) public penaltyRewards;


    mapping(address =>uint256) public claimedRewards;

    uint256 public totalSupply;
    uint256 public lockedSupply;
    uint256  public stakedSupply;

    //  mappings for balance data
    mapping(address => Balances) public balances;
    mapping(address => LockedBalance[]) public userLocks;
    mapping(address => StakedBalance[]) public userStakes;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _stakingToken,address _rewardToken,uint[3] memory _penalty) Ownable() {
        penaltyPercentage=_penalty;
        stakingToken =IERC20(_stakingToken);
        rewardToken = _rewardToken;
        rewardDistributors[msg.sender] = true;
    }

    function changePenaltyPercentgae(uint[3] memory _penalty)external onlyOwner{
        penaltyPercentage=_penalty;
    }

    // Modify approval for an address to call notifyRewardAmount
    function approveRewardDistributor(address _distributor,bool _approved) external onlyOwner {
        rewardDistributors[_distributor] = _approved;
    }

    /* ========== VIEWS ========== */

    function userLocksCount(address _user) external view returns(uint){
        return userLocks[_user].length;
    }

    function userStakingCount(address _user) external view returns(uint){
        return userStakes[_user].length;
    }



    function _rewardPerToken(uint256 _supply) internal view returns (uint256) {
        if (_supply == 0) {
            return rewardData[rewardToken].rewardPerTokenStored;
        }
        return
            rewardData[rewardToken].rewardPerTokenStored.add(
                lastTimeRewardApplicable(false).sub(
                    rewardData[rewardToken].lastUpdateTime).mul(
                        rewardData[rewardToken].rewardRate).mul(1e18).div(_supply)
            );
    }

    function _penaltyRewardPerToken( uint256 _supply) internal view returns (uint256) {
        if (_supply == 0) {
            return rewardData[rewardToken].penaltyRewardPerTokenStored;
        }
        return
            rewardData[rewardToken].penaltyRewardPerTokenStored.add(
                lastTimeRewardApplicable(true).sub(
                    rewardData[rewardToken].penaltyLastUpdateTime).mul(
                        rewardData[rewardToken].penaltyRewardRate).mul(1e18).div(_supply)
            );
    }

    function _earned(
        address _user,
        uint256 _index,
        uint256 _balance,
        uint256 _supply,
        bool _lock
    ) internal view returns (uint256) {
        if(!_lock){
            return _balance.mul(
                _rewardPerToken( _supply).sub(userStakes[_user][_index].userRewardPerTokenPaid)
                ).div(1e18).add(userStakes[_user][_index].reward);
        }else{
            return _balance.mul(
                _rewardPerToken( _supply).sub(userLockedRewardPerTokenPaid[_user])
                ).div(1e18).add(lockedRewards[_user]);
        }
    }

    function _penaltyEarned(address _user,uint256 _balance,uint _supply)internal view returns(uint256){
        return _balance.mul(
                _penaltyRewardPerToken( _supply).sub(userPenaltyRewardPerTokenPaid[_user])
                ).div(1e18).add(penaltyRewards[_user]);
                
    }

    function lastTimeRewardApplicable(bool penalty) public view returns (uint256) {
        if(!penalty){
            return Math.min(block.timestamp, rewardData[rewardToken].periodFinish);
        }
        else{
             return Math.min(block.timestamp, rewardData[rewardToken].penaltyPeriodFinish);
        }
        
    }

    function rewardPerToken(bool penalty) external view returns (uint256) {
        if(!penalty){
            return _rewardPerToken(totalSupply);
        }else{
            return _penaltyRewardPerToken(lockedSupply);
        }
    }

    function getRewardForDuration(bool penalty) external view returns (uint256) {
        if(!penalty){
            return rewardData[rewardToken].rewardRate.mul(rewardsDuration);
        }else{
            return rewardData[rewardToken].penaltyRewardRate.mul(rewardsDuration);
        }
        
    }

    // Address and claimable amount of all reward tokens for the given account
    function claimableRewardsWithoutPenalty(address account) external view returns (RewardData[] memory rewardsAmount) {
        rewardsAmount = new RewardData[](2);
        uint supply=totalSupply;
        uint length=userStakes[account].length;
        for(uint j=0;j<length;j++){
            if(userStakes[account][j].unlockTime > block.timestamp){
                break;
            }
            rewardsAmount[0].amount += _earned(account, j, userStakes[account][j].amount, supply,false);
        }
        rewardsAmount[0].amount += _earned(account,0,balances[account].locked,supply,true);

        rewardsAmount[1].amount = _penaltyEarned(account,balances[account].locked,lockedSupply);

        return rewardsAmount;  
    }

    // Address and claimable amount of all reward tokens for the given account
    function claimableRewards(address account) external view returns (RewardData[] memory rewardsAmount) {
        rewardsAmount = new RewardData[](2);
        uint supply=totalSupply;
        uint length=userStakes[account].length;
        for(uint j=0;j<length;j++){
            rewardsAmount[0].amount += _earned(account, j, userStakes[account][j].amount, supply,false);
        }
        rewardsAmount[0].amount += _earned(account,0,balances[account].locked,supply,true);

        rewardsAmount[1].amount = _penaltyEarned(account,balances[account].locked,lockedSupply);

        return rewardsAmount;  
    }

    

    /* // Total balance of an account, including unlocked, locked and earned tokens
    function totalBalance(address user) view external returns (uint256 amount) {
        return balances[user].total;
    } */

    // Total withdrawable balance for an account to which no penalty is applied
    function unlockedBalanceWithoutPenalty(address user) view external returns (uint256 amount) {
        StakedBalance[] storage stakes = userStakes[user];
        for (uint i = 0; i < stakes.length; i++) {
            if (stakes[i].unlockTime > block.timestamp) {
                break;
            }
            amount = amount.add(stakes[i].amount);
        }
        return amount;
    }

    // Information on a user's locked balances
    function lockedBalances(
        address user
    ) view external returns (
        uint256 total,
        uint256 unlockable,
        uint256 locked,
        LockedBalance[] memory lockData
    ) {
        LockedBalance[] storage locks = userLocks[user];
        uint256 idx;
        for (uint i = 0; i < locks.length; i++) {
            if (locks[i].unlockTime > block.timestamp) {
                if (idx == 0) {
                    lockData = new LockedBalance[](locks.length - i);
                }
                lockData[idx] = locks[i];
                idx++;
                locked = locked.add(locks[i].amount);
            } else {
                unlockable = unlockable.add(locks[i].amount);
            }
        }
        return (balances[user].locked, unlockable, locked, lockData);
    }

    // Final balance received and penalty balance paid by user upon calling exit
    function withdrawableTotalRewards(address user) view public returns (uint256 totalRewards,uint256 penaltyAmount) {
        Balances storage bal = balances[user];
        uint supply=totalSupply;
        if (bal.staked > 0) {
            uint256 length = userStakes[user].length;
            uint calcPenalty;
            for (uint i = 0; i < length; i++) {
                calcPenalty=0;
                uint256 stakedAmount = userStakes[user][i].amount;
                uint256 rewardAmount= _earned(user, i, stakedAmount, supply,false);
                if (stakedAmount == 0) continue;
                if (userStakes[user][i].unlockTime > block.timestamp) {
                    uint256 timeStaked = userStakes[user][i].unlockTime.sub(block.timestamp);
                    if(timeStaked > 60 days){
                        calcPenalty = rewardAmount.mul(penaltyPercentage[0]).div(denominator);
                    }
                    else if(timeStaked <= 60 days && timeStaked > 30 days){
                        calcPenalty = rewardAmount.mul(penaltyPercentage[1]).div(denominator);
                    }
                    else if(timeStaked <= 30 days && timeStaked > 0 days){
                        calcPenalty = rewardAmount.mul(penaltyPercentage[2]).div(denominator);
                    }

                    penaltyAmount +=calcPenalty;
                    totalRewards +=rewardAmount.sub(calcPenalty);
                }else{
                    totalRewards += rewardAmount;
                }    
            }
        }
        
        return (totalRewards, penaltyAmount);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    // Stake tokens to receive rewards
    // Locked tokens cannot be withdrawn for lockDuration and are eligible to receive stakingReward rewards
    function stake(uint256 amount, bool lock) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        totalSupply = totalSupply.add(amount);
        Balances storage bal = balances[msg.sender];
        bal.total = bal.total.add(amount);
        if (lock) {
            lockedSupply = lockedSupply.add(amount);
            bal.locked = bal.locked.add(amount);
            uint256 unlockTime = block.timestamp.div(rewardsDuration).mul(rewardsDuration).add(lockDuration);
            uint256 idx = userLocks[msg.sender].length;
            if (idx == 0 || userLocks[msg.sender][idx-1].unlockTime < unlockTime) {
                userLocks[msg.sender].push(LockedBalance({amount: amount, unlockTime: unlockTime}));
            } else {
                userLocks[msg.sender][idx-1].amount = userLocks[msg.sender][idx-1].amount.add(amount);
            }
        } else {
            stakedSupply = stakedSupply.add(amount);
            bal.staked = bal.staked.add(amount);
            uint256 unlockTime = block.timestamp.div(rewardsDuration).mul(rewardsDuration).add(lockDuration);
            uint256 idx = userStakes[msg.sender].length;
            if (idx == 0 || userStakes[msg.sender][idx-1].unlockTime < unlockTime) {
                userStakes[msg.sender].push(StakedBalance({amount: amount, unlockTime: unlockTime,reward:0,userRewardPerTokenPaid:rewardData[rewardToken].rewardPerTokenStored}));
            } else {
                userStakes[msg.sender][idx-1].amount = userStakes[msg.sender][idx-1].amount.add(amount);
            }
        }
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

  

    // Withdraw staked tokens 
    // incurs  penalty if withdraw before 90 days which is distributed based on locked balances.
    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        Balances storage bal = balances[msg.sender];
        uint256 penaltyAmount;
        uint256 calcPenalty;
        uint256 remaining = amount;
        uint256 totalRewards;
        require(bal.staked >= remaining, "Insufficient staked balance");
        bal.staked = bal.staked.sub(remaining);
        uint256 length=userStakes[msg.sender].length;
        for (uint i = 0;i<length ; i++) {
                calcPenalty = 0;
                uint256 stakedAmount = userStakes[msg.sender][i].amount;
                uint256 rewardAmount= userStakes[msg.sender][i].reward;
                if (stakedAmount == 0) continue;
                if (userStakes[msg.sender][i].unlockTime > block.timestamp) {
                    uint256 penalty;
                    if(stakedAmount>=remaining){
                        penalty = remaining.mul(rewardAmount).div(stakedAmount);
                    }
                    else{
                        penalty=rewardAmount;
                    }
                    uint256 timeStaked = userStakes[msg.sender][i].unlockTime.sub(block.timestamp);
                    if(timeStaked > 60 days){
                        calcPenalty = penalty.mul(penaltyPercentage[0]).div(denominator);
                    }
                    else if(timeStaked <= 60 days && timeStaked > 30 days){
                        calcPenalty = penalty.mul(penaltyPercentage[1]).div(denominator);
                    }
                    else if(timeStaked <= 30 days && timeStaked > 0 days){
                        calcPenalty = penalty.mul(penaltyPercentage[2]).div(denominator);
                    }

                    penaltyAmount +=calcPenalty;
                    totalRewards +=rewardAmount.sub(calcPenalty);

                    if (stakedAmount>= remaining) {
                        userStakes[msg.sender][i].amount = stakedAmount.sub(remaining);
                        userStakes[msg.sender][i].reward=0;
                        break;
                    } else {
                        delete userStakes[msg.sender][i];
                        remaining = remaining.sub(stakedAmount);
                    }
                }else{
                    if (remaining <= stakedAmount) {
                        totalRewards += rewardAmount;
                        userStakes[msg.sender][i].reward=0;
                        userStakes[msg.sender][i].amount = stakedAmount.sub(remaining);
                        break;
                    } else {
                        totalRewards += rewardAmount;
                        delete userStakes[msg.sender][i];
                        remaining = remaining.sub(stakedAmount);
                    }
                }
                
            }
        bal.total = bal.total.sub(amount);
        totalSupply = totalSupply.sub(amount);
        stakedSupply=stakedSupply.sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        IERC20(rewardToken).safeTransfer(msg.sender,totalRewards);
        claimedRewards[msg.sender] = claimedRewards[msg.sender].add(totalRewards);
        if (penaltyAmount > 0) {
            _notifyReward(rewardToken,penaltyAmount,true);
        }
        emit Withdrawn(msg.sender, amount);
    }

    // Claim all pending staking rewards
    function getReward() public nonReentrant updateReward(msg.sender) {
        uint length=userStakes[msg.sender].length;
        address _rewardsToken = rewardToken;
        uint totalRewards;
        for(uint j=0;j<length;j++){
            if(block.timestamp > userStakes[msg.sender][j].unlockTime){
                totalRewards += userStakes[msg.sender][j].reward;
                userStakes[msg.sender][j].reward=0;
            }
        }
        totalRewards += lockedRewards[msg.sender];
        lockedRewards[msg.sender]=0;
        totalRewards += penaltyRewards[msg.sender];
        penaltyRewards[msg.sender]=0;
        claimedRewards[msg.sender] = claimedRewards[msg.sender].add(totalRewards);
        if (totalRewards > 0) {    
            IERC20(_rewardsToken).safeTransfer(msg.sender, totalRewards);
            emit RewardPaid(msg.sender, _rewardsToken, totalRewards);
        }  
    }

    // Withdraw full staked balance and claim pending rewards
    function exit() external updateReward(msg.sender) {
        (uint256 totalRewards, uint256 penaltyAmount) = withdrawableTotalRewards(msg.sender);
        delete userStakes[msg.sender];
        
        Balances storage bal = balances[msg.sender];
	    uint amount=bal.staked;
        totalSupply=totalSupply.sub(amount);
        stakedSupply=stakedSupply.sub(amount);
        bal.total=bal.total.sub(amount);
        bal.staked = 0;
        stakingToken.safeTransfer(msg.sender, amount);
	    IERC20(rewardToken).safeTransfer(msg.sender,totalRewards);
        claimedRewards[msg.sender] = claimedRewards[msg.sender].add(totalRewards);
        if (penaltyAmount > 0) {
             _notifyReward(rewardToken,penaltyAmount,true);
        }
        getReward();
    }

    // Withdraw all currently locked tokens where the unlock time has passed
    function withdrawExpiredLocks() external updateReward(msg.sender){
        LockedBalance[] storage locks = userLocks[msg.sender];
        Balances storage bal = balances[msg.sender];
        uint256 amount;
        uint256 length = locks.length;
        if (locks[length-1].unlockTime <= block.timestamp) {
            amount = bal.locked;
            delete userLocks[msg.sender];
        } else {
            for (uint i = 0; i < length; i++) {
                if (locks[i].unlockTime > block.timestamp) break;
                amount = amount.add(locks[i].amount);
                delete locks[i];
            }
        }
        bal.locked = bal.locked.sub(amount);
        bal.total = bal.total.sub(amount);
        totalSupply = totalSupply.sub(amount);
        lockedSupply = lockedSupply.sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function _notifyReward(address _rewardsToken, uint256 reward,bool penalty) internal {
        if(penalty){
             if (block.timestamp >= rewardData[_rewardsToken].penaltyPeriodFinish) {
                rewardData[_rewardsToken].penaltyRewardRate = reward.div(rewardsDuration);
            } else {
                uint256 remaining = rewardData[_rewardsToken].penaltyPeriodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardData[_rewardsToken].penaltyRewardRate);
                rewardData[_rewardsToken].penaltyRewardRate = reward.add(leftover).div(rewardsDuration);
            }

            rewardData[_rewardsToken].penaltyLastUpdateTime = block.timestamp;
            rewardData[_rewardsToken].penaltyPeriodFinish = block.timestamp.add(rewardsDuration);
            emit penaltyRewardAdded(reward);
        }else{
             if (block.timestamp >= rewardData[_rewardsToken].periodFinish) {
                rewardData[_rewardsToken].rewardRate = reward.div(rewardsDuration);
            } else {
                uint256 remaining = rewardData[_rewardsToken].periodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardData[_rewardsToken].rewardRate);
                rewardData[_rewardsToken].rewardRate = reward.add(leftover).div(rewardsDuration);
            }

            rewardData[_rewardsToken].lastUpdateTime = block.timestamp;
            rewardData[_rewardsToken].periodFinish = block.timestamp.add(rewardsDuration);
        }
    }

    function notifyRewardAmount(address _rewardsToken, uint256 reward) external updateReward(address(0)) {
        require(rewardDistributors[msg.sender],"Not Authorized");
        require(reward > 0, "No reward");
        // handle the transfer of reward tokens via `transferFrom` to reduce the number
        // of transactions required and ensure correctness of the reward amount
        IERC20(_rewardsToken).safeTransferFrom(msg.sender, address(this), reward);
        _notifyReward(_rewardsToken, reward,false);
        emit RewardAdded(reward);
    }

    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(tokenAddress != address(stakingToken), "Cannot withdraw staking token");
        require(rewardData[tokenAddress].lastUpdateTime == 0, "Cannot withdraw reward token");
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        uint256 supply;
        supply = totalSupply;
        uint length=userStakes[account].length;
        rewardData[rewardToken].rewardPerTokenStored = _rewardPerToken(supply);
        rewardData[rewardToken].lastUpdateTime = lastTimeRewardApplicable(false);
        rewardData[rewardToken].penaltyRewardPerTokenStored=_penaltyRewardPerToken(lockedSupply);
        rewardData[rewardToken].penaltyLastUpdateTime = lastTimeRewardApplicable(true);
        if (account != address(0)) {
            for(uint j=0;j<length;j++){
                userStakes[account][j].reward = _earned(account,j, userStakes[account][j].amount, supply,false);
                userStakes[account][j].userRewardPerTokenPaid = rewardData[rewardToken].rewardPerTokenStored;
            }

            lockedRewards[account]=_earned(account,0,balances[account].locked,supply,true);
            userLockedRewardPerTokenPaid[account]=rewardData[rewardToken].rewardPerTokenStored;
 
            penaltyRewards[account]=_penaltyEarned(account,balances[account].locked,lockedSupply);
            userPenaltyRewardPerTokenPaid[account]=rewardData[rewardToken].penaltyRewardPerTokenStored;
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event penaltyRewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, address indexed rewardsToken, uint256 reward);
    event RewardsDurationUpdated(address token, uint256 newDuration);
    event Recovered(address token, uint256 amount);
}