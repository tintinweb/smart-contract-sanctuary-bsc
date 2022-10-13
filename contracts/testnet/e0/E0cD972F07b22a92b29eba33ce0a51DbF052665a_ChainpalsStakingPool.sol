// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./library/SafeBEP20.sol";
import "./utils/DateTime.sol";
import "./owner/Ownable.sol";
import "./utils/ReentrancyGuard.sol";

contract ChainpalsStakingPool is Ownable, DateTime, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Staking status : Active or not
    bool public stakingStatus = true;

    // Emergency withdrawal : Active or not
    bool public openForEmergencyWithdrawal = false;

    // Staked tokens
    uint256 public currentStakedLP = 0;

    // Claimed tokens
    uint256 public totalClaimedTokens = 0;

    // Redemption fee token holder
    address public redemptionFeesHolder;

    // Chainpals platform wallet
    address public chainpalsPlatformWallet;

    // The reward token
    IBEP20 public rewardToken;

    // The staked token
    IBEP20 public lpToken;

    // Early redemption fees percentages
    uint256 public earlyRedemptionFeesPercentage;

    // Current running round
    uint256 public latestRound;

    // subPool details
    uint256[] subPoolStakingDays = [7776000, 15552000, 31104000];

    uint256 public day = 86400; // day in seconds

    struct TransactionInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 claimedRewards; // Reward claimed for the transaction
        uint256 stakedDate; // Staking date
        uint256 stakingEndDate; // Staking end date
        uint256 stakedRound; // Round number in which user has staked tokens
    }

    struct UserInfo {
        uint256 totalStaked; // How many staked tokens the user has provided
        uint256 totalClaimed; // How many tokens the user has claimed
        uint256 totalTransactions; // How many time user has staked into the pool
        mapping(uint256 => TransactionInfo) transactions; // Record of every staking
    }

    // Info of each user that stakes tokens (lpToken)
    mapping(address => UserInfo) private userInfo;

    struct RoundDetails {
        uint256 roundStartDate; // start date of the month
        uint256 totalTokensToDistribute; // How many reward tokens are allocated for monthly profit distribution
        uint256 totalClaimed; // How many tokens the users have claimed
        uint256 totalStakedLPs; // How many LP tokens are staked into the pool
    }

    // Info of each profit rounds
    mapping(uint256 => RoundDetails) private rounds;

    struct RewardClaimedDetails {
        uint256 claimedTokens; // Number of tokens claimed for a round
        uint256 claimDate; // Claimed date
    }
    // Claimed reward details
    mapping(address => mapping(uint256 => mapping(uint256 => RewardClaimedDetails)))
        public claimedRewardDetails;

    // Reward history response json
    struct RewardsHistory {
        uint256 tokens; // Tokens available to claim or claimed in round
        uint256 roundId; // Round id
        uint256 month; // Month in which round had taken place
        uint256 claimedDate; // Claimed date if rewards are already claimed
        bool claimedStatus; // Reward claim status
    }

    struct LatestRoundData {
        uint256 tokensAvailableToClaim; // Tokens available to claim in latest round
        uint256 roundNumber; // Round number
        bool rewardsClaimed; // Rewards are claimed for round or not
    }

    // Transaction record response json
    struct TransactionRecord {
        TransactionInfo transactionInfo;
        LatestRoundData latestRoundData; // Latest round data
        RewardsHistory[] rewardsHistory; // Reward history
    }

    // Validate the rewards are claimed or not
    mapping(address => mapping(uint256 => mapping(uint256 => bool)))
        public claimed;

    event AdminTokenRecovery(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);
    event EmergencyWithdraw(
        IBEP20 _tokenAddress,
        address indexed user,
        uint256 amount
    );
    event NewEarlyRedemptionFeesPercentage(
        uint256 earlyRedemptionFeesPercentage
    );
    event Withdraw(address indexed user, uint256 amount);
    event RewardHolderChange(
        address indexed previousHolder,
        address indexed newHolder
    );
    event StakingStatusChange(bool _status);
    event EmergencyWithdrawalStatusChange(bool _status);
    event ProfitPoolRoundDetails(address indexed user, uint256 _value);

    // Validate staking pool status
    modifier stakingActive() {
        require(stakingStatus == true, "Staking is paused!");
        _;
    }

    // Validate round details update rights
    modifier canAddRoundDetails() {
        require(
            msg.sender == chainpalsPlatformWallet || msg.sender == owner(),
            "Caller cannot add round details"
        );
        _;
    }

    /**
     * @notice Initialize the contract
     * @param _coOwnerAddress Co-Owner address of the contract
     * @param _lpToken: staked token address
     * @param _rewardToken: reward token address
     * @param _redemptionFeesHolder: redemption fee token holder address
     * @param _earlyRedemptionFeesPercentage: early redemption fees in 2 decimal form
     * @param _numberOfRewardTokens : total number of reward tokens for 1st round
     * @param _roundStartDate : Round  start date for the first month
     */

    constructor(
        address _coOwnerAddress,
        IBEP20 _lpToken,
        IBEP20 _rewardToken,
        address _redemptionFeesHolder,
        address _chainpalsPlatformWallet,
        uint256 _earlyRedemptionFeesPercentage,
        uint256 _numberOfRewardTokens,
        uint256 _roundStartDate
    ) public {
        require(
            _coOwnerAddress != address(0),
            "Co-Owner address is zero address"
        );
        require(
            address(_lpToken) != address(0),
            "LP Token address is zero address"
        );
        require(
            address(_rewardToken) != address(0),
            "Reward token address is zero address"
        );
        require(
            _redemptionFeesHolder != address(0),
            "Fees holder wallet address is zero address"
        );
        require(
            _chainpalsPlatformWallet != address(0),
            "Platform wallet address is zero address"
        );
        require(
            _earlyRedemptionFeesPercentage != 0,
            "Fees percentage value should not be zero"
        );
        require(
            _numberOfRewardTokens != 0,
            "Reward token count value should not be zero"
        );
        require(
            _roundStartDate != 0,
            "Round start date value should not be zero"
        );

        _co_owner = _coOwnerAddress;
        lpToken = _lpToken;
        rewardToken = _rewardToken;
        chainpalsPlatformWallet = _chainpalsPlatformWallet;
        redemptionFeesHolder = _redemptionFeesHolder;
        earlyRedemptionFeesPercentage = _earlyRedemptionFeesPercentage;

        // Add 1st round details
        RoundDetails storage round = rounds[latestRound];
        round.totalTokensToDistribute = _numberOfRewardTokens;
        round.roundStartDate = _roundStartDate;
    }

    /**
     * @notice Deposit staked tokens
     * @param _amount: amount to deposit (in lpToken)
     * @param _subPoolId: id of sub-pool to determine staking days
     */
    function deposit(uint256 _amount, uint256 _subPoolId)
        external
        stakingActive
        nonReentrant
        returns (bool)
    {
        require(_amount != 0, "Staking amount should not be zero");
        require(_subPoolId < subPoolStakingDays.length, "Wrong sub-pool id.");
        require(openForEmergencyWithdrawal == false, "Can not deposit funds.");

        UserInfo storage user = userInfo[msg.sender];
        RoundDetails storage round = rounds[latestRound];

        user.transactions[user.totalTransactions].amount = user
            .transactions[user.totalTransactions]
            .amount
            .add(_amount);
        lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        // user details
        user.transactions[user.totalTransactions].stakedRound = latestRound;
        user.transactions[user.totalTransactions].stakedDate = block.timestamp;
        user.transactions[user.totalTransactions].stakingEndDate = block
            .timestamp
            .add(subPoolStakingDays[_subPoolId]);
        currentStakedLP = currentStakedLP.add(_amount);
        round.totalStakedLPs = round.totalStakedLPs.add(_amount);

        user.totalStaked = user.totalStaked.add(_amount);
        user.totalTransactions = user.totalTransactions.add(1);
        emit Deposit(msg.sender, _amount);
        return true;
    }

    /**
     * @notice Collect reward tokens (if any)
     * @param _transactionId: transaction id
     */
    function claimRewardsForRecentRound(uint256 _transactionId)
        external
        stakingActive
        nonReentrant
        returns (bool)
    {
        (bool response, uint8 monthDays) = areRewardsAvailable();
        require(response == true, "Rewards are not available at present.");
        uint256 previousRound = latestRound.sub(1);
        require(
            claimed[msg.sender][_transactionId][previousRound] == false,
            "Rewards are claimed."
        );
        UserInfo storage user = userInfo[msg.sender];
        RoundDetails storage round = rounds[previousRound];

        require(
            user.transactions[_transactionId].amount != 0,
            "Not enough staked tokens"
        );

        uint256 pending = user
            .transactions[_transactionId]
            .amount
            .mul(round.totalTokensToDistribute)
            .div(round.totalStakedLPs);

        uint256 totalRewards = calculateRewards(
            user.transactions[_transactionId].stakedDate,
            monthDays,
            pending
        );

        require(
            rewardToken.balanceOf(address(this)) >= totalRewards,
            "Not enough reward tokens"
        );
        claimed[msg.sender][_transactionId][previousRound] = true;
        claimedRewardDetails[msg.sender][_transactionId][
            previousRound
        ] = RewardClaimedDetails(totalRewards, block.timestamp);
        user.transactions[_transactionId].claimedRewards = user
            .transactions[_transactionId]
            .claimedRewards
            .add(totalRewards);
        user.totalClaimed = user.totalClaimed.add(totalRewards);
        round.totalClaimed = round.totalClaimed.add(totalRewards);
        totalClaimedTokens = totalClaimedTokens.add(totalRewards);
        rewardToken.safeTransfer(address(msg.sender), totalRewards);
        emit RewardsClaimed(msg.sender, totalRewards);
        return true;
    }

    /**
     * @notice Collect reward tokens of previous rounds (if any)
     * @param _transactionId: transaction id
     * @param _roundId : round id
     */
    function claimRewardsForPreviousRound(
        uint256 _transactionId,
        uint256 _roundId
    ) external nonReentrant returns (bool) {
        uint256 previousRound = latestRound.sub(1);
        require(
            _roundId <= previousRound,
            "Cannot claim rewards from given round"
        );
        require(
            claimed[msg.sender][_transactionId][_roundId] == false,
            "Rewards are claimed."
        );
        UserInfo storage user = userInfo[msg.sender];
        RoundDetails storage round = rounds[_roundId];

        require(
            user.transactions[_transactionId].amount != 0,
            "Not enough staked tokens"
        );

        uint256 pending = user
            .transactions[_transactionId]
            .amount
            .mul(round.totalTokensToDistribute)
            .div(round.totalStakedLPs);

        uint256 totalRewards = calculateRewardsForPreviousRound(
            user.transactions[_transactionId].stakedDate,
            round.roundStartDate,
            pending
        );

        require(
            rewardToken.balanceOf(address(this)) >= totalRewards,
            "Not enough reward tokens"
        );
        claimed[msg.sender][_transactionId][_roundId] = true;
        claimedRewardDetails[msg.sender][_transactionId][
            _roundId
        ] = RewardClaimedDetails(totalRewards, block.timestamp);
        user.transactions[_transactionId].claimedRewards = user
            .transactions[_transactionId]
            .claimedRewards
            .add(totalRewards);
        user.totalClaimed = user.totalClaimed.add(totalRewards);
        round.totalClaimed = round.totalClaimed.add(totalRewards);
        totalClaimedTokens = totalClaimedTokens.add(totalRewards);
        rewardToken.safeTransfer(address(msg.sender), totalRewards);
        emit RewardsClaimed(msg.sender, totalRewards);

        return true;
    }

    /**
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in lpToken)
     * @param _transactionId: transaction id
     */
    function withdraw(uint256 _amount, uint256 _transactionId)
        external
        stakingActive
        nonReentrant
        returns (bool)
    {
        UserInfo storage user = userInfo[msg.sender];
        require(
            user.transactions[_transactionId].amount >= _amount,
            "Withdrawal amount is higher than staked amount"
        );
        uint256 previousRound = latestRound.sub(1);
        RoundDetails storage round = rounds[previousRound];
        // To maintain if user unstacks
        RoundDetails storage latestRoundDetails = rounds[latestRound];
        (bool response, uint8 monthDays) = areRewardsAvailable();

        uint256 totalRewards = 0;

        if (response) {
            if (claimed[msg.sender][_transactionId][previousRound] == false) {
                uint256 pending = user
                    .transactions[_transactionId]
                    .amount
                    .mul(round.totalTokensToDistribute)
                    .div(round.totalStakedLPs);
                totalRewards = calculateRewards(
                    user.transactions[_transactionId].stakedDate,
                    monthDays,
                    pending
                );

                if (rewardToken.balanceOf(address(this)) >= totalRewards) {
                    rewardToken.safeTransfer(address(msg.sender), totalRewards);
                    claimed[msg.sender][_transactionId][previousRound] = true;
                    claimedRewardDetails[msg.sender][_transactionId][
                        previousRound
                    ] = RewardClaimedDetails(totalRewards, block.timestamp);
                }
            }
        }

        if (
            _amount > 0 &&
            block.timestamp > user.transactions[_transactionId].stakingEndDate
        ) {
            user.transactions[_transactionId].amount = user
                .transactions[_transactionId]
                .amount
                .sub(_amount);
            lpToken.safeTransfer(address(msg.sender), _amount);
        } else {
            user.transactions[_transactionId].amount = user
                .transactions[_transactionId]
                .amount
                .sub(_amount);
            lpToken.safeTransfer(
                address(msg.sender),
                _amount
                    .mul(uint256(10000).sub(earlyRedemptionFeesPercentage))
                    .div(10000)
            );
            lpToken.safeTransfer(
                address(redemptionFeesHolder),
                _amount.mul(earlyRedemptionFeesPercentage).div(10000)
            );
        }

        user.transactions[_transactionId].claimedRewards = user
            .transactions[_transactionId]
            .claimedRewards
            .add(totalRewards);
        user.totalClaimed = user.totalClaimed.add(totalRewards);
        user.totalStaked = user.totalStaked.sub(_amount);
        // adding claimed rewards count in previous round
        round.totalClaimed = round.totalClaimed.add(totalRewards);
        // Deducting staked lps from latest round because new round has been started
        latestRoundDetails.totalStakedLPs = latestRoundDetails
            .totalStakedLPs
            .sub(_amount);
        totalClaimedTokens = totalClaimedTokens.add(totalRewards);
        currentStakedLP = currentStakedLP.sub(_amount);
        emit Withdraw(msg.sender, _amount);
        return true;
    }

    /**
     * @notice Withdraw reward tokens
     * @dev Only callable by owner. Needs to be for emergency.
     * @param _amount : number of tokens owner wants to withdraw
     */
    function emergencyRewardWithdraw(uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        require(_amount != 0, "Amount should not be zero");
        rewardToken.safeTransfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(rewardToken, msg.sender, _amount);
        return true;
    }

    /**
     * @notice Withdraw staked tokens
     * @dev In case of any issue or attack user can withdraw their investment if owner has lift every conditions
     */
    function emergencyStakedTokenWithdrawal()
        external
        nonReentrant
        returns (bool)
    {
        require(openForEmergencyWithdrawal == true, "Can not withdraw funds.");
        UserInfo storage user = userInfo[msg.sender];
        lpToken.safeTransfer(address(msg.sender), user.totalStaked);
        emit EmergencyWithdraw(lpToken, msg.sender, user.totalStaked);
        return true;
    }

    /**
     * @notice Using this owner can set new fees holding wallet
     * @dev Changes Redemption fee token holder of the contract to a new holder by contract owner only.
     * @param _address : public address of new fees holder
     */
    function changeRedemptionFeesHolder(address _address)
        public
        onlyOwner
        returns (bool)
    {
        require(
            _address != address(0),
            "Holder: new holder is the zero address"
        );

        redemptionFeesHolder = _address;
        emit RewardHolderChange(redemptionFeesHolder, _address);
        return true;
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @dev This function is only callable by admin.
     * @param _tokenAddress: the address of the token to withdraw
     */
    function recoverWrongTokens(address _tokenAddress)
        external
        onlyOwner
        returns (bool)
    {
        require(_tokenAddress != address(0), "Cannot be zero address");
        require(_tokenAddress != address(lpToken), "Cannot be staked token");

        uint256 _tokenAmount = IBEP20(_tokenAddress).balanceOf(address(this));
        IBEP20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
        return true;
    }

    /**
     * @notice Update early redemption fees
     * @dev Only callable by owner.
     * @param _earlyRedemptionFeesPercentage: updated redemption fees(2 decimals e.g 10000 => 100%)
     */
    function updateEarlyRedemptionFeesPercentage(
        uint256 _earlyRedemptionFeesPercentage
    ) external onlyOwner returns (bool) {
        require(
            _earlyRedemptionFeesPercentage != 0,
            "Early redemption fees should be non zero positive value"
        );
        earlyRedemptionFeesPercentage = _earlyRedemptionFeesPercentage;
        emit NewEarlyRedemptionFeesPercentage(_earlyRedemptionFeesPercentage);
        return true;
    }

    /**
     * @notice Update staking token address
     * @dev Only callable by owner.
     * @param _lpToken: new staking token address
     */
    function updateStakingTokenAddress(IBEP20 _lpToken)
        external
        onlyOwner
        returns (bool)
    {
        require(
            address(_lpToken) != address(0),
            "LP token address should not be a zero address"
        );
        lpToken = _lpToken;
        return true;
    }

    /**
     * @notice Update new reward token address
     * @dev Only callable by owner.
     * @param _rewardToken: reward token address
     */
    function updateRewardTokenAddress(IBEP20 _rewardToken)
        external
        onlyOwner
        returns (bool)
    {
        require(
            address(_rewardToken) != address(0),
            "Reward token address should not be a zero address"
        );
        rewardToken = _rewardToken;
        return true;
    }

    /**
     * @notice Update new platform wallet address
     * @dev Only callable by owner.
     * @param _chainpalsPlatformWallet: platform wallet address
     */
    function updatePlatformWalletAddress(address _chainpalsPlatformWallet)
        external
        onlyOwner
        returns (bool)
    {
        require(
            address(_chainpalsPlatformWallet) != address(0),
            "Platform wallet address should not be a zero address"
        );
        chainpalsPlatformWallet = _chainpalsPlatformWallet;
        return true;
    }

    /**
     * @notice Update staking status : Running or Stop
     * @dev Only callable by owner.
     * @param _value: _value can be true/false
     */
    function updateStakingStatus(bool _value)
        external
        onlyOwner
        returns (bool)
    {
        stakingStatus = _value;
        emit StakingStatusChange(_value);
        return true;
    }

    /**
     * @notice Update emergency withdrawal status : available or not
     * @dev Only callable by owner.
     * @param _value: _value should be true
     */
    function updateEmergencyWithdrawalStatus(bool _value)
        external
        onlyOwner
        returns (bool)
    {
        require(
            openForEmergencyWithdrawal == false,
            "Emergency withdrawal is open."
        );
        openForEmergencyWithdrawal = _value;
        emit EmergencyWithdrawalStatusChange(_value);
        return true;
    }

    /**
     * @notice Add round details
     * @dev Only callable by platform wallet or owner.
     * @param _value: _value is total rewards to distributes in next month
     * @param _roundStartDate : round start date
     */
    function addRoundDetails(uint256 _value, uint256 _roundStartDate)
        external
        canAddRoundDetails
        returns (bool)
    {
        require(_value != 0, "Value should not be zero.");
        require(_roundStartDate != 0, "Start date should not be zero.");
        latestRound = latestRound.add(1);
        RoundDetails storage round = rounds[latestRound];
        round.totalTokensToDistribute = _value;
        round.totalStakedLPs = currentStakedLP;
        round.roundStartDate = _roundStartDate;
        emit ProfitPoolRoundDetails(msg.sender, _value);
        return true;
    }

    /**
     * @notice Update round details
     * @dev Only callable by platform wallet or owner.
     * @param _value: _value is total rewards to distributes
     * @param _roundId: Id of the round which values wants to update
     * @param _roundStartDate : round start date
     */
    function updateRoundDetails(
        uint256 _value,
        uint256 _roundId,
        uint256 _roundStartDate
    ) external canAddRoundDetails returns (bool) {
        require(_roundStartDate != 0, "Start date should not be zero.");
        require(_value != 0, "Value should not be zero.");
        require(_roundId <= latestRound, "Wrong round Id");
        RoundDetails storage round = rounds[_roundId];
        round.totalTokensToDistribute = _value;
        round.roundStartDate = _roundStartDate;
        emit ProfitPoolRoundDetails(msg.sender, _value);
        return true;
    }

    /**
     * @notice function to get user's staking data
     * @param _user: public address of user
     *
     * return values
     * @return totalStaked : total staked token count
     * @return totalClaimed : total claimed rewards count
     * @return totalTransactions : user's total transactions
     **/

    function getUserDetails(address _user)
        external
        view
        returns (
            uint256 totalStaked,
            uint256 totalClaimed,
            uint256 totalTransactions
        )
    {
        UserInfo storage user = userInfo[_user];
        totalStaked = user.totalStaked;
        totalClaimed = user.totalClaimed;
        totalTransactions = user.totalTransactions;
    }

    /**
     * @notice function to get user's transaction details
     * @param _user : public address of user
     * @param _transactionIndex : Index of the transaction record
     *
     **/

    function getUserTransactionDetails(address _user, uint256 _transactionIndex)
        external
        view
        returns (TransactionInfo memory)
    {
        UserInfo storage user = userInfo[_user];

        return user.transactions[_transactionIndex];
    }

    /**
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @param _transactionId: transaction id
     * @return Pending reward for a given user
     */
    function pendingReward(address _user, uint256 _transactionId)
        external
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[_user];
        RoundDetails memory round;
        (bool response, uint8 monthDays) = areRewardsAvailable();

        if (response == false) {
            round = rounds[latestRound];
        } else if (response == true && latestRound != 0) {
            uint256 previousRound = latestRound.sub(1);
            round = rounds[previousRound];
        } else if (response == true && latestRound == 0) {
            uint256 previousRound = latestRound;
            round = rounds[previousRound];
        }

        uint256 pending = user
            .transactions[_transactionId]
            .amount
            .mul(round.totalTokensToDistribute)
            .div(round.totalStakedLPs);

        uint256 totalRewards = calculateRewards(
            user.transactions[_transactionId].stakedDate,
            monthDays,
            pending
        );

        return totalRewards;
    }

    /**
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @param _transactionId: transaction id
     * @param _roundId round id
     * @return Pending reward for a given user
     */
    function pendingRewardForPreviousRound(
        address _user,
        uint256 _transactionId,
        uint256 _roundId
    ) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        RoundDetails memory round = rounds[_roundId];

        uint256 pending = user
            .transactions[_transactionId]
            .amount
            .mul(round.totalTokensToDistribute)
            .div(round.totalStakedLPs);

        uint256 totalRewards = calculateRewardsForPreviousRound(
            user.transactions[_transactionId].stakedDate,
            round.roundStartDate,
            pending
        );

        return totalRewards;
    }

    /**
     * @notice Get round details
     * @dev To fetch round details to display on frontend.
     * @param _roundId: _roundId of the round of which details wants
     * @return Object containing round details
     */
    function getRoundDetails(uint256 _roundId)
        external
        view
        returns (RoundDetails memory)
    {
        return rounds[_roundId];
    }

    /**
     * @notice This function will return currently rewards are available to claim of not along with month days count
     * @return Status of claiming available or not
     * @return Days count of month
     */
    function areRewardsAvailable() public view returns (bool, uint8) {
        uint16 year = getYear(block.timestamp);
        uint8 month = getMonth(block.timestamp);
        uint8 previousMonth;
        if (month == 1) {
            previousMonth = 12;
        } else {
            previousMonth = month - 1;
        }
        uint8 daysInPreviousMonth = getDaysInMonth(previousMonth, year);
        uint8 currentDay = getDay(block.timestamp);
        if (currentDay == 1) {
            return (true, daysInPreviousMonth);
        } else {
            return (false, daysInPreviousMonth);
        }
    }

    /**
     * @notice View function to get all transaction details
     * @param _user: user address
     * @return TransactionRecord[] transactions records
     */
    function getTransactionsRecord(address _user)
        external
        view
        returns (TransactionRecord[] memory)
    {
        UserInfo storage user = userInfo[_user];
        TransactionRecord[] memory transactionRecords = new TransactionRecord[](
            user.totalTransactions
        );

        for (uint256 i = 0; i < user.totalTransactions; i++) {
            // User transaction details
            TransactionInfo memory transactionInfo = this
                .getUserTransactionDetails(_user, i);
            // User rewards history
            RewardsHistory[]
                memory transactionRewardsHistory = getRewardHistoryForUser(
                    _user,
                    i
                );
            (bool response, ) = areRewardsAvailable();
            // current running round
            uint256 currentRound = latestRound;
            if (response) {
                currentRound -= 1;
            }

            uint256 pendingRewardsForRound = this.pendingReward(_user, i);
            bool rewardClaimStatus = claimed[_user][i][currentRound];
            LatestRoundData memory latestRoundData = LatestRoundData(
                pendingRewardsForRound,
                currentRound,
                rewardClaimStatus
            );
            TransactionRecord memory transactionRecord;
            transactionRecord.transactionInfo = transactionInfo;
            transactionRecord.latestRoundData = latestRoundData;
            transactionRecord.rewardsHistory = transactionRewardsHistory;

            transactionRecords[i] = transactionRecord;
        }
        return transactionRecords;
    }

    /**
     * @notice View function to get past reward history.
     * @param _user: user address
     * @param _transactionId: transaction id
     * @return RewardsHistory[] reward history for a given user
     */
    function getRewardHistoryForUser(address _user, uint256 _transactionId)
        internal
        view
        returns (RewardsHistory[] memory)
    {
        UserInfo storage user = userInfo[_user];
        uint256 stakedRound = user.transactions[_transactionId].stakedRound;

        (bool response, ) = areRewardsAvailable();
        // current running round
        uint256 currentRound = latestRound;
        if (response) {
            currentRound -= 1;
        }

        RewardsHistory[] memory rewardHistory = new RewardsHistory[](
            currentRound - stakedRound
        );

        for (uint256 i = stakedRound; i < currentRound; i++) {
            RoundDetails memory round = rounds[i];
            uint256 roundTokens = this.pendingRewardForPreviousRound(
                _user,
                _transactionId,
                i
            );
            uint256 roundMonth = getMonth(round.roundStartDate);
            RewardsHistory memory rewardRecord;
            rewardRecord.tokens = roundTokens;
            rewardRecord.roundId = i;
            rewardRecord.month = roundMonth;
            rewardRecord.claimedDate = claimedRewardDetails[_user][
                _transactionId
            ][i].claimDate;
            rewardRecord.claimedStatus = claimed[_user][_transactionId][i];

            rewardHistory[i] = rewardRecord;
        }
        return rewardHistory;
    }

    /**
     * @notice Calculate claimable rewards of staked tokens
     * @param _stakingDate: date when staking happened
     * @param _monthDays: number of days in staked month(in form of seconds)
     * @param _monthlyReward: user's monthly rewards if user has staked for whole month
     */
    function calculateRewards(
        uint256 _stakingDate,
        uint256 _monthDays,
        uint256 _monthlyReward
    ) internal view returns (uint256) {
        uint256 stakedTime = block.timestamp.sub(_stakingDate);
        if (_monthDays.mul(day) <= stakedTime) {
            return _monthlyReward;
        } else {
            return stakedTime.mul(_monthlyReward).div(_monthDays.mul(day));
        }
    }

    /**
     * @notice Calculate claimable rewards of staked tokens
     * @param _stakingDate: date when staking happened
     * @param _roundStartDate: round start date in timestamp
     * @param _monthlyReward: user's monthly rewards if user has staked for whole month
     */
    function calculateRewardsForPreviousRound(
        uint256 _stakingDate,
        uint256 _roundStartDate,
        uint256 _monthlyReward
    ) internal view returns (uint256) {
        uint16 year = getYear(_roundStartDate);
        uint8 month = getMonth(_roundStartDate);
        uint256 daysInMonth = getDaysInMonth(month, year);

        uint256 roundEndDate = _roundStartDate.add(daysInMonth.mul(day));

        if (_stakingDate <= roundEndDate && _stakingDate > _roundStartDate) {
            return
                roundEndDate.sub(_stakingDate).mul(_monthlyReward).div(
                    daysInMonth.mul(day)
                );
        } else if (_stakingDate <= _roundStartDate) {
            return _monthlyReward;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./SafeMath.sol";
import "./Address.sol";
import "../interfaces/IBEP20.sol";

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

contract DateTime {
    /*
     *  Date and Time utilities for ethereum contracts
     *
     */
    struct _DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
        uint8 second;
        uint8 weekday;
    }

    uint256 constant DAY_IN_SECONDS = 86400;
    uint256 constant YEAR_IN_SECONDS = 31536000;
    uint256 constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint256 constant HOUR_IN_SECONDS = 3600;
    uint256 constant MINUTE_IN_SECONDS = 60;

    uint16 constant ORIGIN_YEAR = 1970;

    function isLeapYear(uint16 year) internal pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function leapYearsBefore(uint256 year) internal pure returns (uint256) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year)
        internal
        pure
        returns (uint8)
    {
        if (
            month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12
        ) {
            return 31;
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        } else if (isLeapYear(year)) {
            return 29;
        } else {
            return 28;
        }
    }

    function parseTimestamp(uint256 timestamp)
        internal
        pure
        returns (_DateTime memory dt)
    {
        uint256 secondsAccountedFor = 0;
        uint256 buf;
        uint8 i;

        // Year
        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

        // Month
        uint256 secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                dt.month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }

        // Day
        for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                dt.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }

        // Hour
        dt.hour = getHour(timestamp);

        // Minute
        dt.minute = getMinute(timestamp);

        // Second
        dt.second = getSecond(timestamp);

        // Day of week.
        dt.weekday = getWeekday(timestamp);
    }

    function getYear(uint256 timestamp) internal pure returns (uint16) {
        uint256 secondsAccountedFor = 0;
        uint16 year;
        uint256 numLeapYears;

        // Year
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor +=
            YEAR_IN_SECONDS *
            (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            } else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function getMonth(uint256 timestamp) internal pure returns (uint8) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint256 timestamp) internal pure returns (uint8) {
        return parseTimestamp(timestamp).day;
    }

    function getHour(uint256 timestamp) internal pure returns (uint8) {
        return uint8((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint256 timestamp) internal pure returns (uint8) {
        return uint8((timestamp / 60) % 60);
    }

    function getSecond(uint256 timestamp) internal pure returns (uint8) {
        return uint8(timestamp % 60);
    }

    function getWeekday(uint256 timestamp) internal pure returns (uint8) {
        return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day
    ) internal pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, 0, 0, 0);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour
    ) internal pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, hour, 0, 0);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour,
        uint8 minute
    ) internal pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, hour, minute, 0);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour,
        uint8 minute,
        uint8 second
    ) internal pure returns (uint256 timestamp) {
        uint16 i;

        // Year
        for (i = ORIGIN_YEAR; i < year; i++) {
            if (isLeapYear(i)) {
                timestamp += LEAP_YEAR_IN_SECONDS;
            } else {
                timestamp += YEAR_IN_SECONDS;
            }
        }

        // Month
        uint8[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(year)) {
            monthDayCounts[1] = 29;
        } else {
            monthDayCounts[1] = 28;
        }
        monthDayCounts[2] = 31;
        monthDayCounts[3] = 30;
        monthDayCounts[4] = 31;
        monthDayCounts[5] = 30;
        monthDayCounts[6] = 31;
        monthDayCounts[7] = 31;
        monthDayCounts[8] = 30;
        monthDayCounts[9] = 31;
        monthDayCounts[10] = 30;
        monthDayCounts[11] = 31;

        for (i = 1; i < month; i++) {
            timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
        }

        // Day
        timestamp += DAY_IN_SECONDS * (day - 1);

        // Hour
        timestamp += HOUR_IN_SECONDS * (hour);

        // Minute
        timestamp += MINUTE_IN_SECONDS * (minute);

        // Second
        timestamp += second;

        return timestamp;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./../utils/Context.sol";

contract Ownable is Context {
    address private _owner;
    address internal _co_owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event CoOwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function coOwner() public view returns (address) {
        return _co_owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owners.
     */
    modifier onlyOwners() {
        require(
            _owner == _msgSender() || _co_owner == _msgSender(),
            "Ownable: caller is not the owner"
        );
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers co-ownership of the contract to a new account (`newOwner`).
     */
    function transferCoOwnership(address newCoOwner) public onlyOwners {
        require(
            newCoOwner != address(0),
            "Ownable: new co-owner is the zero address"
        );
        emit CoOwnershipTransferred(_co_owner, newCoOwner);
        _co_owner = newCoOwner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwners {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

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

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0;

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}