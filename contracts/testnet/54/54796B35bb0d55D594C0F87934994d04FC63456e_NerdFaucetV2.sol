/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;



// Part: IFaucet

interface IFaucet {
    function accounting(address _user)
        external
        view
        returns (
            uint256 netFaucet, // User level NetFaucetValue
            // Detail of netFaucet
            uint256 deposits, // Hard Deposits made
            uint256 rolls, // faucet Compounds
            uint256 rebaseCompounded, // RebaseCompounds
            uint256 airdrops_rcv, // Received Airdrops
            uint256 accFaucet, // accumulated but not claimed faucet due to referrals
            uint256 accRebase, // accumulated but not claimed rebases
            // Total Claims
            uint256 faucetClaims,
            uint256 rebaseClaims,
            uint256 rebaseCount,
            uint256 lastAction,
            bool done
        );

    function team(address _user)
        external
        view
        returns (
            uint256 referrals, // People referred
            address upline, // Who my referrer is
            uint256 upline_set, // Last time referrer set
            uint256 refClaimRound, // Whose turn it is to claim referral rewards
            uint256 match_bonus, // round robin distributed
            uint256 lastAirdropSent,
            uint256 airdrops_sent,
            uint256 structure, // Total users under structure
            uint256 maxDownline,
            // Team Swap
            uint256 referralsToUpdate, // Users who haven't updated if team was switched
            address prevUpline, // If updated team, who the previous upline user was to switch user's referrals
            uint256 leaders
        );

    function deposit(uint256 amount, address upline) external;

    function claim() external;

    function switchTeam(address _newUpline) external;

    function checkVault()
        external
        view
        returns (
            uint256 _status,
            uint256 _needs,
            uint256 _threshold,
            uint256 _vaultBalance
        );

    //----------------------------------------------
    //                  EVENTS                    //
    //----------------------------------------------
    event NewDeposit(address indexed _user, uint256 amount);
    event ReferralPayout(
        address indexed _upline,
        address indexed _teammate,
        uint256 amount
    );
    event DirectPayout(
        address indexed addr,
        address indexed from,
        uint256 amount
    );
    event MatchPayout(
        address indexed addr,
        address indexed from,
        uint256 amount
    );
    event NewAirdrop(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 timestamp
    );
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
}

// Part: IToken

interface IToken {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mint(uint256 amount) external;

    function balanceOf(address _user) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    /**
     @return taxAmount // total Tax Amount
     @return taxType // How the tax will be distributed
    */
    function calculateTransferTax(
        address from,
        address to,
        uint256 amount
    ) external returns (uint256 taxAmount, uint8 taxType);

    function approve(address spender, uint256 amount) external returns (bool);
}

// Part: IVault

interface IVault {
    /**
    * @param amount total amount of tokens to recevie
    * @param _type type of spread to execute.
      Stake Vault - Reservoir Collateral - Treasury
      0: do nothing
      1: Buy Spread 5 - 5 - 3
      2: Sell Spread 5 - 5 - 8
    * @param _customTaxSender the address where the tax is originated from.
      @return bool as successful spread op
    **/
    function spread(
        uint256 amount,
        uint8 _type,
        address _customTaxSender
    ) external returns (bool);

    function withdraw(address _address, uint256 amount) external;

    function withdraw(uint256 amount) external;
}

// Part: OpenZeppelin/[email protected]/Context

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

// Part: OpenZeppelin/[email protected]/Ownable

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

// File: NerdFaucetV2.sol

