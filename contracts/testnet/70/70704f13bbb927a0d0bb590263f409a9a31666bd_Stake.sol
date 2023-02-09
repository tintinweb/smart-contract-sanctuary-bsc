/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

//"SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.8.2; 



interface RewardToken {
    
    function transfer(address to, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address to) external returns(uint256);
}

contract Stake { 
    address public owner;  
    mapping(address => uint) public stakeWallet;
    mapping(address => uint) public stakeTime;
    mapping(address => uint) public stakeProfit;
    mapping(uint => uint) public RewardPercentage;
    address public RewardPoolAddress=address(0);
    uint public locking;
    uint public deployTimestamp;
    
    
    constructor(address _tokenContract) {

       owner=msg.sender;       
       
       RewardPoolAddress= _tokenContract; 
       deployTimestamp = block.timestamp ;
       
    }  

    modifier onlyOwner() {
    // owner is storage variable is set during constructor
    if (msg.sender != owner) {      
       _;
    }
   
  }

    event withdraw(address _to, uint _amount);

    function changeRewardPoolAddress( address _rewardaddress) public onlyOwner {
        RewardPoolAddress = _rewardaddress;
    }   

    function RewardPercentageChange( uint _month , uint _percentage) public onlyOwner {
        RewardPercentage[_month] = _percentage;
    } 

    function setRewardToken(uint _amount) public onlyOwner{
        RewardToken(RewardPoolAddress).transfer(address(this), _amount);
       
    }  

    function viewProfit() public returns(uint){
        require(stakeWallet[msg.sender] > 0,"Wallet Address is not Exist");
        uint percentage=stakeTime[msg.sender];
        uint profit = stakeWallet[msg.sender] *  RewardPercentage[percentage]/100;
        stakeProfit[msg.sender]=profit;
        return profit;
    }

    function stake(uint _staketime , uint _stakeamount) public returns (bool){
        require(stakeWallet[msg.sender] == 0,"Wallet Address is already Exist");
        require(RewardToken(RewardPoolAddress).balanceOf(msg.sender) > _stakeamount, "Insufficient tokens");
        stakeWallet[msg.sender]=  _stakeamount;
        stakeTime[msg.sender]=  _staketime;
        RewardToken(RewardPoolAddress).transferFrom(msg.sender,address(this), _stakeamount);
        return true;
    }

    function withdrawProfit() public returns (bool){            
             //uint locktime=deployTimestamp + (30 * stakeTime[msg.sender] *(24*60*60));
             uint locktime=deployTimestamp + 1200;


             uint profit= viewProfit();
             require(stakeWallet[msg.sender] > 0,"Wallet Address is not Exist");
             require(block.timestamp > locktime,"Tokens are Locked");

            stakeWallet[msg.sender]=0;
            stakeTime[msg.sender]=0;

                 

            RewardToken(RewardPoolAddress).transfer(msg.sender, profit);

            
             emit withdraw(msg.sender,profit);
            return true;

             
           
    }

    function unstake() public returns (bool){            
             //uint locktime=deployTimestamp + (30 * stakeTime[msg.sender] *(24*60*60));
            
            uint locktime=deployTimestamp + 1200;

             uint totalAmt= stakeWallet[msg.sender]+stakeProfit[msg.sender];
             require(stakeWallet[msg.sender] > 0,"Wallet Address is not Exist");
             require(block.timestamp > locktime,"Tokens are Locked");

            stakeWallet[msg.sender]=0;
            stakeTime[msg.sender]=0;

                  

            RewardToken(RewardPoolAddress).transfer(msg.sender, totalAmt);

            
             emit withdraw(msg.sender,totalAmt);
            return true;

             
           
    }

    //function rescueTokens(){}
}