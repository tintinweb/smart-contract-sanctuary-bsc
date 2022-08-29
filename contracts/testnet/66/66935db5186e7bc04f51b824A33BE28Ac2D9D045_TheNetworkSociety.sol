/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

/** 
    The Network Society Project

    Variable Daily Yield starts at 1% up to 2.5%:
    - Compound action every 24 hours will give 0.1% added to their current yield. max of 15 times(2.5%) 
        - Compound is not mandatory, but compounding will increase your daily yield.
    - Every withdraw/sell action, will have a 0.5% deduction to the current user yield that will start at 1.6%.
    - User yield percentage greater than or equal to 1.5% will go back to base yield of 1%.
    - User can only compound 5x max of his real invested amount.
    - User max payout cap:
        I.E for sample investment calculation: totalDirectDeposits = 1
        1(totalDirectDeposits) x 5(max compound multiplier) x 3650(max payout) / 1000(percent divider) = 18.25(maxPayoutCap)

    4% Referral Bonus:
    - 2% goes to the Referrer as direct deposit.
    - 2% goes to the Referee as direct deposit.

    Max reward accumulation of 48 Hours.
    - If no action is done within 48 hours, reward accumulation will stop and will only reset if a deposit, withdraw or compound is done.
    
    Daily Top Investors and Daily Top Referrer:
    - 5 winners for reach pool will share the pool 1st place 30%, 2nd place 25%, 3rd place 20%, 4th place 15%, 5th place 10%. 
    - Reward goes directly to user as direct deposit instead of making it withdrawable/claimable.
    - 10% of each deposit will be put into the rewards pool(max pool size of 2000 ether)
      I.E Rewards Distribution is max pool size is reached:
      1st place: 600 ether
      2nd place: 500 ether
      3rd place: 400 ether
      4th place: 300 ether
      5th place: 200 ether
    
    Auto Compound Feature:
    - Users will deposit the current average gas fee per compound.
    - Users will have an option to disable it during the cycle and allow to withdraw the deposited BNB.
    - Enabled auto-compound should finish the cycle, users will not be able to add days in between, 
      will need to disable the function and withdraw and reset auto compound.

    Network and Individual Airdrop.
    - Users can airdrop invested addresses which will go directly as users direct deposit instead of making it withdrawable/claimable.
    - Network Leaders can airdrop x amount of token to their members. amount(less airdrop tax) * no. of network members.

    Unstake Function: 
    - Users can unstake within 14 days. users can unstake (deposit - withdrawn) 5% goes to payFees 15% goes back to TVL (20% total tax).
    - User records will reset to 0.
    - Users will not be able to deposit using the same address again once unstaked.
    
    Partnership program:
    - Hold x Amount of token to earn +% for referral bonuses and max yield cap. depending on level requirements.
      Bronze Tier   - 15,000 Token -  +0.3% Referral Bonus, +0.1% Max Yield Cap
      Silver Tier   - 30,000 Token -  +0.6% Referral Bonus, +0.2% Max Yield Cap
      Gold Tier     - 45,000 Token -  +0.9% Referral Bonus, +0.3% Max Yield Cap
      Platinum Tier - 60,000 Token -  +1.2% Referral Bonus, +0.4% Max Yield Cap
      Diamond Tier  - 75,000 Token -  +1.5% Referral Bonus, +0.5% Max Yield Cap          
**/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IToken {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract TheNetworkSociety {
    using SafeMath for uint256;
    using SafeMath for uint8;
    
    IToken public token;
    
    address private owner;
    address private autoCompoundExecutor;
    address private project;
    address private marketing;

    struct User {
        address sponsor; //network sponsor
        uint256 networkInvites; // invite count
        uint256 totalDepositAmount; //invested + compounded
        uint256 totalDepositPayouts; //payouts
        uint256 totalDirectDeposits; //invested event payouts + airdrops are considered real deposits
        uint256 incomeCompounded; //compounded
        uint256 totalNetworkInvitesDeposit; //total invested by invites
        uint256 checkpoint;
        uint256 userYieldPercentage; //user personal yield.
    }

    struct UserBonusStatistics {
        uint256 directBonus;
        uint256 topDepositBonus; 
        uint256 topReferrerBonus;
    }

    struct Airdrop {
        uint256 airdrops;
        uint256 airdropSent;
        uint256 airdropSentCount;
        uint256 airdropReceived;
        uint256 airdropReceivedCount;
        uint256 lastAirdrop;
        uint256 lastAirdropReceived;
    }

    struct Network {
        address[] members;
        address owner;
        uint256 id;
        uint256 createTime;
        bool isReferralNetwork;
    }

    struct NetworkInfo {
        uint256 id;
        bool exists;
    }
    
    mapping(uint256 => Network) public networks;
    mapping(address => User) public users;
    mapping(address => UserBonusStatistics) public userBonusStatistics;
    mapping(address => Airdrop) public airdrops;
    mapping(address => NetworkInfo[]) public userNetworks;
    mapping(address => NetworkInfo) public userNetworkInfo;
    mapping(address => bool) public alreadyUnstaked;
    mapping(uint8 => address) public topDepositPool;
    mapping(uint8 => address) public topReferrerPool;
    mapping(address => uint256) public userfirstInvestmentTime;
    mapping(uint256 => mapping(address => uint256)) public userTopReferrerList;
    mapping(uint256 => mapping(address => uint256)) public userTopDepositList;
    
    uint256 private percentageDivider = 1000;
    uint256 private referralFee = 20;
    uint256 private sustainabilityTax = 100;
    uint256 private projectTax = 85;

    uint256 private marketTax = 10;
    uint256 private airdropTax = 100;
    uint256 private compoundTax = 30;
    uint256 private userMaxPayout = 3650;
    uint256 private yieldDecreasePerWithdraw = 5;
    uint256 private timeForYieldBonus = 86400;
    uint256 private timeStep = 86400;
    uint256 private eventTimeStep = 86400;
    uint256 private maxAccumulationTime = 86400 * 2;
    uint256 private maxCompoundMultiplier = 5;
    uint256 private unstakeDaysLimit = 14 days;
    uint256 private unstakeTVLtax = 100;
    uint256 private baseYieldPercent = 10;
    uint256 private maxYieldPercent = 25;
    uint256 private depositMinimum = 1 * (10 ** 18);  
    uint256 private depositMaximum = 50000 * (10 ** 18); 
    uint256 private airdropMinimum = 1 * (10 ** 18);
    uint256 private maxRewardsPool = 2000 * (10 ** 18);



    uint8[] private topDepositBonuses = [30, 25, 20, 15, 10];
    uint8[] private topReferrerPoolBonuses = [30, 25, 20, 15, 10];

    uint256 public lastDepositStartTime;
    uint256 private lastDepositTimeStep = 3 hours;
    address public potentialLastDepositWinner;
    uint256 public lastDepositCurrentPot;
    uint256 public currentLastBuyRound = 1;

    uint256 private totalUsers = 1;
    uint256 private totalDeposited;
    uint256 private totalWithdrawn;
    uint256 private totalCompounded;
    uint256 private totalAirdrops;
    uint256 private totalNetworksCreated;

    uint256 public topReferrerLastDrawAction;
    uint256 public topReferrerPoolCycle;
    uint256 public topReferrerPoolBalance;

    uint256 public topDepositLastDrawAction;
    uint256 public topDepositPoolCycle;
    uint256 public topDepositPoolBalance;

    bool private contractInitialized;
    bool private airdropEnabled;
    bool private autoCompoundEnabled;
    bool private partnershipEnabled;
    bool private lasDepositJackpotEnabled;
    bool private locked;

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
    event UnstakeEvent(address indexed addr, uint256 timestamp, address sponsor, uint256 returnAmt);
    event LastBuyEvent(uint256 indexed round, address indexed winner, uint256 amountRewards, uint256 drawTime);

    constructor(address ITokenAddress, address prj, address market) {
		
        require(isContract(ITokenAddress));
        require(!isContract(prj) && !isContract(market));		
        owner = msg.sender;
        project = prj;
        marketing = market;
        token = IToken(ITokenAddress);
    }




  
    function initializeContract() external onlyOwner {
        require(!contractInitialized);
        contractInitialized = true;
        topDepositLastDrawAction = block.timestamp;
        topReferrerLastDrawAction = block.timestamp;    
    }

    //test function delete in main net.
    function updateTimeForTesting(uint256 eventTime, uint256 yieldTime, uint256 dayStep) external onlyOwner {
        eventTimeStep = eventTime;
        timeForYieldBonus = yieldTime;
        timeStep = dayStep;     
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
    function _invest(address _addr, uint256 _amount) private {
        require(contractInitialized, "Contract not initialized.");
        require(!alreadyUnstaked[_addr], "Address already unstaked, please use a new address to invest.");
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
            if(block.timestamp.sub(users[_addr].checkpoint) >= timeForYieldBonus){
                //only increase yield if % not yet capped.
                uint256 addCapBonus = 0;
                if(partnershipEnabled){
                    ( , uint256 bonusCapPrc) = partnershipContract.getPartnershipBonus(users[_addr].sponsor);
                    addCapBonus = bonusCapPrc;             
                }

                if(users[_addr].userYieldPercentage < maxYieldPercent.add(addCapBonus)) users[_addr].userYieldPercentage += 1;
            }

            users[_addr].totalDepositAmount += amountToCompound;	
            users[_addr].incomeCompounded += amountToCompound;        
            totalCompounded += amountToCompound;
            emit CompoundedDeposit(msg.sender, amountToCompound);
        }

        uint256 amount = _amount.sub(payTax(_amount)); //user deposit will be - 10% to make it true value.
        users[_addr].totalDepositAmount += amount; //invested + compounded
        users[_addr].totalDirectDeposits += amount; //invested
        users[_addr].checkpoint = block.timestamp;

        totalDeposited += amount;
        emit NewDeposit(_addr, amount);
        
        if(users[_addr].sponsor != address(0)) {
            uint256 addRefBonus = 0;
            if(partnershipEnabled){
                (uint256 bonusRefFee, ) = partnershipContract.getPartnershipBonus(users[_addr].sponsor);
                 addRefBonus = bonusRefFee;             
            }
            uint256 refBonus = _amount.mul(referralFee.add(addRefBonus)).div(percentageDivider); //use untaxed amount.

			if(users[users[_addr].sponsor].checkpoint > 0 && users[users[_addr].sponsor].totalDepositAmount < this.maxCompoundOf(users[users[_addr].sponsor].totalDirectDeposits)) {

                if(users[users[_addr].sponsor].totalDepositAmount.add(refBonus) > this.maxCompoundOf(users[users[_addr].sponsor].totalDirectDeposits)){
                    refBonus = this.maxCompoundOf(users[users[_addr].sponsor].totalDirectDeposits).sub(users[users[_addr].sponsor].totalDepositAmount);
                }

                //referee
                userBonusStatistics[_addr].directBonus += refBonus;
                users[_addr].totalDirectDeposits += refBonus;
                //referrer
                userBonusStatistics[users[_addr].sponsor].directBonus += refBonus;
                users[users[_addr].sponsor].totalDirectDeposits += refBonus;
                emit DirectPayout(users[_addr].sponsor, _addr, refBonus);
			}
        }

        users[users[_addr].sponsor].totalNetworkInvitesDeposit = users[users[_addr].sponsor].totalNetworkInvitesDeposit.add(_amount); //record invites total deposits.
        
        drawLastDepositWinner();
        lastDepositEntry( _addr,  amount);    
      
         _drawPool();
        topDeposit(_addr, amount);
  
         _drawTopReferrerPool();
        poolReferralDeposit(_addr, amount);
    }
    function lastDepositEntry(address userAddress, uint256 amount) private {
        if(!lasDepositJackpotEnabled || userAddress == owner) return;

        uint256 share = amount.mul(50).div(1000);

        if(lastDepositCurrentPot.add(share) > maxRewardsPool){       
            lastDepositCurrentPot += maxRewardsPool.sub(lastDepositCurrentPot);
        }
        else{
            lastDepositCurrentPot += share;
        }
        
        lastDepositStartTime = block.timestamp;
        potentialLastDepositWinner = userAddress;
    } 

    function drawLastDepositWinner() private {
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
        
	    uint256 pool_amount = _amount.mul(100).div(percentageDivider);
		
        if(topReferrerPoolBalance.add(pool_amount) > maxRewardsPool){ // check if old balance + additional pool deposit is in range            
            topReferrerPoolBalance += maxRewardsPool.sub(topReferrerPoolBalance);
        }else{
            topReferrerPoolBalance += pool_amount;
        }

        address sponsor = users[_addr].sponsor;

        if(sponsor == address(0) || sponsor == owner) return;

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
    
    function topDeposit(address _addr, uint256 _amount) private {
        if(_addr == address(0) || _addr == owner) return;

	    uint256 pool_amount = _amount.mul(100).div(percentageDivider);
		
        if(topDepositPoolBalance.add(pool_amount) > maxRewardsPool) {            
            topDepositPoolBalance += maxRewardsPool.sub(topDepositPoolBalance);
        }
        else{
            topDepositPoolBalance += pool_amount;
        }

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
    
    function _drawTopReferrerPool() private {
        if(topReferrerLastDrawAction.add(eventTimeStep) > block.timestamp) {
        
            topReferrerLastDrawAction = block.timestamp;
            topReferrerPoolCycle++;

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
        }
    }

    function _drawPool() private nonReentrant {
        if(topDepositLastDrawAction.add(eventTimeStep) > block.timestamp) {
            
        
            topDepositLastDrawAction = block.timestamp;
            topDepositPoolCycle++; 

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
        }
    }

    function withdraw() external nonReentrant {
        require(contractInitialized, "Contract not initialized.");
        (, uint256 max_payout, uint256 net_payout, ) = this.payoutOf(msg.sender);
        uint256 maxPayoutCap = this.maxPayoutCapOf(msg.sender);
        require(net_payout > 0, "User has no payout to withdraw.");
        require(users[msg.sender].totalDepositPayouts <= max_payout, "Max payout already received.");
        require(users[msg.sender].totalDepositPayouts <= maxPayoutCap, "Max payout cap reached.");
        
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

        if(users[msg.sender].totalDepositPayouts.add(net_payout) >= maxPayoutCap) {
            net_payout = maxPayoutCap.sub(users[msg.sender].totalDepositPayouts);
            emit MaxPayoutCapReached(msg.sender, maxPayoutCap);
        }

        users[msg.sender].totalDepositPayouts += net_payout;
        users[msg.sender].checkpoint = block.timestamp;
        
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

        //increase user yield % 0.1 every compound after 24 hours.
        if(block.timestamp.sub(users[addr].checkpoint) >= timeForYieldBonus){
                //only increase yield if % not yet capped.
                uint256 addCapBonus = 0;
                if(partnershipEnabled){
                    ( , uint256 bonusCapPrc) = partnershipContract.getPartnershipBonus(users[addr].sponsor);
                    addCapBonus = bonusCapPrc;             
                }
            if(users[addr].userYieldPercentage < maxYieldPercent.add(addCapBonus)) users[addr].userYieldPercentage += 1;
        }
        emit CompoundedDeposit(addr, finalCompoundAmount);
	}

    function setSponsor(address _addr, address _sponsor) private {
        if(this.checkSponsorValid(_addr, _sponsor)) {
            users[_addr].sponsor = _sponsor;

            //create network
            if(userNetworkInfo[_sponsor].exists == false){
                uint256 networkId = totalNetworksCreated++;

                networks[networkId].id = networkId;
                networks[networkId].createTime = block.timestamp;
                networks[networkId].owner = _sponsor;
                networks[networkId].members.push(_sponsor);
                networks[networkId].isReferralNetwork = true;

                userNetworkInfo[_sponsor].id = networkId;
                userNetworkInfo[_sponsor].exists = true;

                userNetworks[_sponsor].push(NetworkInfo(networkId, true));
            }

            // check if current user is in invite-network
            bool memberExists = false;
            for(uint256 i = 0; i < networks[userNetworkInfo[_sponsor].id].members.length; i++){
                if(networks[userNetworkInfo[_sponsor].id].members[i] == _addr){
                    memberExists = true;
                }
            }

            if(memberExists == false){
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
            sustainability_fee = payout.mul(sustainabilityTax).div(percentageDivider);
            net_payout = payout.sub(sustainability_fee);
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

    function maxPayoutCapOf(address addr) view external returns(uint256){
        return users[addr].totalDirectDeposits.mul(maxCompoundMultiplier).mul(userMaxPayout).div(percentageDivider);
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

        airdrops[_addr].airdrops += payout;
        airdrops[_addr].airdropSent += payout;
        airdrops[_addr].lastAirdrop = block.timestamp;
        airdrops[_addr].airdropSentCount = airdrops[_addr].airdropSentCount.add(1);
        airdrops[_to].airdropReceived += payout;
        airdrops[_to].airdropReceivedCount = airdrops[_to].airdropReceivedCount.add(1);
        airdrops[_to].lastAirdropReceived = block.timestamp;

        //airdrop amount will be put in user deposit amount.
        users[_to].totalDirectDeposits += payout;
        
        emit NewAirdrop(_addr, _to, payout, block.timestamp);
        totalAirdrops += payout;
    }

    function networkAirdrop(uint256 networkId, bool excludeOwner,uint256 _amount) external nonReentrant {
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

        for(uint8 i = 0; i < networks[networkId].members.length; i++) {

            address _to = address(networks[networkId].members[i]);
            if(excludeOwner == true && _to == networks[networkId].owner){
                continue;
            }

            if(users[_to].totalDepositAmount.add(_amount) >= this.maxCompoundOf(users[_to].totalDirectDeposits)){
                continue;
            }
            
            airdrops[_addr].airdrops += amountDivided;
            airdrops[_addr].airdropSent += amountDivided;
            airdrops[_addr].lastAirdrop = block.timestamp;
            airdrops[_addr].airdropSentCount += 1;
            airdrops[_to].airdropReceived += amountDivided;
            airdrops[_to].airdropReceivedCount += 1;
            airdrops[_to].lastAirdropReceived = block.timestamp;

            //airdrop amount will be put in user deposit amount.
            users[_to].totalDirectDeposits += amountDivided; 

            emit NewAirdrop(_addr, _to, payout, block.timestamp);
        }
        totalAirdrops += payout;
    }
    

    function payTax(uint256 amount) internal returns(uint256) {
        uint256 projTax = amount.mul(projectTax).div(percentageDivider);
        uint256 mktTax = amount.mul(marketTax).div(percentageDivider);

  
        token.transfer(project, projTax);
        
        token.transfer(marketing, mktTax);
        return projTax.add(marketTax);
    }

    function userPrimaryInfo(address _addr) view external returns(address sponsor, uint256 checkpoint, uint256 totalDepositAmount, uint256 payouts, NetworkInfo[] memory member_of_networks, uint256 userYieldPercentage) {
        return (users[_addr].sponsor, users[_addr].checkpoint, users[_addr].totalDepositAmount, users[_addr].totalDepositPayouts, userNetworks[_addr], users[_addr].userYieldPercentage);
    }

    function userTotalsInfo(address _addr) view external returns(uint256 networkInvites, uint256 totalDirectDeposits, uint256 incomeCompounded, uint256 totalNetworkInvitesDeposit) {
        return (users[_addr].networkInvites, users[_addr].totalDirectDeposits, users[_addr].incomeCompounded, users[_addr].totalNetworkInvitesDeposit);
    }

    function userBonusInfo(address _addr) view external returns(uint256 directBonus, uint256 topDepositBonus, uint256 topReferrerBonus) {
        return (userBonusStatistics[_addr].directBonus, userBonusStatistics[_addr].topDepositBonus, userBonusStatistics[_addr].topReferrerBonus);
    }

    function userAirdropInfo(address _addr) view external returns(uint256 lastAirdrop, uint256 airdropSent, uint256 airdropReceived){
        return  (airdrops[_addr].lastAirdrop, airdrops[_addr].airdropSent, airdrops[_addr].airdropReceived);    
    }

    function userDirectNetworksInfo(address _addr) view external returns(uint256 sponsor_network, bool sponsor_network_exists) {
        User memory user = users[_addr];
        return (userNetworkInfo[user.sponsor].id, userNetworkInfo[user.sponsor].exists);
    }

    function networkInfo(uint256 networkId) view external returns(Network memory _network) {
        return networks[networkId];
    }

    function contractInfo() view external returns(uint256 _totalUsers, uint256 _totalDeposited, uint256 _totalWithdrawn, uint256 _totalCompounded, uint256 _totalAirdrops, uint256 _totalNetworksCreated, uint256 current_tvl) {
        return (totalUsers, totalDeposited, totalWithdrawn, totalCompounded, totalAirdrops, totalNetworksCreated, token.balanceOf(address(this)));
    }

    function topRefInfo() view external returns(uint256 _topReferrerLastDrawAction, uint256 _topReferrerPoolBalance, uint256 _topReferrerCurrentLeader){
        return (topReferrerLastDrawAction, topReferrerPoolBalance, userTopReferrerList[topReferrerPoolCycle][topReferrerPool[0]]);
    }

    function topReferrerInfo() view external returns(address[5] memory addrs, uint256[5] memory deps) {
        for(uint8 i = 0; i < topReferrerPoolBonuses.length; i++) {
            if(topReferrerPool[i] == address(0)) break;

            addrs[i] = topReferrerPool[i];
            deps[i] = userTopReferrerList[topReferrerPoolCycle][topReferrerPool[i]];
        }
    }

    function topDepInfo() view external returns(uint256 _topDepositLastDrawAction, uint256 _topDepositPoolBalance, uint256 _topDepositCurrentLeader){
        return (topDepositLastDrawAction, topDepositPoolBalance, userTopDepositList[topDepositPoolCycle][topDepositPool[0]]);
    }

    function topDepositInfo() view external returns(address[5] memory addrs, uint256[5] memory deps) {
        for(uint8 i = 0; i < topDepositBonuses.length; i++) {
            if(topDepositPool[i] == address(0)) break;  
            addrs[i] = topDepositPool[i];
            deps[i] = userTopDepositList[topDepositPoolCycle][topDepositPool[i]];
        }
    }

    function transferOwnership(address value) external onlyOwner {
        owner = value;
    }
    
    function renounceOwnership() public onlyOwner {
        owner = address(0);
    }

    function enableAirdrop(bool value) external onlyOwner {
        airdropEnabled = value;
    }

    /** External contract related functions. **/
    TNS_Partnership public partnershipContract;
    ITimerPool timer;
    
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

            _drawPool();
            _drawTopReferrerPool();
            drawLastDepositWinner();      
    }
    function checkDrawEvents() external view initialized returns(bool){
        require(msg.sender == autoCompoundExecutor, "Function can only be triggered by the autoCompoundExecutor.");
        if(topDepositLastDrawAction.add(eventTimeStep) > block.timestamp) { return true;}
        if(topReferrerLastDrawAction.add(eventTimeStep) > block.timestamp) {return true;}
        if(lasDepositJackpotEnabled && lastDepositStartTime.add(lastDepositTimeStep) > block.timestamp && potentialLastDepositWinner != address(0)){return true;} 
        return false;
    }

     
    function enableAutoCompound(bool value) external onlyOwner {
        require(contractInitialized, "Contract not yet Started.");
        autoCompoundEnabled = value; //make sure when enabling this feature, autoCompoundExecutor is already set.
    }  
    
    function updateAutoCompoundContract(address value) external onlyOwner {
        require(isContract(value));	
        autoCompoundExecutor = value; //TheNetworkSocietyAutoCompound Contract.
    }
    
    function enablePartnership(bool value) external onlyOwner {
        require(contractInitialized, "Contract not yet Started.");
        partnershipEnabled = value; //make sure when enabling this feature, partnershipAddress is already set.
    }
    
    function setContractAddress(address _partnershipContract) public onlyOwner {
        partnershipContract = TNS_Partnership(_partnershipContract); //TheNetworkPartnership Contract.
    }
    
    function enableLastDepositJackpot(bool value) external onlyOwner {
        require(contractInitialized, "Contract not yet Started.");
        lasDepositJackpotEnabled = value; //make sure when enabling this feature, timer is already set.
    }

    function setJackpotAddress(ITimerPool _timer) public onlyOwner {
        timer = _timer; //TheNetworkJackpot Contract
    }
}

interface ITimerPool {
    function update(uint256 _amount, uint256 _time, address _user) external;
} 

interface TNS_Partnership {
    function getPartnershipBonus(address adr) external view returns(uint256 refBonus, uint256 maxCap);
}