/**
 *Submitted for verification at BscScan.com on 2022-03-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

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
     *
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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

abstract contract Ownable is Context {
    address private _owner;
    address private _manager;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _manager = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function manager() internal view virtual returns (address) {
        return _manager;
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyManager() {
        require(manager() == _msgSender(), "Ownable: caller is not the owner");
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

interface IPancakeRouter {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IStaking {
    function stake(uint256 _amount, address _recipient) external returns (bool);

    function claim(address _recipient) external;
}

interface ITreasury {
    function mintFairLaunch(uint256 _amount) external;

    function deposit(
        uint256 _amount,
        address _token,
        uint256 _profit
    ) external returns (bool);

    function valueOf(address _token, uint256 _amount) external view returns (uint256 value_);
}

contract Airdrop is Ownable {
    using SafeMath for uint256;

    // ==== STRUCTS ====

    struct UserInfo {
        uint256 purchased; // SPOT
        uint256 vesting; // time left to be vested
        uint256 lastTime;
    }

    // ==== CONSTANTS ====

    uint256 private constant MAX_PER_ADDR = 1000e18; // max 1k

    uint256 private constant MAX_FOR_SALE = 50000e18; // 50k

    uint256 private constant VESTING_TERM = 2 days; //Original 14days

    uint256 private constant EXCHANGE_RATE = 5; // 10 asset -> 1 SPOT


    // ==== STORAGES ====

    uint256 public startVesting;

    IERC20 public SPOT;

    // staking contract
    address public staking;

    // treasury contract
    address public treasury;

    // router address
    address public router;

    // factory address
    address public factory;

    // development address
    address public development;

    // finalized status
    bool public finalized;

    // total asset purchased;
    uint256 public totalPurchased;

    // white list for private sale
    mapping(address => bool) public isWhitelist;
    mapping(address => uint) public userType; //1-Airdrop, 2-Developer, 3-Advisor, ...
    mapping(address => UserInfo) public userInfo;

    // ==== EVENTS ====

    event Deposited(address indexed depositor, uint256 indexed amount);
    event Redeemed(address indexed recipient, uint256 payout, uint256 remaining);
    event WhitelistUpdated(address indexed depositor, uint indexed userType);

    // ==== MODIFIERS ====

    modifier onlyWhitelisted(address _depositor) {
        require(isWhitelist[_depositor], "only whitelisted");
        _;
    }

    // ==== CONSTRUCTOR ====

    constructor(address _SPOT) {
        SPOT = IERC20(_SPOT);
        startVesting = 0;
    }

    // ==== VIEW FUNCTIONS ====

    function availableFor(address _depositor) public view returns (uint256 amount_) {
        amount_ = 0;

        if (isWhitelist[_depositor]) {
            UserInfo memory user = userInfo[_depositor];
            uint256 totalAvailable = MAX_FOR_SALE.sub(totalPurchased);
            uint256 assetPurchased = user.purchased.mul(EXCHANGE_RATE).mul(1e9);
            uint256 depositorAvailable = MAX_PER_ADDR.sub(assetPurchased);
            amount_ = totalAvailable > depositorAvailable ? depositorAvailable : totalAvailable;
        }
    }

    function percentVestedFor(address _depositor) public view returns (uint256 percentVested_) {
        UserInfo memory user = userInfo[_depositor];

        if (block.timestamp < user.lastTime) return 0;

        uint256 timeSinceLast = block.timestamp.sub(user.lastTime);
        uint256 vesting = user.vesting;

        if (vesting > 0) {
            percentVested_ = timeSinceLast.mul(10000).div(vesting);
        } else {
            percentVested_ = 0;
        }
    }

    function pendingPayoutFor(address _depositor) external view returns (uint256 pendingPayout_) {
        uint256 percentVested = percentVestedFor(_depositor);
        uint256 payout = userInfo[_depositor].purchased;

        if (percentVested >= 10000) {
            pendingPayout_ = payout;
        } else {
            pendingPayout_ = payout.mul(percentVested).div(10000);
        }
    }

    // ==== EXTERNAL FUNCTIONS ====

    function deposit(address _depositor) external onlyWhitelisted(_depositor) {
        require(!finalized, "already finalized");

        uint256 amount = 10000000000000;        

        totalPurchased = totalPurchased.add(amount);

        UserInfo storage user = userInfo[_depositor];
        user.purchased = amount;
        user.vesting = VESTING_TERM;
        user.lastTime = startVesting;

        emit Deposited(_depositor, amount);
    }

    function redeem(address _recipient, bool _stake) external {
        require(finalized, "not finalized yet");
        UserInfo memory user = userInfo[_recipient];
        emit Redeemed(_recipient, user.purchased, 0); // emit bond data
        _stakeOrSend(_recipient, _stake, user.purchased); // pay user everything due
    }
    
    function airdrop(uint256 _amount) external {
        // require(isWhitelist[msg.sender], "whitelist only can airdrop");
        require(address(SPOT) != address(0), "Not Set spot token address");
        SPOT.transfer(msg.sender, _amount); // send payout
    }

    function _stakeOrSend(
        address _recipient,
        bool _stake,
        uint256 _amount
    ) internal {
        SPOT.transfer(_recipient, _amount); // send payout
    }
    // ==== RESTRICT FUNCTIONS ====

    function addWhitelist(address _depositor, uint _type ) external onlyOwner {
        isWhitelist[_depositor] = true;
        userType[_depositor] = _type;
        emit WhitelistUpdated(_depositor, _type);
    }

    function setWhitelist(address[] memory _depositors, bool _value, uint _type) external onlyOwner {
        for (uint256 i = 0; i < _depositors.length; i++) {
            isWhitelist[_depositors[i]] = _value;
            userType[_depositors[i]] = _type;
            emit WhitelistUpdated(_depositors[i], _type);
        }
    }

    function finalize() external onlyOwner {
        finalized = true;
    }
}