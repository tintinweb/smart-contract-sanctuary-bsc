/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

pragma solidity ^0.5.0;

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

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol

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
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

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
    function burn(address account, uint amount) external;

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

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.5.4;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
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

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

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
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
     function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}


interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}


// File: contracts/CurveRewards.sol

pragma solidity ^0.5.0;


contract LPTokenWrapper is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public lpToken; // Stake Token address

    address public projectAddress;

    function setProjectAddress(address _projectAddress) public onlyOwner{
        
        projectAddress = _projectAddress;
    }

    uint256 private _totalSupply;
    
    mapping(address => uint256) private _balances;
    

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function deposit(uint256 amount) public {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        lpToken.safeTransferFrom(msg.sender, projectAddress, amount.div(100).mul(1));
        lpToken.safeTransferFrom(msg.sender, address(this), amount.sub(amount.div(100).mul(1)));
    }

    function withdraw(uint256 amount) public {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        
        lpToken.safeTransfer(projectAddress, amount.div(100).mul(2));

        lpToken.safeTransfer(msg.sender, amount.div(100).mul(97));
    }
    
}

interface INFTPublish {
    function publishNFT(uint256 triggerAmount) external;
    event PublishNFT(uint256 triggerAmount);
}

contract ANCHStakePool is LPTokenWrapper{

    IERC20 public token;

    IERC20 public usdtToken;
    
    uint256 public lastRebaseTime;

    uint256 public starttime;
     
    mapping(address => UserInfo) public userInfo;
    
    // stake pool total lp
    uint256 public totalStakeLPAmount;

    // stake pool total usdt
    uint256 public totalUSDTAmount;
    // stake pool total anch
    uint256 public totalANCHAmount;

    //  new stake usdt amount
    uint256 public newMillionUSDTAmount;

    uint256 public MILLION = 1000000 * 1e18;

    // stake pool total invite stake lp amount
    uint256 public totalInviteLPAmount;

    uint256 public MAX_REWARD_AMOUNT = 4000000 * 1e18;
    uint256 public totalRewarded;

    uint256 public MAX_RELEASE_AMOUNT = 200000 * 1e18;
    uint256 public newMillionTotalReleased;

    uint256 public MIN_USDT_AMOUNT = 100 * 1e18;


    NewMillionReward[] public newMillionRewardList;

    uint256 public newMillionTotalReleasedAmount;

    mapping(address => address[]) public team;

    uint256 public dayPeriod = 1 days;

    uint256 public releasePercent = 5;

    uint256 newMillionReleaseAmount = 20000 * 1e18;

    bool public isOpenBind = false;

    bool public isAutoRelease = true;

    INFTPublish public nftPublisher;

    //  trigger NFT Publish usdt amount
    uint256 public triggerNFTPublishUSDTAmount;

    uint256 public increaseUSDTAmount = 500000 * 1e18;

    uint256 public initialUSDTAmount = 1000000 * 1e18;

    // Accumulated Stake Reward per share, times 1e12. 
    uint256 public accStakeRewardPerShare; 

    // Accumulated Invite Reward per share, times 1e12. 
    uint256 public accInviteRewardPerShare; 

    uint256 public lastTrxReward;

    struct UserInfo {
        
        uint256 amount;
        uint256 inviteLPAmount;
        uint256 inviteUSDTAmount;
        uint256 inviteANCHAmount;

        // Reward debt. See explanation below.
        uint256 stakeRewardDebt; 
        uint256 inviteRewardDebt;
        //   pending stakeReward = (user.amount * accStakeRewardPerShare) - user.stakeRewardDebt
        //   Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. User receives the pending reward sent to his/her address.
        //   2. User's `amount` gets updated.
        //   3. User's `stakeRewardDebt` gets updated.

        uint256 stakeRewardWithdrawedAmount;
        uint256 inviteRewardWithdrawedAmount;

        uint256 usdtAmount;
        uint256 anchAmount;

        address referrer;
        uint256 directNums;
        bool isStake;
        
    }

    struct NewMillionReward {

        uint256 releaseTime;

        uint256 releaseTotalAmount;
    }
    
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event Earn(address indexed user, uint256 reward);
    event Earn(address indexed user, uint256 reward, uint256 rewardType);
    event BindReferrer(address indexed user, address indexed referrer);
    event DailyReleaseReward(uint256 indexed rewardTokenAmount);
    event NewMillionReleaseReward(uint256 indexed newMillionUSDTAmount);
    event TriggerNFTPublish(uint256 indexed triggerNFTPublishUSDTAmount);


    constructor (IERC20 _token, IERC20 _lpToken, IERC20 _usdtToken, address payable _projectAddress, uint256 _starttime) public{

      token = _token;
      lpToken = _lpToken;
      usdtToken = _usdtToken;
      
      starttime = _starttime;
      lastRebaseTime = _starttime;

      projectAddress = _projectAddress;

      userInfo[projectAddress].isStake = true;
      userInfo[projectAddress].referrer = address(this);

      newMillionUSDTAmount = MILLION;

      triggerNFTPublishUSDTAmount = initialUSDTAmount;
      
    }

    function bindReferrer(address _address) public {
        require(_address != msg.sender, 'must not yourself');
        require(userInfo[msg.sender].referrer == address(0), 'already set Referrer');
        require(userInfo[_address].referrer != address(0), 'Referrer not bind');

        if (isOpenBind == false) {
            require(userInfo[_address].isStake == true, 'Referrer not stake');
        }

        userInfo[msg.sender].referrer = _address;
        userInfo[_address].directNums = userInfo[_address].directNums.add(1);
        team[_address].push(msg.sender);

        emit BindReferrer(msg.sender, _address);
    }



    function getReferrer(address account) public view returns (address) {
        return userInfo[account].referrer;
    }


    function deposit(uint256 amount) public  checkStart{ 
        
        require(amount > 0, "Cannot stake 0");

        require(getUSDTAmount(amount) >= MIN_USDT_AMOUNT, "LP usdt must >= 100");

        UserInfo storage user = userInfo[msg.sender];

        if (user.amount > 0) {
            earnStakeReward();
        }

        if(isAutoRelease) {
            dailyReleaseReward();
            newMillionReleaseReward();
            triggerNFTPublish();
        }
            
        
        super.deposit(amount);
        totalStakeLPAmount = totalStakeLPAmount.add(amount);

        
        user.amount = user.amount.add(amount);
        user.isStake = true;

        uint256 usdtAmount = getUSDTAmount(amount);
        uint256 anchAmount = getTokenAmount(amount);

        totalUSDTAmount = totalUSDTAmount.add(usdtAmount);
        totalANCHAmount = totalANCHAmount.add(anchAmount);

        user.usdtAmount = user.usdtAmount.add(usdtAmount);
        user.anchAmount = user.anchAmount.add(anchAmount);

        user.stakeRewardDebt = user.amount.mul(accStakeRewardPerShare).div(1e12);

        address myRef = userInfo[msg.sender].referrer;
        for(uint8 i=0; i<5; i++) {
            if(myRef != address(0) && myRef != address(this)) {

                if(userInfo[myRef].inviteLPAmount > 0) 
                    earnInviteReward(myRef);

                userInfo[myRef].inviteLPAmount = userInfo[myRef].inviteLPAmount.add(amount);
                userInfo[myRef].inviteUSDTAmount = userInfo[myRef].inviteUSDTAmount.add(usdtAmount);
                userInfo[myRef].inviteANCHAmount = userInfo[myRef].inviteANCHAmount.add(anchAmount);

                userInfo[myRef].inviteRewardDebt = userInfo[myRef].inviteLPAmount.mul(accInviteRewardPerShare).div(1e12);


                totalInviteLPAmount = totalInviteLPAmount.add(amount);
                myRef = userInfo[myRef].referrer;
            }
        }

        emit Staked(msg.sender, amount);

    }


    function newMillionReleaseReward() private {

        if(totalUSDTAmount >= newMillionUSDTAmount) {

            if(newMillionTotalReleased.add(newMillionReleaseAmount) <= MAX_RELEASE_AMOUNT) {

                NewMillionReward memory newMillionReward = NewMillionReward(
                                                                block.timestamp,
                                                                newMillionReleaseAmount
                                                                );

                newMillionRewardList.push(newMillionReward);

            }
            
            emit NewMillionReleaseReward(newMillionUSDTAmount);

            newMillionUSDTAmount = newMillionUSDTAmount.add(MILLION);
        }

        uint256 len = newMillionRewardList.length;
        
        if(len > 0) {

            uint256 newMillionReward;
            for(uint256 i=0; i<len; i++) {

                newMillionReward = newMillionReward.add(newMillionRewardList[i].releaseTotalAmount.mul(10).div(100));

                if(block.timestamp.sub(newMillionRewardList[i].releaseTime) >= dayPeriod.mul(30)) {
                    newMillionReward = newMillionReward.add(newMillionRewardList[i].releaseTotalAmount.mul(90).div(100));
                } else {
                    uint256 time = (block.timestamp.sub(newMillionRewardList[i].releaseTime)).div(dayPeriod);
                    newMillionReward = newMillionReward.add(newMillionRewardList[i].releaseTotalAmount.mul(time.mul(3)).div(100));
                }
            }

            if(newMillionTotalReleasedAmount > 0) {
                newMillionReward = newMillionReward.sub(newMillionTotalReleasedAmount);
            }

            if(totalStakeLPAmount > 0) {
                accStakeRewardPerShare = accStakeRewardPerShare.add(newMillionReward.mul(1e12).div(totalStakeLPAmount));

                newMillionTotalReleasedAmount = newMillionTotalReleasedAmount.add(newMillionReward);
            }
            
        }


    }

    function triggerNFTPublish() private {

        if(totalUSDTAmount >= triggerNFTPublishUSDTAmount) {

            nftPublisher.publishNFT(triggerNFTPublishUSDTAmount);

             emit TriggerNFTPublish(triggerNFTPublishUSDTAmount);

            triggerNFTPublishUSDTAmount = triggerNFTPublishUSDTAmount.add(increaseUSDTAmount);
        }

    }


    function dailyReleaseReward() private {

        if(block.timestamp.sub(lastRebaseTime) >= dayPeriod) {

            uint256 rewardTokenAmount = swapTokenAmount(totalUSDTAmount).mul(releasePercent).div(1000);

            if(rewardTokenAmount > 0 && totalRewarded.add(rewardTokenAmount) <= MAX_REWARD_AMOUNT) {
            
                uint256 stakeReward = rewardTokenAmount.mul(50).div(100);
                uint256 inviteReward = rewardTokenAmount.mul(30).div(100);
                lastTrxReward = rewardTokenAmount.mul(20).div(100);
                safeTransfer(address(token), lastTrxReward);

                if(totalStakeLPAmount > 0)
                    accStakeRewardPerShare = accStakeRewardPerShare.add(stakeReward.mul(1e12).div(totalStakeLPAmount));

                if(totalInviteLPAmount > 0)
                    accInviteRewardPerShare = accInviteRewardPerShare.add(inviteReward.mul(1e12).div(totalInviteLPAmount));

                lastRebaseTime = block.timestamp;

                totalRewarded = totalRewarded.add(rewardTokenAmount);

                emit DailyReleaseReward(rewardTokenAmount);
            }

            
        }
    }



    // lp amount--> usdt amount
    function getUSDTAmount(uint256 lpAmount) view public returns(uint256){

        uint256 usdtTotal = IERC20(usdtToken).balanceOf(address(lpToken));
        uint256 tokenTotal = IERC20(token).balanceOf(address(lpToken));

        if(tokenTotal > 0) {
            return Math.sqrt(lpAmount.mul(lpAmount).mul(usdtTotal).div(tokenTotal));
        } else {
            return 0;
        }
        
    }

    // lp amount--> token amount
    function getTokenAmount(uint256 lpAmount) view public returns(uint256){

        uint256 usdtTotal = IERC20(usdtToken).balanceOf(address(lpToken));
        uint256 tokenTotal = IERC20(token).balanceOf(address(lpToken));

        if(usdtTotal > 0) {
            return Math.sqrt(lpAmount.mul(lpAmount).mul(tokenTotal).div(usdtTotal));
        } else {
            return 0;
        }
        
    }

    // usdt amount--> anch amount
    function swapTokenAmount(uint256 usdtAmount) view public returns(uint256){

        uint256 usdtTotal = IERC20(usdtToken).balanceOf(address(lpToken));
        uint256 tokenTotal = IERC20(token).balanceOf(address(lpToken));

        if(usdtTotal > 0) {
            return usdtAmount.mul(tokenTotal).div(usdtTotal);
        } else {
            return 0;
        }
        
    }

    // usdt amount--> lp amount
    function swapLPTokenAmount(uint256 usdtAmount) view public returns(uint256){

        uint256 usdtTotal = IERC20(usdtToken).balanceOf(address(lpToken));
        uint256 tokenTotal = IERC20(token).balanceOf(address(lpToken));


        if(usdtTotal > 0) {
            return Math.sqrt(usdtAmount.mul(usdtAmount).mul(tokenTotal).div(usdtTotal));
        } else {
            return 0;
        }
        
    }

    function withdraw() public  checkStart{

        UserInfo storage user = userInfo[msg.sender];
        uint256 amount = user.amount;

        require(amount > 0, "Cannot withdraw 0");

        earnStakeReward();

        address myRef = user.referrer;
        for(uint8 i=0; i<5; i++) {
            if(myRef != address(0) && myRef != address(this)) {

                if(userInfo[myRef].inviteLPAmount > 0) 
                    earnInviteReward(myRef);

                userInfo[myRef].inviteLPAmount = userInfo[myRef].inviteLPAmount.sub(amount);
                userInfo[myRef].inviteUSDTAmount = userInfo[myRef].inviteUSDTAmount.sub(user.usdtAmount);
                userInfo[myRef].inviteANCHAmount = userInfo[myRef].inviteANCHAmount.sub(user.anchAmount);

                userInfo[myRef].inviteRewardDebt = userInfo[myRef].inviteLPAmount.mul(accInviteRewardPerShare).div(1e12);


                totalInviteLPAmount = totalInviteLPAmount.sub(amount);
                myRef = userInfo[myRef].referrer;
            }
        }


        super.withdraw(amount);
        totalStakeLPAmount = totalStakeLPAmount.sub(amount);
        
        user.amount = 0;
        user.isStake = false;

        user.stakeRewardDebt = 0;

        totalUSDTAmount = totalUSDTAmount.sub(user.usdtAmount);
        totalANCHAmount = totalANCHAmount.sub(user.anchAmount);

        user.usdtAmount = 0;
        user.anchAmount = 0;

        if(isAutoRelease) {
            dailyReleaseReward();
            newMillionReleaseReward();
            triggerNFTPublish();
        }

        emit Withdrawn(msg.sender, amount);
    }
    

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() public {
        UserInfo storage user = userInfo[msg.sender];
       
        uint256 amount = user.amount;
        require(amount > 0, "Cannot withdraw 0");

        super.withdraw(amount);
        totalStakeLPAmount = totalStakeLPAmount.sub(amount);
        
        user.amount = 0;
        user.isStake = false;

        user.stakeRewardDebt = 0;

        totalUSDTAmount = totalUSDTAmount.sub(user.usdtAmount);
        totalANCHAmount = totalANCHAmount.sub(user.anchAmount);

        user.usdtAmount = 0;
        user.anchAmount = 0;

        emit EmergencyWithdraw(msg.sender, user.amount);

    }


    function earnStakeReward() private{

        (,uint256 stakeLPReward,) = getReward(msg.sender);

        if(stakeLPReward > 0) {
            safeTransfer(msg.sender, stakeLPReward);

            UserInfo storage user = userInfo[msg.sender];

            user.stakeRewardWithdrawedAmount = user.stakeRewardWithdrawedAmount.add(stakeLPReward);

            emit Earn(msg.sender, stakeLPReward);
        }
        
    }

    function earnInviteReward(address account) private{

        (,, uint256 inviteReward) = getReward(account);

        if(inviteReward > 0) {
            safeTransfer(account, inviteReward);

            UserInfo storage user = userInfo[account];

            user.inviteRewardWithdrawedAmount = user.inviteRewardWithdrawedAmount.add(inviteReward);

            emit Earn(account, inviteReward);
        }
        
    }


    function earn() public checkStart {

        (uint256 totalReward,uint256 stakeLPReward , uint256 inviteReward) = getReward(msg.sender);

        require(totalReward > 0, "Cannot earn 0");

        safeTransfer(msg.sender, totalReward);

        UserInfo storage user = userInfo[msg.sender];

        if(stakeLPReward > 0) {
            user.stakeRewardWithdrawedAmount = user.stakeRewardWithdrawedAmount.add(stakeLPReward);
            user.stakeRewardDebt = user.amount.mul(accStakeRewardPerShare).div(1e12);
        }
            

        if(inviteReward > 0) {

            user.inviteRewardWithdrawedAmount = user.inviteRewardWithdrawedAmount.add(inviteReward);
            user.inviteRewardDebt = user.inviteLPAmount.mul(accInviteRewardPerShare).div(1e12);
        }
            

        if(isAutoRelease) {
            dailyReleaseReward();
            newMillionReleaseReward();
            triggerNFTPublish();
        }

        emit Earn(msg.sender, totalReward);
    }


    // rewardType 0: stakeLPReward, 1: inviteReward
    function earn(uint256 rewardType) public checkStart {

        (,uint256 stakeLPReward , uint256 inviteReward) = getReward(msg.sender);
        UserInfo storage user = userInfo[msg.sender];

        if(rewardType == 0) {

            require(stakeLPReward > 0, "Cannot earn 0");

            safeTransfer(msg.sender, stakeLPReward);

            user.stakeRewardWithdrawedAmount = user.stakeRewardWithdrawedAmount.add(stakeLPReward);
            user.stakeRewardDebt = user.amount.mul(accStakeRewardPerShare).div(1e12);

            emit Earn(msg.sender, stakeLPReward, rewardType);

            
            
        } else if(rewardType == 1) {
            
            require(inviteReward > 0, "Cannot earn 0");

            safeTransfer(msg.sender, inviteReward);

            user.inviteRewardWithdrawedAmount = user.inviteRewardWithdrawedAmount.add(inviteReward);
            user.inviteRewardDebt = user.inviteLPAmount.mul(accInviteRewardPerShare).div(1e12);

            emit Earn(msg.sender, inviteReward, rewardType);
        } 
        
        if(isAutoRelease) {
            dailyReleaseReward();
            newMillionReleaseReward();
            triggerNFTPublish();
        }
        
    }

    

    function getReward(address account) public view returns (uint256, uint256, uint256){

        UserInfo storage user = userInfo[account];

        uint256 stakeLPReward = user.amount.mul(accStakeRewardPerShare).div(1e12).sub(user.stakeRewardDebt);
        uint256 inviteReward = user.inviteLPAmount.mul(accInviteRewardPerShare).div(1e12).sub(user.inviteRewardDebt);

        return (stakeLPReward.add(inviteReward), stakeLPReward, inviteReward);
    }
    


    function getRewardWithdrawed(address account) public view returns (uint256, uint256, uint256){

        UserInfo storage user = userInfo[account];

        uint256 stakeLPReward = user.stakeRewardWithdrawedAmount;
        uint256 inviteReward = user.inviteRewardWithdrawedAmount;

        return (stakeLPReward.add(inviteReward), stakeLPReward, inviteReward);
    }

    function getTotalReward(address account) public view returns (uint256, uint256, uint256){

        UserInfo storage user = userInfo[account];
        (,uint256 stakeLPReward , uint256 inviteReward) = getReward(account);

        uint256 totalStakeLPReward = stakeLPReward.add(user.stakeRewardWithdrawedAmount);
        uint256 totalInviteReward = inviteReward.add(user.inviteRewardWithdrawedAmount);

        return (totalStakeLPReward.add(totalInviteReward), totalStakeLPReward, totalInviteReward);
    }


    function getTeamInfo(address account) view external returns(
        address[] memory userAddress, 
        uint256[] memory usdtAmount, 
        uint256[] memory anchAmount) {

        uint256 len = team[account].length;
        userAddress = team[account];
        usdtAmount = new uint256[](len);
        anchAmount = new uint256[](len);

        for(uint256 i=0; i<len; i++) {
            usdtAmount[i] = userInfo[userAddress[i]].usdtAmount;
            anchAmount[i] = userInfo[userAddress[i]].anchAmount;
        }
    }


    function safeTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBalance = token.balanceOf(address(this));
        if(_amount > 0 && tokenBalance > 0) {
            if(_amount > tokenBalance) {
                token.safeTransfer(_to, tokenBalance);
            } else {
                token.safeTransfer(_to, _amount);
            }
        }
        
        
    }
    
    function withdrawAll(IERC20 _token) public onlyOwner{
        
        uint256 balance = _token.balanceOf(address(this)) ;
        if(balance > 0 ){
            _token.safeTransfer(msg.sender, balance) ;
        }
    }

    function rebaseDailyReleaseReward() public onlyOwner{
        
       dailyReleaseReward();
    }

    function rebaseNewMillionReleaseReward() public onlyOwner{
        
       newMillionReleaseReward();
    }

    function rebaseTriggerNFTPublish() public onlyOwner{
        
       triggerNFTPublish();
    }


    function setToken(IERC20 _token) public onlyOwner{
        token = _token;
    }

    function setLPToken(IERC20 _lpToken) public onlyOwner{
        lpToken = _lpToken;
    }

    function setNFTPublisher(address _nftPublisher) public onlyOwner{
        nftPublisher = INFTPublish(_nftPublisher);
    }

    function setNewMillionReleaseAmount(uint256 _newMillionReleaseAmount) public onlyOwner {
        newMillionReleaseAmount = _newMillionReleaseAmount;
    }

    function setMinUsdtAmount(uint256 _MIN_USDT_AMOUNT) public onlyOwner{
        
       MIN_USDT_AMOUNT = _MIN_USDT_AMOUNT;
    }

    function setReleasePercent(uint256 _releasePercent) public onlyOwner{
        
       releasePercent = _releasePercent;
    }

    function setMillion(uint256 _MILLION) public onlyOwner{
        
       MILLION = _MILLION;
       newMillionUSDTAmount = MILLION;
    }


    function setAutoRelease(bool _isAutoRelease) public onlyOwner{
        
       isAutoRelease = _isAutoRelease;
    }

    function setOpenBind(bool _isOpenBind) public onlyOwner{
        
       isOpenBind = _isOpenBind;
    }

    function setTriggerNFTPublishUSDTAmount(uint256 _triggerNFTPublishUSDTAmount) public onlyOwner {
        triggerNFTPublishUSDTAmount = _triggerNFTPublishUSDTAmount;
    }


    modifier checkStart(){
        require(block.timestamp > starttime,"not start");
        _;
    }
    

}