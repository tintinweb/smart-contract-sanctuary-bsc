/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */
// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}


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
  constructor ()  { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
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
  constructor ()  {
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

contract States {
   bool public isStakeActive = true;
   bool public isUnStakeActive = true;


    bool public apyEnabled = true;
    bool public autoCompund = false;

    using TransferHelper for IERC20;
// pollygon testnet matic
    // IERC20 public stakingToken = IERC20(0xB81A2D0116d98D01C94f9BfEa9c4712A48517A5D);
    // IERC20 public rewardingToken = IERC20(0xfEe397938D58672da05fC6Eae0eC405Ab874E53B);

    // bsc testnet
    IERC20 public stakingToken = IERC20(0x8CF822E3b4c1838CE26F58f22da3AC011C425be0);
    IERC20 public rewardingToken = IERC20(0x759d9eEdA5C80041Cec086d6aAdE52970b3dB38f);

    // uint256 tiers;

    mapping(uint256=>uint256) public lockPeriod;
    // uint256 public lockPeriod1 = 2 days;
    // uint256 public lockPeriod2 = 3 days; 
    // uint256 public lockPeriod3 = 4 days;
    // uint256 public lockPeriod4 = 10 days;

    uint256 public apyTier1 = 20;
    uint256 public apyTier2 = 23; 
    uint256 public apyTier3 = 26;
    uint256 public apyTier4 = 30;

    uint256 public maxReward;

    struct User {
        uint256 lockPeriod;
        uint256 stakedAmount;
        uint256 totalAmount;
        uint256 depositTime;
        uint256 endTime;
        uint256 lastClaimTime;
        uint256 reward;
        uint256 tier;
    }

    mapping(address => mapping(uint256 => User)) public deposit;

    uint256 public totalStaked;
    address internal rewardingTokenWallet = address(0x16B1ce2e5642d4861D3208DD18E9302677c9546b);
    uint256 internal earlyUstakeFee;
    uint256 internal earlyRewardUstakeFee;
    uint256 internal timeUntilExpiry = block.timestamp + 3650 days; //ten years

    event Stake(address indexed staker, uint256 _amount, uint256 _lockPeriod);
    event Unstake(address indexed unstaker, uint256 unstakeTime);
    event Withdraw(address indexed withdrawer);
    event WithdrawToken(address indexed withdrawer, uint256 amount);
    event Claim(address staker, uint256 reward);
}

contract SeedxStaking is States, Ownable {

    using SafeMath for uint256;

    constructor(){
      lockPeriod[1] = 730 days;
      lockPeriod[2] = 1095 days;
      lockPeriod[3] = 1460 days;
      lockPeriod[4] = 3650 days;

      // lockPeriod[1] = 5 minutes;
      // lockPeriod[2] = 8 minutes;
      // lockPeriod[3] = 9 minutes;
      // lockPeriod[4] = 10 minutes;
    }

    function flipApyEnabled() public onlyOwner {
        apyEnabled = !apyEnabled;
    }


    function setStakingToken(IERC20 _stakingtoken) public onlyOwner {
        stakingToken = _stakingtoken;
    }

    function setRewardingTokens(IERC20 _rewardingtoken) public onlyOwner {
        rewardingToken = _rewardingtoken;
    }

    function setRewardingWallet(address _address) public onlyOwner {
        rewardingTokenWallet = _address;
    }

    receive() external payable{}

    function flipStakeState() public onlyOwner {
       isStakeActive = !isStakeActive;
    }

    function flipUnStakeState() public onlyOwner {
       isUnStakeActive = !isUnStakeActive;
    }

    function stake(uint256 _amount, uint256 _tier) public {
        require(isStakeActive, "staking is pause");
        _stakeTokens(_amount, _tier);
    }

    function _stakeTokens(uint256 _amount, uint256 _tier)  internal {
        require(stakingToken.balanceOf(_msgSender())>=_amount, "you do not have sufficient balance");
        require(stakingToken.allowance(_msgSender(), address(this))>=_amount, "tokens not approved");
        require(_tier<=4 && _tier >0, "select correct tier");

        User memory user = deposit[_msgSender()][_tier];
        require(user.stakedAmount == 0, "Already Staked");
        
        deposit[_msgSender()][_tier] = User(lockPeriod[_tier], _amount, _amount, block.timestamp,block.timestamp.add(lockPeriod[_tier]), block.timestamp, 0, _tier);

        TransferHelper.safeTransferFrom(address(stakingToken),msg.sender,address(this), _amount);

        totalStaked+=_amount;

        emit Stake(_msgSender(), _amount, lockPeriod[_tier]);
    }

    function UnstakeTokens(uint256 _tier) public {
      require(isUnStakeActive, "staking is pause");
          _unstakeTokens(_msgSender(), _tier);
    }

    function _unstakeTokens(address _address, uint256 _tier) internal {
        User memory user = deposit[_address][_tier];

        require(user.stakedAmount > 0, "deposit first");
        require(block.timestamp > user.lockPeriod, "Token locked");

        // transfer from contract
        stakingToken.transfer(_address,user.stakedAmount);

        if(apyEnabled){
                _claim(_address, _tier);
        }
        totalStaked-=user.stakedAmount;
        deposit[_address][_tier] = User(0 , 0, 0, 0, 0, 0, 0, 0);

        emit Unstake(_address, block.timestamp);
    }
    
    // uint256  public claimcurrentReward;

    function _claim(address _address, uint256 _tier) internal {
        User storage info = deposit[_address][_tier];
         uint256 claimcurrentReward = checkReward(_address, _tier);
  
        if(claimcurrentReward > 0 && claimcurrentReward <= pendingRewards()){
            TransferHelper.safeTransferFrom(address(rewardingToken),rewardingTokenWallet, _address, claimcurrentReward);
        } else{
            require(false, "Pending Rewards Not Allocated");
        }
        if(block.timestamp > info.lockPeriod){

        info.lastClaimTime = info.lockPeriod;

        }else{
          info.lastClaimTime = block.timestamp;
        }
        emit Claim(_address , claimcurrentReward);
    }


    function checkReward(address _address, uint256 _tier) public view returns(uint256) {
        User memory info = deposit[_address][_tier];
        uint256 reward = 0;

        if(block.timestamp + 1 seconds > info.lastClaimTime){
                uint256 timeStaked = (block.timestamp) - (info.lastClaimTime);
                timeStaked = timeStaked / 1 seconds;

                if(info.tier == 1){
                    reward = apyTier1 * timeStaked;
                } else if(info.tier == 2){
                    reward = apyTier2 * timeStaked;
                } else if(info.tier == 3){
                    reward = apyTier3 * timeStaked;
                } else if(info.tier == 4){
                    reward = apyTier4 * timeStaked;
                }
        }
        return reward;
    }


    function claim(uint256 _tier) public {
        User memory info = deposit[_msgSender()][_tier];
        require(info.stakedAmount > 0, "Not Staked");
        require(apyEnabled, "No reward");
          _claim(_msgSender(), _tier);
    }

    function pendingRewards() public view returns (uint256){
      return rewardingToken.allowance(rewardingTokenWallet , address(this));
    }

    function withdrawAnyTokens(address _token, address recipient, uint256 amount) public onlyOwner{
        IERC20 anyToken = IERC20(_token);
        anyToken.transfer(recipient, amount);
        emit WithdrawToken(recipient, amount);
    }

    function withdrawFunds() public onlyOwner{
       _msgSender().transfer(address(this).balance);
       emit Withdraw(_msgSender());
    }

    function contractbalance() public view returns (uint256) {
      return address(this).balance;
    }

    
    function setApyTier1(uint256 _apy) public onlyOwner {
        apyTier1 = _apy;
    }

    function setApyTier2(uint256 _apy) public onlyOwner {
        apyTier2 = _apy;
    }

    function setApyTier3(uint256 _apy) public onlyOwner {
        apyTier3 = _apy;
    }

    function setApyTier4(uint256 _apy) public onlyOwner {
        apyTier4 = _apy;
    }

    function setLLockPeriod1(uint256 _days, uint256 _tiers) public onlyOwner {
        lockPeriod[_tiers] = _days;
    }

    function changeAPYTiers(uint256 _apy1,uint256 _apy2,uint256 _apy3,uint256 _apy4) public onlyOwner {
      apyTier1 = _apy1;
      apyTier2 = _apy2;
      apyTier3 = _apy3;
      apyTier4 = _apy4;
    }

    function changeLockPeriods(uint256 _lockPeriod1,uint256 _lockPeriod2,uint256 _lockPeriod3,uint256 _lockPeriod4) public onlyOwner {
      lockPeriod[1] = _lockPeriod1;
      lockPeriod[2] = _lockPeriod2;
      lockPeriod[3] = _lockPeriod3;
      lockPeriod[4] = _lockPeriod4;
    }
}