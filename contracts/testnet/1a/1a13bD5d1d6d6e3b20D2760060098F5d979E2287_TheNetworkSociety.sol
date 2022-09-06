/** 
    The Network Society Project, a suistainable way of earning BUSD.

    Variable Daily Yield starts at 1% up to 3%:
    - Compound action every 24 hours will give the investor an additional 0.1% for their current yield which can increase up to 3%
        - Compound is not mandatory, but compounding will increase the investors daily yield.
        - There is a 2% sustainability tax every compound in which that 2% will stay in the contract.
    - Every withdraw/sell action, will have a 0.5% deduction to the current user yield that will start at 1.6%.
        - users current daily yield is between 1% to 1.5%, Then when the user sell/withdraw their dividends the daily yield will go back to 1%
        - users current daily yield is 1.6% and above, then yield will decrease 0.5% (i.e user current yield is 3%, after sell/withdraw yield will decrease to 2.5%)
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
    * Every sell/withdraw the compound count will be set back to 0.  

    4% Referral Bonus:
    - 2% goes to the Referrer and be added to the users real deposit.
    - 2% goes to the Referee and be added to the users real deposit.

    Max reward accumulation of 48 Hours.
    - If no action is done within 48 hours, reward accumulation will stop and will only reset if a deposit, withdraw or compound is done.
    
    Daily Top Investors and Daily Top Referrer:
    - 5% of each deposit will be put into the rewards pool of each event, which is capped to 1000 ether per round.
    - event runs every 24 hours.
    - 5 winners for reach pool will share the pool 1st place 30%, 2nd place 25%, 3rd place 20%, 4th place 15%, 5th place 10%. 
    - Reward goes directly to user as direct deposit instead of making it withdrawable/claimable.
      I.E Rewards Distribution is max pool size is reached:
      1st place: 300 ether
      2nd place: 250 ether
      3rd place: 200 ether
      4th place: 150 ether
      5th place: 100 ether

    Last Deposit Rewards:
    - 10% of each deposit will be put into the rewards pool for each event, which is capped to 2000 ether per round.
    - If there is no new deposit after the last deposit after 2 hours, the last deposit address will win the jackpot which is capped to 2000 ether per round.
    
    Auto Compound Feature:
    - Users will deposit the current average gas fee per compound.
    - Users will have an option to disable it during the cycle and will be allowed to withdraw the remaining deposited BNB.
    - Enabled auto-compound should finish the cycle, users will not be able to add days in between.
    - Users will need to trigger disable and withdraw and and do enable and deposit BNB again to re-enabled the auto-compound feature.

    Network and Individual Airdrop.
    - Users can airdrop invested addresses which will go directly as users direct deposit instead of making it withdrawable/claimable.
    - Network Leaders can airdrop x amount of token to their members. amount(less airdrop tax) * no. of network members.  
**/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TheNetworkSociety is Context, Ownable , ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMath for uint8;

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
    bool private airdropEnabled;
    bool private autoCompoundEnabled;
    bool private contractInitialized;
    
    //addresses
    address public autoCompoundExecutor;

    address private development;
    address private project;
    address private marketing;

    ERC20 public token = ERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); //0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56

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

    constructor(address dvt, address prj, address market) {
        require(!Address.isContract(dvt) &&!Address.isContract(prj) && !Address.isContract(market));	
        development = dvt;
        project = prj;
        marketing = market;
    }

    function initializeContract() external onlyOwner {
        require(!contractInitialized);
        contractInitialized = true;
        topDepositLastDrawAction = block.timestamp;
        topReferrerLastDrawAction = block.timestamp;    
    }

    modifier initialized {
        require(contractInitialized, "Contract not yet Started.");
        _;
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
        require(users[_addr].sponsor != address(0) || _addr == owner(), "No Network Sponsor.");
        require(_amount >= depositMinimum, "Mininum investment not met.");
        require(users[_addr].totalDirectDeposits <= depositMaximum, "Maximum investment reached.");

        token.transferFrom(address(msg.sender), address(this), _amount);

        if(users[_addr].totalDepositAmount == 0) {
            users[_addr].userYieldPercentage = baseYieldPercent; //new users will have a default yield of 1%
            totalUsers++;
        }

        uint256 amountToCompound = this.payoutToCompound(msg.sender);
        if(amountToCompound > 0 && users[_addr].totalDepositAmount.add(_amount) < this.maxCompoundOf(users[_addr].totalDirectDeposits)) {
            
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
            if(users[users[_addr].sponsor].totalDepositAmount.add(refBonus) > this.maxCompoundOf(users[users[_addr].sponsor].totalDirectDeposits)) {
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

        if(sponsor == address(0) || sponsor == owner()) return; //initial sponsor address will be excluded from the event.

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
        if(_addr == address(0)) return;

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
        else if(users[msg.sender].userYieldPercentage > 15) {
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
            for(uint256 i = 0; i < networks[userNetworkInfo[_sponsor].id].members.length; i++) {
                if(networks[userNetworkInfo[_sponsor].id].members[i] == _addr){
                    memberExists = true;
                }
            }

            if(!memberExists) {
                Network storage network = networks[userNetworkInfo[_sponsor].id];
                network.members.push(_addr);
                userNetworks[_addr].push(NetworkInfo(userNetworkInfo[_sponsor].id, true));
            }
            emit Sponsor(_addr, _sponsor);
            users[_sponsor].networkInvites++; //record total referral of network upline
        }
    }

    function checkSponsorValid(address _addr, address _sponsor) external view returns (bool isValid) {	
        if(users[_addr].sponsor == address(0) && _sponsor != _addr && _addr != owner() && (users[_sponsor].checkpoint > 0 || _sponsor == owner())) {
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
        if(users[_addr].userCompoundCount <= daysCount[0]) {
            withdrawTax = varTaxes[4]; 
        }
        else if(users[_addr].userCompoundCount > daysCount[0] 
        && users[_addr].userCompoundCount <= daysCount[1]) {
            withdrawTax = varTaxes[3]; 
        }
        else if(users[_addr].userCompoundCount > daysCount[1] 
        && users[_addr].userCompoundCount <= daysCount[2]) { 
            withdrawTax = varTaxes[2]; 
        }
        else if(users[_addr].userCompoundCount > daysCount[2] 
        && users[_addr].userCompoundCount <= daysCount[3]) { 
            withdrawTax = varTaxes[1]; 
        }
        else if(users[_addr].userCompoundCount > daysCount[3]) { 
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
            if(excludeOwner == true && _to == networks[networkId].owner) {
                continue;
            }

            if(users[_to].totalDepositAmount.add(_amount) >= this.maxCompoundOf(users[_to].totalDirectDeposits)) {
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

    function userInfo(address _addr) view external returns(address sponsor, uint256 checkpoint, uint256 totalDirectDeposits, uint256 totalDepositAmount, uint256 payouts, NetworkInfo[] memory member_of_networks, uint256 userYieldPercentage) {
        return (users[_addr].sponsor, users[_addr].checkpoint, users[_addr].totalDirectDeposits, users[_addr].totalDepositAmount, users[_addr].totalDepositPayouts, userNetworks[_addr], users[_addr].userYieldPercentage);
    }

    function userInfo2(address _addr) view external returns(uint256 directBonus, uint256 topDepositBonus, uint256 topReferrerBonus, uint256 networkInvites, uint256 totalNetworkInvitesDeposit, uint256 incomeCompounded) {
        return (userBonusStatistics[_addr].directBonus, userBonusStatistics[_addr].topDepositBonus, userBonusStatistics[_addr].topReferrerBonus, users[_addr].networkInvites, users[_addr].totalNetworkInvitesDeposit, users[_addr].incomeCompounded);
    }

    function userInfo3(address _addr) view external returns(uint256 lastAirdrop, uint256 airdropSent, uint256 airdropReceived, uint256 sponsor_network, bool sponsor_network_exists) {
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

    //External functions. 
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

    function checkDrawEvents() external view initialized returns(bool) {
        require(msg.sender == autoCompoundExecutor, "Function can only be triggered by the autoCompoundExecutor.");
        if(topDepositLastDrawAction.add(topDepositTimeStep) > block.timestamp) return true;
        if(topReferrerLastDrawAction.add(topReferrerTimeStep) > block.timestamp) return true;
        if(lasDepositJackpotEnabled && lastDepositStartTime.add(lastDepositTimeStep) > block.timestamp && potentialLastDepositWinner != address(0)) return true;
        return false;
    }
    
    function updateAutoCompoundContract(address value) external onlyOwner {
        require(Address.isContract(value));	
        autoCompoundExecutor = value; //The Auto Compound Contract.
    }
     
    function enableAutoCompound(bool value) external onlyOwner {
        require(contractInitialized, "Contract not yet Started.");
        autoCompoundEnabled = value; //Make sure when enabling this feature, autoCompoundExecutor is already set.
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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