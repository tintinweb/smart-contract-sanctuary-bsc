//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";
import "./ReentrantGuard.sol";

interface IHarvester {
    function harvest() external;
}

/**
    Betswirl Staking Contract
    Stake BETS-LP To Earn Reward Tokens From The Games
    Developed by dappd.net
 */
contract BetswirlStaking is Ownable, IERC20, ReentrancyGuard {

    // constants
    uint256 private constant precision = 10**36;
    uint256 private constant BOUNTY_DENOM = 10**5;
    uint256 public constant minLockTimeMultiplier = 10*6;

    // name and symbol for tokenized contract
    string private constant _name = "PCS BETS-BNB";
    string private constant _symbol = "xBETS";
    uint8 private immutable _decimals;

    // maximum lock time in blocks
    uint256 public maxLockTime;
    uint256 public minLockTime;
    uint256 public maxLockTimeMultiplier = 4 * minLockTimeMultiplier;

    // Staking Token
    address public immutable token;

    // Reward Harvester
    address public harvester;

    // Reward Token Information
    struct RewardToken {
        bool isRewardToken;
        uint256 dividendsPerPoint;
        uint256 totalRewardsAccrued;
        mapping(address => uint256) totalExcluded;
    }
    mapping(address => RewardToken) public rewardTokens;
    address[] public allRewardTokens;

    // Lock Info
    struct LockInfo {
        uint256 lockAmount;
        uint256 unlockBlock;
        uint256 rewardPointsAssigned;
        uint256 index;
        address locker;
    }

    // Nonce For Lock Info
    uint256 public lockInfoNonce;

    // Nonce => LockInfo
    mapping(uint256 => LockInfo) public lockInfo;

    // User Info
    struct UserInfo {
        bool optedOutOfAirdrop;
        uint256 totalAmountStaked;
        uint256 rewardPoints;
        uint256[] lockIds;
        uint256 index;
        mapping(address => uint256) totalRewardsClaimed;
    }

    // Address => UserInfo
    mapping(address => UserInfo) public userInfo;

    // list of all users for airdrop functionality
    address[] public allUsers;

    // Tracks Dividends
    uint256 public totalStaked;
    uint256 public totalRewardPoints;

    // airdrop index
    uint256 private airdropIndex;

    // claim bounty
    uint256 public bounty = 20; // 0.2%

    // Emergency Withdraw Enabled
    bool public emergencyWithdrawEnabled = false;

    // Events
    event SetHarvester(address newHarvester);
    event SetMaxLockTime(uint256 newMaxLockTime);
    event SetMinLockTime(uint256 newMinLockTime);
    event SetMaxLockTimeMultiplier(uint256 newMaxLockTimeMultiplier);
    event EmergencyWithdrawEnabled();

    constructor(
        address token_,
        uint256 minLockTime_, 
        uint256 maxLockTime_
    ) {
        require(token_ != address(0), "Zero Address");
        require(
            minLockTime_ < maxLockTime_,
            "Min Lock Time Must Not Exceed Max Lock Time"
        );

        // initialize immutable variables
        token = token_;
        _decimals = IERC20(token_).decimals();

        // initialize starting lock times
        minLockTime = minLockTime_;
        maxLockTime = maxLockTime_;

        // init token on block explorer
        emit Transfer(address(0), msg.sender, 0);
    }

    /** Returns the total number of tokens in existence */
    function totalSupply() external view override returns (uint256) {
        return totalStaked;
    }

    /** Returns the number of tokens owned by `account` */
    function balanceOf(address account) public view override returns (uint256) {
        return userInfo[account].totalAmountStaked;
    }

    /** Returns the number of tokens `spender` can transfer from `holder` */
    function allowance(address, address)
        external
        pure
        override
        returns (uint256)
    {
        return 0;
    }

    /** Token Name */
    function name() public pure override returns (string memory) {
        return _name;
    }

    /** Token Ticker Symbol */
    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    /** Tokens decimals */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /** Approves `spender` to transfer `amount` tokens from caller */
    function approve(address spender, uint256) public override returns (bool) {
        emit Approval(msg.sender, spender, 0);
        return true;
    }

    /** Transfer Function */
    function transfer(address recipient, uint256)
        external
        override
        nonReentrant
        returns (bool)
    {
        _claimReward(msg.sender, false);
        emit Transfer(msg.sender, recipient, 0);
        return true;
    }

    /** Transfer Function */
    function transferFrom(
        address,
        address recipient,
        uint256
    ) external override nonReentrant returns (bool) {
        _claimReward(msg.sender, false);
        emit Transfer(msg.sender, recipient, 0);
        return true;
    }

    ///////////////////////////////////////////
    ////////      OWNER FUNCTIONS     /////////
    ///////////////////////////////////////////

    /**
        Sets The Minimum Allowed Lock Time That Users Can Stake 
        Requirements:
            - newMinLockTime must be less than the maxLockTime
     */
    function setMinLockTime(uint256 newMinLockTime) external onlyOwner {
        require(
            newMinLockTime < maxLockTime,
            "Min Lock Time Cannot Exceed Max Lock Time"
        );
        minLockTime = newMinLockTime;
        emit SetMinLockTime(newMinLockTime);
    }

    /**
        Sets The Maximum Allowed Lock Time That Users Can Stake 
        Requirements:
            - newMaxLockTime must be greater than the minLockTime
     */
    function setMaxLockTime(uint256 newMaxLockTime) external onlyOwner {
        require(
            newMaxLockTime > minLockTime,
            "Max Lock Time Must Exceed Min Lock Time"
        );
        maxLockTime = newMaxLockTime;
        emit SetMaxLockTime(newMaxLockTime);
    }

    /**
        Sets The Multiplier For Maximum Lock Time
        A Multiplier Of 4 * 10^18 Would Make A Max Lock Time Stake
        Gain 4x The Rewards Of A Min Lock Time Stake For The Same Amount Of Tokens Staked
        Requirements:
            - newMaxLockTimeMultiplier MUST Be Greater Than Or Equal To 10^18
     */
    function setMaxLockTimeMultiplier(uint256 newMaxLockTimeMultiplier)
        external
        onlyOwner
    {
        require(
            newMaxLockTimeMultiplier >= minLockTimeMultiplier,
            "Max Lock Time Multiplier Too Small"
        );
        maxLockTimeMultiplier = newMaxLockTimeMultiplier;
        emit SetMaxLockTimeMultiplier(newMaxLockTimeMultiplier);
    }

    /**
        Sets The Harvester Smart Contract Through Which Rewards Are Fetched
     */
    function setHarvester(address newHarvester) external onlyOwner {
        require(newHarvester != address(0), "Zero Address");
        harvester = newHarvester;
        emit SetHarvester(newHarvester);
    }

    /**
        Withdraws Any Token That Is Not A BETS-LP Token
        NOTE: Withdrawing Reward Tokens Will Mess Up The Math Associated With Rewarding
              The Contract will still function as desired, but the last users to claim
              Will not receive their full amount, or any, of the reward token
     */
    function withdrawForeignToken(address token_) external onlyOwner {
        require(token != token_, "Cannot Withdraw Staked Token");
        _send(token_, msg.sender, balanceOfToken(token_));
    }

    /**
        Withdraws The Native Chain Token To Owner's Address
     */
    function withdrawNative() external onlyOwner {
        (bool s, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(s, "Failure To Withdraw Native");
    }

    /**
        Adds A Reward Token To The Staking Contract
        NOTE: Do Not Add A Reward Token That Had Previously Been Removed
            - Doing So Will Mess Up The Math Associated With The Reward Metrics
            - If This Is A Must, Implement A Wrapper Contract Around The Reward Token
              That Will Send The Token To The User On Transfer (Not transferFrom)
              However it is done, ensure a new contract address is added
     */
    function addRewardToken(address rewardToken_) external onlyOwner {
        require(
            rewardTokens[rewardToken_].isRewardToken == false,
            "Already Reward Token"
        );
        require(rewardToken_ != address(0), "Zero Address");
        rewardTokens[rewardToken_].isRewardToken = true;
        allRewardTokens.push(rewardToken_);
    }

    /**
        Removes A Reward Token From The Staking Contract
        Removed Reward Tokens Should Not Be Re-Added
        If Required, Add A Wrapper Token Around The Reward Token
     */
    function removeRewardToken(address rewardToken_) external onlyOwner {
        require(rewardTokens[rewardToken_].isRewardToken, "Not A Reward Token");
        require(rewardToken_ != address(0), "Zero Address");

        uint256 index = allRewardTokens.length;
        for (uint256 i = 0; i < allRewardTokens.length; i++) {
            if (allRewardTokens[i] == rewardToken_) {
                index = i;
                break;
            }
        }
        require(index < allRewardTokens.length, "Reward Token Not Found");

        // remove from all reward token array
        allRewardTokens[index] = allRewardTokens[allRewardTokens.length - 1];
        allRewardTokens.pop();

        // set reward token flag to false
        delete rewardTokens[rewardToken_].isRewardToken;

        // resets dividends so new users can't clear pool if accidentally re-added
        delete rewardTokens[rewardToken_].dividendsPerPoint;
    }

    /**
        Sets The Bounty Percentage For The `airdrop()` Mechanic
        This Percentage Will Dictate What Chunk Of Pending Rewards
        Is Paid Out To Airdrop Users / Bots
        Requirements:
            - newBounty cannot exceed 10%
     */
    function setBounty(uint256 newBounty) external onlyOwner {
        require(newBounty <= BOUNTY_DENOM / 10, "Bounty Too High");
        bounty = newBounty;
    }

    /**
        Can Force A User Out Of An Airdrop
        Useful For: 
        - Malicious contracts that fail on receive() or fallback()
        - Accounts That Spam Microscopic Amounts To Make The `airdrop` Function Non Profitable
     */
    function masterOptOutOfAirdrop(address user, bool isOptedOut)
        external
        onlyOwner
    {
        userInfo[user].optedOutOfAirdrop = isOptedOut;
    }

    /**
        Enables Emergency Withdraw On The Contract
        THIS ACTION CANNOT BE UNDONE
        Users Forfeit All Pending Rewards And Lock Times
        Users Are Able To Withdraw Their Entire Sum Of Tokens In One Transaction
        Rewards Are No Longer Permitted To Enter This Contract
     */
    function enableEmergencyWithdraw() external onlyOwner {
        emergencyWithdrawEnabled = true;
        emit EmergencyWithdrawEnabled();
    }

    ///////////////////////////////////////////
    ////////     PUBLIC FUNCTIONS     /////////
    ///////////////////////////////////////////

    /**
        Opts `msg.sender` out of the airdrop, allowing them to claim rewards as they see fit
        And skip their place in line when a user calls `Airdrop`, as to not forfeit any bounty percent of rewards
     */
    function optOutOfAirdrop() external {
        userInfo[msg.sender].optedOutOfAirdrop = true;
    }

    /**
        Opts `msg.sender` into the airdrop, allowing other users to claim a small bounty
        from their pending rewards for paying the gas to distribute rewards to the user
     */
    function optInToAirdrop() external {
        userInfo[msg.sender].optedOutOfAirdrop = false;
    }

    /**
        Airdrops To `iterations` of holders, only can airdrop to holders who have not opted out
        For paying the gas to airdrop holders, msg.sender gains a bounty percentage of all rewards distributed
     */
    function airdrop(uint256 iterations) external nonReentrant {
        for (uint256 i = 0; i < iterations; ) {
            // cycle back to top of array after completing airdrop search
            if (airdropIndex >= allUsers.length) {
                airdropIndex = 0;
            }

            // claim reward for user if they have allowed it
            if (userInfo[allUsers[airdropIndex]].optedOutOfAirdrop == false) {
                _claimReward(allUsers[airdropIndex], true);
            }

            // increment indicies
            unchecked {
                ++i;
                ++airdropIndex;
            }
        }
    }

    /**
        Claims All The Rewards Associated With `msg.sender`
     */
    function claimRewards() external nonReentrant {
        _claimReward(msg.sender, false);
    }

    /**
        Stakes `amount` of BETS-LP for the specified `lockTime`
        Increasing the user's rewardPoints and overall share of the pool
        Also claims the current pending rewards for the user
        Requirements:
            - `amount` is greater than zero
            - lock time is within bounds for min and max lock time, lock time is in blocks
            - emergencyWithdraw has not been enabled by contract owner
     */
    function stake(uint256 amount, uint256 lockTime) external nonReentrant {
        require(amount > 0, "Zero Amount");
        require(lockTime <= maxLockTime, "Lock Time Exceeds Maximum");
        require(lockTime >= minLockTime, "Lock Time Preceeds Minimum");
        require(emergencyWithdrawEnabled == false, "Emergency Mode");

        // gas savings
        address user = msg.sender;

        if (userInfo[user].totalAmountStaked > 0) {
            _claimReward(user, false);
        } else {
            userInfo[user].index = allUsers.length;
            allUsers.push(user);
        }

        // transfer in tokens
        uint256 received = _transferIn(token, amount);

        // total reward multiplier
        uint256 multiplier = calculateRewardPoints(received, lockTime);

        // update reward multiplier data
        userInfo[user].rewardPoints += multiplier;
        totalRewardPoints += multiplier;

        // update staked data
        totalStaked += received;
        userInfo[user].totalAmountStaked += received;

        // update reward data for each reward token
        _updateRewardDebt(user);

        // Map Lock Nonce To Lock Info
        lockInfo[lockInfoNonce] = LockInfo({
            lockAmount: received,
            unlockBlock: block.number + lockTime,
            rewardPointsAssigned: multiplier,
            index: userInfo[user].lockIds.length,
            locker: user
        });

        // Push Lock Nonce To User's Lock IDs
        userInfo[user].lockIds.push(lockInfoNonce);

        // Increment Global Lock Nonce
        lockInfoNonce++;

        // Attempt To Harvest From Bank
        _tryToHarvest();

        emit Transfer(address(0), user, received);
    }

    /**
        Withdraws `amount` of BETS-LP Associated With `lockId`
        Claims All Pending Rewards For The User
        Requirements:
            - `lockId` is a valid lock ID
            - locker of `lockId` is msg.sender
            - lock amount for `lockId` is greater than zero
            - the time left until unlock for `lockId` is zero
            - Emergency Withdraw is disabled
     */
    function withdraw(uint256 lockId, uint256 amount) external nonReentrant {
        // gas savings
        address user = msg.sender;
        uint256 lockIdAmount = lockInfo[lockId].lockAmount;

        // Require Input Data Is Correct
        require(lockId < lockInfoNonce, "Invalid LockID");
        require(lockInfo[lockId].locker == user, "Not Owner Of LockID");
        require(lockIdAmount > 0 && amount > 0, "Insufficient Amount");
        require(timeUntilUnlock(lockId) == 0, "ID Not Unlocked");
        require(emergencyWithdrawEnabled == false, "Emergency Mode");

        if (userInfo[user].totalAmountStaked > 0) {
            _claimReward(user, false);
        }

        // ensure we are not trying to unlock more than we own
        if (amount > lockIdAmount) {
            amount = lockIdAmount;
        }

        // update amount staked
        totalStaked -= amount;
        userInfo[user].totalAmountStaked -= amount;

        // if withdrawing full amount, remove lock ID
        if (amount == lockIdAmount) {
            // reduce reward points assigned
            uint256 rewardPointsAssigned = lockInfo[lockId]
                .rewardPointsAssigned;
            userInfo[user].rewardPoints -= rewardPointsAssigned;
            totalRewardPoints -= rewardPointsAssigned;

            // remove all lockId data
            _removeLock(lockId);
        } else {
            // reduce rewardPoints by rewardPoints * ( amount / lockAmount )
            uint256 rewardPointsToRemove = (amount *
                lockInfo[lockId].rewardPointsAssigned) / lockIdAmount;
            userInfo[user].rewardPoints -= rewardPointsToRemove;
            totalRewardPoints -= rewardPointsToRemove;

            // update lock data
            lockInfo[lockId].lockAmount -= amount;
            lockInfo[lockId].rewardPointsAssigned -= rewardPointsToRemove;
        }

        // update reward data
        _updateRewardDebt(user);

        // remove user from list if unstaked completely
        if (userInfo[user].totalAmountStaked == 0) {
            _removeUser(user);
        }

        // send rest of amount to user
        _send(token, user, amount);

        // Attempt To Harvest From Bank
        _tryToHarvest();

        emit Transfer(user, address(0), amount);
    }

    /**
        Allows User To Withdraw All Locked Tokens, Regardless of lockId or lock time
        User Forfeits All Rewards For Calling This Function
        Requirements:
            - emergencyWithdraw has been enabled by contract owner
            - user has staked tokens
     */
    function emergencyWithdraw() external {
        require(
            emergencyWithdrawEnabled == true,
            "Emergency Withdraw Disabled"
        );

        uint256 amount = userInfo[msg.sender].totalAmountStaked;
        require(amount > 0, "Zero Staked");

        // update amount staked
        totalStaked -= amount;
        totalRewardPoints -= userInfo[msg.sender].rewardPoints;

        // remove user from list
        _removeUser(msg.sender);

        // send rest of amount to user
        _send(token, msg.sender, amount);

        emit Transfer(msg.sender, address(0), amount);
    }

    /**
        Deposits `amount` of `reward` into the contract
        Updates The claim amount of each user if `reward` is a registered rewardToken
     */
    function depositRewards(address reward, uint256 amount) external {
        // if emergency, don't update rewards
        if (emergencyWithdrawEnabled) {
            return;
        }

        // transfer in reward amount
        uint256 received = _transferIn(reward, amount);

        // if points exist and token is reward token, update state
        if (totalRewardPoints > 0 && rewardTokens[reward].isRewardToken) {
            rewardTokens[reward].dividendsPerPoint +=
                (precision * received) /
                totalRewardPoints;
            rewardTokens[reward].totalRewardsAccrued += received;
        }
    }

    /**
        Allows Contract To Receive Native Currency
     */
    receive() external payable {}

    ///////////////////////////////////////////
    ////////    INTERNAL FUNCTIONS    /////////
    ///////////////////////////////////////////

    function _claimReward(address user, bool withBounty) internal {
        // exit if zero value locked
        if (userInfo[user].totalAmountStaked == 0) {
            return;
        }

        // length of all reward tokens
        uint256 len = allRewardTokens.length;

        // loop through reward tokens, claim pending, reset pending value to zero
        for (uint256 i = 0; i < len; ) {
            address reward = allRewardTokens[i];
            uint256 pending = pendingReward(user, reward);
            rewardTokens[reward].totalExcluded[user] = getCumulativeDividends(
                user,
                reward
            );
            if (withBounty) {
                uint256 fee = (bounty * pending) / BOUNTY_DENOM;
                pending -= fee;
                _send(reward, msg.sender, fee);
            }
            unchecked {
                userInfo[user].totalRewardsClaimed[reward] += pending;
            }
            _send(reward, user, pending);
            unchecked {
                ++i;
            }
        }
    }

    function _tryToHarvest() internal {
        if (totalRewardPoints > 0 && harvester != address(0)) {
            try IHarvester(harvester).harvest() {} catch {}
        }
    }

    function _transferIn(address _token, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 before = balanceOfToken(_token);
        IERC20(_token).transferFrom(msg.sender, address(this), amount);
        uint256 After = balanceOfToken(_token);
        require(After > before, "Error On Transfer From");
        return After - before;
    }

    function _send(
        address _token,
        address to,
        uint256 amount
    ) internal {
        if (_token == address(0) || to == address(0)) {
            return;
        }

        // fetch and validate contract owns necessary balance
        uint256 bal = balanceOfToken(_token);
        if (amount > bal) {
            amount = bal;
        }

        // return if amount is zero
        if (amount == 0) {
            return;
        }

        // ensure transfer succeeds
        require(
            IERC20(_token).transfer(to, amount),
            "Failure On Token Transfer"
        );
    }

    function _removeLock(uint256 id) internal {
        // fetch elements to make function more readable
        address user = lockInfo[id].locker;
        uint256 rmIndex = lockInfo[id].index;
        uint256 lastElement = userInfo[user].lockIds[
            userInfo[user].lockIds.length - 1
        ];

        // set last element's index to be removed index
        lockInfo[lastElement].index = rmIndex;
        // set removed index's position to be the last element
        userInfo[user].lockIds[rmIndex] = lastElement;
        // pop last element off the user array
        userInfo[user].lockIds.pop();

        // delete lock data
        delete lockInfo[id];
    }

    function _removeUser(address user) internal {
        // fetch elements to make function more readable
        address lastUser = allUsers[allUsers.length - 1];
        uint256 rmIndex = userInfo[user].index;

        // set last users index to be removed index
        userInfo[lastUser].index = rmIndex;
        // set removed index to be last user
        allUsers[rmIndex] = lastUser;
        // pop last element off the user array
        allUsers.pop();

        // delete user info array
        delete userInfo[user];
    }

    function _updateRewardDebt(address user) internal {
        uint256 len = allRewardTokens.length;
        for (uint256 i = 0; i < len; ) {
            rewardTokens[allRewardTokens[i]].totalExcluded[
                    user
                ] = getCumulativeDividends(user, allRewardTokens[i]);
            unchecked {
                ++i;
            }
        }
    }

    ///////////////////////////////////////////
    ////////      READ FUNCTIONS      /////////
    ///////////////////////////////////////////

    function airdropBounty(uint256 iterations)
        public
        view
        returns (uint256[] memory)
    {
        uint256 len = allRewardTokens.length;
        uint256[] memory pending = new uint256[](len);
        uint256[] memory userPending = new uint256[](len);
        uint256 count = airdropIndex;

        for (uint256 i = 0; i < iterations; ) {
            // cycle back to top of array after completing airdrop search
            if (count >= allUsers.length) {
                count = 0;
            }

            // claim reward for user
            userPending = pendingRewards(allUsers[count]);
            for (uint256 j = 0; j < len; ) {
                pending[j] += (bounty * userPending[j]) / BOUNTY_DENOM;
                unchecked {
                    ++j;
                }
            }

            // increment airdrop index
            count++;
            unchecked {
                ++i;
            }
        }
        delete userPending;
        return pending;
    }

    function balanceOfToken(address _token) public view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }

    function calculateRewardPoints(uint256 lockAmount, uint256 lockTime)
        public
        view
        returns (uint256)
    {
        return
            lockAmount *
            (minLockTimeMultiplier +
                (((lockTime - minLockTime) *
                    (maxLockTimeMultiplier - minLockTimeMultiplier)) /
                    (maxLockTime - minLockTime)));
    }

    function timeUntilUnlock(uint256 lockId) public view returns (uint256) {
        return
            lockInfo[lockId].unlockBlock <= block.number
                ? 0
                : lockInfo[lockId].unlockBlock - block.number;
    }

    function pendingRewards(address user)
        public
        view
        returns (uint256[] memory)
    {
        uint256 len = allRewardTokens.length;
        uint256[] memory pendings = new uint256[](len);
        for (uint256 i = 0; i < len; ) {
            pendings[i] = pendingReward(user, allRewardTokens[i]);
            unchecked {
                ++i;
            }
        }
        return pendings;
    }

    function pendingReward(address shareholder, address rewardToken)
        public
        view
        returns (uint256)
    {
        if (userInfo[shareholder].totalAmountStaked == 0) {
            return 0;
        }

        uint256 holderTotalDividends = getCumulativeDividends(
            shareholder,
            rewardToken
        );
        uint256 holderTotalExcluded = rewardTokens[rewardToken].totalExcluded[
            shareholder
        ];

        return
            holderTotalDividends > holderTotalExcluded
                ? holderTotalDividends - holderTotalExcluded
                : 0;
    }

    function getAllUsers() external view returns (address[] memory) {
        return allUsers;
    }

    function holderCount() external view returns (uint256) {
        return allUsers.length;
    }

    function getAllLockIDsForUser(address user)
        external
        view
        returns (uint256[] memory)
    {
        return userInfo[user].lockIds;
    }

    function getNumberOfLockIDsForUser(address user)
        external
        view
        returns (uint256)
    {
        return userInfo[user].lockIds.length;
    }

    function fetchLockData(address user)
        external
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        uint256 len = userInfo[user].lockIds.length;
        uint256[] memory amounts = new uint256[](len);
        uint256[] memory timeRemaining = new uint256[](len);

        for (uint256 i = 0; i < len; ) {
            amounts[i] = lockInfo[userInfo[user].lockIds[i]].lockAmount;
            timeRemaining[i] = timeUntilUnlock(userInfo[user].lockIds[i]);
            unchecked {
                ++i;
            }
        }

        return (userInfo[user].lockIds, amounts, timeRemaining);
    }

    function getAllRewardTokens() external view returns (address[] memory) {
        return allRewardTokens;
    }

    function getTotalRewardsClaimedForUser(address user, address reward)
        external
        view
        returns (uint256)
    {
        return userInfo[user].totalRewardsClaimed[reward];
    }

    function getAllTotalRewardsClaimedForUser(address user)
        external
        view
        returns (uint256[] memory)
    {
        uint256 len = allRewardTokens.length;
        uint256[] memory totals = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            totals[i] = userInfo[user].totalRewardsClaimed[allRewardTokens[i]];
        }
        return totals;
    }

    function getCumulativeDividends(address shareholder, address rewardToken)
        internal
        view
        returns (uint256)
    {
        return ((userInfo[shareholder].rewardPoints *
            rewardTokens[rewardToken].dividendsPerPoint) / precision);
    }

    function getTotalRewardsAccrued(address rewardToken)
        public
        view
        returns (uint256)
    {
        return rewardTokens[rewardToken].totalRewardsAccrued;
    }

    function getAllTotalRewardsAccrued()
        external
        view
        returns (uint256[] memory)
    {
        uint256 len = allRewardTokens.length;
        uint256[] memory totals = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            totals[i] = rewardTokens[allRewardTokens[i]].totalRewardsAccrued;
        }
        return totals;
    }
}