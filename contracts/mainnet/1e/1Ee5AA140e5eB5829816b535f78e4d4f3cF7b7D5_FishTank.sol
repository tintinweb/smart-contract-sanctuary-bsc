import "./SafeMath.sol";

pragma solidity >=0.8.0;

contract FishTank {

    using SafeMath for uint256;
    address payable private owner;

    uint256 public BEGIN_TIMESTAMP = 1666281600; // Thursday 20st Oct 2022 @ 17:00 GMT

    uint256 public COST_PER_FISH = 1e12; // 0.0000001 ETH per fish, 1000000 fish / ETH
    uint256 public FISH_EGG_PRODUCTION_PER_DAY_PERCENT = 3; // x% * number of fish = eggs produced per 24h
    uint256 public VALUE_PER_EGG = COST_PER_FISH;

    uint256 public DEV_FEE_PERCENT = 1; // on deposits and withdrawals
    uint256 public REF_PERCENT = 1; // on deposits only
    uint256 public REF_MIN_FISH = 100000; // min fish that address must have to get referral rewards

    uint256 private totalFees;
    uint256 public totalRefRewards;

    uint256 public totalFish;
    uint256 public totalDeposited;
    uint256 public totalWithdrawn;

    mapping(address => uint256) public fishCount;
    mapping(address => uint256) public lastAction;
    mapping(address => uint256) private eggCount;

    mapping(address => uint256) public refRewards;

    constructor() {
        owner = payable(msg.sender);
    }

    function buyFish(address payable referrer) public payable returns (bool success) {
        require(block.timestamp >= BEGIN_TIMESTAMP, "too early");
        require(msg.value.div(COST_PER_FISH) > 0, "msg.value < COST_PER_FISH");
        uint256 _fishCount = msg.value.div(COST_PER_FISH);
        updateEggCount(msg.sender);
        fishCount[msg.sender] += _fishCount;
        totalFish += _fishCount;
        totalDeposited += msg.value;
        payFee(msg.value);
        if (referrer != msg.sender) {
            payRef(referrer, msg.value);
        }
        return true;
    }

    function getEggCount(address user) public view returns (uint256 eggs) {
        uint256 _timeDiff = block.timestamp - lastAction[user];
        return eggCount[user].add(fishCount[user].mul(_timeDiff).mul(FISH_EGG_PRODUCTION_PER_DAY_PERCENT).div(8640000));
    }

    function updateEggCount(address user) private returns (uint256 eggs) {
        eggCount[user] = getEggCount(user);
        lastAction[user] = block.timestamp;
        return eggCount[user];
    }

    function hatchEggs() public returns (uint256 eggs) {
        uint256 _eggsToHatch = updateEggCount(msg.sender);
        fishCount[msg.sender] += _eggsToHatch;
        totalFish += _eggsToHatch;
        eggCount[msg.sender] = 0;
        return _eggsToHatch;
    }

    function sellEggs() public returns (uint256 eggs) {
        uint256 _eggsToSell = updateEggCount(msg.sender);
        uint256 _eggsValue = VALUE_PER_EGG.mul(_eggsToSell);
        payable(msg.sender).transfer(_eggsValue);
        eggCount[msg.sender] = 0;
        totalWithdrawn += _eggsValue;
        payFee(_eggsValue);
        return _eggsToSell;
    }

    function payFee(uint256 value) private returns (bool success) {
        owner.transfer(value.mul(DEV_FEE_PERCENT).div(100));
        totalFees += value.mul(DEV_FEE_PERCENT).div(100);
        return true;
    }

    function payRef(address payable referrer, uint256 value) private returns (bool success) {
        if (fishCount[referrer] >= REF_MIN_FISH && referrer != address(0)) {
            uint256 _refReward = value.mul(REF_PERCENT).div(100);
            referrer.transfer(_refReward);
            refRewards[referrer] += _refReward;
            totalRefRewards += _refReward;
            return true;
        } else {
            return false;
        }
    }

    function totalFeesCollected() public view returns (uint256 feesCollected) {
        require(msg.sender == owner);
        return totalFees;
    }

}