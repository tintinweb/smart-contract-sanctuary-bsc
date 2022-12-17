/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;


contract BNBGardenElysium {
    uint256 public constant EGGS_TO_HIRE_1MINERS = 1080000;
    uint256 public constant REFERRAL = 80;
    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public constant TAX = 80;
    uint256 public constant MARKET_EGGS_PERCENT_MUL = 4;
    uint256 public constant MARKET_EGGS_PERCENT_DIV = 7;
    uint256 public constant ROI_DIVISOR = 1e6;
    uint256 public constant ROI_MAX_BONUS = 2000000;//200%
    uint256 public constant ROI_COMPOUND_BONUS = 1100000;//+10%
    uint256 public constant ROI_SELL_PENALTY = 500000;//-50%
    uint256 public roiBoost = 1;//global roi boost will stay at 1 unless users decide otherwise

    uint256 public constant MIN_INVEST_LIMIT = 1e17; /** min. 0.1 BNB  **/
    uint256 public constant WALLET_DEPOSIT_LIMIT = 2000 ether; /** max. 2000 BNB  **/

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 public marketEggs = 1;

    uint256 public constant COMPOUND_STEP = 24 hours; /** 24 Hours Compound Timer **/
	uint256 public constant CUTOFF_STEP = 48 hours; /** 48 Hours Rewards Accumulation Cut-Off **/
    uint256 internal constant INIT = 1671235200; // 2022-12-17 08:00:00
    uint256 internal constant NPV_unit = 1 gwei; // precision increase it too much and you drastically increase the chance of market_eggs overflow decrease it too much and you decrease the ROI. 10**9 is the perfect spot.

    /* addresses */
    address public owner;
    address payable public taxCollector;

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
        uint256 farmerCompoundCount;
        uint256 lastWithdrawTime;
        uint256 roiMultiplier;
    }

    mapping(address => User) public users;

    constructor(address payable payment_splitter) {
        owner = msg.sender;
        taxCollector = payment_splitter;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


    function contractStarted() internal view returns (bool){
        return block.timestamp >= INIT;
    }

    // Compound Function
    function rehireGardeners() external {
        User storage user = users[msg.sender];
        require(contractStarted(), "Contract not started yet.");
        require((block.timestamp - user.lastHatch) >= COMPOUND_STEP, "Tried to compound too early.");
        uint256 eggsUsed = getMyEggs();
        uint256 eggsForCompound = eggsUsed;

        uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
        user.userDeposit += eggsUsedValue;
        totalCompound += eggsUsedValue;
        user.farmerCompoundCount += 1;

        user.miners += eggsForCompound / EGGS_TO_HIRE_1MINERS;
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;
        user.roiMultiplier = min(ROI_MAX_BONUS, (user.roiMultiplier * ROI_COMPOUND_BONUS) / ROI_DIVISOR);

        uint256 additionalEggs = (eggsUsed * MARKET_EGGS_PERCENT_MUL) / MARKET_EGGS_PERCENT_DIV;
        marketEggs += min(additionalEggs, type(uint256).max - marketEggs);
    }

    // Sell Function
    function sellFlowers() external{
        require(contractStarted(), "Contract not started yet.");
        User storage user = users[msg.sender];
        require((block.timestamp - user.lastHatch) >= COMPOUND_STEP, "Tried to sell too early.");
        require(user.initialDeposit > 0, "You have not invested yet.");

        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);

        user.farmerCompoundCount = 0;
        user.lastWithdrawTime = block.timestamp;
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;
        user.roiMultiplier = (user.roiMultiplier * ROI_SELL_PENALTY) / ROI_DIVISOR;

        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue - payFees(eggValue);
        payable(msg.sender).transfer(eggsPayout);
        user.totalWithdrawn += eggsPayout;
        totalWithdrawn += eggsPayout;
    }


    function calculatePayFees(uint256 eggValue) internal pure returns(uint256) {
        uint256 tax = (eggValue * TAX) / PERCENTS_DIVIDER;
        return tax;
    }

    /** Buy with BNB **/
    function hireGardeners(address ref) external payable{
        require(contractStarted(), "Contract not started yet.");
        User storage user = users[msg.sender];
        uint256 amount = msg.value;
        require(amount >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit + amount <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        uint256 netAmount = amount - payFees(amount);
        totalStaked += netAmount;
        uint256 eggsBought = calculateEggBuy(netAmount, getFairBalance()-netAmount);
        // set multiplier to 1 on first buy
        if (user.initialDeposit == 0) {
            user.roiMultiplier = ROI_SELL_PENALTY;
            user.lastHatch = block.timestamp;
        }
        user.userDeposit += amount;
        user.initialDeposit += amount;
        user.claimedEggs += eggsBought;

        if (user.referrer == address(0)) {
            if (ref != msg.sender) {
                user.referrer = ref;
            }

            address upline1 = user.referrer;
            if (upline1 != address(0)) {
                users[upline1].referralsCount += 1;
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            if (upline != address(0)) {
                uint256 refRewards = (amount * REFERRAL) / PERCENTS_DIVIDER;
                payable(upline).transfer(refRewards);
                users[upline].referralEggRewards += refRewards;
                totalRefBonus += refRewards;
            }
        }
        uint256 eggsForCompound = getMyEggs();
        user.miners += eggsForCompound / EGGS_TO_HIRE_1MINERS;
        user.claimedEggs = 0;
        user.userDeposit += calculateEggSell(getEggsSinceLastHatch(msg.sender));
        user.lastHatch = block.timestamp;
        totalCompound += eggsForCompound;

        marketEggs += min(eggsForCompound, type(uint256).max - marketEggs); // this is for the very unlikely case of marketEggs getting close to 10**77

        totalDeposits += 1;
    }

    function payFees(uint256 eggValue) internal returns(uint256){
        uint256 tax = (eggValue * TAX) / PERCENTS_DIVIDER;
        taxCollector.transfer(tax);
        return tax;
    }

    function changeTaxColletor(address payable _taxCollector) public {
        require(msg.sender == owner, "Only admins can do that!");
        taxCollector = _taxCollector;
    }

    function getUserInfo(address _adr) external view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
     uint256 _claimedEggs, uint256 _lastHatch, address _referrer, uint256 _referrals, uint256 _totalWithdrawn, uint256 _referralEggRewards,
     uint256 _farmerCompoundCount, uint256 _lastWithdrawTime, uint256 _roiMultiplier) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedEggs = users[_adr].claimedEggs;
         _lastHatch = users[_adr].lastHatch;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralEggRewards = users[_adr].referralEggRewards;
         _farmerCompoundCount = users[_adr].farmerCompoundCount;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
         _roiMultiplier = users[_adr].roiMultiplier;
	}

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getFairBalance() public view returns(uint256) { // the new formula (in the beginning and on buys) is weak to force feed attacks. This function solves it.
        return totalStaked - min(totalStaked, totalWithdrawn);
    }

    function getAvailableEarnings(address _adr) external view returns(uint256) {
        uint256 userEggs = users[_adr].claimedEggs + getEggsSinceLastHatch(_adr);
        return calculateEggSell(userEggs);
    }

    function calculateTrade(uint256 a, uint256 b, uint256 m) internal pure returns(uint256){
        return (a * m) / (NPV_unit + b);
    }

    function calculateEggSell(uint256 eggs) public view returns(uint256){
        uint256 roiMultiplier = users[msg.sender].roiMultiplier * roiBoost;
        return calculateTrade((roiMultiplier * eggs) / ROI_DIVISOR, marketEggs, getBalance());
    }

    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) external view returns(uint256){
        return calculateEggBuy(eth-calculatePayFees(eth), getFairBalance());
    }

    /** How many miners and eggs per day user will receive based on BNB deposit **/
    function getEggsYield(uint256 amount) external view returns(uint256,uint256) {
        uint256 eggsAmount = calculateEggBuy(amount , getFairBalance());
        uint256 miners = eggsAmount / EGGS_TO_HIRE_1MINERS;
        uint256 day = 1 days;
        uint256 eggsPerDay = day * miners;
        uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay);
        return(miners, earningsPerDay);
    }

    function calculateEggSellForYield(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs, marketEggs, getBalance());
    }

    function getSiteInfo() external view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function getMyMiners() external view returns(uint256){
        return users[msg.sender].miners;
    }

    function getMyEggs() public view returns(uint256){ // in this implementation getMyEggs/user.ClaimedEggs are useless. But let's keep this in case in the future we want to implement an egg airdrop.
        return users[msg.sender].claimedEggs + getEggsSinceLastHatch(msg.sender);
    }

    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp - users[adr].lastHatch;
                            /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed * (users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function setROIBoost(uint256 value) public {
        require(msg.sender == owner, "Only admins can do that!");
        require(1 <= value && value <= 3, "New value is outside of limits");
        roiBoost = value;
    }

}