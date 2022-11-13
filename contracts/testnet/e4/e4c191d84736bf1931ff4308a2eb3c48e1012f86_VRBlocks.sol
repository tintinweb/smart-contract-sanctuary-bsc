/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

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

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

   
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


// https://docs.synthetix.io/contracts/Owned
contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor() public {
        //require(_owner != address(0), "Owner address cannot be 0");
        owner = msg.sender;
        emit OwnerChanged(address(0), owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


// Inheritance
contract VRBlocks is Owned {
    using SafeMath for uint256;
    Token vusd = Token(0x44030120DeE28Fe134FceAe3D19336E7D8b3bBe8); // VUSD TEST
    /* ========== UTIL FUNCTIONS ========== */

    function getTime() internal view returns (uint256) {
        // current block timestamp as seconds since unix epoch
        // Used to mock time changes in tests
        return now;
    }
    
    struct  userStruct{         
        uint256 stakedBal1;
        uint256 stakedTime1;
        //uint256 lockTime1;
        uint256 previousRewardBal1;
        uint256 rewardCalculationDate1;
        uint256 rewardsWithdrawn1;

        uint256 level;
        address referrer;              
        uint256 teamNum;
        uint256 directnum;  
        //uint256 maxDeposit;
        uint256 totalDeposit;
        uint256 directDeposit;
        uint256 teamTotalDeposit;
    }
    

    //mapping(address => address) public refferedBy;   
    mapping(address => userStruct) public user;
    mapping(address => mapping(uint256 => address[])) public teamUsers;

    uint256 totalUser;
    uint256 private constant referDepth = 15;
    uint256 public totalStaked1 = 0;    
    uint256 public minimunStake1 = 10 *1e18;

    uint256 public multiplier1 = 1; // 0.5% daily
    uint256 public divider1 = 200;

    
    function updateMinimumStakeAmount(uint256 amount1) public onlyOwner{
        minimunStake1 = amount1;
    }
     
    function updateMultiDivider(uint256 m1, uint256 d1) public onlyOwner{
        multiplier1 = m1;
        divider1 = d1;       
    }
   
  
    constructor() public {
    }

    fallback() external {
        revert();
    }

  
    uint256 internal rewardInterval = 86400 * 1; // 1 day
   
    function getTeamDeposit(address account) public view returns (uint256){
        uint256 totalTeam;
         for(uint256 i = 0; i < teamUsers[account][0].length; i++){     
          uint256 userTotalTeam = user[teamUsers[account][0][i]].teamTotalDeposit;
            totalTeam = totalTeam.add(userTotalTeam);            
        }
        return totalTeam;
    }

    function getLevelDeposits(address account, uint256 level) public view returns(uint256){
        uint256 levelDeposit;
        level=level-1;
        for(uint256 i = 0; i < teamUsers[account][level].length; i++){     
          uint256 userTotalTeam = user[teamUsers[account][level][i]].totalDeposit;
            levelDeposit = levelDeposit.add(userTotalTeam);            
        }
        return levelDeposit;
    }

    function downlineReward(address account) public view returns (uint256){
        //uint256 totalDownlineDeposit = getTeamDeposit(account);
        uint256 totalFirstLevelDeposits = user[account].directDeposit;
        //uint256 amountForCalculation;
        uint256 perIntervalReward;

        uint256 levelEarning;
        uint256 timeDiff = getTime().sub(user[account].rewardCalculationDate1);
        uint256 intervals = timeDiff.div(rewardInterval);
        /////////////////////////level 1/////////////////////////
        if(user[account].level == 2){
            perIntervalReward = (totalFirstLevelDeposits.mul(multiplier1)).div(divider1*2); // 50% of ROI
            levelEarning = intervals.mul(perIntervalReward);
        }
        else{
            perIntervalReward = (totalFirstLevelDeposits.mul(multiplier1)).div(divider1*5); // 20% of ROI
            levelEarning = intervals.mul(perIntervalReward);
        }
        ///////////////////////////level 2/////////////////////////
            uint256 totalSecondLevelDeposits = getLevelDeposits(account, 2);
            perIntervalReward = (totalSecondLevelDeposits.mul(multiplier1)*10).div(divider1*133); // 7.5% of ROI
            levelEarning = levelEarning + intervals.mul(perIntervalReward);
        ///////////////////////////level 3/////////////////////////
            uint256 totalThirdLevelDeposits = getLevelDeposits(account, 3);
            perIntervalReward = (totalThirdLevelDeposits.mul(multiplier1)).div(divider1*20); // 5% of ROI
            levelEarning = levelEarning + intervals.mul(perIntervalReward);
        ///////////////////////////level 4/////////////////////////
            uint256 totalForthLevelDeposits = getLevelDeposits(account, 4);
            perIntervalReward = (totalForthLevelDeposits.mul(multiplier1)).div(divider1*40); // 2.5% of ROI
            levelEarning = levelEarning + intervals.mul(perIntervalReward);
        ///////////////////////////level 5/////////////////////////
            uint256 totalFifthLevelDeposits = getLevelDeposits(account, 5);
            perIntervalReward = (totalFifthLevelDeposits.mul(multiplier1)).div(divider1*100); // 1% of ROI
            levelEarning = levelEarning + intervals.mul(perIntervalReward);
        ///////////////////////////level 6 to 10////////////////////////////////
            uint256 totalSixthLevelDeposits ;
        for(uint256 i=6;i<10;i++){
            totalSixthLevelDeposits = totalSixthLevelDeposits + getLevelDeposits(account, i);
        }
            perIntervalReward = (totalSixthLevelDeposits.mul(multiplier1)).div(divider1*65); // 1.5% of ROI
            levelEarning = levelEarning + intervals.mul(perIntervalReward);
        ///////////////////////////level 10 to 15////////////////////////////////
            uint256 totalSeventLevelDeposits;
        for(uint256 j=10;j<15;j++){
            totalSeventLevelDeposits = totalSeventLevelDeposits + getLevelDeposits(account, j);
        }
            perIntervalReward = (totalSeventLevelDeposits.mul(multiplier1)).div(divider1*50); // 0.5% of ROI
            levelEarning = levelEarning + intervals.mul(perIntervalReward);
        return levelEarning;
        
    } 
       
    ////////////////////////// STAKE plan 1 //////////////////////
    function stake1(uint256 amount, address upline) external {
        vusd.transferFrom(msg.sender, address(this), amount);
        require(amount >= minimunStake1, "Cannot stake less than minimum stake amount");
        //require(user[msg.sender].stakedBal1 == 0, "Tokens Already Staked!");

        if(user[msg.sender].referrer != address(0)){
            upline = user[msg.sender].referrer;
            user[upline].directDeposit = user[upline].directDeposit + amount;
            for(uint256 i = 0; i < referDepth; i++){
                if(upline != address(0)){
                    user[upline].teamTotalDeposit = user[upline].teamTotalDeposit.add(amount); 
                    upline = user[upline].referrer;
                }else{
                    break;
                }
            }
        }
        else if(user[msg.sender].referrer == address(0) && upline != msg.sender){
            user[msg.sender].referrer = upline;
            user[upline].directnum.add(1);
            if(user[upline].directnum > 50){
                user[upline].level = 2;
            }
            user[upline].directDeposit = user[upline].directDeposit + amount;
            ///// upline info update
            for(uint256 i = 0; i < referDepth; i++){
                if(upline != address(0)){
                    user[upline].teamNum = user[upline].teamNum.add(1);
                    user[upline].teamTotalDeposit = user[upline].teamTotalDeposit.add(amount); 
                    teamUsers[upline][i].push(msg.sender);
                    upline = user[upline].referrer;
                }else{
                    break;
                }
            }            
            /////////////////////////

        }
        
       // updateReferInfo(msg.sender,amount);
        user[msg.sender].totalDeposit = user[msg.sender].totalDeposit.add(amount);

        if(user[msg.sender].stakedBal1 > 0){
            user[msg.sender].previousRewardBal1 = IntervalRewardsOf1(msg.sender);
        }
        else{
            user[msg.sender].stakedTime1 = getTime();
            //user[msg.sender].lockTime1 = getTime() + 365 days;
        }
        
        user[msg.sender].stakedBal1 = user[msg.sender].stakedBal1 + amount;
        user[msg.sender].rewardCalculationDate1 = getTime();
        
        
        totalStaked1 = totalStaked1 + amount;
        //stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        totalUser = totalUser.add(1);
        emit Staked(msg.sender, amount);
    }

    
    function downlines(address account, uint256 level) public view returns(address [] memory){          
        return teamUsers[account][level];      
    }
   
    function upline(address account) public view returns(address){
        return user[account].referrer;
    }
    

    function IntervalRewardsOf1(address account) public view returns (uint256) {
         uint256 amount = user[account].stakedBal1;
         uint256 timeDiff = getTime().sub(user[account].rewardCalculationDate1);
         uint256 intervals = timeDiff.div(rewardInterval);
         uint256 perIntervalReward = (amount.mul(multiplier1)).div(divider1); 
        return intervals.mul(perIntervalReward);
    }
    
    // function unstake1() external{
    //     require(user[msg.sender].stakedBal1 > 0, "Account does not have a balance staked");
    //     //require(user[msg.sender].lockTime1 < now,"Lock Period Not Finished!");

    //     //address payable payee  = address(uint160(msg.sender));
    //     //ICOadmin.transfer(address(this).balance);
    //     withdrawReward1();        
    //     if(user[msg.sender].lockTime1 < now){
    //         //payee.transfer(user[msg.sender].stakedBal1);
    //         vusd.transfer(msg.sender, user[msg.sender].stakedBal1);
    //         emit Unstaked(msg.sender, user[msg.sender].stakedBal1);
    //     }
    //     else{
    //         uint256 withdrawAmount = user[msg.sender].stakedBal1 - (user[msg.sender].stakedBal1).div(10); // -10% penality
    //         //payee.transfer(withdrawAmount);
    //         vusd.transfer(msg.sender, withdrawAmount);
    //         emit Unstaked(msg.sender, withdrawAmount);
            
    //     }
        
    //     user[msg.sender].stakedBal1 = 0;
    //     user[msg.sender].stakedTime1 = 0;
    //     user[msg.sender].rewardCalculationDate1 = 0;
    //     user[msg.sender].lockTime1 = 0;
    //     user[msg.sender].totalDeposit = 0;//user[msg.sender].totalDeposit.sub(amount);
    //     address uplin = user[msg.sender].referrer;
    //     user[uplin].directDeposit = user[uplin].directDeposit.sub(user[msg.sender].stakedBal1);
    //     user[uplin].teamTotalDeposit = user[uplin].teamTotalDeposit.sub(user[msg.sender].stakedBal1); 
    // }
    
    function withdrawReward1() public{   
        uint256 rewards = IntervalRewardsOf1(msg.sender);
        uint256 downlineRewards = downlineReward(msg.sender);
        rewards = rewards + downlineRewards + user[msg.sender].previousRewardBal1;
        if(user[msg.sender].previousRewardBal1 > 0){
            require(user[msg.sender].rewardCalculationDate1 > now + 1 days, "Can withdraw 1 time in 24 Hours");
        }
        user[msg.sender].previousRewardBal1 = 0;
        //if(rewards > 10)
        require(rewards > 10*1e18, "Minimum withdrawl 10 usd and max 100 usd per day");
       
        if(rewards > 100*1e18){
            user[msg.sender].previousRewardBal1 = rewards.sub(100*1e18);
            rewards = 100*1e18;
        }
        //////////////////////////////////////////// update stake time
        uint256 timeDiff = getTime().sub(user[msg.sender].rewardCalculationDate1);
        uint256 intervals = timeDiff.div(rewardInterval);
        user[msg.sender].rewardCalculationDate1 = user[msg.sender].rewardCalculationDate1 + (intervals.mul(86400));
        ///////////////////////////////////////////
        //address payable payee  = address(uint160(msg.sender));
        user[msg.sender].rewardsWithdrawn1 = user[msg.sender].rewardsWithdrawn1 + rewards;
        //payee.transfer(rewards);
        rewards = rewards - rewards.div(10); // 10% tax
         vusd.transfer(msg.sender, rewards);
        emit Withdrawn(msg.sender, rewards);
    }
    
    
    function emergencyWithdraw() external onlyOwner{
         //require(address(this).balance >0 , "Funds  Not Available in contract!");
         address payable payee  = address(uint160(owner));
         payee.transfer(address(this).balance);
         vusd.transfer(owner,vusd.balanceOf(address(this)));
    }
   
 

    /* ========== EVENTS ========== */

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event rewards(address indexed staker, uint256 amount, uint256 reward, uint256 level);

    /* ========== END EVENTS ========== */
}


abstract contract Token {
    function transferFrom(address sender, address recipient, uint256 amount) virtual external;
    function transfer(address recipient, uint256 amount) virtual external;
    function balanceOf(address account) virtual external view returns (uint256)  ;

}