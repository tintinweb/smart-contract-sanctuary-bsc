/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;



// Part: IDistributor

interface IDistributor {
    function BUSD() external returns (address);

    function distributeFunds(
        uint256 amount,
        uint256 treasury,
        uint256 pricefloor,
        uint256 team
    ) external;
}

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

    function airdrop(
        address _receiver,
        uint256 _amount,
        uint8 _level
    ) external;
}

// Part: IToken

interface IToken {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address _user) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    function burnFrom(address owner, uint256 amount) external;

    function mint(address to, uint256 amount) external;
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

// Part: IPOL

interface IPOL is IToken {
    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 base_amount
    ) external returns (uint256);

    function removeLiquidity(
        uint256 amount,
        uint256 min_base,
        uint256 min_tokens
    ) external returns (uint256, uint256);

    function swap(
        uint256 base_input,
        uint256 token_input,
        uint256 base_output,
        uint256 token_output,
        uint256 min_intout,
        address _to
    ) external returns (uint256 _output);

    function getBaseToLiquidityInputPrice(uint256 base_amount)
        external
        view
        returns (uint256 liquidity_minted, uint256 token_amount_needed);

    function outputTokens(uint256 _amount, bool isDesired)
        external
        view
        returns (uint256);

    function outputBase(uint256 _amount, bool isDesired)
        external
        view
        returns (uint256);

    function addLiquidityFromBase(uint256 _base_amount)
        external
        returns (uint256);

    function removeLiquidityToBase(uint256 _liquidity, uint256 _tax)
        external
        returns (uint256 _base);
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

// File: NerdFaucetV4.sol

