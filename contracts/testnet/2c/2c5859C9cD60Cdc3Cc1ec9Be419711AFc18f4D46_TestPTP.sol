// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
contract TestPTP is ERC20 {
     using SafeMath for uint256;

    uint256 startDate = 1652080210;                            
    uint256 counterId = 0;            
    address originAddress = 0x6b26678F4f392B0E400CC419FA3E5161759ca380;
    uint256 originAmount = 0;  
    uint256 stakerPool = 0; 
    uint256 unClaimedBtc = 19000000 * 10 ** 8;
    uint256 claimedBTC = 0;
    uint256 maxValueBPB = 150000000 * 10 ** 8;   
    uint256 divValueBPB = 1500000000 * 10 ** 8;
    uint256 shareRate = 1 * 10 ** 2;
    uint256 claimedBtcAddrCount = 0;
    uint256 BIG_PAY_DAY = 351;
    uint256 unclaimed_BTC_Payout_Bucket = 0;
    uint256 CLAIMABLE_BTC_ADDR_COUNT = 27997742;
    uint256 SHARE_PER_DAY = 19208219 * 10 ** 8;

    address[] internal stakeAddress;
    address[] internal freeStakeholders;
    // onlyOwner
    address internal owner;
    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }

    struct transferInfo {
        address to;
        address from; 
        uint256 amount;
    }

    struct freeStakeClaimInfo {
        string btcAddress;
        uint256 balanceAtMoment;
        uint256 dayFreeStake;
        uint256 claimedAmount;
        uint256 rawBtc;
    }

    struct stakeRecord {
       uint256 stakeShare;
       uint numOfDays;
       uint256 currentTime;
       bool claimed;
       uint256 id;
       uint256 startDay;
       uint256 endDay;
       uint256 endDayTimeStamp;
       bool isFreeStake;
       string stakeName;
       uint256 stakeAmount; 
       
    }   
    //Adoption Amplifier Struct
    struct RecordInfo {
        uint256 amount;
        uint256 time;
        bool claimed;
        address user;
        address refererAddress;
    }

    struct referalsRecord {
        address referdAddress;
        uint256 day;
        uint256 awardedPTP;
    }

    struct TotalStakedShare{
        uint256 share;
        uint256 endDay;
        bool isRemoved;
    }
    mapping (uint256 => mapping(address => RecordInfo)) public AARecords;
    mapping (address => referalsRecord[]) public referals;
    mapping (uint => uint256) public totalBNBSubmitted; 
    mapping (uint256 => address[]) public perDayAARecords;
    mapping (address => uint256) internal stakes;
    mapping (address => stakeRecord[]) public  stakeHolders;
    mapping (address => transferInfo[]) public transferRecords;
    mapping (address => freeStakeClaimInfo[]) public freeStakeClaimRecords;
    mapping (uint256 => TotalStakedShare[]) public perDayShareStakes;
    mapping (string => bool) public btcAddressClaims;
    mapping (uint256 => bool) public bigPayDayCheck;
    mapping (uint256 => uint256) public perDayPenalties;
    mapping (uint256 => uint256) public perDayUnclaimedBTC;
    event Received(address, uint256);
    event CreateStake(uint256 id,uint256 stakeShares);

    constructor() ERC20("10Pantacles", "PTP")  {
        owner =  msg.sender;
    }

    function totalBalance() external view returns(uint) {
     return payable(address(this)).balance;
    }

    function withdraw() public onlyOwner {
     payable(msg.sender).transfer(this.totalBalance());
    }

    function mintAmount(address user, uint256 amount) internal {
         _mint(user,amount);
    }

    function findDay() public view returns(uint) {
        uint day = block.timestamp.sub(startDate);
        day = day.div(180);
        return day;
    }

    function addStakeholder(address _stakeholder) public {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder){
            stakeAddress.push(_stakeholder);
        }
    }

    function isStakeholder(address _address) public view returns(bool, uint256) { 

        for (uint256 s = 0; s < stakeAddress.length; s += 1){
            if (_address == stakeAddress[s]) return (true, s);
        }
        return (false, 0);
    }

    function generateId() public returns(uint256) {
        return counterId++;

    } 

    function findEndDayTimeStamp(uint256 day) public view returns(uint256){
       uint256 futureDays = day.mul(180);
       futureDays = block.timestamp.add(futureDays);
       return futureDays;
    }

    function findMin (uint256 value) public view returns(uint256){
        
        uint256 minValue;
        if(value <=  maxValueBPB){
            minValue = value;
        }
        else{
            minValue = maxValueBPB; 
        }
       return minValue; 
    }

    function findBiggerPayBetter(uint256 inputPTP) public view returns(uint256){
        uint256 minValue = findMin(inputPTP);
        uint256 BPB = inputPTP.mul(minValue);
        BPB = BPB.div(divValueBPB); 
        return BPB;
    }  

    function findLongerPaysBetter(uint256 inputPTP, uint256 numOfDays) public pure returns(uint256){
        uint256 daysToUse = numOfDays.sub(1); 
        uint256 LPB = inputPTP.mul(daysToUse);
        LPB = LPB.div(1820);
        return LPB;
    } 

    function generateShare(uint256 inputPTP, uint256 LPB , uint256 BPB) public view returns(uint256){
            uint256 share = LPB.add(BPB);
            share = share.add(inputPTP);
            share = share.div(shareRate);
            share = share.mul(share);
            return share;  
    }

    function createStake(uint256 _stake,uint day,string memory stakeName) public {
        uint256 balance = balanceOf(msg.sender);
        require(balance >= _stake,'Not enough amount for staking');
        (bool _isStakeholder, ) = isStakeholder(msg.sender);
        if(! _isStakeholder) addStakeholder(msg.sender);
         _burn(msg.sender,_stake);
        uint256 id = generateId();
        uint256 currentDay = findDay();
        uint256 endDay = currentDay.add(day);
        uint256 endDayTimeStamp = findEndDayTimeStamp(day);
        stakerPool = stakerPool.add(_stake);
        uint256 BPB = findBiggerPayBetter(_stake);
        originAmount = originAmount.add(BPB);
        uint256 LPB = findLongerPaysBetter(_stake,day);
        originAmount = originAmount.add(LPB);
        uint256 share = generateShare(_stake,LPB,BPB);
        TotalStakedShare memory record = TotalStakedShare({share:share,endDay:endDay,isRemoved:false});
        for(uint i = currentDay; i<=endDay; i++){
        perDayShareStakes[i].push(record);
        }
        stakeRecord memory myRecord = stakeRecord({id:id,stakeShare:share,stakeName:stakeName, numOfDays:day, currentTime:block.timestamp,claimed:false,startDay:currentDay,endDay:endDay,
        endDayTimeStamp:endDayTimeStamp,isFreeStake:false,stakeAmount:_stake});
        stakeHolders[msg.sender].push(myRecord);
        emit CreateStake(id,share);
    }

    function transferStake(uint256 id,address transferTo) public {
     stakeRecord[] memory myRecord = stakeHolders[msg.sender];
     for(uint i=0; i<myRecord.length; i++){
        if(myRecord[i].id == id){
        stakeHolders[transferTo].push(stakeHolders[msg.sender][i]); 
        delete(stakeHolders[msg.sender][i]);
        }
     }
    }

    function getDailyShare (uint256 day) public view returns(uint256 dailyRewardOfDay){
        uint256 penalties = perDayPenalties[day];
        dailyRewardOfDay = SHARE_PER_DAY.add(penalties);
        return  dailyRewardOfDay;
    }

    function findBPDPercent (uint256 share,uint256 totalSharesOfBPD) public pure returns (uint256){
        uint256 totalShares = totalSharesOfBPD;
        uint256 sharePercent = share * 10 ** 4;
        sharePercent = sharePercent.div(totalShares);
        sharePercent = sharePercent * 10 ** 2;
        return sharePercent;   
    }

    function findStakeSharePercent (uint256 share,uint256 day) public view returns (uint256){
        uint256 dayTotalShares = getStakeTotalOfDay(day);
        uint256 sharePercent = share * 10 ** 4;
        sharePercent = sharePercent.div(dayTotalShares);
        sharePercent = sharePercent * 10 ** 2;
        return sharePercent;   
    }

    function _calcAdoptionBonus(uint256 payout)public view returns (uint256){
        uint256 bonus = 0;
        uint256 viral = payout.mul(claimedBtcAddrCount);
        viral = viral.div(CLAIMABLE_BTC_ADDR_COUNT);
        uint256 crit = payout.mul( claimedBTC) ;
        crit = crit.div(unClaimedBtc);
        bonus = viral.add(crit);
        return bonus; 
    }

    function getAllDayReward(uint256 beginDay,uint256 endDay,uint256 stakeShare) public view returns (uint256 ){
         uint256 totalIntrestAmount = 0; 
        for (uint256 day = beginDay; day < endDay; day++) {
            uint256 dayTotalShares = getStakeTotalOfDay(day);
            uint256 dayShare = getDailyShare(day);
            uint256 currDayAmount = dayShare.mul(stakeShare);
            currDayAmount = currDayAmount.div(dayTotalShares);
            totalIntrestAmount = totalIntrestAmount.add(currDayAmount); 
            }
          if (beginDay <= BIG_PAY_DAY && endDay > BIG_PAY_DAY) {
               uint256 dayTotalShares = getStakeTotalOfDay(350);
              uint256 sharePercentOfBPD = findBPDPercent(stakeShare,dayTotalShares);
              uint256 bigPaySlice = unclaimed_BTC_Payout_Bucket.mul(sharePercentOfBPD);
              bigPaySlice = bigPaySlice.div(100 * 10 ** 4);
              totalIntrestAmount = bigPaySlice.add(_calcAdoptionBonus(bigPaySlice));
            }
        return totalIntrestAmount;
    }

    function findDayDiff(uint256 endDayTimeStamp) public view returns(uint) {
        uint day = block.timestamp.sub(endDayTimeStamp);
        day = day.div(180);
        return day;
    }
    
    function findEstimatedIntrest (uint256 stakeShare,uint256 startDay) public view returns (uint256) {
            uint256 day = findDay();
            uint256 sharePercent = findStakeSharePercent(stakeShare,startDay);
            uint256 dailyEstReward = getDailyShare(day);
            uint256 perDayProfit = dailyEstReward.mul(sharePercent);
            perDayProfit = perDayProfit.div(100 * 10 ** 4);
            return perDayProfit;

    }

    function getDayRewardForPenalty(uint256 beginDay,uint256 stakeShare, uint256 dayData) public view returns (uint256){
         uint256 totalIntrestAmount = 0;
          for (uint256 day = beginDay; day < beginDay.add(dayData); day++) {
            uint256 dayShare = getDailyShare(day);
            totalIntrestAmount = dayShare.mul(stakeShare);
            uint256 dayTotalShares = getStakeTotalOfDay(day); 
            totalIntrestAmount = totalIntrestAmount.div(dayTotalShares);
            }
        return totalIntrestAmount;
    }

    function earlyPenaltyForShort(stakeRecord memory stakeData,uint256 totalIntrestAmount) public view returns(uint256){
            uint256 emergencyDayEnd = findDayDiff(stakeData.currentTime);
            uint256 penalty;
            if(emergencyDayEnd == 0){
                uint256 estimatedAmount = findEstimatedIntrest(stakeData.stakeShare,stakeData.startDay);
                estimatedAmount = estimatedAmount.mul(90);
                penalty = estimatedAmount;
            }

            if(emergencyDayEnd < 90 && emergencyDayEnd !=0){
                penalty = totalIntrestAmount.mul(90);
                penalty = penalty.div(emergencyDayEnd);
               
            }

            if(emergencyDayEnd == 90){
                penalty = totalIntrestAmount;
                
            }

            if(emergencyDayEnd > 90){
                uint256 rewardTo90Days = getDayRewardForPenalty(stakeData.startDay,stakeData.stakeShare,89);
                 penalty = totalIntrestAmount.sub(rewardTo90Days);
            }
            return penalty;
    }

    function earlyPenaltyForLong(stakeRecord memory stakeData,uint256 totalIntrestAmount) public view returns(uint256){
            uint256 emergencyDayEnd = findDayDiff(stakeData.currentTime);
            uint256 endDay = stakeData.numOfDays;
            uint256 halfOfStakeDays = endDay.div(2);
            uint256 penalty ;
            if(emergencyDayEnd == 0){
                uint256 estimatedAmount = findEstimatedIntrest(stakeData.stakeShare,stakeData.startDay);
                estimatedAmount = estimatedAmount.mul(halfOfStakeDays);
                penalty = estimatedAmount;
            }

            if(emergencyDayEnd < halfOfStakeDays && emergencyDayEnd != 0){
                penalty = totalIntrestAmount.mul(halfOfStakeDays);
                penalty = penalty.div(emergencyDayEnd);
            }

            if(emergencyDayEnd == halfOfStakeDays){
                penalty = totalIntrestAmount;
                
            }

            if(emergencyDayEnd > halfOfStakeDays){
                uint256 rewardToHalfDays = getDayRewardForPenalty(stakeData.startDay,stakeData.stakeShare,halfOfStakeDays);
                penalty = totalIntrestAmount.sub(rewardToHalfDays);   
            }
            return penalty;
    }

    function latePenalties (stakeRecord memory stakeData,uint256 totalAmountReturned) public  returns(uint256){
            uint256 dayAfterEnd = findDayDiff(stakeData.endDayTimeStamp);
            if(dayAfterEnd > 14){
            uint256 transferAmount = totalAmountReturned;
            uint256 perDayDeduction = 143 ;
            uint256 penalty = transferAmount.mul(perDayDeduction);
            penalty = penalty.div(1000); 
            penalty = penalty.div(100);
            uint256 totalPenalty = dayAfterEnd.mul(penalty);
            uint256 halfOfPenalty = totalPenalty.div(2);
            uint256 actualAmount = 0;
            uint256 day = findDay();
             day = day.add(1);
            if(totalPenalty < totalAmountReturned){

             perDayPenalties[day] = perDayPenalties[day].add(halfOfPenalty);
             originAmount = originAmount.add(halfOfPenalty);
             actualAmount = totalAmountReturned.sub(totalPenalty);
            }
            else{
             uint256 halfAmount = actualAmount.div(2);
             perDayPenalties[day] = perDayPenalties[day].add(halfAmount);
             originAmount = originAmount.add(halfAmount); 
            }
            return actualAmount;
            }
            else{
            return totalAmountReturned;
            }
    } 

    function settleStakes (address _sender,uint256 id) internal  {
        stakeRecord[] memory myRecord = stakeHolders[_sender];
        for(uint i=0; i<myRecord.length; i++){
            if(myRecord[i].id == id){
                myRecord[i].claimed = true;
                stakeHolders[_sender][i] = myRecord[i];
            }
        }
    }

    function removeStakeRecord(uint256 stakeShare,uint256 currDay,uint256 stakeEndDay) internal returns (uint256 share) {
        uint256 currentDay = findDay();
        for(uint j = currDay; j<=stakeEndDay;j++){
        TotalStakedShare[] memory records = perDayShareStakes[j];
        if(records.length > 0){
            for(uint i = 0; i<records.length; i++){
                if(records[i].share == stakeShare){
                  records[i].isRemoved = true;
                  perDayShareStakes[currentDay][i] = records[i];
                  share = records[i].share;
                  return share;
                }
            }
        }
     }
    }

    function calcNewShareRate (uint256 fullAmount,uint256 stakeShares,uint256 stakeDays) public view returns (uint256){
        uint256 BPB = findBiggerPayBetter(fullAmount);
        uint256 LPB = findLongerPaysBetter(fullAmount,stakeDays);
        uint256 newShareRate = fullAmount.add(BPB.add(LPB));
        newShareRate = newShareRate * 10 ** 2;
        newShareRate = newShareRate.div(stakeShares);
        return newShareRate ;
    }

    function claimStakeReward (uint id) public  {
        (bool _isStakeholder, ) = isStakeholder(msg.sender);
        require(_isStakeholder,'Not SH');
        stakeRecord[] memory myRecord2 = stakeHolders[msg.sender];
        stakeRecord memory stakeData;
        uint256 currDay = findDay();
        uint256 penaltyDay = currDay.add(1);
        uint256 dayToFindBonus;
        uint256 amountToNewShareRate;
        for(uint i=0; i<myRecord2.length; i++){
            if(myRecord2[i].id == id){ 
                stakeData = myRecord2[i];
            }
        }
        if(stakeData.endDay > currDay){
            dayToFindBonus = currDay;
        }
        else{
            dayToFindBonus = stakeData.endDay;
        }
        uint256 totalIntrestAmount = getAllDayReward(stakeData.startDay,dayToFindBonus,stakeData.stakeShare);
        if(block.timestamp < stakeData.endDayTimeStamp){
           require(stakeData.isFreeStake != true,"Free Stake can't be claim early");
            if(stakeData.numOfDays < 180){
                uint256 penalty = earlyPenaltyForShort(stakeData,totalIntrestAmount); 
                uint256 halfOfPenalty = penalty.div(2);
                uint256 compeleteAmount = stakeData.stakeAmount.add(totalIntrestAmount);
                uint256 amountToMint = 0;
                if(penalty < compeleteAmount){ 
                perDayPenalties[penaltyDay] = perDayPenalties[penaltyDay].add(halfOfPenalty);
                originAmount = originAmount.add(halfOfPenalty); 
                amountToMint = compeleteAmount.sub(penalty);
                }
                else{
                 uint256 halfAmount = compeleteAmount.div(2);
                 perDayPenalties[penaltyDay] = perDayPenalties[penaltyDay].add(halfAmount);
                 originAmount = originAmount.add(halfAmount); 
                }
                amountToNewShareRate = amountToMint;
                mintAmount(msg.sender,amountToMint);
            }
            
            if(stakeData.numOfDays >= 180){
                uint256 penalty = earlyPenaltyForLong(stakeData,totalIntrestAmount); 
                uint256 halfOfPenalty = penalty.div(2);
                uint256 compeleteAmount = stakeData.stakeAmount.add(totalIntrestAmount);
                uint256 amountToMint = 0;
                if(penalty < compeleteAmount){ 
                 perDayPenalties[penaltyDay] = perDayPenalties[penaltyDay].add(halfOfPenalty);
                 originAmount = originAmount.add(halfOfPenalty); 
                 amountToMint = compeleteAmount.sub(penalty);
                }
                else{
                 uint256 halfAmount = compeleteAmount.div(2);
                 perDayPenalties[penaltyDay] = perDayPenalties[penaltyDay].add(halfAmount);
                 originAmount = originAmount.add(halfAmount); 
                }
                amountToNewShareRate = amountToMint;
                mintAmount(msg.sender,amountToMint);
            }
            removeStakeRecord(stakeData.stakeShare,currDay,stakeData.endDay); 
        }

        if(block.timestamp >= stakeData.endDayTimeStamp){
         uint256 totalAmount = stakeData.stakeAmount.add(totalIntrestAmount);
         uint256 amounToMinted = latePenalties(stakeData,totalAmount);
         amountToNewShareRate = amounToMinted;
         mintAmount(msg.sender,amounToMinted);
        }
        settleStakes(msg.sender,id);
        uint256 newShare = calcNewShareRate(amountToNewShareRate, stakeData.stakeShare, stakeData.numOfDays);
        if(newShare > shareRate){
            shareRate = newShare;
        }
    }

    function getStakeRecords() public view returns (stakeRecord[] memory stakeHolder) {
        
        return stakeHolders[msg.sender];
    }

    function getStakeTotalShare(uint256 day) public view returns (TotalStakedShare[] memory data){
        return perDayShareStakes[day];
    }

    function getStakeTotalOfDay (uint256 dayToFind) public view returns (uint256){
        uint256 totalShares = 0;
         TotalStakedShare[] memory records = perDayShareStakes[dayToFind];
        if(records.length > 0){
            for(uint i = 0; i<records.length; i++){
                if(records[i].isRemoved == false){
                totalShares = totalShares.add(records[i].share);
                }
            }
        }
        return totalShares;

    }
    //Free Stake functionality
    function isFreeStakeholder(address _address) public view returns(bool, uint256) { 
        for (uint256 s = 0; s < freeStakeholders.length; s += 1){
            if (_address == freeStakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    function createFreeStake(address user,string memory btcAddress,uint balance,address refererAddress) public onlyOwner{
        require(block.timestamp < startDate + 31536000,'Free stakes available just 1 year');
        require(block.timestamp >= startDate ,'Free stakes not started yet');
        require(balance > 0, 'You need to have more than 0 Btc in your wallet');
        (bool _isFreeStakeholder, ) = isFreeStakeholder(user);
        if(!_isFreeStakeholder){
            freeStakeholders.push(user);
        }
        bool isClaimable = btcAddressClaims[btcAddress];
        require(!isClaimable,"Already claimed");
        uint day = findDay();
        distributeFreeStake(user,btcAddress,day,balance, refererAddress); 
        btcAddressClaims[btcAddress] = true;
        claimedBtcAddrCount ++ ;
        unClaimedBtc = unClaimedBtc.sub(balance);
        perDayUnclaimedBTC[day] = perDayUnclaimedBTC[day].add(balance);
        claimedBTC = claimedBTC.add(balance);
        
      
    }

    function findSillyWhalePenalty(uint256 amount) public pure returns (uint256){
        if(amount < 1000e8){
            return amount;
        }
        else if(amount >= 1000e8 && amount < 10000e8){  
            uint256 penaltyPercent = amount.sub(1000e8);
            penaltyPercent = penaltyPercent.mul(25 * 10 ** 2);
            penaltyPercent = penaltyPercent.div(9000e8); 
            penaltyPercent = penaltyPercent.add(50 * 10 ** 2); 
            uint256 deductedAmount = amount.mul(penaltyPercent); 
            deductedAmount = deductedAmount.div(10 ** 4);          
            uint256 adjustedBtc = amount.sub(deductedAmount);  
            return adjustedBtc;   
        }
        else { 
            uint256 adjustedBtc = amount.mul(25);
            adjustedBtc = adjustedBtc.div(10 ** 2);
            return adjustedBtc;  
        }
    }

    function findLatePenaltiy(uint256 dayPassed) public pure returns (uint256){
        uint256 totalDays = 350;
        uint256 latePenalty = totalDays.sub(dayPassed);
        latePenalty = latePenalty.mul( 10 ** 4);
        latePenalty = latePenalty.div(350);
        return latePenalty; 
    }

    function findSpeedBonus(uint256 day,uint256 share) public pure returns (uint256){
      uint256 speedBonus = 0;
      uint256 initialAmount = share;
      uint256 percentValue = initialAmount.mul(20);
      uint256 perDayValue = percentValue.div(350);  
      uint256 deductedAmount = perDayValue.mul(day);      
      speedBonus = percentValue.sub(deductedAmount);
      return speedBonus;

    }

    function findReferalBonus(address user,uint256 share,address referer) public pure returns(uint256) { 
       uint256 fixedAmount = share;
       uint256 sumUpAmount = 0;
      if(referer != address(0)){
       if(referer != user){
         
        // if referer is not user it self
        uint256 referdBonus = fixedAmount.mul(10);
        referdBonus = referdBonus.div(100);
        sumUpAmount = sumUpAmount.add(referdBonus);
       }
       else{
        // if a user referd it self  
        uint256 referdBonus = fixedAmount.mul(20);
        referdBonus = referdBonus.div(100);
        sumUpAmount = sumUpAmount.add(referdBonus);
        }
       }
       return sumUpAmount;
    }

    function createReferalRecords(address refererAddress, address referdAddress,uint256 awardedPTP) public {
        uint day = findDay();
        referalsRecord memory myRecord = referalsRecord({referdAddress:referdAddress,day:day,awardedPTP:awardedPTP});
        referals[refererAddress].push(myRecord);
    }

    function createFreeStakeClaimRecord(address userAddress,string memory btcAddress,uint256 day,uint256 balance,uint256 claimedAmount) internal onlyOwner{

     freeStakeClaimInfo memory myRecord = freeStakeClaimInfo({btcAddress:btcAddress,balanceAtMoment:balance,dayFreeStake:day,claimedAmount:claimedAmount,rawBtc:unClaimedBtc});
     freeStakeClaimRecords[userAddress].push(myRecord);
    }

    function freeStaking(uint256 stakeAmount,address userAddress) internal onlyOwner {
        uint256 id = generateId();
        uint256 dayInYear = 365;
        uint256 startDay = findDay();
        uint256 endDay = startDay.add(dayInYear);   
        uint256 endDayTimeStamp = findEndDayTimeStamp(endDay);
        // uint256 roiPercent = findPercentSlot();
        // uint256 BPB = findBiggerPayBetter(stakeAmount);
        stakerPool = stakerPool.add(stakeAmount);        
        // originAmount = originAmount.add(BPB);
        // uint256 LPB = findLongerPaysBetter(stakeAmount,dayInYear);
        // originAmount = originAmount.add(LPB);
        uint256 share = generateShare(stakeAmount,0,0);

        TotalStakedShare memory record = TotalStakedShare({share:share,endDay:endDay,isRemoved:false});
        for(uint i = startDay; i <= endDay;i++){
        perDayShareStakes[i].push(record);
        }
        stakeRecord memory myRecord = stakeRecord({id:id,stakeShare:share, stakeName:'', numOfDays:dayInYear,
         currentTime:block.timestamp,claimed:false,startDay:startDay,endDay:endDay,
        endDayTimeStamp:endDayTimeStamp,isFreeStake:true,stakeAmount:stakeAmount});
        stakeHolders[userAddress].push(myRecord); 

    }

    function distributeFreeStake(address userAddress,string memory btcAddress,uint256 day,uint256 balance,address refererAddress) internal {
            uint256 sillyWhaleValue = findSillyWhalePenalty(balance);
            uint share = sillyWhaleValue * 10 ** 8;
            share = share.div(10 ** 4);
            uint256 actualAmount = share;  
            uint256 latePenalty = findLatePenaltiy(day);
            actualAmount = actualAmount.mul(latePenalty);
            //Late Penalty return amount in 4 decimal to avoid decimal issue,
            // we didvide with 10 ** 4 to find actual amount 
            actualAmount = actualAmount.div(10 ** 4);
            //Speed Bonus
            
            uint256 userSpeedBonus = findSpeedBonus(day,actualAmount);
            userSpeedBonus = userSpeedBonus.div(100);
            actualAmount = actualAmount.add(userSpeedBonus);
            originAmount = originAmount.add(actualAmount);

            uint256 refBonus = 0;
           //Referal Mints 
            if(refererAddress != userAddress && refererAddress != address(0)){
                uint256 amount = actualAmount;
                uint256 referingBonus = amount.mul(20);
                referingBonus = referingBonus.div(100);
                originAmount = originAmount.add(referingBonus);
                mintAmount(refererAddress,referingBonus);
           }
        
         //Referal Bonus
            if(refererAddress != address(0)){
            refBonus = findReferalBonus(userAddress,actualAmount,refererAddress);
            actualAmount = actualAmount.add(refBonus);
            originAmount = originAmount.add(refBonus);
            createReferalRecords(refererAddress,userAddress,refBonus);
          }
         uint256 mintedValue = actualAmount.mul(10); 
         mintedValue = mintedValue.div(100);
         mintAmount(userAddress,mintedValue); 
         createFreeStakeClaimRecord(userAddress,btcAddress,day,balance,mintedValue);

         uint256 stakeAmount = actualAmount.mul(90);
         stakeAmount = stakeAmount.div(100); 
         freeStaking(stakeAmount,userAddress);
    }

    function getFreeStakeClaimRecord() public view returns (freeStakeClaimInfo[] memory claimRecords){
       return freeStakeClaimRecords[msg.sender];
    } 

    function extendStakeLength(uint256 totalDays, uint256 id) public { 
        stakeRecord[] memory myRecord = stakeHolders[msg.sender];
        for(uint i=0; i<myRecord.length; i++){
            if(myRecord[i].id == id){
                if(myRecord[i].isFreeStake){
                    if(totalDays >= 365){
                        require(myRecord[i].startDay + totalDays > myRecord[i].numOfDays , 'condition should not be meet');
                        myRecord[i].numOfDays = myRecord[i].startDay + totalDays;
                        myRecord[i].endDay = (myRecord[i].startDay).add(totalDays);
                        myRecord[i].endDayTimeStamp = findEndDayTimeStamp(myRecord[i].endDay);
                    }
                }
             stakeHolders[msg.sender][i] = myRecord[i];
            }
        }
    }

    function findAddress(uint256 day, address sender)public view returns(bool){
        address addressValue = AARecords[day][sender].user;
        if(addressValue == address(0)){
            return false;
        }
        else{
           return true;
        }
    }

    function enterAALobby (address refererAddress) external payable {
        require(msg.value > 0, '0 Balance');
        uint day = findDay();
        // address refererAddress = getRefererAddress(msg.sender);
        RecordInfo memory myRecord = RecordInfo({amount: msg.value, time: block.timestamp, claimed: false, user:msg.sender,refererAddress:refererAddress});
        bool check = findAddress(day,msg.sender);
        if(check == false){
            AARecords[day][msg.sender] = myRecord;
            perDayAARecords[day].push(msg.sender);
        }  
        else{
            RecordInfo memory record = AARecords[day][msg.sender];
            record.amount = record.amount.add(msg.value);
            AARecords[day][msg.sender] = record;
        }
      
        totalBNBSubmitted[day] = totalBNBSubmitted[day] + msg.value;
    }

    function getTotalBNB (uint day) public view returns (uint256){
        
       return totalBNBSubmitted[day];
    }

    function getAvailablePTP (uint day) public view returns (uint256 daySupply){
        uint256 hexAvailabel = 0;
       
        uint256 firstDayAvailabilty = 1000000000 * 10 ** 8; 
        if(day == 0){
            hexAvailabel = firstDayAvailabilty;
        }
        else{
            uint256 othersDayAvailability = 19000000 * 10 ** 8;
            uint256 totalUnclaimedToken = 0;
            for(uint256 i = 0; i < day; i++){
                totalUnclaimedToken= totalUnclaimedToken.add(perDayUnclaimedBTC[i]);
            }
            
            othersDayAvailability = othersDayAvailability.sub(totalUnclaimedToken);
            //as per rules we have to multiply it with 10^8 than divided with 10 ^ 4 but as we can make it multiply 
            //with 10 ^ 4
            othersDayAvailability = othersDayAvailability.mul(10 ** 4);
            hexAvailabel = othersDayAvailability.div(350);
        }
        daySupply = hexAvailabel;
       return daySupply;
    }

    function getTransactionRecords(uint day,address user) public view returns (RecordInfo memory record) {   
            return AARecords[day][user];
    }

    function countShare (uint256 userSubmittedBNB, uint256 dayTotalBNB, uint256 availablePTP) public pure returns  (uint256) {
        uint256 share = 0;
        share = userSubmittedBNB.div(dayTotalBNB);
        share = share.mul(availablePTP);
        return share;
    }

    function settleSubmission (uint day, address user) internal  {
        RecordInfo memory myRecord = AARecords[day][user];
                 myRecord.claimed = true;
                 AARecords[day][user] = myRecord;
    }

    function claimAATokens () public {
        uint256 presentDay = findDay();
        require(presentDay > 0,'not now');
        uint256 prevDay = presentDay.sub(1);
        uint256 dayTotalBNB = getTotalBNB(prevDay);
        uint256 availablePTP = getAvailablePTP(prevDay);
        RecordInfo memory record = getTransactionRecords(prevDay,msg.sender);
        if(record.user != address(0) && record.claimed == false){
           uint256 userSubmittedBNB = record.amount;
           uint256 userShare = 0;
           uint256 referalBonus = 0;
           userShare = countShare(userSubmittedBNB,dayTotalBNB,availablePTP);
            address userReferer = record.refererAddress;
             if(userReferer != msg.sender && userReferer !=address(0)){
             uint256 amount = userShare;
             uint256 referingBonus = amount.mul(20);
             referingBonus = referingBonus.div(100);
             originAmount = originAmount.add(referingBonus);
             mintAmount(userReferer,referingBonus);
             createReferalRecords(userReferer,msg.sender,referingBonus);
             }
            referalBonus =  findReferalBonus(msg.sender,userShare,userReferer);  
             userShare = userShare.add(referalBonus);
             originAmount = originAmount.add(referalBonus);
             mintAmount(msg.sender,userShare);
             settleSubmission(prevDay,msg.sender);
             if(userReferer != address(0)){
            createReferalRecords(userReferer,msg.sender,referalBonus);
             }
        }
    }

    function getReferalRecords(address refererAddress) public view returns (referalsRecord[] memory referal) {
        
        return referals[refererAddress];
    }

    function unclaimedRecord(uint256 presentDay) external onlyOwner {
        uint256 prevDay = presentDay.sub(2);
        uint256 dayTotalBNB = getTotalBNB(prevDay);
        uint256 availablePTP = getAvailablePTP(prevDay);
        address[] memory allUserAddresses = perDayAARecords[prevDay];
        if(allUserAddresses.length > 0){
            for(uint i = 0; i < allUserAddresses.length; i++){
                uint256 userSubmittedBNB = 0;
                uint256 userShare = 0;
                RecordInfo memory record = getTransactionRecords(prevDay,allUserAddresses[i]);
                if(record.claimed == false){
                    userSubmittedBNB = record.amount;
                    userShare = countShare(userSubmittedBNB,dayTotalBNB,availablePTP);
                    unclaimed_BTC_Payout_Bucket = unclaimed_BTC_Payout_Bucket.add(userShare);
                    settleSubmission(prevDay,allUserAddresses[i]);
                }
            
            } 
        }  
        else{
         unclaimed_BTC_Payout_Bucket = unclaimed_BTC_Payout_Bucket.add(availablePTP);
        }
    }

    function transferPTP(address recipientAddress, uint256 _amount) public{
        _transfer(msg.sender,recipientAddress,_amount);
        transferInfo memory myRecord = transferInfo({amount: _amount,to:recipientAddress, from: msg.sender});
        transferRecords[msg.sender].push(myRecord);
    }

    function getTransferRecords( address _address ) public view returns (transferInfo[] memory transferRecord) {
        return transferRecords[_address];
    }
    //Origin Amount
    function getOriginAmount() public view returns (uint256){
        return originAmount;
    }

    function setBigPayDay(uint256 day) public onlyOwner{
        bool dayCheck = bigPayDayCheck[day];
        require(!dayCheck,"Already Set");
        uint256 btc = unClaimedBtc.div(10 ** 8);
        uint256 bigPayDayAmount = btc.mul(2857);
        //it should be divieded with 10 ** 6 but we have to convert it in hex so we div it 10 ** 2
        bigPayDayAmount = bigPayDayAmount.div(10 ** 2);
        unclaimed_BTC_Payout_Bucket = unclaimed_BTC_Payout_Bucket.add(bigPayDayAmount);
        if(day >= 1 ){
        uint256 _prevDay = day.sub(1);
        bool _prevDayCheck = bigPayDayCheck[_prevDay];
        if(!_prevDayCheck){
           unclaimed_BTC_Payout_Bucket = unclaimed_BTC_Payout_Bucket.add(bigPayDayAmount);
            bigPayDayCheck[_prevDay] = true;
        }}
        bigPayDayCheck[day] = true;
    }

    function getBigPayDay() public view returns (uint256){
        return unclaimed_BTC_Payout_Bucket;
    }
    
    function getShareRate() public view returns (uint256){
        return shareRate;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

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
        return 8;
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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