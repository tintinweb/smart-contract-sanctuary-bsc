// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./hashVerfication.sol";

contract MYNTIST is ERC20 {
    uint32 internal constant startDate = 1662100800;
    uint32 internal constant timeSlot = 120;
    // uint32 internal constant yearStamp = timeSlot * 350;
    uint32 internal counterId = 0;//change
    address internal originAddress = 0x6b26678F4f392B0E400CC419FA3E5161759ca380;
    uint256 internal originAmount = 0;
    uint256 internal unClaimedBtc = 19000000 * 10**8;
    uint256 internal claimedBTC = 0;
    uint32 internal constant shareRateDecimals = 10**5;//change
    uint8 internal constant shareRateUintSize = 40;
    uint256 internal constant shareRateMax = (1 << shareRateUintSize) - 1;
    uint256 shareRate;
    uint32 internal claimedBtcAddrCount = 0;//change
    uint256 internal lastUpdatedDay; 
    uint256 internal unClaimAATokens;
    address[] internal stakeAddress;
     uint256 internal constant claimeableBtcAddrCount = 27997742;
    SignatureVerification verfiyContract;

    // onlyOwner
    address internal owner;
    modifier onlyOwner() {
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
        uint256 numOfDays;
        uint256 currentTime;
        bool claimed;
        uint256 id;
        uint256 startDay;
        uint256 endDay;
        uint256 endDayTimeStamp;
        bool isFreeStake;
        string stakeName;
        uint256 stakeAmount;
        uint256 sharePrice;
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
        uint256 awardedMynt;
    }

    struct dailyData {
        uint256 dayPayout;
        uint256 stakeShareTotal;
        uint256 unclaimed;
        uint256 mintedTokens;
        uint256 stakedToken;
    }

    mapping(uint256 => mapping(address => RecordInfo)) public AARecords;
    mapping(address => referalsRecord[]) public referals;
    mapping(uint256 => uint256) public totalBNBSubmitted;
    mapping(uint256 => address[]) public perDayAARecords;
    mapping(address => uint256) internal stakes;
    mapping(address => stakeRecord[]) public stakeHolders;
    mapping(address => transferInfo[]) public transferRecords;
    mapping(address => freeStakeClaimInfo[]) public freeStakeClaimRecords;
    mapping(string => bool) public btcAddressClaims;
    mapping(uint256 => uint256) public perDayPenalties;
    mapping(uint256 => uint256) public perDayUnclaimedBTC;
    mapping(uint256 => dailyData) public dailyDataUpdation;
    mapping(uint256 => uint256) public subtractedShares;
    event CreateStake(uint256 id, uint256 stakeShares);
    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    constructor() ERC20("MYNTIST", "MYNT") {
        owner = msg.sender;
        lastUpdatedDay = 0;
        shareRate = 1 * shareRateDecimals;
        verfiyContract = SignatureVerification(
            0x698d1355329FBB711b3cee811EDCed43c86c6234
        );
        //  _mint(0x6b26678F4f392B0E400CC419FA3E5161759ca380, 10000000000000);
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(payable(address(this)).balance);
    }

    function mintAmount(address user, uint256 amount) internal {
        uint256 currentDay = findDay();
        dailyDataUpdation[currentDay].mintedTokens = dailyDataUpdation[currentDay].mintedTokens + amount;
        _mint(user, amount);
    }

    function findDay() internal view returns (uint256) {
        return (block.timestamp - startDate) / timeSlot;
    }

    function updateDailyData(uint256 beginDay, uint256 endDay) internal {
          if(lastUpdatedDay == 0){
            beginDay = 0;
        }
        
        for(uint256 i = beginDay; i<= endDay; i++){
            uint256 iterator = i;
            if(iterator != 0){
                iterator = iterator - 1;
            }

            // TODO (verified in remix) (to be tested here)
            // updating data to current day from previous day I(verified in remix) (to be tested here)
            dailyDataUpdation[i].dayPayout = getDailyShare(iterator);
            dailyDataUpdation[i].stakeShareTotal = dailyDataUpdation[iterator].stakeShareTotal - subtractedShares[i];
            dailyDataUpdation[i].unclaimed = dailyDataUpdation[iterator].unclaimed;
            dailyDataUpdation[i].mintedTokens = dailyDataUpdation[iterator].mintedTokens;
            dailyDataUpdation[i].stakedToken = dailyDataUpdation[iterator].stakedToken;
            if(i >= 2){
                uint256 unClaimAmount = unclaimedRecord(i);
                unClaimAATokens = unClaimAATokens + unClaimAmount;
            }
        }

        lastUpdatedDay = endDay;
    }

    function getDailyData(uint256 day) public view returns (dailyData memory) {
        if (lastUpdatedDay < day) {
            return dailyDataUpdation[lastUpdatedDay];
        } else {
            return dailyDataUpdation[day];
        }
    }

    function isStakeholder(address _address)
        public
        view
        returns (bool, uint256)
    {
        for (uint16 s = 0; s < stakeAddress.length; s += 1) {
            if (_address == stakeAddress[s]) return (true, s);
        }
        return (false, 0);
    }

    function findBiggerPayBetter(uint256 inputMynt)
        internal
        pure
        returns (uint256)
    {
        /*
        Staking HEX for amounts up to 150,000,000 receives a quadratically
        increasing bonus up to 10% of the input MYNT.

        bonus = (input * (min(input, 150e6)/1500e6)
         */

        uint256 minValue = 0;
        if (inputMynt <= (150000000 * 10**8)) {
            minValue = inputMynt;
        } else {
            minValue = (150000000 * 10**8);
        }
        
        return ( inputMynt * minValue ) / (1500000000 * 10**8);
    }

    function findLongerPaysBetter(uint256 inputMynt, uint256 numOfDays)
        internal
        pure
        returns (uint256)
    {
        if (numOfDays > 3641) {
            numOfDays = 3641;
        }
        /*
        Staking HEX for 2 to 3641 days receives a linearly increasing bonus up to 2x the input HEX.

        bonus = input HEX * (days - 1) / 1820;
        
        */
        return (inputMynt * (numOfDays - 1)) / 1820;
    }

    function generateShare(
        uint256 inputMynt,
        uint256 LPB,
        uint256 BPB
    ) internal view returns (uint256) {
        /*
        Shares are generated on stake generate using Longer Pays Better, Bigger Pays Better and share Rate.

        bonusBrooms = LongerPaysBetterBonus + BiggerPaysBetterBonus;
        shareRateDecimals = 10**5; (Value to handle Decimal issue in shareRate);
        shareRate (Current Share Rate)
        Formula:-
        (newStakedBrooms + bonusBrooms) * shareRateDecimals / shareRate;
        
        */
        return ((LPB + BPB + inputMynt) / shareRate) * shareRateDecimals;
    }

    function createStake(
        uint256 _stake,
        uint256 day,
        string memory stakeName
    ) external {
        require(balanceOf(msg.sender) >= _stake, "Low Balance");
        uint256 BPB = findBiggerPayBetter(_stake);
        uint256 LPB = findLongerPaysBetter(_stake, day);
        
        uint256 share = generateShare(_stake, LPB, BPB);
        require(share >= 1, "low shares");
        
        (bool _isStakeholder, ) = isStakeholder(msg.sender);

        if (!_isStakeholder) {
            stakeAddress.push(msg.sender);
        }
        _burn(msg.sender, _stake);

        originAmount = originAmount + LPB + BPB;

        uint256 currentDay = findDay();
        uint256 endDay = currentDay + day;
        uint256 endDayTimeStamp = block.timestamp + (day * timeSlot);
        if (currentDay > lastUpdatedDay) {
            updateDailyData(lastUpdatedDay + 1, currentDay);
        }
        
        subtractedShares[endDay] = subtractedShares[endDay] + share;

        stakeHolders[msg.sender].push( stakeRecord({
            id: counterId++,
            stakeShare: share,
            stakeName: stakeName,
            numOfDays: day,
            currentTime: block.timestamp,
            claimed: false,
            startDay: currentDay,
            endDay: endDay,
            endDayTimeStamp: endDayTimeStamp,
            isFreeStake: false,
            stakeAmount: _stake,
            sharePrice: shareRate
        }) );

        dailyDataUpdation[currentDay].stakeShareTotal = dailyDataUpdation[currentDay].stakeShareTotal + share;
        dailyDataUpdation[currentDay].dayPayout = getDailyShare(currentDay);
        dailyDataUpdation[currentDay].unclaimed = unClaimedBtc;
        dailyDataUpdation[currentDay].mintedTokens = dailyDataUpdation[currentDay].mintedTokens - _stake;
        dailyDataUpdation[currentDay].stakedToken = dailyDataUpdation[currentDay].stakedToken + _stake;
        emit CreateStake(counterId++, share);
    }

    function transferStake(uint256 id, address transferTo) external {
        uint256 currentDay = findDay();
        if (currentDay > lastUpdatedDay) {
            updateDailyData(lastUpdatedDay + 1, currentDay);
        }
        
        for (uint16 i = 0; i < stakeHolders[msg.sender].length; i++) {
            if (stakeHolders[msg.sender][i].id == id) {
                stakeHolders[transferTo].push(stakeHolders[msg.sender][i]);
                delete (stakeHolders[msg.sender][i]);
            }
        }
    }

    function getDailyShare(uint256 day)
        public
        view
        returns (uint256)
    {
        /*
            Inflation of 3.69% inflation per 364 days

            dailyInterestRate = exp(log(1 + 3.69%)  / 364) - 1
                     = exp(log(1 + 0.0369) / 364) - 1
                     = exp(log(1.0369) / 364) - 1
                     = 0.000099553011616349            (approx)


                    payout = allocSupply * dailyInterestRate
                     = allocSupply / (1 / dailyInterestRate)
                     = allocSupply / (1 / 0.000099553011616349)
                     = allocSupply / 10044.899534066692            (approx)
                     = allocSupply * 10000 / 100448995             (* 10000/10000 for int precision)
        
         */
        dailyData memory data = getDailyData(day);
        return (((data.mintedTokens + data.stakedToken) * 10000) / 100448995) + perDayPenalties[day];
    }

    function findBPDPercent(uint256 share, uint256 totalSharesOfBPD)
        internal
        pure
        returns (uint256)
    {
        /*
         Used to find user share percentage in Big Pay Day Shares
            
            uint256 totalShares = totalSharesOfBPD;
            uint256 sharePercent = share * 10**4;
            sharePercent = sharePercent / totalShares;
            sharePercent = sharePercent * 10**2;
        
        */
        return ((share * 10**4) / totalSharesOfBPD) * 10**2;
    }

    function findStakeSharePercent(uint256 share, uint256 day)
        internal
        view
        returns (uint256)
    {
        /*  
        Used to find user share percentage in specific day Shares
        
        uint256 sharePercent = share * 10**4;
        sharePercent = sharePercent / stakeShareTotalofDay;
        sharePercent = sharePercent * 10**2; 
        
        */
        
        return ((share * 10**4) / dailyDataUpdation[day].stakeShareTotal) * 10**2;
    }

    function calcAdoptionBonus(uint256 payout)
        internal
        view
        returns (uint256)
    {

          /*
            VIRAL REWARDS: Add adoption percentage bonus to payout

            viral = payout * (claimedBtcAddrCount / CLAIMABLE_BTC_ADDR_COUNT)


            CRIT MASS REWARDS: Add adoption percentage bonus to payout

            crit  = payout * (claimedSatoshisTotal / CLAIMABLE_SATOSHIS_TOTAL)

             = crit + viral
        */   
        return ((payout * claimedBtcAddrCount) / claimeableBtcAddrCount) + ((payout * claimedBTC) / unClaimedBtc);
    }

    function getAllDayReward(
        uint256 beginDay,
        uint256 endDay,
        uint256 stakeShare
    ) internal view returns (uint256) {
        uint256 totalIntrestAmount = 0;
        /*
        Used To Calc User All day intrest using Shares
        (It will run for each num of days)

            uint256 currDayAmount = userDayShare * stakeShare;
            currDayAmount = currDayAmount / stakeShareTotalofDay;
            totalIntrestAmount = totalIntrestAmount + currDayAmount;

        */
        for (uint256 day = beginDay; day < endDay; day++) {
            totalIntrestAmount = totalIntrestAmount + ((getDailyShare(day) * stakeShare) / dailyDataUpdation[day].stakeShareTotal);
        }
      
        // for checking big pay day
        if (beginDay <= 351 && endDay > 351) {
            /*
            To calc user Big Pay Day Share

            uint256 sharePercentOfBPD = findBPDPercent(
                stakeShare,
                bpdData.stakeShareTotal
            );
            uint256 bigPayDayAmount = getBigPayDay();
            bigPayDayAmount = bigPayDayAmount + unClaimAATokens;
            uint256 bigPaySlice = bigPayDayAmount * sharePercentOfBPD;
            bigPaySlice = (bigPaySlice / 100) * 10**4;
            totalIntrestAmount = bigPaySlice + _calcAdoptionBonus(bigPaySlice);
            */
            uint256 bigPaySlice = (((getBigPayDay() + unClaimAATokens) * (findBPDPercent(stakeShare, dailyDataUpdation[350].stakeShareTotal))) / 100) * 10**4;
            totalIntrestAmount = totalIntrestAmount + bigPaySlice + calcAdoptionBonus(bigPaySlice);
        }
        return totalIntrestAmount;
    }

    function findEstimatedIntrest(uint256 stakeShare, uint256 startDay)
        internal
        view
        returns (uint256)
    {
        /*
        Used To Find the estimated intrest for user stake

        uint256 day = findDay();
        uint256 sharePercent = findStakeSharePercent(stakeShare, startDay);
        uint256 dailyEstReward = getDailyShare(day);
        uint256 perDayProfit = dailyEstReward * sharePercent;
        perDayProfit = (perDayProfit / 100) * 10**4;

        */
        return ((getDailyShare(findDay()) * (findStakeSharePercent(stakeShare, startDay))) / 100) * 10**4;
    }

    function getDayRewardForPenalty(
        uint256 beginDay,
        uint256 stakeShare,
        uint256 dayData
    ) internal view returns (uint256) {

        /*
        Used to calc Day Reward for Penalty

        uint256 totalIntrestAmount = 0;
       
        for (uint256 day = beginDay; day < beginDay + dayData; day++) {
           
          uint256  dayShare = getDailyShare(day);
            totalIntrestAmount = dayShare * stakeShare;
           
            dailyData memory data = dailyDataUpdation[day];
            totalIntrestAmount = totalIntrestAmount / data.stakeShareTotal;
        }
      
        return totalIntrestAmount;
        
        */

        uint256 totalIntrestAmount = 0;
      
        for (uint256 day = beginDay; day < beginDay + dayData; day++) {
        
            totalIntrestAmount = (getDailyShare(day) * stakeShare) / dailyDataUpdation[day].stakeShareTotal;
        }
       
        return totalIntrestAmount;
    }

    function earlyPenaltyForShort(
        // stakeRecord memory stakeData,
        uint256 totalIntrestAmount,
        uint256 currentTime,
        uint256 stakeShare,
        uint256 startDay
    ) internal view returns (uint256) {

        /*
        For Stake < 180 Days
        
        If 0 days Completed
        penalty = EstimatedIntrestAccumalted * 90;

        less than 90 days completed 
        Penalty =  IntrestAccumalted * 90 /DayServed

        if 90 days Completed
        penalty = totalIntrestAmount;

        if more than 90 days pass

        penalty = Intrest Amount to 90 days;

        */

        uint256 emergencyDayEnd = (block.timestamp - currentTime) / timeSlot;
        uint256 penalty = 0;
        if (emergencyDayEnd == 0) {
             penalty = (findEstimatedIntrest(stakeShare, startDay)) * 90;
        }

        if (emergencyDayEnd < 90 && emergencyDayEnd != 0) {
            penalty = (totalIntrestAmount * 90) / emergencyDayEnd;
        }

        if (emergencyDayEnd == 90) {
            penalty = totalIntrestAmount;
        }

        if (emergencyDayEnd > 90) {
            //reason to using 89 instead of 90 here is beacuse our day start from 0
            penalty = totalIntrestAmount - (getDayRewardForPenalty(startDay, stakeShare, 89));
        }
        return penalty;
    }


    function earlyPenaltyForLong(
        // stakeRecord memory stakeData,
        uint256 totalIntrestAmount,
        uint256 currentTime,
        uint256 stakeShare,
        uint256 startDay,
        uint256 numOfDays
    ) internal view returns (uint256) {
        uint256 emergencyDayEnd = (block.timestamp - currentTime) / timeSlot;
        uint256 endDay = numOfDays;
        uint256 halfOfStakeDays = endDay / 2;
        uint256 penalty;

         /*
        For Stake >= 180 Days
        
        If 0 days Completed
        penalty = EstimatedIntrestAccumalted * half Commited Days;

        less than Half days completed 
        Penalty =  IntrestAccumalted * half Commited Day /DayServed

        if Half days Completed
        penalty = totalIntrestAmount;

        if more than half days pass

        penalty = Intrest Amount to after half days;

        */
        if (emergencyDayEnd == 0) {
            penalty = (findEstimatedIntrest(stakeShare, startDay)) * halfOfStakeDays;
        }

        if (emergencyDayEnd < halfOfStakeDays && emergencyDayEnd != 0) {
            penalty = (totalIntrestAmount * halfOfStakeDays) / emergencyDayEnd;
        }

        if (emergencyDayEnd == halfOfStakeDays) {
            penalty = totalIntrestAmount;
        }

        if (emergencyDayEnd > halfOfStakeDays) {
            penalty = totalIntrestAmount - getDayRewardForPenalty(startDay, stakeShare, halfOfStakeDays);
        }
        return penalty;
    }

    function latePenalties(
        uint256 totalAmountReturned,
        uint256 endDayTimeStamp

    ) internal returns (uint256) {

        /*
        There is a 14 day grace period to choose either “End Stake” or “Good Accounting” once your stake ends After 14 days, you will suffer a 1% weekly penalty for every week you do not “End Stake” or select “Good Accounting”. 
        */
        uint256 dayAfterEnd = (block.timestamp - endDayTimeStamp) / timeSlot;
        if (dayAfterEnd > 14) {
            uint256 totalPenalty = dayAfterEnd * (((totalAmountReturned * 143) / 1000) / 100);
            uint256 halfOfPenalty = (totalPenalty) / 2;
            uint256 actualAmount = 0;
            uint256 day = findDay() + 1;
            if (totalPenalty < totalAmountReturned) {
                perDayPenalties[day] = perDayPenalties[day] + halfOfPenalty;
                originAmount = originAmount + halfOfPenalty;
                actualAmount = totalAmountReturned - totalPenalty;
            } else {
                uint256 halfAmount = actualAmount / 2;
                perDayPenalties[day] = perDayPenalties[day] + halfAmount;
                originAmount = originAmount + halfAmount;
            }
            return actualAmount;
        } else {
            return totalAmountReturned;
        }
    }

    function settleStakes(address _sender, uint256 id) internal {
        for (uint16 i = 0; i < stakeHolders[_sender].length; i++) {
            if (stakeHolders[_sender][i].id == id) {
                stakeHolders[_sender][i].claimed = true;
            }
        }
    }

    function calcNewShareRate(
        uint256 fullAmount,
        uint256 stakeShares,
        uint256 stakeDays
    ) internal pure returns (uint256) {
        
        /*
        New Share Rate = ((input HEX + payouts) + bonuses((input HEX + payouts), stake days)) / shares
        */

        uint256 newShareRate = ((fullAmount + findBiggerPayBetter(fullAmount) + findLongerPaysBetter(fullAmount, stakeDays)) * shareRateDecimals) / stakeShares;

        if (newShareRate > shareRateMax) {
            newShareRate = shareRateMax;
        }


        // TODO verify share rate condition
        // if (newShareRate > shareRate * 4) {
        //     newShareRate = shareRate * 4;
        // }
        return newShareRate;
    }

    function claimStakeReward(uint256 id) external {
        (bool _isStakeholder, ) = isStakeholder(msg.sender);
        require(_isStakeholder, "Not stake holder");

        stakeRecord memory stakeData;
        uint256 currDay = findDay();
        uint256 dayToFindBonus;
        uint256 amountToNewShareRate;
        if (currDay > lastUpdatedDay) {
            updateDailyData(lastUpdatedDay + 1, currDay);
        }
        for (uint16 i = 0; i < stakeHolders[msg.sender].length; i++) {
            if (stakeHolders[msg.sender][i].id == id) {
                stakeData = stakeHolders[msg.sender][i];
            }
        }
        if (stakeData.endDay > currDay) {
            dayToFindBonus = currDay;
        } else {
            dayToFindBonus = stakeData.endDay;
        }
        uint256 totalIntrestAmount = getAllDayReward(
            stakeData.startDay,
            dayToFindBonus,
            stakeData.stakeShare
        );
        if (block.timestamp < stakeData.endDayTimeStamp) {
            require(
                stakeData.isFreeStake != true,
                "can't be claim yet"
            );
            uint256 penalty;
            if (stakeData.numOfDays < 180) {
                penalty = earlyPenaltyForShort(totalIntrestAmount,stakeData.currentTime,stakeData.stakeShare,stakeData.startDay);
            }

            if (stakeData.numOfDays >= 180) {
                penalty = earlyPenaltyForLong(totalIntrestAmount,stakeData.currentTime,stakeData.stakeShare,stakeData.startDay,stakeData.numOfDays);
            }

            uint256 halfOfPenalty = penalty / 2;
            uint256 compeleteAmount = stakeData.stakeAmount +
                totalIntrestAmount;
            uint256 amountToMint = 0;
            if (penalty < compeleteAmount) {
                perDayPenalties[currDay + 1] =
                    perDayPenalties[currDay + 1] +
                    halfOfPenalty;
                originAmount = originAmount + halfOfPenalty;
                amountToMint = compeleteAmount - penalty;
            } else {
                uint256 halfAmount = compeleteAmount / 2;
                perDayPenalties[currDay + 1] =
                    perDayPenalties[currDay + 1] +
                    halfAmount;
                originAmount = originAmount + halfAmount;
            }
            dailyDataUpdation[currDay].stakeShareTotal = dailyDataUpdation[currDay].stakeShareTotal - stakeData.stakeShare;
            amountToNewShareRate = amountToMint;
            mintAmount(msg.sender, amountToMint);
        }

        if (block.timestamp >= stakeData.endDayTimeStamp) {
            uint256 amounToMinted = latePenalties( stakeData.stakeAmount + totalIntrestAmount,stakeData.endDayTimeStamp);
            amountToNewShareRate = amounToMinted;
            mintAmount(msg.sender, amounToMinted);
        }
        settleStakes(msg.sender, id);
        uint256 newShare = calcNewShareRate(
            amountToNewShareRate,
            stakeData.stakeShare,
            stakeData.numOfDays
        );
        if (newShare > shareRate) {
            shareRate = newShare;
        }
        dailyDataUpdation[currDay].stakedToken = dailyDataUpdation[currDay].stakedToken - stakeData.stakeAmount;
    }

    function getStakeRecords()
        external
        view
        returns (stakeRecord[] memory stakeHolder)
    {
        return stakeHolders[msg.sender];
    }

    function getStakeSharePercent(
        address user,
        uint256 stakeId,
        uint256 dayToFind
    ) external view returns (uint256) {
        /*
        used To calc user Stake Share %
           sharePercent =  stakeShare * 10**4;
            sharePercent = sharePercent / data.stakeShareTotal;
        */
        uint256 sharePercent;
        for (uint16 i = 0; i < stakeHolders[user].length; i++) {
            if (stakeHolders[user][i].id == stakeId) {
                sharePercent = (stakeHolders[user][i].stakeShare * 10**4) / dailyDataUpdation[dayToFind].stakeShareTotal;
            }
        }
        return sharePercent;
    }

    //Free Stake functionality

    function createFreeStake(
        uint256 autoStakeDays,
        string memory btcAddress,
        uint256 balance,
        address refererAddress,
        bytes32[] calldata proof,
        bytes32 messageHash,
        bytes32 pubKeyX,
        bytes32 pubKeyY,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // require(block.timestamp >= startDate && block.timestamp < yearStamp ,'Invalid Day');
        require(balance > 0, "Low Balance");
        bool verfication = verfiyContract.btcAddressClaim(
            balance,
            proof,
            messageHash,
            pubKeyX,
            pubKeyY,
            v,
            r,
            s
        );
        require(verfication, "not verfied");
        uint256 day = findDay();
        uint256 stakeDays = autoStakeDays;
        uint256 userBtcBalance = balance;
        string memory userBtcAddress = btcAddress;
        address userReferer = refererAddress;

        if (day > lastUpdatedDay) {
            updateDailyData(lastUpdatedDay + 1, day);
        }

        distributeFreeStake(
            msg.sender,
            userBtcAddress,
            day,
            userBtcBalance,
            userReferer,
            stakeDays
        );
        unClaimedBtc = unClaimedBtc - userBtcBalance;
        perDayUnclaimedBTC[day] = perDayUnclaimedBTC[day] + userBtcBalance;
        claimedBTC = claimedBTC + userBtcBalance;
        btcAddressClaims[userBtcAddress] = true;
        claimedBtcAddrCount++;
        dailyData memory dailyRecord = dailyDataUpdation[day];
        dailyRecord.unclaimed = unClaimedBtc;

        dailyRecord.dayPayout = getDailyShare(day);

        dailyDataUpdation[day] = dailyRecord;
    }

    function findSillyWhalePenalty(uint256 amount)
        internal
        pure
        returns (uint256)
    {

        /*
        
        Equal to 1 for addresses with less than 1,000 Bitcoins
        Equal to 0.5 for addresses at 1,000 Bitcoins
        Scales linearly to 0.25 for addresses at 10,000 Bitcoins
        For our example, the Silly Whale Penalty would be 0.444

      if (amount < 1000e8) {
            return amount;
        } else if (amount >= 1000e8 && amount < 10000e8) {
            uint256 penaltyPercent = amount - 1000e8;
            penaltyPercent = penaltyPercent * 25 * 10**2;
            penaltyPercent = penaltyPercent / 9000e8;
            penaltyPercent = penaltyPercent + 50 * 10**2;
            uint256 deductedAmount = amount * penaltyPercent;
            deductedAmount = deductedAmount / 10**4;
            uint256 adjustedBtc = amount - deductedAmount;
            return adjustedBtc;
        } else {
            uint256 adjustedBtc = amount * 25;
            adjustedBtc = adjustedBtc / 10**2;
            return adjustedBtc;
        }

        */

        if (amount < 1000e8) {
            return amount;
        } else if (amount >= 1000e8 && amount < 10000e8) {
         
            return amount - ((amount * ((((amount - 1000e8) * 25 * 10**2) / 9000e8) + 50 * 10**2)) / 10**4);
          } else {
            return (amount * 25) / 10**2;
           }
    }

    function findLatePenaltiy(uint256 dayPassed)
        internal
        pure
        returns (uint256)
    {
      /*
        uint256 totalDays = 350;
        uint256 latePenalty = totalDays - dayPassed;
        latePenalty = latePenalty * 10**4;
        latePenalty = latePenalty / 350;

        On the first claim day, 0 days were passed
        For our example, assume 30 days have passed, so the Late Penalty is 0.914
     */
        return ((350 - dayPassed) * 10**4) / 350;
      
    }

    function findSpeedBonus(uint256 day, uint256 share)
        internal
        pure
        returns (uint256)
    {
        /*
        uint256 speedBonus = 0;
        uint256 initialAmount = share;
        uint256 percentValue = initialAmount * 20;
        uint256 perDayValue = percentValue / 350;
        uint256 deductedAmount = perDayValue * day;
        speedBonus = percentValue - deductedAmount;
        */
        uint256 percentValue = share * 20;
        uint256 deductedAmount = (percentValue / 350) * day;
        return percentValue - deductedAmount;
    }

    function findReferalBonus(
        address user,
        uint256 share,
        address referer
    ) internal returns (uint256) {
        uint256 sumUpAmount = 0;
        if (referer != address(0)) {
            if (referer != user) {
                // if referer is not user it self
                sumUpAmount = (share * 10) / 100;
            } else {
                // if a user referd it self
                sumUpAmount = (share * 20) / 100;
                createReferalRecords(referer, user, sumUpAmount);
            }
        }
        return sumUpAmount;
    }

    function createReferalRecords(
        address refererAddress,
        address referdAddress,
        uint256 awardedMynt
    ) internal {
        referals[refererAddress].push(referalsRecord({
            referdAddress: referdAddress,
            day: findDay(),
            awardedMynt: awardedMynt
        }));
    }

    function createFreeStakeClaimRecord(
        address userAddress,
        string memory btcAddress,
        uint256 day,
        uint256 balance,
        uint256 claimedAmount
    ) internal {
        freeStakeClaimRecords[userAddress].push(freeStakeClaimInfo({
            btcAddress: btcAddress,
            balanceAtMoment: balance,
            dayFreeStake: day,
            claimedAmount: claimedAmount,
            rawBtc: unClaimedBtc
        }));
    }

    function freeStaking(
        uint256 stakeAmount,
        address userAddress,
        uint256 autoStakeDays
    ) internal {
        uint256 startDay = findDay();
        uint256 endDay = startDay + autoStakeDays;
        uint256 share = generateShare(stakeAmount, 0, 0);
        subtractedShares[endDay] = subtractedShares[endDay] + share;
        stakeHolders[userAddress].push( stakeRecord({
            id: counterId++,
            stakeShare: share,
            stakeName: "",
            numOfDays: 365,
            currentTime: block.timestamp,
            claimed: false,
            startDay: startDay,
            endDay: endDay,
            endDayTimeStamp: block.timestamp + (endDay * timeSlot),
            isFreeStake: true,
            stakeAmount: stakeAmount,
            sharePrice: shareRate
        }) );
        dailyDataUpdation[startDay].stakeShareTotal = dailyDataUpdation[startDay].stakeShareTotal + share;
        dailyDataUpdation[startDay].stakedToken = dailyDataUpdation[startDay].stakedToken + stakeAmount;
        (bool _isStakeholder, ) = isStakeholder(userAddress);
        if (!_isStakeholder) {
            stakeAddress.push(msg.sender);
        }
    }

    function distributeFreeStake(
        address userAddress,
        string memory btcAddress,
        uint256 day,
        uint256 balance,
        address refererAddress,
        uint256 autoStakeDays
    ) internal {
        uint256 actualAmount = (((findSillyWhalePenalty(balance) * 10**8) / 10**4) * findLatePenaltiy(day)) / 10**4;
        actualAmount = actualAmount + (findSpeedBonus(day, actualAmount) / 100);
        originAmount = originAmount + actualAmount;

        uint256 refBonus = 0;
        //Referal Mints
        if (refererAddress != userAddress && refererAddress != address(0)) {
            uint256 referingBonus = (actualAmount * 20) / 100;
            originAmount = originAmount + referingBonus;
            mintAmount(refererAddress, referingBonus);
            createReferalRecords(refererAddress, userAddress, referingBonus);
        }

        //Referal Bonus
        if (refererAddress != address(0)) {
            refBonus = findReferalBonus(
                userAddress,
                actualAmount,
                refererAddress
            );
            actualAmount = actualAmount + refBonus;
            originAmount = originAmount + refBonus;
        }
        uint256 mintedValue = (actualAmount * 10) / 100;
        mintAmount(userAddress, mintedValue);
        createFreeStakeClaimRecord(
            userAddress,
            btcAddress,
            day,
            balance,
            mintedValue
        );

        uint256 stakeAmount = (actualAmount * 90) / 100;
        freeStaking(stakeAmount, userAddress, autoStakeDays);
    }

    function getFreeStakeClaimRecord()
        external
        view
        returns (freeStakeClaimInfo[] memory claimRecords)
    {
        return freeStakeClaimRecords[msg.sender];
    }

    function extendStakeLength(uint256 totalDays, uint256 id) external {
        uint256 currentDay = findDay();
        if (currentDay > lastUpdatedDay) {
            updateDailyData(lastUpdatedDay + 1, currentDay);
        }
        for (uint16 i = 0; i < stakeHolders[msg.sender].length; i++) {
            if (stakeHolders[msg.sender][i].id == id) {
                if (stakeHolders[msg.sender][i].isFreeStake) {
                    if (totalDays >= 365) {
                        require( stakeHolders[msg.sender][i].startDay + totalDays > stakeHolders[msg.sender][i].numOfDays,
                            "Less than prev days"
                        );
                        stakeHolders[msg.sender][i].numOfDays = stakeHolders[msg.sender][i].numOfDays + totalDays;
                        stakeHolders[msg.sender][i].endDay = stakeHolders[msg.sender][i].startDay + totalDays;
                        stakeHolders[msg.sender][i].endDayTimeStamp = block.timestamp + (stakeHolders[msg.sender][i].endDay * timeSlot);
                    }
                }
            }
        }
    }

    function enterAALobby(address refererAddress) external payable {
        // require(block.timestamp >= startDate && block.timestamp < yearStamp ,'Invalid Day');
        require(msg.value > 0, "low Balance");
        uint256 day = findDay();
        if (day > lastUpdatedDay) {
            updateDailyData(lastUpdatedDay + 1, day);
        }
        RecordInfo memory myRecord = RecordInfo({
            amount: msg.value,
            time: block.timestamp,
            claimed: false,
            user: msg.sender,
            refererAddress: refererAddress
        });


        bool check = false;
        address addressValue = AARecords[day][msg.sender].user;
        if (addressValue == address(0)) {
            check = false;
        } else {
            check = true;
        }
        
        if (check == false) {
            AARecords[day][msg.sender] = myRecord;
            perDayAARecords[day].push(msg.sender);
        } else {
            RecordInfo memory record = AARecords[day][msg.sender];
            record.amount = record.amount + msg.value;
            AARecords[day][msg.sender] = record;
        }

        totalBNBSubmitted[day] = totalBNBSubmitted[day] + msg.value;
    }

    function getTotalBNB(uint256 day) public view returns (uint256) {
        return totalBNBSubmitted[day];
    }

    function getAvailableMynt(uint256 day)
        public
        view
        returns (uint256 daySupply)
    {
        uint256 myntAvailabel = 0;

        if (day == 0) {
            myntAvailabel = 1000000000 * 10**8;
        } else {
            
            uint256 totalUnclaimedToken = 0;
            for (uint16 i = 0; i < day; i++) {
                totalUnclaimedToken = totalUnclaimedToken + perDayUnclaimedBTC[i];
            }
            /*as per rules we have to multiply it with 10^8 than divided with 10 ^ 4 but as we can make it multiply
            with 10 ^ 4
            */
            myntAvailabel = ((19000000 * 10**8 - totalUnclaimedToken) * 10**4) / 350;
        }
        daySupply = myntAvailabel;
        return daySupply;
    }

    function getTransactionRecords(uint256 day, address user)
        public
        view
        returns (RecordInfo memory record)
    {
        return AARecords[day][user];
    }

    function countShare(
        uint256 userSubmittedBNB,
        uint256 dayTotalBNB,
        uint256 availableMynt
    ) internal pure returns (uint256) {
       /*
            calc user share on day in Transform lobbies
      */
        return (((userSubmittedBNB * 10**5) / dayTotalBNB) * availableMynt) / 10**5;
    }

    function claimAATokens() external {
        uint256 presentDay = findDay();
        require(presentDay > 0, "not yet");
        if (presentDay > lastUpdatedDay) {
            updateDailyData(lastUpdatedDay + 1, presentDay);
        }
        uint256 prevDay = presentDay - 1;
        RecordInfo memory record = getTransactionRecords(prevDay, msg.sender);
        if (record.user != address(0) && record.claimed == false) {
            uint256 userShare = countShare( record.amount, getTotalBNB(prevDay), getAvailableMynt(prevDay) );

            address userReferer = record.refererAddress;
            if (userReferer != msg.sender && userReferer != address(0)) {
                uint256 referingBonus = (userShare * 20) / 100;
                originAmount = originAmount + referingBonus;
                mintAmount(userReferer, referingBonus);
                createReferalRecords(userReferer, msg.sender, referingBonus);
            }
            uint256 referalBonus = findReferalBonus(msg.sender, userShare, userReferer);
            userShare = userShare + referalBonus;
            originAmount = originAmount + referalBonus;
            mintAmount(msg.sender, userShare);

            AARecords[prevDay][msg.sender].claimed = true;
        }
    }

    function getReferalRecords(address refererAddress)
        external
        view
        returns (referalsRecord[] memory referal)
    {
        return referals[refererAddress];
    }

    function transferMynt(address recipientAddress, uint256 _amount) external {
        uint256 currentDay = findDay();
        _transfer(msg.sender, recipientAddress, _amount);
    
        if(currentDay > lastUpdatedDay){
            updateDailyData(lastUpdatedDay + 1,currentDay);
        }
        transferRecords[msg.sender].push(transferInfo({
            amount: _amount,
            to: recipientAddress,
            from: msg.sender
        }));
    }

    function getTransferRecords(address _address)
        external
        view
        returns (transferInfo[] memory transferRecord)
    {
        return transferRecords[_address];
    }

    function getBigPayDay() internal view returns (uint256) {
        uint256 totalAmount = 0;
        for (uint16 j = 0; j <= 350; j++) {
            totalAmount = totalAmount + (((dailyDataUpdation[j].unclaimed / 10**8) * 2857) / 10**2);
        }
        // delete data;
        return totalAmount;
    }

    function getShareRate() external view returns (uint256) {
        return shareRate;
    }

    function unclaimedRecord(uint256 presentDay)
        internal
        view
        returns (uint256 unclaimedAAToken)
    {
        uint256 prevDay = presentDay - 2;
        uint256 availableMynt = getAvailableMynt(prevDay);

        if (perDayAARecords[prevDay].length > 0) {
            for (uint16 i = 0; i < perDayAARecords[prevDay].length; i++) {
                RecordInfo memory record = getTransactionRecords(prevDay, perDayAARecords[prevDay][i]);
                if (record.claimed == false) {
                    unclaimedAAToken = unclaimedAAToken + countShare( record.amount, getTotalBNB(prevDay), availableMynt );
                }
            }
        } else {
            unclaimedAAToken = unclaimedAAToken + availableMynt;
        }
        return unclaimedAAToken;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
        }
        _balances[to] += amount;

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }
}

