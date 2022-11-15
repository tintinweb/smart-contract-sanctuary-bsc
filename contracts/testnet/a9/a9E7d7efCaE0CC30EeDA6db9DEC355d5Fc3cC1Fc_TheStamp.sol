// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TheStamp is Context, Ownable {
    using SafeMath for uint256;

    //user record library
    struct User {
        address networkSponsor; //network sponsor
        uint256 totalNetworkInvites; //invite count
        uint256 totalDepositAmount; //invested + compounded
        uint256 totalDepositPayouts; //payouts
        uint256 totalDirectDeposits; //real deposits
        uint256 totalIncomeCompounded; //compounded
        uint256 totalNetworkInvitesDeposit; //total invested by invites
        uint256 yieldPercentage; //user personal yield.
        uint256 compoundCount; //user compound count record
        uint256 lastAction; //user action checkpoint
    }

    //bonus record library, statistics records only
    struct UserBonus {
        uint256 inviteBonus; //referral / referee bonus
        uint256 lastDepositBonus; //last deposit bonus if address has won
        uint256 topDepositBonus; //top deposit bonus if address has won
    }

    //networks record library
    struct Network {
        bool hasInvites; //if exist or not, if true, then use current id, else create a new one and designate an id.
        uint256 id; //network id 
        address owner; //network owner address
        uint256 createTime; //network creation timestamp
        address[] members; //network invites address
    }
    
    //Address Mapping Details
    mapping(address => User) private users; //users investment details
    mapping(address => Network) private networks; //users network details
    mapping(address => UserBonus) private usersBonus; //users bonus details

    //Events Mapping Details
    mapping(uint256 => address) private topDepositPool;
    mapping(uint256 => address) private topReferrerPool;
    
    //variable 
    uint256 private constant tax = 1000;
    uint256 private constant compoundTax = 300; //3% stays in the contract

    uint256 private constant userMaxPayout = 35000; //350% max profit
    uint256 private constant maxCompoundMultiplier = 5; //5x of real investment
    
    uint256 private constant eventPercent = 100; //1% of each deposit
    uint256 private constant invitePercent = 500; //5% for 2.5% referrer and 2.5% referee.
    uint256 private constant decreasePercent = 50; //0.5% yield decrease per withdraw
    uint256 private constant maxYieldPercent = 350; //3.5%
    uint256 private constant baseYieldPercent = 150; //1.5%
    uint256 private constant dividerPercent = 10000; //10,000 for more precise computation.

    uint256 private constant depositMinimum = 20 ether;  
    uint256 private constant maxRewards = 5000 ether;

    //time steps
    uint256 private timeStep = 1 days;
    uint256 private eventTimeStep = 1 days;
    uint256 private cutOffTimeStep = 2 days;

    uint256 private lastDepositTimeStep = 6 hours;
    uint256 private lastBuyCurrentRound = 1;
    uint256 private lastDepositPoolBalance;
    uint256 private lastDepositLastDrawAction;
    address private lastDepositPotentialWinner;

    address private previousPoolWinner;
    uint256 private previousPoolRewards;

    uint256 private topDepositTimeStep = 2 days;
    uint256 private topDepositCurrentRound = 1;
    uint256 private topDepositPoolBalance;
    uint256 private topDepositCurrentAmount;
    address private topDepositPotentialWinner;
    uint256 private topDepositLastDrawAction;

    address private previousTopDepositWinner;
    uint256 private previousTopDepositRewards;

    //project statistics
    uint256 private totalInvestors; //total users invested. 
    uint256 private totalDeposited; //total amount deposited into the protocol
    uint256 private totalWithdrawn; //total amount withdrawn in the protocol
    uint256 private totalCompounded; //total amount compounded only from investors.
    uint256 private totalNetworksCreated; //total number of networks created in the protocol.
    uint256 private contractLaunchTime; //contract launch timestamp.

    //arrays
    uint256[] private daysCount = [7, 14, 21, 28]; //7 days, 14 days, 21 days, 28 days
    uint256[] private variableTax = [1000, 800, 600, 400, 200]; //10%, 8%, 6%, 4%, 2%

    //protocol feature enablers
    bool private initialized;
    bool private autoCompoundEnabled;

    //event feature enabler
    bool private topDepositEnabled;
    bool private lastDepositEnabled;
    
    address private networkLeader; //initial network leader set as per contract initialization.
    address private autoCompoundExecutorContract; //auto compound contract address
    
    //project addresses
    address private immutable development; //development address

    ERC20 private token = ERC20(0xc46CCBE42Afdf64cc4DA7e56DCd60eE9bF1B743B); //0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56

    //user events
    event AutoCompound(address indexed addr, uint256 timestamp);
    event Deposit(address indexed addr, uint256 amount, uint256 timestamp);
    event Withdraw(address indexed addr, uint256 amount, uint256 timestamp);
	event Compound(address indexed addr, uint256 amount, uint256 timestamp);
    event MaxPayout(address indexed addr, uint256 amount, uint256 timestamp);
    event MaxCompound(address indexed addr, uint256 amount, uint256 timestamp);
    event Sponsor(address indexed addr, address indexed sponsor, uint256 timestamp);

    //payout events
    event RefereePayout(address indexed addr, address indexed from, uint256 amount, uint256 timestamp);
    event ReferralPayout(address indexed addr, address indexed from, uint256 amount, uint256 timestamp);
    event LastBuyPayout(uint256 indexed round, address indexed addr, uint256 amount, uint256 timestamp);
    event TopDepositPayout(uint256 indexed round, address indexed addr, uint256 amount, uint256 timestamp);

    //NOTE: @dev to change seconds to days and hours constants before deploying to mainnet and remove this test function before deploying to mainnet.
    function updateTimeStampForTesting(uint256 cutOffStep, uint256 lastDepositStep, uint256 eventTime, uint256 dayStep) public onlyOwner {
        cutOffTimeStep      = cutOffStep;    
        lastDepositTimeStep = lastDepositStep;
        eventTimeStep       = eventTime;
        timeStep            = dayStep;
    }

    constructor(address ldr, address dvt) {
        require(!Address.isContract(ldr) && !Address.isContract(dvt), "Wallet Address Only.");
        networkLeader  = ldr;
        development    = dvt;
    }

    modifier isInitialized() {
        require(initialized, "Contract not initialized.");
        _;
    }
    
    modifier onlyExecutor() {
        require(autoCompoundExecutorContract == msg.sender, "Function can only be triggered by the autoCompoundExecutorContract.");
        _;
    }
    
    modifier onlyNetworkLeader() {
        require(networkLeader == msg.sender, "Function can only be triggered by the protocol's network leader.");
        _;
    }

    //normal invest function. contract will set the initial sponsor if there is no referral address used or the sponsor address is not invested. This is to follow the business model of the contract.
    function invest(address sponsor, uint256 amount) public isInitialized {
        address addr = msg.sender;
        sponsor = validateNetworkSponsor(sponsor);
		setupSponsorshipDetails(addr, sponsor);
        deposit(addr, amount);
    }

    //setup sponsor for the investor.
    function setupSponsorshipDetails(address addr, address sponsor) private {
        if(isValidSponsorAddress(addr, sponsor)) {
            Network storage network = networks[sponsor];
            users[addr].networkSponsor = sponsor;

            //if sponsor doesn't have existing network, create one for the address.
            if(!networks[sponsor].hasInvites) {
                uint256 networkId  = totalNetworksCreated++;
                network.id         = networkId;
                network.owner      = sponsor;
                network.hasInvites = true;
                network.createTime = block.timestamp;
            }

            // if total direct deposit is 0, means user not yet invest, add address to sponsors network members list. 
            // no need to check network member list to avoid high gas fee.
            if(users[addr].totalDirectDeposits <= 0) {
                network.members.push(addr);
                users[sponsor].totalNetworkInvites++; //only add invites for new investments.
            }
            emit Sponsor(addr, sponsor, block.timestamp); //record total invites of network leader
        }
    }

    //validate sponsorship.
    function isValidSponsorAddress(address addr, address sponsor) view public returns (bool isValidSponsor) {	
        isValidSponsor = ((users[sponsor].lastAction > 0 && users[addr].networkSponsor == address(0) 
        && sponsor != addr && addr != networkLeader) 
        || (sponsor == networkLeader)) ? true : false;
    }

    //user's invest function.
    function deposit(address addr, uint256 amount) private isInitialized {
        User storage user = users[addr];
        require(user.networkSponsor != address(0) || addr == networkLeader, "Invalid network sponsor.");
        require(amount >= depositMinimum, "Mininum deposit not reached or User's maximum investment reached.");

        token.transferFrom(address(addr), address(this), amount);

        if(user.totalDepositAmount <= 0) { 
            user.yieldPercentage = baseYieldPercent; // new users will have a default yield of 1%
            totalInvestors++; // only count new deposits
        }

        compound(addr); //compound existing user's accumulated yield before new deposit.
        uint256 amountPostTax = amount.sub(payTax(amount));
        user.lastAction = block.timestamp; // update action timestamp
        user.totalDirectDeposits += amountPostTax; // invested
        user.totalDepositAmount  += amountPostTax; // invested + compounded
        totalDeposited += amountPostTax; // update protocol's total deposits.
        emit Deposit(addr, amountPostTax, block.timestamp);

        networkInvitePayout(addr, amount);

        // execute events, user's event entry if qualified.
        drawLastDepositWinner();
        poolLastDeposit(addr, amount);    
      
        drawTopDepositWinner();
        poolTopDeposit(addr, amount);
    }

    //users maximum compound.
    function maxCompoundOf(uint256 amount) pure private returns(uint256) {
        return amount.mul(maxCompoundMultiplier);
    }
    
    //user's final amount available for compound.
    function compoundAmountOf(address addr, uint256 value) view private returns(uint256 maxCompound, uint256 amount) { 
        User storage user = users[addr];
        maxCompound = maxCompoundOf(users[addr].totalDirectDeposits);
        amount = value; 
        if(user.totalDepositAmount >= maxCompound) amount = 0; //avoid reverts, but if amount = 0, user already exceeded x5 of total deposit.
        if(user.totalDepositAmount.add(value) >= maxCompound) amount = maxCompound.sub(user.totalDepositAmount);      
    }

    //compound user's current yield.
    function compound(address addr) public isInitialized {   
        User storage user = users[addr];
        (, , uint256 payoutPostTax) = getUserDividends(addr, false);
        (uint256 maxCompound, uint256 amount) = compoundAmountOf(addr, payoutPostTax);

        if(amount > 0 && user.totalDepositAmount < maxCompound){
            if(block.timestamp.sub(user.lastAction) >= timeStep) {
                if(user.yieldPercentage < maxYieldPercent) user.yieldPercentage += 10;
                user.compoundCount++;
            }
              
            user.lastAction = block.timestamp;
            user.totalDepositAmount    += amount;
            user.totalIncomeCompounded += amount;   
            totalCompounded += amount;
            emit Compound(addr, amount, block.timestamp);
            
            //if user reached max compound after last compound. emit MaxCompound event.
            if(user.totalDepositAmount >= maxCompound) {
                emit MaxCompound(addr, user.totalDepositAmount, block.timestamp);
            }
        }
	}

    //Network Invite Payout
    function networkInvitePayout(address addr, uint256 amount) public isInitialized {   
        User storage user = users[addr];
        address sponsor = user.networkSponsor;
        User storage networkSponsor = users[sponsor];

        if(user.networkSponsor != address(0)) {
            uint256 inviteBonus  = amount.mul(invitePercent).div(dividerPercent).div(2);
            
            // referee
            usersBonus[addr].inviteBonus += inviteBonus; //statistics record.
            token.transfer(addr, inviteBonus); 

            // referrer
            usersBonus[sponsor].inviteBonus += inviteBonus; //statistics record.
            token.transfer(sponsor, inviteBonus); 
            
            //record total amount of invites the network leader has.
            networkSponsor.totalNetworkInvitesDeposit += amount;

            emit RefereePayout(addr, address(this), inviteBonus, block.timestamp);
            emit ReferralPayout(user.networkSponsor, address(this), inviteBonus, block.timestamp);  
        }
	}

    //withdraw user's accumulated yield.
    function withdraw() public isInitialized {
        address addr = msg.sender;        
        User storage user = users[addr];
        
        (uint256 maxPayout, , uint256 payoutPostTax) = getUserDividends(addr, true);

        if(payoutPostTax > 0 && user.totalDepositPayouts < maxPayout){ // avoid reverts
            //yieldPercentage will be deducted 0.5% every withdraw, starts at 2% else, if less than 2% yield it goes back to 1%
            if(user.yieldPercentage >= baseYieldPercent || user.yieldPercentage <= 200) {
                user.yieldPercentage = baseYieldPercent;        
            }
            else if(user.yieldPercentage > 200) { // 0.5% decrease starts at 2% user yield.
                user.yieldPercentage -= decreasePercent;    
            }

            if(token.balanceOf(address(this)) < payoutPostTax) payoutPostTax = token.balanceOf(address(this));

            user.compoundCount = 0; //user consecutive compound count will reset when withdraw is triggered
            user.lastAction = block.timestamp;
            user.totalDepositPayouts += payoutPostTax;
            totalWithdrawn += payoutPostTax;
            token.transfer(addr, payoutPostTax);
            emit Withdraw(addr, payoutPostTax, block.timestamp);   
        
            // if user reached max payout after last withdraw. emit MaxPayout event.
            if(user.totalDepositPayouts >= maxPayout) {
                emit MaxPayout(addr, user.totalDepositPayouts, block.timestamp);
            }
        }
    }

    function poolLastDeposit(address userAddress, uint256 amount) private {
        if(!lastDepositEnabled) return;

        uint256 poolShare = amount.mul(eventPercent).div(dividerPercent);

        lastDepositPoolBalance = lastDepositPoolBalance.add(poolShare) > maxRewards ? 
        lastDepositPoolBalance.add(maxRewards.sub(lastDepositPoolBalance)) : lastDepositPoolBalance.add(poolShare);
        lastDepositPotentialWinner = userAddress;
        lastDepositLastDrawAction  = block.timestamp;
    }  

    function drawLastDepositWinner() public {
        if(lastDepositEnabled && block.timestamp.sub(lastDepositLastDrawAction) >= lastDepositTimeStep && lastDepositPotentialWinner != address(0)) {
            
            uint256 projStakeFee = lastDepositPoolBalance.mul(tax).div(dividerPercent); 
            uint256 adjustedAmt  = lastDepositPoolBalance.sub(projStakeFee);
            
            token.transfer(lastDepositPotentialWinner, adjustedAmt); 

            emit LastBuyPayout(lastBuyCurrentRound, lastDepositPotentialWinner, adjustedAmt, block.timestamp);
            
            previousPoolWinner         = lastDepositPotentialWinner;
            previousPoolRewards        = adjustedAmt;
            lastDepositPoolBalance     = 0;
            lastDepositPotentialWinner = address(0);
            lastDepositLastDrawAction  = block.timestamp; 
            lastBuyCurrentRound++;
        }
    }

    function poolTopDeposit(address userAddress, uint256 amount) private {
        if(!topDepositEnabled) return;

        if(amount > topDepositCurrentAmount){
            topDepositCurrentAmount = amount;
            topDepositPoolBalance = topDepositCurrentAmount.mul(tax).div(dividerPercent);
            topDepositPotentialWinner = userAddress;
        }
    } 

    function drawTopDepositWinner() private {
        if(topDepositEnabled && block.timestamp.sub(topDepositLastDrawAction) >= topDepositTimeStep) {
            
            uint256 projFee = topDepositPoolBalance.mul(tax).div(dividerPercent); 
            uint256 adjustedAmt  = topDepositPoolBalance.sub(projFee);
            
            token.transfer(topDepositPotentialWinner, adjustedAmt); 

            emit TopDepositPayout(topDepositCurrentRound, topDepositPotentialWinner, adjustedAmt, block.timestamp);

            previousTopDepositWinner  = topDepositPotentialWinner;
            previousTopDepositRewards = adjustedAmt;
            topDepositPotentialWinner = address(0);
            topDepositCurrentAmount   = 0;
            topDepositPoolBalance     = 0;
            topDepositLastDrawAction  = block.timestamp;
            topDepositCurrentRound++;
        }
    }

    // user's current payout available.
    function getUserDividends(address addr, bool isClaim) view public returns(uint256 maxPayout, uint256 payout, uint256 payoutPostTax) {
        User storage user = users[addr];
        maxPayout = user.totalDepositAmount.mul(userMaxPayout).div(dividerPercent);
        
        if(user.totalDepositPayouts < maxPayout) {
            uint256 timeElapsed = block.timestamp.sub(user.lastAction) > cutOffTimeStep ? cutOffTimeStep : block.timestamp.sub(user.lastAction);
            payout = (user.totalDepositAmount.mul(user.yieldPercentage).div(dividerPercent)).mul(timeElapsed).div(timeStep);
            
            if(user.totalDepositPayouts.add(payout) > maxPayout) payout = maxPayout.sub(user.totalDepositPayouts);

            //isClaim: true = withdraw, false = compound.
            uint256 sustainabilityTax = isClaim ? getVariableWithdrawTax(addr) : compoundTax;
            payoutPostTax = payout.sub(payout.mul(sustainabilityTax).div(dividerPercent));
        }
    }

    // get user's current sustainability tax.
    function getVariableWithdrawTax(address addr) view public returns(uint256 withdrawTax) {
        if(users[addr].compoundCount <= daysCount[0]) { // less than 7 days of continues compounding.
            withdrawTax = variableTax[0]; // 10% tax.
        }
        else if(users[addr].compoundCount > daysCount[0] 
        && users[addr].compoundCount <= daysCount[1]) { // between 7 to 14 days of continues compounding.
            withdrawTax = variableTax[1]; // 8% tax.
        }
        else if(users[addr].compoundCount > daysCount[1] 
        && users[addr].compoundCount <= daysCount[2]) { // between 14 to 21 days of continues compounding.
            withdrawTax = variableTax[2]; // 6% tax.
        }
        else if(users[addr].compoundCount > daysCount[2] 
        && users[addr].compoundCount <= daysCount[3]) { //between 21 to 28 days of continues compounding. 
            withdrawTax = variableTax[3]; // 4% tax.
        }
        else if(users[addr].compoundCount > daysCount[3]) { //above 28 days of continues compounding.
            withdrawTax = variableTax[4]; // 2% tax.
        }
    }
    
    // validate network address, invite-only format.
    function validateNetworkSponsor(address addressForChecking) view private returns(address sponsor) {
        sponsor = addressForChecking == address(0) || addressForChecking == address(0x000000000000000000000000000000000000dEaD) 
        || users[addressForChecking].totalDirectDeposits <= 0 ? networkLeader : addressForChecking;
    }

    // setup and initialized contract start. invest from protocols initial network leader.
    function initializeAndSetupNetwork(uint256 amount) public onlyNetworkLeader {
        require(!initialized, "Contract already initialized.");
        initialized        = true;
        lastDepositEnabled = true;
        topDepositEnabled  = true;
        contractLaunchTime        = block.timestamp;
        lastDepositLastDrawAction = block.timestamp;
        topDepositLastDrawAction  = block.timestamp;
        deposit(networkLeader, amount);
    }
    
    function payTax(uint256 amount) private returns(uint256) {
        uint256 dvtTax = amount.mul(tax).div(dividerPercent);
        token.transfer(development, dvtTax);
        return dvtTax;
    }

    // current timestamp.
    function currentTime() view external returns(uint256) {
        return block.timestamp;
    }

    // current contract balance.
    function getBalance() view external returns(uint256) {
         return token.balanceOf(address(this));
    }

    // user's payout information.
    function userCurrentInvestmentInfo(address addr) view external returns(uint256 maxPayout, uint256 maxCompound, uint256 payout, uint256 payoutWithWithdrawTax, uint256 withdrawalTax, uint256 amountForCompound, uint256 compoundingTax, uint256 compoundCount) {
        compoundingTax = compoundTax;
        compoundCount = users[addr].compoundCount;
        withdrawalTax = getVariableWithdrawTax(addr);
        (maxPayout, payout, payoutWithWithdrawTax) = getUserDividends(addr, true);
        (maxCompound, amountForCompound) = compoundAmountOf(addr, payout.sub(payout.mul(compoundTax).div(dividerPercent)));
    }

    // user's primary information.
    function userDetailsInfo(address addr) view external returns(address networkSponsor, uint256 lastAction, uint256 totalDirectDeposits, uint256 totalDepositAmount, uint256 totalIncomeCompounded, uint256 totalDepositPayouts, uint256 yieldPercentage) {
        return (users[addr].networkSponsor, users[addr].lastAction, users[addr].totalDirectDeposits, users[addr].totalDepositAmount, users[addr].totalIncomeCompounded, users[addr].totalDepositPayouts, users[addr].yieldPercentage);
    }

    // user's bonus information.
    function userBonusInfo(address addr) view external returns(uint256 inviteBonus, uint256 lastDepositBonus, uint256 topDepositBonus) {
        return (usersBonus[addr].inviteBonus, usersBonus[addr].lastDepositBonus, usersBonus[addr].topDepositBonus);
    }
    
    // user's network member info
    function userNetworkMembersInfo(address addr) view external returns(uint256 networkId, address networkOwner, uint256 dateCreated, address[] memory networkMembers, uint256 totalNetworkInvites, uint256 totalNetworkInvitesDeposit) {
        return (networks[addr].id, networks[addr].owner, networks[addr].createTime, networks[addr].members, users[addr].totalNetworkInvites, users[addr].totalNetworkInvitesDeposit);
    }
    
    // user's network sponsor member info
    function userNetworkSponsorMembersInfo(address addr) view external returns(uint256 networkId, address networkOwner, uint256 dateCreated, address[] memory networkMembers, uint256 totalNetworkInvites, uint256 totalNetworkInvitesDeposit) {
        return (networks[users[addr].networkSponsor].id, networks[users[addr].networkSponsor].owner, networks[users[addr].networkSponsor].createTime, networks[users[addr].networkSponsor].members, users[users[addr].networkSponsor].totalNetworkInvites, users[users[addr].networkSponsor].totalNetworkInvitesDeposit);
    }

    // contract information
    function contractInfo() view external returns(uint256 networkInvestors, uint256 networkDeposits, uint256 totalWithdrawnAmount, uint256 totalCompoundedAmount, uint256 networksCreated, uint256 launchTime) {
        return (totalInvestors, totalDeposited, totalWithdrawn, totalCompounded, totalNetworksCreated, contractLaunchTime);
    }

    // get all contracts enabled features
    function getEnabledFeatures() view external returns(bool isContractInitialized, bool isTopDepositEnabled, bool isLastDepositEnabled, bool isAutoCompoundEnabled) {
        isContractInitialized   = initialized; 
        isTopDepositEnabled     = topDepositEnabled;
        isLastDepositEnabled    = lastDepositEnabled;
        isAutoCompoundEnabled   = autoCompoundEnabled;    
    }
    
    function lastDepositInfo() view external returns(uint256 currentRound, uint256 currentBalance, uint256 currentStartTime, uint256 currentStep, address currentPotentialWinner, uint256 previousReward, address previousWinner) {
        currentRound           = lastBuyCurrentRound;
        currentBalance         = lastDepositPoolBalance;
        currentStartTime       = lastDepositLastDrawAction;  
        currentStep            = lastDepositTimeStep;    
        currentPotentialWinner = lastDepositPotentialWinner;
        previousReward         = previousPoolRewards;
        previousWinner         = previousPoolWinner;
    }

    function topDepositInfo() view external returns(uint256 topDepositRound, uint256 topDepositCurrentTopDeposit, address topDepositCurrentPotentialWinner, uint256 topDepositCurrentBalance, uint256 topDepositCurrentStartTime, uint256 topDepositCurrentStep, uint256 topDepositPreviousReward, address topDepositPreviousWinner) {
        topDepositRound                  = topDepositCurrentRound;
        topDepositCurrentTopDeposit      = topDepositCurrentAmount;
        topDepositCurrentPotentialWinner = topDepositPotentialWinner;
        topDepositCurrentBalance         = topDepositPoolBalance;
        topDepositCurrentStartTime       = topDepositLastDrawAction;
        topDepositCurrentStep            = topDepositTimeStep;
        topDepositPreviousReward         = previousTopDepositRewards;
        topDepositPreviousWinner         = previousTopDepositWinner;
    }

    function changeLastDepositEventTime(uint256 step) external onlyOwner {
        require(step >= 1 hours || step <= 1 days, "Time step can only changed to 1 hour up to 24 hours.");
        drawLastDepositWinner();   
        lastDepositTimeStep = timeStep;
    }

    function changeTopDepositEventTime(uint256 step) external onlyOwner {
        require(step >= 1 days || step <= 7 days, "Time step can only changed to 1 day up to 7 days.");
        drawTopDepositWinner();   
        topDepositTimeStep = timeStep;
    }
    
    // enables top deposit feature.
    function switchTopDepositEventStatus() external onlyOwner isInitialized {
        drawTopDepositWinner(); // events will run before value change
        topDepositEnabled = !topDepositEnabled ? true : false;
        if(topDepositEnabled) topDepositLastDrawAction = block.timestamp; //reset the start time everytime feature is enabled.
    }
    
    // enables last deposit feature.
    function switchLastDepositEventStatus() external onlyOwner isInitialized {
        drawLastDepositWinner(); // events will run before value change
        lastDepositEnabled = !lastDepositEnabled ? true : false;
        if(lastDepositEnabled) lastDepositLastDrawAction = block.timestamp; // reset the start time everytime feature is enabled.
    }
    
    function updateNetworkLeader(address addr) external onlyOwner {
        require(!Address.isContract(addr), "Address is a not contract address.");	
        networkLeader = addr; 
    }

    //function for checking user information for auto-compound. 
    function userAutoCompoundInfo(address addr) view external returns(uint256 checkpoint, uint256 totalDepositAmount) {
        User memory user = users[addr];
        return (user.lastAction, user.totalDepositAmount);
    }

    // function call to run the auto-compound feature
    function runAutoCompound(address addr) external onlyExecutor isInitialized {
        require(autoCompoundEnabled, "Auto Compound not Activated.");
        compound(addr); // checks should already be done before this point.
        emit AutoCompound(addr, block.timestamp);
    }
    
    // run event triggers. 
    function runDrawEvents() external onlyExecutor isInitialized { // run draw depending on restrictions
        drawTopDepositWinner();
        drawLastDepositWinner();      
    }

    // check if events can now run.
    function checkDrawEvents() external view returns (bool runEvent) {
        if((topDepositEnabled && block.timestamp.sub(topDepositLastDrawAction) >= eventTimeStep) || (lastDepositEnabled && block.timestamp.sub(lastDepositLastDrawAction) >= lastDepositTimeStep && lastDepositPotentialWinner != address(0))) runEvent = true;
        return runEvent;
    }
    
    // enables the auto-compound feature.
    function enableAutoCompound(bool value) external onlyOwner {
        autoCompoundEnabled = value; // Make sure when enabling this feature, autoCompoundExecutorContract is already set.
    }
    
    // update the auto-compound contract.
    function updateAutoCompoundExecutorContract(address addr) external onlyOwner {
        require(Address.isContract(addr), "Contract Address Only."); // only contract address.	
        autoCompoundExecutorContract = addr; // The Auto Compound Contract.
    }
}

