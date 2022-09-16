/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: RXFNDTN

pragma solidity ^0.7.4;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░██████╗░░░███████╗░░██╗░░░██╗░░ //  CONTRACT:
// ░░██╔══██╗░░██╔════╝░░╚██╗░██╔╝░░ //  DAILY AUCTIONS / "RDA"
// ░░██████╔╝░░█████╗░░░░░╚████╔╝░░░ //  PART OF "REX" SMART CONTRACTS
// ░░██╔══██╗░░██╔══╝░░░░░██╔═██╗░░░ //
// ░░██║░░██║░░███████╗░░██╔╝░░██╗░░ //  THIS CODE IS FOR DEPLOYMENT ON NETWORK:
// ░░╚═╝░░╚═╝░░╚══════╝░░╚═╝░░░╚═╝░░ //  BINANCE SMART CHAIN - ID: 56
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░ Latin: king, ruler, monarch ░░ //
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░░ Copyright (C) 2022 rex.io ░░░ //  SINGLE SOURCE OF TRUTH: rex.io
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //

/**
 *
 * GENERAL SHORT DESCRIPTION
 *
 * REX is the world's first extended STAKING token protocol.
 * It is a store of value designed to provide passive income.
 * REX token and its functionality is described in the REX PAPER (whitepaper).
 *
 * This contract implements REX DAILY AUCTIONS and adds liquidity to PancakeSwap (INITIAL and DAILY).
 *
 * "AUCTION PHASE"
 * For creating the initial REX supply, REX tokens are being auctioned in 222 'Daily Auctions' (REX DAY 1 to 222).
 * A participant is sending BUSD as a bid for a portion of the daily auction pool.
 * The minimum bid is 100 BUSD, th maximum is 50,000 (100,000 when holding TREX), only one bid per day.
 * The daily auctioned REX are then distributed amongst the days' participants in proportion to their investment percentage.
 *
 * Auctioned REX must be actively claimed by the user (as liquid REX or as a REX stake).
 * When taking part in an auction and "claiming REX as a STAKE", the user is eligible for BigPayDays (paid in BUSD).
 * claiming the REX from auctions as liquid REX once, sets the user "not eligible" for BigPayDays forever
 * This incentivizes staking (and thus price appreciation of REX token).
 *
 * BigPayDays:
 * REX introduces Personal Random Big Pay Days that occur every 24 hours, where auction participants may win their BUSD back.
 * BigPayDay routine tries to give the winners ALL their invested BUSD back, every time they are hit, again and again.
 * As only 400 BigPayDays can be distributed safely (gas limits), the BigPayDay pool may rise and rise (if too many addresses are eligible) -
 * therefore an external function "_createUserBPD()" has been created that allows users to trigger a seperate BPD and empty the pool
 * "Random" number generation remark: The community has decided NOT to use oracles to create random numbers (due to safety).
 *
 * TREASURY:
 * All users, that are eligible for BigPayDays but never get one, shall get BUSD from the TREASURY, when the auctions end
 * They are tracked in "address[] private userAddressesBPD" (all BigPayDay addresses) and
 * also the contract knows whether the address is "addressHitByRandom" (= had a BigPayDay)
 * The donations of that address (BUSD sent to auctions) are saved in "sumOfDonationsOfUnHit" (used for ratio calculations):
 * When the TREASURY is opened, the addresses receive their portion of ALL BUSD in the contract at that time.
 * All unclaimed referralBUSD and randomBUSD must be claimed until LAST_CLAIM_DAY (day 250) or they are also sent to BUSDTREASURY.
 *
 * The contract has a referral system.
 * Referrers get 10% of the REX the referee gets, plus (when holding 1-5 MREX) 1-5% of the investor's BUSD ('referralBUSD')
 *
 * AUTOMATIC LIQUIDITY ADDING (to the REX-BUSD PancakeSwap pair)
 * 1) DAILY
 * This contract sends 10% of the daily received BUSD from auctions (and the corresponding amount of REX) to the pair
 * via calling ("_fillLiquidityPool()"). The LP tokens are burnt, so the liquidity can never be withdrawn from the pair.
 *
 * 2) INITIALLY (and maybe also DAILY):
 * Even before the auctions start on REX DAY 1, users may send BUSD to the contract using "sendLiquidityBUSD()"
 * (minimum invest per address: 100 BUSD, maximum per adress: 500,000 BUSD. 10,000,000 BUSD is the total maximum).
 * The total number of BUSD are saved in INITIAL_LIQ_BUSD. The BUSD are collected in the contract.
 * On the beginning of REX DAY 2, those BUSD (and the corresponding amount newly minted REX) are sent to the pair
 * As no REX have ever been sent to the pair before, this adding of liquidity sets the REX PRICE in the pair.
 * If more than 100k BUSD are available in INITIAL_LIQ_BUSD, only 100k BUSD are added as liquidity on REX DAY 2 -
 * the rest is added in the course of the next 200 days (1/200 of the remaining BUSD per day = EXTRA_DAILY_LIQ),
 * starting on REX DAY 3 - with the corresponding amount of REX tokens (newly minted, depending on the actual PCS reserves).
 * This leads to an ever rising liquidity in the pair, in the course of the auction phase
 * (together with the 10% of the BUSD that come from the daily auctions)
 * The LP_TOKENS received from this are collected in the contract and may be withdrawn
 * by the INITIAL LIQUIDITY providers from day 223. (Locked until then, then payout 10% every 30 days)
 *
 * Overview: AUCTION ARRIVING BUSD - DISRIBUTION:
 * 75% of the sent BUSD are GIVEN BACK to the auction participants of auctions via 'BigPayDays'.
 * 10% of the sent BUSD are SENT to PancakeSwap as liquidity, irrevokable (LP tokens burnt, see "_fillLiquidityPool()").
 * 5% are seperated: 1-5% are given back to referrers (if they hold MREX) and the rest (to 5%) is given back via the TREASURY.
 * 5% goes to a marketing fund
 * 5% goes to a development fund
 * In total, 90% are given back to investors, referrers or send to the PCS liquidity pool.
 *
 * Important REX days and INTERNAL timeline in DAILY AUCTIONS
 * 0 INITIAL LIQUIDITY PROVISION phase ("DAY 0" is from contract deployment until DAY 1 starts
 *  1 <=   DAILY AUCTIONS                  <= 222
 *  1 <=   BUSD claim phase of referralBUSD     <= 250
 *   2 <=   BUSD claim phase of randomBUSD      <= 250
 *     223 <=  INITIAL LIQUIDITY providers may withdraw LP_TOKENS (10% every 30 days)
 *       251 =    all BUSD are moved to BUSDTREASURY
 *        252 <=         BUSDTREASURY claimable     <= 258
 *         259 = end of all pools, end of claiming REX from Donations and Referrals = "LAST_CONTRACT_DAY"
 *
 *
 * PROCEDURE:
 * The "supplyTrigger()" modifier is used in every external contract (write) call. The mechanics are:
 *  1) Check for a new day has started (if so, calculate REX distribution from past day(s) and calculate BigPayDays),
 *  2) do whatever the caller wanted to do (claim tokens, send BUSD to auction,...)
 *  3) Check if there is new Liquidity from auction participation to add to PCS (capped) or from INITIAL_LIQ_BUSD (capped)
 *
 * "ADMIN RIGHTS"
 * The deploying address "TOKEN_DEFINER" has only one right (and task to do):
 * Calling initContracts() providing the addresses of the other REX contracts (REX and TREX).
 * This is needed to link the contracts after deployment.
 * Afterwards, the TOKEN_DEFINER shall call "revokeAccess", so this can only be done once.
 * No further special rights are granted to the TOKEN_DEFINER.
 *
 * "GAS_REFUNDER"
 * After deployment and initialization of this contract, one address, the "GAS_REFUNDER",
 * has special rights and access: This address is allowed to send BNB to this contract
 * (which will be used for refunding gas fees to users) and withdraw tokens from the contract
 * after the “LAST CONTRACT DAY” (when the auction phase is over and the TREASURY and all POOLS
 * have already been emptied by the users). This ability will be necessary to withdraw the
 * remaining BNB (that haven’t been used for refunding gas fees) and for withdrawing other tokens
 * from the contract then - for example tokens that have accidentally been sent to the contract
 * and wouldn’t be recoverable otherwise (which happens a lot). To grant full security, this
 * withdrawing ability explicitly excludes the REX-BUSD LP TOKENS that will wait in the contract
 * for initial liquidity providers even after the auction phase.
 *
 */

