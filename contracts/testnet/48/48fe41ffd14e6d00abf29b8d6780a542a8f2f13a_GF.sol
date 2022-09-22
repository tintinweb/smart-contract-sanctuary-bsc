/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract GF {
    using SafeMath for uint256;
    address payable public owner;
    address public collector = 0xA607dcE4a89BB72637E8bCaa788CC5dD23d091C4;
    uint256 public totalRigsPower;
    uint256 public totalSoldRigsPower;
    uint256 public totalClaimedProfitRigsPower;
    uint256 public totalMiners;
    uint256 public feePercentage = 100; //10%
    uint256 public percentDivider = 1000;
    uint256 public buyMultiplier = 100;
    uint256 public sd = 100;

    uint256[4] public Duration = [365 days, 180 days, 90 days, 30 days];
    uint256[4] public Profit = [20, 25, 30, 35];
    uint256[4] public Minimum = [0.01 ether, 0.1 ether, 1 ether, 2 ether];
    uint256[3] public refBonusPercentage = [100, 10, 10]; //10, 1 and 1%
    uint256[4] public totalRigsPowerPerTier;
    uint256[4] public totalMinersPerTier;

    struct Rig {
        uint tier;
        uint256 profitendtime;
        uint256 lastclaimtime;
        uint256 buyime;
        uint256 wattsamount;
        uint256 profit;
        uint256 hourlyprofit;
        uint256 profitClaimed;
        bool sold;
    }

    struct Miner { //User
        uint256 totalPurchasedRigsPowerPerMiner;
        uint256 totalSoldRigsPowerPerMiner;
        uint256 profitClaimed;
        uint256 rigsPowerCount;
        address referrer;
        bool alreadyExists;
    }

    mapping(address => Miner) public Miners;
    mapping(address => mapping(uint256 => Rig)) public minersRecord;
    mapping(address => mapping(uint256 => uint256)) public minerRigsPowerPerTier;
    mapping(address => uint256) public wattsPurchased;

    event BUYWATTS(address Miner, uint256 amount);
    event SELLWATTS(address Miner, uint256 amount);
    event CLAIMWATTS(address Miner, uint256 amount);

    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    constructor(address _owner) {
        owner = payable(_owner);
    }

    function buyWatts(uint256 tier_index, address referrer) public payable {
        require(tier_index >= 0 && tier_index <= 3, "Invalid tier");
        require(msg.value >= Minimum[tier_index], "Amount < minimum");

        uint256 after_tax = msg.value.sub(calcFee(msg.value));
        uint256 watts_amount = calcBuyWattsAmount(after_tax);

        commit(collector, calcFee(msg.value));

        if (!Miners[msg.sender].alreadyExists) {
            Miners[msg.sender].alreadyExists = true;
            totalMiners++;
        }
        
        uint256 watts_index = Miners[msg.sender].rigsPowerCount;
        Miners[msg.sender].totalPurchasedRigsPowerPerMiner = Miners[msg.sender].totalPurchasedRigsPowerPerMiner.add(watts_amount);
        wattsPurchased[msg.sender] = wattsPurchased[msg.sender].add(watts_amount);
        
        minersRecord[msg.sender][watts_index].buyime = block.timestamp;
        minersRecord[msg.sender][watts_index].profitendtime = block.timestamp.add(Duration[tier_index]);
        minersRecord[msg.sender][watts_index].lastclaimtime = block.timestamp;
        minersRecord[msg.sender][watts_index].wattsamount = watts_amount;
        minersRecord[msg.sender][watts_index].profit = watts_amount.mul(Profit[tier_index]).div(percentDivider);

        uint256 _hours = Duration[tier_index].div(1 hours);
        
        minersRecord[msg.sender][watts_index].hourlyprofit = minersRecord[msg.sender][watts_index].profit.div(_hours);
        minersRecord[msg.sender][watts_index].tier = tier_index;
        minersRecord[msg.sender][watts_index].profitClaimed = 0;
        Miners[msg.sender].rigsPowerCount++;
        minerRigsPowerPerTier[msg.sender][tier_index] = minerRigsPowerPerTier[msg.sender][tier_index].add(watts_amount);
        totalRigsPowerPerTier[tier_index] = totalRigsPowerPerTier[tier_index].add(watts_amount);
        totalMinersPerTier[tier_index]++;
        totalRigsPower = totalRigsPower.add(watts_amount);

        if(referrer != address(0)){
            address ref_l2 = getUpline(referrer);
            address ref_l3 = getUpline(ref_l2);

            if(referrer != address(0)){
                commit(referrer, after_tax.mul(refBonusPercentage[0]).div(percentDivider));
            }
            if(ref_l2 != address(0)){
                commit(ref_l2, after_tax.mul(refBonusPercentage[1]).div(percentDivider));
            }
            if(ref_l3 != address(0)){
                commit(ref_l3, after_tax.mul(refBonusPercentage[2]).div(percentDivider));
            }

            Miners[msg.sender].referrer = referrer;
        }

        emit BUYWATTS(msg.sender, msg.value);
    }

    // function sellWatts(uint256 watts) public {
    //     require(!minersRecord[msg.sender][watts].sold, "Already sold");
    //     require(watts < Miners[msg.sender].rigsPowerCount, "RigsPower not found");
    //     require(minersRecord[msg.sender][watts].profitendtime < block.timestamp, "Wait sell time");

    //     uint256 sellamount = minersRecord[msg.sender][watts].wattsamount;
    //     uint256 _sellFee = SafeMath.mul(sellamount, feePercentage);
    //     _sellFee = SafeMath.div(_sellFee, percentDivider);
    //     uint256 _amount = SafeMath.sub(sellamount, _sellFee);
        
    //     // token.transfer(owner, _sellFee);
    //     // token.transfer(msg.sender, _amount);

    //     minersRecord[msg.sender][watts].sold = true;
    //     wattsPurchased[msg.sender] = SafeMath.sub(wattsPurchased[msg.sender], (SafeMath.add(_amount, _sellFee)));
    //     totalSoldRigsPower = SafeMath.add(SafeMath.add(totalSoldRigsPower, _amount), _sellFee);
    //     Miners[msg.sender].totalSoldRigsPowerPerMiner = SafeMath.add(Miners[msg.sender].totalSoldRigsPowerPerMiner, _amount+_sellFee);
        
    //     uint256 tierwatts = minersRecord[msg.sender][watts].tier;

    //     minerRigsPowerPerTier[msg.sender][tierwatts] = SafeMath.sub(minerRigsPowerPerTier[msg.sender][tierwatts], _amount+_sellFee);
    //     totalRigsPowerPerTier[tierwatts] = SafeMath.sub(totalRigsPowerPerTier[tierwatts], _amount+_sellFee);
    //     totalMinersPerTier[tierwatts]--;

    //     emit SELLWATTS(msg.sender, _amount);
    // }

    // function claimProfits(uint256 watts) public {
    //     require(watts < Miners[msg.sender].rigsPowerCount, "Invalid watts");
    //     require(minersRecord[msg.sender][watts].profitClaimed < minersRecord[msg.sender][watts].profit, "All Profits claimed");
    //     require(SafeMath.sub(block.timestamp, minersRecord[msg.sender][watts].lastclaimtime) >= 86400, "Please wait next claim time");
        
    //     uint256 _claimable = generatedProfit(msg.sender, watts);

    //     if(_claimable > (minersRecord[msg.sender][watts].profit) - minersRecord[msg.sender][watts].profitClaimed){
    //         _claimable = (minersRecord[msg.sender][watts].profit) - minersRecord[msg.sender][watts].profitClaimed;
    //     }
         
    //     // token.transfer(msg.sender, _claimable);

    //     minersRecord[msg.sender][watts].profitClaimed = SafeMath.add(minersRecord[msg.sender][watts].profitClaimed, _claimable);
    //     Miners[msg.sender].profitClaimed = SafeMath.add(Miners[msg.sender].profitClaimed, _claimable);
    //     minersRecord[msg.sender][watts].lastclaimtime = block.timestamp;
    //     totalClaimedProfitRigsPower = SafeMath.add(totalClaimedProfitRigsPower, _claimable);

    //     emit CLAIMWATTS(msg.sender, _claimable);
    // }


    function generatedProfit(address _miner, uint256 watts) public view returns(uint256) {
        require(minersRecord[_miner][watts].sold == false, "Watts sold");
        require(minersRecord[_miner][watts].profitClaimed < minersRecord[_miner][watts].profit, "All profits claimed");

        uint256 _sincelastclaim = SafeMath.sub(block.timestamp, minersRecord[_miner][watts].lastclaimtime);
        uint256 _absence_percentage = (_sincelastclaim.div(block.timestamp)).mul(100);
        uint256 _claimable = (minersRecord[_miner][watts].hourlyprofit.mul(_sincelastclaim)).div(3600);
        _claimable = (_absence_percentage.mul(_claimable)).sub(_claimable);
        uint256 _rem = SafeMath.sub(minersRecord[_miner][watts].profit, minersRecord[_miner][watts].profitClaimed); 

        if(_claimable > _rem){
            _claimable = _rem;
        }

        return _claimable;
        
    }

    function commit(address addr, uint256 amt) internal {
        payable(addr).transfer(amt);
    }

    function calcFee(uint256 _buy_amount) public view returns(uint256){
        return _buy_amount.mul(feePercentage).div(percentDivider);
    }

    function trim(uint256 _input) public view returns(uint256) {
        return (_input.div(feePercentage)).div(percentDivider);
    }

    function calcBuyWattsAmount(uint256 _bnb_amount) public view returns(uint256){
        return _bnb_amount.mul(buyMultiplier);
    }

    function getUpline(address _miner) public view returns(address){
        return Miners[_miner].referrer;
    }

    function setMineDuration(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external onlyOwner {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
        Duration[3] = fourth;
    }

    function setMineProfit(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external onlyOwner {
        Profit[0] = first;
        Profit[1] = second;
        Profit[2] = third;
        Profit[3] = fourth;
    }

    function setBuyMinimum(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external onlyOwner {
        Minimum[0] = first;
        Minimum[1] = second;
        Minimum[2] = third;
        Minimum[3] = fourth;
    }

    function setPercentDivider(uint256 _div) external onlyOwner {
        percentDivider = _div;
    }

     function setFeePercentage(uint256 _perc) external onlyOwner {
        feePercentage = _perc;
    }

    function updateBuyMultiplier(uint256 _mult) external onlyOwner {
        buyMultiplier = _mult;
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