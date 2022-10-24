/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

//   /$$      /$$           /$$                                                     /$$                      
//  | $$  /$ | $$          | $$                                                    | $$                      
//  | $$ /$$$| $$  /$$$$$$ | $$  /$$$$$$$  /$$$$$$  /$$$$$$/$$$$   /$$$$$$        /$$$$$$    /$$$$$$         
//  | $$/$$ $$ $$ /$$__  $$| $$ /$$_____/ /$$__  $$| $$_  $$_  $$ /$$__  $$      |_  $$_/   /$$__  $$        
//  | $$$$_  $$$$| $$$$$$$$| $$| $$      | $$  \ $$| $$ \ $$ \ $$| $$$$$$$$        | $$    | $$  \ $$        
//  | $$$/ \  $$$| $$_____/| $$| $$      | $$  | $$| $$ | $$ | $$| $$_____/        | $$ /$$| $$  | $$        
//  | $$/   \  $$|  $$$$$$$| $$|  $$$$$$$|  $$$$$$/| $$ | $$ | $$|  $$$$$$$        |  $$$$/|  $$$$$$/        
//  |__/     \__/ \_______/|__/ \_______/ \______/ |__/ |__/ |__/ \_______/         \___/   \______/         
//                                                                                                           
//                                                                                                           
//                                                                                                           
//    /$$$$$$                                              /$$      /$$ /$$           /$$                    
//   /$$__  $$                                            | $$$    /$$$|__/          |__/                    
//  | $$  \__/  /$$$$$$  /$$$$$$   /$$$$$$$ /$$$$$$$      | $$$$  /$$$$ /$$ /$$$$$$$  /$$ /$$$$$$$   /$$$$$$ 
//  | $$ /$$$$ /$$__  $$/$$__  $$ /$$_____//$$_____/      | $$ $$/$$ $$| $$| $$__  $$| $$| $$__  $$ /$$__  $$
//  | $$|_  $$| $$  \__/ $$  \ $$|  $$$$$$|  $$$$$$       | $$  $$$| $$| $$| $$  \ $$| $$| $$  \ $$| $$  \ $$
//  | $$  \ $$| $$     | $$  | $$ \____  $$\____  $$      | $$\  $ | $$| $$| $$  | $$| $$| $$  | $$| $$  | $$
//  |  $$$$$$/| $$     |  $$$$$$/ /$$$$$$$//$$$$$$$/      | $$ \/  | $$| $$| $$  | $$| $$| $$  | $$|  $$$$$$$
//   \______/ |__/      \______/ |_______/|_______/       |__/     |__/|__/|__/  |__/|__/|__/  |__/ \____  $$
//                                                                                                  /$$  \ $$
//                                                                                                 |  $$$$$$/
//                                                                                                  \______/ 

