/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: CC-BY-SA 4.0
// https://creativecommons.org/licenses/by-sa/4.0/

pragma solidity 0.8.11;

contract Staking{

    constructor(ERC20 _Token, uint256 _RewardFactor, uint256 _MinimumTime, uint256 _WithdrawTime){
        Token = _Token;
        RewardFactor = _RewardFactor;
        MinimumTime = _MinimumTime;
        WithdrawTime = _WithdrawTime;
        owner = msg.sender;
    }

    ERC20 Token;
    
    mapping(address => uint256) public TimeStaked;
    mapping(address => uint256) public TokensStaked;
    mapping(address => uint256) public TimeFactor;
    mapping(address => uint256) public TimeClaim;
    address [] private user;
    mapping(address => uint256) public PendingReward;
    address public owner;
    uint256 public RewardFactor;
    uint256 public MinimumTime;
    uint256 public WithdrawTime;

    event Stake(address account, uint256 amount);
    event ClaimRewards(address account, uint256 amount);
    event Withdraw(address account, uint256 amount);
    event TransferOwnership(address prevOwner, address newOwner);
    event ChangeToken(ERC20 prevToken, ERC20 newToken);
    event ChangeReward(uint256 prevReward, uint256 newReward);
    event ChangeWithdrawTime(uint256 prevTime, uint256 newTime);
    event ChangeMinimumStakeTime(uint256 prevTime, uint256 newTime);


    modifier onlyOwner() {
        
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        
        require(newOwner != address(0), "Owner can't be zero address");
        emit TransferOwnership(owner, newOwner);
        owner = newOwner;
    }

    function EditToken(ERC20 newToken) public onlyOwner {
        require(Token != newToken, "Token must be different");
        emit ChangeToken(Token, newToken);
        Token = newToken;
    }

    function EditReward(uint256 BPSperDay) public onlyOwner {
        require(RewardFactor != BPSperDay, "Reward must be different");
        SaveRewards();
        emit ChangeReward(RewardFactor, BPSperDay);
        RewardFactor = BPSperDay;
    }

    function SweepToken(ERC20 TokenAddress) public onlyOwner {
        
        require(TokenAddress != Token, "This token is currently being used as rewards! You cannot sweep it while its being used!");
        TokenAddress.transfer(msg.sender, TokenAddress.balanceOf(address(this))); 
    }

    function EditWithdrawTime(uint256 HowManyBlocks) public onlyOwner {
        require(WithdrawTime != HowManyBlocks, "WithdrawTime must be different");
        emit ChangeWithdrawTime(WithdrawTime, HowManyBlocks);
        WithdrawTime = HowManyBlocks;
    }

    function EditMinimumStakeTime(uint256 HowManyBlocks) public onlyOwner {
        require(MinimumTime != HowManyBlocks, "MinimumTime must be different");
        emit ChangeMinimumStakeTime(MinimumTime, HowManyBlocks);
        MinimumTime = HowManyBlocks;
    }

    function stake(uint256 amount) public {

        require(Token.balanceOf(msg.sender) > 0, "You don't have any tokens to stake!");
        
        if(TokensStaked[msg.sender] == 0){RecordReward(msg.sender, true);}
        else{RecordReward(msg.sender, false);}
 
        Token.transferFrom(msg.sender, address(this), amount);
        TokensStaked[msg.sender] += amount; 

        user.push(msg.sender); 

        TimeFactor[msg.sender] = block.timestamp;

        emit Stake(msg.sender, amount);
    }

    function claimRewards() public {

        require(block.timestamp - TimeClaim[msg.sender] > MinimumTime, "You cannot claim rewards as the lock is still active");
        require(TokensStaked[msg.sender] > 0, "There is nothing to claim as you haven't staked anything");

        RecordReward(msg.sender, true);
        uint256 reward = PendingReward[msg.sender];
        PendingReward[msg.sender] = 0;

        Token.transfer(msg.sender, reward);

        emit ClaimRewards(msg.sender, reward);
    }

    function Unstake(uint256 amount) public {

        require(block.timestamp - TimeFactor[msg.sender] > WithdrawTime, "You cannot withdraw as the withdraw cooldown is active");
        require(TokensStaked[msg.sender] > 0, "There is nothing to withdraw as you haven't staked anything");

        require(TokensStaked[msg.sender] >= amount, "You cannot withdraw more tokens than you have staked");

        RecordReward(msg.sender, false);

        TokensStaked[msg.sender] -= amount;
        
        Token.transfer(msg.sender, amount); 

        emit Withdraw(msg.sender, amount);
    }
  
    function CalculateTime(address YourAddress) internal view returns (uint256){

        uint256 Time = block.timestamp - TimeStaked[YourAddress];
        
        return Time;
    }

    function CalculateRewards(address YourAddress, uint256 StakeTime) internal view returns (uint256){

        return (StakeTime * RewardFactor * (TokensStaked[YourAddress]/100000))/86400;
    }

    function displayTotalStaked() public view returns(uint256){
    
        return Token.balanceOf(address(this));
    }

    function RecordReward(address User, bool ResetClaim) internal {

        uint256 Unclaimed = CalculateRewards(User, CalculateTime(User));
        TimeStaked[User] = block.timestamp; 
        if(ResetClaim) TimeClaim[User] = block.timestamp;
        PendingReward[User] += Unclaimed;
    }

    function SaveRewards() internal {

        for(uint256 i = 0; i < user.length; i++) {
            if(TokensStaked[user[i]] == 0) continue;

            RecordReward(user[i], false);
        }
    }

    function CalculateDailyReward(address YourAddress) public view returns(uint256){

        return RewardFactor * (TokensStaked[YourAddress]/100000);
    }

    function CheckRewards(address YourAddress) public view returns (uint256){
        
        return(CalculateRewards(YourAddress, CalculateTime(YourAddress))) + PendingReward[YourAddress];
    }

    function APYtoBPS(uint APY) public pure returns(uint){

        APY *= 10e18;
        APY /= 365;

        return APY/10e15;
    }

}

interface ERC20{
    function transferFrom(address, address, uint256) external;
    function transfer(address, uint256) external;
    function balanceOf(address) external view returns(uint256);
    function decimals() external view returns (uint8);
}