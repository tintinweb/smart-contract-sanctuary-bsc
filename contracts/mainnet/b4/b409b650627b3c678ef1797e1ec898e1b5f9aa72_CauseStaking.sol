/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
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
    function mint(uint256 amount) external returns(bool);
    function transferOwnership(address newOwner) external ;

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

contract CauseStaking{
    bool public isHalted=false;
    uint256 public stakedAmount ;
    address admin;
    address CauseTokenAddress=0x3901a1296E4f409D6FB1736A44aee597141f1a03;
    uint stakeCounter=1;
    uint sixMonths=180 days;
    uint twelveMonths=360 days;
    uint eighteenMonths=540 days;
    uint twentyFourMonths=720 days;
    uint interestSix=512;
    uint interestTwelve=830;
    uint interestEighteen=1608;
    uint interestTwoYears=3060;

    IBEP20 cause= IBEP20(CauseTokenAddress);
    
    struct Stake{
        address user;
        uint stakeId;
        uint amount;
        uint since;
        uint dueDate;
        uint duration;
    }

    struct StakeHolder{
        address  user;
        Stake[] userStakes;
    }

    StakeHolder[] public stakeholders;

    // mapping holding an address and an index of that address in the stakeholders array
    mapping(address=>uint256) public stakeholderIndex;
    mapping(address=>uint256) balance;
    // events
    event Staked(address indexed stakingAddress, uint256 stakedAmount);
    event Unstaked(address indexed unstakingAddress, uint256 unstakedAmount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    // modifiers
    modifier onlyAdmin(){
        require(msg.sender == admin, "only admin" );
        _;
    }

    modifier notHalted(){
        require(!isHalted, "cannot execute when contract has be halted");
        _;
    }

    modifier inEmergency(){
        require(isHalted, "cannot execute when contract is not halted");
        _;
    }

    modifier notZero( uint256 amount){
        require(amount >0);
        _;
    }

    constructor(){
        stakeholders.push();
        admin=msg.sender;
    }

    function transferOwnership(address newOwner) public onlyAdmin {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(admin, newOwner);
    admin = newOwner;
  }

    function _addStakeholder(address stakerholder) internal returns (uint){

        uint lastIndex;
        if(stakeholderIndex[stakerholder] == 0){
            stakeholders.push();
            lastIndex =stakeholders.length -1;
        }
        return lastIndex;
    }

    function _stake(uint256 amount, address user, uint duration) notZero(amount) notHalted internal returns(uint){

        cause.transferFrom(user, address(this), amount);
        uint userIdx =stakeholderIndex[user]; 

        if(userIdx == 0){
            userIdx=_addStakeholder(user);
            stakeholderIndex[user]=userIdx;
        }
        uint stakeId=stakeholders[userIdx].userStakes.length;

        if(stakeId == 0){
            stakeholders[userIdx].userStakes.push();
            stakeId=stakeholders[userIdx].userStakes.length;

        }
       
        Stake memory newStake = Stake({user: user,stakeId:stakeId, amount: amount,dueDate:block.timestamp + duration, duration:duration, since: block.timestamp});
        stakeholders[userIdx].userStakes.push(newStake);
        stakedAmount +=amount;
        return stakeholders[userIdx].userStakes.length;
    }

    function _unstake(uint stakeId, address user) notHalted internal {
        uint userIdx =stakeholderIndex[user];
        require(userIdx != 0,"address not a stakeholder");
        Stake memory unstakeAmount= stakeholders[userIdx].userStakes[stakeId];
        require( block.timestamp>=unstakeAmount.dueDate, "cannot unstake before due date");

        uint rewardPeriod=unstakeAmount.duration;
        uint _stakedAmount=unstakeAmount.amount;
        uint rewardAmount;
        if(rewardPeriod == sixMonths){
            rewardAmount=(interestSix*_stakedAmount)/1000;
        }
        if(rewardPeriod == twelveMonths ){
             rewardAmount=(interestTwelve*_stakedAmount)/1000;
        }
        if(rewardPeriod == eighteenMonths){
             rewardAmount=(interestEighteen*_stakedAmount)/10000;
        }
        if(rewardPeriod == twentyFourMonths){
             rewardAmount=(interestTwoYears*_stakedAmount)/10000;
        }
        uint totalAmount =_stakedAmount +rewardAmount;

        cause.transfer(user, totalAmount);
    
        delete stakeholders[userIdx].userStakes[stakeId];
        stakedAmount-=unstakeAmount.amount;
        emit Unstaked(msg.sender, totalAmount);
    }

    function stake(uint amount, uint duration) notHalted public returns(uint) {
        require(amount >0, "cannot stake o");
        require(duration >5, "cannot stake for duration less than 6 months");
        require(cause.allowance(msg.sender, address(this)) >= amount, "no allowance to spend");

        uint index;
        if(duration == 6){
             index =_stake(amount, msg.sender,sixMonths);
        }
        if(duration == 12){
             index =_stake(amount, msg.sender,twelveMonths);
        }
        if(duration == 18){
             index =_stake(amount, msg.sender, eighteenMonths);
        }
       if(duration == 24){
             index =_stake(amount, msg.sender, twentyFourMonths);
        }
        emit Staked(msg.sender, amount);
        return index;
    }


    function unstake (uint stakeId) notHalted  public{
        _unstake(stakeId, msg.sender);
    }

    function addressStakes() public view returns(Stake[] memory){
        uint index=stakeholderIndex[msg.sender];
        return stakeholders[index].userStakes;
    }

    function get_all_stakeholders() public view returns(StakeHolder[] memory){
        return stakeholders;
    }

    function haltContractInEmergency() onlyAdmin notHalted public {
        isHalted =!isHalted;
    }

    function transferContractCause () onlyAdmin inEmergency public{
        uint StakingContractBalance=cause.balanceOf(address(this));
        cause.transfer(admin, StakingContractBalance);
    }
}