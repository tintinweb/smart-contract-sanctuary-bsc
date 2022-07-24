/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() public {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract PyraTa is ReentrancyGuard {
    address[50] public  todayWiner;    
    uint public todayWinerValue;
    uint public timeLottery;
    uint[16] public RoiRounds;
    uint[16] public timeRoudsEnd;
    address[16] public nextWinerSecretGame;
    mapping(address => uint) public lastTimeActivation;
    struct User {
        uint id;
        uint registrationTimestamp;
        address referrer;
        uint referrals;
        uint referralPayoutSum;
        uint roundsRewardSum;
        uint missedReferralPayoutSum;
        mapping(uint8 => UserroundInfo) rounds;
        uint8 maxRound;
        uint turnover;

    }
    struct UserroundInfo {
        uint16 activationTimes;
        uint16 maxPayouts;
        uint16 payouts;
        bool active;
        uint rewardSum;
        uint referralPayoutSum;   
        uint lastTimeBuyround; 
        uint missedRefferalProfit;  
        uint missedRefferalPostProfit;
    }
    
    struct GlobalStat {
        uint members;
        uint transactions;
        uint turnover;
        uint lucky;
        
    }
    event Buyround(uint time, address indexed adress, uint userId, uint8 round);
    event roundPayout(uint time, address indexed adress, uint userId, uint8 round, uint rewardValue, uint fromUserId, uint RoiRound);
    event roundDeactivation(uint time, address indexed adress, uint userId, uint8 round);
    event IncreaseroundMaxPayouts(uint time, address indexed adress, uint userId, uint8 round, uint16 newMaxPayouts);
    event payedPrize(uint time, address indexed payedUser, uint payPrize);
    event winLottery(uint time, address indexed win, uint winPrize);
    event UserRegistration(uint time, address indexed adress, uint referralId, uint referrerId);
    event ReferralPayout(uint time, address indexed adress, uint referrerId, uint referralId, uint8 round, uint rewardValue);
    event MissedReferralPayout(uint time, address indexed adress, uint referrerId, uint referralId, uint8 round, uint rewardValue);
    event ReferralPostPayout(uint time, address indexed adress, uint referrerId, uint referralId, uint8 round, uint rewardValue);
    event MissedReferralPostPayout(uint time, address indexed adress, uint referrerId, uint referralId, uint8 round, uint rewardValue);
     event WinerForeverGame(uint time, address indexed WinerSecretGame, uint8 round, uint valueSecretPrize);
    uint public constant registrationPrice = 0 ether;
    uint8 public constant rewardPayouts = 2;
    uint8 public constant rewardPercents = 75;
    uint8 public constant marketingPercents = 7;
    uint8 public referralRewardPercents = 9;
    uint8 public referralRewardProfitPercents = 8;
    
    address payable public owner;
    address payable public marketing;
    uint[] public roundPrice = [
        0 ether,    
        0.05 ether,
        0.08 ether, 
        0.13 ether,  
        0.22 ether, 
        0.33 ether,  
        0.5 ether, 
        0.7 ether,  
        1.05 ether,
        1.45 ether, 
        1.95 ether, 
        2.4 ether, 
        3.5 ether, 
        5.2 ether, 
        7.3 ether, 
        10 ether

    ];
    uint totalrounds = roundPrice.length - 1;
    uint newUserId = 2;
    mapping(address => User) users;
    mapping(uint => address) usersAddressById;
    mapping(uint8 => address[]) roundQueue;
    mapping(uint8 => uint) headIndex;
    GlobalStat globalStat;
    constructor(address payable _marketing) public {
        owner = payable(msg.sender);
        marketing = _marketing;
        users[owner] = User({
            id : 1,
            registrationTimestamp: now,
            referrer : address(0),
            referrals : 0,
            referralPayoutSum : 0,
            roundsRewardSum : 0,
            missedReferralPayoutSum : 0,
            maxRound : 0,
            turnover : 0

        });
        usersAddressById[1] = owner;
        globalStat.members++;
        globalStat.transactions++;
        for(uint8 round = 1; round <= totalrounds; round++) {
             timeRoudsEnd[round] = now + 864000;
            users[owner].rounds[round].active = true;
            users[owner].rounds[round].maxPayouts = 15;
            roundQueue[round].push(owner);
        }
    }
    function isContract(address addr) public view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(addr)
        }
        return size != 0;
    }
    receive() external payable {
        for(uint8 round = 1; round <= totalrounds; round++) {
            if (roundPrice[round] == msg.value) {
                if(round == 1 && !isUserRegistered(msg.sender)){
                   register();
                }
                buyround(round);
                return;
            }
        }

        revert("Can't find round to buy. Maybe sent value is invalid.");
    }
    function buyFirstRound(address referrer) public payable {
        registerWithReferrer(referrer);
        buyround(1);
    }
    function register() public payable {
        registerWithReferrer(owner);
        
    }
    function registerWithReferrer(address referrer) public payable {
        require(isUserRegistered(referrer), "Referrer is not registered");
        require(!isUserRegistered(msg.sender), "User already registered");
        require(!isContract(msg.sender), "Can not be a contract");
        User memory user = User({
            id : newUserId++,
            registrationTimestamp: now,
            referrer : referrer,
            referrals : 0,
            referralPayoutSum : 0,
            roundsRewardSum : 0,
            missedReferralPayoutSum : 0,
            maxRound : 0,
            turnover: 0

        });
        users[msg.sender] = user;
        usersAddressById[user.id] = msg.sender;
        uint8 line = 1;
        address ref = referrer;
        if(ref != address(0)) {
            users[ref].referrals++;
            ref = users[ref].referrer;
            line++;
        }
        globalStat.members++;
        globalStat.transactions++;
        emit UserRegistration(now, msg.sender, user.id, users[referrer].id);
    }
    function buyround(uint8 round) public payable nonReentrant{
        require(isUserRegistered(msg.sender), "User is not registered");
        require(round > 0 && round <= totalrounds, "Invalid round");
        require(roundPrice[round] == msg.value, "Invalid BNB value");
        require(!isContract(msg.sender), "Can not be a contract");
        require(round <= users[msg.sender].maxRound+1, "Round not available");
        if (timeRoudsEnd[round] < now){
                       uint valueSecretPrize =calcSecretPrize(round);
                        bool sendSecretGamePrize = payable(nextWinerSecretGame[round]).send(valueSecretPrize);
                        if (sendSecretGamePrize) {
                            timeRoudsEnd[round] += 86400;
                            emit WinerForeverGame(now, nextWinerSecretGame[round], round, valueSecretPrize);
                            
                        }
                        
                    } else {
                        timeRoudsEnd[round] += 3600;
                        timeRoudsEnd[0] = now;
                    }
        nextWinerSecretGame[round] = msg.sender;
        users[msg.sender].maxRound++;
        users[msg.sender].turnover += msg.value;
        globalStat.transactions++;
        globalStat.turnover += msg.value;
        lastTimeActivation[msg.sender] = now;
        users[msg.sender].rounds[round].lastTimeBuyround = now;
        uint onePercent = msg.value / 100;
        if (!users[msg.sender].rounds[round].active) {
            users[msg.sender].rounds[round].activationTimes++;
            users[msg.sender].rounds[round].maxPayouts += rewardPayouts;
            users[msg.sender].rounds[round].active = true;
            roundQueue[round].push(msg.sender);
            emit Buyround(now, msg.sender, users[msg.sender].id, round);            
        } else {
            users[msg.sender].rounds[round].activationTimes++;
            users[msg.sender].rounds[round].maxPayouts += rewardPayouts;
            emit IncreaseroundMaxPayouts(now, msg.sender, users[msg.sender].id, round, users[msg.sender].rounds[round].maxPayouts);
        }
        uint reward = onePercent * rewardPercents;
        if (roundQueue[round][headIndex[round]] != msg.sender) {
            address rewardAddress = roundQueue[round][headIndex[round]];
            bool sent = payable(rewardAddress).send(reward);
            if (sent) {
                    uint rewardValue = onePercent * referralRewardProfitPercents;
                    sendPostRewardToReferrer(rewardAddress, round, rewardValue);
                
                users[rewardAddress].rounds[round].rewardSum += reward;
                users[rewardAddress].rounds[round].payouts++;
                users[rewardAddress].roundsRewardSum += reward;
                users[rewardAddress].turnover += reward;
                RoiRounds[round] = 25 * 31536000 / (now - users[rewardAddress].rounds[round].lastTimeBuyround); 
                emit roundPayout(now, msg.sender, users[rewardAddress].id, round, reward, users[msg.sender].id, RoiRounds[round]);
            } else {
                owner.transfer(reward);
            }
            if (users[rewardAddress].rounds[round].payouts < users[rewardAddress].rounds[round].maxPayouts) {
                roundQueue[round].push(rewardAddress);
            } else {
                users[rewardAddress].rounds[round].active = false;
                emit roundDeactivation(now, msg.sender, users[rewardAddress].id, round);
            }
            delete roundQueue[round][headIndex[round]];
            headIndex[round]++;
        } else {
            owner.transfer(reward);
            users[owner].rounds[round].payouts++;
            users[owner].rounds[round].rewardSum += reward;
            users[owner].roundsRewardSum += reward;
        }
            uint rewardValue = onePercent * referralRewardPercents;
            sendRewardToReferrer(msg.sender, round, rewardValue);
        
        (bool success, ) = marketing.call{value: onePercent * marketingPercents}("");
        require(success, "transfer failed while buy round");
    }
    function income() public payable {}
    function Lottery(uint ticket) public {
        require(msg.sender == owner, "you are not an owner!");
        for(uint8 i = 0; i <= 49; i++) {
            todayWiner[i] = address(0);
        }
        uint totalLotteryPlayer; 
        for(uint8 round = 1; round <= totalrounds; round++) {
            for(uint i = headIndex[round]; i < roundQueue[round].length; i++) {
                if(lastTimeActivation[roundQueue[round][i]]+86400 > now) {
                    totalLotteryPlayer++;
                }
            }            
        }
        todayWinerValue =  address(this).balance /2 / ticket;
        timeLottery = now;
        uint rand = totalLotteryPlayer/ticket;
        uint caunting;
        uint8 luckyNum;
        for(uint8 round = 1; round <= totalrounds; round++) {        
            for(uint i = headIndex[round]; i < roundQueue[round].length; i++) {
                caunting++;
                 if(caunting % rand == 0 && lastTimeActivation[roundQueue[round][i]]+86400 > now) {
                    todayWiner[luckyNum] = roundQueue[round][i];
                     luckyNum++;
                     emit winLottery(now, roundQueue[round][i], todayWinerValue);
                 }
            }
        }
    }
    function getPrize() public nonReentrant{
         for (uint8 lucky = 0; lucky <= 49; lucky++) {
            if (todayWiner[lucky] == msg.sender){
                 globalStat.lucky++;
                     todayWiner[lucky] = address(0);
                bool payPrize = payable(msg.sender).send(todayWinerValue);
                 if (payPrize) {
                     emit payedPrize(now, msg.sender, todayWinerValue);
                }
            }
        }
    }
    function sendRewardToReferrer(address userAddress, uint8 round, uint rewardValue) private {
       
        address referrer = users[userAddress].referrer;
        
        if (!users[referrer].rounds[round].active) {
            users[referrer].missedReferralPayoutSum += rewardValue;
            users[referrer].rounds[round].missedRefferalProfit += rewardValue;
            emit MissedReferralPayout(now, referrer, users[referrer].id, users[userAddress].id, round, rewardValue);
            referrer = owner;
        }
        bool sent = payable(referrer).send(rewardValue);
        if (sent) {
            users[referrer].rounds[round].referralPayoutSum += rewardValue;
            users[referrer].referralPayoutSum += rewardValue;
            emit ReferralPayout(now, referrer, users[referrer].id, users[userAddress].id, round, rewardValue);
        } else {
            owner.transfer(rewardValue);
        }
    }
    function sendPostRewardToReferrer(address userAddress, uint8 round, uint rewardValue) private {
        
        address referrer = users[userAddress].referrer;
        
        if (!users[referrer].rounds[round].active ) {
            users[referrer].missedReferralPayoutSum += rewardValue;
            users[referrer].rounds[round].missedRefferalPostProfit += rewardValue;
            emit MissedReferralPostPayout(now, referrer, users[referrer].id, users[userAddress].id, round, rewardValue);
            referrer = owner;
        }
        bool sent = payable(referrer).send(rewardValue);
        if (sent) {
            users[referrer].rounds[round].referralPayoutSum += rewardValue;
            users[referrer].referralPayoutSum += rewardValue;
            emit ReferralPostPayout(now, referrer, users[referrer].id, users[userAddress].id, round, rewardValue);
        } else {
            owner.transfer(rewardValue);
        }
    }
    function getUser(address userAddress) public view returns(uint, uint, uint, address, uint, uint, uint, uint, uint, uint) {
        User memory user = users[userAddress];
        return (
            user.id,
            user.registrationTimestamp,
            users[user.referrer].id,
            user.referrer,
            user.referrals,
            user.referralPayoutSum,
            user.roundsRewardSum,
            user.missedReferralPayoutSum,
            user.maxRound,
            user.turnover
        );
    }
        function getUserroundsMissedProfit(address userAddress) public view returns ( uint[] memory, uint[] memory) {

        uint[] memory missedRefferalProfit = new uint[](totalrounds + 1);
        uint[] memory missedRefferalPostProfit = new uint[](totalrounds + 1);
        for (uint8 round = 1; round <= totalrounds; round++) {
            missedRefferalProfit[round] = users[userAddress].rounds[round].missedRefferalProfit;
            missedRefferalPostProfit[round] = users[userAddress].rounds[round].missedRefferalPostProfit;
        }
        return ( missedRefferalProfit, missedRefferalPostProfit);
    }
    function getUserrounds(address userAddress) public view returns (bool[] memory, uint16[] memory, uint16[] memory, uint16[] memory, uint[] memory, uint[] memory) {
        bool[] memory active = new bool[](totalrounds + 1);
        uint16[] memory payouts = new uint16[](totalrounds + 1);
        uint16[] memory maxPayouts = new uint16[](totalrounds + 1);
        uint16[] memory activationTimes = new uint16[](totalrounds + 1);
        uint[] memory rewardSum = new uint[](totalrounds + 1);
        uint[] memory referralPayoutSum = new uint[](totalrounds + 1);
        for (uint8 round = 1; round <= totalrounds; round++) {
            active[round] = users[userAddress].rounds[round].active;
            payouts[round] = users[userAddress].rounds[round].payouts;
            maxPayouts[round] = users[userAddress].rounds[round].maxPayouts;
            activationTimes[round] = users[userAddress].rounds[round].activationTimes;
            rewardSum[round] = users[userAddress].rounds[round].rewardSum;
            referralPayoutSum[round] = users[userAddress].rounds[round].referralPayoutSum;
        }
        return (active, payouts, maxPayouts, activationTimes, rewardSum, referralPayoutSum);
    }
    function getroundPrices() public view returns(uint[] memory) {
        return roundPrice;
    }
    function getRoiRound() public view returns(uint[16] memory) {
        return RoiRounds;
    }
    function gettimeRoundEnd() public view returns(uint[16] memory) {
        return timeRoudsEnd;
    }
     function getLotteryWiner() public view returns(address[50] memory) {
        return todayWiner;
    }
    function getGlobalStatistic() public view returns(uint[5] memory result) {
        return [globalStat.members, globalStat.transactions, globalStat.turnover, todayWinerValue, timeLottery];
    }
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
    function isUserRegistered(address addr) public view returns (bool) {
        return users[addr].id != 0;
    }
    function getUserAddressById(uint userId) public view returns (address) {
        return usersAddressById[userId];
    }
    function getUserIdByAddress(address userAddress) public view returns (uint) {
        return users[userAddress].id;
    }
    function getReferrerId(address userAddress) public view returns (uint) {
        address referrerAddress = users[userAddress].referrer;
        return users[referrerAddress].id;
    }
    function getReferrer(address userAddress) public view returns (address) {
        require(isUserRegistered(userAddress), "User is not registered");
        return users[userAddress].referrer;
    }
    function getPlaceInQueue(address userAddress, uint8 round) public view returns(uint, uint) {
        require(round > 0 && round <= totalrounds, "Invalid round");
        if(!users[userAddress].rounds[round].active) {
            return (0, 0);
        }
        uint place = 0;
        for(uint i = headIndex[round]; i < roundQueue[round].length; i++) {
            place++;
            if(roundQueue[round][i] == userAddress) {
                return (place, roundQueue[round].length - headIndex[round]);
            }
        }
        revert();
    }
    function calcSecretPrize(uint8 round) public view returns(uint value) {
        uint priceAllRound;
        for(uint8 i = 1; i <= totalrounds; i++) {
            priceAllRound+= roundPrice[i];
        }
        return address(this).balance/priceAllRound*roundPrice[round];


    }
}