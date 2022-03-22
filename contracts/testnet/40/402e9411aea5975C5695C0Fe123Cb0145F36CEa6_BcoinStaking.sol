// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract BcoinStaking {
    IBEP20 public rewardsToken;
    IBEP20 public stakingToken;

    uint private totalStake;
    uint public lastUpdateTime;
    uint public rewardPerTokenStored;

    struct Staker {
        uint rewards;
        uint balances;
        uint timeStake;
        uint userRewardPerTokenPaid;
    }
    mapping(address => Staker) stakers;

    //time start smartcontract
    uint private timeStart;

    //unlock timeline
    uint[] private tokenUnlock = [
        300000, 300000, 250000, 250000,
        250000, 250000, 250000, 250000,
        200000, 200000, 200000, 200000,
        200000, 200000, 200000, 200000,
        200000, 200000, 200000, 200000,
        200000, 100000, 100000, 100000
    ];

    //withdraw fee percent
    uint[] private widthdrawFee = [
        15, 14, 13, 12,
        11, 10, 9, 8,
        7, 6, 5, 4,
        3, 2, 1, 0
    ];

    event Stake(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);
    event GetReward(address indexed user, uint reward);

    constructor(IBEP20 _stakingToken, IBEP20 _rewardsToken) {
        stakingToken = _stakingToken;
        rewardsToken = _rewardsToken;
        timeStart = block.timestamp;
    }

    modifier updateReward(address _account) {  
        rewardPerTokenStored = rewardPerToken();   
        lastUpdateTime = block.timestamp;           
        stakers[_account].rewards = earned(_account);
        stakers[_account].userRewardPerTokenPaid = rewardPerTokenStored;
        _;
    }

    //function run for test change time smartcontract
    function testTimeContract(uint _time) public {
        timeStart = _time;
    }

    function testTimeUser(uint _time) public {
        stakers[msg.sender].timeStake = _time;
    }

    function getTotalBalance() public view returns (uint) {
        return stakingToken.totalSupply();
    }

    function rewardPerToken() public view returns (uint) {
        if (totalStake == 0) {
            return rewardPerTokenStored;
        }
        return 
            rewardPerTokenStored + 
            ((block.timestamp - lastUpdateTime) * rewardPerTokenBySecond());
    }    

    function rewardPerTokenBySecond() public view returns (uint) {
        if (totalStake == 0) {
            return 0;
        }
        return ((getTokenUnlock() / totalStake / 30 ) * 1e18) / 24 / 3600;
    }

    function rewardPerTokenByDay() public view returns (uint) {
        if (totalStake == 0) {
            return 0;
        }
        return (getTokenUnlock() / totalStake / 30) * 1e18;
    }

    function earned(address _account) public view returns (uint) {
        return 
            ((stakers[_account].balances * 
            (rewardPerToken() - stakers[_account].userRewardPerTokenPaid)) / 1e18) + 
            stakers[_account].rewards;
    }    

    function stake(uint _amount) external updateReward(msg.sender) {
        uint allowance = stakingToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");
        totalStake += _amount;
        stakers[msg.sender].timeStake = block.timestamp;
        stakers[msg.sender].balances += _amount;        
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        emit Stake(msg.sender, _amount);
    }

    function withdraw(uint _amount) external updateReward(msg.sender) {
        //check withdraw fee day
        uint fee = getWithdrawFeeByUser(msg.sender);
        _amount -= (_amount * fee) / 100;
        totalStake -= _amount;
        stakers[msg.sender].balances -= _amount;
        stakingToken.transfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _amount);
    }

    function getReward() external updateReward(msg.sender) {
        uint reward = stakers[msg.sender].rewards;
        stakers[msg.sender].rewards = 0;
        rewardsToken.transfer(msg.sender, reward);
        emit GetReward(msg.sender, reward);
    }

    function getTokenUnlock() public view returns (uint) {
        uint currentTime = block.timestamp;
        uint dayStaked = (currentTime - timeStart) / 3600 / 24;

        //get index array token unlock from month staked
        uint index = dayStaked / 30;
        return tokenUnlock[index] * 1e18;
    }

    function getWithdrawFeeByUser(address _account) public view returns (uint) {
        uint currentTime = block.timestamp;
        uint dayStaked = (currentTime - stakers[_account].timeStake) / 3600 / 24;

        //get index array withdraw fee from day staked
        uint index = 0;
        if (dayStaked > 0){
            index = dayStaked - 1;
        }
        if (index <= widthdrawFee.length){
            return widthdrawFee[index];
        }
        return 0;
        
    }

    //return view
    //api return value
    function getTotalStaked() public view returns (uint) {
        return totalStake;
    }

    function getDaylyRewards() public view returns (uint) {
        return (rewardPerTokenByDay() * totalStake) / 1e18;
    }

    function getPercentAPR() public view returns (uint) {
        return rewardPerTokenByDay() * 365 * 100;
    }

    function getMyStaked(address _account) public view returns (uint) {
        return stakers[_account].balances;
    }
}

interface IBEP20 {
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
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

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