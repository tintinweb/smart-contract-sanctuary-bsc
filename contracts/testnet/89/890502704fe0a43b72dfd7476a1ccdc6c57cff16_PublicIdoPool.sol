/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: MIT AND MIT
// File: @openzeppelin\contracts\math\Math.sol


pragma solidity ^0.6.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
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

// File: node_modules\@openzeppelin\contracts\token\ERC20\IERC20.sol


pragma solidity ^0.6.0;

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

// File: node_modules\@openzeppelin\contracts\math\SafeMath.sol


pragma solidity ^0.6.0;

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

// File: node_modules\@openzeppelin\contracts\utils\Address.sol


pragma solidity ^0.6.2;

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
        // This method relies in extcodesize, which returns 0 for contracts in
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

// File: @openzeppelin\contracts\token\ERC20\SafeERC20.sol


pragma solidity ^0.6.0;




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

// File: node_modules\@openzeppelin\contracts\GSN\Context.sol


pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol


pragma solidity ^0.6.0;

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
}

// File: contracts\owner\Auth.sol

pragma solidity >=0.6.0 <0.9.0;


contract Auth is Context, Ownable {

    mapping(address => bool) public authMap;
    event AddAuth(address addr);
    event RemoveAuth(address addr);

    constructor() internal {
        authMap[_msgSender()] = true;
    }

    modifier onlyOperator() {
        require(
            authMap[_msgSender()],
            'Auth: caller is not the operator'
        );
        _;
    }

    function isOperator(address addr) public view returns (bool) {
        return authMap[addr];
    }

    function addAuth(address addr) public onlyOwner {
        require(addr != address(0), "Auth: addr can not be 0x0");
        authMap[addr] = true;
        emit AddAuth(addr);
    }

    function removeAuth(address addr) public onlyOwner {
        require(addr != address(0), "Auth: addr can not be 0x0");
        authMap[addr] = false;
        emit RemoveAuth(addr);
    }

}

// File: contracts\interface\IMiningLpPool.sol

pragma solidity >=0.6.0 <0.9.0;

interface IMiningLpPool {

    function getMortgageNum(address _account) view external returns (uint256);

}

// File: contracts\fundraising\PublicIdoPool.sol

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;





