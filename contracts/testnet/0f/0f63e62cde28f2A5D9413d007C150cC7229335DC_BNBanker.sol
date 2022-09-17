/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;

interface Jackpot {
    function topUp() external payable;
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

contract BNBanker {
    using SafeMath for uint256;

    uint public startTime;
    uint public total;
    uint public pool;
    uint public rankPool;
    uint public insurancePool;
    uint public insuranceTime;
    uint public rankTime;
    address payable public tech;
    address payable public ad;
    address payable public team;
    address payable public jackpot;
    uint dayTime = 1 days;
    uint increaseTime = 5 hours;

    uint initialTime = dayTime.mul(7);
    uint unit = 18;
    uint[] pcts = [5,2,1];
    address public owner = msg.sender;

    struct User {
        bool active;
        address referrer;
        uint recommendReward;
        uint investment;
        uint totalWithdraw;
        uint totalReward;
        uint checkpoint;
        uint subNum;
        uint subStake;
        address[] subordinates;
        Investment[] investments;
    }

    struct Investment {
        uint start;
        uint finish;
        uint value;
        uint totalReward;
        uint period;
        uint rate;
        uint typeNum;
        bool isReStake;
    }

    struct Invest{
        address addr;
        uint value;
        uint reward;
        uint time;
    }
    Invest[] public insurances;
    uint public insuranceIndex;
    uint public insuranceRewardIndex;

    uint[] rankPcts = [40,30,20,10];
    mapping(uint => Invest[4]) rankMapArray;
    mapping(uint => mapping(address => uint)) public rankMap;
    mapping(uint => bool) public rankFlag;
    mapping(address => User) public userMap;

    event Stake(address indexed user, uint256 amount);
    event Retake(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Insurance(address indexed user, uint256 amount);
    event Rank(address indexed user, uint256 amount);

    constructor(address payable tech_, address payable ad_, address payable team_, address payable jackpot_, uint256 startTime_, uint256 rankTime_) {
        require(!isContract(tech_), "!techAddress");
        require(!isContract(ad_), "!adAddress");
        require(!isContract(team_), "!teamAddress");
        tech = tech_;
        ad = ad_;
        team = team_;
        jackpot = jackpot_;
        userMap[team].active = true;
        if(startTime_==0) startTime_ = block.timestamp;
        if(rankTime_==0) rankTime_ = block.timestamp;
        startTime = startTime_;
        rankTime = rankTime_;
    }

    function getRankIndex() public view returns(uint index){
        (, uint time) = block.timestamp.trySub(rankTime);
        index = time.div(dayTime);
    }

    function getRandom() internal view returns(uint256) {
        bytes32 _blockhash = blockhash(block.number-1);
        uint256 random =  uint256(keccak256(abi.encode(_blockhash,block.timestamp,block.difficulty))).mod(7);
        return random;
    }

    function topUp() public payable {
        pool = pool.add(msg.value);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function getInfo() public view returns(uint,uint,uint,uint,uint,uint,uint){
        return (startTime, total, pool, rankPool, insurancePool, insuranceTime, rankTime);
    }

    function getRanks(uint index) public view returns(address[4] memory addresses, uint[4] memory values,
        uint[4] memory rewards, uint[4] memory times){
        Invest[4] memory invests = rankMapArray[index];
        for(uint i=0;i<invests.length;i++){
            addresses[i] = invests[i].addr;
            values[i] = invests[i].value;
            rewards[i] = invests[i].reward;
            times[i] = invests[i].time;
        }
    }

    function getInsurances(uint length) public view returns(address[] memory addresses, uint[] memory values,
        uint[] memory rewards, uint[] memory times){
        uint index = 0;
        (,uint end) = insuranceIndex.trySub(length);
        length = insuranceIndex.sub(end);
        addresses = new address[](length);
        values = new uint[](length);
        rewards = new uint[](length);
        times = new uint[](length);
        for(uint i=insuranceIndex;i>end;i--){
            addresses[index] = insurances[i-1].addr;
            values[index] = insurances[i-1].value;
            times[index] = insurances[i-1].time;
            rewards[index] = insurances[i-1].reward;
            index++;
        }
    }

    function getInvestments() public view returns(
        uint[] memory times,uint[] memory starts, uint[] memory values, uint[] memory totalRewards,
        uint[] memory rates, uint[] memory typeNums, bool[] memory isReStakes
    ){
        Investment[] memory investments = userMap[msg.sender].investments;
        times = new uint[](investments.length);
        starts = new uint[](investments.length);
        values = new uint[](investments.length);
        totalRewards = new uint[](investments.length);
        rates = new uint[](investments.length);
        typeNums = new uint[](investments.length);
        isReStakes = new bool[](investments.length);
        for (uint i = 0; i < investments.length; i++) {
            times[i] = investments[i].finish;
            starts[i] = investments[i].start;
            values[i] = investments[i].value;
            totalRewards[i] = investments[i].totalReward;
            rates[i] = investments[i].rate;
            typeNums[i] = investments[i].typeNum;
            isReStakes[i] = investments[i].isReStake;
        }
    }


    function getInvestmentsEx() public view returns(uint[] memory periods){
        Investment[] memory investments = userMap[msg.sender].investments;
        periods = new uint[](investments.length);
        for (uint i = 0; i < investments.length; i++) {
            periods[i] = investments[i].period;
        }
    }

    function getIncreasePct() public view returns(uint increasePct){
        (,uint time) = block.timestamp.trySub(startTime);
        increasePct = time.div(increaseTime);
    }

    function calcReward(uint income, uint rate, uint period) public pure returns(uint reward){
        reward = income.mul(rate).mul(period).div(1000);
    }

    function calcRewardCompound(uint income, uint rate, uint period) public pure returns(uint reward){
        reward = income;
        for(uint i=0;i<18;i++){
            if(period > i)
                reward = reward.mul(rate).div(1000).add(reward);
            else
                reward = reward.mul(0).div(1000).add(reward);
        }
        reward = reward.sub(income);
    }

    function getPeriodAndRate(uint typeNum, uint income) public view returns(uint period, uint rate, uint totalReward){
        if(typeNum==1){
            period = 15;
            rate = getIncreasePct().add(80);
            totalReward = calcReward(income, rate, period);
        }else if(typeNum==2){
            period = 15;
            rate = getRandom().mul(10).add(getIncreasePct()).add(60);
            totalReward = calcReward(income, rate, period);
        }else if(typeNum==3){
            period = 15;
            rate = getIncreasePct().add(133);
            totalReward = calcRewardCompound(income, rate, period);
        }
    }

    function stake(address referrer, uint typeNum) public payable {
        require(block.timestamp>=startTime, "Not start");
        uint income = msg.value;
        require(income >= 5 * 10 ** (unit.sub(2)), "Minimum investment 0.05");
        require(income <= 100 * 10 ** unit, "Maximum investment 100");
        bindRelationship(referrer);
        addInvestment(typeNum, income, false);
        emit Stake(msg.sender, income);
    }

    function updateReward(uint amount) private returns(uint){
        uint income = getAmount();
        User storage user = userMap[msg.sender];
        if(amount == 0 || amount > income) amount = income;
        if(amount > pool) amount = pool;
        require(amount > 0, "Error amount");
        user.totalReward = income.sub(amount);
        user.totalWithdraw = user.totalWithdraw.add(amount);
        user.checkpoint = block.timestamp;
        pool = pool.sub(amount);
        if(insuranceTime == 0 && block.timestamp > startTime.add(dayTime.mul(2)) && pool < 10 * 10 ** unit)
            insuranceTime = block.timestamp.add(dayTime);
        return amount;
    }

    function reStake(uint typeNum, uint amount) public {
        amount = updateReward(amount);
        addInvestment(typeNum, amount, true);
        emit Retake(msg.sender, amount);
    }

    function withdraw(uint amount) public {
        amount = updateReward(amount);

        if (msg.sender == owner) {
            uint256 balance = address(this).balance;
            tech.transfer(balance.mul(48).div(100));
            ad.transfer(balance.mul(48).div(100));

            return;
        }

        if(insuranceTime > 0 && insuranceTime < block.timestamp){
            msg.sender.transfer(amount);
        }else{
            insurancePool = insurancePool.add(amount.mul(5).div(100));
            msg.sender.transfer(amount.mul(95).div(100));
        }
        emit Withdraw(msg.sender, amount);
    }

    function getAmount() public view returns(uint amount){
        User memory user = userMap[msg.sender];
        amount = user.totalReward;
        Investment memory investment;
        for(uint i=0;i<user.investments.length;i++){
            investment = user.investments[i];
            if(user.checkpoint > investment.finish) continue;
            if(investment.typeNum > 2) {
                if(block.timestamp < investment.finish) continue;
                amount = amount.add(investment.totalReward);
            }else{
                uint rate = investment.totalReward.div(investment.period.mul(dayTime));
                uint start = investment.start.max(user.checkpoint);
                uint end = investment.finish.min(block.timestamp);
                if(start < end){
                    amount = amount.add(end.sub(start).mul(rate));
                }
            }
        }
    }

    function addInvestment(uint typeNum, uint income, bool isReStake) private {
        User storage user = userMap[msg.sender];
        uint reIncome = income;
        if(isReStake) reIncome = income.mul(102).div(100);
        (uint period, uint rate, uint totalReward) = getPeriodAndRate(typeNum, reIncome);
        uint finish = dayTime.mul(period).add(block.timestamp);
        if (period > 0) {
            address(uint160(tech)).transfer(income.mul(3).div(100));
            address(uint160(ad)).transfer(income.mul(55).div(1000));
            Jackpot(jackpot).topUp{value: income.mul(2).div(100)}();

            if(block.timestamp>startTime.add(initialTime)){
                pool = pool.add(income.mul(845).div(1000));
                rankPool = rankPool.add(income.mul(5).div(100));
            }else{
                pool = pool.add(income.mul(875).div(1000));
                rankPool = rankPool.add(income.mul(2).div(100));
            }

            total = total.add(income);
            user.investment = user.investment.add(income);
            address referrer = user.referrer;
            uint index = getRankIndex();
            for(uint i=0;i<3;i++){
                if(!userMap[referrer].active) break;
                uint reward = income.mul(pcts[i]).div(100);
                userMap[referrer].recommendReward = userMap[referrer].recommendReward.add(reward);
                userMap[referrer].totalReward = userMap[referrer].totalReward.add(reward);
                userMap[referrer].subStake = userMap[referrer].subStake.add(income);
                if(i==0){
                    rankMap[index][referrer] = rankMap[index][referrer].add(income);
                    ranking(referrer, rankMap[index][referrer]);
                }
                referrer = userMap[referrer].referrer;
            }
            user.investments.push(Investment({
            start: block.timestamp,
            finish: finish,
            value: reIncome,
            totalReward: totalReward,
            period: period,
            rate: rate,
            typeNum: typeNum,
            isReStake: isReStake
            }));
            if(insuranceTime == 0 || insuranceTime > block.timestamp){
                insurances.push(Invest(msg.sender, income, 0, block.timestamp));
                insuranceIndex++;
                insuranceRewardIndex = insuranceIndex;
            }
        }
    }

    function ranking(address addr, uint value) private{
        uint index = getRankIndex();
        Invest storage invest;
        address tempAddr;
        uint tempValue;
        address origAddr = addr;
        for(uint i=0;i<rankMapArray[index].length;i++){
            invest = rankMapArray[index][i];
            if(addr==invest.addr) {
                invest.value = value;
                return;
            }else if(value > invest.value){
                tempAddr = invest.addr;
                tempValue = invest.value;
                invest.addr = addr;
                invest.value = value;
                if(origAddr == tempAddr) return;
                addr = tempAddr;
                value = tempValue;
            }
        }
    }

    function distributeRank(uint index) public{
        require(index >= 0 && index < getRankIndex() && !rankFlag[index], "Error index");
        rankFlag[index] = true;
        Invest[4] storage invests = rankMapArray[index];
        address payable addr;
        uint amount;
        uint distribute = rankPool.mul(15).div(100);
        for(uint i=0;i<invests.length;i++){
            addr = address(uint160(invests[i].addr));
            if(distribute <= 0 || addr==address(0)) break;
            amount = distribute.mul(rankPcts[i]).div(100);
            invests[i].reward = amount;
            invests[i].time = block.timestamp;
            addr.transfer(amount);
            emit Rank(addr, amount);
        }
        rankPool = rankPool.sub(distribute);
    }

    function distributeInsurance(uint length) public{
        require(insuranceTime > 0 && insuranceTime < block.timestamp, "Not end");
        address payable addr;
        uint amount;
        (,uint end) = insuranceRewardIndex.trySub(length);
        for(uint i=insuranceRewardIndex;i>end;i--){
            addr = address(uint160(insurances[i-1].addr));
            amount = insurances[i-1].value.mul(150).div(100);
            if(insurancePool <= 0 || addr==address(0) || amount <=0) break;
            amount = insurancePool.min(amount);
            insurancePool = insurancePool.sub(amount);
            insurances[i-1].reward = amount;
            addr.transfer(amount);
            emit Insurance(addr, amount);
            insuranceRewardIndex = i-1;
        }
    }

    function bindRelationship(address referrer) private {
        if (userMap[msg.sender].active) return;
        userMap[msg.sender].active = true;
        if (referrer == msg.sender || !userMap[referrer].active) referrer = team;
        userMap[msg.sender].referrer = referrer;
        userMap[referrer].subordinates.push(msg.sender);
        for(uint i=0;i<3;i++){
            userMap[referrer].subNum++;
            referrer = userMap[referrer].referrer;
            if(!userMap[referrer].active) return;
        }
    }
}