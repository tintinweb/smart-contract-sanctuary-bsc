/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

pragma solidity 0.5.16;

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


pragma solidity ^0.5.0;

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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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

// File: contracts/interface/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
    function mint(address account, uint amount) external;
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

// File: contracts/interface/IPlayerBook.sol

pragma solidity ^0.5.0;


interface IPlayerBook {
    function settleReward( address from,uint256 amount ) external returns (uint256);
}


// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.5.5;

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
    function isContractt(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: contracts/library/SafeERC20.sol

pragma solidity ^0.5.0;





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SafeERC20: TRANSFER_FAILED');
    }
    // function safeTransfer(IERC20 token, address to, uint256 value) internal {
    //     callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    // }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContractt(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/library/Governance.sol

pragma solidity ^0.5.0;

contract Governance {

    address public _governance;
    address public _distribution;

    constructor() public {
        _governance = tx.origin;
        _distribution = msg.sender;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance || msg.sender == _distribution, "not governance");
        _;
    }

    function setGovernance(address governance)  public  onlyGovernance
    {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }
    
    function setDistribution(address distribution)  public  onlyGovernance
    {
        require(distribution != address(0), "new governance the zero address");
        _distribution = distribution;
    }

}


library EnumerableSet {
   
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

    
            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }


    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

   
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }

    
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }


    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

   
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

   
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external returns (uint[] memory amounts);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface NFTCon{
    function mainconSetting(uint num) external;
}


