/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-27
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-11
 */

// File: contracts/BItBrick/Staking Project/recursiveFunction.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/// @title RAMT Staking Project(Recursive for referral rewards)
/// @author Muhammad Farooq(Blockchain Developer at BitBrick Technology Pvt. Ltd.)
contract recursive {
    ///For storing referral info
    struct referralInfo {
        address referredBy;
        address directReferrer;
        address referredToA;
        uint256 stakingAmountOfA;
        uint256 referralRewardA;
        address referredToB;
        uint256 stakingAmountOfB;
        uint256 referralRewardB;
        uint256 binaryReward;
        uint256 myReferrals;
        address[] referralList;
        uint256[] referralStakeAmount;
        bool referralRewardAClaimed;
        bool referralRewardBClaimed;
    }

    mapping(address => referralInfo) public referralInfos;

    ///To insert referral at proper location using binary tree
    function binaryEntry(address _referredBy, uint256 _stakeAmount) public {
        uint256 minReferralStakingAmount;
        uint256 newStakeAmount = _stakeAmount;
        if (_referredBy != address(0)) {
            require(
                referralInfos[msg.sender].referredBy == address(0),
                "Already referred"
            );
            referralInfos[msg.sender].referredBy = _referredBy;
            referralInfos[_referredBy].referralList.push(msg.sender);
            referralInfos[_referredBy].referralStakeAmount.push(_stakeAmount);
            referralInfos[_referredBy].myReferrals++;
            if (referralInfos[_referredBy].referredToA == address(0)) {
                referralInfos[_referredBy].referredToA = msg.sender;
                referralInfos[msg.sender].directReferrer = _referredBy;
                referralInfos[_referredBy].stakingAmountOfA = newStakeAmount;
                referralInfos[_referredBy].referralRewardA = ((10 *
                    newStakeAmount) / 100);
            } else if (referralInfos[_referredBy].referredToB == address(0)) {
                referralInfos[_referredBy].referredToB = msg.sender;
                referralInfos[msg.sender].directReferrer = _referredBy;
                referralInfos[_referredBy].stakingAmountOfB = newStakeAmount;
                referralInfos[_referredBy].referralRewardB = ((10 *
                    newStakeAmount) / 100);

                if (
                    referralInfos[_referredBy].stakingAmountOfA < newStakeAmount
                ) {
                    minReferralStakingAmount = referralInfos[_referredBy]
                        .stakingAmountOfA;
                } else {
                    minReferralStakingAmount = newStakeAmount;
                }
                referralInfos[_referredBy].binaryReward = ((10 *
                    minReferralStakingAmount) / 100);
            } else {
                entry(
                    referralInfos[_referredBy].referredToA,
                    referralInfos[_referredBy].referredToB,
                    newStakeAmount
                );
            }
        }
    }

    ///Recursive function for use in binaryEntry function
    function entry(
        address _referredToA,
        address _referredToB,
        uint256 _stakeAmount
    ) public {
        uint256 minReferralStakingAmount;
        uint256 newStakeAmount = _stakeAmount;
        if (referralInfos[_referredToA].referredToA == address(0)) {
            referralInfos[_referredToA].referredToA = msg.sender;
            referralInfos[msg.sender].directReferrer = _referredToA;
            referralInfos[_referredToA].stakingAmountOfA = newStakeAmount;
            referralInfos[_referredToA].referralRewardA = ((10 *
                newStakeAmount) / 100);
            referralInfos[_referredToA].myReferrals += 1;
        } else if (referralInfos[_referredToA].referredToB == address(0)) {
            referralInfos[_referredToA].referredToB = msg.sender;
            referralInfos[msg.sender].directReferrer = _referredToA;
            referralInfos[_referredToA].stakingAmountOfB = newStakeAmount;
            referralInfos[_referredToA].referralRewardB = ((10 *
                newStakeAmount) / 100);

            if (
                referralInfos[_referredToA].stakingAmountOfA == newStakeAmount
            ) {
                minReferralStakingAmount = newStakeAmount;
            } else if (
                referralInfos[_referredToA].stakingAmountOfA < newStakeAmount
            ) {
                minReferralStakingAmount = referralInfos[_referredToA]
                    .stakingAmountOfA;
            } else {
                minReferralStakingAmount = newStakeAmount;
            }
            referralInfos[_referredToA].binaryReward = ((10 *
                minReferralStakingAmount) / 100);
            referralInfos[_referredToA].myReferrals += 1;
        } else if (referralInfos[_referredToB].referredToA == address(0)) {
            referralInfos[_referredToB].referredToA = msg.sender;
            referralInfos[msg.sender].directReferrer = _referredToB;
            referralInfos[_referredToB].stakingAmountOfA = newStakeAmount;
            referralInfos[_referredToB].referralRewardA = ((10 *
                newStakeAmount) / 100);
            referralInfos[_referredToB].myReferrals += 1;
        } else if (referralInfos[_referredToB].referredToB == address(0)) {
            referralInfos[_referredToB].referredToB = msg.sender;
            referralInfos[msg.sender].directReferrer = _referredToB;
            referralInfos[_referredToB].stakingAmountOfB = newStakeAmount;
            referralInfos[_referredToB].referralRewardB = ((10 *
                newStakeAmount) / 100);

            if (
                referralInfos[_referredToB].stakingAmountOfA == newStakeAmount
            ) {
                minReferralStakingAmount = newStakeAmount;
            } else if (
                referralInfos[_referredToB].stakingAmountOfA < newStakeAmount
            ) {
                minReferralStakingAmount = referralInfos[_referredToB]
                    .stakingAmountOfA;
            } else {
                minReferralStakingAmount = newStakeAmount;
            }
            referralInfos[_referredToB].binaryReward = ((10 *
                minReferralStakingAmount) / 100);
            referralInfos[_referredToB].myReferrals += 1;
        } else {
            entry(
                referralInfos[_referredToA].referredToA,
                referralInfos[_referredToA].referredToB,
                newStakeAmount
            );
        }
    }
}
// File: contracts/BItBrick/Staking Project/Staking Project.sol

