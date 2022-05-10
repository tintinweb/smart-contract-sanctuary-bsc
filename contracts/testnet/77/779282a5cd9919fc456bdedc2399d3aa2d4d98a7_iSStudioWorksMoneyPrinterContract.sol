/**
iS.StudioWorks Money Printer
 Buy Money Printers, Print Money, Cash Out for Native Network Coins. 
  3% interest Rate
  Up to 12% Referral Bonus. Will go directly to referrer wallet as printers.
  .05% staking compound bonus every hour, max of 6 days, 144 times. (7.20%)
  Designated Tokens and Partner Token Holders receives extra bonus interest rates
  up to 28.75% and referral rewards up to 12%, based on how many tokens holding.
  48 hours interest accumulation cut off time.
  .3 BNB minimum investment.
  20 BNB max investment per wallet.
  60% feedback and 50% mining rate penalty for withdrawals that are made before mandatory 
  18 consecutive compounds & 6 days since beginning of the cycle. Penalty stays in contract.
  4 hours withdrawal cool time.
  Withdrawals will reset daily compound count back to 0.
*/

// Created by iS.StudioWorks
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./PrinterSettingsFunctions.sol";
import "./SafeMath.sol";


contract iSStudioWorksMoneyPrinterContract is PrinterSettingsFunctions {
    using SafeMath for uint256;

    address[] automate;
    mapping (address => uint256) automateIndexes;

    struct Automation {
        uint256 day;
        uint256 runDays;
        uint256 runHours;
        uint256 startTime;
        uint256 dayRun;
        uint256 lastRun;
    }

    mapping(address => Automation) public automations;

    modifier _initialized() {
        require(initialized);
        _;
    }

    constructor (
        uint256 rateBps_, // 1 = .01%, 10000 = 100%
        uint256 taxBps_, // Applies to both Buy & Sell Fees. 1 = .01%, 10000 = 100%
        uint256 compoundBonusBps_, /** Standard Max 30%.  1 = .01%, 10000 = 100%**/
        uint256 compoundTimer_, /** Standard 12 hours / 2 X 6 days. **/
        address setupFeeReceiver_,
        uint256 serviceFeeBps_ // 1 = .01%, 10000 = 100%
    ) OwnerAdminSettings() {
        require(marketMoney == 0);
        require(!contractSet, "Contract Already Set");
        require(rateBps_ >= 0 && rateBps_ >= minRateBps && rateBps_ <= maxRateBps && rateBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Rate provided is out of range. 0~10000");
        require(taxBps_ >= 0 && taxBps_ >= minTaxBps && taxBps_ <= maxTaxBps && taxBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Tax provided is out of range. 0~1000");
        require(compoundBonusBps_ >= 0 && compoundBonusBps_ <= maxCompoundBonusBps && compoundBonusBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, BonusRate provided is out of range. 0~10000");
        require(compoundTimer_ >= minCompoundTimer && compoundTimer_ <= maxCompoundTimer, "Min 1 H, Max 144 Hours. 1~144");

        maintenanceFund = msg.sender; // SET NEW ONE AFTER LAUNCH!!

        minRate = calcRate(minRateBps); // **NOTE: minRate will calculate the initial money in market.

        printRateBps = rateBps_;
        printRate = calcRate(rateBps_);

        maintenanceFeeBps = 99; // Standard .99% maintenance fee
        autoCompoundFeeBps = 99; // Standard .99% maintenance fee
        buyTaxBps = taxBps_;
        sellTaxBps = taxBps_;

        /** Standard Max 30%.  1 = .01%, 10000 = 100%**/
        compoundBonusBps = compoundBonusBps_; //ie. .21% Up to 60 times = Max 30.24%.  

        /** Standard 12 times / Every 12 Hours / 2 X 6 days. **/
        compoundBonusMaxTimes = 144; /** 24 times / 6 days. **/

        /** Standard 12 hours / 2 X 6 days. **/
        compoundTimer = compoundTimer_ * 1 hours; /** every hour. **/

        // required compound times, for no early withdrawal penalty tax.
        mandatoryCmpndTimes = 18; //3 times 6 days = 18;

        // Standard 12%. Max 15%. 1 = .01%, 10000 = 100%
        refRewardRateBps = 1200;

        setupFeeReceiver = setupFeeReceiver_;
        serviceFeeBps = serviceFeeBps_;

        contractSet = true;
    }


    function initialize() external nonReentrant onlyOwner {
        if (contractSet && !initialized && marketMoney == 0) {
            if (msg.sender == getOwner()) {
            require(marketMoney == 0);
            require(contractSet);
            require(!initialized, "ALREADY INITALIZED!");
            initialized = true;
            marketMoney = 100000 * minRate; // **NOTE: minRate will calculate the initial money in market.
            } else revert("Conditions NOT met to Initialize");
        }
    }

    //Buy Money with Coins, Print Money or Compound with Money, Sell Money

    function buyMoney(address ref) external payable {
        User storage user = users[msg.sender];
        require(initialized);      
        require(msg.value >= minInvReq, "Mininum buy amount not met.");
        require(users[msg.sender].userInvestmentAmt.add(msg.value) <= userMaxInvCap, "Max investment limit reached.");

        if (!verifyUser(msg.sender)){
            setNewUserAccount(msg.sender);
        }
        
        //user.lastCM = calculateMoneyBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        uint256 moneyBought = calculateMoneyBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        if (isWhitelisted[msg.sender] || isDev[msg.sender]) {
            addOnToIt(user.claimedMoney,moneyBought);
            addOnToIt(totalStaked,msg.value);
            addOnToIt(totalDeposits,1);
        } else {
            minusFromIt(moneyBought,buyTax(moneyBought));
            payable (maintenanceFund).transfer(buyTax(msg.value));
            payable (setupFeeReceiver).transfer(serviceFee(msg.value));
            addOnToIt(user.claimedMoney,moneyBought);
            addOnToIt(totalStaked,msg.value);
            addOnToIt(totalDeposits,1);
        }

        user.claimedMoney = getMyMoney(msg.sender);

        //Referrals
        //Sets the referral address for a first-time investor and locks it.
        //Makes sure the referrer is also an investor.
        if(user.referrer == address(0)) {
            if(ref != msg.sender && users[ref].initialInvestmentAmt > minInvReq &&
            user.initialInvestmentAmt == 0 && user.WA == address(0)) {
                user.referrer = ref;
            } else if(ref == msg.sender || ref == address(0) || users[ref].initialInvestmentAmt == 0) {
                user.referrer = setupFeeReceiver;
            } else {
                user.referrer = user.referrer; //makes sure the referrer stays the same.
            }

            if (user.referrer != address(0)) {
                addOnToIt(users[user.referrer].referralsCount,1);
                addOnToIt(totalReferralsMade,1);
            }
        }   
        //Sends the referral bonus as printers or miners.
        if(user.referrer != address(0)) {

            uint256 refRewardsMoney = 0;
            if(user.initialInvestmentAmt == 0 && user.WA == address(0)) {               
                if (isWhitelisted[user.referrer] || isDev[user.referrer] || checkPrtnrTokenMinReqHold(user.referrer)) {
                    refRewardsMoney = SafeMath.div((SafeMath.mul(user.claimedMoney, refRewardRateBps)), BPSDIVIDER);
                } else {
                    //Referral Reward Rate is half of Max for those who do not hold Gold Tier of Partner Tokens. 
                    refRewardsMoney = SafeMath.div((SafeMath.mul(user.claimedMoney, SafeMath.div(refRewardRateBps, 2))), BPSDIVIDER);
                }
                //Adds to cumulative referral rewards paid out in the native coin value.
                totalRefRewards = calculateMoneySell(totalRefRewards.add(refRewardsMoney));
                if (isWhitelisted[user.referrer] || isDev[user.referrer]){
                    users[user.referrer].moneyPrinters = SafeMath.add(users[user.referrer].moneyPrinters, (SafeMath.div((SafeMath.mul((SafeMath.div(refRewardsMoney,calculatePrintRate(user.referrer))), 100)), 100)));    
                } else{
                    users[user.referrer].moneyPrinters = SafeMath.add(users[user.referrer].moneyPrinters, (SafeMath.div((SafeMath.mul((SafeMath.div(refRewardsMoney,calculatePrintRate(user.referrer))), 99)), 100)));
                    users[setupFeeReceiver].moneyPrinters = SafeMath.add(users[setupFeeReceiver].moneyPrinters, (SafeMath.div((SafeMath.mul((SafeMath.div(refRewardsMoney,calculatePrintRate(user.referrer))), 1)), 100)));
                }

                emit RefRewardsSent(msg.sender, user.referrer, users[user.referrer].moneyPrinters);
                emit RefRewardsReceived(user.referrer, msg.sender, users[user.referrer].moneyPrinters);
                users[user.referrer].refRewardsReceivedTotal = SafeMath.add(users[user.referrer].refRewardsReceivedTotal, users[user.referrer].moneyPrinters);        
            }
        }

        internalCompoundingFunction(msg.sender, true, false);

        if(user.initialInvestmentAmt == 0 && user.WA == address(0)) {
            //Determines whether the user is investing for the first time or not.
            addOnToIt(user.initialInvestmentAmt,msg.value);
            user.lastWithdrawTime = block.timestamp;
            user.WA = msg.sender;
        }
        addOnToIt(user.userInvestmentAmt,msg.value);
        user.lastBoughtTime = block.timestamp;
    }

    //Print or Compound Functions
    function printMoney() external {
        require(automations[msg.sender].day == 0, "Your account is automated!");
 
        internalCompoundingFunction(msg.sender, false, false);
    }

    function internalCompoundingFunction(address adr, bool isBuy, bool isAuto) internal {
        User storage user = users[adr];
        require(initialized);
        require(user.initialInvestmentAmt != 0, "You CANNOT compound if you have never bought! Buy first please!");
        require(getMyMoney(adr) != 0, "You CANNOT compound with nothing in your wallet! Buy first please!");
        
        user.claimedMoney = getMyMoney(user.WA);

        if (isAuto) {
            payable (maintenanceFund).transfer(maintenanceFee(calculateMoneySell(user.claimedMoney)).
            add(autoCompoundFee(calculateMoneySell(user.claimedMoney))));
            payable (setupFeeReceiver).transfer(serviceFee(calculateMoneySell(user.claimedMoney)));
            user.claimedMoney = (user.claimedMoney).sub(maintenanceFee(user.claimedMoney)).sub(autoCompoundFee(user.claimedMoney));
        } 
        if (!isBuy || !isAuto || !isDev[adr] || isWhitelisted[adr]){
            payable (maintenanceFund).transfer(maintenanceFee(calculateMoneySell(user.claimedMoney)));
            payable (setupFeeReceiver).transfer(serviceFee(calculateMoneySell(user.claimedMoney)));
            user.claimedMoney = user.claimedMoney.sub(maintenanceFee(user.claimedMoney));
        } 
        {
        addOnToIt(user.moneyPrinters, SafeMath.div(user.claimedMoney,calculatePrintRate(adr)));
        }
        {
        user.lastPrintTime = block.timestamp;
        }

        //User Bonus Compound Counter
        if(block.timestamp.sub(user.lastPrintTime) >= compoundTimer &&
            user.dailyCompoundBonusCounter < compoundBonusMaxTimes) {
            
            if(checkPrtnrTokenMinReqHold(user.WA) == true){
                addOnToIt(user.dailyCompoundBonusCounter, 1);
            }
            if(checkPrtnrTokenMinReqHold(user.WA) == false &&
                user.dailyCompoundBonusCounter < (compoundBonusMaxTimes / 2)){
                    addOnToIt(user.dailyCompoundBonusCounter, 1);
            }
        }

        //boost market to nerf miners hoarding
        //uint256 moneyReleased = SafeMath.div(SafeMath.mul(moneyUsed,mrktMoneyCmpndngDivisorBps),BPSDIVIDER);
        addOnToIt(marketMoney, SafeMath.div(SafeMath.mul(user.claimedMoney,mrktMoneyCmpndngDivisorBps),BPSDIVIDER));
        
        user.claimedMoney = 0;
    }

    //Auto Compound Functions
    
    function startAutoPrint(uint256 intrvlHrs, uint256 runDays) external nonReentrant {
        require(initialized);
        require(users[msg.sender].WA == msg.sender, "YOU ARE NOT THE ACCOUNT HOLDER");
        require(automations[msg.sender].day == 0, "Address already exists!");
        require(intrvlHrs >= compoundTimer && 
        intrvlHrs <= (mandatoryHoldDays / mandatoryCmpndTimes) && 
        intrvlHrs <= 24, "Hours are not correct!");
        require(runDays >= 1, "Minimum 1 Day!");
        {
        automateIndexes[msg.sender] = automate.length;
        automate.push(msg.sender);
        }
        {
        automations[msg.sender].day = 1;
        automations[msg.sender].runDays = runDays;
        }
        {
        automations[msg.sender].runHours = intrvlHrs;
        automations[msg.sender].startTime = block.timestamp;
        }
        {
        automations[msg.sender].lastRun = block.timestamp;
        automations[msg.sender].dayRun = block.timestamp;
        }

        cumulativeAutoUsers++;
    }

    function stopAutoPrint(address adr) public {
        require(initialized);
        require(users[adr].WA == msg.sender || _evm == msg.sender ||
        msg.sender == getOwner(), "YOU ARE NOT THE ACCOUNT HOLDER");
        require(automations[adr].day >= 1, "Address doesn't exists!");

        automate[automateIndexes[adr]] = automate[automate.length-1];
        automateIndexes[automate[automate.length-1]] = automateIndexes[adr];
        automate.pop();
        delete automations[adr];
    }

    //Shows current active auto printing accounts
    function getAutomateCounts() public view returns(uint256) {
        return automate.length;
    }

    function runAutoPrint() external nonReentrant onlyOwner {
        require(initialized);
        uint256 automateCount = automate.length;

        uint256 iterations = 0;
        address adr;

        while(iterations < automateCount) {
            adr = automate[iterations];
            uint256 hasMoney = users[adr].claimedMoney.add(getMoneySinceLastPrintTime(adr));
            if(hasMoney > 0){
                if ((block.timestamp - automations[adr].lastRun) >= (automations[adr].runHours*3600)) {  //86400=24hrs, 3600=1hr, 7200=2hr, 10800=3rs, 14400=4hrs 21600=6hrs, 43200=12hrs, 64800=18
                    if(automations[adr].day == automations[adr].runDays && ((block.timestamp - automations[adr].dayRun) >= (24*3600))) {
                        automations[adr].day = 1;
                        addOnToIt(automations[adr].lastRun, (automations[adr].runHours*3600));
                        addOnToIt(automations[adr].dayRun, (24*3600));
                        {
                        internalCompoundingFunction(adr, false, true);
                        stopAutoPrint(adr);
                        }
                    }
                    else {
                        if((block.timestamp - automations[adr].dayRun) >= (24*3600)) {
                            automations[adr].day++;
                            addOnToIt(automations[adr].dayRun, (24*3600));
                        }
                        addOnToIt(automations[adr].lastRun, (automations[adr].runHours*3600));
                        internalCompoundingFunction(adr, false, true);
                    }
                }
            }
            iterations++;
        }
        addOnToIt(totalAutoHours, automations[adr].dayRun);
        totalAutoDays = SafeMath.div(totalAutoHours,1 days);
    }

    /** Anytime an user sells, compound bonus counter resets.
        IF user compounds less than mandatory compound times &
        sells less than 6 days have elapsed since cycle began,
        WILL BE PENALIZED WITH EARLY WITHDRAWAL TAX
        AND 50% LOSS ON MONEY PRINTERS **/
    function sellMoney(uint256 amtMoney) public nonReentrant {
        require(initialized);
        User storage user = users[msg.sender];
        require(user.WA == msg.sender, "YOU ARE NOT THE ACCOUNT HOLDER");
        require(block.timestamp >= SafeMath.add(users[msg.sender].lastWithdrawTime,withdrawCooldown), "WITHDRAW COOLDOWN HAS NOT FINISHED YET!");
        require(amtMoney <= getMyMoney(msg.sender), "YOU CANNOT SELL MORE THAN WHAT YOU HOLD!");

        uint256 moneyValue = calculateMoneySell(amtMoney);
        //MAKES SURE ONLY SELL WITHIN TVL.
        if((address(this).balance) <= (calculateMoneySell(amtMoney))) {
            moneyValue = address(this).balance;
        }

        if (isWhitelisted[msg.sender] || isDev[msg.sender]) {
            payable (msg.sender).transfer(moneyValue);
            {
            user.dailyCompoundBonusCounter = 0; 
            minusFromIt(user.claimedMoney, amtMoney);
            }
            {
            user.totalWithdrawn = SafeMath.add(user.totalWithdrawn,moneyValue);
            totalWithdrawn = SafeMath.add(totalWithdrawn,moneyValue);
            }
        } 
        //uint256 tax;
        //uint256 afterTaxes;

                /** if user compounds less than mandatory compound times & 
                less than mandatory hold days have elapsed since cycle began**/
        if (!isWhitelisted[msg.sender] || !isDev[msg.sender]) {
            if (user.dailyCompoundBonusCounter < mandatoryCmpndTimes && 
            block.timestamp < ((user.lastWithdrawTime) + mandatoryHoldDays)) {
            {
            //Takes taxes and fees first.
             
            payable (maintenanceFund).transfer(sellTax(calculateMoneySell(amtMoney)));
            payable (setupFeeReceiver).transfer(serviceFee(calculateMoneySell(amtMoney)));
            //afterTaxes = SafeMath.sub(calculateMoneySell(amtMoney),sellTax(calculateMoneySell(amtMoney)));
            }
            {
            //daily compound bonus count will reset and moneyValue will be deducted with Early Withdrawal tax.
            minusFromIt(SafeMath.sub(calculateMoneySell(amtMoney),sellTax(calculateMoneySell(amtMoney))),
            SafeMath.div(SafeMath.mul(SafeMath.sub(calculateMoneySell(amtMoney), sellTax(calculateMoneySell(amtMoney))),
            erlyWthdrwlTaxBps),BPSDIVIDER));

            user.dailyCompoundBonusCounter = 0;
            }
            {
            //penaltyPrinters = SafeMath.div(user.moneyPrinters, 2) //CALCULATE PRINTER LOSS PENALTY AMOUNT
            minusFromIt(user.moneyPrinters, SafeMath.div(user.moneyPrinters, 2)); //PENALIZE FOR SELLING EARLY            
            payable (msg.sender).transfer(SafeMath.sub(calculateMoneySell(amtMoney), sellTax(calculateMoneySell(amtMoney))));
            }
            {
            minusFromIt(user.claimedMoney, amtMoney);
            addOnToIt(user.totalWithdrawn,SafeMath.sub(calculateMoneySell(amtMoney), sellTax(calculateMoneySell(amtMoney))));
            addOnToIt(totalWithdrawn, SafeMath.sub(calculateMoneySell(amtMoney),sellTax(calculateMoneySell(amtMoney))));
            }
            } else {
            //set daily compound bonus count to 0 and moneyValue will remain without deductions.
            user.dailyCompoundBonusCounter = 0;
            {
            //tax = sellTax(moneyValue);          
            payable (maintenanceFund).transfer(sellTax(moneyValue));
            }
            {
            //afterTaxes = SafeMath.sub(moneyValue, sellTax(moneyValue));
            payable (msg.sender).transfer(SafeMath.sub(calculateMoneySell(amtMoney),sellTax(calculateMoneySell(amtMoney))));
            }
            {
            minusFromIt(user.claimedMoney, amtMoney);
            }
            {
            addOnToIt(user.totalWithdrawn, SafeMath.sub(moneyValue, sellTax(moneyValue)));
            addOnToIt(totalWithdrawn, SafeMath.sub(moneyValue, sellTax(moneyValue)));
            }
            }
        }
        {
        user.lastWithdrawTime = block.timestamp;
        user.lastPrintTime = block.timestamp;
        }
        {
        //boost market to nerf miners hoarding
        //uint256 moneyReleased = SafeMath.div(SafeMath.mul(amtMoney,mrktMoneySellDivisorBps),BPSDIVIDER);
        addOnToIt(marketMoney, SafeMath.div(SafeMath.mul(amtMoney,mrktMoneySellDivisorBps),BPSDIVIDER));
        }


        //User Counter
        if (user.moneyPrinters == 0) {
            removeUser(msg.sender);
        }
    }  

}