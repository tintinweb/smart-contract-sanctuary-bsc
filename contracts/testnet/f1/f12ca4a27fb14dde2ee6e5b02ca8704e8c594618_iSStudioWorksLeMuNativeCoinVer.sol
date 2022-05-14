/**
iS.StudioWorks Legacy Mutual Bank Decentralized 
 Buy Locked Savings Bond, Earn Interest, Cash Out for Native Network Coins. 
  1.36% base interest Rate
  Up to 15% Referral Bonus. Will go directly to referrer wallet as bonds.
  .06% staking compound bonus every hour, max of 6 days, 144 times. (8.64%)
  Designated Tokens and Partner Token Holders receives extra bonus interest rates
  up to ~% and referral rewards up to 15%, based on how many tokens holding.
  48 hours interest accumulation cut off time.
  .3 BNB minimum investment.
  100 BNB max investment per wallet.
  65% feedback and 50% bonds penalty for withdrawals that are made before mandatory 
  18 consecutive compounds & 6 days since beginning of the cycle. Penalty gets taxed.
  4 hours withdrawal cool time.
  Withdrawals will reset daily compound count back to 0.
*/

// Created by iS.StudioWorks
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./BankSettingsFunctions.sol";
import "./SafeMath.sol";


contract iSStudioWorksLeMuNativeCoinVer is BankSettingsFunctions {
    using SafeMath for uint256;


                    //BSC TESTNET wBNB CA: 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F /** wBNB Testnet **/
                    //BSC wBNB CA:0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c /** wBNB Mainnet **/
	                //0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; /** BUSD Testnet **/
                    //0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; /** BUSD Mainnet **/
    constructor (
        //address fundTokenCA_, 
        address maintenanceFund_,
        uint256 baseRateBps_, // Standard 1.36% = .01%, 10000 = 100%
        uint256 buyWCTaxBps_, //  1 = .01%, 10000 = 100%
        uint256 withdrawTaxBps_, //  1 = .01%, 10000 = 100%
        uint256 compoundBonusBps_, /** Standard Max 30%.  1 = .01%, 10000 = 100%**/
        uint256 compoundBonusMaxTimes_, /** Standard .06% Up to 144 times = Max 8.64% **/
        uint256 bonusCompoundTimer_, /** Standard 12 hours / 2 X 6 days. **/
        uint256 refRewardRateBps_, // Standard 15% Maximum rate.  1 = .01%, 10000 = 100%
        address setupFeeReceiver_,
        uint256 serviceFeeBps_ // 1 = .01%, 10000 = 100%
    ) OwnerAdminSettings() {
        require(marketMoney == 0);
        require(!contractSet, "Contract Already Set");
        require(baseRateBps_ >= 0 && baseRateBps_ >= minRateBps && baseRateBps_ <= maxRateBps && baseRateBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Rate provided is out of range. 0~10000");
        require(buyWCTaxBps_ >= minTaxBps && buyWCTaxBps_ <= maxTaxBps && buyWCTaxBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Tax provided is out of range. 0~1000");
        require(withdrawTaxBps_ >= minTaxBps && withdrawTaxBps_ <= maxTaxBps && withdrawTaxBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Tax provided is out of range. 0~1000");
        require(compoundBonusBps_ >= 0 && compoundBonusBps_ <= maxCompoundBonusBps && compoundBonusBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Bonmsg.senderate provided is out of range. 0~10000");
        require(bonusCompoundTimer_ >= minBonusCompoundTimer && bonusCompoundTimer_ <= maxBonusCompoundTimer, "Min 1 H, Max 144 Hours. 1~144");

        //tokenCA = fundTokenCA_;
        //fundToken = IToken(tokenCA);

        maintenanceFund = maintenanceFund_;

        baseRateBps = baseRateBps_;
        baseRate = calcRate(baseRateBps_);

        buyWCTaxBps = buyWCTaxBps_;
        withdrawTaxBps = withdrawTaxBps_;

        /** Standard Max 30%.  1 = .01%, 10000 = 100%**/
        compoundBonusBps = compoundBonusBps_; //ie. .21% Up to 60 times = Max 30.24%.

        /** .05% Up to 144 times = Max 7.20% **/
        compoundBonusMaxTimes = compoundBonusMaxTimes_;

        /** Standard 12 hours / 2 X 6 days. **/
        bonusCompoundTimer = bonusCompoundTimer_ * 1 hours; /** every hour. **/

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
    

    //Buy Bonds with Coins, Compound LeXC for more Bonds, and Sell LeXC

    function buyBondsWithCoins(address ref) external payable {
        require(initialized);
        if (!verifyUser(msg.sender)){
            setNewUserAccount(msg.sender, ref);
            userAcctInfo.push(msg.sender);
            userInfoIndexes[msg.sender] = userAcctInfo.length;
        }
        User storage user = users[msg.sender];
        require(msg.value >= minInvReq, "Mininum Investment amount not met.");
        require(user.userInvestmentAmt.add(msg.value) <= userMaxInvCap, "Max investment limit reached.");

        //user.lastCM = calculateBuyBonds(msg.value,SafeMath.sub(address(this).balance,msg.value));
        uint256 LeXC = calculateBuyBonds(msg.value, (getBalance() - msg.value));
        if (isWhitelisted[msg.sender] || isDev[msg.sender]) {
            userinfo[msg.sender].currentLeXC += LeXC;

        } else {
            LeXC -= buyWCTax(LeXC);
            //fundToken.transfer(maintenanceFund, buyWCTax(amt));
            payable (maintenanceFund).transfer(buyWCTax(msg.value));
            //fundToken.transfer(setupFeeReceiver, serviceFee(amt));
            payable (setupFeeReceiver).transfer(serviceFee(msg.value));
            userinfo[msg.sender].currentLeXC += LeXC;
        }
        user.claimedLeXC += LeXC;
        totalStaked += msg.value;
        totalDeposits++;

        userinfo[msg.sender].currentLeXC = getMyLeXC(msg.sender);

        //Referrals
        //Sends the referral bonus as bonds.
        if(user.referrer != address(0) && user.initialInvestmentAmt == 0) {
            uint256 refRewardsLeXC;             
            if (isWhitelisted[user.referrer] || isDev[user.referrer] || checkPrtnrTokenMinReqHold(user.referrer)) {
                refRewardsLeXC = SafeMath.div((SafeMath.mul(LeXC, refRewardRateBps)), BPSDIVIDER);
            } else {
                //Referral Reward Rate is half of Max for those who do not hold Gold Tier of Partner Tokens. 
                refRewardsLeXC = SafeMath.div((SafeMath.mul(LeXC, SafeMath.div(refRewardRateBps, 2))), BPSDIVIDER);
            }
            
            if (isWhitelisted[user.referrer] || isDev[user.referrer]){
                users[user.referrer].Bonds = SafeMath.add(users[user.referrer].Bonds, (SafeMath.div((SafeMath.mul((SafeMath.div(refRewardsLeXC,calculateIntRate(user.referrer))), 100)), 100)));    
            } else{
                users[user.referrer].Bonds = SafeMath.add(users[user.referrer].Bonds, (SafeMath.div((SafeMath.mul((SafeMath.div(refRewardsLeXC,calculateIntRate(user.referrer))), 99)), 100)));
                users[setupFeeReceiver].Bonds = SafeMath.add(users[setupFeeReceiver].Bonds, (SafeMath.div((SafeMath.mul((SafeMath.div(refRewardsLeXC,calculateIntRate(user.referrer))), 1)), 100)));
            }
            //Adds to cumulative referral rewards paid out in the native coin value.
            users[user.referrer].refRewardsReceivedTotal += calculateLeXCWithdraw(refRewardsLeXC);
            emit RefRewardsSent(msg.sender, user.referrer, users[user.referrer].Bonds);
            emit RefRewardsReceived(user.referrer, msg.sender, users[user.referrer].Bonds);
            totalRefRewards += calculateLeXCWithdraw(refRewardsLeXC);    
        }
        user.userInvestmentAmt += msg.value;
        internalCompoundingFunction(msg.sender, getMyLeXC(msg.sender), true, false);
    }

    //Compound Functions
    function compoundLeXC(uint256 amtComp) external {
        require(initialized);
        require(!automations[msg.sender].On, "Your account is already compounding automatically! GREAT JOB!");
        internalCompoundingFunction(msg.sender, amtComp, false, false);
    }

    function internalCompoundingFunction(address adr, uint256 amtComp, bool isHWC, bool isAuto) internal {
        User storage user = users[adr];
        require(initialized);
        //require(user.userInvestmentAmt != 0, "You CANNOT compound if you have never bought! Buy first please!");
        require(amtComp <= getMyLeXC(adr), "You CANNOT compound more than you have!");
        require(getMyLeXC(adr) != 0, "You CANNOT compound with nothing in your wallet! Buy first please!");
        
        uint256 compoundingLeXC = amtComp;

        user.Bonds += compoundLogic(adr, compoundingLeXC, isHWC, isAuto);

        user.lastCompoundTime = block.timestamp;

        //User Bonus Compound Counter
        if(block.timestamp.sub(user.lastCompoundTime) >= bonusCompoundTimer &&
            user.dailyCompoundBonusCounter < compoundBonusMaxTimes) {
            
            if(isDev[adr] || checkPrtnrTokenMinReqHold(adr) == true){
                user.dailyCompoundBonusCounter++;
            }
            if(checkPrtnrTokenMinReqHold(adr) == false &&
                user.dailyCompoundBonusCounter < (compoundBonusMaxTimes / 2)){
                    user.dailyCompoundBonusCounter++;
            }
        }

        if(isHWC){
            //Determines whether the user is investing for the first time or not.
            if(user.initialInvestmentAmt == 0) {
                user.initialInvestmentAmt = user.userInvestmentAmt;
                userinfo[msg.sender].initialInvestmentTime;
                user.lastWithdrawTime = block.timestamp;
                user.WA = msg.sender;
            }
            user.lastBuyWithCoinsTime = block.timestamp;
        }

        userinfo[msg.sender].currentLeXC = 0;
    }


    function compoundLogic(address adr, uint256 amt, bool isHWC, bool isAuto) internal returns(uint256) {
        uint256 autoFeeAmt = 0;
        
        if(!isHWC || !isDev[adr] || !isWhitelisted[adr]){
            if (isAuto) {
            //fundToken.transfer(maintenanceFund, autoFee(calculateLeXCWithdraw(amt)));
            payable (maintenanceFund).transfer(autoFee(calculateLeXCWithdraw(amt)));
            totalAutoEarn += calculateLeXCWithdraw(amt);
            autoFeeAmt = autoFee(amt);
            }
            //fundToken.transfer(maintenanceFund, maintenanceFee(calculateLeXCWithdraw(amt)));
            payable (maintenanceFund).transfer(maintenanceFee(calculateLeXCWithdraw(amt)));
            //fundToken.transfer(setupFeeReceiver, serviceFee(calculateLeXCWithdraw(amt)));
            payable (setupFeeReceiver).transfer(serviceFee(calculateLeXCWithdraw(amt)));
            amt = amt.sub(autoFeeAmt).sub(maintenanceFee(amt)).sub(serviceFee(amt));
        }
        
        //boost market to nerf users hoarding
        //uint256 moneyReleased = SafeMath.div(SafeMath.mul(moneyUsed,mrktMoneyCompDivisorBps),BPSDIVIDER);
        marketMoney += SafeMath.div(SafeMath.mul(amt,mrktMoneyCompDivisorBps),BPSDIVIDER);
        totalCompound += calculateLeXCWithdraw(amt);

        return SafeMath.div(amt,calculateIntRate(adr));
    }



    //Auto Compound Functions
    uint256 bonusCompoundTimerinHrs = bonusCompoundTimer / 3600;
    uint256 mandatoryAutoIntrvlHrs = mandatoryHoldDays / mandatoryCompoundTimes / 3600;

    function startAutoCompounding(uint256 intrvlHrs, uint256 runDays) external nonReentrant {
        require(initialized);
        if (!verifyAutoUser(msg.sender)){
            setNewAutoUserAccount(msg.sender);
        }
        Automation storage aUser = automations[msg.sender];
        require(aUser.WA == msg.sender, "YOU ARE NOT THE ACCOUNT HOLDER");
        require(!aUser.On, "YOU ARE ALREADY AUTO COMPOUNDING! GOOD JOB!!");
        require(intrvlHrs >= bonusCompoundTimerinHrs &&
        intrvlHrs <= mandatoryAutoIntrvlHrs && 
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

        internalCompoundingFunction(msg.sender, userinfo[msg.sender].currentLeXC, false, true);
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

    function stopAutoCompounding() external nonReentrant {
        require(initialized);
        Automation storage aUser = automations[msg.sender];
        require(aUser.WA == msg.sender, "You are NOT the account holder!");
        require(aUser.On, "Your account is NOT automated!");

        uint256 timeAutoWasOn = block.timestamp - aUser.startTime;
        uint256 compoundTimes = timeAutoWasOn.div(aUser.intrvlHoursInSecs);
        uint256 myLeXC = userinfo[msg.sender].currentLeXC;
        uint256 myBonds = users[msg.sender].Bonds;
        uint256 timeLeft;


        for(uint256 j = 1; j <= (compoundTimes + 1); j++ ) {

            //Ensure timeLeft doesn't become a negative number.
            if(timeAutoWasOn < aUser.intrvlHoursInSecs){
                timeLeft = block.timestamp - aUser.startTime;
            }else {
                timeLeft = timeAutoWasOn - ((aUser.intrvlHoursInSecs) * j);
            }
            
            if(timeLeft >= aUser.intrvlHoursInSecs){
                myLeXC = SafeMath.mul(aUser.intrvlHoursInSecs,myBonds);
                users[msg.sender].claimedLeXC += myLeXC;
                myBonds += compoundLogic(msg.sender, myLeXC, false, true);
                myLeXC = 0;
            } else {
                userinfo[msg.sender].currentLeXC = SafeMath.mul(timeLeft,myBonds);
                users[msg.sender].claimedLeXC += SafeMath.mul(timeLeft,myBonds);
                users[msg.sender].Bonds = myBonds;
            }

            //User Bonus Compound Counter
            //Makes sure no bonus compound gets counted if the timeAutoWasOn is less than the bonus compound timer.
            if(timeAutoWasOn >= bonusCompoundTimer){
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
            
        }
        totalAutoHours += (timeAutoWasOn / 1 hours);
        totalAutoDays = (timeAutoWasOn / 1 days);
        aUser.On = false;
        aUser.stoppedTime = block.timestamp;
        aUser.lastRunTime = timeAutoWasOn;
        aUser.lastSetRunDays = aUser.runDays;
        aUser.lastIntrvlHours = aUser.intrvlHours;
        aUser.lastStartTime = aUser.startTime;
    }


    //Shows current active auto compounding accounts
    function getAutomateCounts() public view returns(uint256) {
        return automate.length;
    }



    /** Anytime an user withdraws, compound bonus counter resets.
        IF user compounds less than mandatory compound times &
        withdraws less than 6 days have elapsed since cycle began,
        WILL BE PENALIZED WITH EARLY WITHDRAWAL TAX
        AND 50% LOSS ON BONDS **/
    function withdrawLeXC(uint256 amtWd) external nonReentrant {
        require(initialized);
        User storage user = users[msg.sender];
        userinfo[msg.sender].currentLeXC = getMyLeXC(msg.sender);
        require(user.WA == msg.sender, "YOU ARE NOT THE ACCOUNT HOLDER");
        require(block.timestamp >= SafeMath.add(users[msg.sender].lastWithdrawTime,withdrawCooldown), "WITHDRAW COOLDOWN HAS NOT FINISHED YET!");
        require(amtWd <= userinfo[msg.sender].currentLeXC, "YOU CANNOT SELL MORE THAN WHAT YOU HOLD!");

        uint256 LeXCValue = calculateLeXCWithdraw(amtWd);
        //MAKES SURE ONLY SELL WITHIN TVL.
        //if((address(this).balance) <= (calculateLeXCWithdraw(amtWd))) {
        if(getBalance() <= (calculateLeXCWithdraw(amtWd))) {
            LeXCValue = getBalance();
        }


        //uint256 tax;
        uint256 afterTaxes;

                /** if user compounds less than mandatory compound times & 
                less than mandatory hold days have elapsed since cycle began**/
            if (!isDev[msg.sender] && user.dailyCompoundBonusCounter < mandatoryCompoundTimes && 
            block.timestamp < ((user.lastWithdrawTime) + mandatoryHoldDays)) {
        
            //Takes taxes and fees first.
            uint256 penaltyWdTaxAmt = penaltyWdTax(LeXCValue);
            //fundToken.transfer(maintenanceFund, penaltyWdTaxAmt);
            payable (maintenanceFund).transfer(penaltyWdTaxAmt);
            uint256 serviceFeeAmt = serviceFee(LeXCValue);
            //fundToken.transfer(setupFeeReceiver, serviceFeeAmt);
            payable (setupFeeReceiver).transfer(serviceFeeAmt);
            //LeXCValue will be deducted with Early Withdrawal tax.
            //minusFromIt(SafeMath.sub(calculateLeXCWithdraw(amtWd),withdrawTax(calculateLeXCWithdraw(amtWd))),
            //SafeMath.div(SafeMath.mul(SafeMath.sub(calculateLeXCWithdraw(amtWd), withdrawTax(calculateLeXCWithdraw(amtWd))),
            //erlyWthdrwlTaxBps),BPSDIVIDER));
            afterTaxes = LeXCValue.sub(penaltyWdTaxAmt).sub(serviceFeeAmt);
            
            //penaltyBonds = SafeMath.div(user.Bonds, 2) //CALCULATE BONDS LOSS PENALTY AMOUNT
            user.Bonds =  (user.Bonds).div(2); //LOSE HALF THE BONDS FOR SELLING EARLY            
            //fundToken.transfer(msg.sender, afterTaxes);
            payable (msg.sender).transfer(afterTaxes);
            userinfo[msg.sender].currentLeXC -= amtWd;
            user.totalWithdrawn += afterTaxes;
            totalWithdrawn += afterTaxes;

            }else if (isWhitelisted[msg.sender] || isDev[msg.sender]) {
            //fundToken.transfer(msg.sender, LeXCValue);
            payable (msg.sender).transfer(LeXCValue);

            userinfo[msg.sender].currentLeXC -= amtWd;

            user.totalWithdrawn += LeXCValue;
            totalWithdrawn += LeXCValue;
            }else {
            //LeXCValue will remain without deductions.
            
            uint256 tax = withdrawTax(LeXCValue); 
            //fundToken.transfer(maintenanceFund, tax);         
            payable (maintenanceFund).transfer(tax);

            afterTaxes = LeXCValue - tax;
            //fundToken.transfer(msg.sender, afterTaxes);  
            payable (msg.sender).transfer(afterTaxes);

            userinfo[msg.sender].currentLeXC -= amtWd;

            user.totalWithdrawn += afterTaxes;
            totalWithdrawn += afterTaxes;
            }
        
        {
        user.lastWithdrawTime = block.timestamp;
        //set daily compound bonus count to 0
        user.dailyCompoundBonusCounter = 0;
        user.lastCompoundTime = block.timestamp;
        }
        {
        //boost market to nerf users hoarding
        //uint256 moneyReleased = SafeMath.div(SafeMath.mul(amtWd,mrktMoneySellDivisorBps),BPSDIVIDER);
        marketMoney += SafeMath.div(SafeMath.mul(amtWd,mrktMoneySellDivisorBps),BPSDIVIDER);
        }


        //User Counter
        if (user.Bonds == 0) {
            removeUser(msg.sender);
            removeUserInfo(msg.sender);
        }
    }  

}