/**     
        The Network Society
        Innovation through combination, a sustainable yield farm.
    
    Features:
    Variable Daily Yield starts at 1% up to 3%:
    - Compound action every 24 hours will give the investor an additional 0.1% for their current yield which can increase up to 3%
        - Compound is not mandatory, but compounding will increase the investors daily yield.
        - There is a 3% sustainability tax every compound in which that 3% will stay in the contract.
        - Deflationary behavior.
    - Every withdraw/sell action, will have a 0.5% deduction to the current user yield that will start at 1.6%.
        - users current daily yield is between 1% to 1.5%, Then when the user sell/withdraw their dividends the daily yield will go back to 1%
        - users current daily yield is 1.6% and above, then yield will decrease 0.5% (i.e user current yield is 3%, after sell/withdraw yield will decrease to 2.5%)
    - User can earn 350% of his including real invested amount. (ie. total deposited amount = 100 ether, max payout = 350 ether)
    - Minimum Deposit of 50 ether
    
    - Variable Withdraw Tax:
        Users will have less withdraw tax depending on their consecutive compound count/days
        Default Sustainability Tax : 10% 
        Compound Count is within  1 to 7 Days: 10%
        Compound Count is within 7 to 14 Days: 8%
        Compound Count is within 14 to 21 Days: 6%
        Compound Count is within 21 to 28 Days: 4%
        Compound Count is 28 Days and higher: 2%
    * Every sell/withdraw the compound count will be set back to 0.  

    2% Referral Bonus and 2% Referee Cashback Bonus:
    - 2% goes to the Referrer and Referee's real deposit investments.
    - Referrals will be "auto re-invested" to ensure the stability and sustainability of the contract and also to increase investors potential profit over time.

    Network Sponsor Setup:
    - If investor used a referral link that is not part in to the network, the protocol will automatically setup a network leader on the investor behalf.
    - Referral links will only work if the network invite address is already part in the network society.
    - Once successfully deposited in the protocol, investors can start creating their own network by inviting new investors.

    Max reward accumulation of 48 Hours.
    - If no action is done within 48 hours, reward accumulation will stop and will only reset if a deposit, withdraw or compound is done.
    - This is to avoid investors from accumulating for a long period of time and suddenly sell everything at once.
    
    Daily Top Investors:
    - 5% of each deposit will be put into the rewards pool.
    - Rewards are capped to 2000 ether per round for each event respectively.
    
    - Reward goes directly to winner's wallet address.
    - Events run every 1 to 7 days.

      *Rewards are subject for 10% sustainability tax.

        - Both features will run at launch and after a day, at the 2nd day, top referrer will be turned off, and top deposit will continue to run, on the third day,
        top referrer will be turned on and top deposit will be turned off, and will continue with this cycle moving forward.

    Daily Top Investors:
    - The winning address will be awared with 10% of his deposited amount. 
    - Reward will be directly sent to the winning address after the event draw. 
    - Rewards are subject for 10% sustainability tax.

    Last Deposit Rewards:
    - 1% of each deposit will be put into the rewards pool. 
    - Last deposited address will win the pot when no deposit was done after 6 hours of last deposit. 
    - The pot for each round has a 1,000 BUSD limit. 
    - Rewards are subject for 10% sustainability tax.
    
    Auto Compound Feature:
    - Users will deposit the current average gas fee per compound.
    - Users will have an option to disable it during the cycle and will be allowed to withdraw the remaining deposited BNB.
    - Enabled auto-compound should finish the cycle, users will not be able to add days in between.
    - Users will need to trigger disable and withdraw and and do enable and deposit BNB again to re-enabled the auto-compound feature.
 
**/

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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