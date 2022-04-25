/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

library SafeMath {

  /**
   * @dev Multiplies two unsigned integers, reverts on overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath#mul: OVERFLOW");

    return c;
  }

  /**
   * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath#sub: UNDERFLOW");
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Adds two unsigned integers, reverts on overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath#add: OVERFLOW");

    return c; 
  }

  /**
   * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
   * reverts when dividing by zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
    return a % b;
  }

}
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
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
contract WeedverseStaking is Ownable {
  using SafeMath for uint;

    /// @dev `Checkpoint` is the structure that attaches a block number to a
    ///  given value, the block number attached is the one that last changed the
    ///  value
    struct Checkpoint {

        // `fromBlock` is the block number that the value was generated from
        uint128 fromBlock;

        // `value` is the amount of tokens at a specific block number
        uint128 value;
    }
    mapping(address => Checkpoint[]) balances;

    function getCheckpoint(address _owner, uint _index)
    view
    external
    returns (
        uint128 fromBlock,
        uint128 value
    )
    {
        Checkpoint storage checkpoint_ = balances[_owner][_index];
        fromBlock = checkpoint_.fromBlock;
        value = checkpoint_.value;
    }
    // Tracks the history of the total delegations of the token
    Checkpoint[] totalSupplyHistory;
    struct Staker {
        uint stake;
        uint lastDepositAt;
        uint delegatedAmount;
        address delegatee;
    }

    mapping(address => Staker) public stakers;

    // Tracks sums of delegations for delegatees
    mapping(address => uint) public delegationSums;

    uint private constant GRANULARITY = 10e11;
    uint private constant NUMBER_OF_VARIABLE_REWARD_PERIODS = 59;

    IERC20 public tokenAddress = IERC20(0x1dd453cE32141a80978B0a43Dc519a7d4258796D);
    uint public rewardsPaid;
    uint public totalStake;
    uint public stakingStartBlock; 
    uint public stakingRewardPeriodLength; //in blocks
    uint public stakingStartingReward;
    uint public stakingRewardDownwardStep;
    uint public delegationStakeRequirement;

  constructor() Ownable(){
        stakingStartBlock = block.number;
        stakingRewardPeriodLength = 200000;
        stakingStartingReward = 37250;
        stakingRewardDownwardStep = 620;
        delegationStakeRequirement = 1;

  }

  function setDelegationStakeRequirement(uint _delegationStakeRequirement) external onlyOwner {
        delegationStakeRequirement = _delegationStakeRequirement;
  }
      function getRewardAtBlock(uint _stake, uint _lastDepositAt, uint _blockNumber) public view returns (uint reward)  {
        if(_stake == 0) {
            return 0;
        }

        uint depositingInterval = _lastDepositAt.sub(stakingStartBlock).div(stakingRewardPeriodLength);
        //0 is the first period
        uint currentInterval = _blockNumber.sub(stakingStartBlock).div(stakingRewardPeriodLength);

        uint lastVariableRewardInterval = currentInterval > NUMBER_OF_VARIABLE_REWARD_PERIODS ? NUMBER_OF_VARIABLE_REWARD_PERIODS : currentInterval;

        if (currentInterval > depositingInterval) {
            //first interval, A
            uint rewardAtFirstInterval = stakingStartingReward.sub((depositingInterval.mul(stakingRewardDownwardStep)));

            uint widthOfFirstIntervalSection = stakingStartBlock.add(depositingInterval.add(1).mul(stakingRewardPeriodLength)).sub(_lastDepositAt);

            reward = reward.add(rewardAtFirstInterval.mul(widthOfFirstIntervalSection));

            //last interval, C
            uint rewardAtLastInterval = stakingStartingReward.sub(lastVariableRewardInterval.mul(stakingRewardDownwardStep));

            uint widthOfLastIntervalSection = _blockNumber.sub(stakingStartBlock.add(lastVariableRewardInterval.mul(stakingRewardPeriodLength)));

            reward = reward.add(widthOfLastIntervalSection.mul(rewardAtLastInterval));

            if (lastVariableRewardInterval.sub(depositingInterval) > 1) {
                uint rewardAtPenultimateInterval = rewardAtLastInterval.add(stakingRewardDownwardStep);

                uint widthOfMiddleSections = (lastVariableRewardInterval.sub(depositingInterval).sub(1)).mul(stakingRewardPeriodLength);

                //middle intervals base, B
                reward = reward.add(rewardAtPenultimateInterval.mul(widthOfMiddleSections));

                //middle intervals triangle, B'
                uint rewardAtSecondInterval = rewardAtFirstInterval.sub(stakingRewardDownwardStep);

                reward.add(((rewardAtSecondInterval.sub(rewardAtPenultimateInterval)).mul(widthOfMiddleSections)).div(2));
            }
        } else {
            reward = reward.add(_blockNumber.sub(_lastDepositAt).mul(stakingStartingReward.sub(depositingInterval.mul(stakingRewardDownwardStep))));
        }

        reward = reward.mul(_stake);
        reward = reward.div(GRANULARITY);
    }
    function stake(uint _amount) public {
        // The tokens will be held in a Gnosis multisig contract for which the owners will be the Indorse board members
        require(tokenAddress.transferFrom(msg.sender, address(this), _amount), "Insufficient token balance");
        Staker storage staker = stakers[msg.sender];

        //New staker
        if (staker.stake == 0) {
            staker.stake = _amount;
            staker.lastDepositAt = block.number;
            totalStake = totalStake.add(_amount);
            //Existing staker - adding current reward to the stake
        } else {
            uint reward = getRewardAtBlock(staker.stake, staker.lastDepositAt, block.number);
            staker.stake = staker.stake.add(_amount.add(reward));
            rewardsPaid = rewardsPaid.add(reward);
            totalStake = totalStake.add(_amount).add(reward);
            staker.lastDepositAt = block.number;
        }
    }
    //Withdraws the entire stake and rewards
    function claimAndWithdraw() external {
        Staker storage staker = stakers[msg.sender];
        if (staker.stake == 0) {
            return;
        }

        uint reward = getRewardAtBlock(staker.stake, staker.lastDepositAt, block.number);
        totalStake = totalStake.sub(staker.stake);
        rewardsPaid = rewardsPaid.add(reward);
        require(tokenAddress.transferFrom(address(this), msg.sender, staker.stake.add(reward)));
        staker.stake = 0;
    }
    function withdraw() external  {
        Staker storage staker = stakers[msg.sender];

        if (staker.stake == 0) {
            return;
        }

        totalStake = totalStake.sub(staker.stake);
        require(tokenAddress.transferFrom(address(this), msg.sender, staker.stake));
        staker.stake = 0;

      
    }
     function claim() external {
        Staker storage staker = stakers[msg.sender];

        if(staker.stake == 0) {
            return;
        }

        uint reward = getRewardAtBlock(staker.stake, staker.lastDepositAt, block.number);
        require(tokenAddress.transferFrom(address(this), msg.sender, reward));
        rewardsPaid = rewardsPaid.add(reward);
        staker.lastDepositAt = block.number;
    }
    function claimAndStake() external {
        Staker storage staker = stakers[msg.sender];

        if (staker.stake == 0) {
            return;
        }

        uint reward = getRewardAtBlock(staker.stake, staker.lastDepositAt, block.number);
        totalStake = totalStake.add(reward);
        rewardsPaid = rewardsPaid.add(reward);
        staker.stake = staker.stake.add(reward);
        staker.lastDepositAt = block.number;
    }
    function getStaker(address _addr)
    external
    view
    returns (
        uint stake_,
        uint lastDepositAt_,
        uint delegatedAmount_,
        address delegatee_
    )
    {
        Staker storage staker_ = stakers[_addr];

        stake_ = staker_.stake;
        lastDepositAt_ = staker_.lastDepositAt;
        delegatedAmount_ = staker_.delegatedAmount;
        delegatee_ = staker_.delegatee;
    }

    function getStake(address _addr) external view returns (uint) {
        return stakers[_addr].stake;
    }
    function sendValueTo(address to_, uint256 value) internal {
        address payable to = payable(to_);
        (bool success, ) = to.call{value: value}("");
        require(success, "Transfer failed.");
    }
    function getLastDepositAt(address _addr) external view returns (uint) {
        return stakers[_addr].lastDepositAt;
    }
    function getValueAt(Checkpoint[] storage checkpoints, uint _block) view internal returns (uint) {
        if (checkpoints.length == 0)
            return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length - 1].fromBlock)
            return checkpoints[checkpoints.length - 1].value;
        if (_block < checkpoints[0].fromBlock)
            return 0;

        // Binary search of the value in the array
        uint min = 0;
        uint max = checkpoints.length - 1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock <= _block) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return checkpoints[min].value;
    }
    function totalSupplyAt(uint _blockNumber) external view returns (uint) {
        return getValueAt(totalSupplyHistory, _blockNumber);
    }
    function balanceOfAt(address _owner, uint _blockNumber) external view returns (uint) {
        return getValueAt(balances[_owner], _blockNumber);
    }
    function EmergencyWithdrawaltoken(address token) public onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer( msg.sender, balance);
        
    } 
    function EmergencyValue() public onlyOwner {
        sendValueTo(msg.sender, address(this).balance);
    }
    
}