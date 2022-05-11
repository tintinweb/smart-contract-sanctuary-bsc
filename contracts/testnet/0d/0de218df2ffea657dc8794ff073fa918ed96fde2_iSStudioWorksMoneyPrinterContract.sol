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
        require(compoundBonusBps_ >= 0 && compoundBonusBps_ <= maxCompoundBonusBps && compoundBonusBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Bonmsg.senderate provided is out of range. 0~10000");
        require(compoundTimer_ >= minCompoundTimer && compoundTimer_ <= maxCompoundTimer, "Min 1 H, Max 144 Hours. 1~144");

        maintenanceFund = msg.sender; // SET NEW ONE AFTER LAUNCH!!

        printRateBps = rateBps_;
        printRate = calcRate(rateBps_);

        buyTaxBps = taxBps_;
        sellTaxBps = taxBps_;

        /** Standard Max 30%.  1 = .01%, 10000 = 100%**/
        compoundBonusBps = compoundBonusBps_; //ie. .21% Up to 60 times = Max 30.24%.  

        /** Standard 12 hours / 2 X 6 days. **/
        compoundTimer = compoundTimer_ * 1 hours; /** every hour. **/

        setupFeeReceiver = setupFeeReceiver_;
        serviceFeeBps = serviceFeeBps_;

        contractSet = true;
    }


    function initialize() external nonReentrant onlyOwner {
            require(marketMoney == 0);
            require(contractSet);
            require(!initialized, "ALREADY INITALIZED!");
            initialized = true;
            marketMoney = 100000 * minRate; // **NOTE: minRate will calculate the initial money in market.
            }
    

    //Buy Money with Coins, Print Money or Compound with Money, Sell Money

    function buyMoney(address ref) external payable {
        require(initialized);
        if (!verifyUser(msg.sender)){
            setNewUserAccount(msg.sender, ref);
        }
        User storage user = users[msg.sender];
        require(msg.value >= minInvReq, "Mininum buy amount not met.");
        require(user.userInvestmentAmt.add(msg.value) <= userMaxInvCap, "Max investment limit reached.");

        //user.lastCM = calculateMoneyBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        uint256 moneyBought = calculateMoneyBuy(msg.value, address(this).balance - msg.value);
        if (isWhitelisted[msg.sender] || isDev[msg.sender]) {
            user.claimedMoney += moneyBought;

        } else {
            moneyBought -= buyTax(moneyBought);
            payable (maintenanceFund).transfer(buyTax(msg.value));
            payable (setupFeeReceiver).transfer(serviceFee(msg.value));
            user.claimedMoney += moneyBought;
        }
        user.claimedMoney += moneyBought;
        totalStaked += msg.value;
        totalDeposits++;

        user.claimedMoney = getMyMoney(msg.sender);

        //Referrals
        //Sends the referral bonus as printers or miners.
        if(user.referrer != address(0) && user.initialInvestmentAmt == 0) {
            uint256 refRewardsMoney;             
            if (isWhitelisted[user.referrer] || isDev[user.referrer] || checkPrtnrTokenMinReqHold(user.referrer)) {
                refRewardsMoney = SafeMath.div((SafeMath.mul(moneyBought, refRewardRateBps)), BPSDIVIDER);
            } else {
                //Referral Reward Rate is half of Max for those who do not hold Gold Tier of Partner Tokens. 
                refRewardsMoney = SafeMath.div((SafeMath.mul(moneyBought, SafeMath.div(refRewardRateBps, 2))), BPSDIVIDER);
            }
            
            if (isWhitelisted[user.referrer] || isDev[user.referrer]){
                users[user.referrer].moneyPrinters = SafeMath.add(users[user.referrer].moneyPrinters, (SafeMath.div((SafeMath.mul((SafeMath.div(refRewardsMoney,calculatePrintRate(user.referrer))), 100)), 100)));    
            } else{
                users[user.referrer].moneyPrinters = SafeMath.add(users[user.referrer].moneyPrinters, (SafeMath.div((SafeMath.mul((SafeMath.div(refRewardsMoney,calculatePrintRate(user.referrer))), 99)), 100)));
                users[setupFeeReceiver].moneyPrinters = SafeMath.add(users[setupFeeReceiver].moneyPrinters, (SafeMath.div((SafeMath.mul((SafeMath.div(refRewardsMoney,calculatePrintRate(user.referrer))), 1)), 100)));
            }
            //Adds to cumulative referral rewards paid out in the native coin value.
            users[user.referrer].refRewardsReceivedTotal += calculateMoneySell(refRewardsMoney);
            emit RefRewardsSent(msg.sender, user.referrer, users[user.referrer].moneyPrinters);
            emit RefRewardsReceived(user.referrer, msg.sender, users[user.referrer].moneyPrinters);
            totalRefRewards += calculateMoneySell(refRewardsMoney);    
        }
        user.userInvestmentAmt += msg.value;
        internalCompoundingFunction(msg.sender, true, false);
    }

    //Print or Compound Functions
    function printMoney() external {
        require(automations[msg.sender].day == 0, "Your account is automated!");
        internalCompoundingFunction(msg.sender, false, false);
    }

    function internalCompoundingFunction(address adr, bool isBuy, bool isAuto) internal {
        User storage user = users[adr];
        require(initialized);
        //require(user.userInvestmentAmt != 0, "You CANNOT compound if you have never bought! Buy first please!");
        require(getMyMoney(adr) != 0, "You CANNOT compound with nothing in your wallet! Buy first please!");
        
        uint256 compoundingMoney = getMyMoney(adr);

        if (isAuto) {
            totalAutoEarn += calculateMoneySell(compoundingMoney);
            totalAutoFees += autoCompoundFee(calculateMoneySell(compoundingMoney));
            payable (maintenanceFund).transfer(maintenanceFee(calculateMoneySell(compoundingMoney)).
            add(autoCompoundFee(calculateMoneySell(compoundingMoney))));
            payable (setupFeeReceiver).transfer(serviceFee(calculateMoneySell(compoundingMoney)));
            compoundingMoney = compoundingMoney.sub(maintenanceFee(compoundingMoney)).sub(autoCompoundFee(compoundingMoney)).sub(serviceFee(compoundingMoney));
        }
        if (!isBuy || !isAuto || !isDev[adr] || !isWhitelisted[adr]){
            payable (maintenanceFund).transfer(maintenanceFee(calculateMoneySell(compoundingMoney)));
            payable (setupFeeReceiver).transfer(serviceFee(calculateMoneySell(compoundingMoney)));
            compoundingMoney = compoundingMoney.sub(maintenanceFee(compoundingMoney)).sub(serviceFee(compoundingMoney));
        }
        {
        user.moneyPrinters += SafeMath.div(compoundingMoney,calculatePrintRate(adr));
        }

        //User Bonus Compound Counter
        if(block.timestamp.sub(user.lastPrintTime) >= compoundTimer &&
            user.dailyCompoundBonusCounter < compoundBonusMaxTimes) {
            
            if(isDev[adr] || checkPrtnrTokenMinReqHold(adr) == true){
                user.dailyCompoundBonusCounter++;
            }
            if(checkPrtnrTokenMinReqHold(adr) == false &&
                user.dailyCompoundBonusCounter < (compoundBonusMaxTimes / 2)){
                    user.dailyCompoundBonusCounter++;
            }
        }

        {
        user.lastPrintTime = block.timestamp;
        }

        //boost market to nerf miners hoarding
        //uint256 moneyReleased = SafeMath.div(SafeMath.mul(moneyUsed,mrktMoneyCmpndngDivisorBps),BPSDIVIDER);
        marketMoney += SafeMath.div(SafeMath.mul(compoundingMoney,mrktMoneyCmpndngDivisorBps),BPSDIVIDER);

        if(isBuy){
            //Determines whether the user is investing for the first time or not.
            if(user.initialInvestmentAmt == 0) {
                user.initialInvestmentAmt = user.userInvestmentAmt;
                user.lastWithdrawTime = block.timestamp;
                user.WA = msg.sender;
            }
            user.lastBoughtTime = block.timestamp;
        }

        totalCompound += calculateMoneySell(compoundingMoney);
        user.claimedMoney = 0;
    }

    //Auto Compound Functions
    uint256 compoundTimerinHrs = compoundTimer / 3600;
    uint256 mandatoryAutoCmpndIntrvlHrs = mandatoryHoldDays / mandatoryCmpndTimes / 3600;

    function startAutoPrint(uint256 intrvlHrs, uint256 runDays) external nonReentrant {
        require(initialized);
        require(users[msg.sender].WA == msg.sender, "YOU ARE NOT THE ACCOUNT HOLDER");
        Automation storage user = automations[msg.sender];
        require(user.day == 0, "YOU ARE ALREADY AUTO PRINTING! GOOD JOB!!");
        require(intrvlHrs >= compoundTimerinHrs &&
        intrvlHrs <= mandatoryAutoCmpndIntrvlHrs && 
        intrvlHrs <= 24, "Hours are not correct!");
        require(runDays >= 1, "Minimum 1 Day!");
        {
        automate.push(msg.sender);
        automateIndexes[msg.sender] = automate.length;
        }
        {
        user.day = 1;
        user.runDays = runDays;
        }
        {
        user.runHours = intrvlHrs;
        user.startTime = block.timestamp;
        }
        {
        user.lastRun = block.timestamp;
        user.dayRun = block.timestamp;
        }

        cumulativeAutoUsers++;
    }

    //Stop Auto Print Functions
    function stopAutoPrintFunction() external {
        require(initialized);
        require(users[msg.sender].WA == msg.sender, "YOU ARE NOT THE ACCOUNT HOLDER");
        require(automations[msg.sender].day >= 1, "Your account is NOT automated!");
        internalStopAutoPrintFunction(msg.sender);
    }

    function internalStopAutoPrintFunction(address adr) internal {
        require(initialized);
        require(users[adr].WA == msg.sender, "YOU ARE NOT THE ACCOUNT HOLDER");
        require(automations[msg.sender].day >= 1, "Your account is NOT automated!");

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
                    if(automations[adr].day == (automations[adr].runDays + 1) && ((block.timestamp - automations[adr].dayRun) >= (24*3600))) {
                        automations[adr].day = 1;
                        automations[adr].lastRun += (automations[adr].runHours*3600);
                        automations[adr].dayRun += 24*3600;
                        {
                        internalCompoundingFunction(adr, false, true);
                        internalStopAutoPrintFunction(adr);
                        }
                    }
                    else {
                        if((block.timestamp - automations[adr].dayRun) >= (24*3600)) {
                            automations[adr].day++;
                            automations[adr].dayRun += 24*3600;
                        }
                        automations[adr].lastRun += (automations[adr].runHours*3600);
                        internalCompoundingFunction(adr, false, true);
                    }
                }
            }
            
            totalAutoHours += automations[adr].runHours;
            totalAutoDays = totalAutoHours.div(1 days);
            iterations++;
        }

    }

    /** Anytime an user sells, compound bonus counter resets.
        IF user compounds less than mandatory compound times &
        sells less than 6 days have elapsed since cycle began,
        WILL BE PENALIZED WITH EARLY WITHDRAWAL TAX
        AND 50% LOSS ON MONEY PRINTERS **/
    function sellMoney(uint256 amtMoney) external nonReentrant {
        require(initialized);
        User storage user = users[msg.sender];
        user.claimedMoney = getMyMoney(msg.sender);
        require(user.WA == msg.sender, "YOU ARE NOT THE ACCOUNT HOLDER");
        require(block.timestamp >= SafeMath.add(users[msg.sender].lastWithdrawTime,withdrawCooldown), "WITHDRAW COOLDOWN HAS NOT FINISHED YET!");
        require(amtMoney <= user.claimedMoney, "YOU CANNOT SELL MORE THAN WHAT YOU HOLD!");

        uint256 moneyValue = calculateMoneySell(amtMoney);
        //MAKES SURE ONLY SELL WITHIN TVL.
        if((address(this).balance) <= (calculateMoneySell(amtMoney))) {
            moneyValue = address(this).balance;
        }

        if (isWhitelisted[msg.sender] || isDev[msg.sender]) {
            payable (msg.sender).transfer(moneyValue);
            {
            user.dailyCompoundBonusCounter = 0; 
            user.claimedMoney -= amtMoney;
            }
            {
            user.totalWithdrawn += moneyValue;
            totalWithdrawn += moneyValue;
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
            user.moneyPrinters =  user.moneyPrinters.sub(SafeMath.div(user.moneyPrinters, 2)); //PENALIZE FOR SELLING EARLY            
            payable (msg.sender).transfer(SafeMath.sub(calculateMoneySell(amtMoney), sellTax(calculateMoneySell(amtMoney))));
            }
            {
            user.claimedMoney -= amtMoney;
            user.totalWithdrawn += SafeMath.sub(calculateMoneySell(amtMoney), sellTax(calculateMoneySell(amtMoney)));
            totalWithdrawn += SafeMath.sub(calculateMoneySell(amtMoney),sellTax(calculateMoneySell(amtMoney)));
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
            user.claimedMoney -= amtMoney;
            }
            {
            user.totalWithdrawn += SafeMath.sub(moneyValue, sellTax(moneyValue));
            totalWithdrawn += SafeMath.sub(moneyValue, sellTax(moneyValue));
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
        marketMoney += SafeMath.div(SafeMath.mul(amtMoney,mrktMoneySellDivisorBps),BPSDIVIDER);
        }


        //User Counter
        if (user.moneyPrinters == 0) {
            removeUser(msg.sender);
        }
    }  

}