// TODO: Suggest Ron to set a maximum transaction fee that can be set by the admin. Makes contract more trustable
// TODO: Make AddLiquidity only Ownable
//

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BAM is Ownable, ReentrancyGuard {
    uint256[5] public referralLevelCommission = [
        10 * 100,
        5 * 100,
        3 * 100,
        2 * 100,
        1 * 100
    ];

    /// @notice To check upto what level a user can get referral commisson based on staked amount
    /// @param _amount Staked amount
    /// @return 5  max level eligible for referral
    function maxEligibleLevelForReferralCommission(uint256 _amount)
        private
        pure
        returns (uint256)
    {
        if (_amount < 0.1 * 10**18) return 0;
        else if (_amount < 1 * 10**18) return 1;
        else if (_amount < 5 * 10**18) return 2;
        else if (_amount < 10 * 10**18) return 3;
        else return 4;
    }

    uint256 private constant percentageDivider = 10000;

    uint256 public minimumStakeValue;
    uint256 public maximumStakeValue;
    uint256 public maxStakedBalance;
    uint256 public maximumReturnPercentage;
    uint256 public minimumWithdrawalAmount;
    bool public isActive = true;

    address public nextOwner;

    uint256[] private pauseTime;
    uint256[] private resumeTime;
    // Indirect earnings to be updated as required. They will contribute to total earnings only if eligible
    struct Stake {
        bool isActive;
        bool maxed;
        uint256 stakedAmount; // amount staked
        uint256 activeStake; // amount after fee deduction
        uint256 dailyEarningsBeforeFee; // daily earnings per day -> UPATES TOTAL Earnings
        uint256 dailyEarningsAfterFee; // daily earnings after performance fee deduction -> UPDATES USER BALANCE
        uint256[5] referralEarning; // earnings from referral comissions that has been added to total earnings
        uint256[5] missedReferralEarnings; // referral earnings that has not contributed to total earnings
        uint256 withdrawalCommission;
        uint256[] stakeAmountHistory;
        uint256[] stakeTimeHistory;
        uint256 residualCommissionPerDay; // residual comission per day
        uint256 totalResidualCommission;
        uint256 totalEarnings; // total earnings
        uint256 lastUpdated; // time
        uint256 creationTime;
        uint256 dailyEarningRate;
        uint256 maxReferralLevel;
    }

    struct User {
        bool isRegistered;
        bool isSuspended;
        uint256 balance;
        uint256 withdrawalLimit;
        uint256[] withdrawalrequestedAmount;
        uint256[] withdrawalAmountRecieved;
        uint256[] withdrawalTime;
        Stake activeStake;
        Stake[] previousStakes;
        address referredBy;
        uint256 downlineBalance;
        uint256[5] downlineLevelStakedAmount;
        uint256[5] downlineLevelActiveStakes;
        uint256[5] teamsize;
    }
    struct adminEarnings {
        uint256 teamSize;
        uint256 downlineBalance;
        uint256 totalEarnings;
        uint256 currentBalance;
        // uint256 residualCommissionPerDay;
        uint256 lastUpdated;
        uint256 teamEarnings;
        uint256 depositFees;
        uint256 withdrawFees;
        uint256 referralFees;
        uint256 residualCommissions;
        uint256 performanceFeeCommissions; // From Fee split
        uint256 residualCommissionsPerDay; // from per referee share
        uint256 perFormanceFeeCommissionPerDay;
    }

    struct Fee {
        uint256 fee;
        uint256 adminShare;
        uint256 liquidity;
        uint256 directSponsor;
        uint256 upline;
    }

    Fee public depositFee =
        Fee({
            fee: 1000,
            adminShare: 2500,
            liquidity: 7500,
            directSponsor: 0,
            upline: 0
        });

    Fee public withdrawalFee =
        Fee({
            fee: 1000,
            adminShare: 2500,
            liquidity: 6500,
            directSponsor: 1000,
            upline: 0
        });

    Fee public performanceFee =
        Fee({
            fee: 1000,
            adminShare: 2500,
            liquidity: 6000,
            directSponsor: 0,
            upline: 1500
        });

    Fee public referralCommissionFee =
        Fee({
            fee: 1000,
            adminShare: 2500,
            liquidity: 7500,
            directSponsor: 0,
            upline: 0
        });

    mapping(address => User) userDetails;

    event userRegisterd(address user, address referee);
    event userSuspended(address user);
    event userReinstated(address user);
    event staked(address user, uint256 amount);

    uint256 public totalBNBStaked;
    uint256 public totalBNBWithdrawan;
    uint256 public totalFeePaid;
    uint256 public startTime;
    uint256 public totalMembers;

    uint256 public dailyEarnings_A = 100; // Active Stake <= 100BNB
    uint256 public dailyEarnings_B = 125; //  100 BNB < Active Stake <= 250 BNB
    uint256 public dailyEarnings_C = 150; // 250BNB < Active Stake < 500BNB

    adminEarnings private AdminEarnings;

    constructor() {
        minimumStakeValue = 0.01 * (10**18); // 0.01 BNB
        maximumStakeValue = 500 * (10**18); // 500 BNB
        maxStakedBalance = 500 * (10**18); // 500 BNB
        minimumWithdrawalAmount = 0.01 * (10**18); // 0.01 BNB

        isActive = true;

        userDetails[msg.sender].isRegistered = true;
        AdminEarnings = adminEarnings({
            teamSize: 0,
            downlineBalance: 0,
            totalEarnings: 0,
            currentBalance: 0,
            teamEarnings: 0,
            depositFees: 0,
            withdrawFees: 0,
            referralFees: 0,
            residualCommissions: 0,
            performanceFeeCommissions: 0,
            residualCommissionsPerDay: 0,
            perFormanceFeeCommissionPerDay: 0,
            lastUpdated: block.timestamp
        });
        startTime = block.timestamp;
        maximumReturnPercentage = 25000;
    }

    /// @notice To add additional liquidity to smart contract
    function AddLiquidity() external payable onlyOwner {}

    /// @notice To register new user under a referee
    /// @param _referee -> _referee address
    function registerUser(address _referee) external {
        require(
            userDetails[msg.sender].isRegistered == false,
            "B.A.M:User already registered"
        );
        require(msg.sender != nextOwner, "B.A.M: Cannot register next owner");
        require(msg.sender != owner(), "B.A.M:Cannot register Owner");
        require(
            userDetails[_referee].isRegistered || _referee == owner(),
            "B.A.M:Referee not a registered user"
        );
        require(
            userDetails[_referee].isSuspended == false,
            "B.A.M:Referee is Suspended"
        );
        require(isActive, "B.A.M:Project Paused");

        address origialReferee = _referee;
        userDetails[msg.sender].referredBy = _referee;
        userDetails[msg.sender].isRegistered = true;

        for (uint8 i = 0; i < 5; i++) {
            if (_referee == owner()) {
                AdminEarnings.teamSize++;
                break;
            } else {
                userDetails[_referee].teamsize[i] += 1;
                _referee = userDetails[_referee].referredBy;
            }
        }
        totalMembers += 1;
        emit userRegisterd(msg.sender, origialReferee);
    }

    /// @notice For owner to change deposit fee
    /// @param _fee:  % to deduct from transaction amount * 100
    /// @param _adminShare new admin's share in deducted fee * 100
    /// @param _liquidity new share of fee to be stored in smart contract *100
    function changeDepositFee(
        uint256 _fee,
        uint256 _adminShare,
        uint256 _liquidity
    ) external onlyOwner {
        require(_fee <= 2000, "B.A.M :Fees cannot exceed 20%");
        require(isActive, "B.A.M : Project Paused");
        uint256 total = _adminShare + _liquidity;
        require(total == 10000, "B.A.M : Incorrect Distribution");
        depositFee.fee = _fee * 100;
        depositFee.adminShare = _adminShare;
        depositFee.liquidity = _liquidity;
    }

    /// @notice For owner to change withdrawal fee
    /// @param _fee:  % to deduct from transaction amount
    /// @param _adminShare admin's share in deducted fee * 100
    /// @param _liquidity share of fee to be stored in smart contract *100
    /// @param _directSponsor share of fee to be sent to direct sponsor * 100
    function changeWithdrawalFee(
        uint256 _fee,
        uint256 _adminShare,
        uint256 _liquidity,
        uint256 _directSponsor
    ) external onlyOwner {
        require(_fee <= 2000, "B.A.M :Fees cannot exceed 20%");

        require(isActive, "B.A.M:Project Paused");

        uint256 total = _adminShare + _liquidity + _directSponsor;
        require(total == 10000, "B.A.M:Incorrect Distribution");
        withdrawalFee.fee = _fee;
        withdrawalFee.adminShare = _adminShare;
        withdrawalFee.liquidity = _liquidity;
        withdrawalFee.directSponsor = _directSponsor;
    }

    /// @notice For owner to change Performance fee
    /// @param _fee:  % to deduct from transaction amount * 100
    /// @param _adminShare admin's share in deducted fee * 100
    /// @param _liquidity share of fee to be stored in smart contract * 100
    /// @param _upline share of fee to be shared with upper levels * 100
    function changePerformanceFee(
        uint256 _fee,
        uint256 _adminShare,
        uint256 _liquidity,
        uint256 _upline
    ) external onlyOwner {
        require(_fee <= 2000, "B.A.M :Fees cannot exceed 20%");

        require(isActive, "B.A.M:Project Paused");

        require(
            _adminShare + _liquidity + _upline == 10000,
            "B.A.M:Incorrect Distribution"
        );
        performanceFee.fee = _fee;
        performanceFee.adminShare = _adminShare;
        performanceFee.liquidity = _liquidity;
        performanceFee.upline = _upline;
    }

    /// @notice For owner to change Referral Commission fee
    /// @param _fee:  % to deduct from transaction amount * 100
    /// @param _adminShare admin's share in deducted fee * 100
    /// @param _liquidity share of fee to be stored in smart contract * 100
    function changeReferralCommissionFee(
        uint256 _fee,
        uint256 _adminShare,
        uint256 _liquidity
    ) external onlyOwner {
        require(_fee <= 2000, "B.A.M :Fees cannot exceed 20%");

        require(isActive, "B.A.M:Project Paused");
        require(
            _adminShare + _liquidity == 10000,
            "B.A.M:Incorrect Distribution"
        );
        referralCommissionFee.fee = _fee;
        referralCommissionFee.adminShare = _adminShare;
        referralCommissionFee.liquidity = _liquidity;
    }

    /// @notice For owner to change daily earnings rate for :
    /// @param _rate_A:  new daily earnings percentage * 100 | Active Stake <= 100BNB
    /// @param _rate_B:  new daily earnings percentage * 100 | 100 BNB < Active Stake <= 250 BNB
    /// @param _rate_C:  new daily earnings percentage * 100 | 250BNB < Active Stake < 500BNB
    function ChangeEarningsRate(
        uint256 _rate_A,
        uint256 _rate_B,
        uint256 _rate_C
    ) external onlyOwner {
        require(_rate_A > 0, "B.A.M: Earning rate cannot be zero");
        require(_rate_B > 0, "B.A.M: Earning rate cannot be zero");
        require(_rate_C > 0, "B.A.M: Earning rate cannot be zero");

        require(isActive, "B.A.M:Project Paused");
        dailyEarnings_A = _rate_A;
        dailyEarnings_B = _rate_B;
        dailyEarnings_C = _rate_C;
    }

    /// @notice To change minimum staking amount
    /// @param _minStake - new minimum stake.
    function ChangeMinStake(uint256 _minStake) external onlyOwner {
        require(isActive, "B.A.M:Project Paused");
        minimumStakeValue = _minStake;
    }

    /// @notice To change maximum staking amount
    /// @param _maxStake - new maximum stake.
    function ChangeMaxStake(uint256 _maxStake) external onlyOwner {
        require(isActive, "B.A.M:Project Paused");
        maximumStakeValue = _maxStake;
    }

    function getEarningsRate(uint256 _amount) public view returns (uint256) {
        if (_amount <= 100 * (10**18)) {
            return dailyEarnings_A;
        } else if (_amount <= 250 * (10**18)) {
            return dailyEarnings_B;
        } else return dailyEarnings_C;
    }

    /// @notice To check if a user's active stake has reached it's theshold.
    /// @dev Presence of active stake must be checked before calling this function | Upadate earnings must be called before using this function
    /// @param _user address of user
    function checkBreakThrough(address _user) private {
        if (!isActive) return;

        if (userDetails[_user].activeStake.totalEarnings >= maxReturn(_user)) {
            uint256 activeStake = userDetails[_user].activeStake.activeStake;
            uint256 dailyEarnings = (getEarningsRate(activeStake) *
                activeStake) / percentageDivider;
            uint256 feeOnDailyEarnings = (performanceFee.fee * dailyEarnings) /
                percentageDivider;
            uint256 adminShare = (feeOnDailyEarnings *
                performanceFee.adminShare) / percentageDivider;
            uint256 uplineShare = (feeOnDailyEarnings * performanceFee.upline) /
                percentageDivider;
            updateAdminEarnings();
            AdminEarnings.perFormanceFeeCommissionPerDay = (
                AdminEarnings.perFormanceFeeCommissionPerDay < adminShare
                    ? 0
                    : AdminEarnings.perFormanceFeeCommissionPerDay - adminShare
            );
            uint256 perRefereeShare = uplineShare / 5;

            address referee = userDetails[_user].referredBy;
            for (uint8 i = 0; i < 5; i++) {
                if (referee == owner()) {
                    AdminEarnings.residualCommissionsPerDay = (
                        AdminEarnings.residualCommissionsPerDay <
                            perRefereeShare
                            ? 0
                            : AdminEarnings.residualCommissionsPerDay -
                                perRefereeShare
                    );

                    AdminEarnings.downlineBalance = (AdminEarnings
                        .downlineBalance >
                        userDetails[_user].activeStake.activeStake)
                        ? (AdminEarnings.downlineBalance -
                            userDetails[_user].activeStake.activeStake)
                        : 0;
                } else {
                    updateUserEarnings(referee);

                    userDetails[referee].downlineBalance = (userDetails[referee]
                        .downlineBalance >
                        userDetails[_user].activeStake.activeStake)
                        ? (userDetails[referee].downlineBalance -
                            userDetails[_user].activeStake.activeStake)
                        : 0;

                        userDetails[referee].downlineLevelStakedAmount[i] = (userDetails[referee].downlineLevelStakedAmount[i] >
                        userDetails[_user].activeStake.stakedAmount)
                        ? ( userDetails[referee].downlineLevelStakedAmount[i] -
                             userDetails[_user].activeStake.stakedAmount)
                        : 0;

                        userDetails[referee].downlineLevelActiveStakes[i] = (userDetails[referee].downlineLevelActiveStakes[i] >
                        userDetails[_user].activeStake.activeStake)
                        ? ( userDetails[referee].downlineLevelActiveStakes[i] -
                             userDetails[_user].activeStake.activeStake)
                        : 0;

                    if (
                        userDetails[referee].activeStake.isActive &&
                        !userDetails[referee].activeStake.maxed
                    ) {
                        userDetails[referee]
                            .activeStake
                            .residualCommissionPerDay = (
                            userDetails[referee]
                                .activeStake
                                .residualCommissionPerDay < perRefereeShare
                                ? 0
                                : userDetails[referee]
                                    .activeStake
                                    .residualCommissionPerDay - perRefereeShare
                        );
                    }
                }
                referee = userDetails[_user].referredBy;
            }

            userDetails[_user].activeStake.maxed = true;

            userDetails[_user].previousStakes.push(
                userDetails[_user].activeStake
            );
        }
    }

    /// @notice To deduct Deposit Fees
    /// @param _amount transaction amount
    /// @return amountAfterDeduction amount after deducting Fees
    function deductDepositFee(uint256 _amount) private returns (uint256) {
        uint256 fee = (_amount * depositFee.fee) / (percentageDivider);
        uint256 amountAfterDeduction = _amount - fee;

        uint256 adminShare = (fee * depositFee.adminShare) /
            (percentageDivider);

        totalFeePaid += fee;
        // No need to transfer liquidity share
        AdminEarnings.currentBalance += adminShare;
        AdminEarnings.totalEarnings += adminShare;
        AdminEarnings.depositFees += adminShare;

        return amountAfterDeduction;
    }

    /// @notice To deduct Performance Fees
    /// @param _amount transaction amount
    /// @param _user user's address
    /// @return amountAfterDeduction amount after deducting Fees
    function deductPerformanceFee(uint256 _amount, address _user)
        private
        returns (uint256)
    {
        uint256 fee = (_amount * performanceFee.fee) / (percentageDivider);
        uint256 amountAfterDeduction = _amount - fee;

        uint256 adminShare = (fee * performanceFee.adminShare) /
            (percentageDivider);

        uint256 uplineShare = (fee * performanceFee.upline) /
            (percentageDivider);

        uint256 perRefereeShare = uplineShare / 5;

        address referee = userDetails[_user].referredBy;

        AdminEarnings.perFormanceFeeCommissionPerDay += adminShare;

        for (uint8 i = 0; i < 5; i++) {
            if (referee == owner()) {
                AdminEarnings.residualCommissionsPerDay += perRefereeShare;
                break;
            } else if (
                userDetails[referee].activeStake.isActive &&
                !userDetails[referee].activeStake.maxed
            ) {
                if (userDetails[referee].isSuspended) {
                    continue;
                }
                userDetails[referee]
                    .activeStake
                    .residualCommissionPerDay += perRefereeShare;
            }
            referee = userDetails[_user].referredBy;
        }

        totalFeePaid += fee;

        return amountAfterDeduction;
    }

    /// @notice To deduct Referral Fees
    /// @param _amount transaction amount
    /// @return amountAfterDeduction amount after deducting Fees
    function deductReferralFee(uint256 _amount) private returns (uint256) {
        uint256 fee = (_amount * referralCommissionFee.fee) /
            (percentageDivider);

        uint256 amountAfterDeduction = _amount - fee;

        uint256 adminShare = (fee * referralCommissionFee.adminShare) /
            (percentageDivider);

        AdminEarnings.currentBalance += adminShare;
        AdminEarnings.totalEarnings += adminShare;
        AdminEarnings.referralFees += adminShare;

        totalFeePaid += fee;

        return amountAfterDeduction;
    }

    /// @notice Deducts Anti-whale Tax
    /// @param _amount Transaction amount
    /// @return amountAfterDeduction Amount after tax deduction
    function AntiWhaleTax(uint256 _amount) public view returns (uint256) {
        uint256 contractCurrentBalance = address(this).balance;

        uint256 relativePercentage = (_amount * 100) / (contractCurrentBalance);

        if (relativePercentage > 10) relativePercentage = 10;

        uint256 taxPercentage = 5 * relativePercentage * 100;

        uint256 tax = (_amount * taxPercentage) / percentageDivider;

        return tax;
    }

    /// @notice To deduct withdrawal Fees
    /// @param _amount transaction amount
    /// @param _user user's address
    /// @return amountAfterDeduction amount after deducting Fees
    function deductWithdrawalFees(uint256 _amount, address _user)
        private
        returns (uint256)
    {
        uint256 fee = (_amount * withdrawalFee.fee) / percentageDivider;
        uint256 amountAfterDeduction = _amount - fee;

        uint256 adminShare = (fee * withdrawalFee.adminShare) /
            percentageDivider;

        uint256 directSponsorShare = (fee * withdrawalFee.directSponsor) /
            percentageDivider;

        address directSponsor = userDetails[_user].referredBy;

        AdminEarnings.currentBalance += adminShare;
        AdminEarnings.totalEarnings += adminShare;
        AdminEarnings.withdrawFees += adminShare;

        if (directSponsor == owner()) {
            AdminEarnings.currentBalance += directSponsorShare;
            AdminEarnings.totalEarnings += directSponsorShare;
            AdminEarnings.teamEarnings += directSponsorShare;
        } else {
            updateUserEarnings(directSponsor);
            if (
                userDetails[directSponsor].activeStake.isActive &&
                !userDetails[directSponsor].activeStake.maxed
            ) {
                uint256 maxAmountToAdd = maxReturn(directSponsor) -
                    userDetails[directSponsor].activeStake.totalEarnings;

                uint256 amountToAdd = min(directSponsorShare, maxAmountToAdd);

                userDetails[directSponsor]
                    .activeStake
                    .withdrawalCommission += amountToAdd;

                userDetails[directSponsor]
                    .activeStake
                    .totalEarnings += amountToAdd;

                userDetails[directSponsor].balance += amountToAdd;

                checkBreakThrough(directSponsor);
            }
        }

        uint256 AntiWhaleTaxAmount = AntiWhaleTax(amountAfterDeduction);
        amountAfterDeduction -= AntiWhaleTaxAmount;

        totalFeePaid += (fee + AntiWhaleTaxAmount);

        return amountAfterDeduction;
    }

    /// @notice To add a referee's referral commissions
    /// @param _amount referral commission amount
    /// @param _referee referee address
    function addReferralCommissionToReferee(
        uint256 _amount,
        address _referee,
        uint256 _referralLevel
    ) private {
        if (_referee == owner()) {
            AdminEarnings.totalEarnings += _amount;
            AdminEarnings.currentBalance += _amount;
            AdminEarnings.teamEarnings += _amount;
        } else if (
            userDetails[_referee].activeStake.isActive &&
            !userDetails[_referee].activeStake.maxed
        ) {
            // No update if referee is suspended

            if (userDetails[_referee].isSuspended) {
                return;
            }

            uint256 maxAmountToAddBeforeFee = maxReturn(_referee) -
                userDetails[_referee].activeStake.totalEarnings;

            uint256 amountToAddBeforeFee = min(
                _amount,
                maxAmountToAddBeforeFee
            );

            uint256 maxEligibleLevel = maxEligibleLevelForReferralCommission(
                userDetails[_referee].activeStake.activeStake
            );

            if (maxEligibleLevel >= _referralLevel) {
                uint256 amountToAddAfterFee = deductReferralFee(
                    amountToAddBeforeFee
                );

                userDetails[_referee].activeStake.referralEarning[
                        _referralLevel
                    ] += amountToAddBeforeFee;

                userDetails[_referee]
                    .activeStake
                    .totalEarnings += amountToAddBeforeFee;

                userDetails[_referee].balance += amountToAddAfterFee;

                checkBreakThrough(_referee);
            } else {
                userDetails[_referee].activeStake.missedReferralEarnings[
                        _referralLevel
                    ] += amountToAddBeforeFee;
            }
        }
    }

    /// @notice To distribute referral commissions whenever a user stakes
    /// @param _amount Transaction Amount
    /// @param _user Staker's address
    function distributeReferralCommissions(uint256 _amount, address _user)
        private
    {
        address _referee = userDetails[_user].referredBy;
        for (uint8 i = 0; i < 5; i++) {
            uint256 referralCommission = (referralLevelCommission[i] *
                _amount) / (percentageDivider);
            addReferralCommissionToReferee(referralCommission, _referee, i);
            if (_referee == owner()) {
                break;
            }
            _referee = userDetails[_referee].referredBy;
        }
    }

    /// @notice To stake BNB
    /// @dev Checks for presence of active stake. If present adds BNB to it, else creates a new stake.
    function stakeBNB() external payable {
        require(
            msg.sender != owner() && msg.sender != nextOwner,
            "B.A.M:Owner cannot stake"
        );
        require(
            userDetails[msg.sender].isRegistered,
            "B.A.M:Unregistered user"
        );
        require(!userDetails[msg.sender].isSuspended, "B.A.M:User suspended");

        require(
            msg.value >= minimumStakeValue,
            "B.A.M:Amount less than minimun required"
        );

        require(
            msg.value <= maximumStakeValue,
            "B.A.M:Amount exceeds maximum allowed"
        );

        require(isActive, "B.A.M:Project paused");
        if (
            !userDetails[msg.sender].activeStake.isActive ||
            userDetails[msg.sender].activeStake.maxed
        ) {
            // No Active Stake Present

            Stake memory newStake;

            newStake.isActive = true;
            newStake.maxed = false;
            newStake.stakedAmount = 0;
            newStake.activeStake = 0;
            newStake.dailyEarningsBeforeFee = 0;
            newStake.dailyEarningsAfterFee = 0;
            delete newStake.referralEarning;
            delete newStake.missedReferralEarnings;
            delete newStake.stakeTimeHistory;
            delete newStake.stakeAmountHistory;

            newStake.withdrawalCommission = 0;
            newStake.residualCommissionPerDay = 0;
            newStake.totalResidualCommission = 0;
            newStake.totalEarnings = 0;
            newStake.lastUpdated = block.timestamp;
            newStake.creationTime = block.timestamp;
            newStake.dailyEarningRate = 0;
            newStake.maxReferralLevel = 0;

            userDetails[msg.sender].withdrawalLimit = 0;

            userDetails[msg.sender].activeStake = newStake;
        }

        uint256 amount = msg.value;

        uint256 currentStake = userDetails[msg.sender].activeStake.stakedAmount;
        require(
            currentStake + msg.value <= maxStakedBalance,
            "B.A.M:Total Stake exceeds maximum allowed"
        );

        // Previous stake present
        if (userDetails[msg.sender].activeStake.lastUpdated < block.timestamp) {
            updateUserEarnings(msg.sender);
        }

        address referee = userDetails[msg.sender].referredBy;

        uint256 amountAfterDeduction = deductDepositFee(amount);

        // update earnings for all referee to handle performance commission, referral commission
        for (uint8 i = 0; i < 5; i++) {
            {
                if (referee == owner()) {
                    AdminEarnings.downlineBalance += amountAfterDeduction;
                    updateAdminEarnings();
                    break;
                } else {
                    userDetails[referee]
                        .downlineBalance += amountAfterDeduction;

                    userDetails[referee].downlineLevelActiveStakes[
                            i
                        ] += amountAfterDeduction;

                    userDetails[referee].downlineLevelStakedAmount[i] += amount;

                    if (
                        userDetails[referee].activeStake.isActive &&
                        !userDetails[referee].activeStake.maxed
                    ) {
                        updateUserEarnings(referee);
                    }
                    referee = userDetails[referee].referredBy;
                }
            }
        }

        uint256 newStakeAmount = amountAfterDeduction +
            userDetails[msg.sender].activeStake.activeStake;

        uint256 newEarningsRate = getEarningsRate(newStakeAmount);

        uint256 newDailyEarningsBeforeFee = (newStakeAmount * newEarningsRate) /
            percentageDivider;

        uint256 previousDailyEarnings = userDetails[msg.sender]
            .activeStake
            .dailyEarningsBeforeFee;

        uint256 additionalDailyEarnings = newDailyEarningsBeforeFee -
            previousDailyEarnings;

        // Update Residual commissions
        deductPerformanceFee(additionalDailyEarnings, msg.sender);

        uint256 newDailyEarningsAfterFee = newDailyEarningsBeforeFee -
            ((newDailyEarningsBeforeFee * performanceFee.fee) /
                (percentageDivider));

        // Update Referral Commissions
        distributeReferralCommissions(amountAfterDeduction, msg.sender);

        userDetails[msg.sender].activeStake.stakedAmount += msg.value;
        userDetails[msg.sender].activeStake.activeStake += amountAfterDeduction;
        userDetails[msg.sender]
            .activeStake
            .dailyEarningsBeforeFee = newDailyEarningsBeforeFee;
        userDetails[msg.sender]
            .activeStake
            .dailyEarningsAfterFee = newDailyEarningsAfterFee;

        userDetails[msg.sender]
            .activeStake
            .maxReferralLevel = maxEligibleLevelForReferralCommission(
            userDetails[msg.sender].activeStake.activeStake
        );

        userDetails[msg.sender].activeStake.dailyEarningRate = getEarningsRate(
            userDetails[msg.sender].activeStake.stakedAmount
        );

        userDetails[msg.sender].activeStake.stakeAmountHistory.push(
            amountAfterDeduction
        );
        userDetails[msg.sender].activeStake.stakeTimeHistory.push(
            block.timestamp
        );
        userDetails[msg.sender].withdrawalLimit += msg.value;

        totalBNBStaked += amountAfterDeduction;

        emit staked(msg.sender, msg.value);
    }

    /// @notice For admin to suspend a user. A suspended user will not have any earnings after suspension.
    /// @param _user address of user to be suspended
    function suspendUser(address _user) external onlyOwner {
        require(isActive, "B.A.M:Project Paused");

        require(userDetails[_user].isRegistered, "B.A.M:Unregistered user");
        require(
            !userDetails[_user].isSuspended,
            "B.A.M:User already suspended"
        );

        updateUserEarnings(_user);
        userDetails[_user].isSuspended = true;
        emit userSuspended(_user);
    }

    /// @notice For admin to re-instate a suspended user. User will start recieving all earnings now.
    /// @param _user address of user to be suspended
    function reinstateUser(address _user) external onlyOwner {
        require(isActive, "B.A.M:Project Paused");
        require(userDetails[_user].isRegistered, "B.A.M:User not registered");
        require(userDetails[_user].isSuspended, "B.A.M:User already active");

        userDetails[_user].isSuspended = false;
        if (userDetails[_user].activeStake.isActive) {
            userDetails[_user].activeStake.lastUpdated = block.timestamp;
        }
        emit userReinstated(_user);
    }

    ///@notice To update user's earnings via private calls
    ///@dev presense of active stake should be checked before calling this function
    function updateUserEarnings(address _user) private {
        if (userDetails[_user].isSuspended) return;
        if (!isActive) return;

        if (userDetails[_user].activeStake.lastUpdated < block.timestamp) {
            if (userDetails[_user].activeStake.isActive) {
                uint256 timePassed;
                uint256 lastUpdated = userDetails[_user]
                    .activeStake
                    .lastUpdated;
                uint256 pauseTimeLength = pauseTime.length;

                if (pauseTimeLength > 0) {
                    for (uint256 i = 0; i < pauseTimeLength; i++) {
                        if (lastUpdated < pauseTime[i]) {
                            timePassed = pauseTime[i] - lastUpdated;
                            lastUpdated = resumeTime[i];
                        }
                    }
                }

                timePassed += block.timestamp - lastUpdated;

                uint256 perDayEarnings = userDetails[_user]
                    .activeStake
                    .dailyEarningsBeforeFee;

                uint256 earningPerSecond = perDayEarnings / 1 days;

                if (userDetails[_user].downlineBalance > 100 * 10**18) {
                    uint256 residualCommissionPerSecond = (
                        userDetails[_user].activeStake.residualCommissionPerDay
                    ) / 1 days;
                    earningPerSecond += residualCommissionPerSecond;
                }

                uint256 earnings = (earningPerSecond * timePassed);

                uint256 earningsAfterFee = earnings -
                    (earnings * performanceFee.fee) /
                    percentageDivider;

                userDetails[_user].activeStake.totalResidualCommission +=
                    ((userDetails[_user].activeStake.residualCommissionPerDay) /
                        1 days) *
                    timePassed;

                uint256 maxAmountToAdd = maxReturn(_user) -
                    userDetails[_user].activeStake.totalEarnings;
                uint256 amountToAdd = min(earnings, maxAmountToAdd);

                uint256 amountToAddAfterFee = min(
                    earningsAfterFee,
                    maxAmountToAdd
                );
                userDetails[_user].activeStake.totalEarnings += amountToAdd;

                userDetails[_user].balance += amountToAddAfterFee;

                userDetails[_user].activeStake.lastUpdated = block.timestamp;

                checkBreakThrough(_user);
            }
        }
    }

    ///@notice To see user's maximum return
    ///@dev presense of active stake should be checked before calling this function
    ///@param _user user's address
    function maxReturn(address _user) private view returns (uint256) {
        return
            (userDetails[_user].activeStake.stakedAmount *
                maximumReturnPercentage) / percentageDivider;
    }

    /// @notice To update Admins Earnings
    function updateAdminEarnings() private {
        uint256 lastUpdated = AdminEarnings.lastUpdated;

        if (lastUpdated < block.timestamp) {
            uint256 timePassed;
            uint256 pauseTimeLength = pauseTime.length;

            if (pauseTimeLength > 0) {
                for (uint256 i = 0; i < pauseTimeLength; i++) {
                    if (lastUpdated < pauseTime[i]) {
                        timePassed = pauseTime[i] - lastUpdated;
                        lastUpdated = resumeTime[i];
                    }
                }
            }

            timePassed += block.timestamp - lastUpdated;

            // uint256 daysPassed = timePassed / (1 days);
            uint256 perFormanceFeeCommissionPerSecond = AdminEarnings
                .perFormanceFeeCommissionPerDay / 1 days;
            uint256 residualCommissionPerSecond = 0;

            if (AdminEarnings.downlineBalance >= 100 * 10**18) {
                residualCommissionPerSecond = (AdminEarnings
                    .residualCommissionsPerDay / 1 days);
            }
            uint256 amountToAdd = ((perFormanceFeeCommissionPerSecond +
                residualCommissionPerSecond) * timePassed);

            AdminEarnings.residualCommissions += (residualCommissionPerSecond *
                timePassed);
            AdminEarnings
                .performanceFeeCommissions += (perFormanceFeeCommissionPerSecond *
                timePassed);
            AdminEarnings.totalEarnings += amountToAdd;
            AdminEarnings.currentBalance += amountToAdd;
            AdminEarnings.lastUpdated = block.timestamp;
        }
    }

    /// @notice To see Admins Total Earnings
    function viewAdminEarnings() public view returns (adminEarnings memory) {
        adminEarnings memory tempAdmin = AdminEarnings;

        uint256 lastUpdated = AdminEarnings.lastUpdated;

        if (lastUpdated < block.timestamp) {
            uint256 timePassed;
            uint256 pauseTimeLength = pauseTime.length;

            if (pauseTimeLength > 0) {
                for (uint256 i = 0; i < pauseTimeLength; i++) {
                    if (lastUpdated < pauseTime[i]) {
                        timePassed = pauseTime[i] - lastUpdated;
                        lastUpdated = resumeTime[i];
                    }
                }
            }

            timePassed += block.timestamp - lastUpdated;

            // uint256 daysPassed = timePassed / (1 days);
            uint256 perFormanceFeeCommissionPerSecond = AdminEarnings
                .perFormanceFeeCommissionPerDay / 1 days;
            uint256 residualCommissionPerSecond = 0;

            if (tempAdmin.downlineBalance >= 100 * 10**18) {
                residualCommissionPerSecond = (tempAdmin
                    .residualCommissionsPerDay / 1 days);
            }
            uint256 amountToAdd = ((perFormanceFeeCommissionPerSecond +
                residualCommissionPerSecond) * timePassed);

            tempAdmin.residualCommissions += (residualCommissionPerSecond *
                timePassed);
            tempAdmin
                .performanceFeeCommissions += (perFormanceFeeCommissionPerSecond *
                timePassed);

            tempAdmin.totalEarnings += amountToAdd;
            tempAdmin.currentBalance += amountToAdd;
            tempAdmin.lastUpdated = block.timestamp;
        }
        return tempAdmin;
    }

    /// @notice For Admin to withdraw their earnings
    /// @param _amount amount to withdraw
    function WithdrawAdminEarnings(uint256 _amount)
        external
        onlyOwner
        nonReentrant
    {
        require(isActive, "B.A.M:Project Paused");
        updateAdminEarnings();
        require(
            AdminEarnings.currentBalance >= _amount,
            "B.A.M:Not enough admin earnings"
        );

        AdminEarnings.currentBalance -= _amount;
        (bool sent, ) = payable(owner()).call{value: _amount}("");

        totalBNBWithdrawan += _amount;

        require(sent, "B.A.M:Failed to send BNB");
    }

    /// @notice To check amount user can withdraw considering 24 hour withdrawal limit
    /// @param _user user's address
    /// @return amount that can be withdrawan
    function maxAllowedWithdrawal(address _user) public view returns (uint256) {
        if (!isActive) return 0;

        if (userDetails[_user].isSuspended) return 0;

        uint256 _24HourWithdrawals;
        uint256 userWithdrawalLimit = userDetails[_user].withdrawalLimit;
        uint256[] memory withdrawals = userDetails[_user]
            .withdrawalrequestedAmount;
        uint256[] memory withdrawalTime = userDetails[_user].withdrawalTime;
        if (withdrawals.length == 0) {
            return userWithdrawalLimit;
        }
        for (uint256 i = withdrawals.length; i > 0; i--) {
            if (withdrawalTime[i - 1] > (block.timestamp - 1 days)) {
                _24HourWithdrawals += withdrawals[i - 1];
                if (_24HourWithdrawals >= userWithdrawalLimit) {
                    break;
                }
            } else {
                break;
            }
        }

        if (_24HourWithdrawals >= userWithdrawalLimit) {
            return 0;
        }
        unchecked {
            return userWithdrawalLimit - _24HourWithdrawals;
        }
    }

    /// @notice For users to withdraw their earnings
    /// @param _amount amount to withdraw
    function withdrawEarnings(uint256 _amount) external nonReentrant {
        require(
            _amount > minimumWithdrawalAmount,
            "B.A.M:Amount less than minimum allowed withdrawal"
        );

        require(msg.sender != owner(), "B.A.M:Not for owner");
        require(isActive, "B.A.M:Project paused");

        require(
            userDetails[msg.sender].isRegistered,
            "B.A.M:Unregistered user"
        );
        require(!userDetails[msg.sender].isSuspended, "B.A.M:User Suspended");
        updateUserEarnings(msg.sender);
        require(
            _amount <= userDetails[msg.sender].balance,
            "B.A.M:Not enough earnings"
        );
        require(
            _amount <= address(this).balance,
            "B.A.M:Insufficient funds,Contact Admin"
        );

        require(
            _amount <= maxAllowedWithdrawal(msg.sender),
            "B.A.M:24 hour withdrawal limit exceeded"
        );

        uint256 amountAfterDeduction = deductWithdrawalFees(
            _amount,
            msg.sender
        );

        userDetails[msg.sender].withdrawalrequestedAmount.push(_amount);
        userDetails[msg.sender].withdrawalAmountRecieved.push(
            amountAfterDeduction
        );
        userDetails[msg.sender].withdrawalTime.push(block.timestamp);
        userDetails[msg.sender].balance -= _amount;

        (bool sent, ) = payable(msg.sender).call{value: amountAfterDeduction}(
            ""
        );

        totalBNBWithdrawan += _amount;
        require(sent, "B.A.M:Failed to send BNB");
    }

    /// @notice Overridding transferOwnership
    /// @param _newOwner _newOwner's address
    function transferOwnership(address _newOwner)
        public
        virtual
        override(Ownable)
        onlyOwner
    {
        require(
            _newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        require(isActive, "B.A.M:Project Paused");
        require(!userDetails[_newOwner].isRegistered, "B.A.M:Invalid user");
        require(nextOwner != owner(), "B.A.M:Next owner same as current owner");
        nextOwner = _newOwner;
    }

    /// @notice For new owner to accept ownership
    function acceptOwnerShip() external {
        require(msg.sender == nextOwner, "B.A.M:Not next owner");
        _transferOwnership(nextOwner);
        nextOwner = address(0);
    }

    /// @notice For Owner to pause contracts functionality
    function pauseContract() external onlyOwner {
        require(isActive == true, "B.A.M:Contract already paused");
        isActive = false;
        pauseTime.push(block.timestamp);
    }

    /// @notice For Owner to resume contracts functionality
    function resumeContract() external onlyOwner {
        require(isActive == false, "B.A.M:Contract already active");
        isActive = true;
        resumeTime.push(block.timestamp);
    }

    /// @notice To view details about a user's active stake
    /// @param _user user's address
    /// @return user's current active stake details
    function viewUserStake(address _user) external view returns (Stake memory) {
        Stake memory userStake;
        if (
            !userDetails[_user].activeStake.isActive ||
            userDetails[_user].isSuspended
        ) {
            return userStake;
        }
        userStake = userDetails[_user].activeStake;

        uint256 timePassed;
        uint256 lastUpdated = userDetails[_user].activeStake.lastUpdated;
        uint256 pauseTimeLength = pauseTime.length;

        if (pauseTimeLength > 0) {
            for (uint256 i = 0; i < pauseTimeLength; i++) {
                if (lastUpdated < pauseTime[i]) {
                    timePassed = pauseTime[i] - lastUpdated;
                    lastUpdated = resumeTime[i];
                }
            }
        }

        timePassed += block.timestamp - lastUpdated;
        // uint256 daysPassed = timePassed / (1 days);

        uint256 perDayEarnings = userDetails[_user]
            .activeStake
            .dailyEarningsBeforeFee;

        uint256 earningPerSecond = perDayEarnings / 1 days;

        if (userDetails[_user].downlineBalance > 100 * 10**18) {
            uint256 residualCommissionPerSecond = (
                userDetails[_user].activeStake.residualCommissionPerDay
            ) / 1 days;
            earningPerSecond += residualCommissionPerSecond;
        }

        uint256 earnings = (earningPerSecond * timePassed);

        uint256 maxAmountToAdd = maxReturn(_user) -
            userDetails[_user].activeStake.totalEarnings;
        uint256 amountToAdd = min(earnings, maxAmountToAdd);

        userStake.totalResidualCommission +=
            ((userDetails[_user].activeStake.residualCommissionPerDay) /
                1 days) *
            timePassed;

        userStake.totalEarnings += amountToAdd;
        userStake.lastUpdated += block.timestamp;
        return userStake;
    }

    function viewUserDetails(address _user)
        external
        view
        returns (User memory)
    {
        return userDetails[_user];
    }

    /// @notice To view details about a user's active balance
    /// @param _user user's address
    /// @return user's current balance
    function viewUserBalance(address _user) public view returns (uint256) {
        Stake memory userStake;
        uint256 amountToAdd;
        userStake = userDetails[_user].activeStake;

        if (userStake.isActive) {
            uint256 timePassed;
            uint256 lastUpdated = userDetails[_user].activeStake.lastUpdated;
            uint256 pauseTimeLength = pauseTime.length;

            if (pauseTimeLength > 0) {
                for (uint256 i = 0; i < pauseTimeLength; i++) {
                    if (lastUpdated < pauseTime[i]) {
                        timePassed = pauseTime[i] - lastUpdated;
                        lastUpdated = resumeTime[i];
                    }
                }
            }

            timePassed += block.timestamp - lastUpdated;

            // uint256 daysPassed = timePassed / (1 days);

            uint256 earningsPerSecond = userDetails[_user]
                .activeStake
                .dailyEarningsAfterFee / 1 days;

            if (userDetails[_user].downlineBalance > 100 * 10**18) {
                uint256 residualCommissionPerSecond = (
                    userDetails[_user].activeStake.residualCommissionPerDay
                ) / 1 days;
                earningsPerSecond += residualCommissionPerSecond;
            }

            uint256 earnings = (earningsPerSecond * timePassed);

            uint256 maxAmountToAdd = maxReturn(_user) -
                userDetails[_user].activeStake.totalEarnings;
            amountToAdd = min(earnings, maxAmountToAdd);
        }

        uint256 userBalance = userDetails[_user].balance;

        userBalance += amountToAdd;

        return userBalance;
    }

    /// @notice To view a user's team size
    /// @param _user user's address
    /// @return userDetails[_user].teamsize
    function seeTeamSize(address _user)
        external
        view
        returns (uint256[5] memory)
    {
        uint256[5] memory teamsize = userDetails[_user].teamsize;
        return teamsize;
    }

    /// @notice To view a user registrations status
    /// @param _user user's address
    function checkUserRegistry(address _user) external view returns (bool) {
        return userDetails[_user].isRegistered;
    }

    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // utility function
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a <= b ? a : b;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}