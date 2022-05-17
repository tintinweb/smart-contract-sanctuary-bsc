/**
iSStudioWorksLegacyMutualNativeCoinVer1.01.sol
iS.StudioWorks Legacy Mutual Bank Decentralized 
 Buy Locked Savings Bond, Earn Interest, Cash Out for Native Network Coins. 
  1.36% base interest Rate
  Up to 15% Referral Bonus. Will go directly to referrer wallet as bonds.
  .06% staking comp bonus every hour, max of 6 days, 144 times. (8.64%)
  Designated Tokens and Partner Token Holders receives extra bonus interest rates
  up to ~% and referral rewards up to 15%, based on how many tokens holding.
  48 hours interest accumulation cut off time.
  .3 BNB minimum investment.
  100 BNB max investment per wallet.
  65% feedback and 50% bonds penalty for withdrawals that are made before mandatory 
  18 consecutive comps & 6 days since beginning of the cycle. Penalty gets taxed.
  4 hours withdrawal cool time.
  Withdrawals will reset daily comp count back to 0.
*/

// Created by iS.StudioWorks
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./BankSettingsFunctions.sol";
import "./SafeMath.sol";
//https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorInterface.sol

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

contract iSWLegacyMutualNCV1_01 is BankSettingsFunctions {
    using SafeMath for uint256;

    AggregatorInterface internal NCP;


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
        uint256 compBonusBps_, /** Standard Max 30%.  1 = .01%, 10000 = 100%**/
        uint256 compBonusMaxTimes_, /** Standard .06% Up to 144 times = Max 8.64% **/
        uint256 bonusCompTimer_, /** Standard 12 hours / 2 X 6 days. **/
        uint256 refRewardRateBps_, // Standard 15% Maximum rate.  1 = .01%, 10000 = 100%
        address setupFeeReceiver_,
        uint256 serviceFeeBps_ // 1 = .01%, 10000 = 100%
    ) OwnerAdminSettings() {
        require(marketMoney == 0);
        require(!contractSet, "Contract Already Set");
        require(baseRateBps_ >= 0 && baseRateBps_ >= minRateBps && baseRateBps_ <= maxRateBps && baseRateBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Rate provided is out of range. 0~10000");
        require(buyWCTaxBps_ >= minTaxBps && buyWCTaxBps_ <= maxTaxBps && buyWCTaxBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Tax provided is out of range. 0~1000");
        require(withdrawTaxBps_ >= minTaxBps && withdrawTaxBps_ <= maxTaxBps && withdrawTaxBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Tax provided is out of range. 0~1000");
        require(compBonusBps_ >= 0 && compBonusBps_ <= maxCompBonusBps && compBonusBps_ <= BPSDIVIDER, "1 = .01%, 10000 = 100%, Bonmsg.senderate provided is out of range. 0~10000");
        require(bonusCompTimer_ >= minBonusCompTimer && bonusCompTimer_ <= maxBonusCompTimer, "Min 1 H, Max 144 Hours. 1~144");

        //tokenCA = fundTokenCA_;
        //fundToken = IToken(tokenCA);

        maintenanceFund = maintenanceFund_;

        baseRateBps = baseRateBps_;
        baseRate = calcRate(baseRateBps_);

        buyWCTaxBps = buyWCTaxBps_;
        withdrawTaxBps = withdrawTaxBps_;

        /** Standard Max 30%.  1 = .01%, 10000 = 100%**/
        compBonusBps = compBonusBps_; //ie. .21% Up to 60 times = Max 30.24%.

        /** .05% Up to 144 times = Max 7.20% **/
        compBonusMaxTimes = compBonusMaxTimes_;

        /** Standard 12 hours / 2 X 6 days. **/
        bonusCompTimer = bonusCompTimer_ * 1 hours; /** every hour. **/

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
    
    //fetches latest BNB/USD price
    //function getPrice() internal view returns (uint256){
    //    IStdReference.ReferenceData memory data = BNBPrice.getReferenceData("BNB","USD");
    //    return data.rate;
    //}

    //Buy Bonds with Coins, Comp LeXC for more Bonds, and Sell LeXC

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
        internalCompFunction(msg.sender, getMyLeXC(msg.sender), true, false);
    }

    //Comp Functions
    function compLeXC(uint256 amtComp) external {
        require(initialized);
        require(!automations[msg.sender].On, "Your account is already comp automatically! GREAT JOB!");
        internalCompFunction(msg.sender, amtComp, false, false);
    }

    function internalCompFunction(address adr, uint256 amtComp, bool isBWC, bool isAuto) internal {
        require(initialized);
        User storage user = users[adr];
        userinfo[adr].currentLeXC = getMyLeXC(adr);
        user.claimedLeXC += getMyLeXC(adr);
        //require(user.userInvestmentAmt != 0, "You CANNOT comp if you have never bought! Buy first please!");
        require(amtComp <= userinfo[adr].currentLeXC, "You CANNOT comp more than what you have!");
        require(getMyLeXC(adr) != 0, "You CANNOT comp with nothing in your wallet! Buy first please!");

        
        user.Bonds += compLogic(adr, amtComp, isBWC, isAuto);


        //User Bonus Comp Counter
        if((block.timestamp - userinfo[adr].lastBonusCompTime) >= bonusCompTimer &&
            user.dailyCompBonusCounter < compBonusMaxTimes) {
            
            if(isDev[adr] || checkPrtnrTokenMinReqHold(adr) == true){
                user.dailyCompBonusCounter++;
            }
            if(checkPrtnrTokenMinReqHold(adr) == false &&
                user.dailyCompBonusCounter < (compBonusMaxTimes / 2)){
                    user.dailyCompBonusCounter++;
            }
        }

        NCP = AggregatorInterface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        //Link to CA: https://docs.chain.link/docs/reference-contracts/
        //BNB-USD MAINNET CA: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        //BNB-USD TESTNET CA: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        //ETH-USD MAINNET CA: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        //ETH-USD KOVAN TESTNET CA: 0x9326BFA02ADD2366b30bacB125260Af641031331
        //ETH-USD RINKEBY TESTNET CA: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e

        if(isBWC){
            //Determines whether the user is investing for the first time or not.
            if(user.initialInvestmentAmt == 0) {
                user.initialInvestmentAmt = user.userInvestmentAmt;
                userinfo[adr].initialLeXCValue = (calculateLeXCWithdraw(1)).mul(uint256(NCP.latestAnswer()));
                userinfo[adr].initialBondValue = (calculateLeXCWithdraw(1 * calculateIntRate(adr))).mul(uint256(NCP.latestAnswer()));
                userinfo[adr].initialInvestmentTime = block.timestamp;
                user.lastWithdrawTime = block.timestamp;
                userinfo[adr].lastBonusCompTime = block.timestamp;
            }
            user.lastBuyWithCoinsTime = block.timestamp;
        }

        //Only updates the bonusCompTimer if enough time has passed for the bonus counter to be reset and
        //the user hasn't reached the max compound bonus.
        if((block.timestamp - userinfo[adr].lastBonusCompTime) > bonusCompTimer && 
            user.dailyCompBonusCounter < compBonusMaxTimes){
            userinfo[adr].lastBonusCompTime = block.timestamp;
            
        }
        user.lastCompTime = block.timestamp;
        userinfo[adr].currentLeXC = 0;
    }


    function compLogic(address adr, uint256 amt, bool isBWC, bool isAuto) internal returns(uint256) {
        uint256 autoFeeAmt = 0;
        
        if(!isBWC || !isDev[adr] || !isWhitelisted[adr]){
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

        totalComp += calculateLeXCWithdraw(amt);

        return SafeMath.div(amt,calculateIntRate(adr));
    }



    //Auto Comp Functions
    uint256 public bonusCompTimerinHrs = bonusCompTimer / 3600;
    uint256 public mandatoryAutoIntrvlHrs = mandatoryHoldDays / mandatoryCompTimes / 3600;

    function startAutoComp(uint256 intrvlHrs, uint256 runDays) external nonReentrant {
        require(initialized);
        if (!verifyAutoUser(msg.sender)){
            setNewAutoUserAccount(msg.sender);
        }
        Automation storage aUser = automations[msg.sender];
        require(aUser.WA == msg.sender, "YOU ARE NOT THE ACCOUNT HOLDER");
        require(!aUser.On, "YOU ARE ALREADY AUTO COMP! GOOD JOB!!");
        require(intrvlHrs >= bonusCompTimerinHrs &&
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

        internalCompFunction(msg.sender, getMyLeXC(msg.sender), false, true);
    }

    //Sets up automated comp user account.
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

    function stopAutoComp(bool simulate) external nonReentrant {
        require(initialized);
        Automation storage aUser = automations[msg.sender];
        require(aUser.WA == msg.sender, "You are NOT the account holder!");
        require(aUser.On, "Your account is NOT automated!");

        if(simulate){
            userinfo[msg.sender].lastSimulTime = block.timestamp;
        }
        //Makes sure timeAutoWasOn does not exceed runDays set by the user
        uint256 timeAutoWasOn;
        if((block.timestamp - aUser.startTime) > aUser.runDaysInSecs){
            timeAutoWasOn = aUser.runDaysInSecs;
        }else{
            timeAutoWasOn = block.timestamp - aUser.startTime;
        }

        uint256 compTimes = timeAutoWasOn.div(aUser.intrvlHoursInSecs);
        uint256 myLeXC = userinfo[msg.sender].currentLeXC;
        uint256 myBonds = users[msg.sender].Bonds;
        uint256 timeLeft = block.timestamp - aUser.startTime;
        uint256 compoundedTime = 0;

        for(uint256 j = 1; j <= (compTimes + 1); j++ ) {

            //Ensure timeLeft doesn't become a negative number.
            if(timeAutoWasOn < aUser.intrvlHoursInSecs){
                timeLeft = block.timestamp - aUser.startTime;
            }
            if(j == (compTimes + 1)){
            //else if(timeLeft < (timeAutoWasOn - ((aUser.intrvlHoursInSecs) * j))){
                timeLeft = timeAutoWasOn - compoundedTime;
            }
            
            if(timeLeft >= aUser.intrvlHoursInSecs){
                myLeXC += SafeMath.mul(aUser.intrvlHoursInSecs,myBonds);
                if(!simulate){
                    users[msg.sender].claimedLeXC += myLeXC;
                    myBonds += compLogic(msg.sender, myLeXC, false, true);
                    users[msg.sender].lastCompTime = block.timestamp;
                }else{
                    //uint256 autoFeeAmt = SafeMath.div(SafeMath.mul(myLeXC,autoFeeBps),BPSDIVIDER);
                    //uint256 mntnceFeeAmt = SafeMath.div(SafeMath.mul(myLeXC,maintenanceFeeBps),BPSDIVIDER);
                    //uint256 srvcFeeAmt = SafeMath.div(SafeMath.mul(myLeXC,serviceFeeBps),BPSDIVIDER);
                    //uint256 amt = myLeXC.sub(autoFeeAmt).sub(maintenanceFee(amt)).sub(serviceFee(amt));
                    myBonds += SafeMath.div((myLeXC.sub(SafeMath.div(SafeMath.mul(myLeXC,autoFeeBps),BPSDIVIDER)).sub
                    (SafeMath.div(SafeMath.mul(myLeXC,maintenanceFeeBps),BPSDIVIDER)).sub
                    (SafeMath.div(SafeMath.mul(myLeXC,serviceFeeBps),BPSDIVIDER))
                    ),calculateIntRate(msg.sender));
                }

                myLeXC = 0;
                //User Bonus Compound Counter
                //Only when it's not simulating
                if(!simulate){
                    if(users[msg.sender].dailyCompBonusCounter < compBonusMaxTimes) {
            
                        if(isDev[msg.sender] || checkPrtnrTokenMinReqHold(msg.sender) == true){
                        users[msg.sender].dailyCompBonusCounter++;
                        }
                        if(checkPrtnrTokenMinReqHold(msg.sender) == false &&
                        users[msg.sender].dailyCompBonusCounter < (compBonusMaxTimes / 2)){
                        users[msg.sender].dailyCompBonusCounter++;
                        }
                    }
                }
                timeLeft = timeAutoWasOn - ((aUser.intrvlHoursInSecs) * j);
                compoundedTime += aUser.intrvlHoursInSecs;
            }else {
                if(!simulate){
                    userinfo[msg.sender].simulLeXC = 0;
                    userinfo[msg.sender].currentLeXC = SafeMath.mul(timeLeft,myBonds);
                    users[msg.sender].claimedLeXC += SafeMath.mul(timeLeft,myBonds);

                    userinfo[msg.sender].simulBonds = 0;
                    users[msg.sender].Bonds = myBonds;
                }else{
                    userinfo[msg.sender].simulLeXC = SafeMath.mul(timeLeft,myBonds);
                    userinfo[msg.sender].simulBonds = myBonds;
                }

            }
            
        }

        //Only when it's not simulating
        if(!simulate){
            //Only updates the bonusCompTimer if enough time has passed for the bonus counter to be reset and
            //the user hasn't reached the max compound bonus.
            if((block.timestamp - userinfo[msg.sender].lastBonusCompTime) > bonusCompTimer && 
                users[msg.sender].dailyCompBonusCounter < compBonusMaxTimes){
                userinfo[msg.sender].lastBonusCompTime = block.timestamp;
            }
        
            totalAutoHours += (timeAutoWasOn / 1 hours);
            totalAutoDays += (timeAutoWasOn / 1 days);
            aUser.On = false;
            aUser.stoppedTime = block.timestamp;
            aUser.lastRunTime = timeAutoWasOn;
            aUser.lastSetRunDays = aUser.runDays;
            aUser.lastIntrvlHours = aUser.intrvlHours;
            aUser.lastStartTime = aUser.startTime;
        }

    }


    //Shows current active auto comp accounts
    function getAutomateCounts() public view returns(uint256) {
        return automate.length;
    }



    /** Anytime an user withdraws, comp bonus counter resets.
        IF user comps less than mandatory comp times &
        withdraws less than 6 days have elapsed since cycle began,
        WILL BE PENALIZED WITH EARLY WITHDRAWAL TAX
        AND 50% LOSS ON BONDS **/
    function withdrawLeXC(uint256 amtWd) external nonReentrant {
        require(initialized);
        User storage user = users[msg.sender];
        userinfo[msg.sender].currentLeXC = getMyLeXC(msg.sender);
        user.claimedLeXC += getMyLeXC(msg.sender);
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

                /** if user comps less than mandatory comp times & 
                less than mandatory hold days have elapsed since cycle began**/
            if (!isDev[msg.sender] && user.dailyCompBonusCounter < mandatoryCompTimes && 
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
        //set daily comp bonus count to 0
        user.dailyCompBonusCounter = 0;
        user.lastCompTime = block.timestamp;
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