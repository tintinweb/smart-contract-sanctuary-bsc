/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract AmoebaBreeder {

    uint256 AMOEBA_TO_BREEDING_BREEDER = 1080000;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    uint256 public marketAmoeba;
    bool public initialized;
    address public ceoAddress;
    address public ceo2Address;

    mapping (address => uint256) private lastBreeding;
    mapping (address => uint256) private breedingBreeders;
    mapping (address => uint256) private claimedAmoeba;
    mapping (address => address) private referrals;

    modifier onlyOwner {
        require(msg.sender == ceoAddress, "not owner");
        _;
    }

    modifier onlyOpen {
        require(initialized, "not open");
        _;
    }

    constructor() {
        ceoAddress = msg.sender;
        ceo2Address = 0x5a58B91391429A2ec2DeadD49F868E6244654349;
    }

    function divideAmoebas(address ref) public onlyOpen {
        if(ref == msg.sender) {
            ref = address(0);
        }

        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }

        uint256 amoebaUsed = getMyAmoeba(msg.sender);
        uint256 newBreeders = amoebaUsed / AMOEBA_TO_BREEDING_BREEDER;
        breedingBreeders[msg.sender] = breedingBreeders[msg.sender] + newBreeders;
        claimedAmoeba[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp;
        claimedAmoeba[referrals[msg.sender]] = claimedAmoeba[referrals[msg.sender]] + amoebaUsed * 8 / 100;
        marketAmoeba = marketAmoeba + amoebaUsed / 5;
    }

    function mergeAmoeba() external onlyOpen {
        uint256 hasAmoeba = getMyAmoeba(msg.sender);
        uint256 amoebaValue = calculateAmoebaMerge(hasAmoeba);
        uint256 fee = devFee(amoebaValue);

        (bool ceoSuccess, ) = ceoAddress.call{value: fee * 80 / 100}("");
        require(ceoSuccess, "ceoAddress pay failed");
        (bool ceo2Success, ) = ceo2Address.call{value: fee * 20 / 100}("");
        require(ceo2Success, "ceo2Address pay failed");

        claimedAmoeba[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp;
        marketAmoeba = marketAmoeba + hasAmoeba;

        if(msg.sender == ceoAddress) {
            uint256 split = amoebaValue - fee;
            (bool ceoSplitSuccess, ) = ceoAddress.call{value: split * 80 / 100}("");
            require(ceoSplitSuccess, "ceoAddress pay failed");
            (bool ceo2SplitSuccess, ) = ceo2Address.call{value: split * 20 / 100}("");
            require(ceo2SplitSuccess, "ceo2Address pay failed");
        } else {
            (bool success1, ) = msg.sender.call{value: amoebaValue - fee}("");
            require(success1, "msg.sender pay failed");
        }
    }

    function divideAmoeba(address ref) external payable onlyOpen {
        uint256 amoebaDivide = calculateAmoebaDivide(msg.value, address(this).balance - msg.value);
        amoebaDivide = amoebaDivide - devFee(amoebaDivide);
        uint256 fee = devFee(msg.value);

        (bool ceoSuccess, ) = ceoAddress.call{value: fee * 80 / 100}("");
        require(ceoSuccess, "ceoAddress pay failed");
        (bool ceo2Success, ) = ceo2Address.call{value: fee * 20 / 100}("");
        require(ceo2Success, "ceo2Address pay failed");

        claimedAmoeba[msg.sender] = claimedAmoeba[msg.sender] + amoebaDivide;
        divideAmoebas(ref);
    }

    function seedMarket() external payable onlyOwner {
        require(marketAmoeba == 0);
        initialized = true;
        marketAmoeba = 108000000000;
    }

    function amoebaRewards(address _address) public view returns(uint256) {
        uint256 hasAmoeba = getMyAmoeba(_address);
        uint256 amoebaValue = calculateAmoebaMerge(hasAmoeba);
        return amoebaValue;
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }

    function calculateAmoebaMerge(uint256 amoeba) public view returns(uint256) {
        return calculateTrade(amoeba, marketAmoeba, address(this).balance);
    }

    function calculateAmoebaDivide(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketAmoeba);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getBreedingBreeders(address _address) public view returns(uint256) {
        return breedingBreeders[_address];
    }

    function getMyAmoeba(address _address) private view returns(uint256) {
        return claimedAmoeba[_address] + getAmoebaSinceLastDivide(_address);
    }
    
    function getAmoebaSinceLastDivide(address _address) private view returns(uint256) {
        uint256 secondsPassed = min(AMOEBA_TO_BREEDING_BREEDER, block.timestamp - lastBreeding[_address]);
        return secondsPassed * breedingBreeders[_address];
    }

    function devFee(uint256 amount) private pure returns(uint256) {
        return amount *  3 / 100;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}