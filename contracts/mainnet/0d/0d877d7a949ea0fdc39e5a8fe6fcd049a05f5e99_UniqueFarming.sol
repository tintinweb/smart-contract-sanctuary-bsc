/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IFarmController
{ 
    //// FUNCTIONS
    function AddToPull(uint value, address userAddress) external;
    function Register(address user, uint referalId) external;

    //// VIEW
    function UserExist(address userAddress) external view returns (bool);
    function GetReferrer(address userAddress) external view returns (address);
    function GetReferalLinesCount() external view returns(uint);
    function GerReferalRewardLevel(uint level) external view returns (uint);
}

library SafeMath 
{
   
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) 
    {
        unchecked 
        {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) 
    {
        unchecked 
        {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) 
    {
        unchecked 
        {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return a % b;
    }

    function sub(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) 
    {
        unchecked 
        {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) 
    {
        unchecked 
        {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) 
    {
        unchecked 
        {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract UniqueFarming 
{
    using SafeMath for uint256;
    IFarmController controller;
    address Owner;
    address PullAddress;
    address DeveloperAddress;
    bool Started = false;
    uint256 StartedAt;
    uint256 MinDeposit = 0.05 ether;
    uint256 public MaxDepositePerWeek = 5 ether;
    uint256 public MaxDepositeEver = 500 ether;
    uint256 public minReinvest = 0.01 ether;
    uint256 public minWithdraw = 0.05 ether;
    uint256 RewardPercent = 3;
    uint256 PullValuePercent = 4;
    uint256 DevRewardPercent = 2;
    uint256 public Day = 86400;
    uint256 public Week = 604800;
    
   constructor(address _PullAddress, address _DevAddress, address _controller)
   {
       PullAddress = _PullAddress;
       DeveloperAddress = _DevAddress;
       controller = IFarmController(_controller);
       Owner = msg.sender;
   }


    //// EVENTS
    event Deposited(address indexed _address, uint256 Amount, uint256 IncomeAmount);
    event Reinvested(address indexed _address, uint256 IncomeAmount);
    event Withdrawed(address indexed _address, uint256 IncomeAmount, uint256 bnbValue );

    //// MAPPINGS
    mapping (address => uint) BallanceByAddress;
    mapping (address => uint) LastClaimByAddress;
    mapping (address => uint) TotalIncomeByAddress;
    mapping (address => uint) ReferalsIncomeByAddress;
    mapping (address => uint) ReinvestedValueByAddress;
    //// FUNCTIONS

    ////////   Important! Do not transfer tokens directly  ////////
    fallback() external payable 
    {
        payable(msg.sender).transfer(msg.value);
    }

    receive() external payable 
    {
        payable(msg.sender).transfer(msg.value);
    }

    function Deposit() public payable 
    {
        require(Started, "The game hasn't started yet");
        require(msg.value >= MinDeposit, "DEPOSIT MINIMUM VALUE");
        require(msg.value <= getMaxDeposit(msg.sender), "DEPOSIT VALUE EXCEEDS MAX");
        if (!controller.UserExist(msg.sender))
        {
            RegisterWithReferer(1);
        }
        uint256 value = msg.value;
        uint onePercent = msg.value / 100;
        
        // REFERAL REWARD
        address userReferrer = controller.GetReferrer(msg.sender);
        uint referalLines = controller.GetReferalLinesCount();
        for (uint8 line = 1; line <= referalLines; line++) 
        {
            uint rewardValue = onePercent * controller.GerReferalRewardLevel(line);
            value -= rewardValue;    
            payable(userReferrer).transfer(rewardValue);

            ReferalsIncomeByAddress[userReferrer] += rewardValue;

            userReferrer = controller.GetReferrer(userReferrer);
            if (userReferrer == address(0))
            {
                userReferrer = Owner;
            }
        }
        
        // Transact to pull
        uint pullValue = onePercent * PullValuePercent;
        value -= pullValue;
        payable(PullAddress).transfer(pullValue);
        controller.AddToPull(pullValue, msg.sender);


        // Dev transact
        uint devValue = onePercent * DevRewardPercent;
        value -= devValue;
        payable(DeveloperAddress).transfer(devValue);

        // Construct deposite 
        if (BallanceByAddress[msg.sender] > 0)
        {
            uint256 bnbValue = calculateIncome(msg.sender);
            BallanceByAddress[msg.sender] += bnbValue;
        } 
        LastClaimByAddress[msg.sender] = block.timestamp;
        BallanceByAddress[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value, value);
    }
    function RegisterWithReferer(uint256 refId) public 
    {
        require(!controller.UserExist(msg.sender), "User exist");
        controller.Register(msg.sender, refId);
    }
     
    function Withdraw() public 
    {
        require(Started, "The game hasn't started yet");
        uint256 bnbValue = calculateIncome(msg.sender);
        require(bnbValue > minWithdraw, "Not enought bnb to withdraw");
        require(getBalance() >= bnbValue, "NOT ENOUGH BALANCE");
        LastClaimByAddress[msg.sender] = block.timestamp;
        TotalIncomeByAddress[msg.sender] += bnbValue;
        payable (msg.sender).transfer(bnbValue);
        emit Withdrawed(msg.sender, bnbValue, BallanceByAddress[msg.sender]);
    }

    function Reinvest() public 
    {
        require(Started, "The game hasn't started yet");
        require(isDayPassed(msg.sender), "Day is not passed");
        require(controller.UserExist(msg.sender), "Not registered");       
        uint256 bnbValue = calculateIncome(msg.sender);
        require(bnbValue > minReinvest, "Not enought bnb to reinvest");
        LastClaimByAddress[msg.sender] = block.timestamp;
        BallanceByAddress[msg.sender] += bnbValue;
        ReinvestedValueByAddress[msg.sender] += bnbValue;
    }
   


    /////  View
    function getMaxDeposit(address userAddress) public view returns (uint256) 
    {  
        uint256 weeksPast = 1 + block.timestamp.sub(StartedAt).mul(10).div(Week).div(10);
        uint256 maxDepositeCurrent= MaxDepositePerWeek.mul(weeksPast);
        uint256 maxDeposite = min(maxDepositeCurrent, MaxDepositeEver);
        if (maxDeposite == 0) maxDeposite = MaxDepositePerWeek;
        return maxDeposite.sub(BallanceByAddress[userAddress]);
    }
    function isDayPassed(address userAddress) public view returns(bool)
    {
        return Day < (block.timestamp  - LastClaimByAddress[userAddress]);
    }
    function getUserIncomePercent(uint256 value, uint256 percent) private pure returns(uint256) 
    {  
        return SafeMath.div(SafeMath.mul(value, percent), 100);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) 
    {
        return a < b ? a : b;
    }
    function getTotalIncome(address userAddress) public view returns(uint256)
    {
        return TotalIncomeByAddress[userAddress];
    }
    function getBalance() public view returns(uint256) 
    {
        return address(this).balance;
    }
    function getUserBallance(address userAddress) public view returns(uint256)
    {
        return BallanceByAddress[userAddress];
    }
    function getReferralsIncome(address userAddress) public view returns(uint256) 
    {
        return ReferalsIncomeByAddress[userAddress];
    }
    function calculateIncome(address userAddress) public view returns(uint)
    {
        uint currentTime = block.timestamp;
        if(currentTime == LastClaimByAddress[userAddress])
        {
            return 0;
        }
        uint SecondPassesAfterClime = SafeMath.sub(currentTime, LastClaimByAddress[userAddress]);
        uint PassedDays = SafeMath.div(SecondPassesAfterClime, Day);
        uint SecondsWithoutDays = SafeMath.sub(SecondPassesAfterClime,SafeMath.mul(PassedDays,Day));

        uint value;
        if (PassedDays > 0)
        {
            for (uint dayNumber = 0; dayNumber < PassedDays; dayNumber++)
            {
               value += getUserIncomePercent(BallanceByAddress[userAddress], RewardPercent);
            }
        }
        if (SecondsWithoutDays == 0)
        {
            return value;
        }
        uint SecondPercent = SafeMath.div(SecondsWithoutDays,SafeMath.div(Day,100));
        uint SecRewardPercent = (SafeMath.mul(10000, RewardPercent)).mul(SecondPercent).div(100);
        uint SecReward = SafeMath.div(SafeMath.mul(SecRewardPercent, BallanceByAddress[userAddress]),1000000);
        value += SecReward;
        return value;
    }

    /// ADMIN
    function Start () public
    {
        require(msg.sender == Owner, "2");
        Started = true;
        StartedAt = block.timestamp;
    }
    function ChangeController(address newController) public 
    {
        require(msg.sender == Owner, "2");
        controller = IFarmController(newController);
    }
    function ChangePullAddress(address newAddress) public 
    {
        require(msg.sender == Owner, "2");
        PullAddress = newAddress;
    }
    function ChangeDevAddress(address newAddress) public 
    {
        require(msg.sender == Owner, "2");
        DeveloperAddress = newAddress;
    }
    function ChangeOwner(address newAddress) public
    {
        require(msg.sender == Owner, "2");
        Owner = newAddress;
    }
}