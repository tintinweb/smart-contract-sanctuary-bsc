/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

/*
 *          .      .                                                 .                  
 *               .                                                                      
 *            .;;..         .':::::::::::::;,..    .'::;..   . .':::;'. .               
 *           'xKXk;.      . .oXXXXXXXXXXXXXXKOl'.  .oXXKc.    .l0XX0o.                  
 *          .dXXXXk, .      .;dddddddddddddkKXXk,  .oXXKc.  .:kXXKx,.  .                
 *       . .oKXXXXXx'              .  .    .oKXXo. .oXXKc..'dKXXOc. .    .              
 *     .. .lKXXkxKXXx. .                   .lKXXo. .oXXKd;lOXXKo'.      .               
 *       .cKXXk'.oKXKd.      .cloollllllolox0XXO;. .oXXXXXXXXKl. .                      
 *   .  .c0XXk,  .dXXKo. .  .lXXXXXXXXXXXXXXX0d,.. .oXXXOxkKXKk:.                       
 *     .:0XXO;.   'xXXKl.   .oXXKxcccccco0XXKc.  . .oXXKc..cOXXKd,.                     
 *     ;OXX0:.     ,kXX0c.  .oXXKc      .:0XXO,    .oXXKc. .'o0XX0l.                    
 *    ,kXX0c.       ,OXX0:. .oXXKc.  ..  .c0XXk,   .oXXKc. . .;xKXKk;.                  
 *   .cxxxc.        .;xxko. .:kkx;.       .:xxxl.  .:xxx;. .   .cxxxd;. .               
 *   ......          ...... ......       . ......   .....       .......                 
 *               .             .             ..                                         
 * 
 * ARK VAULT
 *
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.16;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXPair {
    function sync() external;
}

interface ILEGACY {
    function getCwr(address investor) external view returns (uint256);
    function getLevels(address investor) external view returns (uint256);
}

interface IBOND {
    function unstake(address investor, uint256 amount) external;
    function stake(address investor, uint256 amount) external;
    function claimRewardsFor(address investor) external;
    function distributeRewards() external;
    function addToRewardsPool(uint256 busdAmount) external;
    function sendRewards(uint256 busdAmount) external;
    function getBondBalance(address investor) external view returns(uint256);
    function checkAvailableRewards(address investor) external view returns(uint256);
}

interface ICCVRF {
    function requestRandomness(uint256 requestID, uint256 howManyNumbers) external payable;
}

interface ISWAP {
    function vaultSellForBUSD(address investor, uint256 amount) external;
    function vaultAddLiquidityWithArk(address investor, uint256 amount) external;
}

contract ARK_VAULT {
    address private constant TOKEN = 0x111120a4cFacF4C78e0D6729274fD5A5AE2B1111;
    IBEP20 public constant ARK = IBEP20(TOKEN);
    IDEXPair private constant ARK_POOL = IDEXPair(0x4004D3856499d947564521511dCD28e1155C460b);
    IBEP20 public constant BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    ICCVRF public constant VRF = ICCVRF(0xC0de0aB6E25cc34FB26dE4617313ca559f78C0dE); 
    address public constant CEO = 0xdf0048DF98A749ED36553788B4b449eA7a7BAA88;
    uint256 public constant MULTIPLIER = 10**18;
    IBOND public bond;
    ILEGACY public legacy;
    ISWAP public swap;
    mapping(address => bool) public isArk;

    uint256 public totalAccounts;

    mapping(address => uint256) public principalBalance;
    mapping(address => uint256) public airdropBalance;
    
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public newDeposits;
    mapping(address => uint256) public out;
    mapping(address => uint256) public postTaxOut;

    mapping(address => uint256) public roi;
    mapping(address => uint256) public tax;
    mapping(address => uint256) public cwr;
    mapping(address => uint256) public maxCwr;
    mapping(address => bool) public penalized;
    mapping(address => bool) public accountReachedMaxPayout;
    mapping(address => bool) public doneCompounding;

    mapping(address => uint256) public lastAction;
    mapping(address => uint256) public compounds;
    mapping(address => uint256) public withdrawn;
    mapping(address => uint256) public airdropped;
    mapping(address => uint256) public airdropsReceived;
    mapping(address => uint256) public roundRobinRewards;
    mapping(address => uint256) public directRewards;    
    mapping(address => uint256) public timeOfEntry;

    mapping(address => address) public referrerOf;
    mapping(address => uint256) public roundRobinPosition;

    mapping(address => address[]) public upline;
    mapping(address => mapping(address => bool)) private referrerAdded;

    mapping(uint256 => uint256) public bondLevelPrices;
    
    struct Action {
        uint256 compoundSeconds;
        uint256 withdrawSeconds;
    }

    mapping(address => Action[]) public actions;
    
///// VaultVariables    
    uint256 public roiPenalized = 5;
    uint256 public roiNormal = 20;    
    uint256 public roiReduced = 10;
    uint256 public maxCwrWithoutNft = 1500;
    uint256 public cwrLowerLimit = 750;
    uint256 public maxPayoutPercentage = 300;
    uint256 public maxDeposit = 4000 * MULTIPLIER;
    uint256 public minDeposit = 10 * MULTIPLIER;
    uint256 public maxPayoutAmount = 80000 * MULTIPLIER;

///// TimeVariables
    uint256 public cwrAverageTime = 14 days;
    uint256 public timer = 1 days;

///// TaxVariables
    uint256 public swapBuyTax = 5;
    uint256 public depositTax = 10;
    uint256 public depositReferralTax = 5;
    uint256 public buyTax = 8;
    uint256 public buyReferralTax = 5;
    uint256 public roundRobinTax = 5;
    uint256 public airdropLiqTax = 2;
    uint256 public basicTax = 10;
    uint256 public taxLevelSteps = 8000 * MULTIPLIER;
    uint256 public maxTax = 55;
    uint256 public taxIncrease = 5;   

///// SparkVariables
    uint256 public sparkPotPercent = 50;
    uint256 public sparkPot;
    uint256 private nonce;
    uint256 public totalPrizeMoneyPaid;
    uint256 public totalWinners;
    address[] sparkPlayers;
    mapping(address => bool) public sparkPlayerAdded;
    mapping (uint256 => uint256) public prizeAtNonce;
    mapping (uint256 => bool) public nonceProcessed;

///// Events for our backend
    event NewAccountOpened(address investor, uint256 amount, uint256 timestamp);
    event DirectReferralRewardsPaid(address referrer, uint256 amount);
    event Deposit(address investor, uint256 amount);
    event SomeoneHasReachedMaxPayout(address investor);
    event SomeoneIsDoneCompounding(address investor);
    event SomeoneWasFeelingGenerous(address investor, uint256 totalAirdropAmount);
    event Withdrawn(address investor, uint256 amount, uint256 taxAmount);
    event Compounded(address investor, uint256 amount);
    event SomeoneWillAirdropSoon(address investor, uint256 amount);
    event LiquidityTaxSentToPool(uint256 amount);
    event SparkPotToppedUp(uint256 amount, address whoWasntEligible);
    event RoundRobinReferralRewardsPaid(address referrer, uint256 amount, uint256 roundRobinPosition);
    event SomeoneJoinedTheSystem(address investor,address referrer);
    event RoiReduced(address investor);
    event RoiIncreased(address investor);
    event SomeoneWasNaughtyAndWillBePunished(address investor);
    event SomeoneIsUsingHisNftToHyperCompound(address investor, uint256 maxCwr);
    event AutomatedActionTaken(address investor, uint256 withdrawPercent, uint256 compoundPercent, uint256 airdropPercent, bool autoSell, bool autoDeposit, bool autoBond);
    event ManualActionTaken(address investor, uint256 withdrawPercent, uint256 compoundPercent, uint256 airdropPercent, bool autoSell, bool autoDeposit, bool autoBond);
    event TaxesFromAction(address investor, uint256 taxAmount, uint256 withdrawPercent, uint256 compoundPercent, uint256 airdropPercent);
    event BondLevelPriceSet(uint256 level, uint256 price);
    event DepositTaxesSet(uint256 percent, uint256 referralPercent);
    event BuyTaxesSet(uint256 percent, uint256 buyReferralPercent, uint256 buySwapTax);
    event MaxPayoutSet(uint256 percent, uint256 amount);
    event BasicTaxSet(uint256 percent, uint256 stepSize, uint256 maxPercent, uint256 percentIncrease);
    event DepositLimitsSet(uint256 minDeposit, uint256 maxDeposit);
    event SpecialTaxesSet(uint256 robinPercent, uint256 airdropLiqPercent);
    event TimeVariablesSet(uint256 hoursInCycle, uint256 averageDays);
    event RoiSet(uint256 penalizedPerMille, uint256 normalPerMille, uint256 reducedPerMille);
    event SparkPotPercentSet(uint256 percent);
    event ArkWalletSet(address arkWallet, bool status);
    event CwrLowerLimitSet(uint256 lowerLimit);
    event UnpenalizedSet(address investor);
    event SwapBuyTaxSet(uint256 percent);
    event SparkWinnerPaid(address winner, uint256 prizeMoney, uint256 winnerNumber, uint256 timestamp);    
    event LegacySet(address legacyAddress);
    event BondSet(address bondAddress);    
    event SwapSet(address swapAddress);
    event AirDropsSent(address[] airdroppees, uint256[] amounts);
    event CwrSet(uint256 cwrWithoutNft, uint256 cwrLowLimit);
    event BnbRescued();

    modifier onlyCEO() {
        require(msg.sender == CEO, "Only the CEO can do that");
        _;
    }

    modifier onlyArk() {
        require(isArk[msg.sender], "Only ARK can do that");
        _;
    }

    modifier onlyVRF() {
        if (msg.sender != address(VRF)) return;
        _;
    }

    constructor () {
        bondLevelPrices[1] = 250 ether;
        bondLevelPrices[2] = 250 ether;
        bondLevelPrices[3] = 500 ether;
        bondLevelPrices[4] = 500 ether;
        bondLevelPrices[5] = 500 ether;
        bondLevelPrices[6] = 500 ether;
        bondLevelPrices[7] = 500 ether;
        bondLevelPrices[8] = 500 ether;
        bondLevelPrices[9] = 500 ether;
        bondLevelPrices[10] = 1000 ether;
        bondLevelPrices[11] = 1000 ether;
        bondLevelPrices[12] = 1000 ether;
        bondLevelPrices[13] = 1000 ether;
        bondLevelPrices[14] = 1000 ether;
        bondLevelPrices[15] = 1000 ether;
    }

    receive() external payable {}

////////////////////// DEPOSIT FUNCTIONS /////////////////////////////////
    function deposit(uint256 amount, address referrer) external {
        if(upline[msg.sender].length == 0){
            if(referrer == msg.sender) referrer = address(0);
            else referrerOf[msg.sender] = referrer;

            referrerAdded[msg.sender][msg.sender] = true;

            for(uint256 i=0; i<15;i++) {
                upline[msg.sender].push(referrer);
                
                if(referrer != address(0)) {
                    referrerAdded[msg.sender][referrer] = true;
                    referrer = referrerOf[referrer];
                    if(referrerAdded[msg.sender][referrer]) referrer = address(0);
                }
            }
            emit SomeoneJoinedTheSystem(msg.sender, referrer);
        }

        ARK.transferFrom(msg.sender, address(this), amount);
        amount = takeDepositTax(referrerOf[msg.sender], amount);
        uint256 depositsTotal = deposits[msg.sender] + newDeposits[msg.sender] + airdropsReceived[msg.sender];
        require(depositsTotal + amount <= maxDeposit, "Exceeds max deposit");
        require(depositsTotal + amount >= minDeposit, "Less than minimum deposit");
        _deposit(msg.sender, amount);
    }

    function depositFor(address investor, uint256 amount, address referrer) external onlyArk returns (uint256) {
        if(upline[investor].length == 0){
            if(referrer == investor) referrer = address(0);
            else referrerOf[investor] = referrer;

            referrerAdded[investor][investor] = true;

            for(uint256 i=0; i<15;i++){
                upline[investor].push(referrer);
                
                if(referrer != address(0)) {
                    referrerAdded[investor][referrer] = true;
                    referrer = referrerOf[referrer];
                    if(referrerAdded[investor][referrer]) referrer = address(0);
                }
            }
            emit SomeoneJoinedTheSystem(investor, referrer);
        }

        ARK.transferFrom(msg.sender, address(this), amount);
        amount = takeDepositTaxFromBuy(referrerOf[investor], amount);
        uint256 depositsTotal = deposits[investor] + newDeposits[investor] + airdropsReceived[investor];
        require(depositsTotal + amount <= maxDeposit, "Exceeds max deposit");
        require(depositsTotal + amount >= minDeposit, "Less than minimum deposit");
        _deposit(investor, amount);
        return amount;
    }

////////////////////// USER ACTION FUNCTIONS /////////////////////////////////
    function takeAction(uint256 withdrawPercent, uint256 compoundPercent, uint256 airdropPercent, bool autoSell, bool autoDeposit, bool autoBond) external {
        doTheThing(msg.sender, withdrawPercent, compoundPercent, airdropPercent, autoSell, autoDeposit, autoBond);
        emit ManualActionTaken(msg.sender, withdrawPercent, compoundPercent, airdropPercent, autoSell, autoDeposit, autoBond);
    }

    function airdrop(address[] memory airdroppees, uint256[] memory amounts) external {
        require(airdroppees.length == amounts.length, "Array lengths don't match");
        require(airdroppees.length <= 200, "Too many addresses at once");
        uint256 totalAirdropAmount = 0;
        for(uint i = 0; i < airdroppees.length; i++){
            uint256 amount = amounts[i];
            address airdroppee = airdroppees[i];
            if(airdroppee == msg.sender) continue;
            uint256 depositsTotal = deposits[airdroppee] + newDeposits[airdroppee] + airdropsReceived[airdroppee];
            if(depositsTotal > maxDeposit) {
               amounts[i] = 0;
               continue;
            }
            if(depositsTotal + amount > maxDeposit) {
                amount = maxDeposit - depositsTotal;
                amounts[i] = amount;
            }
            _deposit(airdroppee, amount);
            airdropsReceived[airdroppee] += amount;
            airdropBalance[msg.sender] -= amount;
            totalAirdropAmount += amount;
        }
        emit SomeoneWasFeelingGenerous(msg.sender, totalAirdropAmount);
        emit AirDropsSent(airdroppees, amounts);
    }

////////////////////// SERVER FUNCTIONS /////////////////////////////////
    function takeAutomatedAction(address investor, uint256 withdrawPercent, uint256 compoundPercent, uint256 airdropPercent, bool autoSell, bool autoDeposit, bool autoBond) external onlyArk {
        doTheThing(investor, withdrawPercent, compoundPercent, airdropPercent, autoSell, autoDeposit, autoBond);
        emit AutomatedActionTaken(investor, withdrawPercent, compoundPercent, airdropPercent, autoSell, autoDeposit, autoBond);
    }

////////////////////// INTERNAL FUNCTIONS /////////////////////////////////
    function doTheThing(address investor, uint256 withdrawPercent, uint256 compoundPercent, uint256 airdropPercent, bool autoSell, bool autoDeposit, bool autoBond) internal {
        if(autoDeposit) require(!autoSell && !autoBond, "Only one autoAction allowed");
        if(autoSell) require(!autoDeposit && !autoBond, "Only one autoAction allowed");
        if(autoBond) require(!autoSell && !autoDeposit, "Only one autoAction allowed");
        if(accountReachedMaxPayout[investor]) return;
        if(principalBalance[investor] + newDeposits[investor] < minDeposit) return;
        require(withdrawPercent + compoundPercent + airdropPercent == 100, "All available rewards have to be allocated");
        uint256 timeSinceLastAction = block.timestamp - lastAction[investor] > timer ? timer : block.timestamp - lastAction[investor];
        lastAction[investor] = block.timestamp;
        uint256 availableReward = principalBalance[investor] * roi[investor] / 1000 * timeSinceLastAction / timer;

        uint256 maxPayout = checkForMaxPayoutPercent(investor);

        if(maxPayout < out[investor] + availableReward) {
            compoundPercent = 100;
            airdropPercent = 0;
            withdrawPercent = 0;
        }

        if(doneCompounding[investor]) {
            maxPayout = maxPayoutAmount;
            withdrawPercent += compoundPercent;
            compoundPercent = 0;
        }

        if(out[investor] + availableReward > maxPayoutAmount) {
            availableReward = maxPayout - out[investor];
            accountReachedMaxPayout[investor] = true;
            emit SomeoneHasReachedMaxPayout(investor);
        }

        if(availableReward == 0) return;
        out[investor] += availableReward;
        calculateWhaleTax(investor);
        principalBalance[investor] += newDeposits[investor];
        deposits[investor] += newDeposits[investor];
        newDeposits[investor] = 0;
        uint256 taxAmount = availableReward * tax[investor] / 100;
        emit TaxesFromAction(investor, taxAmount, compoundPercent, withdrawPercent, airdropPercent);
        availableReward -= taxAmount;
        postTaxOut[investor] += availableReward;

        if(withdrawPercent > 0) {
            uint256 withdrawAmount = withdrawPercent * availableReward / 100;
            uint256 withdrawTaxAmount = taxAmount * withdrawPercent / 100;
            if(autoDeposit) reDeposit(investor, withdrawAmount);
            else ARK.transfer(investor, withdrawAmount);
            emit Withdrawn(investor, withdrawAmount, withdrawTaxAmount);
            if(autoSell) swap.vaultSellForBUSD(investor, withdrawAmount);
            if(autoBond) swap.vaultAddLiquidityWithArk(investor, withdrawAmount);
            withdrawn[investor] += withdrawAmount;
        }

        if(compoundPercent > 0){
            uint256 compoundAmount = compoundPercent * availableReward / 100;
            uint256 compoundTaxAmount = taxAmount * compoundPercent / 100;
            compound(investor, compoundAmount, compoundTaxAmount);
            emit Compounded(investor, compoundAmount);
            compounds[investor] += compoundAmount;
        }

        if(airdropPercent > 0) {
            uint256 airdropAmount = airdropPercent * availableReward / 100;
            uint256 airdropTaxAmount = taxAmount * airdropPercent / 100;
            handleAirdropTax(investor, airdropTaxAmount);
            airdropBalance[investor] += airdropAmount;
            emit SomeoneWillAirdropSoon(investor, airdropAmount);
            airdropped[investor] += airdropAmount;
        }

        doTheMath(investor, timeSinceLastAction, withdrawPercent, compoundPercent, airdropPercent);
    }

function _addInvestor(address investor, uint256 amount) internal {
        timeOfEntry[investor] = block.timestamp;
        cwr[investor] = 1000;
        
        Action memory currentAction;
        uint256 daysOfCwr = cwrAverageTime / 1 days;
        currentAction.compoundSeconds = 0.5 days;
        currentAction.withdrawSeconds = 0.5 days;
        for(uint256 i = 1; i <= daysOfCwr; i++) actions[investor].push(currentAction);
        roi[investor] = roiNormal;
        maxCwr[investor] = maxCwrWithoutNft;
        lastAction[investor] = block.timestamp;
        principalBalance[investor] = amount;
        deposits[investor] = amount;
        totalAccounts++;
        emit NewAccountOpened(investor, amount, block.timestamp);
    }

    function _deposit(address investor, uint256 amount) internal {
        if (amount == 0) return;
        if (timeOfEntry[investor] == 0) _addInvestor(investor, amount);
        else newDeposits[investor] += amount;
        emit Deposit(investor, amount);
    }

    function checkForMaxPayoutPercent(address investor) internal returns (uint256) {
        uint256 maxPayout = (principalBalance[investor] + newDeposits[investor]) * maxPayoutPercentage / 100;
        if(maxPayout > maxPayoutAmount) {
            doneCompounding[investor] = true;     
            emit SomeoneIsDoneCompounding(investor);
        }
        return maxPayout;
    }

    function reDeposit(address investor, uint256 amount) internal {
        amount = takeDepositTax(referrerOf[investor], amount);
        uint256 depositsTotal = deposits[investor] + newDeposits[investor] + airdropsReceived[investor];
        require(depositsTotal + amount <= maxDeposit, "Exceeds max deposit");
        _deposit(investor, amount);
        principalBalance[investor] += newDeposits[investor];
        deposits[investor] += newDeposits[investor];
        newDeposits[investor] = 0;
    }

    function compound(address investor, uint256 amount, uint256 taxAmount) internal {
        principalBalance[investor] += amount;
        uint256 roundRobinAmount = taxAmount * roundRobinTax / tax[investor];
        roundRobin(investor, roundRobinAmount);
    }

    function roundRobin(address investor, uint256 amount) internal {
        uint256 currentPosition = roundRobinPosition[investor];
        address currentRobin = upline[investor][currentPosition];
        
        if(currentRobin == address(0) || !isEligible(currentRobin,currentPosition)) {
            uint256 sparkPotAmount = amount * sparkPotPercent / 100;
            sparkPot += sparkPotAmount;
            emit SparkPotToppedUp(sparkPotAmount, currentRobin);
        }
        else {
            _deposit(currentRobin, amount);
            roundRobinRewards[currentRobin] += amount;
            emit RoundRobinReferralRewardsPaid(currentRobin, amount, roundRobinPosition[investor]);
        }
        roundRobinPosition[investor]++;
        if(roundRobinPosition[investor] > 14) roundRobinPosition[investor] = 0;
    }

////////////////////// CALCULATION FUNCTIONS /////////////////////////////////
    function calculateWhaleTax(address investor) internal {
        tax[investor] = basicTax + taxIncrease * (out[investor] / taxLevelSteps);
        if(tax[investor] > maxTax) tax[investor] = maxTax;
    } 

    function doTheMath(
        address investor,
        uint256 timeSinceLastAction,
        uint256 withdrawPercent,
        uint256 compoundPercent,
        uint256 airdropPercent
    ) internal {
        uint256 totalActions = actions[investor].length;
        
        Action memory currentAction;
        currentAction.compoundSeconds = timeSinceLastAction * compoundPercent / 100;
        currentAction.withdrawSeconds = timeSinceLastAction * (withdrawPercent + airdropPercent) / 100;
        actions[investor].push(currentAction);

        uint256 newCompoundSeconds = 0;
        uint256 newWithdrawSeconds = 0;

        for(uint256 i = 0; newCompoundSeconds + newWithdrawSeconds < cwrAverageTime; i++) {
            newCompoundSeconds += actions[investor][totalActions - i].compoundSeconds;
            newWithdrawSeconds += actions[investor][totalActions - i].withdrawSeconds;
        }

        uint256 newCwr = newCompoundSeconds * 1000 / newWithdrawSeconds;
        if(newCwr > maxCwr[investor]) updateMaxCwr(investor);
        require(newCwr <= maxCwr[investor], "CWR too high, increase your max CWR by purchasing a Legacy NFT");
        cwr[investor] = newCwr;

        if(!penalized[investor]) {
            if(newCwr < cwrLowerLimit && !doneCompounding[investor]) {
                penalized[investor] = true;
                roi[investor] = roiPenalized;
                emit SomeoneWasNaughtyAndWillBePunished(investor);
                return;
            }

            if(withdrawn[investor] > deposits[investor] + newDeposits[investor] - airdropsReceived[investor]) {
                if(roi[investor] == roiNormal){
                    emit RoiReduced(investor);
                    roi[investor] = roiReduced;
                    return;
                } 
            }

            if(roi[investor] == roiReduced){
                emit RoiIncreased(investor);
                roi[investor] = roiNormal;
            }
        }
    }

    function updateMaxCwr(address investor) internal {
        maxCwr[investor] = legacy.getCwr(investor);
        emit SomeoneIsUsingHisNftToHyperCompound(investor, maxCwr[investor]);
    }

////////////////////// TAX FUNCTIONS /////////////////////////////////
    function takeDepositTax(address referrer, uint256 amount) internal returns(uint256) {
        uint256 taxAmount = amount * depositTax / 100;
        if(referrer == address(0)) return amount - taxAmount;
        uint256 referralTax = amount * depositReferralTax / 100; 
        if(isEligible(referrer,0)) {
            _deposit(referrer, referralTax);
            directRewards[referrer] += referralTax;
            emit DirectReferralRewardsPaid(referrer, referralTax);
        }
        return amount - taxAmount;
    }

    function takeDepositTaxFromBuy(address referrer, uint256 amount) internal returns(uint256) {
        uint256 initialAmount = amount * 100 / (100 - swapBuyTax);
        uint256 taxAmount = initialAmount * buyTax / 100;
        if(referrer == address(0)) return amount - taxAmount;
        uint256 referralTax = initialAmount * buyReferralTax / 100;
        if(isEligible(referrer,0)) {
            _deposit(referrer, referralTax);
            directRewards[referrer] += referralTax;
            emit DirectReferralRewardsPaid(referrer, referralTax);
        }
        return amount - taxAmount;
    }

    function handleAirdropTax(address investor, uint256 amount) internal {
        uint256 amountToLiq = amount / tax[investor] * airdropLiqTax;
        ARK.transfer(address(ARK_POOL), amountToLiq);
        ARK_POOL.sync();
        emit LiquidityTaxSentToPool(amountToLiq);
    }

/////////////////// PUBLIC READ FUNCTIONS //////////////////////////////
    function getAvailableReward(address investor) public view returns(uint256) {
        uint256 timeSinceLastAction = block.timestamp - lastAction[investor] > timer ? timer : block.timestamp - lastAction[investor];
        uint256 availableReward = principalBalance[investor] * roi[investor] * timeSinceLastAction / timer / 1000;
        return availableReward;
    }

    function checkRoi(address investor) public view returns(uint256) {
        if(penalized[investor]) return roiPenalized;
        if(withdrawn[investor] > deposits[investor] + newDeposits[investor] - airdropsReceived[investor]) return roiReduced;
        return roiNormal;
    }

    function checkNdv(address investor) public view returns(int256) {
        int256 ndv = int256(deposits[investor]) + int256(newDeposits[investor]) - int256(airdropsReceived[investor]) - int256(withdrawn[investor]);
        return ndv;
    }

    function checkWhaleTax(address investor) public view returns(uint256) {
        uint256 whaleTax = basicTax + taxIncrease * (out[investor] / taxLevelSteps);
        if(whaleTax > maxTax) whaleTax = maxTax;
        return whaleTax;
    }

    function checkMaxPayout(address investor) public view returns (uint256) {
        uint256 maxPayout = (principalBalance[investor] + newDeposits[investor]) * maxPayoutPercentage / 100;
        if(maxPayout > maxPayoutAmount) maxPayout = maxPayoutAmount;
        return maxPayout;
    }

    function getTotalReferralRewards(address investor) public view returns (uint256) {
        return roundRobinRewards[investor] + directRewards[investor];
    }

    function hasAccount(address investor) external view returns(bool) {
        if(principalBalance[investor] + newDeposits[investor] < minDeposit) return false;
        return true;
    }

    function isEligible(address uplineAddress, uint256 uplinePosition) public view returns(bool) {
        if(uplineAddress == address(0)) return false;
        uint256 levels = legacy.getLevels(uplineAddress);
        if(levels > uplinePosition) return true; 
        levels = addLevelsFromBond(uplineAddress, levels);
        if(levels > uplinePosition) return true;
        return false;
    }

    function addLevelsFromBond(address investor, uint256 nftLevels) public view returns (uint256) {
        uint256 bondValue = getBondValue(investor);
        if(bondValue < bondLevelPrices[1]) return nftLevels;
        uint256 currentLevel = nftLevels;
        uint256 remainingBondValue = bondValue;

        while(remainingBondValue > bondLevelPrices[currentLevel + 1]) {
            currentLevel++;
            remainingBondValue -= bondLevelPrices[currentLevel];
            if(currentLevel > 14) return 15;
        }

        return currentLevel;
    }

    function getBondValue(address investor) public view returns (uint256) {
        uint256 bondAmount = bond.getBondBalance(investor);
        uint256 bondValue = calculateUsdValueOfBond(bondAmount);
        return bondValue;
    }

    function calculateUsdValueOfBond(uint256 amountOfBond) public view returns(uint256) {
        uint256 totalBond = IBEP20(address(ARK_POOL)).totalSupply();
        uint256 totalBusdInBond = BUSD.balanceOf(address(ARK_POOL));
        uint256 busdValueOfBond = amountOfBond * totalBusdInBond * 2 / totalBond;
        return busdValueOfBond;
    }

    function getLevelOfInvestor(address investor) public view returns(uint256) {
        if(investor == address(0)) return 0;
        uint256 levels = legacy.getLevels(investor);
        levels = addLevelsFromBond(investor, levels);
        return levels;
    }

    function getNftLevels(address investor) public view returns(uint256) {
        uint256 nftLevels = legacy.getLevels(investor);
        return nftLevels;
    }
    
    function getRollingAverageCwr(
        address investor,
        uint256 timeSinceLastAction,
        uint256 withdrawPercent,
        uint256 compoundPercent,
        uint256 airdropPercent
    ) public view returns(uint256) {
        uint256 totalActions = actions[investor].length;
        uint256 newCompoundSeconds = timeSinceLastAction * compoundPercent / 100;
        uint256 newWithdrawSeconds = timeSinceLastAction * (withdrawPercent + airdropPercent) / 100;

        for(uint256 i = 1; newCompoundSeconds + newWithdrawSeconds < cwrAverageTime; i++) {
            newCompoundSeconds += actions[investor][totalActions - i].compoundSeconds;
            newWithdrawSeconds += actions[investor][totalActions - i].withdrawSeconds;
        }

        uint256 newCwr = newCompoundSeconds  * 1000 / newWithdrawSeconds;
        return newCwr;
    }

/////////////////// LAUNCH FUNCTIONS //////////////////////////////
    function depositPresaleTokens(address[] calldata investors, uint256[] calldata amounts, address[] calldata referrers, uint256 launchTime) external onlyCEO {
        uint256 totalDepositAmount = 0;
        uint256 amount = 0;
        address investor;

        for(uint256 i=0; i < investors.length; i++) {
            investor = investors[i];
            referrerOf[investor] = referrers[i];
            amount = takeDepositTax(referrerOf[investor], amounts[i]);
            timeOfEntry[investor] = launchTime;
            cwr[investor] = 1000;
            Action memory currentAction;
            uint256 daysOfCwr = cwrAverageTime / 1 days;
            currentAction.compoundSeconds = 0.5 days;
            currentAction.withdrawSeconds = 0.5 days;
            for(uint256 j = 1; j <= daysOfCwr; j++) actions[investor].push(currentAction);
            roi[investor] = roiNormal;
            maxCwr[investor] = maxCwrWithoutNft;
            lastAction[investor] = launchTime;
            principalBalance[investor] += amount;
            deposits[investor] += amount;
            totalDepositAmount += amount;
        }

        ARK.transferFrom(msg.sender, address(this), totalDepositAmount);
    }

    function generateUplineForPresale(address[] calldata investors) external onlyCEO {
        address referrer;
        address investor;

        for(uint256 i=0; i < investors.length; i++) {
            investor = investors[i];
            referrer = referrerOf[investor];
            referrerAdded[investor][investor] = true;

            for(uint256 j=0; j < 15; j++){
                upline[investor].push(referrer);
                
                if(referrer != address(0)) {
                    referrerAdded[investor][referrer] = true;
                    referrer = referrerOf[referrer];
                    if(referrerAdded[investor][referrer]) referrer = address(0);
                }
            }
            emit SomeoneJoinedTheSystem(investor, referrer);
        }
    }

/////////////////// ADMIN FUNCTIONS //////////////////////////////
    function setArkWallet(address arkWallet, bool status) external onlyCEO {
        isArk[arkWallet] = status;
        emit ArkWalletSet(arkWallet, status);
    }

    function setLegacyAddress(address legacyAddress) external onlyCEO {
        legacy = ILEGACY(legacyAddress);
        IBEP20(ARK).approve(address(legacy), type(uint256).max);
        IBEP20(BUSD).approve(address(legacy), type(uint256).max);
        emit LegacySet(legacyAddress);
    }

    function setBondAddress(address bondAddress) external onlyCEO {
        bond = IBOND(bondAddress);
        IBEP20(ARK).approve(address(bond), type(uint256).max);
        IBEP20(BUSD).approve(address(bond), type(uint256).max);
        emit BondSet(bondAddress);
    }
    
    function setSwapAddress(address swapAddress) external onlyCEO {
        swap = ISWAP(swapAddress);
        IBEP20(ARK).approve(address(swap), type(uint256).max);
        IBEP20(BUSD).approve(address(swap), type(uint256).max);
        emit SwapSet(swapAddress);
    }

    function setBondLevelPrice(uint256 level, uint256 price) external onlyCEO {
        bondLevelPrices[level] = price * 1 ether;
        emit BondLevelPriceSet(level, price);
    }

    function setDepositTaxes(uint256 percentTax, uint256 percentReferral) external onlyCEO {
        depositTax = percentTax;
        depositReferralTax = percentReferral;
        emit DepositTaxesSet(percentTax, percentReferral);
    }

    function setBuyTaxes(uint256 buyPercent, uint256 buyReferralPercent, uint256 buySwapTax) external onlyCEO {
        buyTax = buyPercent;
        buyReferralTax = buyReferralPercent;
        swapBuyTax = buySwapTax;
        emit BuyTaxesSet(buyPercent, buyReferralPercent, buySwapTax);
    }

    function setMaxPayout(uint256 percent, uint256 amount) external onlyCEO {
        maxPayoutPercentage = percent;
        maxPayoutAmount = amount * MULTIPLIER;
        emit MaxPayoutSet(percent, amount);
    }

    function setBasicTax(uint256 percent, uint256 stepSize, uint256 maxPercent, uint256 percentIncrease) external onlyCEO {
        basicTax = percent;
        taxLevelSteps = stepSize * MULTIPLIER;
        maxTax = maxPercent;
        taxIncrease = percentIncrease;
        emit BasicTaxSet(percent, stepSize, maxPercent, percentIncrease);
    }

    function setMaxAndMinDeposit(uint256 minAmount, uint256 maxAmount) external onlyCEO {
        minDeposit = minAmount * MULTIPLIER;
        maxDeposit = maxAmount * MULTIPLIER;
        emit DepositLimitsSet(minDeposit, maxDeposit);
    }

    function setSpecialTaxes(uint256 robinPercent, uint256 airdropLiqPercent) external onlyCEO {
        roundRobinTax = robinPercent;
        airdropLiqTax = airdropLiqPercent;
        emit SpecialTaxesSet(robinPercent, airdropLiqPercent);
    }

    function setTimeVariables(uint256 hoursInCycle, uint256 averageDays) external onlyCEO {
        timer = hoursInCycle * 1 hours;
        cwrAverageTime = averageDays * 1 days;
        emit TimeVariablesSet(hoursInCycle, averageDays);
    }   

    function setRoi(uint256 penalizedPerMille, uint256 normalPerMille, uint256 reducedPerMille) external onlyCEO {
        roiPenalized = penalizedPerMille;
        roiNormal = normalPerMille;
        roiReduced = reducedPerMille;
        emit RoiSet(penalizedPerMille, normalPerMille, reducedPerMille);
    }

    function setCwr(uint256 cwrWithoutNft, uint256 cwrLowLimit) external onlyCEO {
        cwrLowerLimit = cwrLowLimit;
        maxCwrWithoutNft = cwrWithoutNft;
        emit CwrSet(cwrWithoutNft, cwrLowLimit);
    }

//////////////// SPARKPOT FUNCTIONS ///////////////////////////////////////
    function setSparkPotPercent(uint256 percent) external onlyCEO {
        sparkPotPercent = percent;
        emit SparkPotPercentSet(percent);
    }

    function addSparkPlayer(address investor) external onlyArk {
        if(sparkPlayerAdded[investor]) return;
        sparkPlayers.push(investor);
        sparkPlayerAdded[investor] = true;
    }

    function getRandomness(uint256 reqID, uint256 howManyNumbers) internal {
        VRF.requestRandomness{value: 0.002 ether}(reqID, howManyNumbers);
    }

    function drawSparkWinnerWithAmount(uint256 prizeAmount) external onlyArk {
        prizeAtNonce[nonce] = prizeAmount;
        getRandomness(nonce, 10);
        nonce++;
    }

    function drawSparkWinnerWithPercent(uint256 percentOfSpark) external onlyArk {
        prizeAtNonce[nonce] = sparkPot * percentOfSpark / 100;
        getRandomness(nonce, 10);
        nonce++;
    }

    function supplyRandomness(uint256 _nonce,uint256[] memory randomNumbers) external onlyVRF {
        if(nonceProcessed[_nonce]) return;
        address winner = getFirstEligibleWinner(randomNumbers);
        if(winner == address(0)) {
            getRandomness(_nonce, 10);
        } else {
            uint256 prizeMoney = prizeAtNonce[_nonce];
            _deposit(winner, prizeMoney);
            sparkPot -= prizeMoney;
            totalPrizeMoneyPaid += prizeMoney;
            totalWinners++;
            nonceProcessed[_nonce] = true;
            emit SparkWinnerPaid(winner, prizeMoney, totalWinners, block.timestamp);
        }
    }

    function getFirstEligibleWinner(uint256[] memory randomNumbers) internal view returns(address) {
        address candidate;
        for(uint256 i=0; i < randomNumbers.length; i++) {
            candidate = sparkPlayers[(randomNumbers[i] % sparkPlayers.length)];
            if(isEligible(candidate, 0)) return candidate;
        }
        return address(0);
    }

//////////////// EMERGENCY FUNCTIONS ///////////////////////////////////////
    function approveNewContract(address token, address approvee) external onlyCEO {
        IBEP20(token).approve(approvee, type(uint256).max);
    }

    function rescueAnyToken(address tokenToRescue, uint256 percent) external onlyCEO {
        require(percent <= 100, "Can't take more than 100%");
        IBEP20(tokenToRescue).transfer(msg.sender, IBEP20(tokenToRescue).balanceOf(address(this)) * percent / 100);
    }

    function rescueBnb() external onlyCEO {
        (bool success,) = address(CEO).call{value: address(this).balance}("");
        require(success, "rescueBnb failed!");
        emit BnbRescued();
    }
}