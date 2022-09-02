/** 
    The Network Society Project, a suistainable way of earning.

    Variable Daily Yield starts at 1% up to 3%:
    - Compound action every 24 hours will give 0.1% added to their current yield up to 3%
        - Compound is not mandatory, but compounding will increase the investors daily yield.
        - There is a 2% tax for each Compound. The 2% will stay in the contract.
    - Every withdraw/sell action, will have a 0.5% deduction to the current user yield that will start at 1.6%.
        - users current daily yield is between 1% to 1.5%, when the user sell/withdraw the daily yield will go back to 1%
        - users current daily yield is 1.6% and above, it will less 0.5%(i.e user yield = 3%, after sell/withdraw user yield will be 2.5%)
    - User can only compound 5x max of his real invested amount.
    - User can earn 365% of his including real invested amount. (deposited = 100 ether, max payout = 365 ether)
    
    - Variable Withdraw Tax:
        Users will have less withdraw tax depending on their consecutive compound count/days
        Default Sustainability Tax : 10% 
        Compount Count is less than 10 Days: 10%
        Compound Count is 11 to 20 Days: 8%
        Compound Count is 21 to 30 Days: 6%
        Compound Count is 31 to 40 Days: 4%
        Compound Count is above 40 Days: 2%
    * Every withdraw the compound count will reset.  

    4% Referral Bonus:
    - 2% goes to the Referrer and be added to the users total deposit.
    - 2% goes to the Referee and be added to the users total deposit.

    Max reward accumulation of 48 Hours.
    - If no action is done within 48 hours, reward accumulation will stop and will only reset if a deposit, withdraw or compound is done.
    
    Daily Top Investors and Daily Top Referrer:
    - 10% of each deposit will be put into the rewards pool for each event, which is capped to 2000 ether per round.
    - event runs every 24 hours.
    - 5 winners for reach pool will share the pool 1st place 30%, 2nd place 25%, 3rd place 20%, 4th place 15%, 5th place 10%. 
    - Reward goes directly to user as direct deposit instead of making it withdrawable/claimable.
      I.E Rewards Distribution is max pool size is reached:
      1st place: 600 ether
      2nd place: 500 ether
      3rd place: 400 ether
      4th place: 300 ether
      5th place: 200 ether

    Last Deposit Rewards:
    - 10% of each deposit will be put into the rewards pool for each event, which is capped to 2000 ether per round.
    - If there is no new deposit after the last deposit after 2 hours, the last deposit address will win the jackpot which is capped to 2000 ether per round.
    
    Auto Compound Feature:
    - Users will deposit the current average gas fee per compound.
    - Users will have an option to disable it during the cycle and allow to withdraw the deposited BNB.
    - Enabled auto-compound should finish the cycle, users will not be able to add days in between, 
      will need to disable the function and withdraw and reset auto compound.

    Network and Individual Airdrop.
    - Users can airdrop invested addresses which will go directly as users direct deposit instead of making it withdrawable/claimable.
    - Network Leaders can airdrop x amount of token to their members. amount(less airdrop tax) * no. of network members.  
**/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IToken {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;

    uint256 c = a * b;
    assert(c / a == b);
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract TheNetworkSociety {
    using SafeMath for uint256;
    using SafeMath for uint8;
    
    IToken public token;

    address public owner;

    struct User {
        address sponsor; //network sponsor
        uint256 networkInvites; // invite count
        uint256 totalDepositAmount; //invested + compounded
        uint256 totalDepositPayouts; //payouts
        uint256 totalDirectDeposits; //invested event payouts + airdrops are considered real deposits
        uint256 incomeCompounded; //compounded
        uint256 totalNetworkInvitesDeposit; //total invested by invites
        uint256 checkpoint; // user action checkpoint
        uint256 userYieldPercentage; //user personal yield.
        uint256 userCompoundCount; //user compound count record
    }

    //bonus record library
    struct UserBonusStatistics {
        uint256 directBonus; 
        uint256 topDepositBonus; 
        uint256 topReferrerBonus;
    }

    //airdrop record library
    struct Airdrop {
        uint256 airdropSent;
        uint256 airdropReceived;
        uint256 lastAirdropReceivedTime;
        uint256 lastAirdropSentTime;
    }

    //Networks record library
    struct Network {
        address[] members;
        address owner;
        uint256 id;
        uint256 createTime;
        bool isReferralNetwork;
    }

    //Networks record info library
    struct NetworkInfo {
        uint256 id;
        bool exists;
    }
    
    //mappings
    mapping(uint256 => Network) public networks;
    mapping(address => User) public users;
    mapping(address => UserBonusStatistics) public userBonusStatistics;
    mapping(address => Airdrop) public airdrops;
    mapping(address => NetworkInfo[]) public userNetworks;
    mapping(address => NetworkInfo) public userNetworkInfo;
    mapping(uint8 => address) public topDepositPool;
    mapping(uint8 => address) public topReferrerPool;
    mapping(address => uint256) public userfirstInvestmentTime;
    mapping(uint256 => mapping(address => uint256)) public userTopReferrerList;
    mapping(uint256 => mapping(address => uint256)) public userTopDepositList;
    
    //variable 
    uint256 private marketTax = 10;
    uint256 private projectTax = 45;
    uint256 private airdropTax = 100; //10%
    uint256 private compoundTax = 20; //2% stays in the contract
    uint256 private developmentTax = 45;
    uint256 private sustainabilityTax = 100; //10%

    uint256 private timeForYieldBonus = 86400; //1 day
    uint256 private timeStep = 86400;  //1 day

    uint256 private userMaxPayout = 3650; //365%
    uint256 private maxAccumulationTime = 172800; //2 days
    uint256 private maxCompoundMultiplier = 5; //5x of real investment.

    uint256 private referralBonus = 20; //2% for referrer and referee total of 4% per deposit.
    uint256 private maxYieldPercent = 30; //3%
    uint256 private baseYieldPercent = 10; //1%
    uint256 private yieldDecreasePerWithdraw = 5; // 0.5% yield decrease per withdraw

    uint256 private depositMinimum = 50 * (10 ** 18);  
    uint256 private depositMaximum = 10000 * (10 ** 18); 
    uint256 private airdropMinimum = 5 * (10 ** 18);
    uint256 private maxRewardsPool = 2000 * (10 ** 18);
    
    uint256 private percentageDivider = 1000;

    //last deposit 
    bool private lasDepositJackpotEnabled;
    address public potentialLastDepositWinner;
    uint256 public lastDepositStartTime;
    uint256 public lastDepositCurrentPot;
    uint256 public currentLastBuyRound = 1;
    uint256 private lastDepositTimeStep = 7200; //2 hours

    //top referrer
    bool private topReferrerEnabled;
    uint256 public topReferrerLastDrawAction;
    uint256 public topReferrerPoolCycle;
    uint256 public topReferrerPoolBalance;
    uint256 private topReferrerTimeStep = 86400; //1 day

    //top deposit
    bool private topDepositEnabled;
    uint256 public topDepositLastDrawAction;
    uint256 public topDepositPoolCycle;
    uint256 public topDepositPoolBalance;
    uint256 private topDepositTimeStep = 86400; //1 day

    //project statistics
    uint256 private totalUsers;
    uint256 private totalDeposited;
    uint256 private totalWithdrawn;
    uint256 private totalCompounded;
    uint256 private totalAirdrops;
    uint256 private totalNetworksCreated;

    //arrays
    uint8[] private daysCount = [10, 20, 30, 40];
    uint8[] private varTaxes = [20, 40, 60, 80, 100];
    uint8[] private topDepositBonuses = [30, 25, 20, 15, 10];
    uint8[] private topReferrerPoolBonuses = [30, 25, 20, 15, 10];

    //contract enablers
    bool private locked;
    bool private airdropEnabled;
    bool private autoCompoundEnabled;
    bool private contractInitialized;
    
    //addresses
    address private autoCompoundExecutor;
    address private development;
    address private project;
    address private marketing;

    //events
    event Sponsor(address indexed addr, address indexed sponsor);
    event NewDeposit(address indexed addr, uint256 amount);
    event DirectPayout(address indexed addr, address indexed from, uint256 amount);
    event TopDepositPayout(address indexed addr, uint256 amount);
    event TopReferrerPayout(address indexed addr, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event MaxPayoutReached(address indexed addr, uint256 amount);
    event MaxPayoutCapReached(address indexed addr, uint256 amount);
	event CompoundedDeposit(address indexed user, uint256 amount);
    event NewAirdrop(address indexed from, address indexed to, uint256 amount, uint256 timestamp);
    event AutoCompoundEvent(address indexed addr, uint256 timestamp);
    event LastBuyEvent(uint256 indexed round, address indexed winner, uint256 amountRewards, uint256 drawTime);

    constructor(address dvt, address prj, address market) {
        require(!isContract(dvt) &&!isContract(prj) && !isContract(market));		
        owner = msg.sender;
        development = dvt;
        project = prj;
        marketing = market;
        token = IToken(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    }

    function initializeContract() external onlyOwner {
        require(!contractInitialized);
        contractInitialized = true;
        topDepositLastDrawAction = block.timestamp;
        topReferrerLastDrawAction = block.timestamp;    
    }

    //for testing only remove in mainnet
    function updateTimeForTesting(uint256 eventTime, uint256 yieldTime, uint256 dayStep) external onlyOwner {
        topDepositTimeStep = eventTime;
        topReferrerTimeStep = eventTime;
        timeForYieldBonus = yieldTime;
        timeStep = dayStep;     
    }

    //for testing only remove in mainnet
    function claimTestFunds() public onlyOwner {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier initialized {
        require(contractInitialized, "Contract not yet Started.");
        _;
    }

    modifier nonReentrant {
        require(!locked, "No re-entrancy.");
        locked = true;
        _;
        locked = false;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function invest(uint256 amount) external onlyOwner {
        _invest(msg.sender, amount);
    }

    function invest(address _sponsor, uint256 amount) external initialized {
		setSponsor(msg.sender, _sponsor);
        _invest(msg.sender, amount);
    }

    //invest
    function _invest(address _addr, uint256 _amount) private nonReentrant {
        require(contractInitialized, "Contract not initialized.");
        require(users[_addr].sponsor != address(0) || _addr == owner, "No Network Sponsor.");
        require(_amount >= depositMinimum, "Mininum investment not met.");
        require(users[_addr].totalDirectDeposits <= depositMaximum, "Maximum investment reached.");

        token.transferFrom(address(msg.sender), address(this), _amount);

        if(users[_addr].totalDepositAmount == 0){
            users[_addr].userYieldPercentage = baseYieldPercent; //new users will have a default yield of 1%
            userfirstInvestmentTime[_addr] = block.timestamp; //record users first initial deposit time
            totalUsers++;
        }

        uint256 amountToCompound = this.payoutToCompound(msg.sender);
        if(amountToCompound > 0 && users[_addr].totalDepositAmount.add(_amount) < this.maxCompoundOf(users[_addr].totalDirectDeposits)){
            
            //if user has existing deposit, increase user yield % 0.1 after 24 hours of last checkpoint.
            if(block.timestamp.sub(users[_addr].checkpoint) >= timeForYieldBonus) {
                if(users[_addr].userYieldPercentage < maxYieldPercent) users[_addr].userYieldPercentage += 1;
                users[_addr].userCompoundCount++; //add compound count
            }

            users[_addr].totalDepositAmount += amountToCompound;	
            users[_addr].incomeCompounded += amountToCompound;        
            totalCompounded += amountToCompound;
            emit CompoundedDeposit(msg.sender, amountToCompound);
        }

        uint256 amount = _amount.sub(payTax(_amount)); //user deposit will be - 10% to make it true value.
        users[_addr].totalDepositAmount += amount; //invested + compounded
        users[_addr].totalDirectDeposits += amount; //invested
        users[_addr].checkpoint = block.timestamp; //update action timestamp

        totalDeposited += amount;
        emit NewDeposit(_addr, amount);
        
        if(users[_addr].sponsor != address(0)) {
            
            uint256 refBonus = _amount.mul(referralBonus).div(percentageDivider);
            if(users[users[_addr].sponsor].totalDepositAmount.add(refBonus) > this.maxCompoundOf(users[users[_addr].sponsor].totalDirectDeposits)){
                refBonus = this.maxCompoundOf(users[users[_addr].sponsor].totalDirectDeposits).sub(users[users[_addr].sponsor].totalDepositAmount);
            }
            
            //referrer
            userBonusStatistics[users[_addr].sponsor].directBonus += refBonus;
            users[users[_addr].sponsor].totalDepositAmount += refBonus;  //invested + compounded
            users[users[_addr].sponsor].totalDirectDeposits += refBonus; //invested
            
            //referee
            userBonusStatistics[_addr].directBonus += refBonus;
            users[_addr].totalDepositAmount += refBonus;  //invested + compounded
            users[_addr].totalDirectDeposits += refBonus; //invested

            emit DirectPayout(users[_addr].sponsor, address(this), refBonus);  
        }

        users[users[_addr].sponsor].totalNetworkInvitesDeposit = users[users[_addr].sponsor].totalNetworkInvitesDeposit.add(_amount);
        
        _drawLastDepositWinner();
        lastDepositEntry( _addr,  amount);    
      
        _drawTopDepositPool();
        topDeposit(_addr, amount);
  
        _drawTopReferrerPool();
        poolReferralDeposit(_addr, amount);
    }

    function lastDepositEntry(address userAddress, uint256 amount) private {
        if(!lasDepositJackpotEnabled) return;

        uint256 share = amount.mul(50).div(percentageDivider);

        lastDepositCurrentPot = lastDepositCurrentPot.add(share) > maxRewardsPool ? 
        lastDepositCurrentPot.add(maxRewardsPool.sub(lastDepositCurrentPot)) : lastDepositCurrentPot.add(share);
        
        lastDepositStartTime = block.timestamp;
        potentialLastDepositWinner = userAddress;
    } 

    function _drawLastDepositWinner() private {
        if(lasDepositJackpotEnabled && lastDepositStartTime.add(lastDepositTimeStep) > block.timestamp && potentialLastDepositWinner != address(0)){
    
            User storage user = users[potentialLastDepositWinner];
            uint256 busdReward = lastDepositCurrentPot;

            user.totalDepositPayouts = user.totalDepositPayouts.add(busdReward);
            totalWithdrawn = totalWithdrawn.add(busdReward);

            uint256 devtTax = payTax(busdReward);

            token.transfer(potentialLastDepositWinner, busdReward.sub(devtTax));
            emit LastBuyEvent(currentLastBuyRound, potentialLastDepositWinner, busdReward, block.timestamp);

            lastDepositCurrentPot = 0;
            potentialLastDepositWinner = address(0);
            lastDepositStartTime = block.timestamp; 
            currentLastBuyRound++;
        }
    }

    function poolReferralDeposit(address _addr, uint256 _amount) private {
        
	    uint256 pool_amount = _amount.mul(50).div(percentageDivider);

        topReferrerPoolBalance = topReferrerPoolBalance.add(pool_amount) > maxRewardsPool ? 
        topReferrerPoolBalance.add(maxRewardsPool.sub(topReferrerPoolBalance)) : topReferrerPoolBalance.add(pool_amount);

        address sponsor = users[_addr].sponsor;

        if(sponsor == address(0) || sponsor == owner) return; //initial sponsor address will be excluded from the event.

        userTopReferrerList[topReferrerPoolCycle][sponsor] += _amount;

        for(uint8 i = 0; i < topReferrerPoolBonuses.length; i++) {
            if(topReferrerPool[i] == sponsor) break;

            if(topReferrerPool[i] == address(0)) {
                topReferrerPool[i] = sponsor;
                break;
            }

            if(userTopReferrerList[topReferrerPoolCycle][sponsor] > userTopReferrerList[topReferrerPoolCycle][topReferrerPool[i]]) {
                for(uint8 j = i + 1; j < topReferrerPoolBonuses.length; j++) {
                    if(topReferrerPool[j] == sponsor) {
                        for(uint8 k = j; k <= topReferrerPoolBonuses.length; k++) {
                            topReferrerPool[k] = topReferrerPool[k + 1];
                        }
                        break;
                    }
                }

                for(uint8 j = uint8(topReferrerPoolBonuses.length.sub(1)); j > i; j--) {
                    topReferrerPool[j] = topReferrerPool[j - 1];
                }

                topReferrerPool[i] = sponsor;

                break;
            }
        }
    }
    
    function _drawTopReferrerPool() private {
        if(topReferrerEnabled && topReferrerLastDrawAction.add(topReferrerTimeStep) > block.timestamp) {

            for(uint8 i = 0; i < topReferrerPoolBonuses.length; i++) {
                if(topReferrerPool[i] == address(0)) break;

                uint256 win = topReferrerPoolBalance.mul(topReferrerPoolBonuses[i]) / 100;

                userBonusStatistics[topReferrerPool[i]].topReferrerBonus += win;
                users[topReferrerPool[i]].totalDirectDeposits += win; // reward goes to top referrer address' deposit instead of being withdrawn.
                users[topReferrerPool[i]].totalDepositAmount += win; // direct deposit + compound
                topReferrerPoolBalance -= win;

                emit TopReferrerPayout(topReferrerPool[i], win);
            }

            for(uint8 i = 0; i < topReferrerPoolBonuses.length; i++) {
                topReferrerPool[i] = address(0);
            }

            topReferrerLastDrawAction = block.timestamp;
            topReferrerPoolCycle++;
        }
    }
    
    function topDeposit(address _addr, uint256 _amount) private {
        if(_addr == address(0) || _addr == owner) return;

	    uint256 pool_amount = _amount.mul(50).div(percentageDivider);

        topDepositPoolBalance = topDepositPoolBalance.add(pool_amount) > maxRewardsPool ? 
        topDepositPoolBalance.add(maxRewardsPool.sub(topDepositPoolBalance)) : topDepositPoolBalance.add(pool_amount);

        userTopDepositList[topDepositPoolCycle][_addr] += _amount;

        for(uint8 i = 0; i < topDepositBonuses.length; i++) {
            if(topDepositPool[i] == _addr) break;

            if(topDepositPool[i] == address(0)) {
                topDepositPool[i] = _addr;
                break;
            }

            if(userTopDepositList[topDepositPoolCycle][_addr] > userTopDepositList[topDepositPoolCycle][topDepositPool[i]]) {
                for(uint8 j = i + 1; j < topDepositBonuses.length; j++) {
                    if(topDepositPool[j] == _addr) {
                        for(uint8 k = j; k <= topDepositBonuses.length; k++) {
                            topDepositPool[k] = topDepositPool[k + 1];
                        }
                        break;
                    }
                }

                for(uint8 j = uint8(topDepositBonuses.length.sub(1)); j > i; j--) {
                    topDepositPool[j] = topDepositPool[j - 1];
                }

                topDepositPool[i] = _addr;
                break;
            }
        }
    }

    function _drawTopDepositPool() private {
        if(topDepositEnabled && topDepositLastDrawAction.add(topDepositTimeStep) > block.timestamp) {
        
            for(uint8 i = 0; i < topDepositBonuses.length; i++) {
                if(topDepositPool[i] == address(0)) break;

                uint256 win = topDepositPoolBalance.mul(topDepositBonuses[i]) / 100;
            
                userBonusStatistics[topDepositPool[i]].topDepositBonus += win; //only for statistics
                users[topDepositPool[i]].totalDirectDeposits += win; // reward goes to user deposit instead of being withdrawn.
                users[topDepositPool[i]].totalDepositAmount += win; // direct deposit + compound
                topDepositPoolBalance -= win;

                emit TopDepositPayout(topDepositPool[i], win);
            }

            for(uint8 i = 0; i < topDepositBonuses.length; i++) {
                topDepositPool[i] = address(0);
            }
            
            topDepositLastDrawAction = block.timestamp;
            topDepositPoolCycle++; 
        }
    }

    function withdraw() external nonReentrant {
        require(contractInitialized, "Contract not initialized.");
        (, uint256 max_payout, uint256 net_payout, ) = this.payoutOf(msg.sender);
        require(net_payout > 0, "User has no payout to withdraw.");
        require(users[msg.sender].totalDepositPayouts <= max_payout, "Max payout already received.");
        
        //userYieldPercentage will be deducted 0.5% every withdraw, starts at 1.6% else, if less than 1.5% yield it goes back to 1%
        if(users[msg.sender].userYieldPercentage >= baseYieldPercent || users[msg.sender].userYieldPercentage <= 15){
            users[msg.sender].userYieldPercentage = baseYieldPercent;        
        }
        else if(users[msg.sender].userYieldPercentage > 15){
            users[msg.sender].userYieldPercentage -= yieldDecreasePerWithdraw;    
        }
        
        if(users[msg.sender].totalDepositPayouts.add(net_payout) >= max_payout) {
            net_payout = max_payout.sub(users[msg.sender].totalDepositPayouts);
            emit MaxPayoutReached(msg.sender, users[msg.sender].totalDepositPayouts);
        }

        users[msg.sender].userCompoundCount = 0; //user consecutive compound count will reset when withdraw is triggered
        users[msg.sender].totalDepositPayouts += net_payout;
        users[msg.sender].checkpoint = block.timestamp;

        if(token.balanceOf(address(this)) < net_payout) {
            net_payout = token.balanceOf(address(this));
        }
        
        token.transfer(msg.sender, net_payout);
        totalWithdrawn += net_payout;
        
        emit Withdraw(msg.sender, net_payout);
    }

    function compound(address addr) public initialized {
        require(contractInitialized, "Contract not initialized.");
        (, uint256 max_payout, , ) = this.payoutOf(addr);
        require(users[addr].totalDepositPayouts < max_payout, "Max payout already received.");

        uint256 toCompound = this.payoutToCompound(addr);

        require(toCompound > 0, "User has zero income to compound.");
        uint256 finalCompoundAmount = compoundAmountOf(addr, toCompound);

        users[addr].totalDepositAmount += finalCompoundAmount;
        users[addr].incomeCompounded += finalCompoundAmount;  
        users[addr].checkpoint = block.timestamp;   
        totalCompounded += finalCompoundAmount;

        //increase user yield % 0.1 for compounds done every after 24 hours of last action.
        if(users[addr].checkpoint.add(timeForYieldBonus) >= block.timestamp) {
            if(users[addr].userYieldPercentage < maxYieldPercent) users[addr].userYieldPercentage += 1;
            users[addr].userCompoundCount++;
        }
        emit CompoundedDeposit(addr, finalCompoundAmount);
	}

    function setSponsor(address _addr, address _sponsor) private {
        if(this.checkSponsorValid(_addr, _sponsor)) {
            users[_addr].sponsor = _sponsor;

            if(!userNetworkInfo[_sponsor].exists) {
                //create network.
                uint256 networkId = totalNetworksCreated++;
                networks[networkId].id = networkId;
                networks[networkId].createTime = block.timestamp;
                networks[networkId].owner = _sponsor;
                networks[networkId].members.push(_sponsor);
                networks[networkId].isReferralNetwork = true;
                //create network info
                userNetworkInfo[_sponsor].id = networkId;
                userNetworkInfo[_sponsor].exists = true;
                //add network to sponsor address
                userNetworks[_sponsor].push(NetworkInfo(networkId, true));
            }

            bool memberExists;
            for(uint256 i = 0; i < networks[userNetworkInfo[_sponsor].id].members.length; i++){
                if(networks[userNetworkInfo[_sponsor].id].members[i] == _addr){
                    memberExists = true;
                }
            }

            if(!memberExists){
                Network storage network = networks[userNetworkInfo[_sponsor].id];
                network.members.push(_addr);
                userNetworks[_addr].push(NetworkInfo(userNetworkInfo[_sponsor].id, true));
            }
            emit Sponsor(_addr, _sponsor);
            users[_sponsor].networkInvites++; //record total referral of network upline
        }
    }

    function checkSponsorValid(address _addr, address _sponsor) external view returns (bool isValid) {	
        if(users[_addr].sponsor == address(0) && _sponsor != _addr && _addr != owner && (users[_sponsor].checkpoint > 0 || _sponsor == owner)) {
            isValid = true;        
        }
    }

    function payoutOf(address _addr) view external returns(uint256 payout, uint256 max_payout, uint256 net_payout, uint256 sustainability_fee) {
        max_payout = this.maxPayoutOf(users[_addr].totalDepositAmount);
        
        if(users[_addr].totalDepositPayouts < max_payout) {
            uint256 actionTime = users[_addr].checkpoint < block.timestamp.sub(maxAccumulationTime) ? block.timestamp.sub(maxAccumulationTime) : users[_addr].checkpoint;
            payout = (users[_addr].totalDepositAmount.mul(users[_addr].userYieldPercentage).div(percentageDivider))
                    .mul(block.timestamp.sub(actionTime)).div(timeStep);

            if(users[_addr].totalDepositPayouts.add(payout) > max_payout) {
                payout = max_payout.sub(users[_addr].totalDepositPayouts);
            }

            uint256 sustainTax = this.getVariableWithdrawTax(_addr);
            sustainability_fee = payout.mul(sustainTax).div(percentageDivider);
            net_payout = payout.sub(sustainability_fee);
        }
    }

    function getVariableWithdrawTax(address _addr) view external returns(uint256 withdrawTax) {
        if(users[_addr].userCompoundCount <= daysCount[0]){
            withdrawTax = varTaxes[4]; 
        }
        else if(users[_addr].userCompoundCount > daysCount[0] 
        && users[_addr].userCompoundCount <= daysCount[1]){
            withdrawTax = varTaxes[3]; 
        }
        else if(users[_addr].userCompoundCount > daysCount[1] 
        && users[_addr].userCompoundCount <= daysCount[2]){ 
            withdrawTax = varTaxes[2]; 
        }
        else if(users[_addr].userCompoundCount > daysCount[2] 
        && users[_addr].userCompoundCount <= daysCount[3]){ 
            withdrawTax = varTaxes[1]; 
        }
        else if(users[_addr].userCompoundCount > daysCount[3]){ 
            withdrawTax = varTaxes[0]; 
        }
    }

    function payoutToCompound(address _addr) view external returns(uint256 finalPayout) {
        uint256 max_payout = this.maxPayoutOf(users[_addr].totalDepositAmount);

        if(users[_addr].totalDepositPayouts < max_payout) {   
            uint256 actionTime = users[_addr].checkpoint < block.timestamp.sub(maxAccumulationTime) ? block.timestamp.sub(maxAccumulationTime) : users[_addr].checkpoint;
            uint256 payout = (users[_addr].totalDepositAmount.mul(users[_addr].userYieldPercentage).div(percentageDivider))
                    .mul(block.timestamp.sub(actionTime)).div(timeStep);
            finalPayout = payout.sub(payout.mul(compoundTax).div(percentageDivider));   
        }            
    }

    function maxPayoutOf(uint256 _amount) view external returns(uint256) {
        return _amount.mul(userMaxPayout).div(percentageDivider);
    }

    function compoundAmountOf(address _addr, uint256 amountToCompound) view public returns(uint256 compoundAmount) {
        uint256 maxCompoundAmount = this.maxCompoundOf(users[_addr].totalDirectDeposits); 
        compoundAmount = amountToCompound; 
        if(users[_addr].totalDepositAmount >= maxCompoundAmount) compoundAmount = 0; //avoid reverts, but if amount = 0, user already has exceeded x5 of total deposit.  
        if(users[_addr].totalDepositAmount.add(compoundAmount) >= maxCompoundAmount) compoundAmount = maxCompoundAmount.sub(users[_addr].totalDepositAmount);    
    }

    function maxCompoundOf(uint256 _amount) view external returns(uint256) {
        return _amount.mul(maxCompoundMultiplier);
    }

    function airdrop(address _to,uint256 _amount) external nonReentrant {
        require(airdropEnabled, "Airdrop not Enabled.");
        require(contractInitialized, "Contract not initialized.");
        require(users[_to].totalDepositAmount.add(_amount) <= this.maxCompoundOf(users[_to].totalDirectDeposits), "User exceeded x5 of total deposit.");
        require(_amount >= airdropMinimum, "Mininum airdrop amount not met.");
        require(users[_to].sponsor != address(0), "Address not found.");
        address _addr = msg.sender;

        token.transferFrom(address(msg.sender), address(this), _amount);
     
        uint256 aidropTax = _amount.mul(airdropTax).div(percentageDivider);
        uint256 payout = _amount.sub(aidropTax);

        airdrops[_addr].airdropSent += payout;
        airdrops[_addr].lastAirdropSentTime = block.timestamp;
        airdrops[_to].airdropReceived += payout;
        airdrops[_to].lastAirdropReceivedTime = block.timestamp;

        //airdrop amount will be put in user deposit amount.
        users[_to].totalDirectDeposits += payout; //real investment
        users[_to].totalDepositAmount += payout; //real investment + compounded 
        
        emit NewAirdrop(_addr, _to, payout, block.timestamp);
        totalAirdrops += payout;
    }

    function networkAirdrop(uint256 networkId, bool excludeOwner, uint256 _amount) external nonReentrant {
        address _addr = msg.sender;
        require(airdropEnabled, "Airdrop not Enabled.");
        require(contractInitialized, "Contract not initialized.");
        require(_amount >= airdropMinimum, "Mininum airdrop amount not met.");
        require(networks[networkId].owner != address(0), "Network not found.");

        token.transferFrom(address(_addr), address(this), _amount);

        uint256 aidropTax = _amount.mul(airdropTax).div(percentageDivider);
        uint256 payout = _amount.sub(aidropTax);
        uint256 memberDivider = networks[networkId].members.length;
        
        if(excludeOwner == true){
            memberDivider--;
        }

        uint256 amountDivided = payout.div(memberDivider);

        for(uint256 i = 0; i < networks[networkId].members.length; i++) {

            address _to = address(networks[networkId].members[i]);
            if(excludeOwner == true && _to == networks[networkId].owner){
                continue;
            }

            if(users[_to].totalDepositAmount.add(_amount) >= this.maxCompoundOf(users[_to].totalDirectDeposits)){
                continue;
            }
            
            airdrops[_addr].airdropSent += amountDivided;
            airdrops[_addr].lastAirdropSentTime = block.timestamp;
            airdrops[_to].airdropReceived += amountDivided;
            airdrops[_to].lastAirdropReceivedTime = block.timestamp;

            //airdrop amount will be put in user deposit amount.
            users[_to].totalDirectDeposits += amountDivided; //real investment
            users[_to].totalDepositAmount += amountDivided; //real investment + compounded 

            emit NewAirdrop(_addr, _to, payout, block.timestamp);
        }
        totalAirdrops += payout;
    }
    
    function payTax(uint256 amount) internal returns(uint256) {
        uint256 devtTax = amount.mul(developmentTax).div(percentageDivider);
        uint256 projTax = amount.mul(projectTax).div(percentageDivider);
        uint256 mktTax = amount.mul(marketTax).div(percentageDivider);
        token.transfer(development, devtTax);
        token.transfer(project, projTax);
        token.transfer(marketing, mktTax);
        return devtTax + projTax + marketTax;
    }

    function userInfo(address _addr) view external returns(address sponsor, uint256 checkpoint, uint256 totalDirectDeposits, uint256 totalDepositAmount, uint256 payouts, NetworkInfo[] memory member_of_networks, uint256 userYieldPercentage    ) {
        return (users[_addr].sponsor, users[_addr].checkpoint, users[_addr].totalDirectDeposits, users[_addr].totalDepositAmount, users[_addr].totalDepositPayouts, userNetworks[_addr], users[_addr].userYieldPercentage);
    }

    function userInfo2(address _addr) view external returns(uint256 directBonus, uint256 topDepositBonus, uint256 topReferrerBonus, uint256 networkInvites, uint256 totalNetworkInvitesDeposit, uint256 incomeCompounded) {
        return (userBonusStatistics[_addr].directBonus, userBonusStatistics[_addr].topDepositBonus, userBonusStatistics[_addr].topReferrerBonus, users[_addr].networkInvites, users[_addr].totalNetworkInvitesDeposit, users[_addr].incomeCompounded);
    }

    function userInfo3(address _addr) view external returns(uint256 lastAirdrop, uint256 airdropSent, uint256 airdropReceived, uint256 sponsor_network, bool sponsor_network_exists){
        User memory user = users[_addr];
        return  (airdrops[_addr].lastAirdropSentTime, airdrops[_addr].airdropSent, airdrops[_addr].airdropReceived, userNetworkInfo[user.sponsor].id, userNetworkInfo[user.sponsor].exists);    
    }

    function contractInfo() view external returns(uint256 _totalUsers, uint256 _totalDeposited, uint256 _totalWithdrawn, uint256 _totalCompounded, uint256 _totalAirdrops, uint256 _totalNetworksCreated, uint256 current_tvl) {
        return (totalUsers, totalDeposited, totalWithdrawn, totalCompounded, totalAirdrops, totalNetworksCreated, token.balanceOf(address(this)));
    }

    function topReferrerInfo() view external returns(address[5] memory addrs, uint256[5] memory deps, uint256 _topReferrerLastDrawAction, uint256 _topReferrerPoolBalance, uint256 _topReferrerCurrentLeader) {
        
        for(uint8 i = 0; i < topReferrerPoolBonuses.length; i++) {
            if(topReferrerPool[i] == address(0)) break;

            addrs[i] = topReferrerPool[i];
            deps[i] = userTopReferrerList[topReferrerPoolCycle][topReferrerPool[i]];
        }
        _topReferrerLastDrawAction = topReferrerLastDrawAction; 
        _topReferrerPoolBalance = topReferrerPoolBalance; 
        _topReferrerCurrentLeader = userTopReferrerList[topReferrerPoolCycle][topReferrerPool[0]];
    }

    function topDepositInfo() view external returns(address[5] memory addrs, uint256[5] memory deps, uint256 _topDepositLastDrawAction, uint256 _topDepositPoolBalance, uint256 _topDepositCurrentLeader) {
        
        for(uint8 i = 0; i < topDepositBonuses.length; i++) {
            if(topDepositPool[i] == address(0)) break;  
            addrs[i] = topDepositPool[i];
            deps[i] = userTopDepositList[topDepositPoolCycle][topDepositPool[i]];
        }
        _topDepositLastDrawAction = topDepositLastDrawAction;
        _topDepositPoolBalance = topDepositPoolBalance;
        _topDepositCurrentLeader = userTopDepositList[topDepositPoolCycle][topDepositPool[0]];
    }
    
    function transferOwnership(bool isRenounce, address addr) public onlyOwner {
        owner = isRenounce ? owner = address(0) : owner = addr;
    }

    function enableAirdrop(bool value) external onlyOwner {
        airdropEnabled = value;
    }  

    function enableTopDepositJackpot(bool value) external onlyOwner {
        require(contractInitialized, "Contract not yet Started.");
        _drawTopDepositPool(); //events will run before value change
        if(value){
            topDepositEnabled = true;
            topDepositTimeStep = block.timestamp;
        }
        else{
            topDepositEnabled = false;                 
        }
    }

    function enableTopReferrerJackpot(bool value) external onlyOwner {
        require(contractInitialized, "Contract not yet Started.");
        _drawTopReferrerPool(); //events will run before value change
        if(value){
            topReferrerEnabled = true;
            topReferrerTimeStep = block.timestamp;
        }
        else{
            topReferrerEnabled = false;                 
        }
    }

    function enableLastDepositJackpot(bool value) external onlyOwner {
        require(contractInitialized, "Contract not yet Started.");
        _drawLastDepositWinner(); //events will run before value change
        if(value){
            lasDepositJackpotEnabled = true;
            lastDepositStartTime = block.timestamp;
        }
        else{
            lasDepositJackpotEnabled = false;                 
        }
    }

    //External contract related functions. 
    function userAutoInfo(address _addr) view external returns(uint256 checkpoint, uint256 totalDepositAmount) {
        return (users[_addr].checkpoint, users[_addr].totalDepositAmount);
    }

    function runAutoCompound(address addr) external initialized {
        require(msg.sender == autoCompoundExecutor, "Function can only be triggered by the autoCompoundExecutor.");
        require(autoCompoundEnabled, "Auto Compound not Activated.");
        compound(addr); //checks should already be done before this point.
        emit AutoCompoundEvent(addr, block.timestamp);
    }
    
    function runDrawEvents() external initialized {
        require(msg.sender == autoCompoundExecutor, "Function can only be triggered by the autoCompoundExecutor.");
            _drawTopDepositPool();
            _drawTopReferrerPool();
            _drawLastDepositWinner();      
    }

    function checkDrawEvents() external view initialized returns(bool){
        require(msg.sender == autoCompoundExecutor, "Function can only be triggered by the autoCompoundExecutor.");
        if(topDepositLastDrawAction.add(topDepositTimeStep) > block.timestamp) return true;
        if(topReferrerLastDrawAction.add(topReferrerTimeStep) > block.timestamp) return true;
        if(lasDepositJackpotEnabled && lastDepositStartTime.add(lastDepositTimeStep) > block.timestamp && potentialLastDepositWinner != address(0)) return true;
        return false;
    }
    
    function updateAutoCompoundContract(address value) external onlyOwner {
        require(isContract(value));	
        autoCompoundExecutor = value; //The Auto Compound Contract.
    }
     
    function enableAutoCompound(bool value) external onlyOwner {
        require(contractInitialized, "Contract not yet Started.");
        autoCompoundEnabled = value; //Make sure when enabling this feature, autoCompoundExecutor is already set.
    }
}