contract NerdFaucetV4 is Ownable {
    struct Accounting {
        uint256 netFaucet; // User level NetFaucetValue
        // Detail of netFaucet
        uint256 deposits; // Hard Deposits made
        uint256 rolls; // faucet Compounds
        uint256 rebaseCompounded; // RebaseCompounds
        uint256 airdrops_rcv; // Received Airdrops
        uint256 accFaucet; // accumulated but not claimed faucet due to referrals
        uint256 accRebase; // accumulated but not claimed rebases
        uint256 rebaseCount; // last rebase claimed
        uint256 lastAction; // last action timestamp
        bool done; // is user done?
    }

    struct Claims {
        uint256 faucetClaims;
        uint256 rebaseClaims;
        uint256 faucetEffectiveClaims;
        uint256 boostEnd;
        uint8 boostLvl;
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
    struct Discount {
        uint8 discount;
        uint256 amount;
    }

    //----------------------------------------------
    //             Global Variables               //
    //----------------------------------------------
    uint256 public immutable start;
    uint256 public constant REBASE_TIMER = 30 minutes;
    uint256 public constant DIVFACTOR = 1000000;

    // Global stats
    uint256 public total_deposits;
    uint256 public total_claims;
    uint256 public total_airdrops;
    uint256 public total_users;

    address public token;
    address public govToken;
    address public busd;
    address public lottery;
    address public leaderDrops;
    address public fundDistributor;
    address public pol;

    uint256 public faucetWhaleBracket;
    uint256 public maxWhaleBracket = 10;
    uint8 public maxRefDepth;
    bool public leadOrLotto = false;

    uint256 public payoutLevelBonus = 10_000 ether;

    uint256 public minimumInitial = 10 ether;

    uint256[] public govLevelHold;
    uint8[] public kickback;
    uint8 public uplineUpdater;
    mapping(address => Accounting) public accounting;
    mapping(address => Claims) public claims;
    mapping(address => Team) public team;
    mapping(uint8 => KickbackReq) public req;
    mapping(address => LeaderReset) public leaders;

    uint256[] public boostTime = [
        1 hours,
        12 hours,
        1 days,
        3 days,
        7 days,
        14 days,
        30 days
    ];
    uint256[] public boostPrice_1 = [
        1 ether,
        3 ether,
        5 ether,
        12 ether,
        24 ether,
        50 ether,
        120 ether
    ];
    uint256[] public boostPriceFactor = [
        1 ether,
        3 ether,
        5 ether,
        12 ether,
        24 ether,
        50 ether,
        110 ether
    ];
    uint8[] public timeWarp = [0, 2, 4, 8, 10, 15, 20]; // TIME IT ADVANCES BY X FACTOR
    mapping(uint256 => uint256[]) public boostPrices;

    uint8 public boostTreasury = 75;
    uint256 public minDrop = 100 ether;
    Discount[] public discounts;

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
        uint256 _effective
    );
    event FaucetClaim(
        address indexed _user,
        uint256 _amount,
        uint256 _realized
    );
    event RebaseCompound(
        address indexed _user,
        uint256 _amount,
        uint256 _realized
    );
    event RebaseClaim(
        address indexed _user,
        uint256 _amount,
        uint256 _realized
    );

    event UplineAidrop(
        address indexed _triggered,
        address indexed _upline,
        uint8 downline,
        uint256 amount
    );
    event Boost(address indexed _user, uint256 _time, uint8 _level);
    event SuperDrop(
        address indexed _sender,
        address indexed _receiver,
        uint256 amount,
        uint8 level,
        uint8 time
    );
    event LogEvent(string _event, uint256 _value, address _add);

    //----------------------------------------------
    //              CONSTRUCTOR FNS               //
    //----------------------------------------------
    constructor(
        address _token,
        address _govToken,
        address _leaderDrops,
        address _busd,
        address _fundDistributor,
        address _pol
    ) {
        pol = _pol;
        fundDistributor = _fundDistributor;
        busd = _busd;
        token = _token;
        leaderDrops = _leaderDrops;
        start = 1654549200;
        faucetWhaleBracket = 7500 ether; // 1% of Total Supply
        maxRefDepth = 15; // 15 levels deep max
        uint256 prev1Num = 1 ether;
        uint256 prev2Num = 2 ether;
        // Initial Factors
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

        boostPrices[0] = [1, 4, 16, 36, 64, 100];
        boostPrices[1] = [3, 9, 25, 49, 81];
        boostPrices[2] = [8, 16, 36, 64];
        boostPrices[3] = [15, 25, 49];
        boostPrices[4] = [22, 36];
        boostPrices[5] = [30];

        discounts.push(Discount(2, 1_000 ether));
        discounts.push(Discount(5, 10_000 ether));
        discounts.push(Discount(10, 100_000 ether));
    }

    //----------------------------------------------
    //                 USER FNS                   //
    //----------------------------------------------
    /// @notice Deposit to start earning
    /// @param _amount amount to deposit
    /// @param _upline team leader or referral, user who is in charge of this user and will
    /// benefit from this user's actions.
    /// @dev the deposit BURNS STAKE
    function deposit(uint256 _amount, address _upline) public {
        address _user = msg.sender;
        Accounting storage user = accounting[_user];
        Claims storage u_claim = claims[_user];
        (uint8 lvl, ) = userLevel(_user, true);
        require(
            u_claim.faucetClaims + u_claim.rebaseClaims < capPayout(lvl),
            "Need a reset"
        );
        if (user.done) user.done = false;
        if (user.deposits == 0) {
            total_users++;
            require(_amount >= minimumInitial, "Initial not met");
            user.rebaseCount = getTotalRebaseCount() + 1;
        }
        //HANDLE TOKEN INFO
        // This requires to burn the total amount. So realized amount is 10% of total
        IToken(token).burnFrom(_user, _amount);

        // 90% is realized
        uint256 realizedAmount = (_amount * 9) / 10; // 10% tax on realized amount

        total_deposits += realizedAmount;
        //HANDLE TEAM Set
        firstUpline(_user, _upline);
        // Compound all
        (uint256 rebaseComp, uint256 rbSpread) = claimRebase(
            msg.sender,
            false,
            true
        );
        claimFaucet(
            true,
            rebaseComp + realizedAmount,
            rbSpread,
            true,
            msg.sender
        );

        emit Deposit(_user, _amount, realizedAmount);
        user.deposits += realizedAmount;
        updateNetFaucet(_user);
        user.lastAction = block.timestamp;
    }

    /// @notice Claims both rebase and faucet
    function claim() external {
        // All of these functions already handle taxes and return the value to mint
        (uint256 _payout, ) = claimRebase(msg.sender, false, false);
        _payout += claimFaucet(false, 0, 0, false, msg.sender);
        payoutUser(msg.sender, _payout);
    }

    function compoundAuto(address _user) external onlyOwner {
        (uint256 _payout, uint256 _rbCompound) = claimRebase(
            _user,
            false,
            true
        );
        claimFaucet(true, _payout, _rbCompound, false, _user);
    }

    function compoundAll() external {
        (uint256 _payout, uint256 _rbCompound) = claimRebase(
            msg.sender,
            false,
            true
        );
        claimFaucet(true, _payout, _rbCompound, false, msg.sender);
    }

    function compoundFaucet() external {
        claimRebase(msg.sender, true, false);
        claimFaucet(true, 0, 0, false, msg.sender);
    }

    function compoundRebase() external {
        (, uint256 _rbCompound) = claimRebase(msg.sender, false, true);
        spreadReferrals(msg.sender, _rbCompound, 100);
    }

    function rebaseClaim() external {
        (uint256 _payout, ) = claimRebase(msg.sender, false, false);
        payoutUser(msg.sender, _payout);
    }

    function faucetClaim() external {
        claimRebase(msg.sender, true, false);
        uint256 _payout = claimFaucet(false, 0, 0, false, msg.sender);
        payoutUser(msg.sender, _payout);
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
        IToken(token).burnFrom(_user, switchFee);
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
        uint8 _level,
        bool self
    ) public {
        require(_receiver != msg.sender, "No gaming");
        // CALCULATE TAXED VALUE
        uint256 realizedAmount = _amount / 10;
        realizedAmount = _amount - realizedAmount;
        if (self) {
            require(
                IToken(token).balanceOf(address(this)) >= _amount,
                "burning nothing"
            );
            IToken(token).burn(_amount);
        } else {
            //TRANSFER TAXED TOKENS
            IToken(token).burnFrom(msg.sender, _amount);
        }
        //ACCUMULATE PAYOUTS
        Team storage teamLeader = team[msg.sender];
        Accounting storage leader = accounting[msg.sender];
        Accounting storage user = accounting[_receiver];
        require(user.deposits > 0, "NonPlayer");
        claimRebase(_receiver, true, false);
        (uint256 grossPayout, , , ) = faucetPayout(_receiver);
        user.accFaucet = grossPayout;
        // KICKBACK Calculation
        uint256 leaderKick = 0;
        if (_level > 1) {
            // level 0 does not exist, level 1 is base level and works only on referral giveouts
            (uint8 currentLevel, ) = userLevel(msg.sender, true);
            require(currentLevel >= _level, "Invalid Level");
            leaderKick = (realizedAmount * kickback[_level - 1]) / 100;
        }
        //SPLIT AIRDROPS
        user.airdrops_rcv += realizedAmount - leaderKick;
        user.lastAction = block.timestamp;
        updateNetFaucet(_receiver);
        teamLeader.airdrops_sent += _amount;
        teamLeader.lastAirdropSent = block.timestamp;
        if (leaderKick > 0) {
            leader.airdrops_rcv += leaderKick;
            updateNetFaucet(msg.sender);
        }
        total_airdrops += realizedAmount;
        // USER AIRDROPPED
        emit Airdrop(msg.sender, _receiver, realizedAmount);
    }

    function leaderReset(uint256 _depositAmount) external {
        LeaderReset storage _lead = leaders[msg.sender];
        (uint8 level, ) = userLevel(msg.sender, true);
        require(_lead.lastResetLvl < 6, "Max Resets");
        _lead.lastResetLvl = level;
        _lead.resets++;
        require(accounting[msg.sender].done, "Keep playing");
        uint256 cap = capPayout(level);
        require(_lead.resets < 99, "Get a new wallet");
        uint256 minDeposit = (cap * _lead.resets * 5) / (1000); // Intervals of 0.5%
        require(
            _depositAmount > minDeposit &&
                _depositAmount - minDeposit >= minimumInitial,
            "Not enough funds"
        );

        Accounting storage userAcc = accounting[msg.sender];
        userAcc.netFaucet = 1;
        userAcc.deposits = 1;
        userAcc.rolls = 0;
        userAcc.airdrops_rcv = 0;
        userAcc.accFaucet = 0;
        userAcc.accRebase = 0;
        userAcc.rebaseCount = getTotalRebaseCount() + 1;
        userAcc.lastAction = block.timestamp;
        userAcc.done = false;

        Claims storage u_claim = claims[msg.sender];
        u_claim.faucetClaims = 0;
        u_claim.rebaseClaims = 0;
        u_claim.faucetEffectiveClaims = 0;
        // Transfer reset Tax to Vault
        IToken(token).burnFrom(msg.sender, minDeposit);
        deposit(_depositAmount - minDeposit, owner());
        emit ResetLeader(msg.sender, _lead.resets, _lead.lastResetLvl);
    }

    function migrate(
        address _user,
        Accounting calldata _acc,
        Team calldata _team,
        LeaderReset calldata _leaderR,
        Claims calldata _claims
    ) public onlyOwner {
        require(!leaders[_user].migrated, "MGX"); //dev: Invalid Migration user
        accounting[_user] = _acc;
        team[_user] = _team;
        leaders[_user] = _leaderR;
        claims[_user] = _claims;
        leaders[_user].migrated = true;
        total_users++;
    }

    function migrateMany(
        address[] calldata _user,
        Accounting[] calldata _acc,
        Team[] calldata _team,
        LeaderReset[] calldata _leaderR,
        Claims[] calldata _claims
    ) public onlyOwner {
        require(
            _user.length == _acc.length &&
                _user.length == _team.length &&
                _user.length == _leaderR.length &&
                _user.length == _claims.length,
            "Invalid Arr"
        );
        for (uint8 i = 0; i < _user.length; i++) {
            migrate(_user[i], _acc[i], _team[i], _leaderR[i], _claims[i]);
        }
    }

    function boost(uint8 time, uint8 level) public {
        (uint8 currentLevel, ) = userLevel(msg.sender, false);

        // Calculate price of boost
        uint256 price = getBoostPrice(currentLevel, level, time);
        // Transfer BUSD to Treasury and buyback and BURN STAKE
        IToken(busd).transferFrom(msg.sender, address(this), price);
        {
            //SEND TO TREASURY
            uint256 treasuryAmount = (boostTreasury * price) / 100;
            IToken(busd).approve(fundDistributor, treasuryAmount);
            IDistributor(fundDistributor).distributeFunds(
                treasuryAmount,
                2,
                1,
                7
            );
            //BUY BACK STAKE AND BURN FROM POL
            treasuryAmount = price - treasuryAmount;
            IToken(busd).approve(pol, treasuryAmount);
            uint256 _stake = IPOL(pol).swap(
                treasuryAmount,
                0,
                0,
                0,
                1,
                address(this)
            );
            IToken(token).burn(_stake);
        }
        boostUser(msg.sender, time, level, currentLevel);
    }

    function superDrop(
        address _receiver,
        uint256 amount_stake,
        uint8 time,
        uint8 level,
        uint8 _kickback
    ) public {
        (uint8 currentLevel, ) = userLevel(_receiver, false);
        uint256 boostPrice = getBoostPrice(currentLevel, level, time);
        uint256 discount;
        if (amount_stake > minDrop) {
            for (uint8 i = 0; i < discounts.length; i++) {
                Discount storage _dc = discounts[i];
                if (_dc.amount > amount_stake || i == discounts.length - 1) {
                    discount = _dc.discount;
                    break;
                }
            }
            boostPrice -= (boostPrice * discount) / 100;
        }
        uint256 stakeTokens = IPOL(pol).outputTokens(
            (amount_stake * 100) / 87,
            true
        );
        IToken(busd).transferFrom(
            msg.sender,
            address(this),
            boostPrice + stakeTokens
        );
        IToken(busd).approve(pol, stakeTokens);
        stakeTokens = IPOL(pol).swap(
            0,
            0,
            0,
            amount_stake,
            stakeTokens,
            address(this)
        );
        airdrop(_receiver, stakeTokens, _kickback, true);
        {
            //SEND TO TREASURY
            uint256 treasuryAmount = (boostTreasury * boostPrice) / 100;
            IToken(busd).approve(fundDistributor, treasuryAmount);
            IDistributor(fundDistributor).distributeFunds(
                treasuryAmount,
                2,
                1,
                7
            );
            //BUY BACK STAKE AND BURN FROM POL
            treasuryAmount = boostPrice - treasuryAmount;
            IToken(busd).approve(pol, treasuryAmount);
            uint256 _stake = IPOL(pol).swap(
                treasuryAmount,
                0,
                0,
                0,
                1,
                address(this)
            );
            IToken(token).burn(_stake);
        }

        //  DO BOOST
        boostUser(_receiver, time, level, currentLevel);
        emit SuperDrop(msg.sender, _receiver, amount_stake, level, time);
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
        Claims storage u_claims = claims[_user];

        _grossClaimed = u_claims.faucetEffectiveClaims + u_claims.rebaseClaims;
        _netFaucetValue = user.netFaucet;
        _netDeposits = (int256)(_netFaucetValue) - (int256)(_grossClaimed);
        if (!user.done) {
            (, _rebasePayout, , _nerdPercent) = getUserAdjustedRebase(
                _netFaucetValue,
                _grossClaimed,
                user.rebaseCompounded,
                user.rebaseCount,
                _user
            );
            _rebasePayout = boostRebase(
                _rebasePayout,
                _user,
                u_claims,
                user.rebaseCount
            );
        }
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
        uint256 _userRebases,
        address _user
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
        int256 playable = (int256)(_nfv + team[_user].airdrops_sent) -
            (int256)(_gc);
        _percent =
            (playable * 100_0000) /
            (int256)(_nfv + team[_user].airdrops_sent);

        _totalRebaseCount = getTotalRebaseCount(); // GET LAST REBASE TIME
        uint256 rebase_Count = _userRebases > _totalRebaseCount
            ? 0
            : _totalRebaseCount - _userRebases; // Rebases pending
        // Each rebase increases the bag by 2% / 48
        _totalRebase = (_compoundedRebase + _nfv) * 2 * rebase_Count;
        _totalRebase = _totalRebase / 4800;

        if (_percent <= -33_0000)
            return (_totalRebase, 0, _totalRebaseCount, _percent);

        uint256 maxRebase = (_nfv * uint256(_percent + 33_0000)) / 100_0000;
        // Cap rebase withdraw to what takes them to -33%
        if (_totalRebase > maxRebase) _totalRebase = maxRebase;
        // Well behaved user... full amount
        if (_percent > 0)
            return (_totalRebase, _totalRebase, _totalRebaseCount, _percent);
        // Poorly behaved user... no amount
        // in the negative, reduce rewards linearly
        _userRebase = ((uint256)(33_0000 + _percent) * _totalRebase) / 33_0000;
    }

    function boostRebase(
        uint256 _rebase,
        address _user,
        Claims memory _claim,
        uint256 userRebases
    ) public view returns (uint256 _updatedRebase) {
        // check if boost is active
        if (!(_claim.boostEnd > accounting[_user].lastAction)) return _rebase;
        // get level and boost status
        (uint256 lvlTimeBoost, ) = userLevel(_user, false);
        lvlTimeBoost = timeWarp[lvlTimeBoost + _claim.boostLvl];
        // get rebases that are boosted
        uint256 totalRebases = getTotalRebaseCount();
        uint256 rebasesRemaining = (_claim.boostEnd -
            accounting[_user].lastAction) / REBASE_TIMER;
        uint256 userOwed = totalRebases - userRebases;
        // get the rebase per time block

        if (userOwed > rebasesRemaining) {
            totalRebases = _rebase / userOwed;
            _updatedRebase =
                (totalRebases * rebasesRemaining * (100 + lvlTimeBoost)) /
                100;
            _updatedRebase += (userOwed - rebasesRemaining) * totalRebases;
        } else {
            _updatedRebase = (_rebase * (100 + lvlTimeBoost)) / 100;
        }
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
        Claims storage u_claims = claims[_user];
        maxPayout = getFaucetMax(user.netFaucet);
        (uint256 share, ) = userLevel(_user, true);
        uint256 cap = capPayout(uint8(share));
        maxPayout = maxPayout > cap ? cap : maxPayout;
        if (user.lastAction < u_claims.boostEnd) {
            // This gets the boosted user level
            share = timeWarp[share] + 100;
            if (block.timestamp > u_claims.boostEnd) {
                grossPayout = block.timestamp - u_claims.boostEnd;
                grossPayout +=
                    ((u_claims.boostEnd - user.lastAction) * share) /
                    100;
            } else
                grossPayout =
                    ((block.timestamp - user.lastAction) * share) /
                    100;
        } else grossPayout = (block.timestamp - user.lastAction);
        if (u_claims.faucetClaims + u_claims.rebaseClaims < maxPayout) {
            share = (user.netFaucet * 1e12) / (100e12 * (24 hours));
            grossPayout = grossPayout * share;
            grossPayout += user.accFaucet;

            if (u_claims.faucetClaims + grossPayout > maxPayout)
                grossPayout = maxPayout - u_claims.faucetClaims;

            uint256 feePercent = whaleFee(_user, grossPayout);
            if (feePercent > 0)
                sustainabilityFee = (feePercent * grossPayout) / 100;
            netPayout = grossPayout - sustainabilityFee;
        }
    }

    function capPayout(uint8 _level) public view returns (uint256 _cap) {
        _cap = 75_000 ether;
        if (_level > 0) _cap += _level * payoutLevelBonus;
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

    function userLevel(address _user, bool getBoosted)
        public
        view
        returns (uint8 _level, uint8 currentBoost)
    {
        Team storage userTeam = team[_user];
        Claims storage u_boost = claims[_user];
        _level = 0;
        if (block.timestamp < u_boost.boostEnd) {
            currentBoost = u_boost.boostLvl;
            if (getBoosted) _level = currentBoost;
        }

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
    //               BOOST INTERNALS              //
    //----------------------------------------------

    function getBoostPrice(
        uint8 currentLevel,
        uint8 lvlIncrease,
        uint8 time
    ) internal view returns (uint256) {
        if (currentLevel == 0 && lvlIncrease == 1) return boostPrice_1[time];
        else
            return
                boostPrices[currentLevel][lvlIncrease - 1] *
                boostPriceFactor[time];
    }

    function boostUser(
        address _user,
        uint8 time,
        uint8 level,
        uint8 _currentLevel
    ) internal {
        Claims storage boostStatus = claims[_user];
        Accounting storage u_acc = accounting[_user];
        uint256 cap = capPayout(_currentLevel + level);
        require(boostStatus.boostEnd < block.timestamp, "B1"); //dev: Boost in progress
        require(
            u_acc.deposits > 0 && //only people who are participating can boost
                time < boostTime.length && // invalid time selection
                level > 0 && // level cant be zero
                level + _currentLevel < 7, // level cant be more than max elvel
            "B2"
        ); // dev: Unable to boost
        if (u_acc.done) {
            require(
                boostStatus.faucetClaims + boostStatus.rebaseClaims < cap,
                "BX"
            ); // dev: already claimed too much
            u_acc.done = false;
        }
        claimRebase(msg.sender, true, false);
        (uint256 grossPayout, , , ) = faucetPayout(msg.sender);
        u_acc.accFaucet += grossPayout;
        u_acc.lastAction = block.timestamp;
        // UPDATE BOOST VALUES

        boostStatus.boostEnd = boostTime[time] + block.timestamp;
        boostStatus.boostLvl = level;
        emit Boost(_user, boostTime[time], _currentLevel + level);
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
        (uint8 _usr_level, ) = userLevel(_user, true);
        uint256 whaleBracket = capPayout(_usr_level) / 10;
        uint256 bracket = (claims[_user].faucetClaims +
            claims[_user].rebaseClaims +
            _payout) / whaleBracket;
        if (bracket < maxWhaleBracket) return bracket * 5;
        return maxWhaleBracket * 5;
    }

    function payoutUser(address _user, uint256 amount) internal {
        require(amount > 0, "POX"); // dev: Won't mint zero
        IToken(token).mint(_user, amount);
    }

    function claimFaucet(
        bool compound,
        uint256 compoundedRebase,
        uint256 _rolled,
        bool isDeposit,
        address _user
    ) internal returns (uint256 _payout) {
        Accounting storage user = accounting[_user];
        Claims storage u_claims = claims[_user];
        (uint8 level, ) = userLevel(_user, true);
        _payout = 0;
        if (user.done) return 0;
        // REBASE CLAIMS DO COUNT TOWARDS MAX PAYOUT
        // DOUBLE CHECK FOR OVERFLOWS IF CLAIMS ARE WAY ABOVE CAPS
        (
            uint256 _gross,
            uint256 max_payout,
            uint256 _netPayout,

        ) = faucetPayout(_user);
        uint256 cap = capPayout(level);
        cap = max_payout > cap ? cap : max_payout;
        uint256 compoundTaxedPayout;
        if (_netPayout > 0) {
            if (
                u_claims.faucetClaims + _netPayout + u_claims.rebaseClaims >=
                cap
            ) {
                if (u_claims.faucetClaims + u_claims.rebaseClaims >= cap)
                    _netPayout = 0;
                else
                    _netPayout =
                        cap -
                        u_claims.faucetClaims -
                        u_claims.rebaseClaims;
                user.done = true;
            }
            u_claims.faucetClaims += _gross;
            if (compound) {
                uint256 tax = isDeposit ? 90 : 95;
                // 5% tax is applied, but for the faucet Claims it counts only the 95%
                compoundTaxedPayout = (_netPayout * tax) / 100;
                u_claims.faucetEffectiveClaims += compoundTaxedPayout;
                user.rolls += compoundTaxedPayout + _rolled;
                updateNetFaucet(_user);
                emit FaucetCompound(_user, _netPayout, compoundTaxedPayout);
                // Pay referrals here
            } else {
                u_claims.faucetEffectiveClaims += _gross;
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
            // Takes out 10% since it's claiming
            _payout = (_payout * 90) / 100;
            emit FaucetClaim(_user, _netPayout, _payout);
        }
    }

    function claimRebase(
        address _user,
        bool accumulate,
        bool compound
    ) internal returns (uint256 _payout, uint256 _compound) {
        Accounting storage user = accounting[_user];
        Claims storage u_claims = claims[_user];
        _payout = 0;
        _compound = 0;
        if (user.done) return (0, 0);
        (
            ,
            uint256 userRebase,
            uint256 totalCount,
            int256 nerdPercent
        ) = getUserAdjustedRebase(
                user.netFaucet,
                u_claims.faucetEffectiveClaims + u_claims.rebaseClaims,
                user.rebaseCompounded,
                user.rebaseCount,
                _user
            );
        userRebase = boostRebase(userRebase, _user, u_claims, user.rebaseCount);
        if (user.rebaseCount < totalCount) user.rebaseCount = totalCount;
        userRebase += user.accRebase;
        // This prevents Stack too deep errors
        {
            (uint8 _level, ) = userLevel(_user, true);
            uint256 cap = capPayout(_level);
            uint256 maxPayout = getFaucetMax(user.netFaucet);
            uint256 t_claims = u_claims.rebaseClaims + u_claims.faucetClaims;
            cap = maxPayout > cap ? cap : maxPayout;
            if (t_claims >= cap) return (0, 0);
            if (
                u_claims.rebaseClaims + userRebase + u_claims.faucetClaims > cap
            ) {
                userRebase =
                    cap -
                    u_claims.rebaseClaims -
                    u_claims.faucetClaims;
                user.done = true;
            }
        }

        if (accumulate) {
            user.accRebase = userRebase;
        } else if (compound) {
            _payout = userRebase;
            user.rebaseCompounded += (_payout * 90) / 100;
            _compound = (_payout * 5) / 100;
            user.accRebase = 0;
            emit RebaseCompound(_user, userRebase, (_payout * 90) / 100);
        } else {
            //  IF PERCENT <= 33%
            //      update Reducer Directly
            //      rebase compound cannot be smaller than 0
            if (nerdPercent <= -330000)
                user.rebaseCompounded = nerdPercent > -1000000
                    ? (user.rebaseCompounded *
                        (uint256)(1000000 + nerdPercent)) / 670000
                    : 0;
            u_claims.rebaseClaims += userRebase;
            total_claims += userRebase;
            user.accRebase = 0;
            uint256 feePercent = whaleFee(_user, userRebase);
            if (feePercent > 0) userRebase -= (userRebase * feePercent) / 100;
            // Since it's claiming tax 10%
            _payout = (userRebase * 90) / 100;
            emit RebaseClaim(_user, userRebase, _payout);
        }
    }

    /// @notice Get the absolute max value to be distributed to any user which is 10% of total Supply
    function setCapLevelIncrease(uint256 _increase) external onlyOwner {
        payoutLevelBonus = _increase;
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
                if (_lott == address(0)) _lott = leaderDrops;
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
                    _kicks[i] > _kicks[i - 1] && _kicks[i] <= 40,
                    "Invalid Kickback"
                );
            }
            kickback[i + 1] = _kicks[i];
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

    /**
     * @notice Add or edit a Discount
     * @param idx the index of the discount to Edit. If idx is larger than array, a new discount is created
     * @param _discount discount to give the user. only integers allowed since they represent percentages. e.g. 1 = 1%
     * @param _maxThreshold the value until this discount applies
     */
    function editDiscounts(
        uint8 idx,
        uint8 _discount,
        uint256 _maxThreshold
    ) external onlyOwner {
        require(_discount < 90); //dev: just dont make it free.
        if (idx > discounts.length - 1) {
            discounts.push(Discount(_discount, _maxThreshold));
            emit LogEvent("Created Discount", discounts.length, msg.sender);
            return;
        }
        discounts[idx] = Discount(_discount, _maxThreshold);
        emit LogEvent("Discount Edit", idx, msg.sender);
    }

    function setBoostTreasury(uint8 _treasuryAmount) external onlyOwner {
        require(_treasuryAmount < 101, "Nope"); // dev: Cant do over 100%
        boostTreasury = _treasuryAmount;
        emit LogEvent("Set Boost Distribution", _treasuryAmount, msg.sender);
    }

    /**
     * @notice Add or edit a boost
     * @param _idx The index to edit, if index is greater than length, then a new boost is created
     * @param _time The amount of time to add... e.g. 10 weeks, 3 hours, 20 minutes, etc...
     * @param _price_1 Price at 1 level boost
     * @param _price_factor from base Price, the factor to increase the base price factor by. 
        e.g. from level 0 to level 6, the base price is 100, so if the price factor is 4 ether, the price for 
        this time boost is now 400 ether.
    */
    function editBoost(
        uint256 _idx,
        uint256 _time,
        uint256 _price_1,
        uint256 _price_factor
    ) external onlyOwner {
        require(_price_factor > 1 ether - 1); // dev: need to get atleast something from this
        if (_idx < boostTime.length) {
            boostTime[_idx] = _time;
            boostPrice_1[_idx] = _price_1;
            boostPriceFactor[_idx] = _price_factor;
            emit LogEvent("Edit Boost", _time, msg.sender);
            return;
        }
        boostTime.push(_time);
        boostPrice_1.push(_price_1);
        boostPriceFactor.push(_price_factor);
        emit LogEvent("Create Boost", _time, msg.sender);
    }

    /**
     * @notice Edit the Price base Price of boosting (non level 0)
     * @param baseLevel the base level of the user to edit
     * @param levelUp the amount of levels the user will go up to
     * @param basePrice the new base price to use for the factor stuff
     */
    function editBoostBasePrice(
        uint256 baseLevel,
        uint8 levelUp,
        uint256 basePrice
    ) external onlyOwner {
        require(baseLevel < 6 && levelUp + baseLevel < 7, "No go"); // Cant edit any other things
        boostPrices[baseLevel][levelUp] = basePrice;
        emit LogEvent("Edit Boost Price", baseLevel, msg.sender);
    }

    function updateGovTk(address _newFlm) external onlyOwner {
        govToken = _newFlm;
        emit LogEvent("Update GovToken", 0, _newFlm);
    }
}