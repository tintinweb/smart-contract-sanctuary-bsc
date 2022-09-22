/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IBEP20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

contract GF {
    using SafeMath for uint256;
    address payable public ecosystem;
    address public collector = 0xA607dcE4a89BB72637E8bCaa788CC5dD23d091C4;
    uint256 public totalRigsPower;
    uint256 public totalSoldRigsPower;
    uint256 public totalClaimedProfitRigsPower;
    uint256 public totalMiners;
    uint256 public feePercentage = 100; //10%
    uint256 public percentDivider = 1000;
    uint256 public bm = 100;
    uint256 public sd = 100;

    uint256[4] public Duration = [365 days, 180 days, 90 days, 30 days];
    uint256[4] public Profit = [20, 25, 30, 35];
    uint256[4] public Minimum = [1, 10, 100, 200];
    uint256[3] public refBonus = [100, 10, 10];
    uint256[4] public totalRigsPowerPerTier;
    uint256[4] public totalMinersPerTier;

    struct Rig {
        uint256 tier;
        uint256 selltime;
        uint256 lastclaimtime;
        uint256 buyime;
        uint256 buymount;
        uint256 profit;
        uint256 hourlyprofit;
        uint256 RigsPowerclaimed;
        bool sold;
    }

    struct Miner { //User
        uint256 totalRigsPowerMiner;
        uint256 totalSoldRigsPowerMiner;
        uint256 rigsPowerclaimed;
        uint256 rigsPowerCount;
        address referrer;
        bool alreadyExists;
    }

    address nullAddr = address(0x0);
    mapping(address => Miner) public Miners;
    mapping(address => mapping(uint256 => Rig)) public minersRecord;
    mapping(address => mapping(uint256 => uint256)) public MinerRigsPowerPerTier;
    mapping(address => uint256) public boughtRigsPower;
    mapping(address => address) public referrals;

    event BUYWATTS(address Miner, uint256 amount);
    event SELLWATTS(address Miner, uint256 amount);
    event CLAIMWATTS(address Miner, uint256 amount);

    modifier ecoOnly() {
        require(ecosystem == msg.sender, "Denied");
        _;
    }

    function _buywatts(address _buyer, uint256 _amount, uint256 tier_index) private {
        require(tier_index >= 0 && tier_index <= 3, "Invalid watts tier");

        uint256 fee = calcFee(_amount);
        uint256 amount_to_buy = _amount.sub(fee);
        uint256 watts_amount = calcBuyWattsAmount(amount_to_buy);

        require(watts_amount >= Minimum[tier_index], "Amount less than tier minimum");

        commit(collector, fee);

        if (!Miners[_buyer].alreadyExists) {
            Miners[_buyer].alreadyExists = true;
            totalMiners++;
        }
        
        uint256 watts_index = Miners[_buyer].rigsPowerCount;
        Miners[_buyer].totalRigsPowerMiner = Miners[_buyer].totalRigsPowerMiner.add(watts_amount);
        boughtRigsPower[_buyer] = boughtRigsPower[_buyer].add(watts_amount);
        
        minersRecord[_buyer][watts_index].selltime = block.timestamp.add(Duration[tier_index]);
        minersRecord[_buyer][watts_index].buyime = block.timestamp;
        minersRecord[_buyer][watts_index].lastclaimtime = block.timestamp;
        minersRecord[_buyer][watts_index].buymount = watts_amount;
        minersRecord[_buyer][watts_index].profit = watts_amount.mul(Profit[tier_index]).div(percentDivider);

        uint256 _hours = Duration[tier_index].div(1 hours);
        
        minersRecord[_buyer][watts_index].hourlyprofit = minersRecord[_buyer][watts_index].profit.div(_hours);
        minersRecord[_buyer][watts_index].tier = tier_index;
        minersRecord[_buyer][watts_index].RigsPowerclaimed = 0;
        Miners[_buyer].rigsPowerCount++;
        MinerRigsPowerPerTier[_buyer][tier_index] = MinerRigsPowerPerTier[_buyer][tier_index].add(watts_amount);
        totalRigsPowerPerTier[tier_index] = totalRigsPowerPerTier[tier_index].add(watts_amount);
        totalMinersPerTier[tier_index]++;
        totalRigsPower = totalRigsPower.add(watts_amount);

        emit BUYWATTS(_buyer, _amount);
    }

    function buyWatts(uint256 tier_index, address referrer) public payable{
 
        _buywatts(msg.sender, msg.value, tier_index);

        if(referrer != address(0)){
            address ref_l1 = referrer;
            address ref_l2 = getUpline(ref_l1);
            address ref_l3 = getUpline(ref_l2);

            uint256 fee = calcFee(msg.value);
            uint256 _after_fee = msg.value.sub(fee);

            if(ref_l1 != address(0)){
                commit(ref_l1, _after_fee.mul(refBonus[0]).div(percentDivider));
            }
            if(ref_l2 != address(0)){
                commit(ref_l2, _after_fee.mul(refBonus[1]).div(percentDivider));
            }
            if(ref_l3 != address(0)){
                commit(ref_l3, _after_fee.mul(refBonus[2]).div(percentDivider));
            }

            Miners[msg.sender].referrer = referrer;
        }
    }

    function generatedProfit(address _miner, uint256 watts) public view returns(uint256) {
        require(minersRecord[_miner][watts].sold == false, "Watts sold");
        require(minersRecord[_miner][watts].RigsPowerclaimed < minersRecord[_miner][watts].profit, "All profits claimed");

        uint256 _hourlyProfit = minersRecord[_miner][watts].hourlyprofit;
        uint256 _sincelastclaim = SafeMath.sub(block.timestamp, minersRecord[_miner][watts].lastclaimtime);
        uint256 _absence = SafeMath.div(_sincelastclaim, block.timestamp);
        uint256 _absence_percentage = SafeMath.mul(_absence, 100);
        uint256 _claimable = SafeMath.div(SafeMath.mul(_hourlyProfit, _sincelastclaim), 3600);
        _claimable = SafeMath.sub(SafeMath.mul(_absence_percentage, _claimable), _claimable);
        uint256 _rem = SafeMath.sub(minersRecord[_miner][watts].profit, minersRecord[_miner][watts].RigsPowerclaimed); 

        if(_claimable > _rem){
            _claimable = _rem;
        }

        return _claimable;
        
    }

    function sellWatts(uint256 watts) public {
        require(!minersRecord[msg.sender][watts].sold, "Already sold");
        require(watts < Miners[msg.sender].rigsPowerCount, "RigsPower not found");
        require(minersRecord[msg.sender][watts].selltime < block.timestamp, "Wait sell time");

        uint256 sellamount = minersRecord[msg.sender][watts].buymount;
        uint256 _sellFee = SafeMath.mul(sellamount, feePercentage);
        _sellFee = SafeMath.div(_sellFee, percentDivider);
        uint256 _amount = SafeMath.sub(sellamount, _sellFee);
        
        // token.transfer(owner, _sellFee);
        // token.transfer(msg.sender, _amount);

        minersRecord[msg.sender][watts].sold = true;
        boughtRigsPower[msg.sender] = SafeMath.sub(boughtRigsPower[msg.sender], (SafeMath.add(_amount, _sellFee)));
        totalSoldRigsPower = SafeMath.add(SafeMath.add(totalSoldRigsPower, _amount), _sellFee);
        Miners[msg.sender].totalSoldRigsPowerMiner = SafeMath.add(Miners[msg.sender].totalSoldRigsPowerMiner, _amount+_sellFee);
        
        uint256 tierwatts = minersRecord[msg.sender][watts].tier;

        MinerRigsPowerPerTier[msg.sender][tierwatts] = SafeMath.sub(MinerRigsPowerPerTier[msg.sender][tierwatts], _amount+_sellFee);
        totalRigsPowerPerTier[tierwatts] = SafeMath.sub(totalRigsPowerPerTier[tierwatts], _amount+_sellFee);
        totalMinersPerTier[tierwatts]--;

        emit SELLWATTS(msg.sender, _amount);
    }

    function claimProfits(uint256 watts) public {
        require(watts < Miners[msg.sender].rigsPowerCount, "Invalid watts");
        require(minersRecord[msg.sender][watts].RigsPowerclaimed < minersRecord[msg.sender][watts].profit, "All Profits claimed");
        require(SafeMath.sub(block.timestamp, minersRecord[msg.sender][watts].lastclaimtime) >= 86400, "Please wait next claim time");
        
        uint256 _claimable = generatedProfit(msg.sender, watts);

        if(_claimable > (minersRecord[msg.sender][watts].profit) - minersRecord[msg.sender][watts].RigsPowerclaimed){
            _claimable = (minersRecord[msg.sender][watts].profit) - minersRecord[msg.sender][watts].RigsPowerclaimed;
        }
         
        // token.transfer(msg.sender, _claimable);

        minersRecord[msg.sender][watts].RigsPowerclaimed = SafeMath.add(minersRecord[msg.sender][watts].RigsPowerclaimed, _claimable);
        Miners[msg.sender].rigsPowerclaimed = SafeMath.add(Miners[msg.sender].rigsPowerclaimed, _claimable);
        minersRecord[msg.sender][watts].lastclaimtime = block.timestamp;
        totalClaimedProfitRigsPower = SafeMath.add(totalClaimedProfitRigsPower, _claimable);

        emit CLAIMWATTS(msg.sender, _claimable);
    }

    function commit(address addr, uint256 amt) internal {
        payable(addr).transfer(amt);
    }

    function calcFee(uint256 _buy_amount) public view returns(uint256){
        return _buy_amount.mul(feePercentage).div(percentDivider);
    }

    function trim(uint256 _input) public view returns(uint256) {
        uint256 x = _input.div(feePercentage);
        x = x.div(percentDivider);
        return x;
    }

    function calcBuyWattsAmount(uint256 _bnb_amount) public view returns(uint256){
        return _bnb_amount.div(1e18).mul(bm);
    }

    function getUpline(address _miner) public view returns(address){
        return Miners[_miner].referrer;
    }

    function SetMineDuration(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external ecoOnly {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
        Duration[3] = fourth;
    }

    function SetMineProfit(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external ecoOnly {
        Profit[0] = first;
        Profit[1] = second;
        Profit[2] = third;
        Profit[3] = fourth;
    }

    function SetBuyMinimum(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external ecoOnly {
        Minimum[0] = first;
        Minimum[1] = second;
        Minimum[2] = third;
        Minimum[3] = fourth;
    }

    function setPercentDivider(uint256 _divider) external ecoOnly {
        percentDivider = _divider;
    }

     function setFeePercentage(uint256 _percentage) external ecoOnly {
        feePercentage = _percentage;
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
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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