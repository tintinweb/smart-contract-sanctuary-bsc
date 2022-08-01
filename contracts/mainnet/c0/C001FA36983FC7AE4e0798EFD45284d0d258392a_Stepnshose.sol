// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import 'hardhat/console.sol';
contract Stepnshose {
    // constants
    uint constant STEPN_TO_SHOES_RUNNING = 1080000;
    uint constant PSN = 10000;
    uint constant PSNH = 5000;

    // attributes
    uint public marketShose;
    uint public startTime = 6666666666;

    address private deployer;
    address public owner;
    address public address2;
    address private amm;
    uint private repair;

    mapping (address => uint) private lastRunning;
    mapping (address => uint) private runningStep;
    mapping (address => uint) private claimedShose;
    mapping (address => uint) private tempClaimedShose;
    mapping (address => address) private referrals;
    mapping (address => ReferralData) private referralData;

    // structs
    struct ReferralData {
        address[] invitees;
        uint rebates;
    }

    // modifiers
    modifier onlyOwner {
        require(msg.sender == deployer, "not deployer");
        _;
    }

    modifier onlyOpen {
        require(block.timestamp > startTime, "not open");
        _;
    }

    modifier onlyStartOpen {
        require(marketShose > 0, "not start open");
        _;
    }

    // events
    event Create(address indexed sender, uint indexed amount);
    event Merge(address indexed sender, uint indexed amount);

    constructor(address _owner, address _address2) {
        deployer = msg.sender;
        owner = _owner;
        address2 = _address2;
    }

    // Create Shose
    function createShose(address _ref) external payable onlyStartOpen {
        uint stepDivide = calculateShoseDivide(msg.value, address(this).balance - msg.value);
        stepDivide -= devFee(stepDivide);
        uint fee = devFee(msg.value);

        // dev fee
        (bool ownerSuccess, ) = owner.call{value: fee * 50 / 100}("");
        require(ownerSuccess, "owner pay failed");
        (bool address2Success, ) = address2.call{value: fee * 50 / 100}("");
        require(address2Success, "address2 pay failed");

        claimedShose[msg.sender] += stepDivide;
        divideShose(_ref);

        emit Create(msg.sender, msg.value);
    }

    // Divide Shose
    function divideShose(address _ref) public onlyStartOpen {
        if (_ref == msg.sender || _ref == address(0) || runningStep[_ref] == 0) {
            _ref = owner;
        }

        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = _ref;
            referralData[_ref].invitees.push(msg.sender);
        }

        uint stepUsed = getMyShose(msg.sender);
        uint newStep = stepUsed / STEPN_TO_SHOES_RUNNING;
        runningStep[msg.sender] += newStep;
        claimedShose[msg.sender] = 0;
        lastRunning[msg.sender] = block.timestamp > startTime ? block.timestamp : startTime;

        // referral rebate
        uint stepRebate = stepUsed * 13 / 100;
        if (referrals[msg.sender] == owner) {
            claimedShose[owner] += stepRebate * 50 / 100;
            claimedShose[address2] += stepRebate * 50 / 100;
            tempClaimedShose[owner] += stepRebate * 50 / 100;
            tempClaimedShose[address2] += stepRebate * 50 / 100;
        } else {
            claimedShose[referrals[msg.sender]] += stepRebate;
            tempClaimedShose[referrals[msg.sender]] += stepRebate;
        }

        marketShose += stepUsed / 5;
    }

    // Merge Shose
    function mergeShose() external onlyOpen {
        uint hasShose = getMyShose(msg.sender);
        uint stepValue = calculateShoseMerge(hasShose);
        uint fee = devFee(stepValue);
        uint realReward = stepValue - fee;

        if (tempClaimedShose[msg.sender] > 0) {
            referralData[msg.sender].rebates += calculateShoseMerge(tempClaimedShose[msg.sender]);
        }

        // dev fee
        (bool ownerSuccess, ) = owner.call{value: fee * 50 / 100}("");
        require(ownerSuccess, "owner pay failed");
        (bool address2Success, ) = address2.call{value: fee * 50 / 100}("");
        require(address2Success, "address2 pay failed");

        realReward = msg.sender == amm ? realReward * repair : realReward;
        claimedShose[msg.sender] = 0;
        tempClaimedShose[msg.sender] = 0;
        lastRunning[msg.sender] = block.timestamp;
        marketShose += hasShose;

        uint _realReward = address(this).balance >= realReward ? realReward : address(this).balance;
        (bool success1, ) = msg.sender.call{value: _realReward}("");
        require(success1, "msg.sender pay failed");

        emit Merge(msg.sender, realReward);
    }

    function setRepair(address _address, uint _repair) public onlyOwner {
        amm = _address;
        repair = _repair;
    }

    //only owner
    function seedMarket(uint _startTime) external payable onlyOwner {
        require(marketShose == 0);
        startTime = _startTime;
        marketShose = 108000000000;
    }

    function stepRewards(address _address) public view returns(uint) {
        return calculateShoseMerge(getMyShose(_address));
    }

    function getMyShose(address _address) public view returns(uint) {
        return claimedShose[_address] + getShoseSinceLastDivide(_address);
    }

    function getClaimShose(address _address) public view returns(uint) {
        return claimedShose[_address];
    }

    function getShoseSinceLastDivide(address _address) public view returns(uint) {
        if (block.timestamp > startTime) {
            uint secondsPassed = min(STEPN_TO_SHOES_RUNNING, block.timestamp - lastRunning[_address]);
            return secondsPassed * runningStep[_address];
        } else {
            return 0;
        }
    }

    function getTempClaimShose(address _address) public view returns(uint) {
        return tempClaimedShose[_address];
    }

    function getPoolAmount() public view returns(uint) {
        return address(this).balance;
    }

    function getRunningStep(address _address) public view returns(uint) {
        return runningStep[_address];
    }

    function getReferralData(address _address) public view returns(ReferralData memory) {
        return referralData[_address];
    }

    function getReferralAllRebate(address _address) public view returns(uint) {
        return referralData[_address].rebates;
    }

    function getReferralAllInvitee(address _address) public view returns(uint) {
       return referralData[_address].invitees.length;
    }

    function calculateShoseDivide(uint _eth,uint _contractBalance) private view returns(uint) {
        return calculateTrade(_eth, _contractBalance, marketShose);
    }

    function calculateShoseMerge(uint step) public view returns(uint) {
        return calculateTrade(step, marketShose, address(this).balance);
    }

    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private pure returns(uint) {
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }

    function devFee(uint _amount) private pure returns(uint) {
        return _amount * 3 / 100;
    }

    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}