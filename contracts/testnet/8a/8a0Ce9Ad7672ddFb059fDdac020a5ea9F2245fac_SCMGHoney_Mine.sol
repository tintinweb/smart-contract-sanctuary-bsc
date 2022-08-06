/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

pragma solidity 0.8.9;
// SPDX-License-Identifier: MIT

//Token Interface
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract SCMGHoney_Mine {
    IERC20 public minedToken; 
    /** Base parameters **/
    uint256 public HONEY_FOR_1WORKERBEE = 1080000;
    uint256 public REFERRAL = 50;                   // 50 = 5% 
    uint256 public QUEENBEE = 10;
    uint256 public TEAM = 5;
    uint256 public MARKETING = 30;
    uint256 public MARKET_HONEY_PERCENT_MUL = 4;
    uint256 public MARKET_HONEY_PERCENT_DIV = 5;
    uint256 public ROI_BOOST = 3;
    uint256 public PERCENTS_DIVIDER = 1000;

    uint256 public MIN_INVEST_LIMIT = 10 ether; /** min. 10 token  **/  
    uint256 public WALLET_DEPOSIT_LIMIT = 50000000 ether; /** max. 50000000 tokens  **/

	uint256 public COMPOUND_BONUS_MAX_TIMES = 12; /** 12 Times Compound MAX bonus // 2 compounds Max per day. **/

    uint256 public WITHDRAWAL_TAX = 750; // 75% tax for For Early Withdrawals - Penalties
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 4; // Must compound at least 2 times for no tax Withdrawal.

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 public marketHoney;
    bool public contractStarted;

    uint256 public COMPOUND_STEP = 12 * 60 * 60 ; /** 12 Hours Compound Timer **/
	uint256 public CUTOFF_STEP = 7 days; /** 7 day Rewards Accumulation Cut-Off **/

    uint256 internal NPV_unit = 1 gwei;

    /* addresses */
    address public owner;
    address public ceo;    //ceo
    address public partner;    //partner
    address public team1;
    address public team2;
    address public mkt;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedHoney;
        uint256 lastHarvest;
        address referrer;
        uint256 referralsCount;
        uint256 referralHoneyRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 workerCompoundCount;
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    constructor(address _ceo, address _partner, address _team1, address _team2, address _mkt, address _token_address) {
		require(!isContract(_ceo) && !isContract(_partner) && !isContract(_team1) && !isContract(_team2));
        owner = msg.sender;
        ceo = _ceo;
        partner = _partner;
        team1 = _team1;
        team2 = _team2;
        mkt = _mkt; 
        minedToken = IERC20(_token_address);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function startFarm() external {
        if (!contractStarted) {
    		if (msg.sender == owner) {
    			contractStarted = true;
                marketHoney = 1000 gwei;
    		} else revert("Not authorized.");
    	}
    }

    function updateMinedToken(address _minedToken) external {
        
        if (msg.sender == owner) {
             minedToken = IERC20(_minedToken);
             } else revert("Not authorized.");
    

    }    

    // Compound Function - Re-Hire Workers
    function hireMoreFarmers() external {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not started yet.");
        require((block.timestamp - user.lastHarvest) >= COMPOUND_STEP, "Tried to compound too early.");
        uint256 honeyUsed = getMyHoney();
        uint256 honeyForCompound = honeyUsed;

        uint256 honeyUsedValue = calculateHoneyell(honeyForCompound);
        user.userDeposit += honeyUsedValue;
        totalCompound += honeyUsedValue;
        if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
            user.dailyCompoundBonus += 1;
        }
        user.workerCompoundCount += 1;
              
        user.miners += honeyForCompound / HONEY_FOR_1WORKERBEE;
        user.claimedHoney = 0;
        user.lastHarvest = block.timestamp;

        marketHoney += (honeyUsed * MARKET_HONEY_PERCENT_MUL) / MARKET_HONEY_PERCENT_DIV;
    }

    // Sell Wine Function
    function sellCrops() external{
        require(contractStarted, "Contract not started yet.");

        User storage user = users[msg.sender];
        require(user.initialDeposit > 0, "You have not invested yet.");
        uint256 hasHoney = getMyHoney();
        uint256 honeyValue = calculateHoneyell(hasHoney);
        

        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            //daily compound bonus count will not reset and honeyValue will be deducted with feedback tax.
            honeyValue -= (honeyValue * WITHDRAWAL_TAX) / PERCENTS_DIVIDER;
        }else{
            //set daily compound bonus count to 0 and honeyValue will remain without deductions
             user.dailyCompoundBonus = 0;   
             user.workerCompoundCount = 0;  
        }
        
        user.lastWithdrawTime = block.timestamp;
        user.claimedHoney = 0;  
        user.lastHarvest = block.timestamp;
        
        if(getBalance() < honeyValue) {
            honeyValue = getBalance();
        }

        uint256 honeyPayout = honeyValue - payFees(honeyValue);
        minedToken.transfer(msg.sender,honeyPayout);
        user.totalWithdrawn += honeyPayout;
        totalWithdrawn += honeyPayout;
    }


    function calculatePayFees(uint256 honeyValue) internal view returns(uint256){
        uint256 devtax = (honeyValue * QUEENBEE) / PERCENTS_DIVIDER;
        uint256 mktng = (honeyValue * MARKETING) / PERCENTS_DIVIDER;
        uint256 teamtax = (honeyValue * TEAM) / PERCENTS_DIVIDER;
        return 2*devtax + 2*teamtax + mktng;
    }

    /** Buy Winemakers with BUSD **/
    function hireFarmers(address ref, uint256 amount) external{
        require(contractStarted, "Contract not started yet.");
        User storage user = users[msg.sender];
        require(amount >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit + amount <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        minedToken.transferFrom(address(msg.sender), address(this), amount);
        uint256 net_amount = amount - payFees(amount);
        uint256 honeyBought = calculateHoneyBuy(net_amount, getBalance()-net_amount);
        user.userDeposit += amount;
        user.initialDeposit += amount;
        user.claimedHoney += honeyBought;

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
                minedToken.transfer(upline,refRewards);
                users[upline].referralHoneyRewards += refRewards;
                totalRefBonus += refRewards;
            }
        }
        uint256 honeyForCompound = getMyHoney();

        user.miners += honeyForCompound / HONEY_FOR_1WORKERBEE;
        user.claimedHoney = 0;
        user.lastHarvest = block.timestamp;

        marketHoney += honeyForCompound;

        totalStaked += net_amount;
        totalDeposits += 1;
    }

    function payFees(uint256 honeyValue) internal returns(uint256){
        uint256 devtax = (honeyValue * QUEENBEE) / PERCENTS_DIVIDER;
        uint256 mktng = (honeyValue * MARKETING) / PERCENTS_DIVIDER;
        uint256 teamtax = (honeyValue * TEAM) / PERCENTS_DIVIDER;
        minedToken.transfer(ceo,devtax);
        minedToken.transfer(partner,devtax);
        minedToken.transfer(mkt,mktng);
        minedToken.transfer(team1,teamtax);
        minedToken.transfer(team2,teamtax);
        return 2*devtax + 2*teamtax + mktng;
    }

    function getUserInfo(address _adr) external view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
     uint256 _claimedHoney, uint256 _lastHarvest, address _referrer, uint256 _referrals,
	 uint256 _totalWithdrawn, uint256 _referralHoneyRewards, uint256 _dailyCompoundBonus, uint256 _workerCompoundCount, uint256 _lastWithdrawTime) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedHoney = users[_adr].claimedHoney;
         _lastHarvest = users[_adr].lastHarvest;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralHoneyRewards = users[_adr].referralHoneyRewards;
         _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
         _workerCompoundCount = users[_adr].workerCompoundCount;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
	}

    function getBalance() public view returns(uint256){
        return minedToken.balanceOf(address(this));
    }


    function getAvailableEarnings(address _adr) external view returns(uint256) {
        uint256 userHoney = users[_adr].claimedHoney + getHoneySinceLastHarvest(_adr);
        return calculateHoneyell(userHoney);
    }

    function calculateTrade(uint256 a, uint256 b, uint256 m) internal view returns(uint256){
        return (a * m) / (NPV_unit + b);
    }

    function calculateHoneyell(uint256 honey) public view returns(uint256){
        return calculateTrade(ROI_BOOST * honey, marketHoney, getBalance());
    }

    function calculateHoneyBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketHoney);
    }

    function calculateHoneyBuySimple(uint256 eth) external view returns(uint256){
        return calculateHoneyBuy(eth-calculatePayFees(eth), getBalance());
    }

    /** How many miners and honey per day user will recieve based on BNB deposit **/
    function getHoneyYield(uint256 amount) external view returns(uint256,uint256) {
        uint256 honeyAmount = calculateHoneyBuy(amount , getBalance());
        uint256 miners = honeyAmount / HONEY_FOR_1WORKERBEE;
        uint256 day = 1 days;
        uint256 honeyPerDay = day * miners;
        uint256 earningsPerDay = calculateHoneyellForYield(honeyPerDay);
        return(miners, earningsPerDay);
    }

    function calculateHoneyellForYield(uint256 honey) public view returns(uint256){ 
        return calculateTrade(ROI_BOOST * honey, marketHoney, getBalance());
    }

    function getSiteInfo() external view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function getMyMiners() external view returns(uint256){
        return users[msg.sender].miners;
    }

    function getMyHoney() public view returns(uint256){
        return users[msg.sender].claimedHoney + getHoneySinceLastHarvest(msg.sender);
    }

    function getHoneySinceLastHarvest(address adr) public view returns(uint256){
        uint256 secondsSinceLastHarvest = block.timestamp - users[adr].lastHarvest;
                            /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastHarvest, CUTOFF_STEP);
        uint256 secondsPassed = min(HONEY_FOR_1WORKERBEE, cutoffTime);
        return secondsPassed * (users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

}