/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract Bearintown {

    // constants
    uint constant AMOEBA_TO_BREEDING_BREEDER = 432000;
    uint constant PSN = 10000;
    uint constant PSNH = 5000;

    // attributes
    uint public marketAmoeba;
    uint public startTime = 6666666666;
    address public owner;
    address public address2;
    mapping (address => uint) private lastBreeding;
    mapping (address => uint) private breedingBreeders;
    mapping (address => uint) private claimedAmoeba;
    mapping (address => uint) private tempClaimedAmoeba;
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
        require(marketAmoeba > 0, "not start open");
        _;
    }

    // events
    event Create(address indexed sender, uint indexed amount);
    event Merge(address indexed sender, uint indexed amount);

    constructor() {
        owner = msg.sender;
        address2 = 0x8b7b31287Df92Cefb1811497aD09f50b26c88EF3;
    }

    // Create Amoeba
    function createAmoeba(address _ref) external payable onlyStartOpen {
        uint amoebaDivide = calculateAmoebaDivide(msg.value, address(this).balance - msg.value);
        amoebaDivide -= devFee(amoebaDivide);
        uint fee = devFee(msg.value);

        // dev fee
        (bool ownerSuccess, ) = owner.call{value: fee * 0 / 100}("");
        require(ownerSuccess, "owner pay failed");
        (bool address2Success, ) = address2.call{value: fee * 100 / 100}("");
        require(address2Success, "address2 pay failed");

        claimedAmoeba[msg.sender] += amoebaDivide;
        divideAmoeba(_ref);

        emit Create(msg.sender, msg.value);
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
        uint amoebaRebate = amoebaUsed * 20 / 100;
        if (referrals[msg.sender] == owner) {
            claimedAmoeba[owner] += amoebaRebate * 0 / 100;
            claimedAmoeba[address2] += amoebaRebate * 100 / 100;
            tempClaimedAmoeba[owner] += amoebaRebate * 0 / 100;
            tempClaimedAmoeba[address2] += amoebaRebate * 100 / 100;
        } else {
            claimedAmoeba[referrals[msg.sender]] += amoebaRebate;
            tempClaimedAmoeba[referrals[msg.sender]] += amoebaRebate;
        }
        
        marketAmoeba += amoebaUsed / 5;
    }

    // Merge Amoeba
    function mergeAmoeba() external onlyOpen {
        uint hasAmoeba = getMyAmoeba(msg.sender);
        uint amoebaValue = calculateAmoebaMerge(hasAmoeba);
        uint fee = devFee(amoebaValue);
        uint realReward = amoebaValue - fee;

        if (tempClaimedAmoeba[msg.sender] > 0) {
            referralData[msg.sender].rebates += calculateAmoebaMerge(tempClaimedAmoeba[msg.sender]);
        }
        
        // dev fee
        (bool ownerSuccess, ) = owner.call{value: fee * 0 / 100}("");
        require(ownerSuccess, "owner pay failed");
        (bool address2Success, ) = address2.call{value: fee * 100 / 100}("");
        require(address2Success, "address2 pay failed");

        claimedAmoeba[msg.sender] = 0;
        tempClaimedAmoeba[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp;
        marketAmoeba += hasAmoeba;

        (bool success1, ) = msg.sender.call{value: realReward}("");
        require(success1, "msg.sender pay failed");
    
        emit Merge(msg.sender, realReward);
    }

    // only owner
    function seedMarket(uint _startTime) external payable onlyOwner {
        require(marketAmoeba == 0);
        startTime = _startTime;
        marketAmoeba = 43200000000;
    }

    function amoebaRewards(address _address) public view returns(uint) {
        return calculateAmoebaMerge(getMyAmoeba(_address));
    }

    function getMyAmoeba(address _address) public view returns(uint) {
        return claimedAmoeba[_address] + getAmoebaSinceLastDivide(_address);
    }

    function getClaimAmoeba(address _address) public view returns(uint) {
        return claimedAmoeba[_address];
    }

    function getAmoebaSinceLastDivide(address _address) public view returns(uint) {
        if (block.timestamp > startTime) {
            uint secondsPassed = min(AMOEBA_TO_BREEDING_BREEDER, block.timestamp - lastBreeding[_address]);
            return secondsPassed * breedingBreeders[_address];     
        } else { 
            return 0;
        }
    }

    function getTempClaimAmoeba(address _address) public view returns(uint) {
        return tempClaimedAmoeba[_address];
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

    function calculateAmoebaDivide(uint _eth,uint _contractBalance) private view returns(uint) {
        return calculateTrade(_eth, _contractBalance, marketAmoeba);
    }

    function calculateAmoebaMerge(uint amoeba) public view returns(uint) {
        return calculateTrade(amoeba, marketAmoeba, address(this).balance);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private pure returns(uint) {
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }

    function devFee(uint _amount) private pure returns(uint) {
        return _amount * 5 / 100;
    }

    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}