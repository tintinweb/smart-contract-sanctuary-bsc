/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: MIT 

pragma solidity ^0.6.12;

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

contract BNBMatrix is ReentrancyGuard {
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

        uint missedRefferalProfit;  
        uint missedRefferalPostProfit;
    }
    
    struct GlobalStat {
        uint members;
        uint transactions;
        uint turnover;
    }

    event Buyround(uint time, address indexed adress, uint userId, uint8 round);
    event roundPayout(uint time, address indexed adress, uint userId, uint8 round, uint rewardValue, uint fromUserId);
    event roundDeactivation(uint time, address indexed adress, uint userId, uint8 round);
    event IncreaseroundMaxPayouts(uint time, address indexed adress, uint userId, uint8 round, uint16 newMaxPayouts);
    event UserRegistration(uint time, address indexed adress, uint referralId, uint referrerId);
    event ReferralPayout(uint time, address indexed adress, uint referrerId, uint referralId, uint8 round, uint rewardValue);
    event MissedReferralPayout(uint time, address indexed adress, uint referrerId, uint referralId, uint8 round, uint rewardValue);
    event ReferralPostPayout(uint time, address indexed adress, uint referrerId, uint referralId, uint8 round, uint rewardValue);
    event MissedReferralPostPayout(uint time, address indexed adress, uint referrerId, uint referralId, uint8 round, uint rewardValue);
  
    uint public constant registrationPrice = 0 ether;
    uint8 public constant rewardPayouts = 2;
    uint8 public constant rewardPercents = 75;
    uint8 public constant marketingPercents = 8;
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


    // 1,2 - мои, 3,4 - игорек, симулятор, 5,6 - мои, 7 - виктор, 8 - симулятор, 9 - игорь, 10 - моq
    address[] public admins = [0x711064f507Fb98E14E066708Ba3450dE8d42048b, 0x0EDa84f33410E96B16794d2e960B458AB564A26f, 0x8aEB17dA394ae08B1397250f7049d800C7248A79,0x5cf2BDC7Fe439bb8708D85C591d327Bd5387Ab10, 0xF7Cf379b22946BB540B3988c6CcAcad4414A3dCe, 0x31675aDb80BC05CEE28DB99384b39CC7Eb78E8De, 0x93c884f67e6ca7133fE7Db435e1CFaff17320f11, 0xaAAc479ee41aDa7599a8016BD232f81e6c612dF2, 0xd84C6e41ABB4a6C6CE1c8bFf06A487027785C855,0x5C4111aefCA017AEeC7Ee19E245BA03764A75A36, 0x4Db5691e11AC2E14AEF17DF7DAC68ce0cd62Bac1];
    uint totalAdmins = admins.length;

    address[] public leaders = [0x9F1D2c57383B7580e388598306d48085eDda5392,0xe4604DBb27D894a2B57E3C987e369b63C95C52bE, 0xcE3ec642d6d375562Da360f29bDa1B44896B0aC9,0x3E843109271C43403C68fefAbb12dd212f57d586];
    uint totalLeaders = leaders.length;
    

    mapping(address => User) users;
    mapping(uint => address) usersAddressById;
    mapping(uint8 => address[]) roundQueue;
    mapping(uint8 => uint) headIndex;

    GlobalStat globalStat;

    constructor(address payable _marketing) public {
        owner = payable(msg.sender);
        marketing = _marketing;
        
        registerFirstId();

        registerAdmins();

        registerLeaders();
    }

    function registerFirstId() public {
        users[owner] = User({
            id: 1,
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
            users[owner].rounds[round].active = true;
            users[owner].rounds[round].maxPayouts = 50;
            roundQueue[round].push(owner);
        }
    }

    function registerLeaders() public {
        // @Karbits (2 lvl)
        users[0x89DfDa3fee6Af483F7508e89a4ca48F058D109d6] = User({
            id : newUserId,
            registrationTimestamp: now,
            referrer : address(0),
            referrals : 0,
            referralPayoutSum : 0,
            roundsRewardSum : 0,
            missedReferralPayoutSum : 0,
            maxRound : 0,
            turnover : 0
        });

        usersAddressById[newUserId] = 0x89DfDa3fee6Af483F7508e89a4ca48F058D109d6;

        globalStat.members++;
        globalStat.transactions++;
        newUserId++;

        for(uint8 round = 1; round <= 2; round++) {
            users[0x89DfDa3fee6Af483F7508e89a4ca48F058D109d6].rounds[round].active = true;
            users[0x89DfDa3fee6Af483F7508e89a4ca48F058D109d6].rounds[round].maxPayouts = 2;
            roundQueue[round].push(0x89DfDa3fee6Af483F7508e89a4ca48F058D109d6);
        }

        // @mishanyaa77 (6 lvl)
        users[0x56b3264a9dD0cb4FFcb2Cb2dCbEd10c803F509D2] = User({
            id : newUserId,
            registrationTimestamp: now,
            referrer : address(0),
            referrals : 0,
            referralPayoutSum : 0,
            roundsRewardSum : 0,
            missedReferralPayoutSum : 0,
            maxRound : 0,
            turnover : 0
        });

        usersAddressById[newUserId] = 0x56b3264a9dD0cb4FFcb2Cb2dCbEd10c803F509D2;

        globalStat.members++;
        globalStat.transactions++;
        newUserId++;

        for(uint8 round = 1; round <= 6; round++) {
            users[0x56b3264a9dD0cb4FFcb2Cb2dCbEd10c803F509D2].rounds[round].active = true;
            users[0x56b3264a9dD0cb4FFcb2Cb2dCbEd10c803F509D2].rounds[round].maxPayouts = 2;
            roundQueue[round].push(0x56b3264a9dD0cb4FFcb2Cb2dCbEd10c803F509D2);
        }

        // https://t.me/Crypto_boom_hype (7 lvl)
        users[0x2c5C76532AAcC906deA7b4A2119abF7E82b0B1c6] = User({
            id : newUserId,
            registrationTimestamp: now,
            referrer : address(0),
            referrals : 0,
            referralPayoutSum : 0,
            roundsRewardSum : 0,
            missedReferralPayoutSum : 0,
            maxRound : 0,
            turnover : 0
        });

        usersAddressById[newUserId] = 0x2c5C76532AAcC906deA7b4A2119abF7E82b0B1c6;

        globalStat.members++;
        globalStat.transactions++;
        newUserId++;

        for(uint8 round = 1; round <= 7; round++) {
            users[0x2c5C76532AAcC906deA7b4A2119abF7E82b0B1c6].rounds[round].active = true;
            users[0x2c5C76532AAcC906deA7b4A2119abF7E82b0B1c6].rounds[round].maxPayouts = 2;
            roundQueue[round].push(0x2c5C76532AAcC906deA7b4A2119abF7E82b0B1c6);
        }

        

        for (uint leader = 0; leader < totalLeaders; leader++) {
            users[leaders[leader]] = User({
                id : newUserId,
                registrationTimestamp: now,
                referrer : address(0),
                referrals : 0,
                referralPayoutSum : 0,
                roundsRewardSum : 0,
                missedReferralPayoutSum : 0,
                maxRound : 0,
                turnover : 0
            });

            usersAddressById[newUserId] = leaders[leader];

            globalStat.members++;
            globalStat.transactions++;
            newUserId++;

            for(uint8 round = 1; round <= totalrounds; round++) {
                users[leaders[leader]].rounds[round].active = true;
                users[leaders[leader]].rounds[round].maxPayouts = 2;
                roundQueue[round].push(leaders[leader]);
            }
        }        
    }

    function registerAdmins() public {
        for (uint admin = 0; admin < totalAdmins; admin++) {
            users[admins[admin]] = User({
                id : newUserId,
                registrationTimestamp: now,
                referrer : admin == 0 ? address(0) : admins[0],
                referrals : 0,
                referralPayoutSum : 0,
                roundsRewardSum : 0,
                missedReferralPayoutSum : 0,
                maxRound : 0,
                turnover : 0
            });

            usersAddressById[newUserId] = admins[admin];

            globalStat.members++;
            globalStat.transactions++;
            newUserId++;

            for(uint8 round = 1; round <= totalrounds; round++) {
                users[admins[admin]].rounds[round].active = true;
                users[admins[admin]].rounds[round].maxPayouts = 50;
                roundQueue[round].push(admins[admin]);
            }
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


        users[msg.sender].maxRound++;
        users[msg.sender].turnover += msg.value;
        globalStat.transactions++;
        globalStat.turnover += msg.value;

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

                emit roundPayout(now, msg.sender, users[rewardAddress].id, round, reward, users[msg.sender].id);
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
  
    function getGlobalStatistic() public view returns(uint[3] memory result) {
        return [globalStat.members, globalStat.transactions, globalStat.turnover];
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
  
}