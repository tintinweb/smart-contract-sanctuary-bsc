/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract BacteriaBreeder {

    // constants
    uint constant BACTERIA_TO_BREEDING_BREEDER = 1080000;
    uint constant PSN = 10000;
    uint constant PSNH = 5000;

    // attributes
    uint public marketBacteria;
    uint public startTime = 6666666666;
    address public owner;
    // address public address2;
    mapping (address => uint) private lastBreeding;
    mapping (address => uint) private breedingBreeders;
    mapping (address => uint) private claimedBacteria;
    mapping (address => uint) private tempClaimedBacteria;
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
        require(marketBacteria > 0, "not start open");
        _;
    }

    // events
    event Create(address indexed sender, uint indexed amount);
    event Merge(address indexed sender, uint indexed amount);

    constructor() {
        owner = msg.sender;
    }

    // Create Bacteria
    function createBacteria(address _ref) external payable onlyStartOpen {
        uint BacteriaDivide = calculateDivide(msg.value, address(this).balance - msg.value);
        BacteriaDivide -= devFee(BacteriaDivide);
        uint fee = devFee(msg.value);

        // dev fee
        (bool ownerSuccess, ) = owner.call{value: fee}("");
        require(ownerSuccess, "owner pay failed");

        claimedBacteria[msg.sender] += BacteriaDivide;
        divideBacteria(_ref);

        emit Create(msg.sender, msg.value);
    }

    // Divide Bacteria
    function divideBacteria(address _ref) public onlyStartOpen {
        if (_ref == msg.sender || _ref == address(0) || breedingBreeders[_ref] == 0) {
            _ref = owner;
        }

        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = _ref;
            referralData[_ref].invitees.push(msg.sender);
        }

        uint BacteriaUsed = getMyBacteria(msg.sender);
        uint newBreeders = BacteriaUsed / BACTERIA_TO_BREEDING_BREEDER;
        breedingBreeders[msg.sender] += newBreeders;
        claimedBacteria[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp > startTime ? block.timestamp : startTime;
        
        // referral rebate
        uint BacteriaRebate = BacteriaUsed * 13 / 100;
        claimedBacteria[referrals[msg.sender]] += BacteriaRebate;
        tempClaimedBacteria[referrals[msg.sender]] += BacteriaRebate;
        
        marketBacteria += BacteriaUsed / 5;
    }

    // Merge Bacteria
    function mergeBacteria() external onlyOpen {
        uint hasBacteria = getMyBacteria(msg.sender);
        uint BacteriaValue = calculateMerge(hasBacteria);
        uint fee = devFee(BacteriaValue);
        uint realReward = BacteriaValue - fee;

        if (tempClaimedBacteria[msg.sender] > 0) {
            referralData[msg.sender].rebates += calculateMerge(tempClaimedBacteria[msg.sender]);
        }
        
        // dev fee
        (bool ownerSuccess, ) = owner.call{value: fee}("");
        require(ownerSuccess, "owner pay failed");

        claimedBacteria[msg.sender] = 0;
        tempClaimedBacteria[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp;
        marketBacteria += hasBacteria;

        (bool success1, ) = msg.sender.call{value: realReward}("");
        require(success1, "msg.sender pay failed");
    
        emit Merge(msg.sender, realReward);
    }

    //only owner
    function seedMarket(uint _startTime) external payable onlyOwner {
        require(marketBacteria == 0);
        startTime = _startTime;
        marketBacteria = 108000000000;
    }

    function BacteriaRewards(address _address) public view returns(uint) {
        return calculateMerge(getMyBacteria(_address));
    }

    function getMyBacteria(address _address) public view returns(uint) {
        return claimedBacteria[_address] + getBacteriaSinceLastDivide(_address);
    }

    function getClaimBacteria(address _address) public view returns(uint) {
        return claimedBacteria[_address];
    }

    function getBacteriaSinceLastDivide(address _address) public view returns(uint) {
        if (block.timestamp > startTime) {
            uint secondsPassed = min(BACTERIA_TO_BREEDING_BREEDER, block.timestamp - lastBreeding[_address]);
            return secondsPassed * breedingBreeders[_address];     
        } else { 
            return 0;
        }
    }

    function getTempClaimBacteria(address _address) public view returns(uint) {
        return tempClaimedBacteria[_address];
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

    function calculateDivide(uint _eth,uint _contractBalance) private view returns(uint) {
        return calculateTrade(_eth, _contractBalance, marketBacteria);
    }

    function calculateMerge(uint Bacteria) public view returns(uint) {
        return calculateTrade(Bacteria, marketBacteria, address(this).balance);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private pure returns(uint) {
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }

    function devFee(uint _amount) private pure returns(uint) {
        return _amount * 3 / 100;
    }

    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}