/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IMintable is IERC20 {
    function topUpRewards(address _user, uint256 _amount) external returns (bool);
    function credit(address to, uint256 amount) external returns (bool);
    function settle(address to) external returns (bool);

    function calculateTransferTaxes(address, uint256) external view returns (uint256, uint256);
    function remainingMintableSupply() external view returns (uint256);
    function estimateMint(uint256 _amount) external view returns (uint256);
}

interface IWoolshedVault {
    function withdraw(uint256 tokenAmount) external;
}

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract RatesController is Ownable {
    using SafeMath for uint256;

    IERC20 public xSH33P_Token; // xSH33P
    IERC20 public SH33P_Token; // SH33P

    address public devWallet;

    uint256[4] public xSH33PBalances;
    uint256[5] public SH33PBalances;

    uint256[6] public rates;
    uint16[6] public maxPayOutRates;
    uint256[15] public refBonuses;

    constructor(address _xSH33P_Token, address _SH33P_Token, address _devWallet) {
        xSH33P_Token = IERC20(_xSH33P_Token); //holding token = xSH33P Token
        SH33P_Token = IERC20(_SH33P_Token); // = SH33P token

        devWallet = _devWallet;

        //set xSH33P balances
        xSH33PBalances[0] = 400e18;
        xSH33PBalances[1] = 2000e18;
        xSH33PBalances[2] = 10000e18;
        xSH33PBalances[3] = 50000e18;

        //assign rates values -- from 0.5 to 1.1 -- daily rates (holding xSH33P)
        rates[0] = 60e16; //0.6
        rates[1] = 70e16; //0.7
        rates[2] = 80e16; //8
        rates[3] = 90e16; //0.9
        rates[4] = 100e16; //1.0
        rates[5] = 110e16; //1.1

        //set SH33P balances
        SH33PBalances[0] = 50e18;
        SH33PBalances[1] = 100e18;
        SH33PBalances[2] = 150e18;
        SH33PBalances[3] = 200e18;
        SH33PBalances[4] = 250e18;

        //assign maxPayOutRates values -- from 255 to 365 -- rates for holding SH33P
        maxPayOutRates[0] = 255;
        maxPayOutRates[1] = 277;
        maxPayOutRates[2] = 300;
        maxPayOutRates[3] = 321;
        maxPayOutRates[4] = 343;
        maxPayOutRates[5] = 365;

        refBonuses[0] = 5; // 5%
        refBonuses[1] = 5; // 5%
        refBonuses[2] = 5; // 5%
        refBonuses[3] = 5; // 5%
        refBonuses[4] = 5; // 5%
        refBonuses[5] = 5; // 5%
        refBonuses[6] = 5; // 5%
        refBonuses[7] = 5; // 5%
        refBonuses[8] = 5; // 5%
        refBonuses[9] = 5; // 5%
        refBonuses[10] = 5; // 5%
        refBonuses[11] = 5; // 5%
        refBonuses[12] = 5; // 5%
        refBonuses[13] = 5; // 5%
        refBonuses[14] = 5;
    }

    function setToken1(address tokenAddress) public onlyOwner {
        xSH33P_Token = IERC20(tokenAddress);
    }

    function setToken2(address tokenAddress) public onlyOwner {
        SH33P_Token = IERC20(tokenAddress);
    }

    function setToken1Balances(uint256[4] memory _balances) public onlyOwner {
        xSH33PBalances = _balances;
    }

    function setToken2Balances(uint256[5] memory _balances) public onlyOwner {
        SH33PBalances = _balances;
    }

    function setRates(uint256[6] memory _rates) public onlyOwner {
        rates = _rates;
    }

    function setMaxPayOutRates(uint16[6] memory _maxPayOutRates) public onlyOwner {
        maxPayOutRates = _maxPayOutRates;
    }

    function setRefBonuses(uint256[5] memory _refBonuses) public onlyOwner {
        refBonuses = _refBonuses;
    }

    function payoutRateOf(address _addr) public view returns (uint256) {
        uint256 balance = xSH33P_Token.balanceOf(_addr);
        uint256 rate;

        if (balance < xSH33PBalances[0]) {
            rate = rates[0];
        }
        if (balance >= xSH33PBalances[0] && balance < xSH33PBalances[1]) {
            rate = rates[1];
        }
        if (balance >= xSH33PBalances[1] && balance < xSH33PBalances[2]) {
            rate = rates[2];
        }
        if (balance >= xSH33PBalances[2] && balance < xSH33PBalances[3]) {
            rate = rates[3];
        }
        if (balance >= xSH33PBalances[3]) {
            rate = rates[4];
        }

        return rate;
    }

    function getMaxPayout(address _user, uint256 amount) public view returns (uint256) {
        
        uint256 balance = SH33P_Token.balanceOf(_user);
        uint256 maxPayOut;

        if (_user == devWallet) {
            maxPayOut = (amount * 3650) / 100;
        }

        if (balance < SH33PBalances[0]) {
            maxPayOut = (amount * maxPayOutRates[0]) / 100;
        }
        if (balance >= SH33PBalances[0] && balance < SH33PBalances[1]) {
            maxPayOut = (amount * maxPayOutRates[1]) / 100;
        }
        if (balance >= SH33PBalances[1] && balance < SH33PBalances[2]) {
            maxPayOut = (amount * maxPayOutRates[2]) / 100;
        }
        if (balance >= SH33PBalances[2] && balance < SH33PBalances[3]) {
            maxPayOut = (amount * maxPayOutRates[3]) / 100;
        }
        if (balance >= SH33PBalances[3] && balance < SH33PBalances[4]) {
            maxPayOut = (amount * maxPayOutRates[4]) / 100;
        }
        if (balance >= SH33PBalances[4]) {
            maxPayOut = (amount * maxPayOutRates[5]) / 100;
        }

        return maxPayOut;
    }

    function getRefBonus(uint8 level) public view returns (uint256) {
        return refBonuses[level];
    }
}

