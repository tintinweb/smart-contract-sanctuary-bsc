/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

contract ReentrancyGuard {
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

    constructor () {
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

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

contract BinanceSmartHustle is ReentrancyGuard{
    uint256 constant internal      MAXDEPO = 200 ether;
    uint256[] internal            DEPRANGE = [0.1 ether, 20.01 ether, 50.01 ether, 100 ether];
    uint256[] internal          INSTANTRW  = [300, 500, 1000, 1500]; // Deposit Bonus
    uint256[] internal           AFFILIATE = [600, 300, 100]; // 10%
    uint256 constant internal    MAXREWARD = 25000; // 250% (2.5x) of seed [includes commissions | earnings stops]
    uint256 constant internal DAILYPERCENT = 150; // 1.5% daily
    uint256[] internal           HOLDBONUS = [20, 300]; // +0.2% daily, max 3%
    uint256 constant internal     WTHDRFEE = 1500; // Withdrawal fees [sub 0.5% daily till gets to 0% after 30days]
    uint256 constant internal     ADMINFEE = 800;
    uint256 constant internal     DEVLPFEE = 700;
    uint256 constant internal       DIVDER = 10000;
    uint256 constant internal    TIME_STEP = 24 hours;
    uint256 constant internal    MAXC_STEP = 30;
 
    struct Players{
        uint256 _userId;
        uint256 _dateJoined;
        uint256 _totalStaked;
        uint256 _pendingWithdrawal;
        uint256 _totalWithdrawn;
        uint256 _totalBonus;
        uint256 _unPaidBonus;
        uint256 _lastDeposit; // next minimum must be +15%
        uint256 _dateWithdrawn;
        address _sponsor;
        Downlines[3] _downlines;
    }

    struct Downlines{
        address[] _referrals;
    }

    mapping(address => Players) public players;

    mapping(uint256 => address) public playersById;
    
    address internal admin;
    address internal devlp;

    uint256 public _totalStaked;
    uint256 public _totalWithdrawn;
    uint256 public _totalCommissions;
    uint256 public totalPlayers;

    event NewSignup (address _user, address _sponsor);
    event NewStake (address _user, uint256 _amount);
    event InstantRewardPaid(address _user, uint256 _amount, uint256 _instantReward);
    event DailyRewardPaid (address _to, uint256 _amount, uint8 _daysPassed);
    event CommissionEarned (address _from, address _to, uint256 _amount, uint8 _level);
    event AdminFeePaid (address _from, uint256 _amount);
    event DevlpFeePaid (address _from, uint256 _amount);

    constructor(address _admin){
        admin = _admin;
        devlp = msg.sender;
    }
    
    // get Instant Reward
    function getInstantRwrd(uint256 _amount) private view returns(uint256){
        uint256 _percent = INSTANTRW[0];
        for(uint8 i = 0; i < 4; i++){
            if(i < 3 && _amount >= DEPRANGE[i] && _amount < DEPRANGE[i + 1]){
                _percent = INSTANTRW[i];
            }
            else if(_amount >= DEPRANGE[i]){
                _percent = INSTANTRW[i];
            }
        }
        return _amount * _percent / DIVDER;
    }

    // distribute earnings [aff commissions + dev fees + instant reward]
    function dispatchRewards(uint256 _amount) private{
        uint256 _adminfee = _amount * ADMINFEE / DIVDER;
        uint256 _devlpfee = _amount * DEVLPFEE / DIVDER;
        address _sponsor = players[msg.sender]._sponsor;
        for(uint8 i = 0; i < 3; i++){
            if(_sponsor != address(0)){
                uint256 _comm = _amount * AFFILIATE[i] / DIVDER;
                players[_sponsor]._totalBonus += _comm;
                players[_sponsor]._unPaidBonus += _comm;
                _totalCommissions += _comm;
                // emit new Commission earned
                emit CommissionEarned(msg.sender, _sponsor, _comm, i + 1);
                _sponsor = players[_sponsor]._sponsor;
            }
        }
        payable(admin).transfer(_adminfee);
        payable(devlp).transfer(_devlpfee);
        // emit deveFee & Admin fee paid
        emit AdminFeePaid(msg.sender, _adminfee);
        emit DevlpFeePaid(msg.sender, _devlpfee);
    }
    
    // Insert deposit [unique plan] 
    function insertStake(uint256 _amount) private{
        uint256 _instantReward = getInstantRwrd(_amount);
        // if first stake
        if(players[msg.sender]._totalStaked == 0)
            players[msg.sender]._dateWithdrawn = block.timestamp;
        players[msg.sender]._totalStaked += _amount;
        players[msg.sender]._pendingWithdrawal += _amount * MAXREWARD / DIVDER - _instantReward;
        players[msg.sender]._totalWithdrawn += _instantReward;
        players[msg.sender]._lastDeposit = _amount;
        // Instant Reward 
        payable(msg.sender).transfer(_instantReward);
        _totalStaked += _amount;
        _totalWithdrawn += _instantReward;
        // emit instant Reward Earned
        emit InstantRewardPaid(msg.sender, _amount, _instantReward);
        // emit bnb staked
        emit NewStake(msg.sender, _amount);
    }

    // register user
    function registerUser(address _ref) private{
        if(msg.sender != _ref && _ref != address(0)){
            if(players[_ref]._totalStaked == 0){
                _ref = devlp;
            }  
        }
        else{
            _ref = devlp;
        } 
            
        totalPlayers++;
        players[msg.sender]._userId = totalPlayers;
        players[msg.sender]._dateJoined = block.timestamp;
        players[msg.sender]._sponsor = _ref;
        playersById[totalPlayers + 1] = msg.sender;
        // emit new user
        // assign upline
        address _upline = _ref;
        for(uint8 i = 0; i < 3; i++){
            if(_upline == address(0))
                break;
            players[_upline]._downlines[i]._referrals.push(msg.sender);
            _upline = players[_upline]._sponsor;
        }
        emit NewSignup(msg.sender, _ref);
    }

    // stake bnb
    function stakeBNB(address _ref) public payable{
        // don't allow contract to stake
        require(!isContract(msg.sender), 'NotAllowed');
        uint256 _amount = msg.value;
        require(_amount >= DEPRANGE[0] && _amount <= MAXDEPO, 'WrongAmount');
        // minimum stake must be +15% of last deposit
        uint256 _lastDeposit = players[msg.sender]._lastDeposit;
        if(_lastDeposit > 0){
            _lastDeposit += _lastDeposit * WTHDRFEE / DIVDER; // Minimum deposit should be +15% of last deposit
            require(_amount >= _lastDeposit, 'LastDpo+15%');
        }
        // register User if first deposit
        if(players[msg.sender]._sponsor == address(0)){
            registerUser(_ref);
        }
    
        // Insert new Deposit
        insertStake(_amount);
        // dispatch reward
        dispatchRewards(_amount);
    }

    // withdrawa bnb
    function withdrawBNB() public{
        require(!isContract(msg.sender), 'NotAllowed');
        uint256 daysPassed = _daysPassed(msg.sender);
        require (players[msg.sender]._totalStaked > 0, 'NotStaker');
        require (daysPassed > 0, '24hrsWindow');

        (uint256 _withdrawAmount, uint256 _withdrawFees) = getDvd(msg.sender);

        require(_withdrawAmount >= players[msg.sender]._lastDeposit / 10, 'NoEarnings'); // min withdrawal 10% of last deposit

        players[msg.sender]._unPaidBonus = 0;
        players[msg.sender]._pendingWithdrawal -= _withdrawAmount;
        players[msg.sender]._totalWithdrawn += _withdrawAmount;
        _totalWithdrawn += _withdrawAmount;

        _withdrawAmount -= _withdrawAmount * _withdrawFees / DIVDER;

        require(_withdrawAmount < address(this).balance, 'LowCBalance');
        players[msg.sender]._dateWithdrawn = block.timestamp;
        payable(msg.sender).transfer(_withdrawAmount);
        // Emit BNB Withdrawn
        emit DailyRewardPaid(msg.sender, _withdrawAmount, uint8(daysPassed));
    }

    function refCounts(address _user, uint8 _index) public view returns(uint256 _length, address[] memory _downlines){
        _length = players[_user]._downlines[_index]._referrals.length;
        _downlines = players[_user]._downlines[_index]._referrals;
    }

    function getDvd(address _user) public view returns(uint256, uint256){
        uint256 _amount = players[_user]._pendingWithdrawal;
        uint256 _withdrawFees = WTHDRFEE;
        uint256 _holdBonus = 0;
        uint256 _withdrawAmount;
        uint256 daysPassed = _daysPassed(_user);

        for(uint256 i = 1; i <= daysPassed; i++){
            _withdrawAmount += _amount * DAILYPERCENT / DIVDER;
            _amount -= _amount * DAILYPERCENT / DIVDER;
            if(daysPassed >= 2){
                _withdrawFees -= 50;
                _holdBonus += HOLDBONUS[0];
                if(_holdBonus >= HOLDBONUS[1]){
                    _holdBonus = HOLDBONUS[1];
                }
            }
        }

        _withdrawAmount += _withdrawAmount * _holdBonus / DIVDER;

        if(players[msg.sender]._unPaidBonus > 0){
            _withdrawAmount += players[_user]._unPaidBonus;
        }

        // max withdraw should be 2.5x
        uint256 _earnCap = players[_user]._totalStaked * MAXREWARD / DIVDER;

        uint256 _totalWithdraw = players[_user]._totalWithdrawn + _withdrawAmount;

        if(_totalWithdraw >= _earnCap){
            uint256 _diff = _totalWithdraw - _earnCap;
            _withdrawAmount -= _diff;
        }

        // _withdrawAmount -= _withdrawAmount * _withdrawFees / DIVDER;
        return(_withdrawAmount, _withdrawFees);
    }

    function _daysPassed(address _user) private view returns(uint256){
        uint256 _checkpoint = players[_user]._dateWithdrawn;
        uint256 daysPassed = (block.timestamp - _checkpoint) / TIME_STEP;
        return daysPassed >= MAXC_STEP ? MAXC_STEP : daysPassed;
    }

    // callBack Function
    receive() external payable{}

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}