pragma solidity ^0.8.6;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

/// @title RAMT Staking Project
/// @author Muhammad Farooq(Blockchain Developer at BitBrick Technology Pvt. Ltd.)
//Zero Address: 0x0000000000000000000000000000000000000000

contract StakeUSDT is recursive {
    IERC20 RAMT;
    address public owner;
    uint8 public totalStakers;

    // 30 Days (30 * 24 * 60 * 60)
    uint256 private oneMonthTime = 2592000;
    // Package 1: 30 Months (30 * 30 * 24 * 60 * 60)
    uint256 private package1Time = 2 * 30;
    // Package 2: 25 Months (25 * 30 * 24 * 60 * 60)
    uint256 private package2Time = 2592000 * 25;
    // Package 3: 20 Months (20 * 30 * 24 * 60 * 60)
    uint256 private package3Time = 2592000 * 20;
    // Package 4: 16 Months (16 * 30 * 24 * 60 * 60)
    uint256 private package4Time = 2592000 * 16;
    // Package 5: 13 Months (13 * 30 * 24 * 60 * 60)
    uint256 private package5Time = 2592000 * 13;
    // Package 6: 10 Months (10 * 30 * 24 * 60 * 60)
    uint256 private package6Time = 2592000 * 10;

    struct StakeInfo {
        uint256 startTime;
        uint256 endTime;
        uint256 amount;
        uint256 package1_to_6;
        uint256 interestAmount;
        uint256 designationRank;
        uint256 designationReward;
        uint256 businessReward;
        bool staked;
        bool claimed;
    }

    mapping(address => StakeInfo) public stakeInfos;
    mapping(address => bool) public isUser;

    event Staked(address indexed from, uint256 amount);
    event Claimed(address indexed from, uint256 amount);

  

    constructor(IERC20 _tokenAddress) {
        require(
            address(_tokenAddress) != address(0),
            "Token address cannot be zero"
        );

        RAMT = _tokenAddress;
        totalStakers = 0;
        owner = msg.sender;
    }

    ///modifiers
    ///@dev only admin
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @notice To Claim reward and your staking amount after specified period of staking
    /// @dev will give error if, time not over yet.

    function claimReward() public {
        require(stakeInfos[msg.sender].staked == true, "not a participant");
        require(
            stakeInfos[msg.sender].endTime < block.timestamp,
            "Stake Time not over"
        );
        require(stakeInfos[msg.sender].claimed == false, "Already claimed");

        uint256 totalTokens = stakeInfos[msg.sender].amount +
            stakeInfos[msg.sender].interestAmount;
        stakeInfos[msg.sender].claimed = true;
        stakeInfos[msg.sender].staked = false;
        RAMT.transfer(msg.sender, stakeInfos[msg.sender].amount);
        RAMT.transfer(msg.sender, stakeInfos[msg.sender].interestAmount);

        emit Claimed(msg.sender, totalTokens);
    }

    /// @notice To stake your
    /// @dev You can get by back, designation, business, binary and referral rewards
    /// @param  _referredBy address, amount you want to stake for specified period
    function stakeToken(address _referredBy, uint256 _stakeAmount) public {
        uint256 stakeAmount = _stakeAmount;
        require(stakeAmount >= 20, "Min stake 20$");
        require(stakeInfos[msg.sender].staked == false, "already participated");
        require(
            RAMT.balanceOf(msg.sender) >= _stakeAmount,
            "Insufficient Balance"
        );
        require(
            isUser[_referredBy] == true || _referredBy == address(0),
            "Referrer is not User"
        );

        ///Using recursive contract function to allocate referrer and referral reward, binary and busiess reward
        recursive.binaryEntry(_referredBy, stakeAmount);

        ///Staking amount and saving info through mapping
        ///interestRate1 (50 < 600) = 30 * ((10 * amount)/ 100) ;
        if (
            stakeAmount >= 50 * (10 * RAMT.decimals()) &&
            stakeAmount < 600 * (10 * RAMT.decimals())
        ) {
            RAMT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time;
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 1;
            stakeInfos[msg.sender].interestAmount =
                30 *
                ((10 * stakeAmount) / 100);
            stakeInfos[msg.sender].designationRank = 0;
            stakeInfos[msg.sender].designationReward = 0;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;
            isUser[msg.sender] = true;

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }
        ///interestRate2 (600 < 1100) = 25 * ((12 * amount)/ 100) ;
        else if (
            stakeAmount >= 600 * (10 * RAMT.decimals()) &&
            stakeAmount < 1100 * (10 * RAMT.decimals())
        ) {
            RAMT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time;
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 2;
            stakeInfos[msg.sender].interestAmount =
                25 *
                ((12 * stakeAmount) / 100);
            stakeInfos[msg.sender].designationRank = 0;
            stakeInfos[msg.sender].designationReward = 0;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;
            isUser[msg.sender] = true;

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }
        ///interestRate3 (1100 < 3100) = 20 * ((15 * amount)/ 100) ;
        ///designationReward1 (1100 < 3100) = 100RAMT;
        else if (
            stakeAmount >= 1100 * (10 * RAMT.decimals()) &&
            stakeAmount < 3100 * (10 * RAMT.decimals())
        ) {
            RAMT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time;
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 3;
            stakeInfos[msg.sender].interestAmount =
                20 *
                ((15 * stakeAmount) / 100);
            stakeInfos[msg.sender].designationRank = 1;
            stakeInfos[msg.sender].designationReward =
                100 *
                (10**RAMT.decimals());
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;
            isUser[msg.sender] = true;

            RAMT.transfer(msg.sender, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }
        ///interestRate4 (3100 < 5100) = 16 * ((18 * amount)/ 100) ;
        ///designationReward2 (3100 < 5100) = 200RAMT;
        else if (
            stakeAmount >= 3100 * (10 * RAMT.decimals()) &&
            stakeAmount < 5100 * (10 * RAMT.decimals())
        ) {
            RAMT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time;
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 4;
            stakeInfos[msg.sender].interestAmount =
                16 *
                ((18 * stakeAmount) / 100);
            stakeInfos[msg.sender].designationRank = 2;
            stakeInfos[msg.sender].designationReward =
                200 *
                (10**RAMT.decimals());
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;
            isUser[msg.sender] = true;

            RAMT.transfer(msg.sender, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }
        ///interestRate5 (5100 < 11000) = 13 * (((22 + (1/2)) * amount)/ 100)
        ///designationReward3 (5100 < 11000) = 500RAMT;;
        else if (
            stakeAmount >= 5100 * (10 * RAMT.decimals()) &&
            stakeAmount < 11000 * (10 * RAMT.decimals())
        ) {
            RAMT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time;
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 5;
            stakeInfos[msg.sender].interestAmount =
                13 *
                (((22) * stakeAmount) / 100);
            stakeInfos[msg.sender].designationRank = 3;
            stakeInfos[msg.sender].designationReward =
                500 *
                (10**RAMT.decimals());
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;
            isUser[msg.sender] = true;

            RAMT.transfer(msg.sender, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }
        ///interestRate6 (11000 >) = 10 * ((30 * amount)/ 100) ;
        ///designationReward4 (11000 < 21000) = 1000RAMT;
        else if (
            stakeAmount >= 11000 * (10 * RAMT.decimals()) &&
            stakeAmount < 21000 * (10 * RAMT.decimals())
        ) {
            RAMT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time;
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 6;
            stakeInfos[msg.sender].interestAmount =
                10 *
                ((30 * stakeAmount) / 100);
            stakeInfos[msg.sender].designationRank = 4;
            stakeInfos[msg.sender].designationReward =
                1000 *
                (10**RAMT.decimals());
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;
            isUser[msg.sender] = true;

            RAMT.transfer(msg.sender, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }
        ///interestRate6 (11000 >) = 10 * ((30 * amount)/ 100) ;
        ///designationReward5 (21000>) = 1500RAMT;
        else if (stakeAmount >= 21000 * (10**RAMT.decimals())) {
            RAMT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time;
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 6;
            stakeInfos[msg.sender].interestAmount =
                10 *
                ((30 * stakeAmount) / 100);
            stakeInfos[msg.sender].designationRank = 5;
            stakeInfos[msg.sender].designationReward =
                1500 *
                (10**RAMT.decimals());
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;
            isUser[msg.sender] = true;

            RAMT.transfer(msg.sender, stakeInfos[msg.sender].designationReward);

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        } else {
            RAMT.transferFrom(msg.sender, address(this), stakeAmount);

            stakeInfos[msg.sender].startTime = block.timestamp;
            stakeInfos[msg.sender].endTime = block.timestamp + package1Time;
            stakeInfos[msg.sender].amount = stakeAmount;
            stakeInfos[msg.sender].package1_to_6 = 1;
            stakeInfos[msg.sender].interestAmount = 0;
            stakeInfos[msg.sender].designationRank = 0;
            stakeInfos[msg.sender].designationReward = 0;
            stakeInfos[msg.sender].staked = true;
            stakeInfos[msg.sender].claimed = false;
            isUser[msg.sender] = true;

            totalStakers++;
            emit Staked(msg.sender, stakeAmount);
        }

        setBusinessIncentive(_referredBy);

        ///To Transfer referral reward, binary reward and business reward
        if (_referredBy != address(0)) {
            if (
                referralInfos[referralInfos[msg.sender].referredBy]
                    .referredToB == 0x0000000000000000000000000000000000000000
            ) {
                RAMT.transfer(
                    referralInfos[msg.sender].referredBy,
                    ((10 * stakeAmount) / 100)
                );
                referralInfos[_referredBy].referralRewardAClaimed = true;
            } else {
                RAMT.transfer(
                    referralInfos[msg.sender].referredBy,
                    ((10 * stakeAmount) / 100)
                );
                RAMT.transfer(
                    referralInfos[msg.sender].directReferrer,
                    referralInfos[referralInfos[msg.sender].directReferrer]
                        .binaryReward
                );
                referralInfos[_referredBy].referralRewardBClaimed = true;

                if (
                    stakeInfos[_referredBy].businessReward >=
                    5000 * (10 * RAMT.decimals()) &&
                    stakeInfos[_referredBy].businessReward <
                    10000 * (10 * RAMT.decimals())
                ) {
                    stakeInfos[_referredBy].businessReward =
                        100 *
                        (10**RAMT.decimals());
                    RAMT.transfer(
                        _referredBy,
                        stakeInfos[_referredBy].businessReward
                    );
                } else if (
                    stakeInfos[_referredBy].businessReward >=
                    10000 * (10 * RAMT.decimals()) &&
                    stakeInfos[_referredBy].businessReward <
                    15000 * (10 * RAMT.decimals())
                ) {
                    stakeInfos[_referredBy].businessReward =
                        250 *
                        (10**RAMT.decimals());
                    RAMT.transfer(
                        _referredBy,
                        stakeInfos[_referredBy].businessReward
                    );
                } else if (
                    stakeInfos[_referredBy].businessReward >=
                    15000 * (10 * RAMT.decimals()) &&
                    stakeInfos[_referredBy].businessReward <
                    20000 * (10 * RAMT.decimals())
                ) {
                    stakeInfos[_referredBy].businessReward =
                        500 *
                        (10**RAMT.decimals());
                    RAMT.transfer(
                        _referredBy,
                        stakeInfos[_referredBy].businessReward
                    );
                } else if (
                    stakeInfos[_referredBy].businessReward >=
                    20000 * (10 * RAMT.decimals()) &&
                    stakeInfos[_referredBy].businessReward <
                    25000 * (10 * RAMT.decimals())
                ) {
                    stakeInfos[_referredBy].businessReward =
                        1000 *
                        (10**RAMT.decimals());
                    RAMT.transfer(
                        _referredBy,
                        stakeInfos[_referredBy].businessReward
                    );
                } else if (
                    stakeInfos[_referredBy].businessReward >=
                    25000 * (10 * RAMT.decimals()) &&
                    stakeInfos[_referredBy].businessReward <
                    30000 * (10 * RAMT.decimals())
                ) {
                    stakeInfos[_referredBy].businessReward =
                        1500 *
                        (10**RAMT.decimals());
                    RAMT.transfer(
                        _referredBy,
                        stakeInfos[_referredBy].businessReward
                    );
                } else if (
                    stakeInfos[_referredBy].businessReward >=
                    30000 * (10 * RAMT.decimals()) &&
                    stakeInfos[_referredBy].businessReward <
                    100000 * (10 * RAMT.decimals())
                ) {
                    stakeInfos[_referredBy].businessReward =
                        2000 *
                        (10**RAMT.decimals());
                    RAMT.transfer(
                        _referredBy,
                        stakeInfos[_referredBy].businessReward
                    );
                } else if (
                    stakeInfos[_referredBy].businessReward >=
                    100000 * (10 * RAMT.decimals()) &&
                    stakeInfos[_referredBy].businessReward <
                    300000 * (10 * RAMT.decimals())
                ) {
                    stakeInfos[_referredBy].businessReward =
                        2500 *
                        (10**RAMT.decimals());
                    RAMT.transfer(
                        _referredBy,
                        stakeInfos[_referredBy].businessReward
                    );
                } else if (
                    stakeInfos[_referredBy].businessReward >=
                    300000 * (10 * RAMT.decimals()) &&
                    stakeInfos[_referredBy].businessReward <
                    500000 * (10 * RAMT.decimals())
                ) {
                    stakeInfos[_referredBy].businessReward =
                        6000 *
                        (10**RAMT.decimals());
                    RAMT.transfer(
                        _referredBy,
                        stakeInfos[_referredBy].businessReward
                    );
                } else if (
                    stakeInfos[_referredBy].businessReward >=
                    500000 * (10 * RAMT.decimals()) &&
                    stakeInfos[_referredBy].businessReward <
                    1000000 * (10 * RAMT.decimals())
                ) {
                    stakeInfos[_referredBy].businessReward =
                        10000 *
                        (10**RAMT.decimals());
                    RAMT.transfer(
                        _referredBy,
                        stakeInfos[_referredBy].businessReward
                    );
                } else if (
                    stakeInfos[_referredBy].businessReward >=
                    1000000 * (10**RAMT.decimals())
                ) {
                    stakeInfos[_referredBy].businessReward =
                        20000 *
                        (10**RAMT.decimals());
                    RAMT.transfer(
                        _referredBy,
                        stakeInfos[_referredBy].businessReward
                    );
                }
            }
        }
    }

    function setBusinessIncentive(address _referredBy) internal {
        if (referralInfos[_referredBy].myReferrals == 2) {
            stakeInfos[_referredBy].businessReward = min(
                referralInfos[_referredBy].referralStakeAmount[0],
                referralInfos[_referredBy].referralStakeAmount[1]
            );
        } else if (referralInfos[_referredBy].myReferrals == 6) {
            stakeInfos[_referredBy].businessReward = min4(
                referralInfos[_referredBy].referralStakeAmount[2],
                referralInfos[_referredBy].referralStakeAmount[3],
                referralInfos[_referredBy].referralStakeAmount[4],
                referralInfos[_referredBy].referralStakeAmount[5]
            );
        } else if (referralInfos[_referredBy].myReferrals == 14) {
            stakeInfos[_referredBy].businessReward = min8(
                referralInfos[_referredBy].referralStakeAmount[6],
                referralInfos[_referredBy].referralStakeAmount[7],
                referralInfos[_referredBy].referralStakeAmount[8],
                referralInfos[_referredBy].referralStakeAmount[9],
                referralInfos[_referredBy].referralStakeAmount[10],
                referralInfos[_referredBy].referralStakeAmount[11],
                referralInfos[_referredBy].referralStakeAmount[12],
                referralInfos[_referredBy].referralStakeAmount[13]
            );
        } else if (referralInfos[_referredBy].myReferrals == 30) {
            uint256 A;
            uint256 B;
            A = min8(
                referralInfos[_referredBy].referralStakeAmount[14],
                referralInfos[_referredBy].referralStakeAmount[15],
                referralInfos[_referredBy].referralStakeAmount[16],
                referralInfos[_referredBy].referralStakeAmount[17],
                referralInfos[_referredBy].referralStakeAmount[18],
                referralInfos[_referredBy].referralStakeAmount[19],
                referralInfos[_referredBy].referralStakeAmount[20],
                referralInfos[_referredBy].referralStakeAmount[21]
            );

            B = min8(
                referralInfos[_referredBy].referralStakeAmount[22],
                referralInfos[_referredBy].referralStakeAmount[23],
                referralInfos[_referredBy].referralStakeAmount[24],
                referralInfos[_referredBy].referralStakeAmount[25],
                referralInfos[_referredBy].referralStakeAmount[26],
                referralInfos[_referredBy].referralStakeAmount[27],
                referralInfos[_referredBy].referralStakeAmount[28],
                referralInfos[_referredBy].referralStakeAmount[29]
            );

            stakeInfos[_referredBy].businessReward = min(A, B);
        }
    }

    function min(uint256 _A, uint256 _B) internal pure returns (uint256) {
        if (_A <= _B) {
            return _A;
        } else {
            return _B;
        }
    }

    function min4(
        uint256 _A,
        uint256 _B,
        uint256 _C,
        uint256 _D
    ) internal pure returns (uint256) {
        if (min(_A, _B) <= min(_C, _D)) {
            return min(_A, _B);
        } else {
            return min(_C, _D);
        }
    }

    function min8(
        uint256 _A,
        uint256 _B,
        uint256 _C,
        uint256 _D,
        uint256 _E,
        uint256 _F,
        uint256 _G,
        uint256 _H
    ) public pure returns (uint256) {
        if (min4(_A, _B, _C, _D) <= min4(_E, _F, _G, _H)) {
            return min4(_A, _B, _C, _D);
        } else {
            return min4(_E, _F, _G, _H);
        }
    }

    function getStakeInfo(address _staker)
        public
        view
        returns (StakeInfo memory)
    {
        return stakeInfos[_staker];
    }

    function getReferralInfo(address _referrer)
        public
        view
        returns (referralInfo memory)
    {
        return referralInfos[_referrer];
    }

    function getReferralList(address _referrer)
        public
        view
        returns (address[] memory)
    {
        return referralInfos[_referrer].referralList;
    }

    function getReferralsStakeAmount(address _referrer)
        public
        view
        returns (uint256[] memory)
    {
        return referralInfos[_referrer].referralStakeAmount;
    }
}