contract NerdFaucetV2 is Ownable, IFaucet {
    struct Accounting {
        uint256 netFaucet; // User level NetFaucetValue
        // Detail of netFaucet
        uint256 deposits; // Hard Deposits made
        uint256 rolls; // faucet Compounds
        uint256 rebaseCompounded; // RebaseCompounds
        uint256 airdrops_rcv; // Received Airdrops
        uint256 accFaucet; // accumulated but not claimed faucet due to referrals
        uint256 accRebase; // accumulated but not claimed rebases
        // Total Claims
        uint256 faucetClaims;
        uint256 rebaseClaims;
        uint256 rebaseCount;
        uint256 lastAction;
        bool done;
    }

    struct Team {
        uint256 referrals; // People referred
        address upline; // Who my referrer is
        uint256 upline_set; // Last time referrer set
        uint256 refClaimRound; // Whose turn it is to claim referral rewards
        uint256 match_bonus; // round robin distributed
        uint256 lastAirdropSent;
        uint256 airdrops_sent;
        uint256 structure; // Total users under structure
        uint256 maxDownline;
        // Team Swap
        uint256 referralsToUpdate; // Users who haven't updated if team was switched
        address prevUpline; // If updated team, who the previous upline user was to switch user's referrals
        uint256 leaders;
    }
    struct LeaderReset {
        uint8 resets;
        uint8 lastResetLvl;
        bool migrated;
    }

    struct KickbackReq {
        uint256 directReferrals;
        uint256 directTeamLeaders;
        uint256 structureTotal;
    }

    //----------------------------------------------
    //             Global Variables               //
    //----------------------------------------------
    uint256 public immutable start;
    uint256 public rebases;
    uint256 public constant REBASE_TIMER = 30 minutes;
    // Global stats
    uint256 public total_deposits;
    uint256 public total_claims;
    uint256 public total_airdrops;
    uint256 public total_users;
    uint256 public accLiability;

    address public token;
    address public govToken;
    address public vault;
    address public lottery;
    address public leaderDrops;

    uint256 public faucetWhaleBracket;
    uint256 public maxWhaleBracket = 10;
    uint8 public maxRefDepth;
    bool public needToMint;
    bool public leadOrLotto = false;

    // MINT FACTORS
    uint256 public dayFactor;
    uint256 public lowMint;
    uint256 public highMint;
    uint256 public constant DIVFACTOR = 1000000;

    uint256 public minimumInitial = 10 ether;

    uint256[] public govLevelHold;
    uint8[] public kickback;
    uint8 public uplineUpdater;
    mapping(address => Accounting) public accounting;
    mapping(address => Team) public team;
    mapping(uint8 => KickbackReq) public req;
    mapping(address => LeaderReset) public leaders;

    IFaucet public prevFaucet;

    //----------------------------------------------
    //                   EVENTS                   //
    //----------------------------------------------
    event AddLotteryFunds(uint256 amount);
    event UplineChanged(
        address indexed _newUpline,
        address indexed _user,
        address indexed _prevUpline
    );
    event Airdrop(
        address indexed _sender,
        address indexed _receiver,
        uint256 amount
    );
    event ModRequirements(
        uint8 indexed _level,
        uint256 _newDirect,
        uint256 _directLeaders,
        uint256 _structureTotal
    );
    event ResetLeader(
        address indexed _leader,
        uint256 _resetCount,
        uint256 _level
    );
    event FlameHoldLevelTweak(uint8 _index, uint256 _amount);
    event UplineAdded(address indexed _upline, address indexed _user);

    event Deposit(address indexed _user, uint256 _total, uint256 _realized);

    event FaucetCompound(
        address indexed _user,
        uint256 _total,
        uint256 _realized
    );
    event FaucetClaim(address indexed _user, uint256 _amount);
    event RebaseCompound(
        address indexed _user,
        uint256 _amount,
        uint256 _realized
    );
    event RebaseClaim(address indexed _user, uint256 amount);

    event UplineAidrop(
        address indexed _triggered,
        address indexed _upline,
        uint8 downline,
        uint256 amount
    );
    event LogEvent(string _event, uint256 _value, address _add);

    //----------------------------------------------
    //              CONSTRUCTOR FNS               //
    //----------------------------------------------
    constructor(
        address _token,
        address _vault,
        address _govToken,
        address _leaderDrops,
        address _prevFaucet
    ) {
        prevFaucet = IFaucet(_prevFaucet);
        token = _token;
        vault = _vault;
        leaderDrops = _leaderDrops;
        start = 1654549200;
        faucetWhaleBracket = 7500 ether; // 1% of Total Supply
        maxRefDepth = 15; // 15 levels deep max
        uint256 prev1Num = 1 ether;
        uint256 prev2Num = 2 ether;
        // Initial Factors
        dayFactor = 21; // 21 days
        lowMint = 670000; // 0.67
        highMint = 500000; // 0.5
        govToken = _govToken;
        kickback.push(0);
        kickback.push(1);
        kickback.push(5);
        kickback.push(10);
        kickback.push(15);
        kickback.push(20);
        //Fibonacci... hardcoding it would be a pain
        for (uint8 i = 0; i < maxRefDepth; i++) {
            if (i == 0) {
                govLevelHold.push(2 ether);
            } else {
                govLevelHold.push(prev1Num + prev2Num);
                prev2Num = prev2Num + prev1Num;
                prev1Num = prev2Num - prev1Num;
            }
        }
        req[1] = KickbackReq(5, 0, 0);
        req[2] = KickbackReq(10, 0, 0);
        req[3] = KickbackReq(10, 10, 500);
        req[4] = KickbackReq(10, 15, 2500);
        req[5] = KickbackReq(10, 25, 5000);
        req[6] = KickbackReq(10, 50, 10000);
    }

    //----------------------------------------------
    //                 USER FNS                   //
    //----------------------------------------------
    function deposit(uint256 _amount, address _upline) public {
        address _user = msg.sender;
        Accounting storage user = accounting[_user];
        require(
            user.faucetClaims + user.rebaseClaims < capPayout(),
            "Need a reset"
        );
        if (user.done) user.done = false;
        if (user.deposits == 0) {
            total_users++;
            require(_amount >= minimumInitial, "Initial not met");
            user.rebaseCount = getTotalRebaseCount() + 1;
        }
        //HANDLE TOKEN INFO
        (uint256 realizedAmount, ) = IToken(token).calculateTransferTax(
            _user,
            vault,
            _amount
        );
        realizedAmount = _amount - realizedAmount;
        total_deposits += realizedAmount;
        removeLiability(_user);
        //HANDLE TEAM Set
        firstUpline(_user, _upline);
        // Compound all
        uint256 rebaseComp = claimRebase(msg.sender, false, true, true);
        claimFaucet(true, rebaseComp + realizedAmount, true);

        //TRANSFER TOKENS
        require(
            IToken(token).transferFrom(_user, vault, _amount),
            "Transfer failed"
        );
        emit Deposit(_user, _amount, realizedAmount);
        user.deposits += realizedAmount;
        updateNetFaucet(_user);
        user.lastAction = block.timestamp;
        addLiability(_user);
    }

    /// @notice Claims both rebase and faucet
    function claim() external {
        uint256 _payout;
        removeLiability(msg.sender);
        _payout += claimRebase(msg.sender, false, false, false);
        _payout += claimFaucet(false, 0, false);
        payoutUser(msg.sender, _payout);
        addLiability(msg.sender);
    }

    function compoundAll() external {
        uint256 _payout;
        removeLiability(msg.sender);
        _payout += claimRebase(msg.sender, false, true, false);
        claimFaucet(true, _payout, false);
        addLiability(msg.sender);
    }

    function compoundFaucet() external {
        removeLiability(msg.sender);
        claimRebase(msg.sender, true, false, false);
        claimFaucet(true, 0, false);
        addLiability(msg.sender);
    }

    function compoundRebase() external {
        removeLiability(msg.sender);
        uint256 compounded = claimRebase(msg.sender, false, true, false);
        spreadReferrals(msg.sender, compounded, 5);
        addLiability(msg.sender);
    }

    function rebaseClaim() external {
        removeLiability(msg.sender);
        uint256 _payout = claimRebase(msg.sender, false, false, false);
        payoutUser(msg.sender, _payout);
        addLiability(msg.sender);
    }

    function faucetClaim() external {
        removeLiability(msg.sender);
        claimRebase(msg.sender, true, false, false);
        uint256 _payout = claimFaucet(false, 0, false);
        payoutUser(msg.sender, _payout);
        addLiability(msg.sender);
    }

    function switchTeam(address _newUpline) external {
        address _user = msg.sender;
        require(
            team[_user].prevUpline == address(0),
            "Can't switch more than once"
        );
        require(
            _newUpline != _user &&
                _newUpline != address(0) &&
                _user != owner() &&
                accounting[_newUpline].deposits > 0 &&
                accounting[_newUpline].lastAction > 0,
            "Invalid upline"
        );
        uint256 switchFee = accounting[_user].airdrops_rcv / 10;
        switchFee = switchFee > 50 ether ? 50 ether : switchFee;
        bool succ = IToken(token).transferFrom(_user, vault, switchFee);
        require(succ, "Error in fee");
        Team storage _team = team[_user];
        _team.prevUpline = _team.upline;
        _team.referralsToUpdate = _team.referrals;
        // Remove referral from Upline
        team[_team.upline].referrals--;
        address _prevUp = team[_user].upline;
        team[_user].structure = 0;
        emit UplineChanged(_newUpline, _user, _prevUp);
        for (uint8 i = 0; i < maxRefDepth; i++) {
            if (_prevUp == address(0)) break;
            team[_prevUp].structure--;
            _prevUp = team[_prevUp].upline;
        }
        setUpline(_user, _newUpline, false);
    }

    function airdrop(
        address _receiver,
        uint256 _amount,
        uint8 _level
    ) public {
        // CALCULATE TAXED VALUE
        (uint256 realizedAmount, ) = IToken(token).calculateTransferTax(
            msg.sender,
            vault,
            _amount
        );
        realizedAmount = _amount - realizedAmount;
        //TRANSFER TAXED TOKENS
        require(
            IToken(token).transferFrom(msg.sender, vault, _amount),
            "airdrop failed"
        );
        //ACCUMULATE PAYOUTS
        Team storage teamLeader = team[msg.sender];
        Accounting storage leader = accounting[msg.sender];
        Accounting storage user = accounting[_receiver];
        claimRebase(_receiver, true, false, false);
        (uint256 grossPayout, , , ) = faucetPayout(_receiver);
        user.accFaucet = grossPayout;
        // KICKBACK Calculation
        uint256 leaderKick = 0;
        if (_level > 1) {
            // level 0 does not exist, level 1 is base level and works only on referral giveouts
            uint8 currentLevel = userLevel(msg.sender);
            require(currentLevel >= _level, "Invalid Level");
            leaderKick = (realizedAmount * kickback[_level]) / 100;
        }
        //SPLIT AIRDROPS
        removeLiability(_receiver);
        user.airdrops_rcv += realizedAmount - leaderKick;
        addLiability(_receiver);
        user.lastAction = block.timestamp;
        updateNetFaucet(_receiver);
        teamLeader.airdrops_sent += _amount;
        teamLeader.lastAirdropSent = block.timestamp;
        if (leaderKick > 0) {
            removeLiability(msg.sender);
            leader.airdrops_rcv += leaderKick;
            updateNetFaucet(msg.sender);
            addLiability(msg.sender);
        }
        total_airdrops += realizedAmount;
        // USER AIRDROPPED
        emit Airdrop(msg.sender, _receiver, realizedAmount);
    }

    function leaderReset(uint256 _depositAmount) external {
        require(team[msg.sender].upline == owner(), "Are you leader?");
        LeaderReset storage _lead = leaders[msg.sender];
        uint8 level = userLevel(msg.sender);
        require(_lead.resets < 5 && _lead.lastResetLvl < 6, "Max Resets");
        if (leaders[msg.sender].resets == 0) {
            require(level >= 3, "Min Level 3");
        }
        _lead.lastResetLvl = level;
        _lead.resets++;
        require(accounting[msg.sender].done, "Keep playing");
        uint256 cap = capPayout();
        uint256 minDeposit = (cap * _lead.resets) / (100);
        require(
            _depositAmount > minDeposit &&
                _depositAmount - minDeposit > minimumInitial,
            "Not enough funds"
        );

        Accounting storage userAcc = accounting[msg.sender];
        userAcc.netFaucet = 1;
        userAcc.deposits = 1;
        userAcc.rolls = 0;
        userAcc.airdrops_rcv = 0;
        userAcc.accFaucet = 0;
        userAcc.accRebase = 0;
        userAcc.faucetClaims = 0;
        userAcc.rebaseCount = getTotalRebaseCount() + 1;
        userAcc.lastAction = block.timestamp;
        userAcc.done = false;
        // Transfer reset Tax to Vault
        bool succ = IToken(token).transferFrom(msg.sender, vault, minDeposit);
        require(succ, "Transfer Success");
        deposit(_depositAmount - minDeposit, owner());
        emit ResetLeader(msg.sender, _lead.resets, _lead.lastResetLvl);
    }

    function migrate(address _user) external onlyOwner {
        require(!leaders[_user].migrated, "Already migrated");
        leaders[_user].migrated = true;
        migrateAcc(_user);
        migrateTeam(_user);
        // Migrate but stats aren't updated if there are no deposits
        if (accounting[_user].deposits == 0) return;
        total_deposits += accounting[_user].deposits;
        total_claims +=
            accounting[_user].faucetClaims +
            accounting[_user].rebaseClaims;
        total_airdrops += team[_user].airdrops_sent;
        total_users++;
        addLiability(_user);
    }

    function migrateAcc(address _user) internal {
        Accounting storage user = accounting[_user];
        (
            uint256 netFaucet,
            uint256 deposits,
            uint256 rolls,
            uint256 rebaseCompounded,
            uint256 airdrops_rcv,
            uint256 _acc,
            uint256 accRebase,
            uint256 faucetClaims,
            uint256 rebaseClaims,
            uint256 rebaseCount,
            uint256 lastAction,
            bool done
        ) = prevFaucet.accounting(_user);
        bool gotMore = (faucetClaims + rebaseClaims) > ((netFaucet * 3) / 100);
        user.accFaucet = gotMore ? 0 : _acc;
        user.netFaucet = netFaucet;
        user.deposits = deposits;
        user.rolls = rolls;
        user.rebaseCompounded = rebaseCompounded;
        user.airdrops_rcv = airdrops_rcv;
        user.accRebase = gotMore ? 0 : accRebase;
        user.faucetClaims = faucetClaims;
        user.rebaseClaims = rebaseClaims;
        user.rebaseCount = rebaseCount;
        user.lastAction = lastAction;
        user.done = done;
    }

    function migrateTeam(address _user) internal {
        Team storage user = team[_user];
        (
            uint256 referrals,
            address upline,
            uint256 upline_set,
            uint256 refClaimRound,
            uint256 match_bonus,
            uint256 lastAirdropSent,
            uint256 airdrops_sent,
            uint256 structure,
            uint256 maxDownline,
            uint256 referralsToUpdate,
            address prevUpline,
            uint256 _teamLeads
        ) = prevFaucet.team(_user);

        user.referrals = referrals;
        user.upline = upline;
        user.upline_set = upline_set;
        user.refClaimRound = refClaimRound;
        user.match_bonus = match_bonus;
        user.lastAirdropSent = lastAirdropSent;
        user.airdrops_sent = airdrops_sent;
        user.structure = structure;
        user.maxDownline = maxDownline;
        user.referralsToUpdate = referralsToUpdate;
        user.prevUpline = prevUpline;
        user.leaders = _teamLeads;
    }

    //----------------------------------------------
    //         EXTERNAL/PUBLIC VIEW FNS           //
    //----------------------------------------------

    function getNerdData(address _user)
        public
        view
        returns (
            uint256 _grossClaimed,
            int256 _netDeposits,
            uint256 _netFaucetValue,
            uint256 _grossFaucetValue,
            uint256 _faucetPayout, // User's available faucet payout
            uint256 _faucetMaxPayout, // User's max faucet payout
            uint256 _rebasePayout, // User's available rebase payout
            int256 _nerdPercent
        )
    {
        Accounting storage user = accounting[_user];

        _grossClaimed = user.faucetClaims + user.rebaseClaims;
        _netFaucetValue = user.netFaucet;
        _netDeposits = (int256)(_netFaucetValue) - (int256)(_grossClaimed);
        if (!user.done)
            (, _rebasePayout, , _nerdPercent) = getUserAdjustedRebase(
                _netFaucetValue,
                _grossClaimed,
                user.rebaseCompounded,
                user.rebaseCount
            );
        _rebasePayout += user.accRebase;
        _grossFaucetValue = _netFaucetValue + user.rebaseCompounded;
        uint256 sustainableFee;
        uint256 grossPayout;
        (
            grossPayout,
            _faucetMaxPayout,
            _faucetPayout,
            sustainableFee
        ) = faucetPayout(_user);
        // If there are any whale taxes, apply those to the rebasePayout
        if (sustainableFee > 0 && _rebasePayout > 0) {
            _rebasePayout =
                (_rebasePayout * (grossPayout - sustainableFee)) /
                grossPayout;
        }
    }

    function getUserAdjustedRebase(
        uint256 _nfv,
        uint256 _gc,
        uint256 _compoundedRebase,
        uint256 _userRebases
    )
        public
        view
        returns (
            uint256 _totalRebase,
            uint256 _userRebase,
            uint256 _totalRebaseCount,
            int256 _percent
        )
    {
        if (_nfv == 0) _nfv = 1;
        int256 playable = (int256)(_nfv) - (int256)(_gc);
        _percent = (playable * 1000000) / (int256)(_nfv);

        _totalRebaseCount = getTotalRebaseCount(); // GET LAST REBASE TIME
        uint256 rebase_Count = _userRebases > _totalRebaseCount
            ? 0
            : _totalRebaseCount - _userRebases; // Rebases pending
        // Each rebase increases the bag by 2% / 48
        _totalRebase = (_compoundedRebase + _nfv) * 2 * rebase_Count;
        _totalRebase = _totalRebase / 4800;

        if (_percent <= -330000)
            return (_totalRebase, 0, _totalRebaseCount, _percent);

        uint256 maxRebase = (_nfv * 133) / 100;
        // Cap rebase withdraw to 133% of NFV
        if (_totalRebase > maxRebase) _totalRebase = maxRebase;
        // Well behaved user... full amount
        if (_percent > 0)
            return (_totalRebase, _totalRebase, _totalRebaseCount, _percent);
        // Poorly behaved user... no amount
        // in the negative, reduce rewards linearly
        _userRebase = ((uint256)(330000 + _percent) * _totalRebase) / 330000;
    }

    function getFaucetMax(uint256 _deposits) public pure returns (uint256) {
        return (_deposits * 365) / 100;
    }

    function getTotalRebaseCount() public view returns (uint256) {
        //THANK GOD FOR TRUNCATION
        if (start > block.timestamp) return 0;
        return (block.timestamp - start) / REBASE_TIMER;
    }

    function faucetPayout(address _user)
        public
        view
        returns (
            uint256 grossPayout,
            uint256 maxPayout,
            uint256 netPayout,
            uint256 sustainabilityFee
        )
    {
        Accounting storage user = accounting[_user];
        maxPayout = getFaucetMax(user.netFaucet);
        uint256 maxClaimCap = capPayout() - user.rebaseCompounded;
        if (maxPayout > maxClaimCap) maxPayout = maxClaimCap;
        uint256 share;
        if (user.faucetClaims + user.rebaseClaims < maxPayout) {
            share = (user.netFaucet * 1e12) / (100e12 * (24 hours));
            grossPayout = (block.timestamp - user.lastAction) * share;
            grossPayout += user.accFaucet;

            if (user.faucetClaims + grossPayout > maxPayout)
                grossPayout = maxPayout - user.faucetClaims;

            uint256 feePercent = whaleFee(_user, grossPayout);
            if (feePercent > 0)
                sustainabilityFee = (feePercent * grossPayout) / 100;
            netPayout = grossPayout - sustainabilityFee;
        }
    }

    //----------------------------------------------
    //            ACCOUNTING INTERNALS            //
    //----------------------------------------------
    function updateNetFaucet(address _user) internal {
        Accounting storage user = accounting[_user];
        user.netFaucet = user.deposits + user.airdrops_rcv + user.rolls;
    }

    function whaleFee(address _user, uint256 _payout)
        internal
        view
        returns (uint256)
    {
        uint256 bracket = (accounting[_user].faucetClaims + _payout) /
            faucetWhaleBracket;
        if (bracket < maxWhaleBracket) return bracket * 5;
        return maxWhaleBracket * 5;
    }

    function checkVault()
        public
        view
        returns (
            uint256 _status,
            uint256 _needs,
            uint256 _threshold,
            uint256 _vaultBalance
        )
    {
        uint256 stakeVaulted = IToken(token).balanceOf(vault);
        _status = accLiability * dayFactor;
        _needs = (stakeVaulted * lowMint) / DIVFACTOR;
        _threshold = (stakeVaulted * highMint) / DIVFACTOR;
        _vaultBalance = stakeVaulted;
    }

    function payoutUser(address _user, uint256 amount) internal {
        uint256 stakeVaulted = IToken(token).balanceOf(vault);
        require(stakeVaulted >= amount, "Insufficient funds");
        IVault(vault).withdraw(_user, amount);
    }

    function claimFaucet(
        bool compound,
        uint256 compoundedRebase,
        bool isDeposit
    ) internal returns (uint256 _payout) {
        address _user = msg.sender;
        Accounting storage user = accounting[_user];
        _payout = 0;
        if (user.done) return 0;
        (
            uint256 _gross,
            uint256 max_payout,
            uint256 _netPayout,

        ) = faucetPayout(_user);
        uint256 cap = capPayout();
        uint256 compoundTaxedPayout;
        if (_netPayout > 0) {
            if (user.faucetClaims + _netPayout + user.rebaseClaims >= cap) {
                _netPayout = cap - user.faucetClaims - user.rebaseClaims;
                user.done = true;
            } else if (user.faucetClaims + _netPayout > max_payout) {
                _netPayout = max_payout - user.faucetClaims;
                user.done = true;
            }
            user.faucetClaims += _gross;
            if (compound) {
                //5% goes to Referrals
                compoundTaxedPayout = _netPayout;
                user.rolls += (_netPayout * 95) / 100;
                updateNetFaucet(_user);
                emit FaucetCompound(_user, _netPayout, (_netPayout * 95) / 100);
                // Pay referrals here
            }
        }
        if (compoundTaxedPayout + compoundedRebase > 0)
            spreadReferrals(
                _user,
                compoundTaxedPayout + compoundedRebase,
                isDeposit ? 10 : 5
            );
        if (_netPayout > 0) {
            total_claims += _netPayout;
        }
        user.lastAction = block.timestamp;
        user.accFaucet = 0;
        if (!compound) {
            _payout = _netPayout;
            // Recall that there's a 10% tax happening after this
            emit FaucetClaim(_user, _netPayout);
        }
    }

    function claimRebase(
        address _user,
        bool accumulate,
        bool compound,
        bool isDeposit
    ) internal returns (uint256 _payout) {
        Accounting storage user = accounting[_user];
        _payout = 0;
        if (user.done) return 0;
        (
            ,
            uint256 userRebase,
            uint256 totalCount,
            int256 nerdPercent
        ) = getUserAdjustedRebase(
                user.netFaucet,
                user.faucetClaims + user.rebaseClaims,
                user.rebaseCompounded,
                user.rebaseCount
            );
        user.rebaseCount = totalCount;
        userRebase += user.accRebase;
        if (
            user.rebaseClaims + user.faucetClaims + user.rebaseCompounded >=
            capPayout()
        ) return 0;
        if (
            user.rebaseClaims +
                userRebase +
                user.faucetClaims +
                user.rebaseCompounded >
            capPayout()
        ) {
            userRebase =
                capPayout() -
                user.rebaseClaims -
                user.faucetClaims -
                user.rebaseCompounded;
            user.done = true;
        }
        if (accumulate) {
            user.accRebase = userRebase;
        } else if (compound) {
            _payout = userRebase;
            uint256 tax = isDeposit ? 90 : 95;
            user.rebaseCompounded += (_payout * tax) / 100;
            user.accRebase = 0;
            emit RebaseCompound(_user, userRebase, (_payout * tax) / 100);
        } else {
            //  IF PERCENT <= 33%
            //      update Reducer Directly
            //      rebase compound cannot be smaller than 0
            if (nerdPercent <= -330000)
                user.rebaseCompounded = nerdPercent > -1000000
                    ? (user.rebaseCompounded *
                        (uint256)(1000000 + nerdPercent)) / 670000
                    : 0;
            emit RebaseClaim(_user, userRebase);
            user.rebaseClaims += userRebase;
            total_claims += userRebase;
            user.accRebase = 0;
            _payout = userRebase;
        }
    }

    /// @notice Get the absolute max value to be distributed to any user which is 10% of total Supply
    function capPayout() public view returns (uint256) {
        return IToken(token).totalSupply() / 10;
    }

    function removeLiability(address _user) internal {
        (, , uint256 nfv, uint256 gfv, , , , int256 nP) = getNerdData(_user);
        if (nP <= -330000) accLiability -= nfv / 100;
        else accLiability -= (gfv * 3) / 100;
    }

    function addLiability(address _user) internal {
        Accounting storage user = accounting[_user];
        (
            uint256 grossClaim,
            ,
            uint256 netFV,
            uint256 grossFV,
            ,
            uint256 faucetMax,
            ,
            int256 nerdPercent
        ) = getNerdData(_user);
        // if cap is exceeded, remove all liability, user is done
        if (
            user.faucetClaims >= faucetMax ||
            grossClaim + user.rebaseCompounded >= capPayout()
        ) {
            return;
        }
        if (nerdPercent <= -330000) accLiability += netFV / 100;
        else accLiability += (grossFV * 3) / 100;
    }

    //----------------------------------------------
    //                TEAM INTERNALS              //
    //----------------------------------------------
    function firstUpline(address _user, address _upline) internal {
        Team storage user = team[_user];
        if (user.upline != address(0)) return;
        require(_upline != address(0), "Invalid upline address");
        Accounting storage acUp = accounting[_upline];
        if (
            (acUp.deposits > 0 &&
                user.upline == address(0) &&
                _upline != _user &&
                _user != owner()) || _upline == owner()
        ) {
            setUpline(_user, _upline, false);
            emit UplineAdded(_upline, _user);
        } else {
            revert("Invalid user for upline");
        }
    }

    function setUpline(
        address _user,
        address _upline,
        bool _keepRef
    ) internal {
        if (uplineUpdater > maxRefDepth) return;
        Team storage user = team[_user];
        Team storage upline = team[_upline];
        user.upline = _upline;
        user.upline_set = block.timestamp;
        // If if just became a leader, prev referral needs to be less than 5 and new one needs to be 5 or more
        bool becameLeader = upline.referrals < 5 && upline.referrals + 1 >= 5;
        upline.referrals++;
        if (!_keepRef) {
            user.refClaimRound = 0;
            user.referrals = 0; // reset in case of team Switching
            user.leaders = 0; // reset leaders count
        }
        for (uint8 i = 0; i < maxRefDepth; i++) {
            bool didUpdate = checkTeamUpdate(_upline);
            if (_upline == address(0)) break;
            if (becameLeader && i != 0) {
                team[_upline].leaders++;
            }
            if (team[_upline].maxDownline < i + 1) {
                team[_upline].maxDownline = i + 1;
            }
            team[_upline].structure++;
            _upline = team[_upline].upline;
            if (didUpdate) break;
        }
    }

    function checkTeamUpdate(address _user) internal returns (bool) {
        address toCheck = team[_user].upline;
        if (
            team[toCheck].upline_set >= team[_user].upline_set &&
            team[toCheck].referralsToUpdate > 0
        ) {
            uplineUpdater++;
            setUpline(_user, team[toCheck].prevUpline, true);
            emit UplineChanged(team[toCheck].prevUpline, _user, toCheck);
            team[toCheck].referralsToUpdate--;
            return true;
        }
        uplineUpdater = 0;
        return false;
    }

    function isBalanceCovered(address _user, uint8 _level)
        public
        view
        returns (bool)
    {
        if (team[_user].upline == address(0)) return true;
        uint8 currentLevel = 0;
        uint256 currentBalance = IToken(govToken).balanceOf(_user);
        for (uint8 i = 0; i < maxRefDepth; i++) {
            if (currentBalance < govLevelHold[i]) break;
            currentLevel++;
        }
        return currentLevel >= _level;
    }

    function isNetPositive(address _user) public view returns (bool) {
        (, int256 net_deposits, , , , , , ) = getNerdData(_user);
        return net_deposits >= 0;
    }

    function spreadReferrals(
        address _user,
        uint256 _amount,
        uint256 _bonusPercent
    ) internal {
        checkTeamUpdate(_user);
        //for deposit _addr is the sender/depositor
        address _up = team[_user].upline;
        uint256 _bonus = (_amount * _bonusPercent) / 100; // 10% of amount
        uint256 _share = _bonus / 4; // 2.5% of amount
        uint256 _up_share = _bonus - _share; // 7.5% of amount
        bool _team_found = false;

        for (uint8 i = 0; i < maxRefDepth; i++) {
            // If we have reached the top of the chain, the owner
            if (_up == address(0) || _up == owner()) {
                //The equivalent of looping through all available
                // while we build, send to vault
                address _lott = leadOrLotto ? leaderDrops : lottery;
                if (_lott == address(0)) _lott = vault;
                leadOrLotto = !leadOrLotto;
                payoutUser(_lott, _bonus); // Will send the bonus to the lottery
                emit AddLotteryFunds(_bonus);
                team[_user].refClaimRound = maxRefDepth;
                break;
            }

            //We only match if the claim position is valid
            if (team[_user].refClaimRound == i) {
                if (isBalanceCovered(_up, i + 1) && isNetPositive(_up)) {
                    //Team wallets are split 75/25%
                    if (team[_up].referrals >= 5 && !_team_found) {
                        //This should only be called once
                        _team_found = true;

                        (uint256 gross_payout_upline, , , ) = faucetPayout(_up);
                        accounting[_up].accFaucet = gross_payout_upline;
                        accounting[_up].airdrops_rcv += _up_share;
                        accounting[_up].lastAction = block.timestamp;

                        updateNetFaucet(_up);

                        (uint256 gross_payout_user, , , ) = faucetPayout(_user);
                        accounting[_user].accFaucet = gross_payout_user;
                        accounting[_user].lastAction = block.timestamp;
                        updateNetFaucet(_user);

                        //match accounting
                        team[_up].match_bonus += _up_share;

                        //Synthetic Airdrop tracking; team wallets get automatic airdrop benefits
                        team[_up].airdrops_sent += _share;
                        team[_up].lastAirdropSent = block.timestamp;
                        accounting[_user].airdrops_rcv += _share;

                        //Global airdrops
                        total_airdrops += _share;

                        //Events
                        emit UplineAidrop(_user, _up, i + 1, _up_share);
                        emit Airdrop(_up, _user, _share);
                    } else {
                        (uint256 gross_payout, , , ) = faucetPayout(_up);
                        accounting[_up].accFaucet = gross_payout;
                        accounting[_up].airdrops_rcv += _bonus;
                        accounting[_up].lastAction = block.timestamp;

                        //match accounting
                        team[_up].match_bonus += _bonus;
                        updateNetFaucet(_up);

                        emit UplineAidrop(_user, _up, i + 1, _bonus);
                    }

                    //The work has been done for the position; just break
                    break;
                }

                team[_user].refClaimRound += 1;
            }

            _up = team[_up].upline;
        }

        //Reward the next
        team[_user].refClaimRound += 1;

        //Reset if we've hit the end of the line
        if (team[_user].refClaimRound >= maxRefDepth) {
            team[_user].refClaimRound = 0;
        }
    }

    function userLevel(address _user) public view returns (uint8 _level) {
        Team storage userTeam = team[_user];
        _level = 0;

        //Check each level if failed test, break loop
        for (uint8 i = 1; i < 7; i++) {
            KickbackReq storage levelReq = req[i];
            if (
                userTeam.referrals >= levelReq.directReferrals &&
                userTeam.leaders >= levelReq.directTeamLeaders &&
                userTeam.structure >= levelReq.structureTotal
            ) _level++;
            else break;
        }
    }

    //----------------------------------------------
    //                    Setters                 //
    //----------------------------------------------
    /// @notice set the lottery wallet to send top of chain funds.
    function setLottery(address _lottery) external onlyOwner {
        require(
            _lottery != address(0) && _lottery != owner(),
            "Invalid Lottery"
        );
        lottery = _lottery;
    }

    function setLeaderGiveaway(address _leaderHolder) external onlyOwner {
        require(
            _leaderHolder != address(0) && _leaderHolder != owner(),
            "Invalid Holder"
        );
        leaderDrops = _leaderHolder;
    }

    function setKickbacks(uint8[5] calldata _kicks) external onlyOwner {
        for (uint8 i = 0; i < 5; i++) {
            if (i > 1) {
                // we set a max kickback of 20%
                require(
                    _kicks[i] > _kicks[i - 1] && _kicks[i] < 20,
                    "Invalid Kickback"
                );
            }
            kickback[i] = _kicks[i];
        }
    }

    function setMinimumInitial(uint256 _newVal) external onlyOwner {
        require(_newVal > 0, "Invalid min");
        minimumInitial = _newVal;
    }

    function setWhaleBracketSize(uint256 _newSize) external onlyOwner {
        require(_newSize > 0, "Invalid tax size");
        faucetWhaleBracket = _newSize;
    }

    /// @notice factors that determine when minting should happen.
    /// @dev these factors will be adjusted as we move forward to determine the correct balance
    function setFactors(
        uint256 _daysToAccount,
        uint256 _mintStartFactor,
        uint256 _stopMintFactor
    ) external onlyOwner {
        require(_stopMintFactor >= _mintStartFactor, "can't end below high");
        dayFactor = _daysToAccount;
        lowMint = _mintStartFactor;
        highMint = _stopMintFactor;
    }

    function setGovHold(uint8 index, uint256 _val) external onlyOwner {
        govLevelHold[index] = _val;
        emit FlameHoldLevelTweak(index, _val);
    }

    function editLevelRequirements(
        uint8 _level,
        uint256 _directRef,
        uint256 _directLeaders,
        uint256 _structureTotal
    ) external onlyOwner {
        require(_level > 0 && _level <= 6, "Invalid level");
        KickbackReq storage prevReq = req[_level - 1];
        require(
            prevReq.directReferrals <= _directRef &&
                prevReq.directTeamLeaders <= _directLeaders &&
                prevReq.structureTotal <= _structureTotal,
            "Invalid data"
        );
        req[_level] = KickbackReq(_directRef, _directLeaders, _structureTotal);
        emit ModRequirements(
            _level,
            _directRef,
            _directLeaders,
            _structureTotal
        );
    }
}