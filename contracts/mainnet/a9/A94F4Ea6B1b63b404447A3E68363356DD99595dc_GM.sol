/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract GM {
    using SafeMath for uint256;

    address public Dev;
    address public ecosystem = 0xFF878c92EDbc7a3dBcF697E01F8B462fB67Dd899;
    address public promo = 0x1f3eBE485D1Bf9402Dc7eED9c9DF5865f3800b38;

    uint256 totalDeposits;
    uint256 public totalTx;
    uint256 public totalProfitWithdrawn;
    uint256 public totalMiners;
    uint256 public feePercentage = 100; //10%
    uint256 percentDivider = 1000;
    uint256 powerFactor = 10000000000;

    uint256[3] public Duration = [
        365 days,
        182 days,
        121 days
    ];

    uint256[2] Sf = [800, 200];
    uint256[3] public totalDepositPerTier;
    uint256[3] public totalMinersPerTier;
    uint256[3] MinimumPerPlan = [0.05 ether, 0.2 ether, 1 ether];
    uint256[3] RefBonusPercentage = [100, 20, 10];
    uint256[3] MinimumHashRatePerTier = [20, 25, 30];

    uint256 NORM_REF_COUNT = 10;
    uint256 ELIT_REF_COUNT = 30;
    uint256 public LIBERTY_WITHDRAWALS = 100;
    uint256 public MIN_ABSENT_DAYS = 5;
    uint256 maximumHashRate = 100; //10%
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
        uint256 withdrawalCount;
        uint256 depositCount;
        address uplineAddress;
        uint256 downLinesCount;
        bool exists;
    }

    mapping(address => Miner) public Miners;
    mapping(address => mapping(uint256 => Mine)) public minersRecord;
    mapping(address => mapping(uint256 => uint256)) public minerDepositedPerTier;
    mapping(address => uint256) public deposits;

    event DEPOSIT(address Miner, uint256 amount);
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
        require(msg.value >= MinimumPerPlan[tierIndex], "Amount too low");

        uint256 deposit_amount = msg.value;
        uint256 fee = calcFee(deposit_amount);
        uint256 after_tax = msg.value.sub(fee);
        uint256 watt_amount = toWatts(after_tax);

        commit(ecosystem, fee.mul(Sf[0]).div(percentDivider));
        commit(promo, fee.mul(Sf[1]).div(percentDivider));

        //first time deposit
        if (!Miners[msg.sender].exists) {
            
            if(ref != address(0) && ref != msg.sender && ref != address(this) && !isContract(ref)){

                address ref_l2 = Miners[ref].uplineAddress;
                address ref_l3 = Miners[ref_l2].uplineAddress;

                if(Miners[ref].depositCount >= 1){
                    commit(ref, after_tax.mul(RefBonusPercentage[0]).div(percentDivider));
                }
                
                if(ref_l2 != address(0) && Miners[ref_l2].depositCount >= 1){
                    commit(ref_l2, after_tax.mul(RefBonusPercentage[1]).div(percentDivider));
                }

                if(ref_l3 != address(0) && Miners[ref_l3].depositCount >= 1){
                    commit(ref_l3, after_tax.mul(RefBonusPercentage[2]).div(percentDivider));
                }

                Miners[msg.sender].uplineAddress = ref;
                Miners[ref].downLinesCount++;
            }
        
            Miners[msg.sender].exists = true;
            totalMiners++;
            totalMinersPerTier[tierIndex]++;
        }

        uint256 index = Miners[msg.sender].depositCount;
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
        Miners[msg.sender].depositCount++;
        minerDepositedPerTier[msg.sender][tierIndex] = minerDepositedPerTier[msg.sender][tierIndex] + deposit_amount;
        totalDepositPerTier[tierIndex] += deposit_amount;

        emit DEPOSIT(msg.sender, deposit_amount);
    }

    function getwithdrawable(address miner, uint256 watts_index) public view returns(uint256) {

        if(minersRecord[miner][watts_index].endtime < block.timestamp){
            minersRecord[miner][watts_index].ended == true;
        }
        require(minersRecord[miner][watts_index].ended == false, "Contract ended");

        uint256 tier_index = minersRecord[miner][watts_index].tier;
        uint256 hash_rate = getHashRate(miner, tier_index);

        uint256 _daily = minersRecord[miner][watts_index].wattsamount.mul(hash_rate).div(percentDivider);
        uint256 _hourlyreward = _daily.div(24);
        uint256 _sincelastwithdraw = block.timestamp - minersRecord[miner][watts_index].lastwithdrawtime;
        uint256 _withdrawable = _hourlyreward.mul(_sincelastwithdraw) / 3600;

        return _withdrawable;
    }

    function withdrawProfit(uint256 wattsIndex) public {
        require(wattsIndex <= Miners[msg.sender].depositCount, "Invalid index");
        require(block.timestamp.sub(minersRecord[msg.sender][wattsIndex].lastwithdrawtime) >= 86400, "Please wait next withdraw time");

        uint256 _withdrawable = getwithdrawable(msg.sender, wattsIndex);
        uint256 fee_on_watts = calcFee(_withdrawable);
        uint256 after_tax = _withdrawable.sub(fee_on_watts);
        uint256 bnb_withdrawable = toBnb(after_tax);
        uint256 bnb_fee = toBnb(fee_on_watts);
         
        commit(ecosystem, bnb_fee.mul(Sf[0]).div(percentDivider));
        commit(promo, bnb_fee.mul(Sf[1]).div(percentDivider));
        commit(msg.sender, bnb_withdrawable);
        
        minersRecord[msg.sender][wattsIndex].withdrawn = minersRecord[msg.sender][wattsIndex].withdrawn + _withdrawable;
        Miners[msg.sender].profitWithdrawn = Miners[msg.sender].profitWithdrawn + _withdrawable; 
        Miners[msg.sender].lastWithdrawTime = block.timestamp;
        minersRecord[msg.sender][wattsIndex].lastwithdrawtime = block.timestamp;
        totalProfitWithdrawn = totalProfitWithdrawn + _withdrawable;
        Miners[msg.sender].withdrawalCount++;
        totalTx++;

        emit WITHDRAW(msg.sender, _withdrawable);
    }

    function calcFee(uint256 _input_amount) public view returns(uint256){
        return _input_amount.mul(feePercentage).div(percentDivider);
    }

    function commit(address _address, uint256 _amount) internal {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
    }

    function getHashRate(address miner, uint256 tier_index) public view returns(uint256) {
        uint256 hash_rate = MinimumHashRatePerTier[tier_index];

        if(Miners[miner].exists){
        uint256 days_since_last_withdraw = (block.timestamp - Miners[miner].lastWithdrawTime) / 86400;

            if(Miners[miner].withdrawalCount > 0 && days_since_last_withdraw >= MIN_ABSENT_DAYS){
                hash_rate = hash_rate - (HASH_RATE_COMPENSATOR * SURGE_FACTOR);
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

            if(Miners[miner].withdrawalCount > LIBERTY_WITHDRAWALS && Miners[miner].withdrawalCount > Miners[miner].depositCount){
                uint256 tx_diff = Miners[miner].withdrawalCount - Miners[miner].depositCount;
                if(tx_diff >= 2){
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

    function SetMineDuration(
        uint256 first,
        uint256 second,
        uint256 third
    ) external OnlyDev {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
    }

    function changeDev(address _dev) external OnlyDev {
        Dev = _dev;
    }

    function setPercentDivider(uint256 _div) external OnlyDev {
        percentDivider = _div;
    }

    function setFeePercentage(uint256 _perc) external OnlyDev {
        require(100 >= _perc, "Can not set fee more than 10%");
        feePercentage = _perc;
    }

    function ce(address payable _ecosystem) external OnlyDev {
        ecosystem = _ecosystem;
    }

    function cm(address payable _mkt) external OnlyDev {
        promo = _mkt;
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