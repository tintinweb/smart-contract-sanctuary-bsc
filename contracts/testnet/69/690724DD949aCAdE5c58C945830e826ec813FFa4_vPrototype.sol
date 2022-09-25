/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract vPrototype {
    using SafeMath for uint256;

    address owner;
    address ecosystem = 0xA607dcE4a89BB72637E8bCaa788CC5dD23d091C4;
    address marketing = 0xCE6F4091152A3889224cc1133D25f3CCF6a74B21;

    uint256 feePercentage = 100; //10%
    uint256 percentDivider = 1000;
    uint256 exchangeMultiplier = 10000;
    uint256 referralCompensationFactor = 3;
    uint256 maximumHashRate = 100; //10%
    uint256 minimumRewardConvertable = 1;
    uint256 HashRateCompensator = 1; //0.1%
 
    uint256[2] Sf = [800, 200];
    uint256[4] MineDuration = [365 days, 182 days, 121 days, 91 days];
    uint256[4] MinimumHashRatePerTier = [20, 25, 30, 35];
    uint256[4] MinimumDepositPerTier = [0.05 ether, 0.2 ether, 1 ether, 2 ether];
    uint256[3] RefBonusPercentage = [100, 10, 10]; //10, 1 and 1%
    
    uint256 public totalClaimed;
    uint256 public totalWithdrawn;
    uint256[4] public totalDepositsPerTier;
    uint256[4] public totalMinersPerTier;

    struct Rig {
        uint256 tier;
        uint256 contractStartTime;
        uint256 contractEndTime;
        uint256 lastClaimTime;
        uint256 wattsAmount;
    }

    struct Miner {
        uint256 rigsCount;
        uint256 availableToWithdraw;
        uint256 claimed;
        uint256 withdrawn;
        uint256 lastWithdrawTime;
        uint256 withdrawalCounter;
        address uplineAddress;
        uint256 downLinesCount;
        bool exists;
    }

    mapping(address => Miner) public Miners;
    mapping(address => mapping(uint256 => Rig)) public minersRecord;
    mapping(address => mapping(uint256 => uint256)) public minerDepositPerTier;
    mapping(address => uint256) public minerDeposits;

    event DEPOSIT(address Miner, uint256 amount);
    event WITHDRAWREWARD(address Miner, uint256 amount);
    event CLAIMREWARD(address Miner, uint256 amount);

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

    function buyWatts(uint256 tier_index, address ref) external payable nonReentrant {
        require(tier_index >= 0 && tier_index <= 3, "Invalid tier");
        require(msg.value >= MinimumDepositPerTier[tier_index], "Amount less than minimum");

        uint256 fee = calcFee(msg.value);
        uint256 after_tax = msg.value.sub(fee);
        uint256 watts_amount = toWatts(after_tax);

        commit(ecosystem, fee.mul(Sf[0]).div(percentDivider));
        commit(marketing, fee.mul(Sf[1]).div(percentDivider));
        
        uint256 watts_index = Miners[msg.sender].rigsCount;

        minerDeposits[msg.sender] = minerDeposits[msg.sender].add(msg.value);
        minersRecord[msg.sender][watts_index].tier = tier_index;
        minersRecord[msg.sender][watts_index].contractStartTime = block.timestamp;
        minersRecord[msg.sender][watts_index].contractEndTime = block.timestamp.add(MineDuration[tier_index]);
        minersRecord[msg.sender][watts_index].lastClaimTime = block.timestamp;
        minersRecord[msg.sender][watts_index].wattsAmount = watts_amount;
        Miners[msg.sender].rigsCount++;
        Miners[msg.sender].withdrawalCounter--;
        totalDepositsPerTier[tier_index] += msg.value;

        if(ref != address(0) && ref != msg.sender && ref != address(this) && !isContract(ref) && ref != owner){

            address ref_l2 = Miners[ref].uplineAddress;
            address ref_l3 = Miners[ref_l2].uplineAddress;

            if(ref != address(0)){
                commit(ref, after_tax.mul(RefBonusPercentage[0]).div(percentDivider));
            }
            if(ref_l2 != address(0)){
                commit(ref_l2, after_tax.mul(RefBonusPercentage[1]).div(percentDivider));
            }
            if(ref_l3 != address(0)){
                commit(ref_l3, after_tax.mul(RefBonusPercentage[2]).div(percentDivider));
            }

            Miners[msg.sender].uplineAddress = ref;
            Miners[ref].downLinesCount++;
        }

        //If a first-timer
        if (!Miners[msg.sender].exists) {
            Miners[msg.sender].exists = true;
            totalMinersPerTier[tier_index]++;
        }

        emit DEPOSIT(msg.sender, msg.value);
    }

    function withdrawReward() external nonReentrant {
        require(Miners[msg.sender].availableToWithdraw > minimumRewardConvertable, "Not enough rewards");

        uint256 available = Miners[msg.sender].availableToWithdraw;
        uint256 bnb_amount = toBnb(available);
        uint256 fee = calcFee(bnb_amount);
        uint256 after_tax = bnb_amount.sub(fee);
        
        commit(msg.sender, after_tax);
        commit(ecosystem, fee.mul(Sf[0]).div(percentDivider));
        commit(marketing, fee.mul(Sf[1]).div(percentDivider));
        
        minerDeposits[msg.sender] = minerDeposits[msg.sender].sub(bnb_amount);
        Miners[msg.sender].availableToWithdraw = 0;
        totalWithdrawn += bnb_amount;
        Miners[msg.sender].withdrawn += after_tax;
        Miners[msg.sender].lastWithdrawTime = block.timestamp;
        Miners[msg.sender].withdrawalCounter++;

        emit WITHDRAWREWARD(msg.sender, after_tax);
    }

    function claimReward(uint256 watts_index) external {
        require(watts_index <= Miners[msg.sender].rigsCount, "Invalid watts index");
        require(block.timestamp.sub(minersRecord[msg.sender][watts_index].lastClaimTime) > 24 hours, "Wait next claim time");
        
        uint256 _claimable = rewardGenerated(msg.sender, watts_index);

        Miners[msg.sender].availableToWithdraw = Miners[msg.sender].availableToWithdraw.add(_claimable);
        Miners[msg.sender].claimed = Miners[msg.sender].claimed.add(_claimable);
        minersRecord[msg.sender][watts_index].lastClaimTime = block.timestamp;
        totalClaimed = totalClaimed.add(_claimable);

        emit CLAIMREWARD(msg.sender, _claimable);
    }

    function rewardGenerated(address _miner, uint256 watts_index) public view returns(uint256) {
        require(minersRecord[_miner][watts_index].contractEndTime > block.timestamp, "Mining contract concluded");

        uint256 tier_index = minersRecord[_miner][watts_index].tier;
        uint256 hash_rate = MinimumHashRatePerTier[tier_index];
        uint256 since_last_withdraw = block.timestamp.sub(Miners[_miner].lastWithdrawTime);

        if(since_last_withdraw.div(24 hours) >= 2){
            hash_rate -= HashRateCompensator;
        }

        if(Miners[_miner].downLinesCount >= referralCompensationFactor){
            hash_rate += HashRateCompensator;
        }

        if(Miners[msg.sender].withdrawalCounter > 2){
            hash_rate -= HashRateCompensator.mul(Miners[msg.sender].withdrawalCounter);
        }

        if(hash_rate > maximumHashRate){
            hash_rate = maximumHashRate;
        }

        uint256 daily = minersRecord[_miner][watts_index].wattsAmount.mul(hash_rate).div(percentDivider);
        uint256 since_last_claim = block.timestamp.sub(minersRecord[msg.sender][watts_index].lastClaimTime);

        return (daily.mul(since_last_claim)).div(24 hours);

    }

    function calcFee(uint256 _input_amount) public view returns(uint256){
        return _input_amount.mul(feePercentage).div(percentDivider);
    }

    function commit(address _address, uint256 _amount) internal {
        payable(_address).transfer(_amount);
    }

    function toWatts(uint256 _bnb_amount) public view returns(uint256){
        return _bnb_amount.mul(exchangeMultiplier).div(1 ether);
    }

    function toBnb(uint256 _watts_amount) public view returns(uint256){
        return _watts_amount.mul(1 ether).div(exchangeMultiplier);
    }

    function e(address _eco) external onlyOwner {
        ecosystem = _eco;
    }

    function isContract(address addr) public view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

     function m(address _mkt) external onlyOwner {
        marketing = _mkt;
    }

    function updateMineMineDuration(
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

    function updateMinimumHashRatePerTier(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external onlyOwner {
        MinimumHashRatePerTier[0] = first;
        MinimumHashRatePerTier[1] = second;
        MinimumHashRatePerTier[2] = third;
        MinimumHashRatePerTier[3] = fourth;
    }

    function updateBuyMinimum(
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

    function updatePercentDivider(uint256 _div) external onlyOwner {
        percentDivider = _div;
    }

    function updateMinimumRewardConvertable(uint256 _mic) external onlyOwner {
        minimumRewardConvertable = _mic;
    }
    
     function updateFeePercentage(uint256 _perc) external onlyOwner {
        feePercentage = _perc;
    }

    function updateexchangeMultiplier(uint256 _mult) external onlyOwner {
        exchangeMultiplier = _mult;
    }

    function updateHashRateCompensator(uint256 _hrc) external onlyOwner {
        HashRateCompensator = _hrc;
    }

    function updatereferralCompensationFactor(uint256 _dlfd) external onlyOwner {
        referralCompensationFactor = _dlfd;
    }

    //REMEMBER:::TEST PURPOSES ONLY! DELETE IN PRODUCTION
    function recoverBal() external onlyOwner {
        commit(msg.sender, address(this).balance);
    }

    function updateSf(
        uint256 first,
        uint256 second
    ) external onlyOwner {
        Sf[0] = first;
        Sf[1] = second;
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