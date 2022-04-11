// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../contracts/interface/IVault.sol";
import "../contracts/interface/IInfinity.sol";
import "../contracts/interface/IPriceFeed.sol";

contract Syndicate is
    Initializable,
    PausableUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using MathUpgradeable for uint256;

    struct User {
        //Referral Info
        address upline;
        uint256 referrals;
        uint256 total_structure;
        //Long-term Referral Accounting
        uint256 direct_bonus;
        uint256 match_bonus;
        //Deposit Accounting
        uint256 deposits;
        uint256 deposit_time;
        //Payout and Roll Accounting
        uint256 payouts;
        uint256 rolls;
        //Upline Round Robin tracking
        uint256 ref_claim_pos;
        uint256 accumulatedDiv;
        //Record Deposits of users for eject function
        UserDepositsForEject[] userDepositsForEject;
    }

    //Airdrop tracking
    struct Airdrop {
        uint256 airdrops;
        uint256 airdrops_received;
        uint256 last_airdrop;
    }

    struct UserDepositsForEject {
        uint256 amount_INF;
        uint256 amount_BUSD; // real amount in BUSD
        uint256 depositTime;
        bool ejected;
    }

    struct UserDepositReal {
        uint256 deposits; // real amount of Tokens
        uint256 deposits_BUSD; // real amount in BUSD
    }

    //StakedBoost tracking
    struct UserBoost {
        address user;
        uint256 stakedBoost_INF;
        uint256 stakedBoost_BUSD;
        uint256 last_action_time;
    }

    struct UserWithdrawn {
        uint256 withdrawn; // amount of Tokens
        uint256 withdrawn_BUSD; // amount in BUSD
    }

    address public infinityVaultAddress;

    IInfinity private infinityToken;
    IPriceFeed private infinityTokenPriceFeed;
    IVault private infinityVault;

    mapping(address => User) public users;
    mapping(address => UserDepositReal) public usersRealDeposits;
    mapping(address => Airdrop) public airdrops;
    mapping(uint256 => address) public id2Address;
    mapping(address => UserBoost) public usersBoosts;

    uint256 public CompoundTax;
    uint256 public ExitTax;
    uint256 public EjectTax;
    uint256 public DepositTax;

    uint256 private payoutRate;
    uint256 private ref_depth;
    uint256 private ref_bonus;
    uint256 private max_deposit_multiplier;
    uint256 private userDepositEjectDays;

    uint256 private minimumInitial;
    uint256 private minimumAmount;

    uint256 public deposit_bracket_size; // @BB 5% increase whale tax per 10000 tokens... 10 below cuts it at 50% since 5 * 10
    uint256 public max_payout_cap; // 100k INF or 10% of supply
    uint256 private deposit_bracket_max; // sustainability fee is (bracket * 5)
    uint256 public min_staked_boost_amount; // Minimum staked Boost amount should be the same as 0 level ref_depth amount.

    uint256[] public ref_balances;

    uint256 public total_airdrops;
    uint256 public total_users;
    uint256 public total_deposited;
    uint256 public total_withdraw;
    uint256 public total_bnb;
    uint256 public total_txs;

    bool public STORE_BUSD_VALUE;
    uint256 public AIRDROP_MIN_AMOUNT;

    mapping(address => UserWithdrawn) public usersWithdrawn;
    bool public AIRDROP_ENABLED;
    bool public EJECT_ENABLED;

    uint256 public constant MAX_UINT = 2**256 - 1;

    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);
    event Leaderboard(
        address indexed addr,
        uint256 referrals,
        uint256 total_deposits,
        uint256 total_payouts,
        uint256 total_structure
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
    event BalanceTransfer(
        address indexed _src,
        address indexed _dest,
        uint256 _deposits,
        uint256 _payouts
    );
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
    event NewAirdrop(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 timestamp
    );
    event ManagerUpdate(
        address indexed addr,
        address indexed manager,
        uint256 timestamp
    );
    event BeneficiaryUpdate(address indexed addr, address indexed beneficiary);
    event HeartBeatIntervalUpdate(address indexed addr, uint256 interval);
    event HeartBeat(address indexed addr, uint256 timestamp);
    event Ejected(address indexed addr, uint256 amount, uint256 timestamp);

    function initialize() public initializer {
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        total_users = 1;
        deposit_bracket_size = 5000 ether; // @BB 5% increase whale tax per 5000 tokens...
        max_payout_cap = 50000 ether; // 50k INFINITY or 5% of supply

        //should remain 1e18 so we can set minimum to below 1 depending on the future price of infinity.
        minimumInitial = 1 * 1e18;
        minimumAmount = 1 * 1e18;
        min_staked_boost_amount = 2 ether;
        AIRDROP_MIN_AMOUNT = 1 * 1e18;

        userDepositEjectDays = 7 days;
        payoutRate = 1;
        ref_depth = 15;
        ref_bonus = 5; // 5 % to round robin
        max_deposit_multiplier = 5;
        deposit_bracket_max = 10; // sustainability fee is (bracket * 5)

        CompoundTax = 3;
        ExitTax = 10;
        EjectTax = 10;
        DepositTax = 10;

        AIRDROP_ENABLED = true;

        STORE_BUSD_VALUE = false; // this will be true after the priceFeedContract was set by updateInfinityTokenPriceFeed(...)
        infinityToken = IInfinity(
            address(0x770550554d12089893fAc98c36854C6Bf9CFe908)
        );

        updateInfinityTokenPriceFeed(
            address(0x60E8CEDD303D02B84F34d1f69D7D3a0C0F99BB50),
            true
        );

        infinityVault = IVault(
            address(0x6DF631d2aF5DA5F05c420D21015b6a2Af159dB62)
        );

        infinityVaultAddress = 0x6DF631d2aF5DA5F05c420D21015b6a2Af159dB62;

        //Boost levels
        ref_balances.push(100 ether); // 1 $100 worth of INF
        ref_balances.push(300 ether); // 2 $300 worth of INF
        ref_balances.push(500 ether); // 3 $500 worth of INF
        ref_balances.push(700 ether); // 4 $700 worth of INF
        ref_balances.push(900 ether); // 5 $900 worth of INF
        ref_balances.push(1100 ether); // 6 $1100 worth of INF
        ref_balances.push(1300 ether); // 7 $1300 worth of INF
        ref_balances.push(1500 ether); // 8 $1500 worth of INF
        ref_balances.push(1700 ether); // 9 $1700 worth of INF
        ref_balances.push(1900 ether); // 10 $1900 worth of INF
        ref_balances.push(2100 ether); // 11 $2100 worth of INF
        ref_balances.push(2300 ether); // 12 $2300 worth of INF
        ref_balances.push(2500 ether); // 13 $2500 worth of INF
        ref_balances.push(2700 ether); // 14 $2700 worth of INF
        ref_balances.push(2900 ether); // 15 $2900 worth of INF
    }

    //@dev Default payable is empty since Faucet executes trades and recieves BNB
    fallback() external payable {
        //Do nothing, BNB will be sent to contract when selling tokens
    }

    /****** Administrative Functions *******/

    function updateTaxes(
        uint256 _depositTax,
        uint256 _exitTax,
        uint256 _compoundTax
    ) external onlyOwner {
        DepositTax = _depositTax;
        ExitTax = _exitTax;
        CompoundTax = _compoundTax;
    }

    function updateInfinityTokenPriceFeed(
        address priceFeedAddress,
        bool _store_busd_enabled
    ) public onlyOwner {
        infinityTokenPriceFeed = IPriceFeed(priceFeedAddress);
        STORE_BUSD_VALUE = _store_busd_enabled;
    }

    function updatePayoutRate(uint256 _newPayoutRate) public onlyOwner {
        payoutRate = _newPayoutRate;
    }

    function updateRefDepth(uint256 _newRefDepth) public onlyOwner {
        ref_depth = _newRefDepth;
    }

    function updateRefBonus(uint256 _newRefBonus) public onlyOwner {
        ref_bonus = _newRefBonus;
    }

    function updateInitialDeposit(uint256 _newInitialDeposit) public onlyOwner {
        minimumInitial = _newInitialDeposit;
    }

    function updateMinimumAmount(uint256 _newminimumAmount) external onlyOwner {
        minimumAmount = _newminimumAmount * 1e18;
    }

    function updateDepositBracketSize(uint256 _newBracketSize)
        public
        onlyOwner
    {
        deposit_bracket_size = _newBracketSize;
    }

    function updateMaxPayoutCap(uint256 _newPayoutCap) public onlyOwner {
        max_payout_cap = _newPayoutCap;
    }

    function updateHoldRequirements(uint256[] memory _newRefBalances)
        public
        onlyOwner
    {
        require(_newRefBalances.length == ref_depth);
        delete ref_balances;
        for (uint8 i = 0; i < ref_depth; i++) {
            ref_balances.push(_newRefBalances[i]);
        }
    }

    function updateMinimumStakedBoostAmount(
        uint256 _newMinimumStakedBoostAmount
    ) external onlyOwner {
        min_staked_boost_amount = _newMinimumStakedBoostAmount * 1 ether;
    }

    function updateMinimumAirdropAmount(uint8 value) public onlyOwner {
        AIRDROP_MIN_AMOUNT = value * 1e18;
    }

    function updateAirdropEnabled(bool value) external onlyOwner {
        AIRDROP_ENABLED = value;
    }

    function updateEjectEnabledEnabled(bool value) external onlyOwner {
        EJECT_ENABLED = value;
    }

    /********** User Fuctions **************************************************/

    function calculateDepositTax(uint256 _value)
        public
        view
        returns (uint256 adjustedValue, uint256 taxAmount)
    {
        taxAmount = (_value * (DepositTax)) / (100);
        adjustedValue = _value - taxAmount;
        return (adjustedValue, taxAmount);
    }

    function deposit(uint256 _amount) external onlyOwner {
        _deposit(msg.sender, _amount);
    }

    function HasUsedEject(address _wallet) public view returns (bool) {
        User memory _user = users[_wallet];
        if (_user.userDepositsForEject.length > 0) {
            return _user.userDepositsForEject[0].ejected;
        }
        return false;
    }

    function updateVault(address _newVault) public onlyOwner {
        require(_newVault != address(0), "invalid address");
        infinityVaultAddress = _newVault;
        infinityVault = IVault(address(_newVault));
    }

    //@dev Deposit specified INF amount supplying an upline referral
    function deposit(address _upline, uint256 _amount) external whenNotPaused {
        address _wallet = msg.sender;

        require(!HasUsedEject(_wallet), "user is ejected");

        (uint256 realizedDeposit, ) = calculateDepositTax(_amount);
        uint256 _total_amount = realizedDeposit;

        require(_amount >= minimumAmount, "Minimum deposit");

        //If fresh account require a minimal amount of INF
        if (users[_wallet].deposits == 0) {
            require(_amount >= minimumInitial, "Initial deposit too low");
        }

        _setUpline(_wallet, _upline);

        uint256 taxedDivs;
        // Claim if divs are greater than 1% of the deposit
        if (claimsAvailable(_wallet) > _amount / 100) {
            uint256 claimedDivs = _claim(_wallet, true);
            taxedDivs = (claimedDivs * (100 - CompoundTax)) / 100; // 5% tax on compounding
            _total_amount += taxedDivs;
            taxedDivs = taxedDivs / 2;
        }

        //Transfer INF to the contract
        require(
            infinityToken.transferFrom(
                _wallet,
                address(infinityVaultAddress),
                _amount
            ),
            "INF token transfer failed"
        );

        // record user new deposit (here comes fresh money. userRealDeposits only contains the amount from external. nothing from roll)
        usersRealDeposits[_wallet].deposits += _total_amount;
        if (STORE_BUSD_VALUE) {
            usersRealDeposits[_wallet].deposits_BUSD += infinityTokenPriceFeed
                .getPrice(_total_amount / (1 ether)); // new cash in BUSD
        }

        /*
        User deposits 10;
        1 goes for tax, 9 are realized deposit
        */

        _deposit(_wallet, _total_amount);

        _refPayout(_wallet, realizedDeposit + taxedDivs, ref_bonus);

        /** deposit amount and Time of Deposits/ it will record all new deposits of the user. 
            This mapping will be used to check if the deposits is will qualified for eject **/
        users[_wallet].userDepositsForEject.push(
            UserDepositsForEject(
                _total_amount,
                infinityTokenPriceFeed.getPrice(_total_amount / (1 ether)),
                block.timestamp,
                false
            )
        );

        emit Leaderboard(
            _wallet,
            users[_wallet].referrals,
            users[_wallet].deposits,
            users[_wallet].payouts,
            users[_wallet].total_structure
        );
        total_txs++;
    }

    //record to usersBoosts users staked INF token and its dollar value.
    function stakeBoost(uint256 _amount) external whenNotPaused {
        address _wallet = msg.sender;
        require(
            users[_wallet].upline != address(0) || _wallet == owner(),
            "user not found"
        ); // non existent user has no upline
        require(STORE_BUSD_VALUE, "BUSD storing is disabled");
        require(!HasUsedEject(msg.sender), "user used eject");
        require(
            _amount >= min_staked_boost_amount,
            "Did not meet minimum amount that can be staked."
        );
        require(
            infinityToken.transferFrom(_wallet, address(this), _amount),
            "INFINITY to contract transfer failed; check balance and allowance for staking."
        );
        usersBoosts[_wallet].stakedBoost_INF += _amount;
        usersBoosts[_wallet].last_action_time = block.timestamp;
        if (STORE_BUSD_VALUE) {
            usersBoosts[_wallet].stakedBoost_BUSD += infinityTokenPriceFeed
                .getPrice(_amount / (1 ether));
        }
    }

    function stakeBoostSimulate(address _wallet, uint256 _amount)
        external
        view
        returns (uint256 stakedINF, uint256 stakedBUSD)
    {
        require(
            users[_wallet].upline != address(0) || _wallet == owner(),
            "user not found"
        ); // non existent user has no upline
        require(STORE_BUSD_VALUE, "BUSD storing is disabled");
        require(!HasUsedEject(msg.sender), "user used eject");
        require(
            _amount >= min_staked_boost_amount,
            "Did not meet minimum amount that can be staked."
        );

        stakedINF = usersBoosts[_wallet].stakedBoost_INF + _amount;

        if (STORE_BUSD_VALUE) {
            uint256 infinityPrice = infinityTokenPriceFeed.getPrice(1);
            stakedBUSD =
                usersBoosts[_wallet].stakedBoost_BUSD +
                ((infinityPrice * _amount) / 1 ether);
        }
    }

    function unstakeBoost() external whenNotPaused {
        address _wallet = msg.sender;
        (, uint256 _max_payout, , ) = payoutOf(_wallet);

        require(
            users[_wallet].payouts >= _max_payout,
            "User can only unstakeBoost if max payout has been reached."
        );
        require(usersBoosts[_wallet].stakedBoost_INF > 0, "nothing staked");
        uint256 infinityPrice = infinityTokenPriceFeed.getPrice(1);

        require(infinityPrice > 0, "infinity price missing");

        //allow to unstakeBoost the dollar amount of the staked INF tokens.
        //same rules as in eject here. if price has increased, the dollar amount is the cap. if the price has fallen the pston amount is the cap.

        uint256 amountAvailableForUnstakeBoost = 0;
        uint256 current_amount_BUSD = (infinityPrice *
            (usersBoosts[_wallet].stakedBoost_INF)) / (1 ether);

        //check if current busd price of users deposited INF token is greater that INF amount(in busd) deposited.
        if (current_amount_BUSD >= usersBoosts[_wallet].stakedBoost_BUSD) {
            amountAvailableForUnstakeBoost += (usersBoosts[_wallet]
                .stakedBoost_BUSD / (infinityPrice)).min(
                    usersBoosts[_wallet].stakedBoost_INF
                );
        }
        //else-if the current busd price of users deposited INF token is lower than INF amount(in busd) deposited.
        else if (current_amount_BUSD <= usersBoosts[_wallet].stakedBoost_BUSD) {
            amountAvailableForUnstakeBoost += usersBoosts[_wallet]
                .stakedBoost_INF;
        }

        //set user stakeBoost Token to 0
        usersBoosts[_wallet].stakedBoost_INF = 0;
        usersBoosts[_wallet].stakedBoost_BUSD = 0;
        usersBoosts[_wallet].last_action_time = block.timestamp;

        //mint new tokens if reward infinityVault is getting low, or amountAvailableForUnstakeBoost is higher than the tokens inside the contract.
        uint256 vaultBalance = getVaultBalance();
        if (vaultBalance < amountAvailableForUnstakeBoost) {
            uint256 differenceToMint = amountAvailableForUnstakeBoost -
                (vaultBalance);
            infinityToken.mint(address(infinityVaultAddress), differenceToMint);
        }

        //transfer amount to the user
        require(
            infinityToken.transfer(
                address(_wallet),
                amountAvailableForUnstakeBoost
            ),
            "INFINITY from contract transfer failed; check balance and allowance for unstaking."
        );
    }

    function getVaultBalance() public view returns (uint256) {
        return infinityToken.balanceOf(address(infinityVaultAddress));
    }

    //@dev Claim, transfer, withdraw from infinityVault
    function claim() external whenNotPaused {
        address _wallet = msg.sender;
        _claim_out(_wallet);
    }

    //@dev Claim and deposit;
    function roll() public {
        address _wallet = msg.sender;
        _roll(_wallet);
    }

    /********** Internal Fuctions **************************************************/

    //@dev Add direct referral and update team structure of upline
    function _setUpline(address _wallet, address _upline) internal {
        /*
        1) User must not have existing up-line
        2) Up-line argument must not be equal to senders own address
        3) Senders address must not be equal to the owner
        4) Up-lined user must have a existing deposit
        */
        if (
            users[_wallet].upline == address(0) &&
            _upline != _wallet &&
            _wallet != owner() &&
            (users[_upline].deposit_time > 0 || _upline == owner())
        ) {
            users[_wallet].upline = _upline;
            users[_upline].referrals++;

            emit Upline(_wallet, _upline);

            total_users++;

            for (uint8 i = 0; i < ref_depth; i++) {
                if (_upline == address(0)) break;

                users[_upline].total_structure++;

                _upline = users[_upline].upline;
            }
        }
    }

    //@dev Deposit
    function _deposit(address _wallet, uint256 _amount) internal {
        //Can't maintain upline referrals without this being set

        require(
            users[_wallet].upline != address(0) || _wallet == owner(),
            "No upline"
        );

        //stats
        users[_wallet].deposits += _amount;
        users[_wallet].deposit_time = block.timestamp;

        total_deposited += _amount;

        //events
        emit NewDeposit(_wallet, _amount);
    }

    //Payout upline; Bonuses are from 5 - 30% on the 1% paid out daily; Referrals only help
    function _refPayout(
        address _wallet,
        uint256 _amount,
        uint256 _refBonus
    ) internal {
        //for deposit _wallet is the sender/depositor

        address _up = users[_wallet].upline;
        uint256 _bonus = (_amount * _refBonus) / 100; // 10% of amount

        for (uint8 i = 0; i < ref_depth; i++) {
            // If we have reached the top of the chain, the owner
            if (_up == address(0)) {
                //The equivalent of looping through all available
                users[_wallet].ref_claim_pos = ref_depth;
                break;
            } //We only match if the claim position is valid
            //user can only get refpayout if user has not reach x5 max deposit
            if (users[_wallet].ref_claim_pos == i) {
                if (
                    isBalanceCovered(_up, i + 1) &&
                    isNetPositive(_up) &&
                    users[_wallet].deposits + (_bonus) <
                    this.maxRollOf(usersRealDeposits[_wallet].deposits)
                ) {
                    (uint256 gross_payout, , , ) = payoutOf(_up);
                    users[_up].accumulatedDiv = gross_payout;
                    users[_up].deposits += _bonus;
                    users[_up].deposit_time = block.timestamp;

                    //match accounting
                    users[_up].match_bonus += _bonus;

                    //events
                    emit NewDeposit(_up, _bonus);
                    emit MatchPayout(_up, _wallet, _bonus);

                    if (users[_up].upline == address(0)) {
                        users[_wallet].ref_claim_pos = ref_depth;
                    }

                    //conditions done, break statement
                    break;
                }

                users[_wallet].ref_claim_pos += 1;
            }

            _up = users[_up].upline;
        }

        //Reward next position for referrals
        users[_wallet].ref_claim_pos += 1;

        //Reset if ref_depth or all positions are rewarded.
        if (users[_wallet].ref_claim_pos >= ref_depth) {
            users[_wallet].ref_claim_pos = 0;
        }
    }

    // calculates the next ref address
    function getNextUpline(
        address _wallet,
        uint256 _amount,
        uint256 _refBonus
    )
        public
        view
        returns (
            address _next_upline,
            bool _balance_coverd,
            bool _net_positive,
            bool _max_roll_ok
        )
    {
        address _up = users[_wallet].upline;
        uint256 _bonus = (_amount * _refBonus) / 100;

        for (uint8 i = 0; i < ref_depth; i++) {
            // If we have reached the top of the chain, the owner
            if (_up == address(0)) {
                break;
            }

            //We only match if the claim position is valid
            if (users[_wallet].ref_claim_pos == i) {
                _balance_coverd = isBalanceCovered(_up, (i + 1));
                _net_positive = isNetPositive(_up);
                _max_roll_ok =
                    users[_wallet].deposits + (_bonus) <
                    this.maxRollOf(usersRealDeposits[_wallet].deposits);

                return (_up, _balance_coverd, _net_positive, _max_roll_ok);
            }

            _up = users[_up].upline;
        }

        return (address(0), false, false, false);
    }

    //@dev Claim and deposit;
    function _roll(address _wallet) internal {
        require(!HasUsedEject(msg.sender), "user used eject");

        uint256 to_payout = _claim(_wallet, false);

        uint256 payout_taxed = (to_payout * ((100 - CompoundTax))) / (100); // 3% tax on compounding

        uint256 roll_amount_final = rollAmountOf(_wallet, payout_taxed);

        _deposit(_wallet, roll_amount_final);

        //track rolls for net positive
        users[_wallet].rolls += roll_amount_final;

        emit Leaderboard(
            _wallet,
            users[_wallet].referrals,
            users[_wallet].deposits,
            users[_wallet].payouts,
            users[_wallet].total_structure
        );
        total_txs++;
    }

    //max roll per user is 5x user deposit.
    function maxRollOf(uint256 _amount) public view returns (uint256) {
        return _amount * (max_deposit_multiplier);
    }

    //get the amount that can be rolled
    function rollAmountOf(address _wallet, uint256 _toBeRolledAmount)
        public
        view
        returns (uint256 rollAmount)
    {
        //validate the total amount that can be rolled is 5x the users real deposit only.
        uint256 maxRollAmount = maxRollOf(usersRealDeposits[_wallet].deposits);

        rollAmount = _toBeRolledAmount;

        if (users[_wallet].deposits >= maxRollAmount) {
            // user already got max roll
            revert("User exceeded x5 of total deposit to be rolled.");
        }

        if (users[_wallet].deposits + (rollAmount) >= maxRollAmount) {
            // user will reach max roll with current roll
            rollAmount = maxRollAmount - (users[_wallet].deposits); // only let him roll until max roll is reached
        }
    }

    //@dev Claim, transfer, and topoff
    function _claim_out(address _wallet) internal {
        uint256 to_payout = _claim(_wallet, true);
        uint256 realizedPayout = (to_payout * (100 - ExitTax)) / (100); // 10% tax on withdraw

        uint256 vaultBalance = getVaultBalance();
        if (vaultBalance < to_payout) {
            uint256 differenceToMint = to_payout - vaultBalance;
            infinityToken.mint(address(infinityVaultAddress), differenceToMint);
        }

        //update user withdrawn statistics.
        usersWithdrawn[_wallet].withdrawn += realizedPayout;
        usersWithdrawn[_wallet].withdrawn_BUSD += infinityTokenPriceFeed
            .getPrice(realizedPayout / (1 ether));

        //transfer payout to the investor address

        infinityVault.release(
            address(infinityToken),
            address(msg.sender),
            realizedPayout
        );
        emit Leaderboard(
            _wallet,
            users[_wallet].referrals,
            users[_wallet].deposits,
            users[_wallet].payouts,
            users[_wallet].total_structure
        );
        total_txs++;
    }

    //@dev Claim current payouts
    function _claim(address _wallet, bool isClaimedOut)
        internal
        returns (uint256)
    {
        (
            uint256 _gross_payout,
            uint256 _max_payout,
            uint256 _to_payout,

        ) = payoutOf(_wallet);
        require(users[_wallet].payouts < _max_payout, "Full payouts");
        require(!HasUsedEject(_wallet), "user is ejected");

        // Deposit payout
        if (_to_payout > 0) {
            // payout remaining allowable divs if exceeds
            if (users[_wallet].payouts + _to_payout > _max_payout) {
                _to_payout = _max_payout - (users[_wallet].payouts);
            }

            users[_wallet].payouts += _gross_payout;

            if (!isClaimedOut) {
                //Payout referrals
                uint256 compoundTaxedPayout = (_to_payout *
                    ((100 - CompoundTax))) / (100); // 3% tax on compounding
                _refPayout(_wallet, compoundTaxedPayout, CompoundTax);
            }
        }

        require(_to_payout > 0, "Zero payout");

        //Update global statistics
        total_withdraw += _to_payout;

        //Update user statistics
        users[_wallet].deposit_time = block.timestamp;
        users[_wallet].accumulatedDiv = 0;

        emit Withdraw(_wallet, _to_payout);

        if (users[_wallet].payouts >= _max_payout) {
            emit LimitReached(_wallet, users[_wallet].payouts);
        }

        return _to_payout;
    }

    function eject() external whenNotPaused {
        require(EJECT_ENABLED, "reject is not enabled");

        User storage user = users[msg.sender]; // user statistics
        uint256 amountAvailableForEject;
        uint256 amountDeposits_INF;
        uint256 infinityPrice = infinityTokenPriceFeed.getPrice(1);

        require(!HasUsedEject(msg.sender), "user already used eject");
        require(infinityPrice > 0, "infinity price missing");
        require(user.userDepositsForEject.length > 0, "no deposits");
        require(
            user.userDepositsForEject[0].depositTime >
                block.timestamp - (userDepositEjectDays),
            "eject period is over"
        ); // use first deposit time for begin of the period

        for (uint256 i = 0; i < user.userDepositsForEject.length; i++) {
            if (user.userDepositsForEject[i].ejected == false) {
                // get current BUSD value of deposited INF token.
                uint256 current_amount_BUSD = (infinityPrice *
                    (user.userDepositsForEject[i].amount_INF)) / (1 ether);
                amountDeposits_INF += user.userDepositsForEject[i].amount_INF;

                //check if current busd price of users deposited INF token is greater that INF amount(in busd) deposited.
                if (
                    current_amount_BUSD >=
                    user.userDepositsForEject[i].amount_BUSD
                ) {
                    amountAvailableForEject += (
                        (user.userDepositsForEject[i].amount_BUSD /
                            (infinityPrice)).min(
                                user.userDepositsForEject[i].amount_INF
                            )
                    );
                }
                //else-if the current busd price of users deposited INF token is lower than INF amount(in busd) deposited.
                else if (
                    (infinityPrice *
                        (user.userDepositsForEject[i].amount_INF)) /
                        (1 ether) <=
                    user.userDepositsForEject[i].amount_BUSD
                ) {
                    amountAvailableForEject =
                        amountAvailableForEject +
                        user.userDepositsForEject[i].amount_INF;
                }

                user.userDepositsForEject[i].ejected = true;
            }
        }

        // final check for manipulation. whatever the price has calculated, the deposited amount is the upper limit
        require(
            amountAvailableForEject <= amountDeposits_INF,
            "wrong calculation"
        );

        //update user deposit info
        user.deposits = 0; // eject == game over
        user.payouts = 0;
        usersRealDeposits[msg.sender].deposits = 0;
        airdrops[msg.sender].airdrops = 0;
        user.rolls = 0;

        if (STORE_BUSD_VALUE) {
            usersRealDeposits[msg.sender].deposits_BUSD = 0;
        }

        //transfer payout to the investor address less 10% sustainability fee
        uint256 ejectTaxAmount = (amountAvailableForEject * (EjectTax)) / (100);
        amountAvailableForEject = amountAvailableForEject - ejectTaxAmount;

        require(
            usersWithdrawn[msg.sender].withdrawn < amountAvailableForEject,
            "withdrawn amount is higher than eject amount"
        );

        //emit EjectDebug(msg.sender, amountAvailableForEject, usersWithdrawn[msg.sender].withdrawn, block.timestamp);
        amountAvailableForEject =
            amountAvailableForEject -
            (usersWithdrawn[msg.sender].withdrawn);

        //mint new tokens if reward infinityVault is getting low, or amountAvailableForEject is higher than the tokens inside the contract.
        uint256 vaultBalance = getVaultBalance();
        if (vaultBalance < amountAvailableForEject) {
            uint256 differenceToMint = amountAvailableForEject - (vaultBalance);
            infinityToken.mint(address(infinityVaultAddress), differenceToMint);
        }

        infinityVault.release(
            address(infinityToken),
            msg.sender,
            amountAvailableForEject
        );

        // require(infinityToken.transfer(address(msg.sender), amountAvailableForEject));

        emit Ejected(msg.sender, amountAvailableForEject, block.timestamp);
    }

    /********* Views ***************************************/

    //@dev Returns true if the address is net positive
    function isNetPositive(address _wallet) public view returns (bool) {
        if (HasUsedEject(_wallet)) {
            return false;
        }

        (uint256 _credits, uint256 _debits) = creditsAndDebits(_wallet);

        return _credits > _debits;
    }

    //@dev Returns the total credits and debits for a given address
    function creditsAndDebits(address _wallet)
        public
        view
        returns (uint256 _credits, uint256 _debits)
    {
        User memory _user = users[_wallet];
        Airdrop memory _airdrop = airdrops[_wallet];

        _credits = _airdrop.airdrops + _user.rolls + _user.deposits;
        _debits = _user.payouts;
    }

    //@dev Returns whether BR34P balance matches level
    function isBalanceCovered(address _wallet, uint8 _level)
        public
        view
        returns (bool)
    {
        if (users[_wallet].upline == address(0)) {
            return true;
        }
        return balanceLevel(_wallet) >= _level;
    }

    //@dev Returns the level of the address
    function balanceLevel(address _wallet) public view returns (uint8) {
        uint8 _level = 0;
        for (uint8 i = 0; i < ref_depth; i++) {
            //check if users staked boost(in BUSD) is less then ref_balances ( ether value/ busd value)
            if (usersBoosts[_wallet].stakedBoost_BUSD < ref_balances[i]) break;
            _level += 1;
        }

        return _level;
    }

    //@dev Returns amount of claims available for sender
    function claimsAvailable(address _wallet) public view returns (uint256) {
        (, , uint256 _to_payout, ) = payoutOf(_wallet);
        return _to_payout;
    }

    //@dev Maxpayout of 3.65 of deposit
    function maxPayoutOf(uint256 _amount) public pure returns (uint256) {
        return (_amount * 365) / 100;
    }

    function sustainabilityFeeV2(address _wallet, uint256 _pendingDiv)
        public
        view
        returns (uint256)
    {
        uint256 _bracket = users[_wallet].payouts +
            _pendingDiv /
            deposit_bracket_size;
        _bracket = _bracket.min(deposit_bracket_max);
        return _bracket * 5;
    }

    //@dev Calculate the current payout and maxpayout of a given address
    function payoutOf(address _wallet)
        public
        view
        returns (
            uint256 payout,
            uint256 max_payout,
            uint256 net_payout,
            uint256 sustainability_fee
        )
    {
        //The max_payout is capped so that we can also cap available rewards daily
        max_payout = maxPayoutOf(users[_wallet].deposits).min(max_payout_cap);

        uint256 share;

        if (users[_wallet].payouts < max_payout) {
            //Using 1e18 we capture all significant digits when calculating available divs
            share =
                (users[_wallet].deposits * (payoutRate * 1e18)) /
                (100e18) /
                (24 hours); //divide the profit by payout rate and seconds in the day

            payout = share * block.timestamp - (users[_wallet].deposit_time);

            payout += users[_wallet].accumulatedDiv;

            // payout remaining allowable divs if exceeds
            if (users[_wallet].payouts + payout > max_payout) {
                payout = max_payout - (users[_wallet].payouts);
            }

            uint256 _fee = sustainabilityFeeV2(_wallet, payout);

            sustainability_fee = (payout * _fee) / 100;

            net_payout = payout - (sustainability_fee);
        }
    }

    //@dev Get current user snapshot
    function userInfo(address _wallet)
        external
        view
        returns (
            address upline,
            uint256 deposit_time,
            uint256 deposits,
            uint256 payouts,
            uint256 direct_bonus,
            uint256 match_bonus,
            uint256 last_airdrop
        )
    {
        return (
            users[_wallet].upline,
            users[_wallet].deposit_time,
            users[_wallet].deposits,
            users[_wallet].payouts,
            users[_wallet].direct_bonus,
            users[_wallet].match_bonus,
            airdrops[_wallet].last_airdrop
        );
    }

    //@dev Get user totals
    function userInfoTotals(address _wallet)
        external
        view
        returns (
            uint256 referrals,
            uint256 total_deposits,
            uint256 total_payouts,
            uint256 total_structure,
            uint256 airdrops_total,
            uint256 airdrops_received
        )
    {
        return (
            users[_wallet].referrals,
            users[_wallet].deposits,
            users[_wallet].payouts,
            users[_wallet].total_structure,
            airdrops[_wallet].airdrops,
            airdrops[_wallet].airdrops_received
        );
    }

    function userInfoRealDeposits(address _wallet)
        external
        view
        returns (uint256 deposits_real, uint256 deposits_real_busd)
    {
        return (
            usersRealDeposits[_wallet].deposits,
            usersRealDeposits[_wallet].deposits_BUSD
        );
    }

    //@dev Get contract snapshot
    function contractInfo()
        external
        view
        returns (
            uint256 _total_users,
            uint256 _total_deposited,
            uint256 _total_withdraw,
            uint256 _total_bnb,
            uint256 _total_txs,
            uint256 _total_airdrops,
            uint256 _tokenPrice,
            uint256 _vaultBalance
        )
    {
        return (
            total_users,
            total_deposited,
            total_withdraw,
            total_bnb,
            total_txs,
            total_airdrops,
            infinityTokenPriceFeed.getPrice(1),
            getVaultBalance()
        );
    }

    /////// Airdrops ///////

    //@dev Send specified INF amount supplying an upline referral
    function airdrop(address _to, uint256 _amount) external whenNotPaused {
        address _wallet = msg.sender;
        require(AIRDROP_ENABLED == true, "airdrops are disabled");
        require(_wallet != _to, "self airdrop not allowed");
        require(_amount >= AIRDROP_MIN_AMOUNT, "minimum not reached");
        require(!HasUsedEject(msg.sender), "user used eject");

        (uint256 _realizedAmount, ) = calculateDepositTax(_amount);
        //This can only fail if the balance is insufficient
        require(
            infinityToken.transferFrom(
                _wallet,
                address(infinityVaultAddress),
                _amount
            ),
            "INFINITY to contract transfer failed; check balance and allowance, airdrop"
        );

        //Make sure _to exists in the system; we increase
        require(users[_to].upline != address(0), "_to not found");

        (uint256 gross_payout, , , ) = payoutOf(_to);

        users[_to].accumulatedDiv = gross_payout;

        //Fund to deposits (not a transfer)
        users[_to].deposits += _realizedAmount;
        users[_to].deposit_time = block.timestamp;

        //User statistics
        airdrops[_wallet].airdrops += _realizedAmount;
        airdrops[_wallet].last_airdrop = block.timestamp;
        airdrops[_to].airdrops_received += _realizedAmount;

        //Global Statistics
        total_airdrops += _realizedAmount;
        total_txs += 1;

        //Let em know!
        emit NewAirdrop(_wallet, _to, _realizedAmount, block.timestamp);
        emit NewDeposit(_to, _realizedAmount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVault {
    function release(address token, address to, uint256 tokenAmount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IPriceFeed {
    function getPrice(uint256 amount) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IInfinity {
    function mint(address _to, uint256 _amount) external;
    function remainingMintableSupply() external view returns (uint256);
    function calculateTransferTaxes(address _from, uint256 _value) external view returns (uint256 adjustedValue, uint256 taxAmount);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function mintedSupply() external returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function burn(uint256 _value) external;
}