abstract contract Initializable {

    bool private _initialized;
    bool private _initializing;

    modifier initializer() {
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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

abstract contract ContextUpgradeable is Initializable {

    uint256[50] private __gap;

    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    
    address private _owner;

    uint256[49] private __gap;

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Woolshed is OwnableUpgradeable {
    using SafeMath for uint256;

    struct User {
        address upline;
        uint256 referrals;
        uint256 total_structure;

        uint256 match_bonus;

        uint256 deposits;
        uint256 deposit_time;

        uint256 payouts;
        uint256 rolls;

        uint256 ref_claim_pos;
        uint256 accumulatedDiv;
    }

    struct Airdrop {
        uint256 airdrops;
        uint256 airdrops_received;
        uint256 last_airdrop;
    }

    struct Custody {
        address manager;
        address beneficiary;
        uint256 last_heartbeat;
        uint256 last_checkin;
        uint256 heartbeat_interval;
    }

    IERC20 private sheepToken;
    IMintable private woolToken;

    RatesController private ratesController;
    IWoolshedVault private woolshedVault;

    mapping(address => User) private users;
    mapping(address => Airdrop) private airdrops;
    mapping(address => Custody) private custody;

    uint256 public CompoundTax;
    uint256 public ExitTax;

    uint256 private ref_depth;
    uint256 private ref_bonus;

    uint256 private minimumAmount; // Minimum amount and initial can be the same...

    uint256 public deposit_bracket_size; // @BB 5% increase whale tax per 10000 tokens... 10 below cuts it at 50% since 5 * 10
    uint256 public max_payout_cap;       // 50k WOOL per account max
    uint256 private deposit_bracket_max; // sustainability fee is (bracket * 5)

    uint256[] public ref_balances;

    uint256 public total_airdrops;
    uint256 public total_users;
    uint256 public total_deposited;
    uint256 public total_withdraw;
    uint256 public total_txs;

    uint256 public constant MAX_UINT = 2**256 - 1;

    event onDeposit(address indexed addr, uint256 amount);
    event onWithdraw(address indexed addr, uint256 amount);
    event onAirdrop(address indexed from, address indexed to, uint256 amount, uint256 timestamp);
    
    event onMatchPayout(address indexed addr, address indexed from, uint256 amount);
    event onLimitReached(address indexed addr, uint256 amount);

    event ManagerUpdate(address indexed addr, address indexed manager, uint256 timestamp);
    
    event onPulse(address indexed addr, uint256 timestamp);
    event onCheckIn(address indexed addr, uint256 timestamp);

    event Leaderboard(address indexed addr, uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure);

    /* ========== INITIALIZER ========== */
    function initialize(address _teamToken, address _gameToken, address _rates, address _vault) external initializer {
        __Ownable_init();

        sheepToken = IERC20(_teamToken);
        woolToken = IMintable(_gameToken);
        woolshedVault = IWoolshedVault(_vault);
        ratesController = RatesController(_rates);

        max_payout_cap = 50000 * 1e18;
    }

    //@dev Default payable is empty since Faucet executes trades and recieves BNB
    fallback() external {
        //Do nothing, CRO will be sent to contract when selling tokens
    }

    /****** Administrative Functions *******/

    function updateRefDepth(uint256 _newRefDepth) external onlyOwner {
        ref_depth = _newRefDepth;
    }

    function updateMinimumAmount(uint256 _newMinimumAmount) external onlyOwner {
        minimumAmount = _newMinimumAmount;
    }

    function updateCompoundTax(uint256 _newCompoundTax) external onlyOwner {
        require(_newCompoundTax >= 0 && _newCompoundTax <= 20);
        CompoundTax = _newCompoundTax;
    }

    function updateExitTax(uint256 _newExitTax) external onlyOwner {
        require(_newExitTax >= 0 && _newExitTax <= 20);
        ExitTax = _newExitTax;
    }

    function updateDepositBracketSize(uint256 _newBracketSize) external onlyOwner {
        deposit_bracket_size = _newBracketSize;
    }

    function updateMaxPayoutCap(uint256 _newPayoutCap) external onlyOwner {
        max_payout_cap = _newPayoutCap;
    }

    function updateHoldRequirements(uint256[] memory _newRefBalances) external onlyOwner {
        require(_newRefBalances.length == ref_depth);
        delete ref_balances;
        for (uint8 i = 0; i < ref_depth; i++) {
            ref_balances.push(_newRefBalances[i]);
        }
    }

    /********** User Fuctions **************************************************/

    function checkin(address _user) public {
        
        // Find manager if one is set
        (, , address _manager) = getCustody(_user);

        // Only an account manager or the actual account holder can update checkin time
        require(msg.sender == _manager || msg.sender == _user, "INVALID_CALLER");

        // Update the checkin timestamp
        custody[_user].last_checkin = block.timestamp;

        emit onCheckIn(_user, custody[_user].last_checkin);
    }

    //@dev Deposit specified WOOL amount supplying an upline referral
    function deposit(address _upline, uint256 _amount) external {
        address _addr = msg.sender;

        (uint256 realizedDeposit, uint256 taxAmount) = woolToken.calculateTransferTaxes(_addr, _amount);
        uint256 _total_amount = realizedDeposit;

        //onCheckIn for custody management.
        checkin(_addr);

        require(_amount >= minimumAmount, "Minimum deposit");

        //If fresh account require a minimal amount of WOOL
        if (users[_addr].deposits == 0) {
            require(_amount >= minimumAmount, "Initial deposit too low");
        }

        _setUpline(_addr, _upline);

        uint256 taxedDivs;

        // Claim if divs are greater than 1% of the deposit
        if (claimsAvailable(_addr) > _amount / 100) {
            uint256 claimedDivs = _claim(_addr, true);
            taxedDivs = claimedDivs.mul(SafeMath.sub(100, CompoundTax)).div(100); // 5% tax on compounding
            _total_amount += taxedDivs;
        }

        //Transfer WOOL to the contract
        require(woolToken.transferFrom(_addr, address(woolshedVault), _amount), "WOOL token transfer failed");

        // User deposits 10; 1 goes for tax, 9 are realized deposit
        _deposit(_addr, _total_amount);

        // 5% direct commission; only if net positive
        address _up = users[_addr].upline;

        _refPayout(_up, taxAmount + taxedDivs, ref_bonus);

        emit Leaderboard(_addr, users[_addr].referrals, users[_addr].deposits, users[_addr].payouts, users[_addr].total_structure);
        total_txs++;
    }

    //@dev Claim, transfer, withdraw from vault
    function claim() external {

        address _addr = msg.sender;

        //onCheckIn for custody management.  If a user rolls for themselves they are active
        checkin(_addr);

        _claim_out(_addr);
    }

    //@dev Claim and deposit;
    function roll(address _user) external {

        // Find manager if one is set
        (, , address _manager) = getCustody(_user);

        // Only an account manager or the actual account holder can update checkin time
        require(msg.sender == _manager || msg.sender == _user, "INVALID_CALLER");

        //onCheckIn for custody management.  If a user rolls for themselves they are active
        checkin(_user);

        _roll(_user);
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
        if (
            users[_addr].upline == address(0) &&
            _upline != _addr &&
            _addr != owner() &&
            (users[_upline].deposit_time > 0 || _upline == owner())
        ) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;

            total_users++;

            for (uint8 i = 0; i < ref_depth; i++) {
                if (_upline == address(0)) break;

                users[_upline].total_structure++;

                _upline = users[_upline].upline;
            }
        }
    }

    //@dev Deposit
    function _deposit(address _addr, uint256 _amount) internal {
        //Can't maintain upline referrals without this being set

        require(
            users[_addr].upline != address(0) || _addr == owner(),
            "No upline"
        );

        //stats
        users[_addr].deposits += _amount;
        users[_addr].deposit_time = block.timestamp;

        total_deposited += _amount;

        //events
        emit onDeposit(_addr, _amount);
    }

    //Payout upline; Bonuses are from 5 - 30% on the 1% paid out daily; Referrals only help
    function _refPayout(address _addr, uint256 _amount, uint256 _refBonus) internal {
        // for deposit _addr is the sender/depositor

        address _up = users[_addr].upline;
        uint256 _bonus = _amount * _refBonus / 100; // 10% of amount
        uint256 _share = _bonus / 4;                // 2.5% of amount
        uint256 _up_share = _bonus.sub(_share);     // 7.5% of amount
        bool _team_found = false;

        for(uint8 i = 0; i < ref_depth; i++) {

            // If we have reached the top of the chain, the owner
            if(_up == address(0)){
                users[_addr].ref_claim_pos = ref_depth;
                break;
            }

            //We only match if the claim position is valid
            if(users[_addr].ref_claim_pos == i) {
                if (isBalanceCovered(_up, i + 1) && isNetPositive(_up)){

                    //Team wallets are split 75/25%
                    if(users[_up].referrals >= 5 && !_team_found) {

                        //This should only be called once
                        _team_found = true;

                        (uint256 gross_payout_upline,,,) = payoutOf(_up);
                        updateDepositData(_up, gross_payout_upline, _up_share);

                        users[_up].match_bonus += _up_share;

                        (uint256 gross_payout_addr,,,) = payoutOf(_addr);
                        updateDepositData(_addr, gross_payout_addr, _share);

                        airdrops[_up].airdrops += _share;
                        airdrops[_up].last_airdrop = block.timestamp;
                        airdrops[_addr].airdrops_received += _share;

                        total_airdrops += _share;

                        emit onDeposit(_addr, _share);
                        emit onDeposit(_up, _up_share);
                        emit onMatchPayout(_up, _addr, _up_share);
                    } else {

                        (uint256 gross_payout,,,) = payoutOf(_up);
                        updateDepositData(_up, gross_payout, _bonus);

                        users[_up].match_bonus += _bonus;

                        emit onDeposit(_up, _bonus);
                        emit onMatchPayout(_up, _addr, _bonus);
                    }

                    if (users[_up].upline == address(0)){
                        users[_addr].ref_claim_pos = ref_depth;
                    }

                    break;
                }

                users[_addr].ref_claim_pos += 1;
            }

            _up = users[_up].upline;
        }

        //Reward the next
        users[_addr].ref_claim_pos += 1;

        //Reset if we've hit the end of the line
        if (users[_addr].ref_claim_pos >= ref_depth){
            users[_addr].ref_claim_pos = 0;
        }
    }

    //@dev General purpose heartbeat in the system used for custody/management planning
    function _heart(address _addr) internal {
        custody[_addr].last_heartbeat = block.timestamp;
        emit onPulse(_addr, custody[_addr].last_heartbeat);
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

        uint256 vaultBalance = woolToken.balanceOf(address(woolshedVault));

        if (vaultBalance < to_payout) {
            uint256 differenceToMint = to_payout.sub(vaultBalance);
            woolToken.topUpRewards(address(woolshedVault), differenceToMint);
        }

        woolshedVault.withdraw(to_payout);

        uint256 realizedPayout = to_payout.mul(SafeMath.sub(100, ExitTax)).div(100); // 15% tax on withdraw
        require(woolToken.transfer(address(msg.sender), realizedPayout));

        emit Leaderboard(_addr, users[_addr].referrals, users[_addr].deposits, users[_addr].payouts, users[_addr].total_structure);
        total_txs++;
    }

    //@dev Claim current payouts
    function _claim(address _addr, bool isClaimedOut) internal returns (uint256) {
        (uint256 _gross_payout, uint256 _max_payout, uint256 _to_payout, ) = payoutOf(_addr);
        require(users[_addr].payouts < _max_payout, "Full payouts");

        // Deposit payout
        if (_to_payout > 0) {
            // payout remaining allowable divs if exceeds
            if (users[_addr].payouts + _to_payout > _max_payout) {
                _to_payout = _max_payout.safeSub(users[_addr].payouts);
            }

            users[_addr].payouts += _gross_payout;

            if (!isClaimedOut) {
                //Payout referrals
                uint256 compoundTaxedPayout = _to_payout.mul(SafeMath.sub(100, CompoundTax)).div(100); // 5% tax on compounding
                _refPayout(_addr, compoundTaxedPayout, 5);
            }
        }

        require(_to_payout > 0, "Zero payout");

        //Update the payouts
        total_withdraw += _to_payout;

        //Update time!
        users[_addr].deposit_time = block.timestamp;
        users[_addr].accumulatedDiv = 0;

        emit onWithdraw(_addr, _to_payout);

        if (users[_addr].payouts >= _max_payout) {
            emit onLimitReached(_addr, users[_addr].payouts);
        }

        return _to_payout;
    }

    /********* Views ***************************************/

    //@dev Returns true if the address is net positive
    function isNetPositive(address _addr) public view returns (bool) {
        (uint256 _credits, uint256 _debits) = creditsAndDebits(_addr);
        return _credits > _debits;
    }

    //@dev Returns the total credits and debits for a given address
    function creditsAndDebits(address _addr) public view returns (uint256 _credits, uint256 _debits) {
        User memory _user = users[_addr];
        Airdrop memory _airdrop = airdrops[_addr];

        _credits = _airdrop.airdrops + _user.rolls + _user.deposits;
        _debits = _user.payouts;
    }

    //@dev Returns whether SH33P balance matches level
    function isBalanceCovered(address _addr, uint8 _level) public view returns (bool) {
        if (users[_addr].upline == address(0)) {
            return true;
        }
        return balanceLevel(_addr) >= _level;
    }

    //@dev Returns the level of the address
    function balanceLevel(address _addr) public view returns (uint8) {
        uint8 _level = 0;
        for (uint8 i = 0; i < ref_depth; i++) {
            if (sheepToken.balanceOf(_addr) < ref_balances[i]) break;
            _level += 1;
        }

        return _level;
    }

    //@dev Returns custody info of _addr
    function getCustody(address _addr) public view returns (address _beneficiary, uint256 _heartbeat_interval, address _manager) {
        return (custody[_addr].beneficiary, custody[_addr].heartbeat_interval, custody[_addr].manager);
    }

    //@dev Returns account activity timestamps
    function lastActivity(address _addr) external view returns (uint256 _heartbeat, uint256 _lapsed_heartbeat, uint256 _checkin, uint256 _lapsed_checkin) {
        _heartbeat = custody[_addr].last_heartbeat;
        _lapsed_heartbeat = block.timestamp.safeSub(_heartbeat);
        _checkin = custody[_addr].last_checkin;
        _lapsed_checkin = block.timestamp.safeSub(_checkin);
    }

    function claimsAvailable(address _addr) public view returns (uint256) {
        ( , , uint256 _to_payout, ) = payoutOf(_addr);
        return _to_payout;
    }

    function maxPayoutOf(address _addr, uint256 _amount) public view returns (uint256) {
        uint256 maxpayout = ratesController.getMaxPayout(_addr, _amount);
        return maxpayout;
    }

    function sustainabilityFee(address _addr, uint256 _pendingDiv) public view returns (uint256) {
        uint256 _bracket = users[_addr].payouts.add(_pendingDiv).div(deposit_bracket_size);
        _bracket = SafeMath.min(_bracket, deposit_bracket_max);
        return _bracket * 5;
    }

    //@dev calculates payout for a given address based off xSH33P balance
    function payoutRateOf(address _addr) public view returns (uint256) {
        uint256 rate = ratesController.payoutRateOf(_addr);
        return rate;
    }

    //@dev Calculate the current payout and maxpayout of a given address
    function payoutOf(address _addr) public view returns (uint256 payout, uint256 max_payout, uint256 net_payout, uint256 sustainability_fee) {
        
        //The max_payout is capped so that we can also cap available rewards daily
        max_payout = maxPayoutOf(_addr, users[_addr].deposits).min(max_payout_cap);

        uint256 share;

        if (users[_addr].payouts < max_payout) {
            //Using 1e18 we capture all significant digits when calculating available divs
            share = users[_addr].deposits.mul(payoutRateOf(_addr)).div(100e18).div(24 hours); //divide the profit by payout rate and seconds in the day

            payout = share * block.timestamp.safeSub(users[_addr].deposit_time);

            payout += users[_addr].accumulatedDiv;

            // payout remaining allowable divs if exceeds
            if (users[_addr].payouts + payout > max_payout) {
                payout = max_payout.safeSub(users[_addr].payouts);
            }

            uint256 _fee = sustainabilityFee(_addr, payout);

            sustainability_fee = (payout * _fee) / 100;

            net_payout = payout.safeSub(sustainability_fee);
        }
    }

    //@dev Get current user snapshot
    function userInfo(address _addr) external view returns (address upline, uint256 deposit_time, uint256 deposits, uint256 payouts, uint256 match_bonus, uint256 last_airdrop) {
        return (
            users[_addr].upline, 
            users[_addr].deposit_time, 
            users[_addr].deposits, 
            users[_addr].payouts, 
            users[_addr].match_bonus, 
            airdrops[_addr].last_airdrop
        );
    }

    //@dev Get user totals
    function userInfoTotals(address _addr) external view returns (uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure, uint256 airdrops_total, uint256 airdrops_received) {
        return (
            users[_addr].referrals, 
            users[_addr].deposits, 
            users[_addr].payouts, 
            users[_addr].total_structure, 
            airdrops[_addr].airdrops, 
            airdrops[_addr].airdrops_received
        );
    }

    /////// Airdrops ///////

    //@dev Send specified WOOL amount supplying an upline referral
    function airdrop(address _to, uint256 _amount) external {
        address _addr = msg.sender;

        (uint256 _realizedAmount, ) = woolToken.calculateTransferTaxes(_addr, _amount);

        //This can only fail if the balance is insufficient
        require(woolToken.transferFrom(_addr, address(woolshedVault), _amount), "CHECK_ALLOWANCE");

        //Make sure _to exists in the system; we increase
        require(users[_to].upline != address(0), "_to not found");

        (uint256 gross_payout, , , ) = payoutOf(_to);

        users[_to].accumulatedDiv = gross_payout;

        //Fund to deposits (not a transfer)
        users[_to].deposits += _realizedAmount;
        users[_to].deposit_time = block.timestamp;

        //User stats
        airdrops[_addr].airdrops += _realizedAmount;
        airdrops[_addr].last_airdrop = block.timestamp;
        airdrops[_to].airdrops_received += _realizedAmount;

        //Keep track of overall stats
        total_airdrops += _realizedAmount;
        total_txs += 1;

        //Let em know!
        emit onAirdrop(_addr, _to, _realizedAmount, block.timestamp);
        emit onDeposit(_to, _realizedAmount);
    }

    // Update deposit data - modular function because Solidity is shit...
    function updateDepositData(address _user, uint256 _accumulated, uint256 _deposits) private {
        users[_user].accumulatedDiv = _accumulated;
        users[_user].deposits += _deposits;
        users[_user].deposit_time = block.timestamp;
    }
}