/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
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

        // solhint-disable-next-line avoid-low-level-calls
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
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

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
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
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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

    constructor() internal {
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


contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;

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
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

interface BCC{
    function get_pairAddr() external view returns (address);
    function get_parents(address account) external view returns (address);
    function get_childers(address account) external view returns (address[] memory);
}

contract BccSake is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    address private marketAddr= 0xf98cd1616400a2e5f10B4350711BFE6F69420a60;
    address private bccAddr= 0x5623588c1CCdF8a7FE93637ad27532442e964D41;
    IBEP20 public usdtToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IBEP20 public rewardToken = IBEP20(bccAddr); 
    IBEP20 public lpToken;
    BCC public bccToken = BCC(bccAddr); 

    mapping (address => bool) private idoList;
    mapping (address => bool) private whiteList;
    mapping(string => PoolInfo) public poolInfo;
    mapping(address => UserInfo) public userIdo;
    mapping(address => UserInfo) public userWhite;
    uint256 lpMin = 5 * 1e18;

    address[] public whiteUserList;
    address[] public idoUserList;

    struct PoolInfo {
      uint256 duration;
      uint256 cost;
      uint256 totalIncome;
      uint256 totalNum;
      uint256 startTime;
      uint256 getAmount;
      uint256 periodAmount;
      uint256 periodNum;
      uint256 periodFlag;
      uint256 released;
      bool enable;
      bool isVaild;
    }

    struct UserInfo {
        uint256 duration;
        uint256 startTime; 
        uint256 getTime;
        uint256 perPaid; 
        uint256 amount; 
        uint256 rewarded; 
        uint256 rewardDebt; 
    }

    struct Info {
      uint256 earned_ido; 
      uint256 rewarded_ido;
      uint256 rewardDebt_ido;
      uint256 earned_white;
      uint256 rewarded_white;
      uint256 rewardDebt_white;
      bool isActive;
      uint256 bcc_token;
      uint256 lp_token;
      uint256 lpMin;
    }

    event Deposit(string _name, address indexed _user, uint256 _amount);
    event RewardPaid(string _flag, address indexed _user, uint256 _reward);
    event AdminTokenRecovery(address _tokenRecovered, uint256 _amount);
    event AdminSetEnable(string _name, bool _enable);

    constructor() public {
        lpToken = IBEP20(bccToken.get_pairAddr());
        poolInfo["ido"] = PoolInfo({
            duration: 100 days, 
            cost: 30 finney,  //0.03 BNB
            totalIncome: 0,
            totalNum: 0,
            startTime: 1658160000, //2022-07-19
            getAmount: 10000000 * 1e18,
            periodAmount: 400000000000 * 1e18,
            periodNum: 3,
            periodFlag: 0, 
            released: 0,
            enable: true,
            isVaild: true
        });

        poolInfo["white"] = PoolInfo({
            duration: 100 days, 
            cost: 100 * 1e18, //100 USDT
            totalIncome: 0,
            totalNum: 0,
            startTime: 1658160000, //2022-07-19
            getAmount: 150000000 * 1e18,
            periodAmount: 200000000000000 * 1e18,
            periodNum: 1,
            periodFlag: 0, 
            released: 0,
            enable: true,
            isVaild: true
        });

    }

    
    //////////////////
    //
    // OWNER functions
    //
    //////////////////

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        IBEP20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }
    function setPoolEnable(string memory name, bool value) external onlyOwner{
        require(poolInfo[name].isVaild==true,"The pool is not vaild");
        PoolInfo storage pool = poolInfo[name];
        pool.enable = value;
        emit AdminSetEnable(name,value);
    }
 
    function setLpMin(uint256 _lpMin) public onlyOwner {
      lpMin = _lpMin;
    }

    function setPoolCost(string memory name, uint256 value) external onlyOwner{
        require(poolInfo[name].isVaild==true,"The pool is not vaild");
        PoolInfo storage pool = poolInfo[name];
        pool.cost = value;
    }
    function setPoolPeriodAmount(string memory name, uint256 value) external onlyOwner{
        require(poolInfo[name].isVaild==true,"The pool is not vaild");
        PoolInfo storage pool = poolInfo[name];
        pool.periodAmount = value;
    }
    function set_marketAddr(address account) external onlyOwner{
        marketAddr = account;
    }

    function get_whiteUserList() external onlyOwner view returns (address[] memory) {
        return whiteUserList;
    }

    function get_idoUserList() external onlyOwner view returns (address[] memory) {
        return idoUserList;
    }

    function get_idoUserInfo(address account) external onlyOwner view returns (UserInfo memory) {
        UserInfo memory userinfo = userIdo[account];
        return userinfo;
    }
    function get_whiteUserInfo(address account) external onlyOwner view returns (UserInfo memory) {
        UserInfo memory userinfo = userWhite[account];
        return userinfo;
    }
    //////////////////
    //
    // PUBLIC functions
    //
    //////////////////

    receive() external payable {}

    function deposit_ido() payable public nonReentrant{ 
        PoolInfo storage pool = poolInfo["ido"];
        UserInfo storage my = userIdo[msg.sender];

        uint256 _amount = msg.value;

        require(!idoList[msg.sender], "BCC: Already involved");
        require(_amount >= pool.cost, "Insufficient quantity");
        require(pool.enable==true,"The pool is closed");
        require(block.timestamp > pool.startTime, "no start");
        require(pool.periodNum > pool.periodFlag, "Ended");
        
        idoList[msg.sender] = true;
        idoUserList.push(msg.sender);

        my.startTime = block.timestamp;
        my.getTime = block.timestamp;
        my.duration = pool.duration;
        my.amount = pool.getAmount;
        my.rewardDebt = pool.getAmount;
        my.perPaid = pool.getAmount.div(pool.duration);

        pool.released = pool.released.add(pool.getAmount);
        pool.totalIncome = pool.totalIncome.add(_amount);
        pool.totalNum = pool.totalNum.add(1);

        if (pool.released >= pool.periodAmount.mul( pool.periodFlag.add(1) )) {
            pool.periodFlag = pool.periodFlag.add(1);
            pool.getAmount = pool.getAmount.div(2);
        }
        
        payable(marketAddr).transfer(_amount);
        emit Deposit("ido",msg.sender, _amount);
    }

    function deposit_white(uint256 _amount) public nonReentrant{ 
        PoolInfo storage pool = poolInfo["white"];
        UserInfo storage my = userWhite[msg.sender];

        require(!whiteList[msg.sender], "BCC: Already involved");
        require(_amount >= pool.cost, "Insufficient quantity");
        require(pool.enable==true,"The pool is closed");
        require(block.timestamp > pool.startTime, "no start");
        require(pool.periodNum > pool.periodFlag, "Ended");
        
        whiteList[msg.sender] = true;
        whiteUserList.push(msg.sender);

        my.startTime = block.timestamp;
        my.getTime = block.timestamp;
        my.duration = pool.duration;
        my.amount = pool.getAmount;
        my.rewardDebt = pool.getAmount;
        my.perPaid = pool.getAmount.div(pool.duration);

        pool.released = pool.released.add(pool.getAmount);
        pool.totalIncome = pool.totalIncome.add(_amount);
        pool.totalNum = pool.totalNum.add(1);

        if (pool.released >= pool.periodAmount.mul( pool.periodFlag.add(1) )) {
            pool.periodFlag = pool.periodFlag.add(1);
        }

        uint256 rewardNum = _amount;
        address parents =  get_parents(msg.sender);
        if (parents != address(0) ) {
            uint256 reward = _amount.mul(20).div(100);  //20%
            rewardNum= _amount.sub(reward);
            usdtToken.safeTransferFrom(msg.sender, parents, reward);
        }
        usdtToken.safeTransferFrom(msg.sender, marketAddr, rewardNum);

        emit Deposit("white", msg.sender, _amount);
    }
    
    function earned_ido(address account) public view returns (uint256) {
        UserInfo storage my = userIdo[account];
        uint256 t = Math.min(block.timestamp, my.startTime.add(my.duration));
        uint256 num = ( t.sub(my.getTime) ).mul(my.perPaid);
        if(num<0){
           num = 0;
        }
        return num;
    }
    function earned_white(address account) public view returns (uint256) {
        UserInfo storage my = userWhite[account];
        uint256 t = Math.min(block.timestamp, my.startTime.add(my.duration));
        uint256 num = ( t.sub(my.getTime) ).mul(my.perPaid);
        if(num<0){
           num = 0;
        }
        return num;
    }

    function get_parents(address account) public view returns (address) {
        address parents =  bccToken.get_parents(account);
        return parents;
    }
    function get_childers(address account) public view returns (address[] memory) {
        address[] memory childers =  bccToken.get_childers(account);
        return childers;
    }

    function getIdoReward() public nonReentrant{
        UserInfo storage my = userIdo[msg.sender];

        require(lpToken.balanceOf(msg.sender) >= lpMin, 'LP is insufficient');

        uint256 reward = earned_ido(msg.sender);
        if(my.rewarded.add(reward) > my.amount){
            reward = my.amount.sub(my.rewarded);
        }

        if (reward > 0) {
            my.rewarded = my.rewarded.add(reward);
            my.rewardDebt = my.amount.sub(my.rewarded);
            my.getTime = block.timestamp;

            rewardToken.safeTransfer(msg.sender, reward);

            address parents =  get_parents(msg.sender);
            if (parents != address(0) && lpToken.balanceOf(parents) >= lpMin) {
                rewardToken.safeTransfer(parents, reward);
            }

            emit RewardPaid("ido", msg.sender, reward);
        }
    }
    function getWhiteReward() public nonReentrant{
        UserInfo storage my = userWhite[msg.sender];

        require(lpToken.balanceOf(msg.sender) >= lpMin, 'LP is insufficient');

        uint256 reward = earned_white(msg.sender);
        if(my.rewarded.add(reward) > my.amount){
            reward = my.amount.sub(my.rewarded);
        }
        if (reward > 0) {
            my.rewarded = my.rewarded.add(reward);
            my.rewardDebt = my.amount.sub(my.rewarded);
            my.getTime = block.timestamp;
            
            rewardToken.safeTransfer(msg.sender, reward);
            emit RewardPaid("white", msg.sender, reward);
        }
    }

    function getMyInfo() external view returns (Info memory){
        
        address account = address(msg.sender);
        UserInfo memory myIdo = userIdo[account];
        UserInfo memory myWhite = userWhite[account];

        return  Info({
            earned_ido: earned_ido(account),
            rewarded_ido: myIdo.rewarded,
            rewardDebt_ido: myIdo.rewardDebt,
            earned_white: earned_white(account),
            rewarded_white: myWhite.rewarded,
            rewardDebt_white: myWhite.rewardDebt,
            isActive : lpToken.balanceOf(account) >= lpMin,
            bcc_token: rewardToken.balanceOf(account),
            lp_token: lpToken.balanceOf(account),
            lpMin : lpMin
        });

    }

    function getPoolInfo(string memory name) external view returns (PoolInfo memory) {
        PoolInfo memory pool = poolInfo[name];
        return pool;
    }

}