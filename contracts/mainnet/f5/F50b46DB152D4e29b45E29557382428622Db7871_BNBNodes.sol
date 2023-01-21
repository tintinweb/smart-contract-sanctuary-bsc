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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
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

// ░▒█▀▀▄░▒█▄░▒█░▒█▀▀▄░░░▒█▄░▒█░▒█▀▀▀█░▒█▀▀▄░▒█▀▀▀░▒█▀▀▀█
// ░▒█▀▀▄░▒█▒█▒█░▒█▀▀▄░░░▒█▒█▒█░▒█░░▒█░▒█░▒█░▒█▀▀▀░░▀▀▀▄▄
// ░▒█▄▄█░▒█░░▀█░▒█▄▄█░░░▒█░░▀█░▒█▄▄▄█░▒█▄▄█░▒█▄▄▄░▒█▄▄▄█

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title The BNBNodes contract
contract BNBNodes is Ownable, ReentrancyGuard {
    /// @notice Defines how many levels of referrals can go for the Direct Referral Commission (DRC)
    uint8 public constant MAX_DIRECT_REFERRAL_DEPTH = 5;

    /// @notice Defines Minimum Amount Required in Daily Pool for Payout to be triggered
    uint public constant MIN_POOL_AMOUNT = 10000000000000000; //

    /// @notice Defines Investment Cycle Limits per User
    uint256 public constant CYCLE_LIMIT_ONE = 10 ether;
    uint256 public constant CYCLE_LIMIT_TWO = 25 ether;
    uint256 public constant CYCLE_LIMIT_THREE = 100 ether;
    uint256 public constant CYCLE_LIMIT_FOUR = 250 ether;

    /// @notice Defines percentages for Direct Referral Commission (DRC) levels
    uint8 public constant FIRST_GEN_DRC = 10;
    uint8 public constant SECOND_GEN_DRC = 2;
    uint8 public constant THIRD_AND_MORE_GEN_DRC = 1;

    /// @notice Defines percentages for Daily Node Reward Commission (DNRC) levels
    uint8 public constant FIRST_GEN_DNRC = 30;
    uint8 public constant SECOND_TO_5TH_GEN_DNRC = 10;
    uint8 public constant SIXTH_TO_10TH_GEN_DNRC = 8;
    uint8 public constant ELEVENTH_TO_15TH_GEN_DNRC = 5;
    uint8 public constant SIXTEENTH_TO_20TH_GEN_DNRC = 1;

    /// @notice Defines how many levels of rewards comission are distributed
    uint8 public constant MAX_DAILY_NODE_REWARDS_COMMISSION_DEPTH = 20;

    /// @notice Defines how many percent (%) Daily Node Reward (DNR) are paid
    uint8 public constant DAILY_NODE_REWARD_PERCENTAGE = 1;

    /// @notice Defines how many percent (%) of new investments are dispersed to the masterAccount
    uint8 public constant HOUSE_FEE_PERCENTAGE = 5;

    /// @notice Defines how many percent (%) of the Daily Top Sponsor (DTS) Pool are distributed to Top Sponsors
    uint8 public constant DAILY_TOP_SPONSOR_POOL_DISTRIBUTION_PERCENT = 10;

    /// @notice Defines how many percent (%) of new investments are flowing into the Daily Pool
    uint8 public constant DAILY_TOP_SPONSOR_POOL_PERCENT = 5;

    /// @notice Defines how many percent (%) of new investments are flowing into the Whale Pool
    uint8 public constant WHALEPOOL_PERCENTAGE_X10 = 25;

    /// @notice Defines the amount an investor needs to invest to be considered a whale.
    uint256 public constant WHALE_RANK_AMOUNT = 250 ether;

    /// @notice Defines the duration of one round, which is 1 day, equalling 24 hours
    uint256 public constant DAILY_ROUND_DURATION = 24 hours;

    /// @notice Defines the minimum investment amount
    uint256 public constant MIN_INVEST = 0.01 ether;

    /// @notice This DailyRound structure is instantiated each DailyRound
    struct DailyRound {
        uint256 startTime;
        uint256 endTime;
        bool ended;
        uint256 pool;
        uint256 whalepool;
    }

    /// @notice struct storing all User-related information
    struct User {
        address account; // the account of the User
        uint256 id; // this is the referral ID of the User
        Investment investment; // tracks investment struct per User
        uint256 referralCount; // tracks how many accounts contain the User.id in User.referrer (currently not reset after cycle)
        address referrer; // an address that referred the User, this must be retrieved via the `id` which is the referral link
        bool isWhale; // boolean that needs to be set once
        statistics stats; // tracks personal stats
        uint256 totalEarnings; // tracks total Earnings (ever paid out, per User, note that includes all income streams)
        string rank; // stores current rank of user
    }

    /// @notice struct storing all investment-related information
    struct Investment {
        uint256 totalInvestment; // increases from 0 for new joinee, needs to be increased with each investment cycle
        uint256 currInvestment; // how much the user invested in the current cycle
        uint256 initialInvestment; // what the user invested when he first joined (first cycle currInvestment)
        uint256 currInvestmentCycle; // in which cycle the user currently is with currInvestment
        uint256 currInvestmentDepositTime; // trackss the moment currInvestment was done using block.timestamp
        uint256 currInvestmentWithdrawn; // tracks the withdrawn amount of the currInvestment
        uint256 incomeLimitLeft; // is initialized with currInvestment.mul(3) or .mul(2), i.e., 300% of currInvestment for non-whales, 200% for whales
        uint256 incomeWithdrawn; // tracks the totally withdrawn amount of DNR ONLY (1% a day)
        uint256 directReferralCommission; // tracks the claimable amount of the Direct Referral Commission (DRC)
        uint256 dailyNodeRewardCommission; // tracks claimable amount of the Direct Node Reward Commission (DNRC) note only triggered by sponsor's payouts
        uint256 dailyTopSponsorBonus; // tracks claimable amount of Daily Top Sponsor Bonus note this is *only* increased on startNextRound() and awardTopSponsors()
        uint256 dailyWhaleBonus; // tracks the Daily Whale Pool Bonus note this is *only* increased on startNextRound() and wardWhales()
    }

    /// @notice struct storing personal statistics (ever-increasing, never reset per User)
    struct statistics {
        uint256 totalDirectReferralCommission;
        uint256 totalDailyNodeRewardCommission;
        uint256 totalDailyTopSponsorBonus;
        uint256 totalDailyWhaleBonus;
    }

    /// @notice This struct tracks currInvestment daily volume per User in UserVolPerRound
    struct UserDailyRounds {
        uint256 volume;
    }

    /// @notice This struct is used in an array (topSponsors) to track the Daily Top Sponsor (DTS) Leaders
    struct DTSLeader {
        uint256 _amount; // previously amt;
        address _address; // previously addr;
    }

    /// @notice Arrays tracking the Accounts for the Daily Top Sponsor Bonus
    DTSLeader[4] public topSponsors;
    DTSLeader[4] public lastTopSponsors;
    uint256[4] public lastTopSponsorsWinningAmount;

    /// _address @notice Array tracking whale a_address
    address[] public whales;

    /// @notice Contract-wide Storage variables
    uint256 public totalWithdrawals; // total amount of withdrawals ever made
    uint256 public roundID; // increases every day, one day per round (new either triggered by registerUser or by Owner)
    uint256 public currentUserID; // increases with each new User registering
    address public masterAccount; // the houseFee is forwarded to this account

    /// @notice The DTSBonusPercentage array is initialized in the constructor
    uint256[4] private DTSBonusPercentage; // tracks the 4 stages of percentages for the TopSponsorBonus (used for iteration)

    /// @notice Mapping of a unit256 key to the roundID pointing at a UserDailyRounds struct containing the ether volume per *round*
    mapping(address => mapping(uint256 => UserDailyRounds)) public userVolPerRound; // tracks user's invited / referred volume per round
    mapping(uint256 => DailyRound) public dailyRounds; // previously "round", tracks the global state of rounds
    mapping(uint256 => address) public addressMap; // previously "userList", tracks global mapping of referrerID to address
    mapping(address => User) public userMap; // previously "player", tracks global state uof User objects via ID

    event registerNewUserEvent(
        address indexed _userAddress,
        address indexed _referrer,
        uint256 indexed _timestamp
    );
    event investmentEvent(
        address indexed _investorAddr,
        uint256 indexed _currInvestmentCycle,
        uint256 _amount,
        uint256 indexed _timestamp
    );
    event directReferralCommissionEvent(
        address indexed _userAddress,
        address indexed _referrer,
        uint256 amount,
        uint256 indexed _timestamp
    );
    event dailyNodeRewardCommissionEvent(
        address indexed _userAddress,
        address indexed _referrer,
        uint256 amount,
        uint256 indexed _timestamp
    );
    event withdrawalEvent(address indexed _userAddress, uint256 indexed _amount, uint256 _timestamp);
    event dailyTopSponsorBonusEvent(
        address indexed _userAddress,
        uint256 indexed _amount,
        uint256 indexed _timestamp
    );
    event dailyWhaleBonusEvent(
        address indexed _userAddress,
        uint256 indexed _amount,
        uint256 indexed _timestamp
    );
    event newMasterAccountEvent(
        address indexed _oldMasterAccount,
        address indexed _newMasterAccount,
        uint256 indexed _timestamp
    );

    /// @notice Constructor of BNBNodes
    /// @param _owner of the contract
    /// @param _masterAccount account receiving houseFee
    constructor(address _owner, address _masterAccount) {
        require(_owner != address(0x0), "Owner not set");
        require(_masterAccount != address(0x0), "Master Account not set");

        super.transferOwnership(_owner);
        masterAccount = _masterAccount;

        /// @dev initialize DTSBonusPercentage
        DTSBonusPercentage[0] = 40;
        DTSBonusPercentage[1] = 30;
        DTSBonusPercentage[2] = 20;
        DTSBonusPercentage[3] = 10;

        /// @dev initialize global roundID and first dailyRounds[1]
        roundID = 1;
        uint256 startBlockTimeStamp = block.timestamp;
        dailyRounds[roundID].startTime = block.timestamp;
        dailyRounds[roundID].endTime = startBlockTimeStamp + DAILY_ROUND_DURATION;

        /// @dev initializes global user-tracking
        currentUserID = 0;

        /// @notice ref ID 0 is reserved for the masterAccount
        /// @dev Setting up the masterAccount with ID = 0
        addressMap[currentUserID] = masterAccount;
        userMap[masterAccount].id = currentUserID;
        userMap[masterAccount].account = masterAccount;
    }

    /// @notice main register function for pay ins
    /// @param _referrerID User.id of who referred the new user
    function registerUser(uint256 _referrerID) public payable nonReentrant {
        require(msg.value >= MIN_INVEST, "Insufficient investment amount.");
        require(msg.value % MIN_INVEST == 0, "Must be divisible by 0.01 BNB.");
        require(_referrerID >= 0, "Referrer cannot be negative");
        // require(_referrerID < currentUserID, "Referrer does not exist");

        /// @dev assing vars of this transaction
        uint256 _investAmount = msg.value;
        address _investorAddr = msg.sender;

        address _referrerAddr; // will be initialized with _referrerID or existing referrer for registered users.

        if (userMap[msg.sender].id <= 0) {
            require(_investAmount <= CYCLE_LIMIT_ONE, "Can not send more than first cycle limit");

            // Checks performed, now Effects
            currentUserID++;

            if (_referrerID == 0) {
                /// @notice set masterAcc as referrer if referrerID is 0
                if (addressMap[1] == address(0x0)) {
                    _referrerAddr = masterAccount;
                } else {
                    /// @notice case only reached for first ever user registered
                    _referrerAddr = addressMap[1];
                }
            } else {
                /// @notice retrieve address of the referee (that invited the new user)
                _referrerAddr = addressMap[_referrerID];
            }

            /// @dev Set the addressMap correctly
            addressMap[currentUserID] = _investorAddr;

            /// @dev Set all variables for the new User
            userMap[_investorAddr].id = currentUserID;
            userMap[_investorAddr].account = _investorAddr;
            userMap[_investorAddr].referrer = _referrerAddr;
            userMap[_investorAddr].isWhale = false;
            userMap[_investorAddr].rank = this.getRank(_investAmount);

            /// @dev Set all variables in the investment struct
            userMap[_investorAddr].investment.currInvestment = _investAmount;
            userMap[_investorAddr].investment.totalInvestment = _investAmount;
            userMap[_investorAddr].investment.currInvestmentCycle = 1;
            userMap[_investorAddr].investment.currInvestmentDepositTime = block.timestamp;
            userMap[_investorAddr].investment.currInvestmentWithdrawn = 0;
            userMap[_investorAddr].investment.incomeLimitLeft = _investAmount * 3;
            userMap[_investorAddr].investment.incomeWithdrawn = 0;

            /// @dev Increase _amount by pool and referrer for the Top Sponsor Pool
            addToDailyTopSponsorPool(_referrerAddr, _investAmount);
            /// @dev Distribute commission for new user
            distributeDirectReferralCommission(_referrerAddr, _investorAddr, _investAmount);

            /// @dev Emit event
            emit registerNewUserEvent(
                _investorAddr,
                _referrerAddr,
                userMap[_investorAddr].investment.currInvestmentDepositTime
            );
        } else {
            /// @notice branching in here means the investor is already registered (increase cycle +1)
            /// @dev check if incomeLimit == 0
            require(
                userMap[_investorAddr].investment.incomeLimitLeft == 0,
                "There are claimable DNR remaining"
            );

            /// @dev check that new investment is at least x2 the last investment
            uint256 _doubleUpCurrInvest = userMap[_investorAddr].investment.currInvestment * 2;
            require(_investAmount >= _doubleUpCurrInvest, "Investment must be at least double the last");

            /// @dev check if sent amount is *** than minimum cycle amount
            if (userMap[_investorAddr].investment.currInvestmentCycle == 1) {
                require(_investAmount <= CYCLE_LIMIT_TWO, "Please send correct amount for second cycle.");
                /// @dev if these checks were fine, we can increase the cycle
                userMap[_investorAddr].investment.currInvestmentCycle++; // now 2
            } else if (userMap[_investorAddr].investment.currInvestmentCycle == 2) {
                require(_investAmount <= CYCLE_LIMIT_THREE, "Please send correct amount for third cycle.");
                /// @dev if these checks were fine, we can increase the cycle
                userMap[_investorAddr].investment.currInvestmentCycle++; // now 3
            } else if (userMap[_investorAddr].investment.currInvestmentCycle == 3) {
                /// @dev if these checks were fine, we can increase the cycle
                require(_investAmount <= CYCLE_LIMIT_FOUR, "Please send correct amount for fourth cycle.");
                userMap[_investorAddr].investment.currInvestmentCycle++; // now 4
            }

            /// @dev execution is still within the 'else' of the "existing user"
            /// @dev Following if checks whether the user can be added as a whale
            /// @dev whales array is ONLY pushed to (also in old contract), makes sense?
            if (_investAmount >= WHALE_RANK_AMOUNT && (userMap[_investorAddr].isWhale == false)) {
                userMap[_investorAddr].isWhale = true;
                /// @dev Add to whalepool if not added yet.
                whales.push(_investorAddr);
                // TODO: we need to cover the corner case where someone is a whale and wants to reinvest, what then?
            }

            /// @dev Set variables for existing user
            userMap[_investorAddr].rank = this.getRank(_investAmount);

            /// @dev Set all variables in the investment struct for existing user
            userMap[_investorAddr].investment.currInvestment = _investAmount;
            userMap[_investorAddr].investment.currInvestmentWithdrawn = 0;
            userMap[_investorAddr].investment.totalInvestment += _investAmount;
            userMap[_investorAddr].investment.currInvestmentDepositTime = block.timestamp;
            if (userMap[_investorAddr].investment.currInvestmentCycle == 4) {
                userMap[_investorAddr].investment.incomeLimitLeft = _investAmount * 2;
            } else {
                userMap[_investorAddr].investment.incomeLimitLeft = _investAmount * 3;
            }
            userMap[_investorAddr].investment.incomeWithdrawn = 0;

            _referrerAddr = userMap[_investorAddr].referrer;
            /// @dev Increase _amount by pool and referrer for the Top Sponsor Pool
            addToDailyTopSponsorPool(_referrerAddr, _investAmount);
            /// @dev Distribute commission for new user
            distributeDirectReferralCommission(_referrerAddr, _investorAddr, _investAmount);

            /// @dev Emit event
            emit investmentEvent(
                _investorAddr,
                userMap[_investorAddr].investment.currInvestmentCycle,
                _investAmount,
                userMap[_investorAddr].investment.currInvestmentDepositTime
            );
        }

        /// @dev Checks whether the current referrer has enough volume for the topSponsors
        addReferrerToTopSponsorPool(_referrerAddr, userVolPerRound[_referrerAddr][roundID].volume);

        /// @dev Adds WHALEPOOL_PERCENTAGE of _investAmount to whalepool
        addAmountToWhalePool(_investAmount);

        /// @dev sends housefee on the _investAmount to the masterAccount
        collectHouseFee(_investAmount);

        /// @dev If the 24 hours are over, the new user can call the function, too.
        if (block.timestamp > dailyRounds[roundID].endTime && dailyRounds[roundID].ended == false) {
            startNextRound();
        }
    }

    /// @notice Distributes Rewards to Referrers when a new joinee joins
    /// @param _investorAddr the address of the referee
    /// @param _investorAmount the amount that the new joinee invested
    function distributeDirectReferralCommission(
        address _referrerAddr,
        address _investorAddr,
        uint256 _investorAmount
    ) private {
        require(_investorAddr != address(0x0), "Investor Address is zero");

        /// @dev increase the referralCount variable in the User struct by 1
        userMap[_referrerAddr].referralCount += 1;

        /// @dev assign first instance of _nextReferrer for the loop below
        address _nextReferrer = userMap[_investorAddr].referrer;

        for (uint i = 0; i < MAX_DIRECT_REFERRAL_DEPTH; i++) {
            if (_nextReferrer != address(0x0)) {
                if (i == 0) {
                    // DRC Depth 1
                    uint256 _firstLevelDRC = (_investorAmount * FIRST_GEN_DRC) / 100;
                    userMap[_nextReferrer].investment.directReferralCommission += _firstLevelDRC;
                    userMap[_nextReferrer].stats.totalDirectReferralCommission += _firstLevelDRC;

                    emit directReferralCommissionEvent(
                        _investorAddr,
                        _nextReferrer,
                        _firstLevelDRC,
                        block.timestamp
                    );
                } else if (i == 1) {
                    // DRC Depth 2
                    /// @dev Additional check whether the referralcount is larger than 2
                    if (userMap[_nextReferrer].referralCount >= 2) {
                        // if (userMap[_nextReferrer].referralCount >= 2) {
                        uint256 _secondLevelDRC = (_investorAmount * SECOND_GEN_DRC) / 100;
                        userMap[_nextReferrer].investment.directReferralCommission += _secondLevelDRC;
                        userMap[_nextReferrer].stats.totalDirectReferralCommission += _secondLevelDRC;

                        emit directReferralCommissionEvent(
                            _investorAddr,
                            _nextReferrer,
                            _secondLevelDRC,
                            block.timestamp
                        );
                    }
                } else {
                    // DRC Depth 3-5
                    // if (userMap[_nextReferrer].referralCount >= i + 1) {
                    if (userMap[_nextReferrer].referralCount >= i + 1) {
                        uint256 _thirdToFifthLevelDRC = (_investorAmount * THIRD_AND_MORE_GEN_DRC) / 100;
                        userMap[_nextReferrer].investment.directReferralCommission += _thirdToFifthLevelDRC;
                        userMap[_nextReferrer].stats.totalDirectReferralCommission += _thirdToFifthLevelDRC;
                        emit directReferralCommissionEvent(
                            _investorAddr,
                            _nextReferrer,
                            _thirdToFifthLevelDRC,
                            block.timestamp
                        );
                    }
                }
            } else {
                break; // no more referrals
            }
            _nextReferrer = userMap[_nextReferrer].referrer;
        }
    }

    /// @notice this function adds the referrer / sponsor the the daily top sponsor pool if _refVolume is larger than the last rank
    /// @param _refAddress is the referrer's / sponsor's address
    /// @param _refVolume is the the referrer's / sponsor's partner's volume
    function addReferrerToTopSponsorPool(
        address _refAddress,
        uint256 _refVolume
    ) private returns (bool _success) {
        require(_refAddress != address(0x0), "Non-zero address required");

        // if the amount is less than the last on the leaderboard pool, reject
        if (topSponsors[3]._amount >= _refVolume) {
            return false;
        }

        address firstAddr = topSponsors[0]._address;
        uint256 firstAmt = topSponsors[0]._amount;

        address secondAddr = topSponsors[1]._address;
        uint256 secondAmt = topSponsors[1]._amount;

        address thirdAddr = topSponsors[2]._address;
        uint256 thirdAmt = topSponsors[2]._amount;

        // if the user should be at the top
        if (_refVolume > topSponsors[0]._amount) {
            if (topSponsors[0]._address == _refAddress) {
                topSponsors[0]._amount = _refVolume;
                return true;
            }
            //if user is at the second position already and will come on first
            else if (topSponsors[1]._address == _refAddress) {
                topSponsors[0]._address = _refAddress;
                topSponsors[0]._amount = _refVolume;
                topSponsors[1]._address = firstAddr;
                topSponsors[1]._amount = firstAmt;
                return true;
            }
            //if user is at the third position and will come on first
            else if (topSponsors[2]._address == _refAddress) {
                topSponsors[0]._address = _refAddress;
                topSponsors[0]._amount = _refVolume;
                topSponsors[1]._address = firstAddr;
                topSponsors[1]._amount = firstAmt;
                topSponsors[2]._address = secondAddr;
                topSponsors[2]._amount = secondAmt;
                return true;
            } else {
                topSponsors[0]._address = _refAddress;
                topSponsors[0]._amount = _refVolume;
                topSponsors[1]._address = firstAddr;
                topSponsors[1]._amount = firstAmt;
                topSponsors[2]._address = secondAddr;
                topSponsors[2]._amount = secondAmt;
                topSponsors[3]._address = thirdAddr;
                topSponsors[3]._amount = thirdAmt;
                return true;
            }
        }
        // if the user should be at the second position
        else if (_refVolume > topSponsors[1]._amount) {
            if (topSponsors[1]._address == _refAddress) {
                topSponsors[1]._amount = _refVolume;
                return true;
            }
            //if user is at the third position, move it to second
            else if (topSponsors[2]._address == _refAddress) {
                topSponsors[1]._address = _refAddress;
                topSponsors[1]._amount = _refVolume;
                topSponsors[2]._address = secondAddr;
                topSponsors[2]._amount = secondAmt;
                return true;
            } else {
                topSponsors[1]._address = _refAddress;
                topSponsors[1]._amount = _refVolume;
                topSponsors[2]._address = secondAddr;
                topSponsors[2]._amount = secondAmt;
                topSponsors[3]._address = thirdAddr;
                topSponsors[3]._amount = thirdAmt;
                return true;
            }
        }
        //if the user should be at third position
        else if (_refVolume > topSponsors[2]._amount) {
            if (topSponsors[2]._address == _refAddress) {
                topSponsors[2]._amount = _refVolume;
                return true;
            } else {
                topSponsors[2]._address = _refAddress;
                topSponsors[2]._amount = _refVolume;
                topSponsors[3]._address = thirdAddr;
                topSponsors[3]._amount = thirdAmt;
            }
        }
        // if the user should be at the fourth position
        else if (_refVolume > topSponsors[3]._amount) {
            if (topSponsors[3]._address == _refAddress) {
                topSponsors[3]._amount = _refVolume;
                return true;
            } else {
                topSponsors[3]._address = _refAddress;
                topSponsors[3]._amount = _refVolume;
                return true;
            }
        }
    }

    /// @notice this function is called to increase the Daily Top Sponsor Pool _amount for the _sponsor (referrer)
    /// @notice it also increases dailyRounds[roundID].pool by DAILY_TOP_SPONSOR_POOL_PERCENT of the _investAmount
    /// @param _referrerAddr is the address of the sponsor / referrer
    /// @param _investAmount is the amount the new investor placed
    function addToDailyTopSponsorPool(address _referrerAddr, uint256 _investAmount) private {
        require(_investAmount > 0, "Amount can not be negative");

        /// @notice Calculate and add to the daily pool of roundID
        uint256 _amountPercentage = (_investAmount * DAILY_TOP_SPONSOR_POOL_PERCENT) / 100;
        dailyRounds[roundID].pool += _amountPercentage;

        /// @notice  Increase user volume for _referrerAddr by _investAmount
        userVolPerRound[_referrerAddr][roundID].volume += _investAmount;
    }

    /// @notice this function will add WHALEPOOL_PERCENTAGE of _amount to the daily round's whalepool variable
    /// @param _amount is the new investment amount that the whalepool calculation will be based on
    function addAmountToWhalePool(uint256 _amount) private {
        require(_amount > 0, "Amount can not be zero");
        uint256 _whalepoolAmount = (_amount * WHALEPOOL_PERCENTAGE_X10) / 1000; // Divided by 1000 because percentage is X10
        dailyRounds[roundID].whalepool += _whalepoolAmount;
    }

    /// @notice this function will send the HOUSE_FEE_PERCENTAGE of _amount to the _masterAccount
    /// @param _amount is the new investment amount that the house fee calculation will be based on
    function collectHouseFee(uint256 _amount) private {
        address payable _masterAccount = payable(masterAccount);
        uint256 _houseFeeAmount = (_amount * HOUSE_FEE_PERCENTAGE) / 100;
        _masterAccount.transfer(_houseFeeAmount);
    }

    /// @notice can be used to set a new address as the masterAccount receiving the houseFee
    /// @param _address the address of the new masterAccount
    function setNewMasterAccount(address _address) external onlyOwner {
        require(_address != address(0x0), "Address is null");
        require(_address != masterAccount, "Address already set");
        address _oldMasterAccount = masterAccount;
        masterAccount = _address;

        /// @notice Set global variables to new masterAccount
        addressMap[0] = masterAccount;
        userMap[masterAccount].id = 0;
        userMap[masterAccount].account = masterAccount;
        emit newMasterAccountEvent(_oldMasterAccount, masterAccount, block.timestamp);
    }

    /// @notice safely callable by contract owner to start new daily round
    function startNextRoundAsOwner() external onlyOwner {
        require(block.timestamp > dailyRounds[roundID].endTime, "Round has not ended yet");
        startNextRound();
    }

    /// @notice only called in emergencies to force-start new rounds
    function forceStartNextRoundAsOwner() external onlyOwner {
        startNextRound();
    }

    /// @notice called from either (a) owner through startNextRoundAsOwner(), or (b) during registerUser
    function startNextRound() private {
        uint256 _roundID = roundID;
        uint256 _poolAmount = dailyRounds[roundID].pool;

        /// @dev the _poolAmount needs to be at least MIN_POOL_AMOUNT, otherwise not really worth distributing
        if (_poolAmount >= MIN_POOL_AMOUNT) {
            /// @dev end round
            dailyRounds[_roundID].ended = true;
            uint256 _distributedAmount = awardTopSponsors();
            if (whales.length > 0) {
                awardWhales();
                // pool should be emptied now
            }

            // if pool not emptied
            uint256 _whalePoolCarryOver = dailyRounds[roundID].whalepool;

            /// @dev increase roundID by 1
            _roundID++;
            roundID++;

            uint256 _blockTimestamp = block.timestamp;
            dailyRounds[_roundID].startTime = _blockTimestamp;
            dailyRounds[_roundID].pool = _poolAmount - _distributedAmount;
            dailyRounds[_roundID].endTime = _blockTimestamp + DAILY_ROUND_DURATION;
            dailyRounds[_roundID].whalepool = _whalePoolCarryOver;
        } else {
            /// @dev this only gets executed if there are not more than 0.1 BNB in the pool
            uint256 _blockTimestamp = block.timestamp;
            dailyRounds[_roundID].startTime = _blockTimestamp;
            dailyRounds[_roundID].endTime = _blockTimestamp + DAILY_ROUND_DURATION;
            // Carry over _poolAmount
            dailyRounds[_roundID].pool = _poolAmount;
        }
    }

    /// @notice function that triggers the distribution of DNR commissions
    /// @dev the _investorAddress in that case is collecting its DNR, and then triggers the dailyNodeRewardCommission
    /// @param _investorAddress the investor that collects DNR, this triggers DNR Comissions for its sponsor
    function distributeDailyNodeRewardCommission(address _investorAddress, uint256 _amount) private {
        address _sponsor = userMap[_investorAddress].referrer;
        uint256 i;

        for (i = 0; i < 20; i++) {
            if (_sponsor != address(0x0)) {
                if (i == 0) {
                    uint256 _dailyNodeRewCom = (_amount * FIRST_GEN_DNRC) / 100;
                    userMap[_sponsor].investment.dailyNodeRewardCommission += _dailyNodeRewCom;
                    userMap[_sponsor].stats.totalDailyNodeRewardCommission += _dailyNodeRewCom;
                    emit dailyNodeRewardCommissionEvent(
                        _investorAddress,
                        _sponsor,
                        _dailyNodeRewCom,
                        block.timestamp
                    );
                }
                //for depth 2-5
                else if (i > 0 && i < 5) {
                    if (userMap[_sponsor].referralCount >= i + 1) {
                        uint256 _dailyNodeRewCom = (_amount * SECOND_TO_5TH_GEN_DNRC) / 100;
                        userMap[_sponsor].investment.dailyNodeRewardCommission += _dailyNodeRewCom;
                        userMap[_sponsor].stats.totalDailyNodeRewardCommission += _dailyNodeRewCom;
                        emit dailyNodeRewardCommissionEvent(
                            _investorAddress,
                            _sponsor,
                            _dailyNodeRewCom,
                            block.timestamp
                        );
                    }
                }
                //for depth 6-10
                else if (i > 4 && i < 10) {
                    if (userMap[_sponsor].referralCount >= i + 1) {
                        uint256 _dailyNodeRewCom = (_amount * SIXTH_TO_10TH_GEN_DNRC) / 100;
                        userMap[_sponsor].investment.dailyNodeRewardCommission += _dailyNodeRewCom;
                        userMap[_sponsor].stats.totalDailyNodeRewardCommission += _dailyNodeRewCom;
                        emit dailyNodeRewardCommissionEvent(
                            _investorAddress,
                            _sponsor,
                            _dailyNodeRewCom,
                            block.timestamp
                        );
                    }
                }
                //for user 11-15
                else if (i > 9 && i < 15) {
                    if (userMap[_sponsor].referralCount >= i + 1) {
                        uint256 _dailyNodeRewCom = (_amount * ELEVENTH_TO_15TH_GEN_DNRC) / 100;
                        userMap[_sponsor].investment.dailyNodeRewardCommission += _dailyNodeRewCom;
                        userMap[_sponsor].stats.totalDailyNodeRewardCommission += _dailyNodeRewCom;
                        emit dailyNodeRewardCommissionEvent(
                            _investorAddress,
                            _sponsor,
                            _dailyNodeRewCom,
                            block.timestamp
                        );
                    }
                } else {
                    // for users 16-20
                    if (userMap[_sponsor].referralCount >= i + 1) {
                        uint256 _dailyNodeRewCom = (_amount * SIXTEENTH_TO_20TH_GEN_DNRC) / 100;
                        userMap[_sponsor].investment.dailyNodeRewardCommission += _dailyNodeRewCom;
                        userMap[_sponsor].stats.totalDailyNodeRewardCommission += _dailyNodeRewCom;
                        emit dailyNodeRewardCommissionEvent(
                            _investorAddress,
                            _sponsor,
                            _dailyNodeRewCom,
                            block.timestamp
                        );
                    }
                }
            } else {
                break;
            }
            _sponsor = userMap[_sponsor].referrer;
        }
    }

    /// @notice function that returns the Daily Node Reward (DNR), which is 1% daily of currInvestment, until 300% reached
    /// @dev called by view (getUnclaimedEarningsbyAddress) or by withdrawEarnings()
    /// @param _investorAddr the investor's address for which DNR wille calculated and returned
    function getDailyNodeReward(address _investorAddr) external view returns (uint256 _dailyNodeReward) {
        // Calculate how many DNR (1% daily) have accumulated up until this point in time.
        /// @notice assign variables to memory
        uint256 _currInvestment = userMap[_investorAddr].investment.currInvestment;
        uint256 _currInvestDepositTime = userMap[_investorAddr].investment.currInvestmentDepositTime;
        uint256 _incomeWithdrawn = userMap[_investorAddr].investment.incomeWithdrawn;
        uint256 _incomeLimitLeft = userMap[_investorAddr].investment.incomeLimitLeft;
        uint256 _blockTimestamp = block.timestamp;

        /// @notice define daily multiplier
        uint256 _multiplier = (_blockTimestamp - _currInvestDepositTime) / 24 hours;
        _dailyNodeReward = ((_currInvestment * _multiplier) / 100) - _incomeWithdrawn;

        if ((_incomeWithdrawn + _dailyNodeReward) > _incomeLimitLeft) {
            _dailyNodeReward = _incomeLimitLeft;
        }
    }

    /// @dev nonReentrant protects from re-entrancy attacks
    /// @notice withdrawal function called by registered users to receive their payout
    function withdrawEarnings() public nonReentrant {
        require(userMap[msg.sender].investment.incomeLimitLeft > 0, "No more income left");

        uint256 _payout = this.getDailyNodeReward(msg.sender);

        /// @notice DailyNodeRewards
        /// @dev this means the currInvestment * 3 has not been reached yet.
        if (_payout > 0) {
            /// @notice The User did not yet reach 300% in payouts
            /// @dev now we add the _payout to the withdrawn amount
            userMap[msg.sender].investment.incomeWithdrawn += _payout;
            /// @dev we subtract the _payout from the limit that is left
            userMap[msg.sender].investment.incomeLimitLeft -= _payout;

            /// @dev trigger the Daily Node Reward Commission
            distributeDailyNodeRewardCommission(msg.sender, _payout);
        }

        /// @notice Direct Referral Commission (DRC) (one-time commission for partners invited by msg.sender)
        if (
            userMap[msg.sender].investment.incomeLimitLeft > 0 &&
            userMap[msg.sender].investment.directReferralCommission > 0
        ) {
            uint256 _directRefCom = userMap[msg.sender].investment.directReferralCommission;

            /// @dev If the DRC is larger than the incomeLimitLeft, 300% are reached immediately
            if (_directRefCom > userMap[msg.sender].investment.incomeLimitLeft) {
                // This assignment assures that nobody can pay out more than 300%
                _directRefCom = userMap[msg.sender].investment.incomeLimitLeft;
            }
            /// @dev Subtract _directRefCom from *.directReferralCommission because it is being paid out
            userMap[msg.sender].investment.directReferralCommission -= _directRefCom;
            /// @dev Subtract _directRefCom from *.incomeLimitLeft because it is being paid out
            userMap[msg.sender].investment.incomeLimitLeft -= _directRefCom;
            /// @dev Add _directRefCom to the _payout
            _payout += _directRefCom;
        }

        /// @notice Daily Node Rewards Commission (recurring commission for partners invited by msg.sender)
        if (
            userMap[msg.sender].investment.incomeLimitLeft > 0 &&
            userMap[msg.sender].investment.dailyNodeRewardCommission > 0
        ) {
            uint256 _dnrCom = userMap[msg.sender].investment.dailyNodeRewardCommission;
            /// @dev If the DNR Commission is larger than the incomeLimitLeft, 300% are reached immediately
            if (_dnrCom > userMap[msg.sender].investment.incomeLimitLeft) {
                // This assignment assures that nobody can pay out more than 300%
                _dnrCom = userMap[msg.sender].investment.incomeLimitLeft;
            }

            /// @dev Subtract _dnrCom from *.daily because it is being paid out
            userMap[msg.sender].investment.dailyNodeRewardCommission -= _dnrCom;
            /// @dev Subtract _dnrCom from *.incomeLimitLeft because it is being paid out
            userMap[msg.sender].investment.incomeLimitLeft -= _dnrCom;
            /// @dev Add _dnrCom to the _payout
            _payout += _dnrCom;
        }

        /// @notice Daily Top Sponsor Pool Bonus
        if (
            userMap[msg.sender].investment.incomeLimitLeft > 0 &&
            userMap[msg.sender].investment.dailyTopSponsorBonus > 0
        ) {
            uint256 _dtsBonus = userMap[msg.sender].investment.dailyTopSponsorBonus;
            /// @dev If the dailyTopSponsorBonus is larger than the incomeLimitLeft, 300% are reached immediately
            if (_dtsBonus > userMap[msg.sender].investment.incomeLimitLeft) {
                // This assignment assures that nobody can pay out more than 300%
                _dtsBonus = userMap[msg.sender].investment.incomeLimitLeft;
            }

            /// @dev Subtract _dtsBonus from *.daily because it is being paid out
            userMap[msg.sender].investment.dailyTopSponsorBonus -= _dtsBonus;
            /// @dev Subtract _dtsBonus from *.incomeLimitLeft because it is being paid out
            userMap[msg.sender].investment.incomeLimitLeft -= _dtsBonus;
            /// @dev Add _dtsBonus to the _payout
            _payout += _dtsBonus;
        }

        /// @notice Daily Whale Pool
        if (
            userMap[msg.sender].investment.incomeLimitLeft > 0 &&
            userMap[msg.sender].investment.dailyWhaleBonus > 0
        ) {
            uint256 _dwBonus = userMap[msg.sender].investment.dailyWhaleBonus;
            /// @dev If the dailyTopSponsorBonus is larger than the incomeLimitLeft, 300% are reached immediately
            if (_dwBonus > userMap[msg.sender].investment.incomeLimitLeft) {
                // This assignment assures that nobody can pay out more than 300%
                _dwBonus = userMap[msg.sender].investment.incomeLimitLeft;
            }

            /// @dev Subtract _dwBonus from *.daily because it is being paid out
            userMap[msg.sender].investment.dailyWhaleBonus -= _dwBonus;
            /// @dev Subtract _dwBonus from *.incomeLimitLeft because it is being paid out
            userMap[msg.sender].investment.incomeLimitLeft -= _dwBonus;
            /// @dev Add _dtsBonus to the _payout
            _payout += _dwBonus;
        }

        /// @dev make sure payout is larger than 0
        require(_payout > 0, "Payout needs to be larger than 0");

        /// @dev increase totalEarnings for msg.sender
        userMap[msg.sender].totalEarnings += _payout;

        /// @dev Sets correct amount of currentInvestmentWithdrawn
        userMap[msg.sender].investment.currInvestmentWithdrawn += _payout;

        /// @dev Increases total amount of withdrawal
        totalWithdrawals += _payout;
        address payable _senderAddr = payable(msg.sender);
        _senderAddr.transfer(_payout);

        /// @dev emit withdrawalEvent
        emit withdrawalEvent(msg.sender, _payout, block.timestamp);
    }

    /// @notice function to award whales (if there are any) after every daily round
    /// @dev called on every "startNexRound" (if more than 24hours passed from previous round)
    function awardWhales() private {
        uint256 _totalWhales = whales.length;
        uint256 _toPayout = dailyRounds[roundID].whalepool / _totalWhales;

        for (uint256 i = 0; i < _totalWhales; i++) {
            userMap[whales[i]].investment.dailyWhaleBonus += _toPayout;
            userMap[whales[i]].stats.totalDailyWhaleBonus += _toPayout;
            emit dailyWhaleBonusEvent(whales[i], _toPayout, block.timestamp);
        }
        dailyRounds[roundID].whalepool = 0;
    }

    /// @notice function to award top sponsors after every daily round
    /// @dev called on every "startNexRound" (if more than 24hours passed from previous round)
    /// @return _distributedAmount is the sum of the individual distributed top sponsor pool amounts
    function awardTopSponsors() private returns (uint256 _distributedAmount) {
        uint256 _totalAmount = (dailyRounds[roundID].pool * DAILY_TOP_SPONSOR_POOL_DISTRIBUTION_PERCENT) /
            100;

        for (uint256 i = 0; i < 4; i++) {
            if (topSponsors[i]._address != address(0x0)) {
                uint256 bonus = ((_totalAmount * DTSBonusPercentage[i]) / 100);
                userMap[topSponsors[i]._address].investment.dailyTopSponsorBonus += bonus;
                userMap[topSponsors[i]._address].stats.totalDailyTopSponsorBonus += bonus;

                _distributedAmount += bonus;
                emit dailyTopSponsorBonusEvent(topSponsors[i]._address, bonus, block.timestamp);

                lastTopSponsors[i]._address = topSponsors[i]._address;
                lastTopSponsors[i]._amount = topSponsors[i]._amount;
                lastTopSponsorsWinningAmount[i] = bonus;

                /// @dev resets the topSponsor slot i
                topSponsors[i]._address = address(0x0);
                topSponsors[i]._amount = 0;
            } else {
                break;
            }
        }
        return _distributedAmount;
    }

    /// @dev view returns unclaimed earnings of address
    function getUnclaimedEarningsByAddress(address _investorAddress) public view returns (uint256 _amount) {
        require(_investorAddress != address(0x0), "Address is zero");

        uint256 _unclaimedEarnings = this.getDailyNodeReward(_investorAddress);

        if (_unclaimedEarnings > 0) {
            /// @notice The User did not yet reach 300% in payouts
            if (_unclaimedEarnings > userMap[_investorAddress].investment.incomeLimitLeft) {
                _unclaimedEarnings = userMap[_investorAddress].investment.incomeLimitLeft;
                /// @notice this should not be reached in fact. check whether this invariant is ever reached.
            }
        }

        /// @notice Direct Referral Commission (DRC) (one-time commission for partners invited by msg.sender)
        if (
            userMap[_investorAddress].investment.incomeLimitLeft > 0 &&
            userMap[_investorAddress].investment.directReferralCommission > 0
        ) {
            uint256 _directRefCom = userMap[_investorAddress].investment.directReferralCommission;

            /// @dev If the DRC is larger than the incomeLimitLeft, 300% are reached immediately
            if (_directRefCom > userMap[_investorAddress].investment.incomeLimitLeft) {
                // This assignment assures that nobody can pay out more than 300%
                _directRefCom = userMap[_investorAddress].investment.incomeLimitLeft;
            }
            /// @dev Add _directRefCom to the _unclaimedEarnings
            _unclaimedEarnings += _directRefCom;
        }

        /// @notice Daily Node Rewards Commission (recurring commission for partners invited by msg.sender)
        if (
            userMap[_investorAddress].investment.incomeLimitLeft > 0 &&
            userMap[_investorAddress].investment.dailyNodeRewardCommission > 0
        ) {
            uint256 _dnrCom = userMap[_investorAddress].investment.dailyNodeRewardCommission;
            /// @dev If the DNR Commission is larger than the incomeLimitLeft, 300% are reached immediately
            if (_dnrCom > userMap[_investorAddress].investment.incomeLimitLeft) {
                // This assignment assures that nobody can pay out more than 300%
                _dnrCom = userMap[_investorAddress].investment.incomeLimitLeft;
            }
            /// @dev Add _dnrCom to the _unclaimedEarnings
            _unclaimedEarnings += _dnrCom;
        }

        /// @notice Daily Top Sponsor Pool Bonus
        if (
            userMap[_investorAddress].investment.incomeLimitLeft > 0 &&
            userMap[_investorAddress].investment.dailyTopSponsorBonus > 0
        ) {
            uint256 _dtsBonus = userMap[_investorAddress].investment.dailyTopSponsorBonus;
            /// @dev If the dailyTopSponsorBonus is larger than the incomeLimitLeft, 300% are reached immediately
            if (_dtsBonus > userMap[_investorAddress].investment.incomeLimitLeft) {
                // This assignment assures that nobody can pay out more than 300%
                _dtsBonus = userMap[_investorAddress].investment.incomeLimitLeft;
            }
            /// @dev Add _dtsBonus to the _unclaimedEarnings
            _unclaimedEarnings += _dtsBonus;
        }

        /// @notice Daily Whale Pool
        if (
            userMap[_investorAddress].investment.incomeLimitLeft > 0 &&
            userMap[_investorAddress].investment.dailyWhaleBonus > 0
        ) {
            uint256 _dwBonus = userMap[_investorAddress].investment.dailyWhaleBonus;
            /// @dev If the dailyTopSponsorBonus is larger than the incomeLimitLeft, 300% are reached immediately
            if (_dwBonus > userMap[_investorAddress].investment.incomeLimitLeft) {
                // This assignment assures that nobody can pay out more than 300%
                _dwBonus = userMap[_investorAddress].investment.incomeLimitLeft;
            }

            /// @dev Add _dtsBonus to the _unclaimedEarnings
            _unclaimedEarnings += _dwBonus;
        }

        /// @dev make sure payout is larger than 0
        return _unclaimedEarnings;
    }

    /// @dev memory call returning rank associated to investment amount
    function getRank(uint256 _amount) external pure returns (string memory) {
        require(_amount > 0, "Amount cannot be zero");
        require(_amount >= MIN_INVEST, "Amount must be larger or equal MIN_INVEST");

        string memory _rank;

        /// @dev just needs one check because
        if (_amount < 1 ether) {
            _rank = "STARTER";
        } else if (_amount < 5 ether) {
            _rank = "SHRIMP";
        } else if (_amount < 10 ether) {
            _rank = "CRAB";
        } else if (_amount < 25 ether) {
            _rank = "OCTOPUS";
        } else if (_amount < 50 ether) {
            _rank = "FISH";
        } else if (_amount < 100 ether) {
            _rank = "DOLPHIN";
        } else if (_amount < 250 ether) {
            _rank = "SHARK";
        } else if (_amount >= 250 ether) {
            _rank = "WHALE";
        }

        return _rank;
    }

    /// @dev view returning the income limit left of address
    function getIncomeLimitLeft(address _investorAddr) external view returns (uint256 _incomeLimitLeft) {
        require(_investorAddr != address(0x0), "Investor address is zero");
        return userMap[_investorAddr].investment.incomeLimitLeft;
    }

    /// @dev view returning rank of specific investor
    function getRankOf(address _investorAddr) external view returns (string memory) {
        require(_investorAddr != address(0x0), "Investor address is zero");
        return userMap[_investorAddr].rank;
    }

    /// @dev view returning amount of whales
    function getWhaleCount() external view returns (uint256 size) {
        return whales.length;
    }

    /// @dev view returning current investment cycle
    function getCurrentInvestmentCycle(
        address _investorAddr
    ) external view returns (uint256 _CurrInvestmentCycle) {
        require(_investorAddr != address(0x0), "Investor address is zero");
        return userMap[_investorAddr].investment.currInvestmentCycle;
    }

    /// @dev view returning address associated to ID
    function getAddressByID(uint _id) public view returns (address _address) {
        require(_id <= currentUserID, "Can not be larger than currentUserID");
        return addressMap[_id];
    }

    /// @dev view returning ID associated to address
    function getIDByAddress(address _address) public view returns (uint _id) {
        require(_address != address(0x0), "Can not get zero address");
        return userMap[_address].id;
    }

    /// @dev returns (a) direct partners / sponsors (referralcount) and
    /// @dev returns (b) active nodes of direct partners / sponsors (sum of currinvest divided by cost per node of all partners)
    function getStatsOfPartners(
        address _address
    ) public view returns (uint256 _referralCount, uint256 _activeNodes) {
        require(_address != address(0x0), "Investor address is zero");
        /// @dev Loops through all users, if referrer is _address, divides their investment by MIN_INVEST and adds to _activeNodes
        for (uint256 i = 0; i < currentUserID; i++) {
            if (userMap[getAddressByID(i)].referrer == _address) {
                // We divide by MIN_INVEST (cost per node), which should return the active nodes
                _activeNodes += (userMap[getAddressByID(i)].investment.currInvestment / MIN_INVEST);
            }
        }
        /// @dev returns referralcount of _address, plus the sum of all activeNodes (from loop above)
        return (userMap[_address].referralCount, _activeNodes);
    }

    /// @dev returns the Return On Investment (RoI)
    /// @dev ratio of incomeLimitLeft minus claimable to 3 * currInvest
    /// @dev max return 300%
    function getROI(address _address) public view returns (int256 _roiPercentage) {
        require(_address != address(0x0), "Investor address is zero");

        int256 _roiInWei;
        int256 _maxROIinWei;
        bool _isWhale;
        // there's no string comparison, but this checks whether the investment is WHALE level
        if (
            userMap[_address].investment.currInvestment >= WHALE_RANK_AMOUNT ||
            userMap[_address].investment.currInvestmentCycle >= 4
        ) {
            _maxROIinWei = int(userMap[_address].investment.currInvestment * 2);
            _isWhale = true;
        } else {
            _maxROIinWei = int(userMap[_address].investment.currInvestment * 3);
        }

        int256 _incomeLimitLeftInWei = int(userMap[_address].investment.incomeLimitLeft);
        int256 _claimableInWei = int(getUnclaimedEarningsByAddress(_address));

        // Meaning that the claimable amount will be so much that ROI is reached
        if (_incomeLimitLeftInWei - _claimableInWei <= 0) {
            _roiInWei = _maxROIinWei;
            if (_isWhale) {
                _roiPercentage = 200;
            } else {
                _roiPercentage = 300;
            }
        } else {
            // incomeLimitLeft minus claimable will give the actual incomeLimitLeft value in wei
            // minus maxROIInWei will return the actual _roiInWei
            _roiInWei = _maxROIinWei - (_incomeLimitLeftInWei - _claimableInWei);

            if (_isWhale) {
                _roiPercentage = _roiInWei / (_maxROIinWei / 200);
            } else {
                _roiPercentage = _roiInWei / (_maxROIinWei / 300);
            }

            // _roiInWei;
            if (_roiInWei < 0) {
                _roiInWei = _maxROIinWei;
                if (_isWhale) {
                    _roiPercentage = 200;
                } else {
                    _roiPercentage = 300;
                }
            }
        }

        return (_roiPercentage);
    }

    function getUnclaimedEarningsByRef(uint _id) public view returns (uint256 _amount) {
        require(_id >= currentUserID, "ID does not exist");
        return this.getUnclaimedEarningsByAddress(this.getAddressByID(_id));
    }
}