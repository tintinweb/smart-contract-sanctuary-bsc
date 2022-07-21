/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

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

interface IToken is IERC20 {
    function calculateTransferTaxes(address _from, uint256 _value) external returns (uint256 adjustedValue, uint256 taxAmount);
    function mintedSupply() external returns (uint256);
    function print(uint256 _amount) external;
}

interface IRatesController {
    function getRefBonus(uint8 level) external view returns (uint256);
    function getMaxPayOut(address _user, uint256 amount) external view returns (uint256);
    function payOutRateOf(address _addr) external view returns (uint256);
}

interface IWoolshedVault {
    function withdraw(uint256 tokenAmount) external;
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

    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

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

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
    uint256[49] private __gap;
}

contract ContractGuard {
    mapping(uint256 => mapping(address => bool)) private _status;

    modifier onlyOneBlock() {
        require(!_status[block.number][tx.origin], 'ContractGuard: PROHIBITED');
        _;

        _status[block.number][tx.origin] = true;
    }
}

contract WoolshedV1 is OwnableUpgradeable, ContractGuard {
    using SafeMath for uint256;

    struct User {

        //Referral Info
        address upline;
        uint256 referrals;
        uint256 total_structure;

        // Long-term Referral Accounting
        uint256 match_bonus;

        // Deposit Accounting
        uint256 deposits;
        uint256 deposit_time;

        // Payout and Roll Accounting
        uint256 payouts;
        uint256 rolls;

        // Round Robin tracking
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

    IToken public sheepToken;
    IToken public woolToken;

    IRatesController public ratesController;
    IWoolshedVault private taxVault;

    mapping(address => User) public users;
    mapping(address => Airdrop) public airdrops;
    mapping(address => Custody) public custody;
    
    uint256 public CompoundTax;
    uint256 public ExitTax;

    uint256 private ref_depth;

    uint256 private minimumAmount;

    uint256 public deposit_bracket_size; // @BB 5% increase whale tax per 10000 tokens... 10 below cuts it at 50% since 5 * 10
    uint256 private deposit_bracket_max; // sustainability fee is (bracket * 5)
    uint256 public max_payout_cap;       // 50k WOOL

    uint256[] public ref_balances;

    uint256 public total_airdrops;
    uint256 public total_users;
    uint256 public total_deposited;
    uint256 public total_withdraw;
    uint256 public total_txs;

    event NewDeposit(address indexed addr, uint256 amount);
    event Leaderboard(address indexed addr, uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure);
    event onPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
    event NewAirdrop(address indexed from, address indexed to, uint256 amount, uint256 timestamp);
    
    event ManagerUpdate(address indexed addr, address indexed manager, uint256 timestamp);
    event BeneficiaryUpdate(address indexed addr, address indexed beneficiary);
    
    event HeartBeat(address indexed addr, uint256 timestamp);
    event Checkin(address indexed addr, uint256 timestamp);

    /* ========== INITIALIZER ========== */
    function initialize() external initializer {
        __Ownable_init();
    }

    //@dev Default payable is empty since Faucet executes trades and recieves BNB
    fallback() external payable {
        //Do nothing, BNB will be sent to contract when selling tokens
    }

    receive() external payable {
        //Do nothing, BNB will be sent to contract when selling tokens
    }

    /****** Administrative Functions *******/

    // Update how many levels of referral are used
    function updateRefDepth(uint256 _newRefDepth) public onlyOwner {
        ref_depth = _newRefDepth;
    }

    // update the minimum amount of tokens to deposit
    function updateMinimumAmount(uint256 _newMinimumAmount) public onlyOwner {
        minimumAmount = _newMinimumAmount;
    }

    // update the compound tax
    function updateCompoundTax(uint256 _newCompoundTax) public onlyOwner {
        require(_newCompoundTax >= 0 && _newCompoundTax <= 20);
        CompoundTax = _newCompoundTax;
    }

    // update the exit tax
    function updateExitTax(uint256 _newExitTax) public onlyOwner {
        require(_newExitTax >= 0 && _newExitTax <= 20);
        ExitTax = _newExitTax;
    }

    // update the deposit bracket size
    function updateDepositBracketSize(uint256 _newBracketSize) public onlyOwner {
        deposit_bracket_size = _newBracketSize;
    }

    // update the max payout cap
    function updateMaxPayoutCap(uint256 _newPayoutCap) public onlyOwner {
        max_payout_cap = _newPayoutCap;
    }

    // Update hold requirements for referral bonuses (levels)
    function updateHoldRequirements(uint256[] memory _newRefBalances) public onlyOwner {
        require(_newRefBalances.length == ref_depth);
        delete ref_balances;
        for (uint8 i = 0; i < ref_depth; i++) {
            ref_balances.push(_newRefBalances[i]);
        }
    }

    /********** User Fuctions **************************************************/
    function checkin() public {
        address _addr = msg.sender;
        custody[_addr].last_checkin = block.timestamp;
        emit Checkin(_addr, custody[_addr].last_checkin);
    }

    //@dev Deposit specified WOOL amount supplying an upline referral
    function deposit(address _upline, uint256 _amount) external {
        address _addr = msg.sender;

        (uint256 realizedDeposit, uint256 taxAmount) = woolToken.calculateTransferTaxes(_addr, _amount);
        uint256 _total_amount = realizedDeposit;

        //Checkin for custody management.
        checkin();

        require(_amount >= minimumAmount, "Minimum deposit");

        _setUpline(_addr, _upline);

        uint256 taxedDivs;
        // Claim if divs are greater than 1% of the deposit
        if (claimsAvailable(_addr) > _amount / 100) {
            uint256 claimedDivs = _claim(_addr, true);
            taxedDivs = claimedDivs.mul(SafeMath.sub(100, CompoundTax)).div(100); // 5% tax on compounding
            _total_amount += taxedDivs;
        }

        //Transfer WOOL to the contract
        require(woolToken.transferFrom(_addr, address(taxVault), _amount), "WOOL token transfer failed");

        /*
        User deposits 10;
        1 goes for tax, 9 are realized deposit
        */
        _deposit(_addr, _total_amount);

        //5% direct commission; only if net positive
        address _up = users[_addr].upline;
        if (_up != address(0) && isNetPositive(_up) && isBalanceCovered(_up, 1)) {
            uint256 _bonus = _total_amount / 10;

            //Log historical and add to deposits
            users[_up].deposits += _bonus;

            emit NewDeposit(_up, _bonus);
            emit onPayout(_up, _addr, _bonus);
        }

        _refPayout(_up, taxAmount + taxedDivs);

        emit Leaderboard(_addr, users[_addr].referrals, users[_addr].deposits, users[_addr].payouts, users[_addr].total_structure);
        total_txs++;
    }

    //@dev Claim, transfer, withdraw from vault
    function claim() external {
        //Checkin for custody management.  If a user rolls for themselves they are active
        checkin();

        address _addr = msg.sender;

        _claim_out(_addr);
    }

    //@dev Claim and deposit;
    function roll() public {
        //Checkin for custody management.  If a user rolls for themselves they are active
        checkin();

        address _addr = msg.sender;

        _roll(_addr);
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

        require(users[_addr].upline != address(0) || _addr == owner(), "No upline");

        //stats
        users[_addr].deposits += _amount;
        users[_addr].deposit_time = block.timestamp;

        total_deposited += _amount;

        //events
        emit NewDeposit(_addr, _amount);
    }

    //Payout upline; Bonuses are from 5 - 30% on the 1% paid out daily; Referrals only help
    function _refPayout(address _addr, uint256 _amount) internal {

        address _up = users[_addr].upline;
        
        for (uint8 i = 0; i < ref_depth; i++) {
            //15 max depth

            uint256 _refBonus = ratesController.getRefBonus(i);

            uint256 _bonus = _amount * _refBonus / 100; // 10% of amount
            uint256 _share = _bonus / 4;                // 2.5% of amount
            uint256 _up_share = _bonus.sub(_share);     // 7.5% of amount
            bool _team_found = false;
            
            // If we have reached the top of the chain, the owner
            if(_up == address(0)){
                //The equivalent of looping through all available
                users[_addr].ref_claim_pos = ref_depth;
                break;
            }

            // We only match if the claim position is valid
            if(users[_addr].ref_claim_pos == i) {
                if (isBalanceCovered(_up, i + 1) && isNetPositive(_up)){

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
                        total_airdrops += _share;

                        //Events
                        emit NewDeposit(_addr, _share);
                        emit NewDeposit(_up, _up_share);

                        emit NewAirdrop(_up, _addr, _share, block.timestamp);
                        emit onPayout(_up, _addr, _up_share);
                    } else {

                        (uint256 gross_payout,,,) = payoutOf(_up);
                        users[_up].accumulatedDiv = gross_payout;
                        users[_up].deposits += _bonus;
                        users[_up].deposit_time = block.timestamp;

                        //match accounting
                        users[_up].match_bonus += _bonus;

                        //events
                        emit NewDeposit(_up, _bonus);
                        emit onPayout(_up, _addr, _bonus);
                    }

                    if (users[_up].upline == address(0)){
                        users[_addr].ref_claim_pos = ref_depth;
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
        if (users[_addr].ref_claim_pos >= ref_depth){
            users[_addr].ref_claim_pos = 0;
        }
    }

    //@dev General purpose heartbeat in the system used for custody/management planning
    function _heart(address _addr) internal {
        custody[_addr].last_heartbeat = block.timestamp;
        emit HeartBeat(_addr, custody[_addr].last_heartbeat);
    }

    //@dev Claim and deposit;
    function _roll(address _addr) internal {
        uint256 to_payout = _claim(_addr, false);

        uint256 payout_taxed = to_payout
            .mul(SafeMath.sub(100, CompoundTax))
            .div(100); // 5% tax on compounding

        //Recycle baby!
        _deposit(_addr, payout_taxed);

        //track rolls for net positive
        users[_addr].rolls += payout_taxed;

        emit Leaderboard(
            _addr,
            users[_addr].referrals,
            users[_addr].deposits,
            users[_addr].payouts,
            users[_addr].total_structure
        );
        total_txs++;
    }

    //@dev Claim, transfer, and topoff
    function _claim_out(address _addr) internal {
        uint256 to_payout = _claim(_addr, true);

        uint256 vaultBalance = woolToken.balanceOf(address(taxVault));
        if (vaultBalance < to_payout) {
            uint256 differenceToMint = to_payout.sub(vaultBalance);
            woolToken.print(differenceToMint);
        }

        taxVault.withdraw(to_payout);

        uint256 realizedPayout = to_payout.mul(SafeMath.sub(100, ExitTax)).div(100);
        require(woolToken.transfer(address(msg.sender), realizedPayout));

        emit Leaderboard(_addr, users[_addr].referrals, users[_addr].deposits, users[_addr].payouts, users[_addr].total_structure);
        total_txs++;
    }

    //@dev Claim current payouts
    function _claim(address _addr, bool isClaimedOut) internal returns (uint256) {
        (uint256 _gross_payout, uint256 _max_payout, uint256 _to_payout,) = payoutOf(_addr);
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
                uint256 compoundTaxedPayout = _to_payout
                    .mul(SafeMath.sub(100, CompoundTax))
                    .div(100); // 5% tax on compounding

                _refPayout(_addr, compoundTaxedPayout);
            }
        }

        require(_to_payout > 0, "Zero payout");

        //Update the payouts
        total_withdraw += _to_payout;

        //Update time!
        users[_addr].deposit_time = block.timestamp;
        users[_addr].accumulatedDiv = 0;

        emit Withdraw(_addr, _to_payout);

        if (users[_addr].payouts >= _max_payout) {
            emit LimitReached(_addr, users[_addr].payouts);
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

    //@dev Returns whether BR34P balance matches level
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
    function lastActivity(address _addr) public view returns (uint256 _heartbeat, uint256 _lapsed_heartbeat, uint256 _checkin, uint256 _lapsed_checkin) {
        _heartbeat = custody[_addr].last_heartbeat;
        _lapsed_heartbeat = block.timestamp.safeSub(_heartbeat);
        _checkin = custody[_addr].last_checkin;
        _lapsed_checkin = block.timestamp.safeSub(_checkin);
    }

    //@dev Returns amount of claims available for sender
    function claimsAvailable(address _addr) public view returns (uint256) {
        (,,uint256 _to_payout,) = payoutOf(_addr);
        return _to_payout;
    }

    //@dev Maxpayout of 3.65 of deposit
    function maxPayoutOf(address _addr, uint256 _amount) public view returns (uint256) {
        uint256 maxpayout = ratesController.getMaxPayOut(_addr, _amount);
        return maxpayout;
    }

    // Sustainability fee calculation
    function sustainabilityFeeV2(address _addr, uint256 _pendingDiv) public view returns (uint256) {
        uint256 _bracket = users[_addr].payouts.add(_pendingDiv).div(deposit_bracket_size);
        _bracket = SafeMath.min(_bracket, deposit_bracket_max);
        return _bracket * 5;
    }

    //@dev calculates payout for a given address based off SK balance
    //todo integrate this into the actual payout functions
    function payOutRateOf(address _addr) public view returns (uint256) {
        uint256 rate = ratesController.payOutRateOf(_addr);
        return rate;
    }

    //@dev Calculate the current payout and maxpayout of a given address
    function payoutOf(address _addr) public view returns (uint256 payout, uint256 max_payout, uint256 net_payout, uint256 sustainability_fee) {
        
        //The max_payout is capped so that we can also cap available rewards daily
        max_payout = maxPayoutOf(_addr, users[_addr].deposits).min(max_payout_cap);

        uint256 share;

        if (users[_addr].payouts < max_payout) {
            //Using 1e18 we capture all significant digits when calculating available divs
            share = users[_addr]
                .deposits
                .mul(payOutRateOf(_addr))
                .div(100e18)
                .div(24 hours); //divide the profit by payout rate and seconds in the day

            payout = share * block.timestamp.safeSub(users[_addr].deposit_time);

            payout += users[_addr].accumulatedDiv;

            // payout remaining allowable divs if exceeds
            if (users[_addr].payouts + payout > max_payout) {
                payout = max_payout.safeSub(users[_addr].payouts);
            }

            uint256 _fee = sustainabilityFeeV2(_addr, payout);

            sustainability_fee = (payout * _fee) / 100;

            net_payout = payout.safeSub(sustainability_fee);
        }
    }

    //@dev Get current user snapshot
    function userInfo(address _addr) external view returns (
            address upline,
            uint256 deposit_time,
            uint256 deposits,
            uint256 payouts,
            uint256 match_bonus,
            uint256 last_airdrop
        ) {
        return (users[_addr].upline, users[_addr].deposit_time, users[_addr].deposits, users[_addr].payouts, users[_addr].match_bonus, airdrops[_addr].last_airdrop);
    }

    //@dev Get user totals
    function userInfoTotals(address _addr) external view returns (
            uint256 referrals,
            uint256 total_deposits,
            uint256 total_payouts,
            uint256 total_structure,
            uint256 airdrops_total,
            uint256 airdrops_received
        ) {
        return (
            users[_addr].referrals,
            users[_addr].deposits,
            users[_addr].payouts,
            users[_addr].total_structure,
            airdrops[_addr].airdrops,
            airdrops[_addr].airdrops_received
        );
    }

    //@dev Get contract snapshot
    function contractInfo() external view returns (uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw, uint256 _total_txs, uint256 _total_airdrops) {
        return (total_users, total_deposited, total_withdraw, total_txs, total_airdrops);
    }

    /////// Airdrops ///////

    //@dev Send specified WOOL amount supplying an upline referral
    function airdrop(address _to, uint256 _amount) external {
        address _addr = msg.sender;

        (uint256 _realizedAmount, ) = woolToken.calculateTransferTaxes(_addr, _amount);
        
        //This can only fail if the balance is insufficient
        require(woolToken.transferFrom(_addr, address(taxVault), _amount), "WOOL to contract transfer failed; check balance and allowance, airdrop");

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
        emit NewAirdrop(_addr, _to, _realizedAmount, block.timestamp);
        emit NewDeposit(_to, _realizedAmount);
    }
}