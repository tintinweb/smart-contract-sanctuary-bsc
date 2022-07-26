// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract NanoBot {

    // constants
    IERC20 BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

    uint constant AMOEBA_TO_BREEDING_BREEDER = 720000;
    uint constant PSN = 10000;
    uint constant PSNH = 5000;
    uint constant DEV_FEE = 3;
    uint constant POOL_FEE = 3;

    // attributes
    uint public marketAmoeba;
    uint public startTime = 6666666666;
    address public owner;
    mapping(address => uint) private lastBreeding;
    mapping(address => uint) private breedingBreeders;
    mapping(address => uint) private claimedAmoeba;
    mapping(address => uint) private tempClaimedAmoeba;
    mapping(address => address) private referrals;
    mapping(address => ReferralData) private referralData;

    // structs
    struct ReferralData {
        address[] invitees;
        uint rebates;
    }

    // modifiers
    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlyOpen {
        require(block.timestamp > startTime, "not open");
        _;
    }

    modifier onlyStartOpen {
        require(marketAmoeba > 0, "not start open");
        _;
    }

    // events
    event Create(address indexed sender, uint indexed amount);
    event Merge(address indexed sender, uint indexed amount);

    constructor() {
        owner = msg.sender;
    }

    // Create Amoeba
    function createAmoeba(address _ref, uint _amount) external onlyStartOpen {
        require(_amount >= 10 ether, "minimum 10BUSD");
        BUSD.transferFrom(msg.sender, address(this), _amount);
        uint poolBalance = BUSD.balanceOf(address(this)) - _amount;
        uint amoebaDivide = calculateAmoebaDivide(_amount, poolBalance);

        // dev fee
        amoebaDivide -= getDevFee(amoebaDivide);
        uint fee = getDevFee(_amount);
        BUSD.transfer(owner, fee);

        claimedAmoeba[msg.sender] += amoebaDivide;
        divideAmoeba(_ref);

        emit Create(msg.sender, _amount);
    }

    // Divide Amoeba
    function divideAmoeba(address _ref) public onlyStartOpen {
        if (_ref == msg.sender || _ref == address(0) || breedingBreeders[_ref] == 0) {
            _ref = owner;
        }

        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = _ref;
            referralData[_ref].invitees.push(msg.sender);
        }

        uint amoebaUsed = getMyAmoeba(msg.sender);
        uint newBreeders = amoebaUsed / AMOEBA_TO_BREEDING_BREEDER;
        breedingBreeders[msg.sender] += newBreeders;
        claimedAmoeba[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp > startTime ? block.timestamp : startTime;

        // referral rebate
        uint amoebaRebate = amoebaUsed * 16 / 100;
        claimedAmoeba[referrals[msg.sender]] += amoebaRebate;
        tempClaimedAmoeba[referrals[msg.sender]] += amoebaRebate;

        marketAmoeba += amoebaUsed / 5;
    }

    // Merge Amoeba
    function mergeAmoeba() external onlyOpen {
        uint hasAmoeba = getMyAmoeba(msg.sender);
        uint amoebaValue = calculateAmoebaMerge(hasAmoeba);
        uint devFee = getDevFee(amoebaValue);
        uint poolFee = getPoolFee(amoebaValue);
        uint realReward = amoebaValue - devFee - poolFee;

        if (tempClaimedAmoeba[msg.sender] > 0) {
            referralData[msg.sender].rebates += calculateAmoebaMerge(tempClaimedAmoeba[msg.sender]);
        }

        // reset
        claimedAmoeba[msg.sender] = 0;
        tempClaimedAmoeba[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp;
        marketAmoeba += hasAmoeba;

        // dev fee
        BUSD.transfer(owner, devFee);

        // user reward
        BUSD.transfer(msg.sender, realReward);

        emit Merge(msg.sender, realReward);
    }

    //only owner
    function seedMarket(uint _startTime, uint _amount) external onlyOwner {
        require(marketAmoeba == 0);
        BUSD.transferFrom(msg.sender, address(this), _amount);
        startTime = _startTime;
        marketAmoeba = 72000000000;
    }

    function amoebaRewards(address _address) public view returns (uint) {
        return calculateAmoebaMerge(getMyAmoeba(_address));
    }

    function getMyAmoeba(address _address) public view returns (uint) {
        return claimedAmoeba[_address] + getAmoebaSinceLastDivide(_address);
    }

    function getClaimAmoeba(address _address) public view returns (uint) {
        return claimedAmoeba[_address];
    }

    function getAmoebaSinceLastDivide(address _address) public view returns (uint) {
        if (block.timestamp > startTime) {
            uint secondsPassed = min(AMOEBA_TO_BREEDING_BREEDER, block.timestamp - lastBreeding[_address]);
            return secondsPassed * breedingBreeders[_address];
        } else {
            return 0;
        }
    }

    function getTempClaimAmoeba(address _address) public view returns (uint) {
        return tempClaimedAmoeba[_address];
    }

    function getPoolAmount() public view returns (uint) {
        return BUSD.balanceOf(address(this));
    }

    function getBreedingBreeders(address _address) public view returns (uint) {
        return breedingBreeders[_address];
    }

    function getReferralData(address _address) public view returns (ReferralData memory) {
        return referralData[_address];
    }

    function getReferralAllRebate(address _address) public view returns (uint) {
        return referralData[_address].rebates;
    }

    function getReferralAllInvitee(address _address) public view returns (uint) {
        return referralData[_address].invitees.length;
    }

    function calculateAmoebaMerge(uint amoeba) public view returns (uint) {
        return calculateTrade(amoeba, marketAmoeba, BUSD.balanceOf(address(this)));
    }

    function calculateAmoebaDivide(uint _busd, uint _contractBalance) private view returns (uint) {
        return calculateTrade(_busd, _contractBalance, marketAmoeba);
    }

    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private pure returns (uint) {
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }

    function getDevFee(uint _amount) private pure returns (uint) {
        return _amount * DEV_FEE / 100;
    }

    function getPoolFee(uint _amount) private pure returns (uint) {
        return _amount * POOL_FEE / 100;
    }

    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}