interface IREXToken {

    function currentRxDay()
        external view
        returns (uint32);

    function approve(
        address _spender,
        uint256 _value
    ) external returns (bool success);

    function mintSupply(
        address _donatorAddress,
        uint256 _amount
    ) external;

    function UNISWAP_PAIR()
        external view
        returns (IUniswapV2Pair);

    function balanceOf(
        address account
    ) external view returns (uint256);

    function transfer(
        address to,
        uint value
    ) external returns (bool);

    function createStake(
        address _staker,
        uint256 _amount,
        uint32 _days,
        string calldata _description,
        bool _irrevocable
    ) external;
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

contract RexDailyAuction {

    using RexSafeMath for uint256;
    using RexSafeMath32 for uint32;

    address public TOKEN_DEFINER;   // for initializing contracts after deployment
    address public GAS_REFUNDER;    // address that may send BNB to pay for gas refunds
    IUniswapV2Pair public UNISWAP_PAIR;
    IREXToken public REX_CONTRACT;
    IBEP20 public TREX_TOKEN;
    IBEP20 public MREX_TOKEN;
    IBEP20 public BUSD_TOKEN;
    IBEP20 public LP_TOKEN;

    IUniswapV2Router02 public constant UNISWAP_ROUTER = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant mrex_address = 0x76837D56D1105bb493CDDbEFeDDf136e7c34f0c4;
    address constant busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address constant MARKETING_ADDR = 0x231f8084fECEee5b90021C42C083FEB73d4182F9;
    address constant DEVELOPMENT_ADDR = 0xF3393b11Dc4CADFDc5BCed0F7BEB9d09Ce5C78D6;

    uint32 constant DONATION_DAYS = 222;
    uint32 constant LAST_CLAIM_DAY = 250;       // DONATION_DAYS + 28
    uint32 constant TREASURY_CALC_DAY = 251;    // LAST_CLAIM_DAY + 1
    uint32 constant TREASURY_CLAIM_DAY = 252;   // TREASURY_CALC_DAY + 1
    uint32 constant LAST_CONTRACT_DAY = 259;    // TREASURY_CLAIM_DAY + 7

    uint256 constant RX_DECIMALS = 1E18;        // decimals
    uint256 constant HIGH_PRECISION = 100E18;
    uint256 constant MIN_INVEST = 100E18;       // 100 BUSD minimum invest, for auctions and liquidity provision
    uint256 constant MAX_INVEST = 50000E18;     // 50,000 BUSD maximum invest for auctions (per address per day)
    uint256 constant DAILY_DIFF_SUPPLY = uint256(130000);  // daily supply reduction (day 4-222)
    uint256 constant DAY_ONE_SUPPLY =    uint256(200E6);
    uint256 constant DAY_TWO_SUPPLY =    uint256(140E6);
    uint256 constant DAY_THREE_SUPPLY =  uint256(90E6);
    uint256 constant DAY_LAST_SUPPLY =   uint256(53230000);
    uint256 constant INTIAL_REX_PRICE = 7143;    // No of REX minted per BUSD => equals start price: 1/7143 = 0.0001399972 (BUSD/REX)

    struct Globals {
        uint32 generatedDays;
        uint32 generatedBigPayDays;
        uint256 totalDonatedBUSD;
        uint256 totalGeneratedREX;
        uint256 totalClaimedDonationREX;
        uint256 totalClaimedReferralREX;
        uint256 totalClaimedReferralBUSD;
        uint256 totalClaimedRandomBUSD;
    }

    Globals public g;

    bool public poolWasntEmpty;   // used to decide whether users can create an extra BigPayDay (where empty means 5000 BUSD or less were left)

    mapping(uint32 => uint256) public dailyGeneratedREX;        // for calculating dailyRatio (REX)
    mapping(uint32 => uint256) public dailyTotalDonation;       // for calculating dailyRatio (REX)
    mapping(uint32 => uint256) public dailyTotalReferral;       // for calculating dailyRatio (REX)
    mapping(uint32 => uint256) public dailyRatio;               // for calculating how many REX a BUSD gets (per day from auction investments)
    uint32 public lastCheckedSupplyDay;                         // tracks successfully created past days of supply generation

    mapping(uint32 => uint256) public donatorAccountCount;                    // numberOfDonators per day
    mapping(address => mapping(uint32 => uint256)) public donatorBalances;    // address->day->amount
    mapping(address => mapping(uint32 => bool)) public donatorBalancesDrawn;  // address->day->bool // set to true at withdrawal
    mapping(address => uint256) public donatorTotalBalance;                   // donations per day including bonus (if MREX holder, if referrer set)
    mapping(address => uint256) public donatorTotalRexReceived;               // total REX received from auctions
    mapping(address => uint256) public originalDonation;                      // count donations for BUSDTREASURY
    mapping (uint256 => address) public uniqueDonators;                       // address of x-th donator
    uint256 public uniqueDonatorCount;

    mapping(address => mapping(uint32 => uint256)) public referrerBalances;   // address->day => amount
    mapping(address => mapping(uint32 => bool)) public referrerBalancesDrawn; // address->day => bool // set to true at withdrawal
    mapping(address => uint256) public referralBUSD;                          // claimable referral BUSD of an address
    mapping(address => uint256) public referrerTotalBalance;                  // Total received amount for referrals (10% of referred donations)
    mapping (uint256 => address) public uniqueReferrers;                      // address of x-th referrer
    uint256 public uniqueReferrerCount;

    mapping(address => uint256) public randomBUSD;            // addresses' total amount of claimable BUSD from BPDs
    mapping(address => bool) public addressHitByRandom;       // if not hit, take part in BUSDTREASURY claim phase (days 252-258)
    mapping(address => bool) public addressBPDExcluded;       // if true, address may not take part in BPD
    mapping(address => uint256) private userIndicesBPD;       // address index in the list "userAddressesBPD"
    address[] private userAddressesBPD;                       // address list for BPD distribution

    mapping(address => uint256) public liquidityBalances;       // BUSD sent by early investors (for PCS initial liquidity)
    mapping(address => uint256) public liquidityBalancesDrawn;  // LP tokens withdrawn
    uint256 public INITIAL_LIQ_BUSD;      // total liquidity send by users before DAY 1 (to add to PancakeSwap, initially and daily)
    uint256 public EXTRA_DAILY_LIQ;       // the amount of BUSD in INITIAL_LIQ_BUSD that is exceeding 100k divided by 200
    uint256 public totalLpTokens;         // total No of LP tokens received (from PCS) after sending initial liquidity to PCS (after day 1)

    uint256 public toSendToPairBusd;      // pool of BUSD (10% from AUCTION amounts) that shall be sent be sent to PCS
    uint256 public extraLiqBusdSent;      // total number of BUSD that have been sent to PCS (from EXTRA_DAILY_LIQ)
    uint256 public BUSDPOOL;              // temporary pool of BUSD reserved for BPDs, unless distributed (to "randomBUSD[user]")
    uint256 public BUSDTREASURY;          // pool of BUSD for donators not hit by random, claim phase: days 252-258
    uint256 public treasuryRatio;         // 1E10 precision ratio, an unhit address gets from BUSDTREASURY
    uint256 public sumOfDonationsOfUnHit; // needed for calculating treasuryRatio, updated with every donation

    event DonationReceived(address indexed sender, uint32 indexed donationDay, uint256 amount);
    event ReferralAdded(address indexed referrer, address indexed donator, uint256 amount);
    event DistributedBigPayDay(uint32 round, uint256 participants, uint256 receivers, uint256 poolSizeStart, uint256 poolSizeEnd);
    event SupplyGenerated(uint32 indexed donationDay, uint256 generatedREX);
    event TreasuryGenerated(uint256 treasury, uint256 ratio);
    event ClaimedBusdFromReferrals(address receiver, uint256 amount);
    event ClaimedRexFromAuctions(address receiver, uint256 amount);
    event ClaimedStakeFromAuctions(address receiver, uint256 amount);
    event ClaimedRexFromReferrals(address receiver, uint256 amount);
    event ClaimedBusdFromBPD(address receiver, uint256 amount);
    event LiquidityGenerated(uint32 day, uint256 busdAmount, uint256 rexAmount);
    event LiquidityReceived(address sender, uint256 busdAmount);
    event LPtokensWithdrawn(address receiver, uint256 amountLpTokens);
    event GasRefunded(address refundedAddress, uint256 refundedBNB);

    /**
     * @notice Triggers the daily distribution routines, checks for LIQUIDITY to add to the PCS PAIR
     */
    modifier supplyTrigger() {
        require(_notContract(msg.sender) && msg.sender == tx.origin, 'REX: Invalid sender.');
        _dailyDistributionRoutine();
        _;
        _fillLiquidityPool();
    }

    /**
     * @notice For initializing the contract
     */
    modifier onlyTokenDefiner() {
        require(
            msg.sender == TOKEN_DEFINER,
            'REX: Not allowed.'
        );
        _;
    }

    receive() external payable {
        require (
            msg.sender == address(UNISWAP_ROUTER) ||
            msg.sender == address(GAS_REFUNDER), 'REX: No direct deposits.'
        );
    }

    fallback() external payable { revert(); }

    /** @dev IMPORTANT PRE-DEPLOYMENT NOTICE:
      * REX CONTRACT HAS TO BE DEPLOYED and initialized FIRST,
      * because REX_CONTRACT.UNISWAP_PAIR is NEEDED for this init()
      */
    function initContracts(address _rex, address _trex) external onlyTokenDefiner {
        REX_CONTRACT = IREXToken(_rex);
        TREX_TOKEN = IBEP20(_trex);
        UNISWAP_PAIR = REX_CONTRACT.UNISWAP_PAIR();
        LP_TOKEN = IBEP20( address(UNISWAP_PAIR) );
    }

    function revokeAccess() external onlyTokenDefiner {
        TOKEN_DEFINER = address(0x0);
    }

    constructor() {
        TOKEN_DEFINER = msg.sender;
        GAS_REFUNDER = msg.sender;
        MREX_TOKEN = IBEP20(mrex_address);
        BUSD_TOKEN = IBEP20(busd_address);
    }

    /** @notice A external function for a user (not a contract) to donate BUSD to daily auction's current day
      * @dev This will require RDA contract to be approved as a spender (front-end)
      * @param _busd_amount Amount of BUSD the sender wants to donate
      * @param _referralAddress Referral address for 10% bonus
      */
    function donateBUSD(uint256 _busd_amount, address _referralAddress)
        external supplyTrigger
    {
        require(_notContract(msg.sender) && msg.sender == tx.origin, 'REX: Not an address');

        require(_currentRxDay() >= 1 && _currentRxDay() <= DONATION_DAYS, 'REX: Not in range.');
        require(donatorBalances[msg.sender][_currentRxDay()] == 0, 'REX: Already donated.');
        uint256 maxinvest = TREX_TOKEN.balanceOf(msg.sender) > 0 ? MAX_INVEST.mul(2) : MAX_INVEST; // TREX holders may donate 50% more
        require(_busd_amount <= maxinvest, 'REX: donation above maximum');
        require(_busd_amount >= MIN_INVEST, 'REX: donation below minimum');

        require(BUSD_TOKEN.transferFrom(msg.sender, address(this), _busd_amount), "REX: Transfer of BUSD failed.");

        _reserveRex(_referralAddress, msg.sender, _busd_amount);
    }

    /** @notice A private function doing the REX auction reservation and fills the pools, manages referral
      * @param _referralAddress Referral address for BONUS (REX and BUSD)
      * @param _senderAddress Address of donator
      * @param _senderValue amount of BUSD (Wei)
      */
    function _reserveRex(
        address _referralAddress,
        address _senderAddress,
        uint256 _senderValue
    )
        private
    {
          // self referral: allow, but no bonus (or if !_notContract) -> set to 0x0
        if (_senderAddress == _referralAddress || !_notContract(_referralAddress)) { _referralAddress = address(0x0); }

          // bonus: 10% more REX, if referrer provided
        uint256 _donationBalance = _referralAddress == address(0x0)
            ? _senderValue
            : _senderValue.mul(11).div(10);

          // bonus: up to 10% more REX, if MREX holder
          // 2% more for every held MREX, capped at 5 MREX
        uint256 mrex = MREX_TOKEN.balanceOf(_senderAddress);
        if (mrex > 0)
        {
            if (mrex > 5) { mrex = 5; }  // limit
            _donationBalance = _donationBalance.add( _senderValue.mul( mrex.mul(2) ).div(100) );
        }

          // this is for treasuryRatio calculation: add to the sum, if address has not been hit yet
          // (the BigPayDay function subtracts, if an address is hit later, so the sum is always correct)
        if (!addressHitByRandom[_senderAddress]) {
            sumOfDonationsOfUnHit = sumOfDonationsOfUnHit.add(_senderValue);
        }

        _addDonationToDay(_senderAddress, _currentRxDay(), _donationBalance);
        _trackDonators(_senderAddress, _donationBalance);             // count uniqueDonators
        originalDonation[_senderAddress] = originalDonation[_senderAddress].add(_senderValue);
        g.totalDonatedBUSD = g.totalDonatedBUSD.add(_senderValue);

        BUSDPOOL = BUSDPOOL.add(_senderValue.mul(75).div(100));         // 75% for random BUSD BigPayDays
        toSendToPairBusd = toSendToPairBusd.add(_senderValue.div(10));  // amount of BUSD to send to the PCS PAIR
        BUSD_TOKEN.transfer(MARKETING_ADDR, _senderValue.div(20));      // 5% go to marketing
        BUSD_TOKEN.transfer(DEVELOPMENT_ADDR, _senderValue.div(20));    // 5% go to development
        // and 0-5% of BUSD go to the referrer, while 0-5% of BUSD of to TREASURY, so that ref + treasury = 5%
        // 10% of BUSD go to liquidity, once a day (triggered by dailyRoutine)

        if (_referralAddress != address(0x0)) {

              // if referred: 10% of REX are reserved for referrer
            uint256 amountREX = _senderValue.div(10);
            _addReferralToDay(_referralAddress, _currentRxDay(), amountREX);
            _trackReferrals(_referralAddress, amountREX);                             // count uniqueReferrers

              // if referred: claimable BUSD for referrer (1% of BUSD per MREX held by referrer), rest goes to treasury
            uint256 mrexRef = MREX_TOKEN.balanceOf(_referralAddress);
            if (mrexRef > 5) { mrexRef = 5; }  // limit
            referralBUSD[_referralAddress] = referralBUSD[_referralAddress].add( _senderValue.mul(mrexRef).div(100) );
            BUSDTREASURY = BUSDTREASURY.add( _senderValue.mul( uint256(5).sub(mrexRef) ).div(100) );  // 0-5 MREX => rest goes to treasury

            emit ReferralAdded(_referralAddress, _senderAddress, amountREX);
        }
        else
        {
            BUSDTREASURY = BUSDTREASURY.add( _senderValue.mul(5).div(100) );
        }
    }

    /** @notice Record balance on specific day
      * @param _senderAddress senders address
      * @param _donationDay specific day
      * @param _donationBalance amount (with bonus)
      */
    function _addDonationToDay(
        address _senderAddress,
        uint32 _donationDay,
        uint256 _donationBalance
    )
        private
    {
        if (donatorBalances[_senderAddress][_donationDay] == 0) {
            donatorAccountCount[_donationDay]++;
        }
        donatorBalances[_senderAddress][_donationDay] = donatorBalances[_senderAddress][_donationDay].add(_donationBalance);
        dailyTotalDonation[_donationDay] = dailyTotalDonation[_donationDay].add(_donationBalance);

        emit DonationReceived(_senderAddress, _donationDay, _donationBalance);
    }

    function _addReferralToDay(
        address _referrer,
        uint32 _donationDay,
        uint256 _referralAmount
    )
        private
    {
        referrerBalances[_referrer][_donationDay] = referrerBalances[_referrer][_donationDay].add(_referralAmount);
        dailyTotalReferral[_donationDay] = dailyTotalReferral[_donationDay].add(_referralAmount);
    }

    /** @notice Tracks donatorTotalBalance and uniqueDonators
      * @dev used in _reserveRex() function
      * @param _donatorAddress address of the donator
      * @param _value BUSD invested (with bonus)
      */
    function _trackDonators(address _donatorAddress, uint256 _value) private {
        if (donatorTotalBalance[_donatorAddress] == 0) {
            uniqueDonators[uniqueDonatorCount] = _donatorAddress;
            uniqueDonatorCount++;
        }
        donatorTotalBalance[_donatorAddress] = donatorTotalBalance[_donatorAddress].add(_value);
    }

    /** @notice Tracks referrerTotalBalance and uniqueReferrers
      * @dev used in _reserveRex() internal function
      * @param _referralAddress address of the referrer
      * @param _value Amount referred during reservation
      */
    function _trackReferrals(address _referralAddress, uint256 _value) private {
        if (referrerTotalBalance[_referralAddress] == 0) {
            uniqueReferrers[uniqueReferrerCount] = _referralAddress;
            uniqueReferrerCount++;
        }
        referrerTotalBalance[_referralAddress] = referrerTotalBalance[_referralAddress].add(_value);
    }

    /** @notice A function to allow an investor (not a contract) to send BUSD into this contract, before auctions start
      * @dev This does not use the "supplyTrigger", because it is before day 1 and would fail
      * Those BUSD will be added REX later and both will be added to REX/BUSD pair (on PancakeSwap V2)
      * The LP tokens received after sending the liquidity, may be withdrawn (vested, after DONATION_DAYS)
      * The user must APPROVE this contract to spend the user's BUSD (front-end)
      * @param _busd_amount Amount of BUSD the sender wants to send
      */
    function sendLiquidityBUSD(uint256 _busd_amount)
        external
    {
        require(_currentRxDay() < 1, 'REX: Too late');
        require(_notContract(msg.sender) && msg.sender == tx.origin, 'REX: Invalid sender');
        require(_busd_amount >= MIN_INVEST, 'REX: Below min');
        require( (_busd_amount + liquidityBalances[msg.sender]) <= 5E23, 'REX: Address cap exceeded'); // 500,000 * 1E18 = 5E23
        require( (_busd_amount + INITIAL_LIQ_BUSD) <= 1E25, 'REX: Liquidity cap exceeded'); // 10,000,000 * 1E18 = 1E25
        require(_busd_amount.mod(MIN_INVEST) == 0, 'REX: Send full hundreds of BUSD only');

        require(BUSD_TOKEN.transferFrom(msg.sender, address(this), _busd_amount), "REX: Transfer of BUSD failed.");

        liquidityBalances[msg.sender] = liquidityBalances[msg.sender].add(_busd_amount);
        INITIAL_LIQ_BUSD = INITIAL_LIQ_BUSD.add(_busd_amount);

        emit LiquidityReceived(msg.sender, _busd_amount);
    }

    /** @notice A function to allow an investor to withdraw LP tokens this contract, after auctions ended
      */
    function withdrawLPTokens()
        external supplyTrigger returns (uint256 lpTokensPayout)
    {
        require(_currentRxDay() > DONATION_DAYS, 'REX: Too early');          // LP token withdraw possible after DONATION_DAYS
        require(liquidityBalances[msg.sender] > 0, 'REX: No LP tokens');     // sanity check for totalLpTokens > 0

        lpTokensPayout = withdrawableLPTokens(msg.sender);
        require(lpTokensPayout > 0, 'REX: No payout possible');

        liquidityBalancesDrawn[msg.sender] = liquidityBalancesDrawn[msg.sender].add(lpTokensPayout);
        LP_TOKEN.transfer(msg.sender, lpTokensPayout);

        emit LPtokensWithdrawn(msg.sender, lpTokensPayout);
    }

    /** @notice A function to allow an investor to check for withdrawable LP tokens in this contract
      * where 1/10 of LP tokens may be withdrawn every 30 days, beginning on day DONATION_DAYS+1 (after the auction phase)
      */
    function withdrawableLPTokens(address who)
        public view returns (uint256 lpTokenPayout)
    {
        if (_currentRxDay() <= DONATION_DAYS) { return 0; }
        if (liquidityBalances[who] == 0)  { return 0; }
        if (INITIAL_LIQ_BUSD == 0)  { return 0; }

        lpTokenPayout = totalLpTokens.mul(liquidityBalances[who]).div(INITIAL_LIQ_BUSD);  // payout = share of total
        uint256 vestingPeriods = (uint256(_currentRxDay()).sub(uint256(DONATION_DAYS))).div(uint256(30)).add(uint256(1)); // = "days after auction" div(30) add(1) returns the number of "vesting periods"
        vestingPeriods = vestingPeriods > 10 ? 10 : vestingPeriods; // if bigger than 10, cap to 10 (10=100%, see next line)
        lpTokenPayout = lpTokenPayout.mul(vestingPeriods).div(10); // the possible payout is vestingPeriods/10
        lpTokenPayout = lpTokenPayout > liquidityBalancesDrawn[who] ? lpTokenPayout.sub(liquidityBalancesDrawn[who]) : 0; // check if withdrawn LP tokens exist, then deduct from payout
    }

    /**
     * @notice Allows to trigger routine (one day) without someone doing something
     */
    function triggerDailyRoutineOneDay()
        external
    {
        require(_notContract(msg.sender) && msg.sender == tx.origin, 'REX: No contracts');

        if (_currentRxDay() > 1)
        {
            uint32 _firstCheckDay = lastCheckedSupplyDay.add(1);
            uint32 _lastCheckDay = _currentRxDay().sub(1);

            if (_firstCheckDay <= _lastCheckDay) {
                _generateSupplyAndCheckPools(_firstCheckDay);
            }
        }
    }


    /** @notice Checks for past days if dailyRoutines have run, beginning on day2 for day1
      * @dev triggered by any external contract call "write" via "supplyTrigger" modifier
      */
    function _dailyDistributionRoutine()
        private
    {
          // the calculations must be made from day 2  - until LAST_CONTRACT_DAY == lastCheckedSupplyDay
        if (_currentRxDay() > 1 && lastCheckedSupplyDay < LAST_CONTRACT_DAY)
        {
              // BPD list is randomly filled from day 1
              // (shuffle from day 2 to have better randomness)
            _shuffleBPDlist();

            uint32 _firstCheckDay = lastCheckedSupplyDay.add(1);
            uint32 _lastCheckDay = _currentRxDay().sub(1);

            if (_firstCheckDay == _lastCheckDay) {                              // CHECK 1 DAY ONLY
                _generateSupplyAndCheckPools(_firstCheckDay);
            }
            else
            {
                if (_firstCheckDay < _lastCheckDay) {                           // CHECK MORE DAYS
                    for (uint32 _day = _firstCheckDay; _day <= _lastCheckDay; _day++) {
                        _generateSupplyAndCheckPools(_day);
                    }
                }
            }
        }
    }

    /** @notice Generates supply for past days and sets dailyRatio
      * Calculate all bonuses and assign claimables
      * @param _donationDay day index (from day 1 to DONATION_DAYS)
      */
    function _generateSupplyAndCheckPools(
        uint32 _donationDay
    )
        private
    {
        uint256 gasAtStart = gasleft();   // TRACK THE GAS - to refund gas to the calling address at the end of this function

          // Send initial liquidity (BUSD collected before REX DAY 1 + REX) to PancakeSwap pair
          // A sandwich attack is not possible here, as no REX tokens exist at this moment
        if (_donationDay == 1) { _sendInitialLiquidityToPCS(); }

          // Generate REX supply for auction days (days 1-DONATION_DAYS)
        if (_donationDay >= 1 && _donationDay <= DONATION_DAYS)
        { _generateSupply(_donationDay); }

          // if there is any investor that day, create BPD with up to 400 recipients
        if (_donationDay >= 2 && _donationDay < LAST_CLAIM_DAY && BUSDPOOL >= MIN_INVEST)
        { _createBPD(400); }

          // BUSDTREASURY calculations trigger
        if (_donationDay == TREASURY_CALC_DAY)
        { _setTreasuryRatio(); }

          // BUSDTREASURY is emptied, all unused balances are moved to MARKETING_ADDR
        if (_donationDay == LAST_CONTRACT_DAY)
        {
            BUSDTREASURY = 0;
            if (BUSD_TOKEN.balanceOf(address(this)) > 0) { uint256 amo = BUSD_TOKEN.balanceOf(address(this)); BUSD_TOKEN.transfer(MARKETING_ADDR, amo); }
            if (address(this).balance > 0) { sendValue(payable(MARKETING_ADDR), address(this).balance); }
        }

        lastCheckedSupplyDay = lastCheckedSupplyDay.add(1);  // set the day checked

        uint256 gasSpent = gasAtStart > gasleft() ? (gasAtStart - gasleft() + 21000) : 0; // calculate the "gasSpent"
        uint256 refundBNB = gasSpent * tx.gasprice;                                       // calculate spent BNB
        if (refundBNB > 5E16 && address(this).balance >= refundBNB) {                     // if msg.sender spent more than 0.05 BNB and if the money is available in the contract...
            msg.sender.transfer(refundBNB);                                               // send it to the spender
            emit GasRefunded(msg.sender, refundBNB);
        }

    }

    /** @notice A function generating REX supply and setting the ratio (REX/BUSD) for that auction day
      * @dev triggered by the dailyRoutines (once a day, with the first tx that day)
      */
    function _generateSupply(uint32 _donationDay)
        private
    {
        if (dailyTotalDonation[_donationDay] > 0)
        {
            if (_donationDay == 1) { dailyGeneratedREX[_donationDay] = RX_DECIMALS.mul(DAY_ONE_SUPPLY); }
            if (_donationDay == 2) { dailyGeneratedREX[_donationDay] = RX_DECIMALS.mul(DAY_TWO_SUPPLY); }
            if (_donationDay >= 3 && _donationDay < DONATION_DAYS ) {
                dailyGeneratedREX[_donationDay] = RX_DECIMALS.mul(DAY_THREE_SUPPLY.sub( (uint256(_donationDay).sub(3)).mul(DAILY_DIFF_SUPPLY) )); }
            if (_donationDay == DONATION_DAYS) { dailyGeneratedREX[_donationDay] = RX_DECIMALS.mul(DAY_LAST_SUPPLY); }

              // save generated amount in globals
            g.totalGeneratedREX = g.totalGeneratedREX.add(dailyGeneratedREX[_donationDay]);
            g.generatedDays++;

              // set dailyRatio: Regard Donations and Referrals (everything counts for ratio calculation)
            uint256 totalDonAndRef = dailyTotalDonation[_donationDay].add(dailyTotalReferral[_donationDay]);
            uint256 ratio = dailyGeneratedREX[_donationDay].mul(HIGH_PRECISION).div(totalDonAndRef);
            uint256 remainderCheck = dailyGeneratedREX[_donationDay].mul(HIGH_PRECISION).mod(totalDonAndRef);
            dailyRatio[_donationDay] = remainderCheck == 0 ? ratio : ratio.add(1);

            emit SupplyGenerated(_donationDay, dailyGeneratedREX[_donationDay]);
        }
        else
        {
            emit SupplyGenerated(_donationDay, uint256(0));
        }

    }

    /** @notice Fill the liquidity pool on Pancakeswap V2 (BUSD from INITIAL_LIQ_BUSD and AUCTIONS) starting REX DAY 2
      * @dev Function is called at the end of "SupplyTrigger" routines, after _generateSupplyAndCheckPools
      * MAX 1000 BUSD shall be added per Tx to prevent from sandwich attacks
      */
    function _fillLiquidityPool()
        private
    {
        if (_currentRxDay() > 1 && _currentRxDay() <= 250)   // on DAY 251 all BUSD in the contract are moved to TREASURY
        {
            uint256 totalAdd;   // to track that not more than 1000 BUSD are added in total

              // STEP 1: INITIAL_LIQ_BUSD: add extra liquidity (if any), capped at 500 BUSD
              // triggered only between REX DAY 3 and 203 (= 201 days), but on REX DAY 203 only check for a remainder
            if (EXTRA_DAILY_LIQ > 0 && _currentRxDay() >= 3 && _currentRxDay() <= 203)
            {
                  // in case it is DAY 203 and the extraLiqBusdSent has not reached the FULL amount
                  // or if it is before DAY 203 and the extraLiqBusdSent has not reached the DAILY amount: addLiquidity
                if ( ( _currentRxDay() == 203 && extraLiqBusdSent < uint256(200).mul(EXTRA_DAILY_LIQ) ) ||
                     ( _currentRxDay() < 203 && extraLiqBusdSent < uint256(_currentRxDay().sub(2)).mul(EXTRA_DAILY_LIQ)) )
                {
                        // "EXTRA_DAILY_LIQ > 0" means there must have been INITIAL_LIQ_BUSD and the reserves will already be > 0
                    (uint256 reserveIn, uint256 reserveOut, ) = UNISWAP_PAIR.getReserves(); // reserveIn SHOULD be REX, may be BUSD

                    uint256 _busdAmount;

                    if (_currentRxDay() < 203)
                    {
                        _busdAmount = uint256(_currentRxDay().sub(2)).mul(EXTRA_DAILY_LIQ).sub(extraLiqBusdSent) > uint256(500E18)
                            ? uint256(500E18)
                            : uint256(_currentRxDay().sub(2)).mul(EXTRA_DAILY_LIQ).sub(extraLiqBusdSent);
                    }
                    else
                    {
                        _busdAmount = uint256(200).mul(EXTRA_DAILY_LIQ).sub(extraLiqBusdSent);
                    }

                    if (_busdAmount >= 1E18)  // skip if less than 1 BUSD would be added (PCS would fail)
                    {
                        uint256 _rexAmount = UNISWAP_PAIR.token0() == busd_address  // CreatePair() sometimes sets wrong token order
                            ? _busdAmount.mul(reserveOut).div(reserveIn)            // BUSD to token0, sometimes BUSD to token1 - so it
                            : _busdAmount.mul(reserveIn).div(reserveOut);           // must be checked to get the correct ratio

                        REX_CONTRACT.mintSupply(address(this), _rexAmount);
                        REX_CONTRACT.approve(address(UNISWAP_ROUTER), _rexAmount);
                        BUSD_TOKEN.approve(address(UNISWAP_ROUTER), _busdAmount);

                        (
                            uint256 amountREX,
                            uint256 amountBUSD,
                        ) =

                        UNISWAP_ROUTER.addLiquidity(
                          address(REX_CONTRACT),
                          busd_address,
                          _rexAmount,
                          _busdAmount,
                          0,
                          0,
                          address(this),
                          block.timestamp.add(2 hours)
                        );

                        extraLiqBusdSent = extraLiqBusdSent.add(amountBUSD);  // update "extraLiqBusdSent" with amountBUSD (not _busdAmount)
                        totalAdd = amountBUSD;                                // update the total sent amount until now
                        totalLpTokens = LP_TOKEN.balanceOf(address(this));    // update the total LP token amount (for later withdrawal by investors)

                        emit LiquidityGenerated(_currentRxDay(), amountBUSD, amountREX);
                    }
                }
            }

              // STEP 2: add liquidity (BUSD received from AUCTIONS)
              // capped at 500 BUSD (or up to 1000 if nothing has been sent in STEP 1 above)
            if (toSendToPairBusd >= 500E18)
            {
                (uint256 reserveIn, uint256 reserveOut, ) = UNISWAP_PAIR.getReserves(); // reserveIn SHOULD be REX, may be BUSD

                uint256 _busdAmount = toSendToPairBusd > uint256(1000E18).sub(totalAdd)
                    ? uint256(1000E18).sub(totalAdd)
                    : toSendToPairBusd;

                uint256 _rexAmount;

                if (reserveIn == 0)   // if there are NO RESERVES yet, the start price has not been set before and has to be set NOW
                {
                    _rexAmount = _busdAmount.mul(INTIAL_REX_PRICE);
                }
                else                  // if there ARE reserves, get the ratio - (reserveIn and reservwOut cannot be zero then)
                {
                    _rexAmount = UNISWAP_PAIR.token0() == busd_address      // CreatePair() sometimes sets wrong token order
                        ? _busdAmount.mul(reserveOut).div(reserveIn)        // BUSD to token0, sometimes BUSD to token1 - so it
                        : _busdAmount.mul(reserveIn).div(reserveOut);       // must be checked to get the correct ratio
                }

                REX_CONTRACT.mintSupply(address(this), _rexAmount);
                REX_CONTRACT.approve(address(UNISWAP_ROUTER), _rexAmount);
                BUSD_TOKEN.approve(address(UNISWAP_ROUTER), _busdAmount);

                (
                    uint256 amountREX,
                    uint256 amountBUSD,
                ) =

                UNISWAP_ROUTER.addLiquidity(
                  address(REX_CONTRACT),
                  busd_address,
                  _rexAmount,
                  _busdAmount,
                  0,
                  0,
                  address(0x0),
                  block.timestamp.add(2 hours)
                );

                toSendToPairBusd = toSendToPairBusd.sub(amountBUSD);

                emit LiquidityGenerated(_currentRxDay(), amountBUSD, amountREX);
            }
        }
    }

    /** @notice Fill the liquidity pool on Pancakeswap V2 with initial liquidity, when day 1 has ended
      * THIS creates the start PRICE of the PancakeSwap REX-BUSD pair (if there is any liquidity to be added).
      * This initial LP provision is capped to 100k BUSD. If it is more, it will be added daily to PCS (1/200 for 200 days)
      * The LP tokens are sent to this contract, can be fetched by liquidity providers after auction phase.
      * (The REX needed to send to the PAIR are minted for FREE for the liquidity providers, based on the start price)
      */
    function _sendInitialLiquidityToPCS()
        private
    {
        if (INITIAL_LIQ_BUSD > 0)       // sanity check
        {
            uint256 _startLiquidity;    // the amount of BUSD used to send as Initial Liquidity to the REX-BUSD pair on PCS

            if (INITIAL_LIQ_BUSD > 100000E18)
            {
                _startLiquidity = uint256(100000E18);                               // cap at 100k BUSD
                EXTRA_DAILY_LIQ = INITIAL_LIQ_BUSD.sub(_startLiquidity).div(200);   // set the daily EXTRA_DAILY_LIQ
            }
            else
            {
                _startLiquidity = INITIAL_LIQ_BUSD;
            }

            uint256 _rexAmount = _startLiquidity.mul(INTIAL_REX_PRICE);     // amount REX = BUSD * (REX/BUSD)

            REX_CONTRACT.mintSupply(address(this), _rexAmount);             // mint those needed REX
            REX_CONTRACT.approve(address(UNISWAP_ROUTER), _rexAmount);      // allow ROUTER to withdraw REX from here
            BUSD_TOKEN.approve(address(UNISWAP_ROUTER), _startLiquidity);   // allow ROUTER to withdraw BUSD from here

            (
                uint256 amountREX,
                uint256 amountBUSD,
            ) =

            UNISWAP_ROUTER.addLiquidity(
              address(REX_CONTRACT),
              busd_address,
              _rexAmount,
              _startLiquidity,
              0,
              0,
              address(this),
              block.timestamp.add(2 hours)
            );

              // save the received total LP token amount (for later withdrawal by investors)
            totalLpTokens = LP_TOKEN.balanceOf(address(this));

            emit LiquidityGenerated(0, amountBUSD, amountREX);
        }
    }

    function _getRandomNumber(uint256 ceiling)
        private view returns (uint256)
    {
        if (ceiling > 0) {
            uint256 val = uint256(blockhash(block.number - 1)) * uint256(block.timestamp) + (block.difficulty);
            val = val % uint(ceiling);
            return val;
        }
        else return 0;
    }

    function _getAnotherRandomNumber(uint256 ceiling)
        private view returns (uint256)
    {
        if (ceiling > 0) {
            uint256 val = uint256(blockhash(block.number - 1)) * (block.difficulty) + uint256(block.timestamp);
            val = val % uint(ceiling);
            return val;
        }
        else return 0;
    }

    function isBPDeligibleAddr(
        address _userAddress
    )
        public view
        returns(bool)
    {
        if(userAddressesBPD.length == 0) return false;
        return (userAddressesBPD[userIndicesBPD[_userAddress]] == _userAddress);
    }

    /** @notice Adds an address to the BigPayDay list at random position
      * @dev triggered from claimStakeFromDonations
      */
    function _addEligibleAddr(
        address _userAddress
    )
        private
    {

        if(!isBPDeligibleAddr(_userAddress))      // if not in list, add to list / array
        {
            if(userAddressesBPD.length < 6)   // first 5 addresses are just added chronically, then inserted randomly
            {
                userAddressesBPD.push(_userAddress);
                userIndicesBPD[_userAddress] = userAddressesBPD.length - 1;
            }
            else
            {
                uint256 _pos = _getRandomNumber(userAddressesBPD.length - 1); // leave out "userAddressesBPD.length" as target, so relocation (in the next step) will work
                userAddressesBPD.push(userAddressesBPD[_pos]);                // relocate address from _pos to userAddressesBPD.length
                userIndicesBPD[userAddressesBPD[_pos]] = userAddressesBPD.length - 1;  // save its index
                userAddressesBPD[_pos] = _userAddress;                        // save _userAddress (at _pos)
                userIndicesBPD[_userAddress] = _pos;                          // save index of _userAddress (at _pos)
            }
        }
    }

    /** @notice Removes an address to the BigPayDay list forever
      * @dev triggered from claimRexFromDonations
      */
    function _removeEligibleAddr(
        address _userAddress
    )
        private
    {
        addressBPDExcluded[_userAddress] = true;

        if(isBPDeligibleAddr(_userAddress))
        {
            uint256 indexToDelete = userIndicesBPD[_userAddress];
            address addressToMove = userAddressesBPD[userAddressesBPD.length-1];
            userAddressesBPD[indexToDelete] = addressToMove;
            userIndicesBPD[addressToMove] = indexToDelete;
            userIndicesBPD[_userAddress] = 0;
            userAddressesBPD.pop();
        }
    }

    /** @notice A function to (constantly) mix the list BPD participants
      */
    function _shuffleBPDlist()
        private
    {
        if (userAddressesBPD.length > 6 && _currentRxDay() < LAST_CLAIM_DAY)
        {
              // mix two random addresses (at _posA and _posB)
            uint256 _posA = _getRandomNumber(userAddressesBPD.length);
            uint256 _posB = _getAnotherRandomNumber(userAddressesBPD.length);

            if (_posA != _posB) {
                address _addrA = userAddressesBPD[_posA];   // get and save address of A
                address _addrB = userAddressesBPD[_posB];   // get and save address of B
                userIndicesBPD[_addrA] = _posB;             // write index of B to A
                userIndicesBPD[_addrB] = _posA;             // write index of A to B
                userAddressesBPD[_posA] = _addrB;           // write B to A's Index
                userAddressesBPD[_posB] = _addrA;           // write A to B's Index
            }
        }
    }

    /** @notice An external function to check the number of addresses that are eligible for BPD
      */
    function getBPDCount()
        external view
        returns(uint256)
    {
        return userAddressesBPD.length;
    }

    /** @notice An external function to distribute claimable BUSD to (up to 222) BPD winners ("UserCreatedBigPayDay")
      */
    function _createUserBPD()
        external
    {
        require ( BUSDPOOL > 50000E18, 'REX: Pool too small.');
        require ( poolWasntEmpty, 'REX: Pool was empty.');

        _createBPD(222);
    }

    /** @notice A private function to distribute claimable BUSD to BPD winners
      * Triggered by dailyRoutine (and maybe by users, see function above)
      * Emits "DistributedBigPayDay" even if no BUSD were to be distributed
      * @param _maxBpd Maximum number of distributed BigPayDays
      */
    function _createBPD(uint256 _maxBpd)
        private
    {
        if (userAddressesBPD.length > 0)          // only run, if there are any addresses for BPD
        {
            address who;                          // the address to look up for BPD
            uint256 maxBUSDtoClaim;               // the claimableAmount per address
            uint256 busdPoolStart = BUSDPOOL;     // track the POOL at start and end, for the event
            uint256 busdPoolTemp = BUSDPOOL;      // use a memory variable to count down BUSDPOOL (and not storage) in the loop
            uint256 todaysNumOfBPD;               // count todays BigPayDays for the event
            uint256 minNumOfBPD =                 // distribute minimum 50 BPDs
                userAddressesBPD.length < 50      // (unless there are less than 50 participants -
                    ? userAddressesBPD.length     // then use number of participants)
                    : uint256(50);
            uint256 maxNumOfBPD =                 // the max number of BigPayDays shall be limited due to gas cost
                userAddressesBPD.length > _maxBpd
                ? _maxBpd
                : userAddressesBPD.length;

            if (g.generatedBigPayDays.mod(2) == 0)    // on even rounds: distribute from array start -> end
            {
                for (uint256 i = 0; i < maxNumOfBPD; i++)
                {
                    if (busdPoolTemp > 0)
                    {
                        who = userAddressesBPD[i];                              // get address
                        maxBUSDtoClaim = originalDonation[who];                 // get total donated BUSD of address
                        maxBUSDtoClaim =                                        // limit maxBUSDtoClaim, depending on No of participants
                            maxBUSDtoClaim > busdPoolStart.div(minNumOfBPD)
                                ? busdPoolStart.div(minNumOfBPD)
                                : maxBUSDtoClaim;
                        maxBUSDtoClaim =
                            maxBUSDtoClaim > busdPoolTemp                       // cap at BUSDPOOL
                                ? busdPoolTemp
                                : maxBUSDtoClaim;
                        busdPoolTemp = busdPoolTemp.sub(maxBUSDtoClaim);        // reduce POOL
                        randomBUSD[who] = randomBUSD[who].add(maxBUSDtoClaim);  // assign to address
                        todaysNumOfBPD++;                                       // count BPD

                        if (!addressHitByRandom[who]) {                         // track and count the hit address
                            addressHitByRandom[who] = true;                     // to exclude from TREASURY opening
                            sumOfDonationsOfUnHit = sumOfDonationsOfUnHit.sub(originalDonation[who]); // subtract amount of former donations from the sum (for treasury calculations)
                        }
                    }
                }
            }
            else                  // on odd rounds: distribute from array end -> start
            {
                for (uint256 i = maxNumOfBPD; i > 0; i--)
                {
                    if (busdPoolTemp > 0)
                    {
                        who = userAddressesBPD[i-1];                            // get an address
                        maxBUSDtoClaim = originalDonation[who];                 // get total donated BUSD of address
                        maxBUSDtoClaim =                                        // limit maxBUSDtoClaim, depending on No of participants
                            maxBUSDtoClaim > busdPoolStart.div(minNumOfBPD)
                                ? busdPoolStart.div(minNumOfBPD)
                                : maxBUSDtoClaim;
                        maxBUSDtoClaim =
                            maxBUSDtoClaim > busdPoolTemp                       // cap at BUSDPOOL
                                ? busdPoolTemp
                                : maxBUSDtoClaim;
                        busdPoolTemp = busdPoolTemp.sub(maxBUSDtoClaim);        // reduce POOL
                        randomBUSD[who] = randomBUSD[who].add(maxBUSDtoClaim);  // assign to address
                        todaysNumOfBPD++;                                       // count BPD

                        if (!addressHitByRandom[who]) {                         // track and count the hit address
                            addressHitByRandom[who] = true;                     // to exclude from TREASURY opening
                            sumOfDonationsOfUnHit = sumOfDonationsOfUnHit.sub(originalDonation[who]); // subtract amount of former donations from the sum (for treasury calculations)
                        }
                    }
                }
            }
            BUSDPOOL = busdPoolTemp;
            poolWasntEmpty = BUSDPOOL > 5000E18;   // set a flag if more than 5000 BUSD left, so users CAN or CANNOT trigger BigPayDays manually
            g.generatedBigPayDays++;
            emit DistributedBigPayDay(g.generatedBigPayDays, maxNumOfBPD, todaysNumOfBPD, busdPoolStart, BUSDPOOL);
        }
    }

    /** @notice Allows a user to directly create a stake from the claimable REX from auction
      * @dev Uses REX_CONTRACT instance to create a stakes there, qualifies for BigPayDay
      * @return _payout Amount staked for the donators address (principal)
      */
    function claimStakeFromDonations(
        uint32 _stakingDays
    )
        supplyTrigger
        external
        returns (uint256 _payout)
    {
        require(_currentRxDay() > 1, 'REX: Too early.');
        require(_currentRxDay() <= LAST_CONTRACT_DAY, 'REX: Too late.');
        require(_stakingDays >= DONATION_DAYS && _stakingDays <= 3653, 'REX: Stake duration not in range.');

        uint32 lastClaimableDay = _currentRxDay().sub(1);   // only past days claimable
        if (lastClaimableDay > DONATION_DAYS) { lastClaimableDay = DONATION_DAYS; }

        for (uint32 i = 1; i <= lastClaimableDay; i++) {
            if (!donatorBalancesDrawn[msg.sender][i]) {
                donatorBalancesDrawn[msg.sender][i] = true;
                _payout += donatorBalances[msg.sender][i].mul(dailyRatio[i]).div(HIGH_PRECISION);
            }
        }

        if (_payout > 0) {
            if(!addressBPDExcluded[msg.sender]) { _addEligibleAddr(msg.sender); }
            g.totalClaimedDonationREX = g.totalClaimedDonationREX.add(_payout);
            donatorTotalRexReceived[msg.sender] = donatorTotalRexReceived[msg.sender].add(_payout);
            REX_CONTRACT.createStake(msg.sender, _payout, _stakingDays, unicode'0', true);
            emit ClaimedStakeFromAuctions(msg.sender, _payout);
        }
    }

    /** @notice Allows to mint tokens for specific donator address
      * @dev aggregates donators tokens across all donation days
      * and uses REX_CONTRACT instance to mint all the REX tokens
      * disqualifies from BigPayDays forever
      * @return _payout amount minted to the donators address
      */
    function claimRexFromDonations()
        supplyTrigger
        external
        returns (uint256 _payout)
    {
        require(_currentRxDay() > 1, 'REX: Too early.');
        require(_currentRxDay() <= LAST_CONTRACT_DAY, 'REX: Too late.');

        uint32 lastClaimableDay = _currentRxDay().sub(1);                           // only past days claimable
        if (lastClaimableDay > DONATION_DAYS) { lastClaimableDay = DONATION_DAYS; } // max. 222 days

        for (uint32 i = 1; i <= lastClaimableDay; i++) {                            // sum up all donations for payout
            if (!donatorBalancesDrawn[msg.sender][i]) {                             // check if already withdrawn
                donatorBalancesDrawn[msg.sender][i] = true;                         // set withdrawn to true
                _payout += donatorBalances[msg.sender][i].mul(dailyRatio[i]).div(HIGH_PRECISION);  // count for payout
            }
        }

        if (_payout > 0) {
            if(!addressBPDExcluded[msg.sender]) { _removeEligibleAddr(msg.sender); }  // exclude address from BigPayDays FOREVER
            g.totalClaimedDonationREX = g.totalClaimedDonationREX.add(_payout);
            donatorTotalRexReceived[msg.sender] = donatorTotalRexReceived[msg.sender].add(_payout);
            REX_CONTRACT.mintSupply(msg.sender, _payout);
            emit ClaimedRexFromAuctions(msg.sender, _payout);
        }
    }

    /** @notice Allows to mint tokens for specific referrer address
      * @dev aggregates referrer tokens across all donation days
      * and uses REX_CONTRACT instance to mint all the REX tokens
      * @return _payout amount minted to the donators address
      */
    function claimRexFromReferrals()
        supplyTrigger
        external
        returns (uint256 _payout)
    {
        require(_currentRxDay() > 1, 'REX: Too early.');
        require(_currentRxDay() <= LAST_CONTRACT_DAY, 'REX: Too late.');
        uint32 lastClaimableDay = _currentRxDay() - 1; // only past days
        if (lastClaimableDay > DONATION_DAYS) { lastClaimableDay = DONATION_DAYS; } // max. 222 days
        for (uint32 i = 1; i <= lastClaimableDay; i++) {
            if (!referrerBalancesDrawn[msg.sender][i]) {
                referrerBalancesDrawn[msg.sender][i] = true;
                _payout += referrerBalances[msg.sender][i].mul(dailyRatio[i]).div(HIGH_PRECISION);
            }
        }
        if (_payout > 0) {
            g.totalClaimedReferralREX = g.totalClaimedReferralREX.add(_payout);
            REX_CONTRACT.mintSupply(msg.sender, _payout);
            emit ClaimedRexFromReferrals(msg.sender, _payout);
        }
    }

    /** @notice Allows to claim BUSD for specific referrer address, allow low amount claims for TREX holders
      * @return claimed Amount that has been claimed
      */
    function claimBusdFromReferrals()
        supplyTrigger
        external
        returns (uint256 claimed)
    {
        require(_currentRxDay() <= LAST_CLAIM_DAY, 'REX: Too late to claim');     // day 250 is last BUSD claiming day
        claimed = referralBUSD[msg.sender];                                       // get amount
        require(claimed > 0, 'REX: No BUSD to to claim');                         // check for zero balance
        referralBUSD[msg.sender] = 0;                                             // reset to zero
        g.totalClaimedReferralBUSD = g.totalClaimedReferralBUSD.add(claimed);     // add to totalClaimed
        BUSD_TOKEN.transfer(msg.sender, claimed);                                 // move BUSD to Referrer
        emit ClaimedBusdFromReferrals(msg.sender, claimed);
    }

    /** @notice Allows an address to claim all its BUSD from "randomBUSD"
      * @return claimed Amount that has been claimed successfully
      */
    function claimBusdFromBPD()
        supplyTrigger
        external
        returns (uint256 claimed)
    {
        require(_currentRxDay() <= LAST_CLAIM_DAY, 'REX: Too late to claim.');  // day 250 is last BUSD claiming day
        require(randomBUSD[msg.sender] > 0, 'REX: No BUSD to claim.');       // check positive balance
        claimed = randomBUSD[msg.sender];                                       // get amount
        randomBUSD[msg.sender] = 0;                                             // reset to zero
        g.totalClaimedRandomBUSD = g.totalClaimedRandomBUSD.add(claimed);       // add to totalClaimed
        BUSD_TOKEN.transfer(msg.sender, claimed);                               // move BUSD
        emit ClaimedBusdFromBPD(msg.sender, claimed);
    }

    /** @notice Allows to claim BUSD from BUSDTREASURY for specific referrer address
      * @return claimed Amount that has been claimed
      */
    function claimBusdFromTREASURY()
        supplyTrigger
        external
        returns (uint256 claimed)
    {
        require(_currentRxDay() >= TREASURY_CLAIM_DAY, 'REX: Too early to claim'); // day 252 is first BUSD claiming day
        require(_currentRxDay() < LAST_CONTRACT_DAY, 'REX: Too late to claim');    // day 258 is last BUSD claiming day
        require(!addressHitByRandom[msg.sender], 'REX: Already hit by random');    // check address eligibility
        require(BUSDTREASURY > 0, 'REX: TREASURY is empty');                       // sanity check
        claimed = originalDonation[msg.sender].mul(treasuryRatio).div(1E10); // calculate payable claim amount
        if (claimed > BUSDTREASURY) { claimed = BUSDTREASURY; }                       // sanity check
        require(claimed > 0, 'REX: Nothing to claim.');                               // revert if 0
        addressHitByRandom[msg.sender] = true;                                        // avoid double claiming / reentrancy
        BUSDTREASURY = BUSDTREASURY.sub(claimed);                                     // deduct from POOL
        BUSD_TOKEN.transfer(msg.sender, claimed);                                     // move BUSD
    }

    /** @notice Sets ratio for BUSDTREASURY with 1E10 precision, called on day 251 by DailyRoutine
      * @dev Ratio equals BUSDTREASURY divided by sumOfDonationsOfUnHit
      */
    function _setTreasuryRatio()
        private
    {
        BUSDPOOL = 0;                                         // reset pools :: no more claiming from pools
        BUSDTREASURY = BUSD_TOKEN.balanceOf(address(this));   // put the whole BUSD balance into TREASURY

        if (sumOfDonationsOfUnHit > 0) {
            treasuryRatio = BUSDTREASURY.mul(1E10).div(sumOfDonationsOfUnHit);
        }
        else {
            treasuryRatio = 0;
        }
        emit TreasuryGenerated(BUSDTREASURY, treasuryRatio);
    }


    // CLAIMABLES check functions

    /** @notice Checks for callers claimable REX from donations
      * @return _payout Total REX claimable
      */
    function myClaimableRexFromDonations(address who)
        external
        view
        returns (uint256 _payout)
    {
        if (_currentRxDay() > 1 && _currentRxDay() <= LAST_CONTRACT_DAY)
        {
            uint32 lastClaimableDay = _currentRxDay() - 1;                                // only past days
            if (lastClaimableDay > DONATION_DAYS) { lastClaimableDay = DONATION_DAYS; }   // limited to DONATION_DAYS
            for (uint32 i = 1; i <= lastClaimableDay; i++) {
                if (!donatorBalancesDrawn[who][i]) {
                    _payout += donatorBalances[who][i].mul(dailyRatio[i]).div(HIGH_PRECISION);
                }
            }
        }
    }

    /** @notice Checks for callers claimable REX from referrals
      * @return _payout Total REX claimable
      */
    function myClaimableRexFromReferrals(address who)
        external
        view
        returns (uint256 _payout)
    {
        if (_currentRxDay() > 1 && _currentRxDay() <= LAST_CONTRACT_DAY)
        {
            uint32 lastClaimableDay = _currentRxDay() - 1; // only past days
            if (lastClaimableDay > DONATION_DAYS) { lastClaimableDay = DONATION_DAYS; }
            for (uint32 i = 1; i <= lastClaimableDay; i++) {
                if (!referrerBalancesDrawn[who][i]) {
                    _payout += referrerBalances[who][i].mul(dailyRatio[i]).div(HIGH_PRECISION);
                }
            }
        }
    }

    /** @notice Checks for number of BPD eligible addresses unhit by BigPayDay ( = TREASURY eligible addresses)
      * @dev Will not deliver a return value for some 10,000 eligible addresses (gas), but not a problem
      * @return unhit Number of not hit addresses (BigPayDay)
      */
    function getActualUnhitByRandom() external view returns (uint256 unhit) {
        for (uint256 i = 0; i < userAddressesBPD.length; i++) {
            if (!addressHitByRandom[userAddressesBPD[i]]) { unhit++; }
        }
    }

    /** @notice Checks for REX that will be generated on current day
      * @return REX amount
      */
    function auctionSupplyOnDay(uint32 _donationDay) external pure returns (uint256) {
        if (_donationDay == 1) { return RX_DECIMALS.mul(DAY_ONE_SUPPLY); }
        if (_donationDay == 2) { return RX_DECIMALS.mul(DAY_TWO_SUPPLY); }
        if (_donationDay >= 3 && _donationDay < DONATION_DAYS ) {
            return RX_DECIMALS.mul(DAY_THREE_SUPPLY.sub( (uint256(_donationDay).sub(3)).mul(DAILY_DIFF_SUPPLY) )); }
        if (_donationDay == DONATION_DAYS) { return RX_DECIMALS.mul(DAY_LAST_SUPPLY); }
        return 0;
    }

    function auctionStatsOfDay(uint32 _donationDay) external view returns (uint256[4] memory _stats) {
        _stats[0] = dailyGeneratedREX[_donationDay];
        _stats[1] = dailyTotalDonation[_donationDay] + dailyTotalReferral[_donationDay];
        _stats[2] = donatorAccountCount[_donationDay];
        _stats[3] = dailyRatio[_donationDay];
    }

    /** @notice Shows current day of RexToken
      * @dev Fetched from REX_CONTRACT
      * @return Iteration day since REX inception
      */
    function _currentRxDay() public view returns (uint32) {
        return REX_CONTRACT.currentRxDay();
    }

    function _notContract(address _addr) internal view returns (bool) {
        uint32 size; assembly { size := extcodesize(_addr) } return (size == 0); }

    function sendValue(address payable recipient, uint256 amount) internal {
        (bool success, ) = recipient.call{value: amount}(''); require(success, 'Address: Failed to send value'); }

    /** @notice A function allowing WITHDRAWING any tokens from the contract AFTER the contract has ended
      * For example: BNB that the GAS_REFUNDER has sent for GAS_REFUND or tokens that have accidentially been sent to the contract
      * @param token The token's address to withdraw (LP_TOKEN withdraws are forbidden)
      */
    function withdrawTokensAfterContractEnd(address token)
        external
    {
        require(_currentRxDay() > LAST_CONTRACT_DAY, 'RDA: Too early.');
        require(msg.sender == GAS_REFUNDER, 'REX: Not allowed.');         // only the GAS_REFUNDER may withdraw tokens
        require(token != address(LP_TOKEN), 'REX: Not allowed.');         // LP_TOKENs are not allowed to be withdrawn

        IBEP20 Token = IBEP20(token);
        if ( Token.balanceOf(address(this)) > 0 )
        {
            uint256 amo = Token.balanceOf(address(this));
            Token.transfer(MARKETING_ADDR, amo);
        }
    }
}

library RexSafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'REX: addition overflow');
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, 'REX: subtraction overflow');
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'REX: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'REX: division by zero');
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, 'REX: modulo by zero');
        return a % b;
    }
}

library RexSafeMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        require(c >= a, 'REX: addition overflow');
        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b <= a, 'REX: subtraction overflow');
        uint32 c = a - b;
        return c;
    }

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {

        if (a == 0) {
            return 0;
        }

        uint32 c = a * b;
        require(c / a == b, 'REX: multiplication overflow');

        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b > 0, 'REX: division by zero');
        uint32 c = a / b;
        return c;
    }

    function mod(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b != 0, 'REX: modulo by zero');
        return a % b;
    }
}