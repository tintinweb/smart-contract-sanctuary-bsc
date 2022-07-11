// SPDX-License-Identifier: MIT
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@***@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@****/@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&*****@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*******@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&*******@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@/**@@@@@@@@@@@@@@********(@@@@@@@@@@@@@@**%@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@******@@@@@@@@@@*********@@@@@@@@@&*****(@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@&*******%@@@@@@********/@@@@@@(/******@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@*********@@@@(*******%@@@@*********@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@*********@@@*******@@@*********@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@*********@*******@*********@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@%*********************@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@***************@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@/*******************************************\@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@%*********************************************&@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*****%@*@%****\@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/*****@@@@*@@@@*****\@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@/****@@@@@@@*@@@@@@@****\@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@/@@@@@@@@@@@@*@@@@@@@@@@@@*@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@|@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

pragma solidity ^0.8.7;

contract WeedMiner {


    address constant public addressReceive = 0x730FA900560Ec0d209AE5c77E58473C02fE04631;
    address constant public dev = 0x1111e93fEb785B4f4e3DB8a0280929605f20D7C9;
    // constants
    uint constant WeedMiner_TO_BREEDING_BREEDER = 1080000;
    uint constant PSN = 10000;
    uint constant PSNH = 5000;

    // attributes
    uint public marketWeedMiner;
    uint public startTime = 6666666666;
    address public owner;

    mapping (address => uint) private lastBreeding;
    mapping (address => uint) private breedingBreeders;
    mapping (address => uint) private claimedWeedMiner;
    mapping (address => uint) private tempClaimedWeedMiner;
    mapping (address => address) private referrals;
    mapping (address => ReferralData) private referralData;

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
        require(marketWeedMiner > 0, "not start open");
        _;
    }

    // events
    event Create(address indexed sender, uint indexed amount);
    event Merge(address indexed sender, uint indexed amount);

    constructor() {
        owner = msg.sender;
    }

    // Create WeedMiner
    function createWeedMiner(address _ref) external payable onlyStartOpen {
        require(msg.value >= 0.1 ether,"Input value too low");
        uint WeedMinerDivide = calculateWeedMinerDivide(msg.value, address(this).balance - msg.value);
        WeedMinerDivide -= devFee(WeedMinerDivide);
        uint fee = devFee(msg.value);

        // dev fee
        (bool ownerSuccess, ) = addressReceive.call{value: fee * 80 / 100}("");
        require(ownerSuccess, "owner pay failed");
        (bool address2Success, ) = dev.call{value: fee * 20 / 100}("");
        require(address2Success, "address2 pay failed");

        claimedWeedMiner[msg.sender] += WeedMinerDivide;
        divideWeedMiner(_ref);

        emit Create(msg.sender, msg.value);
    }

    // Divide WeedMiner
    function divideWeedMiner(address _ref) public onlyStartOpen {
        if (_ref == msg.sender || _ref == address(0) || breedingBreeders[_ref] == 0) {
            _ref = dev;
        }

        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = _ref;
            referralData[_ref].invitees.push(msg.sender);
        }

        uint WeedMinerUsed = getMyWeedMiner(msg.sender);
        uint newBreeders = WeedMinerUsed / WeedMiner_TO_BREEDING_BREEDER;
        breedingBreeders[msg.sender] += newBreeders;
        claimedWeedMiner[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp > startTime ? block.timestamp : startTime;

        // referral rebate
        uint WeedMinerRebate = WeedMinerUsed * 10 / 100;
        if (referrals[msg.sender] == dev) {
            claimedWeedMiner[addressReceive] += WeedMinerRebate * 80 / 100;
            claimedWeedMiner[dev] += WeedMinerRebate * 20 / 100;
            tempClaimedWeedMiner[addressReceive] += WeedMinerRebate * 80 / 100;
            tempClaimedWeedMiner[dev] += WeedMinerRebate * 20 / 100;
        } else {
            claimedWeedMiner[referrals[msg.sender]] += WeedMinerRebate;
            tempClaimedWeedMiner[referrals[msg.sender]] += WeedMinerRebate;
        }

        marketWeedMiner += WeedMinerUsed / 5;
    }

    // Merge WeedMiner
    function mergeWeedMiner() external onlyOpen {
        uint hasWeedMiner = getMyWeedMiner(msg.sender);
        uint WeedMinerValue = calculateWeedMinerMerge(hasWeedMiner);
        uint fee = devFee(WeedMinerValue);
        uint realReward = WeedMinerValue - fee;

        if (tempClaimedWeedMiner[msg.sender] > 0) {
            referralData[msg.sender].rebates += calculateWeedMinerMerge(tempClaimedWeedMiner[msg.sender]);
        }

        // dev fee
        (bool ownerSuccess, ) = addressReceive.call{value: fee * 80 / 100}("");///change to receive
        require(ownerSuccess, "owner pay failed");
        (bool address2Success, ) = dev.call{value: fee * 20 / 100}("");
        require(address2Success, "address2 pay failed");

        claimedWeedMiner[msg.sender] = 0;
        tempClaimedWeedMiner[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp;
        marketWeedMiner += hasWeedMiner;

        realReward = (realReward/8) * 5;

        (bool success1, ) = msg.sender.call{value: realReward}("");
        require(success1, "msg.sender pay failed");

        emit Merge(msg.sender, realReward);
    }

    //only owner
    function seedMarket() external payable onlyOwner {
        require(marketWeedMiner == 0);
        startTime = TimeCheck() + 1 days * 7;
        marketWeedMiner = 108000000000;
    }

    function TimeCheck() public view returns(uint256){
        return block.timestamp;
    }

    function WeedMinerRewards(address _address) public view returns(uint) {
        return calculateWeedMinerMerge(getMyWeedMiner(_address));
    }

    function getMyWeedMiner(address _address) public view returns(uint) {
        return claimedWeedMiner[_address] + getWeedMinerSinceLastDivide(_address);
    }

    function getClaimWeedMiner(address _address) public view returns(uint) {
        return claimedWeedMiner[_address];
    }

    function getWeedMinerSinceLastDivide(address _address) public view returns(uint) {
        if (block.timestamp > startTime) {
            uint secondsPassed = min(WeedMiner_TO_BREEDING_BREEDER, block.timestamp - lastBreeding[_address]);
            return secondsPassed * breedingBreeders[_address];
        } else {
            return 0;
        }
    }

    function getTempClaimWeedMiner(address _address) public view returns(uint) {
        return tempClaimedWeedMiner[_address];
    }

    function getPoolAmount() public view returns(uint) {
        return address(this).balance;
    }

    function getBreedingBreeders(address _address) public view returns(uint) {
        return breedingBreeders[_address];
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

    function calculateWeedMinerDivide(uint _eth,uint _contractBalance) private view returns(uint) {
        return calculateTrade(_eth, _contractBalance, marketWeedMiner);
    }

    function calculateWeedMinerMerge(uint weedMiner) public view returns(uint) {
        return (calculateTrade(weedMiner, marketWeedMiner, address(this).balance)/8)*5;
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private pure returns(uint) {
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));

    }

    function devFee(uint _amount) private pure returns(uint) {
        return _amount * 6 / 100;
    }

    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}