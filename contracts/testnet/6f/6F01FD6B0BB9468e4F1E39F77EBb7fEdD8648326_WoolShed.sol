// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./Math.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

import "./IERC20.sol";
import "./IMintable.sol";
import "./IReserve.sol";

import "./Context.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract WoolShed is Ownable, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct User {
        address upline;
        uint256 referrals;
        uint256 total_structure;

        uint256 deposits;
        uint256 deposit_time;

        uint256 payouts;
        uint256 rolls;

        uint256 match_bonus;
        uint256 ref_claim_pos;

        uint256 accumulatedDiv;
    }

    struct Airdrop {
        uint256 airdrops;
        uint256 airdrops_received;
        uint256 last_airdrop;
    }

    struct Rates {
        uint256 rateLevel;
        uint256 teamLevel;

        uint256 payoutRate;

        uint256 lockedRateBalance;
        uint256 lockedTeamBalance;
    }

    IERC20 private teamToken; // Team Token
    IERC20 private rateToken; // Rate Token

    IMintable private gameToken; // Game Token
    IReserve private fundVault; // Fund Vault

    mapping(address => User) public users;
    mapping(address => Rates) internal rates;
    mapping(address => Airdrop) public airdrops;

    uint256 public CompoundTax = 5;
    uint256 public ExitTax = 10;

    uint256 private ref_bonus = 10;
    uint256 private team_depth = 15;
    uint256 private rate_depth = 7;

    uint256 private minimumInitial = 10e18;
    uint256 private minimumAmount = 1e18;

    uint256 public deposit_bracket_size = 10000e18; // @BB 5% increase whale tax per 10000 tokens... 10 below cuts it at 50% since 5 * 10
    uint256 public max_payout_cap = 100000e18;      // 100k DRIP or 10% of supply
    uint256 private deposit_bracket_max = 10;       // sustainability fee is (bracket * 5)

    uint256[] public rate_balances;
    uint256[] public team_balances;

    uint256 public total_txs;
    uint256 public total_users;
    uint256 public total_deposited;
    uint256 public total_withdrawn;
    uint256 public total_airdropped;

    uint256[] public rate_requirements;
    uint256[] public team_requirements;

    uint256 private maxPayoutRate = 11000;
    uint256 private increment = 1000;
    uint256 private baseRate = 5000;

    event onDeposit(address indexed addr, uint256 amount);
    event onWithdraw(address indexed addr, uint256 amount);

    event onLimitReached(address indexed addr, uint256 amount);
    
    event onAirdrop(address indexed from, address indexed to, uint256 amount, uint256 timestamp);

    event onLockTokens(address indexed addr, address indexed _token, uint256 _amount, uint256 timestamp);
    event onUnlockTokens(address indexed addr, address indexed _token, uint256 _amount, uint256 timestamp);

    event Leaderboard(address indexed addr, uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure);

    /* ========== INITIALIZER ========== */

    constructor (address _teamToken, address _rateToken, address _gameToken, address _vault) {
        teamToken = IERC20(_teamToken);
        rateToken = IERC20(_rateToken);
        gameToken = IMintable(_gameToken);

        fundVault = IReserve(_vault);
    }

    receive() external payable {
        
    }

    /********** User Fuctions **************************************************/

    //@dev Deposit specified DRIP amount supplying an upline referral
    function deposit(address _upline, uint256 _amount) external {

        address _addr = msg.sender;

        (uint256 realizedDeposit, ) = gameToken.calculateTransferTaxes(_addr, _amount);
        uint256 _total_amount = realizedDeposit;

        require(_amount >= minimumAmount, "Minimum deposit");

        //If fresh account require a minimal amount of DRIP
        if (users[_addr].deposits == 0){
            require(_amount >= minimumInitial, "Initial deposit too low");
        }

        _setUpline(_addr, _upline);

        uint256 taxedDivs;
        // Claim if divs are greater than 1% of the deposit
        if (claimsAvailable(_addr) > _amount / 100){
            uint256 claimedDivs = _claim(_addr, true);
            taxedDivs = claimedDivs.mul(SafeMath.sub(100, CompoundTax)).div(100); // 5% tax on compounding
            _total_amount += taxedDivs;
            taxedDivs = taxedDivs / 2;
        }

        //Transfer DRIP to the contract
        require(gameToken.transferFrom(_addr, address(fundVault), _amount), "DRIP token transfer failed");

        /*
        User deposits 10;
        1 goes for tax, 9 are realized deposit
        */

        _deposit(_addr, _total_amount);

        _refPayout(_addr, realizedDeposit + taxedDivs, ref_bonus);

        emit Leaderboard(_addr, users[_addr].referrals, users[_addr].deposits, users[_addr].payouts, users[_addr].total_structure);
        total_txs++;

    }

    //@dev Claim, transfer, withdraw from vault
    function claim() external {
        address _addr = msg.sender;
        _claim_out(_addr);
    }

    //@dev Claim and deposit;
    function roll() external {
        address _addr = msg.sender;
        _roll(_addr);
    }

    //@dev Send specified DRIP amount supplying an upline referral
    function airdrop(address _to, uint256 _amount) external {

        address _addr = msg.sender;

        (uint256 _realizedAmount, ) = gameToken.calculateTransferTaxes(_addr, _amount);
        require(gameToken.transferFrom( _addr, address(fundVault), _amount), "REQUIRES_APPROVAL");

        require(users[_to].upline != address(0), "_to not found");

        (uint256 gross_payout,,,) = payoutOf(_to);

        users[_to].accumulatedDiv = gross_payout;

        //Fund to deposits (not a transfer)
        users[_to].deposits += _realizedAmount;
        users[_to].deposit_time = block.timestamp;

        //User stats
        airdrops[_addr].airdrops += _realizedAmount;
        airdrops[_addr].last_airdrop = block.timestamp;
        airdrops[_to].airdrops_received += _realizedAmount;

        //Keep track of overall stats
        total_airdropped += _realizedAmount;
        total_txs += 1;


        //Let em know!
        emit onAirdrop(_addr, _to, _realizedAmount, block.timestamp);
        emit onDeposit(_to, _realizedAmount);
    }

    function lock(address _token, uint256 _amount) external returns (bool _success) {
        require(_token == address(teamToken) || _token == address(rateToken), "ONLY_BOOST_TOKENS");

        // 0: Identify caller as _addr
        address _addr = msg.sender;

        // 1: Collect tokens from caller
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        // if token is SH33P, boost daily rate
        if (_token == address(teamToken)) {

            // 2A: Credit their records with the amount
            rates[_addr].lockedRateBalance += _amount;
            rates[_addr].rateLevel = rateBalanceLevel(_addr);
        }

        // if token is xSH33P, boost team structure
        if (_token == address(rateToken)) {

            // 2A: Credit their records with the amount
            rates[_addr].lockedTeamBalance += _amount;
            rates[_addr].teamLevel = teamBalanceLevel(_addr);
        }

        emit onLockTokens(msg.sender, _token, _amount, block.timestamp);
        return true;
    }

    function unlock(address _token, uint256 _amount) external returns (bool _success) {
        require(_token == address(teamToken) || _token == address(rateToken), "ONLY_BOOST_TOKENS");

        // 0: Identify caller as _addr
        address _addr = msg.sender;

        // if token is SH33P, boost daily rate
        if (_token == address(teamToken)) {

            // 2A: Credit their records with the amount
            rates[_addr].lockedRateBalance -= _amount;
            rates[_addr].rateLevel = rateBalanceLevel(_addr);
        }

        // if token is xSH33P, boost team structure
        if (_token == address(rateToken)) {

            // 2A: Credit their records with the amount
            rates[_addr].lockedTeamBalance -= _amount;
            rates[_addr].teamLevel = teamBalanceLevel(_addr);
        }

        // 1: Collect tokens from caller
        IERC20(_token).transfer(msg.sender, _amount);

        emit onUnlockTokens(msg.sender, _token, _amount, block.timestamp);
        return true;
    }

    /********* Views ***************************************/

    // Payout Rate of _addr
    function payoutRateOf(address _addr) public view returns (uint256) {
        //      _rate = (   5000 ) + (  1000 * (however many increments for tokens locked))
        uint256 _rate = (baseRate.add(increment.mul(rateBalanceLevel(_addr))));
        return (_rate);
    }

    //@dev Returns the level of the address
    function rateBalanceLevel(address _addr) public view returns (uint8) {
        uint8 _level = 0;
        for (uint8 i = 0; i < rate_depth; i++) {
            if (rates[_addr].lockedRateBalance < rate_requirements[i]) break;
            _level += 1;
        }

        return _level;
    }

    //@dev Returns the level of the address
    function teamBalanceLevel(address _addr) public view returns (uint8) {
        uint8 _level = 0;
        for (uint8 i = 0; i < team_depth; i++) {
            if (rates[_addr].lockedTeamBalance < team_requirements[i]) break;
            _level += 1;
        }

        return _level;
    }

    //@dev Returns true if the address is net positive
    function isNetPositive(address _addr) public view returns (bool) {
        (uint256 _credits, uint256 _debits) = creditsAndDebits(_addr);
        return _credits > _debits;
    }

    //@dev Returns amount of claims available for sender
    function claimsAvailable(address _addr) public view returns (uint256) {
        ( , , uint256 _to_payout, ) = payoutOf(_addr);
        return _to_payout;
    }

    //@dev Maxpayout of 3.65 of deposit
    function maxPayoutOf(uint256 _amount) public pure returns(uint256) {
        return _amount * 365 / 100;
    }

    // Sustainability fee to stop whales fucking the system
    function sustainabilityFee(address _addr, uint256 _pendingDiv) public view returns (uint256) {
        uint256 _bracket = users[_addr].payouts.add(_pendingDiv).div(deposit_bracket_size);
        _bracket = SafeMath.min(_bracket, deposit_bracket_max);
        return _bracket * 5;
    }

    //@dev Returns the total credits and debits for a given address
    function creditsAndDebits(address _addr) public view returns (uint256 _credits, uint256 _debits) {
        User memory _user = users[_addr];
        Airdrop memory _airdrop = airdrops[_addr];

        _credits = _airdrop.airdrops + _user.rolls + _user.deposits;
        _debits = _user.payouts;

    }

    //@dev Calculate the current payout and maxpayout of a given address
    function payoutOf(address _addr) public view returns(uint256 payout, uint256 max_payout, uint256 net_payout, uint256 sustainability_fee) {
        //The max_payout is capped so that we can also cap available rewards daily
        max_payout = maxPayoutOf(users[_addr].deposits).min(max_payout_cap);

        uint256 share;

        // Get payout rate as calculated by locked token values and holdings
        uint256 userPayoutRate = payoutRateOf(msg.sender);

        if(users[_addr].payouts < max_payout) {

            share = users[_addr].deposits.mul(userPayoutRate * 1e18).div(100e18).div(24 hours);

            payout = share * block.timestamp.sub(users[_addr].deposit_time);

            payout += users[_addr].accumulatedDiv;

            if(users[_addr].payouts + payout > max_payout) {
                payout = max_payout.sub(users[_addr].payouts);
            }

            uint256 _fee = sustainabilityFee(_addr, payout);

            sustainability_fee = payout * _fee / 100;

            net_payout = payout.sub(sustainability_fee);
        }
    }

    //@dev Get contract snapshot
    function contractInfo() external view returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw, uint256 _total_txs, uint256 _total_airdrops) {
        return (total_users, total_deposited, total_withdrawn, total_txs, total_airdropped);
    }

    //@dev Get current user snapshot
    function userInfo(address _addr) external view returns(address upline, uint256 deposit_time, uint256 deposits, uint256 payouts, uint256 match_bonus, uint256 last_airdrop) {
        return (users[_addr].upline, users[_addr].deposit_time, users[_addr].deposits, users[_addr].payouts, users[_addr].match_bonus, airdrops[_addr].last_airdrop);
    }

    //@dev Get user totals
    function userInfoTotals(address _addr) external view returns(uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure, uint256 airdrops_total, uint256 airdrops_received) {
        return (users[_addr].referrals, users[_addr].deposits, users[_addr].payouts, users[_addr].total_structure, airdrops[_addr].airdrops, airdrops[_addr].airdrops_received);
    }

    /****** Administrative Functions *******/

    function updateRefDepth(uint256 _newRefDepth) public onlyOwner {
        team_depth = _newRefDepth;
    }

    function updateRefBonus(uint256 _newRefBonus) public onlyOwner {
        ref_bonus = _newRefBonus;
    }

    function updateInitialDeposit(uint256 _newInitialDeposit) public onlyOwner {
        minimumInitial = _newInitialDeposit;
    }

    function updateCompoundTax(uint256 _newCompoundTax) public onlyOwner {
        require(_newCompoundTax >= 0 && _newCompoundTax <= 20);
        CompoundTax = _newCompoundTax;
    }

    function updateExitTax(uint256 _newExitTax) public onlyOwner {
        require(_newExitTax >= 0 && _newExitTax <= 20);
        ExitTax = _newExitTax;
    }

    function updateDepositBracketSize(uint256 _newBracketSize) public onlyOwner {
        deposit_bracket_size = _newBracketSize;
    }

    function updateMaxPayoutCap(uint256 _newPayoutCap) public onlyOwner {
        max_payout_cap = _newPayoutCap;
    }

    function updateHoldRequirements(uint256[] memory _newRefBalances) public onlyOwner {
        require(_newRefBalances.length == team_depth);
        delete team_balances;
        for(uint8 i = 0; i < team_depth; i++) {
            team_balances.push(_newRefBalances[i]);
        }
    }

    /********** Internal Fuctions **************************************************/

    //@dev Add direct referral and update team structure of upline
    function _setUpline(address _addr, address _upline) internal {
        /*
        1) User must not have existing up-line
        2) Up-line argument must not be equal to senders own address
        3) Senders address must not be equal to the owner
        4) Up-lined user must have a existing deposit
        */
        if(users[_addr].upline == address(0) && _upline != _addr && _addr != owner() && (users[_upline].deposit_time > 0 || _upline == owner() )) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;

            total_users++;

            for(uint8 i = 0; i < team_depth; i++) {
                if(_upline == address(0)) break;

                users[_upline].total_structure++;

                _upline = users[_upline].upline;
            }
        }
    }

    //@dev Deposit
    function _deposit(address _addr, uint256 _amount) internal {
        //Can't maintain upline referrals without this being set

        require(users[_addr].upline != address(0) || _addr == owner(), "No upline");

        //stats
        users[_addr].deposits += _amount;
        users[_addr].deposit_time = block.timestamp;

        total_deposited += _amount;

        //events
        emit onDeposit(_addr, _amount);

    }

    //Payout upline; Bonuses are from 5 - 30% on the 1% paid out daily; Referrals only help
    function _refPayout(address _addr, uint256 _amount, uint256 _refBonus) internal {
        //for deposit _addr is the sender/depositor

        address _up = users[_addr].upline;
        uint256 _bonus = _amount * _refBonus / 100; // 10% of amount
        uint256 _share = _bonus / 4;                // 2.5% of amount
        uint256 _up_share = _bonus.sub(_share);     // 7.5% of amount
        bool _team_found = false;

        for(uint8 i = 0; i < team_depth; i++) {

            // If we have reached the top of the chain, the owner
            if(_up == address(0)){
                //The equivalent of looping through all available
                users[_addr].ref_claim_pos = team_depth;
                break;
            }

            //We only match if the claim position is valid
            if(users[_addr].ref_claim_pos == i) {
                if (isTeamBalanceCovered(_up, i + 1) && isNetPositive(_up)){

                    //Team wallets are split 75/25%
                    if(users[_up].referrals >= 5 && !_team_found) {

                        //This should only be called once
                        _team_found = true;

                        (uint256 gross_payout_upline,,,) = payoutOf(_up);
                        users[_up].accumulatedDiv = gross_payout_upline;
                        users[_up].deposits += _up_share;
                        users[_up].deposit_time = block.timestamp;

                        (uint256 gross_payout_addr,,,) = payoutOf(_addr);
                        users[_addr].accumulatedDiv = gross_payout_addr;
                        users[_addr].deposits += _share;
                        users[_addr].deposit_time = block.timestamp;

                        //match accounting
                        users[_up].match_bonus += _up_share;

                        //Synthetic Airdrop tracking; team wallets get automatic airdrop benefits
                        airdrops[_up].airdrops += _share;
                        airdrops[_up].last_airdrop = block.timestamp;
                        airdrops[_addr].airdrops_received += _share;

                        //Global airdrops
                        total_airdropped += _share;

                        //Events
                        emit onDeposit(_addr, _share);
                        emit onDeposit(_up, _up_share);

                        emit onAirdrop(_up, _addr, _share, block.timestamp);
                    } else {

                        (uint256 gross_payout,,,) = payoutOf(_up);
                        users[_up].accumulatedDiv = gross_payout;
                        users[_up].deposits += _bonus;
                        users[_up].deposit_time = block.timestamp;


                        //match accounting
                        users[_up].match_bonus += _bonus;

                        //events
                        emit onDeposit(_up, _bonus);
                    }

                    if (users[_up].upline == address(0)){
                        users[_addr].ref_claim_pos = team_depth;
                    }

                    //The work has been done for the position; just break
                    break;
                }

                users[_addr].ref_claim_pos += 1;
            }

            _up = users[_up].upline;
        }

        //Reward the next
        users[_addr].ref_claim_pos += 1;

        //Reset if we've hit the end of the line
        if (users[_addr].ref_claim_pos >= team_depth){
            users[_addr].ref_claim_pos = 0;
        }
    }

    //@dev Claim and deposit;
    function _roll(address _addr) internal {

        uint256 to_payout = _claim(_addr, false);

        uint256 payout_taxed = to_payout.mul(SafeMath.sub(100, CompoundTax)).div(100); // 5% tax on compounding

        //Recycle baby!
        _deposit(_addr, payout_taxed);

        //track rolls for net positive
        users[_addr].rolls += payout_taxed;

        emit Leaderboard(_addr, users[_addr].referrals, users[_addr].deposits, users[_addr].payouts, users[_addr].total_structure);
        total_txs++;

    }

    //@dev Claim, transfer, and topoff
    function _claim_out(address _addr) internal {

        uint256 to_payout = _claim(_addr, true);

        uint256 vaultBalance = gameToken.balanceOf(address(fundVault));
        if (vaultBalance < to_payout) {
            uint256 differenceToMint = to_payout.sub(vaultBalance);
            gameToken.directMint(address(fundVault), differenceToMint);
        }

        fundVault.withdraw(to_payout);

        uint256 realizedPayout = to_payout.mul(SafeMath.sub(100, ExitTax)).div(100); // 10% tax on withdraw
        require(gameToken.transfer(address(msg.sender), realizedPayout));

        emit Leaderboard(_addr, users[_addr].referrals, users[_addr].deposits, users[_addr].payouts, users[_addr].total_structure);
        total_txs++;

    }

    //@dev Claim current payouts
    function _claim(address _addr, bool isClaimedOut) internal returns (uint256) {
        (uint256 _gross_payout, uint256 _max_payout, uint256 _to_payout, ) = payoutOf(_addr);
        require(users[_addr].payouts < _max_payout, "Full payouts");

        // Deposit payout
        if(_to_payout > 0) {

            // payout remaining allowable divs if exceeds
            if(users[_addr].payouts + _to_payout > _max_payout) {
                _to_payout = _max_payout.sub(users[_addr].payouts);
            }

            users[_addr].payouts += _gross_payout;

            if (!isClaimedOut){
                //Payout referrals
                uint256 compoundTaxedPayout = _to_payout.mul(SafeMath.sub(100, CompoundTax)).div(100); // 5% tax on compounding
                _refPayout(_addr, compoundTaxedPayout, 5);
            }
        }

        require(_to_payout > 0, "Zero payout");

        //Update the payouts
        total_withdrawn += _to_payout;

        //Update time!
        users[_addr].deposit_time = block.timestamp;
        users[_addr].accumulatedDiv = 0;

        emit onWithdraw(_addr, _to_payout);

        if(users[_addr].payouts >= _max_payout) {
            emit onLimitReached(_addr, users[_addr].payouts);
        }

        return _to_payout;
    }

    //@dev Returns whether Locked xSH33P balance matches level
    function isTeamBalanceCovered(address _addr, uint8 _level) private view returns (bool) {
        if (users[_addr].upline == address(0)){
            return true;
        }

        return teamBalanceLevel(_addr) >= _level;
    }

    //@dev Returns whether Locked SH33P balance matches level
    function isRateBalanceCovered(address _addr, uint8 _level) private view returns (bool) {
        if (users[_addr].upline == address(0)){
            return true;
        }

        return rateBalanceLevel(_addr) >= _level;
    }

    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    function updateTeamHoldRequirements(uint256[] memory _newTeamBalances) external onlyOwner {
        require(_newTeamBalances.length == team_depth);
        delete team_requirements;
        for(uint8 i = 0; i < team_depth; i++) {
            team_requirements.push(_newTeamBalances[i]);
        }
    }

    function updateRateHoldRequirements(uint256[] memory _newRateBalances) external onlyOwner {
        require(_newRateBalances.length == rate_depth);
        delete rate_requirements;
        for(uint8 i = 0; i < rate_depth; i++) {
            rate_requirements.push(_newRateBalances[i]);
        }
    }

    function updateMaxPayoutRate(uint256 _newPayoutRate) external onlyOwner {
        maxPayoutRate = _newPayoutRate;
    }
}