//This software is an interlectual property of GrossMining... DO NOT COPY!
//Website: https://grossmining.com

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract GrossMining_v2_test {
    using SafeMath for uint256;

    address Dev;
    address engine = 0xFF878c92EDbc7a3dBcF697E01F8B462fB67Dd899;
    address pr = 0x1f3eBE485D1Bf9402Dc7eED9c9DF5865f3800b38;

    uint256 totalDeposits;
    uint256 public totalTx;
    uint256 public totalProfitWithdrawn;
    uint256 distributionPercentage = 100; //10%
    bool public isCloudOpen = false;
    uint256 percentDivider = 1000;
    uint256 powerFactor = 10000000000;

    uint256[4] public Duration = [
        365 days,
        182 days,
        121 days,
        30 days
    ];

    uint256[2] Sf = [800, 200];
    uint256[4] public totalDepositPerTier;
    uint256[4] public totalMinersPerTier;
    uint256[4] MinimumDepositPerPlan = [0.05 ether, 0.2 ether, 1 ether, 0.1 ether];
    uint256 minimumUpgradeAmount = 0.05 ether;
    uint256[3] RefBonusPercentage = [100, 20, 10];
    uint256[4] MinimumHashRatePerTier = [20, 25, 30, 50];

    uint256 NORM_REF_COUNT = 10;
    uint256 ELIT_REF_COUNT = 30;
    uint256 public LIBERTY_WITHDRAWALS = 100;
    uint256 public MIN_ABSENT_DAYS = 5;
    uint256 inOutDifference = 2;
    uint256 maximumHashRate = 50; //5%
    uint256 HASH_RATE_COMPENSATOR = 1; //0.1%
    uint256 SURGE_FACTOR = 3;

    struct Mine {
        uint256 tier;
        uint256 endtime;
        uint256 lastwithdrawtime;
        uint256 starttime;
        uint256 wattsamount;
        uint256 withdrawn;
        bool ended;
    }

    struct Miner {
        uint256 totalDepositMiner;
        uint256 profitWithdrawn;
        uint256 lastWithdrawTime;
        uint256 outCounter;
        uint256 inCounter;
        address uplineAddress;
        uint256 downLinesCount;
        bool exists;
    }

    mapping(address => Miner) public Miners;
    mapping(address => mapping(uint256 => Mine)) public minersRecord;
    mapping(address => mapping(uint256 => uint256)) public minerDepositedPerTier;
    mapping(address => uint256) public deposits;

    event DEPOSIT(address Miner, uint256 amount);
    event UPGRADE(address Miner, uint256 amount);
    event WITHDRAW(address Miner, uint256 amount);

    modifier OnlyDev() {
        require(Dev == msg.sender, "only Dev");
        _;
    }

    bool private reentrancySafe = false;

    modifier nonReentrant() {
        require(!reentrancySafe);
        reentrancySafe = true;
        _;
        reentrancySafe = false;
    }

    constructor(address _Dev) {
        Dev = payable(_Dev);
    }

    function deposit(address ref, uint256 tierIndex) public payable nonReentrant {
        require(tierIndex >= 0 && tierIndex <= 2, "Invalid tier index");
        require(msg.value >= MinimumDepositPerPlan[tierIndex], "Amount too low");

        if(tierIndex == 3){
            require(isCloudOpen, "Special cloud tier is closed for now");
        }

        uint256 deposit_amount = msg.value;
        uint256 distribution = calculateDistribution(deposit_amount);
        uint256 after_distribution = msg.value.sub(distribution);
        uint256 watt_amount = toWatts(after_distribution);

        commit(engine, distribution.mul(Sf[0]).div(percentDivider));
        commit(pr, distribution.mul(Sf[1]).div(percentDivider));

        //first time deposit
        if (!Miners[msg.sender].exists){
            
            if(ref != address(0) && ref != msg.sender && ref != address(this) && !isContract(ref)){

                address ref_l2 = Miners[ref].uplineAddress;
                address ref_l3 = Miners[ref_l2].uplineAddress;

                if(Miners[ref].inCounter >= 1){
                    commit(ref, after_distribution.mul(RefBonusPercentage[0]).div(percentDivider));
                }
                
                if(ref_l2 != address(0) && Miners[ref_l2].inCounter >= 1){
                    commit(ref_l2, after_distribution.mul(RefBonusPercentage[1]).div(percentDivider));
                }

                if(ref_l3 != address(0) && Miners[ref_l3].inCounter >= 1){
                    commit(ref_l3, after_distribution.mul(RefBonusPercentage[2]).div(percentDivider));
                }

                Miners[msg.sender].uplineAddress = ref;
                Miners[ref].downLinesCount++;
            }
        
            Miners[msg.sender].exists = true;
            totalMinersPerTier[tierIndex]++;
        }

        uint256 index = Miners[msg.sender].inCounter;
        Miners[msg.sender].totalDepositMiner = Miners[msg.sender].totalDepositMiner + deposit_amount;
        deposits[msg.sender] += deposit_amount;
        totalDeposits += deposit_amount;
        totalTx++;
        minersRecord[msg.sender][index].endtime = block.timestamp.add(Duration[tierIndex]);
        minersRecord[msg.sender][index].starttime = block.timestamp;
        minersRecord[msg.sender][index].lastwithdrawtime = block.timestamp;
        minersRecord[msg.sender][index].wattsamount = watt_amount;
        minersRecord[msg.sender][index].tier = tierIndex;
        minersRecord[msg.sender][index].withdrawn = 0;
        Miners[msg.sender].inCounter++;
        minerDepositedPerTier[msg.sender][tierIndex] = minerDepositedPerTier[msg.sender][tierIndex] + deposit_amount;
        totalDepositPerTier[tierIndex] += deposit_amount;

        emit DEPOSIT(msg.sender, deposit_amount);
    }

    function upgrade(uint256 watts_index) public payable nonReentrant {
        require(msg.value >= minimumUpgradeAmount, "Amount too low");
        require(minersRecord[msg.sender][watts_index].wattsamount > 1, "Invalid request");
        require(!minersRecord[msg.sender][watts_index].ended, "Contract ended");

        uint256 upgrade_amount = msg.value;
        uint256 distribution = calculateDistribution(upgrade_amount);
        uint256 after_distribution = msg.value.sub(distribution);
        uint256 watt_amount = toWatts(after_distribution);

        uint256 index = Miners[msg.sender].inCounter;
        Miners[msg.sender].totalDepositMiner += upgrade_amount;
        deposits[msg.sender] += upgrade_amount;
        totalDeposits += upgrade_amount;
        totalTx++;
        minersRecord[msg.sender][index].wattsamount += watt_amount;
        Miners[msg.sender].inCounter++;
        minerDepositedPerTier[msg.sender][minersRecord[msg.sender][watts_index].tier] += upgrade_amount;
        totalDepositPerTier[minersRecord[msg.sender][watts_index].tier] += upgrade_amount;

        emit UPGRADE(msg.sender, upgrade_amount);
    }

    function getwithdrawable(address miner, uint256 watts_index) public view returns(uint256) {

        if(minersRecord[miner][watts_index].endtime < block.timestamp){
            minersRecord[miner][watts_index].ended == true;
        }
        require(!minersRecord[miner][watts_index].ended, "Contract ended");

        uint256 tier_index = minersRecord[miner][watts_index].tier;
        uint256 hash_rate = getHashRate(miner, tier_index);

        uint256 _daily = minersRecord[miner][watts_index].wattsamount.mul(hash_rate).div(percentDivider);
        uint256 _hourlyreward = _daily.div(24);
        uint256 _sincelastwithdraw = block.timestamp - minersRecord[miner][watts_index].lastwithdrawtime;
        uint256 _withdrawable = _hourlyreward.mul(_sincelastwithdraw) / 3600;

        return _withdrawable;
    }

    function withdrawProfit(uint256 watts_ndex) public nonReentrant {
        require(watts_ndex <= Miners[msg.sender].inCounter, "Invalid index");
        //require(block.timestamp.sub(minersRecord[msg.sender][watts_ndex].lastwithdrawtime) >= 86400, "Please wait next withdraw time");

        uint256 _withdrawable = getwithdrawable(msg.sender, watts_ndex);
        uint256 distribution_on_watts = calculateDistribution(_withdrawable);
        uint256 after_distribution = _withdrawable.sub(distribution_on_watts);
        uint256 bnb_withdrawable = toBnb(after_distribution);
        uint256 bnb_distribution = toBnb(distribution_on_watts);
         
        commit(engine, bnb_distribution.mul(Sf[0]).div(percentDivider));
        commit(pr, bnb_distribution.mul(Sf[1]).div(percentDivider));
        commit(msg.sender, bnb_withdrawable);
        
        minersRecord[msg.sender][watts_ndex].withdrawn += _withdrawable;
        Miners[msg.sender].profitWithdrawn += _withdrawable; 
        Miners[msg.sender].lastWithdrawTime = block.timestamp;
        minersRecord[msg.sender][watts_ndex].lastwithdrawtime = block.timestamp;
        totalProfitWithdrawn += _withdrawable;
        Miners[msg.sender].outCounter++;
        totalTx++;

        emit WITHDRAW(msg.sender, _withdrawable);
    }

    function calculateDistribution(uint256 _input_amount) public view returns(uint256){
        return _input_amount.mul(distributionPercentage).div(percentDivider);
    }

    function commit(address _address, uint256 _amount) internal {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
    }

    function getHashRate(address miner, uint256 tier_index) public view returns(uint256) {
        uint256 hash_rate = MinimumHashRatePerTier[tier_index];

        if(Miners[miner].exists){
        uint256 days_since_last_withdraw = (block.timestamp - Miners[miner].lastWithdrawTime) / 86400;
        uint256 absence_balancer = days_since_last_withdraw + 1;
            if(Miners[miner].outCounter > 0 && days_since_last_withdraw >= MIN_ABSENT_DAYS){
                hash_rate = hash_rate - (HASH_RATE_COMPENSATOR * (absence_balancer - MIN_ABSENT_DAYS));
            }

            // Normal referral compansation
            if(Miners[miner].downLinesCount >= NORM_REF_COUNT){
                if(Miners[miner].downLinesCount >= ELIT_REF_COUNT){
                    //Elit referral compansation
                    hash_rate = hash_rate + (HASH_RATE_COMPENSATOR * SURGE_FACTOR);
                }else{
                    hash_rate = hash_rate + HASH_RATE_COMPENSATOR;
                }
            }

            if(Miners[miner].outCounter > LIBERTY_WITHDRAWALS && Miners[miner].outCounter > Miners[miner].inCounter){
                uint256 tx_diff = Miners[miner].outCounter - Miners[miner].inCounter;
                if(tx_diff >= inOutDifference){
                    hash_rate = hash_rate - (HASH_RATE_COMPENSATOR * tx_diff);
                }
            }
        }

        //Stop at max
        if(hash_rate > maximumHashRate){
            hash_rate = maximumHashRate;
        }

        //1% Minimum rate
        if(hash_rate < 10){
            hash_rate = 10;
        }

        return hash_rate;
    }

    function toWatts(uint256 _bnb_amount) public view returns(uint256){
        return _bnb_amount.mul(powerFactor).div(1 ether);
    }

    function toBnb(uint256 _watts_amount) public view returns(uint256){
        return _watts_amount.mul(1 ether).div(powerFactor);
    }

    function isContract(address addr) public view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function setMineDuration(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external OnlyDev {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
        Duration[3] = fourth;
    }

    function setSf(
        uint256 first,
        uint256 second
    ) external OnlyDev {
        Sf[0] = first;
        Sf[1] = second;
    }

    function setRefBonusPercentage(
        uint256 first,
        uint256 second,
        uint256 third
    ) external OnlyDev {
        RefBonusPercentage[0] = first;
        RefBonusPercentage[1] = second;
        RefBonusPercentage[2] = third;
    }

    function setMinPerTier(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external OnlyDev {
        MinimumDepositPerPlan[0] = first;
        MinimumDepositPerPlan[1] = second;
        MinimumDepositPerPlan[2] = third;
        MinimumDepositPerPlan[3] = fourth;
    }

    function setMinimumHashRatePerTier(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external OnlyDev {
        MinimumHashRatePerTier[0] = first;
        MinimumHashRatePerTier[1] = second;
        MinimumHashRatePerTier[2] = third;
        MinimumHashRatePerTier[3] = fourth;
    }

    function setMinimumUpgradeAmount(uint256 _mua) external OnlyDev {
        minimumUpgradeAmount = _mua;
    }

    function setInOutDifference(uint256 _iod) external OnlyDev {
        inOutDifference = _iod;
    }

    function setIsCloudOpen(bool _ico) external OnlyDev {
        isCloudOpen = _ico;
    }

    function changeDev(address _dev) external OnlyDev {
        Dev = _dev;
    }

    function setPercentDivider(uint256 _div) external OnlyDev {
        percentDivider = _div;
    }

    function setDistributionPercentage(uint256 _perc) external OnlyDev {
        require(_perc >= 100, "Can not set distribution more than 10%");
        distributionPercentage = _perc;
    }

    function ce(address payable _engine) external OnlyDev {
        engine = _engine;
    }

    function cm(address payable _mkt) external OnlyDev {
        pr = _mkt;
    }

    function updatePowerFactor(uint256 _pf) external OnlyDev {
        powerFactor = _pf;
    }

    function updateLiberty(uint256 _lbt) external OnlyDev {
        LIBERTY_WITHDRAWALS = _lbt;
    }

    function updateMinAbsentDays(uint256 _mds) external OnlyDev {
        MIN_ABSENT_DAYS = _mds;
    }

    function updateMaximumHashRate(uint256 _mhr) external OnlyDev {
        maximumHashRate = _mhr;
    }

    function updateSurgeFactor(uint256 _pnt) external OnlyDev {
        SURGE_FACTOR = _pnt;
    } 
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-Tiers/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}