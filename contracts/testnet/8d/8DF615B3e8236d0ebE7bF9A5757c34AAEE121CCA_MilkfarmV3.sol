/*
    Milkfarm V3 - BSC BNB Miner
    Developed by Kraitor <TG: kraitordev>
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BasicLibraries/SafeMath.sol";
import "./BasicLibraries/Auth.sol";
import "./BasicLibraries/IBEP20.sol";
import "./Libraries/MinerBasic.sol";
import "./Libraries/Airdrop.sol";
import "./Libraries/AutoEXE.sol";
import "./Libraries/InvestorsManager.sol";
import "./Libraries/Algorithm.sol";
import "./Libraries/MilkfarmV3ConfigIface.sol";
import "./Libraries/EmergencyWithdrawal.sol";
import "./Libraries/Migration.sol";
import "./Libraries/Testable.sol";

contract MilkfarmV3 is Auth, MinerBasic, AutoEXE, Algorithm, Airdrop, InvestorsManager, EmergencyWithdrawal, Migration, Testable {
    using SafeMath for uint256;
    using SafeMath for uint64;
    using SafeMath for uint32;
    using SafeMath for uint8;

    //External config iface (Roi events)
    milkfarmV3ConfigIface reIface;

    constructor(address _airdropToken, address _autoAdd, address _angAdr, address _recIface, address timerAddr) Auth(msg.sender) Testable(timerAddr) {
        recAdd = payable(msg.sender);
        autoAdd = payable(_autoAdd);
        angAdd = payable(_angAdr);
        airdropToken = _airdropToken;
        reIface = milkfarmV3ConfigIface(address(_recIface));
    }


    //CONFIG////////////////
    function setAirdropToken(address _airdropToken) public override authorized { airdropToken =_airdropToken; }
    function enableClaim(bool _enableClaim) public override authorized { claimEnabled = _enableClaim; }
    function setExecutionHour(uint32 exeHour) public override authorized { executionHour = exeHour; }
    function setMaxInvestorsPerExecution(uint64 maxInvPE) public override authorized { maxInvestorPerExecution = maxInvPE; }
    function enableSingleMode(bool _enable) public override authorized { enabledSingleMode = _enable; }
    function enablenMaxSellsRestriction(bool _enable) public override authorized { nMaxSellsRestriction = _enable; }
    function openToPublic(bool _openPublic) public override authorized { openPublic = _openPublic; }
    function setExternalConfigAddress(address _recIface) public authorized { reIface = milkfarmV3ConfigIface(address(_recIface)); }
    function renounceUnstuck() public authorized { renounce_unstuck = true; }
    function disableMigration() public override authorized { migrationEnabled = false; }
    function setAutotax(uint8 _autoFeeTax, address _autoAdd) public override authorized {
        require(_autoFeeTax <= 5);
        autoFeeTax = _autoFeeTax;
        autoAdd = payable(_autoAdd);
    }
    function setDevTax(uint8 _devFeeVal, address _devAdd) public authorized {
        require(_devFeeVal <= 5);
        devFeeVal = _devFeeVal;
        recAdd = payable(_devAdd);
    }
    function setTaxForAngel(uint8 _angTax, address _angAdr) public authorized {
        require(_angTax <= 5 && _angTax >= 2);
        angTax = _angTax;
        angAdd = payable(_angAdr);
    }
    function setAlgorithmLimits(uint8 _minDaysSell, uint8 _maxDaysSell) public override authorized {
        require(_minDaysSell >= 0 && _maxDaysSell <= 21, 'Limits not allowed');
        minDaysSell = _minDaysSell;
        maxDaysSell = _maxDaysSell;
    }
    function setEmergencyWithdrawPenalty(uint256 _penalty) public override authorized {
        require(_penalty < 100);
        emergencyWithdrawPenalty = _penalty;
    }
    function setMaxSellPc(uint256 _maxSellNum, uint256 _maxSellDiv) public authorized {
        require(uint256(1000).mul(_maxSellNum) >= _maxSellDiv, "Min max sell is 0.1% of TLV");
        maxSellNum = _maxSellNum;
        maxSellDiv = _maxSellDiv;
    }
    function setRewardsPercentage(uint32 _percentage) public authorized {
        require(_percentage >= 15, 'Percentage cannot be less than 15');
        rewardsPercentage = _percentage;
    }    
    function unstuck_bnb(uint256 _amount) public authorized { 
        require(!renounce_unstuck, "Unstuck renounced, can not withdraw funds"); //Testing/Security meassure
        payable(msg.sender).transfer(_amount); 
    }
    ////////////////////////

    //MIGRATION/////////////
    function restoreBase(uint256 _marketMilks) public override authorized { 
        require(migrationEnabled, 'Migration disabled');
        marketMilks = _marketMilks; 
    }

    function claimRestore() public override {
        require(migrationEnabled, 'Migration disabled');
        require(false, 'Not implemented');
        //Get milkers and referrals calling v2 miner
    }

    function performMigration(address [] memory address_restore, uint256 [] memory milkers) public override authorized {
        require(migrationEnabled, 'Migration disabled');
        require(address_restore.length == milkers.length, 'Arrays lengths does not match');

        for(uint _i = 0; _i < address_restore.length; _i++){
            initializeInvestor(address_restore[_i]);
            setInvestorHiredMilkers(address_restore[_i], milkers[_i]);
            //setInvestorReferral(address_restore[_i], referrals[_i]);
        }
    }
    ////////////////////////

    //AIRDROPS//////////////
    function claimMilkers(address ref) public override {
        require(initialized);
        require(claimEnabled || isAuthorized(msg.sender), 'Claim still not available');

        uint256 airdropTokens = IBEP20(airdropToken).balanceOf(msg.sender);
        IBEP20(airdropToken).transferFrom(msg.sender, address(this), airdropTokens); //The token has to be approved first
        IBEP20(airdropToken).burn(airdropTokens); //Tokens burned

        //MILKBNB is used to buy pigs (miners)
        uint256 pigsClaimed = calculateHireMilkers(airdropTokens, address(this).balance);

        setInvestorClaimedMilks(msg.sender, SafeMath.add(getInvestorData(msg.sender).claimedMilks, pigsClaimed));
        rehireMilkers(msg.sender, ref, true);

        emit ClaimMilkers(msg.sender, pigsClaimed, airdropTokens);
    }
    ////////////////////////

    //AUTO EXE//////////////
    function executeN(uint256 nInvestorsExecute) public override {
        require(initialized);
        require(msg.sender == autoAdd || isAuthorized(msg.sender), 'Only auto account can trigger this');    

        uint256 _daysForSelling = this.daysForSelling(getCurrentTime());
        uint256 _nSells = this.totalSoldsToday();
        uint64 nInvestors = getNumberInvestors();
        uint256 _nSellsMax = SafeMath.div(nInvestors, _daysForSelling).add(1);
        if(!nMaxSellsRestriction){ _nSellsMax = type(uint256).max; }
        uint256 _loopStop = investorsNextIndex.add(min(nInvestorsExecute, nInvestors));

        for(uint64 i = investorsNextIndex; i < _loopStop; i++) {
            
            investor memory investorData = getInvestorData(investorsNextIndex);
            bool _canSell = canSell(investorData.investorAddress, _daysForSelling);
            if(_canSell == false || _nSells >= _nSellsMax){
                rehireMilkers(investorData.investorAddress, address(0), false);
            }else{
                _nSells++;
                sellMilks(investorData.investorAddress);
            }

            investorsNextIndex++; //Next iteration we begin on first rehire or zero
            if(investorsNextIndex == nInvestors){
                investorsNextIndex = 0;
            }
        }

        emit Execute(msg.sender, nInvestors, _daysForSelling, _nSells, _nSellsMax);
    }

    function execute() public override {
        require(initialized);
        require(msg.sender == autoAdd || isAuthorized(msg.sender), 'Only auto account can trigger this');    

        uint256 _daysForSelling = this.daysForSelling(getCurrentTime());
        uint256 _nSells = this.totalSoldsToday();
        uint64 nInvestors = getNumberInvestors();
        uint256 _nSellsMax = SafeMath.div(nInvestors, _daysForSelling).add(1);
        if(!nMaxSellsRestriction){ _nSellsMax = type(uint256).max; }
        uint256 _loopStop = investorsNextIndex.add(min(maxInvestorPerExecution, nInvestors));

        for(uint64 i = investorsNextIndex; i < _loopStop; i++) {
            
            investor memory investorData = getInvestorData(investorsNextIndex);
            bool _canSell = canSell(investorData.investorAddress, _daysForSelling);
            if(_canSell == false || _nSells >= _nSellsMax){
                rehireMilkers(investorData.investorAddress, address(0), false);
            }else{
                _nSells++;
                sellMilks(investorData.investorAddress);
            }

            investorsNextIndex++; //Next iteration we begin on first rehire or zero
            if(investorsNextIndex == nInvestors){
                investorsNextIndex = 0;
            }
        }

        emit Execute(msg.sender, nInvestors, _daysForSelling, _nSells, _nSellsMax);
    }

    function executeAddresses(address [] memory investorsRun, bool forceSell) public override {
        require(initialized);
        require(msg.sender == autoAdd || isAuthorized(msg.sender), 'Only auto account can trigger this');  

        uint256 _daysForSelling = this.daysForSelling(getCurrentTime());
        uint256 _nSells = this.totalSoldsToday();
        uint64 nInvestors = getNumberInvestors();
        uint256 _nSellsMax = SafeMath.div(nInvestors, _daysForSelling).add(1);    
        if(!nMaxSellsRestriction){ _nSellsMax = type(uint256).max; }  

        for(uint64 i = 0; i < investorsRun.length; i++) {
            address _investorAdr = investorsRun[i];
            investor memory investorData = getInvestorData(_investorAdr);
            bool _canSell = canSell(investorData.investorAddress, _daysForSelling);
            if((_canSell == false || _nSells >= _nSellsMax) && forceSell == false){
                rehireMilkers(investorData.investorAddress, address(0), false);
            }else{
                _nSells++;
                sellMilks(investorData.investorAddress);
            }
        }

        emit Execute(msg.sender, nInvestors, _daysForSelling, _nSells, _nSellsMax);
    }

    function executeSingle() public override {
        require(initialized);
        require(enabledSingleMode || isAuthorized(msg.sender), 'Single mode not enabled');
        require(openPublic || isAuthorized(msg.sender), 'Miner still not opened');

        uint256 _daysForSelling = this.daysForSelling(getCurrentTime());        
        uint256 _nSellsMax = SafeMath.div(getNumberInvestors(), _daysForSelling).add(1);
        if(!nMaxSellsRestriction){ _nSellsMax = type(uint256).max; }
        uint256 _nSells = this.totalSoldsToday(); //How much investors sold today?
        bool _canSell = canSell(msg.sender, _daysForSelling);
        bool rehire = _canSell == false || _nSells >= _nSellsMax;

        if(rehire){
            rehireMilkers(msg.sender, address(0), false);
        }else{
            sellMilks(msg.sender);
        }

        emit ExecuteSingle(msg.sender, rehire);
    }

    function getExecutionPeriodicity() public view override returns(uint64) {
        uint64 nInvestors = getNumberInvestors();
        uint256 _div = min(nInvestors, max(maxInvestorPerExecution, 20));
        uint64 nExecutions = uint64(nInvestors.div(_div));
        if(nInvestors % _div != 0){ nExecutions++; }
        return uint64(minutesDay.div(nExecutions)); 
        //Executions periodicity in minutes (sleep after each execution)
        //We have to sell/rehire for all investors each day
    }
    ////////////////////////


    //Emergency withdraw////
    function emergencyWithdraw() public override {
        require(initialized);
        require(getInvestorData(msg.sender).withdrawal < getInvestorData(msg.sender).investment, 'You already recovered your investment');
        require(getInvestorData(msg.sender).hiredMilkers > 1, 'You cant use this function');
        uint256 amountToWithdraw = getInvestorData(msg.sender).investment.sub(getInvestorData(msg.sender).withdrawal);
        uint256 amountToWithdrawAfterTax = amountToWithdraw.mul(uint256(100).sub(emergencyWithdrawPenalty)).div(100);
        require(amountToWithdrawAfterTax > 0, 'There is nothing to withdraw');
        uint256 amountToWithdrawTaxed = amountToWithdraw.sub(amountToWithdrawAfterTax);

        addInvestorWithdrawal(msg.sender, amountToWithdraw);
        acumWithdrawal(getCurrentTime(), amountToWithdraw);
        setInvestorHiredMilkers(msg.sender, 1); //Burn

        if(amountToWithdrawTaxed > 0){
            recAdd.transfer(amountToWithdrawTaxed);
        }

        payable (msg.sender).transfer(amountToWithdrawAfterTax);

        emit EmergencyWithdraw(getInvestorData(msg.sender).investment, getInvestorData(msg.sender).withdrawal, amountToWithdraw, amountToWithdrawAfterTax, amountToWithdrawTaxed);
    }
    ////////////////////////


    //BASIC/////////////////
    function seedMarket() public payable authorized {
        require(marketMilks == 0);
        initialized = true;
        marketMilks = 108000000000;
    }

    function hireMilkers(address ref) public payable {
        require(initialized);
        require(openPublic || isAuthorized(msg.sender), 'Miner still not opened');

        _hireMilkers(ref, msg.sender, msg.value);
    }

    function rehireMilkers(address _sender, address ref, bool isClaim) private {
        require(initialized);

        if(ref == _sender) {
            ref = address(0);
        }
                
        if(getInvestorData(_sender).referral == address(0) && getInvestorData(_sender).referral != _sender) {
            getInvestorData(_sender).referral = ref;
        }
        
        uint256 milksUsed = getMyMilks(_sender);
        uint256 newMilkers = SafeMath.div(milksUsed,MILKS_TO_HATCH_1MILKER);

        //We need this to iterate later on auto executions
        if(newMilkers > 0 && getInvestorData(_sender).hiredMilkers == 0){            
            initializeInvestor(_sender);
        }

        setInvestorHiredMilkers(_sender, SafeMath.add(getInvestorData(_sender).hiredMilkers, newMilkers));
        setInvestorClaimedMilks(_sender, 0);
        setInvestorLastHire(_sender, getCurrentTime());
        
        //send referral milks
        setInvestorMilksByReferral(getReferralData(_sender).investorAddress, getReferralData(_sender).referralMilks.add(SafeMath.div(milksUsed, 8)));
        setInvestorClaimedMilks(getReferralData(_sender).investorAddress, SafeMath.add(getReferralData(_sender).claimedMilks, SafeMath.div(milksUsed, 8))); 
        
        //boost market to nerf miners hoarding
        if(isClaim == false){
            marketMilks=SafeMath.add(marketMilks, SafeMath.div(milksUsed, 5));
        }

        emit RehireMilkers(_sender, newMilkers, getInvestorData(_sender).hiredMilkers, getNumberInvestors(), getReferralData(_sender).claimedMilks, marketMilks, milksUsed);
    }
    
    function sellMilks(address _sender) private {
        require(initialized);

        uint256 milksLeft = 0;
        uint256 hasMilks = getMyMilks(_sender);
        uint256 milksValue = calculateMilkSell(hasMilks);
        (milksValue, milksLeft) = capToMaxSell(milksValue, hasMilks);
        uint256 sellTax = calculateBuySellTax(milksValue);
        uint256 penalty = getBuySellPenalty();

        setInvestorClaimedMilks(_sender, milksLeft);
        setInvestorLastHire(_sender, getCurrentTime());
        marketMilks = SafeMath.add(marketMilks,hasMilks);
        payBuySellTax(sellTax);
        addInvestorWithdrawal(_sender, SafeMath.sub(milksValue, sellTax));
        acumWithdrawal(getCurrentTime(), SafeMath.sub(milksValue, sellTax));
        payable (_sender).transfer(SafeMath.sub(milksValue,sellTax));

        // Push the timestamp
        setInvestorSellsTimestamp(_sender, getCurrentTime());
        setInvestorNsells(_sender, getInvestorData(_sender).nSells.add(1));
        registerSell();

        emit Sell(_sender, milksValue, SafeMath.sub(milksValue,sellTax), penalty);
    }

    function _hireMilkers(address _ref, address _sender, uint256 _amount) private {        
        uint256 milksBought = calculateHireMilkers(_amount, SafeMath.sub(address(this).balance, _amount));
            
        if(reIface.needUpdateEventBoostTimestamps()){
            reIface.updateEventsBoostTimestamps();
        }

        uint256 milksBSFee = calculateBuySellTax(milksBought);
        milksBought = SafeMath.sub(milksBought, milksBSFee);
        uint256 fee = calculateBuySellTax(_amount);        
        payBuySellTax(fee);
        setInvestorClaimedMilks(_sender, SafeMath.add(getInvestorData(_sender).claimedMilks, milksBought));
        addInvestorInvestment(_sender, _amount);
        acumInvestment(getCurrentTime(), _amount);
        rehireMilkers(_sender, _ref, false);

        emit Hire(_sender, milksBought, _amount);
    }

    function canSell(address _sender, uint256 _daysForSelling) public view returns (bool) {
        uint256 _lastSellTimestamp = 0;
        if(getInvestorData(_sender).sellsTimestamp > 0){
            _lastSellTimestamp = getInvestorData(_sender).sellsTimestamp;
        }
        else{
            return false;            
        }
        return getCurrentTime() > _lastSellTimestamp && getCurrentTime().sub(_lastSellTimestamp) > _daysForSelling.mul(1 days);
    }

    function totalSoldsToday() public view returns (uint256) {
        //Last 24h
        uint256 _soldsToday = 0;
        uint256 _time = getCurrentTime();
        uint256 hourTimestamp = getCurrHourTimestamp(_time);
        for(uint i=0; i < 24; i++){
            _soldsToday += dayHourSells[hourTimestamp];
            hourTimestamp -= 3600;
        }

        return _soldsToday;
    }

    function registerSell() private { dayHourSells[getCurrHourTimestamp(getCurrentTime())]++; }

    function capToMaxSell(uint256 milksValue, uint256 milks) public view returns(uint256, uint256){
        uint256 maxSell = address(this).balance.mul(maxSellNum).div(maxSellDiv);
        if(maxSell >= milksValue){
            return (milksValue, 0);
        }
        else{
            uint256 nMilksHire = calculateHireMilkersSimpleNoEvent(milksValue.sub(maxSell));
            if(nMilksHire <= milks){
                return (maxSell, milks.sub(nMilksHire));
            }
            else{
                return (maxSell, 0);
            }
        }     
    }

    function getRewardsPercentage() public view returns (uint32) { return rewardsPercentage; }

    function getMarketMilks() public view returns (uint256) {
        return marketMilks;
    }
    
    function milksRewards(address adr) public view returns(uint256) {
        uint256 hasMilks = getMyMilks(adr);
        uint256 milksValue = calculateMilkSell(hasMilks);
        return milksValue;
    }

    function milksRewardsIncludingTaxes(address adr) public view returns(uint256) {
        uint256 hasMilks = getMyMilks(adr);
        (uint256 milksValue,) = calculateMilkSellIncludingTaxes(hasMilks);
        return milksValue;
    }

    function getBuySellPenalty() public view returns (uint256) {
        return SafeMath.add(SafeMath.add(autoFeeTax, devFeeVal), angTax);
    }

    function calculateBuySellTax(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, getBuySellPenalty()), 100);
    }

    function payBuySellTax(uint256 amountTaxed) private {        
        uint256 buySellPenalty = getBuySellPenalty();        
        payable(recAdd).transfer(amountTaxed.mul(devFeeVal).div(buySellPenalty));        
        payable(autoAdd).transfer(amountTaxed.mul(autoFeeTax).div(buySellPenalty));        
        payable(angAdd).transfer(amountTaxed.mul(angTax).div(buySellPenalty));
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        uint256 valueTrade = SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
        if(rewardsPercentage > 15) {
            return SafeMath.div(SafeMath.mul(valueTrade,rewardsPercentage), 15);
        }

        return valueTrade;
    }
    
    function calculateMilkSell(uint256 milks) public view returns(uint256) {
        if(milks > 0){
            return calculateTrade(milks, marketMilks, address(this).balance);
        }
        else{
            return 0;
        }
    }

    function calculateMilkSellIncludingTaxes(uint256 milks) public view returns(uint256, uint256) {
        uint256 totalTrade = calculateTrade(milks, marketMilks, address(this).balance);
        uint256 penalty = getBuySellPenalty();
        uint256 sellTax = calculateBuySellTax(totalTrade);

        return (
            SafeMath.sub(totalTrade, sellTax),
            penalty
        );
    }
    
    function calculateHireMilkers(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return reIface.applyROIEventBoost(calculateHireMilkersNoEvent(eth, contractBalance));
    }

    function calculateHireMilkersNoEvent(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketMilks);
    }
    
    function calculateHireMilkersSimple(uint256 eth) public view returns(uint256) {
        return calculateHireMilkers(eth, address(this).balance);
    }

    function calculateHireMilkersSimpleNoEvent(uint256 eth) public view returns(uint256) {
        return calculateHireMilkersNoEvent(eth, address(this).balance);
    }
    
    function isInitialized() public view returns (bool) {
        return initialized;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyMilks(address adr) public view returns(uint256) {
        return SafeMath.add(getInvestorData(adr).claimedMilks, getMilksSinceLastHire(adr));
    }
    
    function getMilksSinceLastHire(address adr) public view returns(uint256) {        
        uint256 secondsPassed=min(MILKS_TO_HATCH_1MILKER, SafeMath.sub(getCurrentTime(), getInvestorData(adr).lastHire));
        return SafeMath.mul(secondsPassed, getInvestorData(adr).hiredMilkers);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? b : a;
    }

    receive() external payable {}
    ////////////////////////
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BasicLibraries/Auth.sol";
import "./BasicLibraries/SafeMath.sol";

/**
 * @title Universal store of current contract time for testing environments.
 */