contract PlayerBook is Governance {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Player {
        address laff;
        uint256 rreward;

        uint _type;
    }

    // struct stakeInfo {
    //     address _addr;
    //     uint256 _count;
    // }

    //Record
    uint public inviteAccountsTotal = 0;
    address[] public inviteAccounts;

    address public _uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;

    address public rewardToken;
    mapping (address => bool) public _pools;
    mapping (address => Player) public _plyr;
    // uint256[] public _referRewardRate = [3000,500,500,500,500,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200];     //todo
    uint256 public _baseRate = 10000;
    mapping (address => uint) public _hasInvite;

    address payable public _teamWallet;
    mapping (address => bool) public addrExist;

    uint public stakeMaxCounts = 30;
    uint public uintAmount = 100*1e18;
    address[] public allStake;
    uint public curCount = 0;
    uint public stakeCounts = 0;
    address _uniswapV2Pair;
    uint public surNodeLP = 0;
    uint public lastLP = 0;
    uint public NFTLP = 0;
    mapping (address => uint) public norCount;
    mapping (address => uint) public surCount;
    mapping (address => uint) public creatorCount;
    mapping (address => bool) public _activeAddr;
    EnumerableSet.AddressSet surNodeAddr;
    EnumerableSet.AddressSet creatorNodeAddr;
    mapping (address => uint) public _addrLocked;
    address public _team;
    uint public lastUpdateTime = 0;
    address public _NFTCon;

    struct recordInfo {
        address _addr;
        uint256 _count;
        uint256 _type;
        uint256 _recordtime;
    }
    mapping (address => recordInfo[]) public _record;

    struct itemInfo {
        uint256 _recordtime;
        uint256 _type;
        uint256 _LPLocked;
    }
    itemInfo[] public _allItems;
    mapping (address => uint[]) public _addr2count;

    constructor(address _rewardToken,address new_Pair,address new_team) public {
        rewardToken = _rewardToken;
        _teamWallet = msg.sender;
        addrExist[_teamWallet] = true;

        _uniswapV2Pair = new_Pair;
        _team = new_team;
    }

    modifier onlyNFTCon(){
        require(_NFTCon == msg.sender,"invalid _NFTCon address!");
        _;
    }

    modifier isRegisteredPool(){
        require(_pools[msg.sender],"invalid pool address!");
        _;
    }

    modifier validAddress( address addr ) {
        require(addr != address(0x0));
        _;
    }

    function addPool(address poolAddr)
        onlyGovernance
        public
    {
        require( !_pools[poolAddr], "derp, that pool already been registered");

        _pools[poolAddr] = true;
    }

    function setRewardToken(address _rewardToken)
        onlyGovernance
        public
    {
        rewardToken = _rewardToken;
    }

    function removePool(address poolAddr)
        onlyGovernance
        public
    {
        require( _pools[poolAddr], "derp, that pool must be registered");

        _pools[poolAddr] = false;
    }

    function govReward() external onlyGovernance
    {
        uint stakeLength = allStake.length>=10?10:allStake.length;
        for(uint i=0;i<stakeLength;i++)
        {
            IUniswapV2Router02(_uniswapV2Router).removeLiquidity(
                usdt,
                rewardToken,
                lastLP.div(stakeLength),
                0,
                0,
                allStake[allStake.length.sub(stakeLength).add(i)],
                block.timestamp.add(1800)
            );

            recordInfo memory itemRecord;
            itemRecord._addr = _uniswapV2Pair;
            itemRecord._count = lastLP.div(stakeLength);
            itemRecord._type = 6;
            itemRecord._recordtime = block.timestamp;
            _record[allStake[allStake.length.sub(stakeLength).add(i)]].push(itemRecord);
        }

        if(stakeLength > 0)
        {
            lastLP = 0;
        }
    }

    function restake(uint count) public
    {
        require(_allItems[count]._type == 1 && allStake[count] == msg.sender,"restake err");
        _allItems[count]._type = 2;
        uint retLP = _allItems[count]._LPLocked;

        stake(1);

            recordInfo memory itemRecord;
            itemRecord._addr = _uniswapV2Pair;
            itemRecord._count = retLP;
            itemRecord._type = 2;
            itemRecord._recordtime = block.timestamp;
            _record[msg.sender].push(itemRecord);

        IUniswapV2Router02(_uniswapV2Router).removeLiquidity(
            usdt,
            rewardToken,
            retLP,
            0,
            0,
            msg.sender,
            block.timestamp.add(1800)
        );
    }

    
    function stake(uint amount) public returns(uint)
    {
        require(amount>= 1 && amount<= stakeMaxCounts,"stake err");
        lastUpdateTime = block.timestamp.add(24 hours);

        //node
        nodeinternal();

        //record
            itemInfo memory itemtemporary;
        for(uint i=0;i<amount;i++)
        {
            _addr2count[msg.sender].push(allStake.length);

            allStake.push(msg.sender);
            
            itemtemporary._recordtime = block.timestamp;
            itemtemporary._type = 0;
            _allItems.push(itemtemporary);
        }

        tokeninternal(amount.mul(uintAmount));

        IERC20(usdt).safeApprove(_uniswapV2Router, 0);
        IERC20(usdt).safeApprove(_uniswapV2Router, uint(-1));
        address[] memory path = new address[](2);
        path[0] = usdt;
        path[1] = rewardToken;
        uint[] memory ret = IUniswapV2Router02(_uniswapV2Router).swapExactTokensForTokens(
                amount.mul(uintAmount).div(2),
                uint256(0),
                path,
                address(this),
                block.timestamp.add(1800)
        );

        uint256 token0Amt = amount.mul(uintAmount).div(2);
        uint256 token1Amt = ret[ret.length - 1];
        uint lpAmount = 0;
        if (token0Amt > 0 && token1Amt > 0) {
                IERC20(usdt).safeApprove(_uniswapV2Router, 0);
                IERC20(usdt).safeApprove(_uniswapV2Router, uint256(-1));
                IERC20(rewardToken).safeApprove(_uniswapV2Router, 0);
                IERC20(rewardToken).safeApprove(_uniswapV2Router, uint256(-1));
                (,,lpAmount) = IUniswapV2Router02(_uniswapV2Router).addLiquidity(
                    usdt,
                    rewardToken,
                    token0Amt,
                    token1Amt,
                    0,
                    0,
                    address(this),
                    block.timestamp.add(1800)
                );
        }

        surNodeLP = surNodeLP.add(lpAmount.mul(5).div(100));
        lastLP = lastLP.add(lpAmount.mul(1).div(100));
        NFTLP = NFTLP.add(lpAmount.mul(24).div(100));

        IERC20(_uniswapV2Pair).safeApprove(_uniswapV2Router, 0);
        IERC20(_uniswapV2Pair).safeApprove(_uniswapV2Router, uint256(-1));
        address affCode = _plyr[msg.sender].laff == address(0)?_teamWallet:_plyr[msg.sender].laff;
        IUniswapV2Router02(_uniswapV2Router).removeLiquidity(
            usdt,
            rewardToken,
            lpAmount.mul(10).div(100),
            0,
            0,
            affCode,
            block.timestamp.add(1800)
        );

            recordInfo memory itemRecord;
            itemRecord._addr = _uniswapV2Pair;
            itemRecord._count = lpAmount.mul(10).div(100);
            itemRecord._type = 3;
            itemRecord._recordtime = block.timestamp;
            _record[affCode].push(itemRecord);

        nodeReward(msg.sender,lpAmount.mul(5).div(100));

        for(uint i=stakeCounts+1;i<=stakeCounts + amount;i++)
        {
            if(i.mod(1000) == 0)
            {
                surNodeReward();
            }

            _allItems[curCount]._LPLocked = _allItems[curCount]._LPLocked.add(lpAmount.div(amount).div(2));
                if(i > 1 && i.sub(1).mod(2) == 0)
                {
                    lockLP();
                }
        }
        stakeCounts = stakeCounts + amount;

        IUniswapV2Router02(_uniswapV2Router).removeLiquidity(
            usdt,
            rewardToken,
            lpAmount.mul(5).div(100),
            0,
            0,
            _team,
            block.timestamp.add(1800)
        );

        return lpAmount;

    }

    function nodeinternal()
        internal
    {
        address affCode = _plyr[msg.sender].laff;
        address affaff;
        if(!_activeAddr[msg.sender] && affCode != address(0))
        {
            _activeAddr[msg.sender] = true;
            if(_plyr[affCode]._type == 0)
            {
                norCount[affCode] = norCount[affCode].add(1);
                if(norCount[affCode] >= 2)
                {
                    _plyr[affCode]._type = 1;
                    if(surCount[affCode] >= 3)
                    {
                        _plyr[affCode]._type = 2;
                        surNodeAddr.add(affCode);

                        affaff = _plyr[affCode].laff;
                        if(affaff != address(0) && _plyr[affaff]._type < 3)
                        {
                            creatorCount[affaff] = creatorCount[affaff].add(1);
                            if(creatorCount[affaff] >= 3)
                            {
                                if(_plyr[affaff]._type == 2)
                                {
                                    surNodeAddr.remove(affaff);
                                }
                               _plyr[affaff]._type = 3;
                                creatorNodeAddr.add(affaff);
                            }
                        }
                    }

                    affCode = _plyr[affCode].laff;
                    if(affCode != address(0))
                    {
                        surCount[affCode] = surCount[affCode].add(1);
                        if(surCount[affCode] >= 3 &&  _plyr[affCode]._type == 1)
                        {
                            _plyr[affCode]._type = 2;
                            surNodeAddr.add(affCode);

                            affaff = _plyr[affCode].laff;
                            if(affaff != address(0) && _plyr[affaff]._type < 3)
                            {
                                creatorCount[affaff] = creatorCount[affaff].add(1);
                                if(creatorCount[affaff] >= 3)
                                {
                                    if(_plyr[affaff]._type == 2)
                                    {
                                        surNodeAddr.remove(affaff);
                                    }
                                    _plyr[affaff]._type = 3;
                                    creatorNodeAddr.add(affaff);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function tokeninternal(uint usdtAmounts)
        internal
    {
        IERC20(usdt).safeTransferFrom(msg.sender,address(this),usdtAmounts);
        address[] memory callbackpath = new address[](2);
            callbackpath[0] = usdt;
            callbackpath[1] = rewardToken;
        uint[] memory invpower = IUniswapV2Router02(_uniswapV2Router).getAmountsOut(usdtAmounts, callbackpath);
        IERC20(rewardToken).safeTransfer(msg.sender,invpower[invpower.length - 1].div(5));

            recordInfo memory itemRecord;
            itemRecord._addr = rewardToken;
            itemRecord._count = invpower[invpower.length - 1].div(5);
            itemRecord._type = 1;
            itemRecord._recordtime = block.timestamp;
            _record[msg.sender].push(itemRecord);

        NFTCon(_NFTCon).mainconSetting(invpower[invpower.length - 1].div(25));
    }

    function lockLP()
        internal
    {
        _allItems[curCount]._type = 1;
        _addrLocked[allStake[curCount]] = _addrLocked[allStake[curCount]].add(1);
        curCount = curCount.add(1);
    }

    function nodeReward(address affCode,uint _lpamount)
        internal
    {
        address curaddr = msg.sender;
        address affID = _plyr[msg.sender].laff;
        address noraddr = _teamWallet;

        if(_plyr[curaddr]._type == 1){
           return;
        }
        
        if(affID == address(0x0) ){
            affID = _teamWallet;
        }

        while(affID != _teamWallet)
        {
            affID = _plyr[curaddr].laff;
            curaddr = affID;
            if(affID == address(0x0) ){
                affID = _teamWallet;
            }

            if( _plyr[affCode]._type == 1)
            {
                noraddr = affCode;
                break;
            }
        }

            recordInfo memory itemRecord;
            itemRecord._addr = _uniswapV2Pair;
            itemRecord._count = _lpamount;
            itemRecord._type = 4;
            itemRecord._recordtime = block.timestamp;
            _record[noraddr].push(itemRecord);

        IUniswapV2Router02(_uniswapV2Router).removeLiquidity(
            usdt,
            rewardToken,
            _lpamount,
            0,
            0,
            noraddr,
            block.timestamp.add(1800)
        );
    }

    function surNodeReward()
        internal
    {
        uint surLength = surNodeAddr.length();
        if(surLength == 0)
        {
            IUniswapV2Router02(_uniswapV2Router).removeLiquidity(
                usdt,
                rewardToken,
                surNodeLP,
                0,
                0,
                _team,
                block.timestamp.add(1800)
            );
        }

        for(uint i=0;i<surLength;i++)
        {
            recordInfo memory itemRecord;
            itemRecord._addr = rewardToken;
            itemRecord._count = surNodeLP.div(surLength);
            itemRecord._type = 5;
            itemRecord._recordtime = block.timestamp;
            _record[surNodeAddr.at(i)].push(itemRecord);

            IUniswapV2Router02(_uniswapV2Router).removeLiquidity(
                usdt,
                rewardToken,
                surNodeLP.div(surLength),
                0,
                0,
                surNodeAddr.at(i),
                block.timestamp.add(1800)
            );
        }

        surNodeLP = 0;

        
    }

    function creatorNode(uint256 amounts)
        external
    {
        require(msg.sender == rewardToken,"Token err");

        uint creatorLength = creatorNodeAddr.length();
        if(creatorLength == 0)
        {
            IERC20(rewardToken).safeTransfer(_team,amounts);
        }

        for(uint i=0;i<creatorLength;i++)
        {
            recordInfo memory itemRecord;
            itemRecord._addr = rewardToken;
            itemRecord._count = amounts.div(creatorLength);
            itemRecord._type = 0;
            itemRecord._recordtime = block.timestamp;
            _record[creatorNodeAddr.at(i)].push(itemRecord);

            IERC20(rewardToken).safeTransfer(creatorNodeAddr.at(i),amounts.div(creatorLength));
        }
    }


    function register(address affCode)
        public
    {
        require(addrExist[affCode],"not exist");
        address addr = msg.sender;
        require(_plyr[addr].laff == address(0), "sorry already register");

        _plyr[addr].laff = affCode;
        _plyr[addr]._type = 0;
        addrExist[addr] = true;
        
        inviteAccountsTotal = inviteAccountsTotal.add(1);
        inviteAccounts.push(msg.sender);
    }

    function getRecordLength(address from)
        external
        view
        returns (uint256)
    {
        return _record[from].length;
    }

    function getItemLength(address from)
        external
        view
        returns (uint256)
    {
        return _addr2count[from].length;
    }

    function getPlayerInfo(address from)
        external
        view
        returns (address,uint256)
    {
        return (_plyr[from].laff,_plyr[from]._type);
    }


    function govwithdraw(address ercaddr, uint amount) external onlyGovernance {
        IERC20(ercaddr).safeTransfer(msg.sender,amount);
    }

    
    function setStakeMaxCounts(uint new_stakeMaxCounts) external onlyGovernance {
        stakeMaxCounts = new_stakeMaxCounts;
    }

    function setTeam(address new_team) external onlyGovernance {
        _team = new_team;
    }

    function setNFTCon(address new_NFTCon) external onlyGovernance {
        _NFTCon = new_NFTCon;
    }

    function govWithdrawLP(uint num) external onlyNFTCon {
        IERC20(_uniswapV2Pair).safeTransfer(msg.sender,num);
        NFTLP = NFTLP.sub(num);
    }

}