/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract stakingReward{
    IERC20 public token;
    address private owner;
    uint public rewardRate = 150; //150 percent on the total investment
   struct StakeInfo{
       uint256 amount;
       uint256 lastUpdatedTime;
       uint256 endsAt;
       uint256 rewardClaimed;
   }
   struct User{
       address referredBy;
       mapping (uint8 => uint256) referrals_per_level;
   }

    // mapping (address=>uint[]) public ARRAY;
    mapping(address => StakeInfo) public stakeInfos;
    mapping(address => bool)public addressStaked;
    mapping (address => User)public user_info;
    // mapping (address => ReferralLevels) public  referInfo;
    // mapping (address => uint) private referral;
    uint8[4] private referralBonuses = [5, 4, 3, 2]; //percantages to give according to levels
    uint256 private stakeRoi; // for contract use
    uint public stakingTime; //time of staking plan
    uint public rewardPerMint = 5; //5 percent of the reward per mint
    event Deposit(address indexed _depositor, uint indexed _amount);
    event Received(address indexed _account, uint indexed  _value);
    event ReferralPayout(address indexed addr, uint256 amount, uint8 level);

 constructor(address contractAddress, uint _stakingTime){
    token = IERC20(contractAddress);
    stakingTime = _stakingTime;
    owner = msg.sender;
}


//deposit function

   function deposit(uint256 stakeAmount, address _referredBy)public{
       require(stakeAmount >0, "Not sufficient amount");
        token.transferFrom(msg.sender, address(this), stakeAmount);
        addressStaked[msg.sender] = true;
        stakeInfos[msg.sender] = StakeInfo({
        amount : stakeAmount,
        lastUpdatedTime : block.timestamp,
        endsAt : block.timestamp + stakingTime,
        rewardClaimed : 0
        });
        if (addressStaked[address(_referredBy)]== false){
           user_info[msg.sender].referredBy = address(0);
        }
        if(addressStaked[address(_referredBy)]== true) {
            user_info[msg.sender].referredBy = _referredBy;

            for(uint8 i = 0; i < referralBonuses.length; i++) {
                if(_referredBy == address(0)) break;
                user_info[_referredBy].referrals_per_level[i]++;
                _referredBy = user_info[_referredBy].referredBy;
            }
        }
        address ref = user_info[msg.sender].referredBy;
        for(uint8 i = 0; i < referralBonuses.length; i++){
            if(ref == address(0)) break;
              uint256 bonuses = (stakeAmount * referralBonuses[i])/ 100;
              token.transfer(ref, bonuses);
              emit ReferralPayout(ref, bonuses, (i+1));
             ref = user_info[ref].referredBy;
        }
        

        emit Deposit(msg.sender, stakeAmount);
   }
    
   //external function to receive tokens from the owner to give rewards

   receive() external payable {
        emit Received(msg.sender, msg.value);
    }

//withdraw function

  function withdraw() public{
        require(stakeInfos[msg.sender].amount > 0);
        uint256 stakeAmount = stakeInfos[msg.sender].amount;
         stakeRoi = (rewardRate * stakeAmount) /100;

        if(block.timestamp < stakeInfos[msg.sender].endsAt){
           require(block.timestamp >= stakeInfos[msg.sender].lastUpdatedTime + 60);
           uint256 updatedTime = (block.timestamp - (stakeInfos[msg.sender].lastUpdatedTime)) / 60;
           uint256 tokensToTransfer = ((stakeRoi * rewardPerMint) / 100) * updatedTime;
           token.transfer(msg.sender, tokensToTransfer);
           stakeInfos[msg.sender].rewardClaimed += tokensToTransfer; 
        }
        else if(block.timestamp > stakeInfos[msg.sender] .endsAt){
            require(stakeInfos[msg.sender].rewardClaimed < stakeRoi, "You have already claimed");
            uint256 remainingBalance = stakeRoi - stakeInfos[msg.sender].rewardClaimed;
            token.transfer(msg.sender, remainingBalance);
            stakeInfos[msg.sender].rewardClaimed += remainingBalance;
        }
        
        stakeInfos[msg.sender].lastUpdatedTime = block.timestamp;

    }
    function reInvest()public{
        require(stakeInfos[msg.sender].rewardClaimed > 0, " You don't have any rewards");
        uint256 rewards = stakeInfos[msg.sender].rewardClaimed;
        stakeInfos[msg.sender].amount += rewards;
        stakeInfos[msg.sender].rewardClaimed = 0;
        if(block.timestamp > stakeInfos[msg.sender].endsAt){
            stakeInfos[msg.sender] = StakeInfo({
           amount : rewards,
           lastUpdatedTime : block.timestamp,
           endsAt : block.timestamp + stakingTime,
           rewardClaimed : 0
       });
        }
    }
           

  
}