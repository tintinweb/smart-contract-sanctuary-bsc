/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract GF {
    using SafeMath for uint256;
    address payable owner;
    address ecosystem = 0xA607dcE4a89BB72637E8bCaa788CC5dD23d091C4;
    address marketing = 0xCE6F4091152A3889224cc1133D25f3CCF6a74B21;
    uint256 public totalRigsPower;
    uint256 public totalSoldRigsPower;
    uint256 public totalClaimedProfitRigsPower;
    uint256 public totalMiners;
    uint256 public feePercentage = 100; //10%
    uint256 public percentDivider = 1000;
    uint256 public bm = 100;
    uint256 public sd = 100;

    uint256[2] Sf = [800, 200];
    uint256[4] public MineDuration = [365 days, 180 days, 90 days, 30 days];
    uint256[4] Profit = [20, 25, 30, 35];
    uint256[4] public MinimumDepositPerTier = [0.05 ether, 0.2 ether, 1 ether, 2 ether];
    uint256[3] RefBonusPercentage = [100, 10, 10]; //10, 1 and 1%
    uint256[4] public totalDepositsPerTier;
    uint256[4] public totalMinersPerTier;

    struct Rig {
        uint tier;
        uint256 contractStartTime;
        uint256 contractEndTime;
        uint256 lastClaimTime;
        uint256 wattsAmount;
    }

    struct Miners {
        uint256 totalDeposited;
        uint256 totalWithdrawn;
        uint256 rewardBalance;
        uint256 depositsCount;
        uint256 lastWithdrawTime;
        uint256 withdrawalCounter;
        address uplineAddress;
        uint256 downLinesCount;
        bool exists;
    }

    mapping(address => Miners) public Miner;
    mapping(address => mapping(uint256 => Rig)) public minersRecord;

    event BUYWATTS(address Miner, uint256 amount);
    event SELLWATTS(address Miner, uint256 amount);
    event CLAIMWATTS(address Miner, uint256 amount);

    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    bool private reentrancySafe = false;

    modifier nonReentrant() {
        require(!reentrancySafe);
        reentrancySafe = true;
        _;
        reentrancySafe = false;
    }

    constructor(address _owner) {
        owner = payable(_owner);
    }

    function buyWatts(uint256 tier_index, address ref) public payable nonReentrant {
        require(tier_index >= 0 && tier_index <= 3, "Invalid tier");
        require(msg.value >= MinimumDepositPerTier[tier_index], "Amount < minimum");

        uint256 fee = calcFee(msg.value);
        uint256 after_tax = msg.value.sub(fee);
        uint256 watts_amount = calcBuyWattsAmount(after_tax);

        commit(ecosystem, fee.mul(Sf[0]).div(percentDivider));
        commit(marketing, fee.mul(Sf[1]).div(percentDivider));
        
        uint256 watts_index = Miner[msg.sender].depositsCount;
        Miner[msg.sender].totalDeposited = Miner[msg.sender].totalDeposited.add(msg.value);
        minersRecord[msg.sender][watts_index].contractEndTime = block.timestamp.add(MineDuration[tier_index]);
        minersRecord[msg.sender][watts_index].contractStartTime = block.timestamp;
        minersRecord[msg.sender][watts_index].lastClaimTime = block.timestamp;
        minersRecord[msg.sender][watts_index].wattsAmount = watts_amount;
        minersRecord[msg.sender][watts_index].tier = tier_index;
        Miner[msg.sender].depositsCount++;
        totalMinersPerTier[tier_index]++;
        totalDepositsPerTier[tier_index] = totalDepositsPerTier[tier_index].add(msg.value);
        Miner[msg.sender].withdrawalCounter--;

        if(ref != address(0) && ref != msg.sender && ref != address(this) && !isContract(ref) && ref != owner){

            address ref_l2 = Miner[ref].uplineAddress;
            address ref_l3 = Miner[ref_l2].uplineAddress;
                
            commit(ref, after_tax.mul(RefBonusPercentage[0]).div(percentDivider));

            if(ref_l2 != address(0)){
                commit(ref_l2, after_tax.mul(RefBonusPercentage[1]).div(percentDivider));
            }
            if(ref_l3 != address(0)){
                commit(ref_l3, after_tax.mul(RefBonusPercentage[2]).div(percentDivider));
            }

            Miner[msg.sender].uplineAddress = ref;
            Miner[ref].downLinesCount++;
        }

        //If a first-timer
        if (!Miner[msg.sender].exists) {
            Miner[msg.sender].exists = true;
            totalMiners++;
            totalMinersPerTier[tier_index]++;
        }

        emit BUYWATTS(msg.sender, msg.value);
    }

    // function sellWatts(uint256 watts) public nonReentrant {
    //     require(!minersRecord[msg.sender][watts].sold, "Already sold");
    //     require(watts < Miner[msg.sender].depositsCount, "RigsPower not found");
    //     require(minersRecord[msg.sender][watts].selltime < block.timestamp, "Wait sell time");

    //     uint256 sellamount = minersRecord[msg.sender][watts].buymount;
    //     uint256 _sellFee = SafeMath.mul(sellamount, feePercentage);
    //     _sellFee = SafeMath.div(_sellFee, percentDivider);
    //     uint256 _amount = SafeMath.sub(sellamount, _sellFee);
        
    //     // token.transfer(owner, _sellFee);
    //     // token.transfer(msg.sender, _amount);

    //     minersRecord[msg.sender][watts].sold = true;
    //     wattsPurchased[msg.sender] = SafeMath.sub(wattsPurchased[msg.sender], (SafeMath.add(_amount, _sellFee)));
    //     totalSoldRigsPower = SafeMath.add(SafeMath.add(totalSoldRigsPower, _amount), _sellFee);
    //     Miner[msg.sender].totalSoldRigsPowerPerMiner = SafeMath.add(Miner[msg.sender].totalSoldRigsPowerPerMiner, _amount+_sellFee);
        
    //     uint256 tierwatts = minersRecord[msg.sender][watts].tier;

    //     totalMinersPerTier[tierwatts]--;

    //     emit SELLWATTS(msg.sender, _amount);
    // }

    // function claimProfits(uint256 watts) public {
    //     require(watts < Miner[msg.sender].depositsCount, "Invalid watts");
    //     require(minersRecord[msg.sender][watts].profitClaimed < minersRecord[msg.sender][watts].profit, "All Profits claimed");
    //     require(SafeMath.sub(block.timestamp, minersRecord[msg.sender][watts].lastclaimtime) >= 86400, "Please wait next claim time");
        
    //     uint256 _claimable = generatedProfit(msg.sender, watts);

    //     if(_claimable > (minersRecord[msg.sender][watts].profit) - minersRecord[msg.sender][watts].profitClaimed){
    //         _claimable = (minersRecord[msg.sender][watts].profit) - minersRecord[msg.sender][watts].profitClaimed;
    //     }
         
    //     // token.transfer(msg.sender, _claimable);

    //     minersRecord[msg.sender][watts].profitClaimed = SafeMath.add(minersRecord[msg.sender][watts].profitClaimed, _claimable);
    //     Miner[msg.sender].profitClaimed = SafeMath.add(Miner[msg.sender].profitClaimed, _claimable);
    //     minersRecord[msg.sender][watts].lastclaimtime = block.timestamp;
    //     totalClaimedProfitRigsPower = SafeMath.add(totalClaimedProfitRigsPower, _claimable);

    //     emit CLAIMWATTS(msg.sender, _claimable);
    // }

    // function generatedProfit(address _miner, uint256 watts) public view returns(uint256) {
    //     require(minersRecord[_miner][watts].sold == false, "Watts sold");
    //     require(minersRecord[_miner][watts].profitClaimed < minersRecord[_miner][watts].profit, "All profits claimed");

    //     uint256 _sincelastclaim = SafeMath.sub(block.timestamp, minersRecord[_miner][watts].lastclaimtime);
    //     uint256 _absence_percentage = (_sincelastclaim.div(block.timestamp)).mul(100);
    //     uint256 _claimable = (minersRecord[_miner][watts].hourlyprofit.mul(_sincelastclaim)).div(3600);
    //     _claimable = (_absence_percentage.mul(_claimable)).sub(_claimable);
    //     uint256 _rem = SafeMath.sub(minersRecord[_miner][watts].profit, minersRecord[_miner][watts].profitClaimed); 

    //     if(_claimable > _rem){
    //         _claimable = _rem;
    //     }

    //     return _claimable;
        
    // }

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
        return _bnb_amount.div(1e18).mul(bm);
    }

    function isContract(address addr) public view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function getUpline(address _miner) public view returns(address){
        return Miner[_miner].uplineAddress;
    }

    function setMineDuration(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external onlyOwner {
        MineDuration[0] = first;
        MineDuration[1] = second;
        MineDuration[2] = third;
        MineDuration[3] = fourth;
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
        MinimumDepositPerTier[0] = first;
        MinimumDepositPerTier[1] = second;
        MinimumDepositPerTier[2] = third;
        MinimumDepositPerTier[3] = fourth;
    }

    function setPercentDivider(uint256 _div) external onlyOwner {
        percentDivider = _div;
    }

     function setFeePercentage(uint256 _perc) external onlyOwner {
        feePercentage = _perc;
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