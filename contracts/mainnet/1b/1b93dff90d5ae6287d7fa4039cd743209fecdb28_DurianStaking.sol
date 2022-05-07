/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

//SPDX-License-Identifier:MIT
// File: @openzeppelin/contracts/math/Math.sol

pragma solidity 0.8.13;

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

// File: @openzeppelin/contracts/math/SafeMath.sol


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
    constructor () { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol


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
    constructor () {
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

// File: @openzeppelin/contracts/utils/Address.sol


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
    function toPayable(address account) internal pure returns (address) {
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
        (bool success, ) = recipient.call{value:amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol





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

interface Uni {
    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external;
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

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

struct UserInfo {                                                                
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of CAKEs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accCakePerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accCakePerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
}

interface dRewards {
    function userInfo(uint256,address) external view returns(UserInfo calldata);
    // function stake(address _pair, uint256 _amount) external;
    // function unstake(address _pair, uint256 _amount) external;
    // function pendingToken(address _pair, address _user) external returns (uint256);
    
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function pendingCake(uint256 _pid, address _user) external view returns (uint256);
}


// File: contracts/CurveRewards.sol


contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public x = IERC20(0x0eD7e52944161450477ee417DE9Cd3a859b14fD0);
    address public AdminAccount = 0xBFE6f285F92D85268A3C6CbCf4A7e2c0702Ab31B;
    
    uint public lpdepositfee = 10;
    uint public lpwithdrawalfee = 5;
    uint public lpdenominator = 1000;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function GetStakeToken() public view returns(IERC20){
        return x;
    }   

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    

    function Deposit(uint256 amount) public virtual{
        uint taxamount = amount.mul(lpdepositfee).div(lpdenominator);
        uint stakeamount = amount.sub(taxamount);
        _totalSupply = _totalSupply.add(stakeamount);
        _balances[msg.sender] = _balances[msg.sender].add(stakeamount);
        x.safeTransferFrom(msg.sender, address(this), amount);
        x.safeTransfer(AdminAccount, taxamount);
    }

    function Withdraw(uint amount) public virtual{
        uint taxamount = amount.mul(lpwithdrawalfee).div(lpdenominator);
        uint withdrawamount = amount.sub(taxamount);
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = 0;
        x.safeTransfer(msg.sender, withdrawamount);
        x.safeTransfer(AdminAccount, taxamount);
    }

    function Exit() public virtual{
        uint amount = _balances[msg.sender];
        uint taxamount = amount.mul(lpwithdrawalfee).div(lpdenominator);
        uint withdrawamount = amount.sub(taxamount);
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = 0;
        x.safeTransfer(msg.sender, withdrawamount);
        x.safeTransfer(AdminAccount, taxamount);
    }
}

contract DurianStaking is LPTokenWrapper, Ownable{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 public StakeToken = IERC20(0x0eD7e52944161450477ee417DE9Cd3a859b14fD0);
    IERC20 public RewardToken = IERC20(0xA2894c83a7f5F3BD8811b1A44668fd42BCb71039);
    uint256 public constant DURATION = 1 seconds;
    address public PlatformAccount = 0xBFE6f285F92D85268A3C6CbCf4A7e2c0702Ab31B;
    address public constant pool = 0x8aB1121D31542d818e4FCdBF3037633a1F3FA7B1;//0x73feaa1eE314F8c655E354234017bE2193C9E24E;
    address public constant poolrewardtoken = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address public constant uniRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public initreward = 0;
    uint256 public starttime = block.timestamp; 
    uint256 public periodFinish = block.timestamp;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint public min = 10000;
    uint public constant max = 10000;
    uint public pid = 2;
    uint public strategistReward = 20;
    address public cakebnblp = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    uint public restake = 80;
    address public token0Address = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82; //cake
    address public token1Address = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //wbnb
    bool public started;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    uint public harvesttax = 30;
    uint public taxdenominator = 100;

    

    event RewardAdded(uint256 reward);
    event InsertUser(address indexed _address, uint indexed _poolid, uint indexed _amount);
    event WithdrawUser(address indexed _address, uint indexed _poolid, uint indexed _amount);
    event RewardPaid(address indexed _address, uint indexed _amount);
    event RewardPaidRestakeElronlp(address indexed _address, uint indexed _amount);
    event RewardPaidRestake(address indexed _address, uint indexed _amount);
    event RewardDistributed(uint indexed _poolid, address indexed _userAddress, uint indexed _reward);
    event StartPhase(uint indexed _phaseId, uint _poolEndTime);
    event PoolRewardDistributedEvent(uint indexed _poolId);
    
    constructor(){}

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e9)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e9)
                .add(rewards[account]);
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function Deposit(uint256 amount) public override updateReward(msg.sender) checkStart{ 
        require(amount > 0, "Cannot stake 0");
        super.Deposit(amount);

        _deposit();

        emit InsertUser(msg.sender, 0, amount);
    }

    function Withdraw(uint amount) public override{
        require(amount > 0, "Cannot withdraw 0");
        Claim();

        _withdrawSome(amount);

        super.Withdraw(amount);
    }

    function Exit() public override{
        uint amount = balanceOf(msg.sender);
        require(amount > 0, "Cannot withdraw 0");
        Claim();
        super.Exit();
    }

    function Claim() public updateReward(msg.sender) checkStart{
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            uint taxamount = reward.mul(harvesttax).div(taxdenominator);
            uint claimreward = reward.sub(taxamount);
            RewardToken.safeTransfer(msg.sender, claimreward);
            RewardToken.safeTransfer(PlatformAccount, taxamount);
            emit RewardPaid(msg.sender, claimreward);
        }
    }


    function convertPancake(uint _amount, address _tokenin, address _tokenout) internal {
            require(!Address.isContract(msg.sender),"!contract");
            IERC20(_tokenin).safeApprove(uniRouter, 0);
            IERC20(_tokenin).safeApprove(uniRouter, uint256(_amount));
            address[] memory path = new address[](2);
                path[0] = _tokenin;
                path[1] = _tokenout;
                Uni(uniRouter).swapExactTokensForTokens(
                        _amount,
                        uint256(0),
                        path,
                        address(this),
                        block.timestamp.add(1800)
                );
    }
    
    modifier checkStart(){
        require(block.timestamp > starttime,"not start");
        _;
    }

    function setReward(uint256 initamount) public updateReward(address(0)) onlyOwner returns (uint){
        if (block.timestamp >= periodFinish) {
            initreward = initamount;
            rewardRate = initamount.div(DURATION); 
            periodFinish = periodFinish + 1 seconds;  
            emit RewardAdded(initamount);
            return periodFinish;
        }
        return 0;
    }

    function notifyStartTime(uint256 StartTime)
        external
        onlyOwner
        updateReward(address(0))
    {
        //Start 
        require(!started, "Already Started");
        started = true;
        lastUpdateTime = StartTime;
        periodFinish = StartTime;
    }
    
    function set_admin_address(address admin)public onlyOwner{
        PlatformAccount = admin;
    }

    // Custom logic in here for how much the vault allows to be borrowed
    // Sets minimum required on-hand to keep small withdrawals cheap
    function available() public view returns (uint) {
        return StakeToken.balanceOf(address(this)).mul(min).div(max);
    }
    
    // function earn() public {
    //     uint _bal = available();
    //     token.safeTransfer(controller, _bal);
    //     Controller(controller).earn(address(token), _bal);
    // }

    function _deposit() internal returns (uint) {
        uint256 _want = IERC20(StakeToken).balanceOf(address(this));
        if (_want > 0) {

            IERC20(StakeToken).safeApprove(pool, 0);
            IERC20(StakeToken).safeApprove(pool, _want);
            dRewards(pool).deposit(pid,_want);
        }
        return _want;
    }

    function _withdrawSome(uint256 _amount) internal returns (uint256) {
        uint _before = IERC20(StakeToken).balanceOf(address(this));
        dRewards(pool).withdraw(pid,_amount);
        uint _after = IERC20(StakeToken).balanceOf(address(this));
        uint _withdrew = _after.sub(_before);
        return _withdrew;
    }

    function harvestNew() public{
        require(!Address.isContract(msg.sender),"!contract");
        dRewards(pool).withdraw(pid,0);

        uint256 _2reward = IERC20(poolrewardtoken).balanceOf(address(this)).mul(strategistReward).div(100);
        uint256 _2want = IERC20(poolrewardtoken).balanceOf(address(this)).mul(restake).div(100);

        IERC20(poolrewardtoken).safeTransfer(PlatformAccount, _2reward);

        uint half = _2want.div(2);
        convertPancake(half, address(poolrewardtoken), address(token1Address));
        uint256 token0Amt = IERC20(token0Address).balanceOf(address(this));
        uint256 token1Amt = IERC20(token1Address).balanceOf(address(this));
        if(token0Amt > 0 && token1Amt > 0) {
            IERC20(token0Address).safeApprove(uniRouter, 0);
            IERC20(token0Address).safeApprove(uniRouter, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
            IERC20(token1Address).safeApprove(uniRouter, 0);
            IERC20(token1Address).safeApprove(uniRouter, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
            Uni(uniRouter).addLiquidity(
                token0Address,
                token1Address,
                token0Amt,
                token1Amt,
                0,
                0,
                address(this),
                block.timestamp.add(1800)
            );
        }
        _deposit();
    }

    

    function balanceOfPool() public view returns (uint256) {
        UserInfo memory user = dRewards(pool).userInfo(pid,address(this));
        return user.amount;
    }

    function balanceOfWant() public view returns (uint256) {
        return IERC20(StakeToken).balanceOf(address(this));
    }

    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }
    
    function getNumOfRewards() public view returns (uint256 pending) {
        pending = dRewards(pool).pendingCake(pid,address(this));
    }

    function seize(IERC20 token, uint256 amount) external onlyOwner{
        token.safeTransfer(msg.sender, amount);
    }
}