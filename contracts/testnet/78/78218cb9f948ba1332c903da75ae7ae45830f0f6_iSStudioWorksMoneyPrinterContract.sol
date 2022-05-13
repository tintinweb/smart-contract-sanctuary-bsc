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

    modifier _initialized() {
        require(initialized);
        _;
    }

                    //BSC TESTNET wBNB CA: 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F /** wBNB Testnet **/
                    //BSC wBNB CA:0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c /** wBNB Mainnet **/
	                //0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; /** BUSD Testnet **/
                    //0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; /** BUSD Mainnet **/
    constructor (
        //address fundTokenCA_, 
        address maintenanceFund_,
        uint256 rateBps_, // 1 = .01%, 10000 = 100%
        uint256 buyTaxBps_, //  1 = .01%, 10000 = 100%
        uint256 sellTaxBps_, //  1 = .01%, 10000 = 100%
        uint256 compoundBonusBps_, /** Standard Max 30%.  1 = .01%, 10000 = 100%**/
        uint256 compoundBonusMaxTimes_, /** .05% Up to 144 times = Max 7.20% **/
        uint256 compoundTimer_, /** Standard 12 hours / 2 X 6 days. **/
        uint256 refRewardRateBps_, // Standard 15% Maximum rate.  1 = .01%, 10000 = 100%
        address setupFeeReceiver_,
        uint256 serviceFeeBps_ // 1 = .01%, 10000 = 100%
    ) OwnerAdminSettings() {
        require(marketMoney == 0);
        require(!contractSet, "Contract Already Set");
        require(rateBps_ >= 0 && rateBps_ >= minRateBps && rateBps_ <= maxRateBps && rateBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Rate provided is out of range. 0~10000");
        require(buyTaxBps_ >= minTaxBps && buyTaxBps_ <= maxTaxBps && buyTaxBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Tax provided is out of range. 0~1000");
        require(sellTaxBps_ >= minTaxBps && sellTaxBps_ <= maxTaxBps && sellTaxBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Tax provided is out of range. 0~1000");
        require(compoundBonusBps_ >= 0 && compoundBonusBps_ <= maxCompoundBonusBps && compoundBonusBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Bonmsg.senderate provided is out of range. 0~10000");
        require(compoundTimer_ >= minCompoundTimer && compoundTimer_ <= maxCompoundTimer, "Min 1 H, Max 144 Hours. 1~144");

        //tokenCA = fundTokenCA_;
        //fundToken = IToken(tokenCA);

        maintenanceFund = maintenanceFund_;

        printRateBps = rateBps_;
        printRate = calcRate(rateBps_);

        buyTaxBps = buyTaxBps_;
        sellTaxBps = sellTaxBps_;

        /** Standard Max 30%.  1 = .01%, 10000 = 100%**/
        compoundBonusBps = compoundBonusBps_; //ie. .21% Up to 60 times = Max 30.24%.

        /** .05% Up to 144 times = Max 7.20% **/
        compoundBonusMaxTimes = compoundBonusMaxTimes_;

        /** Standard 12 hours / 2 X 6 days. **/
        compoundTimer = compoundTimer_ * 1 hours; /** every hour. **/

        // Standard 15% Maximum rate.  1 = .01%, 10000 = 100%
        refRewardRateBps = refRewardRateBps_;

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
        uint256 moneyBought = calculateMoneyBuy(msg.value, (getBalance() - msg.value));
        if (isWhitelisted[msg.sender] || isDev[msg.sender]) {
            user.claimedMoney += moneyBought;

        } else {
            moneyBought -= buyTax(moneyBought);
            //fundToken.transfer(maintenanceFund, buyTax(amt));
            payable (maintenanceFund).transfer(buyTax(msg.value));
            //fundToken.transfer(setupFeeReceiver, serviceFee(amt));
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
    function compoundMoney() external {
        require(!automations[msg.sender].On, "Your account is already compounding automatically! GREAT JOB!");
        internalCompoundingFunction(msg.sender, false, false);
    }

    function internalCompoundingFunction(address adr, bool isBuy, bool isAuto) internal {
        User storage user = users[adr];
        require(initialized);
        //require(user.userInvestmentAmt != 0, "You CANNOT compound if you have never bought! Buy first please!");
        require(getMyMoney(adr) != 0, "You CANNOT compound with nothing in your wallet! Buy first please!");
        
        uint256 compoundingMoney = getMyMoney(adr);

        user.moneyPrinters += compoundLogic(adr, compoundingMoney, isBuy, isAuto);

        user.lastPrintTime = block.timestamp;

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

        if(isBuy){
            //Determines whether the user is investing for the first time or not.
            if(user.initialInvestmentAmt == 0) {
                user.initialInvestmentAmt = user.userInvestmentAmt;
                user.lastWithdrawTime = block.timestamp;
                user.WA = msg.sender;
            }
            user.lastBoughtTime = block.timestamp;
        }

        user.claimedMoney = 0;
    }


    function compoundLogic(address adr, uint256 amt, bool isBuy, bool isAuto) internal returns(uint256) {
        uint256 autoFeeAmt = 0;
        if (isAuto) {
            payable (maintenanceFund).transfer(autoCompoundFee(calculateMoneySell(amt)));
            totalAutoEarn += calculateMoneySell(amt);
            autoFeeAmt = autoCompoundFee(amt);
        }
        if (!isBuy || isAuto || !isDev[adr] || !isWhitelisted[adr]){
            //fundToken.transfer(maintenanceFund, maintenanceFee(calculateMoneySell(amt)));
            payable (maintenanceFund).transfer(maintenanceFee(calculateMoneySell(amt)));
            //fundToken.transfer(setupFeeReceiver, serviceFee(calculateMoneySell(amt)));
            payable (setupFeeReceiver).transfer(serviceFee(calculateMoneySell(amt)));
            amt = amt.sub(autoFeeAmt).sub(maintenanceFee(amt)).sub(serviceFee(amt));
        }
        //boost market to nerf miners hoarding
        //uint256 moneyReleased = SafeMath.div(SafeMath.mul(moneyUsed,mrktMoneyCmpndngDivisorBps),BPSDIVIDER);
        marketMoney += SafeMath.div(SafeMath.mul(amt,mrktMoneyCmpndngDivisorBps),BPSDIVIDER);
        totalCompound += calculateMoneySell(amt);

        return SafeMath.div(amt,calculatePrintRate(adr));
    }



    //Auto Compound Functions
    uint256 compoundTimerinHrs = compoundTimer / 3600;
    uint256 mandatoryAutoCmpndIntrvlHrs = mandatoryHoldDays / mandatoryCmpndTimes / 3600;

    function startAutoPrint(uint256 intrvlHrs, uint256 runDays) external nonReentrant {
        require(initialized);
        if (!verifyAutoUser(msg.sender)){
            setNewAutoUserAccount(msg.sender);
        }
        Automation storage aUser = automations[msg.sender];
        require(aUser.WA == msg.sender, "YOU ARE NOT THE ACCOUNT HOLDER");
        require(!aUser.On, "YOU ARE ALREADY AUTO PRINTING! GOOD JOB!!");
        require(intrvlHrs >= compoundTimerinHrs &&
        intrvlHrs <= mandatoryAutoCmpndIntrvlHrs && 
        intrvlHrs <= 24, "Hours are not correct!");
        require(runDays >= 1, "Minimum 1 Day!");
        {
        aUser.On = true;
        aUser.runDays = runDays;
        aUser.runDaysInSecs = runDays * 1 days;
        }
        {
        aUser.intrvlHours = intrvlHrs;
        aUser.intrvlHoursInSecs = intrvlHrs * 1 hours;
        aUser.startTime = block.timestamp;
        }

        internalCompoundingFunction(msg.sender, false, true);
    }

    //Sets up automated compounding user account.
    function setNewAutoUserAccount(address wa) internal {

        automate.push(wa);
        automateIndexes[wa] = automate.length;
        cumulativeAutoUsers++;
        Automation storage aUser = automations[wa];
        aUser.WA = wa;
        aUser.On = false;
     
    }

    function verifyAutoUser(address wa) public view returns(bool) {
        uint256 iterations = 0;
        while(iterations < automate.length) {
            if(automate[iterations] == wa) {return true;}
            iterations++;
        }
        return false;
    }

    function stopAutoPrint() external nonReentrant {
        require(initialized);
        Automation memory aUser = automations[msg.sender];
        require(aUser.WA == msg.sender, "You are NOT the account holder!");
        require(aUser.On, "Your account is NOT automated!");


        uint256 timeAutoWasOn = block.timestamp - aUser.startTime;
        uint256 compoundTimes = timeAutoWasOn.div(aUser.intrvlHoursInSecs);
        uint256 myMoney = users[msg.sender].claimedMoney;
        uint256 myPrinters = users[msg.sender].moneyPrinters;


        for(uint256 j = 1; j <= (compoundTimes + 1); j++ ) {

            uint256 timeLeft = timeAutoWasOn - ((aUser.intrvlHoursInSecs) * j);
            if(timeLeft >= aUser.intrvlHoursInSecs){
                myMoney = SafeMath.mul(aUser.intrvlHoursInSecs,myPrinters);
                myPrinters = compoundLogic(msg.sender, myMoney, false, true);
                myMoney = 0;
            } else {
                myMoney = SafeMath.mul(timeLeft,myPrinters);
                users[msg.sender].moneyPrinters = compoundLogic(msg.sender, myMoney, false, true);
                users[msg.sender].claimedMoney = 0;
            }

            //User Bonus Compound Counter
            if(users[msg.sender].dailyCompoundBonusCounter < compoundBonusMaxTimes) {
            
                if(isDev[msg.sender] || checkPrtnrTokenMinReqHold(msg.sender) == true){
                    users[msg.sender].dailyCompoundBonusCounter++;
                }
                if(checkPrtnrTokenMinReqHold(msg.sender) == false &&
                    users[msg.sender].dailyCompoundBonusCounter < (compoundBonusMaxTimes / 2)){
                    users[msg.sender].dailyCompoundBonusCounter++;
                }
            }
        }
        totalAutoHours += (timeAutoWasOn / 1 hours);
        totalAutoDays = (timeAutoWasOn / 1 hours);
    }


    //Shows current active auto printing accounts
    function getAutomateCounts() public view returns(uint256) {
        return automate.length;
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
        //if((address(this).balance) <= (calculateMoneySell(amtMoney))) {
        if(getBalance() <= (calculateMoneySell(amtMoney))) {
            moneyValue = getBalance();
        }

        if (isWhitelisted[msg.sender] || isDev[msg.sender]) {
            //fundToken.transfer(msg.sender, moneyValue);
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
        uint256 afterTaxes;

                /** if user compounds less than mandatory compound times & 
                less than mandatory hold days have elapsed since cycle began**/
        if (!isWhitelisted[msg.sender] || !isDev[msg.sender]) {
            if (user.dailyCompoundBonusCounter < mandatoryCmpndTimes && 
            block.timestamp < ((user.lastWithdrawTime) + mandatoryHoldDays)) {
        
            //Takes taxes and fees first.
            uint256 penaltySellTaxAmt = penaltySellTax(moneyValue);
            //fundToken.transfer(maintenanceFund, penaltySellTaxAmt);
            payable (maintenanceFund).transfer(penaltySellTaxAmt);
            uint256 serviceFeeAmt = serviceFee(moneyValue);
            //fundToken.transfer(setupFeeReceiver, serviceFeeAmt);
            payable (setupFeeReceiver).transfer(serviceFeeAmt);
            //daily compound bonus count will reset and moneyValue will be deducted with Early Withdrawal tax.
            //minusFromIt(SafeMath.sub(calculateMoneySell(amtMoney),sellTax(calculateMoneySell(amtMoney))),
            //SafeMath.div(SafeMath.mul(SafeMath.sub(calculateMoneySell(amtMoney), sellTax(calculateMoneySell(amtMoney))),
            //erlyWthdrwlTaxBps),BPSDIVIDER));
            afterTaxes = moneyValue.sub(penaltySellTaxAmt).sub(serviceFeeAmt);
            user.dailyCompoundBonusCounter = 0;
            //penaltyPrinters = SafeMath.div(user.moneyPrinters, 2) //CALCULATE PRINTER LOSS PENALTY AMOUNT
            user.moneyPrinters =  (user.moneyPrinters).div(2); //PENALIZE FOR SELLING EARLY            
            //fundToken.transfer(msg.sender, afterTaxes);
            payable (msg.sender).transfer(afterTaxes);
            user.claimedMoney -= amtMoney;
            user.totalWithdrawn += afterTaxes;
            totalWithdrawn += afterTaxes;

            } else {
            //set daily compound bonus count to 0 and moneyValue will remain without deductions.
            user.dailyCompoundBonusCounter = 0;
            
            uint256 tax = sellTax(moneyValue); 
            //fundToken.transfer(maintenanceFund, tax);         
            payable (maintenanceFund).transfer(tax);

            afterTaxes = moneyValue - tax;
            //fundToken.transfer(msg.sender, afterTaxes);  
            payable (msg.sender).transfer(afterTaxes);

            user.claimedMoney -= amtMoney;

            user.totalWithdrawn += afterTaxes;
            totalWithdrawn += afterTaxes;

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