contract Timer is Auth {
    using SafeMath for uint256;
    uint256 private currentTime;

    bool enabled = false;

    constructor() Auth(msg.sender) { }

    /**
     * @notice Sets the current time.
     * @dev Will revert if not running in test mode.
     * @param time timestamp to set `currentTime` to.
     */
    function setCurrentTime(uint256 time) external authorized {
        require(time >= currentTime, "Return to the future Doc!");
        currentTime = time;
    }

    function enable(bool _enabled) external authorized {
        require(enabled == false, 'Can not be disabled');
        enabled = _enabled;
    }

    function increaseDays(uint256 _days) external authorized {
        currentTime = getCurrentTime().add(uint256(1 days).mul(_days));
    }

    function increaseMinutes(uint256 _minutes) external authorized {
        currentTime = getCurrentTime().add(uint256(1 minutes).mul(_minutes));
    }

    function increaseSeconds(uint256 _seconds) external authorized {
        currentTime = getCurrentTime().add(uint256(1 seconds).mul(_seconds));
    }

    /**
     * @notice Gets the current time. Will return the last time set in `setCurrentTime` if running in test mode.
     * Otherwise, it will return the block timestamp.
     * @return uint256 for the current Testable timestamp.
     */
    function getCurrentTime() public view returns (uint256) {
        if(enabled){
            return currentTime;
        }
        else{
            return block.timestamp;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./../Timer.sol";

/**
 * @title Base class that provides time overrides, but only if being run in test mode.
 */
abstract contract Testable {
    // If the contract is being run on the test network, then `timerAddress` will be the 0x0 address.
    // Note: this variable should be set on construction and never modified.
    address public timerAddress;

    /**
     * @notice Constructs the Testable contract. Called by child contracts.
     * @param _timerAddress Contract that stores the current time in a testing environment.
     * Must be set to 0x0 for production environments that use live time.
     */
    constructor(address _timerAddress) {
        timerAddress = _timerAddress;
    }

    /**
     * @notice Reverts if not running in test mode.
     */
    modifier onlyIfTest {
        require(timerAddress != address(0x0));
        _;
    }

    /**
     * @notice Sets the current time.
     * @dev Will revert if not running in test mode.
     * @param time timestamp to set current Testable time to.
     */
    // function setCurrentTime(uint256 time) external onlyIfTest {
    //     Timer(timerAddress).setCurrentTime(time);
    // }

    /**
     * @notice Gets the current time. Will return the last time set in `setCurrentTime` if running in test mode.
     * Otherwise, it will return the block timestamp.
     * @return uint for the current Testable timestamp.
     */
    function getCurrentTime() public view returns (uint256) {
        if (timerAddress != address(0x0)) {
            return Timer(timerAddress).getCurrentTime();
        } else {
            return block.timestamp;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract MinerBasic {

    event Hire(address indexed adr, uint256 milks, uint256 amount);
    event Sell(address indexed adr, uint256 milks, uint256 amount, uint256 penalty);
    event RehireMilkers(address _investor, uint256 _newMilkers, uint256 _hiredMilkers, uint256 _nInvestors, uint256 _referralMilks, uint256 _marketMilks, uint256 _milksUsed);

    bool internal renounce_unstuck = false; //Testing/security meassure, owner should renounce after checking everything is working fine
    uint32 internal rewardsPercentage = 15; //Rewards increase to apply (hire/sell)
    uint32 internal MILKS_TO_HATCH_1MILKER = 576000; //576000/24*60*60 = 6.666 days to recover your investment (6.666*15 = 100%)
    uint16 internal PSN = 10000;
    uint16 internal PSNH = 5000;
    bool internal initialized = false;
    uint256 internal marketMilks; //This variable is responsible for inflation.
                                    //Number of milks on market (sold) rehire adds 20% of milks rehired

    address payable internal recAdd;
    uint8 internal devFeeVal = 1; //Dev fee
    address payable internal angAdd;
    uint8 internal angTax = 2; //Tax for lottery

    uint256 public maxSellNum = 20; //Max sell TVL num
    uint256 public maxSellDiv = 1000; //Max sell TVL div //For example: 20 and 1000 -> 20/1000 = 2/100 = 2% of TVL max sell

    //uint8 internal sellTaxVal = 4; //Sell fee //REMOVED, only have auto and dev fee

    // This function is called by anyone who want to contribute to TVL
    function ContributeToTVL() public payable { }

    //Open/close miner
    bool public openPublic = false;
    function openToPublic(bool _openPublic) public virtual;

    constructor () {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface milkfarmV3ConfigIface {
    //Apply ROI event boost to the amount specified
    function applyROIEventBoost(uint256 amount) external view returns (uint256); 
    //Is needed to update CA timestamps?
    function needUpdateEventBoostTimestamps() external view returns (bool); 
    //Update CA timestamps
    function updateEventsBoostTimestamps() external; 
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract Migration {
    
    bool public migrationEnabled = true;

    //event MigrationDone(address _sender, uint256 _milkersAirdropped, uint256 _mmBNB);

    //Disable migration once we finished
    function disableMigration() public virtual;

    //Restore base miner data
    function restoreBase(uint256 marketMilks) public virtual;

    //Used for people in order to perform migration
    function claimRestore() public virtual;

    //Used for software to auto migrate //Initialize user and set milkers
    function performMigration(address [] memory adress_restore, uint256 [] memory milkers) public virtual;

    constructor() {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract InvestorsManager {

    //INVESTORS DATA
    uint64 private nInvestors = 0;
    mapping (address => investor) private investors; //Investor data mapped by address
    mapping (uint64 => address) private investors_addresses; //Investors addresses mapped by index

    struct investor {
        address investorAddress; //Investor address
        uint256 investment; //Total investor investment on miner (real BNB, presales/airdrops not taken into account)
        uint256 withdrawal; //Total investor withdraw BNB from the miner
        uint256 hiredMilkers; //Total hired pigs (miners)
        uint256 claimedMilks; //Total milks claimed (produced by miners)
        uint256 lastHire; //Last time you hired pigs
        uint256 sellsTimestamp; //Last time you sold your milks
        uint256 nSells; //Number of sells you did
        uint256 referralMilks; //Number of milks you got from people that used your referral address
        address referral; //Referral address you used for joining the miner
    }

    function initializeInvestor(address adr) internal {
        investors_addresses[nInvestors] = adr;
        investors[adr].investorAddress = adr;
        investors[adr].sellsTimestamp = block.timestamp;
        nInvestors++;
    }

    function getNumberInvestors() public view returns(uint64) { return nInvestors; }

    function getInvestorData(uint64 investor_index) public view returns(investor memory) { return investors[investors_addresses[investor_index]]; }

    function getInvestorData(address addr) public view returns(investor memory) { return investors[addr]; }

    function getReferralData(address addr) public view returns(investor memory) { return investors[investors[addr].referral]; }

    function setInvestorAddress(address addr) internal { investors[addr].investorAddress = addr; }

    function addInvestorInvestment(address addr, uint256 investment) internal { investors[addr].investment += investment; }

    function addInvestorWithdrawal(address addr, uint256 withdrawal) internal { investors[addr].withdrawal += withdrawal; }

    function setInvestorHiredMilkers(address addr, uint256 hiredMilkers) internal { investors[addr].hiredMilkers = hiredMilkers; }

    function setInvestorClaimedMilks(address addr, uint256 claimedMilks) internal { investors[addr].claimedMilks = claimedMilks; }

    function setInvestorMilksByReferral(address addr, uint256 milks) internal { investors[addr].referralMilks = milks; }

    function setInvestorLastHire(address addr, uint256 lastHire) internal { investors[addr].lastHire = lastHire; }

    function setInvestorSellsTimestamp(address addr, uint256 sellsTimestamp) internal { investors[addr].sellsTimestamp = sellsTimestamp; }

    function setInvestorNsells(address addr, uint256 nSells) internal { investors[addr].nSells = nSells; }

    function setInvestorReferral(address addr, address referral) internal { investors[addr].referral = referral; }

    constructor(){}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract EmergencyWithdrawal {

    uint256 public emergencyWithdrawPenalty = 25;
    event EmergencyWithdraw(uint256 _investments, uint256 _withdrawals, uint256 _amountToWithdraw, uint256 _amountToWithdrawAfterTax, uint256 _amountToWithdrawTaxed);

    //Users can use emergencyWithdraw to withdraw the (100 - emergencyWithdrawPenalty)% of the investment they did not recover
    //Simple example, if you invested 5 BNB, recovered 1 BNB, and you use emergencyWithdraw with 25% tax you will recover 3 BNB
    //---> (5 - 1) * (100 - 25) / 100 = 3 BNB
    ////////////////////////////////////////////////////////////////////////////////////////////
    //WARNING!!!!! when we talk about BNB investment presale/airdrops are NOT taken into account
    //////////////////////////////////////////////////////////////////////////////////////////// 
    function emergencyWithdraw() public virtual;

    function setEmergencyWithdrawPenalty(uint256 _penalty) public virtual;

    constructor() {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./../BasicLibraries/SafeMath.sol";

abstract contract AutoEXE {
    using SafeMath for uint256;

    //AUTO EXE//
    uint64 internal investorsNextIndex = 0; //User on consecutive auto executions to know where executions have to continue
    uint8 public autoFeeTax = 2; //Tax used to cost the auto executions
    uint32 internal executionHour = 1200; //12:00 //Execution hour auto executions will begin
    uint32 constant internal minutesDay = 1440;
    uint64 internal maxInvestorPerExecution = type(uint64).max; //Max investors processed per execution
    bool public enabledSingleMode = false; //Enable/disable single mode
    address payable public autoAdd; //Wallet used for auto executions
     
    event Execute(address _sender, uint256 _totalInvestors, uint256 daysForSelling, uint256 nSells, uint256 nSellsMax);
    event ExecuteSingle(address _sender, bool _rehire);

    //Automatic execution, triggered offchain, each day or each X minutes depending on config
    //Will sell or rehire depending on algorithm decision and max sells per day
    function execute() public virtual;

    //Execute for the next n investors
    function executeN(uint256 nInvestorsExe) public virtual;

    //Automatic exection, triggered offchain, for an array of investors
    //For emergencies
    function executeAddresses(address [] memory investorsRun, bool forceSell) public virtual;

    //Single executions, only can be runned by each user if enabled
    //Will sell or rehire depending on algorithm decision and max sells per day
    function executeSingle() public virtual;
 
    function setExecutionHour(uint32 exeHour) public virtual;

    function setMaxInvestorsPerExecution(uint64 maxInvPE) public virtual;

    function setAutotax(uint8 pcTaxAuto, address _autoAdd) public virtual;

    function enableSingleMode(bool _enable) public virtual;

    function getExecutionHour() public view returns(uint256){ return executionHour; }

    function getExecutionPeriodicity() public virtual view returns(uint64);

    function calculateAutoTax(uint256 amount) internal view returns(uint256) { return SafeMath.div(SafeMath.mul(amount, autoFeeTax), 100); }

    constructor() {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./../BasicLibraries/SafeMath.sol";

abstract contract Algorithm {
    using SafeMath for uint256;
    using SafeMath for uint64;

    //ALGORITHM
    mapping(uint256 => uint256) internal dayInvestmentsAcum; //Total investment in miner registered at certain day
    mapping(uint256 => uint256) internal dayWithdrawalsAcum; //Total withdrawals in miner registered by certain day
    mapping(uint256 => uint256) internal dayHourSells;
    bool public nMaxSellsRestriction = true; //Max sell restriction in order to avoid TLV dumps, can produce delays on sells
    uint8 public minDaysSell = 7;
    uint8 public maxDaysSell = 14;

    //Min and Max days for selling, your sell date will vary between this limits
    function setAlgorithmLimits(uint8 _minDaysSell, uint8 _maxDaysSell) public virtual;

    function enablenMaxSellsRestriction(bool _enable) public virtual;

    function getCurrDayTimestamp(uint256 timestamp) public pure returns (uint256) {
        uint256 _hour = getCurrDayHours(timestamp);
        uint256 _minute = getCurrDayMinutes(timestamp);
        uint256 _second = getCurrDaySeconds(timestamp);
        return timestamp.sub(_hour.mul(3600).add(_minute.mul(60)).add(_second));
    }

    function getCurrHourTimestamp(uint256 timestamp) public pure returns (uint256) {
        uint256 _minute = (timestamp / 60) % 60;
        uint256 _second = timestamp % 60;
        return timestamp.sub(_minute.mul(60).add(_second));
    }

    function getCurrDayHours(uint256 timestamp) public pure returns (uint256) {
        return (timestamp / 60 / 60) % 24;
    }

    function getCurrDayMinutes(uint256 timestamp) public pure returns (uint256) {
        return (timestamp / 60) % 60;
    }

    function getCurrDaySeconds(uint256 timestamp) public pure returns (uint256) {
        return timestamp % 60;
    }

    function acumInvestment(uint256 timestamp, uint256 amount) internal { dayInvestmentsAcum[getCurrDayTimestamp(timestamp)] += amount; }

    function acumWithdrawal(uint256 timestamp, uint256 amount) internal { dayWithdrawalsAcum[getCurrDayTimestamp(timestamp)] += amount; }

    function lastDaysInvestments(uint256 timestamp) public view returns (uint256 [7] memory) {
        uint256 currDayTimestamp = getCurrDayTimestamp(timestamp);
        uint256 [7] memory _investments;
        for(uint64 i = 1; i <= 7; i++){            
            _investments[i-1] = dayInvestmentsAcum[currDayTimestamp-i.mul(86400)];
        }
        return _investments;
    }

    function lastDaysWithdrawals(uint256 timestamp) public view returns (uint256 [7] memory) {
        uint256 currDayTimestamp = getCurrDayTimestamp(timestamp);
        uint256 [7] memory _withdrawals;
        for(uint64 i = 1; i <= 7; i++){            
            _withdrawals[i-1] = dayWithdrawalsAcum[currDayTimestamp-i.mul(86400)];
        }
        return _withdrawals;
    }

    //Days for selling taking into account bnb entering/leaving the TLV last days
    function daysForSelling(uint256 timestamp) public view returns (uint256) {

        uint256 posRatio = 0;
        uint256 negRatio = 0;      
        uint256 daysSell = SafeMath.add(minDaysSell, SafeMath.sub(maxDaysSell, minDaysSell).div(2)); //We begin in the middle
        uint256 globalDiff = 0;

        //We storage the snapshots BNB diff to storage how much BNB was withdraw/invest on the miner each dat
        uint256 [7] memory _withdrawals = lastDaysWithdrawals(timestamp);
        uint256 [7] memory _investments = lastDaysInvestments(timestamp);

        //BNB investing diff along the days vs withdraws
        (posRatio, negRatio) = getRatiosFromInvWitDiff(_investments, _withdrawals);

        //We take the ratio diff, and get the amount of days to add/substract to daysSell
        if(negRatio > posRatio){
            globalDiff = (negRatio.sub(posRatio)).div(100);
        }
        else{
            globalDiff = (posRatio.sub(negRatio)).div(100);
        }

        //We adjust daysSell taking into acount the limits
        if(negRatio > posRatio){
            daysSell = daysSell.add(globalDiff);
            if(daysSell > maxDaysSell){
                daysSell = maxDaysSell;
            }
        }else{
            if(globalDiff < daysSell && daysSell.sub(globalDiff) > minDaysSell){
                daysSell = daysSell.sub(globalDiff);
            }
            else{
                daysSell = minDaysSell;
            }
        }

        return daysSell;        
    }

    //Returns pos and neg ratios used for daysForSelling, are calculated using differences between the snapshots take
    function getRatiosFromInvWitDiff(uint256 [7] memory investmentsDiff, uint256 [7] memory withdrawalsDiff) internal pure returns (uint256, uint256){
        uint256 posRatio = 0;
        uint256 negRatio = 0;
        uint256 ratioPosAdd = 0;
        uint256 ratioNegAdd = 0;

        //We storage the ratio, how much times BNB was invested respect the withdraws and vice versa
        for(uint256 i = 0; i < investmentsDiff.length; i++){
            if(investmentsDiff[i] != 0 || withdrawalsDiff[i] != 0){
                if(investmentsDiff[i] > withdrawalsDiff[i]){
                    if(withdrawalsDiff[i] > 0){
                        ratioPosAdd = investmentsDiff[i].mul(100).div(withdrawalsDiff[i]);
                        if(ratioPosAdd > 200){
                            posRatio += 200;
                        }
                        else{
                            posRatio += ratioPosAdd;
                        }
                    }else{
                        posRatio += 100;
                    }
                }
                else{
                    if(investmentsDiff[i] > 0){
                        ratioNegAdd = withdrawalsDiff[i].mul(100).div(investmentsDiff[i]);
                        if(ratioNegAdd > 200){
                            negRatio += 200;
                        }
                        else{
                            negRatio += ratioNegAdd;
                        }
                    }else{
                        negRatio += 100;
                    }
                }
            }
        }

        return (posRatio, negRatio);
    }

    constructor() {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract Airdrop {
    
    address public airdropToken = address(0); //Will be used for performing old miner airdrops
    bool public claimEnabled = false;

    event ClaimMilkers(address _sender, uint256 _milkersToClaim, uint256 _mmBNB);

    //Enable/disable claim
    function enableClaim(bool _enableClaim) public virtual;

    //Used for people in order to claim their milks, the fake token is burned
    function claimMilkers(address ref) public virtual;

    function setAirdropToken(address _airdropToken) public virtual;

    constructor() {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
pragma solidity ^0.8.9;

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}