contract SignatureVerification {

    /* Largest BTC address Satoshis balance in UTXO snapshot (sanity check) */
    uint256 internal constant MAX_BTC_ADDR_BALANCE_SATOSHIS = 25550214098481;
    /* Root hash of the UTXO Merkle tree */
    bytes32 internal constant MERKLE_TREE_ROOT = 0x7f595b64c3ad65759aaab71b3f4d0f8951ac89d869e170cd659926d9edc1cdbe;


        /* Claimed BTC addresses */
    mapping(bytes20 => bool) public btcAddressClaims;


    function btcAddressClaim(
        uint256 rawSatoshis,
        bytes32[] calldata proof,
        bytes32 messageHash,
        bytes32 pubKeyX,
        bytes32 pubKeyY,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        returns (bool)
    {
        /* Sanity check */
        require(rawSatoshis <= MAX_BTC_ADDR_BALANCE_SATOSHIS, "Myntist: CHK: rawSatoshis");
         /* Enforce the minimum stake time for the auto-stake from this claim */
        // require(autoStakeDays >= MIN_AUTO_STAKE_DAYS, "Myntist: autoStakeDays lower than minimum");

        {
            require(
                claimMessageMatchesSignature(
                    pubKeyX,
                    pubKeyY,
                    messageHash,
                    v,
                    r,
                    s
                ),
                "Myntist: Signature mismatch"
            );
        }

         /* Derive BTC address from public key */
        bytes20 btcAddr = pubKeyToBtcAddress(pubKeyX, pubKeyY);

         /* Ensure BTC address has not yet been claimed */
        require(!btcAddressClaims[btcAddr], "Myntist: BTC address balance already claimed");

        /* Ensure BTC address is part of the Merkle tree */
        require(
            _btcAddressIsValid(btcAddr, rawSatoshis, proof),
            "Myntist: BTC address or balance unknown"
        );

        /* Mark BTC address as claimed */
        btcAddressClaims[btcAddr] = true;

        // Your airdrop logic and functions come here
        return true;
    }
    
    function claimMessageMatchesSignature(
        bytes32 pubKeyX,
        bytes32 pubKeyY,
        bytes32 messageHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        pure
        returns (bool)
    {
        require(v >= 27 && v <= 30, "Myntist: v invalid");

        /*
            ecrecover() returns an Eth address rather than a public key, so
            we must do the same to compare.
        */
        address pubToEth = pubKeyToEthAddress(pubKeyX, pubKeyY);

        return  ecrecover(messageHash, v, r, s) == pubToEth;
    }

    function sigAddress(bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) public pure returns(address){
        require(v >= 27 && v <= 30, "Myntist: v invalid");
        return ecrecover(messageHash, v, r, s);
    }


    function pubKeyToEthAddress(bytes32 pubKeyX, bytes32 pubKeyY)
        public
        pure
        returns (address)
    {
        return address(uint160(uint256(keccak256(abi.encodePacked(pubKeyX, pubKeyY)))));
    }

    function pubKeyToBtcAddress(bytes32 pubKeyX, bytes32 pubKeyY)
        public
        pure
        returns (bytes20)
    {
        /*
            Helpful references:
             - https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
             - https://github.com/cryptocoinjs/ecurve/blob/master/lib/point.js
        */
        uint8 startingByte;
        bytes memory pubKey;
        // bool compressed = (claimFlags & CLAIM_FLAG_BTC_ADDR_COMPRESSED) != 0;
        // bool nested = (claimFlags & CLAIM_FLAG_BTC_ADDR_P2WPKH_IN_P2SH) != 0;
        // bool bech32 = (claimFlags & CLAIM_FLAG_BTC_ADDR_BECH32) != 0;

        // if (compressed) {
        //     /* Compressed public key format */
        //     require(!(nested && bech32), "Myntist: claimFlags invalid");

        //     startingByte = (pubKeyY[31] & 0x01) == 0 ? 0x02 : 0x03;
        //     pubKey = abi.encodePacked(startingByte, pubKeyX);
        // } else {
            /* Uncompressed public key format */
            // require(!nested && !bech32, "Myntist: claimFlags invalid");

            startingByte = 0x04;
            pubKey = abi.encodePacked(startingByte, pubKeyX, pubKeyY);
        // }

        bytes20 pubKeyHash = _hash160(pubKey);
        // if (nested) {
        //     return _hash160(abi.encodePacked(hex"0014", pubKeyHash));
        // }
        return pubKeyHash;
    }

        /**
     * @dev ripemd160(sha256(data))
     * @param data Data to be hashed
     * @return 20-byte hash
     */
    function _hash160(bytes memory data)
        private
        pure
        returns (bytes20)
    {
        return ripemd160(abi.encodePacked(sha256(data)));
    }

    /**
     * @dev Verify a BTC address and balance are part of the Merkle tree
     * @param btcAddr Bitcoin address (binary; no base58-check encoding)
     * @param rawSatoshis Raw BTC address balance in Satoshis
     * @param proof Merkle tree proof
     * @return True if valid
     */
    function _btcAddressIsValid(bytes20 btcAddr, uint256 rawSatoshis, bytes32[] memory proof)
        internal
        pure
        returns (bool)
    {
        
        bytes32 merkleLeaf = keccak256(abi.encodePacked(btcAddr, rawSatoshis));

        return _merkleProofIsValid(merkleLeaf, proof);
    }

    /**
     * @dev Verify a Merkle proof using the UTXO Merkle tree
     * @param merkleLeaf Leaf asserted to be present in the Merkle tree
     * @param proof Generated Merkle tree proof
     * @return True if valid
     */
    function _merkleProofIsValid(bytes32 merkleLeaf, bytes32[] memory proof)
        private
        pure
        returns (bool)
    {
        return MerkleProof.verify(proof, MERKLE_TREE_ROOT, merkleLeaf);
    }
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