/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/CinemaPop.sol

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;




contract SPACBNBMINER {
    using SafeMath for uint256;

    /** base parameters **/
    uint256 public EGGS_TO_HIRE_1MINERS = 1440000;
    uint256 public REFERRAL = 130;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public OWNERTAX = 25;
    uint256 public DEVTAX = 5;
    uint256 public LIQTAX = 20;
    uint256 public MARKET_EGGS_DIVISOR = 2;

    uint256 public MIN_INVEST_LIMIT = 1 * 1e17; /** 0.1 BNB  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 25 * 1e18; /** 25 BNB  **/

	uint256 public COMPOUND_BONUS = 20;
	uint256 public COMPOUND_BONUS_MAX_TIMES = 10;
    uint256 public COMPOUND_STEP = 12 * 60 * 60;

    uint256 public WITHDRAWAL_TAX = 800;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 10;

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 public marketEggs;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;
    bool public blacklistActive = true;
    mapping(address => bool) public Blacklisted;

	uint256 public CUTOFF_STEP = 48 * 60 * 60;
	uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60;

    /* addresses */
    address public owner;
    address payable public dev;
    address payable public liq;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedEggs;
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

    constructor(address payable _dev, address payable _liq) {
		require(!isContract(_dev) && !isContract(_liq));
        owner = msg.sender;
        dev = _dev;
        liq = _liq;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function setblacklistActive(bool isActive) public{
        require(msg.sender == owner, "Admin use only.");
        blacklistActive = isActive;
    }

    function blackListWallet(address Wallet, bool isBlacklisted) public{
        require(msg.sender == owner, "Admin use only.");
        Blacklisted[Wallet] = isBlacklisted;
    }

    function blackMultipleWallets(address[] calldata Wallet, bool isBlacklisted) public{
        require(msg.sender == owner, "Admin use only.");
        for(uint256 i = 0; i < Wallet.length; i++) {
            Blacklisted[Wallet[i]] = isBlacklisted;
        }
    }

    function checkIfBlacklisted(address Wallet) public view returns(bool blacklisted){
        require(msg.sender == owner, "Admin use only.");
        blacklisted = Blacklisted[Wallet];
    }

    function startFarm(address addr) public payable {
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketEggs == 0);
    			contractStarted = true;
                marketEggs = 144000000000;
                hireFarmers(addr);
    		} else revert("Contract not yet started.");
    	}
    }

    //fund contract with BNB before launch.
    function fundContract() external payable {}

    function hireMoreFarmers(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet Started.");

        uint256 eggsUsed = getMyEggs();
        uint256 eggsForCompound = eggsUsed;

        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, eggsForCompound);
            eggsForCompound = eggsForCompound.add(dailyCompoundBonus);
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            totalCompound = totalCompound.add(eggsUsedValue);
        } 

        if(block.timestamp.sub(user.lastHatch) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
            //add compoundCount for monitoring purposes.
            user.farmerCompoundCount = user.farmerCompoundCount.add(1);
        }
        
        user.miners = user.miners.add(eggsForCompound.div(EGGS_TO_HIRE_1MINERS));
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

        marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));
    }

    function sellCrops() public{
        require(contractStarted, "Contract not yet Started.");

        if (blacklistActive) {
            require(!Blacklisted[msg.sender], "Address is blacklisted.");
        }

        User storage user = users[msg.sender];
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);
        
        //if user compound < to mandatory compound days
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            //daily compound bonus count will not reset and eggValue will be deducted with 60% feedback tax.
            eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
            //set daily compound bonus count to 0 and eggValue will remain without deductions
             user.dailyCompoundBonus = 0;   
             user.farmerCompoundCount = 0;  
        }
        
        user.lastWithdrawTime = block.timestamp;
        user.claimedEggs = 0;  
        user.lastHatch = block.timestamp;
        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR));
        
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue));
        payable(address(msg.sender)).transfer(eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);
    }
     
    /** transfer amount of BNB **/
    function hireFarmers(address ref) public payable{
        require(contractStarted, "Contract not yet Started.");
        User storage user = users[msg.sender];
        require(msg.value >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(msg.value) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        uint256 eggsBought = calculateEggBuy(msg.value, address(this).balance.sub(msg.value));
        user.userDeposit = user.userDeposit.add(msg.value);
        user.initialDeposit = user.initialDeposit.add(msg.value);
        user.claimedEggs = user.claimedEggs.add(eggsBought);

        if (user.referrer == address(0)) {
            if (ref != msg.sender && ref != address(0)) {
                user.referrer = ref;
            } else {
                user.referrer = owner;
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
                payable(address(upline)).transfer(refRewards);
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        uint256 eggsPayout = payFees(msg.value);
        totalStaked = totalStaked.add(msg.value.sub(eggsPayout));
        totalDeposits = totalDeposits.add(1);
        hireMoreFarmers(false);
    }

    function payFees(uint256 eggValue) internal returns(uint256){
        uint256 ownerTax = eggValue.mul(OWNERTAX).div(PERCENTS_DIVIDER);
        uint256 devTax = eggValue.mul(DEVTAX).div(PERCENTS_DIVIDER);
        uint256 liqTax = eggValue.mul(LIQTAX).div(PERCENTS_DIVIDER);
        payable(address(owner)).transfer(ownerTax);
        dev.transfer(devTax);
        liq.transfer(liqTax);
        return ownerTax.add(devTax.add(liqTax));
    }

    function getDailyCompoundBonus(address _adr, uint256 amount) public view returns(uint256){
        if(users[_adr].dailyCompoundBonus == 0) {
            return 0;
        } else {
            uint256 totalBonus = users[_adr].dailyCompoundBonus.mul(COMPOUND_BONUS); 
            uint256 result = amount.mul(totalBonus).div(PERCENTS_DIVIDER);
            return result;
        }
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

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getAvailableEarnings(address _adr) public view returns(uint256) {
        uint256 userEggs = users[_adr].claimedEggs.add(getEggsSinceLastHatch(_adr));
        return calculateEggSell(userEggs);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(
                SafeMath.mul(PSN, bs), 
                    SafeMath.add(PSNH, 
                        SafeMath.div(
                            SafeMath.add(
                                SafeMath.mul(PSN, rs), 
                                    SafeMath.mul(PSNH, rt)), 
                                        rt)));
    }

    function calculateEggSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs, marketEggs, getBalance());
    }

    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth, getBalance());
    }

    /** How many miners and eggs per day user will recieve based on BNB deposit **/
    function getEggsYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 eggsAmount = calculateEggBuy(amount , getBalance().add(amount).sub(amount));
        uint256 miners = eggsAmount.div(EGGS_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 eggsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay, amount);
        return(miners, earningsPerDay);
    }

    function calculateEggSellForYield(uint256 eggs,uint256 amount) public view returns(uint256){
        return calculateTrade(eggs,marketEggs, getBalance().add(amount));
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function getMyMiners() public view returns(uint256){
        return users[msg.sender].miners;
    }

    function getMyEggs() public view returns(uint256){
        return users[msg.sender].claimedEggs.add(getEggsSinceLastHatch(msg.sender));
    }

    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
                            /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    /** percentage setters **/

    // 2592000 - 3%, 2160000 - 4%, 1728000 - 5%, 1440000 - 6%, 1200000 - 7%
    // 1080000 - 8%, 959000 - 9%, 864000 - 10%, 720000 - 12%
    
    function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 720000); /** min 3% max 12%**/
        EGGS_TO_HIRE_1MINERS = value;
    }

    function PRC_OWNERTAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        OWNERTAX = value;
    }

    function PRC_DEVTAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        DEVTAX = value;
    }

    function PRC_LIQTAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        LIQTAX = value;
    }

    function PRC_REFERRAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100);
        REFERRAL = value;
    }

    function PRC_MARKET_EGGS_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50);
        MARKET_EGGS_DIVISOR = value;
    }

    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 900);
        WITHDRAWAL_TAX = value;
    }

    function BONUS_DAILY_COMPOUND(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 900);
        COMPOUND_BONUS = value;
    }

    function BONUS_DAILY_COMPOUND_BONUS_MAX_TIMES(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 30);
        COMPOUND_BONUS_MAX_TIMES = value;
    }

    function BONUS_COMPOUND_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 24);
        COMPOUND_STEP = value * 60 * 60;
    }

    function SET_INVEST_MIN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MIN_INVEST_LIMIT = value * 1e17;
    }

    function SET_CUTOFF_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        CUTOFF_STEP = value * 60 * 60;
    }

    function SET_WITHDRAW_COOLDOWN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value <= 24);
        WITHDRAW_COOLDOWN = value * 60 * 60;
    }

    function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 10);
        WALLET_DEPOSIT_LIMIT = value * 1 ether;
    }
    
    function SET_COMPOUND_FOR_NO_TAX_WITHDRAWAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 12);
        COMPOUND_FOR_NO_TAX_WITHDRAWAL = value;
    }
}