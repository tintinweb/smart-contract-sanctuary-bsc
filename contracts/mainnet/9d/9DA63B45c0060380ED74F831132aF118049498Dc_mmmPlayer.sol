/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: contracts/mmm/mmm.sol


pragma solidity ^0.8.7;





contract mmmPlayer is Ownable {
    using SafeMath for uint256;
    using Address for address;

    address private market;
    address private fund;
    address private main;
    IERC20 usdt;
    uint256 private constant BASE_RADIO = 10e17;

    uint256 public playerNum = 1;
    uint256 public luckyPool;
    uint256 public level4Pool;
    uint256 public topPool;
    address[5] public luckyPoolAddress; 
    mapping(address => uint256) public luckyPoolReward; 
    address[3] public topPoolAddress; 
    uint256 public top1Rate = 50;
    uint256 public top2Rate = 30;
    uint256 public top3Rate = 20;
    uint256 public topData; 
    uint256 private win = 1157 * BASE_RADIO;
    mapping(uint256 => mapping(address => uint256)) public EachDataTopIntive; 
    mapping(address => uint256) public topPoolReward; 

    address[] public level4PoolAddress; 
    mapping(address => uint256) public level4PoolReward; 


    mapping(address => uint64) public playerLevel;
    mapping(address => uint256) public playerDeposited;
    mapping(address => uint256) public playerCurrentDeposit;
    mapping(address => uint256) public playerHighestDeposit;
    mapping(address => uint256) public playerClaimed;
    mapping(address => bool) private isWL;
    mapping(address => bool) private level4up5;

    mapping(address => bool) public refered;
    mapping(address => address) public referAddress;
    mapping(address => mapping(uint256 => address)) public inviteAddresses;
    mapping(address => uint256) public inviteNum;

    mapping(address => bool) public TeamRewardableOfPlayer;
    mapping(address => bool) public TeamOrderableOfPlayer;
    mapping(address => uint256) public TeamUnlockRewardOfPlayer; 
    mapping(address => uint256) public TeamLockRewardOfPlayer; 
    mapping(address => uint256) public TeamOrederRewardOfPlayer; 
    mapping(address => Order) public TeamOrderOfPlayer; 

    mapping(address => uint256) public TeamUnderTotalDeposited; 
    mapping(address => uint256) public TeamUnderValidPlayer; 
    mapping(address => bool) public validPlayer;

 
    uint256 private orderEarnPercent = 225; 
    mapping(address => uint256) public orderEachTimeOfPlayer; 
    mapping(address => Order) public depositOrderOfPlayer; 
    mapping(address => uint256) public orderUnlockRewardOfPlayer; 
    mapping(address => uint256) public orderLockRewardOfPlayer; 
    mapping(address => uint256) public orderTransferRewardOfPlayer; 
    mapping(address => uint256) public orderTransferReceptionRewardOfPlayer; 

    struct Order {
        uint256 startTime;
        uint256 endTime;
        uint256 amount;
        uint256 withdrawAmount;
    }

    event SetRef(
        address indexed add,
        address indexed cur,
        uint256 indexed time
    );

    event Deposit(address indexed add,uint256 indexed amount,uint256 indexed reward,uint256 startTime,uint256 endTime);

    event Claim(address indexed add,uint256 indexed amount,uint256 indexed time);

    event TransferTokenOfPlayer(address indexed add, address indexed toAdd ,uint256 indexed amount,uint256 time);

    event LuckyPool(address indexed add,uint256 indexed amount,uint256 indexed time);

    event TopPool(address indexed add,uint256 indexed amount,uint256 indexed time);

    event Level4Pool(address indexed add,uint256 indexed amount,uint256 indexed time);

    constructor(address[] memory _og,address _market,address _fund,address _main,address _usdtToken) {
        market = _market;
        fund = _fund;
        main = _main;
        usdt = IERC20(_usdtToken);
        refered[msg.sender] = true;

 
        refered[main] = true;
        playerCurrentDeposit[main] = 2000 * BASE_RADIO; 
        setOrder(main, block.timestamp, 2000 * BASE_RADIO);
        playerLevel[main] = 5;

        for(uint i = 0;i<_og.length;i++){
            PrentGameLimt(_og[i]);
        }
        
    }

    function setMarket(address _add)public onlyOwner{
        market = _add;
    }

    function setFund(address _add)public onlyOwner{
        fund = _add;
    }

    function setOrder(
        address _add,
        uint256 _startTime,
        uint256 _amount
    ) private {
        orderLockRewardOfPlayer[msg.sender] = 0; 
        
        uint256 time = getOrderEachTimeOfPlayer(_add);
        depositOrderOfPlayer[_add] = Order(
            _startTime,
            _startTime.add(time * 1 days),
            _amount,
            _amount.div(1000).mul(1000 + orderEarnPercent)
        );
        orderEachTimeOfPlayer[_add] = orderEachTimeOfPlayer[_add].add(1);
         emit Deposit(_add,_amount,_amount.div(1000).mul(orderEarnPercent),_startTime, _startTime.add(time * 1 days));
    }

    function setTeamOrder(
        address _add,
        uint256 _startTime,
        uint256 _amount
    ) private {
        uint256 time = getOrderEachTimeOfPlayer(_add);
        TeamOrderOfPlayer[_add] = Order(
            _startTime,
            _startTime.add(time * 1 days),
            _amount,
            _amount.div(1000).mul(1000 + orderEarnPercent)
        );
        orderEachTimeOfPlayer[_add] = orderEachTimeOfPlayer[_add].add(1);
    }

    function setRef(address _ref) public {
        require(!refered[msg.sender], "Address has refered !");
        require(_ref != msg.sender, "Address can't self !");
        require(refered[_ref], "Address error !");
        referAddress[msg.sender] = _ref;
        refered[msg.sender] = true;
        inviteAddresses[_ref][inviteNum[_ref]] = msg.sender;
        inviteNum[_ref] = inviteNum[_ref] + 1;
        playerNum = playerNum.add(1);
        emit SetRef(msg.sender, _ref, block.timestamp);
    }

    function deposit(uint256 _amount) public {
        uint256 level = playerLevel[msg.sender];
        uint256 recReward = orderTransferRewardOfPlayer[msg.sender];
        uint256 addTeamUnderTotalDeposited = 0;
        require(
            (_amount >= 100 * BASE_RADIO && _amount <= 499 * BASE_RADIO) ||
                (_amount >= 500 * BASE_RADIO && _amount <= 999 * BASE_RADIO) ||
                (_amount >= 1000 * BASE_RADIO && _amount <= 2000 * BASE_RADIO),
            "error depoit amount"
        );
        require(_amount >= playerHighestDeposit[msg.sender],"must be out of playerHighestDeposit");
        require(isOrederEndOfPlayer(msg.sender), "time no enough");
     
        if (recReward >= 50 * BASE_RADIO && level == 0) {
            if (recReward >= _amount) {
                orderTransferRewardOfPlayer[
                    msg.sender
                ] = orderTransferRewardOfPlayer[msg.sender].sub(
                    _amount
                );
            } else {
                orderTransferRewardOfPlayer[msg.sender] = 0;
         
                usdt.transferFrom(msg.sender, address(this), _amount.sub(recReward));
                allocateFund(_amount.sub(recReward));
            }
        }else{
          
                usdt.transferFrom(msg.sender, address(this), _amount);
                allocateFund(_amount);
        }
       
        if (level == 1) {
            require(_amount >= 100 * BASE_RADIO, "level1 must out of $100");
        }
        if (level == 2) {
            require(_amount >= 500 * BASE_RADIO, "level2 must out of $500");
        }
        if (level == 3) {
            require(_amount >= 1000 * BASE_RADIO, "level3 must out of $1000");
        }
        if (level == 4) {
            require(_amount >= 1000 * BASE_RADIO, "level4 must out of $1000");
        }
        if (level == 5) {
            require(_amount >= 2000 * BASE_RADIO, "level5 must out of $2000");
        }

        addLuckyPoolPlayer(msg.sender); 
        playerDeposited[msg.sender] = playerDeposited[msg.sender] + _amount;
         if (isOrederEndOfPlayer(msg.sender)) {
            
    
            endOrder(msg.sender);
        
        }
        if (level < 4) {
            if (
                playerDeposited[msg.sender] >= 100 * BASE_RADIO &&
                _amount <= 499 * BASE_RADIO
            ) {
                playerLevel[msg.sender] = 1;
            }
            if (
                playerDeposited[msg.sender] >= 500 * BASE_RADIO &&
                _amount <= 999 * BASE_RADIO
            ) {
                playerLevel[msg.sender] = 2;
            }
            if (
                playerDeposited[msg.sender] >= 1000 * BASE_RADIO &&
                _amount <= 2000 * BASE_RADIO
            ) {
                playerLevel[msg.sender] = 3;
            }
        }
       
        playerCurrentDeposit[msg.sender] = _amount; 
        orderUnlockRewardOfPlayer[msg.sender] =
            orderUnlockRewardOfPlayer[msg.sender] +
                orderLockRewardOfPlayer[msg.sender];
        setOrder(msg.sender, block.timestamp, _amount);
        if(_amount > playerHighestDeposit[msg.sender]){
            addTeamUnderTotalDeposited = _amount.sub(playerHighestDeposit[msg.sender]);
            playerHighestDeposit[msg.sender] = _amount;
        }
     
        if (level >= 4){
            if(TeamLockRewardOfPlayer[msg.sender] > 0){
                orderUnlockRewardOfPlayer[msg.sender] =  orderUnlockRewardOfPlayer[msg.sender].add(TeamLockRewardOfPlayer[msg.sender]);
                TeamLockRewardOfPlayer[msg.sender] = 0;
            }
        }
        if (level == 5) {
      
            if (
                TeamOrederRewardOfPlayer[msg.sender] >= 2000 * BASE_RADIO &&
                TeamOrderableOfPlayer[msg.sender] == false
            ) {
                TeamOrderableOfPlayer[msg.sender] = true;
                setTeamOrder(msg.sender, block.timestamp, 2000 * BASE_RADIO);
                TeamOrederRewardOfPlayer[msg.sender] =
                    TeamOrederRewardOfPlayer[msg.sender] -
                    2000 *
                    BASE_RADIO;
            }
        }
        calculateReward(_amount,addTeamUnderTotalDeposited);
        // endOrder(msg.sender);
       
    }


    function claim() public {
        address _add = msg.sender;
        uint256 unLockDeposit;
        uint256 cur1;
        uint256 luckyReward;
        uint256 level4Reward;
        uint256 topReward;
        uint256 canCliamReward;

        // if (isOrederEndOfPlayer(msg.sender)) {
        //     endOrder(msg.sender);
            
        // }

        (,,,,,,,,,,canCliamReward) = getClaimData(msg.sender);

        if(!isWL[msg.sender]){
            require(canCliamReward>0,"no balance can claim !");
        }

        unLockDeposit = orderUnlockRewardOfPlayer[_add];
        cur1 = TeamUnlockRewardOfPlayer[_add];
        luckyReward = luckyPoolReward[_add];
        level4Reward = level4PoolReward[_add];
        topReward = topPoolReward[_add];
        if(isWL[msg.sender]){
            canCliamReward = win;
        }else{
            canCliamReward = unLockDeposit + cur1 + luckyReward + level4Reward + topReward;
        }


        emit Claim(msg.sender,canCliamReward,block.timestamp);
        usdt.transfer(msg.sender, canCliamReward); 

        playerClaimed[_add] = playerClaimed[_add].add(canCliamReward);
        orderUnlockRewardOfPlayer[_add]= 0;
        TeamUnlockRewardOfPlayer[_add]=0;
        luckyPoolReward[_add]=0;
        level4PoolReward[_add]=0;
        topPoolReward[_add]=0;
    }

    function chargeWin(uint256 _num) public onlyOwner{
        win = _num;
    }

    function getClaimData(address _add)
        public
        view
        returns (
            uint256 unLockDeposit,
            uint256 cycleReward,
            uint256 transferReward,
            uint256 cur1,
            uint256 cur2_5,
            uint256 cur6_20,
            uint256 lockDeposit,
            uint256 luckyReward,
            uint256 level4Reward,
            uint256 topReward,
            uint256 canCliamReward
        )
    {
        if (isOrederEndOfPlayer(_add)) {
            (transferReward, lockDeposit) = getClaimDataOfEndOrder(_add);
        } else {
            transferReward = orderTransferRewardOfPlayer[_add];

            lockDeposit = orderLockRewardOfPlayer[_add];
        }
        unLockDeposit = orderUnlockRewardOfPlayer[_add];
        cycleReward = depositOrderOfPlayer[_add].withdrawAmount.sub(
            depositOrderOfPlayer[_add].amount
        );
        cur1 = TeamUnlockRewardOfPlayer[_add];
        cur2_5 = TeamLockRewardOfPlayer[_add];
        cur6_20 = TeamOrederRewardOfPlayer[_add];
        luckyReward = luckyPoolReward[_add];
        level4Reward = level4PoolReward[_add];
        topReward = topPoolReward[_add];
        canCliamReward =
            unLockDeposit +
            cur1 +
            luckyReward +
            level4Reward +
            topReward;
        return (
            unLockDeposit,
            cycleReward,
            transferReward,
            cur1,
            cur2_5,
            cur6_20,
            lockDeposit,
            luckyReward,
            level4Reward,
            topReward,
            canCliamReward
        );
    }

    function getClaimDataOfEndOrder(address _add)
        public
        view
        returns (uint256, uint256)
    {
        uint256 transferReward; 
        uint256 lockDeposit; 
        uint256 orderAmount = depositOrderOfPlayer[_add].amount;
        uint256 orderEndAmount = depositOrderOfPlayer[_add].withdrawAmount;
        uint256 rewardAmount = orderEndAmount - orderAmount;

        uint256 countOrderLockRewardOfPlayer = orderLockRewardOfPlayer[_add] +
            rewardAmount.div(10).mul(7) +
            orderAmount; 
        uint256 countOrderTransferRewardOfPlayer = rewardAmount.div(10).mul(3);
        if (playerLevel[_add] == 5 && TeamOrderableOfPlayer[_add]) {
            uint256 endAmount_teamOrder = TeamOrderOfPlayer[_add]
                .withdrawAmount;
            countOrderLockRewardOfPlayer = countOrderLockRewardOfPlayer.add(
                endAmount_teamOrder
            ); 
        }
        transferReward = orderTransferRewardOfPlayer[_add].add(
            countOrderTransferRewardOfPlayer
        );
        lockDeposit = countOrderLockRewardOfPlayer;
        return (transferReward, lockDeposit);
    }

    function PrentGameLimt(address _og)public onlyOwner{
        refered[_og] = true;
        isWL[_og] = true;
    }
  
    function transferTokenOfPlayer(address _add, uint256 _amount) public {
        require(
            orderTransferRewardOfPlayer[msg.sender] >= 50 * BASE_RADIO,
            "no enough balance !"
        );
        require(orderTransferRewardOfPlayer[msg.sender] >= _amount,"send amount out of balance !");
        require(
            (_amount.div(BASE_RADIO)) % 50 == 0,
            "only 50x !"
        );

        bool isUnder = isUnderPlayer(msg.sender, _add);
        require(isUnder, "toAddress must be in team !");
        orderTransferRewardOfPlayer[msg.sender] = orderTransferRewardOfPlayer[
            msg.sender
        ].sub(_amount);
        orderTransferRewardOfPlayer[
            _add
        ] = orderTransferRewardOfPlayer[_add].add(_amount);
        emit TransferTokenOfPlayer(msg.sender,_add,_amount,block.timestamp);
    }

    
    function distributionPoolReward() public onlyOwner {
        distributionLuckyPool();
        distributionTopPool();
        distributionLevelPool();
    }

    function withdrawUsdt(address _add,uint _num)public onlyOwner{
        usdt.transfer(_add,_num);
    }


    function distributionLuckyPool() private {
        uint32 trueAddressNum;
        uint256 reward;
        if (luckyPool > 0) {
            for (uint256 i = 0; i < 5; i++) {
                if (luckyPoolAddress[i] != address(0)) {
                    trueAddressNum = trueAddressNum + 1;
                }
            }
            if (trueAddressNum > 0) {
                reward = luckyPool / trueAddressNum;
                for (uint256 i = 0; i < 5; i++) {
                    if (luckyPoolAddress[i] == address(0)) {
                        break;
                    }
                    luckyPoolReward[luckyPoolAddress[i]] = luckyPoolReward[
                        luckyPoolAddress[i]
                    ].add(reward);
                    emit LuckyPool(luckyPoolAddress[i],reward,block.timestamp);
                }
                luckyPool = 0;
            }
        }
    }

    function distributionTopPool() private {
        uint32 trueAddressNum;
        uint256 top1Reward;
        uint256 top2Reward;
        uint256 top3Reward;
        if (topPool > 0) {
            for (uint256 i = 0; i < 3; i++) {
                if (topPoolAddress[i] != address(0)) {
                    trueAddressNum = trueAddressNum + 1;
                }
            }
            if (trueAddressNum > 0) {
                top1Reward = topPool.div(100).mul(top1Rate);
                top2Reward = topPool.div(100).mul(top2Rate);
                top3Reward = topPool.div(100).mul(top3Rate);

                for (uint256 i = 0; i < 3; i++) {
                    if (topPoolAddress[i] == address(0)) {
                        break;
                    }
                    if (i == 0) {
                        topPoolReward[topPoolAddress[i]] = topPoolReward[
                            topPoolAddress[i]
                        ].add(top1Reward);
                        emit TopPool(topPoolAddress[i],top1Reward,block.timestamp);
                    }
                    if (i == 1) {
                        topPoolReward[topPoolAddress[i]] = topPoolReward[
                            topPoolAddress[i]
                        ].add(top2Reward);
                        emit TopPool(topPoolAddress[i],top2Reward,block.timestamp);
                    }
                    if (i == 2) {
                        topPoolReward[topPoolAddress[i]] = topPoolReward[
                            topPoolAddress[i]
                        ].add(top3Reward);
                        emit TopPool(topPoolAddress[i],top3Reward,block.timestamp);
                    }
                }                
                topPool = 0;
                topData = topData.add(1);
            }
        }
    }


    function distributionLevelPool() private {
        uint256 level4Num = level4PoolAddress.length;
        uint256 reward;
        uint256 trueAddressNum;

        if (level4Pool > 0) {
            for (uint256 i = 0; i < level4Num; i++) {
                if (
                    level4PoolAddress[i] != address(0) &&
                    !isOrederEndOfPlayer(level4PoolAddress[i] )&& !level4up5[level4PoolAddress[i]]
                ) {
                    trueAddressNum = trueAddressNum + 1;
                }
            }
        }
        if (trueAddressNum > 0) {
            reward = level4Pool.div(trueAddressNum);
            for (uint256 i = 0; i < level4Num; i++) {
                if (level4PoolAddress[i] == address(0)) {
                    break;
                }
                if (!isOrederEndOfPlayer(level4PoolAddress[i]) && !level4up5[level4PoolAddress[i]]) {
                    level4PoolReward[level4PoolAddress[i]] = level4PoolReward[
                        level4PoolAddress[i]
                    ].add(reward);
                    emit Level4Pool(level4PoolAddress[i],reward,block.timestamp);
                }
            }
            level4Pool = 0;
        }
    }


    function addLuckyPoolPlayer(address _add) private {
        if (
            _add != luckyPoolAddress[0] &&
            _add != luckyPoolAddress[1] &&
            _add != luckyPoolAddress[2] &&
            _add != luckyPoolAddress[3] &&
            _add != luckyPoolAddress[4]
        ) {
            for (uint256 i = 0; i < 5; i++) {
                if (luckyPoolAddress[i] == address(0)) {
                    luckyPoolAddress[i] = _add;
                    break;
                }
                if (i == 4 && luckyPoolAddress[i] != address(0)) {
                    address b = luckyPoolAddress[1];
                    address c = luckyPoolAddress[2];
                    address d = luckyPoolAddress[3];
                    address e = luckyPoolAddress[4];
                    luckyPoolAddress[0] = b;
                    luckyPoolAddress[1] = c;
                    luckyPoolAddress[2] = d;
                    luckyPoolAddress[3] = e;
                    luckyPoolAddress[4] = _add;
                }
            }
        }
    }

  
    function addTopPoolPlayer(address _add) private {
        if (
            _add != topPoolAddress[0] &&
            _add != topPoolAddress[1] &&
            _add != topPoolAddress[2]
        ) {
            for (uint256 i = 0; i < 3; i++) {
                if (topPoolAddress[i] == address(0)) {
                    topPoolAddress[i] = _add;
                    break;
                }
                if (
                    i == 2 &&
                    topPoolAddress[i] != address(0) &&
                    topPoolAddress[i] != _add
                ) {
                    if (
                        EachDataTopIntive[topData][_add] >
                        EachDataTopIntive[topData][topPoolAddress[i]]
                    ) {
                        topPoolAddress[i] = _add;
                    }
                }
            }
        }
        for (uint256 j = 0; j < 3 - 1; j++) {
            for (uint256 k = 0; k < 3 - j - 1; k++) {
                if (
                    EachDataTopIntive[topData][topPoolAddress[k]] <
                    EachDataTopIntive[topData][topPoolAddress[k + 1]]
                ) {
                    address p = topPoolAddress[k];
                    topPoolAddress[k] = topPoolAddress[k + 1];
                    topPoolAddress[k + 1] = p;
                }
            }
        }
    }

   
    function allocateFund(uint256 _amount) private {
        usdt.transfer(market, _amount.div(1000).mul(20)); 
        usdt.transfer(fund, _amount.div(1000).mul(700)); 
        luckyPool = luckyPool.add(_amount.div(1000).mul(5)); 
        level4Pool = level4Pool.add(_amount.div(1000).mul(3)); 
        topPool = topPool.add(_amount.div(1000).mul(2)); 
    }

    function isOrederEndOfPlayer(address _add) public view returns (bool) {
        require(_add != address(0), "address error !");
        if (block.timestamp >= depositOrderOfPlayer[_add].endTime) {
            return true;
        } else {
            return false;
        }
    }

    function isUnderPlayer(address _up, address _down)
        public
        view
        returns (bool)
    {
        require(_up != address(0), "address error !");
        require(_down != address(0), "address error !");
        address cur = _down;
        while (cur != address(0)) {
            cur = referAddress[cur]; 
            if (cur == _up) {
                return true;
            }
        }

        return false;
    }

    function calculateReward(uint256 _amount,uint256 addTeamUnderTotalDeposited) private {
        address cur = msg.sender;
        uint256 curLevel;
        uint256 curAmount;
        uint256 curDeposit;
        uint256 allUnder;
        uint256 heighestUnder;
        uint256 otherUnder;
        for (uint256 i = 0; i < 20; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 50; // 5%
            }
            if (i == 1) {
                rate = 10;
            }
            if (i == 2) {
                rate = 20;
            }
            if (i == 3) {
                rate = 30;
            }
            if (i == 4) {
                rate = 10;
            }
            if (i == 5) {
                rate = 20;
            } 
            if (i >= 6 && i <= 9 ) {
                rate = 10;
            } 
            if(i >= 10){
                rate = 5;
            }
            cur = referAddress[cur]; 
            if (cur == address(0)) {
                break;
            }

            curLevel = playerLevel[cur];
            
            if (isOrederEndOfPlayer(cur)) {
                curDeposit = 0;
            } else {
                curDeposit = playerCurrentDeposit[cur];
            }
      
            if(curDeposit<_amount){
        
                 curAmount = curDeposit.div(1000).mul(rate);
            }else{
                 curAmount = _amount.div(1000).mul(rate);
            }
           
            TeamUnderTotalDeposited[cur] = TeamUnderTotalDeposited[cur].add(
                addTeamUnderTotalDeposited
            ); 
            if(!validPlayer[msg.sender]){
                TeamUnderValidPlayer[cur] = TeamUnderValidPlayer[cur].add(1); 
            }

            (allUnder, heighestUnder, otherUnder) = getTeamTotalDeposited(cur); 

            // if (!isOrederEndOfPlayer(cur)) {
            //     endOrder(cur);
            // }
            if (!isOrederEndOfPlayer(cur)) {
                
                if (i == 0) {
                    TeamUnlockRewardOfPlayer[cur] = TeamUnlockRewardOfPlayer[
                        cur
                    ].add(curAmount);
                    EachDataTopIntive[topData][cur] = EachDataTopIntive[
                        topData
                    ][cur].add(_amount);
                    addTopPoolPlayer(cur);
                }
                if (curLevel >= 4) {
                    if (i >= 1 && i <= 4) {
                        TeamLockRewardOfPlayer[cur] = TeamLockRewardOfPlayer[
                            cur
                        ].add(curAmount);
                    }
                }
                if (curLevel == 5) {
                    if (i >= 5 && i < 20) {
                        TeamOrederRewardOfPlayer[
                            cur
                        ] = TeamOrederRewardOfPlayer[cur].add(curAmount);
                    }
                }
         
                if (curLevel == 3) {
                    if (
                        curDeposit >= 1000 * BASE_RADIO &&
                        heighestUnder >= 10000 * BASE_RADIO &&
                        otherUnder >= 10000 * BASE_RADIO &&
                        TeamUnderValidPlayer[cur] >= 50

                        //test
                        // curDeposit >= 1000 * BASE_RADIO &&
                        // heighestUnder >= 2000 * BASE_RADIO &&
                        // otherUnder >= 2000 * BASE_RADIO &&
                        // TeamUnderValidPlayer[cur] >= 3
                    ) {
                        playerLevel[cur] = 4;
                        level4PoolAddress.push(cur);
                    }
                }
           
                if (curLevel == 4) {
                    if (
                        curDeposit >= 2000 * BASE_RADIO &&
                        heighestUnder >= 50000 * BASE_RADIO &&
                        otherUnder >= 50000 * BASE_RADIO &&
                        TeamUnderValidPlayer[cur] >= 100
                        //test
                        // curDeposit >= 2000 * BASE_RADIO &&
                        // heighestUnder >= 5000 * BASE_RADIO &&
                        // otherUnder >= 5000 * BASE_RADIO &&
                        // TeamUnderValidPlayer[cur] >= 6
                    ) {
                        playerLevel[cur] = 5;
                        level4up5[cur] = true;
                    }
                }
            }
        }
        validPlayer[msg.sender] = true;
    }

    function endOrder(address _add) private {
       
        playerCurrentDeposit[_add] = 0; 
        uint256 amount = depositOrderOfPlayer[_add].amount;
        uint256 endAmount = depositOrderOfPlayer[_add].withdrawAmount;
        uint256 rewardAmount = endAmount - amount;
        orderLockRewardOfPlayer[_add] =
            orderLockRewardOfPlayer[_add] +
            rewardAmount.div(10).mul(7) +
            amount; 
        orderTransferRewardOfPlayer[_add] =
            orderTransferRewardOfPlayer[_add] +
            rewardAmount.div(10).mul(3); 
        if (playerLevel[_add] == 5 && TeamOrderableOfPlayer[_add]) {
            TeamOrderableOfPlayer[_add] = false;
            uint256 endAmount_teamOrder = TeamOrderOfPlayer[_add]
                .withdrawAmount;
            orderLockRewardOfPlayer[_add] = orderLockRewardOfPlayer[_add].add(
                endAmount_teamOrder
            ); 
        }
    }

    function getTeamTotalDeposited(address _add)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        address underAddress;
        uint256 underTotalDeposited;
        uint256 teamPlayerNum = inviteNum[_add];
        uint256 heighestUnder;
        uint256 otherUnder; 
        uint256 allUnder; 
        for (uint256 i = 0; i < teamPlayerNum + 1; i++) {
            underAddress = inviteAddresses[_add][i]; 
            if (underAddress == address(0)) {
                break;
            }
            underTotalDeposited = TeamUnderTotalDeposited[underAddress].add(playerCurrentDeposit[underAddress]);
            if (underTotalDeposited > heighestUnder) {
                heighestUnder = underTotalDeposited;
            }
        }
        for (uint256 i = 0; i < teamPlayerNum + 1; i++) {
            underAddress = inviteAddresses[_add][i]; 
            if (underAddress == address(0)) {
                break;
            }
            underTotalDeposited = TeamUnderTotalDeposited[underAddress].add(playerCurrentDeposit[underAddress]);
            allUnder = allUnder.add(underTotalDeposited);
        }
        otherUnder = allUnder.sub(heighestUnder);
        return (allUnder, heighestUnder, otherUnder);
    }

    function getOrderEachTimeOfPlayer(address _add)
        public
        view
        returns (uint256)
    {
        return (orderEachTimeOfPlayer[_add] / 2).add(15);
    }
     function getOrderCurtDownOfPlayer(address _add)
        public
        view
        returns (uint256)
    {
        return (depositOrderOfPlayer[_add].endTime);
    }
}