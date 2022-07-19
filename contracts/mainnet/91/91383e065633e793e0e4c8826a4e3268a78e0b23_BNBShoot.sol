pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

contract BNBShoot is OwnableUpgradeable{
    using SafeMathUpgradeable for uint256;
    uint256 PSN;
    uint256 PSNH;
    uint256 public minBuyValue;
    uint256 public minSellValue;
    address public marketingAddress;

    address public ceoAddress;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedShoots;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    mapping (address => uint256) public numRealRef;
    uint256 public marketShoots;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _buyItemIds;
    uint256 public roundTime;
    uint256 public roundlength; //8 hour
    uint256 public roundNum;

    mapping(uint256 => uint256[]) public roundToIds;
    mapping(uint256 => buyItem) public idToBuy;
    struct buyItem {
        uint256 amount;
        uint256 buyTime;
        address buyer;
        uint256 buyItemId;
        uint256 roundNum;
    }

    mapping(uint256 => mapping(uint256 => uint256)) public roundToNextId;
    mapping(uint256 => uint256) public roundToReward;
    mapping(address => uint256) public myFomoRewardTotal;
    uint256 public thisRoundRate;
    uint256 public moneyRankingRate;
    uint256 public fomoRewardRate;
    uint256 public fomoRewardLen;
    uint256 constant GUARD = ~uint256(0);

    uint256 public realRefMinAmount;

    mapping(address => bool) public appointedQualified;

    mapping(address => mapping(uint256 =>uint256)) public addressToReferralInvestAmount;
    mapping(address => mapping(uint256 =>uint256)) public addressToReferralReInvestAmount;


    mapping (address => uint256) public myHatchAmount;

    uint256[15] public referralRates;
    uint256 public burnRate;
    mapping(address => address[]) public myInviteAddress;

    struct referralDetails {
        uint256 level;
        uint256 proportion;
        uint256 investAmount;
        uint256 reInvestProportion;
        uint256 reInvestAmount;
        uint256 reInvestAmountBNB;
    }

    event buyShoot (address buyer, uint256 amount,  uint256 roundNum);
    event timeFomoRewardDistributed (address buyer, uint256 amount,  uint256 roundNum);
    event moneyFomoRewardDistributed (address buyer, uint256 amount,  uint256 roundNum);

    bool punishMod;

    mapping(address => bool) public sellBlackList;
    mapping(address => uint256) public mySellValue;
    mapping(address => uint256) public lastPunishedTime;
    mapping(address => uint256) public myBuyValue;
    uint256 public realRefPunish;
    uint256 public minHatchAmountPunish;
    uint256 public minBuyValuePunish;
    uint256 public maxSellValuePunish;
    uint256 public punishFactor;

    function initialize() public initializer{
        __Ownable_init();
        PSN = 10000;
        PSNH = 5000;
        minBuyValue = 100000000000000000;
        minSellValue = 0;
        marketShoots = 86400000000;
        roundlength = 28800;
        thisRoundRate = 7;
        moneyRankingRate = 6;
        fomoRewardRate = 3;
        fomoRewardLen = 10;
        realRefMinAmount = 50000000000000000;
        burnRate = 50;
        realRefPunish = 20;
        minHatchAmountPunish = 10000000000000000000;
        minBuyValuePunish = 1000000000000000000;
        maxSellValuePunish = 10000000000000000000;
        punishFactor = 2;
        punishMod = false;
        ceoAddress = 0x17531BB6BFece55f3337e54130dcF8d6305E89B1;
        marketingAddress = 0x6d05bC0FEa587c80a6bac2966BCa0f43Cc9e34D9;
        referralRates = [100,50,30,20,5,5,5,5,5,5,5,5,5,5,5];

    }

    function startShoot ()  public onlyOwner{
        require(roundTime == 0,"Already started");
        roundTime = block.timestamp;
    }


    function setCeoAddress(address _address) public onlyOwner{
        ceoAddress = _address;
    }
    function setMarketingAddress(address _address) public onlyOwner{
        marketingAddress = _address;
    }

    // **admin function**

    function setPunishFactor(uint256 _punishFactor) public onlyOwner{
        punishFactor = _punishFactor;
    }

    function setRealRefPunish(uint256 _realRefPunish) public onlyOwner{
        realRefPunish = _realRefPunish;
    }

    function setMyBuyValue(address _address, uint256 _value) public onlyOwner{
        myBuyValue[_address] = _value;
    }
    function setMySellValue(address _address, uint256 _value) public onlyOwner{
        mySellValue[_address] = _value;
    }
    function setBlacklist(address _address, bool _bool) public onlyOwner{
        sellBlackList[_address] = _bool;
    }

    function setBlacklistBatch(address[] memory _address, bool _bool) public onlyOwner{
        for(uint i=0; i<_address.length; i++){
            sellBlackList[_address[i]] = _bool;
        }
    }

    function setPS(uint256 _PSN, uint256 _PSNH) public onlyOwner{
        PSN = _PSN;
        PSNH = _PSNH;
    }
    function setMinBuyValue(uint256 _minBuyValue) public onlyOwner{
        minBuyValue = _minBuyValue;
    }
    function setMinSellValue(uint256 _minSellValue) public onlyOwner{
        minSellValue = _minSellValue;
    }
    function setHatcheryMiners(address _addr, uint256 _hatchValue) public onlyOwner{
        hatcheryMiners[_addr] = _hatchValue;
    }
    function setClaimedShoots(address _addr, uint256 _claimedShoots) public onlyOwner{
        claimedShoots[_addr] = _claimedShoots;
    }
    function setLastHatch(address _addr, uint256 _lastHatch) public onlyOwner{
        lastHatch[_addr] = _lastHatch;
    }
    function setReferrals(address _addr, address _referrals) public onlyOwner{
        referrals[_addr] = _referrals;
    }
    function setNumRealRef(address _addr, uint256 _numRealRef) public onlyOwner{
        numRealRef[_addr] = _numRealRef;
    }
    function setMarketShoots(uint256 _marketShoots) public onlyOwner{
        marketShoots = _marketShoots;
    }
    function setRoundlength(uint256 _roundlength) public onlyOwner{
        roundlength = _roundlength;
    }
    function setThisRoundRate(uint256 _thisRoundRate) public onlyOwner{
        thisRoundRate = _thisRoundRate;
    }
    function setMoneyRankingRate(uint256 _moneyRankingRate) public onlyOwner{
        moneyRankingRate = _moneyRankingRate;
    }
    function setFomoRewardRate(uint256 _fomoRewardRate) public onlyOwner{
        fomoRewardRate = _fomoRewardRate;
    }
    function setRealRefMinAmount(uint256 _realRefMinAmount) public onlyOwner{
        realRefMinAmount = _realRefMinAmount;
    }
    function setAppointedQualified(address _addr, bool _appointedQualified) public onlyOwner{
        appointedQualified[_addr] = _appointedQualified;
    }

    function setReferralRates(uint256[15] memory _inputRate) public onlyOwner{
        for(uint i=0; i<15; i++){
            referralRates[i] = _inputRate[i];
        }
    }

    function setBurnRate(uint256 _burnRate) public onlyOwner{
        burnRate = _burnRate;
    }
    function setMyInviteAddress(address _addr,address _downline) public onlyOwner{
        myInviteAddress[_addr].push(_downline);
    }

    function setFomoRewardLen(uint256 _len) public onlyOwner{
        fomoRewardLen = _len;
    }
    function setPunishMod(bool _bool) public onlyOwner{
        punishMod = _bool;
    }

    // **calculate function**
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMathUpgradeable.div(SafeMathUpgradeable.mul(PSN,bs),SafeMathUpgradeable.add(PSNH,SafeMathUpgradeable.div(SafeMathUpgradeable.add(SafeMathUpgradeable.mul(PSN,rs),SafeMathUpgradeable.mul(PSNH,rt)),rt)));
    }
    function calculateShootSell(uint256 shoots) public view returns(uint256){
        if(shoots == 0){
            return 0;
        }
        return calculateTrade(shoots,marketShoots,address(this).balance);
    }
    function calculateShootBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketShoots);
    }
    function calculateShootBuySimple(uint256 eth) public view returns(uint256){
        return calculateShootBuy(eth,address(this).balance);
    }
    function devFee(uint256 amount) public view returns(uint256){
        uint256 balance = address(this).balance;
        uint256 rate = 0;
        if(balance < 2000  * 10 ** 18) {
            rate = 5;
        }else if(balance < 5000 * 10 ** 18){
            rate = 4;
        }else if(balance < 10000 * 10 ** 18){
            rate = 3;
        }else if(balance < 20000 * 10 ** 18){
            rate = 2;
        }else{
            rate = 1;
        }
        return SafeMathUpgradeable.div(SafeMathUpgradeable.mul(amount,rate),100);
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyMiners() public view returns(uint256){
        return hatcheryMiners[msg.sender];
    }
    function getMyShoots() public view returns(uint256){
        return SafeMathUpgradeable.add(claimedShoots[msg.sender],getShootsSinceLastHatch(msg.sender));
    }
    function getMyWetShoots() public view returns(uint256){
        uint256 wetShoots = getMyinviteReward();

        return wetShoots;
    }
    function getMyNetShoots() public view returns(uint256){
        uint256 totalShoots = getMyShoots();
        uint256 wetShoots = getMyWetShoots();
        uint256 netShoots = SafeMathUpgradeable.sub(totalShoots,wetShoots);

        return netShoots;
    }

    function getMyReinvestAmount() public view returns(uint256){
        return myHatchAmount[msg.sender];
    }
    function getShootsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsPassed=SafeMathUpgradeable.sub(block.timestamp,lastHatch[adr]);
        if(getPunishedStatus(msg.sender)){
            return secondsPassed*hatcheryMiners[adr]/punishFactor;
        }else{
            return secondsPassed*hatcheryMiners[adr];
        }

    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    // **user function**
    // ***user basic function***
    function getPunishedStatus(address _addr) public view returns(bool){
        if(!punishMod){
            return false;
        }
        if( numRealRef[_addr]<realRefPunish && mySellValue[_addr]>maxSellValuePunish && myBuyValue[_addr]<minBuyValuePunish && myHatchAmount[_addr]<minHatchAmountPunish){
            return true;
        }else{
            return false;
        }

    }

    function sellShoots() public{
        require(!sellBlackList[msg.sender], "You are in the blacklist");
        uint256 hasShoots=getMyShoots();
        uint256 shootValue=calculateShootSell(hasShoots);


        require(shootValue>=minSellValue, "You need to have at least minSellValue to sell");
        uint256 fee=devFee(shootValue);
        claimedShoots[msg.sender]=0;
        lastHatch[msg.sender]=block.timestamp;
        marketShoots=SafeMathUpgradeable.add(marketShoots,hasShoots);
        payable(marketingAddress).transfer(fee);
        payable(msg.sender).transfer(SafeMathUpgradeable.sub(shootValue,fee));
        mySellValue[msg.sender]=SafeMathUpgradeable.add(mySellValue[msg.sender],shootValue);
    }

    function buyShoots(address ref) public payable{
        require(roundTime > 0,"Not started");
        require(msg.value >= minBuyValue, "Not Enough BNB");
        myBuyValue[msg.sender]=SafeMathUpgradeable.add(myBuyValue[msg.sender],msg.value);
        updateRoundNum();
        _buyItemIds.increment();
        uint256 itemId = _buyItemIds.current();
        roundToIds[roundNum].push(itemId);
        idToBuy[itemId] = buyItem(
            msg.value,
            block.timestamp,
            msg.sender,
            itemId,
            roundNum
        );

        _addPlayer(roundNum, itemId);
        roundToReward[roundNum] = roundToReward[roundNum] + msg.value*fomoRewardRate*thisRoundRate/1000;
        roundToReward[roundNum+1] = roundToReward[roundNum+1] + msg.value*fomoRewardRate*(10-thisRoundRate)/1000;

        uint256 shootsBought=calculateShootBuy(msg.value,SafeMathUpgradeable.sub(address(this).balance,msg.value));
        shootsBought=SafeMathUpgradeable.sub(shootsBought,devFee(shootsBought));
        uint256 fee=devFee(msg.value);
        payable(marketingAddress).transfer(fee);
        claimedShoots[msg.sender]=SafeMathUpgradeable.add(claimedShoots[msg.sender],shootsBought);
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
            myInviteAddress[ref].push(msg.sender);
        }
        numRealRef[referrals[msg.sender]] +=1;


        uint256 shootsUsed = getMyShoots();
        address[] memory uplineRewards = new address[](15);

        // uplingAddress
        uplineRewards[0] = referrals[msg.sender];

        for(uint256 i=0;i<14;i++){
            uplineRewards[i+1] = referrals[uplineRewards[i]];
        }

        for(uint256 i=0;i<15;i++){
            if(getIsQualified(uplineRewards[i],i+1)){
                if (uplineRewards[i] != address(0)) {
                    addressToReferralInvestAmount[uplineRewards[i]][i+1] += SafeMathUpgradeable.div((shootsUsed * referralRates[i]), 1000);
                }
            }
        }

        hatchShoots(ref);

        emit buyShoot (msg.sender, msg.value,  roundNum);
    }


    function hatchShoots(address ref) public{
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
            myInviteAddress[ref].push(msg.sender);
        }

        uint256 shootsUsed = getMyShoots();
        myHatchAmount[msg.sender] += shootsUsed;
        hatcheryMiners[msg.sender] = calculateMiners(myBuyValue[msg.sender],myHatchAmount[msg.sender]);
        claimedShoots[msg.sender]=0;
        lastHatch[msg.sender]=block.timestamp;


        // uplingAddress
        address[] memory uplineRewards = new address[](15);

        // uplingAddress
        uplineRewards[0] = referrals[msg.sender];
        for(uint256 i=0;i<14;i++){
            uplineRewards[i+1] = referrals[uplineRewards[i]];
        }
        //send referral shoots
        if(getIsQualified(uplineRewards[0],1)){
            if (uplineRewards[0] != address(0)) {
                if(myHatchAmount[msg.sender] <= myHatchAmount[uplineRewards[0]]){
                    uint256 shootsToAdd = SafeMathUpgradeable.div((shootsUsed * referralRates[0]), 1000);
                    claimedShoots[uplineRewards[0]] = SafeMathUpgradeable.add(
                        claimedShoots[uplineRewards[0]],
                        shootsToAdd
                    );


                }else{
                    uint256 shootsToAdd = SafeMathUpgradeable.div((shootsUsed * referralRates[0]* burnRate), 100000);
                    claimedShoots[uplineRewards[0]] = SafeMathUpgradeable.add(
                        claimedShoots[uplineRewards[0]],
                        shootsToAdd
                    );
                }
                addressToReferralReInvestAmount[uplineRewards[0]][1] += SafeMathUpgradeable.div((shootsUsed * referralRates[0]), 1000);
            }
        }
        for(uint256 i=1;i<15;i++){
            if(getIsQualified(uplineRewards[i],i+1)){
                if (uplineRewards[i] != address(0)) {
                    claimedShoots[uplineRewards[i]] = SafeMathUpgradeable.add(
                        claimedShoots[uplineRewards[i]],
                        SafeMathUpgradeable.div((shootsUsed * referralRates[i]), 100)
                    );

                    addressToReferralReInvestAmount[uplineRewards[i]][i+1]  += SafeMathUpgradeable.div((shootsUsed * referralRates[i]), 1000);

                }
            }
        }
        //boost market to nerf miners hoarding
        marketShoots=SafeMathUpgradeable.add(marketShoots,SafeMathUpgradeable.div(shootsUsed,5));
    }



    // ***user fomo function***

    function updateRoundNum() public {
        uint256 nextRoundtime = roundTime + roundlength;
        if(block.timestamp > nextRoundtime){
            address[] memory timeRankingAddresses = getTimeRankingThisRoundAddress();
            address[] memory moneyRankingAddresses = getMoneyRankingThisRoundAddress();
            uint256 moneyRankingReward = roundToReward[roundNum] * moneyRankingRate / 10;
            uint256 timeRankingReward = roundToReward[roundNum] * (10-moneyRankingRate) / 10;

            for(uint i = 0; i < fomoRewardLen; i++){
                myFomoRewardTotal[timeRankingAddresses[i]] = myFomoRewardTotal[timeRankingAddresses[i]] + timeRankingReward/fomoRewardLen;
                myFomoRewardTotal[moneyRankingAddresses[i]] = myFomoRewardTotal[moneyRankingAddresses[i]] + moneyRankingReward/fomoRewardLen;
                emit timeFomoRewardDistributed(timeRankingAddresses[i],timeRankingReward/fomoRewardLen,roundNum);
                emit moneyFomoRewardDistributed(moneyRankingAddresses[i],moneyRankingReward/fomoRewardLen,roundNum);
            }
            roundNum += 1;
            roundTime = nextRoundtime;
        }
    }
    // ****only need to write until the end of the round to reduce gas****
    function _getTimeRankingThisRoundAddress(uint256 _roundNum) public view returns(address[] memory){

        uint256[] memory ids = roundToIds[_roundNum];
        address[] memory timeRankingAddresses = new address[](10);
        for (uint i = 0; i < ids.length; i++) {
            if(i<10){
                uint iReverse = ids.length-i-1;
                uint256 id = ids[iReverse];
                timeRankingAddresses[i] = idToBuy[id].buyer;
            }
        }
        return timeRankingAddresses;
    }

    function getTimeRankingThisRoundAddress() public view returns(address[] memory){
        address[] memory timeRankingAddresses = _getTimeRankingThisRoundAddress(roundNum);
        return timeRankingAddresses;
    }

    function _getMoneyRankingThisRoundAddress(uint256 _roundNum) public view returns(address[] memory){

        uint256[] memory ids = roundToIds[_roundNum];
        address[] memory moneyRankingAddresses = new address[](10);
        uint256 currentId = roundToNextId[_roundNum][GUARD];
        for (uint i = 0; i < ids.length; i++) {
            if(i<10){
                moneyRankingAddresses[i] = idToBuy[currentId].buyer;
                currentId = roundToNextId[_roundNum][currentId];
            }
        }
        return moneyRankingAddresses;
    }

    function getMoneyRankingThisRoundAddress() public view returns(address[] memory){
        address[] memory moneyRankingAddresses = _getMoneyRankingThisRoundAddress(roundNum);
        return moneyRankingAddresses;
    }


    function _addPlayer(uint256 _roundNum, uint256 _id) internal {
        uint256 index = _findIndex(_roundNum, _id);
        roundToNextId[_roundNum][_id] = roundToNextId[_roundNum][index];
        roundToNextId[_roundNum][index] = _id;
    }

    function _findIndex(uint256 _roundNum, uint256 _id) internal view returns(uint256) {
        uint256 candidateId = ~uint256(0);
        while(true) {
            if(_verifyIndex(candidateId, idToBuy[_id].amount, roundToNextId[_roundNum][candidateId] )){
                return candidateId;
            }
            candidateId = roundToNextId[_roundNum][candidateId];
        }
    }

    function _verifyIndex(uint256 prevStudent, uint256 newValue, uint256 nextStudent) internal view returns(bool){
        return (prevStudent == GUARD || idToBuy[prevStudent].amount >= newValue) && (nextStudent == GUARD || newValue > idToBuy[nextStudent].amount);
    }

    function claimFomoRewards() public  {
        require(myFomoRewardTotal[msg.sender] > 0, "Not enough FOMO rewards");
        uint256 fomoRewards = myFomoRewardTotal[msg.sender];
        myFomoRewardTotal[msg.sender] = 0;
        payable(msg.sender).transfer(fomoRewards);

    }

    function getMyFomoRewardTotal() public view returns(uint256){
        return myFomoRewardTotal[msg.sender];
    }

    function getFomoThisRoundReward() public view returns(uint256){
        return roundToReward[roundNum];
    }

    function getFomoThisRoundNumber() public view returns(uint256){
        return roundNum;
    }

    function getFomoThisRoundStartTime() public view returns(uint256){
        return roundTime;
    }

    function getFomoTotalRewardDistributed() public view returns(uint256){
        uint256 fomoTotalRewardDistributed=0;
        for(uint i=0;i<roundNum;i++){
            fomoTotalRewardDistributed += roundToReward[i];
        }
        return fomoTotalRewardDistributed;
    }

    // ***user referral function***

    function getIsQualified(address _addr,uint256 level) public view returns(bool){
        uint256 myValue = myBuyValue[_addr];
        uint256 qualifiedLevel = 1;
        if(myValue >= 1 *10 ** 17 && myValue < 1 *10 ** 18){
            qualifiedLevel = 2;
        }else if(myValue < 2 * 10 ** 18){
            qualifiedLevel = 3;
        }else if(myValue < 3 * 10 ** 18){
            qualifiedLevel = 5;
        }else if(myValue < 4 * 10 ** 18){
            qualifiedLevel = 8;
        }else if(myValue < 5 * 10 ** 18){
            qualifiedLevel = 12;
        }else if(myValue >= 5 * 10 ** 18) {
            qualifiedLevel = 15;
        }
        bool natureBool = qualifiedLevel >= level;
        bool ceoBool = appointedQualified[_addr];
        if (natureBool || ceoBool){
            return true;
        }else{
            return false;
        }
    }

    function getMyRealRefNumber() public view returns(uint256){
        return numRealRef[msg.sender];
    }

    function getRealRefNumber(address _addr) public view returns(uint256){
        return numRealRef[_addr];
    }

    function getMySon() public view returns(referralDetails[] memory){
        uint256 myValue = myBuyValue[msg.sender];
        uint256 length = 0;
        if(myValue == 0){
            length = 0;
        }else if(myValue < 1 *10 ** 18){
            length = 2;
        }else if(myValue < 2 * 10 ** 18){
            length = 3;
        }else if(myValue < 3 * 10 ** 18){
            length = 5;
        }else if(myValue < 4 * 10 ** 18){
            length = 8;
        }else if(myValue < 5 * 10 ** 18){
            length = 12;
        }else {
            length = 15;
        }
        if(appointedQualified[msg.sender]){
            length = 15;
        }
        referralDetails[] memory returndata = new referralDetails[](length);
        for (uint i = 1; i < length + 1; i++) {
            returndata[i-1] = referralDetails(i,referralRates[i-1],addressToReferralInvestAmount[msg.sender][i] ,referralRates[i-1],addressToReferralReInvestAmount[msg.sender][i],calculateShootSell(addressToReferralReInvestAmount[msg.sender][i]));
        }
        return returndata;
    }

    function getMyinviteReward() public view returns(uint256){
        uint256 returndata = 0;
        for(uint i=1;i<11;i++){
            returndata += addressToReferralReInvestAmount[msg.sender][i];
        }
        return returndata;
    }

    function getInviteRewardEachLayer(address _addr, uint256 _layer) public view returns(uint256){
        return addressToReferralReInvestAmount[_addr][_layer];
    }


    function getInviteReward(address _addr) public view returns(uint256){
        uint256 returndata = 0;
        for(uint i=1;i<11;i++){
            returndata += addressToReferralReInvestAmount[_addr][i];
        }
        return returndata;
    }

    function getMyInviteAddress() public view returns(address[] memory){
        return myInviteAddress[msg.sender];
    }

    function getInviteAddress(address _addr ) public view returns(address[] memory){
        return myInviteAddress[_addr];
    }

    function getMyReferralAmount() public view returns(address[] memory, uint256[] memory){
        uint256 lenMyInvite = myInviteAddress[msg.sender].length;
        uint256[] memory inviteNum = new uint256[](lenMyInvite);
        for(uint i=0;i<lenMyInvite;i++){
            inviteNum[i] = myInviteAddress[myInviteAddress[msg.sender][i]].length;
        }
        return (myInviteAddress[msg.sender],inviteNum);
    }

    function calculateMiners (uint256 buyValue,uint256 shootsUsed) public view returns(uint256 res)  {
        uint256 _miner;
        if(buyValue < 1 * 10**18){
            _miner = 17280000;
        }else if(buyValue >= 1 * 10 ** 18 && buyValue < 2 * 10 ** 18){
            _miner = 8640000;
        }else if(buyValue >= 2 * 10 ** 18 && buyValue < 3 * 10 ** 18){
            _miner = 4320000;
        }else if(buyValue >= 3 * 10 ** 18 && buyValue < 4 * 10 ** 18){
            _miner = 2880000;
        }else if(buyValue >= 4 * 10 ** 18 && buyValue < 5 * 10 ** 18){
            _miner = 2160000;
        }else if(buyValue >= 5 * 10 ** 18){
            _miner = 1728000;
        }
        return SafeMathUpgradeable.div(shootsUsed,_miner);
    }

    fallback() external payable{}

    function upgrade() public onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
library SafeMathUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}