contract PublicIdoPool is Auth {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private _adminAddress;

    address public lpAddress;

    uint256 public lpQuantitySold;

    uint256 public totalIssuance;

    uint256 public startTime;

    uint256 public endTime;

    uint256 public claimTime;

    address public fundRaisingAddress;

    uint256 public precision;

    uint256 public totalFundRaising;

    uint256 public claimPercentage;

    uint256 public totalAmountInvested;

    uint256 public availableLimit;

    uint256 public refundAmount;

    uint256 public refundPeriod;

    bool public isOverRaising;

    bool public isOpenClaim;

    bool public claimLock;

    bool public ownerClaimLock;

    bool public isPublic;

    uint256 public quotaTop;

    uint256 public quotaBottom;

    mapping(uint8 => uint256) public exchangeRate;

    mapping(address => uint256) public superWhiteListQuota;

    mapping(address => uint8) public whiteList;

    mapping(uint8 => address[]) public whiteListArr;

    mapping(address => uint256) public whiteListIndex;

    mapping(address => bool) public userIsClaim;

    address[] public poolAddressArray;

    mapping(address => uint256) public poolIndex;

    address[] public numberParticipants;

    struct IdoInfo {
        uint256 index;
        uint256 investment;
        uint256 received;
    }
    mapping(address => IdoInfo) public userIdoInfo;

    struct QuotaInfo {
        uint256 threshold;
        uint256 whiteListQuota;
    }
    mapping(address => mapping(uint8 => QuotaInfo)) public QuotaInfoList;


    event SetWhiteList(address indexed user, uint8 rank);

    event ParticipateExchange(address indexed user, uint256 amount);

    event Claim(address indexed user, uint256 obtain, uint256 investment, uint256 exchange, uint256 retrievable, bool isRefund);

    event OwnerClaim(address indexed user, uint256 amount, uint256 lpBalance);


    constructor(
        address _admin,
        address _lpAddress,
        uint256 _totalIssuance,
        uint256 _price,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _claimTime,
        address _fundRaisingAddress,
        uint256 _precision,
        uint256 _totalFundRaising,
        uint256 _claimPercentage,
        bool _isPublic
    ) public {
        require(_admin != address(0), "Admin address cannot be 0!");
        _adminAddress = _admin;
        require(_lpAddress != address(0), "LP address cannot be 0!");
        lpAddress = _lpAddress;
        totalIssuance = _totalIssuance;
        lpQuantitySold = _price.mul(_totalFundRaising);
        startTime = _startTime;
        endTime = _endTime;
        claimTime = _claimTime;
        refundPeriod = _claimTime + 1 days;
        require(_fundRaisingAddress != address(0), "Fund raising address cannot be 0!");
        fundRaisingAddress = _fundRaisingAddress;
        precision = _precision;
        totalFundRaising = _totalFundRaising.mul(10 ** _precision);
        quotaTop = totalFundRaising;
        exchangeRate[1] = uint256(1).mul(10 ** _precision);
        exchangeRate[2] = _price;
        claimPercentage = _claimPercentage.mul(1e18);
        isPublic = _isPublic;
    }


    modifier addressCheck(address _account, bool _isContract) {
        require(_account != address(0), "Address can not be 0x0!");
        if (_isContract) {
            require(Address.isContract(_account), "Must be a contract address!");
        } else {
            require(!Address.isContract(_account), "Cannot be a contract address!");
        }
        _;
    }

    modifier inspectLock() {
        require(!claimLock, "Lock occupied!");
        claimLock = true;
        _;
        claimLock = false;
    }

    modifier inspectOwnerLock() {
        require(!ownerClaimLock, "Lock occupied!");
        ownerClaimLock = true;
        _;
        ownerClaimLock = false;
    }

    function addPoolAddress(address _addPool) public onlyOperator addressCheck(_addPool, true) {
        uint256 index = poolAddressArray.length;
        poolIndex[_addPool] = index;
        poolAddressArray.push(_addPool);

        addAuth(_addPool);
    }

    function deletePoolAddress(address _delPool) public onlyOperator addressCheck(_delPool, true) {
        uint256 length = poolAddressArray.length;
        uint256 index = poolIndex[_delPool];

        require(poolAddressArray[index] == _delPool, "Address does not exist!");

        if (index != length.sub(1)) {
            poolAddressArray[index] = poolAddressArray[length.sub(1)];
            poolIndex[poolAddressArray[index]] = index;
        }
        poolAddressArray.pop();
        poolIndex[_delPool] = 0;

        removeAuth(_delPool);
    }

    function setAdminAddress(address _admin) public onlyOperator addressCheck(_admin, false) {
        removeAuth(_adminAddress);
        _adminAddress = _admin;
        addAuth(_admin);
    }

    function setLpAddress(address _lpAddress) public onlyOperator {
        lpAddress = _lpAddress;
    }

    function setExchangeRate(uint256 _material, uint256 _exchange) public onlyOperator {
        exchangeRate[1] = _material;
        exchangeRate[2] = _exchange;
    }

    function setStartTime(uint256 _startTime) public onlyOperator {
        startTime = _startTime;
    }

    function setEndTime(uint256 _endTime) public onlyOperator {
        endTime = _endTime;
    }

    function setClaimTime(uint256 _claimTime) public onlyOperator {
        claimTime = _claimTime;
    }

    function setRefundPeriod(uint256 _refundPeriod) public onlyOperator {
        refundPeriod = _refundPeriod;
    }

    function setIsOverRaising(bool _isOverRaising) public onlyOperator {
        isOverRaising = _isOverRaising;
    }

    function setIsOpenClaim(bool _isOpenClaim) public onlyOperator {
        isOpenClaim = _isOpenClaim;
    }

    function setClaimPercentage(uint256 _claimPercentage) public onlyOperator {
        claimPercentage = _claimPercentage.mul(1e18);
    }

    function setTotalFundRaising(uint256 _num) public onlyOperator {
        totalFundRaising = _num.mul(10 ** precision);
    }

    function setUserQuota(uint256 _top, uint256 _bottom) public onlyOperator {
        quotaTop = _top;
        quotaBottom = _bottom;
    }

    function setThresholdQuota(address _pool, uint8 _index, uint256 _threshold, uint256 _quota) public onlyOperator addressCheck(_pool, true) {
        require(_index > 0, "Index must be greater than zero!");
        bool isPool;
        for (uint256 i = 0; i < poolAddressArray.length; i++) {
            if (_pool == poolAddressArray[i]) {
                isPool = true;
                break;
            }
        }
        require(isPool, "This ore pool is not associated!");

        QuotaInfoList[_pool][_index].threshold = _threshold.mul(10 ** precision);
        QuotaInfoList[_pool][_index].whiteListQuota = _quota.mul(10 ** precision);
    }

    function setSuperWhiteListQuota(address _account, uint256 _quota) public onlyOperator {
        superWhiteListQuota[_account] = _quota.mul(10 ** precision);
    }

    function addSuperWhiteList(address[] calldata _accounts, uint256[] calldata _quotas) external onlyOperator {
        require(_accounts.length > 0 && _quotas.length > 0, "The number of whitelists added cannot be 0!");
        require(_accounts.length == _quotas.length, "The number of white lists added and the number of quotas are not equal!");

        for(uint256 i = 0; i < _accounts.length; i++) {
            if (whiteList[_accounts[i]] != 2) {
                setWhiteList(_accounts[i], 2);
                superWhiteListQuota[_accounts[i]] = _quotas[i].mul(10 ** precision);
            }
        }
    }

    function adminSafeTransfer(address _token, address _to, uint256 _amount) public onlyOperator {
        _upgradeSafeTransfer(_token, _to, _amount);
    }

    function _upgradeSafeTransfer(address _token, address _to, uint256 _amount) internal {
        require(_token != address(0), "Token can not be 0x0!");
        require(_amount > 0, "Transfer limit cannot be 0!");

        uint256 balance = IERC20(_token).balanceOf(address(this));

        if (_amount > balance) {
            require(_amount.sub(balance) < uint256(1).mul(1e18), "Insufficient contract balance!");
            IERC20(_token).safeTransfer(_to, balance);
        } else {
            IERC20(_token).safeTransfer(_to, _amount);
        }
    }

    function _setWhiteList(address _account, uint8 _rank) internal addressCheck(_account, false) {
        require(_rank < 4, "Invalid whitelist rank setting!");

        uint8 rank = whiteList[_account];

        if (_rank == 3 && isThreshold(_account)) {
            _rank = rank;
        }

        if (rank != _rank) {

            if (rank != 0) {
                uint256 length = whiteListArr[rank].length;
                uint256 index = whiteListIndex[_account];

                if (index != length.sub(1)) {
                    whiteListArr[rank][index] = whiteListArr[rank][length.sub(1)];
                    whiteListIndex[whiteListArr[rank][index]] = index;
                }
                whiteListArr[rank].pop();
            }

            whiteList[_account] = _rank;

            if (_rank != 0) {
                whiteListIndex[_account] = whiteListArr[_rank].length;
                whiteListArr[_rank].push(_account);
            } else {
                whiteListIndex[_account] = 0;
            }
        }
    }

    function setWhiteList(address _account, uint8 _rank) public onlyOperator {
        _setWhiteList(_account, _rank);
        emit SetWhiteList(_account, _rank);
    }

    function participateExchange(uint256 _amount) public {
        require(msg.sender != _adminAddress, "Administrators cannot participate!");
        require(_amount > 0, "Exchange amount cannot be zero!");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Not in IDO time range at this time!");

        if (!isOverRaising) {
            require(totalAmountInvested.add(_amount) <= totalFundRaising, "It cannot exceed the set fund-raising limit!");
        }

        if (!isPublic) {
            uint8 rank = whiteList[msg.sender];

            if (rank == 0 && isThreshold(msg.sender)) {
                _setWhiteList(msg.sender, 1);
            } else {
                require(rank == 1 || rank == 2, "You don't have permission to participate!");
            }
        }

        uint256 quota = queryQuotaByUser(msg.sender);
        uint256 investment = userIdoInfo[msg.sender].investment;
        require(_amount <= quota && (investment.add(_amount) <= quota) && (investment.add(_amount) >= quotaBottom), "Input limit exceeded!");

        if (investment == 0) {
            userIdoInfo[msg.sender].index = numberParticipants.length;
            numberParticipants.push(msg.sender);
        }

        totalAmountInvested = totalAmountInvested.add(_amount);
        userIdoInfo[msg.sender].investment = userIdoInfo[msg.sender].investment.add(_amount);

        IERC20(fundRaisingAddress).safeTransferFrom(msg.sender, address(this), _amount);

        emit ParticipateExchange(msg.sender, _amount);
    }

    function claim(bool _isRefund) public inspectLock {
        require(block.timestamp >= claimTime, "Claim time not reached!");
        require(!userIsClaim[msg.sender], "You have received the reward!");

        uint256 proportion;
        uint256 obtain;
        uint256 exchange;
        uint256 retrievable;
        uint256 balance;
        uint256 quota;
        uint256 availableAuota;

        if (_isRefund) {
            require(!isRefundPeriod(), "The refund period has expired!");
            uint256 investment = userIdoInfo[msg.sender].investment;
            if (investment > 0) {
                _upgradeSafeTransfer(fundRaisingAddress, msg.sender, investment);

                uint256 length = numberParticipants.length;
                uint256 index = userIdoInfo[msg.sender].index;

                require(numberParticipants[index] == msg.sender, "User address does not exist!");

                if (index != length.sub(1)) {
                    numberParticipants[index] = numberParticipants[length.sub(1)];
                    userIdoInfo[numberParticipants[index]].index = index;
                }
                numberParticipants.pop();

                userIdoInfo[msg.sender].index = 0;
                userIdoInfo[msg.sender].investment = 0;

                refundAmount = refundAmount.add(investment);
            }
        } else {
            require(isOpenClaim, "Can't claim!");

            (proportion,
            obtain,
            exchange,
            retrievable,
            balance,
            quota,
            availableAuota
            ) = getExchangeInfo(msg.sender);

            if (obtain > 0) {
                obtain = obtain.mul(claimPercentage).div(uint256(100).mul(1e18));
                if (obtain > 0) {
                    _upgradeSafeTransfer(lpAddress, msg.sender, obtain);
                    userIdoInfo[msg.sender].received = obtain;
                }
            }
            if (retrievable > 0) {
                _upgradeSafeTransfer(fundRaisingAddress, msg.sender, retrievable);
            }
        }

        userIsClaim[msg.sender] = true;

        emit Claim(msg.sender, obtain, userIdoInfo[msg.sender].investment, exchange, retrievable, _isRefund);
    }

    function ownerClaim() public onlyOperator inspectOwnerLock {
        require(isRefundPeriod(), "Claim time not reached!");
        require(msg.sender == _adminAddress, "You do not have administrator privileges!");
        require(!userIsClaim[msg.sender], "You have received the reward!");

        uint256 lpBalance = 0;

        if (totalAmountInvested < totalFundRaising) {
            availableLimit = totalAmountInvested.sub(refundAmount);
        } else {
            if (totalAmountInvested.sub(refundAmount) < totalFundRaising) {
                availableLimit = totalAmountInvested.sub(refundAmount).mul(totalFundRaising).div(totalAmountInvested);
            } else {
                availableLimit = totalFundRaising;
            }
        }

        if (availableLimit > 0) {
            if (availableLimit < totalFundRaising) {
                lpBalance = lpQuantitySold.sub(availableLimit.mul(exchangeRate[2]).div(exchangeRate[1]));
                if (lpBalance > 0) {
                    _upgradeSafeTransfer(lpAddress, msg.sender, lpBalance);
                }
            }
            _upgradeSafeTransfer(fundRaisingAddress, msg.sender, availableLimit);
        }

        if (claimPercentage < uint256(100).mul(1e18)) {
            uint256 lockLpBalance = 0;
            if (lpBalance > 0) {
                lockLpBalance = lpQuantitySold.sub(lpBalance);
                lockLpBalance = lockLpBalance.sub(lockLpBalance.mul(claimPercentage).div(uint256(100).mul(1e18)));
            } else {
                lockLpBalance = lpQuantitySold.sub(lpQuantitySold.mul(claimPercentage).div(uint256(100).mul(1e18)));
            }

            if (lockLpBalance > 0) {
                _upgradeSafeTransfer(lpAddress, msg.sender, lockLpBalance);
            }
        }

        userIsClaim[msg.sender] = true;

        emit OwnerClaim(msg.sender, availableLimit, lpBalance);
    }

    function queryQuotaByUser(address _account) public view returns (uint256) {
        uint256 countQuota = 0;

        if (isPublic) {
            countQuota = quotaTop;
        } else {
            for (uint256 i = 0; i < poolAddressArray.length; i++) {
                uint256 mortgageNum = getPoolMortgage(poolAddressArray[i], _account);
                if (mortgageNum > 0) {
                    uint256 quota = 0;
                    for (uint8 x = 1; QuotaInfoList[poolAddressArray[i]][x].threshold > 0; x++) {
                        if (mortgageNum >= QuotaInfoList[poolAddressArray[i]][x].threshold) {
                            quota = QuotaInfoList[poolAddressArray[i]][x].whiteListQuota;
                        } else {
                            break;
                        }
                    }
                    countQuota += quota;
                }
            }
        }

        countQuota = countQuota.add(superWhiteListQuota[_account]);

        return countQuota;
    }

    function getPoolMortgage(address _pool, address _account) public view returns (uint256) {
        return IMiningLpPool(_pool).getMortgageNum(_account);
    }

    function getThreshold() public view returns (uint256) {
        return QuotaInfoList[msg.sender][1].threshold;
    }

    function getThresholdByIndex(address _pool, uint8 _index) public view returns (uint256) {
        return QuotaInfoList[_pool][_index].threshold;
    }

    function isThreshold(address _account) public view returns (bool) {
        bool identification;
        for (uint256 i = 0; i < poolAddressArray.length; i++) {
            uint256 mortgageNum = getPoolMortgage(poolAddressArray[i], _account);
            if (
                mortgageNum > 0
                &&
                QuotaInfoList[poolAddressArray[i]][1].threshold > 0
                &&
                mortgageNum >= QuotaInfoList[poolAddressArray[i]][1].threshold
            ) {
                identification = true;
                break;
            }
        }
        return identification;
    }

    function getPoolAddressArray() public view returns (address[] memory) {
        return poolAddressArray;
    }

    function isStart() public view returns (bool) {
        return block.timestamp >= startTime;
    }

    function isEnd() public view returns (bool) {
        return block.timestamp > endTime;
    }

    function isClaim() public view returns (bool) {
        return block.timestamp >= claimTime;
    }

    function isRefundPeriod() public view returns (bool) {
        return block.timestamp > refundPeriod;
    }

    function isClaimByUser(address _account) public view returns (bool) {
        return userIsClaim[_account];
    }

    function isMortgage(address _account) public view returns (bool) {
        return userIdoInfo[_account].investment > 0;
    }

    function isAdmin() public view returns (bool) {
        return msg.sender == _adminAddress;
    }

    function isWhiteList(address _account) public view returns (uint8) {
        return whiteList[_account];
    }

    function getWhiteList(uint8 _rank) public view returns (address[] memory) {
        return whiteListArr[_rank];
    }

    function getNumberParticipants() public view returns (uint256) {
        return numberParticipants.length;
    }

    function getNumberParticipantsAll() public view returns (address[] memory) {
        return numberParticipants;
    }

    function getExchangeInfo(address _account) public view returns (
        uint256 proportion,
        uint256 obtain,
        uint256 exchange,
        uint256 retrievable,
        uint256 balance,
        uint256 quota,
        uint256 availableAuota
    ) {
        if (totalAmountInvested < totalFundRaising) {
            proportion = userIdoInfo[_account].investment.mul(1e18).div(totalFundRaising);
            obtain = userIdoInfo[_account].investment.mul(exchangeRate[2]).div(exchangeRate[1]);
        } else {
            proportion = userIdoInfo[_account].investment.mul(1e18).div(totalAmountInvested);
            obtain = userIdoInfo[_account].investment.mul(totalFundRaising).mul(exchangeRate[2]);
            obtain = obtain.div(exchangeRate[1]).div(totalAmountInvested);
        }
        proportion = proportion.mul(100).div(1e18);
        exchange = obtain.mul(exchangeRate[1]).div(exchangeRate[2]);
        retrievable = userIdoInfo[_account].investment.sub(exchange);

        balance = IERC20(fundRaisingAddress).balanceOf(_account);

        quota = queryQuotaByUser(_account);
        if (quota <= userIdoInfo[_account].investment) {
            availableAuota = 0;
        } else {
            availableAuota = quota.sub(userIdoInfo[_account].investment);
        }

        return (proportion, obtain, exchange, retrievable, balance, quota, availableAuota);
    }

    function getExchangePoolDetails() public view returns (
        address,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return (
        lpAddress,
        lpQuantitySold,
        totalIssuance,
        startTime,
        endTime,
        claimTime,
        fundRaisingAddress,
        totalFundRaising,
        exchangeRate[1],
        exchangeRate[2],
        totalAmountInvested
        );
    }

    function remainingTime(uint8 _timeType) public view returns (uint256) {
        if (_timeType == 0) {
            if (startTime > 0 && block.timestamp <= startTime) {
                return startTime.sub(block.timestamp);
            } else {
                return 0;
            }
        } else {
            if (endTime > 0 && block.timestamp <= endTime) {
                return endTime.sub(block.timestamp);
            } else {
                return 0;
            }
        }
    }

    function getRemainingFundraising() public view returns (uint) {
        if (totalFundRaising >= totalAmountInvested) {
            return totalFundRaising.sub(totalAmountInvested);
        } else {
            return 0;
        }
    }

    function balanceOfByUser(address _account) public view returns (uint, uint) {
        return (IERC20(lpAddress).balanceOf(_account), IERC20(fundRaisingAddress).balanceOf(_account));
    }

}